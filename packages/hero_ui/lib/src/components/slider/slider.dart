/// HeroUI's Slider: select one value, or a range, within bounds.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../form/form.dart';
import '../input/hero_field.dart';
import '../label/label.dart';
import '../meter/range_layout.dart';
import '../progress_circle/range_format.dart';

/// The render props of a [HeroSlider] (React Aria's `SliderRenderProps`
/// and the parts of `SliderState` HeroUI's examples use).
@immutable
class HeroSliderState {
  /// Creates a slider state.
  const HeroSliderState({
    required this.values,
    required this.valueLabels,
    required this.minValue,
    required this.maxValue,
    required this.orientation,
    required this.isDisabled,
  });

  /// The value of every thumb, in thumb order.
  final List<double> values;

  /// The formatted value of every thumb.
  final List<String> valueLabels;

  /// The lower end of the range.
  final double minValue;

  /// The upper end of the range.
  final double maxValue;

  /// The orientation of the slider.
  final Axis orientation;

  /// Whether the slider is disabled.
  final bool isDisabled;

  /// The formatted value of thumb [index] (`getThumbValueLabel`).
  String getThumbValueLabel(int index) => valueLabels[index];

  /// Where thumb [index] sits in the range, from 0 to 1
  /// (`getThumbPercent`).
  double getThumbPercent(int index) =>
      HeroRangeFormat.fraction(values[index], minValue, maxValue);

  @override
  bool operator ==(Object other) =>
      other is HeroSliderState &&
      listEquals(other.values, values) &&
      listEquals(other.valueLabels, valueLabels) &&
      other.minValue == minValue &&
      other.maxValue == maxValue &&
      other.orientation == orientation &&
      other.isDisabled == isDisabled;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(values),
    Object.hashAll(valueLabels),
    minValue,
    maxValue,
    orientation,
    isDisabled,
  );

  @override
  String toString() => 'HeroSliderState(${valueLabels.join(', ')})';
}

/// Builds the parts of a [HeroSlider] or a [HeroSliderTrack] from the
/// slider state (HeroUI's render-prop children).
typedef HeroSliderPartsBuilder =
    List<Widget> Function(BuildContext context, HeroSliderState state);

/// Builds the content of a [HeroSliderOutput] from the slider state.
typedef HeroSliderOutputBuilder =
    Widget Function(BuildContext context, HeroSliderState state);

/// Color and text overrides for a [HeroSlider], the counterpart of the
/// Tailwind classes HeroUI's customization example puts on the parts.
///
/// A part's own parameters win over the style.
@immutable
class HeroSliderStyle with Diagnosticable {
  /// Creates slider style overrides.
  const HeroSliderStyle({
    this.trackColor,
    this.fillColor,
    this.thumbColor,
    this.knobColor,
    this.outputStyle,
  });

  /// Track background (`--default`).
  final Color? trackColor;

  /// Fill and end cap color (`--accent`).
  final Color? fillColor;

  /// Thumb frame color (`--accent`).
  final Color? thumbColor;

  /// Thumb knob color (`--accent-foreground`).
  final Color? knobColor;

  /// Merged over the output text style.
  final TextStyle? outputStyle;

  @override
  bool operator ==(Object other) =>
      other is HeroSliderStyle &&
      other.trackColor == trackColor &&
      other.fillColor == fillColor &&
      other.thumbColor == thumbColor &&
      other.knobColor == knobColor &&
      other.outputStyle == outputStyle;

  @override
  int get hashCode =>
      Object.hash(trackColor, fillColor, thumbColor, knobColor, outputStyle);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('trackColor', trackColor, defaultValue: null))
      ..add(ColorProperty('fillColor', fillColor, defaultValue: null))
      ..add(ColorProperty('thumbColor', thumbColor, defaultValue: null))
      ..add(ColorProperty('knobColor', knobColor, defaultValue: null));
  }
}

/// A slider to pick one value, or a range, within bounds (HeroUI
/// `Slider`).
///
/// ```dart
/// HeroSlider(
///   defaultValue: 30,
///   label: const Text('Volume'),
///   onChanged: (double value) => debugPrint('$value'),
/// )
/// ```
///
/// [HeroSlider.range] has one thumb per value:
///
/// ```dart
/// HeroSlider.range(
///   defaultValues: const <double>[100, 500],
///   maxValue: 1000,
///   step: 50,
///   numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
///   label: const Text('Price Range'),
/// )
/// ```
///
/// With a [label] the slider builds HeroUI's standard layout: the label and
/// the formatted value ([HeroSliderOutput]) above a [HeroSliderTrack] with
/// a [HeroSliderFill] and one [HeroSliderThumb] per value. The same layout
/// from its parts:
///
/// ```dart
/// HeroSlider(
///   defaultValue: 30,
///   children: const <Widget>[
///     HeroLabel.text('Volume'),
///     HeroSliderOutput(),
///     HeroSliderTrack(),
///   ],
/// )
/// ```
///
/// Behaviour follows React Aria: pressing the track moves the closest
/// thumb there and keeps dragging it; dragging a thumb moves it by the
/// pointer's travel; thumbs cannot pass each other; values snap to [step].
/// A focused thumb reacts to the arrow keys (one step; Left and Right are
/// swapped in right-to-left layouts), Page Up / Page Down (a tenth of the
/// range) and Home / End. [onChanged] reports every change and
/// [onChangeEnd] the value at the end of a drag or key press.
///
/// Vertical sliders ([orientation]) put the minimum at the bottom and fill
/// the available height (256 when unbounded). The slider registers with
/// the enclosing [Form] ([validator], [onSaved], [autovalidateMode]); its
/// form value is the list of thumb values.
class HeroSlider extends StatefulWidget {
  /// Creates a single-thumb slider.
  const HeroSlider({
    super.key,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onChangeEnd,
    this.minValue = 0,
    this.maxValue = 100,
    this.step = 1,
    this.numberFormat,
    this.orientation = Axis.horizontal,
    this.isDisabled = false,
    this.label,
    this.showOutput,
    this.semanticLabel,
    this.children,
    this.builder,
    this.style,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.name,
  }) : assert(step > 0, 'The step must be positive.'),
       assert(maxValue > minValue, 'The range must not be empty.'),
       isRange = false,
       values = null,
       defaultValues = null,
       onRangeChanged = null,
       onRangeChangeEnd = null;

