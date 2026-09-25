import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The painted surface of a floating container: dialogs, drawers,
/// popovers, tooltips and toasts.
///
/// Paints [color] (default `overlay`) in [shape] with the [shadow] token
/// (default `shadow-overlay`): the layered drop shadows in light mode and
/// the faint inner highlight (`inset 0 0 1px rgba(255,255,255,.3)`) in dark
/// mode. The [child] is clipped to [shape] (`overflow-clip`).
///
/// [side] draws a border inside the shape and [backdropBlur] blurs what is
/// behind a translucent surface (`backdrop-blur-*`).
class HeroOverlaySurface extends StatelessWidget {
  /// Creates an overlay surface.
  const HeroOverlaySurface({
    super.key,
    required this.shape,
    required this.child,
    this.color,
    this.shadow,
    this.shadows,
    this.side = BorderSide.none,
    this.backdropBlur = 0,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The outline of the surface.
  final ShapeBorder shape;

  /// The content.
  final Widget child;

  /// Fill color; defaults to the `overlay` token.
  final Color? color;

  /// The shadow token; defaults to the theme's overlay shadow.
  final HeroShadow? shadow;

  /// Replaces the drop shadows of [shadow] (`shadow-*` utilities).
  final List<BoxShadow>? shadows;

  /// A border drawn inside the shape.
  final BorderSide side;

  /// Standard deviation of a blur applied to what is behind the surface.
  final double backdropBlur;

  /// How the content is clipped to [shape].
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroShadow shadow = this.shadow ?? theme.shadows.overlay;
    final TextDirection? direction = Directionality.maybeOf(context);
    final Color fill = color ?? theme.colors.overlay;

    Widget content = child;
    if (clipBehavior != Clip.none) {
      content = ClipPath(
        clipper: ShapeBorderClipper(shape: shape, textDirection: direction),
        clipBehavior: clipBehavior,
        child: content,
      );
    }
    final Color? inset = shadow.insetColor;
    if (inset != null || side.style != BorderStyle.none) {
      content = CustomPaint(
        painter: _HeroOverlayChromePainter(
          shape: shape,
          inset: inset,
          insetBlur: Shadow.convertRadiusToSigma(theme.spacing(0.25)),
          side: side,
          textDirection: direction,
        ),
        child: content,
      );
    }
    Widget surface = DecoratedBox(
      decoration: ShapeDecoration(color: fill, shape: shape),
      child: content,
    );
    if (backdropBlur > 0) {
      surface = ClipPath(
        clipper: ShapeBorderClipper(shape: shape, textDirection: direction),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: backdropBlur, sigmaY: backdropBlur),
          child: surface,
        ),
      );
    }
    final List<BoxShadow> drop = shadows ?? shadow.boxShadows;
    if (drop.isNotEmpty) {
      surface = DecoratedBox(
        decoration: ShapeDecoration(shape: shape, shadows: drop),
        child: surface,
      );
    }
    return surface;
  }
}

/// Paints the inner highlight of dark overlay shadows and a border inside
/// the shape.
class _HeroOverlayChromePainter extends CustomPainter {
  const _HeroOverlayChromePainter({
    required this.shape,
    required this.inset,
    required this.insetBlur,
    required this.side,
    required this.textDirection,
  });

  final ShapeBorder shape;
  final Color? inset;
  final double insetBlur;
  final BorderSide side;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path outer = shape.getOuterPath(rect, textDirection: textDirection);
    final Color? inset = this.inset;
    if (inset != null) {
      // `box-shadow: inset 0 0 1px`: the area outside the shape, blurred
      // back inside it.
      canvas
        ..save()
        ..clipPath(outer)
        ..drawPath(
          Path.combine(
            PathOperation.difference,
            Path()..addRect(rect.inflate(insetBlur * 4)),
            outer,
          ),
          Paint()
            ..color = inset
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, insetBlur),
        )
        ..restore();
    }
    if (side.style != BorderStyle.none && side.width > 0) {
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          outer,
          _deflated(rect, side.width),
        ),
        Paint()..color = side.color,
      );
    }
  }

  /// The outline of [shape] inset by [width], with radii reduced by the
  /// same amount like the inner edge of a CSS border.
  Path _deflated(Rect rect, double width) {
    final ShapeBorder shrunk = switch (shape) {
      RoundedSuperellipseBorder(:final BorderRadiusGeometry borderRadius) =>
        RoundedSuperellipseBorder(borderRadius: _shrink(borderRadius, width)),
      RoundedRectangleBorder(:final BorderRadiusGeometry borderRadius) =>
        RoundedRectangleBorder(borderRadius: _shrink(borderRadius, width)),
      _ => shape,
    };
    return shrunk.getOuterPath(
      rect.deflate(width),
      textDirection: textDirection,
    );
  }

  BorderRadius _shrink(BorderRadiusGeometry radius, double by) {
    final BorderRadius r = radius.resolve(textDirection ?? TextDirection.ltr);
    Radius s(Radius x) => Radius.elliptical(
      (x.x - by).clamp(0.0, double.infinity),
      (x.y - by).clamp(0.0, double.infinity),
    );
    return BorderRadius.only(
      topLeft: s(r.topLeft),
      topRight: s(r.topRight),
      bottomLeft: s(r.bottomLeft),
      bottomRight: s(r.bottomRight),
    );
  }

  @override
  bool shouldRepaint(_HeroOverlayChromePainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.inset != inset ||
      oldDelegate.insetBlur != insetBlur ||
      oldDelegate.side != side ||
      oldDelegate.textDirection != textDirection;
}
