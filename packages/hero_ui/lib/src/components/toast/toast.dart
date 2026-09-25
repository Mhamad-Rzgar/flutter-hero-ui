/// HeroUI's Toast: temporary notifications with automatic dismissal,
/// stacking and placements.
library;

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../button/button.dart';
import '../close_button/close_button.dart';
import '../modal/modal.dart' show HeroOverlaySurface, heroIsSmallBreakpoint;
import '../spinner/spinner.dart';
import 'toast_queue.dart';

export 'toast_queue.dart';

/// Builds a custom toast for a queued toast (the provider's render-prop
/// children). Return a [HeroToast].
typedef HeroToastBuilder =
    Widget Function(BuildContext context, HeroQueuedToast toast);

/// The toast region (`Toast.Provider`): renders the toasts of a
/// [HeroToastQueue] stacked in a corner or edge of the screen.
///
/// Place it once around the app, above every route, so toasts added with
/// [heroToast] from anywhere show on top of pages and modals:
///
/// ```dart
/// HeroApp(
///   builder: (context, child) => HeroToastProvider(child: child!),
///   home: const HomePage(),
/// )
/// ```
///
/// Without a [child] it renders its region over the nearest overlay, which
/// is how extra regions for custom queues and placements are added. Only
/// the first mounted provider of a queue renders it, so several providers
/// for the same queue never show duplicates.
///
/// Toasts stack with the newest in front: older ones peek out 12 px
/// ([gap]) behind it, 5% smaller each ([scaleFactor]), with the front
/// toast's height. Hovering the stack with a pointer, focusing it (Alt+T,
/// [hotkey]) or [isExpanded] fans them out; toasts beyond
/// [maxVisibleToasts] fade out while still counting down. Countdowns pause
/// while the stack is hovered or focused and while the app is in the
/// background. Escape collapses the stack.
class HeroToastProvider extends StatefulWidget {
  /// Creates a toast region.
  const HeroToastProvider({
    super.key,
    this.child,
    this.queue,
    this.placement = HeroToastPlacement.bottom,
    this.gap,
    this.isExpanded = false,
    this.maxVisibleToasts,
    this.hotkey = const SingleActivator(LogicalKeyboardKey.keyT, alt: true),
    this.scaleFactor = 0.05,
    this.width,
    this.builder,
    this.semanticLabel = 'Notifications',
  });

  /// The app content rendered below the region.
  final Widget? child;

  /// The queue to render; defaults to [heroToastQueue].
  final HeroToastQueue? queue;

  /// Where the region sits.
  final HeroToastPlacement placement;

  /// The gap between toasts (12).
  final double? gap;

  /// Keeps the stack expanded (does not pause the countdowns).
  final bool isExpanded;

  /// How many toasts are shown at a time; defaults to the queue's value,
  /// then 3.
  final int? maxVisibleToasts;

  /// Focuses the region; null disables it.
  final ShortcutActivator? hotkey;

  /// How much each toast behind the front one scales down.
  final double scaleFactor;

  /// The toast width from 640 px (460); below, toasts span the screen
  /// minus 16 px on each side.
  final double? width;

  /// Builds custom toasts; defaults to HeroUI's layout.
  final HeroToastBuilder? builder;

  /// Accessibility label of the region.
  final String semanticLabel;

  /// The queue of the nearest provider that wraps [context], or
  /// [heroToastQueue].
  static HeroToastQueue queueOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_HeroToastProviderScope>()?.queue ??
      heroToastQueue;

  @override
  State<HeroToastProvider> createState() => _HeroToastProviderState();
}

class _HeroToastProviderScope extends InheritedWidget {
  const _HeroToastProviderScope({required this.queue, required super.child});

  final HeroToastQueue queue;

  @override
  bool updateShouldNotify(_HeroToastProviderScope oldWidget) =>
      queue != oldWidget.queue;
}

class _HeroToastProviderState extends State<HeroToastProvider> {
  final OverlayPortalController _portal = OverlayPortalController();
  final FocusNode _regionFocus = FocusNode(debugLabel: 'HeroToastRegion');
  final Map<String, double> _heights = <String, double>{};
  late HeroToastQueue _queue = widget.queue ?? heroToastQueue;
  late final AppLifecycleListener _lifecycle;
  bool _hovered = false;
  bool _focused = false;
  bool _interacting = false;

  @override
  void initState() {
    super.initState();
    _attach();
    _lifecycle = AppLifecycleListener(onStateChange: _handleLifecycle);
    HardwareKeyboard.instance.addHandler(_handleKey);
    _scheduleSync();
  }