  /// Creates a slider with one thumb per value (a range slider).
  const HeroSlider.range({
    super.key,
    this.values,
    this.defaultValues,
    ValueChanged<List<double>>? onChanged,
    ValueChanged<List<double>>? onChangeEnd,
    this.minValue = 0,
    this.maxValue = 100,
    this.step = 1,
    this.numberFormat,
    this.orientation = Axis.horizontal,
    this.isDisabled = false,
    this.label,
    this.showOutput,
    this.semanticLabel,
    this.children,
    this.builder,
    this.style,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.name,
  }) : assert(step > 0, 'The step must be positive.'),
       assert(maxValue > minValue, 'The range must not be empty.'),
       isRange = true,
       value = null,
       defaultValue = null,
       onChanged = null,
       onChangeEnd = null,
       onRangeChanged = onChanged,
       onRangeChangeEnd = onChangeEnd;

  /// Whether the slider was created with [HeroSlider.range].
  final bool isRange;

  /// The controlled value of a single-thumb slider.
  final double? value;

  /// The initial value of an uncontrolled single-thumb slider; defaults to
  /// [minValue].
  final double? defaultValue;

  /// Called with the new value while a single-thumb slider changes.
  final ValueChanged<double>? onChanged;

  /// Called with the value when a drag or key press on a single-thumb
  /// slider ends.
  final ValueChanged<double>? onChangeEnd;

  /// The controlled values of a range slider.
  final List<double>? values;

  /// The initial values of an uncontrolled range slider; defaults to
  /// [minValue] and [maxValue].
  final List<double>? defaultValues;

  /// Called with the new values while a range slider changes (the
  /// `onChanged` of [HeroSlider.range]).
  final ValueChanged<List<double>>? onRangeChanged;

  /// Called with the values when a drag or key press on a range slider
  /// ends (the `onChangeEnd` of [HeroSlider.range]).
  final ValueChanged<List<double>>? onRangeChangeEnd;

  /// The lower end of the range.
  final double minValue;

  /// The upper end of the range.
  final double maxValue;

  /// The granularity values snap to.
  final double step;

  /// Formats the value labels (`formatOptions`); defaults to a
  /// locale-aware decimal. See [HeroRangeFormat.valueText].
  final NumberFormat? numberFormat;

  /// Whether the track runs horizontally or vertically.
  final Axis orientation;

  /// Whether the slider is disabled (50% opacity, no interaction).
  final bool isDisabled;

  /// The label of the standard layout; text widgets take the label style.
  /// Ignored when [children] or [builder] are given.
  final Widget? label;

  /// Whether the standard layout shows the output; defaults to whether
  /// there is a [label].
  final bool? showOutput;

  /// Accessibility label of the thumbs (`aria-label`); defaults to the
  /// label text.
  final String? semanticLabel;

  /// The parts: a [HeroLabel], a [HeroSliderOutput] and a
  /// [HeroSliderTrack] in their areas; other widgets follow the track.
  final List<Widget>? children;

  /// Builds the parts from the state; replaces [children].
  final HeroSliderPartsBuilder? builder;

  /// Color and text overrides.
  final HeroSliderStyle? style;

  /// Validates the thumb values when the enclosing [Form] validates.
  final FormFieldValidator<List<double>>? validator;

  /// Receives the thumb values when the enclosing [Form] saves.
  final FormFieldSetter<List<double>>? onSaved;

  /// When to validate automatically.
  final AutovalidateMode? autovalidateMode;

  /// The form name of every thumb that does not set its own
  /// ([HeroSliderThumb.name]). Named thumbs add their values to the data
  /// a [HeroForm] submits (a list when several share a name).
  final String? name;

  @override
  State<HeroSlider> createState() => _HeroSliderRootState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('value', value, defaultValue: null))
      ..add(IterableProperty<double>('values', values, defaultValue: null))
      ..add(DoubleProperty('minValue', minValue, defaultValue: 0))
      ..add(DoubleProperty('maxValue', maxValue, defaultValue: 100))
      ..add(DoubleProperty('step', step, defaultValue: 1))
      ..add(
        EnumProperty<Axis>(
          'orientation',
          orientation,
          defaultValue: Axis.horizontal,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isRange', value: isRange, ifTrue: 'range'));
  }
}

/// The metrics of HeroUI's slider (`slider.css`), resolved from the theme.
@immutable
class _SliderMetrics {
  _SliderMetrics(HeroThemeData theme)
    : thickness = theme.spacing(5),
      cap = theme.spacing(3),
      thumbLength = theme.spacing(7),
      knobLength = theme.spacing(6),
      knobThickness = theme.spacing(4),
      trackRadius = theme.radii.xl,
      thumbRadius = theme.radii.xl,
      knobRadius = theme.radii.lg;

  /// Track thickness and thumb thickness (`h-5` / `w-5`).
  final double thickness;

  /// The transparent end caps (`border-x-[0.75rem]`).
  final double cap;

  /// Thumb length along the track (`1.5rem + 0.25rem`).
  final double thumbLength;

  /// Knob length along the track (`1.5rem`).
  final double knobLength;

  /// Knob thickness (`1rem`).
  final double knobThickness;

  /// Track radius (`rounded-xl`).
  final double trackRadius;

  /// Thumb radius (`rounded-xl`).
  final double thumbRadius;

  /// Knob radius (`rounded-lg`).
  final double knobRadius;
}

