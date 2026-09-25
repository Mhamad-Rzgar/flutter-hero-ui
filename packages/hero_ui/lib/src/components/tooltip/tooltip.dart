/// HeroUI's Tooltip: a short label shown next to a trigger on hover or
/// keyboard focus.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../modal/modal.dart' show HeroOverlaySurface;
import 'overlay_arrow.dart';

export 'overlay_arrow.dart';

/// What opens a [HeroTooltip] (React Aria's `trigger`).
enum HeroTooltipTriggerMode {
  /// Hovering the trigger (after the delay), keyboard focus and, on touch
  /// screens, a long press.
  hover,

  /// Keyboard focus only.
  focus,
}

/// The state handed to [HeroTooltipContent.builder].
@immutable
class HeroTooltipRenderState {
  /// Creates a render state.
  const HeroTooltipRenderState({required this.placement});

  /// The side of the trigger the tooltip ended up on (`data-placement`),
  /// after flipping.
  final HeroOverlaySide placement;

  @override
  bool operator ==(Object other) =>
      other is HeroTooltipRenderState && other.placement == placement;

  @override
  int get hashCode => placement.hashCode;
}

/// Builds a custom tooltip around the styled [tooltip] (`render`).
typedef HeroTooltipContentBuilder =
    Widget Function(
      BuildContext context,
      HeroTooltipRenderState state,
      Widget tooltip,
    );

/// A tooltip (`Tooltip`): shows [content] next to the trigger [child] when
/// it is hovered or focused with the keyboard.
///
/// ```dart
/// HeroTooltip(
///   content: const Text('This is a tooltip'),
///   child: HeroButton(onPressed: () {}, child: const Text('Hover me')),
/// )
/// ```
///
/// Behaviour follows React Aria's `TooltipTrigger`:
///
/// * a mouse hovering the trigger opens it after [delay] (the theme's
///   `--tooltip-delay`, 1500 ms) and leaving closes it after [closeDelay]
///   (`--tooltip-close-delay`, 500 ms). The pointer can move onto the
///   tooltip without closing it;
/// * keyboard focus opens it at once and blur closes it;
/// * pressing the trigger, pressing Escape or pressing outside closes it;
/// * once a tooltip is open, other tooltips open at once until
///   [warmUpCooldown] after the last one closed (the global warm-up), and
///   only one tooltip is shown at a time;
/// * on touch screens, where nothing hovers, a long press on the trigger
///   opens it; it closes on the next tap.
///
/// Pass a [HeroTooltipContent] as [content] to set the placement, arrow,
/// offset or style; any other widget is wrapped in one using [placement],
/// [showArrow] and [offset].
///
/// The trigger must be focusable for keyboard users (a button, or any
/// content wrapped in [HeroTooltipTrigger]). The text of the tooltip is
/// attached to the trigger's semantics (see [semanticLabel]).
class HeroTooltip extends StatefulWidget {
  /// Creates a tooltip.
  const HeroTooltip({
    super.key,
    required this.child,
    required this.content,
    this.delay,
    this.closeDelay,
    this.trigger = HeroTooltipTriggerMode.hover,
    this.isDisabled = false,
    this.shouldSkipAnimation = false,
    this.isOpen,
    this.defaultOpen = false,
    this.onOpenChanged,
    this.placement = HeroPlacement.top,
    this.showArrow = false,
    this.offset,
    this.semanticLabel,
  });

  /// How long other tooltips keep opening at once after the last one
  /// closed (React Aria's `TOOLTIP_COOLDOWN`).
  static const Duration warmUpCooldown = Duration(milliseconds: 500);

  /// The trigger.
  final Widget child;

  /// The tooltip: a [HeroTooltipContent], or any widget (usually a [Text])
  /// that is wrapped in one.
  final Widget content;

  /// Hover time before the tooltip opens; defaults to the theme's
  /// [HeroThemeData.tooltipDelay].
  final Duration? delay;

  /// Time before the tooltip closes after the pointer left; defaults to the
  /// theme's [HeroThemeData.tooltipCloseDelay].
  final Duration? closeDelay;

