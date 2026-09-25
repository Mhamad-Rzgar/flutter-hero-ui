/// HeroUI's `FieldError`: the validation message of a form field.
library;

import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../input/hero_field.dart';

/// Builds the content of a [HeroFieldError] from the field's validation
/// state (HeroUI's render-function children).
typedef HeroFieldErrorBuilder =
    Widget Function(BuildContext context, HeroValidationResult validation);

/// The validation message of a form field (HeroUI `FieldError`): `text-xs`
/// in `--danger` with 4 px horizontal padding, wrapping long messages.
///
/// It is only rendered while the field is invalid. Inside a field root
/// (`HeroTextField`, or any [HeroFieldScope]) that is the field's validation
/// state; [isInvalid] overrides it, which also lets the error be used next to
/// a standalone control.
///
/// Directly inside a Checkbox, Radio or Switch ([HeroFieldHelpTextScope])
/// the error is `--muted` and indented under the label, as in HeroUI.
///
/// The content is, in order of precedence, the text of [HeroFieldError.text],
/// [builder] (called with the field's [HeroValidationResult]), [child], or
/// the field's validation messages joined with spaces. When there is nothing
/// to show, nothing is rendered.
///
/// ```dart
/// HeroTextField(
///   isInvalid: username.isNotEmpty && username.length < 3,
///   value: username,
///   onChanged: (String value) => setState(() => username = value),
///   children: const <Widget>[
///     HeroLabel.text('Username'),
///     HeroInput(placeholder: 'Enter username'),
///     HeroFieldError.text('Username must be at least 3 characters'),
///   ],
/// )
/// ```
///
/// The error is a polite live region, so assistive technologies announce it
/// when it appears.
class HeroFieldError extends StatelessWidget {
  /// Creates a field error showing [child], the result of [builder], or the
  /// field's validation messages when both are null.
  const HeroFieldError({
    super.key,
    this.child,
    this.builder,
    this.isInvalid,
    this.style,
  }) : data = null;

  /// Creates a field error showing [data].
  const HeroFieldError.text(
    String this.data, {
    super.key,
    this.isInvalid,
    this.style,
  }) : child = null,
       builder = null;

  /// The error content (text widgets inherit the error style).
  final Widget? child;

  /// Builds the content from the field's validation state; takes precedence
  /// over [child].
  final HeroFieldErrorBuilder? builder;

  /// The error text, for [HeroFieldError.text].
  final String? data;

  /// Whether the error is shown; null inherits from the field.
  final bool? isInvalid;

  /// Style merged over the error style (the counterpart of `className`).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroFieldScope? scope = HeroFieldScope.maybeOf(context);
    final bool invalid = isInvalid ?? scope?.isInvalid ?? false;
    if (!invalid) return const SizedBox.shrink();

    final HeroValidationResult validation = HeroValidationResult.invalid(
      scope?.validationErrors ?? const <String>[],
    );
    final HeroThemeData theme = HeroTheme.of(context);
    // Directly inside a Checkbox, Radio or Switch the error is muted and
    // indented under the label instead of padded.
    final HeroFieldHelpTextScope? help = HeroFieldHelpTextScope.maybeOf(
      context,
    );
    final TextStyle textStyle = theme.typography.xs
        .copyWith(
          color: help != null ? theme.colors.muted : theme.colors.danger,
        )
        .merge(style?.copyWith(inherit: true));

    final Widget content;
    final String? data = this.data;
    final HeroFieldErrorBuilder? builder = this.builder;
    if (data != null) {
      content = Text(data, style: textStyle, softWrap: true);
    } else if (builder != null || child != null) {
      content = DefaultTextStyle.merge(
        style: textStyle,
        softWrap: true,
        child: builder?.call(context, validation) ?? child!,
      );
    } else if (validation.validationErrors.isNotEmpty) {
      content = Text(
        validation.validationErrors.join(' '),
        style: textStyle,
        softWrap: true,
      );
    } else {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: help != null
            ? EdgeInsetsDirectional.only(start: help.indent)
            : EdgeInsetsDirectional.symmetric(horizontal: theme.spacing(1)),
        child: content,
      ),
    );
  }
}