/// Maps between values (as fractions of the range) and positions on a
/// laid out track.
@immutable
class _TrackGeometry {
  const _TrackGeometry({
    required this.size,
    required this.axis,
    required this.textDirection,
    required this.metrics,
  });

  final Size size;
  final Axis axis;
  final TextDirection textDirection;
  final _SliderMetrics metrics;

  double get _extent => axis == Axis.horizontal ? size.width : size.height;

  /// The usable length between the caps.
  double get length => math.max(0, _extent - 2 * metrics.cap);

  /// Whether fractions grow towards the physical start of the axis
  /// (leftwards in right-to-left layouts, upwards when vertical).
  bool get _reversed =>
      axis == Axis.vertical || textDirection == TextDirection.rtl;

  /// The position along the axis of [fraction].
  double offsetOf(double fraction) {
    final double f = _reversed ? 1 - fraction : fraction;
    return metrics.cap + f * length;
  }

  /// The center of a thumb at [fraction].
  Offset thumbCenter(double fraction) => axis == Axis.horizontal
      ? Offset(offsetOf(fraction), size.height / 2)
      : Offset(size.width / 2, offsetOf(fraction));

  /// The size of a thumb.
  Size get thumbSize => axis == Axis.horizontal
      ? Size(metrics.thumbLength, size.height)
      : Size(size.width, metrics.thumbLength);

  /// The box of a thumb at [fraction].
  Rect thumbRect(double fraction) => Rect.fromCenter(
    center: thumbCenter(fraction),
    width: thumbSize.width,
    height: thumbSize.height,
  );

  /// The box of a fill from [start] to [end].
  Rect fillRect(double start, double end) {
    final double a = offsetOf(start);
    final double b = offsetOf(end);
    return axis == Axis.horizontal
        ? Rect.fromLTRB(math.min(a, b), 0, math.max(a, b), size.height)
        : Rect.fromLTRB(0, math.min(a, b), size.width, math.max(a, b));
  }

  /// The fraction under [local].
  double fractionAt(Offset local) {
    if (length == 0) return 0;
    final double along = axis == Axis.horizontal ? local.dx : local.dy;
    final double f = (along - metrics.cap) / length;
    return (_reversed ? 1 - f : f).clamp(0, 1).toDouble();
  }

  /// The change in fraction for a pointer movement of [delta].
  double fractionDelta(Offset delta) {
    if (length == 0) return 0;
    final double along = axis == Axis.horizontal ? delta.dx : delta.dy;
    return (_reversed ? -along : along) / length;
  }
}

/// Keyboard commands of a focused thumb.
enum _ThumbKey { decrement, increment, pageDecrement, pageIncrement, min, max }

class _ThumbKeyIntent extends Intent {
  const _ThumbKeyIntent(this.key);

  final _ThumbKey key;
}

class _HeroSliderRootState extends State<HeroSlider> {
  late List<double> _uncontrolled;
  late List<double> _initial;
  final List<FocusNode> _nodes = <FocusNode>[];
  final GlobalKey<_HeroSliderFormFieldState> _fieldKey =
      GlobalKey<_HeroSliderFormFieldState>();

  /// The names set on the thumbs, by index (collected by the track).
  Map<int, String> _thumbNames = const <int, String>{};

  /// The thumb being dragged (`data-dragging`).
  int? _dragging;

  /// The thumb a pointer is moving, and its position as a fraction.
  int? _activeThumb;
  double _activeFraction = 0;

  /// Whether a drag gesture (rather than a tap) is in progress.
  bool _pointerDragging = false;

  bool get _controlled =>
      widget.isRange ? widget.values != null : widget.value != null;

  List<double> get _values {
    final List<double>? controlled = widget.isRange
        ? widget.values
        : (widget.value == null ? null : <double>[widget.value!]);
    return controlled == null ? _uncontrolled : _normalize(controlled);
  }

  @override
  void initState() {
    super.initState();
    _uncontrolled = _normalize(
      widget.isRange
          ? (widget.values ??
                widget.defaultValues ??
                <double>[widget.minValue, widget.maxValue])
          : <double>[widget.value ?? widget.defaultValue ?? widget.minValue],
    );
    _initial = _uncontrolled;
  }