  @override
  void didUpdateWidget(HeroToastProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final HeroToastQueue queue = widget.queue ?? heroToastQueue;
    if (queue != _queue) {
      _detach();
      _queue = queue;
      _attach();
    }
    _scheduleSync();
  }

  @override
  void dispose() {
    _detach();
    HardwareKeyboard.instance.removeHandler(_handleKey);
    _lifecycle.dispose();
    _regionFocus.dispose();
    super.dispose();
  }

  void _attach() {
    _queue
      ..attachRegion(this)
      ..addListener(_handleQueue);
  }

  void _detach() {
    if (_interacting) _queue.resumeTimers(#interaction);
    _interacting = false;
    _queue
      ..resumeTimers(#lifecycle)
      ..removeListener(_handleQueue)
      ..detachRegion(this);
  }

  bool get _isActive => _queue.isActiveRegion(this);

  void _handleQueue() {
    if (!mounted) return;
    final Set<String> keys = <String>{
      for (final HeroQueuedToast toast in _queue.visibleToasts) toast.key,
    };
    _heights.removeWhere((String key, _) => !keys.contains(key));
    if (_queue.visibleToasts
        .where((HeroQueuedToast t) => !t.isExiting)
        .isEmpty) {
      // Nothing left to hover or focus.
      _hovered = false;
      if (_regionFocus.hasFocus) _regionFocus.unfocus();
      _updateInteraction();
    }
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
    _scheduleSync();
  }

  void _scheduleSync() {
    SchedulerBinding.instance.addPostFrameCallback((_) => _syncPortal());
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _syncPortal() {
    if (!mounted || widget.child != null) return;
    final bool show = _isActive && _queue.visibleToasts.isNotEmpty;
    if (show && !_portal.isShowing) {
      _portal.show();
    } else if (!show && _portal.isShowing) {
      _portal.hide();
    }
  }

  void _handleLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        _queue.resumeTimers(#lifecycle);
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _queue.suspendTimers(#lifecycle);
    }
  }

  bool _handleKey(KeyEvent event) {
    final ShortcutActivator? hotkey = widget.hotkey;
    if (hotkey == null ||
        event is! KeyDownEvent ||
        !_isActive ||
        _queue.visibleToasts.isEmpty ||
        !hotkey.accepts(event, HardwareKeyboard.instance)) {
      return false;
    }
    _regionFocus.requestFocus();
    return true;
  }

  void _updateInteraction() {
    final bool interacting = _hovered || _focused;
    if (interacting == _interacting) return;
    _interacting = interacting;
    if (interacting) {
      _queue.suspendTimers(#interaction);
    } else {
      _queue.resumeTimers(#interaction);
    }
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _updateInteraction();
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
    _updateInteraction();
  }

  void _handleHeight(String key, double height) {
    if (!mounted || _heights[key] == height) return;
    setState(() => _heights[key] = height);
  }

  KeyEventResult _handleRegionKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      // Escape folds the stack and releases focus.
      FocusManager.instance.primaryFocus?.unfocus();
      _setHovered(false);
      _setFocused(false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildRegion(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final MediaQueryData media = MediaQuery.of(context);
    final bool sm = heroIsSmallBreakpoint(context);
    final HeroToastPlacement placement = widget.placement;
    final bool top = placement.isTop;
    final double margin = theme.spacing(4);
    final double gap = widget.gap ?? theme.spacing(3);
    final int maxVisible =
        widget.maxVisibleToasts ?? _queue.maxVisibleToasts ?? 3;
    final List<HeroQueuedToast> toasts = _queue.visibleToasts;
    final List<HeroQueuedToast> layout = <HeroQueuedToast>[
      for (final HeroQueuedToast toast in toasts)
        if (!toast.isExiting) toast,
    ];
    // A single toast never expands.
    final bool expanded =
        (widget.isExpanded || _hovered || _focused) && layout.length > 1;

    final List<(int, Widget)> slots = <(int, Widget)>[];
    for (int i = 0; i < toasts.length; i++) {
      final HeroQueuedToast toast = toasts[i];
      // Exiting toasts leave the layout but keep their own slot.
      final List<HeroQueuedToast> own = toast.isExiting
          ? <HeroQueuedToast>[
              for (final HeroQueuedToast t in toasts)
                if (!t.isExiting || identical(t, toast)) t,
            ]
          : layout;
      final int index = own.indexOf(toast);
      final bool frontmost = index <= 0;
      final double ownHeight = _heights[toast.key] ?? 0;
      final double frontHeight = _heights[own.first.key] ?? ownHeight;
      double before = 0;
      for (int j = 0; j < index; j++) {
        before += _heights[own[j].key] ?? frontHeight;
      }
      slots.add((
        toast.isExiting ? 0 : toasts.length - i,
        _HeroToastSlot(
          key: ValueKey<String>(toast.key),
          toast: toast,
          queue: _queue,
          placement: placement,
          builder: widget.builder,
          gap: gap,
          isFrontmost: frontmost,
          isExpanded: expanded,
          isExiting: toast.isExiting,
          isHidden: !toast.isExiting && index >= maxVisible,
          offset: expanded ? before + index * gap : index * gap,
          collapsedScale: 1 - index * widget.scaleFactor,
          forcedHeight: !frontmost && !expanded ? frontHeight : null,
          onHeight: _handleHeight,
        ),
      ));
    }
    // Newest on top; exiting toasts at the bottom.
    slots.sort(((int, Widget) a, (int, Widget) b) => a.$1.compareTo(b.$1));

    final double width = sm
        ? (widget.width ?? theme.spacing(115))
        : math.max(0, media.size.width - margin * 2);
    Widget region = SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[for (final (int, Widget) slot in slots) slot.$2],
      ),
    );
    region = MouseRegion(
      opaque: false,
      hitTestBehavior: HitTestBehavior.deferToChild,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: region,
    );
    region = Focus(
      focusNode: _regionFocus,
      onFocusChange: _setFocused,
      onKeyEvent: _handleRegionKey,
      child: region,
    );
    region = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.region,
      label: widget.semanticLabel,
      child: region,
    );
    final AlignmentGeometry alignment = switch (placement) {
      HeroToastPlacement.topStart => AlignmentDirectional.topStart,
      HeroToastPlacement.top => Alignment.topCenter,
      HeroToastPlacement.topEnd => AlignmentDirectional.topEnd,
      HeroToastPlacement.bottomStart => AlignmentDirectional.bottomStart,
      HeroToastPlacement.bottom => Alignment.bottomCenter,
      HeroToastPlacement.bottomEnd => AlignmentDirectional.bottomEnd,
    };
    final EdgeInsets padding =
        EdgeInsets.all(margin) +
        media.padding +
        EdgeInsets.only(bottom: top ? 0 : media.viewInsets.bottom);
    return Padding(
      padding: padding,
      child: Align(alignment: alignment, child: region),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget? child = widget.child;
    if (child != null) {
      final bool show = _isActive && _queue.visibleToasts.isNotEmpty;
      return _HeroToastProviderScope(
        queue: _queue,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            child,
            if (show) Positioned.fill(child: Builder(builder: _buildRegion)),
          ],
        ),
      );
    }
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildRegion,
      child: const SizedBox.shrink(),
    );
  }
}

/// What a [HeroToast] knows about its place in the stack.
class HeroToastScope extends InheritedWidget {
  /// Creates the scope.
  const HeroToastScope({
    super.key,
    required this.toast,
    required this.queue,
    required this.placement,
    required this.isFrontmost,
    required this.isExpanded,
    required this.isExiting,
    required this.isHidden,
    required super.child,
  });

