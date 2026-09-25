import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The fill behind a modal, alert dialog or drawer (the backdrop `variant`).
enum HeroBackdropVariant {
  /// The `backdrop` token (black at 50% in light, 60% in dark), the
  /// default.
  opaque,

  /// The `backdrop` token plus a 12 px blur of the page
  /// (`backdrop-blur-md`).
  blur,

  /// No fill; the page stays visible but still cannot be interacted with.
  transparent,
}

/// The enter and exit motion of one layer of a modal route (the backdrop,
/// the container or a drawer panel).
///
/// Every field is optional; `null` keeps the component's HeroUI value. The
/// scales and offsets are the start of the enter transition and the end of
/// the exit transition (Tailwind's `zoom-in-*`, `zoom-out-*`,
/// `slide-in-from-*` and `slide-out-to-*`).
///
/// ```dart
/// // HeroUI's "Kinematic Scale" example.
/// const HeroModalMotion(
///   enterDuration: Duration(milliseconds: 400),
///   exitDuration: Duration(milliseconds: 200),
///   enterCurve: Cubic(0.16, 1, 0.3, 1),
///   exitCurve: Cubic(0.7, 0, 0.84, 0),
///   enterScale: 0.95,
///   exitScale: 0.95,
///   enterOffset: Offset.zero,
/// )
/// ```
@immutable
class HeroModalMotion with Diagnosticable {
  /// Creates a motion override.
  const HeroModalMotion({
    this.enterDuration,
    this.exitDuration,
    this.enterCurve,
    this.exitCurve,
    this.enterScale,
    this.exitScale,
    this.enterOffset,
    this.exitOffset,
  });

  /// Duration of the enter transition.
  final Duration? enterDuration;

  /// Duration of the exit transition.
  final Duration? exitDuration;

  /// Easing of the enter transition.
  final Curve? enterCurve;

  /// Easing of the exit transition.
  final Curve? exitCurve;

  /// Scale the layer enters from.
  final double? enterScale;

  /// Scale the layer exits to.
  final double? exitScale;

  /// Offset the layer enters from.
  final Offset? enterOffset;

  /// Offset the layer exits to.
  final Offset? exitOffset;

  /// Fills the unset fields of this motion from [defaults].
  HeroModalMotion withDefaults(HeroModalMotion defaults) => HeroModalMotion(
    enterDuration: enterDuration ?? defaults.enterDuration,
    exitDuration: exitDuration ?? defaults.exitDuration,
    enterCurve: enterCurve ?? defaults.enterCurve,
    exitCurve: exitCurve ?? defaults.exitCurve,
    enterScale: enterScale ?? defaults.enterScale,
    exitScale: exitScale ?? defaults.exitScale,
    enterOffset: enterOffset ?? defaults.enterOffset,
    exitOffset: exitOffset ?? defaults.exitOffset,
  );

  /// The progress of this layer, from 0 (hidden) to 1 (shown), for the
  /// state of a modal [route] animation.
  ///
  /// The route runs for its own (longest) durations; this layer occupies
  /// the start of the enter and of the exit transition.
  double progress(HeroModalRoute<Object?> route) {
    final Animation<double> animation = route.animation!;
    final double t = animation.value;
    if (animation.status == AnimationStatus.reverse) {
      final int total = route.reverseTransitionDuration.inMicroseconds;
      final int own = (exitDuration ?? Duration.zero).inMicroseconds;
      if (total == 0 || own == 0) return t;
      final double elapsed = ((1 - t) * total / own).clamp(0.0, 1.0);
      return 1 - (exitCurve ?? HeroMotion.linear).transform(elapsed);
    }
    final int total = route.transitionDuration.inMicroseconds;
    final int own = (enterDuration ?? Duration.zero).inMicroseconds;
    if (total == 0 || own == 0) return t;
    final double elapsed = (t * total / own).clamp(0.0, 1.0);
    return (enterCurve ?? HeroMotion.linear).transform(elapsed);
  }

