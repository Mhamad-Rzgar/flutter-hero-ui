/// HeroUI's Meter: a quantity within a known range.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../label/label.dart';
import '../progress_circle/range_format.dart';
import 'range_layout.dart';

export 'range_layout.dart';

/// The render props of a [HeroMeter] (React Aria's `MeterRenderProps`).
@immutable
class HeroMeterState {
  /// Creates a meter state.
  const HeroMeterState({required this.percentage, required this.valueText});

  /// The value as a percentage of the range, from 0 to 100.
  final double percentage;

  /// The formatted value ("60%").
  final String valueText;

  @override
  bool operator ==(Object other) =>
      other is HeroMeterState &&
      other.percentage == percentage &&
      other.valueText == valueText;

  @override
  int get hashCode => Object.hash(percentage, valueText);

  @override
  String toString() => 'HeroMeterState($percentage%, $valueText)';
}

/// Builds the parts of a [HeroMeter] from its state (HeroUI's render-prop
/// children).
typedef HeroMeterChildrenBuilder =
    List<Widget> Function(BuildContext context, HeroMeterState state);

/// A quantity within a known range, or a fractional value (HeroUI `Meter`).
///
/// With a [label] the meter builds HeroUI's standard layout: the label and
/// the formatted value on the first row, the track below.
///
/// ```dart
/// const HeroMeter(value: 60, label: Text('Storage'))
/// ```
///
/// The same meter from its parts (HeroUI's anatomy); a [HeroLabel] goes to
/// the label area, a [HeroMeterOutput] to the output area and a
/// [HeroMeterTrack] across the second row:
///
/// ```dart
/// const HeroMeter(
///   value: 60,
///   children: <Widget>[
///     HeroLabel.text('Storage'),
///     HeroMeterOutput(),
///     HeroMeterTrack(child: HeroMeterFill()),
///   ],
/// )
/// ```
///
/// * [size]: the track is 4 (sm), 8 (md, default) or 12 (lg) tall.
/// * [color]: the fill in `--accent` (default), `--default-foreground`
///   (standard), `--success`, `--warning` or `--danger`.
/// * [numberFormat]: the value text is a whole percentage by default; a
///   currency format shows "$750.00" (see [HeroRangeFormat.progressText]).
///
/// The meter fills the available width (see [HeroRangeLayout]). Its fill
/// grows from the start edge (right in right-to-left layouts) and animates
/// width changes over 300 ms with `ease-out`.
class HeroMeter extends StatelessWidget {
  /// Creates a meter.
  const HeroMeter({
    super.key,
    this.value = 0,
    this.minValue = 0,
    this.maxValue = 100,
    this.size = HeroSize.md,
    this.color = HeroColor.accent,
    this.isDisabled = false,
    this.numberFormat,
    this.valueLabel,
    this.label,
    this.showValueLabel,
    this.semanticLabel,
    this.children,
    this.builder,
  });

  /// The current value, clamped to [minValue]–[maxValue].
  final double value;

  /// The lower end of the range.
  final double minValue;

  /// The upper end of the range.
  final double maxValue;

  /// The track thickness.
  final HeroSize size;

  /// The color of the fill.
  final HeroColor color;

  /// Whether the meter looks disabled (50% opacity).
  final bool isDisabled;

  /// Formats the value text (`formatOptions`); defaults to a whole
  /// percentage.
  final NumberFormat? numberFormat;

  /// Replaces the formatted value text (`valueLabel`).
  final String? valueLabel;

  /// The label of the standard layout; text widgets take the label style.
  /// Ignored when [children] or [builder] are given.
  final Widget? label;

  /// Whether the standard layout shows the value text; defaults to whether
  /// there is a [label].
  final bool? showValueLabel;

  /// Accessibility label (`aria-label`); defaults to the label text.
  final String? semanticLabel;

