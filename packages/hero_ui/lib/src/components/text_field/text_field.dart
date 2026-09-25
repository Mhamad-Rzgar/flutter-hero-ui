/// HeroUI's `TextField`: a label, a text input, a description and an error
/// message composed into one accessible form field.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/input.dart';
import '../label/label.dart';
import '../text_area/text_area.dart';
import 'hero_field_layout.dart';

export 'hero_field_layout.dart';

/// The render props of a [HeroTextField], passed to its
/// [HeroTextField.builder].
@immutable
class HeroTextFieldState {
  /// Creates text field render props.
  const HeroTextFieldState({
    this.isDisabled = false,
    this.isInvalid = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isFocusWithin = false,
    this.isFocusVisible = false,
    this.validation = HeroValidationResult.valid,
  });

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Whether the field currently shows as invalid.
  final bool isInvalid;

  /// Whether the field is read-only.
  final bool isReadOnly;

  /// Whether the field is required.
  final bool isRequired;

  /// Whether the input inside the field has focus.
  final bool isFocusWithin;

  /// Whether the focus is visible (keyboard navigation).
  final bool isFocusVisible;

  /// The displayed validation state (invalid state and messages).
  final HeroValidationResult validation;

  @override
  bool operator ==(Object other) =>
      other is HeroTextFieldState &&
      other.isDisabled == isDisabled &&
      other.isInvalid == isInvalid &&
      other.isReadOnly == isReadOnly &&
      other.isRequired == isRequired &&
      other.isFocusWithin == isFocusWithin &&
      other.isFocusVisible == isFocusVisible &&
      other.validation == validation;

  @override
  int get hashCode => Object.hash(
    isDisabled,
    isInvalid,
    isReadOnly,
    isRequired,
    isFocusWithin,
    isFocusVisible,
    validation,
  );
}

/// Builds the parts of a [HeroTextField] from its state (HeroUI's
/// render-function children).
typedef HeroTextFieldBuilder =
    List<Widget> Function(BuildContext context, HeroTextFieldState state);

/// A text field (HeroUI `TextField`): a [HeroLabel], a [HeroInput] or
/// [HeroTextArea], a [HeroDescription] and a [HeroFieldError] in a column
/// with a 4 px gap, sharing one state.
///
/// Build it from convenience parameters:
///
/// ```dart
/// const HeroTextField(
///   label: 'Email',
///   placeholder: 'Enter your email',
///   description: "We'll never share your email",
///   type: HeroInputType.email,
///   isRequired: true,
/// )
/// ```
///
/// or compose the parts yourself, like HeroUI:
///
/// ```dart
/// HeroTextField(
///   name: 'email',
///   type: HeroInputType.email,
///   children: const <Widget>[
///     HeroLabel.text('Email'),
///     HeroInput(placeholder: 'Enter your email'),
///     HeroDescription.text("We'll never share your email"),
///     HeroFieldError(),
///   ],
/// )
/// ```
///
/// The field owns the text (controlled with [value] + [onChanged],
/// uncontrolled with [defaultValue], or a [controller]) and the focus node;
/// the input inside edits them. Pressing the label focuses the input.
///
/// It is a `FormField<String>` of the nearest `Form` (a [HeroForm]):
/// [validator], the built-in constraints ([isRequired], [type],
/// [minLength], [pattern], [min], [max], [step], and those set on the input
/// inside), server-side [validationErrors] and [isInvalid] decide whether it
/// is invalid. The [validationBehavior] (inherited from the [HeroForm],
/// native by default) decides when the errors show:
///
/// * native: after the value is committed (the input loses focus after an
///   edit) or the form is validated, and they block submission;
/// * aria: in realtime while the user edits.
///
/// While invalid the label turns `--danger`, the input shows the invalid
/// outline, the description is hidden and the [HeroFieldError] shows the
/// messages. [isInvalid] set to true or false overrides the validation
/// display, as in HeroUI.
///
/// The column shrink-wraps its widest part (an unsized input is 192 wide)
/// and stretches every part to that width; given a tight width (or
/// [fullWidth]) it fills it, like HeroUI's `flex flex-col` field in CSS.
class HeroTextField extends StatefulWidget {
  /// Creates a text field.
  const HeroTextField({
    super.key,
    this.children,
    this.builder,
    this.label,
    this.placeholder,
    this.description,
    this.errorMessage,
    this.isMultiline = false,
    this.rows = 2,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.variant = HeroFieldVariant.primary,
    this.fullWidth = false,
    this.spacing,
    this.inputStyle,
    this.type = HeroInputType.text,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid,
    this.name,
    this.validator,
    this.validationBehavior,
    this.validationErrors,
    this.onSaved,
    this.autovalidateMode,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.min,
    this.max,
    this.step,
    this.validationMessages = const HeroValidationMessages(),
    this.autofocus = false,
    this.autofillHints,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization,
    this.semanticLabel,
  }) : assert(rows > 0);

