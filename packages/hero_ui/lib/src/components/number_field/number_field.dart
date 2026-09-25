/// HeroUI's `NumberField`: a formatted number input with increment and
/// decrement buttons, a label, a description and an error message.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../foundation/foundation.dart';
import '../button/button.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/input.dart';
import '../label/label.dart';
import '../text_field/text_field.dart';
import 'number_format.dart';

export 'number_format.dart';

/// The render props of a [HeroNumberField], passed to its
/// [HeroNumberField.builder].
@immutable
class HeroNumberFieldState {
  /// Creates number field render props.
  const HeroNumberFieldState({
    this.isDisabled = false,
    this.isInvalid = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isFocusWithin = false,
    this.isFocusVisible = false,
    this.validation = HeroValidationResult.valid,
    this.value,
    this.minValue,
    this.maxValue,
    this.step,
  });

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Whether the field currently shows as invalid.
  final bool isInvalid;

  /// Whether the field is read-only.
  final bool isReadOnly;

  /// Whether the field is required.
  final bool isRequired;

  /// Whether the input has focus.
  final bool isFocusWithin;

  /// Whether the focus is visible (keyboard navigation).
  final bool isFocusVisible;

  /// The displayed validation state.
  final HeroValidationResult validation;

  /// The committed value; null while empty.
  final double? value;

  /// The minimum value.
  final double? minValue;

  /// The maximum value.
  final double? maxValue;

  /// The step of the buttons, keys and wheel.
  final double? step;

  @override
  bool operator ==(Object other) =>
      other is HeroNumberFieldState &&
      other.isDisabled == isDisabled &&
      other.isInvalid == isInvalid &&
      other.isReadOnly == isReadOnly &&
      other.isRequired == isRequired &&
      other.isFocusWithin == isFocusWithin &&
      other.isFocusVisible == isFocusVisible &&
      other.validation == validation &&
      other.value == value &&
      other.minValue == minValue &&
      other.maxValue == maxValue &&
      other.step == step;

  @override
  int get hashCode => Object.hash(
    isDisabled,
    isInvalid,
    isReadOnly,
    isRequired,
    isFocusWithin,
    isFocusVisible,
    validation,
    value,
    minValue,
    maxValue,
    step,
  );
}

/// Builds the parts of a [HeroNumberField] from its state (HeroUI's
/// render-function children).
typedef HeroNumberFieldBuilder =
    List<Widget> Function(BuildContext context, HeroNumberFieldState state);

/// A number field (HeroUI `NumberField`): a [HeroLabel], a
/// [HeroNumberFieldGroup] with a [HeroNumberFieldDecrementButton], a
/// [HeroNumberFieldInput] and a [HeroNumberFieldIncrementButton], a
/// [HeroDescription] and a [HeroFieldError], in a column with a 4 px gap.
///
/// ```dart
/// HeroNumberField(
///   name: 'width',
///   defaultValue: 1024,
///   minValue: 0,
///   children: const <Widget>[
///     HeroLabel.text('Width'),
///     HeroNumberFieldGroup(
///       children: <Widget>[
///         HeroNumberFieldDecrementButton(),
///         HeroNumberFieldInput(width: 120),
///         HeroNumberFieldIncrementButton(),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// Without [children] (or [builder]) the field builds this layout from
/// [label], [placeholder], [description], [errorMessage] and [showStepper].
///
/// The value is formatted with [formatOptions] (or an intl [numberFormat])
/// in the field's [locale]: currencies, accounting signs, percentages
/// (0.5 shows as "50%"), fraction digits and units. Typing accepts only
/// what can become a number in that format. The value is committed when
/// the input loses focus or on Enter: it is parsed, clamped to
/// [minValue]..[maxValue], snapped to [step] (when set) and reformatted,
/// and [onChanged] is called with the new value (not on every keystroke).
///
/// The buttons, ArrowUp / ArrowDown, PageUp / PageDown and the mouse wheel
/// (while focused) step by [step] (1, or 0.01 for percentages) and commit
/// at once; Home and End go to [minValue] and [maxValue]. Holding a button
/// repeats the step. From an empty field, incrementing starts at
/// [minValue] (or 0) and decrementing at [maxValue] (or 0). The buttons
/// are disabled at the limits and are not in the focus order.
///
/// It is controlled with [value] + [onChanged] (a NaN [value] is an empty
/// controlled field) or uncontrolled with [defaultValue], and registers a
/// form field with the nearest `Form`: [validator] receives the number,
/// [isRequired] fails while empty, and a [HeroForm] submits the number
/// under [name]. The validation display follows `HeroTextField`.
class HeroNumberField extends StatefulWidget {
  /// Creates a number field.
  const HeroNumberField({
    super.key,
    this.children,
    this.builder,
    this.label,
    this.placeholder,
    this.description,
    this.errorMessage,
    this.showStepper = true,
    this.inputWidth,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.minValue,
    this.maxValue,
    this.step,
    this.formatOptions,
    this.numberFormat,
    this.locale,
    this.variant = HeroFieldVariant.primary,
    this.fullWidth = false,
    this.spacing,
    this.focusNode,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid,
    this.isWheelDisabled = false,
    this.name,
    this.validator,
    this.validationBehavior,
    this.validationErrors,
    this.onSaved,
    this.autovalidateMode,
    this.validationMessages = const HeroValidationMessages(),
    this.autofocus = false,
    this.semanticLabel,
    this.incrementLabel = 'Increase',
    this.decrementLabel = 'Decrease',
  }) : assert(step == null || step > 0);

