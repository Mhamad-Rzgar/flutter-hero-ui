/// HeroUI's `CheckboxGroup`: a labelled group of checkboxes with a shared
/// selection and validation.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../checkbox/checkbox.dart';
import '../checkbox/toggle_field.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/hero_field.dart';
import '../input/hero_text_constraints.dart';
import '../label/label.dart';
import '../text_field/hero_field_layout.dart';

/// The render props of a [HeroCheckboxGroup] (React Aria's
/// `CheckboxGroupRenderProps`), passed to [HeroCheckboxGroup.builder].
@immutable
class HeroCheckboxGroupState {
  /// Creates checkbox group render props.
  const HeroCheckboxGroupState({
    this.value = const <String>{},
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isInvalid = false,
    this.isRequired = false,
  });

  /// The values of the checked checkboxes.
  final Set<String> value;

  /// Whether the group is disabled.
  final bool isDisabled;

  /// Whether the group is read-only.
  final bool isReadOnly;

  /// Whether the group currently shows as invalid.
  final bool isInvalid;

  /// Whether a selection is required.
  final bool isRequired;

  @override
  bool operator ==(Object other) =>
      other is HeroCheckboxGroupState &&
      setEquals(other.value, value) &&
      other.isDisabled == isDisabled &&
      other.isReadOnly == isReadOnly &&
      other.isInvalid == isInvalid &&
      other.isRequired == isRequired;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(value),
    isDisabled,
    isReadOnly,
    isInvalid,
    isRequired,
  );
}

/// Builds the parts of a [HeroCheckboxGroup] from its state (HeroUI's
/// render-function children).
typedef HeroCheckboxGroupBuilder =
    List<Widget> Function(BuildContext context, HeroCheckboxGroupState state);

/// A group of checkboxes (HeroUI `CheckboxGroup`): a [HeroLabel], an
/// optional [HeroDescription], [HeroCheckbox]es with a `value` and an
/// optional [HeroFieldError], stacked in a column.
///
/// ```dart
/// const HeroCheckboxGroup(
///   name: 'interests',
///   label: 'Select your interests',
///   description: 'Choose all that apply',
///   children: <Widget>[
///     HeroCheckbox(value: 'coding', label: 'Coding'),
///     HeroCheckbox(value: 'design', label: 'Design'),
///     HeroCheckbox(value: 'writing', label: 'Writing'),
///   ],
/// )
/// ```
///
/// [label], [description] and [errorMessage] are placed before and after
/// [children]; the parts can also be composed directly. Every checkbox gets
/// a 16 px top margin ([itemMargin], HeroUI's `mt-4`) while the label and
/// description touch ([spacing] 0).
///
/// The group owns the selection: controlled with [value] + [onChanged] or
/// uncontrolled with [defaultValue]. Its [variant], [isDisabled],
/// [isReadOnly] and invalid state apply to every checkbox; a disabled group
/// dims its label and checkboxes. Tab moves through the checkboxes.
///
/// It is a `FormField<Set<String>>` of the nearest `Form` (a [HeroForm]):
/// [isRequired] asks for at least one checked box (and puts the asterisk on
/// the label), [validator], [validationErrors] and [isInvalid] work as on
/// the other fields, and the checked values are submitted as a list under
/// [name]. While invalid the label turns `--danger`, every control shows
/// the invalid style and the [HeroFieldError] shows the message.
class HeroCheckboxGroup extends StatefulWidget {
  /// Creates a checkbox group.
  const HeroCheckboxGroup({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.label,
    this.description,
    this.errorMessage,
    this.value,
    this.defaultValue = const <String>{},
    this.onChanged,
    this.variant = HeroFieldVariant.primary,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid,
    this.name,
    this.validator,
    this.validationBehavior,
    this.validationErrors,
    this.validationMessages = const HeroValidationMessages(),
    this.onSaved,
    this.autovalidateMode,
    this.spacing,
    this.itemMargin,
    this.fullWidth = false,
    this.semanticLabel,
  });

  /// The parts of the group: checkboxes, and optionally a label, a
  /// description and an error.
  final List<Widget> children;

  /// Builds the parts from the group state; replaces [children].
  final HeroCheckboxGroupBuilder? builder;

  /// Label text shown before the parts.
  final String? label;

  /// Description text shown after the label.
  final String? description;

  /// Error text shown after the parts while the group is invalid.
  final String? errorMessage;

  /// The values of the checked checkboxes (controlled).
  final Set<String>? value;

  /// The initially checked values (uncontrolled).
  final Set<String> defaultValue;

  /// Called with the new selection when the user toggles a checkbox.
  final ValueChanged<Set<String>>? onChanged;

  /// Variant of the checkboxes that do not set their own.
  final HeroFieldVariant variant;

  /// Whether every checkbox is disabled.
  final bool isDisabled;

  /// Whether the checkboxes can be focused but not toggled.
  final bool isReadOnly;

  /// Whether at least one checkbox must be checked.
  final bool isRequired;

  /// Overrides the displayed validation: true invalid, false valid.
  final bool? isInvalid;

  /// The name of the checked values in the data a [HeroForm] submits.
  final String? name;

  /// Custom validation (`validate`): an error message or null.
  final FormFieldValidator<Set<String>>? validator;