  @override
  bool operator ==(Object other) =>
      other is HeroModalMotion &&
      other.enterDuration == enterDuration &&
      other.exitDuration == exitDuration &&
      other.enterCurve == enterCurve &&
      other.exitCurve == exitCurve &&
      other.enterScale == enterScale &&
      other.exitScale == exitScale &&
      other.enterOffset == enterOffset &&
      other.exitOffset == exitOffset;

  @override
  int get hashCode => Object.hash(
    enterDuration,
    exitDuration,
    enterCurve,
    exitCurve,
    enterScale,
    exitScale,
    enterOffset,
    exitOffset,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Duration>('enterDuration', enterDuration))
      ..add(DiagnosticsProperty<Duration>('exitDuration', exitDuration))
      ..add(DoubleProperty('enterScale', enterScale))
      ..add(DoubleProperty('exitScale', exitScale));
  }
}

/// A layer of a modal route with its own enter and exit durations; the
/// route runs as long as its slowest layer.
abstract interface class HeroModalAnimatedLayer {
  /// How long the layer takes to enter.
  Duration get enterDuration;

  /// How long the layer takes to exit.
  Duration get exitDuration;
}

/// The Navigator route behind modals, alert dialogs and drawers.
///
/// A [PopupRoute] (not a Material dialog) that
///
/// * paints nothing by itself: the backdrop, the container and the dialog
///   animate themselves from [animation] (see [HeroModalBackdrop]);
/// * traps focus (Tab and Shift+Tab cycle inside the route) and hands focus
///   back to the previously focused widget when it closes;
/// * blocks pointer input and semantics of the page below;
/// * turns Escape, outside presses, close buttons and the system back
///   action into [dismiss] requests, honouring [isDismissable] and
///   [isKeyboardDismissDisabled];
/// * exposes [HeroDialogScope] so `HeroButton(slot: HeroButtonSlot.close)`
///   closes it.
///
/// When [onDismissRequest] is set (controlled components), dismiss requests
/// are forwarded to it and the owner closes the route with [close];
/// otherwise the route closes itself.
class HeroModalRoute<T> extends PopupRoute<T> {
  /// Creates a modal route.
  HeroModalRoute({
    required this.builder,
    Duration transitionDuration = HeroMotion.slow,
    Duration reverseTransitionDuration = HeroMotion.fast,
    this.onDismissRequest,
    this.isDismissable = true,
    this.isKeyboardDismissDisabled = false,
    this.theme,
    this.textDirection,
    super.settings,
  }) : _transitionDuration = transitionDuration,
       _reverseTransitionDuration = reverseTransitionDuration,
       super(traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop);

  /// Builds the content of the route, usually a [HeroModalBackdrop].
  WidgetBuilder builder;

  /// Called instead of closing when the user asks to close the route.
  VoidCallback? onDismissRequest;

  /// Whether pressing outside the dialog closes the route.
  bool isDismissable;

  /// Whether Escape (and the system back action) does NOT close the route.
  bool isKeyboardDismissDisabled;

  /// The theme captured from the widget that opened the route.
  HeroThemeData? theme;

  /// The text direction captured from the widget that opened the route.
  TextDirection? textDirection;

  final Duration _transitionDuration;
  final Duration _reverseTransitionDuration;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  /// Whether the route is playing its exit transition.
  bool get isExiting => animation?.status == AnimationStatus.reverse;

  /// Asks the route to close: forwards to [onDismissRequest] when set,
  /// otherwise closes the route with [result].
  void dismiss([Object? result]) {
    if (!isActive || isExiting) return;
    final VoidCallback? request = onDismissRequest;
    if (request != null) {
      request();
    } else {
      close(result is T ? result : null);
    }
  }

  /// Handles a press outside the dialog: dismisses when [isDismissable].
  void handleOutsidePress() {
    if (isDismissable) dismiss();
  }

  /// Handles Escape: dismisses unless [isKeyboardDismissDisabled].
  void handleEscape() {
    if (!isKeyboardDismissDisabled) dismiss();
  }

