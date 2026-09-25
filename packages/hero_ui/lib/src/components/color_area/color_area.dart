/// HeroUI's ColorArea: a two-dimensional color picker over a gradient.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../color/color.dart';

export '../color/color.dart';

/// The render props of a [HeroColorArea].
@immutable
class HeroColorAreaState {
  /// Creates an area state.
  const HeroColorAreaState({
    required this.value,
    required this.xChannel,
    required this.yChannel,
    this.isDisabled = false,
    this.isDragging = false,
    this.isFocused = false,
    this.isFocusVisible = false,
  });

  /// The current value, in the area's color space.
  final HeroColorValue value;

  /// The channel on the horizontal axis.
  final HeroColorChannel xChannel;

  /// The channel on the vertical axis.
  final HeroColorChannel yChannel;

  /// Whether the area is disabled.
  final bool isDisabled;

  /// Whether the thumb is being dragged.
  final bool isDragging;

  /// Whether the thumb has focus.
  final bool isFocused;

  /// Whether the thumb has keyboard focus (focus ring shown).
  final bool isFocusVisible;

  /// The current value as a Flutter color.
  Color get color => value.toColor();

  /// The color space of the area.
  HeroColorSpace get colorSpace => value.space;

  /// The channel fixed by the area (the third channel of the space).
  HeroColorChannel get zChannel => colorSpace.channels.firstWhere(
    (HeroColorChannel c) => c != xChannel && c != yChannel,
  );

  /// The value of the horizontal channel.
  double get xValue => value.channelValue(xChannel);

  /// The value of the vertical channel.
  double get yValue => value.channelValue(yChannel);

  /// The thumb position, from (0, 0) (minimum x, minimum y) to (1, 1).
  Offset get fraction =>
      Offset(xChannel.range.fraction(xValue), yChannel.range.fraction(yValue));

  @override
  bool operator ==(Object other) =>
      other is HeroColorAreaState &&
      other.value == value &&
      other.xChannel == xChannel &&
      other.yChannel == yChannel &&
      other.isDisabled == isDisabled &&
      other.isDragging == isDragging &&
      other.isFocused == isFocused &&
      other.isFocusVisible == isFocusVisible;

  @override
  int get hashCode => Object.hash(
    value,
    xChannel,
    yChannel,
    isDisabled,
    isDragging,
    isFocused,
    isFocusVisible,
  );
}

/// Builds content from the state of a [HeroColorArea].
typedef HeroColorAreaWidgetBuilder =
    Widget Function(BuildContext context, HeroColorAreaState state);

