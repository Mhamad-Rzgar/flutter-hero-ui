/// HeroUI's Popover: rich content in a floating dialog anchored to a
/// trigger.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../modal/modal.dart' show HeroOverlaySurface;
import '../surface/surface.dart' show HeroSurfaceScope, HeroSurfaceVariant;
import '../tooltip/overlay_arrow.dart';

/// The state handed to [HeroPopoverContent.builder].
@immutable
class HeroPopoverRenderState {
  /// Creates a render state.
  const HeroPopoverRenderState({required this.placement});

  /// The side of the trigger the popover ended up on (`data-placement`),
  /// after flipping.
  final HeroOverlaySide placement;

  @override
  bool operator ==(Object other) =>
      other is HeroPopoverRenderState && other.placement == placement;

  @override
  int get hashCode => placement.hashCode;
}

/// Builds a custom popover around the styled [popover] (`render`).
typedef HeroPopoverContentBuilder =
    Widget Function(
      BuildContext context,
      HeroPopoverRenderState state,
      Widget popover,
    );

/// Builds dialog content with a callback that closes the popover.
typedef HeroPopoverDialogBuilder =
    Widget Function(BuildContext context, VoidCallback close);

/// A popover (`Popover`): pressing the trigger [child] toggles [content], a
/// floating dialog placed next to it.
///
/// ```dart
/// HeroPopover(
///   content: const HeroPopoverContent(
///     child: HeroPopoverDialog(
///       children: [
///         HeroPopoverHeading(child: Text('Popover Title')),
///         Text('This is the popover content.'),
///       ],
///     ),
///   ),
///   child: const HeroButton(child: Text('Click me')),
/// )
/// ```
///
/// Any button (or [HeroPopoverTrigger]) works as the trigger; it is
/// announced as expanded while the popover is open. Pressing outside or
/// pressing Escape closes the popover, and so does a
/// `HeroButton(slot: HeroButtonSlot.close)` inside it.
///
/// By default the popover is modal (React Aria's `isNonModal: false`): the
/// page behind does not react to presses, focus moves into the popover when
/// it opens, Tab stays inside it, and focus returns to the trigger when it
/// closes.
///
/// The open state is controlled by [controller], or by [isOpen] and
/// [onOpenChanged], or kept internally (starting at [defaultOpen]).
class HeroPopover extends StatefulWidget {
  /// Creates a popover.
  const HeroPopover({
    super.key,
    required this.child,
    required this.content,
    this.isOpen,
    this.defaultOpen = false,
    this.onOpenChanged,
    this.controller,
  });

  /// The trigger.
  final Widget child;

  /// The popover: a [HeroPopoverContent], or any widget wrapped in one.
  final Widget content;

  /// Whether the popover is open (controlled).
  final bool? isOpen;

  /// Whether the popover is initially open (uncontrolled).
  final bool defaultOpen;

  /// Called when the popover should open or close.
  final ValueChanged<bool>? onOpenChanged;

  /// External open state; takes precedence over [isOpen].
  final HeroOverlayController? controller;

  @override
  State<HeroPopover> createState() => _HeroPopoverState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<bool>('isOpen', isOpen, defaultValue: null),
    );
  }
}

class _HeroPopoverState extends State<HeroPopover> {
  late bool _uncontrolledOpen = widget.defaultOpen;

