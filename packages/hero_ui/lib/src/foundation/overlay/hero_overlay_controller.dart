import 'package:flutter/widgets.dart';

/// The open state of an overlay, the counterpart of HeroUI's
/// `useOverlayState` hook.
///
/// Pass it to a modal, drawer, alert dialog or popover (`controller:`) to
/// open and close it from anywhere:
///
/// ```dart
/// final HeroOverlayController state = HeroOverlayController();
///
/// HeroButton(onPressed: state.open, child: const Text('Open'));
/// HeroModal(controller: state, child: HeroModalBackdrop(...));
/// ```
class HeroOverlayController extends ChangeNotifier {
  /// Creates a controller that starts open when [defaultOpen] is true.
  HeroOverlayController({bool defaultOpen = false, this.onOpenChanged})
    : _isOpen = defaultOpen;

  /// Called whenever the open state changes.
  final ValueChanged<bool>? onOpenChanged;

  bool _isOpen;

  /// Whether the overlay is open.
  bool get isOpen => _isOpen;

  /// Opens the overlay.
  void open() => setOpen(true);

  /// Closes the overlay.
  void close() => setOpen(false);

  /// Opens a closed overlay and closes an open one.
  void toggle() => setOpen(!_isOpen);

  /// Sets the open state.
  void setOpen(bool value) {
    if (_isOpen == value) return;
    _isOpen = value;
    notifyListeners();
    onOpenChanged?.call(value);
  }
}

/// Gives the content of a dialog-like overlay (modal, alert dialog, drawer,
/// popover dialog) access to its [close] function.
///
/// This is the Flutter counterpart of React Aria's dialog context:
/// `HeroButton(slot: HeroButtonSlot.close)` and the close triggers call
/// [close] of the nearest scope.
class HeroDialogScope extends InheritedWidget {
  /// Creates a dialog scope.
  const HeroDialogScope({super.key, required this.close, required super.child});

  /// Closes the dialog, optionally completing it with a result.
  final void Function([Object? result]) close;

  /// The nearest scope, or null outside of a dialog.
  static HeroDialogScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<HeroDialogScope>();

  /// The nearest scope.
  static HeroDialogScope of(BuildContext context) {
    final HeroDialogScope? scope = maybeOf(context);
    assert(scope != null, 'No HeroDialogScope found in the context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(HeroDialogScope oldWidget) => false;
}
