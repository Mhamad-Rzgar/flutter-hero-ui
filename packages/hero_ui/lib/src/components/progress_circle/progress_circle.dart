/// HeroUI's ProgressCircle: a circular determinate or indeterminate
/// progress indicator.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../foundation/foundation.dart';
import 'range_format.dart';

export 'range_format.dart';

/// The render props of a [HeroProgressCircle] (React Aria's
/// `ProgressBarRenderProps`).
@immutable
class HeroProgressCircleState {
  /// Creates a progress circle state.
  const HeroProgressCircleState({
    required this.percentage,
    required this.valueText,
    required this.isIndeterminate,
  });

  /// The progress from 0 to 100.
  final double percentage;

  /// The formatted value ("60%"), or null while indeterminate.
  final String? valueText;

  /// Whether the progress is unknown.
  final bool isIndeterminate;

  @override
  bool operator ==(Object other) =>
      other is HeroProgressCircleState &&
      other.percentage == percentage &&
      other.valueText == valueText &&
      other.isIndeterminate == isIndeterminate;

  @override
  int get hashCode => Object.hash(percentage, valueText, isIndeterminate);

  @override
  String toString() =>
      'HeroProgressCircleState($percentage%, ${valueText ?? 'indeterminate'})';
}

/// Builds the content of a [HeroProgressCircle] from its state (HeroUI's
/// render-prop children).
typedef HeroProgressCircleWidgetBuilder =
    Widget Function(BuildContext context, HeroProgressCircleState state);

/// A circular progress indicator (HeroUI `ProgressCircle`).
///
/// ```dart
/// const HeroProgressCircle(value: 60, semanticLabel: 'Loading')
/// ```
///
/// * [size]: sm (20), md (28, default) or lg (36); [dimension] sets any
///   other size.
/// * [color]: the fill arc in `--accent` (default), `--default-foreground`
///   (standard), `--success`, `--warning` or `--danger`, over a `--default`
///   track.
/// * [isIndeterminate]: a quarter arc spinning once per second
///   ([HeroMotion.progressSpin]).
///
/// The arc starts at 12 o'clock and grows clockwise in both text
/// directions, like HeroUI's SVG. Value changes animate over 300 ms with
/// `ease-out`; under reduced motion nothing animates.
///
/// The default content is a [HeroProgressCircleTrack] with a
/// [HeroProgressCircleTrackCircle] and a [HeroProgressCircleFillCircle].
/// Pass your own [child] (usually a customized track) or a [builder] to
/// change the geometry:
///
/// ```dart
/// const HeroProgressCircle(
///   value: 60,
///   child: HeroProgressCircleTrack(
///     children: <Widget>[
///       HeroProgressCircleTrackCircle(radius: 17, strokeWidth: 2),
///       HeroProgressCircleFillCircle(radius: 17, strokeWidth: 2),
///     ],
///   ),
/// )
/// ```
class HeroProgressCircle extends StatelessWidget {
  /// Creates a progress circle.
  const HeroProgressCircle({
    super.key,
    this.value = 0,
    this.minValue = 0,
    this.maxValue = 100,
    this.isIndeterminate = false,
    this.isDisabled = false,
    this.size = HeroSize.md,
    this.color = HeroColor.accent,
    this.dimension,
    this.numberFormat,
    this.valueLabel,
    this.semanticLabel,
    this.child,
    this.builder,
  });

  /// The current value, clamped to [minValue]–[maxValue].
  final double value;

  /// The value of an empty circle.
  final double minValue;

  /// The value of a full circle.
  final double maxValue;

  /// Whether the progress is unknown (spinning quarter arc).
  final bool isIndeterminate;

  /// Whether the indicator looks disabled (50% opacity).
  final bool isDisabled;

  /// The size of the circle.
  final HeroSize size;

  /// The color of the fill arc.
  final HeroColor color;

  /// Overrides the side length of the circle (a `size-*` class).
  final double? dimension;

  /// Formats the announced value text (`formatOptions`); defaults to a
  /// whole percentage. See [HeroRangeFormat.progressText].
  final NumberFormat? numberFormat;

  /// Replaces the formatted value text (`valueLabel`).
  final String? valueLabel;

  /// Accessibility label (`aria-label`).
  final String? semanticLabel;

  /// The content; defaults to a [HeroProgressCircleTrack] with both
  /// circles.
  final Widget? child;