  /// What opens the tooltip.
  final HeroTooltipTriggerMode trigger;

  /// Whether the tooltip never opens.
  final bool isDisabled;

  /// Whether to skip the enter and exit animations while the global warm-up
  /// is active, i.e. when moving quickly from one tooltip to another.
  final bool shouldSkipAnimation;

  /// Whether the tooltip is shown (controlled).
  final bool? isOpen;

  /// Whether the tooltip is initially shown (uncontrolled).
  final bool defaultOpen;

  /// Called when the tooltip opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  /// Placement when [content] is not a [HeroTooltipContent].
  final HeroPlacement placement;

  /// Whether to show the arrow when [content] is not a [HeroTooltipContent].
  final bool showArrow;

  /// Offset when [content] is not a [HeroTooltipContent].
  final double? offset;

  /// The tooltip text announced with the trigger; defaults to the text of
  /// the content when it is a [Text].
  final String? semanticLabel;

  @override
  State<HeroTooltip> createState() => _HeroTooltipState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Duration>('delay', delay, defaultValue: null))
      ..add(
        DiagnosticsProperty<Duration>(
          'closeDelay',
          closeDelay,
          defaultValue: null,
        ),
      )
      ..add(
        EnumProperty<HeroTooltipTriggerMode>(
          'trigger',
          trigger,
          defaultValue: HeroTooltipTriggerMode.hover,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen, defaultValue: null));
  }
}

class _HeroTooltipState extends State<HeroTooltip> {
  // The global warm-up shared by all tooltips (React Aria keeps it in
  // module state as well).
  static final Set<_HeroTooltipState> _mounted = <_HeroTooltipState>{};
  static _HeroTooltipState? _shown;
  static bool _warm = false;
  static Timer? _cooldown;

  late bool _open = widget.defaultOpen;
  Timer? _openTimer;
  Timer? _closeTimer;
  bool _hovered = false;
  bool _focused = false;
  bool _contentHovered = false;
  bool _skipAnimation = false;

  bool get _isOpen => (widget.isOpen ?? _open) && !widget.isDisabled;

  HeroThemeData get _theme => HeroTheme.of(context);

  Duration get _delay => widget.delay ?? _theme.tooltipDelay;

  Duration get _closeDelay => widget.closeDelay ?? _theme.tooltipCloseDelay;

  HeroTooltipContent get _content {
    final Widget content = widget.content;
    if (content is HeroTooltipContent) return content;
    return HeroTooltipContent(
      placement: widget.placement,
      showArrow: widget.showArrow,
      offset: widget.offset,
      child: content,
    );
  }

  @override
  void initState() {
    super.initState();
    _mounted.add(this);
  }

  @override
  void didUpdateWidget(HeroTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDisabled && !oldWidget.isDisabled) {
      _cancelTimers();
      _open = false;
      if (_shown == this) _releaseShown();
    }
    if (widget.isOpen == false && oldWidget.isOpen != false && _shown == this) {
      _releaseShown();
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    if (_shown == this) _shown = null;
    _mounted.remove(this);
    if (_mounted.isEmpty) {
      _cooldown?.cancel();
      _cooldown = null;
      _warm = false;
    }
    super.dispose();
  }

