import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// The `style` of [HeroNumberFormatOptions] (`Intl.NumberFormatOptions`).
enum HeroNumberFormatStyle {
  /// A plain number ("1,234.5").
  decimal,

  /// An amount of [HeroNumberFormatOptions.currency] ("€99.00").
  currency,

  /// A fraction shown as a percentage (0.5 → "50%").
  percent,

  /// A quantity of [HeroNumberFormatOptions.unit] ("1,000 kg").
  unit,
}

/// How negative currency amounts are written (`currencySign`).
enum HeroCurrencySign {
  /// With a minus sign ("-€99.00").
  standard,

  /// In parentheses ("(€99.00)").
  accounting,
}

/// How the currency is shown (`currencyDisplay`).
enum HeroCurrencyDisplay {
  /// The localized symbol ("€").
  symbol,

  /// The ISO 4217 code ("EUR 99.00").
  code,
}

/// How the unit is shown (`unitDisplay`).
enum HeroUnitDisplay {
  /// Abbreviated with a space ("1,000 kg").
  short,

  /// Spelled out ("1,000 kilograms").
  long,

  /// Abbreviated without a space ("1,000kg").
  narrow,
}

/// Number formatting options, the counterpart of the
/// `Intl.NumberFormatOptions` HeroUI's number field takes as
/// `formatOptions`.
///
/// ```dart
/// const HeroNumberFormatOptions(
///   style: HeroNumberFormatStyle.currency,
///   currency: 'EUR',
///   currencySign: HeroCurrencySign.accounting,
/// )
/// ```
///
/// Formatting and parsing use `package:intl` for the locale's digits,
/// separators and currency patterns. Unit names are English.
@immutable
class HeroNumberFormatOptions {
  /// Creates number formatting options.
  const HeroNumberFormatOptions({
    this.style = HeroNumberFormatStyle.decimal,
    this.currency,
    this.currencySign = HeroCurrencySign.standard,
    this.currencyDisplay = HeroCurrencyDisplay.symbol,
    this.unit,
    this.unitDisplay = HeroUnitDisplay.short,
    this.minimumFractionDigits,
    this.maximumFractionDigits,
    this.useGrouping = true,
  }) : assert(
         style != HeroNumberFormatStyle.currency || currency != null,
         'A currency style needs a currency code.',
       ),
       assert(
         style != HeroNumberFormatStyle.unit || unit != null,
         'A unit style needs a unit.',
       );

  /// The formatting style.
  final HeroNumberFormatStyle style;

  /// The ISO 4217 currency code of a currency style (`'EUR'`, `'USD'`).
  final String? currency;

  /// How negative currency amounts are written.
  final HeroCurrencySign currencySign;

  /// Whether the currency shows as a symbol or its code.
  final HeroCurrencyDisplay currencyDisplay;

  /// The unit of a unit style, as in `Intl` (`'kilogram'`, `'meter'`,
  /// `'celsius'`, `'kilometer-per-hour'`, ...).
  final String? unit;

  /// How the unit is shown.
  final HeroUnitDisplay unitDisplay;

  /// The minimum number of fraction digits.
  final int? minimumFractionDigits;

  /// The maximum number of fraction digits; defaults to 3 for decimals and
  /// units, 0 for percentages and the currency's digits for currencies.
  final int? maximumFractionDigits;

  /// Whether to use grouping separators ("1,000").
  final bool useGrouping;

  @override
  bool operator ==(Object other) =>
      other is HeroNumberFormatOptions &&
      other.style == style &&
      other.currency == currency &&
      other.currencySign == currencySign &&
      other.currencyDisplay == currencyDisplay &&
      other.unit == unit &&
      other.unitDisplay == unitDisplay &&
      other.minimumFractionDigits == minimumFractionDigits &&
      other.maximumFractionDigits == maximumFractionDigits &&
      other.useGrouping == useGrouping;

