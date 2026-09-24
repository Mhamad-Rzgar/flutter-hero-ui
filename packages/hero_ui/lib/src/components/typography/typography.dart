import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';

export 'prose.dart';

/// The typography styles of [HeroText] (HeroUI's `type` prop).
enum HeroTextType {
  /// `text-4xl font-semibold tracking-tight` (36 / 40).
  h1,

  /// `text-3xl font-semibold tracking-tight` (30 / 36).
  h2,

  /// `text-2xl font-semibold tracking-tight` (24 / 32).
  h3,

  /// `text-xl font-semibold tracking-tight` (20 / 28).
  h4,

  /// `text-lg font-semibold tracking-tight` (18 / 28).
  h5,

  /// `text-base font-semibold tracking-tight` (16 / 24).
  h6,

  /// `text-base leading-7` (16 / 28), the default.
  body,

  /// `text-sm leading-6` (14 / 24).
  bodySm,

  /// `text-xs leading-5` (12 / 20).
  bodyXs,

  /// Inline code: `font-mono text-sm` on a `--default` fill.
  code;

  /// The heading level (1–6) of a heading type, or null.
  int? get headingLevel => switch (this) {
    h1 => 1,
    h2 => 2,
    h3 => 3,
    h4 => 4,
    h5 => 5,
    h6 => 6,
    _ => null,
  };

  /// The heading type for [level] (1–6).
  static HeroTextType heading(int level) {
    assert(level >= 1 && level <= 6, 'Heading levels are 1 to 6.');
    return <HeroTextType>[h1, h2, h3, h4, h5, h6][level.clamp(1, 6) - 1];
  }
}

/// The text colors of [HeroText] (HeroUI's `color` prop).
enum HeroTextColor {
  /// `--foreground` (HeroUI's `default`).
  standard,

  /// `--muted`, for secondary copy.
  muted,
}

/// The sizes of a [HeroParagraph].
enum HeroParagraphSize {
  /// `body` (16 / 28).
  base,

  /// `body-sm` (14 / 24).
  sm,

  /// `body-xs` (12 / 20).
  xs,
}

/// A semantic typography primitive for headings, body copy and inline code
/// (HeroUI `Typography`).
///
/// ```dart
/// HeroText('Build better interfaces', type: HeroTextType.h1)
/// HeroText('Secondary copy', type: HeroTextType.bodySm, color: HeroTextColor.muted)
/// HeroText('pnpm add @heroui/react', type: HeroTextType.code)
/// ```
///
/// Heading types are exposed to assistive technologies as headings of the
/// matching level; [semanticHeadingLevel] decouples the semantic level from
/// the visual style (HeroUI's `render` prop).
///
/// The widget is named `HeroText` because [HeroTypography] is the name of
/// the typography token set.
class HeroText extends StatelessWidget {
  /// Creates a text with a plain string.
  const HeroText(
    String this.data, {
    super.key,
    this.type = HeroTextType.body,
    this.align = TextAlign.start,
    this.color = HeroTextColor.standard,
    this.weight,
    this.truncate = false,
    this.semanticHeadingLevel,
    this.semanticsLabel,
    this.style,
  }) : span = null;

  /// Creates a text from an [InlineSpan] (for example with inline
  /// [HeroCode.span]s).
  const HeroText.rich(
    InlineSpan this.span, {
    super.key,
    this.type = HeroTextType.body,
    this.align = TextAlign.start,
    this.color = HeroTextColor.standard,
    this.weight,
    this.truncate = false,
    this.semanticHeadingLevel,
    this.semanticsLabel,
    this.style,
  }) : data = null;

  /// The text to show; null for [HeroText.rich].
  final String? data;

  /// The rich text to show; null for the default constructor.
  final InlineSpan? span;

  /// Typography style.
  final HeroTextType type;

  /// Horizontal alignment (`start`, `center`, `end`, `justify`).
  final TextAlign align;

  /// Text color.
  final HeroTextColor color;

  /// Overrides the type's font weight (`normal`, `medium`, `semibold`,
  /// `bold` are [HeroTypography.normal] ... [HeroTypography.bold]).
  final FontWeight? weight;

