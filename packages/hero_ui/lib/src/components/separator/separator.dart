import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';

/// The color variants of a [HeroSeparator] (the `variant` prop).
enum HeroSeparatorVariant {
  /// `--separator` (HeroUI's `default`).
  standard,

  /// `--separator-secondary`, for secondary surfaces.
  secondary,

  /// `--separator-tertiary`, for tertiary surfaces.
  tertiary,
}

/// Provides a default orientation (and relative length) to the
/// [HeroSeparator]s below it.
///
/// This is the counterpart of React Aria's `SeparatorContext`: a toolbar
/// lays its items out horizontally and flips its separators to vertical,
/// drawn at half of the toolbar's height (`.toolbar .separator--vertical`
/// is `h-1/2 self-center`).
class HeroSeparatorScope extends InheritedWidget {
  /// Applies [orientation] and [lengthFactor] to descendant separators that
  /// do not set their own orientation.
  const HeroSeparatorScope({
    super.key,
    this.orientation,
    this.lengthFactor,
    required super.child,
  });

  /// Orientation of separators that do not set one.
  final Axis? orientation;

  /// Fraction of the available length a separator covers, centered
  /// (`h-1/2 self-center` in a toolbar). Null keeps the full length.
  final double? lengthFactor;

  /// Returns the nearest scope, or null.
  static HeroSeparatorScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroSeparatorScope>();

  @override
  bool updateShouldNotify(HeroSeparatorScope oldWidget) =>
      orientation != oldWidget.orientation ||
      lengthFactor != oldWidget.lengthFactor;
}

/// A thin line that visually divides content (HeroUI `Separator`).
///
/// A horizontal separator is 1 logical pixel tall and as wide as its
/// parent allows. A vertical separator is 1 pixel wide and stretches to the
/// height its parent allows (`self-stretch`), with a minimum of 8 (`min-h-2`)
/// when the height is unbounded. To divide items of a [Row], give the row a
/// height (for example `SizedBox(height: 20)`, HeroUI's `h-5`) or wrap it in
/// an [IntrinsicHeight]:
///
/// ```dart
/// SizedBox(
///   height: 20,
///   child: Row(
///     children: <Widget>[
///       Text('Blog'),
///       SizedBox(width: 16),
///       HeroSeparator(orientation: Axis.vertical),
///       SizedBox(width: 16),
///       Text('Docs'),
///     ],
///   ),
/// )
/// ```
///
/// The separator is decorative and excluded from semantics.
class HeroSeparator extends StatelessWidget {
  /// Creates a separator.
  const HeroSeparator({
    super.key,
    this.orientation,
    this.variant = HeroSeparatorVariant.standard,
    this.margin,
    this.length,
    this.color,
    this.thickness = 1,
  });

  /// Direction of the line. When null, the orientation of the enclosing
  /// [HeroSeparatorScope] is used, else [Axis.horizontal].
  final Axis? orientation;

  /// Color variant.
  final HeroSeparatorVariant variant;

  /// Space around the line (`my-4` is `EdgeInsets.symmetric(vertical: 16)`).
  final EdgeInsetsGeometry? margin;

  /// Fixed length along the line (`h-4` on a vertical separator). When null
  /// the separator fills the available length.
  final double? length;

  /// Overrides the variant color (`bg-*` utilities).
  final Color? color;

  /// Width of the line (`h-px` / `w-px`).
  final double thickness;

  /// Returns the line color of [variant] in [theme].
  static Color colorOf(HeroThemeData theme, HeroSeparatorVariant variant) =>
      switch (variant) {
        HeroSeparatorVariant.standard => theme.colors.separator,
        HeroSeparatorVariant.secondary => theme.colors.separatorSecondary,
        HeroSeparatorVariant.tertiary => theme.colors.separatorTertiary,
      };

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroSeparatorScope? scope = HeroSeparatorScope.maybeOf(context);
    final Axis axis = orientation ?? scope?.orientation ?? Axis.horizontal;
    Widget result = _SeparatorLine(
      axis: axis,
      thickness: thickness,
      length: length,
      minLength: axis == Axis.vertical ? theme.spacing(2) : 0,
      lengthFactor: scope?.lengthFactor ?? 1,
      color: color ?? colorOf(theme, variant),
      shape: theme.shapeAll(theme.radii.sm),
    );
    if (margin != null) result = Padding(padding: margin!, child: result);
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Axis>('orientation', orientation, defaultValue: null))
      ..add(
        EnumProperty<HeroSeparatorVariant>(
          'variant',
          variant,
          defaultValue: HeroSeparatorVariant.standard,
        ),
      )
      ..add(DoubleProperty('length', length, defaultValue: null))
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(DoubleProperty('thickness', thickness, defaultValue: 1));
  }
}