  /// Closes the route with its exit transition.
  void close([T? result]) {
    final NavigatorState? navigator = this.navigator;
    if (!isActive || navigator == null) return;
    if (isCurrent) {
      navigator.pop<T>(result);
    } else {
      navigator.removeRoute<T>(this, result);
    }
  }

  /// Rebuilds the route's content after [builder], [theme] or
  /// [textDirection] changed. Safe to call during a build.
  void markContentNeedsBuild() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (isActive) changedExternalState();
      });
    } else if (isActive) {
      changedExternalState();
    }
  }

  // The system back action is routed through [dismiss] so controlled owners
  // stay in charge and `isKeyboardDismissDisabled` applies to it too.
  @override
  RoutePopDisposition get popDisposition => RoutePopDisposition.doNotPop;

  @override
  void onPopInvokedWithResult(bool didPop, T? result) {
    if (!didPop) handleEscape();
    super.onPopInvokedWithResult(didPop, result);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    Widget page = _HeroModalContentSlot(
      route: this,
      child: _HeroModalAutofocus(child: Builder(builder: builder)),
    );
    page = HeroDialogScope(close: dismiss, child: page);
    page = Actions(
      actions: <Type, Action<Intent>>{
        DismissIntent: _HeroModalDismissAction(this),
      },
      child: page,
    );
    page = HeroModalRouteScope(route: this, child: page);
    if (textDirection != null) {
      page = Directionality(textDirection: textDirection!, child: page);
    }
    if (theme != null) page = HeroTheme(data: theme!, child: page);
    return page;
  }
}

/// The focus target of the dialog itself.
///
/// React Aria focuses the dialog when it opens, even when nothing on the
/// page was focused. The route's own focus scope sits above the route's
/// actions (Escape), so focus that lands on the scope is moved to this
/// node, which is below them. It is skipped by Tab traversal.
class _HeroModalAutofocus extends StatefulWidget {
  const _HeroModalAutofocus({required this.child});

  final Widget child;

  @override
  State<_HeroModalAutofocus> createState() => _HeroModalAutofocusState();
}

class _HeroModalAutofocusState extends State<_HeroModalAutofocus> {
  final FocusNode _node = FocusNode(
    debugLabel: 'HeroModalRoute',
    skipTraversal: true,
  );
  FocusScopeNode? _scope;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final FocusScopeNode scope = FocusScope.of(context);
    if (scope != _scope) {
      _scope?.removeListener(_redirect);
      _scope = scope..addListener(_redirect);
    }
  }

  @override
  void dispose() {
    _scope?.removeListener(_redirect);
    _node.dispose();
    super.dispose();
  }

  void _redirect() {
    final FocusScopeNode? scope = _scope;
    if (!mounted || scope == null) return;
    final HeroModalRoute<Object?>? route = context
        .getInheritedWidgetOfExactType<HeroModalRouteScope>()
        ?.route;
    if (route != null && (!route.isCurrent || route.isExiting)) return;
    if (!scope.hasFocus || scope.hasPrimaryFocus) _node.requestFocus();
  }

  @override
  Widget build(BuildContext context) =>
      Focus(focusNode: _node, child: widget.child);
}

class _HeroModalDismissAction extends DismissAction {
  _HeroModalDismissAction(this.route);

  final HeroModalRoute<Object?> route;

  @override
  bool isEnabled(DismissIntent intent) =>
      !route.isKeyboardDismissDisabled && !route.isExiting;

  @override
  Object? invoke(DismissIntent intent) {
    route.handleEscape();
    return null;
  }
}

/// Gives the layers of a modal route access to their [route].
class HeroModalRouteScope extends InheritedWidget {
  /// Creates the scope.
  const HeroModalRouteScope({
    super.key,
    required this.route,
    required super.child,
  });

  /// The enclosing modal route.
  final HeroModalRoute<Object?> route;

  /// The nearest modal route, or null outside of one.
  static HeroModalRoute<Object?>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroModalRouteScope>()?.route;

  @override
  bool updateShouldNotify(HeroModalRouteScope oldWidget) =>
      route != oldWidget.route;
}

