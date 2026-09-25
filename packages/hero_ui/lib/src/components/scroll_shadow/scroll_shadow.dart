/// HeroUI's ScrollShadow: a scroll container whose edges fade out where
/// there is more content to scroll to.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The visual effect of a [HeroScrollShadow] (HeroUI's `variant`).
enum HeroScrollShadowVariant {
  /// The edges fade to transparent (a gradient mask).
  fade,
}

/// Which edges of a [HeroScrollShadow] fade (HeroUI's
/// `ScrollShadowVisibility`).
///
/// As [HeroScrollShadow.visibility] it controls the fades; [auto] follows
/// the scroll position. [HeroScrollShadow.onVisibilityChanged] reports one
/// of the other values: [both], [top] or [left] (only content before),
/// [bottom] or [right] (only content after) and [none].
enum HeroScrollShadowVisibility {
  /// Follows the scroll position (the default).
  auto,

  /// Both edges fade.
  both,

  /// The top edge of a vertical scroll shadow fades.
  top,

  /// The bottom edge of a vertical scroll shadow fades.
  bottom,

  /// The start edge of a horizontal scroll shadow fades (the right edge in
  /// right-to-left layouts).
  left,

  /// The end edge of a horizontal scroll shadow fades (the left edge in
  /// right-to-left layouts).
  right,

  /// No edge fades.
  none,
}

/// Builds the scroll view of a [HeroScrollShadow.builder] around the
/// [controller] the scroll shadow tracks.
typedef HeroScrollShadowBuilder =
    Widget Function(BuildContext context, ScrollController controller);

/// A scroll container whose edges fade where there is more content (HeroUI
/// `ScrollShadow`).
///
/// ```dart
/// HeroScrollShadow(
///   constraints: const BoxConstraints(maxHeight: 240),
///   padding: const EdgeInsets.all(16),
///   child: const Text(longText),
/// )
/// ```
///
/// The fade follows the scroll position continuously, exactly like
/// HeroUI's scroll-driven mask: the start edge fades over
/// `clamp(scrolled - offset, 0, size)` and the end edge over
/// `clamp(remaining - offset, 0, size)`, so both fades grow and shrink
/// gradually over the first and last [size] pixels. Content that does not
/// overflow is not faded.
///
/// * [orientation]: vertical (default) or horizontal. Horizontal fades are
///   logical: the start edge is on the right in right-to-left layouts.
/// * [size]: the fade length (40 by default); [offset]: how far the content
///   must scroll before a fade starts.
/// * [visibility]: [HeroScrollShadowVisibility.auto] follows the scroll
///   position; any other value shows fixed, full-size fades on the given
///   edges. [isEnabled] `false` turns the automatic fade off.
/// * [onVisibilityChanged] reports which edges have content beyond them,
///   whenever that changes.
/// * [hideScrollBar] hides the scrollbar. Otherwise a [scrollbarGutter]
///   strip (10 by default) along the scrollbar edge is never faded, so the
///   scrollbar stays crisp.
///
/// The scroll view uses iOS bouncing physics. Like HeroUI's container the
/// scroll shadow has no background, border or padding of its own; [padding]
/// is applied inside the scroll view and scrolls with the content, and
/// [decoration] is painted behind the content and fades with it, like CSS
/// backgrounds on a masked element.
///
/// Use [HeroScrollShadow.builder] to fade a [ListView] or any other scroll
/// view: build it with the given controller.
class HeroScrollShadow extends StatefulWidget {
  /// Creates a scroll shadow that scrolls [child].
  const HeroScrollShadow({
    super.key,
    required Widget this.child,
    this.orientation = Axis.vertical,
    this.variant = HeroScrollShadowVariant.fade,
    this.size,
    this.offset = 0,
    this.hideScrollBar = false,
    this.isEnabled = true,
    this.visibility = HeroScrollShadowVisibility.auto,
    this.onVisibilityChanged,
    this.controller,
    this.physics,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.decoration,
    this.scrollbarGutter,
    this.focusNode,
  }) : builder = null;

