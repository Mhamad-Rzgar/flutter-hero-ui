/// HeroUI's `EmptyState`: the placeholder shown by an empty collection.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The placeholder of an empty collection (HeroUI `EmptyState`): 8 px of
/// padding around `text-sm` text in `--muted`.
///
/// It is what list boxes, tag groups, combo boxes, autocompletes and tables
/// render when they have no items (React Aria's `renderEmptyState`). Without
/// a [child] it reads "No results found", like HeroUI.
///
/// ```dart
/// HeroListBox(
///   semanticLabel: 'Results',
///   emptyStateBuilder: (BuildContext context) => const HeroEmptyState(),
///   children: const <Widget>[],
/// )
///
/// const HeroEmptyState.text('No tags')
/// ```
///
/// The text is announced politely (a live region), so screen readers report
/// it when a filter empties the collection.
class HeroEmptyState extends StatelessWidget {
  /// Creates an empty state showing [child], or [defaultText] when null.
  const HeroEmptyState({super.key, this.child, this.style, this.padding})
    : data = null;

  /// Creates an empty state showing [data].
  const HeroEmptyState.text(
    String this.data, {
    super.key,
    this.style,
    this.padding,
  }) : child = null;

  /// The text shown when neither a child nor text is given.
  static const String defaultText = 'No results found';

  /// The content; text widgets inherit the empty-state style.
  final Widget? child;

  /// The text, for [HeroEmptyState.text].
  final String? data;

  /// Style merged over the empty-state style (the counterpart of
  /// `className`).
  final TextStyle? style;

  /// Replaces the 8 px padding (`p-2`).
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography.sm
        .copyWith(color: theme.colors.muted)
        .merge(style?.copyWith(inherit: true));
    final Widget content =
        child ?? Text(data ?? defaultText, style: textStyle, softWrap: true);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.spacing(2)),
        child: DefaultTextStyle.merge(
          style: textStyle,
          child: IconTheme.merge(
            data: IconThemeData(color: textStyle.color),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('data', data, defaultValue: null));
  }
}
