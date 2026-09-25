# AvatarGroup

Display a stacked or grid group of avatars with overflow counting.

HeroUI reference: [AvatarGroup](https://heroui.com/en/docs/react/components/avatar-group)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroAvatarGroup(
  children: <Widget>[
    for (final (String name, String src) in users.take(4))
      HeroAvatar(src: src, name: name),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `AvatarGroup` | `HeroAvatarGroup(children:)` |
| `AvatarGroup.Count` | `HeroAvatarGroupCount(child:)` |

With `max`, the group shows the first `max` avatars followed by a `+N` count. A
`HeroAvatarGroupCount` among the children replaces that automatic count and is never hidden
by `max`. The group's `size` (default `md`), `color` and `variant` apply to avatars and counts
that do not set their own (through `HeroAvatarScope`).

## Layout and overlap

| Mode | Look |
| --- | --- |
| Stacked (default) | Each avatar overlaps the previous one by `overlapDistance` (8); later avatars are on top. |
| `overlap: clip` (default) | A transparent crescent is cut from every avatar but the last, `seam` (2) wider than the next avatar, so the page shows through the seam. Fallback content moves 2.8 px (0.35 × overlap) away from the cut. |
| `overlap: ring` | Every avatar gets a `seam`-wide outline in the `background` color. |
| `isGrid: true` | Avatars wrap in rows with 12 px gaps, without overlap. |

The cut and the stacking follow the text direction: in right-to-left layouts the first avatar
is on the right and the cut is on each avatar's left edge.

## Examples

### Max

```dart
HeroAvatarGroup(max: 3, children: avatars) // 3 avatars and "+2"
```

### With count

```dart
HeroAvatarGroup(
  size: HeroSize.sm,
  children: <Widget>[
    ...avatars.take(3),
    const HeroAvatarGroupCount(child: Text('+9')),
  ],
)
```

### Sizes

```dart
HeroAvatarGroup(size: HeroSize.lg, children: avatars)
```

### Grid

```dart
HeroAvatarGroup(isGrid: true, max: 5, children: avatars)
```

### Overlap

```dart
HeroAvatarGroup(
  overlap: HeroAvatarGroupOverlap.ring,
  size: HeroSize.lg,
  children: avatars,
)
```

### Customization

```dart
HeroAvatarGroup(
  semanticLabel: 'Assignees',
  overlapDistance: 11.2,
  seam: 2,
  size: HeroSize.sm,
  children: <Widget>[
    ...assignees,
    const HeroAvatar(fallback: HeroIcon(HeroIcons.person)),
    const HeroAvatarGroupCount(child: Text('+3')),
  ],
)
```

## Accessibility

- The group adds no semantics of its own; each avatar keeps its label.
- With `semanticLabel` the group becomes one labelled container (HeroUI's `role="group"` with
  `aria-label`).
- Pointer hits go to the top-most (later) avatar where avatars overlap.

## API

### HeroAvatarGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Avatars, optionally with a `HeroAvatarGroupCount`. |
| `size` | `HeroSize` | `md` | Size of avatars that do not set one. |
| `color` | `HeroColor?` | `null` | Color of avatars that do not set one. |
| `variant` | `HeroAvatarVariant?` | `null` | Variant of avatars that do not set one. |
| `max` | `int?` | `null` | Maximum number of avatars shown. |
| `isGrid` | `bool` | `false` | Wraps avatars in a grid instead of stacking them. |
| `overlap` | `HeroAvatarGroupOverlap` | `clip` | `clip` or `ring`; ignored in a grid. |
| `overlapDistance` | `double?` | 8 | `--avatar-group-overlap`. |
| `seam` | `double?` | 2 | `--avatar-group-seam`. |
| `semanticLabel` | `String?` | `null` | Labels the group as one container. |

### HeroAvatarGroupCount

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Count content, such as `Text('+3')`. |
| `size` | `HeroSize?` | group size | Overrides the size. |
| `color` | `HeroColor?` | group color | Overrides the color. |
| `variant` | `HeroAvatarVariant?` | group variant | Overrides the variant. |

`HeroAvatarGroupClipper` is the crescent clipper used by `clip`, available for custom layouts.