  void _cancelTimers() {
    _openTimer?.cancel();
    _openTimer = null;
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _setOpen(bool value) {
    if (!mounted || value == _isOpen) return;
    if (widget.isOpen == null) setState(() => _open = value);
    widget.onOpenChanged?.call(value);
  }

  /// Opens after [delay] unless [immediate], a delay of zero or the global
  /// warm-up.
  void _requestOpen({bool immediate = false}) {
    if (widget.isDisabled) return;
    _closeTimer?.cancel();
    _closeTimer = null;
    if (immediate || _isOpen || _warm || _delay <= Duration.zero) {
      _show();
      return;
    }
    // Starting to warm up closes other tooltips at once.
    final _HeroTooltipState? other = _shown;
    if (other != null && other != this) other._hide();
    _openTimer ??= Timer(_delay, () {
      _openTimer = null;
      if (mounted) _show();
    });
  }

  /// Closes after [closeDelay] unless [immediate], once neither the
  /// trigger nor the tooltip is hovered or focused.
  void _requestClose({bool immediate = false}) {
    if (_hovered || _focused || _contentHovered) return;
    _openTimer?.cancel();
    _openTimer = null;
    if (!_isOpen) return;
    if (immediate || _closeDelay <= Duration.zero) {
      _hide();
      return;
    }
    _closeTimer ??= Timer(_closeDelay, () {
      _closeTimer = null;
      if (mounted) _hide();
    });
  }

  void _show() {
    _cancelTimers();
    _cooldown?.cancel();
    _cooldown = null;
    final _HeroTooltipState? other = _shown;
    final bool swapping = _warm;
    if (other != null && other != this) other._hide(replaced: true);
    _shown = this;
    _warm = true;
    final bool skip = widget.shouldSkipAnimation && swapping;
    if (skip != _skipAnimation) setState(() => _skipAnimation = skip);
    _setOpen(true);
  }

  void _hide({bool replaced = false}) {
    _cancelTimers();
    if (_shown == this) _releaseShown();
    final bool skip = widget.shouldSkipAnimation && replaced;
    if (mounted && skip != _skipAnimation) {
      setState(() => _skipAnimation = skip);
    }
    _setOpen(false);
  }

  /// Gives up the shown slot and starts the warm-up cooldown.
  void _releaseShown() {
    _shown = null;
    _cooldown?.cancel();
    _cooldown = Timer(HeroTooltip.warmUpCooldown, () {
      _cooldown = null;
      if (_shown == null) _warm = false;
    });
  }

  void _handleHover(bool hovered) {
    _hovered = hovered;
    if (hovered) {
      _requestOpen();
    } else {
      _requestClose();
    }
  }

  void _handleContentHover(bool hovered) {
    _contentHovered = hovered;
    if (hovered) {
      if (_isOpen) _requestOpen(immediate: true);
    } else {
      _requestClose();
    }
  }

  void _handleFocus(bool focused) {
    if (focused) {
      // Only keyboard focus opens the tooltip (`isFocusVisible`).
      if (FocusManager.instance.highlightMode !=
          FocusHighlightMode.traditional) {
        return;
      }
      _focused = true;
      _requestOpen(immediate: true);
    } else {
      _focused = false;
      _requestClose(immediate: true);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    // Pressing the trigger closes the tooltip (`shouldCloseOnPress`).
    _focused = false;
    _openTimer?.cancel();
    _openTimer = null;
    if (_isOpen) _hide();
  }

  void _handleLongPress(LongPressStartDetails details) {
    _requestOpen(immediate: true);
  }

  void _handleDismiss() {
    _hovered = false;
    _focused = false;
    _contentHovered = false;
    _hide();
  }

  static String? _textOf(Widget widget) {
    if (widget is Text) return widget.data ?? widget.textSpan?.toPlainText();
    if (widget is RichText) return widget.text.toPlainText();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroTooltipContent content = _content;
    final Duration enter = _skipAnimation
        ? Duration.zero
        : theme.motion.resolve(context, HeroMotion.normal);
    final Duration exit = _skipAnimation
        ? Duration.zero
        : theme.motion.resolve(context, HeroMotion.fast);

    Widget trigger = widget.child;
    if (!widget.isDisabled) {
      final String? label = widget.semanticLabel ?? _textOf(content.child);
      if (label != null) {
        // Merged so the text lands on the trigger's own node.
        trigger = MergeSemantics(
          child: Semantics(tooltip: label, child: trigger),
        );
      }
      trigger = Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onFocusChange: _handleFocus,
        child: trigger,
      );
      if (widget.trigger == HeroTooltipTriggerMode.hover) {
        trigger = MouseRegion(
          opaque: false,
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: trigger,
        );
        // Interactive triggers do not report hits to their ancestors (their
        // hover region is not opaque), so the detectors around them test
        // their own bounds.
        trigger = RawGestureDetector(
          behavior: HitTestBehavior.translucent,
          gestures: <Type, GestureRecognizerFactory>{
            LongPressGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                  LongPressGestureRecognizer
                >(
                  () => LongPressGestureRecognizer(
                    debugOwner: this,
                    supportedDevices: const <PointerDeviceKind>{
                      PointerDeviceKind.touch,
                    },
                  ),
                  (LongPressGestureRecognizer recognizer) {
                    recognizer.onLongPressStart = _handleLongPress;
                  },
                ),
          },
          child: trigger,
        );
      }
      // Opaque so the overlay's tap region sees presses on the trigger as
      // inside.
      trigger = Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handlePointerDown,
        child: trigger,
      );
    }

    final bool arrow = content.showArrow;
    return HeroAnchoredOverlay(
      isOpen: _isOpen,
      onDismiss: _handleDismiss,
      placement: content.placement,
      offset: content.offset ?? theme.spacing(arrow ? 1.75 : 0.75),
      crossOffset: content.crossOffset,
      shouldFlip: content.shouldFlip,
      restoreFocus: false,
      enterDuration: enter,
      exitDuration: exit,
      overlayBuilder: (BuildContext context, HeroOverlayGeometry geometry) {
        return _HeroTooltipScope(
          geometry: geometry,
          child: MouseRegion(
            opaque: false,
            onEnter: (_) => _handleContentHover(true),
            onExit: (_) => _handleContentHover(false),
            child: content,
          ),
        );
      },
      child: trigger,
    );
  }
}

