import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Value formatting shared by HeroUI's range components (progress circles,
/// meters and sliders), the counterpart of React Aria's number formatter.
///
/// Formats come from `package:intl`'s [NumberFormat]; the default locale is
/// the app locale from [Localizations].
abstract final class HeroRangeFormat {
  /// Returns where [value] sits between [minValue] and [maxValue] as a
  /// fraction from 0 to 1, clamped (0 when the range is empty).
  static double fraction(double value, double minValue, double maxValue) {
    if (!(maxValue > minValue) || value.isNaN) return 0;
    return ((value - minValue) / (maxValue - minValue)).clamp(0, 1).toDouble();
  }

  /// The intl locale name of the app locale in [context] (for example
  /// `en_US`), or null when intl has no number symbols for it (intl then
  /// uses its default locale).
  static String? localeOf(BuildContext context) {
    final Locale? locale = Localizations.maybeLocaleOf(context);
    if (locale == null) return null;
    return Intl.verifiedLocale(
      locale.toString(),
      NumberFormat.localeExists,
      onFailure: (_) => null,
    );
  }

  /// The value text of a progress indicator or meter (React Aria's
  /// `valueText`).
  ///
  /// Without a [format] the fraction is formatted as a whole percentage
  /// (`{style: 'percent'}`, "60%"). A percent [format] (one whose
  /// [NumberFormat.multiplier] is not 1) also formats the fraction; any
  /// other format formats the value itself, so a currency format shows
  /// "$750.00" for a value of 750.
  static String progressText(
    BuildContext context, {
    required double value,
    required double minValue,
    required double maxValue,
    NumberFormat? format,
  }) {
    final NumberFormat formatter =
        format ?? NumberFormat.percentPattern(localeOf(context));
    if (formatter.multiplier != 1) {
      return formatter.format(fraction(value, minValue, maxValue));
    }
    return formatter.format(value.clamp(minValue, maxValue));
  }

  /// The label of a slider value (React Aria's `getThumbValueLabel`):
  /// [format] applied to [value], by default a locale-aware decimal
  /// ("30", "12.5").
  static String valueText(
    BuildContext context,
    double value, {
    NumberFormat? format,
  }) {
    final NumberFormat formatter =
        format ?? NumberFormat.decimalPattern(localeOf(context));
    return formatter.format(value);
  }

  /// A plain, locale-independent rendering of [value] for semantics
  /// properties ("0", "12.5").
  static String plain(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }
}

/// Exposes a range indicator (progress circle, progress bar or meter) to
/// assistive technologies: [label], the formatted [valueText] and the
/// range.
///
/// Determinate indicators get the progress bar role (React Aria's
/// `role="progressbar"`, also used for meters as `role="meter
/// progressbar"`) when the value text is a number or a percentage;
/// indeterminate ones are announced as a loading indicator without a
/// value.
class HeroRangeSemantics extends StatelessWidget {
  /// Creates range semantics around [child].
  const HeroRangeSemantics({
    super.key,
    required this.child,
    this.label,
    this.valueText,
    this.minValue = 0,
    this.maxValue = 100,
    this.isIndeterminate = false,
  });

  /// The accessibility label (`aria-label`).
  final String? label;

  /// The announced value, or null for none.
  final String? valueText;

  /// The minimum of the range.
  final double minValue;

  /// The maximum of the range.
  final double maxValue;

  /// Whether the progress is unknown.
  final bool isIndeterminate;

  /// The indicator.
  final Widget child;

  /// Whether [valueText] satisfies the progress bar role: a number inside
  /// the range or a percentage from 0% to 100%.
  bool get _isRoleValue {
    final String? text = valueText?.trim();
    if (text == null || text.isEmpty || !(maxValue > minValue)) return false;
    final double? number = double.tryParse(text);
    if (number != null) return number >= minValue && number <= maxValue;
    if (!text.endsWith('%')) return false;
    final double? percent = double.tryParse(text.substring(0, text.length - 1));
    return percent != null && percent >= 0 && percent <= 100;
  }

  @override
  Widget build(BuildContext context) {
    final bool progressRole = !isIndeterminate && _isRoleValue;
    return Semantics(
      container: true,
      label: label,
      value: isIndeterminate ? null : valueText,
      role: isIndeterminate
          ? SemanticsRole.loadingSpinner
          : (progressRole ? SemanticsRole.progressBar : null),
      minValue: progressRole ? HeroRangeFormat.plain(minValue) : null,
      maxValue: progressRole ? HeroRangeFormat.plain(maxValue) : null,
      child: child,
    );
  }
}
