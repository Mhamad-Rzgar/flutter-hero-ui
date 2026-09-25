import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../input/hero_field.dart';

/// The group a `HeroRadio` belongs to: selects values and drives the roving
/// keyboard focus (React Aria's radio group state).
abstract interface class HeroRadioGroupController {
  /// Registers a radio of the group.
  void registerRadio(HeroRadioRegistration radio);

  /// Removes a radio from the group.
  void unregisterRadio(HeroRadioRegistration radio);

  /// Selects [value] (a user action); returns whether it is selected
  /// afterwards.
  bool select(String value);

  /// Reports that the radio with [value] received focus.
  void handleRadioFocused(String value);
}

/// A radio registered with its [HeroRadioGroupController].
class HeroRadioRegistration {
  /// Creates a registration.
  HeroRadioRegistration({
    required this.controller,
    required this.value,
    required this.focusNode,
    required this.isEnabled,
  });

  /// The group the radio is registered with.
  final HeroRadioGroupController controller;

  /// The radio's value.
  final String value;

  /// The focus node of the radio's content.
  final FocusNode focusNode;

  /// Whether the radio can currently be focused and selected.
  final ValueGetter<bool> isEnabled;
}

/// The state a `HeroRadioGroup` shares with its radios.
class HeroRadioGroupScope extends InheritedWidget {
  /// Publishes a radio group's state to [child].
  const HeroRadioGroupScope({
    super.key,
    required this.controller,
    required this.value,
    required super.child,
    this.tabStopValue,
    this.variant = HeroFieldVariant.primary,
    this.orientation = Axis.vertical,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid = false,
    this.validationErrors = const <String>[],
    this.itemMargin = EdgeInsets.zero,
  });

  /// The group that owns the selection.
  final HeroRadioGroupController controller;

  /// The selected value, or null.
  final String? value;

  /// The value of the radio that takes part in Tab traversal (the selected
  /// one, or the first enabled one); null lets every radio take part.
  final String? tabStopValue;

  /// The group's variant.
  final HeroFieldVariant variant;

  /// The group's layout direction.
  final Axis orientation;

  /// Whether every radio is disabled.
  final bool isDisabled;

  /// Whether the selection can be focused but not changed.
  final bool isReadOnly;

  /// Whether a selection is required.
  final bool isRequired;

  /// Whether the group shows as invalid (every radio does too).
  final bool isInvalid;

  /// The group's validation messages.
  final List<String> validationErrors;

  /// Space around every radio of a vertical group (`mt-4`).
  final EdgeInsetsGeometry itemMargin;

  /// The closest radio group scope, or null.
  static HeroRadioGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroRadioGroupScope>();

  @override
  bool updateShouldNotify(HeroRadioGroupScope oldWidget) =>
      !identical(controller, oldWidget.controller) ||
      value != oldWidget.value ||
      tabStopValue != oldWidget.tabStopValue ||
      variant != oldWidget.variant ||
      orientation != oldWidget.orientation ||
      isDisabled != oldWidget.isDisabled ||
      isReadOnly != oldWidget.isReadOnly ||
      isRequired != oldWidget.isRequired ||
      isInvalid != oldWidget.isInvalid ||
      !listEquals(validationErrors, oldWidget.validationErrors) ||
      itemMargin != oldWidget.itemMargin;
}