  /// The parts of the field (`HeroLabel`, `HeroInput` or `HeroTextArea`,
  /// `HeroDescription`, `HeroFieldError`, ...). When null (and [builder] is
  /// null) the field builds them from [label], [placeholder],
  /// [description], [errorMessage] and [isMultiline].
  final List<Widget>? children;

  /// Builds the parts from the field state; takes precedence over
  /// [children].
  final HeroTextFieldBuilder? builder;

  /// Label text of the built field.
  final String? label;

  /// Placeholder of the built input.
  final String? placeholder;

  /// Description text of the built field, hidden while invalid.
  final String? description;

  /// Error text of the built field, shown while invalid; defaults to the
  /// validation messages.
  final String? errorMessage;

  /// Whether the built field edits multiple lines with a [HeroTextArea].
  final bool isMultiline;

  /// Visible lines of the built text area.
  final int rows;

  /// Controls the text; when null the field owns a controller.
  final TextEditingController? controller;

  /// Focus node of the input; when null the field owns one.
  final FocusNode? focusNode;

  /// The current value (controlled).
  final String? value;

  /// The initial value (uncontrolled).
  final String? defaultValue;

  /// Called when the user edits the value (`onChange`).
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the built input with the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Visual variant of the inputs inside the field.
  final HeroFieldVariant variant;

  /// Whether the field and its input take the full available width.
  final bool fullWidth;

  /// Gap between the parts; defaults to 4 (`gap-1`).
  final double? spacing;

  /// Visual overrides of the built input.
  final HeroFieldStyle? inputStyle;

  /// The input type (`type`), passed to the input inside the field.
  final HeroInputType type;

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Whether the text can be selected but not edited.
  final bool isReadOnly;

  /// Whether a value is required: shows the label asterisk and, with the
  /// native behaviour, fails validation while empty.
  final bool isRequired;

  /// Overrides the displayed validation: true shows the field as invalid,
  /// false as valid; null lets the validation decide.
  final bool? isInvalid;

  /// The name of the value in the data a [HeroForm] submits, and of the
  /// form's server-side errors for this field.
  final String? name;

  /// Custom validation (`validate`): returns an error message or null. Runs
  /// before the built-in constraints.
  final FormFieldValidator<String>? validator;

  /// When errors show and whether they block submission; null inherits the
  /// [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors, shown immediately and cleared once the user edits
  /// the field; overrides the form's errors for [name]. Pass a new list to
  /// show errors again.
  final List<String>? validationErrors;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// When the native behaviour shows errors without a commit.
  final AutovalidateMode? autovalidateMode;

  /// Minimum number of characters (validation).
  final int? minLength;

  /// Maximum number of characters of the built input (truncates input).
  final int? maxLength;

  /// Pattern the whole value must match (validation).
  final RegExp? pattern;

  /// Minimum number for [HeroInputType.number] (validation).
  final num? min;

  /// Maximum number for [HeroInputType.number] (validation).
  final num? max;

  /// Step for [HeroInputType.number] (validation).
  final num? step;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Whether to focus the input when first built.
  final bool autofocus;

  /// Autofill hints of the built input.
  final Iterable<String>? autofillHints;

  /// Extra input formatters of the built input.
  final List<TextInputFormatter>? inputFormatters;

  /// Keyboard type of the built input.
  final TextInputType? keyboardType;

  /// Keyboard action of the built input.
  final TextInputAction? textInputAction;

  /// Automatic capitalization of the built input.
  final TextCapitalization? textCapitalization;

  /// Accessibility label of the input (`aria-label`); defaults to the label
  /// text.
  final String? semanticLabel;