  /// When errors show; null inherits the [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors, shown until the user changes the selection.
  final List<String>? validationErrors;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Called with the selection when the enclosing form is saved.
  final FormFieldSetter<Set<String>>? onSaved;

  /// When the native behaviour shows errors before any change.
  final AutovalidateMode? autovalidateMode;

  /// Gap between the parts; 0 by default.
  final double? spacing;

  /// Space around every checkbox; defaults to a 16 px top margin (`mt-4`).
  final EdgeInsetsGeometry? itemMargin;

  /// Whether the group fills the available width (`w-full`); otherwise it
  /// is as wide as its widest part.
  final bool fullWidth;

  /// Accessibility label of the group; defaults to the label text.
  final String? semanticLabel;

  @override
  State<HeroCheckboxGroup> createState() => _HeroCheckboxGroupState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(IterableProperty<String>('value', value, defaultValue: null))
      ..add(
        EnumProperty<HeroFieldVariant>(
          'variant',
          variant,
          defaultValue: HeroFieldVariant.primary,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isReadOnly', value: isReadOnly, ifTrue: 'read-only'))
      ..add(FlagProperty('isRequired', value: isRequired, ifTrue: 'required'))
      ..add(
        DiagnosticsProperty<bool>('isInvalid', isInvalid, defaultValue: null),
      )
      ..add(StringProperty('name', name, defaultValue: null));
  }
}

class _HeroCheckboxGroupState extends State<HeroCheckboxGroup> {
  final GlobalKey<HeroValidatedFieldState<Set<String>>> _fieldKey =
      GlobalKey<HeroValidatedFieldState<Set<String>>>();
  late Set<String> _value = <String>{...widget.defaultValue};
  late final Set<String> _initialValue = <String>{
    ...widget.value ?? widget.defaultValue,
  };

  Set<String> get _effectiveValue => widget.value ?? _value;

  bool _toggle(String value) {
    final Set<String> next = <String>{..._effectiveValue};
    final bool selected = next.add(value);
    if (!selected) next.remove(value);
    if (widget.value == null) setState(() => _value = next);
    _fieldKey.currentState?.didChange(next);
    widget.onChanged?.call(next);
    return selected;
  }

  void _handleReset() {
    if (setEquals(_effectiveValue, _initialValue)) return;
    if (widget.value == null) {
      setState(() => _value = <String>{..._initialValue});
    }
    widget.onChanged?.call(<String>{..._initialValue});
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> value = _effectiveValue;
    return HeroValidatedField<Set<String>>(
      key: _fieldKey,
      value: value,
      name: widget.name,
      formValue: (Set<String>? v) => v == null || v.isEmpty ? null : v.toList(),
      onReset: _handleReset,
      isDisabled: widget.isDisabled,
      isRequired: widget.isRequired,
      isValueMissing: (Set<String>? v) => v == null || v.isEmpty,
      valueMissingMessage: widget.validationMessages.checkboxValueMissing,
      isInvalid: widget.isInvalid,
      errorMessage: widget.errorMessage,
      validator: widget.validator,
      validationBehavior: widget.validationBehavior,
      validationErrors: widget.validationErrors,
      validationMessages: widget.validationMessages,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      builder: (BuildContext context, HeroValidationResult validation) =>
          _buildGroup(context, value, validation),
    );
  }

  Widget _buildGroup(
    BuildContext context,
    Set<String> value,
    HeroValidationResult validation,
  ) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroCheckboxGroupState state = HeroCheckboxGroupState(
      value: value,
      isDisabled: widget.isDisabled,
      isReadOnly: widget.isReadOnly,
      isInvalid: validation.isInvalid,
      isRequired: widget.isRequired,
    );
    final String? label = widget.label;
    final String? description = widget.description;
    final String? errorMessage = widget.errorMessage;
    final List<Widget> parts = <Widget>[
      if (label != null) HeroLabel.text(label),
      if (description != null) HeroDescription.text(description),
      ...widget.builder?.call(context, state) ?? widget.children,
      if (errorMessage != null) HeroFieldError.text(errorMessage),
    ];

    final String? semanticLabel = widget.semanticLabel ?? _labelText(parts);
    final String? hint = heroToggleFieldHint(parts, validation);
    return HeroFieldScope(
      variant: widget.variant,
      isDisabled: widget.isDisabled,
      isInvalid: validation.isInvalid,
      validationErrors: validation.validationErrors,
      isRequired: widget.isRequired,
      isReadOnly: widget.isReadOnly,
      semanticLabel: semanticLabel,
      semanticHint: hint,
      child: HeroCheckboxGroupScope(
        value: value,
        toggle: _toggle,
        variant: widget.variant,
        isDisabled: widget.isDisabled,
        isReadOnly: widget.isReadOnly,
        isRequired: widget.isRequired,
        isInvalid: validation.isInvalid,
        validationErrors: validation.validationErrors,
        itemMargin:
            widget.itemMargin ??
            EdgeInsetsDirectional.only(top: theme.spacing(4)),
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: semanticLabel,
          hint: hint,
          child: HeroFieldLayout(
            spacing: widget.spacing ?? 0,
            fullWidth: widget.fullWidth,
            children: parts,
          ),
        ),
      ),
    );
  }

  /// The text of the group's label, announced for the group.
  static String? _labelText(List<Widget> parts) {
    for (final Widget part in parts) {
      if (part is HeroLabel) return part.data;
    }
    return null;
  }
}
