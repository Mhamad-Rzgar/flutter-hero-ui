# Typography

A semantic typography primitive for headings, body copy, and inline code.

HeroUI reference: [Typography](https://heroui.com/en/docs/react/components/typography)

The widget is called `HeroText` because `HeroTypography` is the name of the typography token
set (`theme.typography`).

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 16,
  children: const <Widget>[
    HeroText('Build better interfaces', type: HeroTextType.h1),
    HeroText('Typography that stays semantic', type: HeroTextType.h2),
    HeroText('Composable by default', type: HeroTextType.h3),
    HeroText('Small heading', type: HeroTextType.h4),
    HeroText('HeroUI Typography maps visual types to semantic roles.'),
    HeroText(
      'Smaller muted body copy for secondary descriptions.',
      type: HeroTextType.bodySm,
      color: HeroTextColor.muted,
    ),
    HeroText('pnpm add @heroui/react', type: HeroTextType.code),
  ],
)
```

## Anatomy

| HeroUI | Flutter | Notes |
| --- | --- | --- |
| `Typography` | `HeroText` | `type`, `align`, `color`, `weight`, `truncate`. |
| `Typography.Heading` | `HeroHeading` | `level` 1–6 maps to `h1`–`h6`. |
| `Typography.Paragraph` | `HeroParagraph` | `size` `base`, `sm`, `xs` maps to `body`, `body-sm`, `body-xs`. |
| `Typography.Code` | `HeroCode` | Inline code; `HeroCode.span` places it inside running text. |
| `Typography.Prose` | `HeroProse` | Container for authored content (see below). |

Every widget also has a `.rich` constructor (except `HeroCode`) that takes an `InlineSpan`.

## Types

| Type | Style |
| --- | --- |
| `h1` | 36 / 40, semibold, tracking −0.025em |
| `h2` | 30 / 36, semibold, tracking −0.025em |
| `h3` | 24 / 32, semibold, tracking −0.025em |
| `h4` | 20 / 28, semibold, tracking −0.025em |
| `h5` | 18 / 28, semibold, tracking −0.025em |
| `h6` | 16 / 24, semibold, tracking −0.025em |
| `body` (default) | 16 / 28 |
| `bodySm` | 14 / 24 |
| `bodyXs` | 12 / 20 |
| `code` | 14 / 20 monospace on `defaultColor`, radius `md`, padding 6 × 2 |

Colors: `HeroTextColor.standard` (`foreground`, default) and `HeroTextColor.muted` (`muted`).
`weight` overrides the type's weight (`HeroTypography.normal`, `medium`, `semibold`, `bold`),
`align` takes a `TextAlign` (`start` by default) and `truncate` keeps one line with an
ellipsis. `style` merges extra text style on top, the counterpart of Tailwind text utilities.

The docs' scale captions list line heights such as 1.11 for `h1`; the CSS values (40 px for
36 px text, and so on) are used, as in the table above.

## Examples

### Primitives

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 16,
  children: const <Widget>[
    HeroHeading('Dashboard', level: 1),
    HeroParagraph('Convenience primitives are thin wrappers over HeroText.'),
    HeroParagraph(
      'Paragraph supports base, sm, and xs sizes.',
      size: HeroParagraphSize.sm,
      color: HeroTextColor.muted,
    ),
    HeroCode('Typography.Code'),
  ],
)
```

### Prose

```dart
HeroProse(
  spacing: 12,
  children: <Widget>[
    const HeroHeading('Prose title'),
    const HeroParagraph('Prose is for authored content.'),
    const HeroHeading('Section title', level: 2),
    HeroParagraph.rich(
      TextSpan(children: <InlineSpan>[
        const TextSpan(text: 'Inline code like '),
        HeroCode.span('render'),
        const TextSpan(text: ' receives the same code treatment.'),
      ]),
    ),
  ],
)
```

React's `Typography.Prose` styles raw HTML. In Flutter every prose element is a widget:

