/// HeroUI's `Form`: validation and submission for a group of fields.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// When a form field shows its validation errors and whether invalid fields
/// block submission (HeroUI's `validationBehavior`).
enum HeroValidationBehavior {
  /// Errors appear once the value is committed (the field loses focus after
  /// an edit) or the form is submitted, and invalid fields block submission;
  /// the first invalid field is focused. This is the default, matching a
  /// browser's native form validation.
  native,

  /// Errors appear in realtime while the user edits and submission is never
  /// blocked. Built-in constraints such as `isRequired` are only announced
  /// to assistive technologies, not validated (`aria-required`).
  aria,
}

/// A form (HeroUI `Form`): a Flutter [Form] with HeroUI's validation and
/// submission behaviour.
///
/// Fields inside it (`HeroTextField`, `HeroInput`, ... or any [FormField])
/// register with the underlying [Form]. [submit] (or a `HeroButton` with
/// `type: HeroButtonType.submit`, or Enter in a single-line input) then:
///
/// * with [HeroValidationBehavior.native] (the default) validates every
///   field, shows the errors, calls [onInvalid] and focuses the first invalid
///   field when one fails, and does not submit;
/// * otherwise saves every field and calls [onSubmit] with the values of the
///   named fields (`name` → value, a `List` when several fields share a
///   name), the counterpart of the browser's `FormData`.
///
/// [reset] (or a `HeroButton` with `type: HeroButtonType.reset`) restores
/// every field's initial value, clears the errors and calls [onReset].
///
/// [validationBehavior] and the server-side [validationErrors] (by field
/// name) are inherited by the fields, which show those errors immediately
/// and clear them once the user edits the field.
///
/// ```dart
/// HeroForm(
///   onSubmit: (Map<String, Object?> data) => debugPrint('$data'),
///   child: Column(
///     crossAxisAlignment: CrossAxisAlignment.start,
///     spacing: 16,
///     children: <Widget>[
///       const HeroInput(
///         name: 'email',
///         type: HeroInputType.email,
///         isRequired: true,
///         semanticLabel: 'Email',
///       ),
///       HeroButton(
///         type: HeroButtonType.submit,
///         child: const Text('Submit'),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Use `HeroForm.of(context)` or a `GlobalKey<HeroFormState>` to [submit],
/// [reset], validate or save it programmatically.
class HeroForm extends StatefulWidget {
  /// Creates a form around [child].
  const HeroForm({
    super.key,
    required this.child,
    this.onSubmit,
    this.onInvalid,
    this.onReset,
    this.onChanged,
    this.validationBehavior = HeroValidationBehavior.native,
    this.validationErrors,
    this.autovalidateMode,
    this.focusInvalidField = true,
    this.semanticLabel,
  });

  /// The form content: fields, buttons and layout.
  final Widget child;

  /// Called with the values of the named fields when the form is submitted
  /// (and, with [HeroValidationBehavior.native], every field is valid).
  final ValueChanged<Map<String, Object?>>? onSubmit;

  /// Called when a submission is blocked because a field is invalid
  /// (`onInvalid`).
  final VoidCallback? onInvalid;

  /// Called after the form was reset (`onReset`).
  final VoidCallback? onReset;

  /// Called whenever a field's value changes.
  final VoidCallback? onChanged;

  /// How the fields validate; fields can override it.
  final HeroValidationBehavior validationBehavior;

  /// Server-side errors by field name. A field shows its errors immediately
  /// and clears them once the user edits it; a new map shows them again.
  final Map<String, List<String>>? validationErrors;

  /// When the underlying [Form] validates all its fields automatically.
  final AutovalidateMode? autovalidateMode;

  /// Whether a blocked submission focuses the first invalid field (the
  /// browser default that `onInvalid` + `preventDefault()` turns off).
  final bool focusInvalidField;

  /// Accessibility label of the form (`aria-label`).
  final String? semanticLabel;

  /// The state of the closest enclosing form, or null. The caller rebuilds
  /// when the form's [validationBehavior] or [validationErrors] change.
  static HeroFormState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroFormScope>()?.state;

  /// The state of the closest enclosing form.
  static HeroFormState of(BuildContext context) {
    final HeroFormState? state = maybeOf(context);
    assert(
      state != null,
      'HeroForm.of() was called with a context that does not contain a '
      'HeroForm.',
    );
    return state!;
  }