  /// The parts: a [HeroLabel], a [HeroMeterOutput] and a [HeroMeterTrack]
  /// in their grid areas; other widgets follow the track.
  final List<Widget>? children;

  /// Builds the parts from the state; replaces [children].
  final HeroMeterChildrenBuilder? builder;

  /// Returns the fill color of [color] (`--meter-fill`).
  static Color fillColorOf(HeroColors colors, HeroColor color) =>
      switch (color) {
        HeroColor.standard => colors.defaultForeground,
        _ => colors.role(color).base,
      };

  /// Returns the track height of [size] (`h-1`, `h-2`, `h-3`).
  static double trackHeightOf(HeroThemeData theme, HeroSize size) =>
      switch (size) {
        HeroSize.sm => theme.spacing(1),
        HeroSize.md => theme.spacing(2),
        HeroSize.lg => theme.spacing(3),
      };

  /// Returns the track and fill radius of [size] (`rounded-xs`,
  /// `rounded-sm`, `rounded-md`).
  static double radiusOf(HeroThemeData theme, HeroSize size) => switch (size) {
    HeroSize.sm => theme.radii.xs,
    HeroSize.md => theme.radii.sm,
    HeroSize.lg => theme.radii.md,
  };

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroMeterState state = HeroMeterState(
      percentage: HeroRangeFormat.fraction(value, minValue, maxValue) * 100,
      valueText:
          valueLabel ??
          HeroRangeFormat.progressText(
            context,
            value: value,
            minValue: minValue,
            maxValue: maxValue,
            format: numberFormat,
          ),
    );
    final List<Widget> parts =
        builder?.call(context, state) ?? children ?? _standardParts();

    Widget? labelPart;
    Widget? outputPart;
    Widget? trackPart;
    final List<Widget> rest = <Widget>[];
    for (final Widget part in parts) {
      if (part is HeroLabel && labelPart == null) {
        labelPart = part;
      } else if (part is HeroMeterOutput && outputPart == null) {
        outputPart = part;
      } else if (part is HeroMeterTrack && trackPart == null) {
        trackPart = part;
      } else {
        rest.add(part);
      }
    }
    // An explicit accessibility label replaces the visible one, which would
    // otherwise be announced twice.
    if (labelPart != null && semanticLabel != null) {
      labelPart = ExcludeSemantics(child: labelPart);
    }

    return HeroRangeSemantics(
      label: semanticLabel,
      valueText: state.valueText,
      minValue: minValue,
      maxValue: maxValue,
      child: HeroDisabledOpacity(
        disabled: isDisabled,
        child: _HeroMeterScope(
          state: state,
          size: size,
          fillColor: fillColorOf(theme.colors, color),
          child: HeroRangeLayout(
            label: labelPart,
            output: outputPart,
            track: trackPart ?? const SizedBox.shrink(),
            children: rest,
          ),
        ),
      ),
    );
  }

  List<Widget> _standardParts() {
    final Widget? label = this.label;
    return <Widget>[
      if (label != null) label is HeroLabel ? label : HeroLabel(child: label),
      if (showValueLabel ?? label != null) const HeroMeterOutput(),
      const HeroMeterTrack(),
    ];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('value', value))
      ..add(DoubleProperty('minValue', minValue, defaultValue: 0))
      ..add(DoubleProperty('maxValue', maxValue, defaultValue: 100))
      ..add(EnumProperty<HeroSize>('size', size, defaultValue: HeroSize.md))
      ..add(
        EnumProperty<HeroColor>('color', color, defaultValue: HeroColor.accent),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(StringProperty('valueLabel', valueLabel, defaultValue: null));
  }
}

/// Shares the state of a [HeroMeter] with its parts.
class _HeroMeterScope extends InheritedWidget {
  const _HeroMeterScope({
    required this.state,
    required this.size,
    required this.fillColor,
    required super.child,
  });

  final HeroMeterState state;
  final HeroSize size;
  final Color fillColor;