  /// The queued toast.
  final HeroQueuedToast toast;

  /// Its queue.
  final HeroToastQueue queue;

  /// The region placement.
  final HeroToastPlacement placement;

  /// Whether this is the newest toast.
  final bool isFrontmost;

  /// Whether the stack is expanded.
  final bool isExpanded;

  /// Whether the toast is animating out.
  final bool isExiting;

  /// Whether the toast is beyond the visible limit.
  final bool isHidden;

  /// Whether the toast is folded behind the front one (content hidden).
  bool get isCollapsedBehind => !isFrontmost && !isExpanded;

  /// The nearest scope, or null.
  static HeroToastScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroToastScope>();

  @override
  bool updateShouldNotify(HeroToastScope oldWidget) =>
      toast != oldWidget.toast ||
      placement != oldWidget.placement ||
      isFrontmost != oldWidget.isFrontmost ||
      isExpanded != oldWidget.isExpanded ||
      isExiting != oldWidget.isExiting ||
      isHidden != oldWidget.isHidden;
}

/// Positions and animates one toast of the stack.
class _HeroToastSlot extends StatelessWidget {
  const _HeroToastSlot({
    super.key,
    required this.toast,
    required this.queue,
    required this.placement,
    required this.builder,
    required this.gap,
    required this.isFrontmost,
    required this.isExpanded,
    required this.isExiting,
    required this.isHidden,
    required this.offset,
    required this.collapsedScale,
    required this.forcedHeight,
    required this.onHeight,
  });