  /// Builds the content from the state; replaces [child].
  final HeroProgressCircleWidgetBuilder? builder;

  /// Returns the side length of [size] in [theme] (`size-5`, `size-7`,
  /// `size-9`).
  static double dimensionOf(HeroThemeData theme, HeroSize size) =>
      switch (size) {
        HeroSize.sm => theme.spacing(5),
        HeroSize.md => theme.spacing(7),
        HeroSize.lg => theme.spacing(9),
      };

  /// Returns the fill arc color of [color] (`--progress-circle-stroke`).
  static Color fillColorOf(HeroColors colors, HeroColor color) =>
      switch (color) {
        HeroColor.standard => colors.defaultForeground,
        _ => colors.role(color).base,
      };

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double percentage = isIndeterminate
        ? 0
        : HeroRangeFormat.fraction(value, minValue, maxValue) * 100;
    final String? valueText = isIndeterminate
        ? null
        : valueLabel ??
              HeroRangeFormat.progressText(
                context,
                value: value,
                minValue: minValue,
                maxValue: maxValue,
                format: numberFormat,
              );
    final HeroProgressCircleState state = HeroProgressCircleState(
      percentage: percentage,
      valueText: valueText,
      isIndeterminate: isIndeterminate,
    );
    final Widget content =
        builder?.call(context, state) ??
        child ??
        const HeroProgressCircleTrack();
    return HeroRangeSemantics(
      label: semanticLabel,
      valueText: valueText,
      minValue: minValue,
      maxValue: maxValue,
      isIndeterminate: isIndeterminate,
      child: HeroDisabledOpacity(
        disabled: isDisabled,
        child: _HeroProgressCircleScope(
          state: state,
          dimension: dimension ?? dimensionOf(theme, size),
          fillColor: fillColorOf(theme.colors, color),
          trackColor: theme.colors.defaultColor,
          child: content,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('value', value))
      ..add(DoubleProperty('minValue', minValue, defaultValue: 0))
      ..add(DoubleProperty('maxValue', maxValue, defaultValue: 100))
      ..add(
        FlagProperty(
          'isIndeterminate',
          value: isIndeterminate,
          ifTrue: 'indeterminate',
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(EnumProperty<HeroSize>('size', size, defaultValue: HeroSize.md))
      ..add(
        EnumProperty<HeroColor>('color', color, defaultValue: HeroColor.accent),
      )
      ..add(DoubleProperty('dimension', dimension, defaultValue: null));
  }
}

/// Shares the state and resolved paint of a [HeroProgressCircle] with its
/// parts.
class _HeroProgressCircleScope extends InheritedWidget {
  const _HeroProgressCircleScope({
    required this.state,
    required this.dimension,
    required this.fillColor,
    required this.trackColor,
    required super.child,
  });

  final HeroProgressCircleState state;
  final double dimension;
  final Color fillColor;
  final Color trackColor;

  static _HeroProgressCircleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroProgressCircleScope>();

  @override
  bool updateShouldNotify(_HeroProgressCircleScope oldWidget) =>
      state != oldWidget.state ||
      dimension != oldWidget.dimension ||
      fillColor != oldWidget.fillColor ||
      trackColor != oldWidget.trackColor;
}

/// Shares the view box and default stroke width of a
/// [HeroProgressCircleTrack] with its circles.
class _HeroProgressCircleTrackScope extends InheritedWidget {
  const _HeroProgressCircleTrackScope({
    required this.viewBox,
    required this.strokeWidth,
    required super.child,
  });

  final Size viewBox;
  final double? strokeWidth;

  static _HeroProgressCircleTrackScope? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_HeroProgressCircleTrackScope>();

  @override
  bool updateShouldNotify(_HeroProgressCircleTrackScope oldWidget) =>
      viewBox != oldWidget.viewBox || strokeWidth != oldWidget.strokeWidth;
}

/// The drawing area of a [HeroProgressCircle] (HeroUI
/// `ProgressCircle.Track`, the SVG canvas).
///
/// Its circles are drawn in [viewBox] coordinates (36 × 36 by default)
/// scaled to the circle's size. While the circle is indeterminate the
/// track turns once every [HeroMotion.progressSpin] (not under reduced
/// motion).
class HeroProgressCircleTrack extends StatefulWidget {
  /// Creates a track holding [children].
  const HeroProgressCircleTrack({
    super.key,
    this.children = const <Widget>[
      HeroProgressCircleTrackCircle(),
      HeroProgressCircleFillCircle(),
    ],
    this.viewBox = HeroProgressCircleTrack.defaultViewBox,
    this.strokeWidth,
    this.dimension,
  });

  /// HeroUI's view box (`0 0 36 36`).
  static const Size defaultViewBox = Size.square(36);

  /// The circles, painted in order (track first, then fill).
  final List<Widget> children;

  /// The coordinate space of the circles (`viewBox`).
  final Size viewBox;

  /// Default stroke width of circles that do not set one, in view box
  /// units.
  final double? strokeWidth;

  /// Overrides the side length; defaults to the circle's size.
  final double? dimension;

  @override
  State<HeroProgressCircleTrack> createState() =>
      _HeroProgressCircleTrackState();
}

class _HeroProgressCircleTrackState extends State<HeroProgressCircleTrack>
    with SingleTickerProviderStateMixin {
  AnimationController? _spin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSpin();
  }

  @override
  void didUpdateWidget(HeroProgressCircleTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSpin();
  }

  bool get _spinning {
    final bool indeterminate =
        _HeroProgressCircleScope.maybeOf(context)?.state.isIndeterminate ??
        false;
    return indeterminate &&
        !HeroTheme.of(context).motion.shouldReduceMotion(context);
  }

  void _syncSpin() {
    if (_spinning) {
      final AnimationController spin = _spin ??= AnimationController(
        vsync: this,
        duration: HeroMotion.progressSpin,
      );
      if (!spin.isAnimating) spin.repeat();
    } else {
      _spin?.stop();
      _spin?.value = 0;
    }
  }

  @override
  void dispose() {
    _spin?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double dimension =
        widget.dimension ??
        _HeroProgressCircleScope.maybeOf(context)?.dimension ??
        HeroProgressCircle.dimensionOf(theme, HeroSize.md);
    Widget result = _HeroProgressCircleTrackScope(
      viewBox: widget.viewBox,
      strokeWidth: widget.strokeWidth,
      child: Stack(fit: StackFit.expand, children: widget.children),
    );
    final AnimationController? spin = _spin;
    if (spin != null && _spinning) {
      result = RotationTransition(turns: spin, child: result);
    }
    return SizedBox.square(
      dimension: dimension,
      child: RepaintBoundary(child: result),
    );
  }
}

/// The background ring of a [HeroProgressCircle] (HeroUI
/// `ProgressCircle.TrackCircle`), stroked in `--default`.
///
/// Geometry is in view box units: [center] (18, 18), [radius] 16 and
/// [strokeWidth] 4 by default.
class HeroProgressCircleTrackCircle extends StatelessWidget {
  /// Creates the track circle.
  const HeroProgressCircleTrackCircle({
    super.key,
    this.center,
    this.radius,
    this.strokeWidth,
    this.color,
  });

  /// The center (`cx`, `cy`); defaults to the middle of the view box.
  final Offset? center;

  /// The radius (`r`); defaults to 16.
  final double? radius;

  /// The stroke width; defaults to the track's, then 4.
  final double? strokeWidth;

  /// The stroke color (`stroke-*`); defaults to `--default`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final _HeroProgressCircleScope? scope = _HeroProgressCircleScope.maybeOf(
      context,
    );
    return CustomPaint(
      painter: _HeroCirclePainter(
        geometry: _CircleGeometry.resolve(
          context,
          center: center,
          radius: radius,
          strokeWidth: strokeWidth,
        ),
        color:
            color ??
            scope?.trackColor ??
            HeroTheme.of(context).colors.defaultColor,
        fraction: 1,
        strokeCap: StrokeCap.butt,
      ),
    );
  }
}

