import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../form/form.dart';
import 'hero_editable_text.dart';
import 'hero_field.dart';
import 'hero_text_constraints.dart';

/// The stateful core shared by hero_ui's text inputs (`HeroInput`,
/// `HeroTextArea` and the inputs of composite fields).
///
/// It owns what every text input needs besides its look:
///
/// * the controller and focus node (its own, the caller's, or the ones of an
///   enclosing [HeroFieldScope]);
/// * the controlled [value] / uncontrolled [defaultValue] model;
/// * registration with the nearest `Form` as a `FormField<String>`, with
///   the native constraints of [HeroTextConstraints] followed by
///   [validator], and a [name]d value in the data a [HeroForm] submits;
/// * a browser's implicit submission: Enter (or the done, go, send or
///   search keyboard action) in a single-line input submits the enclosing
///   [HeroForm];
/// * the field look: a [HeroFieldBox] around a [HeroEditableText] (or only
///   the editable text when [decorated] is false, for inputs inside a
///   composite field that paints its own box).
class HeroTextInputCore extends StatefulWidget {
  /// Creates a text input core.
  const HeroTextInputCore({
    super.key,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.onFocusChanged,
    this.placeholder,
    this.type = HeroInputType.text,
    this.variant,
    this.fullWidth = false,
    this.width,
    this.height,
    this.minHeight,
    this.maxLines = 1,
    this.minLines,
    this.decorated = true,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid = false,
    this.name,
    this.autofillHints,
    this.maxLength,
    this.minLength,
    this.pattern,
    this.min,
    this.max,
    this.step,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.validationMessages = const HeroValidationMessages(),
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText,
    this.autocorrect,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.semanticLabel,
    this.style,
    this.scrollController,
    this.debugLabel = 'HeroTextInput',
  });

  /// Controls the text. When null the input manages its own controller (or
  /// uses the one of an enclosing [HeroFieldScope]).
  final TextEditingController? controller;

  /// Focus node of the input.
  final FocusNode? focusNode;

  /// The current value (controlled). Changes are applied to the text.
  final String? value;

  /// The initial value (uncontrolled).
  final String? defaultValue;

  /// Called on every user edit (`onChange`).
  final ValueChanged<String>? onChanged;

  /// Called when the user submits with the keyboard action or Enter.
  final ValueChanged<String>? onSubmitted;

  /// Called when the user completes editing.
  final VoidCallback? onEditingComplete;

  /// Called on each tap on the input.
  final VoidCallback? onTap;

  /// Called when the input gains or loses focus.
  final ValueChanged<bool>? onFocusChanged;

  /// Text shown while the input is empty.
  final String? placeholder;

  /// The input type (`type`): keyboard, obscuring and type validation.
  final HeroInputType type;

  /// Visual variant; null inherits from the enclosing field, then primary.
  final HeroFieldVariant? variant;

  /// Whether the input takes the full available width.
  final bool fullWidth;

  /// Explicit width; defaults to [HeroFieldMetrics.defaultWidth].
  final double? width;

  /// Explicit height (multi-line inputs fill it).
  final double? height;

  /// Minimum height of the field.
  final double? minHeight;

  /// Maximum number of visible lines (null for unlimited).
  final int? maxLines;

  /// Minimum number of visible lines.
  final int? minLines;

  /// Whether to paint the [HeroFieldBox] around the text.
  final bool decorated;

  /// Whether the input is disabled (`disabled`).
  final bool isDisabled;

  /// Whether the text can be selected but not edited (`readOnly`).
  final bool isReadOnly;

  /// Whether a value is required (`required`).
  final bool isRequired;

  /// Forces the invalid look (`aria-invalid`).
  final bool isInvalid;

  /// The name of the value in the data a [HeroForm] submits (`name`).
  final String? name;

  /// Autofill hints (`autoComplete`), see `AutofillHints`.
  final Iterable<String>? autofillHints;

  /// Maximum number of characters; longer input is truncated (`maxLength`).
  final int? maxLength;

  /// Minimum number of characters (`minLength`, validation).
  final int? minLength;

  /// Pattern the whole value must match (`pattern`, validation).
  final RegExp? pattern;

  /// Minimum number for [HeroInputType.number] (`min`, validation).
  final num? min;

  /// Maximum number for [HeroInputType.number] (`max`, validation).
  final num? max;

  /// Step for [HeroInputType.number] (`step`, validation).
  final num? step;