  final HeroQueuedToast toast;
  final HeroToastQueue queue;
  final HeroToastPlacement placement;
  final HeroToastBuilder? builder;
  final double gap;
  final bool isFrontmost;
  final bool isExpanded;
  final bool isExiting;
  final bool isHidden;
  final double offset;
  final double collapsedScale;
  final double? forcedHeight;
  final void Function(String key, double height) onHeight;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool top = placement.isTop;
    final double dir = top ? 1 : -1;
    const Curve curve = HeroMotion.easeOutFluid;
    // --toast-enter-duration 350ms, --toast-exit-duration 250ms, 200ms for
    // toasts behind the front one.
    final Duration translate = theme.motion.resolve(
      context,
      isExiting
          ? (isFrontmost ? HeroMotion.slow : HeroMotion.medium)
          : HeroMotion.slowest,
    );
    final Duration size = theme.motion.resolve(context, HeroMotion.slowest);
    final Duration fade = theme.motion.resolve(context, HeroMotion.normal);
    final double scale = isExiting
        ? (isFrontmost ? 1 : (isExpanded ? 0.96 : collapsedScale * 0.96))
        : (isExpanded ? 1 : collapsedScale);

    Widget body = HeroToastScope(
      toast: toast,
      queue: queue,
      placement: placement,
      isFrontmost: isFrontmost,
      isExpanded: isExpanded,
      isExiting: isExiting,
      isHidden: isHidden,
      child: Builder(
        builder: (BuildContext context) =>
            builder?.call(context, toast) ?? _HeroDefaultToast(toast: toast),
      ),
    );
    body = _HeroToastMeasure(
      onHeight: (double height) => onHeight(toast.key, height),
      child: body,
    );
    final double? forced = forcedHeight;
    if (forced != null) {
      // Folded behind the front toast: the front toast's height, clipped.
      body = SizedBox(
        height: forced,
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: double.infinity,
          child: body,
        ),
      );
    }
    body = AnimatedSize(
      duration: size,
      curve: curve,
      alignment: Alignment.topCenter,
      clipBehavior: forced != null ? Clip.hardEdge : Clip.none,
      child: body,
    );
    if (isExpanded) {
      // The hit area covers the gap towards the next toast, so moving the
      // pointer between toasts keeps the stack expanded.
      body = Padding(
        padding: top
            ? EdgeInsets.only(bottom: gap + 1)
            : EdgeInsets.only(top: gap + 1),
        child: body,
      );
    }
    body = Listener(behavior: HitTestBehavior.opaque, child: body);
    body = AnimatedScale(
      scale: scale,
      duration: translate,
      curve: curve,
      alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
      child: body,
    );
    // Enter from one toast height beyond the edge; the front toast exits the
    // same way.
    body = TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: translate == Duration.zero ? 0 : -1,
        end: isExiting && isFrontmost ? -1 : 0,
      ),
      duration: translate,
      curve: curve,
      child: body,
      builder: (BuildContext context, double enter, Widget? child) =>
          FractionalTranslation(
            translation: Offset(0, dir * enter),
            child: child,
          ),
    );
    body = TweenAnimationBuilder<double>(
      tween: Tween<double>(end: offset),
      duration: translate,
      curve: curve,
      child: body,
      builder: (BuildContext context, double y, Widget? child) =>
          Transform.translate(offset: Offset(0, dir * y), child: child),
    );
    body = AnimatedOpacity(
      opacity: isExiting || isHidden ? 0 : 1,
      duration: fade,
      curve: curve,
      child: body,
    );
    body = IgnorePointer(ignoring: isHidden, child: body);
    body = ExcludeSemantics(excluding: isHidden || isExiting, child: body);
    return Positioned(
      left: 0,
      right: 0,
      top: top ? 0 : null,
      bottom: top ? null : 0,
      child: body,
    );
  }
}

/// Reports the natural height of its child after layout.
class _HeroToastMeasure extends SingleChildRenderObjectWidget {
  const _HeroToastMeasure({required this.onHeight, super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeroToastMeasure(onHeight);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeroToastMeasure renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderHeroToastMeasure extends RenderProxyBox {
  _RenderHeroToastMeasure(this.onHeight);

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final double height = size.height;
    if (height == _reported) return;
    _reported = height;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (attached) onHeight(height);
    });
  }
}

