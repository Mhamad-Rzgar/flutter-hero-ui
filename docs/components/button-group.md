# ButtonGroup

Group related buttons together with consistent styling and spacing.

HeroUI docs: [heroui.com/en/docs/react/components/button-group](https://heroui.com/en/docs/react/components/button-group)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroButtonGroup(
  children: [
    HeroButton(onPressed: () {}, child: const Text('First')),
    const HeroButtonGroupSeparator(),
    HeroButton(onPressed: () {}, child: const Text('Second')),
    const HeroButtonGroupSeparator(),
    HeroButton(onPressed: () {}, child: const Text('Third')),
  ],
)
```

## Anatomy

| HeroUI | Flutter | Notes |
| --- | --- | --- |
| `ButtonGroup` | `HeroButtonGroup` | A row or column of attached buttons (`role="group"`). |
| `ButtonGroup.Separator` | `HeroButtonGroupSeparator` | Placed in `children` **between** two buttons; the following button draws the divider. HeroUI places it inside the button. |

The group passes `variant`, `size`, `isDisabled` and `fullWidth` to its buttons through
`HeroButtonGroupScope`; a button's own props win, so `isDisabled: false` re-enables a single
button of a disabled group. Only the outer corners are rounded (`rounded-3xl` on the start and
end, or top and bottom, of the group), `outline` buttons share their borders, and buttons do
not scale when pressed. A keyboard-focused button paints above its neighbours so its focus
ring is not covered.

Buttons inside a wrapper child (for example a dropdown around its trigger) also take the
group's styling. Buttons nested in another button's content do not; wrap other content that
should ignore the group in `HeroButtonGroupScope.reset`.

## Separator

The divider is a 1 px line in the button's text color at 15% opacity, half the button's height,
centred on the button's start edge (half its width on the top edge in vertical groups), with
`rounded-sm` ends. Leave the separators out for a seamless group.

## Orientation, sizes and variants

- `orientation`: `Axis.horizontal` (default) or `Axis.vertical`. Vertical groups centre their
  buttons (`items-center`).
- `size`: any `HeroSize`; no default (buttons use `md`).
- `variant`: any `HeroButtonVariant`; no default (buttons use `primary`).
- `fullWidth`: the group fills a bounded width; buttons share a row equally and stretch in a
  column.

## Examples

### Variants

```dart
HeroButtonGroup(
  variant: HeroButtonVariant.secondary, // primary, tertiary, outline, ghost, danger
  children: [
    HeroButton(onPressed: () {}, child: const Text('First')),
    const HeroButtonGroupSeparator(),
    HeroButton(onPressed: () {}, child: const Text('Second')),
    const HeroButtonGroupSeparator(),
    HeroButton(onPressed: () {}, child: const Text('Third')),
  ],
)
```

### Sizes

```dart
HeroButtonGroup(
  size: HeroSize.sm, // md, lg
  variant: HeroButtonVariant.secondary,
  children: [...],
)
```

### Orientation

```dart
HeroButtonGroup(
  orientation: Axis.vertical,
  variant: HeroButtonVariant.tertiary,
  children: [
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Align left',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.textAlignLeft),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Align center',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.textAlignCenter),
    ),
  ],
)
```

### With icons

```dart
HeroButtonGroup(
  variant: HeroButtonVariant.secondary,
  children: [
    HeroButton(
      startContent: const HeroIcon(HeroIcons.globe),
      onPressed: () {},
      child: const Text('Search'),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      startContent: const HeroIcon(HeroIcons.plus),
      onPressed: () {},
      child: const Text('Add'),
    ),
  ],
)
```

### Full width

```dart
SizedBox(
  width: 400,
  child: HeroButtonGroup(fullWidth: true, children: [...]),
)
```

### Disabled

```dart
HeroButtonGroup(
  isDisabled: true,
  children: [
    HeroButton(onPressed: () {}, child: const Text('First')),
    const HeroButtonGroupSeparator(),
    HeroButton(
      isDisabled: false, // overrides the group
      onPressed: () {},
      child: const Text('Third (enabled)'),
    ),
  ],
)
```

### Without separator

```dart
HeroButtonGroup(
  children: [
    HeroButton(onPressed: () {}, child: const Text('First')),
    HeroButton(onPressed: () {}, child: const Text('Second')),
    HeroButton(onPressed: () {}, child: const Text('Third')),
  ],
)
```

The docs' split-button examples (a button with a dropdown menu, chips inside buttons) arrive
with `HeroDropdown` and `HeroChip`.

## Accessibility

- The group is a semantics container (`role="group"`) with an optional `semanticLabel`; each
  button keeps its own button semantics.
- Tab moves through the buttons in order; Enter and Space activate them.
- Separators are decorative and hidden from assistive technologies.
- Right-to-left layouts reverse the order and the rounded corners.

## API

### HeroButtonGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Buttons, optionally with `HeroButtonGroupSeparator`s between them. |
| `variant` | `HeroButtonVariant?` | `null` | Variant of buttons that do not set one. |
| `size` | `HeroSize?` | `null` | Size of buttons that do not set one. |
| `orientation` | `Axis?` | toolbar's, then `horizontal` | Row or column; inside a `HeroToolbar` it follows the toolbar. |
| `fullWidth` | `bool` | `false` | Fill a bounded width. |
| `isDisabled` | `bool` | `false` | Disable buttons that do not set `isDisabled`. |
| `semanticLabel` | `String?` | `null` | Accessibility label of the group. |

### HeroButtonGroupSeparator

No parameters. Outside a group it renders nothing.

### HeroButtonGroupScope

| Member | Description |
| --- | --- |
| `HeroButtonGroupScope.maybeOf(context)` | The group props and `HeroGroupPosition` of the enclosing item, or null. |
| `HeroButtonGroupScope.reset(child:)` | Hides the enclosing group from `child`. |

### HeroGroupPosition

| Member | Description |
| --- | --- |
| `orientation`, `index`, `count` | Where the item sits in the group. |
| `isFirst`, `isLast`, `isOnly` | Position helpers. |
| `borderRadius(radius)` | Outer-corner radii of the item. |
| `borderWidths(width)` | Outline widths with the shared sides removed. |
