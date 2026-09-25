/// HeroUI's Drawer: a panel that slides in from an edge of the screen.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../modal/modal.dart';

/// The edge a drawer slides in from (`Drawer.Content` `placement`).
///
/// `left` and `right` follow the reading direction like HeroUI's
/// `justify-start` / `justify-end`: in right-to-left layouts a `left`
/// drawer opens from the right edge.
enum HeroDrawerPlacement {
  /// From the top edge.
  top,

  /// From the bottom edge (the default).
  bottom,

  /// From the start edge (left in left-to-right layouts).
  left,

  /// From the end edge (right in left-to-right layouts).
  right;

  /// Whether the drawer is a full-width sheet (top or bottom).
  bool get isVertical => this == top || this == bottom;
}

/// The physical screen edge of a drawer after resolving the text
/// direction.
enum HeroDrawerEdge {
  /// The top edge.
  top,

  /// The bottom edge.
  bottom,

  /// The left edge.
  left,

  /// The right edge.
  right;

  /// Resolves [placement] for [direction].
  static HeroDrawerEdge resolve(
    HeroDrawerPlacement placement,
    TextDirection direction,
  ) {
    final bool rtl = direction == TextDirection.rtl;
    return switch (placement) {
      HeroDrawerPlacement.top => top,
      HeroDrawerPlacement.bottom => bottom,
      HeroDrawerPlacement.left => rtl ? right : left,
      HeroDrawerPlacement.right => rtl ? left : right,
    };
  }

  /// Whether the panel slides vertically.
  bool get isVertical => this == top || this == bottom;

  /// The direction that moves the panel off screen, as a unit offset.
  Offset get outward => switch (this) {
    top => const Offset(0, -1),
    bottom => const Offset(0, 1),
    left => const Offset(-1, 0),
    right => const Offset(1, 0),
  };

  /// Where the panel sits on screen.
  Alignment get alignment => switch (this) {
    top => Alignment.topCenter,
    bottom => Alignment.bottomCenter,
    left => Alignment.centerLeft,
    right => Alignment.centerRight,
  };
}

/// A panel that slides out from an edge of the screen for supplementary
/// content and actions.
///
/// ```dart
/// HeroDrawer(
///   trigger: const HeroButton(
///     variant: HeroButtonVariant.secondary,
///     child: Text('Open Drawer'),
///   ),
///   child: HeroDrawerBackdrop(
///     child: HeroDrawerContent(
///       placement: HeroDrawerPlacement.right,
///       child: HeroDrawerDialog(children: const <Widget>[
///         HeroDrawerHeader(children: <Widget>[
///           HeroDrawerHeading(child: Text('Drawer Title')),
///         ]),
///         HeroDrawerBody(child: Text('Supplementary content.')),
///         HeroDrawerFooter(children: <Widget>[
///           HeroButton(slot: HeroButtonSlot.close, child: Text('Done')),
///         ]),
///       ]),
///     ),
///   ),
/// )
/// ```
///
/// It opens in the shared [HeroModalRoute] (focus trap, Escape, outside
/// press, close buttons, controlled and uncontrolled state). The backdrop
/// fades in over 250 ms and the panel slides in from its edge with
/// `ease-out-fluid` (out over 200 ms). Bottom and top drawers are full
/// width with rounded inner corners and at most 85% of the screen tall;
/// left and right drawers are full height and 320 wide (384 from 640 px).
///
/// When dismissable, the panel can be dragged towards its edge from
/// anywhere but the body: past 30% of its size, or with a flick faster
/// than 0.5 px/ms, it closes and keeps sliding from where it was released;
/// otherwise it springs back over 300 ms.
class HeroDrawer extends StatelessWidget {
  /// Creates a drawer.
  const HeroDrawer({
    super.key,
    required this.child,
    this.trigger,
    this.isOpen,
    this.defaultOpen = false,
    this.onOpenChanged,
    this.controller,
    this.useRootNavigator = true,
  });

  /// The overlay: a [HeroDrawerBackdrop] holding a [HeroDrawerContent].
  final Widget child;

