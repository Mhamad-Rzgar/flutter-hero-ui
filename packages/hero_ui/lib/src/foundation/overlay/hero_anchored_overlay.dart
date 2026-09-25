import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/hero_theme.dart';
import '../theme/hero_theme_data.dart';
import '../tokens/hero_motion.dart';
import 'hero_placement.dart';

/// Builds the content of an anchored overlay for a resolved [geometry].
typedef HeroOverlayContentBuilder =
    Widget Function(BuildContext context, HeroOverlayGeometry geometry);

/// Wraps overlay content in its enter/exit transition.
typedef HeroOverlayTransitionBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      HeroOverlayGeometry geometry,
      Widget child,
    );

/// The shared overlay and positioning layer behind popovers, tooltips,
/// menus, selects and combo boxes.
///
/// It renders [overlayBuilder] in the nearest [Overlay] next to [child] (the
/// trigger), positioned with React Aria's placement rules: preferred
/// [placement], [offset] from the trigger, [crossOffset] along the edge,
/// flipping to the opposite side when there is not enough room
/// ([shouldFlip]) and staying [containerPadding] inside the safe area. The
/// overlay follows the trigger when it scrolls or moves.
///
/// Dismissal follows React Aria's `useOverlay`: pressing outside
/// ([isDismissable]) or pressing Escape ([isKeyboardDismissDisabled])
/// calls [onDismiss]; the owner then sets [isOpen] to false. Modal overlays
/// ([isModal]) put a transparent barrier behind the content so the outside
/// press does not reach the page.
///
/// Opening plays HeroUI's popover entrance (150 ms: fade in, zoom from 90%,
/// 4 px slide from the trigger) and closing plays the exit (100 ms: fade out,
/// zoom to 95%), both around the trigger anchor point. Supply
/// [transitionBuilder] to customise.
class HeroAnchoredOverlay extends StatefulWidget {
  /// Creates an anchored overlay.
  const HeroAnchoredOverlay({
    super.key,
    required this.isOpen,
    required this.overlayBuilder,
    required this.child,
    this.onDismiss,
    this.onClosed,
    this.placement = HeroPlacement.bottom,
    this.offset = 8,
    this.crossOffset = 0,
    this.shouldFlip = true,
    this.containerPadding = 12,
    this.isDismissable = true,
    this.isKeyboardDismissDisabled = false,
    this.isModal = false,
    this.matchAnchorWidth = false,
    this.minWidthFromAnchor = false,
    this.autofocus = false,
    this.restoreFocus = true,
    this.enterDuration = HeroMotion.normal,
    this.exitDuration = HeroMotion.fast,
    this.transitionBuilder,
    this.groupId,
  });

  /// Whether the overlay is shown.
  final bool isOpen;

  /// Builds the overlay content.
  final HeroOverlayContentBuilder overlayBuilder;

  /// The trigger the overlay is anchored to.
  final Widget child;

  /// Called when the user asks to close the overlay (outside press or
  /// Escape).
  final VoidCallback? onDismiss;

  /// Called after the exit animation completed and the overlay was removed.
  final VoidCallback? onClosed;

  /// Preferred placement.
  final HeroPlacement placement;

  /// Distance between trigger and overlay along the main axis.
  final double offset;

  /// Shift along the cross axis.
  final double crossOffset;

  /// Whether to flip to the opposite side when there is not enough room.
  final bool shouldFlip;

  /// Minimum distance to the edges of the safe area.
  final double containerPadding;

  /// Whether pressing outside dismisses the overlay.
  final bool isDismissable;

  /// Whether Escape does NOT dismiss the overlay.
  final bool isKeyboardDismissDisabled;

  /// Whether a transparent barrier blocks the page behind the overlay.
  final bool isModal;

  /// Whether the overlay is exactly as wide as the trigger.
  final bool matchAnchorWidth;

  /// Whether the overlay is at least as wide as the trigger
  /// (`min-width: var(--trigger-width)`).
  final bool minWidthFromAnchor;