/// The progress arc of a [HeroProgressCircle] (HeroUI
/// `ProgressCircle.FillCircle`).
///
/// It starts at 12 o'clock and runs clockwise for the circle's percentage
/// (a quarter while indeterminate), with round caps, and animates its
/// length over 300 ms with `ease-out` (`stroke-dashoffset` transition).
class HeroProgressCircleFillCircle extends StatelessWidget {
  /// Creates the fill arc.
  const HeroProgressCircleFillCircle({
    super.key,
    this.center,
    this.radius,
    this.strokeWidth,
    this.color,
    this.strokeCap = StrokeCap.round,
  });

  /// The center (`cx`, `cy`); defaults to the middle of the view box.
  final Offset? center;

  /// The radius (`r`); defaults to 16.
  final double? radius;

  /// The stroke width; defaults to the track's, then 4.
  final double? strokeWidth;

  /// The stroke color (`stroke-*`); defaults to the circle's color.
  final Color? color;

  /// The shape of the arc ends (`strokeLinecap`).
  final StrokeCap strokeCap;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroProgressCircleScope? scope = _HeroProgressCircleScope.maybeOf(
      context,
    );
    final HeroProgressCircleState? state = scope?.state;
    final double fraction = state == null
        ? 0
        : (state.isIndeterminate ? 0.25 : state.percentage / 100);
    final _CircleGeometry geometry = _CircleGeometry.resolve(
      context,
      center: center,
      radius: radius,
      strokeWidth: strokeWidth,
    );
    final Color stroke = color ?? scope?.fillColor ?? theme.colors.accent;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: fraction),
      duration: theme.motion.resolve(context, HeroMotion.slower),
      curve: HeroMotion.easeOut,
      builder: (BuildContext context, double fraction, _) => CustomPaint(
        painter: _HeroCirclePainter(
          geometry: geometry,
          color: stroke,
          fraction: fraction,
          strokeCap: strokeCap,
        ),
      ),
    );
  }
}