  /// Creates a scroll shadow around the scroll view built by [builder],
  /// such as a [ListView] using the given controller.
  ///
  /// [physics] and [padding] are left to the built scroll view.
  const HeroScrollShadow.builder({
    super.key,
    required HeroScrollShadowBuilder this.builder,
    this.orientation = Axis.vertical,
    this.variant = HeroScrollShadowVariant.fade,
    this.size,
    this.offset = 0,
    this.hideScrollBar = false,
    this.isEnabled = true,
    this.visibility = HeroScrollShadowVisibility.auto,
    this.onVisibilityChanged,
    this.controller,
    this.width,
    this.height,
    this.constraints,
    this.decoration,
    this.scrollbarGutter,
  }) : child = null,
       physics = null,
       padding = null,
       focusNode = null;

  /// The scrolled content.
  final Widget? child;

  /// Builds the scroll view; replaces [child].
  final HeroScrollShadowBuilder? builder;

  /// The scroll direction.
  final Axis orientation;

  /// The visual effect.
  final HeroScrollShadowVariant variant;

  /// The fade length; defaults to 40 (`--scroll-shadow-size`).
  final double? size;

  /// How far the content must be scrolled before a fade starts
  /// (`--scroll-shadow-offset`).
  final double offset;

  /// Whether to hide the scrollbar (`hideScrollBar`).
  final bool hideScrollBar;

  /// Whether the automatic fade is on; when false and [visibility] is
  /// [HeroScrollShadowVisibility.auto] no edge fades.
  final bool isEnabled;

  /// Which edges fade; [HeroScrollShadowVisibility.auto] follows the scroll
  /// position.
  final HeroScrollShadowVisibility visibility;

  /// Called with the edges that have content beyond them when that changes
  /// (automatic mode only), and once when the content is first laid out.
  final ValueChanged<HeroScrollShadowVisibility>? onVisibilityChanged;

  /// An optional scroll controller.
  final ScrollController? controller;

  /// Scroll physics; defaults to iOS bouncing physics.
  final ScrollPhysics? physics;

  /// Padding inside the scroll view, scrolling with the content.
  final EdgeInsetsGeometry? padding;

  /// Fixed width (`w-*`).
  final double? width;

  /// Fixed height (`h-*`).
  final double? height;

  /// Extra size constraints, such as a maximum height (`max-h-*`).
  final BoxConstraints? constraints;

  /// Painted behind the content and faded with it; a border takes room
  /// inside, and the content is clipped to the decoration's shape.
  final Decoration? decoration;

  /// The strip along the scrollbar edge that never fades
  /// (`--scroll-shadow-scrollbar-size`); defaults to 10, or 0 when
  /// [hideScrollBar].
  final double? scrollbarGutter;

  /// Focus node of the scroll area. Content that overflows and has no
  /// focusable descendants can be focused to scroll it with the keyboard.
  final FocusNode? focusNode;

  /// Returns the edges with content beyond them for [metrics], as HeroUI
  /// reports them: content before is more than [offset] pixels away, content
  /// after more than [offset] + 1 pixels.
  static HeroScrollShadowVisibility visibilityOf(
    ScrollMetrics metrics, {
    double offset = 0,
  }) {
    final double scrolled = metrics.pixels - metrics.minScrollExtent;
    final double range = metrics.maxScrollExtent - metrics.minScrollExtent;
    final bool before = scrolled > offset;
    final bool after = scrolled + offset < range - 1;
    final bool vertical = metrics.axis == Axis.vertical;
    if (before && after) return HeroScrollShadowVisibility.both;
    if (before) {
      return vertical
          ? HeroScrollShadowVisibility.top
          : HeroScrollShadowVisibility.left;
    }
    if (after) {
      return vertical
          ? HeroScrollShadowVisibility.bottom
          : HeroScrollShadowVisibility.right;
    }
    return HeroScrollShadowVisibility.none;
  }

  /// Returns the lengths of the start and end fades for [metrics] in
  /// automatic mode (HeroUI's scroll-driven fade).
  static ({double start, double end}) fadesOf(
    ScrollMetrics metrics, {
    required double size,
    double offset = 0,
  }) {
    final double range = metrics.maxScrollExtent - metrics.minScrollExtent;
    if (range <= 0) return (start: 0, end: 0);
    final double scrolled = metrics.pixels - metrics.minScrollExtent;
    return (
      start: clampDouble(scrolled - offset, 0, size),
      end: clampDouble(range - scrolled - offset, 0, size),
    );
  }

