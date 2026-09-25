import 'package:flutter/widgets.dart';

/// Forwards presses of the nearest pressable descendant to [onPressed], the
/// counterpart of React Aria's `PressResponder`.
///
/// Overlay roots use it to turn their first child into the trigger: a
/// `HeroButton` (or any `HeroInteractable`) below the responder calls its
/// own `onPressed` and then [onPressed]. Only the nearest pressable consumes
/// the responder; pressables nested inside it do not.
///
/// ```dart
/// HeroPressResponder(
///   onPressed: open,
///   isExpanded: isOpen,
///   child: const HeroButton(child: Text('Open')),
/// )
/// ```
class HeroPressResponder extends InheritedWidget {
  /// Creates a press responder.
  const HeroPressResponder({
    super.key,
    required VoidCallback this.onPressed,
    this.isExpanded,
    required super.child,
  });

  /// Hides an enclosing responder from [child].
  const HeroPressResponder.reset({super.key, required super.child})
    : onPressed = null,
      isExpanded = null;

  /// Called after the pressable's own handler.
  final VoidCallback? onPressed;

  /// Whether the overlay controlled by the pressable is open, announced as
  /// the expanded state (`aria-expanded`); null announces nothing.
  final bool? isExpanded;

  /// The nearest active responder, or null.
  static HeroPressResponder? maybeOf(BuildContext context) {
    final HeroPressResponder? responder = context
        .dependOnInheritedWidgetOfExactType<HeroPressResponder>();
    return responder?.onPressed == null ? null : responder;
  }

  @override
  bool updateShouldNotify(HeroPressResponder oldWidget) =>
      onPressed != oldWidget.onPressed || isExpanded != oldWidget.isExpanded;
}
