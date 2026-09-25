/// HeroUI's `Fieldset`: groups related form controls under a legend, with a
/// description, field groups and actions.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../description/description.dart';
import '../text_field/hero_field_layout.dart';

/// A group of related form controls (HeroUI `Fieldset`): a
/// [HeroFieldsetLegend], an optional `HeroDescription`, one or more
/// [HeroFieldsetGroup]s of fields and [HeroFieldsetActions], stacked with a
/// 24 px gap (`flex flex-col gap-6`).
///
/// Like a browser's `<legend>`, the legend sits on top of the fieldset's
/// content without a gap, wherever it appears in [children].
///
/// ```dart
/// HeroFieldset(
///   children: <Widget>[
///     const HeroFieldsetLegend.text('Profile Settings'),
///     const HeroDescription.text('Update your profile information.'),
///     HeroFieldsetGroup(
///       children: const <Widget>[
///         HeroTextField(label: 'Name', name: 'name', isRequired: true),
///         HeroTextField(label: 'Email', name: 'email'),
///       ],
///     ),
///     HeroFieldsetActions(
///       children: <Widget>[
///         HeroButton(
///           type: HeroButtonType.submit,
///           child: const Text('Save changes'),
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// The convenience parameters [legend], [description] and [actions] build
/// the legend, the description and the actions around [children].
///
/// [isDisabled] disables every control inside the fieldset (text fields,
/// buttons, links, toggles, ...) and dims their labels, like
/// `<fieldset disabled>`: it publishes a [HeroDisabledScope].
///
/// The fieldset fills the available width (and shrink-wraps its widest part
/// when the width is unbounded). HeroUI's `grow basis-0` in a flex row is an
/// `Expanded` around the fieldset in Flutter.
class HeroFieldset extends StatelessWidget {
  /// Creates a fieldset.
  const HeroFieldset({
    super.key,
    this.children = const <Widget>[],
    this.legend,
    this.description,
    this.actions,
    this.isDisabled = false,
    this.spacing,
    this.padding,
    this.decoration,
    this.legendStyle,
    this.semanticLabel,
  });

  /// The parts of the fieldset: a [HeroFieldsetLegend], a
  /// `HeroDescription`, [HeroFieldsetGroup]s, [HeroFieldsetActions] or any
  /// other widget.
  final List<Widget> children;

  /// Legend text, placed before [children].
  final String? legend;

  /// Description text, placed after the legend and before [children].
  final String? description;

  /// Action widgets (usually buttons), placed in a [HeroFieldsetActions]
  /// after [children].
  final List<Widget>? actions;

  /// Whether every control inside the fieldset is disabled
  /// (`<fieldset disabled>`).
  final bool isDisabled;

  /// Gap between the parts; defaults to 24 (`gap-6`).
  final double? spacing;

  /// Padding inside the fieldset's [decoration] (none by default).
  final EdgeInsetsGeometry? padding;

  /// Decoration painted behind the fieldset (none by default), the
  /// counterpart of the border, background and ring classes of HeroUI's
  /// customization example.
  final Decoration? decoration;

  /// Style merged over the text of the [legend].
  final TextStyle? legendStyle;

  /// Accessibility label of the group; defaults to the legend text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final String? legend = this.legend;
    final String? description = this.description;
    final List<Widget>? actions = this.actions;
    final List<Widget> parts = <Widget>[
      if (legend != null) HeroFieldsetLegend.text(legend, style: legendStyle),
      if (description != null) HeroDescription.text(description),
      ...children,
      if (actions != null) HeroFieldsetActions(children: actions),
    ];

    // The first legend is the fieldset's rendered legend: it is laid out
    // above the content box, so the content gap does not follow it.
    final int legendIndex = parts.indexWhere(
      (Widget part) => part is HeroFieldsetLegend,
    );
    final HeroFieldsetLegend? legendPart = legendIndex < 0
        ? null
        : parts.removeAt(legendIndex) as HeroFieldsetLegend;
    final String? label = semanticLabel ?? legendPart?.data;