/// Hands the resolved geometry to the content and its arrow.
class _HeroTooltipScope extends InheritedWidget {
  const _HeroTooltipScope({required this.geometry, required super.child});

  final HeroOverlayGeometry geometry;

  static _HeroTooltipScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroTooltipScope>();

  @override
  bool updateShouldNotify(_HeroTooltipScope oldWidget) =>
      oldWidget.geometry != geometry;
}

/// Hands the tooltip's fill color to [HeroTooltipArrow].
class _HeroTooltipArrowStyle extends InheritedWidget {
  const _HeroTooltipArrowStyle({
    required this.side,
    required this.color,
    required super.child,
  });

  final HeroOverlaySide side;
  final Color color;

  static _HeroTooltipArrowStyle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroTooltipArrowStyle>();

  @override
  bool updateShouldNotify(_HeroTooltipArrowStyle oldWidget) =>
      oldWidget.side != side || oldWidget.color != color;
}

/// The tooltip bubble (`Tooltip.Content`): an `overlay` surface with
/// 8 px padding, 12 px text, a 320 px maximum width, 12 px radius and the
/// overlay shadow.
///
/// It sits [offset] from the trigger: 3 px, or 7 px with [showArrow]. The
/// arrow is drawn on the edge facing the trigger, pointing at its center.
class HeroTooltipContent extends StatelessWidget {
  /// Creates tooltip content.
  const HeroTooltipContent({
    super.key,
    required this.child,
    this.placement = HeroPlacement.top,
    this.offset,
    this.crossOffset = 0,
    this.shouldFlip = true,
    this.showArrow = false,
    this.arrow,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius,
    this.side = BorderSide.none,
    this.padding,
    this.maxWidth,
    this.shadows,
    this.builder,
  });

  /// The content, usually a [Text].
  final Widget child;

  /// Preferred placement; flips when there is not enough room.
  final HeroPlacement placement;

  /// Distance from the trigger; 3, or 7 with [showArrow].
  final double? offset;

  /// Shift along the trigger edge.
  final double crossOffset;

  /// Whether to flip to the opposite side when there is not enough room.
  final bool shouldFlip;

  /// Whether to show the arrow (`Tooltip.Arrow`).
  final bool showArrow;

  /// A custom arrow; defaults to [HeroTooltipArrow].
  final Widget? arrow;

  /// Fill color; defaults to `overlay`.
  final Color? backgroundColor;

  /// Text color; defaults to `overlay-foreground`.
  final Color? foregroundColor;

  /// Text style merged over `text-xs`.
  final TextStyle? textStyle;

  /// Corner radius; defaults to `min(32px, --radius-xl)`.
  final double? borderRadius;

  /// Border drawn inside the bubble.
  final BorderSide side;

  /// Inner padding; defaults to 8.
  final EdgeInsetsGeometry? padding;

