/// HeroUI's ColorSlider: a slider that adjusts one channel of a color.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../color/color.dart';
import '../input/hero_field.dart';
import '../label/label.dart';

export '../color/color.dart';

/// The render props of a [HeroColorSlider] (`{state, color, orientation,
/// isDisabled}`).
@immutable
class HeroColorSliderState {
  /// Creates a slider state.
  const HeroColorSliderState({
    required this.value,
    required this.channel,
    required this.orientation,
    this.isDisabled = false,
    this.isDragging = false,
    this.isFocused = false,
    this.isFocusVisible = false,
  });

  /// The current value, in the slider's color space.
  final HeroColorValue value;

  /// The channel the slider edits.
  final HeroColorChannel channel;

  /// The slider orientation.
  final Axis orientation;

  /// Whether the slider is disabled.
  final bool isDisabled;

  /// Whether the thumb is being dragged.
  final bool isDragging;

  /// Whether the thumb has focus.
  final bool isFocused;

  /// Whether the thumb has keyboard focus (focus ring shown).
  final bool isFocusVisible;

  /// The current value as a Flutter color.
  Color get color => value.toColor();

  /// The color space the slider works in.
  HeroColorSpace get colorSpace => value.space;

  /// The value of [channel].
  double get channelValue => value.channelValue(channel);

  /// The position of the thumb along the track, from 0 to 1.
  double get fraction => channel.range.fraction(channelValue);

  /// The formatted channel value shown by the output ("200°", "50%").
  String get valueLabel => value.formatChannelValue(channel);

  /// The color the thumb and track show (React Aria's `getDisplayColor`):
  /// the pure hue for [HeroColorChannel.hue], the value including alpha for
  /// [HeroColorChannel.alpha], and the opaque value otherwise.
  HeroColorValue get displayColor => switch (channel) {
    HeroColorChannel.hue => HeroColorValue.hsl(
      value.channelValue(HeroColorChannel.hue),
      100,
      50,
    ),
    HeroColorChannel.alpha => value,
    _ => value.withAlpha(1),
  };

  @override
  bool operator ==(Object other) =>
      other is HeroColorSliderState &&
      other.value == value &&
      other.channel == channel &&
      other.orientation == orientation &&
      other.isDisabled == isDisabled &&
      other.isDragging == isDragging &&
      other.isFocused == isFocused &&
      other.isFocusVisible == isFocusVisible;

  @override
  int get hashCode => Object.hash(
    value,
    channel,
    orientation,
    isDisabled,
    isDragging,
    isFocused,
    isFocusVisible,
  );
}

/// Builds content from the state of a [HeroColorSlider].
typedef HeroColorSliderWidgetBuilder =
    Widget Function(BuildContext context, HeroColorSliderState state);