  @override
  void didUpdateWidget(HeroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controlled) {
      final List<double> values = _values;
      final _HeroSliderFormFieldState? field = _fieldKey.currentState;
      if (field != null && !listEquals(field.value, values)) {
        field.syncValue(values);
      }
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  List<double> _normalize(List<double> values) {
    final List<double> result = <double>[
      for (final double v in values)
        v.isNaN ? widget.minValue : v.clamp(widget.minValue, widget.maxValue),
    ]..sort();
    return result.isEmpty ? <double>[widget.minValue] : result;
  }

  FocusNode _nodeFor(int index) {
    while (_nodes.length <= index) {
      _nodes.add(FocusNode(debugLabel: 'HeroSliderThumb#${_nodes.length}'));
    }
    return _nodes[index];
  }

  /// Snaps [value] to the step grid inside the range, like React Aria's
  /// `snapValueToStep`.
  double _snap(double value) {
    final double min = widget.minValue;
    final double max = widget.maxValue;
    final double step = widget.step;
    double snapped = min + ((value - min) / step).round() * step;
    if (snapped > max) snapped = min + ((max - min) / step).floor() * step;
    snapped = snapped.clamp(min, max).toDouble();
    final String text = step.toString();
    final int dot = text.indexOf('.');
    final int decimals = text.contains('e')
        ? 10
        : (dot < 0 ? 0 : text.length - dot - 1);
    return double.parse(snapped.toStringAsFixed(decimals));
  }

  double get _pageSize {
    final double tenth = (widget.maxValue - widget.minValue) / 10;
    return math.max(widget.step, (tenth / widget.step).floor() * widget.step);
  }

  double _thumbMin(List<double> values, int index) =>
      index == 0 ? widget.minValue : values[index - 1];

  double _thumbMax(List<double> values, int index) =>
      index == values.length - 1 ? widget.maxValue : values[index + 1];

  double _valueAt(double fraction) =>
      widget.minValue + fraction * (widget.maxValue - widget.minValue);

  double _fractionOf(double value) =>
      HeroRangeFormat.fraction(value, widget.minValue, widget.maxValue);

  void _setThumbValue(int index, double value) {
    final List<double> values = _values;
    if (index >= values.length) return;
    final double next = _snap(
      value,
    ).clamp(_thumbMin(values, index), _thumbMax(values, index)).toDouble();
    if (next == values[index]) return;
    final List<double> updated = List<double>.of(values)..[index] = next;
    if (!_controlled) setState(() => _uncontrolled = updated);
    _fieldKey.currentState?.didChange(updated);
    if (widget.isRange) {
      widget.onRangeChanged?.call(List<double>.unmodifiable(updated));
    } else {
      widget.onChanged?.call(updated.first);
    }
  }

  void _notifyChangeEnd() {
    final List<double> values = _values;
    if (widget.isRange) {
      widget.onRangeChangeEnd?.call(List<double>.unmodifiable(values));
    } else {
      widget.onChangeEnd?.call(values.first);
    }
  }

  void _handleKey(int index, _ThumbKey key) {
    final List<double> values = _values;
    if (widget.isDisabled || index >= values.length) return;
    final double current = values[index];
    final double target = switch (key) {
      _ThumbKey.decrement => current - widget.step,
      _ThumbKey.increment => current + widget.step,
      _ThumbKey.pageDecrement => current - _pageSize,
      _ThumbKey.pageIncrement => current + _pageSize,
      _ThumbKey.min => _thumbMin(values, index),
      _ThumbKey.max => _thumbMax(values, index),
    };
    _setThumbValue(index, target);
    _notifyChangeEnd();
  }

  /// The thumb React Aria moves when the track is pressed at [value].
  int _closestThumb(List<double> values, double value) {
    final int split = values.indexWhere((double v) => value - v < 0);
    if (split == 0) return 0;
    if (split == -1) return values.length - 1;
    final double lastLeft = values[split - 1];
    final double firstRight = values[split];
    return (lastLeft - value).abs() < (firstRight - value).abs()
        ? split - 1
        : split;
  }

  void _pointerDown(
    _TrackGeometry geometry,
    Offset local,
    Set<int> disabledThumbs,
  ) {
    if (widget.isDisabled || _activeThumb != null) return;
    final List<double> values = _values;
    int? thumb;
    for (int i = values.length - 1; i >= 0; i--) {
      if (disabledThumbs.contains(i)) continue;
      if (geometry.thumbRect(_fractionOf(values[i])).contains(local)) {
        thumb = i;
        _activeFraction = _fractionOf(values[i]);
        break;
      }
    }
    if (thumb == null) {
      final double fraction = geometry.fractionAt(local);
      final int closest = _closestThumb(values, _valueAt(fraction));
      if (disabledThumbs.contains(closest)) return;
      thumb = closest;
      _activeFraction = fraction;
      _setThumbValue(thumb, _valueAt(fraction));
    }
    _activeThumb = thumb;
    _nodeFor(thumb).requestFocus();
    setState(() => _dragging = thumb);
  }

  void _pointerMove(_TrackGeometry geometry, Offset delta) {
    final int? thumb = _activeThumb;
    if (thumb == null) return;
    _activeFraction += geometry.fractionDelta(delta);
    _setThumbValue(thumb, _valueAt(_activeFraction.clamp(0, 1).toDouble()));
  }

  void _pointerUp() {
    if (_activeThumb == null) return;
    _activeThumb = null;
    if (mounted) setState(() => _dragging = null);
    _notifyChangeEnd();
  }

  void _handleTapCancel() {
    // A tap is cancelled right before a drag takes over the same pointer;
    // only end the interaction when no drag follows.
    scheduleMicrotask(() {
      if (!_pointerDragging) _pointerUp();
    });
  }

  void _handleDragStart(
    _TrackGeometry geometry,
    Offset local,
    Set<int> disabledThumbs,
  ) {
    _pointerDragging = true;
    _pointerDown(geometry, local, disabledThumbs);
  }

  void _handleDragEnd() {
    _pointerDragging = false;
    _pointerUp();
  }

  void _handleSaved(List<double>? values) {
    widget.onSaved?.call(values);
    if (values == null || widget.isDisabled) return;
    final HeroFormState? form = context
        .findAncestorStateOfType<HeroFormState>();
    if (form == null) return;
    for (int i = 0; i < values.length; i++) {
      final String? name = _thumbNames[i] ?? widget.name;
      if (name != null) form.addValue(name, values[i]);
    }
  }

  void _handleReset() {
    if (!_controlled) setState(() => _uncontrolled = _initial);
    if (widget.isRange) {
      widget.onRangeChanged?.call(List<double>.unmodifiable(_initial));
    } else {
      widget.onChanged?.call(_initial.first);
    }
  }

  static String? _textOf(Widget? label) => switch (label) {
    HeroLabel(:final String? data?) => data,
    HeroLabel(child: Text(:final String? data?)) => data,
    Text(:final String? data?) => data,
    _ => null,
  };

  List<Widget> _standardParts() {
    final Widget? label = widget.label;
    return <Widget>[
      if (label != null) label is HeroLabel ? label : HeroLabel(child: label),
      if (widget.showOutput ?? label != null) const HeroSliderOutput(),
      const HeroSliderTrack(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<double> values = _values;
    return _HeroSliderFormField(
      key: _fieldKey,
      initialValue: values,
      validator: widget.validator,
      onSaved: _handleSaved,
      onReset: _handleReset,
      autovalidateMode: widget.autovalidateMode,
      enabled: !widget.isDisabled,
      builder: (FormFieldState<List<double>> field) =>
          _buildSlider(field.context, values),
    );
  }

  Widget _buildSlider(BuildContext context, List<double> values) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroSliderState state = HeroSliderState(
      values: List<double>.unmodifiable(values),
      valueLabels: List<String>.unmodifiable(<String>[
        for (final double v in values)
          HeroRangeFormat.valueText(context, v, format: widget.numberFormat),
      ]),
      minValue: widget.minValue,
      maxValue: widget.maxValue,
      orientation: widget.orientation,
      isDisabled: widget.isDisabled,
    );
    final List<Widget> parts =
        widget.builder?.call(context, state) ??
        widget.children ??
        _standardParts();

    Widget? label;
    Widget? output;
    Widget? track;
    final List<Widget> rest = <Widget>[];
    for (final Widget part in parts) {
      if (part is HeroLabel && label == null) {
        label = part;
      } else if (part is HeroSliderOutput && output == null) {
        output = part;
      } else if (part is HeroSliderTrack && track == null) {
        track = part;
      } else {
        rest.add(part);
      }
    }
    final String? thumbLabel = widget.semanticLabel ?? _textOf(label);
    track ??= const HeroSliderTrack();

    final Widget layout = switch (widget.orientation) {
      Axis.horizontal => HeroRangeLayout(
        label: label,
        output: output,
        track: track,
        children: rest,
      ),
      Axis.vertical => HeroFillExtent(
        axis: Axis.vertical,
        fallback: theme.spacing(64),
        child: DefaultTextStyle.merge(
          textAlign: TextAlign.center,
          child: Column(
            spacing: theme.spacing(2),
            children: <Widget>[
              ?output,
              Expanded(child: track),
              ?label,
              ...rest,
            ],
          ),
        ),
      ),
    };

    return HeroDisabledOpacity(
      disabled: widget.isDisabled,
      child: _HeroSliderScope(
        controller: this,
        state: state,
        style: widget.style,
        dragging: _dragging,
        thumbLabel: thumbLabel,
        child: HeroFieldScope(
          // Pressing the label focuses the first thumb (`htmlFor`); the
          // label text is announced by the thumbs.
          focusNode: _nodeFor(0),
          semanticLabel: thumbLabel,
          child: layout,
        ),
      ),
    );
  }
}

/// The `FormField` a slider registers with the nearest [Form].
class _HeroSliderFormField extends FormField<List<double>> {
  const _HeroSliderFormField({
    super.key,
    required super.builder,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.onReset,
    super.autovalidateMode,
    super.enabled,
  });

  @override
  FormFieldState<List<double>> createState() => _HeroSliderFormFieldState();
}

class _HeroSliderFormFieldState extends FormFieldState<List<double>> {
  /// Updates the value without notifying the form (a new controlled
  /// value).
  void syncValue(List<double> value) => setValue(value);
}

/// Shares the state and controller of a [HeroSlider] with its parts.
class _HeroSliderScope extends InheritedWidget {
  const _HeroSliderScope({
    required this.controller,
    required this.state,
    required this.style,
    required this.dragging,
    required this.thumbLabel,
    required super.child,
  });

  final _HeroSliderRootState controller;
  final HeroSliderState state;
  final HeroSliderStyle? style;
  final int? dragging;
  final String? thumbLabel;

  static _HeroSliderScope of(BuildContext context) {
    final _HeroSliderScope? scope = context
        .dependOnInheritedWidgetOfExactType<_HeroSliderScope>();
    assert(scope != null, 'Slider parts must be placed inside a HeroSlider.');
    return scope!;
  }

  @override
  bool updateShouldNotify(_HeroSliderScope oldWidget) =>
      state != oldWidget.state ||
      style != oldWidget.style ||
      dragging != oldWidget.dragging ||
      thumbLabel != oldWidget.thumbLabel;
}

/// The formatted value of a [HeroSlider] (HeroUI `Slider.Output`):
/// `text-sm font-medium` with tabular figures, in the surrounding text
/// color.
///
/// By default it shows the thumb labels joined by " – " ("$100 – $500").
/// The value is announced by the thumbs, so the output is excluded from
/// semantics.
class HeroSliderOutput extends StatelessWidget {
  /// Creates the output.
  const HeroSliderOutput({super.key, this.child, this.builder, this.style});

  /// Replaces the value text.
  final Widget? child;

  /// Builds the content from the slider state; replaces [child].
  final HeroSliderOutputBuilder? builder;

  /// Style merged over the output style (a `text-*` class).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroSliderScope scope = _HeroSliderScope.of(context);
    final TextStyle textStyle = theme.typography
        .style(HeroFontSize.sm, weight: HeroTypography.medium)
        .copyWith(
          color:
              DefaultTextStyle.of(context).style.color ??
              theme.colors.foreground,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        )
        .merge(scope.style?.outputStyle?.copyWith(inherit: true))
        .merge(style?.copyWith(inherit: true));
    final Widget content =
        builder?.call(context, scope.state) ??
        child ??
        Text(scope.state.valueLabels.join(' – '));
    return ExcludeSemantics(
      child: DefaultTextStyle.merge(style: textStyle, child: content),
    );
  }
}

/// The track of a [HeroSlider] (HeroUI `Slider.Track`).
///
/// A `--default` bar, 20 thick with a 12 radius, whose 12-pixel end caps
/// leave room for the thumbs at the ends of the range; a cap turns
/// `--accent` when the fill reaches it. It lays out its parts: a
/// [HeroSliderFill] spans the selected range and each [HeroSliderThumb]
/// sits centered on its value. Without [children] it shows a fill and one
/// thumb per value.
///
/// Pressing the track moves the closest thumb to the pointer and keeps
/// dragging it.
class HeroSliderTrack extends StatelessWidget {
  /// Creates the track.
  const HeroSliderTrack({super.key, this.children, this.builder, this.color});