/// A two-dimensional color picker (HeroUI `ColorArea`): drag the thumb over
/// a gradient to set two channels of a color at once.
///
/// ```dart
/// HeroColorArea(
///   defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
///   onChanged: (Color color) => debugPrint('$color'),
/// )
/// ```
///
/// * [colorSpace], [xChannel], [yChannel]: the axes. Without any of them
///   the area edits saturation (x) and brightness (y) in hsb. A missing
///   axis takes the first remaining channel of the space, and a channel
///   that needs another space switches the space (red/green/blue → rgb,
///   lightness → hsl, brightness → hsb).
/// * [showDots]: a grid of faint dots over the gradient.
/// * [isDisabled]: 50% opacity, no input, not focusable.
///
/// The area is square, fills the available width up to [maxSize] (224,
/// `max-w-56`) unless [size] is set, and has `rounded-2xl` corners with a
/// 1 px inset ring. The [thumb] (a [HeroColorAreaThumb] by default) sits at
/// the value, x from the start side, y from the bottom.
///
/// The value is a [Color]: controlled with [value] + [onChanged],
/// uncontrolled with [defaultValue] (white when null), or, without either
/// inside a `HeroColorPicker`, the picker's color. The area keeps its own
/// hue and saturation, so black or gray keep the hue the user chose.
///
/// Pointer: press anywhere to move the thumb there and drag; [onChangeEnd]
/// fires on release. Keyboard (focus on the thumb): left/right change x by
/// one step (mirrored in right-to-left layouts), up/down change y, Shift
/// makes it one page, Page Up / Page Down change y by a page and Home / End
/// change x by a page.
class HeroColorArea extends StatefulWidget {
  /// Creates a color area.
  const HeroColorArea({
    super.key,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onChangeEnd,
    this.colorSpace,
    this.xChannel,
    this.yChannel,
    this.isDisabled = false,
    this.showDots = false,
    this.size,
    this.maxSize,
    this.borderRadius,
    this.thumb,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// The current color (controlled).
  final Color? value;

  /// The initial color (uncontrolled); white when null.
  final Color? defaultValue;

  /// Called with the new color while the user moves the thumb.
  final ValueChanged<Color>? onChanged;

  /// Called with the final color when the user stops moving the thumb.
  final ValueChanged<Color>? onChangeEnd;

  /// The color space of the axes.
  final HeroColorSpace? colorSpace;

  /// The channel on the horizontal axis.
  final HeroColorChannel? xChannel;

  /// The channel on the vertical axis.
  final HeroColorChannel? yChannel;

  /// Whether the area is disabled.
  final bool isDisabled;

  /// Whether to show the dot grid.
  final bool showDots;

  /// A fixed side length; by default the area fills the available width up
  /// to [maxSize].
  final double? size;

  /// The largest side length when [size] is null; defaults to 224
  /// (`max-w-56`). `double.infinity` fills the width (`max-w-full`).
  final double? maxSize;

  /// The corner radius (`rounded-2xl`).
  final BorderRadiusGeometry? borderRadius;

  /// The thumb; defaults to [HeroColorAreaThumb].
  final Widget? thumb;

  /// The focus node of the thumb.
  final FocusNode? focusNode;

  /// Whether to focus the thumb when first built.
  final bool autofocus;

  /// Accessibility label of the area; defaults to "Color picker".
  final String? semanticLabel;

  /// Resolves the space and axes of an area the way [HeroColorArea] does.
  static (HeroColorSpace, HeroColorChannel, HeroColorChannel) resolveAxes({
    HeroColorSpace? colorSpace,
    HeroColorChannel? xChannel,
    HeroColorChannel? yChannel,
  }) {
    HeroColorChannel? x = xChannel == HeroColorChannel.alpha ? null : xChannel;
    HeroColorChannel? y = yChannel == HeroColorChannel.alpha ? null : yChannel;
    if (colorSpace == null && x == null && y == null) {
      return (
        HeroColorSpace.hsb,
        HeroColorChannel.saturation,
        HeroColorChannel.brightness,
      );
    }
    HeroColorSpace space =
        x?.requiredSpace ??
        y?.requiredSpace ??
        colorSpace ??
        HeroColorSpace.hsb;
    // Hue and saturation do not exist in rgb.
    if ((x != null && !x.isIn(space)) || (y != null && !y.isIn(space))) {
      space = HeroColorSpace.hsl;
    }
    if (x != null && !x.isIn(space)) x = null;
    if (y != null && !y.isIn(space) || y == x) y = null;
    final List<HeroColorChannel> channels = space.channels;
    x ??= channels.firstWhere((HeroColorChannel c) => c != y);
    y ??= channels.firstWhere((HeroColorChannel c) => c != x);
    return (space, x, y);
  }

  @override
  State<HeroColorArea> createState() => _HeroColorAreaState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('value', value, defaultValue: null))
      ..add(
        EnumProperty<HeroColorSpace>(
          'colorSpace',
          colorSpace,
          defaultValue: null,
        ),
      )
      ..add(
        EnumProperty<HeroColorChannel>(
          'xChannel',
          xChannel,
          defaultValue: null,
        ),
      )
      ..add(
        EnumProperty<HeroColorChannel>(
          'yChannel',
          yChannel,
          defaultValue: null,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('showDots', value: showDots, ifTrue: 'dots'));
  }
}

class _HeroColorAreaState extends State<HeroColorArea> {
  FocusNode? _ownFocusNode;
  HeroColorValue? _value;
  bool _dragging = false;
  bool _focused = false;
  bool _highlight =
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
  // Offset from the pointer to the thumb centre when a drag starts on the
  // thumb, so grabbing it does not make it jump.
  Offset _grab = Offset.zero;
  final GlobalKey _boxKey = GlobalKey();

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroColorArea'));

  late (HeroColorSpace, HeroColorChannel, HeroColorChannel) _axes =
      _resolveAxes();