class _SeparatorLine extends LeafRenderObjectWidget {
  const _SeparatorLine({
    required this.axis,
    required this.thickness,
    required this.length,
    required this.minLength,
    required this.lengthFactor,
    required this.color,
    required this.shape,
  });

  final Axis axis;
  final double thickness;
  final double? length;
  final double minLength;
  final double lengthFactor;
  final Color color;
  final ShapeBorder shape;

  @override
  RenderHeroSeparator createRenderObject(BuildContext context) =>
      RenderHeroSeparator(
        axis: axis,
        thickness: thickness,
        length: length,
        minLength: minLength,
        lengthFactor: lengthFactor,
        color: color,
        shape: shape,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHeroSeparator renderObject,
  ) {
    renderObject
      ..axis = axis
      ..thickness = thickness
      ..length = length
      ..minLength = minLength
      ..lengthFactor = lengthFactor
      ..color = color
      ..shape = shape;
  }
}

/// Lays out and paints a [HeroSeparator] line.
///
/// Along its [axis] the line fills the incoming maximum extent (scaled by
/// [lengthFactor]) when it is bounded, and falls back to [minLength]
/// otherwise; a fixed [length] wins over both. Across the axis it is
/// [thickness] wide. When the parent forces a larger box (for example
/// `CrossAxisAlignment.stretch`), the line is centered inside it.
class RenderHeroSeparator extends RenderBox {
  /// Creates the render object.
  RenderHeroSeparator({
    required Axis axis,
    required double thickness,
    required double? length,
    required double minLength,
    required double lengthFactor,
    required Color color,
    required ShapeBorder shape,
  }) : _axis = axis,
       _thickness = thickness,
       _length = length,
       _minLength = minLength,
       _lengthFactor = lengthFactor,
       _color = color,
       _shape = shape;

  /// Direction of the line.
  Axis get axis => _axis;
  Axis _axis;
  set axis(Axis value) {
    if (value == _axis) return;
    _axis = value;
    markNeedsLayout();
  }

  /// Width of the line across [axis].
  double get thickness => _thickness;
  double _thickness;
  set thickness(double value) {
    if (value == _thickness) return;
    _thickness = value;
    markNeedsLayout();
  }

  /// Fixed length along [axis], or null to fill.
  double? get length => _length;
  double? _length;
  set length(double? value) {
    if (value == _length) return;
    _length = value;
    markNeedsLayout();
  }

  /// Length used when the available extent is unbounded.
  double get minLength => _minLength;
  double _minLength;
  set minLength(double value) {
    if (value == _minLength) return;
    _minLength = value;
    markNeedsLayout();
  }

  /// Fraction of the available extent covered by the line.
  double get lengthFactor => _lengthFactor;
  double _lengthFactor;
  set lengthFactor(double value) {
    if (value == _lengthFactor) return;
    _lengthFactor = value;
    markNeedsLayout();
  }

  /// Line color.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  /// Outline of the line (`rounded-sm`).
  ShapeBorder get shape => _shape;
  ShapeBorder _shape;
  set shape(ShapeBorder value) {
    if (value == _shape) return;
    _shape = value;
    markNeedsPaint();
  }

  bool get _vertical => _axis == Axis.vertical;

  double get _intrinsicLength => _length ?? _minLength;

  @override
  double computeMinIntrinsicWidth(double height) =>
      _vertical ? _thickness : _intrinsicLength;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _vertical ? _thickness : _intrinsicLength;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _vertical ? _intrinsicLength : _thickness;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _vertical ? _intrinsicLength : _thickness;

  double _lineLength(BoxConstraints constraints) {
    if (_length != null) return _length!;
    final double max = _vertical ? constraints.maxHeight : constraints.maxWidth;
    if (!max.isFinite) return _minLength;
    return math.max(max * _lengthFactor, _vertical ? _minLength : 0);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final double along = _lineLength(constraints);
    return constraints.constrain(
      _vertical ? Size(_thickness, along) : Size(along, _thickness),
    );
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double along = math.min(
      _lineLength(constraints),
      _vertical ? size.height : size.width,
    );
    final double across = math.min(
      _thickness,
      _vertical ? size.width : size.height,
    );
    if (along <= 0 || across <= 0) return;
    final Size line = _vertical ? Size(across, along) : Size(along, across);
    final Rect rect = Alignment.center.inscribe(line, offset & size);
    context.canvas.drawPath(
      _shape.getOuterPath(rect),
      Paint()
        ..color = _color
        ..isAntiAlias = true,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Axis>('axis', axis))
      ..add(DoubleProperty('thickness', thickness))
      ..add(DoubleProperty('length', length, defaultValue: null))
      ..add(ColorProperty('color', color));
  }
}