  @override
  int get hashCode => Object.hash(
    style,
    currency,
    currencySign,
    currencyDisplay,
    unit,
    unitDisplay,
    minimumFractionDigits,
    maximumFractionDigits,
    useGrouping,
  );
}

/// Formats numbers for display and parses what the user types, the
/// counterpart of `@internationalized/number`'s formatter and parser used
/// by React Aria's number field.
///
/// Parsing is lenient like React Aria's: currency symbols, percent signs,
/// unit names, grouping separators and spaces are optional; parentheses or
/// a minus sign make the number negative; a percent value is divided by
/// 100.
class HeroNumberFormatter {
  /// Creates a formatter from [options] for [locale] (an intl locale name
  /// such as `en_US`; null for intl's default locale).
  factory HeroNumberFormatter(
    HeroNumberFormatOptions options, {
    String? locale,
  }) {
    final String resolved = _resolveLocale(locale);
    final NumberFormat format = switch (options.style) {
      HeroNumberFormatStyle.decimal ||
      HeroNumberFormatStyle.unit => NumberFormat.decimalPattern(resolved),
      HeroNumberFormatStyle.percent => NumberFormat.percentPattern(resolved),
      HeroNumberFormatStyle.currency => _currencyFormat(options, resolved),
    };
    final int defaultMax = switch (options.style) {
      HeroNumberFormatStyle.decimal || HeroNumberFormatStyle.unit => 3,
      HeroNumberFormatStyle.percent => 0,
      HeroNumberFormatStyle.currency => format.maximumFractionDigits,
    };
    final int defaultMin = options.style == HeroNumberFormatStyle.currency
        ? format.minimumFractionDigits
        : 0;
    final int minDigits = options.minimumFractionDigits ?? defaultMin;
    final int maxDigits = math.max(
      minDigits,
      options.maximumFractionDigits ?? math.max(defaultMax, minDigits),
    );
    format
      ..minimumFractionDigits = minDigits
      ..maximumFractionDigits = maxDigits;
    if (!options.useGrouping) format.turnOffGrouping();

    String unitSuffix = '';
    String? unitSingularSuffix;
    final List<String> literals = <String>[];
    if (options.style == HeroNumberFormatStyle.unit) {
      final String unit = options.unit!;
      final _HeroUnitNames names =
          _unitNames[unit] ?? _HeroUnitNames(unit, unit, unit, unit);
      switch (options.unitDisplay) {
        case HeroUnitDisplay.short:
          unitSuffix = names.attached ? names.short : ' ${names.short}';
        case HeroUnitDisplay.narrow:
          unitSuffix = names.narrow;
        case HeroUnitDisplay.long:
          unitSuffix = ' ${names.plural}';
          unitSingularSuffix = ' ${names.singular}';
      }
      literals.addAll(<String>{
        names.short,
        names.narrow,
        names.singular,
        names.plural,
      });
    }
    return HeroNumberFormatter._(
      format,
      isPercent: options.style == HeroNumberFormatStyle.percent,
      unitSuffix: unitSuffix,
      unitSingularSuffix: unitSingularSuffix,
      extraLiterals: literals,
    );
  }

  /// Creates a formatter from an intl [NumberFormat] (for example one also
  /// used by a slider).
  factory HeroNumberFormatter.fromNumberFormat(NumberFormat format) =>
      HeroNumberFormatter._(format, isPercent: format.multiplier == 100);

  HeroNumberFormatter._(
    this.numberFormat, {
    required this.isPercent,
    this.unitSuffix = '',
    this.unitSingularSuffix,
    List<String> extraLiterals = const <String>[],
  }) : _literals = _collectLiterals(numberFormat, extraLiterals);

  /// The intl format of the numbers.
  final NumberFormat numberFormat;

  /// Whether the format shows fractions as percentages.
  final bool isPercent;

  /// The unit text after the number (a unit style).
  final String unitSuffix;