  (HeroColorSpace, HeroColorChannel, HeroColorChannel) _resolveAxes() =>
      HeroColorArea.resolveAxes(
        colorSpace: widget.colorSpace,
        xChannel: widget.xChannel,
        yChannel: widget.yChannel,
      );

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_handleHighlightMode);
  }

  @override
  void didUpdateWidget(HeroColorArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.colorSpace != widget.colorSpace ||
        oldWidget.xChannel != widget.xChannel ||
        oldWidget.yChannel != widget.yChannel) {
      _axes = _resolveAxes();
    }
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

  HeroColorValue _resolve(HeroColorPickerScope? scope) {
    final HeroColorSpace space = _axes.$1;
    final Color? controlled = widget.value;
    final HeroColorValue resolved;
    if (controlled != null) {
      resolved = heroResolveColorValue(controlled, space, previous: _value);
    } else if (scope != null) {
      resolved = scope.value.toSpace(space);
    } else {
      resolved =
          _value?.toSpace(space) ??
          HeroColorValue.fromColor(
            widget.defaultValue ?? const Color(0xFFFFFFFF),
            space: space,
          );
    }
    _value = resolved;
    return resolved;
  }

  void _commit(HeroColorValue next, {bool end = false}) {
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    if (next != _value) {
      setState(() => _value = next);
      if (widget.value == null) scope?.onChanged(next);
      widget.onChanged?.call(next.toColor());
    }
    if (end) widget.onChangeEnd?.call(next.toColor());
  }

  void _setChannels({double? x, double? y, bool end = false}) {
    HeroColorValue next = _value!;
    final (
      HeroColorSpace _,
      HeroColorChannel xChannel,
      HeroColorChannel yChannel,
    ) = _axes;
    if (x != null) {
      next = next.withChannelValue(xChannel, xChannel.range.snap(x));
    }
    if (y != null) {
      next = next.withChannelValue(yChannel, yChannel.range.snap(y));
    }
    _commit(next, end: end);
  }

  // Converts a position in the area into channel values.
  void _setPosition(Offset local, Size size, {bool end = false}) {
    final (
      HeroColorSpace _,
      HeroColorChannel xChannel,
      HeroColorChannel yChannel,
    ) = _axes;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final Offset point = local + _grab;
    double fx = size.width <= 0 ? 0 : (point.dx / size.width).clamp(0.0, 1.0);
    if (rtl) fx = 1 - fx;
    final double fy = size.height <= 0
        ? 0
        : 1 - (point.dy / size.height).clamp(0.0, 1.0);
    _setChannels(
      x: xChannel.range.lerp(fx),
      y: yChannel.range.lerp(fy),
      end: end,
    );
  }

  Offset _thumbCenter(Size size) {
    final HeroColorAreaState state = _state();
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final Offset f = state.fraction;
    return Offset(
      (rtl ? 1 - f.dx : f.dx) * size.width,
      (1 - f.dy) * size.height,
    );
  }

  HeroColorAreaState _state() => HeroColorAreaState(
    value: _value!,
    xChannel: _axes.$2,
    yChannel: _axes.$3,
    isDisabled: widget.isDisabled,
    isDragging: _dragging,
    isFocused: _focused,
    isFocusVisible: _focused && _highlight,
  );

  // The pointer that is moving the thumb, if any.
  int? _pointer;

  RenderBox? get _box {
    final RenderObject? object = _boxKey.currentContext?.findRenderObject();
    return object is RenderBox && object.hasSize ? object : null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    final RenderBox? box = _box;
    if (widget.isDisabled || _pointer != null || box == null) return;
    _pointer = event.pointer;
    final Offset local = box.globalToLocal(event.position);
    final double extent = HeroTheme.of(context).spacing(4);
    final Offset delta = _thumbCenter(box.size) - local;
    _grab = delta.dx.abs() <= extent / 2 && delta.dy.abs() <= extent / 2
        ? delta
        : Offset.zero;
    if (_focusNode.canRequestFocus) _focusNode.requestFocus();
    setState(() => _dragging = true);
    _setPosition(local, box.size);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final RenderBox? box = _box;
    if (event.pointer != _pointer || box == null) return;
    _setPosition(box.globalToLocal(event.position), box.size);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _pointer = null;
    if (!mounted) return;
    setState(() => _dragging = false);
    final HeroColorValue? value = _value;
    if (value != null) widget.onChangeEnd?.call(value.toColor());
  }

  void _step({double dx = 0, double dy = 0}) {
    final HeroColorAreaState state = _state();
    _setChannels(
      x: dx == 0 ? null : state.xValue + dx,
      y: dy == 0 ? null : state.yValue + dy,
      end: true,
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (widget.isDisabled ||
        (event is! KeyDownEvent && event is! KeyRepeatEvent)) {
      return KeyEventResult.ignored;
    }
    final HeroChannelRange xRange = _axes.$2.range;
    final HeroChannelRange yRange = _axes.$3.range;
    final bool shift = HardwareKeyboard.instance.isShiftPressed;
    final double xStep = shift ? xRange.pageSize : xRange.step;
    final double yStep = shift ? yRange.pageSize : yRange.step;
    final double dir = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight) {
      _step(dx: xStep * dir);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _step(dx: -xStep * dir);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _step(dy: yStep);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _step(dy: -yStep);
    } else if (key == LogicalKeyboardKey.pageUp) {
      _step(dy: yRange.pageSize);
    } else if (key == LogicalKeyboardKey.pageDown) {
      _step(dy: -yRange.pageSize);
    } else if (key == LogicalKeyboardKey.home) {
      _step(dx: -xRange.pageSize * dir);
    } else if (key == LogicalKeyboardKey.end) {
      _step(dx: xRange.pageSize * dir);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    _resolve(scope);
    _focusNode.canRequestFocus = !widget.isDisabled;
    final HeroColorAreaState state = _state();
    final TextDirection direction = Directionality.of(context);
    final OutlinedBorder shape = theme.shape(
      widget.borderRadius ?? BorderRadius.circular(theme.radii.xl2),
    );

    return _HeroColorAreaScope(
      state: state,
      child: HeroDisabledOpacity(
        disabled: widget.isDisabled,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double maxSize = widget.maxSize ?? theme.spacing(56);
            final double available = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : maxSize.isFinite
                ? maxSize
                : theme.spacing(56);
            final double side = widget.size ?? math.min(available, maxSize);
            final Size size = Size.square(side);

            final Widget thumb = _AreaThumbSemantics(
              state: state,
              semanticLabel: widget.semanticLabel ?? 'Color picker',
              onStep: _step,
              child: Focus(
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                includeSemantics: false,
                onFocusChange: _handleFocusChanged,
                onKeyEvent: _handleKey,
                child: widget.thumb ?? const HeroColorAreaThumb(),
              ),
            );

            // The area claims every pointer that lands on it (React Aria
            // sets `touch-action: none`), so dragging inside it never
            // scrolls the page, and follows the pointer from the press.
            return RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: <Type, GestureRecognizerFactory>{
                EagerGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      EagerGestureRecognizer
                    >(
                      EagerGestureRecognizer.new,
                      (EagerGestureRecognizer recognizer) {},
                    ),
              },
              child: Listener(
                onPointerDown: _handlePointerDown,
                onPointerMove: _handlePointerMove,
                onPointerUp: _handlePointerEnd,
                onPointerCancel: _handlePointerEnd,
                child: SizedBox.fromSize(
                  key: _boxKey,
                  size: size,
                  child: CustomPaint(
                    painter: _HeroColorAreaPainter(
                      state: state,
                      shape: shape,
                      showDots: widget.showDots,
                      dotSpacing: theme.spacing(2),
                      dotRadius: theme.spacing(0.25),
                      ringWidth: theme.spacing(0.25),
                      textDirection: direction,
                      white: theme.colors.white,
                      black: theme.colors.black,
                    ),
                    child: CustomSingleChildLayout(
                      delegate: _CenterLayoutDelegate(_thumbCenter(size)),
                      child: thumb,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CenterLayoutDelegate extends SingleChildLayoutDelegate {
  const _CenterLayoutDelegate(this.center);

  final Offset center;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      const BoxConstraints();

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      center - Offset(childSize.width / 2, childSize.height / 2);

  @override
  bool shouldRelayout(_CenterLayoutDelegate oldDelegate) =>
      oldDelegate.center != center;
}

class _HeroColorAreaScope extends InheritedWidget {
  const _HeroColorAreaScope({required this.state, required super.child});

  final HeroColorAreaState state;

  static _HeroColorAreaScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroColorAreaScope>();

  @override
  bool updateShouldNotify(_HeroColorAreaScope oldWidget) =>
      state != oldWidget.state;
}

// The area is a group of two adjustable sliders (x and y) for assistive
// technology, like React Aria's pair of hidden range inputs.
class _AreaThumbSemantics extends StatelessWidget {
  const _AreaThumbSemantics({
    required this.state,
    required this.semanticLabel,
    required this.onStep,
    required this.child,
  });

  final HeroColorAreaState state;
  final String semanticLabel;
  final void Function({double dx, double dy}) onStep;
  final Widget child;

  Widget _axis(HeroColorChannel channel, {required bool horizontal}) {
    final HeroChannelRange range = channel.range;
    final double current = state.value.channelValue(channel);
    String text(double v) =>
        state.value.withChannelValue(channel, v).formatChannelValue(channel);
    final bool enabled = !state.isDisabled;
    return Semantics(
      container: true,
      slider: true,
      label: channel.label,
      value: text(current),
      increasedValue: text(range.clamp(current + range.step)),
      decreasedValue: text(range.clamp(current - range.step)),
      enabled: enabled,
      onIncrease: enabled
          ? () => horizontal ? onStep(dx: range.step) : onStep(dy: range.step)
          : null,
      onDecrease: enabled
          ? () => horizontal ? onStep(dx: -range.step) : onStep(dy: -range.step)
          : null,
      child: const SizedBox.expand(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      value: heroColorName(state.value.toColor()),
      enabled: !state.isDisabled,
      focusable: !state.isDisabled,
      focused: state.isFocused,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ExcludeSemantics(child: child),
          Positioned.fill(child: _axis(state.xChannel, horizontal: true)),
          Positioned.fill(child: _axis(state.yChannel, horizontal: false)),
        ],
      ),
    );
  }
}

class _HeroColorAreaPainter extends CustomPainter {
  const _HeroColorAreaPainter({
    required this.state,
    required this.shape,
    required this.showDots,
    required this.dotSpacing,
    required this.dotRadius,
    required this.ringWidth,
    required this.textDirection,
    required this.white,
    required this.black,
  });

  final HeroColorAreaState state;
  final Color white;
  final Color black;
  final ShapeBorder shape;
  final bool showDots;
  final double dotSpacing;
  final double dotRadius;
  final double ringWidth;
  final TextDirection textDirection;

  static const List<double> _hues = <double>[0, 60, 120, 180, 240, 300, 360];

  // Paints a gradient along the x axis (min at the start side) or the y
  // axis (min at the bottom).
  void _axisGradient(
    Canvas canvas,
    Rect rect,
    List<Color> colors, {
    required bool horizontal,
    List<double>? stops,
    BlendMode blendMode = BlendMode.srcOver,
  }) {
    final bool rtl = textDirection == TextDirection.rtl;
    final Gradient gradient = LinearGradient(
      begin: horizontal
          ? (rtl ? Alignment.centerRight : Alignment.centerLeft)
          : Alignment.bottomCenter,
      end: horizontal
          ? (rtl ? Alignment.centerLeft : Alignment.centerRight)
          : Alignment.topCenter,
      colors: colors,
      stops: stops,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = gradient.createShader(rect)
        ..blendMode = blendMode,
    );
  }

  void _paintBackground(Canvas canvas, Rect rect) {
    final HeroColorValue value = state.value.withAlpha(1);
    final HeroColorChannel x = state.xChannel;
    final HeroColorChannel y = state.yChannel;
    final HeroColorSpace space = value.space;
    bool isX(HeroColorChannel c) => c == x;

    if (space == HeroColorSpace.rgb) {
      // A base with the fixed channel, plus each axis channel from 0 to 255
      // (additive, like React Aria's screen-blended layers).
      final HeroColorChannel z = state.zChannel;
      Color only(HeroColorChannel channel, double v) {
        const HeroColorValue zero = HeroColorValue.rgb(0, 0, 0);
        return zero.withChannelValue(channel, v).toColor();
      }

      canvas
        ..saveLayer(rect, Paint())
        ..drawRect(rect, Paint()..color = only(z, value.channelValue(z)));
      _axisGradient(
        canvas,
        rect,
        <Color>[only(x, 0), only(x, 255)],
        horizontal: true,
        blendMode: BlendMode.plus,
      );
      _axisGradient(
        canvas,
        rect,
        <Color>[only(y, 0), only(y, 255)],
        horizontal: false,
        blendMode: BlendMode.plus,
      );
      canvas.restore();
      return;
    }

    final double hue = value.channelValue(HeroColorChannel.hue);
    final double saturation = value.channelValue(HeroColorChannel.saturation);
    final HeroColorChannel third = space.channels[2];
    final double thirdValue = value.channelValue(third);
    Color hsb(double h, double s, double b) =>
        HeroColorValue.hsb(h, s, b).toColor();
    Color hsl(double h, double s, double l) =>
        HeroColorValue.hsl(h, s, l).toColor();

    // Lightness: black at 0, the color at 50%, white at 100%.
    void lightnessOverlay(bool horizontal) => _axisGradient(
      canvas,
      rect,
      <Color>[
        black,
        black.withValues(alpha: 0),
        white.withValues(alpha: 0),
        white,
      ],
      stops: const <double>[0, 0.5, 0.5, 1],
      horizontal: horizontal,
    );

    if (x != HeroColorChannel.hue && y != HeroColorChannel.hue) {
      // Saturation × brightness or saturation × lightness at a fixed hue.
      final bool satHorizontal = isX(HeroColorChannel.saturation);
      if (space == HeroColorSpace.hsb) {
        _axisGradient(canvas, rect, <Color>[
          white,
          hsb(hue, 100, 100),
        ], horizontal: satHorizontal);
        _axisGradient(canvas, rect, <Color>[
          black,
          black.withValues(alpha: 0),
        ], horizontal: !satHorizontal);
      } else {
        _axisGradient(canvas, rect, <Color>[
          hsl(hue, 0, 50),
          hsl(hue, 100, 50),
        ], horizontal: satHorizontal);
        lightnessOverlay(!satHorizontal);
      }
      return;
    }

    // One axis is the hue: a rainbow along it with the other channels fixed,
    // then the second axis fades it towards gray, black or white.
    final bool hueHorizontal = isX(HeroColorChannel.hue);
    final HeroColorChannel other = hueHorizontal ? y : x;
    final List<Color> rainbow;
    if (other == HeroColorChannel.saturation) {
      rainbow = <Color>[
        for (final double h in _hues)
          space == HeroColorSpace.hsb
              ? hsb(h, 100, thirdValue)
              : hsl(h, 100, thirdValue),
      ];
    } else if (space == HeroColorSpace.hsb) {
      rainbow = <Color>[for (final double h in _hues) hsb(h, saturation, 100)];
    } else {
      rainbow = <Color>[for (final double h in _hues) hsl(h, saturation, 50)];
    }
    _axisGradient(canvas, rect, rainbow, horizontal: hueHorizontal);
    if (other == HeroColorChannel.saturation) {
      final Color gray = space == HeroColorSpace.hsb
          ? hsb(0, 0, thirdValue)
          : hsl(0, 0, thirdValue);
      _axisGradient(canvas, rect, <Color>[
        gray,
        gray.withValues(alpha: 0),
      ], horizontal: !hueHorizontal);
    } else if (space == HeroColorSpace.hsb) {
      _axisGradient(canvas, rect, <Color>[
        black,
        black.withValues(alpha: 0),
      ], horizontal: !hueHorizontal);
    } else {
      lightnessOverlay(!hueHorizontal);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path outline = shape.getOuterPath(rect, textDirection: textDirection);
    canvas
      ..save()
      ..clipPath(outline);
    _paintBackground(canvas, rect);
    canvas.restore();

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        outline,
        heroInflatedShapePath(shape, rect, -ringWidth, textDirection),
      ),
      Paint()..color = black.withValues(alpha: black.a * 0.1),
    );

    if (showDots && dotSpacing > 0) {
      canvas
        ..save()
        ..clipPath(outline);
      final Paint dot = Paint()..color = white.withValues(alpha: 0.2);
      for (double y = dotSpacing / 2; y < size.height; y += dotSpacing) {
        for (double x = dotSpacing / 2; x < size.width; x += dotSpacing) {
          canvas.drawCircle(Offset(x, y), dotRadius, dot);
        }
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HeroColorAreaPainter oldDelegate) =>
      oldDelegate.state.value != state.value ||
      oldDelegate.state.xChannel != state.xChannel ||
      oldDelegate.state.yChannel != state.yChannel ||
      oldDelegate.shape != shape ||
      oldDelegate.showDots != showDots ||
      oldDelegate.dotSpacing != dotSpacing ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.ringWidth != ringWidth ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.white != white ||
      oldDelegate.black != black;
}

/// The thumb of a [HeroColorArea] (`ColorArea.Thumb`).
///
/// A 16 px circle filled with the current color (opaque), with a 3 px
/// white border, a 1 px `rgba(0,0,0,.1)` ring outside and inside the
/// border; it grows to 20 px while dragged (150 ms ease-out), shows HeroUI's
/// focus ring for keyboard focus and fades while disabled.
class HeroColorAreaThumb extends StatelessWidget {
  /// Creates the thumb part.
  const HeroColorAreaThumb({
    super.key,
    this.size,
    this.draggingSize,
    this.borderWidth,
    this.borderColor,
    this.borderRadius,
    this.builder,
  });

  /// The side length (`size-4`).
  final double? size;

  /// The side length while dragged (`size-5`).
  final double? draggingSize;

  /// The border width (3).
  final double? borderWidth;

  /// The border color (white).
  final Color? borderColor;

  /// The corner radius (`rounded-xl`).
  final BorderRadiusGeometry? borderRadius;

  /// Builds the thumb from the area state; replaces the default look.
  final HeroColorAreaWidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final _HeroColorAreaScope? scope = _HeroColorAreaScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColorAreaState state = scope.state;
    final HeroColorAreaWidgetBuilder? builder = this.builder;
    if (builder != null) return builder(context, state);

    final double extent = state.isDragging
        ? (draggingSize ?? size ?? theme.spacing(5))
        : (size ?? theme.spacing(4));
    final OutlinedBorder shape = theme.shape(
      borderRadius ?? BorderRadius.circular(theme.radii.xl),
    );
    final double border = borderWidth ?? theme.spacing(0.75);
    final double ring = theme.spacing(0.25);
    return MouseRegion(
      cursor: state.isDisabled
          ? SystemMouseCursors.basic
          : state.isDragging
          ? SystemMouseCursors.grabbing
          : SystemMouseCursors.grab,
      child: HeroFocusRing(
        visible: state.isFocusVisible,
        shape: shape,
        child: HeroDisabledOpacity(
          disabled: state.isDisabled,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: extent),
            duration: theme.motion.resolve(context, HeroMotion.normal),
            curve: HeroMotion.easeOut,
            builder: (BuildContext context, double side, Widget? _) =>
                SizedBox.square(
                  dimension: side,
                  child: CustomPaint(
                    painter: _AreaThumbPainter(
                      color: state.value.withAlpha(1).toColor(),
                      shape: shape,
                      borderWidth: border,
                      borderColor: borderColor ?? theme.colors.white,
                      ringColor: heroColorInsetRing(theme.colors),
                      ringWidth: ring,
                      textDirection: Directionality.maybeOf(context),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _AreaThumbPainter extends CustomPainter {
  const _AreaThumbPainter({
    required this.color,
    required this.shape,
    required this.borderWidth,
    required this.borderColor,
    required this.ringWidth,
    required this.ringColor,
    required this.textDirection,
  });

  final Color color;
  final ShapeBorder shape;
  final double borderWidth;
  final Color borderColor;
  final double ringWidth;
  final Color ringColor;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path outer = shape.getOuterPath(rect, textDirection: textDirection);
    final Path inner = heroInflatedShapePath(
      shape,
      rect,
      -borderWidth,
      textDirection,
    );
    final Paint ringPaint = Paint()..color = ringColor;
    // `0 0 0 1px rgba(0,0,0,.1)` outside the border box.
    canvas
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          heroInflatedShapePath(shape, rect, ringWidth, textDirection),
          outer,
        ),
        ringPaint,
      )
      ..drawPath(outer, Paint()..color = borderColor)
      ..drawPath(inner, Paint()..color = color)
      // `inset 0 0 0 1px rgba(0,0,0,.1)` inside the border.
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          inner,
          heroInflatedShapePath(
            shape,
            rect,
            -(borderWidth + ringWidth),
            textDirection,
          ),
        ),
        ringPaint,
      );
  }

  @override
  bool shouldRepaint(_AreaThumbPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.shape != shape ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.ringWidth != ringWidth ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.textDirection != textDirection;
}