  @override
  State<HeroScrollShadow> createState() => _HeroScrollShadowState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<Axis>(
          'orientation',
          orientation,
          defaultValue: Axis.vertical,
        ),
      )
      ..add(DoubleProperty('size', size, defaultValue: null))
      ..add(DoubleProperty('offset', offset, defaultValue: 0))
      ..add(
        EnumProperty<HeroScrollShadowVisibility>(
          'visibility',
          visibility,
          defaultValue: HeroScrollShadowVisibility.auto,
        ),
      )
      ..add(
        FlagProperty(
          'hideScrollBar',
          value: hideScrollBar,
          ifTrue: 'scrollbar hidden',
        ),
      )
      ..add(
        FlagProperty(
          'isEnabled',
          value: isEnabled,
          ifFalse: 'disabled',
          defaultValue: true,
        ),
      );
  }
}

class _HeroScrollShadowState extends State<HeroScrollShadow> {
  ScrollController? _ownController;
  FocusNode? _ownFocusNode;
  final ValueNotifier<int> _metricsChanged = ValueNotifier<int>(0);
  late Listenable _repaint;
  HeroScrollShadowVisibility? _reported;
  bool _overflows = false;
  bool _hasFocusableContent = false;
  bool _focused = false;
  bool _focusHighlight = false;

  ScrollController get _controller =>
      widget.controller ?? (_ownController ??= ScrollController());

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroScrollShadow'));