/// Marks the direct content of a modal route. The first
/// [HeroModalBackdrop] below it renders as the route's backdrop; other
/// backdrops (e.g. a nested, controlled modal inside the dialog) act as
/// their own roots.
class _HeroModalContentSlot extends InheritedWidget {
  const _HeroModalContentSlot({required this.route, required super.child});

  const _HeroModalContentSlot.claimed({required super.child}) : route = null;

  final HeroModalRoute<Object?>? route;

  @override
  bool updateShouldNotify(_HeroModalContentSlot oldWidget) =>
      route != oldWidget.route;
}

/// Opens [content] in a [HeroModalRoute] and keeps it in sync with an open
/// state: the shared root of `HeroModal`, `HeroAlertDialog` and
/// `HeroDrawer`.
///
/// The state is controlled by [controller], or by [isOpen] and
/// [onOpenChanged], or kept internally (starting at [defaultOpen]).
/// Pressing the [trigger] (any `HeroButton` or `HeroInteractable`) opens
/// it. In controlled mode, dismissal only calls [onOpenChanged] with
/// `false`; the modal closes when the owner passes `isOpen: false`.
class HeroModalHost extends StatefulWidget {
  /// Creates a modal host.
  const HeroModalHost({
    super.key,
    required this.content,
    this.trigger,
    this.isOpen,
    this.defaultOpen = false,
    this.onOpenChanged,
    this.controller,
    this.transitionDuration = HeroMotion.slow,
    this.reverseTransitionDuration = HeroMotion.fast,
    this.useRootNavigator = true,
  });

  /// The route content, usually a backdrop widget.
  final Widget content;

  /// The widget that opens the modal when pressed.
  final Widget? trigger;

  /// Controlled open state.
  final bool? isOpen;

  /// Initial open state when uncontrolled.
  final bool defaultOpen;

  /// Called when the open state should change.
  final ValueChanged<bool>? onOpenChanged;

  /// External open state; takes precedence over [isOpen].
  final HeroOverlayController? controller;

  /// Duration of the route's enter transition.
  final Duration transitionDuration;

  /// Duration of the route's exit transition.
  final Duration reverseTransitionDuration;

  /// Whether to open in the root navigator (like a portal to `body`) or
  /// in the nearest one (e.g. inside a [HeroOverlayHost]).
  final bool useRootNavigator;

  @override
  State<HeroModalHost> createState() => _HeroModalHostState();
}

class _HeroModalHostState extends State<HeroModalHost> {
  late bool _uncontrolledOpen = widget.defaultOpen;
  HeroModalRoute<Object?>? _route;

  bool get _controlled => widget.controller != null || widget.isOpen != null;

