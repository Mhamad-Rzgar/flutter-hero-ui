# Badge

Small counts, labels and status dots placed on the corner of another element.

HeroUI reference: [Badge](https://heroui.com/en/docs/react/components/badge)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 24,
  children: <Widget>[
    HeroBadgeAnchor(
      badge: const HeroBadge(label: '5', color: HeroColor.danger, size: HeroSize.sm),
      child: HeroAvatar(src: greenUrl, fallback: const Text('JD')),
    ),
    HeroBadgeAnchor(
      badge: const HeroBadge(label: 'New', color: HeroColor.accent, size: HeroSize.sm),
      child: HeroAvatar(src: orangeUrl, fallback: const Text('AB')),
    ),
    HeroBadgeAnchor(
      badge: const HeroBadge(
        color: HeroColor.success,
        placement: HeroBadgePlacement.bottomRight,
        size: HeroSize.sm,
      ),
      child: HeroAvatar(src: blueUrl, fallback: const Text('CD')),
    ),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `Badge.Anchor` | `HeroBadgeAnchor(child:, badge:)` |
| `Badge` | `HeroBadge` (no `label` or `child` makes a dot) |
| `Badge.Label` | `HeroBadgeLabel` (a `label` string is wrapped automatically) |

The anchor sizes itself to its child; the badge's corner sits on the child's corner and is
pushed outwards by a quarter of the badge's own width and height. Placements are physical
(`topRight` stays on the right in right-to-left layouts), like HeroUI's `right-0`/`left-0`.

## Variants, colors and sizes

| Variant | Fill | Foreground |
| --- | --- | --- |
| `primary` (default) | role color (`defaultColor` for `standard`) | role foreground |
| `secondary` | `defaultColor` | role soft foreground (`defaultForeground` for `standard`) |
| `soft` | role soft color | role soft foreground |

| Size | Minimum size | Radius | Text |
| --- | --- | --- | --- |
| `sm` | 16 × 16 | `xl` (12) | 10 / 1.34 medium |
| `md` (default) | 28 × 28 | `xl3` (24) | 12 / 1.34 medium |
| `lg` | 32 × 32 | `xl2` (16) | 14 / 1.43 medium |

Every badge has a 1 px outline in the `background` color (with the fill inside it), so it
separates from the element it overlaps. Labels have 2 px of horizontal padding.

## Examples

### Placements

```dart
HeroBadgeAnchor(
  badge: const HeroBadge(
    color: HeroColor.accent,
    placement: HeroBadgePlacement.bottomLeft,
    size: HeroSize.sm,
  ),
  child: avatar,
)
```

### Dot badge

```dart
const HeroBadge(
  color: HeroColor.success,
  placement: HeroBadgePlacement.bottomRight,
  size: HeroSize.sm,
  semanticLabel: 'Online',
)
```

### With content

```dart
const HeroBadge(
  color: HeroColor.accent,
  size: HeroSize.sm,
  child: HeroIcon(HeroIcons.bell, size: 10),
)
```

### Customization

```dart
const HeroBadge(
  label: '5',
  color: HeroColor.accent,
  size: HeroSize.sm,
  variant: HeroBadgeVariant.soft,
  minWidth: 20,
  style: TextStyle(
    fontWeight: HeroTypography.semibold,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  ),
)
```

## Accessibility

- `HeroBadgeAnchor` merges the anchored element and its badge into one node, so an avatar with
  a count reads as "Jane Doe, 5".
- `semanticLabel` replaces the badge text (for example "5 notifications").
- Dots without a `semanticLabel` are decorative and excluded from semantics.
- Badges grow with the text scale; the minimum sizes are kept.

## API

### HeroBadge

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String?` | `null` | Text shown in a `HeroBadgeLabel`. |
| `child` | `Widget?` | `null` | Custom content, for example an icon. |
| `color` | `HeroColor` | `standard` | Color role. |
| `variant` | `HeroBadgeVariant` | `primary` | `primary`, `secondary` or `soft`. |
| `size` | `HeroSize` | `md` | `sm`, `md` or `lg`. |
| `placement` | `HeroBadgePlacement` | `topRight` | Corner used by `HeroBadgeAnchor`. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |
| `minWidth` | `double?` | `null` | Overrides the minimum width. |
| `style` | `TextStyle?` | `null` | Extra text style merged on top. |

`HeroBadge.styleOf(theme, variant, color)` and `HeroBadge.minSizeOf(theme, size)` are helpers.

### HeroBadgeAnchor

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The element carrying the badge. |
| `badge` | `Widget` | required | Usually a `HeroBadge`; other widgets are placed top-right. |

### HeroBadgeLabel

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The label content (positional), usually a `Text`. |