| HTML | Flutter |
| --- | --- |
| `h1`–`h6`, `p` | `HeroHeading`, `HeroParagraph` |
| `code` | `HeroCode.span` |
| `strong`, `em`, `a` | `HeroProse.stylesOf(context).strong` / `.em` / `.link` text styles |
| `blockquote` | `HeroProseBlockquote` (top margin 16, 4 px start border, muted italic) |
| `ul`, `ol` | `HeroProseList(ordered:)` (margin 16, item gap 8, start padding 24) |
| `hr` | `HeroProseDivider` (a `HeroSeparator` with 32 margins) |
| `pre` | `HeroProsePre` (radius 12, `defaultColor`, padding 16, mono 14 / 1.625, scrolls horizontally) |
| `img` | `HeroProseImage` (radius 12, margin 16) |

Plain `Text` children get the prose body style. Vertical margins of prose blocks do not
collapse the way CSS block margins do; use `spacing` for a flex-like rhythm (the docs demo
uses `gap-3`). The link style uses Flutter's underline position; CSS draws it 4 px below the
baseline (`underline-offset-4`).

### Render props

```dart
HeroText(
  'H1 visual style, h2 semantic element',
  type: HeroTextType.h1,
  semanticHeadingLevel: 2,
)
```

### Customization

```dart
HeroText(
  'CHANGELOG',
  type: HeroTextType.bodyXs,
  weight: HeroTypography.medium,
  style: TextStyle(color: theme.colors.accent, letterSpacing: 0.3),
)
```

## Accessibility

- `h1`–`h6` are exposed as headings of level 1–6 (`Semantics(header: true, headingLevel:)`).
  `semanticHeadingLevel` sets another level, or removes the heading role with `0`.
- Text scales with the platform text scale; line heights are expressed relative to the font
  size, so wrapped text never overlaps.
- `align: TextAlign.start` and `end` follow the text direction.

## API

### HeroText

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `String` | required | The text (positional). `HeroText.rich` takes an `InlineSpan` instead. |
| `type` | `HeroTextType` | `body` | Typography style. |
| `align` | `TextAlign` | `TextAlign.start` | Horizontal alignment. |
| `color` | `HeroTextColor` | `standard` | Text color. |
| `weight` | `FontWeight?` | `null` | Overrides the type's weight. |
| `truncate` | `bool` | `false` | One line with an ellipsis. |
| `semanticHeadingLevel` | `int?` | `null` | Semantic heading level; null derives it from `type`, 0 removes it. |
| `semanticsLabel` | `String?` | `null` | Alternative accessibility label. |
| `style` | `TextStyle?` | `null` | Extra style merged on top. |

`HeroText.styleOf(theme, type)` and `HeroText.colorOf(theme, color)` return the resolved
style and color.

### HeroHeading

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `String` | required | The heading (positional); `.rich` takes an `InlineSpan`. |
| `level` | `int` | `1` | Heading level 1–6. |
| `align`, `color`, `weight`, `truncate`, `style` | | | As on `HeroText`. |

### HeroParagraph

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `String` | required | The text (positional); `.rich` takes an `InlineSpan`. |
| `size` | `HeroParagraphSize` | `base` | `base`, `sm` or `xs`. |
| `align`, `color`, `weight`, `truncate`, `style` | | | As on `HeroText`. |

### HeroCode

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `String` | required | The code (positional). |
| `color`, `weight`, `truncate`, `style` | | | As on `HeroText`. |

`HeroCode.span(String data, {TextStyle? style})` returns a baseline-aligned `WidgetSpan`.

### HeroProse

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Prose elements. |
| `spacing` | `double` | `0` | Gap between elements. |

`HeroProse.stylesOf(context)` returns `HeroProseStyles` (`strong`, `em`, `link`).

### Prose elements

| Widget | Parameters |
| --- | --- |
| `HeroProseBlockquote` | `child` |
| `HeroProseList` | `children`, `ordered` (`false`) |
| `HeroProseDivider` | — |
| `HeroProsePre` | `code` (positional) |
| `HeroProseImage` | `child` |