  /// The parts: a [HeroSliderFill] and [HeroSliderThumb]s; other widgets
  /// cover the whole track.
  final List<Widget>? children;

  /// Builds the parts from the slider state; replaces [children].
  final HeroSliderPartsBuilder? builder;

  /// Background color (`bg-*`); defaults to `--default`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroSliderScope scope = _HeroSliderScope.of(context);
    final HeroSliderState state = scope.state;
    final _HeroSliderRootState controller = scope.controller;
    final _SliderMetrics metrics = _SliderMetrics(theme);
    final TextDirection direction = Directionality.of(context);
    final Axis axis = state.orientation;

    final List<Widget> parts =
        builder?.call(context, state) ??
        children ??
        <Widget>[
          const HeroSliderFill(),
          for (int i = 0; i < state.values.length; i++)
            HeroSliderThumb(index: i),
        ];
    controller._thumbNames = <int, String>{
      for (final Widget part in parts)
        if (part is HeroSliderThumb && part.name != null)
          part.index: part.name!,
    };
    final Set<int> disabledThumbs = <int>{
      for (final Widget part in parts)
        if (part is HeroSliderThumb && part.isDisabled) part.index,
    };

    final List<double> fractions = <double>[
      for (int i = 0; i < state.values.length; i++) state.getThumbPercent(i),
    ];
    final double fillStart = fractions.length > 1 ? fractions.first : 0;
    final double fillEnd = fractions.last;
    // `data-fill-start` / `data-fill-end`, as computed by HeroUI.
    final bool single = fractions.length == 1;
    final bool capStart = single ? fillEnd > 0 : fillStart == 0;
    final bool capEnd = fillEnd >= 1;