  /// The widget that opens the drawer when pressed.
  final Widget? trigger;

  /// Controlled open state; defaults to the backdrop's `isOpen`.
  final bool? isOpen;

  /// Initial open state when uncontrolled.
  final bool defaultOpen;

  /// Called when the open state should change.
  final ValueChanged<bool>? onOpenChanged;

  /// External open state (`state`).
  final HeroOverlayController? controller;

  /// Whether to open in the root navigator.
  final bool useRootNavigator;

  /// Opens a drawer and completes with the value it is closed with.
  ///
  /// [builder] returns the [HeroDrawerDialog]; its `close` argument closes
  /// the drawer.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext context, VoidCallback close) builder,
    HeroDrawerPlacement placement = HeroDrawerPlacement.bottom,
    HeroBackdropVariant backdropVariant = HeroBackdropVariant.opaque,
    bool isDismissable = true,
    bool isKeyboardDismissDisabled = false,
    bool useRootNavigator = true,
    RouteSettings? settings,
  }) {
    return showHeroModalRoute<T>(
      context,
      useRootNavigator: useRootNavigator,
      settings: settings,
      content: HeroDrawerBackdrop(
        variant: backdropVariant,
        isDismissable: isDismissable,
        isKeyboardDismissDisabled: isKeyboardDismissDisabled,
        child: HeroDrawerContent(
          placement: placement,
          child: Builder(
            builder: (BuildContext context) => builder(
              context,
              () => HeroDialogScope.maybeOf(context)?.close(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HeroModal(
      trigger: trigger,
      isOpen: isOpen,
      defaultOpen: defaultOpen,
      onOpenChanged: onOpenChanged,
      controller: controller,
      useRootNavigator: useRootNavigator,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('isOpen', value: isOpen, ifTrue: 'open'))
      ..add(FlagProperty('defaultOpen', value: defaultOpen));
  }
}

/// A custom pressable that opens a drawer (`Drawer.Trigger`); see
/// [HeroModalTrigger].
class HeroDrawerTrigger extends HeroModalTrigger {
  /// Creates a trigger.
  const HeroDrawerTrigger({
    super.key,
    super.child,
    super.builder,
    super.onPressed,
    super.borderRadius,
    super.isDisabled,
    super.semanticLabel,
  });
}

/// The backdrop of a drawer (`Drawer.Backdrop`).
///
/// Like [HeroModalBackdrop] with the drawer's fade (250 ms in, 200 ms out,
/// `ease-out-fluid`). [isDismissable] also enables dragging the panel
/// closed.
class HeroDrawerBackdrop extends HeroModalBackdrop {
  /// Creates a backdrop.
  const HeroDrawerBackdrop({
    super.key,
    required super.child,
    super.variant,
    super.isDismissable,
    super.isKeyboardDismissDisabled,
    super.isOpen,
    super.onOpenChanged,
    super.color,
    super.decoration,
    super.motion,
    super.useRootNavigator,
  });

  /// HeroUI's drawer backdrop and panel timing.
  static const HeroModalMotion drawerMotion = HeroModalMotion(
    enterDuration: HeroMotion.slow,
    exitDuration: HeroMotion.medium,
    enterCurve: HeroMotion.easeOutFluid,
    exitCurve: HeroMotion.easeOutFluid,
  );

  @override
  HeroModalMotion get resolvedMotion => motion.withDefaults(drawerMotion);
}

/// Placement information a [HeroDrawerContent] shares with its dialog.
class HeroDrawerScope extends InheritedWidget {
  /// Creates the scope.
  const HeroDrawerScope({
    super.key,
    required this.placement,
    required this.edge,
    required super.child,
  });

  /// The requested placement.
  final HeroDrawerPlacement placement;

  /// The physical edge.
  final HeroDrawerEdge edge;

  /// The nearest scope, or null.
  static HeroDrawerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroDrawerScope>();

  @override
  bool updateShouldNotify(HeroDrawerScope oldWidget) =>
      placement != oldWidget.placement || edge != oldWidget.edge;
}

/// Positions the drawer panel against an edge (`Drawer.Content`) and slides
/// it in and out.
class HeroDrawerContent extends StatelessWidget
    implements HeroModalAnimatedLayer {
  /// Creates the content layer.
  const HeroDrawerContent({
    super.key,
    required this.child,
    this.placement = HeroDrawerPlacement.bottom,
    this.motion = const HeroModalMotion(),
  });

  /// The panel, a [HeroDrawerDialog].
  final Widget child;

  /// The edge the drawer slides from.
  final HeroDrawerPlacement placement;

  /// Overrides of the slide timing.
  final HeroModalMotion motion;

  HeroModalMotion get _motion =>
      motion.withDefaults(HeroDrawerBackdrop.drawerMotion);

  @override
  Duration get enterDuration => _motion.enterDuration!;

  @override
  Duration get exitDuration => _motion.exitDuration!;

  @override
  Widget build(BuildContext context) {
    final HeroModalRoute<Object?>? route = HeroModalRouteScope.maybeOf(context);
    final HeroDrawerEdge edge = HeroDrawerEdge.resolve(
      placement,
      Directionality.of(context),
    );
    Widget panel = HeroDrawerScope(
      placement: placement,
      edge: edge,
      child: child,
    );
    if (route != null) {
      final HeroModalMotion resolved = _motion;
      panel = AnimatedBuilder(
        animation: route.animation!,
        child: panel,
        builder: (BuildContext context, Widget? child) => FractionalTranslation(
          translation: edge.outward * (1 - resolved.progress(route)),
          child: child,
        ),
      );
    }
    // The visual viewport ends at the keyboard.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0,
      ),
      child: Align(alignment: edge.alignment, child: panel),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HeroDrawerPlacement>('placement', placement));
  }
}

/// The drawer panel (`Drawer.Dialog`).
///
/// `overlay` surface with the overlay shadow and 24 px padding. Top and
/// bottom drawers span the width, grow with their content up to 85% of the
/// screen height and round their inner corners (16 px); left and right
/// drawers span the height and are 320 wide (384 from 640 px, at most 85%
/// of the screen width). The body takes the remaining height and scrolls.
///
/// Its [children] are the parts ([HeroDrawerHandle],
/// [HeroDrawerCloseTrigger], [HeroDrawerHeader], [HeroDrawerBody],
/// [HeroDrawerFooter]); [builder] builds them with a `close` function.
class HeroDrawerDialog extends StatefulWidget {
  /// Creates a drawer panel.
  const HeroDrawerDialog({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.role = SemanticsRole.dialog,
    this.semanticLabel,
    this.padding,
    this.backgroundColor,
    this.side = BorderSide.none,
    this.shadows,
    this.width,
  });

  /// The parts of the drawer.
  final List<Widget> children;

  /// Builds the parts with a `close` function; replaces [children].
  final HeroDialogPartsBuilder? builder;

  /// The semantics role.
  final SemanticsRole role;

  /// Accessibility label; defaults to the heading.
  final String? semanticLabel;

  /// Overrides the 24 px padding.
  final EdgeInsets? padding;

  /// Overrides the `overlay` fill.
  final Color? backgroundColor;

  /// A border on the edge facing the page (e.g. `border-l` on a right
  /// drawer).
  final BorderSide side;

  /// Replaces the overlay shadow.
  final List<BoxShadow>? shadows;

  /// Overrides the width of left and right drawers.
  final double? width;

  /// Drag distance before a drag starts (`DRAG_THRESHOLD`).
  static const double dragThreshold = 8;

  /// Fraction of the panel size past which a release dismisses
  /// (`DISMISS_FRACTION`).
  static const double dismissFraction = 0.3;

  /// Release velocity, in logical pixels per millisecond, that dismisses
  /// (`VELOCITY_THRESHOLD`).
  static const double velocityThreshold = 0.5;

  @override
  State<HeroDrawerDialog> createState() => _HeroDrawerDialogState();
}

class _HeroDrawerDialogState extends State<HeroDrawerDialog>
    with SingleTickerProviderStateMixin {
  /// Snap-back after a released drag: 300 ms `ease-out-fluid`.
  late final AnimationController _snap = AnimationController(
    vsync: this,
    duration: HeroMotion.slower,
  )..addListener(_handleSnap);

  /// How far the panel is dragged towards its edge, in logical pixels.
  final ValueNotifier<double> _drag = ValueNotifier<double>(0);
  double _snapFrom = 0;
  bool _dismissing = false;

  @override
  void dispose() {
    _snap.dispose();
    _drag.dispose();
    super.dispose();
  }

  void _handleSnap() {
    _drag.value =
        _snapFrom * (1 - HeroMotion.easeOutFluid.transform(_snap.value));
  }

  /// The edge and route of the last build, used by the gesture callbacks.
  HeroDrawerEdge _edge = HeroDrawerEdge.bottom;
  HeroModalRoute<Object?>? _route;

  bool _canStartAt(Offset globalPosition) {
    final RenderObject? box = context.findRenderObject();
    if (box is! RenderBox || !box.attached) return false;
    final BoxHitTestResult result = BoxHitTestResult();
    box.hitTest(result, position: box.globalToLocal(globalPosition));
    // The body scrolls; it never starts a drag.
    return !result.path.any(
      (HitTestEntry entry) => entry.target is _RenderHeroDrawerNoDrag,
    );
  }

  void _handleStart(DragStartDetails details) {
    _snap.stop();
    _dismissing = false;
  }

  void _handleUpdate(DragUpdateDetails details) {
    final Offset outward = _edge.outward;
    final double delta =
        details.delta.dx * outward.dx + details.delta.dy * outward.dy;
    // Only towards the edge the drawer came from.
    _drag.value = math.max(0, _drag.value + delta);
  }

  void _handleEnd(DragEndDetails details) {
    final Size size = context.size ?? Size.zero;
    final double extent = _edge.isVertical ? size.height : size.width;
    final Offset outward = _edge.outward;
    final double velocity =
        (details.velocity.pixelsPerSecond.dx * outward.dx +
            details.velocity.pixelsPerSecond.dy * outward.dy) /
        1000;
    final bool dismiss =
        _drag.value > extent * HeroDrawerDialog.dismissFraction ||
        velocity > HeroDrawerDialog.velocityThreshold;
    if (dismiss) {
      // Keep the offset: the exit slide continues from here.
      _dismissing = true;
      HeroDialogScope.maybeOf(context)?.close();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // A controlled owner may keep the drawer open.
        if (mounted && _dismissing && !(_route?.isExiting ?? false)) {
          _dismissing = false;
          _snapBack();
        }
      });
      SchedulerBinding.instance.ensureVisualUpdate();
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    if (_drag.value == 0) return;
    _snapFrom = _drag.value;
    if (HeroTheme.of(context).motion.shouldReduceMotion(context)) {
      _drag.value = 0;
    } else {
      _snap.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroModalRoute<Object?>? route = HeroModalRouteScope.maybeOf(context);
    final HeroDrawerEdge edge =
        HeroDrawerScope.maybeOf(context)?.edge ?? HeroDrawerEdge.bottom;
    _edge = edge;
    _route = route;
    final bool vertical = edge.isVertical;
    final bool sm = heroIsSmallBreakpoint(context);
    final Radius corner = Radius.circular(
      math.min(theme.spacing(8), theme.radii.xl2),
    );
    final BorderRadius radius = switch (edge) {
      HeroDrawerEdge.bottom => BorderRadius.vertical(top: corner),
      HeroDrawerEdge.top => BorderRadius.vertical(bottom: corner),
      _ => BorderRadius.zero,
    };
    // Safe-area insets on the screen edges the panel touches.
    final EdgeInsets safe =
        MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    EdgeInsets padding = widget.padding ?? EdgeInsets.all(theme.spacing(6));
    if (widget.padding == null && edge == HeroDrawerEdge.top) {
      padding = padding.copyWith(bottom: theme.spacing(2));
    }
    padding += switch (edge) {
      HeroDrawerEdge.bottom => EdgeInsets.fromLTRB(
        safe.left,
        0,
        safe.right,
        safe.bottom,
      ),
      HeroDrawerEdge.top => EdgeInsets.fromLTRB(
        safe.left,
        safe.top,
        safe.right,
        0,
      ),
      HeroDrawerEdge.left => EdgeInsets.fromLTRB(
        safe.left,
        safe.top,
        0,
        safe.bottom,
      ),
      HeroDrawerEdge.right => EdgeInsets.fromLTRB(
        0,
        safe.top,
        safe.right,
        safe.bottom,
      ),
    };
    final List<Widget> parts =
        widget.builder?.call(
          context,
          () => HeroDialogScope.maybeOf(context)?.close(),
        ) ??
        widget.children;

    final bool dismissable = route?.isDismissable ?? true;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool bounded = constraints.hasBoundedHeight;
        final BoxConstraints size;
        if (vertical) {
          size = BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            maxHeight: bounded ? constraints.maxHeight * 0.85 : double.infinity,
          );
        } else {
          final double width = math.min(
            widget.width ?? theme.spacing(sm ? 96 : 80),
            constraints.maxWidth * 0.85,
          );
          size = BoxConstraints.tightFor(
            width: width,
            height: bounded ? constraints.maxHeight : null,
          );
        }

        Widget panel = HeroDialogLayout(
          padding: padding,
          scrollableBody: bounded,
          fillHeight: !vertical && bounded,
          children: parts,
        );
        panel = DefaultTextStyle(
          style: theme.typography.base.copyWith(color: theme.colors.foreground),
          child: IconTheme(
            data: IconThemeData(color: theme.colors.foreground),
            child: panel,
          ),
        );
        if (widget.side.style != BorderStyle.none) {
          panel = CustomPaint(
            foregroundPainter: _HeroDrawerEdgePainter(
              edge: edge,
              side: widget.side,
            ),
            child: panel,
          );
        }
        panel = HeroOverlaySurface(
          shape: theme.shape(radius),
          color: widget.backgroundColor,
          shadows: widget.shadows,
          child: panel,
        );
        panel = Semantics(
          role: widget.role,
          scopesRoute: true,
          explicitChildNodes: true,
          namesRoute: widget.semanticLabel != null ? true : null,
          label: widget.semanticLabel,
          child: panel,
        );
        panel = ConstrainedBox(constraints: size, child: panel);
        panel = ValueListenableBuilder<double>(
          valueListenable: _drag,
          child: panel,
          builder: (BuildContext context, double drag, Widget? child) =>
              Transform.translate(offset: edge.outward * drag, child: child),
        );
        return RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          gestures: <Type, GestureRecognizerFactory>{
            if (dismissable && vertical)
              _HeroDrawerVerticalDrag:
                  GestureRecognizerFactoryWithHandlers<_HeroDrawerVerticalDrag>(
                    () => _HeroDrawerVerticalDrag(canStartAt: _canStartAt),
                    _configure,
                  ),
            if (dismissable && !vertical)
              _HeroDrawerHorizontalDrag:
                  GestureRecognizerFactoryWithHandlers<
                    _HeroDrawerHorizontalDrag
                  >(
                    () => _HeroDrawerHorizontalDrag(canStartAt: _canStartAt),
                    _configure,
                  ),
          },
          child: panel,
        );
      },
    );
  }

  void _configure(DragGestureRecognizer recognizer) {
    recognizer
      ..dragStartBehavior = DragStartBehavior.down
      ..gestureSettings = const DeviceGestureSettings(
        touchSlop: HeroDrawerDialog.dragThreshold,
      )
      ..onStart = _handleStart
      ..onUpdate = _handleUpdate
      ..onEnd = _handleEnd
      ..onCancel = _snapBack;
  }
}