/// HeroUI's default toast layout for a queued toast.
class _HeroDefaultToast extends StatelessWidget {
  const _HeroDefaultToast({required this.toast});

  final HeroQueuedToast toast;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroToastData data = toast.data;
    // The action sits beside the text on desktop and below it on touch
    // layouts.
    final bool desktop = theme.isDesktop(context);
    final HeroToastAction? action = data.action;
    final Widget? actionButton = action == null
        ? null
        : HeroToastActionButton(
            variant: action.variant,
            style: action.style,
            onPressed: action.onPressed,
            child: Text(action.label),
          );
    return HeroToast(
      variant: data.variant,
      children: <Widget>[
        if (data.showIndicator)
          HeroToastIndicator(
            variant: data.variant,
            child: data.isLoading
                ? const HeroSpinner(
                    size: HeroSpinnerSize.sm,
                    color: HeroSpinnerColor.current,
                  )
                : data.indicator,
          ),
        HeroToastContent(
          children: <Widget>[
            if (data.title != null) HeroToastTitle(child: Text(data.title!)),
            if (data.description != null)
              HeroToastDescription(child: Text(data.description!)),
            if (!desktop && actionButton != null) actionButton,
          ],
        ),
        if (desktop && actionButton != null) actionButton,
        const HeroToastCloseButton(),
      ],
    );
  }
}

class _HeroToastVariantScope extends InheritedWidget {
  const _HeroToastVariantScope({required this.variant, required super.child});

  final HeroToastVariant variant;

  static HeroToastVariant of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_HeroToastVariantScope>()
          ?.variant ??
      HeroToastVariant.standard;

  @override
  bool updateShouldNotify(_HeroToastVariantScope oldWidget) =>
      variant != oldWidget.variant;
}

class _HeroToastCloseScope extends InheritedWidget {
  const _HeroToastCloseScope({
    required this.isRevealed,
    required this.onFocusChanged,
    required super.child,
  });

  final bool isRevealed;
  final ValueChanged<bool> onFocusChanged;

  @override
  bool updateShouldNotify(_HeroToastCloseScope oldWidget) =>
      isRevealed != oldWidget.isRevealed;
}

/// One toast (`Toast`): a `surface` card with the overlay shadow, 24 px
/// corners and 16 × 12 padding laying out its [children] in a row with
/// 6 px gaps.
///
/// Inside a [HeroToastProvider] it follows its place in the stack: the
/// content fades out when it is folded behind the front toast, it can be
/// focused when it is in front or the stack is expanded, and its
/// [HeroToastCloseButton] (pinned just outside the top end corner) appears
/// while the pointer hovers it.
///
/// Use it from a provider `builder` to render custom toasts:
///
/// ```dart
/// HeroToastProvider(
///   queue: queue,
///   builder: (context, toast) => HeroToast(
///     variant: toast.data.variant,
///     children: <Widget>[
///       HeroToastIndicator(variant: toast.data.variant),
///       HeroToastContent(children: <Widget>[
///         HeroToastTitle(child: Text(toast.data.title ?? '')),
///       ]),
///       const HeroToastCloseButton(),
///     ],
///   ),
/// )
/// ```
class HeroToast extends StatefulWidget {
  /// Creates a toast.
  const HeroToast({
    super.key,
    this.variant = HeroToastVariant.standard,
    this.children = const <Widget>[],
    this.backgroundColor,
    this.side = BorderSide.none,
    this.borderRadius,
    this.shadows,
    this.padding,
  });

  /// The color scheme of the title and indicator.
  final HeroToastVariant variant;

  /// The parts: [HeroToastIndicator], [HeroToastContent],
  /// [HeroToastActionButton], [HeroToastCloseButton]. [Positioned] and
  /// [PositionedDirectional] children are placed over the card (e.g. a
  /// close button in a custom position).
  final List<Widget> children;

  /// Overrides the `surface` fill.
  final Color? backgroundColor;

  /// A border inside the card.
  final BorderSide side;

  /// Overrides the 24 px corner radius.
  final double? borderRadius;

  /// Replaces the overlay shadow.
  final List<BoxShadow>? shadows;

  /// Overrides the 16 × 12 padding.
  final EdgeInsetsGeometry? padding;