  bool get _tracksScroll =>
      widget.isEnabled && widget.visibility == HeroScrollShadowVisibility.auto;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(HeroScrollShadow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detach(oldWidget.controller ?? _ownController);
      if (widget.controller != null) {
        _ownController?.dispose();
        _ownController = null;
      }
      _attach();
    }
    if (oldWidget.focusNode != widget.focusNode && widget.focusNode != null) {
      _ownFocusNode?.dispose();
      _ownFocusNode = null;
    }
    if (!_tracksScroll) {
      _reported = null;
    } else if (oldWidget.offset != widget.offset ||
        oldWidget.orientation != widget.orientation ||
        !(oldWidget.isEnabled &&
            oldWidget.visibility == HeroScrollShadowVisibility.auto)) {
      _reported = null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _update();
      });
    }
  }

  void _attach() {
    _controller.addListener(_handleScroll);
    _repaint = Listenable.merge(<Listenable>[_controller, _metricsChanged]);
  }

  void _detach(ScrollController? controller) {
    controller?.removeListener(_handleScroll);
  }

  @override
  void dispose() {
    _detach(widget.controller ?? _ownController);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    _metricsChanged.dispose();
    super.dispose();
  }

  ScrollPosition? get _position {
    final ScrollController controller = _controller;
    if (!controller.hasClients) return null;
    for (final ScrollPosition position in controller.positions) {
      if (axisDirectionToAxis(position.axisDirection) == widget.orientation) {
        return position;
      }
    }
    return null;
  }

  void _handleScroll() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // Scrolled during layout: report after the frame.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _update();
      });
      return;
    }
    _update();
  }

  bool _handleMetrics(ScrollMetricsNotification notification) {
    if (notification.depth == 0 &&
        notification.metrics.axis == widget.orientation) {
      // Content resized without scrolling: repaint the fade.
      _metricsChanged.value++;
      _update();
    }
    return false;
  }

  void _update() {
    final ScrollPosition? position = _position;
    if (position == null ||
        !position.hasContentDimensions ||
        !position.hasPixels ||
        !position.hasViewportDimension) {
      return;
    }
    final bool overflows = position.maxScrollExtent > position.minScrollExtent;
    final bool focusable =
        widget.child != null && _focusNode.traversalDescendants.isNotEmpty;
    if (overflows != _overflows || focusable != _hasFocusableContent) {
      setState(() {
        _overflows = overflows;
        _hasFocusableContent = focusable;
      });
    }
    if (!_tracksScroll) return;
    final HeroScrollShadowVisibility visibility = HeroScrollShadow.visibilityOf(
      position,
      offset: widget.offset,
    );
    if (visibility == _reported) return;
    _reported = visibility;
    widget.onVisibilityChanged?.call(visibility);
  }

  void _handleFocus(bool focused) {
    if (_focused == focused) return;
    setState(() => _focused = focused);
  }

  void _handleFocusHighlight(bool visible) {
    if (_focusHighlight == visible) return;
    setState(() => _focusHighlight = visible);
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextDirection textDirection = Directionality.of(context);
    final ScrollBehavior behavior = ScrollConfiguration.of(context);
    final Decoration? decoration = widget.decoration;

    Widget scrollView;
    final HeroScrollShadowBuilder? builder = widget.builder;
    if (builder != null) {
      scrollView = builder(context, _controller);
    } else {
      Widget content = widget.child!;
      if (widget.hideScrollBar) {
        // Nested scroll views keep their scrollbars (`scrollbar-none` is not
        // inherited).
        content = ScrollConfiguration(behavior: behavior, child: content);
      }
      scrollView = SingleChildScrollView(
        controller: _controller,
        scrollDirection: widget.orientation,
        physics: widget.physics ?? const BouncingScrollPhysics(),
        padding: widget.padding,
        child: FocusableActionDetector(
          focusNode: _focusNode,
          enabled: _overflows && !_hasFocusableContent,
          includeFocusSemantics: false,
          mouseCursor: MouseCursor.defer,
          onFocusChange: _handleFocus,
          onShowFocusHighlight: _handleFocusHighlight,
          child: content,
        ),
      );
    }
    if (widget.hideScrollBar) {
      scrollView = ScrollConfiguration(
        behavior: behavior.copyWith(scrollbars: false),
        child: scrollView,
      );
    }
    scrollView = NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleMetrics,
      child: scrollView,
    );
    if (decoration != null) {
      scrollView = DecoratedBox(
        decoration: decoration,
        child: Padding(
          padding: decoration.padding,
          child: ClipPath(
            clipper: _DecorationClipper(decoration, textDirection),
            child: scrollView,
          ),
        ),
      );
    }

    Widget result = _HeroScrollFadeMask(
      controller: _controller,
      repaint: _repaint,
      axis: widget.orientation,
      size: widget.size ?? theme.spacing(10),
      offset: widget.offset,
      gutter: widget.hideScrollBar
          ? 0
          : widget.scrollbarGutter ?? theme.spacing(2.5),
      visibility: widget.visibility,
      isEnabled: widget.isEnabled,
      textDirection: textDirection,
      child: scrollView,
    );
    if (widget.width != null ||
        widget.height != null ||
        widget.constraints != null) {
      result = ConstrainedBox(
        constraints: (widget.constraints ?? const BoxConstraints()).tighten(
          width: widget.width,
          height: widget.height,
        ),
        child: result,
      );
    }
    if (widget.builder == null) {
      result = HeroFocusRing(
        visible: _focused && _focusHighlight,
        shape: decoration is ShapeDecoration
            ? decoration.shape
            : theme.shape(
                decoration is BoxDecoration
                    ? decoration.borderRadius ?? BorderRadius.zero
                    : BorderRadius.zero,
              ),
        child: result,
      );
    }
    return result;
  }
}

class _DecorationClipper extends CustomClipper<Path> {
  const _DecorationClipper(this.decoration, this.textDirection);

  final Decoration decoration;
  final TextDirection textDirection;

  @override
  Path getClip(Size size) {
    // The clip follows the inner edge of the decoration's border.
    final EdgeInsets border = decoration.padding.resolve(textDirection);
    return decoration.getClipPath(
      border.inflateRect(Offset.zero & size),
      textDirection,
    );
  }

  @override
  bool shouldReclip(_DecorationClipper oldClipper) =>
      oldClipper.decoration != decoration ||
      oldClipper.textDirection != textDirection;
}

/// Paints [child] through HeroUI's fade mask and sizes it like a block.
class _HeroScrollFadeMask extends SingleChildRenderObjectWidget {
  const _HeroScrollFadeMask({
    required this.controller,
    required this.repaint,
    required this.axis,
    required this.size,
    required this.offset,
    required this.gutter,
    required this.visibility,
    required this.isEnabled,
    required this.textDirection,
    required Widget super.child,
  });