  bool get _isOpen =>
      widget.controller?.isOpen ?? widget.isOpen ?? _uncontrolledOpen;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleController);
  }

  @override
  void didUpdateWidget(HeroPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleController);
      widget.controller?.addListener(_handleController);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleController);
    super.dispose();
  }

  void _handleController() {
    if (mounted) setState(() {});
  }

  void _setOpen(bool value) {
    if (!mounted || value == _isOpen) return;
    final HeroOverlayController? controller = widget.controller;
    if (controller != null) {
      controller.setOpen(value);
    } else if (widget.isOpen == null) {
      setState(() => _uncontrolledOpen = value);
    }
    widget.onOpenChanged?.call(value);
  }

  void _close() => _setOpen(false);

  HeroPopoverContent get _content {
    final Widget content = widget.content;
    if (content is HeroPopoverContent) return content;
    return HeroPopoverContent(child: content);
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroPopoverContent content = _content;
    final bool open = _isOpen;
    return HeroAnchoredOverlay(
      isOpen: open,
      onDismiss: _close,
      placement: content.placement,
      offset: content.offset ?? theme.spacing(2),
      crossOffset: content.crossOffset,
      shouldFlip: content.shouldFlip,
      containerPadding: content.containerPadding ?? theme.spacing(3),
      isModal: !content.isNonModal,
      enterDuration: theme.motion.resolve(context, HeroMotion.normal),
      exitDuration: theme.motion.resolve(context, HeroMotion.fast),
      overlayBuilder: (BuildContext context, HeroOverlayGeometry geometry) {
        return _HeroPopoverScope(
          geometry: geometry,
          close: _close,
          child: HeroDialogScope(
            close: ([Object? _]) => _close(),
            child: content,
          ),
        );
      },
      // Opaque so presses on the trigger count as inside the popover's tap
      // region (interactive widgets do not report hits to their ancestors).
      child: Listener(
        behavior: HitTestBehavior.opaque,
        child: HeroPressResponder(
          onPressed: () => _setOpen(!open),
          isExpanded: open,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Hands the resolved geometry and the close callback to the content.
class _HeroPopoverScope extends InheritedWidget {
  const _HeroPopoverScope({
    required this.geometry,
    required this.close,
    required super.child,
  });

  final HeroOverlayGeometry geometry;
  final VoidCallback close;

  static _HeroPopoverScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroPopoverScope>();

  @override
  bool updateShouldNotify(_HeroPopoverScope oldWidget) =>
      oldWidget.geometry != geometry || oldWidget.close != close;
}

/// Lets a [HeroPopoverArrow] anywhere in the content register with it.
class _HeroPopoverArrowSlot extends InheritedWidget {
  const _HeroPopoverArrowSlot({required this.owner, required super.child});

  final _HeroPopoverContentState owner;

  @override
  bool updateShouldNotify(_HeroPopoverArrowSlot oldWidget) =>
      oldWidget.owner != owner;
}

/// The floating panel of a popover (`Popover.Content`): an `overlay`
/// surface with 14 px text, radius `min(32px, --radius-3xl)` (24 by
/// default) and the overlay shadow, placed [offset] (8) from the trigger.
///
/// Put a [HeroPopoverDialog] inside for the 16 px padded dialog, and a
/// [HeroPopoverArrow] anywhere inside to point at the trigger.
class HeroPopoverContent extends StatefulWidget {
  /// Creates popover content.
  const HeroPopoverContent({
    super.key,
    required this.child,
    this.placement = HeroPlacement.bottom,
    this.offset,
    this.crossOffset = 0,
    this.shouldFlip = true,
    this.containerPadding,
    this.isNonModal = false,
    this.constraints,
    this.backgroundColor,
    this.borderRadius,
    this.side = BorderSide.none,
    this.shadows,
    this.backdropBlur = 0,
    this.padding,
    this.clipBehavior = Clip.none,
    this.builder,
  });

  /// The content, usually a [HeroPopoverDialog].
  final Widget child;

  /// Preferred placement; flips when there is not enough room.
  final HeroPlacement placement;

  /// Distance from the trigger; defaults to 8.
  final double? offset;

  /// Shift along the trigger edge.
  final double crossOffset;

  /// Whether to flip to the opposite side when there is not enough room.
  final bool shouldFlip;

  /// Minimum distance to the edges of the screen; defaults to 12.
  final double? containerPadding;

  /// Whether the page behind stays interactive (`isNonModal`). Pressing
  /// outside still closes the popover.
  final bool isNonModal;

  /// Size limits of the panel (`w-*` / `max-w-*`).
  final BoxConstraints? constraints;

  /// Fill color; defaults to `overlay`. It also fills the arrow.
  final Color? backgroundColor;

  /// Corner radius; defaults to `min(32px, --radius-3xl)`.
  final double? borderRadius;

  /// Border drawn inside the panel.
  final BorderSide side;

  /// Replaces the overlay drop shadows.
  final List<BoxShadow>? shadows;

  /// Blur of what is behind a translucent panel (`backdrop-blur-*`).
  final double backdropBlur;

  /// Inner padding; defaults to none (the dialog is padded).
  final EdgeInsetsGeometry? padding;

  /// How the content is clipped to the panel (`overflow-hidden`); defaults
  /// to no clipping, like HeroUI.
  final Clip clipBehavior;

  /// Wraps the styled popover (`render`).
  final HeroPopoverContentBuilder? builder;

  @override
  State<HeroPopoverContent> createState() => _HeroPopoverContentState();
}

class _HeroPopoverContentState extends State<HeroPopoverContent> {
  final FocusNode _focusNode = FocusNode(
    debugLabel: 'HeroPopoverContent',
    skipTraversal: true,
  );
  _HeroPopoverArrowState? _arrow;
  bool _rebuildScheduled = false;

  @override
  void initState() {
    super.initState();
    // Focus moves into the popover when it opens, unless a descendant
    // autofocuses; that request is applied first.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scheduleMicrotask(() {
        if (mounted && !_focusNode.hasFocus) _focusNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _register(_HeroPopoverArrowState arrow) {
    _arrow = arrow;
    _scheduleRebuild();
  }

  void _unregister(_HeroPopoverArrowState arrow) {
    if (_arrow != arrow) return;
    _arrow = null;
    _scheduleRebuild();
  }

  /// Arrows register while the tree builds; paint them in the next frame.
  void _scheduleRebuild() {
    if (_rebuildScheduled) return;
    _rebuildScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _rebuildScheduled = false;
      if (mounted) setState(() {});
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroPopoverScope? scope = _HeroPopoverScope.maybeOf(context);
    final HeroOverlayGeometry? geometry = scope?.geometry;
    final HeroOverlaySide placement =
        geometry?.side ??
        resolveHeroPlacementSide(
          widget.placement,
          Directionality.maybeOf(context) ?? TextDirection.ltr,
        );
    final Color fill = widget.backgroundColor ?? theme.colors.overlay;
    final ShapeBorder shape = theme.shapeAll(
      widget.borderRadius ?? math.min(theme.spacing(8), theme.radii.xl3),
    );

    Widget body = widget.child;
    final EdgeInsetsGeometry? padding = widget.padding;
    if (padding != null) body = Padding(padding: padding, child: body);
    // Scrolls when the space next to the trigger is too short.
    body = SingleChildScrollView(primary: false, child: body);
    body = DefaultTextStyle(
      style: theme.typography.sm.copyWith(
        color: theme.colors.overlayForeground,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: theme.colors.overlayForeground),
        child: body,
      ),
    );
    body = _HeroPopoverArrowSlot(
      owner: this,
      child: HeroSurfaceScope(
        variant: HeroSurfaceVariant.standard,
        child: body,
      ),
    );
    Widget popover = HeroOverlaySurface(
      shape: shape,
      color: fill,
      shadows: widget.shadows,
      side: widget.side,
      backdropBlur: widget.backdropBlur,
      clipBehavior: widget.clipBehavior,
      child: body,
    );
    final BoxConstraints? constraints = widget.constraints;
    if (constraints != null) {
      popover = ConstrainedBox(constraints: constraints, child: popover);
    }
    final _HeroPopoverArrowState? arrow = _arrow;
    if (arrow != null && geometry != null) {
      popover = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          popover,
          HeroOverlayArrow.positioned(
            geometry: geometry,
            extent: theme.spacing(3),
            arrow: HeroOverlayArrow(
              side: geometry.side,
              color: fill,
              child: arrow.widget.child,
            ),
          ),
        ],
      );
    }
    popover = Focus(focusNode: _focusNode, child: popover);
    final HeroPopoverContentBuilder? builder = widget.builder;
    if (builder != null) {
      popover = builder(
        context,
        HeroPopoverRenderState(placement: placement),
        popover,
      );
    }
    return popover;
  }
}

/// The dialog inside a popover (`Popover.Dialog`): 16 px padding, announced
/// as a dialog named by its [HeroPopoverHeading].
class HeroPopoverDialog extends StatelessWidget {
  /// Creates a popover dialog from [children] laid out in a column, or
  /// from [builder].
  const HeroPopoverDialog({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.semanticLabel,
  });

  /// The content, stacked vertically.
  final List<Widget> children;

  /// Builds the content with a callback that closes the popover; replaces
  /// [children].
  final HeroPopoverDialogBuilder? builder;

  /// Inner padding; defaults to 16.
  final EdgeInsetsGeometry? padding;

  /// Horizontal alignment of [children].
  final CrossAxisAlignment crossAxisAlignment;

  /// Accessibility label when there is no heading.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroPopoverDialogBuilder? builder = this.builder;
    final Widget content = builder != null
        ? builder(context, _HeroPopoverScope.maybeOf(context)?.close ?? () {})
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment,
            children: children,
          );
    return Semantics(
      role: SemanticsRole.dialog,
      scopesRoute: true,
      explicitChildNodes: true,
      namesRoute: semanticLabel != null ? true : null,
      label: semanticLabel,
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.spacing(4)),
        child: content,
      ),
    );
  }
}