  /// Whether to move focus into the overlay when it opens.
  final bool autofocus;

  /// Whether to return focus to the previously focused node on close.
  final bool restoreFocus;

  /// Duration of the enter transition.
  final Duration enterDuration;

  /// Duration of the exit transition.
  final Duration exitDuration;

  /// Custom transition; defaults to [HeroOverlayTransition].
  final HeroOverlayTransitionBuilder? transitionBuilder;

  /// [TapRegion] group shared by trigger and overlay. Components that render
  /// extra regions (e.g. a combo box input) can share it.
  final Object? groupId;

  @override
  State<HeroAnchoredOverlay> createState() => _HeroAnchoredOverlayState();
}

class _HeroAnchoredOverlayState extends State<HeroAnchoredOverlay>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  final ValueNotifier<HeroOverlayGeometry?> _geometry =
      ValueNotifier<HeroOverlayGeometry?>(null);
  final FocusScopeNode _scope = FocusScopeNode(debugLabel: 'HeroOverlay');
  final Object _fallbackGroup = Object();
  FocusNode? _restoreTarget;

  /// Open overlays, most recent last. Escape dismisses only the top one,
  /// even when keyboard focus is outside of it.
  static final List<_HeroAnchoredOverlayState> _openStack =
      <_HeroAnchoredOverlayState>[];

  static bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        _openStack.isEmpty) {
      return false;
    }
    final _HeroAnchoredOverlayState top = _openStack.last;
    if (top.widget.isKeyboardDismissDisabled || !top.widget.isOpen) {
      return false;
    }
    top._dismiss();
    return true;
  }

  void _register() {
    if (_openStack.contains(this)) return;
    if (_openStack.isEmpty) HardwareKeyboard.instance.addHandler(_handleKey);
    _openStack.add(this);
  }

  void _unregister() {
    if (!_openStack.remove(this)) return;
    if (_openStack.isEmpty) HardwareKeyboard.instance.removeHandler(_handleKey);
  }

  Object get _groupId => widget.groupId ?? _fallbackGroup;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.enterDuration,
      reverseDuration: widget.exitDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: HeroMotion.smooth,
      reverseCurve: HeroMotion.smooth,
    );
    _controller.addStatusListener(_handleStatus);
    if (widget.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isOpen) _open();
      });
    }
  }

  @override
  void didUpdateWidget(HeroAnchoredOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller
      ..duration = widget.enterDuration
      ..reverseDuration = widget.exitDuration;
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        // OverlayPortalController.show() must not run during build.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.isOpen) _open();
        });
        SchedulerBinding.instance.ensureVisualUpdate();
      } else {
        _close();
      }
    }
  }

  @override
  void dispose() {
    _unregister();
    _controller.removeStatusListener(_handleStatus);
    _animation.dispose();
    _controller.dispose();
    _geometry.dispose();
    _scope.dispose();
    super.dispose();
  }

  bool get _reduceMotion {
    final HeroThemeData theme = HeroTheme.of(context);
    return theme.motion.shouldReduceMotion(context);
  }

  void _open() {
    _register();
    _restoreTarget = FocusManager.instance.primaryFocus;
    _portal.show();
    if (_reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.isOpen) return;
        final FocusNode? first = _scope.traversalDescendants
            .where((FocusNode n) => n.canRequestFocus)
            .firstOrNull;
        (first ?? _scope).requestFocus();
      });
    }
  }

  void _close() {
    _unregister();
    if (_reduceMotion) {
      _controller.value = 0;
    } else {
      _controller.reverse();
    }
    if (widget.restoreFocus) {
      final bool focusInside = _scope.hasFocus;
      final FocusNode? target = _restoreTarget;
      if (focusInside && target != null && target.context != null) {
        target.requestFocus();
      }
    }
  }

  void _handleStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.isOpen) {
      // A zero exit duration (reduced motion) completes while the owner
      // rebuilds, and the portal can only hide outside of the build phase.
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _handleStatus(_controller.status);
        });
        return;
      }
      if (_portal.isShowing) _portal.hide();
      _geometry.value = null;
      widget.onClosed?.call();
    }
  }

  void _dismiss() {
    if (!widget.isOpen) return;
    widget.onDismiss?.call();
  }

  void _handleGeometry(HeroOverlayGeometry geometry) {
    if (!mounted) return;
    _geometry.value = geometry;
  }

  Widget _buildOverlay(BuildContext context, OverlayChildLayoutInfo info) {
    final Rect anchor = MatrixUtils.transformRect(
      info.childPaintTransform,
      Offset.zero & info.childSize,
    );
    final MediaQueryData? media = MediaQuery.maybeOf(context);
    final EdgeInsets safe =
        (media?.padding ?? EdgeInsets.zero) +
        EdgeInsets.only(bottom: media?.viewInsets.bottom ?? 0);
    final TextDirection direction =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    Widget content = ValueListenableBuilder<HeroOverlayGeometry?>(
      valueListenable: _geometry,
      builder: (BuildContext context, HeroOverlayGeometry? geometry, _) {
        final HeroOverlayGeometry g =
            geometry ??
            HeroOverlayGeometry(
              rect: Rect.fromLTWH(anchor.left, anchor.bottom, 0, 0),
              side: resolveHeroPlacementSide(widget.placement, direction),
              anchorPoint: Offset.zero,
              maxHeight: double.infinity,
            );
        final Widget body = widget.overlayBuilder(context, g);
        final HeroOverlayTransitionBuilder transition =
            widget.transitionBuilder ?? _defaultTransition;
        return transition(context, _animation, g, body);
      },
    );

    content = _HeroAnchoredLayout(
      anchor: anchor,
      padding: safe + EdgeInsets.all(widget.containerPadding),
      placement: widget.placement,
      direction: direction,
      offset: widget.offset,
      crossOffset: widget.crossOffset,
      shouldFlip: widget.shouldFlip,
      matchAnchorWidth: widget.matchAnchorWidth,
      minWidthFromAnchor: widget.minWidthFromAnchor,
      onGeometry: _handleGeometry,
      child: TapRegion(
        groupId: _groupId,
        onTapOutside: widget.isDismissable && !widget.isModal
            ? (_) => _dismiss()
            : null,
        child: FocusScope(node: _scope, child: content),
      ),
    );

    content = AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => IgnorePointer(
        ignoring: _controller.status == AnimationStatus.reverse,
        child: child,
      ),
      child: content,
    );

    if (widget.isModal) {
      content = Stack(
        fit: StackFit.expand,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.isDismissable ? _dismiss : null,
            excludeFromSemantics: true,
          ),
          content,
        ],
      );
    }
    return content;
  }

  static Widget _defaultTransition(
    BuildContext context,
    Animation<double> animation,
    HeroOverlayGeometry geometry,
    Widget child,
  ) {
    return HeroOverlayTransition(
      animation: animation,
      geometry: geometry,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget anchor = TapRegion(groupId: _groupId, child: widget.child);
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _portal,
      overlayChildBuilder: _buildOverlay,
      child: anchor,
    );
  }
}