  bool get _isOpen =>
      widget.controller?.isOpen ?? widget.isOpen ?? _uncontrolledOpen;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_scheduleSync);
    if (_isOpen) _scheduleSync();
  }

  @override
  void didUpdateWidget(HeroModalHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_scheduleSync);
      widget.controller?.addListener(_scheduleSync);
    }
    _updateRoute();
    _scheduleSync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRoute();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_scheduleSync);
    final HeroModalRoute<Object?>? route = _route;
    _route = null;
    if (route != null) {
      route.onDismissRequest = null;
      SchedulerBinding.instance.addPostFrameCallback((_) => route.close());
    }
    super.dispose();
  }

  void _updateRoute() {
    final HeroModalRoute<Object?>? route = _route;
    if (route == null) return;
    route
      ..theme = context.getInheritedWidgetOfExactType<HeroTheme>()?.data
      ..textDirection = Directionality.maybeOf(context)
      ..markContentNeedsBuild();
  }

  void _setOpen(bool value) {
    if (value == _isOpen) return;
    final HeroOverlayController? controller = widget.controller;
    if (controller != null) {
      controller.setOpen(value);
      widget.onOpenChanged?.call(value);
    } else if (widget.isOpen != null) {
      widget.onOpenChanged?.call(value);
    } else {
      setState(() => _uncontrolledOpen = value);
      widget.onOpenChanged?.call(value);
    }
    _scheduleSync();
  }

  void _scheduleSync() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _sync());
      SchedulerBinding.instance.ensureVisualUpdate();
    } else {
      _sync();
    }
  }

  void _sync() {
    if (!mounted) return;
    if (_isOpen && _route == null) {
      _open();
    } else if (!_isOpen && _route != null) {
      final HeroModalRoute<Object?> route = _route!;
      _route = null;
      route.close();
    }
  }

  void _open() {
    final NavigatorState navigator = Navigator.of(
      context,
      rootNavigator: widget.useRootNavigator,
    );
    final bool reduce = HeroTheme.of(
      context,
    ).motion.shouldReduceMotion(context);
    final HeroModalRoute<Object?> route = HeroModalRoute<Object?>(
      builder: (BuildContext context) => widget.content,
      transitionDuration: reduce ? Duration.zero : widget.transitionDuration,
      reverseTransitionDuration: reduce
          ? Duration.zero
          : widget.reverseTransitionDuration,
      onDismissRequest: () => _setOpen(false),
      theme: context.getInheritedWidgetOfExactType<HeroTheme>()?.data,
      textDirection: Directionality.maybeOf(context),
    );
    _route = route;
    unawaited(
      navigator.push<Object?>(route).then((_) {
        if (!mounted || _route != route) return;
        // Closed from outside (e.g. Navigator.pop): report it.
        _route = null;
        if (_isOpen) {
          if (_controlled) {
            widget.controller?.setOpen(false);
            widget.onOpenChanged?.call(false);
          } else {
            _setOpen(false);
          }
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The route inherits theme and direction from here; rebuild with them.
    context.dependOnInheritedWidgetOfExactType<HeroTheme>();
    Directionality.maybeOf(context);
    final Widget? trigger = widget.trigger;
    if (trigger == null) return const SizedBox.shrink();
    return HeroPressResponder(
      onPressed: () => _setOpen(true),
      isExpanded: _isOpen,
      child: trigger,
    );
  }
}

/// A bounded area that modals, alert dialogs and drawers opened inside it
/// (with `useRootNavigator: false`) render into, instead of covering the
/// whole app. The counterpart of HeroUI's `UNSTABLE_portalContainer`.
///
/// ```dart
/// SizedBox(
///   height: 380,
///   child: HeroOverlayHost(
///     child: HeroModal(useRootNavigator: false, ...),
///   ),
/// )
/// ```
class HeroOverlayHost extends StatefulWidget {
  /// Creates an overlay host.
  const HeroOverlayHost({super.key, required this.child});

  /// The content of the area.
  final Widget child;

  @override
  State<HeroOverlayHost> createState() => _HeroOverlayHostState();
}

class _HeroOverlayHostState extends State<HeroOverlayHost> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Navigator(
        pages: <Page<void>>[_HeroOverlayHostPage(child: widget.child)],
        onDidRemovePage: (Page<Object?> page) {},
      ),
    );
  }
}

class _HeroOverlayHostPage extends Page<void> {
  const _HeroOverlayHostPage({required this.child})
    : super(key: const ValueKey<String>('HeroOverlayHost'));

  final Widget child;

  @override
  Route<void> createRoute(BuildContext context) =>
      _HeroOverlayHostRoute(page: this);
}

class _HeroOverlayHostRoute extends PageRoute<void> {
  _HeroOverlayHostRoute({required _HeroOverlayHostPage page})
    : super(settings: page);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => (settings as _HeroOverlayHostPage).child;
}