  /// The parts of the field. When null (and [builder] is null) the field
  /// builds them from the convenience parameters.
  final List<Widget>? children;

  /// Builds the parts from the field state; takes precedence over
  /// [children].
  final HeroNumberFieldBuilder? builder;

  /// Label text of the built field.
  final String? label;

  /// Placeholder of the built input.
  final String? placeholder;

  /// Description text of the built field, hidden while invalid.
  final String? description;

  /// Error text of the built field, shown while invalid; defaults to the
  /// validation messages.
  final String? errorMessage;

  /// Whether the built group has the decrement and increment buttons.
  final bool showStepper;

  /// Width of the built input (the group adds its buttons).
  final double? inputWidth;

  /// The current value (controlled); NaN for an empty controlled field.
  final double? value;

  /// The initial value (uncontrolled).
  final double? defaultValue;

  /// Called with the committed value (null when emptied): on blur, Enter,
  /// a button, a key or the wheel, not on every keystroke.
  final ValueChanged<double?>? onChanged;

  /// The smallest value; committed values are clamped to it.
  final double? minValue;

  /// The largest value; committed values are clamped to it.
  final double? maxValue;

  /// The step of the buttons, keys and wheel; when set, committed values
  /// also snap to it. Defaults to 1 (0.01 for percentages).
  final double? step;

  /// How the value is formatted (`formatOptions`).
  final HeroNumberFormatOptions? formatOptions;

  /// An intl format used instead of [formatOptions] (as on `HeroSlider`).
  final NumberFormat? numberFormat;

  /// The locale of the format; defaults to the app locale.
  final Locale? locale;

  /// Visual variant.
  final HeroFieldVariant variant;

  /// Whether the field and its group take the full available width.
  final bool fullWidth;

  /// Gap between the parts; defaults to 4 (`gap-1`).
  final double? spacing;

  /// Focus node of the input; when null the field owns one.
  final FocusNode? focusNode;

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Whether the value can be read but not changed.
  final bool isReadOnly;

  /// Whether a value is required.
  final bool isRequired;

  /// Overrides the displayed validation: true invalid, false valid, null
  /// lets the validation decide.
  final bool? isInvalid;

  /// Whether the mouse wheel leaves the value alone (`isWheelDisabled`).
  final bool isWheelDisabled;

  /// The name of the value in the data a [HeroForm] submits.
  final String? name;

  /// Custom validation (`validate`), called with the committed number.
  final FormFieldValidator<double>? validator;

  /// When errors show and whether they block submission; null inherits the
  /// [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors, shown until the user edits the field.
  final List<String>? validationErrors;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<double>? onSaved;

  /// When the native behaviour shows errors without a commit.
  final AutovalidateMode? autovalidateMode;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Whether to focus the input when first built.
  final bool autofocus;

  /// Accessibility label of the input; defaults to the label text.
  final String? semanticLabel;

  /// Accessibility label of the increment button.
  final String incrementLabel;

  /// Accessibility label of the decrement button.
  final String decrementLabel;

  @override
  State<HeroNumberField> createState() => _HeroNumberFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(DoubleProperty('value', value, defaultValue: null))
      ..add(DoubleProperty('minValue', minValue, defaultValue: null))
      ..add(DoubleProperty('maxValue', maxValue, defaultValue: null))
      ..add(DoubleProperty('step', step, defaultValue: null))
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
      );
  }
}

class _HeroNumberFieldState extends State<HeroNumberField> {
  final TextEditingController _controller = TextEditingController();
  FocusNode? _ownFocusNode;
  FocusNode? _listenedFocusNode;
  HeroNumberFormatter? _formatter;
  Object? _formatterKey;
  String _defaultText = '';