class _HeroDrawerVerticalDrag extends VerticalDragGestureRecognizer {
  _HeroDrawerVerticalDrag({required this.canStartAt});

  final bool Function(Offset globalPosition) canStartAt;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      canStartAt(event.position) && super.isPointerAllowed(event);
}

class _HeroDrawerHorizontalDrag extends HorizontalDragGestureRecognizer {
  _HeroDrawerHorizontalDrag({required this.canStartAt});

  final bool Function(Offset globalPosition) canStartAt;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      canStartAt(event.position) && super.isPointerAllowed(event);
}

/// Paints a border on the edge of the panel facing the page.
class _HeroDrawerEdgePainter extends CustomPainter {
  const _HeroDrawerEdgePainter({required this.edge, required this.side});

  final HeroDrawerEdge edge;
  final BorderSide side;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = side.width;
    final Rect line = switch (edge) {
      HeroDrawerEdge.right => Rect.fromLTWH(0, 0, w, size.height),
      HeroDrawerEdge.left => Rect.fromLTWH(size.width - w, 0, w, size.height),
      HeroDrawerEdge.bottom => Rect.fromLTWH(0, 0, size.width, w),
      HeroDrawerEdge.top => Rect.fromLTWH(0, size.height - w, size.width, w),
    };
    canvas.drawRect(line, Paint()..color = side.color);
  }

  @override
  bool shouldRepaint(_HeroDrawerEdgePainter oldDelegate) =>
      oldDelegate.edge != edge || oldDelegate.side != side;
}

