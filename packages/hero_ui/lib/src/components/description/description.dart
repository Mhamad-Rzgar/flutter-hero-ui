/// HeroUI's `Description`: supplementary text for form fields.
library;

import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../input/hero_field.dart';

/// Supplementary text for a form field (HeroUI `Description`): `text-xs` in
/// `--muted`, wrapping long words.
///
/// Inside a field whose [HeroFieldScope.hideDescriptionWhenInvalid] is set
/// (TextField, SearchField, NumberField) the description is not rendered
/// while the field is invalid, so the error message takes its place.
///
/// ```dart
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   spacing: 4,
///   children: <Widget>[
///     HeroLabel.text('Email', focusNode: emailFocus),
///     HeroInput(focusNode: emailFocus, type: HeroInputType.email),
///     HeroDescription.text("We'll never share your email with anyone else."),
///   ],
/// )
/// ```
class HeroDescription extends StatelessWidget {
  /// Creates a description for [child].
  const HeroDescription({super.key, required Widget this.child, this.style})
    : data = null;

  /// Creates a description showing [data].
  const HeroDescription.text(String this.data, {super.key, this.style})
    : child = null;

  /// The description content (text widgets inherit the description style).
  final Widget? child;

  /// The description text, for [HeroDescription.text].
  final String? data;

  /// Style merged over the description style (the counterpart of
  /// `className`).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroFieldScope? scope = HeroFieldScope.maybeOf(context);
    if (scope != null && scope.isInvalid && scope.hideDescriptionWhenInvalid) {
      return const SizedBox.shrink();
    }
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography.xs
        .copyWith(color: theme.colors.muted)
        .merge(style?.copyWith(inherit: true));
    final String? data = this.data;
    final Widget content = data != null
        ? Text(data, style: textStyle, softWrap: true)
        : DefaultTextStyle.merge(style: textStyle, child: child!);
    // Inside a field that describes its control through the semantics hint,
    // the description is announced with the control instead.
    return Semantics(
      excludeSemantics: scope?.semanticHint != null,
      child: content,
    );
  }
}