  /// The unit text after the number 1, when it differs (long units).
  final String? unitSingularSuffix;

  /// Texts that may appear around the digits and are ignored when parsing,
  /// longest first.
  final List<String> _literals;

  static String _resolveLocale(String? locale) =>
      Intl.verifiedLocale(
        locale ?? Intl.getCurrentLocale(),
        NumberFormat.localeExists,
        onFailure: (_) => 'en_US',
      ) ??
      'en_US';

  static NumberFormat _currencyFormat(
    HeroNumberFormatOptions options,
    String locale,
  ) {
    final String code = options.currency!.toUpperCase();
    final NumberFormat simple = NumberFormat.simpleCurrency(
      locale: locale,
      name: code,
    );
    final String symbol = options.currencyDisplay == HeroCurrencyDisplay.code
        ? '$code '
        : simple.currencySymbol;
    String? pattern;
    if (options.currencySign == HeroCurrencySign.accounting) {
      final String positive = simple.symbols.CURRENCY_PATTERN.split(';').first;
      pattern = '$positive;($positive)';
    }
    return NumberFormat.currency(
      locale: locale,
      name: code,
      symbol: symbol,
      decimalDigits: simple.decimalDigits,
      customPattern: pattern,
    );
  }

  static List<String> _collectLiterals(
    NumberFormat format,
    List<String> extra,
  ) {
    final Set<String> literals = <String>{
      ...extra,
      format.currencySymbol,
      format.currencySymbol.trim(),
      format.symbols.PERCENT,
      '%',
    };
    for (final String affix in <String>[
      format.positivePrefix,
      format.positiveSuffix,
      format.negativePrefix,
      format.negativeSuffix,
    ]) {
      final String stripped = affix
          .replaceAll(format.symbols.MINUS_SIGN, '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();
      if (stripped.isNotEmpty) literals.add(stripped);
    }
    literals.removeWhere((String literal) => literal.isEmpty);
    return literals.toList()
      ..sort((String a, String b) => b.length.compareTo(a.length));
  }

  /// The locale's decimal separator.
  String get decimalSeparator => numberFormat.symbols.DECIMAL_SEP;

  /// The locale's grouping separator.
  String get groupSeparator => numberFormat.symbols.GROUP_SEP;

  /// The maximum number of fraction digits shown.
  int get maximumFractionDigits => numberFormat.maximumFractionDigits;

  /// Formats [value]; NaN formats as an empty string.
  String format(double value) {
    if (value.isNaN) return '';
    final String number = numberFormat.format(value);
    if (unitSuffix.isEmpty) return number;
    final String? singular = unitSingularSuffix;
    if (singular != null && value.abs() == 1) return '$number$singular';
    return '$number$unitSuffix';
  }

  /// Removes literals and whitespace and normalizes signs; returns the
  /// remaining text and whether parentheses marked it negative.
  (String, bool) _sanitize(String text) {
    String value = text;
    for (final String literal in _literals) {
      value = value.replaceAll(literal, '');
    }
    value = value
        .replaceAll(RegExp(r'[\s  ‎‏]'), '')
        .replaceAll(RegExp('[−‒–—﹣－]'), '-');
    final String minus = numberFormat.symbols.MINUS_SIGN;
    if (minus != '-') value = value.replaceAll(minus, '-');
    bool parenthesized = false;
    if (value.startsWith('(')) {
      parenthesized = true;
      value = value.substring(1);
      if (value.endsWith(')')) value = value.substring(0, value.length - 1);
    }
    return (value, parenthesized);
  }

  /// Parses [text] as typed by the user; returns NaN when it is not a
  /// number.
  double parse(String text) {
    var (String value, bool negative) = _sanitize(text);
    if (value.startsWith('-')) {
      negative = !negative;
      value = value.substring(1);
    } else if (value.startsWith('+')) {
      value = value.substring(1);
    }
    final String group = groupSeparator;
    if (group.isNotEmpty) value = value.replaceAll(group, '');
    final String decimal = decimalSeparator;
    if (decimal != '.') value = value.replaceAll(decimal, '.');
    if (!RegExp(r'^(\d+\.?\d*|\.\d+)$').hasMatch(value)) return double.nan;
    double number = double.parse(value);
    if (negative) number = -number;
    if (isPercent) {
      number = double.parse(
        (number / 100).toStringAsFixed(maximumFractionDigits + 2),
      );
    }
    return number;
  }

  /// Whether [text] can become a number while the user keeps typing
  /// (React Aria's `isValidPartialNumber`): only digits, one decimal
  /// separator (when fractions are shown), grouping separators, the
  /// format's symbols, and a leading sign allowed by [minValue] and
  /// [maxValue].
  bool isValidPartial(String text, {double? minValue, double? maxValue}) {
    var (String value, bool negative) = _sanitize(text);
    final bool allowsNegative = minValue == null || minValue < 0;
    if (negative && !allowsNegative) return false;
    if (value.startsWith('-')) {
      if (!allowsNegative) return false;
      value = value.substring(1);
    } else if (value.startsWith('+')) {
      if (maxValue != null && maxValue <= 0) return false;
      value = value.substring(1);
    }
    final String group = groupSeparator;
    if (group.isNotEmpty && value.startsWith(group)) return false;
    final String decimal = decimalSeparator;
    if (value.contains(decimal) && maximumFractionDigits == 0) return false;
    if (group.isNotEmpty) value = value.replaceAll(group, '');
    value = value.replaceAll(RegExp(r'\d'), '');
    value = value.replaceFirst(decimal, '');
    return value.isEmpty;
  }
}

@immutable
class _HeroUnitNames {
  const _HeroUnitNames(
    this.short,
    this.narrow,
    this.singular,
    this.plural, {
    this.attached = false,
  });