  @override
  State<HeroForm> createState() => HeroFormState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<HeroValidationBehavior>(
          'validationBehavior',
          validationBehavior,
          defaultValue: HeroValidationBehavior.native,
        ),
      )
      ..add(
        DiagnosticsProperty<Map<String, List<String>>>(
          'validationErrors',
          validationErrors,
          defaultValue: null,
        ),
      );
  }
}

/// The state of a [HeroForm]: submit, reset, validate and save it.
class HeroFormState extends State<HeroForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, Object?>? _values;
  final Set<String> _multiValueNames = <String>{};

  /// The underlying Flutter form.
  FormState get form => _formKey.currentState!;

  /// How the fields of this form validate.
  HeroValidationBehavior get validationBehavior => widget.validationBehavior;

  /// The server-side errors of the field called [name].
  List<String> validationErrorsFor(String? name) {
    if (name == null) return const <String>[];
    return widget.validationErrors?[name] ?? const <String>[];
  }

  /// Submits the form and returns whether [HeroForm.onSubmit] was called.
  ///
  /// With [HeroValidationBehavior.native] every field is validated first;
  /// when one is invalid the errors are shown, [HeroForm.onInvalid] is
  /// called, the first invalid field is focused and nothing is submitted.
  bool submit() {
    if (widget.validationBehavior == HeroValidationBehavior.native) {
      final Set<FormFieldState<Object?>> invalid = form.validateGranularly();
      if (invalid.isNotEmpty) {
        widget.onInvalid?.call();
        if (widget.focusInvalidField) _focusFirst(invalid);
        return false;
      }
    }
    final Map<String, Object?> values = save();
    widget.onSubmit?.call(values);
    return true;
  }

  /// Validates every field, shows their errors and returns whether all are
  /// valid.
  bool validate() => form.validate();

  /// Saves every field (calling their `onSaved`) and returns the values of
  /// the named fields.
  Map<String, Object?> save() {
    final Map<String, Object?> values = <String, Object?>{};
    _values = values;
    try {
      form.save();
    } finally {
      _values = null;
      _multiValueNames.clear();
    }
    return values;
  }

  /// Restores every field's initial value, clears the errors and calls
  /// [HeroForm.onReset].
  void reset() {
    form.reset();
    widget.onReset?.call();
  }

  /// Adds the value of the field called [name] to the values collected by
  /// [save]. Fields call this from their `onSaved`; outside [save] it does
  /// nothing. Several values with the same name are collected in a list.
  void addValue(String name, Object? value) {
    final Map<String, Object?>? values = _values;
    if (values == null) return;
    if (!values.containsKey(name)) {
      values[name] = value;
      return;
    }
    if (_multiValueNames.add(name)) {
      values[name] = <Object?>[values[name], value];
    } else {
      (values[name]! as List<Object?>).add(value);
    }
  }

  /// Focuses the first focusable control, in focus order, that belongs to
  /// one of the [invalid] fields.
  void _focusFirst(Set<FormFieldState<Object?>> invalid) {
    for (final FocusNode node in FocusManager.instance.rootScope.descendants) {
      final BuildContext? nodeContext = node.context;
      if (nodeContext == null ||
          !node.canRequestFocus ||
          node.skipTraversal ||
          node is FocusScopeNode) {
        continue;
      }
      final FormFieldState<Object?>? field = nodeContext
          .findAncestorStateOfType<FormFieldState<Object?>>();
      if (field != null && invalid.contains(field)) {
        node.requestFocus();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget form = Form(
      key: _formKey,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      child: _HeroFormScope(
        state: this,
        validationBehavior: widget.validationBehavior,
        validationErrors: widget.validationErrors,
        child: widget.child,
      ),
    );
    final String? label = widget.semanticLabel;
    if (label == null) return form;
    // Flutter's form node keeps its children explicit, so the label is set
    // on a group around it (the form landmark's accessible name).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: form,
    );
  }
}

class _HeroFormScope extends InheritedWidget {
  const _HeroFormScope({
    required this.state,
    required this.validationBehavior,
    required this.validationErrors,
    required super.child,
  });

  final HeroFormState state;
  final HeroValidationBehavior validationBehavior;
  final Map<String, List<String>>? validationErrors;

  @override
  bool updateShouldNotify(_HeroFormScope oldWidget) =>
      validationBehavior != oldWidget.validationBehavior ||
      validationErrors != oldWidget.validationErrors;
}
