/// HeroUI's ColorSwatch: a visual preview of a color value.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../color/color.dart';

export '../color/color.dart';

/// The size of a [HeroColorSwatch] (HeroUI's `size` prop), also used by
/// `HeroColorSwatchPicker`.
enum HeroColorSwatchSize {
  /// 16 × 16 (`size-4`).
  xs,

  /// 24 × 24 (`size-6`).
  sm,

  /// 32 × 32 (`size-8`), the default.
  md,

  /// 36 × 36 (`size-9`).
  lg,

  /// 40 × 40 (`size-10`).
  xl;

  /// The side length of a swatch of this size.
  double extent(HeroThemeData theme) => theme.spacing(switch (this) {
    xs => 4,
    sm => 6,
    md => 8,
    lg => 9,
    xl => 10,
  });

  /// The corner radius of a circular swatch of this size: `rounded-lg`,
  /// `rounded-xl`, `rounded-2xl`, `rounded-3xl` and `rounded-3xl`, which
  /// make circles at the default `--radius`.
  double circleRadius(HeroRadii radii) => switch (this) {
    xs => radii.lg,
    sm => radii.xl,
    md => radii.xl2,
    lg || xl => radii.xl3,
  };
}

/// The shape of a [HeroColorSwatch] (HeroUI's `shape` prop), also the
/// `variant` of `HeroColorSwatchPicker`.
enum HeroColorSwatchShape {
  /// Fully rounded, the default.
  circle,

  /// A rounded square (`rounded-md`).
  square,
}

/// Builds per-color style overrides of a [HeroColorSwatch] (the `style`
/// render function, which receives the color).
typedef HeroColorSwatchStyleBuilder =
    HeroColorSwatchStyle Function(Color color);

/// Per-instance visual overrides of a [HeroColorSwatch] (the counterpart of
/// `className` and `style`).
@immutable
class HeroColorSwatchStyle with Diagnosticable {
  /// Creates swatch style overrides.
  const HeroColorSwatchStyle({
    this.size,
    this.borderRadius,
    this.gradient,
    this.shadows,
    this.ringColor,
  });

  /// The side length; defaults to the one of the swatch size.
  final double? size;

  /// The corner radius; defaults to the one of the shape and size.
  final BorderRadiusGeometry? borderRadius;

  /// Replaces the fill (the color over the checkerboard), like overriding
  /// the CSS `background`.
  final Gradient? gradient;

  /// Replaces the swatch box shadow, like overriding the CSS `box-shadow`.
  /// HeroUI's only shadow is the inset ring, so setting shadows removes it.
  final List<BoxShadow>? shadows;

  /// The color of the 1 px inset ring (`rgba(0, 0, 0, 0.1)` by default); a
  /// transparent color removes it.
  final Color? ringColor;

  /// Returns a copy where the non-null values of [other] win.
  HeroColorSwatchStyle merge(HeroColorSwatchStyle? other) {
    if (other == null) return this;
    return HeroColorSwatchStyle(
      size: other.size ?? size,
      borderRadius: other.borderRadius ?? borderRadius,
      gradient: other.gradient ?? gradient,
      shadows: other.shadows ?? shadows,
      ringColor: other.ringColor ?? ringColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroColorSwatchStyle &&
      other.size == size &&
      other.borderRadius == borderRadius &&
      other.gradient == gradient &&
      listEquals(other.shadows, shadows) &&
      other.ringColor == ringColor;

  @override
  int get hashCode => Object.hash(
    size,
    borderRadius,
    gradient,
    shadows == null ? null : Object.hashAll(shadows!),
    ringColor,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('size', size, defaultValue: null))
      ..add(
        DiagnosticsProperty<BorderRadiusGeometry>(
          'borderRadius',
          borderRadius,
          defaultValue: null,
        ),
      )
      ..add(ColorProperty('ringColor', ringColor, defaultValue: null));
  }
}

/// A visual preview of a color value (HeroUI `ColorSwatch`).
///
/// The color is painted over HeroUI's transparency checkerboard, so
/// translucent colors read as such, and a 1 px inset ring keeps light
/// colors visible on light backgrounds.
///
/// ```dart
/// const HeroColorSwatch(color: Color(0xFF0485F7), semanticLabel: 'Blue')
/// ```
///
/// * [size]: xs (16), sm (24), md (32, default), lg (36) or xl (40).
/// * [shape]: circle (default) or square (`rounded-md`).
/// * [color]: null inside a `HeroColorPicker` shows the picker color;
///   elsewhere it shows a transparent swatch.
///
/// The swatch is an image for assistive technology, labelled with
/// [colorName] (or a generated name such as "vibrant blue", see
/// [heroColorName]) followed by [semanticLabel]. It is not focusable.
class HeroColorSwatch extends StatelessWidget {
  /// Creates a color swatch.
  const HeroColorSwatch({
    super.key,
    this.color,
    this.colorName,
    this.shape = HeroColorSwatchShape.circle,
    this.size = HeroColorSwatchSize.md,
    this.style,
    this.styleBuilder,
    this.semanticLabel,
  });

  /// The color to preview; null uses the enclosing color picker's color.
  final Color? color;

  /// The accessible name of the color, replacing the generated name.
  final String? colorName;

  /// The shape of the swatch.
  final HeroColorSwatchShape shape;

  /// The size of the swatch.
  final HeroColorSwatchSize size;

  /// Visual overrides.
  final HeroColorSwatchStyle? style;