/// HeroUI's popover enter/exit transition.
///
/// Entering (forward): fade from 0, zoom from [enterScale] and slide
/// [slideDistance] from the trigger. Exiting (reverse): fade out and zoom to
/// [exitScale]. Transforms originate at the trigger anchor point.
class HeroOverlayTransition extends StatelessWidget {
  /// Creates the transition.
  const HeroOverlayTransition({
    super.key,
    required this.animation,
    required this.geometry,
    required this.child,
    this.enterScale = 0.9,
    this.exitScale = 0.95,
    this.slideDistance = 4,
  });

  /// Drives the transition: 0 hidden, 1 shown.
  final Animation<double> animation;

  /// The overlay geometry (side and anchor point).
  final HeroOverlayGeometry geometry;

  /// Scale at the start of the enter transition (`zoom-in-90`).
  final double enterScale;

  /// Scale at the end of the exit transition (`zoom-out-95`).
  final double exitScale;

  /// Slide distance of the enter transition (`slide-in-from-*-1`).
  final double slideDistance;

  /// The transitioned content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double t = animation.value;
        final bool exiting = animation.status == AnimationStatus.reverse;
        final double scale = exiting
            ? exitScale + (1 - exitScale) * t
            : enterScale + (1 - enterScale) * t;
        Offset slide = Offset.zero;
        if (!exiting) {
          final double d = (1 - t) * slideDistance;
          slide = switch (geometry.side) {
            HeroOverlaySide.top => Offset(0, d),
            HeroOverlaySide.bottom => Offset(0, -d),
            HeroOverlaySide.left => Offset(d, 0),
            HeroOverlaySide.right => Offset(-d, 0),
          };
        }
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: slide,
            child: Transform.scale(
              scale: scale,
              alignment: geometry.anchorAlignment,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _HeroAnchoredLayout extends SingleChildRenderObjectWidget {
  const _HeroAnchoredLayout({
    required this.anchor,
    required this.padding,
    required this.placement,
    required this.direction,
    required this.offset,
    required this.crossOffset,
    required this.shouldFlip,
    required this.matchAnchorWidth,
    required this.minWidthFromAnchor,
    required this.onGeometry,
    super.child,
  });

  final Rect anchor;
  final EdgeInsets padding;
  final HeroPlacement placement;
  final TextDirection direction;
  final double offset;
  final double crossOffset;
  final bool shouldFlip;
  final bool matchAnchorWidth;
  final bool minWidthFromAnchor;
  final ValueChanged<HeroOverlayGeometry> onGeometry;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeroAnchoredLayout(
        anchor: anchor,
        padding: padding,
        placement: placement,
        direction: direction,
        offset: offset,
        crossOffset: crossOffset,
        shouldFlip: shouldFlip,
        matchAnchorWidth: matchAnchorWidth,
        minWidthFromAnchor: minWidthFromAnchor,
        onGeometry: onGeometry,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeroAnchoredLayout renderObject,
  ) {
    renderObject
      ..anchor = anchor
      ..padding = padding
      ..placement = placement
      ..direction = direction
      ..offset = offset
      ..crossOffset = crossOffset
      ..shouldFlip = shouldFlip
      ..matchAnchorWidth = matchAnchorWidth
      ..minWidthFromAnchor = minWidthFromAnchor
      ..onGeometry = onGeometry;
  }
}

class _RenderHeroAnchoredLayout extends RenderShiftedBox {
  _RenderHeroAnchoredLayout({
    required Rect anchor,
    required EdgeInsets padding,
    required HeroPlacement placement,
    required TextDirection direction,
    required double offset,
    required double crossOffset,
    required bool shouldFlip,
    required bool matchAnchorWidth,
    required bool minWidthFromAnchor,
    required this.onGeometry,
  }) : _anchor = anchor,
       _padding = padding,
       _placement = placement,
       _direction = direction,
       _offset = offset,
       _crossOffset = crossOffset,
       _shouldFlip = shouldFlip,
       _matchAnchorWidth = matchAnchorWidth,
       _minWidthFromAnchor = minWidthFromAnchor,
       super(null);

  ValueChanged<HeroOverlayGeometry> onGeometry;
  HeroOverlayGeometry? _lastGeometry;
  bool _callbackScheduled = false;

  Rect _anchor;
  set anchor(Rect value) {
    if (_anchor == value) return;
    _anchor = value;
    markNeedsLayout();
  }

  EdgeInsets _padding;
  set padding(EdgeInsets value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsLayout();
  }

  HeroPlacement _placement;
  set placement(HeroPlacement value) {
    if (_placement == value) return;
    _placement = value;
    markNeedsLayout();
  }

  TextDirection _direction;
  set direction(TextDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  double _offset;
  set offset(double value) {
    if (_offset == value) return;
    _offset = value;
    markNeedsLayout();
  }

  double _crossOffset;
  set crossOffset(double value) {
    if (_crossOffset == value) return;
    _crossOffset = value;
    markNeedsLayout();
  }

  bool _shouldFlip;
  set shouldFlip(bool value) {
    if (_shouldFlip == value) return;
    _shouldFlip = value;
    markNeedsLayout();
  }

  bool _matchAnchorWidth;
  set matchAnchorWidth(bool value) {
    if (_matchAnchorWidth == value) return;
    _matchAnchorWidth = value;
    markNeedsLayout();
  }

  bool _minWidthFromAnchor;
  set minWidthFromAnchor(bool value) {
    if (_minWidthFromAnchor == value) return;
    _minWidthFromAnchor = value;
    markNeedsLayout();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) return;
    final Rect viewport = _padding.deflateRect(Offset.zero & size);
    final HeroOverlaySide preferred = resolveHeroPlacementSide(
      _placement,
      _direction,
    );

    double maxWidth = math.max(0, viewport.width);
    double maxHeight = math.max(0, viewport.height);
    if (preferred.isVertical) {
      maxHeight = math.max(
        heroOverlayMaxExtent(
          side: HeroOverlaySide.top,
          anchor: _anchor,
          viewport: viewport,
          offset: _offset,
        ),
        heroOverlayMaxExtent(
          side: HeroOverlaySide.bottom,
          anchor: _anchor,
          viewport: viewport,
          offset: _offset,
        ),
      );
    } else {
      maxWidth = math.max(
        heroOverlayMaxExtent(
          side: HeroOverlaySide.left,
          anchor: _anchor,
          viewport: viewport,
          offset: _offset,
        ),
        heroOverlayMaxExtent(
          side: HeroOverlaySide.right,
          anchor: _anchor,
          viewport: viewport,
          offset: _offset,
        ),
      );
    }
    double minWidth = 0;
    if (_matchAnchorWidth) {
      minWidth = math.min(_anchor.width, maxWidth);
      maxWidth = minWidth;
    } else if (_minWidthFromAnchor) {
      minWidth = math.min(_anchor.width, maxWidth);
    }

    BoxConstraints childConstraints = BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    child.layout(childConstraints, parentUsesSize: true);

    final HeroOverlaySide side = chooseHeroOverlaySide(
      preferred: preferred,
      size: child.size,
      anchor: _anchor,
      viewport: viewport,
      offset: _offset,
      shouldFlip: _shouldFlip,
    );
    final double sideExtent = heroOverlayMaxExtent(
      side: side,
      anchor: _anchor,
      viewport: viewport,
      offset: _offset,
    );
    if (side.isVertical && child.size.height > sideExtent) {
      childConstraints = childConstraints.copyWith(maxHeight: sideExtent);
      child.layout(childConstraints, parentUsesSize: true);
    } else if (!side.isVertical && child.size.width > sideExtent) {
      childConstraints = childConstraints.copyWith(
        maxWidth: sideExtent,
        minWidth: math.min(childConstraints.minWidth, sideExtent),
      );
      child.layout(childConstraints, parentUsesSize: true);
    }

    final HeroOverlayGeometry geometry = computeHeroOverlayGeometry(
      anchor: _anchor,
      size: child.size,
      viewport: viewport,
      placement: _placement,
      direction: _direction,
      offset: _offset,
      crossOffset: _crossOffset,
      shouldFlip: _shouldFlip,
    );
    (child.parentData! as BoxParentData).offset = geometry.rect.topLeft;

    if (geometry != _lastGeometry) {
      _lastGeometry = geometry;
      if (!_callbackScheduled) {
        _callbackScheduled = true;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _callbackScheduled = false;
          if (attached && _lastGeometry != null) onGeometry(_lastGeometry!);
        });
        SchedulerBinding.instance.ensureVisualUpdate();
      }
    }
  }
}