    int otherId = 0;
    Widget result = CustomMultiChildLayout(
      delegate: _HeroSliderTrackLayout(
        fractions: fractions,
        fillStart: fillStart,
        fillEnd: fillEnd,
        axis: axis,
        textDirection: direction,
        metrics: metrics,
      ),
      children: <Widget>[
        for (final Widget part in parts)
          LayoutId(
            id: switch (part) {
              HeroSliderFill() => const _PartId.fill(),
              HeroSliderThumb(:final int index) => _PartId.thumb(index),
              _ => _PartId.other(otherId++),
            },
            child: part,
          ),
      ],
    );

    result = CustomPaint(
      painter: _HeroSliderTrackPainter(
        color: color ?? scope.style?.trackColor ?? theme.colors.defaultColor,
        capColor: scope.style?.fillColor ?? theme.colors.accent,
        capStart: capStart,
        capEnd: capEnd,
        axis: axis,
        textDirection: direction,
        cap: metrics.cap,
        shape: theme.shapeAll(metrics.trackRadius),
      ),
      child: result,
    );

    if (!state.isDisabled) {
      _TrackGeometry geometryOf(BuildContext context) => _TrackGeometry(
        size: (context.findRenderObject()! as RenderBox).size,
        axis: axis,
        textDirection: direction,
        metrics: metrics,
      );
      final Widget painted = result;
      result = Builder(
        builder: (BuildContext context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          dragStartBehavior: DragStartBehavior.down,
          onTapDown: (TapDownDetails details) => controller._pointerDown(
            geometryOf(context),
            details.localPosition,
            disabledThumbs,
          ),
          onTapUp: (_) => controller._pointerUp(),
          onTapCancel: controller._handleTapCancel,
          onHorizontalDragStart: axis == Axis.horizontal
              ? (DragStartDetails details) => controller._handleDragStart(
                  geometryOf(context),
                  details.localPosition,
                  disabledThumbs,
                )
              : null,
          onHorizontalDragUpdate: axis == Axis.horizontal
              ? (DragUpdateDetails details) =>
                    controller._pointerMove(geometryOf(context), details.delta)
              : null,
          onHorizontalDragEnd: axis == Axis.horizontal
              ? (_) => controller._handleDragEnd()
              : null,
          onHorizontalDragCancel: axis == Axis.horizontal
              ? controller._handleDragEnd
              : null,
          onVerticalDragStart: axis == Axis.vertical
              ? (DragStartDetails details) => controller._handleDragStart(
                  geometryOf(context),
                  details.localPosition,
                  disabledThumbs,
                )
              : null,
          onVerticalDragUpdate: axis == Axis.vertical
              ? (DragUpdateDetails details) =>
                    controller._pointerMove(geometryOf(context), details.delta)
              : null,
          onVerticalDragEnd: axis == Axis.vertical
              ? (_) => controller._handleDragEnd()
              : null,
          onVerticalDragCancel: axis == Axis.vertical
              ? controller._handleDragEnd
              : null,
          child: painted,
        ),
      );
    }

    return Align(
      widthFactor: axis == Axis.vertical ? 1 : null,
      heightFactor: axis == Axis.horizontal ? 1 : null,
      child: result,
    );
  }
}

/// Identifies a part of a slider track for its layout.
@immutable
class _PartId {
  const _PartId.fill() : kind = 0, index = 0;
  const _PartId.thumb(this.index) : kind = 1;
  const _PartId.other(this.index) : kind = 2;

  final int kind;
  final int index;

  @override
  bool operator ==(Object other) =>
      other is _PartId && other.kind == kind && other.index == index;

  @override
  int get hashCode => Object.hash(kind, index);
}

/// Sizes the track (full length, 20 thick) and places its parts.
class _HeroSliderTrackLayout extends MultiChildLayoutDelegate {
  _HeroSliderTrackLayout({
    required this.fractions,
    required this.fillStart,
    required this.fillEnd,
    required this.axis,
    required this.textDirection,
    required this.metrics,
  });

  final List<double> fractions;
  final double fillStart;
  final double fillEnd;
  final Axis axis;
  final TextDirection textDirection;
  final _SliderMetrics metrics;

  @override
  Size getSize(BoxConstraints constraints) {
    final double thickness = metrics.thickness;
    return constraints.constrain(
      axis == Axis.horizontal
          ? Size(
              constraints.hasBoundedWidth
                  ? constraints.maxWidth
                  : constraints.minWidth,
              thickness,
            )
          : Size(
              thickness,
              constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : constraints.minHeight,
            ),
    );
  }