  /// Builds visual overrides from the displayed color (merged over
  /// [style]).
  final HeroColorSwatchStyleBuilder? styleBuilder;

  /// Accessibility context appended to the color name (`aria-label`).
  final String? semanticLabel;

  /// The color shown when there is no [color] and no picker (`#fff0`).
  static const Color transparent = Color(0x00FFFFFF);

  /// The accessibility label of a swatch showing [color].
  static String semanticsLabelFor(
    Color color, {
    String? colorName,
    String? semanticLabel,
  }) => <String?>[
    colorName ?? heroColorName(color),
    semanticLabel,
  ].whereType<String>().where((String part) => part.isNotEmpty).join(', ');

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Color resolved =
        color ??
        HeroColorPickerScope.maybeOf(context)?.value.toColor() ??
        transparent;
    final HeroColorSwatchStyle overrides =
        (style ?? const HeroColorSwatchStyle()).merge(
          styleBuilder?.call(resolved),
        );
    final double extent = overrides.size ?? size.extent(theme);
    final BorderRadiusGeometry radius =
        overrides.borderRadius ??
        BorderRadius.circular(
          shape == HeroColorSwatchShape.circle
              ? size.circleRadius(theme.radii)
              : theme.radii.md,
        );

    return Semantics(
      image: true,
      label: semanticsLabelFor(
        resolved,
        colorName: colorName,
        semanticLabel: semanticLabel,
      ),
      child: SizedBox.square(
        dimension: extent,
        child: CustomPaint(
          painter: HeroColorSwatchPainter(
            color: resolved,
            shape: theme.shape(radius),
            tileSize: theme.spacing(4),
            gradient: overrides.gradient,
            shadows: overrides.shadows,
            ringColor: overrides.ringColor ?? heroColorInsetRing(theme.colors),
            ringWidth: theme.spacing(0.25),
            textDirection: Directionality.maybeOf(context),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(StringProperty('colorName', colorName, defaultValue: null))
      ..add(
        EnumProperty<HeroColorSwatchShape>(
          'shape',
          shape,
          defaultValue: HeroColorSwatchShape.circle,
        ),
      )
      ..add(
        EnumProperty<HeroColorSwatchSize>(
          'size',
          size,
          defaultValue: HeroColorSwatchSize.md,
        ),
      );
  }
}

/// Paints a color swatch: outer [shadows], then the [color] over the
/// transparency checkerboard (or a [gradient]) clipped to [shape], then an
/// inset ring in [ringColor] (unless [shadows] replace it).
///
/// Shared by [HeroColorSwatch] and the swatches of the color swatch picker.
class HeroColorSwatchPainter extends CustomPainter {
  /// Creates a swatch painter.
  const HeroColorSwatchPainter({
    required this.color,
    required this.shape,
    required this.tileSize,
    this.gradient,
    this.shadows,
    this.ringColor,
    this.ringWidth = 1,
    this.textDirection,
  });

  /// The previewed color.
  final Color color;

  /// The outline of the swatch.
  final ShapeBorder shape;

  /// The checkerboard tile size.
  final double tileSize;

  /// A fill replacing the color and checkerboard.
  final Gradient? gradient;

  /// Outer shadows replacing the inset ring.
  final List<BoxShadow>? shadows;

  /// The color of the inset ring; null paints no ring.
  final Color? ringColor;

  /// The width of the inset ring.
  final double ringWidth;

  /// Text direction for directional radii.
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path outline = shape.getOuterPath(rect, textDirection: textDirection);
    final List<BoxShadow>? shadows = this.shadows;

    if (shadows != null && shadows.isNotEmpty) {
      double extent = 0;
      for (final BoxShadow shadow in shadows) {
        extent = math.max(
          extent,
          shadow.offset.distance + shadow.spreadRadius + shadow.blurRadius * 2,
        );
      }
      // CSS box shadows are only painted outside the border box.
      canvas
        ..save()
        ..clipPath(
          Path.combine(
            PathOperation.difference,
            Path()..addRect(rect.inflate(extent)),
            outline,
          ),
        );
      for (final BoxShadow shadow in shadows) {
        canvas.drawPath(
          heroInflatedShapePath(
            shape,
            rect.shift(shadow.offset),
            shadow.spreadRadius,
            textDirection,
          ),
          shadow.toPaint(),
        );
      }
      canvas.restore();
    }

    canvas
      ..save()
      ..clipPath(outline);
    final Gradient? gradient = this.gradient;
    if (gradient != null) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = gradient.createShader(rect, textDirection: textDirection),
      );
    } else {
      if (color.a < 1) HeroCheckerboard.paint(canvas, rect, tileSize: tileSize);
      if (color.a > 0) canvas.drawRect(rect, Paint()..color = color);
    }
    canvas.restore();

    final Color? ringColor = this.ringColor;
    if (ringColor != null &&
        shadows == null &&
        ringColor.a > 0 &&
        ringWidth > 0) {
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          outline,
          heroInflatedShapePath(shape, rect, -ringWidth, textDirection),
        ),
        Paint()..color = ringColor,
      );
    }
  }

  @override
  bool shouldRepaint(HeroColorSwatchPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.shape != shape ||
      oldDelegate.tileSize != tileSize ||
      oldDelegate.gradient != gradient ||
      !listEquals(oldDelegate.shadows, shadows) ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.ringWidth != ringWidth ||
      oldDelegate.textDirection != textDirection;
}