/// A slider that adjusts one channel of a color (HeroUI `ColorSlider`).
///
/// ```dart
/// HeroColorSlider(
///   channel: HeroColorChannel.hue,
///   label: 'Hue',
///   defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
/// )
/// ```
///
/// The track shows the channel's gradient over the transparency
/// checkerboard with rounded end caps; the thumb shows the current color
/// (the pure hue for the hue channel) with a white border.
///
/// * [channel]: hue, saturation, lightness, brightness, red, green, blue or
///   alpha.
/// * [colorSpace]: the space the channel is read in. Channels that need
///   another space are corrected like HeroUI does (red/green/blue → rgb,
///   lightness → hsl, brightness → hsb, hue/saturation with rgb → hsl).
///   Defaults to hsl (hsb for brightness, rgb for red/green/blue).
/// * [orientation]: horizontal (default) or vertical (min at the bottom).
/// * [label] and [showOutput] build the default layout (label and value
///   above the track, or value / track / label in a column when
///   vertical). Pass [children] (a [HeroLabel], a [HeroColorSliderOutput]
///   and a [HeroColorSliderTrack]) or a [builder] to compose the parts.
///
/// The value is a [Color]: controlled with [value] + [onChanged],
/// uncontrolled with [defaultValue], or, without either inside a
/// `HeroColorPicker`, the picker's color. The slider keeps its own hue and
/// saturation so the thumb does not jump when the color becomes gray,
/// black or white.
///
/// Pointer: tap the track to jump, drag to adjust; [onChangeEnd] fires on
/// release. Keyboard (focus on the thumb): arrows ± step (Shift: ± page),
/// Page Up / Page Down ± page, Home / End to the minimum / maximum.
class HeroColorSlider extends StatefulWidget {
  /// Creates a color slider.
  const HeroColorSlider({
    super.key,
    required this.channel,
    this.colorSpace,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onChangeEnd,
    this.orientation = Axis.horizontal,
    this.isDisabled = false,
    this.label,
    this.showOutput,
    this.children,
    this.builder,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// The channel the slider adjusts.
  final HeroColorChannel channel;

  /// The color space the channel is read in.
  final HeroColorSpace? colorSpace;

  /// The current color (controlled).
  final Color? value;

  /// The initial color (uncontrolled); white when null.
  final Color? defaultValue;

  /// Called with the new color while the user adjusts it.
  final ValueChanged<Color>? onChanged;

  /// Called with the final color when the user stops adjusting.
  final ValueChanged<Color>? onChangeEnd;

  /// The direction of the track.
  final Axis orientation;

  /// Whether the slider is disabled.
  final bool isDisabled;

  /// A label shown above (horizontal) or below (vertical) the track.
  final String? label;

  /// Whether to show the formatted value; defaults to true with a [label].
  final bool? showOutput;

  /// Custom parts laid out like HeroUI's grid: a [HeroLabel], a
  /// [HeroColorSliderOutput] and a [HeroColorSliderTrack].
  final List<Widget>? children;

  /// Builds the whole content from the slider state; replaces [children].
  final HeroColorSliderWidgetBuilder? builder;

  /// The focus node of the thumb.
  final FocusNode? focusNode;

  /// Whether to focus the thumb when first built.
  final bool autofocus;

  /// Accessibility label; defaults to [label], then the channel name.
  final String? semanticLabel;

  @override
  State<HeroColorSlider> createState() => _HeroColorSliderState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HeroColorChannel>('channel', channel))
      ..add(
        EnumProperty<HeroColorSpace>(
          'colorSpace',
          colorSpace,
          defaultValue: null,
        ),
      )
      ..add(ColorProperty('value', value, defaultValue: null))
      ..add(
        EnumProperty<Axis>(
          'orientation',
          orientation,
          defaultValue: Axis.horizontal,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroColorSliderState extends State<HeroColorSlider> {
  FocusNode? _ownFocusNode;
  HeroColorValue? _value;
  bool _dragging = false;
  bool _focused = false;
  bool _highlight =
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroColorSlider'));

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_handleHighlightMode);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_handleHighlightMode);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _handleHighlightMode(FocusHighlightMode mode) {
    final bool highlight = mode == FocusHighlightMode.traditional;
    if (highlight == _highlight) return;
    setState(() => _highlight = highlight);
  }

  void _handleFocusChanged(bool focused) {
    if (focused == _focused) return;
    setState(() => _focused = focused);
  }

  HeroColorSpace _space(HeroColorValue? source) {
    final HeroColorSpace? preferred =
        widget.colorSpace ??
        (source != null && widget.channel.isIn(source.space)
            ? source.space
            : null);
    return widget.channel.resolveSpace(preferred);
  }

  // Resolves the displayed value from the controlled value, the picker
  // scope or the uncontrolled state, keeping the cached hue.
  HeroColorValue _resolve(HeroColorPickerScope? scope) {
    final Color? controlled = widget.value;
    final HeroColorValue resolved;
    if (controlled != null) {
      resolved = heroResolveColorValue(
        controlled,
        _space(_value),
        previous: _value,
      );
    } else if (scope != null) {
      resolved = scope.value.toSpace(_space(scope.value));
    } else {
      final HeroColorValue? current = _value;
      resolved = current != null
          ? current.toSpace(_space(current))
          : HeroColorValue.fromColor(
              widget.defaultValue ?? const Color(0xFFFFFFFF),
              space: _space(null),
            );
    }
    _value = resolved;
    return resolved;
  }

  void _commit(HeroColorValue next, {bool end = false}) {
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    final HeroColorValue current = _value ?? next;
    if (next != current) {
      setState(() => _value = next);
      if (widget.value == null) scope?.onChanged(next);
      widget.onChanged?.call(next.toColor());
    }
    if (end) widget.onChangeEnd?.call(next.toColor());
  }

  void _setChannel(double value, {bool end = false}) {
    final HeroColorValue current = _value!;
    final HeroChannelRange range = widget.channel.range;
    _commit(
      current.withChannelValue(widget.channel, range.snap(value)),
      end: end,
    );
  }

  void _setFraction(double fraction, {bool end = false}) =>
      _setChannel(widget.channel.range.lerp(fraction), end: end);

  void _dragStart(double fraction) {
    if (widget.isDisabled) return;
    if (_focusNode.canRequestFocus) _focusNode.requestFocus();
    setState(() => _dragging = true);
    _setFraction(fraction);
  }

  void _dragUpdate(double fraction) {
    if (widget.isDisabled || !_dragging) return;
    _setFraction(fraction);
  }

  void _dragEnd() {
    if (!_dragging) return;
    setState(() => _dragging = false);
    final HeroColorValue? value = _value;
    if (value != null) widget.onChangeEnd?.call(value.toColor());
  }

  void _step(double delta) {
    final HeroColorValue value = _value!;
    _setChannel(value.channelValue(widget.channel) + delta, end: true);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (widget.isDisabled ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final HeroChannelRange range = widget.channel.range;
    final bool shift = HardwareKeyboard.instance.isShiftPressed;
    final double step = shift ? range.pageSize : range.step;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _step(step);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _step(-step);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _step(rtl ? -step : step);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _step(rtl ? step : -step);
    } else if (key == LogicalKeyboardKey.pageUp) {
      _step(range.pageSize);
    } else if (key == LogicalKeyboardKey.pageDown) {
      _step(-range.pageSize);
    } else if (key == LogicalKeyboardKey.home) {
      _setChannel(range.min, end: true);
    } else if (key == LogicalKeyboardKey.end) {
      _setChannel(range.max, end: true);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    final HeroColorValue value = _resolve(scope);
    _focusNode.canRequestFocus = !widget.isDisabled;
    final HeroColorSliderState state = HeroColorSliderState(
      value: value,
      channel: widget.channel,
      orientation: widget.orientation,
      isDisabled: widget.isDisabled,
      isDragging: _dragging,
      isFocused: _focused,
      isFocusVisible: _focused && _highlight,
    );

    final bool horizontal = widget.orientation == Axis.horizontal;
    Widget content;
    final HeroColorSliderWidgetBuilder? builder = widget.builder;
    if (builder != null) {
      content = Builder(
        builder: (BuildContext context) => builder(context, state),
      );
    } else {
      final List<Widget> parts =
          widget.children ??
          <Widget>[
            if (widget.label != null) HeroLabel.text(widget.label!),
            if (widget.showOutput ?? widget.label != null)
              const HeroColorSliderOutput(),
            const HeroColorSliderTrack(),
          ];
      content = _HeroColorSliderLayout(
        orientation: widget.orientation,
        parts: parts,
      );
    }

    String? labelText = widget.label;
    for (final Widget part in widget.children ?? const <Widget>[]) {
      if (part is HeroLabel && part.data != null) labelText ??= part.data;
    }

    content = HeroFieldScope(
      focusNode: _focusNode,
      semanticLabel: widget.semanticLabel ?? labelText ?? widget.channel.label,
      child: content,
    );

    return _HeroColorSliderScope(
      state: state,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel ?? labelText ?? widget.channel.label,
      onFocusChanged: _handleFocusChanged,
      onKey: _handleKey,
      onDragStart: _dragStart,
      onDragUpdate: _dragUpdate,
      onDragEnd: _dragEnd,
      onStep: _step,
      child: HeroDisabledOpacity(
        disabled: widget.isDisabled,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double fallback = theme.spacing(48);
            if (horizontal) {
              return SizedBox(
                width: constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : fallback,
                child: content,
              );
            }
            return SizedBox(
              height: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : fallback,
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _HeroColorSliderScope extends InheritedWidget {
  const _HeroColorSliderScope({
    required this.state,
    required this.focusNode,
    required this.autofocus,
    required this.semanticLabel,
    required this.onFocusChanged,
    required this.onKey,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onStep,
    required super.child,
  });

  final HeroColorSliderState state;
  final FocusNode focusNode;
  final bool autofocus;
  final String semanticLabel;
  final ValueChanged<bool> onFocusChanged;
  final FocusOnKeyEventCallback onKey;
  final ValueChanged<double> onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final ValueChanged<double> onStep;

  static _HeroColorSliderScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroColorSliderScope>();

  @override
  bool updateShouldNotify(_HeroColorSliderScope oldWidget) =>
      state != oldWidget.state ||
      focusNode != oldWidget.focusNode ||
      autofocus != oldWidget.autofocus ||
      semanticLabel != oldWidget.semanticLabel;
}

// HeroUI's grid: `label output / track track` (horizontal) or
// `output / track / label` (vertical), collapsing absent parts.
class _HeroColorSliderLayout extends StatelessWidget {
  const _HeroColorSliderLayout({
    required this.orientation,
    required this.parts,
  });

  final Axis orientation;
  final List<Widget> parts;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    Widget? label;
    Widget? output;
    final List<Widget> track = <Widget>[];
    for (final Widget part in parts) {
      if (part is HeroLabel && label == null) {
        label = part;
      } else if (part is HeroColorSliderOutput && output == null) {
        output = part;
      } else {
        track.add(part);
      }
    }
    final Widget trackArea = track.length == 1
        ? track.single
        : Column(mainAxisSize: MainAxisSize.min, children: track);

    if (orientation == Axis.horizontal) {
      final bool header = label != null || output != null;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: header ? theme.spacing(1) : 0,
        children: <Widget>[
          if (header)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: label ?? const SizedBox.shrink(),
                  ),
                ),
                ?output,
              ],
            ),
          trackArea,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: label != null || output != null ? theme.spacing(2) : 0,
      children: <Widget>[
        ?output,
        Expanded(child: trackArea),
        ?label,
      ],
    );
  }
}

/// The formatted value of a [HeroColorSlider] (`ColorSlider.Output`):
/// `text-sm font-medium` with tabular figures, such as "200°", "50%" or
/// "255".
class HeroColorSliderOutput extends StatelessWidget {
  /// Creates the output part.
  const HeroColorSliderOutput({super.key, this.builder, this.style});

  /// Builds the output from the slider state; defaults to the formatted
  /// channel value.
  final HeroColorSliderWidgetBuilder? builder;

  /// Style merged over the output style (`text-muted` in the picker demos).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final _HeroColorSliderScope? scope = _HeroColorSliderScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography
        .style(HeroFontSize.sm, weight: HeroTypography.medium)
        .copyWith(
          color: theme.colors.foreground,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        )
        .merge(style);
    return ExcludeSemantics(
      child: DefaultTextStyle.merge(
        style: textStyle,
        textAlign: scope.state.orientation == Axis.vertical
            ? TextAlign.center
            : null,
        child:
            builder?.call(context, scope.state) ?? Text(scope.state.valueLabel),
      ),
    );
  }
}

/// The track of a [HeroColorSlider] (`ColorSlider.Track`): the channel
/// gradient over the transparency checkerboard, rounded end caps that
/// continue the minimum and maximum colors, and the [thumb] at the value.
///
/// Horizontal tracks are 20 tall and fill the slider width (the gradient
/// runs between two 10 px caps, reversed in right-to-left layouts);
/// vertical tracks are 20 wide with the minimum at the bottom. Tap the
/// track to jump to a value and drag to adjust it.
class HeroColorSliderTrack extends StatefulWidget {
  /// Creates the track part.
  const HeroColorSliderTrack({
    super.key,
    this.thumb,
    this.thickness,
    this.capRadius,
    this.borderColor,
  });

  /// The thumb; defaults to [HeroColorSliderThumb].
  final Widget? thumb;

  /// The height (horizontal) or width (vertical) of the track (`h-5`).
  final double? thickness;

  /// The radius of the outer corners of the end caps (`rounded-2xl`).
  final double? capRadius;

  /// The color of the 1 px inset border (`rgba(0, 0, 0, 0.1)`).
  final Color? borderColor;

  @override
  State<HeroColorSliderTrack> createState() => _HeroColorSliderTrackState();
}

class _HeroColorSliderTrackState extends State<HeroColorSliderTrack> {
  // Distance from the pointer to the thumb centre when a drag starts on the
  // thumb, so grabbing the thumb does not make it jump.
  double _grab = 0;

  @override
  Widget build(BuildContext context) {
    final _HeroColorSliderScope? scope = _HeroColorSliderScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColorSliderState state = scope.state;
    final bool horizontal = state.orientation == Axis.horizontal;
    final TextDirection direction = Directionality.of(context);
    final double thickness = widget.thickness ?? theme.spacing(5);
    final double thumbExtent = theme.spacing(4);
    final double cap = theme.spacing(2.5);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double length = horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final double travel = math.max(0, length - cap * 2);

        // The position of the pointer along the track, from 0 (minimum) to 1.
        double fractionAt(Offset local) {
          if (travel <= 0) return 0;
          if (horizontal) {
            final double f = ((local.dx + _grab - cap) / travel).clamp(
              0.0,
              1.0,
            );
            return direction == TextDirection.rtl ? 1 - f : f;
          }
          return 1 - ((local.dy + _grab - cap) / travel).clamp(0.0, 1.0);
        }

        double along = state.fraction;
        if (horizontal && direction == TextDirection.rtl) along = 1 - along;
        final Offset center = horizontal
            ? Offset(cap + travel * along, thickness / 2)
            : Offset(thickness / 2, cap + travel * (1 - along));

        final Widget painted = CustomPaint(
          painter: _HeroColorSliderTrackPainter(
            state: state,
            shape: theme.shape(
              BorderRadius.circular(
                math.min(
                  widget.capRadius ?? theme.radii.xl2,
                  math.min(cap, thickness / 2),
                ),
              ),
            ),
            cap: cap,
            tileSize: theme.spacing(4),
            borderColor: widget.borderColor ?? heroColorInsetRing(theme.colors),
            borderWidth: theme.spacing(0.25),
            textDirection: direction,
          ),
          child: CustomSingleChildLayout(
            delegate: _ThumbLayoutDelegate(center),
            child: widget.thumb ?? const HeroColorSliderThumb(),
          ),
        );

        final Widget track = SizedBox(
          width: horizontal ? length : thickness,
          height: horizontal ? thickness : length,
          child: painted,
        );
        if (state.isDisabled) {
          return Center(widthFactor: 1, heightFactor: 1, child: track);
        }

        void start(Offset local) {
          final double offset = horizontal
              ? center.dx - local.dx
              : center.dy - local.dy;
          final bool onThumb =
              offset.abs() <= thumbExtent / 2 &&
              (horizontal ? center.dy - local.dy : center.dx - local.dx)
                      .abs() <=
                  thumbExtent / 2;
          _grab = onThumb ? offset : 0;
          scope.onDragStart(fractionAt(local));
        }

        void update(Offset local) => scope.onDragUpdate(fractionAt(local));
        return Center(
          widthFactor: 1,
          heightFactor: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            dragStartBehavior: DragStartBehavior.down,
            onTapDown: (TapDownDetails d) => start(d.localPosition),
            onTapUp: (_) => scope.onDragEnd(),
            onTapCancel: () {},
            onHorizontalDragStart: horizontal
                ? (DragStartDetails d) => start(d.localPosition)
                : null,
            onHorizontalDragUpdate: horizontal
                ? (DragUpdateDetails d) => update(d.localPosition)
                : null,
            onHorizontalDragEnd: horizontal ? (_) => scope.onDragEnd() : null,
            onHorizontalDragCancel: horizontal ? scope.onDragEnd : null,
            onVerticalDragStart: horizontal
                ? null
                : (DragStartDetails d) => start(d.localPosition),
            onVerticalDragUpdate: horizontal
                ? null
                : (DragUpdateDetails d) => update(d.localPosition),
            onVerticalDragEnd: horizontal ? null : (_) => scope.onDragEnd(),
            onVerticalDragCancel: horizontal ? null : scope.onDragEnd,
            child: track,
          ),
        );
      },
    );
  }
}

