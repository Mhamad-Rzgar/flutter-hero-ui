# Toolbar

A container for interactive controls with arrow key navigation.

HeroUI docs: [heroui.com/en/docs/react/components/toolbar](https://heroui.com/en/docs/react/components/toolbar)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroToolbar(
  semanticLabel: 'Text formatting',
  children: <Widget>[
    HeroToggleButtonGroup(
      selectionMode: HeroSelectionMode.multiple,
      semanticLabel: 'Text style',
      children: const <Widget>[
        HeroToggleButton(
          id: 'bold',
          isIconOnly: true,
          semanticLabel: 'Bold',
          child: HeroIcon(HeroIcons.bold),
        ),
        HeroToggleButton(
          id: 'italic',
          isIconOnly: true,
          semanticLabel: 'Italic',
          separator: HeroToggleButtonGroupSeparator(),
          child: HeroIcon(HeroIcons.italic),
        ),
        HeroToggleButton(
          id: 'underline',
          isIconOnly: true,
          semanticLabel: 'Underline',
          separator: HeroToggleButtonGroupSeparator(),
          child: HeroIcon(HeroIcons.underline),
        ),
      ],
    ),
    const HeroSeparator(),
    HeroButtonGroup(
      variant: HeroButtonVariant.tertiary,
      children: <Widget>[
        HeroButton(isIconOnly: true, semanticLabel: 'Copy', onPressed: copy, child: const HeroIcon(HeroIcons.copy)),
        const HeroButtonGroupSeparator(),
        HeroButton(isIconOnly: true, semanticLabel: 'Cut', onPressed: cut, child: const HeroIcon(HeroIcons.scissors)),
      ],
    ),
  ],
)
```

## Anatomy

`HeroToolbar` is a single container. It publishes a `HeroToolbarScope` (HeroUI's
`ToggleButtonGroupContext`) so `HeroToggleButtonGroup` and `HeroButtonGroup` take its
orientation unless they set their own, and a `HeroSeparatorScope` that turns `HeroSeparator`s
perpendicular to the toolbar at half its thickness.

## Look

- Sized to its content (`w-fit`) with an 8 px gap. Horizontal toolbars center their controls
  vertically; vertical toolbars align them at the start.
- Separators cover half of the toolbar's height (width when vertical), centered.
- Attached (`isAttached`): a `--surface` pill with radius 24, 4 px padding and the overlay
  shadow (a faint inner hairline in dark mode).
- `gap`, `padding` and `decoration` replace the defaults for custom styles.

## Keyboard

- The toolbar is a single Tab stop: Tab enters at the control focused last (the first one at
  first) and the next Tab leaves the toolbar.
- Left / Right (Up / Down in vertical toolbars) move the focus to the previous or next control
  on screen, without wrapping. In right-to-left layouts Right still moves right.
- Home / End move to the first / last control in reading order.
- Disabled controls are skipped. Toggle button groups inside the toolbar leave the arrow keys
  to it, so the focus moves across groups.

## Examples

### Vertical

```dart
HeroToolbar(
  orientation: Axis.vertical,
  semanticLabel: 'Tools',
  children: <Widget>[
    textStyleGroup, // renders vertically
    const HeroSeparator(), // renders horizontally
    HeroButtonGroup(
      variant: HeroButtonVariant.tertiary,
      children: <Widget>[
        HeroButton(isIconOnly: true, semanticLabel: 'Undo', onPressed: undo, child: const HeroIcon(HeroIcons.arrowUturnCcwLeft)),
        const HeroButtonGroupSeparator(),
        HeroButton(isIconOnly: true, semanticLabel: 'Redo', onPressed: redo, child: const HeroIcon(HeroIcons.arrowUturnCwRight)),
      ],
    ),
  ],
)
```

### Attached

```dart
HeroToolbar(
  isAttached: true,
  semanticLabel: 'Text formatting',
  children: <Widget>[textStyleGroup, const HeroSeparator(), clipboardGroup],
)
```

### With ButtonGroup

```dart
HeroToolbar(
  semanticLabel: 'Editor toolbar',
  children: <Widget>[
    HeroButtonGroup(
      variant: HeroButtonVariant.tertiary,
      children: <Widget>[
        HeroButton(onPressed: undo, startContent: const HeroIcon(HeroIcons.arrowUturnCcwLeft), child: const Text('Undo')),
        const HeroButtonGroupSeparator(),
        HeroButton(onPressed: redo, startContent: const HeroIcon(HeroIcons.arrowUturnCwRight), child: const Text('Redo')),
      ],
    ),
    const HeroSeparator(),
    textStyleGroup,
    const HeroSeparator(),
    alignmentGroup,
  ],
)
```

### Customization

```dart
HeroToolbar(
  gap: 4,
  padding: const EdgeInsets.all(6),
  decoration: ShapeDecoration(
    color: colors.surfaceSecondary,
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: colors.border.withValues(alpha: 0.8)),
    ),
  ),
  children: <Widget>[
    HeroToggleButtonGroup(
      selectionMode: HeroSelectionMode.multiple,
      gap: 2,
      children: <Widget>[
        HeroToggleButton(
          id: 'bold',
          isIconOnly: true,
          semanticLabel: 'Bold',
          style: HeroToggleButtonStyle(
            borderRadius: BorderRadius.circular(theme.radii.lg),
            backgroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> s) => s.contains(WidgetState.selected) ? colors.accent : null,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> s) =>
                  s.contains(WidgetState.selected) ? colors.accentForeground : null,
            ),
          ),
          child: const HeroIcon(HeroIcons.bold),
        ),
        // Italic and Underline alike.
      ],
    ),
  ],
)
```

### Render function

```dart
HeroToolbar(
  orientation: Axis.vertical,
  builder: (BuildContext context, Axis orientation) => <Widget>[
    textStyleGroup,
    if (orientation == Axis.horizontal) const HeroSeparator(),
  ],
)
```

## Accessibility

- Announced as a group labelled `semanticLabel` (`aria-label`); its controls keep their own
  semantics.
- Keyboard behaviour follows React Aria's toolbar (see above).

## API

### HeroToolbar

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Controls, groups and separators. |
| `builder` | `HeroToolbarChildrenBuilder?` | `null` | Builds the children for the orientation. |
| `orientation` | `Axis` | `horizontal` | Row or column. |
| `isAttached` | `bool` | `false` | Surface pill with the overlay shadow. |
| `gap` | `double?` | `8` | Space between children. |
| `padding` | `EdgeInsetsGeometry?` | `4` when attached | Padding around the children. |
| `decoration` | `Decoration?` | pill when attached | Background. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### HeroToolbarScope

| Field | Type | Description |
| --- | --- | --- |
| `orientation` | `Axis` | The toolbar's orientation, read by button groups inside. |