/// The drag handle of a drawer (`Drawer.Handle`): a 36 × 4 bar in the
/// `separator` color, centered, with 8 px below it (none in top drawers,
/// where it sits at the bottom). Hidden from assistive technologies.
class HeroDrawerHandle extends HeroDialogPart {
  /// Creates a handle.
  const HeroDrawerHandle({super.key, this.color});

  /// Overrides the bar color.
  final Color? color;

  @override
  HeroDialogPartKind get kind => HeroDialogPartKind.handle;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool top =
        HeroDrawerScope.maybeOf(context)?.edge == HeroDrawerEdge.top;
    return ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.only(bottom: top ? 0 : theme.spacing(2)),
        child: Center(
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: color ?? theme.colors.separator,
              shape: theme.shapeAll(theme.radii.xs),
            ),
            child: SizedBox(width: theme.spacing(9), height: theme.spacing(1)),
          ),
        ),
      ),
    );
  }
}

/// The title area of a drawer (`Drawer.Header`); see [HeroModalHeader].
class HeroDrawerHeader extends HeroModalHeader {
  /// Creates a header.
  const HeroDrawerHeader({super.key, super.children, super.crossAxisAlignment});
}

/// The title of a drawer (`Drawer.Heading`); see [HeroModalHeading].
class HeroDrawerHeading extends HeroModalHeading {
  /// Creates a heading.
  const HeroDrawerHeading({super.key, required super.child, super.textAlign});
}