  final String short;
  final String narrow;
  final String singular;
  final String plural;

  /// Whether the short form attaches without a space ("20°C").
  final bool attached;
}

/// English names of the common `Intl` units (short, narrow, singular,
/// plural).
const Map<String, _HeroUnitNames> _unitNames = <String, _HeroUnitNames>{
  'kilogram': _HeroUnitNames('kg', 'kg', 'kilogram', 'kilograms'),
  'gram': _HeroUnitNames('g', 'g', 'gram', 'grams'),
  'pound': _HeroUnitNames('lb', 'lb', 'pound', 'pounds'),
  'ounce': _HeroUnitNames('oz', 'oz', 'ounce', 'ounces'),
  'kilometer': _HeroUnitNames('km', 'km', 'kilometer', 'kilometers'),
  'meter': _HeroUnitNames('m', 'm', 'meter', 'meters'),
  'centimeter': _HeroUnitNames('cm', 'cm', 'centimeter', 'centimeters'),
  'millimeter': _HeroUnitNames('mm', 'mm', 'millimeter', 'millimeters'),
  'mile': _HeroUnitNames('mi', 'mi', 'mile', 'miles'),
  'foot': _HeroUnitNames('ft', '′', 'foot', 'feet'),
  'inch': _HeroUnitNames('in', '″', 'inch', 'inches'),
  'liter': _HeroUnitNames('L', 'L', 'liter', 'liters'),
  'milliliter': _HeroUnitNames('mL', 'mL', 'milliliter', 'milliliters'),
  'celsius': _HeroUnitNames(
    '°C',
    '°C',
    'degree Celsius',
    'degrees Celsius',
    attached: true,
  ),
  'fahrenheit': _HeroUnitNames(
    '°F',
    '°',
    'degree Fahrenheit',
    'degrees Fahrenheit',
    attached: true,
  ),
  'percent': _HeroUnitNames('%', '%', 'percent', 'percent', attached: true),
  'second': _HeroUnitNames('sec', 's', 'second', 'seconds'),
  'minute': _HeroUnitNames('min', 'm', 'minute', 'minutes'),
  'hour': _HeroUnitNames('hr', 'h', 'hour', 'hours'),
  'day': _HeroUnitNames('days', 'd', 'day', 'days'),
  'week': _HeroUnitNames('wks', 'w', 'week', 'weeks'),
  'month': _HeroUnitNames('mths', 'm', 'month', 'months'),
  'year': _HeroUnitNames('yrs', 'y', 'year', 'years'),
  'byte': _HeroUnitNames('byte', 'B', 'byte', 'bytes'),
  'kilobyte': _HeroUnitNames('kB', 'kB', 'kilobyte', 'kilobytes'),
  'megabyte': _HeroUnitNames('MB', 'MB', 'megabyte', 'megabytes'),
  'gigabyte': _HeroUnitNames('GB', 'GB', 'gigabyte', 'gigabytes'),
  'kilometer-per-hour': _HeroUnitNames(
    'km/h',
    'km/h',
    'kilometer per hour',
    'kilometers per hour',
  ),
  'mile-per-hour': _HeroUnitNames(
    'mph',
    'mph',
    'mile per hour',
    'miles per hour',
  ),
};

/// React Aria's `snapValueToStep`: rounds [value] to the nearest multiple
/// of [step] counted from [minValue] (or 0), keeps it inside
/// [minValue]..[maxValue] and rounds to the step's precision.
double heroSnapValueToStep(
  double value,
  double? minValue,
  double? maxValue,
  double step,
) {
  final double min = minValue ?? double.nan;
  final double max = maxValue ?? double.nan;
  final double remainder = (value - (min.isNaN ? 0 : min)).remainder(step);
  double snapped = _roundToStepPrecision(
    remainder.abs() * 2 >= step
        ? value + remainder.sign * (step - remainder.abs())
        : value - remainder,
    step,
  );
  if (!min.isNaN) {
    if (snapped < min) {
      snapped = min;
    } else if (!max.isNaN && snapped > max) {
      snapped =
          min + _roundToStepPrecision((max - min) / step, step).floor() * step;
    }
  } else if (!max.isNaN && snapped > max) {
    snapped = _roundToStepPrecision(max / step, step).floor() * step;
  }
  return _roundToStepPrecision(snapped, step);
}

double _roundToStepPrecision(double value, double step) {
  final String text = _jsNumberString(step);
  final int exponent = text.toLowerCase().indexOf('e-');
  int precision = 0;
  if (exponent > 0) {
    precision = (math.log(step.abs()) / math.ln10).floor().abs() + exponent;
  } else {
    final int point = text.indexOf('.');
    if (point >= 0) precision = text.length - point;
  }
  if (precision <= 0) return value;
  final double pow = math.pow(10, precision).toDouble();
  return (value * pow).roundToDouble() / pow;
}

/// Adds or subtracts [b] from [a] without floating point noise (React
/// Aria's `handleDecimalOperation`).
double heroDecimalOperation(bool add, double a, double b) {
  double result = add ? a + b : a - b;
  if (a % 1 != 0 || b % 1 != 0) {
    final int digitsA = _fractionLength(a);
    final int digitsB = _fractionLength(b);
    final double multiplier = math
        .pow(10, math.max(digitsA, digitsB))
        .toDouble();
    final double intA = (a * multiplier).roundToDouble();
    final double intB = (b * multiplier).roundToDouble();
    result = (add ? intA + intB : intA - intB) / multiplier;
  }
  return result;
}

int _fractionLength(double value) {
  final List<String> parts = _jsNumberString(value).split('.');
  return parts.length > 1 ? parts[1].length : 0;
}

/// A JavaScript-like `toString` of [value]: integers without ".0".
String _jsNumberString(double value) {
  if (value == value.roundToDouble() && value.abs() < 1e21) {
    return value.toInt().toString();
  }
  return value.toString();
}
