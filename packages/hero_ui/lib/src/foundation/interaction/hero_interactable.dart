import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'hero_disabled_scope.dart';
import 'hero_press_responder.dart';

/// A snapshot of the interaction state of a [HeroInteractable].
///
/// Mirrors the `data-*` state attributes React Aria sets on HeroUI
/// components: `data-hovered`, `data-pressed`, `data-focused`,
/// `data-focus-visible`, `data-disabled`, `data-pending` and
/// `data-selected`.
@immutable
class HeroInteractionState {
  /// Creates an interaction state.
  const HeroInteractionState({
    this.isHovered = false,
    this.isPressed = false,
    this.isFocused = false,
    this.isFocusVisible = false,
    this.isDisabled = false,
    this.isPending = false,
    this.isSelected = false,
  });

  /// The idle state.
  static const HeroInteractionState idle = HeroInteractionState();

  /// A pointer hovers the component (only on devices that can hover).
  final bool isHovered;

  /// The component is being pressed by a pointer or the keyboard.
  final bool isPressed;

  /// The component has input focus.
  final bool isFocused;

  /// The component has focus that was reached with the keyboard, so the
  /// focus ring must be shown.
  final bool isFocusVisible;

  /// The component is disabled.
  final bool isDisabled;

  /// The component is pending (loading) and ignores interaction.
  final bool isPending;

  /// The component is selected / checked / toggled on.
  final bool isSelected;

  /// Whether the component currently accepts interaction.
  bool get isInteractive => !isDisabled && !isPending;

  /// The equivalent Flutter [WidgetState] set.
  Set<WidgetState> get widgetStates => <WidgetState>{
    if (isHovered) WidgetState.hovered,
    if (isPressed) WidgetState.pressed,
    if (isFocused) WidgetState.focused,
    if (isDisabled) WidgetState.disabled,
    if (isSelected) WidgetState.selected,
  };