class _ThumbLayoutDelegate extends SingleChildLayoutDelegate {
  const _ThumbLayoutDelegate(this.center);

  final Offset center;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      center - Offset(childSize.width / 2, childSize.height / 2);

  @override
  bool shouldRelayout(_ThumbLayoutDelegate oldDelegate) =>
      oldDelegate.center != center;
}

class _HeroColorSliderTrackPainter extends CustomPainter {
  const _HeroColorSliderTrackPainter({
    required this.state,
    required this.shape,
    required this.cap,
    required this.tileSize,
    required this.borderColor,
    required this.borderWidth,
    required this.textDirection,
  });

  final HeroColorSliderState state;
  final ShapeBorder shape;
  final double cap;
  final double tileSize;
  final Color borderColor;
  final double borderWidth;
  final TextDirection textDirection;

  // The gradient stops of the channel, from minimum to maximum (React
  // Aria's `generateBackground`).
  List<Color> _stops() {
    final HeroColorValue display = state.displayColor;
    final HeroColorChannel channel = state.channel;
    final HeroChannelRange range = channel.range;
    Color at(double v) => display.withChannelValue(channel, v).toColor();
    return switch (channel) {
      HeroColorChannel.hue => <Color>[
        for (final double hue in <double>[0, 60, 120, 180, 240, 300, 360])
          at(hue),
      ],
      HeroColorChannel.lightness => <Color>[
        at(range.min),
        at((range.max - range.min) / 2),
        at(range.max),
      ],
      _ => <Color>[at(range.min), at(range.max)],
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final bool horizontal = state.orientation == Axis.horizontal;
    final bool reversed = horizontal && textDirection == TextDirection.rtl;
    final List<Color> stops = _stops();
    final Color startColor = stops.first;
    final Color endColor = stops.last;
    final bool translucent = stops.any((Color c) => c.a < 1);

    final Rect startCap;
    final Rect endCap;
    final Rect track;
    if (horizontal) {
      final Rect left = Rect.fromLTWH(0, 0, cap, size.height);
      final Rect right = Rect.fromLTWH(size.width - cap, 0, cap, size.height);
      startCap = reversed ? right : left;
      endCap = reversed ? left : right;
      track = Rect.fromLTRB(cap, 0, size.width - cap, size.height);
    } else {
      startCap = Rect.fromLTWH(0, size.height - cap, size.width, cap);
      endCap = Rect.fromLTWH(0, 0, size.width, cap);
      track = Rect.fromLTRB(0, cap, size.width, size.height - cap);
    }

    final Path outline = shape.getOuterPath(rect, textDirection: textDirection);
    canvas
      ..save()
      ..clipPath(outline);

    // Start cap: the minimum color over the checkerboard.
    if (startColor.a < 1) {
      canvas
        ..save()
        ..clipRect(startCap);
      HeroCheckerboard.paint(canvas, startCap, tileSize: tileSize);
      canvas.restore();
    }
    canvas.drawRect(startCap, Paint()..color = startColor);

    // The gradient between the caps, over the checkerboard.
    if (!track.isEmpty) {
      if (translucent) {
        canvas
          ..save()
          ..clipRect(track);
        HeroCheckerboard.paint(canvas, track, tileSize: tileSize);
        canvas.restore();
      }
      final Alignment begin = horizontal
          ? (reversed ? Alignment.centerRight : Alignment.centerLeft)
          : Alignment.bottomCenter;
      final Alignment end = horizontal
          ? (reversed ? Alignment.centerLeft : Alignment.centerRight)
          : Alignment.topCenter;
      canvas.drawRect(
        track,
        Paint()
          ..shader = LinearGradient(
            begin: begin,
            end: end,
            colors: stops,
          ).createShader(track),
      );
    }

    // End cap: the maximum color.
    canvas
      ..drawRect(endCap, Paint()..color = endColor)
      ..restore();

    if (borderColor.a > 0 && borderWidth > 0) {
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          outline,
          heroInflatedShapePath(shape, rect, -borderWidth, textDirection),
        ),
        Paint()..color = borderColor,
      );
    }
  }

  @override
  bool shouldRepaint(_HeroColorSliderTrackPainter oldDelegate) =>
      oldDelegate.state.value != state.value ||
      oldDelegate.state.channel != state.channel ||
      oldDelegate.state.orientation != state.orientation ||
      oldDelegate.shape != shape ||
      oldDelegate.cap != cap ||
      oldDelegate.tileSize != tileSize ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.textDirection != textDirection;
}

