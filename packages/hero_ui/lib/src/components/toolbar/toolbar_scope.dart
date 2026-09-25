import 'package:flutter/widgets.dart';

/// Tells the button groups inside a `HeroToolbar` about the toolbar.
///
/// The counterpart of the `ToggleButtonGroupContext` HeroUI's toolbar
/// provides: `HeroToggleButtonGroup` and `HeroButtonGroup` take the
/// toolbar's [orientation] unless they set their own, and a toggle button
/// group leaves arrow-key navigation to the toolbar (React Aria turns a
/// toolbar nested in a toolbar into a plain group).
class HeroToolbarScope extends InheritedWidget {
  /// Publishes a toolbar's [orientation] to [child].
  const HeroToolbarScope({
    super.key,
    required this.orientation,
    required super.child,
  });

  /// The orientation of the toolbar.
  final Axis orientation;

  /// The closest toolbar scope, or null outside a toolbar.
  static HeroToolbarScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroToolbarScope>();

  @override
  bool updateShouldNotify(HeroToolbarScope oldWidget) =>
      orientation != oldWidget.orientation;
}