  /// Truncates the text to a single line with an ellipsis.
  final bool truncate;

  /// Semantic heading level. Null derives it from [type] (h1–h6 are
  /// headings 1–6); 0 removes the heading semantics.
  final int? semanticHeadingLevel;

  /// Alternative accessibility label.
  final String? semanticsLabel;

  /// Extra style merged on top of the type's style (the equivalent of
  /// Tailwind text utilities in `className`).
  final TextStyle? style;

  /// Returns the text style of [type] in [theme], without a color.
  static TextStyle styleOf(HeroThemeData theme, HeroTextType type) =>
      switch (type) {
        HeroTextType.h1 => theme.typography.h1,
        HeroTextType.h2 => theme.typography.h2,
        HeroTextType.h3 => theme.typography.h3,
        HeroTextType.h4 => theme.typography.h4,
        HeroTextType.h5 => theme.typography.h5,
        HeroTextType.h6 => theme.typography.h6,
        HeroTextType.body => theme.typography.body,
        HeroTextType.bodySm => theme.typography.bodySm,
        HeroTextType.bodyXs => theme.typography.bodyXs,
        HeroTextType.code => theme.typography.code,
      };

  /// Returns the text color of [color] in [theme].
  static Color colorOf(HeroThemeData theme, HeroTextColor color) =>
      switch (color) {
        HeroTextColor.standard => theme.colors.foreground,
        HeroTextColor.muted => theme.colors.muted,
      };

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    TextStyle resolved = styleOf(
      theme,
      type,
    ).copyWith(color: colorOf(theme, color), fontWeight: weight);
    if (style != null) resolved = resolved.merge(style);

    Widget result = span != null
        ? Text.rich(
            span!,
            style: resolved,
            textAlign: align,
            maxLines: truncate ? 1 : null,
            softWrap: !truncate,
            overflow: truncate ? TextOverflow.ellipsis : null,
            semanticsLabel: semanticsLabel,
          )
        : Text(
            data!,
            style: resolved,
            textAlign: align,
            maxLines: truncate ? 1 : null,
            softWrap: !truncate,
            overflow: truncate ? TextOverflow.ellipsis : null,
            semanticsLabel: semanticsLabel,
          );

    if (type == HeroTextType.code) {
      result = DecoratedBox(
        decoration: ShapeDecoration(
          color: theme.colors.defaultColor,
          shape: theme.shapeAll(theme.radii.md),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing(1.5),
            vertical: theme.spacing(0.5),
          ),
          child: result,
        ),
      );
    }

    final int level = semanticHeadingLevel ?? type.headingLevel ?? 0;
    if (level > 0) {
      result = Semantics(header: true, headingLevel: level, child: result);
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('data', data, defaultValue: null))
      ..add(EnumProperty<HeroTextType>('type', type))
      ..add(EnumProperty<TextAlign>('align', align))
      ..add(EnumProperty<HeroTextColor>('color', color))
      ..add(DiagnosticsProperty<FontWeight>('weight', weight))
      ..add(FlagProperty('truncate', value: truncate, ifTrue: 'truncate'));
  }
}

/// A heading (HeroUI `Typography.Heading`): [HeroText] with the `h1`–`h6`
/// type of [level] and heading semantics of the same level.
class HeroHeading extends StatelessWidget {
  /// Creates a heading.
  const HeroHeading(
    String this.data, {
    super.key,
    this.level = 1,
    this.align = TextAlign.start,
    this.color = HeroTextColor.standard,
    this.weight,
    this.truncate = false,
    this.style,
  }) : assert(level >= 1 && level <= 6, 'Heading levels are 1 to 6.'),
       span = null;

  /// Creates a heading from an [InlineSpan].
  const HeroHeading.rich(
    InlineSpan this.span, {
    super.key,
    this.level = 1,
    this.align = TextAlign.start,
    this.color = HeroTextColor.standard,
    this.weight,
    this.truncate = false,
    this.style,
  }) : assert(level >= 1 && level <= 6, 'Heading levels are 1 to 6.'),
       data = null;

  /// The heading text; null for [HeroHeading.rich].
  final String? data;