  static _HeroMeterScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroMeterScope>();

  @override
  bool updateShouldNotify(_HeroMeterScope oldWidget) =>
      state != oldWidget.state ||
      size != oldWidget.size ||
      fillColor != oldWidget.fillColor;
}

/// The formatted value of a [HeroMeter] (HeroUI `Meter.Output`):
/// `text-sm font-medium` with tabular figures, in the surrounding text
/// color.
///
/// It shows the meter's value text unless a [child] is given. The value
/// is announced by the meter itself, so the output is excluded from
/// semantics.
class HeroMeterOutput extends StatelessWidget {
  /// Creates the output.
  const HeroMeterOutput({super.key, this.child, this.style});

  /// Replaces the value text.
  final Widget? child;

  /// Style merged over the output style (a `text-*` class).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography
        .style(HeroFontSize.sm, weight: HeroTypography.medium)
        .copyWith(
          color:
              DefaultTextStyle.of(context).style.color ??
              theme.colors.foreground,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        )
        .merge(style?.copyWith(inherit: true));
    final Widget content =
        child ?? Text(_HeroMeterScope.maybeOf(context)?.state.valueText ?? '');
    return ExcludeSemantics(
      child: DefaultTextStyle(style: textStyle, child: content),
    );
  }
}

/// The track of a [HeroMeter] (HeroUI `Meter.Track`): a `--default` bar,
/// 4, 8 or 12 tall with matching radii, that clips its [child].
class HeroMeterTrack extends StatelessWidget {
  /// Creates the track.
  const HeroMeterTrack({
    super.key,
    this.child = const HeroMeterFill(),
    this.color,
    this.borderRadius,
    this.height,
  });

  /// The content, usually a [HeroMeterFill].
  final Widget child;

  /// Background color (`bg-*`); defaults to `--default`.
  final Color? color;

  /// Corner radii (`rounded-*`); defaults to the meter size's radius.
  final BorderRadiusGeometry? borderRadius;

  /// Height (`h-*`); defaults to the meter size's height.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroSize size = _HeroMeterScope.maybeOf(context)?.size ?? HeroSize.md;
    final OutlinedBorder shape = theme.shape(
      borderRadius ??
          BorderRadius.all(Radius.circular(HeroMeter.radiusOf(theme, size))),
    );
    return SizedBox(
      height: height ?? HeroMeter.trackHeightOf(theme, size),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color ?? theme.colors.defaultColor,
          shape: shape,
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: shape,
            textDirection: Directionality.of(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The filled part of a [HeroMeterTrack] (HeroUI `Meter.Fill`).
///
/// It covers the meter's percentage of the track from the start edge, at
/// full height, with the track's radius, and animates width changes over
/// 300 ms with `ease-out` (not under reduced motion).
class HeroMeterFill extends StatelessWidget {
  /// Creates the fill.
  const HeroMeterFill({super.key, this.color, this.borderRadius});

  /// Fill color (`bg-*`); defaults to the meter's color.
  final Color? color;

  /// Corner radii (`rounded-*`); defaults to the meter size's radius.
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroMeterScope? scope = _HeroMeterScope.maybeOf(context);
    final HeroSize size = scope?.size ?? HeroSize.md;
    final Decoration decoration = ShapeDecoration(
      color: color ?? scope?.fillColor ?? theme.colors.accent,
      shape: theme.shape(
        borderRadius ??
            BorderRadius.all(Radius.circular(HeroMeter.radiusOf(theme, size))),
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: (scope?.state.percentage ?? 0) / 100),
      duration: theme.motion.resolve(context, HeroMotion.slower),
      curve: HeroMotion.easeOut,
      builder: (BuildContext context, double fraction, Widget? child) =>
          FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: fraction,
            heightFactor: 1,
            child: child,
          ),
      child: DecoratedBox(decoration: decoration),
    );
  }
}