  @override
  void performLayout(Size size) {
    final _TrackGeometry geometry = _TrackGeometry(
      size: size,
      axis: axis,
      textDirection: textDirection,
      metrics: metrics,
    );
    const _PartId fill = _PartId.fill();
    if (hasChild(fill)) {
      final Rect rect = geometry.fillRect(fillStart, fillEnd);
      layoutChild(fill, BoxConstraints.tight(rect.size));
      positionChild(fill, rect.topLeft);
    }
    for (int i = 0; i < fractions.length; i++) {
      final _PartId thumb = _PartId.thumb(i);
      if (!hasChild(thumb)) continue;
      final Rect rect = geometry.thumbRect(fractions[i]);
      layoutChild(thumb, BoxConstraints.tight(rect.size));
      positionChild(thumb, rect.topLeft);
    }
    for (int i = 0; hasChild(_PartId.other(i)); i++) {
      layoutChild(_PartId.other(i), BoxConstraints.tight(size));
      positionChild(_PartId.other(i), Offset.zero);
    }
    // Thumbs whose index has no value are not shown.
    for (int i = fractions.length; hasChild(_PartId.thumb(i)); i++) {
      layoutChild(_PartId.thumb(i), BoxConstraints.tight(Size.zero));
      positionChild(_PartId.thumb(i), Offset.zero);
    }
  }

  @override
  bool shouldRelayout(_HeroSliderTrackLayout oldDelegate) =>
      !listEquals(oldDelegate.fractions, fractions) ||
      oldDelegate.fillStart != fillStart ||
      oldDelegate.fillEnd != fillEnd ||
      oldDelegate.axis != axis ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.metrics.thickness != metrics.thickness ||
      oldDelegate.metrics.cap != metrics.cap ||
      oldDelegate.metrics.thumbLength != metrics.thumbLength;
}

/// Paints the track background and its colored end caps.
class _HeroSliderTrackPainter extends CustomPainter {
  const _HeroSliderTrackPainter({
    required this.color,
    required this.capColor,
    required this.capStart,
    required this.capEnd,
    required this.axis,
    required this.textDirection,
    required this.cap,
    required this.shape,
  });

  final Color color;
  final Color capColor;
  final bool capStart;
  final bool capEnd;
  final Axis axis;
  final TextDirection textDirection;
  final double cap;
  final ShapeBorder shape;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path outline = shape.getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(outline, Paint()..color = color);
    if (!capStart && !capEnd) return;
    // The start cap is the inline start (right in right-to-left layouts)
    // or the bottom of a vertical track.
    final Rect startCap;
    final Rect endCap;
    switch (axis) {
      case Axis.horizontal:
        final Rect left = Rect.fromLTWH(0, 0, cap, size.height);
        final Rect right = Rect.fromLTWH(size.width - cap, 0, cap, size.height);
        final bool rtl = textDirection == TextDirection.rtl;
        startCap = rtl ? right : left;
        endCap = rtl ? left : right;
      case Axis.vertical:
        startCap = Rect.fromLTWH(0, size.height - cap, size.width, cap);
        endCap = Rect.fromLTWH(0, 0, size.width, cap);
    }
    canvas
      ..save()
      ..clipPath(outline);
    final Paint paint = Paint()..color = capColor;
    if (capStart) canvas.drawRect(startCap, paint);
    if (capEnd) canvas.drawRect(endCap, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeroSliderTrackPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.capColor != capColor ||
      oldDelegate.capStart != capStart ||
      oldDelegate.capEnd != capEnd ||
      oldDelegate.axis != axis ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.cap != cap ||
      oldDelegate.shape != shape;
}

/// The selected part of a [HeroSliderTrack] (HeroUI `Slider.Fill`): an
/// `--accent` band from the minimum (or the first thumb of a range) to
/// the last thumb. It has no radius and ignores the pointer.
class HeroSliderFill extends StatelessWidget {
  /// Creates the fill.
  const HeroSliderFill({super.key, this.color});

  /// Fill color (`bg-*`); defaults to `--accent`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroSliderScope scope = _HeroSliderScope.of(context);
    return IgnorePointer(
      child: ColoredBox(
        color: color ?? scope.style?.fillColor ?? theme.colors.accent,
      ),
    );
  }
}

/// A draggable thumb of a [HeroSlider] (HeroUI `Slider.Thumb`) for the
/// value at [index].
///
/// A 28 × 20 `--accent` pill (20 × 28 when vertical) around a 24 × 16
/// `--accent-foreground` knob with the field shadow, so the thumb reads as
/// a white pill in a 2 px accent frame. The knob shrinks to 90% while
/// dragged; keyboard focus shows the focus ring.
///
/// Each thumb is focusable and exposed as a slider to assistive
/// technologies, with its formatted value and increase / decrease
/// actions.
class HeroSliderThumb extends StatelessWidget {
  /// Creates the thumb for value [index].
  const HeroSliderThumb({
    super.key,
    this.index = 0,
    this.isDisabled = false,
    this.color,
    this.knobColor,
    this.name,
    this.child,
  });

  /// The index of the value this thumb controls.
  final int index;

  /// Whether this thumb cannot be moved.
  final bool isDisabled;

  /// Frame color (`bg-*`); defaults to `--accent`.
  final Color? color;

  /// Knob color (`after:bg-*`); defaults to `--accent-foreground`.
  final Color? knobColor;

  /// The form name of this thumb's value (the hidden input's `name`);
  /// defaults to [HeroSlider.name].
  final String? name;

