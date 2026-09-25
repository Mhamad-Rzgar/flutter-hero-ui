# Separator

Visually divide content sections.

HeroUI reference: [Separator](https://heroui.com/en/docs/react/components/separator)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    const Text('HeroUI v3 Components'),
    const Text('Beautiful, fast and modern React UI library.'),
    const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 16)),
    SizedBox(
      height: 20,
      child: Row(
        spacing: 16,
        children: const <Widget>[
          Text('Blog'),
          HeroSeparator(orientation: Axis.vertical),
          Text('Docs'),
          HeroSeparator(orientation: Axis.vertical),
          Text('Source'),
        ],
      ),
    ),
  ],
)
```

## Anatomy

`HeroSeparator` is a single widget. `HeroSeparatorScope` sets the default orientation (and
relative length) of the separators below it; a toolbar uses it to turn its separators
vertical, like React Aria's `SeparatorContext`.

## Orientation and length

| Orientation | Size |
| --- | --- |
| `Axis.horizontal` (default) | 1 px tall, fills the available width (`h-px w-full`). |
| `Axis.vertical` | 1 px wide, fills the available height (`self-stretch`), at least 8 (`min-h-2`) when the height is unbounded. |

Flutter rows do not stretch their children by default. Give a row of vertical separators a
height (`SizedBox(height: 20)` is HeroUI's `h-5`), use `CrossAxisAlignment.stretch`, or wrap
it in an `IntrinsicHeight` to make the separators as tall as the row. `length` fixes the
length instead (`h-4` is `length: 16`).

## Variants

| Variant | Color token |
| --- | --- |
| `HeroSeparatorVariant.standard` (default) | `separator` |
| `HeroSeparatorVariant.secondary` | `separatorSecondary` |
| `HeroSeparatorVariant.tertiary` | `separatorTertiary` |

Use the variant that matches the surface the separator sits on (`secondary` on a secondary
surface, and so on).

## Examples

### Variants

```dart
Column(
  spacing: 12,
  children: const <Widget>[
    Text('Default Variant'),
    HeroSeparator(),
    Text('Secondary Variant'),
    HeroSeparator(variant: HeroSeparatorVariant.secondary),
    Text('Tertiary Variant'),
    HeroSeparator(variant: HeroSeparatorVariant.tertiary),
  ],
)
```

### With surface

Match the separator variant to the surface it sits on.

```dart
HeroSurface(
  variant: HeroSurfaceVariant.secondary,
  constraints: const BoxConstraints(minWidth: 320),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: <Widget>[
      Text('Secondary Surface'),
      HeroSeparator(variant: HeroSeparatorVariant.secondary),
      Text('Surface Content'),
    ],
  ),
)
```

### Vertical

```dart
SizedBox(
  height: 20,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: const <Widget>[
      Text('Blog'),
      HeroSeparator(orientation: Axis.vertical),
      Text('Docs'),
      HeroSeparator(orientation: Axis.vertical),
      Text('Source'),
    ],
  ),
)
```

### With content

```dart
Column(
  children: <Widget>[
    const ListRow(title: 'Set Up Notifications'),
    const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 16)),
    const ListRow(title: 'Set up Browser Extension'),
    const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 16)),
    const ListRow(title: 'Mint Collectible'),
  ],
)
```

### Customization

```dart
final HeroThemeData theme = HeroTheme.of(context);

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    const Text('Account settings'),
    HeroSeparator(color: theme.colors.separatorSecondary),
    Wrap(
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        const Text('Profile'),
        HeroSeparator(orientation: Axis.vertical, length: 16, color: theme.colors.separator),
        const Text('Billing'),
        HeroSeparator(orientation: Axis.vertical, length: 16, color: theme.colors.separator),
        const Text('Security'),
      ],
    ),
  ],
)
```

The docs' "Render function" example replaces the DOM element; in Flutter the separator is
composed like any other widget, so wrap it in your own widget instead.

## Accessibility

The separator is decorative: Flutter has no separator role, so it adds nothing to the
semantics tree (React Aria renders `role="separator"`). It is not focusable and does not
change in right-to-left layouts.

## API

### HeroSeparator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `orientation` | `Axis?` | `null` | Direction of the line. Null uses the enclosing `HeroSeparatorScope`, else horizontal. |
| `variant` | `HeroSeparatorVariant` | `standard` | Color variant. |
| `margin` | `EdgeInsetsGeometry?` | `null` | Space around the line (`my-4`). |
| `length` | `double?` | `null` | Fixed length along the line; null fills the available length. |
| `color` | `Color?` | `null` | Overrides the variant color. |
| `thickness` | `double` | `1` | Width of the line. |

`HeroSeparator.colorOf(theme, variant)` returns the color of a variant.

### HeroSeparatorScope

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `orientation` | `Axis?` | `null` | Orientation of descendant separators that do not set one. |
| `lengthFactor` | `double?` | `null` | Fraction of the available length the separators cover, centered (a toolbar uses `0.5`). |
| `child` | `Widget` | required | The subtree. |