  /// Shows a toast on the queue of the nearest [HeroToastProvider] (or the
  /// default queue) and returns its key.
  ///
  /// When no provider renders that queue, a region is added to the root
  /// overlay so the toast is visible.
  static String show(
    BuildContext context,
    String title, {
    String? description,
    Widget? indicator,
    bool showIndicator = true,
    HeroToastVariant variant = HeroToastVariant.standard,
    HeroToastAction? action,
    bool isLoading = false,
    Duration timeout = HeroToastQueue.defaultTimeout,
    VoidCallback? onClose,
  }) {
    final HeroToastQueue queue = HeroToastProvider.queueOf(context);
    if (!queue.hasRegion) {
      final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
      overlay?.insert(
        OverlayEntry(
          builder: (BuildContext context) => HeroToastProvider(
            queue: identical(queue, heroToastQueue) ? null : queue,
            child: const SizedBox.expand(),
          ),
        ),
      );
    }
    return HeroToaster(queue)(
      title,
      description: description,
      indicator: indicator,
      showIndicator: showIndicator,
      variant: variant,
      action: action,
      isLoading: isLoading,
      timeout: timeout,
      onClose: onClose,
    );
  }

  @override
  State<HeroToast> createState() => _HeroToastState();
}

class _HeroToastState extends State<HeroToast> {
  final FocusNode _focus = FocusNode(debugLabel: 'HeroToast');
  bool _hovered = false;
  bool _focusVisible = false;
  bool _closeFocused = false;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _handleFocus(bool focused) {
    final bool visible =
        focused &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    if (visible != _focusVisible) setState(() => _focusVisible = visible);
  }

  void _moveFocusAway() {
    // A focused toast that leaves the stack hands keyboard focus to the
    // nearest remaining toast (React Aria's behaviour); pointer focus is
    // simply released.
    if (!_focus.hasFocus) return;
    if (FocusManager.instance.highlightMode == FocusHighlightMode.traditional) {
      final bool moved = _focus.nextFocus() || _focus.previousFocus();
      if (moved) return;
    }
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroToastScope? scope = HeroToastScope.maybeOf(context);
    final bool frontmost = scope?.isFrontmost ?? true;
    final bool expanded = scope?.isExpanded ?? false;
    final bool exiting = scope?.isExiting ?? false;
    final bool hidden = scope?.isHidden ?? false;
    final bool collapsed = scope?.isCollapsedBehind ?? false;
    final bool focusable = frontmost || (expanded && !hidden && !exiting);
    if ((exiting || hidden) && _focus.hasFocus) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _moveFocusAway());
    }
    final Duration fade = theme.motion.resolve(context, HeroMotion.medium);
    final double radius =
        widget.borderRadius ?? math.min(theme.spacing(8), theme.radii.xl3);
    final OutlinedBorder shape = theme.shapeAll(radius, side: widget.side);

    final List<Widget> closeButtons = <Widget>[];
    final List<Widget> positioned = <Widget>[];
    final List<Widget> row = <Widget>[];
    for (final Widget child in widget.children) {
      if (child is Positioned || child is PositionedDirectional) {
        positioned.add(child);
      } else if (child is HeroToastCloseButton) {
        closeButtons.add(child);
      } else if (child is HeroToastContent) {
        row.add(
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: child,
            ),
          ),
        );
      } else {
        row.add(Align(alignment: AlignmentDirectional.topStart, child: child));
      }
    }

    Widget content = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: theme.spacing(1.5),
        children: row,
      ),
    );
    // Content fades while the toast is folded behind the front one.
    content = AnimatedOpacity(
      opacity: collapsed ? 0 : 1,
      duration: fade,
      curve: HeroMotion.easeOutFluid,
      child: content,
    );
    content = Padding(
      padding:
          widget.padding ??
          EdgeInsets.symmetric(
            horizontal: theme.spacing(4),
            vertical: theme.spacing(3),
          ),
      child: content,
    );
    content = DefaultTextStyle(
      style: theme.typography.sm.copyWith(
        color: theme.colors.overlayForeground,
      ),
      child: content,
    );
    Widget card = HeroOverlaySurface(
      shape: shape,
      color: widget.backgroundColor ?? theme.colors.surface,
      shadows: widget.shadows,
      side: widget.side,
      clipBehavior: Clip.none,
      child: content,
    );
    card = HeroFocusRing(
      visible: _focusVisible && !exiting,
      shape: shape,
      child: card,
    );
    final bool revealed =
        (frontmost || expanded) && (_hovered || _closeFocused) && !exiting;
    if (closeButtons.isNotEmpty || positioned.isNotEmpty) {
      card = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          card,
          for (final Widget child in positioned)
            _HeroToastCloseScope(
              isRevealed: revealed && !collapsed,
              onFocusChanged: (bool focused) {
                if (focused != _closeFocused) {
                  setState(() => _closeFocused = focused);
                }
              },
              child: child,
            ),
          if (closeButtons.isNotEmpty)
            PositionedDirectional(
              top: -theme.spacing(1),
              end: -theme.spacing(1),
              child: _HeroToastCloseScope(
                isRevealed: revealed && !collapsed,
                onFocusChanged: (bool focused) {
                  if (focused != _closeFocused) {
                    setState(() => _closeFocused = focused);
                  }
                },
                child: closeButtons.first,
              ),
            ),
        ],
      );
    }
    card = MouseRegion(
      opaque: false,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: card,
    );
    card = Focus(
      focusNode: _focus,
      canRequestFocus: focusable,
      skipTraversal: !focusable,
      onFocusChange: _handleFocus,
      child: card,
    );
    return _HeroToastVariantScope(
      variant: widget.variant,
      child: Semantics(
        container: true,
        liveRegion: true,
        explicitChildNodes: true,
        role: SemanticsRole.alertDialog,
        child: card,
      ),
    );
  }
}

