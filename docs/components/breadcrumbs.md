# Breadcrumbs

Navigation breadcrumbs showing the current page's location within a hierarchy.

HeroUI reference: <https://heroui.com/en/docs/react/components/breadcrumbs>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroBreadcrumbs(
  children: <Widget>[
    HeroBreadcrumbsItem(href: '/', onPressed: goHome, child: const Text('Home')),
    HeroBreadcrumbsItem(
      href: '/products',
      onPressed: goProducts,
      child: const Text('Products'),
    ),
    const HeroBreadcrumbsItem(child: Text('Laptop')),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `Breadcrumbs` | `HeroBreadcrumbs` |
| `Breadcrumbs.Item` | `HeroBreadcrumbsItem` |

The last item is the current page (React Aria marks the last breadcrumb current). Every other
item is a link followed by the separator.

## Look

- Items are 6 px apart; a link and its separator 4 px. Items wrap onto a new line when they do
  not fit.
- Links: 14 px medium `--muted` text on a 20 px line. Hover underlines in `--muted` at 50%,
  press in `--muted` (1.5 px line, 4 px below the baseline). Keyboard focus shows the focus ring
  with a 12 px radius.
- The current page uses `--link` (the foreground), is not interactive and never fades.
- The separator is a 12 px `--muted` chevron that mirrors in right-to-left layouts.
- `isDisabled` fades every link except the current page to `--disabled-opacity`.

## Examples

### Navigation levels

```dart
HeroBreadcrumbs(
  children: <Widget>[
    HeroBreadcrumbsItem(href: '#', onPressed: open, child: const Text('Home')),
    HeroBreadcrumbsItem(href: '#', onPressed: open, child: const Text('Category')),
    const HeroBreadcrumbsItem(child: Text('Current Page')),
  ],
)
```

### Disabled state

```dart
HeroBreadcrumbs(isDisabled: true, children: <Widget>[...])
```

### Custom separator

```dart
HeroBreadcrumbs(
  separator: const HeroIcon(HeroIcons.chevronsRight),
  children: <Widget>[...],
)
```

The separator gets a 12 px icon size and the `--muted` color through the `IconTheme`. Use a
directional icon (`matchTextDirection: true`) so it mirrors in right-to-left layouts.

### Render function

```dart
HeroBreadcrumbsItem(
  onPressed: open,
  builder: (BuildContext context, HeroBreadcrumbState state) =>
      Text(state.isCurrent ? 'Laptop (current)' : 'Laptop'),
)
```

### Customization

```dart
HeroBreadcrumbsItem(
  href: '#',
  onPressed: open,
  style: HeroBreadcrumbsItemStyle(
    foregroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) =>
          states.contains(WidgetState.hovered) ? colors.accent : colors.muted,
    ),
  ),
  child: const Text('Home'),
)
```

## Accessibility

- The breadcrumbs are a navigation landmark (`SemanticsRole.navigation`) labelled
  "Breadcrumbs".
- Items are links; `href` is exposed as the link URL. The current page is selected
  (`aria-current="page"`) and disabled, so it is skipped by Tab.
- Tab moves through the links; Enter activates `onPressed`. Separators are hidden from
  assistive technologies.

## API

### HeroBreadcrumbs

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The items; the last is the current page. |
| `separator` | `Widget?` | chevron-right | Replaces the separator. |
| `isDisabled` | `bool` | `false` | Disables every link but the current page. |
| `semanticLabel` | `String` | `'Breadcrumbs'` | Landmark label. |

### HeroBreadcrumbsItem

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Label. |
| `builder` | `HeroBreadcrumbWidgetBuilder?` | `null` | Builds the label from the `HeroBreadcrumbState`. |
| `href` | `String?` | `null` | Link target announced to assistive technologies. |
| `onPressed` | `VoidCallback?` | `null` | Called when the link is pressed (navigate here). |
| `style` | `HeroBreadcrumbsItemStyle?` | `null` | Style overrides. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### HeroBreadcrumbState

`isCurrent`, `isDisabled`, `isHovered`, `isPressed`, `isFocusVisible`.

### HeroBreadcrumbsItemStyle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `foregroundColor` | `WidgetStateProperty<Color?>?` | `null` | Link color (`selected` = current page). |
| `textStyle` | `TextStyle?` | `null` | Merged into the link text style. |