/// The circle geometry in view box units.
@immutable
class _CircleGeometry {
  const _CircleGeometry({
    required this.viewBox,
    required this.center,
    required this.radius,
    required this.strokeWidth,
  });

  factory _CircleGeometry.resolve(
    BuildContext context, {
    Offset? center,
    double? radius,
    double? strokeWidth,
  }) {
    final _HeroProgressCircleTrackScope? track =
        _HeroProgressCircleTrackScope.maybeOf(context);
    final Size viewBox =
        track?.viewBox ?? HeroProgressCircleTrack.defaultViewBox;
    return _CircleGeometry(
      viewBox: viewBox,
      center: center ?? viewBox.center(Offset.zero),
      radius: radius ?? _radius,
      strokeWidth: strokeWidth ?? track?.strokeWidth ?? _strokeWidth,
    );
  }

  /// HeroUI's `STROKE_WIDTH`.
  static const double _strokeWidth = 4;

  /// HeroUI's `RADIUS` (`CENTER - STROKE_WIDTH / 2`).
  static const double _radius = 16;

  final Size viewBox;
  final Offset center;
  final double radius;
  final double strokeWidth;

  @override
  bool operator ==(Object other) =>
      other is _CircleGeometry &&
      other.viewBox == viewBox &&
      other.center == center &&
      other.radius == radius &&
      other.strokeWidth == strokeWidth;

  @override
  int get hashCode => Object.hash(viewBox, center, radius, strokeWidth);
}

/// Strokes [fraction] of a circle, from 12 o'clock clockwise, scaled from
/// the view box to the paint size (`preserveAspectRatio="xMidYMid meet"`).
class _HeroCirclePainter extends CustomPainter {
  const _HeroCirclePainter({
    required this.geometry,
    required this.color,
    required this.fraction,
    required this.strokeCap,
  });

  final _CircleGeometry geometry;
  final Color color;
  final double fraction;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction <= 0 || geometry.radius <= 0 || geometry.strokeWidth <= 0) {
      return;
    }
    final Size viewBox = geometry.viewBox;
    final double scale = math.min(
      size.width / viewBox.width,
      size.height / viewBox.height,
    );
    final Offset origin = Offset(
      (size.width - viewBox.width * scale) / 2,
      (size.height - viewBox.height * scale) / 2,
    );
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = geometry.strokeWidth * scale
      ..strokeCap = strokeCap;
    final Offset center = origin + geometry.center * scale;
    final double radius = geometry.radius * scale;
    if (fraction >= 1) {
      canvas.drawCircle(center, radius, paint);
      return;
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      fraction * 2 * math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_HeroCirclePainter oldDelegate) =>
      oldDelegate.geometry != geometry ||
      oldDelegate.color != color ||
      oldDelegate.fraction != fraction ||
      oldDelegate.strokeCap != strokeCap;
}