/// The icon of a toast (`Toast.Indicator`): 16 px in a 24 px box, in
/// `overlay-foreground` (the soft foreground of the success, warning and
/// danger variants), defaulting to the variant's info, success, warning or
/// danger icon. When a spinner is replaced by an icon (a promise toast
/// settling) the icon fades in and zooms from 92%.
class HeroToastIndicator extends StatefulWidget {
  /// Creates an indicator.
  const HeroToastIndicator({super.key, this.variant, this.child});

  /// The variant; defaults to the enclosing [HeroToast]'s.
  final HeroToastVariant? variant;

  /// A custom icon or a spinner.
  final Widget? child;

  /// The default icon of [variant].
  static HeroIconData iconFor(HeroToastVariant variant) => switch (variant) {
    HeroToastVariant.success => HeroIcons.success,
    HeroToastVariant.warning => HeroIcons.warning,
    HeroToastVariant.danger => HeroIcons.danger,
    HeroToastVariant.standard || HeroToastVariant.accent => HeroIcons.info,
  };

  @override
  State<HeroToastIndicator> createState() => _HeroToastIndicatorState();
}

class _HeroToastIndicatorState extends State<HeroToastIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swap = AnimationController(
    vsync: this,
    duration: HeroMotion.medium,
    value: 1,
  );
  late Object _kind = _kindOf(widget.child);

  static Object _kindOf(Widget? child) => child?.runtimeType ?? #standard;

  @override
  void didUpdateWidget(HeroToastIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Object kind = _kindOf(widget.child);
    if (kind != _kind) {
      _kind = kind;
      if (widget.child is! HeroSpinner &&
          !HeroTheme.of(context).motion.shouldReduceMotion(context)) {
        _swap.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _swap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroToastVariant variant =
        widget.variant ?? _HeroToastVariantScope.of(context);
    final Color color = switch (variant) {
      HeroToastVariant.success => theme.colors.successSoftForeground,
      HeroToastVariant.warning => theme.colors.warningSoftForeground,
      HeroToastVariant.danger => theme.colors.dangerSoftForeground,
      HeroToastVariant.standard ||
      HeroToastVariant.accent => theme.colors.overlayForeground,
    };
    final Widget icon =
        widget.child ?? HeroIcon(HeroToastIndicator.iconFor(variant));
    return ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing(1)),
        child: IconTheme(
          data: IconThemeData(color: color, size: theme.spacing(4)),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: color),
            child: SizedBox.square(
              dimension: theme.spacing(4),
              child: AnimatedBuilder(
                animation: _swap,
                child: Center(child: icon),
                builder: (BuildContext context, Widget? child) {
                  // Fade over 150 ms, zoom from 92% over 200 ms.
                  final double t = _swap.value;
                  final double fade = HeroMotion.easeOutFluid.transform(
                    (t * 4 / 3).clamp(0.0, 1.0),
                  );
                  final double zoom = HeroMotion.easeOutFluid.transform(t);
                  return Opacity(
                    opacity: fade,
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * zoom,
                      child: child,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The text column of a toast (`Toast.Content`), vertically centered in
/// the row.
class HeroToastContent extends StatelessWidget {
  /// Creates the content column.
  const HeroToastContent({super.key, this.children = const <Widget>[]});

  /// The title, description and (on touch layouts) the action.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// The title of a toast (`Toast.Title`): 14/20 medium in
/// `overlay-foreground`, or the soft foreground of the variant.
class HeroToastTitle extends StatelessWidget {
  /// Creates a title.
  const HeroToastTitle({super.key, required this.child});

  /// The title, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Color color = switch (_HeroToastVariantScope.of(context)) {
      HeroToastVariant.standard => theme.colors.overlayForeground,
      HeroToastVariant.accent => theme.colors.accentSoftForeground,
      HeroToastVariant.success => theme.colors.successSoftForeground,
      HeroToastVariant.warning => theme.colors.warningSoftForeground,
      HeroToastVariant.danger => theme.colors.dangerSoftForeground,
    };
    return DefaultTextStyle(
      style: theme.typography
          .style(HeroFontSize.sm, weight: HeroTypography.medium)
          .copyWith(color: color),
      child: child,
    );
  }
}

/// The description of a toast (`Toast.Description`): 14 px `muted`.
class HeroToastDescription extends StatelessWidget {
  /// Creates a description.
  const HeroToastDescription({super.key, required this.child});

  /// The description, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return DefaultTextStyle(
      style: theme.typography.sm.copyWith(color: theme.colors.muted),
      child: child,
    );
  }
}

/// The action button of a toast (`Toast.ActionButton`): a [HeroButton]
/// with 8 px above it when it sits below the text (below 640 px).
class HeroToastActionButton extends StatelessWidget {
  /// Creates an action button.
  const HeroToastActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = HeroButtonVariant.primary,
    this.size,
    this.style,
  });

  /// The label.
  final Widget child;

  /// Called when pressed.
  final VoidCallback? onPressed;

  /// The button variant.
  final HeroButtonVariant variant;

  /// The button size.
  final HeroSize? size;

  /// Button style overrides.
  final HeroButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        top: heroIsSmallBreakpoint(context) ? 0 : theme.spacing(2),
      ),
      child: HeroButton(
        variant: variant,
        size: size,
        style: style,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

/// The close button of a toast (`Toast.CloseButton`): a 20 px
/// [HeroCloseButton] pinned just outside the top end corner that closes the
/// toast. It is hidden until the pointer hovers the toast (or it has
/// keyboard focus); from 640 px it has an `overlay` fill with a 1 px
/// border.
class HeroToastCloseButton extends StatelessWidget {
  /// Creates a close button.
  const HeroToastCloseButton({
    super.key,
    this.onPressed,
    this.semanticLabel = 'Close',
    this.style,
    this.alwaysVisible = false,
  });

  /// Called before the toast closes.
  final VoidCallback? onPressed;

  /// Accessibility label.
  final String semanticLabel;

  /// Overrides the close button style.
  final HeroButtonStyle? style;

  /// Shows the button without hovering (custom layouts).
  final bool alwaysVisible;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroToastScope? scope = HeroToastScope.maybeOf(context);
    final _HeroToastCloseScope? close = context
        .dependOnInheritedWidgetOfExactType<_HeroToastCloseScope>();
    final bool sm = heroIsSmallBreakpoint(context);
    final bool revealed =
        alwaysVisible ||
        (close?.isRevealed ?? true) && !(scope?.isExiting ?? false);
    final HeroButtonStyle base = HeroButtonStyle(
      height: theme.spacing(5),
      borderRadius: BorderRadius.circular(theme.spacing(2.5)),
      iconSize: theme.spacing(sm ? 3 : 3.5),
      side: sm
          ? BorderSide(color: theme.colors.border, width: theme.borderWidth)
          : null,
      backgroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.hovered) || !sm
            ? theme.colors.defaultColor
            : theme.colors.overlay,
      ),
    );
    Widget button = HeroCloseButton(
      semanticLabel: semanticLabel,
      style: style ?? base,
      onPressed: () {
        onPressed?.call();
        final HeroToastScope? scope = HeroToastScope.maybeOf(context);
        scope?.queue.close(scope.toast.key);
      },
    );
    button = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: close?.onFocusChanged,
      child: button,
    );
    return IgnorePointer(
      ignoring: !revealed,
      child: AnimatedOpacity(
        opacity: revealed ? 1 : 0,
        duration: theme.motion.resolve(context, HeroMotion.normal),
        curve: HeroMotion.smooth,
        child: button,
      ),
    );
  }
}