  /// Content shown on the knob.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final _HeroSliderScope scope = _HeroSliderScope.of(context);
    if (index >= scope.state.values.length) return const SizedBox.shrink();
    return _HeroSliderThumbControl(
      scope: scope,
      thumb: this,
      focusNode: scope.controller._nodeFor(index),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('index', index))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroSliderThumbControl extends StatefulWidget {
  const _HeroSliderThumbControl({
    required this.scope,
    required this.thumb,
    required this.focusNode,
  });

  final _HeroSliderScope scope;
  final HeroSliderThumb thumb;
  final FocusNode focusNode;

  @override
  State<_HeroSliderThumbControl> createState() =>
      _HeroSliderThumbControlState();
}

class _HeroSliderThumbControlState extends State<_HeroSliderThumbControl> {
  bool _focused = false;
  bool _focusVisible = false;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    _ThumbKeyIntent: CallbackAction<_ThumbKeyIntent>(
      onInvoke: (_ThumbKeyIntent intent) =>
          widget.scope.controller._handleKey(widget.thumb.index, intent.key),
    ),
  };

  Map<ShortcutActivator, Intent> _shortcuts(TextDirection direction) {
    final bool rtl = direction == TextDirection.rtl;
    return <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.arrowUp): const _ThumbKeyIntent(
        _ThumbKey.increment,
      ),
      const SingleActivator(LogicalKeyboardKey.arrowDown):
          const _ThumbKeyIntent(_ThumbKey.decrement),
      const SingleActivator(LogicalKeyboardKey.arrowRight): _ThumbKeyIntent(
        rtl ? _ThumbKey.decrement : _ThumbKey.increment,
      ),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): _ThumbKeyIntent(
        rtl ? _ThumbKey.increment : _ThumbKey.decrement,
      ),
      const SingleActivator(LogicalKeyboardKey.pageUp): const _ThumbKeyIntent(
        _ThumbKey.pageIncrement,
      ),
      const SingleActivator(LogicalKeyboardKey.pageDown): const _ThumbKeyIntent(
        _ThumbKey.pageDecrement,
      ),
      const SingleActivator(LogicalKeyboardKey.home): const _ThumbKeyIntent(
        _ThumbKey.min,
      ),
      const SingleActivator(LogicalKeyboardKey.end): const _ThumbKeyIntent(
        _ThumbKey.max,
      ),
    };
  }

  void _step(int direction) {
    widget.scope.controller._handleKey(
      widget.thumb.index,
      direction > 0 ? _ThumbKey.increment : _ThumbKey.decrement,
    );
  }

  String? _labelFor(double value, HeroSliderState state) {
    final _HeroSliderRootState controller = widget.scope.controller;
    final int index = widget.thumb.index;
    final double bounded = controller
        ._snap(value)
        .clamp(
          controller._thumbMin(state.values, index),
          controller._thumbMax(state.values, index),
        )
        .toDouble();
    if (bounded == state.values[index]) return null;
    return HeroRangeFormat.valueText(
      context,
      bounded,
      format: controller.widget.numberFormat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroSliderScope scope = widget.scope;
    final HeroSliderThumb thumb = widget.thumb;
    final HeroSliderState state = scope.state;
    final int index = thumb.index;
    final bool enabled = !state.isDisabled && !thumb.isDisabled;
    final bool dragging = scope.dragging == index;
    final bool vertical = state.orientation == Axis.vertical;
    final _SliderMetrics metrics = _SliderMetrics(theme);
    final TextDirection direction = Directionality.of(context);
    final double value = state.values[index];
    final double step = scope.controller.widget.step;

    final Color frame =
        thumb.color ?? scope.style?.thumbColor ?? theme.colors.accent;
    final Color knob =
        thumb.knobColor ??
        scope.style?.knobColor ??
        theme.colors.accentForeground;

    Widget knobBox = DecoratedBox(
      decoration: ShapeDecoration(
        color: knob,
        shape: theme.shapeAll(metrics.knobRadius),
        shadows: theme.shadows.field.boxShadows,
      ),
      child: thumb.child == null ? null : Center(child: thumb.child),
    );
    knobBox = SizedBox(
      width: vertical ? metrics.knobThickness : metrics.knobLength,
      height: vertical ? metrics.knobLength : metrics.knobThickness,
      child: knobBox,
    );
    knobBox = AnimatedScale(
      scale: dragging && !theme.motion.shouldReduceMotion(context) ? 0.9 : 1,
      duration: theme.motion.resolve(context, HeroMotion.normal),
      curve: HeroMotion.easeInOut,
      child: knobBox,
    );

    final OutlinedBorder shape = theme.shapeAll(metrics.thumbRadius);
    Widget result = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: frame),
      duration: theme.motion.resolve(context, HeroMotion.slow),
      curve: HeroMotion.smooth,
      child: Center(child: knobBox),
      builder: (BuildContext context, Color? color, Widget? child) =>
          DecoratedBox(
            decoration: ShapeDecoration(color: color, shape: shape),
            child: child,
          ),
    );
    result = HeroFocusRing(
      visible: _focusVisible && _focused && enabled,
      shape: shape,
      child: result,
    );

    result = FocusableActionDetector(
      focusNode: widget.focusNode,
      enabled: enabled,
      shortcuts: _shortcuts(direction),
      actions: _actions,
      mouseCursor: !enabled
          ? SystemMouseCursors.basic
          : (dragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab),
      includeFocusSemantics: false,
      onShowFocusHighlight: (bool value) =>
          setState(() => _focusVisible = value),
      onFocusChange: (bool value) => setState(() => _focused = value),
      child: result,
    );

    final String? increased = enabled ? _labelFor(value + step, state) : null;
    final String? decreased = enabled ? _labelFor(value - step, state) : null;
    return Semantics(
      container: true,
      slider: true,
      label: scope.thumbLabel,
      value: state.valueLabels[index],
      increasedValue: increased,
      decreasedValue: decreased,
      onIncrease: increased == null ? null : () => _step(1),
      onDecrease: decreased == null ? null : () => _step(-1),
      enabled: enabled,
      focusable: enabled,
      focused: enabled ? _focused : null,
      textDirection: direction,
      child: result,
    );
  }
}