/// The thumb of a [HeroColorSlider] (`ColorSlider.Thumb`).
///
/// A 16 px circle with a 3 px white border and the overlay shadow, filled
/// with the slider's display color (the default gray while disabled). It
/// holds the keyboard focus of the slider, shows HeroUI's focus ring and is
/// the adjustable node for assistive technology.
class HeroColorSliderThumb extends StatelessWidget {
  /// Creates the thumb part.
  const HeroColorSliderThumb({
    super.key,
    this.size,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.shadows,
  });

  /// The side length (`size-4`).
  final double? size;

  /// The corner radius (`rounded-2xl`).
  final BorderRadiusGeometry? borderRadius;

  /// The border width (`border-3`).
  final double? borderWidth;

  /// The border color (`border-white`).
  final Color? borderColor;

  /// The shadows (`shadow-overlay`).
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final _HeroColorSliderScope? scope = _HeroColorSliderScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColorSliderState state = scope.state;
    final HeroChannelRange range = state.channel.range;
    final OutlinedBorder shape = theme.shape(
      borderRadius ?? BorderRadius.circular(theme.radii.xl2),
    );
    final double extent = size ?? theme.spacing(4);
    final Color fill = state.isDisabled
        ? theme.colors.defaultColor
        : state.displayColor.toColor();

