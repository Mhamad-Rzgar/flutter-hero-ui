/// HeroUI's `Label`: the accessible label of a form control.
library;

import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../input/hero_field.dart';

/// A form label (HeroUI `Label`): `text-sm font-medium` in `--foreground`.
///
/// * [isRequired] appends a `--danger` asterisk 2 px after the text.
/// * [isDisabled] fades the label to `--disabled-opacity`.
/// * [isInvalid] colors the text `--danger`.
///
/// Each state defaults to the enclosing [HeroFieldScope], like HeroUI's
/// `[data-required] > .label`, `[data-disabled] .label` and
/// `[data-invalid] .label` selectors.
///
/// Pressing the label focuses [focusNode] (the `htmlFor` association) or runs
/// [onPressed]; inside a field it uses the field's focus node or label
/// action.
///
/// ```dart
/// final FocusNode emailFocus = FocusNode();
///
/// Column(
///   crossAxisAlignment: CrossAxisAlignment.start,
///   spacing: 4,
///   children: <Widget>[
///     HeroLabel.text('Email', focusNode: emailFocus, isRequired: true),
///     HeroInput(focusNode: emailFocus, type: HeroInputType.email),
///   ],
/// )
/// ```
class HeroLabel extends StatelessWidget {
  /// Creates a label for [child].
  const HeroLabel({
    super.key,
    required Widget this.child,
    this.isRequired,
    this.isDisabled,
    this.isInvalid,
    this.focusNode,
    this.onPressed,
    this.style,
  }) : data = null;

  /// Creates a label showing [data].
  const HeroLabel.text(
    String this.data, {
    super.key,
    this.isRequired,
    this.isDisabled,
    this.isInvalid,
    this.focusNode,
    this.onPressed,
    this.style,
  }) : child = null;

  /// The label content (text widgets inherit the label style).
  final Widget? child;

  /// The label text, for [HeroLabel.text].
  final String? data;

  /// Whether to show the required asterisk; null inherits from the field.
  final bool? isRequired;

  /// Whether the label looks disabled; null inherits from the field.
  final bool? isDisabled;

  /// Whether the label looks invalid; null inherits from the field.
  final bool? isInvalid;

  /// The focus node of the labelled control (`htmlFor`), focused on press.
  final FocusNode? focusNode;

  /// Called when the label is pressed; takes precedence over [focusNode].
  final VoidCallback? onPressed;

  /// Style merged over the label style (the counterpart of `className`).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldScope? scope = HeroFieldScope.maybeOf(context);
    final bool required =
        isRequired ?? scope?.requiredIndicatorVisible ?? false;
    final bool disabled =
        isDisabled ??
        ((scope?.isDisabled ?? false) || HeroDisabledScope.of(context));
    final bool invalid = isInvalid ?? scope?.isInvalid ?? false;

    final TextStyle textStyle = theme.typography
        .style(HeroFontSize.sm, weight: HeroTypography.medium)
        .copyWith(
          color: invalid ? theme.colors.danger : theme.colors.foreground,
        )
        .merge(style?.copyWith(inherit: true));
    final TextStyle asteriskStyle = textStyle.copyWith(
      color: theme.colors.danger,
    );

    Widget content;
    final String? data = this.data;
    if (data != null) {
      content = Text.rich(
        TextSpan(
          text: data,
          children: <InlineSpan>[
            if (required) ..._asterisk(theme, asteriskStyle),
          ],
        ),
        style: textStyle,
      );
    } else {
      content = DefaultTextStyle.merge(style: textStyle, child: child!);
      if (required) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Flexible(child: content),
            Text.rich(
              TextSpan(children: _asterisk(theme, asteriskStyle)),
              style: asteriskStyle,
            ),
          ],
        );
      }
    }

    final VoidCallback? action = disabled ? null : _resolveAction(scope);
    if (action != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action,
        excludeFromSemantics: true,
        child: content,
      );
    }

    return HeroDisabledOpacity(
      disabled: disabled,
      child: Semantics(
        // Inside a field whose control is already labelled, the label is
        // announced by the control instead.
        excludeSemantics: scope?.semanticLabel != null,
        child: content,
      ),
    );
  }

  VoidCallback? _resolveAction(HeroFieldScope? scope) {
    final VoidCallback? pressed = onPressed ?? scope?.onLabelPressed;
    if (pressed != null) return pressed;
    final FocusNode? node = focusNode ?? scope?.focusNode;
    if (node == null) return null;
    return node.requestFocus;
  }

  static List<InlineSpan> _asterisk(HeroThemeData theme, TextStyle style) =>
      <InlineSpan>[
        WidgetSpan(child: SizedBox(width: theme.spacing(0.5))),
        // The required state is announced by the control itself.
        TextSpan(text: '*', style: style, semanticsLabel: ''),
      ];
}
