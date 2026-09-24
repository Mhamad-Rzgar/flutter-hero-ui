/// HeroUI's `Input`: the primitive single-line text input, plus the shared
/// field primitives every hero_ui text field is built from.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'hero_editable_text.dart';
import 'hero_field.dart';
import 'hero_text_constraints.dart';
import 'hero_text_input_core.dart';

export 'hero_editable_text.dart';
export 'hero_field.dart';
export 'hero_text_constraints.dart';
export 'hero_text_input_core.dart';
export 'hero_text_selection.dart';

/// A primitive single-line text input (HeroUI `Input`).
///
/// A rounded field (`rounded-field`, `px-3 py-2`) in `--field-background`
/// with the field shadow, `text-base` below the `sm` breakpoint and
/// `text-sm` from it. It shows HeroUI's hover background, a 2 px focus ring
/// with no offset, a danger outline when invalid and the disabled opacity.
/// [HeroFieldVariant.secondary] is the lower-emphasis variant for use on
/// surfaces.
///
/// The input is controlled with [value] + [onChanged], uncontrolled with
/// [defaultValue], or driven by a [controller]. It registers a
/// `FormField<String>` with the nearest `Form`: [validator], [onSaved] and
/// [autovalidateMode] work as in Flutter, and the native constraints
/// ([isRequired], [type], [minLength], [pattern], [min], [max], [step]) are
/// validated like in a browser. Inside a field root that publishes a
/// [HeroFieldScope] with a controller (a TextField), the root owns the form
/// state instead and the input inherits its variant and states.
///
/// ```dart
/// HeroInput(
///   placeholder: 'Enter your name',
///   semanticLabel: 'Name',
///   onChanged: (String value) => print(value),
/// )
/// ```
///
/// Built on [HeroTextInputCore], [HeroEditableText] and [HeroFieldBox],
/// which `HeroTextArea` and composite fields reuse.
class HeroInput extends StatelessWidget {
  /// Creates a text input.
  const HeroInput({
    super.key,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.placeholder,
    this.type = HeroInputType.text,
    this.variant,
    this.fullWidth = false,
    this.width,
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

  /// Whether the input is disabled (`disabled`).
  final bool isDisabled;

  /// Whether the text can be selected but not edited (`readOnly`).
  final bool isReadOnly;

  /// Whether a value is required (`required`).
  final bool isRequired;

  /// Forces the invalid look (`aria-invalid`).
  final bool isInvalid;

  /// The name of the value when a form collects its fields (`name`).
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

  /// Keyboard type; defaults to the one of [type].
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

  @override
  Widget build(BuildContext context) {
    return HeroTextInputCore(
      controller: controller,
      focusNode: focusNode,
      value: value,
      defaultValue: defaultValue,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      onTap: onTap,
      placeholder: placeholder,
      type: type,
      variant: variant,
      fullWidth: fullWidth,
      width: width,
      isDisabled: isDisabled,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isInvalid: isInvalid,
      name: name,
      autofillHints: autofillHints,
      maxLength: maxLength,
      minLength: minLength,
      pattern: pattern,
      min: min,
      max: max,
      step: step,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      validationMessages: validationMessages,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      autocorrect: autocorrect,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      semanticLabel: semanticLabel,
      style: style,
      debugLabel: 'HeroInput',
    );
  }
}