  /// The rich heading text; null for the default constructor.
  final InlineSpan? span;

  /// Heading level, 1 to 6.
  final int level;

  /// See [HeroText.align].
  final TextAlign align;

  /// See [HeroText.color].
  final HeroTextColor color;

  /// See [HeroText.weight].
  final FontWeight? weight;

  /// See [HeroText.truncate].
  final bool truncate;

  /// See [HeroText.style].
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroTextType type = HeroTextType.heading(level);
    return span != null
        ? HeroText.rich(
            span!,
            type: type,
            align: align,
            color: color,
            weight: weight,
            truncate: truncate,
            style: style,
          )
        : HeroText(
            data!,
            type: type,
            align: align,
            color: color,
            weight: weight,
            truncate: truncate,
            style: style,
          );
  }
}

/// Body copy (HeroUI `Typography.Paragraph`): [HeroText] with the `body`,
/// `body-sm` or `body-xs` type of [size].
class HeroParagraph extends StatelessWidget {
  /// Creates a paragraph.
  const HeroParagraph(
    String this.data, {
    super.key,
    this.size = HeroParagraphSize.base,
    this.align = TextAlign.start,
    this.color = HeroTextColor.standard,
    this.weight,
    this.truncate = false,
    this.style,
  }) : span = null;

  /// Creates a paragraph from an [InlineSpan], for example with inline
  /// [HeroCode.span]s.
  const HeroParagraph.rich(
    InlineSpan this.span, {
    super.key,
    this.size = HeroParagraphSize.base,
    this.align = TextAlign.start,
    this.color = HeroTextColor.standard,
    this.weight,
    this.truncate = false,
    this.style,
  }) : data = null;

  /// The paragraph text; null for [HeroParagraph.rich].
  final String? data;

  /// The rich paragraph text; null for the default constructor.
  final InlineSpan? span;

  /// Paragraph size.
  final HeroParagraphSize size;

  /// See [HeroText.align].
  final TextAlign align;

  /// See [HeroText.color].
  final HeroTextColor color;

  /// See [HeroText.weight].
  final FontWeight? weight;

  /// See [HeroText.truncate].
  final bool truncate;

  /// See [HeroText.style].
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroTextType type = switch (size) {
      HeroParagraphSize.base => HeroTextType.body,
      HeroParagraphSize.sm => HeroTextType.bodySm,
      HeroParagraphSize.xs => HeroTextType.bodyXs,
    };
    return span != null
        ? HeroText.rich(
            span!,
            type: type,
            align: align,
            color: color,
            weight: weight,
            truncate: truncate,
            style: style,
          )
        : HeroText(
            data!,
            type: type,
            align: align,
            color: color,
            weight: weight,
            truncate: truncate,
            style: style,
          );
  }
}

/// Inline code (HeroUI `Typography.Code`): monospace text on a rounded
/// `--default` fill.
///
/// Use [HeroCode.span] to place code inside running text:
///
/// ```dart
/// HeroParagraph.rich(
///   TextSpan(children: <InlineSpan>[
///     const TextSpan(text: 'Inline code like '),
///     HeroCode.span('render'),
///     const TextSpan(text: ' gets the code treatment.'),
///   ]),
/// )
/// ```
class HeroCode extends StatelessWidget {
  /// Creates an inline code element.
  const HeroCode(
    this.data, {
    super.key,
    this.color = HeroTextColor.standard,
    this.weight,
    this.truncate = false,
    this.style,
  });

  /// The code text.
  final String data;

  /// See [HeroText.color].
  final HeroTextColor color;

  /// See [HeroText.weight].
  final FontWeight? weight;

  /// See [HeroText.truncate].
  final bool truncate;

  /// See [HeroText.style].
  final TextStyle? style;

  /// Returns an inline span showing [data] as code, aligned on the text
  /// baseline of the surrounding paragraph.
  static InlineSpan span(String data, {TextStyle? style}) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: HeroCode(data, style: style),
  );

  @override
  Widget build(BuildContext context) => HeroText(
    data,
    type: HeroTextType.code,
    color: color,
    weight: weight,
    truncate: truncate,
    style: style,
  );
}