  /// The committed value of an uncontrolled field (NaN while empty).
  late double _uncontrolledValue = widget.defaultValue ?? double.nan;

  bool _scopeDisabled = false;

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroNumberField'));

  bool get _isControlled => widget.value != null;

  /// The committed value (React Aria's `numberValue`).
  double get numberValue => _isControlled ? widget.value! : _uncontrolledValue;

  HeroNumberFormatter get formatter => _formatter!;

  bool get isDisabled => widget.isDisabled || _scopeDisabled;

  bool get isReadOnly => widget.isReadOnly;

  double? get minValue => widget.minValue;

  double? get maxValue => widget.maxValue;

  /// The step of the buttons, keys and wheel (React Aria's `clampStep`).
  double get clampStep => widget.step ?? (formatter.isPercent ? 0.01 : 1);

  /// The number currently typed (React Aria's `parsedValue`).
  double get parsedValue => formatter.parse(_controller.text);

  TextEditingController get controller => _controller;

  FocusNode get focusNode => _focusNode;

  @override
  void initState() {
    super.initState();
    _attachFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scopeDisabled = HeroDisabledScope.of(context);
    final bool first = _formatter == null;
    final bool changed = _resolveFormatter();
    if (first) {
      _defaultText = formatter.format(widget.defaultValue ?? double.nan);
      _controller.text = formatter.format(numberValue);
    } else if (changed) {
      // The app locale changed.
      _setText(formatter.format(numberValue));
    }
  }

  @override
  void didUpdateWidget(HeroNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attachFocus();
    final bool formatChanged = _resolveFormatter();
    final double? value = widget.value;
    final bool valueChanged =
        value != null && !_same(value, oldWidget.value ?? double.nan);
    if (formatChanged || valueChanged) {
      _setText(formatter.format(numberValue));
    }
  }