  /// Maximum width; defaults to 320 (`max-w-xs`).
  final double? maxWidth;

  /// Replaces the overlay drop shadows.
  final List<BoxShadow>? shadows;

  /// Wraps the styled tooltip (`render`).
  final HeroTooltipContentBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroOverlayGeometry? geometry = _HeroTooltipScope.maybeOf(
      context,
    )?.geometry;
    final HeroOverlaySide placementSide =
        geometry?.side ??
        resolveHeroPlacementSide(
          placement,
          Directionality.maybeOf(context) ?? TextDirection.ltr,
        );
    final Color fill = backgroundColor ?? theme.colors.overlay;
    final ShapeBorder shape = theme.shapeAll(
      borderRadius ?? math.min(theme.spacing(8), theme.radii.xl),
    );

    Widget body = Padding(
      padding: padding ?? EdgeInsets.all(theme.spacing(2)),
      child: child,
    );
    // Scrolls when the space next to the trigger is too short.
    body = SingleChildScrollView(primary: false, child: body);
    body = DefaultTextStyle(
      style: theme.typography.xs
          .copyWith(color: foregroundColor ?? theme.colors.overlayForeground)
          .merge(textStyle),
      child: IconTheme.merge(
        data: IconThemeData(
          color: foregroundColor ?? theme.colors.overlayForeground,
          size: theme.spacing(4),
        ),
        child: body,
      ),
    );
    Widget tooltip = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? theme.spacing(80)),
      child: HeroOverlaySurface(
        shape: shape,
        color: fill,
        shadows: shadows,
        side: side,
        child: body,
      ),
    );
    if (showArrow && geometry != null) {
      tooltip = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          tooltip,
          HeroOverlayArrow.positioned(
            geometry: geometry,
            extent: theme.spacing(3),
            arrow: _HeroTooltipArrowStyle(
              side: geometry.side,
              color: fill,
              child: arrow ?? const HeroTooltipArrow(),
            ),
          ),
        ],
      );
    }
    tooltip = Semantics(container: true, child: tooltip);
    final HeroTooltipContentBuilder? builder = this.builder;
    if (builder != null) {
      tooltip = builder(
        context,
        HeroTooltipRenderState(placement: placementSide),
        tooltip,
      );
    }
    return tooltip;
  }
}

/// The arrow of a tooltip (`Tooltip.Arrow`): HeroUI's 12 × 12 curved
/// triangle filled with the tooltip color and outlined with `border` at
/// 40%, rotated towards the trigger.
///
/// Pass it as [HeroTooltipContent.arrow] with a [child] to draw a custom
/// shape (pointing down; it is rotated for the other placements).
class HeroTooltipArrow extends StatelessWidget {
  /// Creates a tooltip arrow.
  const HeroTooltipArrow({super.key, this.child});

  /// A custom shape drawn pointing down.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroTooltipArrowStyle? style = _HeroTooltipArrowStyle.maybeOf(
      context,
    );
    return HeroOverlayArrow(
      side: style?.side ?? HeroOverlaySide.top,
      color: style?.color ?? theme.colors.overlay,
      strokeColor: theme.colors.border.withValues(alpha: 0.4),
      child: child,
    );
  }
}

/// Makes any content a focusable tooltip trigger (`Tooltip.Trigger`):
/// keyboard users can tab to it to show the tooltip, and it shows the
/// focus ring on keyboard focus.
class HeroTooltipTrigger extends StatelessWidget {
  /// Creates a tooltip trigger.
  const HeroTooltipTrigger({
    super.key,
    required this.child,
    this.shape,
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  });

  /// The content.
  final Widget child;

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
      focusNode: focusNode,
      autofocus: autofocus,
      mouseCursor: SystemMouseCursors.basic,
      behavior: HitTestBehavior.deferToChild,
      semanticsLabel: semanticsLabel,
      child: child,
      builder:
          (BuildContext context, HeroInteractionState state, Widget? child) {
            return HeroFocusRing(
              visible: state.isFocusVisible,
              shape: shape ?? theme.shapeAll(0),
              child: child!,
            );
          },
    );
  }
}
