/// HeroUI's `ErrorMessage`: an error message for non-form components.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// A low-level error message (HeroUI `ErrorMessage`): `text-xs` in
/// `--danger`, wrapping long words.
///
/// It is meant for components that are not form fields, such as a tag group
/// or a calendar, and is not tied to any validation: it always shows its
/// content, and nothing when there is none. Form fields use a field error
/// instead, which follows the field's validation state.
///
/// ```dart
/// HeroTagGroup(
///   label: 'Required Categories',
///   selectionMode: HeroSelectionMode.multiple,
///   selectedKeys: selected,
///   onSelectionChanged: (Set<Object> keys) => setState(() => selected = keys),
///   children: <Widget>[
///     HeroTagGroupList(children: tags),
///     const HeroDescription.text('Select at least one category'),
///     if (selected.isEmpty)
///       const HeroErrorMessage.text('Please select at least one category'),
///   ],
/// )
/// ```
///
/// The message is a polite live region, so assistive technologies announce
/// it when it appears.
class HeroErrorMessage extends StatelessWidget {
  /// Creates an error message showing [child]; a null child shows nothing.
  const HeroErrorMessage({super.key, this.child, this.style}) : data = null;

  /// Creates an error message showing [data]; an empty string shows
  /// nothing.
  const HeroErrorMessage.text(String this.data, {super.key, this.style})
    : child = null;

  /// The content (text widgets inherit the error style).
  final Widget? child;

  /// The error text, for [HeroErrorMessage.text].
  final String? data;

  /// Style merged over the error style (the counterpart of `className`).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final String? data = this.data;
    if (child == null && (data == null || data.isEmpty)) {
      return const SizedBox.shrink();
    }
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography.xs
        .copyWith(color: theme.colors.danger)
        .merge(style?.copyWith(inherit: true));
    return Semantics(
      container: true,
      liveRegion: true,
      child: data != null
          ? Text(data, style: textStyle, softWrap: true)
          : DefaultTextStyle.merge(
              style: textStyle,
              softWrap: true,
              child: IconTheme.merge(
                data: IconThemeData(color: textStyle.color),
                child: child!,
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