  /// Returns a copy with the given fields replaced.
  HeroInteractionState copyWith({
    bool? isHovered,
    bool? isPressed,
    bool? isFocused,
    bool? isFocusVisible,
    bool? isDisabled,
    bool? isPending,
    bool? isSelected,
  }) {
    return HeroInteractionState(
      isHovered: isHovered ?? this.isHovered,
      isPressed: isPressed ?? this.isPressed,
      isFocused: isFocused ?? this.isFocused,
      isFocusVisible: isFocusVisible ?? this.isFocusVisible,
      isDisabled: isDisabled ?? this.isDisabled,
      isPending: isPending ?? this.isPending,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroInteractionState &&
      other.isHovered == isHovered &&
      other.isPressed == isPressed &&
      other.isFocused == isFocused &&
      other.isFocusVisible == isFocusVisible &&
      other.isDisabled == isDisabled &&
      other.isPending == isPending &&
      other.isSelected == isSelected;

  @override
  int get hashCode => Object.hash(
    isHovered,
    isPressed,
    isFocused,
    isFocusVisible,
    isDisabled,
    isPending,
    isSelected,
  );

  @override
  String toString() =>
      'HeroInteractionState(${<String>[if (isHovered) 'hovered', if (isPressed) 'pressed', if (isFocused) 'focused', if (isFocusVisible) 'focusVisible', if (isDisabled) 'disabled', if (isPending) 'pending', if (isSelected) 'selected'].join(', ')})';
}

/// Signature of the builder used by [HeroInteractable].
typedef HeroInteractionBuilder =
    Widget Function(
      BuildContext context,
      HeroInteractionState state,
      Widget? child,
    );

/// The shared interaction layer of hero_ui, the Flutter counterpart of React
/// Aria's `usePress`, `useHover` and `useFocusRing` hooks.
///
/// It tracks hover, press, focus and keyboard focus visibility, activates on
/// tap, Enter and Space, exposes button semantics, shows the pointer cursor
/// and hands a [HeroInteractionState] to [builder] so the component can
/// paint its own states. There is no ink splash: visual feedback comes
/// entirely from the component's tokens.
///
/// A quick tap still shows the pressed state for at least
/// [minimumPressDuration], so press feedback is visible on touch screens
/// where down and up events can arrive in the same frame.
class HeroInteractable extends StatefulWidget {
  /// Creates an interactable region.
  const HeroInteractable({
    super.key,
    required this.builder,
    this.child,
    this.onPressed,
    this.onLongPress,
    this.onPressStart,
    this.onPressEnd,
    this.onHoverChanged,
    this.onFocusChanged,
    this.isDisabled = false,
    this.isPending = false,
    this.isSelected = false,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.mouseCursor,
    this.shortcuts,
    this.actions,
    this.behavior = HitTestBehavior.opaque,
    this.semanticsLabel,
    this.semanticsHint,
    this.semanticsValue,
    this.isButton = true,
    this.isToggle = false,
    this.isLink = false,
    this.linkUrl,
    this.excludeSemantics = false,
    this.minimumPressDuration = const Duration(milliseconds: 100),
    this.pressOnKeyboardActivate = true,
  });

  /// Builds the visual representation for the current state.
  final HeroInteractionBuilder builder;

  /// An optional subtree passed back to [builder] untouched (for rebuild
  /// efficiency).
  final Widget? child;

  /// Called when the component is activated (tap, Enter or Space).
  final VoidCallback? onPressed;

  /// Called on a long press.
  final VoidCallback? onLongPress;

  /// Called when a press starts (`onPressStart`).
  final VoidCallback? onPressStart;

  /// Called when a press ends, whether or not it activated (`onPressEnd`).
  final VoidCallback? onPressEnd;

  /// Called when hover starts or ends (`onHoverChange`).
  final ValueChanged<bool>? onHoverChanged;

  /// Called when focus is gained or lost (`onFocusChange`).
  final ValueChanged<bool>? onFocusChanged;

  /// Disables all interaction and removes the region from focus traversal.
  /// An enclosing [HeroDisabledScope] (a disabled `HeroFieldset`) disables
  /// the region as well.
  final bool isDisabled;

  /// Ignores interaction while keeping focusability (`isPending`).
  final bool isPending;

  /// Marks the component as selected.
  final bool isSelected;

  /// Optional externally managed focus node.
  final FocusNode? focusNode;

  /// Whether to request focus when first built.
  final bool autofocus;

  /// Whether the region takes part in focus traversal.
  final bool canRequestFocus;

  /// Cursor shown on hover; defaults to the pointer (`--cursor-interactive`).
  final MouseCursor? mouseCursor;

  /// Extra keyboard shortcuts active while focused.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Extra actions handling [shortcuts].
  final Map<Type, Action<Intent>>? actions;

  /// Hit-test behaviour of the gesture detector.
  final HitTestBehavior behavior;

  /// Accessibility label; defaults to the text of the subtree.
  final String? semanticsLabel;

  /// Accessibility hint.
  final String? semanticsHint;

  /// Accessibility value.
  final String? semanticsValue;

  /// Whether to expose button semantics.
  final bool isButton;

  /// Whether to expose the selected state as a toggle (`aria-pressed`).
  final bool isToggle;

  /// Whether to expose link semantics instead of button semantics.
  final bool isLink;

  /// Destination exposed with link semantics (only used when [isLink]).
  final Uri? linkUrl;

  /// Whether to drop the subtree's own semantics.
  final bool excludeSemantics;

  /// Minimum time the pressed state stays visible after a tap.
  final Duration minimumPressDuration;

  /// Whether keyboard activation briefly shows the pressed state.
  final bool pressOnKeyboardActivate;

  @override
  State<HeroInteractable> createState() => _HeroInteractableState();
}

class _HeroInteractableState extends State<HeroInteractable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;
  bool _focusVisible = false;
  DateTime? _pressStartedAt;
  Timer? _releaseTimer;
  HeroPressResponder? _responder;
  bool _scopeDisabled = false;

  bool get _disabled => widget.isDisabled || _scopeDisabled;

  bool get _interactive => !_disabled && !widget.isPending;

  late final Map<Type, Action<Intent>> _defaultActions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(
      onInvoke: (_) => _handleKeyboardActivate(),
    ),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
      onInvoke: (_) => _handleKeyboardActivate(),
    ),
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scopeDisabled = HeroDisabledScope.of(context);
    _resetWhenInactive();
  }

  @override
  void didUpdateWidget(HeroInteractable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetWhenInactive();
  }

  void _resetWhenInactive() {
    if (!_interactive) {
      _releaseTimer?.cancel();
      if (_pressed || _hovered) {
        _pressed = false;
        _hovered = false;
      }
    }
  }

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_interactive) return;
    _releaseTimer?.cancel();
    _pressStartedAt = DateTime.now();
    _setPressed(true);
    widget.onPressStart?.call();
  }

  void _release() {
    final DateTime? started = _pressStartedAt;
    _pressStartedAt = null;
    widget.onPressEnd?.call();
    if (started == null) {
      _setPressed(false);
      return;
    }
    final Duration elapsed = DateTime.now().difference(started);
    final Duration remaining = widget.minimumPressDuration - elapsed;
    if (remaining <= Duration.zero) {
      _setPressed(false);
    } else {
      _releaseTimer?.cancel();
      _releaseTimer = Timer(remaining, () {
        if (mounted) _setPressed(false);
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_interactive) return;
    _release();
  }

  void _handleTapCancel() {
    if (_pressStartedAt == null && !_pressed) return;
    _pressStartedAt = null;
    _releaseTimer?.cancel();
    widget.onPressEnd?.call();
    _setPressed(false);
  }

  void _handleTap() {
    if (!_interactive) return;
    widget.onPressed?.call();
    _responder?.onPressed?.call();
  }

  void _handleKeyboardActivate() {
    if (!_interactive) return;
    if (widget.pressOnKeyboardActivate) {
      _pressStartedAt = DateTime.now();
      _setPressed(true);
      widget.onPressStart?.call();
      _release();
    }
    widget.onPressed?.call();
    _responder?.onPressed?.call();
  }

  void _handleHover(bool value) {
    final bool hovered = value && _interactive;
    if (_hovered == hovered) return;
    setState(() => _hovered = hovered);
    widget.onHoverChanged?.call(hovered);
  }

  void _handleFocus(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
    widget.onFocusChanged?.call(value);
  }

  void _handleFocusHighlight(bool value) {
    if (_focusVisible == value) return;
    setState(() => _focusVisible = value);
  }

  @override
  Widget build(BuildContext context) {
    // A trigger slot (e.g. the first child of a modal) forwards presses.
    final HeroPressResponder? responder = HeroPressResponder.maybeOf(context);
    _responder = responder;
    final bool pressable = widget.onPressed != null || responder != null;
    final HeroInteractionState state = HeroInteractionState(
      isHovered: _hovered && _interactive,
      isPressed: _pressed && _interactive,
      isFocused: _focused,
      isFocusVisible: _focusVisible && _focused,
      isDisabled: _disabled,
      isPending: widget.isPending,
      isSelected: widget.isSelected,
    );

    Widget result = widget.builder(context, state, widget.child);
    if (responder != null) {
      // Pressables inside this one do not consume the responder.
      result = HeroPressResponder.reset(child: result);
    }

    result = GestureDetector(
      behavior: widget.behavior,
      onTapDown: _interactive ? _handleTapDown : null,
      onTapUp: _interactive ? _handleTapUp : null,
      onTapCancel: _interactive ? _handleTapCancel : null,
      onTap: _interactive ? _handleTap : null,
      onLongPress: _interactive && widget.onLongPress != null
          ? widget.onLongPress
          : null,
      excludeFromSemantics: true,
      child: result,
    );

    result = FocusableActionDetector(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: !_disabled,
      descendantsAreFocusable: true,
      descendantsAreTraversable: true,
      shortcuts: widget.shortcuts,
      actions: <Type, Action<Intent>>{..._defaultActions, ...?widget.actions},
      mouseCursor: _disabled
          ? SystemMouseCursors.basic
          : widget.isPending
          ? SystemMouseCursors.basic
          : (widget.mouseCursor ?? SystemMouseCursors.click),
      onShowFocusHighlight: _handleFocusHighlight,
      onFocusChange: _handleFocus,
      includeFocusSemantics: false,
      child: result,
    );

    // Hover is tracked for any hovering pointer (mouse, stylus), like CSS
    // `@media (hover: hover)`, independent of the focus highlight mode.
    result = MouseRegion(
      opaque: false,
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: result,
    );

    if (!widget.canRequestFocus) {
      result = ExcludeFocus(child: result);
    }

    return Semantics(
      container: true,
      button: widget.isButton && !widget.isLink,
      link: widget.isLink,
      linkUrl: widget.isLink ? widget.linkUrl : null,
      // Pending components stay focusable but are announced as unavailable
      // (React Aria sets `aria-disabled` while pending).
      enabled: !_disabled && !widget.isPending,
      focusable: !_disabled && widget.canRequestFocus,
      // A null `focused` marks the node as not focusable.
      focused: !_disabled && widget.canRequestFocus ? _focused : null,
      selected: widget.isToggle ? null : (widget.isSelected ? true : null),
      toggled: widget.isToggle ? widget.isSelected : null,
      expanded: responder?.isExpanded,
      label: widget.semanticsLabel,
      hint: widget.semanticsHint,
      value: widget.semanticsValue,
      excludeSemantics: widget.excludeSemantics,
      onTap: _interactive && pressable ? _handleTap : null,
      onLongPress: _interactive && widget.onLongPress != null
          ? widget.onLongPress
          : null,
      child: result,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('hovered', value: _hovered, ifTrue: 'hovered'))
      ..add(FlagProperty('pressed', value: _pressed, ifTrue: 'pressed'))
      ..add(FlagProperty('focused', value: _focused, ifTrue: 'focused'));
  }
}

/// Keyboard shortcut helper: the activators that trigger a HeroUI button
/// (Enter and Space), exposed for components that build custom shortcut
/// maps.
const Map<ShortcutActivator, Intent> heroActivateShortcuts =
    <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
      SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
    };
