# Chip

Small informational badges for displaying labels, statuses, and categories.

HeroUI reference: [Chip](https://heroui.com/en/docs/react/components/chip)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: const <Widget>[
    HeroChip(label: 'Default'),
    HeroChip(color: HeroColor.accent, label: 'Accent'),
    HeroChip(color: HeroColor.success, label: 'Success'),
    HeroChip(color: HeroColor.warning, label: 'Warning'),
    HeroChip(color: HeroColor.danger, label: 'Danger'),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `Chip` | `HeroChip` |
| `Chip.Label` | `HeroChipLabel` (a `label` string is wrapped automatically) |
| Icons before / after the label | `startContent` / `endContent` |

```dart
const HeroChip(
  startContent: HeroIcon(HeroIcons.circleDashed),
  child: HeroChipLabel(Text('Label')),
  endContent: HeroIcon(HeroIcons.circleDashed),
)
```

## Variants, colors and sizes

| Variant | Fill | Foreground |
| --- | --- | --- |
| `primary` | role color (`defaultColor` for `standard`) | role foreground |
| `secondary` (default) | `defaultColor` | role soft foreground (`defaultForeground` for `standard`) |
| `tertiary` | none | role soft foreground |
| `soft` | role soft color | role soft foreground |

Colors: `HeroColor.standard` (default), `accent`, `success`, `warning`, `danger`.

| Size | Padding | Text | Height |
| --- | --- | --- | --- |
| `sm` | 4 × 0 | 12 / 20 medium | 20 |
| `md` (default) | 8 × 2 | 12 / 20 medium | 24 |
| `lg` | 12 × 4 | 14 / 20 medium | 28 |

Chips are radius 16 (`rounded-2xl`) with 2 px between parts; the label has 2 px of horizontal
padding. Icons take the chip's foreground color and default to 16 px. With
`HeroThemeData(vibrantPalette: true)` the soft foregrounds become more saturated, like HeroUI's
`data-vibrant-palette`.

## Examples

### Statuses

```dart
const HeroChip(
  color: HeroColor.success,
  variant: HeroChipVariant.primary,
  startContent: HeroIcon(HeroIcons.circleFill, size: 6),
  label: 'Active',
)
```

### With icons

```dart
const HeroChip(
  color: HeroColor.accent,
  label: 'Label',
  endContent: HeroIcon(HeroIcons.chevronDown, size: 12),
)
```

### Customization

```dart
HeroChip(
  variant: HeroChipVariant.soft,
  color: HeroColor.warning,
  radius: theme.radii.full,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
  label: 'In review',
)
```

## Accessibility

- Chips are static text: the label is read as plain text and icons are decorative unless
  they carry a `semanticLabel`.
- `startContent` and `endContent` follow the text direction.
- Height grows with the text scale; long labels wrap instead of overflowing.

## API

### HeroChip

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String?` | `null` | Chip text, shown in a `HeroChipLabel`. |
| `child` | `Widget?` | `null` | Custom content after the label. |
| `startContent` | `Widget?` | `null` | Widget before the label. |
| `endContent` | `Widget?` | `null` | Widget after the label. |
| `color` | `HeroColor` | `standard` | Color role. |
| `variant` | `HeroChipVariant` | `secondary` | `primary`, `secondary`, `tertiary` or `soft`. |
| `size` | `HeroSize` | `md` | `sm`, `md` or `lg`. |
| `radius` | `double?` | `null` | Overrides the 16 px radius. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Overrides the size padding. |

`HeroChip.styleOf(theme, variant, color)` returns the resolved fill and foreground.

### HeroChipLabel

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The label content (positional), usually a `Text`. |