  @override
  void dispose() {
    _listenedFocusNode?.removeListener(_handleFocusChanged);
    _controller.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _attachFocus() {
    final FocusNode node = _focusNode;
    if (identical(node, _listenedFocusNode)) return;
    _listenedFocusNode?.removeListener(_handleFocusChanged);
    node.addListener(_handleFocusChanged);
    _listenedFocusNode = node;
  }

  /// Returns whether the formatter changed.
  bool _resolveFormatter() {
    final String? locale = _localeName();
    final Object key = Object.hash(
      widget.numberFormat,
      widget.formatOptions,
      locale,
    );
    if (_formatter != null && key == _formatterKey) return false;
    _formatterKey = key;
    final NumberFormat? numberFormat = widget.numberFormat;
    _formatter = numberFormat != null
        ? HeroNumberFormatter.fromNumberFormat(numberFormat)
        : HeroNumberFormatter(
            widget.formatOptions ?? const HeroNumberFormatOptions(),
            locale: locale,
          );
    return true;
  }

  String? _localeName() {
    final Locale? locale =
        widget.locale ?? Localizations.maybeLocaleOf(context);
    if (locale == null) return null;
    return Intl.verifiedLocale(
      locale.toString(),
      NumberFormat.localeExists,
      onFailure: (_) => null,
    );
  }

  static bool _same(double a, double b) => a == b || (a.isNaN && b.isNaN);

  void _setText(String text) {
    if (_controller.text == text) return;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _handleFocusChanged() {
    // Commit on blur, like React Aria's `onBlur: commit`.
    if (!_focusNode.hasFocus) commit();
    if (widget.builder != null && mounted) setState(() {});
  }

  /// Updates the committed value and notifies the owner.
  void _setNumberValue(double value) {
    if (_same(value, numberValue)) return;
    if (!_isControlled) {
      setState(() => _uncontrolledValue = value);
      _setText(formatter.format(value));
    }
    widget.onChanged?.call(value.isNaN ? null : value);
  }

  /// Parses, clamps, snaps and reformats the typed text (React Aria's
  /// `commit`).
  void commit() {
    final String text = _controller.text;
    if (text.isEmpty) {
      _setNumberValue(double.nan);
      _setText(_isControlled ? formatter.format(numberValue) : '');
      return;
    }
    final double parsed = parsedValue;
    if (parsed.isNaN) {
      _setText(formatter.format(numberValue));
      return;
    }
    final double? step = widget.step;
    double clamped = step == null
        ? parsed.clamp(
            minValue ?? double.negativeInfinity,
            maxValue ?? double.infinity,
          )
        : heroSnapValueToStep(parsed, minValue, maxValue, step);
    clamped = formatter.parse(formatter.format(clamped));
    _setNumberValue(clamped);
    _setText(formatter.format(_isControlled ? numberValue : clamped));
  }

  double _safeNextStep(bool increment, double? minMax) {
    final double previous = parsedValue;
    final double step = clampStep;
    if (previous.isNaN) {
      return heroSnapValueToStep(minMax ?? 0, minValue, maxValue, step);
    }
    final double snapped = heroSnapValueToStep(
      previous,
      minValue,
      maxValue,
      step,
    );
    if ((increment && snapped > previous) ||
        (!increment && snapped < previous)) {
      return snapped;
    }
    return heroSnapValueToStep(
      heroDecimalOperation(increment, previous, step),
      minValue,
      maxValue,
      step,
    );
  }

  /// The value one step up from the typed value.
  double get nextIncrement => _safeNextStep(true, minValue);

  /// The value one step down from the typed value.
  double get nextDecrement => _safeNextStep(false, maxValue);

  /// Steps up and commits (React Aria's `increment`).
  void increment() => _step(nextIncrement);

  /// Steps down and commits (React Aria's `decrement`).
  void decrement() => _step(nextDecrement);

  void _step(double value) {
    if (!canChange) return;
    if (_same(value, numberValue)) _setText(formatter.format(value));
    _setNumberValue(value);
  }

  /// Goes to the maximum (End).
  void incrementToMax() {
    final double? max = maxValue;
    if (max == null || !canChange) return;
    _step(heroSnapValueToStep(max, minValue, max, clampStep));
  }

  /// Goes to the minimum (Home).
  void decrementToMin() {
    final double? min = minValue;
    if (min == null || !canChange) return;
    _step(min);
  }

  /// Whether the value can change at all.
  bool get canChange => !isDisabled && !isReadOnly;

  /// Whether a step up is possible (React Aria's `canIncrement`).
  bool get canIncrement {
    if (!canChange) return false;
    final double parsed = parsedValue;
    final double? max = maxValue;
    return parsed.isNaN ||
        max == null ||
        heroSnapValueToStep(parsed, minValue, max, clampStep) > parsed ||
        heroDecimalOperation(true, parsed, clampStep) <= max;
  }

  /// Whether a step down is possible (React Aria's `canDecrement`).
  bool get canDecrement {
    if (!canChange) return false;
    final double parsed = parsedValue;
    final double? min = minValue;
    return parsed.isNaN ||
        min == null ||
        heroSnapValueToStep(parsed, min, maxValue, clampStep) < parsed ||
        heroDecimalOperation(false, parsed, clampStep) >= min;
  }

  String? _validate(String? text) {
    final double parsed = formatter.parse(text ?? '');
    return widget.validator?.call(parsed.isNaN ? null : parsed);
  }

  void _handleSaved(String? text) {
    final double value = numberValue;
    final double? number = value.isNaN ? null : value;
    widget.onSaved?.call(number);
    final String? name = widget.name;
    if (name == null || isDisabled) return;
    context.findAncestorStateOfType<HeroFormState>()?.addValue(name, number);
  }

  void _handleReset() {
    // HeroTextField restored the default text; restore the default number.
    final double value = widget.defaultValue ?? double.nan;
    if (!_isControlled) _uncontrolledValue = value;
    _setText(formatter.format(_isControlled ? numberValue : value));
    if (!_isControlled) setState(() {});
    widget.onChanged?.call(value.isNaN ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    _focusNode.canRequestFocus = !isDisabled;
    final HeroNumberFieldBuilder? builder = widget.builder;
    final HeroFormState? form = HeroForm.maybeOf(context);
    return _HeroNumberFieldScope(
      state: this,
      formatter: formatter,
      isWheelDisabled: widget.isWheelDisabled,
      incrementLabel: widget.incrementLabel,
      decrementLabel: widget.decrementLabel,
      child: HeroTextField(
        controller: _controller,
        focusNode: _focusNode,
        defaultValue: _defaultText,
        variant: widget.variant,
        fullWidth: widget.fullWidth,
        spacing: widget.spacing,
        isDisabled: widget.isDisabled,
        isReadOnly: widget.isReadOnly,
        isRequired: widget.isRequired,
        isInvalid: widget.isInvalid,
        validator: widget.validator == null ? null : _validate,
        validationBehavior: widget.validationBehavior,
        // The field submits the number itself, so the text field has no
        // name; the form's server errors for the name still apply.
        validationErrors:
            widget.validationErrors ?? form?.validationErrorsFor(widget.name),
        onSaved: _handleSaved,
        onReset: _handleReset,
        autovalidateMode: widget.autovalidateMode,
        validationMessages: widget.validationMessages,
        autofocus: widget.autofocus,
        label: widget.label,
        description: widget.description,
        errorMessage: widget.errorMessage,
        semanticLabel: widget.semanticLabel,
        builder: builder == null
            ? null
            : (BuildContext context, HeroTextFieldState state) => builder(
                context,
                HeroNumberFieldState(
                  isDisabled: state.isDisabled,
                  isInvalid: state.isInvalid,
                  isReadOnly: state.isReadOnly,
                  isRequired: state.isRequired,
                  isFocusWithin: state.isFocusWithin,
                  isFocusVisible: state.isFocusVisible,
                  validation: state.validation,
                  value: numberValue.isNaN ? null : numberValue,
                  minValue: minValue,
                  maxValue: maxValue,
                  step: widget.step,
                ),
              ),
        children: builder == null
            ? (widget.children ?? _defaultChildren())
            : null,
      ),
    );
  }

  List<Widget> _defaultChildren() {
    final String? label = widget.label;
    final String? description = widget.description;
    final String? errorMessage = widget.errorMessage;
    return <Widget>[
      if (label != null) HeroLabel.text(label),
      HeroNumberFieldGroup(
        children: <Widget>[
          if (widget.showStepper) const HeroNumberFieldDecrementButton(),
          HeroNumberFieldInput(
            placeholder: widget.placeholder,
            width: widget.inputWidth,
          ),
          if (widget.showStepper) const HeroNumberFieldIncrementButton(),
        ],
      ),
      if (description != null) HeroDescription.text(description),
      if (errorMessage != null)
        HeroFieldError.text(errorMessage)
      else
        const HeroFieldError(),
    ];
  }
}

/// Shares a [HeroNumberField]'s state with its parts.
class _HeroNumberFieldScope extends InheritedWidget {
  const _HeroNumberFieldScope({
    required this.state,
    required this.formatter,
    required this.isWheelDisabled,
    required this.incrementLabel,
    required this.decrementLabel,
    required super.child,
  });

  final _HeroNumberFieldState state;
  final HeroNumberFormatter formatter;
  final bool isWheelDisabled;
  final String incrementLabel;
  final String decrementLabel;

  static _HeroNumberFieldScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroNumberFieldScope>();

  // The parts also read live values (limits, step, value) from [state];
  // any rebuild of the field updates them.
  @override
  bool updateShouldNotify(_HeroNumberFieldScope oldWidget) => true;
}

/// Commits the validation of the field around [context] after a step, like
/// React Aria's `commitValidation`.
void _commitValidation(BuildContext context) {
  context.findAncestorStateOfType<FormFieldState<String>>()?.validate();
}

/// The box of a [HeroNumberField] (HeroUI `NumberField.Group`): the
/// decrement button, the input and the increment button in a 36 px field
/// box (`rounded-field`, `--field-background`, field shadow), 40 px per
/// button.
///
/// It shows the hover background (mouse, while not focused), the focus
/// ring while the input has focus, the invalid outline and the disabled
/// opacity, takes the field's variant and clips its parts to its corners.
/// Other widgets (for example a column of chevron buttons) are laid out
/// at their own width.
class HeroNumberFieldGroup extends StatefulWidget {
  /// Creates the group of a number field.
  const HeroNumberFieldGroup({super.key, required this.children, this.style});

  /// The parts: [HeroNumberFieldDecrementButton], [HeroNumberFieldInput],
  /// [HeroNumberFieldIncrementButton] or other widgets.
  final List<Widget> children;

  /// Visual overrides of the box (the counterpart of `className`).
  final HeroFieldStyle? style;

  @override
  State<HeroNumberFieldGroup> createState() => _HeroNumberFieldGroupState();
}

class _HeroNumberFieldGroupState extends State<HeroNumberFieldGroup> {
  bool _focusWithin = false;

  void _handleFocusWithin(bool value) {
    if (_focusWithin == value) return;
    setState(() => _focusWithin = value);
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldScope? field = HeroFieldScope.maybeOf(context);
    final bool disabled =
        (field?.isDisabled ?? false) || HeroDisabledScope.of(context);
    final OutlinedBorder shape = theme.shape(
      widget.style?.borderRadius ??
          BorderRadius.all(Radius.circular(theme.radii.field)),
    );

    final Widget row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: theme.spacing(9)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final Widget child in widget.children)
              if (child is HeroNumberFieldInput)
                Expanded(child: child)
              else
                child,
          ],
        ),
      ),
    );

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: _handleFocusWithin,
      child: IgnorePointer(
        ignoring: disabled,
        child: HeroFieldBox(
          variant: field?.variant ?? HeroFieldVariant.primary,
          isFocused: _focusWithin && !disabled,
          isInvalid: field?.isInvalid ?? false,
          isDisabled: disabled,
          style: widget.style,
          // `overflow-hidden`: the pressed button fill follows the corners.
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: shape,
              textDirection: Directionality.of(context),
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}

/// The input of a [HeroNumberField] (HeroUI `NumberField.Input`): the
/// formatted value in `text-base` (`text-sm` from the `sm` breakpoint) with
/// tabular figures, `px-3`, start-aligned, centred in the 36 px group.
///
/// It accepts only text that can become a number in the field's format,
/// commits on Enter (and submits the enclosing form) and steps with
/// ArrowUp / ArrowDown / PageUp / PageDown, Home / End and the mouse wheel
/// while focused. It is announced as an adjustable text field.
class HeroNumberFieldInput extends StatelessWidget {
  /// Creates the input of a number field.
  const HeroNumberFieldInput({
    super.key,
    this.placeholder,
    this.width,
    this.textAlign = TextAlign.start,
    this.style,
  });

  /// Text shown while the input is empty.
  final String? placeholder;

  /// Width of the input when the field shrink-wraps; defaults to the
  /// browser's default input width (192).
  final double? width;

  /// Horizontal text alignment (`text-center` in HeroUI's customization
  /// example).
  final TextAlign textAlign;

  /// Text, placeholder, caret and padding overrides.
  final HeroFieldStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroNumberFieldScope? number = _HeroNumberFieldScope.maybeOf(
      context,
    );
    final HeroFieldScope? field = HeroFieldScope.maybeOf(context);
    final double inputWidth = width ?? HeroFieldMetrics.defaultWidth(theme);
    if (number == null || field == null) {
      return SizedBox(width: inputWidth);
    }
    final bool disabled = field.isDisabled || HeroDisabledScope.of(context);
    // Presses above or below the text line focus the input too.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: disabled ? null : number.state.focusNode.requestFocus,
      child: SizedBox(
        width: inputWidth,
        child: _HeroNumberFieldEditable(
          number: number,
          field: field,
          placeholder: placeholder,
          textAlign: textAlign,
          style: style,
        ),
      ),
    );
  }
}