  @override
  State<HeroTextField> createState() => _HeroTextFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(StringProperty('value', value, defaultValue: null))
      ..add(
        EnumProperty<HeroInputType>(
          'type',
          type,
          defaultValue: HeroInputType.text,
        ),
      )
      ..add(
        EnumProperty<HeroFieldVariant>(
          'variant',
          variant,
          defaultValue: HeroFieldVariant.primary,
        ),
      )
      ..add(FlagProperty('fullWidth', value: fullWidth, ifTrue: 'full width'))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isReadOnly', value: isReadOnly, ifTrue: 'read-only'))
      ..add(FlagProperty('isRequired', value: isRequired, ifTrue: 'required'))
      ..add(
        DiagnosticsProperty<bool>('isInvalid', isInvalid, defaultValue: null),
      )
      ..add(
        EnumProperty<HeroValidationBehavior>(
          'validationBehavior',
          validationBehavior,
          defaultValue: null,
        ),
      );
  }
}

class _HeroTextFieldState extends State<HeroTextField> {
  final GlobalKey<_HeroTextFieldFormFieldState> _fieldKey =
      GlobalKey<_HeroTextFieldFormFieldState>();
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  TextEditingController? _listenedController;
  FocusNode? _listenedFocusNode;

  late String _initialText;
  late String _lastText;
  bool _syncing = false;
  bool _autofocused = false;

  /// Whether the user edited the value since the last commit.
  bool _dirty = false;

  /// The validation shown with the native behaviour: updated when the
  /// value is committed (blur after an edit) or the form validates.
  HeroValidationResult _committed = HeroValidationResult.valid;