    String textFor(double channelValue) {
      final HeroColorValue value = state.value.withChannelValue(
        state.channel,
        channelValue,
      );
      final HeroColorSliderState next = HeroColorSliderState(
        value: value,
        channel: state.channel,
        orientation: state.orientation,
      );
      return '${next.valueLabel}, ${heroColorName(next.displayColor.toColor())}';
    }

    final double current = state.channelValue;
    Widget thumb = SizedBox.square(
      dimension: extent,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: fill,
          shape: shape.copyWith(
            side: BorderSide(
              color: borderColor ?? theme.colors.white,
              width: borderWidth ?? theme.spacing(0.75),
            ),
          ),
          shadows: shadows ?? theme.shadows.overlay.boxShadows,
        ),
      ),
    );
    thumb = HeroFocusRing(
      visible: state.isFocusVisible,
      shape: shape,
      child: thumb,
    );
    thumb = MouseRegion(
      cursor: state.isDisabled
          ? SystemMouseCursors.basic
          : state.isDragging
          ? SystemMouseCursors.grabbing
          : SystemMouseCursors.grab,
      child: thumb,
    );
    return Semantics(
      slider: true,
      label: scope.semanticLabel,
      value: textFor(current),
      increasedValue: textFor(range.clamp(current + range.step)),
      decreasedValue: textFor(range.clamp(current - range.step)),
      enabled: !state.isDisabled,
      focusable: !state.isDisabled,
      focused: state.isFocused,
      onIncrease: state.isDisabled ? null : () => scope.onStep(range.step),
      onDecrease: state.isDisabled ? null : () => scope.onStep(-range.step),
      child: Focus(
        focusNode: scope.focusNode,
        autofocus: scope.autofocus,
        includeSemantics: false,
        onFocusChange: scope.onFocusChanged,
        onKeyEvent: scope.onKey,
        child: thumb,
      ),
    );
  }
}