  final ScrollController controller;
  final Listenable repaint;
  final Axis axis;
  final double size;
  final double offset;
  final double gutter;
  final HeroScrollShadowVisibility visibility;
  final bool isEnabled;
  final TextDirection textDirection;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeroScrollFadeMask(
        controller: controller,
        repaint: repaint,
        axis: axis,
        size: size,
        offset: offset,
        gutter: gutter,
        visibility: visibility,
        isEnabled: isEnabled,
        textDirection: textDirection,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeroScrollFadeMask renderObject,
  ) {
    renderObject
      ..controller = controller
      ..repaint = repaint
      ..axis = axis
      ..fadeSize = size
      ..offset = offset
      ..gutter = gutter
      ..visibility = visibility
      ..isEnabled = isEnabled
      ..textDirection = textDirection;
  }
}

class _RenderHeroScrollFadeMask extends RenderProxyBox {
  _RenderHeroScrollFadeMask({
    required ScrollController controller,
    required Listenable repaint,
    required Axis axis,
    required double size,
    required double offset,
    required double gutter,
    required HeroScrollShadowVisibility visibility,
    required bool isEnabled,
    required TextDirection textDirection,
  }) : _controller = controller,
       _repaint = repaint,
       _axis = axis,
       _fadeSize = size,
       _offset = offset,
       _gutter = gutter,
       _visibility = visibility,
       _isEnabled = isEnabled,
       _textDirection = textDirection;

  ScrollController get controller => _controller;
  ScrollController _controller;
  set controller(ScrollController value) {
    if (value == _controller) return;
    _controller = value;
    markNeedsPaint();
  }

  Listenable get repaint => _repaint;
  Listenable _repaint;
  set repaint(Listenable value) {
    if (value == _repaint) return;
    if (attached) _repaint.removeListener(markNeedsPaint);
    _repaint = value;
    if (attached) _repaint.addListener(markNeedsPaint);
    markNeedsPaint();
  }

  Axis get axis => _axis;
  Axis _axis;
  set axis(Axis value) {
    if (value == _axis) return;
    _axis = value;
    markNeedsPaint();
  }

  double get fadeSize => _fadeSize;
  double _fadeSize;
  set fadeSize(double value) {
    if (value == _fadeSize) return;
    _fadeSize = value;
    markNeedsPaint();
  }

  double get offset => _offset;
  double _offset;
  set offset(double value) {
    if (value == _offset) return;
    _offset = value;
    markNeedsPaint();
  }

  double get gutter => _gutter;
  double _gutter;
  set gutter(double value) {
    if (value == _gutter) return;
    _gutter = value;
    markNeedsPaint();
  }

  HeroScrollShadowVisibility get visibility => _visibility;
  HeroScrollShadowVisibility _visibility;
  set visibility(HeroScrollShadowVisibility value) {
    if (value == _visibility) return;
    _visibility = value;
    markNeedsPaint();
  }

  bool get isEnabled => _isEnabled;
  bool _isEnabled;
  set isEnabled(bool value) {
    if (value == _isEnabled) return;
    _isEnabled = value;
    markNeedsPaint();
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _repaint.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _repaint.removeListener(markNeedsPaint);
    super.detach();
  }