/// The title of a popover (`Popover.Heading`): medium weight. It names the
/// dialog for assistive technologies.
class HeroPopoverHeading extends StatelessWidget {
  /// Creates a heading.
  const HeroPopoverHeading({super.key, required this.child, this.style});

  /// The title, usually a [Text].
  final Widget child;

  /// Text style merged over the default.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      namesRoute: true,
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontWeight: HeroTypography.medium).merge(style),
        child: child,
      ),
    );
  }
}

/// The arrow of a popover (`Popover.Arrow`): HeroUI's 12 × 12 curved
/// triangle filled with the popover color, pointing at the trigger.
///
/// Place it anywhere inside [HeroPopoverContent]; it takes no space where
/// it is and is drawn on the edge of the popover that faces the trigger.
/// Pass a [child] to draw a custom shape (pointing down; it is rotated for
/// the other placements).
class HeroPopoverArrow extends StatefulWidget {
  /// Creates a popover arrow.
  const HeroPopoverArrow({super.key, this.child});

  /// A custom shape drawn pointing down.
  final Widget? child;

  @override
  State<HeroPopoverArrow> createState() => _HeroPopoverArrowState();
}

class _HeroPopoverArrowState extends State<HeroPopoverArrow> {
  _HeroPopoverContentState? _owner;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _HeroPopoverContentState? owner = context
        .dependOnInheritedWidgetOfExactType<_HeroPopoverArrowSlot>()
        ?.owner;
    if (owner == _owner) return;
    _owner?._unregister(this);
    _owner = owner;
    owner?._register(this);
  }

  @override
  void didUpdateWidget(HeroPopoverArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) _owner?._scheduleRebuild();
  }

  @override
  void dispose() {
    _owner?._unregister(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Makes any content a popover trigger (`Popover.Trigger`): pressable with
/// the pointer cursor, focusable with a focus ring, announced as a button,
/// and dimmed when disabled.
class HeroPopoverTrigger extends StatelessWidget {
  /// Creates a popover trigger.
  const HeroPopoverTrigger({
    super.key,
    required this.child,
    this.onPressed,
    this.isDisabled = false,
    this.shape,
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  });

  /// The content.
  final Widget child;

  /// Called when pressed, before the popover toggles.
  final VoidCallback? onPressed;

  /// Whether the trigger is disabled.
  final bool isDisabled;

  /// Outline of the focus ring; defaults to a rectangle around [child].
  final ShapeBorder? shape;

  /// Accessibility label (`aria-label`).
  final String? semanticsLabel;

  /// Optional externally managed focus node.
  final FocusNode? focusNode;

  /// Whether to request focus when first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroInteractable(
      onPressed: onPressed,
      isDisabled: isDisabled,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticsLabel: semanticsLabel,
      child: child,
      builder:
          (BuildContext context, HeroInteractionState state, Widget? child) {
            return HeroFocusRing(
              visible: state.isFocusVisible,
              shape: shape ?? theme.shapeAll(0),
              child: HeroDisabledOpacity(disabled: isDisabled, child: child!),
            );
          },
    );
  }
}