/// The main content of a drawer (`Drawer.Body`): 14 px `muted` text that
/// takes the remaining height and scrolls. Dragging inside it scrolls
/// instead of moving the drawer.
class HeroDrawerBody extends HeroModalBody {
  /// Creates a body.
  const HeroDrawerBody({super.key, super.child, super.children, super.padding});

  @override
  Widget build(BuildContext context) =>
      _HeroDrawerNoDrag(child: super.build(context));
}

/// The actions of a drawer (`Drawer.Footer`); see [HeroModalFooter].
class HeroDrawerFooter extends HeroModalFooter {
  /// Creates a footer.
  const HeroDrawerFooter({super.key, super.children, super.child});
}

/// The close button of a drawer (`Drawer.CloseTrigger`); see
/// [HeroModalCloseTrigger].
class HeroDrawerCloseTrigger extends HeroModalCloseTrigger {
  /// Creates a close trigger.
  const HeroDrawerCloseTrigger({
    super.key,
    super.child,
    super.onPressed,
    super.semanticLabel,
  });
}

/// Marks an area where a drawer drag cannot start.
class _HeroDrawerNoDrag extends SingleChildRenderObjectWidget {
  const _HeroDrawerNoDrag({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeroDrawerNoDrag();
}

class _RenderHeroDrawerNoDrag extends RenderProxyBox {}
