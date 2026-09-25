import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../input/hero_field.dart';

/// The state a `HeroCheckboxGroup` shares with its checkboxes (HeroUI's
/// `CheckboxGroupContext` plus React Aria's checkbox group state).
///
/// The group owns the selection: a `HeroCheckbox` with a `value` inside the
/// group is checked while [value] contains it and asks the group to
/// [toggle] it. The group's variant, disabled, read-only, required and
/// invalid states and the top margin of its items apply to every checkbox.
class HeroCheckboxGroupScope extends InheritedWidget {
  /// Publishes a checkbox group's state to [child].
  const HeroCheckboxGroupScope({
    super.key,
    required this.value,
    required this.toggle,
    required super.child,
    this.variant = HeroFieldVariant.primary,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid = false,
    this.validationErrors = const <String>[],
    this.itemMargin = EdgeInsets.zero,
  });

  /// The values of the checked checkboxes.
  final Set<String> value;

  /// Toggles the checkbox with [value]; returns whether it is checked
  /// afterwards.
  final bool Function(String value) toggle;

  /// Variant of checkboxes that do not set their own.
  final HeroFieldVariant variant;

  /// Whether every checkbox is disabled.
  final bool isDisabled;

  /// Whether every checkbox is read-only.
  final bool isReadOnly;

  /// Whether a selection is required.
  final bool isRequired;

  /// Whether the group shows as invalid (every checkbox does too).
  final bool isInvalid;

  /// The group's validation messages.
  final List<String> validationErrors;

  /// Space around every checkbox of the group (`mt-4`).
  final EdgeInsetsGeometry itemMargin;

  /// Whether the checkbox with [value] is checked.
  bool isSelected(String value) => this.value.contains(value);

  /// The closest checkbox group scope, or null.
  static HeroCheckboxGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroCheckboxGroupScope>();

  @override
  bool updateShouldNotify(HeroCheckboxGroupScope oldWidget) =>
      !setEquals(value, oldWidget.value) ||
      toggle != oldWidget.toggle ||
      variant != oldWidget.variant ||
      isDisabled != oldWidget.isDisabled ||
      isReadOnly != oldWidget.isReadOnly ||
      isRequired != oldWidget.isRequired ||
      isInvalid != oldWidget.isInvalid ||
      !listEquals(validationErrors, oldWidget.validationErrors) ||
      itemMargin != oldWidget.itemMargin;
}
