import 'dart:ui' show SemanticsInputType;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The HTML `type` of a HeroUI text input.
///
/// It picks the on-screen keyboard, obscures passwords, filters number
/// input and adds the browser's type validation (`typeMismatch`).
enum HeroInputType {
  /// Plain text (`type="text"`).
  text,

  /// An email address (`type="email"`).
  email,

  /// A password: the text is obscured (`type="password"`).
  password,

  /// A number (`type="number"`): only numeric characters can be typed.
  number,

  /// An absolute URL (`type="url"`).
  url,

  /// A telephone number (`type="tel"`).
  tel,

  /// A search term (`type="search"`).
  search;

  /// The on-screen keyboard for this type.
  TextInputType get keyboardType => switch (this) {
    HeroInputType.text || HeroInputType.password => TextInputType.text,
    HeroInputType.email => TextInputType.emailAddress,
    HeroInputType.number => const TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    ),
    HeroInputType.url => TextInputType.url,
    HeroInputType.tel => TextInputType.phone,
    HeroInputType.search => TextInputType.webSearch,
  };

  /// Whether the text is obscured.
  bool get obscuresText => this == HeroInputType.password;

  /// Whether autocorrect and suggestions are turned off for this type.
  bool get disablesSuggestions => switch (this) {
    HeroInputType.password ||
    HeroInputType.email ||
    HeroInputType.url ||
    HeroInputType.number ||
    HeroInputType.tel => true,
    HeroInputType.text || HeroInputType.search => false,
  };

  /// The default keyboard action for this type.
  TextInputAction? get textInputAction =>
      this == HeroInputType.search ? TextInputAction.search : null;

  /// The input type reported to assistive technologies.
  SemanticsInputType get semanticsInputType => switch (this) {
    HeroInputType.text ||
    HeroInputType.password ||
    HeroInputType.number => SemanticsInputType.text,
    HeroInputType.email => SemanticsInputType.email,
    HeroInputType.url => SemanticsInputType.url,
    HeroInputType.tel => SemanticsInputType.phone,
    HeroInputType.search => SemanticsInputType.search,
  };

  /// Formatters implied by the type (numbers accept only numeric
  /// characters, like a browser's number input).
  List<TextInputFormatter> get inputFormatters => switch (this) {
    HeroInputType.number => <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[0-9eE+\-.]')),
    ],
    _ => const <TextInputFormatter>[],
  };
}

/// The messages of the built-in (native) validation, in English by default.
///
/// They follow the browser messages HeroUI shows for its native validation.
/// Subclass it to localize or reword them.
@immutable
class HeroValidationMessages {
  /// Creates the default English messages.
  const HeroValidationMessages();

  /// A required field is empty (`valueMissing`).
  String get valueMissing => 'Please fill out this field.';

  /// The value does not match [type] (`typeMismatch` / `badInput`).
  String typeMismatch(HeroInputType type) => switch (type) {
    HeroInputType.email => 'Please enter an email address.',
    HeroInputType.url => 'Please enter a URL.',
    HeroInputType.number => 'Please enter a number.',
    _ => 'Please enter a valid value.',
  };

  /// The value is shorter than [minLength] (`tooShort`).
  String tooShort(int minLength, int length) =>
      'Please lengthen this text to $minLength characters or more '
      '(you are currently using $length characters).';

  /// The value does not match the pattern (`patternMismatch`).
  String get patternMismatch => 'Please match the requested format.';

  /// The number is below [min] (`rangeUnderflow`).
  String rangeUnderflow(num min) =>
      'Value must be greater than or equal to ${_format(min)}.';

  /// The number is above [max] (`rangeOverflow`).
  String rangeOverflow(num max) =>
      'Value must be less than or equal to ${_format(max)}.';

  /// The number is not a multiple of the step (`stepMismatch`).
  String get stepMismatch => 'Please enter a valid value.';

  static String _format(num value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}

/// The native constraints of a text input (`required`, `type`, `minLength`,
/// `pattern`, `min`, `max`, `step`), evaluated like a browser's constraint
/// validation.
///
/// Empty values only fail [isRequired]; every other rule applies to
/// non-empty values. `maxLength` is enforced while typing, not validated.
@immutable
class HeroTextConstraints {
  /// Creates a set of constraints.
  const HeroTextConstraints({
    this.isRequired = false,
    this.type = HeroInputType.text,
    this.minLength,
    this.pattern,
    this.min,
    this.max,
    this.step,
    this.messages = const HeroValidationMessages(),
  });

  /// The value must not be empty.
  final bool isRequired;

  /// The value must match the type (email, URL, number).
  final HeroInputType type;

  /// Minimum number of characters.
  final int? minLength;

  /// The whole value must match this pattern.
  final RegExp? pattern;

  /// Minimum number (number inputs).
  final num? min;

  /// Maximum number (number inputs).
  final num? max;

  /// The number must be `min + n × step` (number inputs; only checked when
  /// set).
  final num? step;

  /// The error messages.
  final HeroValidationMessages messages;

  static final RegExp _email = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
    r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  static final RegExp _number = RegExp(r'^-?(\d+|\d*\.\d+)([eE][-+]?\d+)?$');

  /// Returns the first failing constraint's message, or null when [value]
  /// is valid.
  String? validate(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return isRequired ? messages.valueMissing : null;

    switch (type) {
      case HeroInputType.email:
        if (!_email.hasMatch(text)) return messages.typeMismatch(type);
      case HeroInputType.url:
        final Uri? uri = Uri.tryParse(text.trim());
        if (uri == null || !uri.hasScheme || uri.scheme.isEmpty) {
          return messages.typeMismatch(type);
        }
      case HeroInputType.number:
        if (!_number.hasMatch(text.trim())) return messages.typeMismatch(type);
      case HeroInputType.text:
      case HeroInputType.password:
      case HeroInputType.tel:
      case HeroInputType.search:
        break;
    }

    final int? minLength = this.minLength;
    if (minLength != null && text.characters.length < minLength) {
      return messages.tooShort(minLength, text.characters.length);
    }

    final RegExp? pattern = this.pattern;
    if (pattern != null) {
      final RegExp anchored = RegExp(
        '^(?:${pattern.pattern})\$',
        caseSensitive: pattern.isCaseSensitive,
        unicode: pattern.isUnicode,
        dotAll: pattern.isDotAll,
      );
      if (!anchored.hasMatch(text)) return messages.patternMismatch;
    }

    if (type == HeroInputType.number) {
      final num number = num.parse(text.trim());
      final num? min = this.min;
      final num? max = this.max;
      final num? step = this.step;
      if (min != null && number < min) return messages.rangeUnderflow(min);
      if (max != null && number > max) return messages.rangeOverflow(max);
      if (step != null && step > 0) {
        final double steps = (number - (min ?? 0)) / step;
        if ((steps - steps.roundToDouble()).abs() > 1e-9) {
          return messages.stepMismatch;
        }
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is HeroTextConstraints &&
      other.isRequired == isRequired &&
      other.type == type &&
      other.minLength == minLength &&
      other.pattern == pattern &&
      other.min == min &&
      other.max == max &&
      other.step == step &&
      other.messages == messages;

  @override
  int get hashCode =>
      Object.hash(isRequired, type, minLength, pattern, min, max, step);
}