    Widget result = HeroFieldLayout(
      spacing: spacing ?? theme.spacing(6),
      fullWidth: true,
      children: parts,
    );
    if (legendPart != null) {
      result = HeroFieldLayout(
        spacing: 0,
        fullWidth: true,
        children: <Widget>[
          // The legend names the group, which announces it.
          if (label != null)
            ExcludeSemantics(child: legendPart)
          else
            legendPart,
          result,
        ],
      );
    }

    final EdgeInsetsGeometry? padding = this.padding;
    if (padding != null) result = Padding(padding: padding, child: result);
    final Decoration? decoration = this.decoration;
    if (decoration != null) {
      result = DecoratedBox(decoration: decoration, child: result);
    }
    if (isDisabled) result = HeroDisabledScope(child: result);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: result,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('legend', legend, defaultValue: null))
      ..add(StringProperty('description', description, defaultValue: null))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(DoubleProperty('spacing', spacing, defaultValue: null));
  }
}

/// The legend of a [HeroFieldset] (HeroUI `Fieldset.Legend`): `text-base
/// font-medium` in `--foreground`.
class HeroFieldsetLegend extends StatelessWidget {
  /// Creates a legend showing [child].
  const HeroFieldsetLegend({super.key, required Widget this.child, this.style})
    : data = null;

  /// Creates a legend showing [data].
  const HeroFieldsetLegend.text(String this.data, {super.key, this.style})
    : child = null;

  /// The legend content (text widgets inherit the legend style).
  final Widget? child;

  /// The legend text, for [HeroFieldsetLegend.text]. It also names the
  /// fieldset for assistive technologies.
  final String? data;

  /// Style merged over the legend style (the counterpart of `className`).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography
        .style(HeroFontSize.base, weight: HeroTypography.medium)
        .copyWith(color: theme.colors.foreground)
        .merge(style?.copyWith(inherit: true));
    final String? data = this.data;
    if (data != null) return Text(data, style: textStyle);
    return DefaultTextStyle.merge(style: textStyle, child: child!);
  }
}

/// A group of fields inside a [HeroFieldset] (HeroUI `Fieldset.Group`, also
/// exported as `FieldGroup`): full width, 16 px between the fields
/// (`space-y-4`).
///
/// Each field is stretched to the group's width, like block-level fields in
/// CSS.
class HeroFieldsetGroup extends StatelessWidget {
  /// Groups [children].
  const HeroFieldsetGroup({super.key, required this.children, this.spacing});

  /// The fields.
  final List<Widget> children;

  /// Vertical gap between the fields; defaults to 16 (`space-y-4`).
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return HeroFieldLayout(
      spacing: spacing ?? HeroTheme.of(context).spacing(4),
      fullWidth: true,
      children: children,
    );
  }
}

/// HeroUI's `FieldGroup` export: the same widget as [HeroFieldsetGroup].
typedef HeroFieldGroup = HeroFieldsetGroup;

/// The action bar of a [HeroFieldset] (HeroUI `Fieldset.Actions`): a row
/// of buttons, vertically centred, 8 px apart, with 4 px of top padding
/// (`flex items-center gap-2 pt-1`).
///
/// Actions that do not fit wrap onto another line instead of overflowing.
class HeroFieldsetActions extends StatelessWidget {
  /// Lays out [children] as fieldset actions.
  const HeroFieldsetActions({
    super.key,
    required this.children,
    this.spacing,
    this.alignment = WrapAlignment.start,
    this.padding,
  });

  /// The actions, usually buttons.
  final List<Widget> children;

  /// Gap between the actions; defaults to 8 (`gap-2`).
  final double? spacing;

  /// Horizontal alignment of the actions (`justify-*`).
  final WrapAlignment alignment;

  /// Padding around the actions; defaults to 4 at the top (`pt-1`).
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double gap = spacing ?? theme.spacing(2);
    return Padding(
      padding: padding ?? EdgeInsetsDirectional.only(top: theme.spacing(1)),
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        alignment: alignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}
