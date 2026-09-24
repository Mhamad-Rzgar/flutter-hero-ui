import 'package:flutter/widgets.dart';

import '../theme/hero_theme.dart';
import '../theme/hero_theme_data.dart';
import '../tokens/hero_motion.dart';

/// Paints HeroUI's focus ring around [child] without affecting layout.
///
/// Reproduces Tailwind's `ring-2 ring-focus ring-offset-2
/// ring-offset-background` (the `status-focused` utility): a band of
/// [HeroThemeData.focusRingWidth] in the focus color, separated from the
/// component by a [HeroThemeData.focusRingOffset] gap filled with the page
/// background. Form fields use `offset: 0` (`focus-field-ring`).
///
/// The ring follows [shape], so it matches continuous or circular corners,
/// stadiums and circles. It fades in over 100 ms like HeroUI's box-shadow
/// transition.
class HeroFocusRing extends StatelessWidget {
  /// Wraps [child] with a focus ring that shows when [visible] is true.
  const HeroFocusRing({
    super.key,
    required this.visible,
    required this.shape,
    required this.child,
    this.color,
    this.width,
    this.offset,
    this.offsetColor,
  });

  /// Whether the ring is shown.
  final bool visible;

  /// The outline of the component the ring surrounds.
  final ShapeBorder shape;

  /// The ringed component.
  final Widget child;

  /// Ring color; defaults to the `focus` token.
  final Color? color;

  /// Ring width; defaults to [HeroThemeData.focusRingWidth].
  final double? width;

  /// Gap between component and ring; defaults to
  /// [HeroThemeData.focusRingOffset].
  final double? offset;

  /// Gap fill color; defaults to the `background` token.
  final Color? offsetColor;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: visible ? 1 : 0),
      duration: theme.motion.resolve(context, HeroMotion.fast),
      curve: HeroMotion.easeOut,
      child: child,
      builder: (BuildContext context, double t, Widget? child) {
        if (t == 0) return child!;
        return CustomPaint(
          foregroundPainter: HeroFocusRingPainter(
            shape: shape,
            color: (color ?? theme.colors.focus),
            width: width ?? theme.focusRingWidth,
            offset: offset ?? theme.focusRingOffset,
            offsetColor: offsetColor ?? theme.colors.background,
            opacity: t,
            textDirection: Directionality.maybeOf(context),
          ),
          child: child,
        );
      },
    );
  }
}

/// Paints a focus ring (and its offset gap) outside a [shape].
class HeroFocusRingPainter extends CustomPainter {
  /// Creates a focus ring painter.
  const HeroFocusRingPainter({
    required this.shape,
    required this.color,
    required this.width,
    required this.offset,
    required this.offsetColor,
    this.opacity = 1,
    this.textDirection,
  });

  /// Outline of the ringed component.
  final ShapeBorder shape;

  /// Ring color.
  final Color color;

  /// Ring width.
  final double width;

  /// Gap between component and ring.
  final double offset;

  /// Gap fill color.
  final Color offsetColor;

  /// Overall opacity, used for the fade transition.
  final double opacity;

  /// Text direction for directional border radii.
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path inner = heroInflatedShapePath(shape, rect, 0, textDirection);
    final Path gap = heroInflatedShapePath(shape, rect, offset, textDirection);
    final Path outer = heroInflatedShapePath(
      shape,
      rect,
      offset + width,
      textDirection,
    );
    if (offset > 0) {
      canvas.drawPath(
        Path.combine(PathOperation.difference, gap, inner),
        Paint()..color = offsetColor.withValues(alpha: offsetColor.a * opacity),
      );
    }
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, offset > 0 ? gap : inner),
      Paint()..color = color.withValues(alpha: color.a * opacity),
    );
  }

  @override
  bool shouldRepaint(HeroFocusRingPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.offset != offset ||
      oldDelegate.offsetColor != offsetColor ||
      oldDelegate.opacity != opacity ||
      oldDelegate.textDirection != textDirection;
}

/// Returns the outer path of [shape] for [rect] grown outwards by [delta],
/// growing corner radii by the same amount (like CSS box-shadow spread).
Path heroInflatedShapePath(
  ShapeBorder shape,
  Rect rect,
  double delta, [
  TextDirection? textDirection,
]) {
  final Rect grown = rect.inflate(delta);
  if (delta == 0) return shape.getOuterPath(rect, textDirection: textDirection);
  final ShapeBorder inflated = switch (shape) {
    RoundedSuperellipseBorder(:final BorderRadiusGeometry borderRadius) =>
      RoundedSuperellipseBorder(
        borderRadius: _grow(borderRadius, delta, textDirection),
      ),
    RoundedRectangleBorder(:final BorderRadiusGeometry borderRadius) =>
      RoundedRectangleBorder(
        borderRadius: _grow(borderRadius, delta, textDirection),
      ),
    ContinuousRectangleBorder(:final BorderRadiusGeometry borderRadius) =>
      ContinuousRectangleBorder(
        borderRadius: _grow(borderRadius, delta, textDirection),
      ),
    _ => shape,
  };
  return inflated.getOuterPath(grown, textDirection: textDirection);
}

BorderRadius _grow(
  BorderRadiusGeometry radius,
  double delta,
  TextDirection? textDirection,
) {
  final BorderRadius r = radius.resolve(textDirection ?? TextDirection.ltr);
  Radius g(Radius x) => x == Radius.zero
      ? Radius.zero
      : Radius.elliptical(x.x + delta, x.y + delta);
  return BorderRadius.only(
    topLeft: g(r.topLeft),
    topRight: g(r.topRight),
    bottomLeft: g(r.bottomLeft),
    bottomRight: g(r.bottomRight),
  );
}
