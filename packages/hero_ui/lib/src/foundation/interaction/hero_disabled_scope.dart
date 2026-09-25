import 'package:flutter/widgets.dart';

/// Disables every hero_ui control below it, like a native
/// `<fieldset disabled>`: buttons, links, toggles and text fields stop
/// responding, leave the focus order, report themselves as disabled and fade
/// to the disabled opacity, and labels dim.
///
/// `HeroFieldset` publishes one when its `isDisabled` is set. Controls read
/// it through [HeroDisabledScope.of] in addition to their own `isDisabled`.
/// A scope cannot re-enable the controls of a disabled ancestor scope (like
/// nested fieldsets in a browser).
///
/// ```dart
/// HeroDisabledScope(
///   child: Column(
///     children: <Widget>[
///       const HeroTextField(label: 'Name'),
///       HeroButton(onPressed: save, child: const Text('Save')),
///     ],
///   ),
/// )
/// ```
class HeroDisabledScope extends StatelessWidget {
  /// Disables the controls in [child] when [isDisabled] is true.
  const HeroDisabledScope({
    super.key,
    this.isDisabled = true,
    required this.child,
  });

  /// Whether the controls below are disabled.
  final bool isDisabled;

  /// The subtree.
  final Widget child;

  /// Whether a [HeroDisabledScope] above [context] disables its controls.
  ///
  /// The caller rebuilds when the answer changes.
  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_HeroDisabledScopeData>()
          ?.isDisabled ??
      false;

  @override
  Widget build(BuildContext context) => _HeroDisabledScopeData(
    isDisabled: isDisabled || of(context),
    child: child,
  );
}

class _HeroDisabledScopeData extends InheritedWidget {
  const _HeroDisabledScopeData({
    required this.isDisabled,
    required super.child,
  });

  final bool isDisabled;

  @override
  bool updateShouldNotify(_HeroDisabledScopeData oldWidget) =>
      isDisabled != oldWidget.isDisabled;
}
