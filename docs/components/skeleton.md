# Skeleton

Skeleton is a placeholder to show a loading state and the expected shape of a
component.

HeroUI docs: [heroui.com/en/docs/react/components/skeleton](https://heroui.com/en/docs/react/components/skeleton)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
final BorderRadius rounded = BorderRadius.circular(theme.radii.lg);
SizedBox(
  width: 250,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 20,
    children: <Widget>[
      HeroSkeleton(height: 128, borderRadius: rounded),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          FractionallySizedBox(
            widthFactor: 3 / 5,
            child: HeroSkeleton(height: 12, borderRadius: rounded),
          ),
          FractionallySizedBox(
            widthFactor: 4 / 5,
            child: HeroSkeleton(height: 12, borderRadius: rounded),
          ),
        ],
      ),
    ],
  ),
)
```

## Anatomy

- `HeroSkeleton` – one placeholder block. Size it with `width` / `height`
  (without a width it fills the available width, like a block element), or
  give it a `child` to take that child's size (the child is hidden).
- `HeroSkeletonGroup` – plays one synchronized shimmer over every skeleton
  inside it (HeroUI's `skeleton--shimmer` class on a parent).

## Styles

| Part | Value |
| --- | --- |
| Block | `--surface-tertiary` at 70%, `rounded-sm` (4), clipped, ignores pointers |
| Shimmer | a `transparent → --surface-tertiary → transparent` highlight sweeping left to right, from one width before to one width after the block, 2 s linear, repeating |
| Pulse | opacity 1 → 0.5 → 1, 2 s, `cubic-bezier(0.4, 0, 0.6, 1)`, repeating |
| None | static |
| Group shimmer | `transparent → white 50% → transparent` across the whole group with `overlay` blending, drawn on the skeletons only |

## Animation types

`animationType` picks `HeroSkeletonAnimation.shimmer`, `pulse` or `none`. When
it is null the theme decides, like HeroUI's `--skeleton-animation` variable:

```dart
HeroThemeData.light().copyWith(skeletonAnimation: HeroSkeletonAnimation.pulse)
```

Nothing animates under reduced motion (`MediaQuery.disableAnimations` or
`HeroMotion(reduceMotion: true)`), and tickers pause with `TickerMode`.

## Examples

### Text content

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 12,
  children: <Widget>[
    for (final double factor in <double>[1, 5 / 6, 4 / 6, 1, 3 / 6])
      FractionallySizedBox(
        widthFactor: factor,
        child: const HeroSkeleton(height: 16),
      ),
  ],
)
```

### User profile

```dart
Row(
  spacing: 12,
  children: <Widget>[
    const HeroSkeleton(width: 40, height: 40, shape: BoxShape.circle),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          HeroSkeleton(width: 144, height: 12, borderRadius: rounded),
          HeroSkeleton(width: 96, height: 12, borderRadius: rounded),
        ],
      ),
    ),
  ],
)
```

### Single shimmer

```dart
ClipPath(
  clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl)),
  child: HeroSkeletonGroup(
    child: Row(
      spacing: 16,
      children: <Widget>[
        for (int i = 0; i < 3; i++)
          Expanded(
            child: HeroSkeleton(
              height: 96,
              animationType: HeroSkeletonAnimation.none,
              borderRadius: BorderRadius.circular(theme.radii.xl),
            ),
          ),
      ],
    ),
  ),
)
```

### Customization

`color` replaces the block color; a custom animation can be layered on top of a
static skeleton (see the gallery's "shine" example).

```dart
HeroSkeleton(
  height: 128,
  color: theme.colors.defaultColor.withValues(alpha: 0.9),
  animationType: HeroSkeletonAnimation.none,
  borderRadius: BorderRadius.circular(theme.radii.lg),
)
```

## Accessibility

Skeletons are decorative and excluded from the semantics tree. Pass
`semanticLabel` (for example "Loading") to announce one placeholder, and
announce the loading state of the region elsewhere when appropriate.

## API

### HeroSkeleton

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `width` | `double?` | fills | Fixed width. |
| `height` | `double?` | 0 / child | Fixed height. |
| `borderRadius` | `BorderRadiusGeometry?` | `rounded-sm` (4) | Corner radius. |
| `shape` | `BoxShape` | `rectangle` | `circle` for avatars. |
| `animationType` | `HeroSkeletonAnimation?` | theme (`shimmer`) | `shimmer`, `pulse` or `none`. |
| `color` | `Color?` | `--surface-tertiary` / 70% | Block color. |
| `semanticLabel` | `String?` | – | Announces the placeholder. |
| `child` | `Widget?` | – | Content the skeleton takes its size from (hidden). |

### HeroSkeletonGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Content holding skeletons. |

### Theme

| Token | Type | Default | Description |
| --- | --- | --- | --- |
| `HeroThemeData.skeletonAnimation` | `HeroSkeletonAnimation` | `shimmer` | Default animation (`--skeleton-animation`). |