  // Like a CSS block box, the scroll area takes the full width it is
  // offered, or the width of its content where the width is unbounded.
  BoxConstraints _childConstraints(RenderBox child, BoxConstraints c) {
    if (c.hasBoundedWidth) return c.tighten(width: c.maxWidth);
    return c.tighten(
      width: c.constrainWidth(child.getMaxIntrinsicWidth(c.maxHeight)),
    );
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) return constraints.smallest;
    return child.getDryLayout(_childConstraints(child, constraints));
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(child, constraints), parentUsesSize: true);
    size = child.size;
  }

  @override
  ShaderMaskLayer? get layer => super.layer as ShaderMaskLayer?;

  @override
  bool get alwaysNeedsCompositing => child != null;

  /// The fade lengths at the physical top/left ([before]) and bottom/right
  /// ([after]) edges.
  ({double before, double after}) _fades() {
    final bool vertical = _axis == Axis.vertical;
    final bool rtl = _textDirection == TextDirection.rtl;
    final double size = _fadeSize;
    // Horizontal `left`/`right` are logical (before/after the scroll).
    ({double before, double after}) logical(double start, double end) =>
        !vertical && rtl
        ? (before: end, after: start)
        : (before: start, after: end);
    switch (_visibility) {
      case HeroScrollShadowVisibility.auto:
        break;
      case HeroScrollShadowVisibility.both:
        return (before: size, after: size);
      case HeroScrollShadowVisibility.top:
        return vertical ? (before: size, after: 0) : (before: 0, after: 0);
      case HeroScrollShadowVisibility.bottom:
        return vertical ? (before: 0, after: size) : (before: 0, after: 0);
      case HeroScrollShadowVisibility.left:
        return vertical ? (before: 0, after: 0) : logical(size, 0);
      case HeroScrollShadowVisibility.right:
        return vertical ? (before: 0, after: 0) : logical(0, size);
      case HeroScrollShadowVisibility.none:
        return (before: 0, after: 0);
    }
    if (!_isEnabled || !_controller.hasClients) return (before: 0, after: 0);
    for (final ScrollPosition position in _controller.positions) {
      if (axisDirectionToAxis(position.axisDirection) != _axis ||
          !position.hasContentDimensions ||
          !position.hasPixels ||
          !position.hasViewportDimension) {
        continue;
      }
      final ({double start, double end}) fades = HeroScrollShadow.fadesOf(
        position,
        size: size,
        offset: _offset,
      );
      return switch (position.axisDirection) {
        AxisDirection.down ||
        AxisDirection.right => (before: fades.start, after: fades.end),
        AxisDirection.up ||
        AxisDirection.left => (before: fades.end, after: fades.start),
      };
    }
    return (before: 0, after: 0);
  }

  /// The masked area: everything but the scrollbar gutter.
  Rect _maskRect() {
    final double gutter = math.min(
      _gutter,
      _axis == Axis.vertical ? size.width : size.height,
    );
    return switch (_axis) {
      // The scrollbar is on the end side of a vertical scroll view.
      Axis.vertical => Rect.fromLTWH(
        _textDirection == TextDirection.rtl ? gutter : 0,
        0,
        size.width - gutter,
        size.height,
      ),
      Axis.horizontal => Rect.fromLTWH(0, 0, size.width, size.height - gutter),
    };
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child == null) {
      layer = null;
      return;
    }
    final ({double before, double after}) fades = _fades();
    final Rect mask = _maskRect();
    final double extent = _axis == Axis.vertical ? mask.height : mask.width;
    if ((fades.before <= 0 && fades.after <= 0) ||
        mask.isEmpty ||
        extent <= 0) {
      layer = null;
      context.paintChild(child, offset);
      return;
    }
    // `transparent 0, #000 before, #000 calc(100% - after), transparent
    // 100%`, with CSS color-stop fix-up for overlapping fades.
    final double first = clampDouble(fades.before / extent, 0, 1);
    final double second = math.max(
      first,
      clampDouble(1 - fades.after / extent, 0, 1),
    );
    const Color opaque = Color(0xFF000000);
    const Color clear = Color(0x00000000);
    final Shader shader = LinearGradient(
      begin: _axis == Axis.vertical
          ? Alignment.topCenter
          : Alignment.centerLeft,
      end: _axis == Axis.vertical
          ? Alignment.bottomCenter
          : Alignment.centerRight,
      colors: const <Color>[clear, opaque, opaque, clear],
      stops: <double>[0, first, second, 1],
    ).createShader(Offset.zero & mask.size);
    layer ??= ShaderMaskLayer();
    layer!
      ..shader = shader
      ..maskRect = mask.shift(offset)
      ..blendMode = BlendMode.dstIn;
    context.pushLayer(layer!, super.paint, offset);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Axis>('axis', axis))
      ..add(DoubleProperty('fadeSize', fadeSize))
      ..add(DoubleProperty('gutter', gutter))
      ..add(EnumProperty<HeroScrollShadowVisibility>('visibility', visibility));
  }
}