  /// Additional validation, run after the native constraints.
  final FormFieldValidator<String>? validator;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// When to validate automatically.
  final AutovalidateMode? autovalidateMode;

  /// Messages of the native constraint validation.
  final HeroValidationMessages validationMessages;

  /// Whether to focus the input when first built.
  final bool autofocus;

  /// Keyboard type; defaults to the one of [type] (multiline for
  /// multi-line inputs).
  final TextInputType? keyboardType;

  /// Keyboard action button; defaults to the one of [type].
  final TextInputAction? textInputAction;

  /// Automatic capitalization.
  final TextCapitalization textCapitalization;

  /// Whether to obscure the text; defaults to true for passwords.
  final bool? obscureText;

  /// Whether autocorrect and suggestions are enabled; defaults to off for
  /// passwords, emails, URLs, numbers and phone numbers.
  final bool? autocorrect;

  /// Extra input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Horizontal text alignment.
  final TextAlign textAlign;

  /// Accessibility label (`aria-label`).
  final String? semanticLabel;

  /// Visual overrides (the counterpart of `className`).
  final HeroFieldStyle? style;

  /// Scroll controller of multi-line text.
  final ScrollController? scrollController;

  /// Debug label of the focus node the input creates for itself.
  final String debugLabel;

  /// Whether the input edits more than one line.
  bool get isMultiline => maxLines != 1;

  @override
  State<HeroTextInputCore> createState() => _HeroTextInputCoreState();
}