/// The backdrop of a modal (`Modal.Backdrop`), also used by alert dialogs
/// and drawers.
///
/// Inside a modal route it covers the (visual) viewport with the [variant]
/// fill, fades in and out with the route and closes the route when pressed
/// ([isDismissable]); its [child] (the container) is laid out on top.
///
/// Placed directly in a page with [isOpen] and [onOpenChanged] (HeroUI's
/// controlled `<Modal.Backdrop isOpen onOpenChange>`), it acts as the root
/// of the modal: it renders nothing in place and opens itself in a route
/// while [isOpen] is true.
class HeroModalBackdrop extends StatelessWidget
    implements HeroModalAnimatedLayer {
  /// Creates a backdrop.
  const HeroModalBackdrop({
    super.key,
    required this.child,
    this.variant = HeroBackdropVariant.opaque,
    this.isDismissable = true,
    this.isKeyboardDismissDisabled = false,
    this.isOpen,
    this.onOpenChanged,
    this.color,
    this.decoration,
    this.motion = const HeroModalMotion(),
    this.useRootNavigator = true,
  });

  /// The container laid out on top of the backdrop.
  final Widget child;

  /// The fill.
  final HeroBackdropVariant variant;

  /// Whether pressing the backdrop closes the modal.
  final bool isDismissable;

  /// Whether Escape does NOT close the modal.
  final bool isKeyboardDismissDisabled;

  /// Controlled open state when the backdrop is used as the root.
  final bool? isOpen;

  /// Called when the open state should change.
  final ValueChanged<bool>? onOpenChanged;

  /// Replaces the fill color of the variant (`bg-*`).
  final Color? color;

  /// Replaces the fill with a decoration, e.g. a gradient (`bg-linear-*`);
  /// the blur of [HeroBackdropVariant.blur] still applies.
  final Decoration? decoration;

  /// Overrides of the fade (150 ms `ease-out` in, 100 ms out).
  final HeroModalMotion motion;

  /// Whether a root backdrop opens in the root navigator.
  final bool useRootNavigator;

  /// HeroUI's backdrop motion: fade in over 150 ms and out over 100 ms,
  /// both `ease-out`.
  static const HeroModalMotion defaultMotion = HeroModalMotion(
    enterDuration: HeroMotion.normal,
    exitDuration: HeroMotion.fast,
    enterCurve: HeroMotion.easeOut,
    exitCurve: HeroMotion.easeOut,
  );

  /// The motion used by this backdrop (overrides on top of the defaults).
  HeroModalMotion get resolvedMotion => motion.withDefaults(defaultMotion);

  /// The route enter duration: the slower of the backdrop and its child.
  @override
  Duration get enterDuration {
    final Duration own = resolvedMotion.enterDuration!;
    final Widget child = this.child;
    if (child is HeroModalAnimatedLayer) {
      final Duration other = (child as HeroModalAnimatedLayer).enterDuration;
      return other > own ? other : own;
    }
    return own;
  }

  /// The route exit duration: the slower of the backdrop and its child.
  @override
  Duration get exitDuration {
    final Duration own = resolvedMotion.exitDuration!;
    final Widget child = this.child;
    if (child is HeroModalAnimatedLayer) {
      final Duration other = (child as HeroModalAnimatedLayer).exitDuration;
      return other > own ? other : own;
    }
    return own;
  }

  @override
  Widget build(BuildContext context) {
    final _HeroModalContentSlot? slot = context
        .dependOnInheritedWidgetOfExactType<_HeroModalContentSlot>();
    final HeroModalRoute<Object?>? route = slot?.route;
    if (route == null) {
      // Used directly in a page: act as the root of the modal.
      return HeroModalHost(
        content: this,
        isOpen: isOpen ?? false,
        onOpenChanged: onOpenChanged,
        transitionDuration: enterDuration,
        reverseTransitionDuration: exitDuration,
        useRootNavigator: useRootNavigator,
      );
    }
    route
      ..isDismissable = isDismissable
      ..isKeyboardDismissDisabled = isKeyboardDismissDisabled;
    return _HeroModalContentSlot.claimed(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          HeroModalBackdropLayer(
            route: route,
            variant: variant,
            color: color,
            decoration: decoration,
            motion: resolvedMotion,
          ),
          child,
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HeroBackdropVariant>('variant', variant))
      ..add(FlagProperty('isDismissable', value: isDismissable))
      ..add(
        FlagProperty(
          'isKeyboardDismissDisabled',
          value: isKeyboardDismissDisabled,
        ),
      )
      ..add(FlagProperty('isOpen', value: isOpen, ifTrue: 'open'));
  }
}