class _HeroNumberFieldEditable extends StatelessWidget {
  const _HeroNumberFieldEditable({
    required this.number,
    required this.field,
    required this.placeholder,
    required this.textAlign,
    required this.style,
  });

  final _HeroNumberFieldScope number;
  final HeroFieldScope field;
  final String? placeholder;
  final TextAlign textAlign;
  final HeroFieldStyle? style;

  _HeroNumberFieldState get _state => number.state;

  void _stepWith(BuildContext context, VoidCallback action) {
    action();
    _commitValidation(context);
  }

  KeyEventResult _handleKey(BuildContext context, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!_state.canChange) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    final VoidCallback? action = switch (key) {
      LogicalKeyboardKey.arrowUp ||
      LogicalKeyboardKey.pageUp => _state.increment,
      LogicalKeyboardKey.arrowDown ||
      LogicalKeyboardKey.pageDown => _state.decrement,
      LogicalKeyboardKey.home => _state.decrementToMin,
      LogicalKeyboardKey.end => _state.incrementToMax,
      _ => null,
    };
    if (action == null) return KeyEventResult.ignored;
    _stepWith(context, action);
    return KeyEventResult.handled;
  }

  void _handlePointerSignal(BuildContext context, PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        number.isWheelDisabled ||
        !_state.canChange ||
        !_state.focusNode.hasFocus) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, (
      PointerSignalEvent event,
    ) {
      final Offset delta = (event as PointerScrollEvent).scrollDelta;
      if (delta.dy.abs() <= delta.dx.abs()) return;
      _stepWith(context, delta.dy > 0 ? _state.increment : _state.decrement);
    });
  }

  void _handleSubmitted(BuildContext context) {
    _state.commit();
    _commitValidation(context);
    // Enter submits the enclosing form, like a browser.
    context.findAncestorStateOfType<HeroFormState>()?.submit();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroNumberFormatter formatter = number.formatter;
    final bool disabled = field.isDisabled || HeroDisabledScope.of(context);
    final bool allowsNegative = _state.minValue == null || _state.minValue! < 0;
    final HeroFieldStyle? style = this.style;
    final TextStyle textStyle = const TextStyle(
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ).merge(style?.textStyle);

    return Listener(
      onPointerSignal: (PointerSignalEvent event) =>
          _handlePointerSignal(context, event),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        includeSemantics: false,
        onKeyEvent: (FocusNode node, KeyEvent event) =>
            _handleKey(context, event),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _state.controller,
          builder: (BuildContext context, TextEditingValue value, _) {
            final bool canStep = _state.canChange;
            return Center(
              child: HeroEditableText(
                controller: _state.controller,
                focusNode: _state.focusNode,
                placeholder: placeholder,
                style: textStyle,
                placeholderStyle: style?.placeholderStyle,
                cursorColor: style?.cursorColor,
                selectionColor: style?.selectionColor,
                padding:
                    style?.padding ??
                    EdgeInsetsDirectional.symmetric(
                      horizontal: theme.spacing(3),
                    ),
                textAlign: textAlign,
                keyboardType: TextInputType.numberWithOptions(
                  signed: allowsNegative,
                  decimal: formatter.maximumFractionDigits > 0,
                ),
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                isReadOnly: field.isReadOnly,
                isDisabled: disabled,
                isInvalid: field.isInvalid,
                isRequired: field.isRequired,
                inputFormatters: <TextInputFormatter>[
                  TextInputFormatter.withFunction(
                    (TextEditingValue oldValue, TextEditingValue newValue) =>
                        formatter.isValidPartial(
                          newValue.text,
                          minValue: _state.minValue,
                          maxValue: _state.maxValue,
                        )
                        ? newValue
                        : oldValue,
                  ),
                ],
                onSubmitted: (_) => _handleSubmitted(context),
                semanticLabel: field.semanticLabel,
                semanticHint: field.semanticHint,
                onSemanticsIncrease: canStep && _state.canIncrement
                    ? () => _stepWith(context, _state.increment)
                    : null,
                onSemanticsDecrease: canStep && _state.canDecrement
                    ? () => _stepWith(context, _state.decrement)
                    : null,
                semanticsIncreasedValue: formatter.format(_state.nextIncrement),
                semanticsDecreasedValue: formatter.format(_state.nextDecrement),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The increment button of a [HeroNumberField] (HeroUI
/// `NumberField.IncrementButton`): 40 px wide, full height, a 16 px plus
/// icon in `--field-foreground`, a 1 px start divider in
/// `--field-placeholder` at 15%.
///
/// Pressing it steps up (holding repeats after 400 ms, every 60 ms). It is
/// disabled at the maximum and while the field is disabled or read-only,
/// is not in the focus order and is announced as "Increase".
class HeroNumberFieldIncrementButton extends StatelessWidget {
  /// Creates the increment button; [child] replaces the plus icon.
  const HeroNumberFieldIncrementButton({
    super.key,
    this.child,
    this.width,
    this.padding,
    this.showDivider = true,
    this.style,
    this.semanticLabel,
  });

  /// A custom icon; defaults to HeroUI's plus icon.
  final Widget? child;

  /// Width of the button; defaults to 40 (`w-10`).
  final double? width;

  /// Padding around the icon.
  final EdgeInsetsGeometry? padding;

  /// Whether to draw the divider next to the input (`border-s`).
  final bool showDivider;

  /// Colors and press scale overrides (`foregroundColor` per state for
  /// `hover:text-*`).
  final HeroButtonStyle? style;

  /// Accessibility label; defaults to the field's `incrementLabel`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => _HeroNumberFieldStepButton(
    isIncrement: true,
    width: width,
    padding: padding,
    showDivider: showDivider,
    style: style,
    semanticLabel: semanticLabel,
    child: child ?? const HeroIcon(HeroIcons.plusSign),
  );
}

/// The decrement button of a [HeroNumberField] (HeroUI
/// `NumberField.DecrementButton`): like [HeroNumberFieldIncrementButton]
/// with a minus icon, a 1 px end divider and the "Decrease" label; disabled
/// at the minimum.
class HeroNumberFieldDecrementButton extends StatelessWidget {
  /// Creates the decrement button; [child] replaces the minus icon.
  const HeroNumberFieldDecrementButton({
    super.key,
    this.child,
    this.width,
    this.padding,
    this.showDivider = true,
    this.style,
    this.semanticLabel,
  });

  /// A custom icon; defaults to HeroUI's minus icon.
  final Widget? child;

  /// Width of the button; defaults to 40 (`w-10`).
  final double? width;

  /// Padding around the icon.
  final EdgeInsetsGeometry? padding;

  /// Whether to draw the divider next to the input (`border-e`).
  final bool showDivider;

  /// Colors and press scale overrides.
  final HeroButtonStyle? style;

  /// Accessibility label; defaults to the field's `decrementLabel`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => _HeroNumberFieldStepButton(
    isIncrement: false,
    width: width,
    padding: padding,
    showDivider: showDivider,
    style: style,
    semanticLabel: semanticLabel,
    child: child ?? const HeroIcon(HeroIcons.minusSign),
  );
}

class _HeroNumberFieldStepButton extends StatefulWidget {
  const _HeroNumberFieldStepButton({
    required this.isIncrement,
    required this.child,
    this.width,
    this.padding,
    this.showDivider = true,
    this.style,
    this.semanticLabel,
  });

  final bool isIncrement;
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;
  final HeroButtonStyle? style;
  final String? semanticLabel;

  @override
  State<_HeroNumberFieldStepButton> createState() =>
      _HeroNumberFieldStepButtonState();
}

class _HeroNumberFieldStepButtonState
    extends State<_HeroNumberFieldStepButton> {
  Timer? _timer;

  /// Whether the current press already stepped (so the tap that ends it
  /// does not step again).
  bool _pressStepped = false;

  _HeroNumberFieldState? get _state =>
      _HeroNumberFieldScope.maybeOf(context)?.state;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _canStep {
    final _HeroNumberFieldState? state = _state;
    if (state == null) return false;
    return widget.isIncrement ? state.canIncrement : state.canDecrement;
  }

  void _stepOnce() {
    final _HeroNumberFieldState? state = _state;
    if (state == null || !_canStep) {
      _timer?.cancel();
      return;
    }
    if (widget.isIncrement) {
      state.increment();
    } else {
      state.decrement();
    }
    _commitValidation(context);
  }

  void _handlePressStart() {
    _pressStepped = true;
    final _HeroNumberFieldState? state = _state;
    // A mouse press moves the focus into the input (the button itself is
    // not focusable), so the group shows its focus ring; touch leaves the
    // keyboard closed.
    if (state != null &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional &&
        !state.focusNode.hasFocus) {
      state.focusNode.requestFocus();
    }
    _stepOnce();
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), () {
      _timer = Timer.periodic(const Duration(milliseconds: 60), (_) {
        if (mounted) _stepOnce();
      });
    });
  }

  void _handlePressEnd() => _timer?.cancel();

  void _handlePressed() {
    // Assistive technologies activate the button without a press.
    if (_pressStepped) {
      _pressStepped = false;
      return;
    }
    _stepOnce();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final _HeroNumberFieldScope? number = _HeroNumberFieldScope.maybeOf(
      context,
    );
    final HeroButtonStyle? style = widget.style;
    final String label =
        widget.semanticLabel ??
        (widget.isIncrement
            ? number?.incrementLabel ?? 'Increase'
            : number?.decrementLabel ?? 'Decrease');
    final TextEditingController? controller = number?.state.controller;

    Widget build(bool enabled) {
      return ExcludeFocus(
        child: HeroInteractable(
          isDisabled: !enabled,
          onPressStart: _handlePressStart,
          onPressEnd: _handlePressEnd,
          onPressed: _handlePressed,
          semanticsLabel: label,
          excludeSemantics: true,
          builder: (BuildContext context, HeroInteractionState state, _) {
            final Set<WidgetState> states = state.widgetStates;
            final Color background =
                style?.backgroundColor?.resolve(states) ??
                (state.isPressed
                    ? colors.fieldForeground.withValues(
                        alpha: colors.fieldForeground.a * 0.1,
                      )
                    : colors.fieldForeground.withValues(alpha: 0));
            final Color foreground =
                style?.foregroundColor?.resolve(states) ??
                colors.fieldForeground;
            final Duration duration = theme.motion.resolve(
              context,
              HeroMotion.normal,
            );
            final BorderSide divider = widget.showDivider
                ? BorderSide(
                    color: colors.fieldPlaceholder.withValues(
                      alpha: colors.fieldPlaceholder.a * 0.15,
                    ),
                    width: theme.borderWidth,
                  )
                : BorderSide.none;
            return HeroDisabledOpacity(
              disabled: state.isDisabled,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    start: widget.isIncrement ? divider : BorderSide.none,
                    end: widget.isIncrement ? BorderSide.none : divider,
                  ),
                ),
                child: HeroPressScale(
                  pressed: state.isPressed,
                  scale: style?.pressedScale ?? 0.97,
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(end: background),
                    duration: duration,
                    curve: HeroMotion.smooth,
                    builder: (BuildContext context, Color? fill, Widget? _) =>
                        ColoredBox(
                          color: fill ?? background,
                          child: SizedBox(
                            width: widget.width ?? theme.spacing(10),
                            child: Padding(
                              padding: widget.padding ?? EdgeInsets.zero,
                              child: Center(
                                child: IconTheme.merge(
                                  data: IconThemeData(
                                    size: style?.iconSize ?? theme.spacing(4),
                                    color: foreground,
                                  ),
                                  child: DefaultTextStyle.merge(
                                    style: TextStyle(color: foreground),
                                    child: widget.child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    if (controller == null) return build(false);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) =>
          build(_canStep),
    );
  }
}