class _HeroTextInputCoreState extends State<HeroTextInputCore> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  TextEditingController? _listenedController;
  FocusNode? _listenedFocusNode;
  HeroFieldScope? _scope;
  final GlobalKey<_HeroTextFormFieldState> _fieldKey =
      GlobalKey<_HeroTextFormFieldState>();
  late String _initialText;
  bool _syncing = false;

  TextEditingController get _controller =>
      widget.controller ??
      _scope?.controller ??
      (_ownController ??= TextEditingController(text: _initialText));

  FocusNode get _focusNode =>
      widget.focusNode ??
      _scope?.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: widget.debugLabel));

  bool get _isDisabled => widget.isDisabled || (_scope?.isDisabled ?? false);

  bool get _ownsFormField => _scope?.controller == null;

  /// The own type, or the field's type while the input keeps the default.
  HeroInputType get _type => widget.type != HeroInputType.text
      ? widget.type
      : (_scope?.inputType ?? HeroInputType.text);

  HeroTextConstraints get _constraints => HeroTextConstraints(
    isRequired: widget.isRequired || (_scope?.isRequired ?? false),
    type: _type,
    minLength: widget.minLength,
    pattern: widget.pattern,
    min: widget.min,
    max: widget.max,
    step: widget.step,
    messages: widget.validationMessages,
  );

  @override
  void initState() {
    super.initState();
    _initialText =
        widget.value ?? widget.defaultValue ?? widget.controller?.text ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = HeroFieldScope.maybeOf(context);
    _attach();
  }

  @override
  void didUpdateWidget(HeroTextInputCore oldWidget) {
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
    if (!_ownsFormField) _scope?.onInputConstraintsChanged?.call(null);
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
    }
    final FocusNode focusNode = _focusNode;
    if (!identical(focusNode, _listenedFocusNode)) {
      _listenedFocusNode?.removeListener(_handleFocusChanged);
      focusNode.addListener(_handleFocusChanged);
      _listenedFocusNode = focusNode;
    }
    focusNode.canRequestFocus = !_isDisabled;
  }

  void _handleTextChanged() {
    final _HeroTextFormFieldState? field = _fieldKey.currentState;
    final String text = _controller.text;
    if (field == null || field.value == text) return;
    if (_syncing) {
      field.syncValue(text);
    } else {
      field.didChange(text);
    }
  }

  void _handleFocusChanged() {
    setState(() {});
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _handleSaved(String? value) {
    widget.onSaved?.call(value);
    final String? name = widget.name;
    if (name == null || _isDisabled) return;
    context.findAncestorStateOfType<HeroFormState>()?.addValue(
      name,
      value ?? '',
    );
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    if (!mounted || widget.isMultiline) return;
    final TextInputAction action =
        widget.textInputAction ?? _type.textInputAction ?? TextInputAction.done;
    if (!_implicitSubmitActions.contains(action)) return;
    context.findAncestorStateOfType<HeroFormState>()?.submit();
  }

  /// Keyboard actions that submit the enclosing form, like Enter or the
  /// "Go" key in a browser form.
  static const Set<TextInputAction> _implicitSubmitActions = <TextInputAction>{
    TextInputAction.done,
    TextInputAction.go,
    TextInputAction.send,
    TextInputAction.search,
  };

  void _handleReset() {
    final String text = widget.value ?? _initialText;
    if (_controller.text == text) return;
    _syncing = true;
    _controller.text = text;
    _syncing = false;
    widget.onChanged?.call(text);
  }

  String? _validate(String? value) =>
      _constraints.validate(value) ?? widget.validator?.call(value);

  @override
  Widget build(BuildContext context) {
    if (!_ownsFormField) {
      // The field root owns the form state and validates these constraints.
      _scope?.onInputConstraintsChanged?.call(_constraints);
      return _buildField(context, hasError: false);
    }
    return _HeroTextFormField(
      key: _fieldKey,
      initialValue: _controller.text,
      validator: _validate,
      onSaved: _handleSaved,
      onReset: _handleReset,
      autovalidateMode: widget.autovalidateMode,
      enabled: !_isDisabled,
      builder: (FormFieldState<String> field) =>
          _buildField(field.context, hasError: field.hasError),
    );
  }

  Widget _buildField(BuildContext context, {required bool hasError}) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldScope? scope = _scope;
    final HeroFieldStyle? style = widget.style;
    final bool disabled = _isDisabled;
    final bool invalid =
        widget.isInvalid || (scope?.isInvalid ?? false) || hasError;
    final HeroInputType type = _type;
    final bool suggestions = widget.autocorrect ?? !type.disablesSuggestions;
    final int? maxLength = widget.maxLength;
    final bool multiline = widget.isMultiline;
    final bool expands = multiline && widget.height != null;

    final Widget editable = HeroEditableText(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: widget.placeholder,
      style: style?.textStyle,
      placeholderStyle: style?.placeholderStyle,
      cursorColor: style?.cursorColor,
      selectionColor: style?.selectionColor,
      padding: style?.padding ?? HeroFieldMetrics.padding(theme),
      textAlign: widget.textAlign,
      keyboardType:
          widget.keyboardType ??
          (multiline ? TextInputType.multiline : type.keyboardType),
      textInputAction: widget.textInputAction ?? type.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: !multiline && (widget.obscureText ?? type.obscuresText),
      autocorrect: suggestions,
      enableSuggestions: suggestions,
      maxLines: expands ? null : widget.maxLines,
      minLines: expands ? null : widget.minLines,
      expands: expands,
      isReadOnly: widget.isReadOnly || (scope?.isReadOnly ?? false),
      isDisabled: disabled,
      isInvalid: invalid,
      isRequired: widget.isRequired || (scope?.isRequired ?? false),
      autofocus: widget.autofocus,
      inputFormatters: <TextInputFormatter>[
        ...type.inputFormatters,
        ...?widget.inputFormatters,
        if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
      ],
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: _handleSubmitted,
      onEditingComplete: widget.onEditingComplete,
      onTap: widget.onTap,
      scrollController: widget.scrollController,
      semanticLabel: widget.semanticLabel ?? scope?.semanticLabel,
      semanticHint: scope?.semanticHint,
      semanticsInputType: type.semanticsInputType,
    );

    Widget field = widget.decorated
        ? HeroFieldBox(
            variant:
                widget.variant ?? scope?.variant ?? HeroFieldVariant.primary,
            isFocused: _focusNode.hasFocus && !disabled,
            isInvalid: invalid,
            isDisabled: disabled,
            style: style,
            child: editable,
          )
        : editable;

    final double? minHeight = widget.minHeight;
    if (minHeight != null) {
      field = ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: field,
      );
    }

    final bool fullWidth = widget.fullWidth || (scope?.fullWidth ?? false);
    return SizedBox(
      width: fullWidth
          ? double.infinity
          : (widget.width ?? HeroFieldMetrics.defaultWidth(theme)),
      height: widget.height,
      child: field,
    );
  }
}

/// The `FormField<String>` a standalone text input registers with the
/// nearest `Form`.
class _HeroTextFormField extends FormField<String> {
  const _HeroTextFormField({
    super.key,
    required super.builder,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.onReset,
    super.autovalidateMode,
    super.enabled,
  });

  @override
  FormFieldState<String> createState() => _HeroTextFormFieldState();
}

class _HeroTextFormFieldState extends FormFieldState<String> {
  /// Updates the value without notifying the form, for changes made while
  /// widgets are building (a new controlled value).
  void syncValue(String value) => setValue(value);
}