/// Paints a modal backdrop for [route]: the [variant] fill (or [color] /
/// [decoration]) and blur, faded with [motion], and dismisses the route
/// when pressed.
class HeroModalBackdropLayer extends StatelessWidget {
  /// Creates a backdrop layer.
  const HeroModalBackdropLayer({
    super.key,
    required this.route,
    required this.motion,
    this.variant = HeroBackdropVariant.opaque,
    this.color,
    this.decoration,
  });

  /// The route the backdrop belongs to.
  final HeroModalRoute<Object?> route;

  /// The fade timing (fully resolved).
  final HeroModalMotion motion;

  /// The fill.
  final HeroBackdropVariant variant;

  /// Replaces the fill color.
  final Color? color;

  /// Replaces the fill.
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Decoration? fill =
        decoration ??
        switch (variant) {
          HeroBackdropVariant.transparent =>
            color == null ? null : BoxDecoration(color: color),
          _ => BoxDecoration(color: color ?? theme.colors.backdrop),
        };
    // `backdrop-blur-md`: blur(12px), a standard deviation of 12.
    final double blur = variant == HeroBackdropVariant.blur
        ? theme.spacing(3)
        : 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: route.handleOutsidePress,
      child: AnimatedBuilder(
        animation: route.animation!,
        builder: (BuildContext context, Widget? child) {
          final double t = motion.progress(route);
          Widget result = fill == null
              ? const SizedBox.expand()
              : Opacity(
                  opacity: t,
                  child: DecoratedBox(
                    decoration: fill,
                    child: const SizedBox.expand(),
                  ),
                );
          if (blur > 0 && t > 0) {
            // A backdrop filter cannot sit below an opacity layer, so the
            // blur radius fades instead.
            result = BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur * t, sigmaY: blur * t),
              child: result,
            );
          }
          return ClipRect(child: result);
        },
      ),
    );
  }
}

/// Whether HeroUI's `sm:` utilities (640 px and up) apply in [context],
/// honouring a pinned [HeroThemeData.density].
bool heroIsSmallBreakpoint(BuildContext context) {
  final HeroThemeData theme = HeroTheme.of(context);
  return switch (theme.density) {
    HeroDensity.touch => false,
    HeroDensity.desktop => true,
    HeroDensity.adaptive =>
      (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= HeroBreakpoints.sm,
  };
}

/// Returns [padding] grown to at least the safe-area insets of [context].
EdgeInsets heroSafePadding(BuildContext context, EdgeInsets padding) {
  final EdgeInsets safe = MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
  return EdgeInsets.fromLTRB(
    math.max(padding.left, safe.left),
    math.max(padding.top, safe.top),
    math.max(padding.right, safe.right),
    math.max(padding.bottom, safe.bottom),
  );
}

/// Pushes [content] (a backdrop widget) in an uncontrolled
/// [HeroModalRoute] and completes with the result it is closed with: the
/// imperative API behind `HeroModal.show`, `HeroAlertDialog.show` and
/// `HeroDrawer.show`.
///
/// The route durations come from [content] when it is a
/// [HeroModalAnimatedLayer]; motion is skipped when the platform asks for
/// reduced motion.
Future<T?> showHeroModalRoute<T>(
  BuildContext context, {
  required Widget content,
  bool useRootNavigator = true,
  RouteSettings? settings,
}) {
  final NavigatorState navigator = Navigator.of(
    context,
    rootNavigator: useRootNavigator,
  );
  final bool reduce = HeroTheme.of(context).motion.shouldReduceMotion(context);
  final HeroModalAnimatedLayer? layer = content is HeroModalAnimatedLayer
      ? content as HeroModalAnimatedLayer
      : null;
  return navigator.push<T>(
    HeroModalRoute<T>(
      builder: (BuildContext context) => content,
      transitionDuration: reduce
          ? Duration.zero
          : (layer?.enterDuration ?? HeroMotion.slow),
      reverseTransitionDuration: reduce
          ? Duration.zero
          : (layer?.exitDuration ?? HeroMotion.fast),
      theme: context.getInheritedWidgetOfExactType<HeroTheme>()?.data,
      textDirection: Directionality.maybeOf(context),
      settings: settings,
    ),
  );
}