  HeroValidationBehavior _behavior = HeroValidationBehavior.native;
  List<String> _serverErrors = const <String>[];
  Object? _serverSource;
  bool _serverErrorsCleared = false;
  HeroTextConstraints? _inputConstraints;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(text: _initialText));

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroTextField'));

  List<String> get _activeServerErrors =>
      _serverErrorsCleared ? const <String>[] : _serverErrors;

  @override
  void initState() {
    super.initState();
    _initialText =
        widget.value ?? widget.defaultValue ?? widget.controller?.text ?? '';
    final String? value = widget.value;
    final TextEditingController? controller = widget.controller;
    if (value != null && controller != null && controller.text != value) {
      controller.text = value;
    }
    _lastText = _controller.text;
    _attach();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autofocus && !_autofocused) {
      _autofocused = true;
      FocusScope.of(context).autofocus(_focusNode);
    }
  }

  @override
  void didUpdateWidget(HeroTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach();
    final String? value = widget.value;
    if (value != null && value != _controller.text) {
      _syncing = true;
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
      _syncing = false;
    }
  }

  @override
  void dispose() {
    _listenedController?.removeListener(_handleTextChanged);
    _listenedFocusNode?.removeListener(_handleFocusChanged);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _attach() {
    final TextEditingController controller = _controller;
    if (!identical(controller, _listenedController)) {
      _listenedController?.removeListener(_handleTextChanged);
      controller.addListener(_handleTextChanged);
      _listenedController = controller;
      _lastText = controller.text;
    }
    final FocusNode focusNode = _focusNode;
    if (!identical(focusNode, _listenedFocusNode)) {
      _listenedFocusNode?.removeListener(_handleFocusChanged);
      focusNode.addListener(_handleFocusChanged);
      _listenedFocusNode = focusNode;
    }
  }

  void _handleTextChanged() {
    final String text = _controller.text;
    if (text == _lastText) return;
    _lastText = text;
    final _HeroTextFieldFormFieldState? field = _fieldKey.currentState;
    // Changes made while widgets build (a new controlled value) are not
    // user edits: they must not notify the form or the owner.
    final bool programmatic =
        _syncing ||
        SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.persistentCallbacks;
    if (programmatic) {
      field?.syncValue(text);
      return;
    }
    _dirty = true;
    _serverErrorsCleared = true;
    field?.didChange(text);
    widget.onChanged?.call(text);
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus && _dirty) {
      // Commit the value, like the DOM `change` event on blur.
      _fieldKey.currentState?.validate();
    }
    if (widget.builder != null) setState(() {});
  }

  void _registerInputConstraints(HeroTextConstraints? constraints) {
    _inputConstraints = constraints;
  }

  HeroTextConstraints get _constraints {
    final HeroTextConstraints? input = _inputConstraints;
    return HeroTextConstraints(
      isRequired: widget.isRequired || (input?.isRequired ?? false),
      type: input?.type ?? widget.type,
      minLength: input?.minLength ?? widget.minLength,
      pattern: input?.pattern ?? widget.pattern,
      min: input?.min ?? widget.min,
      max: input?.max ?? widget.max,
      step: input?.step ?? widget.step,
      messages: widget.validationMessages,
    );
  }

  /// The custom validator's error, then (native only) the first failing
  /// built-in constraint.
  HeroValidationResult _clientValidation(String text) {
    final String? error = widget.validator?.call(text);
    if (error != null) return HeroValidationResult.invalid(<String>[error]);
    if (_behavior == HeroValidationBehavior.aria) {
      return HeroValidationResult.valid;
    }
    final String? native = _constraints.validate(text);
    return native == null
        ? HeroValidationResult.valid
        : HeroValidationResult.invalid(<String>[native]);
  }

  /// The form field validator: whether the value blocks submission.
  String? _validate(String? value) {
    if (widget.isDisabled) return null;
    if (widget.isInvalid ?? false) {
      return widget.errorMessage ?? widget.validationMessages.invalidValue;
    }
    final List<String> server = _activeServerErrors;
    if (server.isNotEmpty) return server.join(' ');
    final HeroValidationResult client = _clientValidation(value ?? '');
    return client.isInvalid ? client.validationErrors.join(' ') : null;
  }

  /// Called when the form field validates: the native behaviour now shows
  /// the current validation.
  void _commitValidation() {
    _dirty = false;
    _committed = _clientValidation(_controller.text);
  }

  void _handleSaved(String? value) {
    widget.onSaved?.call(value);
    final String? name = widget.name;
    if (name == null || widget.isDisabled) return;
    context.findAncestorStateOfType<HeroFormState>()?.addValue(
      name,
      value ?? '',
    );
  }

  void _handleReset() {
    _dirty = false;
    _committed = HeroValidationResult.valid;
    _serverErrorsCleared = true;
    final String text = _initialText;
    if (_controller.text == text) return;
    _syncing = true;
    _controller.text = text;
    _syncing = false;
    widget.onChanged?.call(text);
  }

  bool _autovalidates(FormFieldState<String> field) {
    return switch (widget.autovalidateMode ?? AutovalidateMode.disabled) {
      AutovalidateMode.always => true,
      AutovalidateMode.onUserInteraction => field.hasInteractedByUser,
      AutovalidateMode.onUserInteractionIfError =>
        field.hasInteractedByUser && _committed.isInvalid,
      AutovalidateMode.onUnfocus || AutovalidateMode.disabled => false,
    };
  }

  HeroValidationResult _displayValidation(FormFieldState<String> field) {
    final bool? controlled = widget.isInvalid;
    if (controlled != null) {
      return controlled
          ? const HeroValidationResult.invalid()
          : HeroValidationResult.valid;
    }
    final List<String> server = _activeServerErrors;
    if (server.isNotEmpty) return HeroValidationResult.invalid(server);
    if (_behavior == HeroValidationBehavior.aria || _autovalidates(field)) {
      return _clientValidation(_controller.text);
    }
    return _committed;
  }

  void _resolveFormState(HeroFormState? form) {
    _behavior =
        widget.validationBehavior ??
        form?.validationBehavior ??
        HeroValidationBehavior.native;
    final Object? source =
        widget.validationErrors ?? form?.widget.validationErrors;
    if (!identical(source, _serverSource)) {
      _serverSource = source;
      _serverErrorsCleared = false;
    }
    _serverErrors =
        widget.validationErrors ??
        form?.validationErrorsFor(widget.name) ??
        const <String>[];
  }

  @override
  Widget build(BuildContext context) {
    _resolveFormState(HeroForm.maybeOf(context));
    return _HeroTextFieldFormField(
      key: _fieldKey,
      initialValue: _initialText,
      validator: _validate,
      onSaved: _handleSaved,
      onReset: _handleReset,
      onValidate: _commitValidation,
      autovalidateMode: _behavior == HeroValidationBehavior.aria
          ? AutovalidateMode.always
          : widget.autovalidateMode,
      enabled: !widget.isDisabled,
      builder: _buildField,
    );
  }

  Widget _buildField(FormFieldState<String> field) {
    final BuildContext context = field.context;
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroValidationResult validation = _displayValidation(field);
    final bool invalid = validation.isInvalid;

    final List<Widget> children;
    final HeroTextFieldBuilder? builder = widget.builder;
    if (builder != null) {
      final bool focused = _focusNode.hasFocus;
      children = builder(
        context,
        HeroTextFieldState(
          isDisabled: widget.isDisabled,
          isInvalid: invalid,
          isReadOnly: widget.isReadOnly,
          isRequired: widget.isRequired,
          isFocusWithin: focused,
          isFocusVisible:
              focused &&
              FocusManager.instance.highlightMode ==
                  FocusHighlightMode.traditional,
          validation: validation,
        ),
      );
    } else {
      children = widget.children ?? _defaultChildren();
    }

    return HeroFieldScope(
      variant: widget.variant,
      isDisabled: widget.isDisabled,
      isInvalid: invalid,
      validationErrors: validation.validationErrors,
      isRequired: widget.isRequired,
      isReadOnly: widget.isReadOnly,
      hideDescriptionWhenInvalid: true,
      fullWidth: widget.fullWidth,
      focusNode: _focusNode,
      controller: _controller,
      semanticLabel: widget.semanticLabel ?? _labelText(children),
      semanticHint: _hintText(children, validation),
      inputType: widget.type,
      onInputConstraintsChanged: _registerInputConstraints,
      child: HeroFieldLayout(
        spacing: widget.spacing ?? theme.spacing(1),
        fullWidth: widget.fullWidth,
        children: children,
      ),
    );
  }

  List<Widget> _defaultChildren() {
    final String? label = widget.label;
    final String? description = widget.description;
    final String? errorMessage = widget.errorMessage;
    return <Widget>[
      if (label != null) HeroLabel.text(label),
      if (widget.isMultiline)
        HeroTextArea(
          placeholder: widget.placeholder,
          rows: widget.rows,
          maxLength: widget.maxLength,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.sentences,
          style: widget.inputStyle,
        )
      else
        HeroInput(
          placeholder: widget.placeholder,
          maxLength: widget.maxLength,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          onSubmitted: widget.onSubmitted,
          style: widget.inputStyle,
        ),
      if (description != null) HeroDescription.text(description),
      if (errorMessage != null)
        HeroFieldError.text(errorMessage)
      else
        const HeroFieldError(),
    ];
  }

  /// The text of the field's label, announced with the input.
  String? _labelText(List<Widget> children) {
    if (widget.label case final String label) return label;
    for (final Widget child in children) {
      if (child is HeroLabel) return child.data;
    }
    return null;
  }

  /// The description (valid) or error (invalid) text, announced with the
  /// input like `aria-describedby`.
  String? _hintText(List<Widget> children, HeroValidationResult validation) {
    if (validation.isInvalid) {
      String? error = widget.errorMessage;
      if (error == null) {
        for (final Widget child in children) {
          if (child is HeroFieldError) error ??= child.data;
        }
      }
      error ??= validation.validationErrors.join(' ');
      return error.isEmpty ? null : error;
    }
    if (widget.description case final String description) return description;
    for (final Widget child in children) {
      if (child is HeroDescription) return child.data;
    }
    return null;
  }
}

/// The `FormField<String>` a [HeroTextField] registers with the nearest
/// `Form`.
class _HeroTextFieldFormField extends FormField<String> {
  const _HeroTextFieldFormField({
    super.key,
    required super.builder,
    required this.onValidate,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.onReset,
    super.autovalidateMode,
    super.enabled,
  });

  /// Called before the field validates (form submission, blur commit).
  final VoidCallback onValidate;

  @override
  FormFieldState<String> createState() => _HeroTextFieldFormFieldState();
}

class _HeroTextFieldFormFieldState extends FormFieldState<String> {
  @override
  _HeroTextFieldFormField get widget => super.widget as _HeroTextFieldFormField;

  @override
  bool validate() {
    widget.onValidate();
    return super.validate();
  }

  /// Updates the value without notifying the form, for changes made while
  /// widgets are building.
  void syncValue(String value) => setValue(value);
}
