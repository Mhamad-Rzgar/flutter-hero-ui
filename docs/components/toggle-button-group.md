# ToggleButtonGroup

Groups multiple ToggleButtons into a unified control, allowing users to select one or multiple
options.

HeroUI reference: <https://heroui.com/en/docs/react/components/toggle-button-group>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
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
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `ToggleButtonGroup` | `HeroToggleButtonGroup` |
| `ToggleButton` (with `id`) | `HeroToggleButton(id: ...)` |
| `ToggleButtonGroup.Separator` | `HeroToggleButtonGroupSeparator`, passed as the `separator` of every button but the first |

The group owns the selection. Every button needs a unique `id`; the ids are the keys of
`selectedKeys` and `defaultSelectedKeys`. Buttons inherit the group's `size` and `isDisabled`
unless they set their own (`isDisabled: false` re-enables one button of a disabled group).

## Layout

- **Attached** (default): no gap; only the outer corners are rounded (24 px at the start and
  end, or top and bottom when vertical, mirrored in right-to-left layouts). The focus ring is
  drawn inside the button so neighbours do not cover it.
- **Detached** (`isDetached: true`): a 4 px gap, fully rounded buttons, separators hidden.
- **Separator**: 1 px line at 50% of the button's height (width when vertical), centered, in
  the button's foreground at 15% opacity, straddling the edge with the previous button.
- **Full width** (`fullWidth: true`): the group fills the available width and the buttons share
  it equally.
- Buttons do not scale down when pressed inside a group.

## Examples

### Sizes

```dart
HeroToggleButtonGroup(
  size: HeroSize.lg,
  selectionMode: HeroSelectionMode.multiple,
  children: formattingButtons,
)
```

### Orientation

```dart
HeroToggleButtonGroup(
  orientation: Axis.vertical,
  selectionMode: HeroSelectionMode.multiple,
  children: formattingButtons,
)
```

### Full width

```dart
HeroToggleButtonGroup(
  fullWidth: true,
  children: const <Widget>[
    HeroToggleButton(
      id: 'left',
      startContent: HeroIcon(HeroIcons.textAlignLeft),
      child: Text('Left'),
    ),
    HeroToggleButton(
      id: 'center',
      separator: HeroToggleButtonGroupSeparator(),
      startContent: HeroIcon(HeroIcons.textAlignCenter),
      child: Text('Center'),
    ),
    HeroToggleButton(
      id: 'right',
      separator: HeroToggleButtonGroupSeparator(),
      startContent: HeroIcon(HeroIcons.textAlignRight),
      child: Text('Right'),
    ),
  ],
)
```

### Disabled

```dart
HeroToggleButtonGroup(
  isDisabled: true,
  selectionMode: HeroSelectionMode.multiple,
  children: formattingButtons,
)
```

### Without separator

Leave out the `separator` of the buttons.

### Detached

```dart
HeroToggleButtonGroup(
  isDetached: true,
  selectionMode: HeroSelectionMode.multiple,
  children: formattingButtons,
)
```

### Selection mode

```dart
HeroToggleButtonGroup(
  defaultSelectedKeys: const <Object>{'center'},
  children: alignmentButtons,
)

HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
  defaultSelectedKeys: const <Object>{'bold', 'underline'},
  children: formattingButtons,
)
```

In single selection, pressing the selected button clears the selection unless
`disallowEmptySelection` is set.

### Controlled

```dart
Set<Object> selectedKeys = <Object>{'bold'};

HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
  selectedKeys: selectedKeys,
  onSelectionChanged: (Set<Object> keys) => setState(() => selectedKeys = keys),
  children: formattingButtons,
)
```

### Customization

Wrap the group in a decorated container and give the buttons a `HeroToggleButtonStyle`:

```dart
DecoratedBox(
  decoration: ShapeDecoration(
    color: colors.surface,
    shape: theme.shapeAll(theme.radii.xl, side: BorderSide(color: colors.border)),
  ),
  child: Padding(
    padding: const EdgeInsets.all(4),
    child: HeroToggleButtonGroup(
      isDetached: true,
      selectionMode: HeroSelectionMode.multiple,
      children: <Widget>[
        HeroToggleButton(
          id: 'bold',
          isIconOnly: true,
          semanticLabel: 'Bold',
          style: HeroToggleButtonStyle(
            borderRadius: BorderRadius.all(Radius.circular(theme.radii.lg)),
          ),
          child: const HeroIcon(HeroIcons.bold),
        ),
      ],
    ),
  ),
)
```

## Accessibility

- Single selection exposes a radio group (`SemanticsRole.radioGroup`) whose buttons are
  radios (`checked`, `inMutuallyExclusiveGroup`); multiple selection exposes toggle buttons.
  `semanticLabel` labels the group.
- The group is one Tab stop (the last focused button, else the first enabled one). Arrow
  Left/Right (horizontal, flipped in right-to-left layouts) or Up/Down (vertical) move the
  focus, skipping disabled buttons and stopping at the ends, like React Aria's toolbar. Enter
  and Space toggle the focused button.

## API

### HeroToggleButtonGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The buttons, each with an `id`. |
| `selectionMode` | `HeroSelectionMode` | `single` | `single` or `multiple`. |
| `selectedKeys` | `Set<Object>?` | `null` | Controlled selection. |
| `defaultSelectedKeys` | `Set<Object>?` | `null` | Initial selection when uncontrolled. |
| `onSelectionChanged` | `ValueChanged<Set<Object>>?` | `null` | Called with the new selection. |
| `disallowEmptySelection` | `bool` | `false` | Keeps at least one button selected. |
| `orientation` | `Axis?` | toolbar's, then `horizontal` | Row or column; inside a `HeroToolbar` it follows the toolbar. |
| `size` | `HeroSize` | `HeroSize.md` | Size of buttons without their own. |
| `isDetached` | `bool` | `false` | Gap between buttons instead of attaching them. |
| `gap` | `double?` | 4 detached, else 0 | Space between the buttons (`gap-*`). |
| `fullWidth` | `bool` | `false` | Fill the available width. |
| `isDisabled` | `bool` | `false` | Disable every button that does not opt out. |
| `semanticLabel` | `String?` | `null` | Group label (`aria-label`). |

### HeroToggleButtonGroupSeparator

No parameters. Pass it as `HeroToggleButton.separator`.

See [ToggleButton](toggle-button.md) for the button parameters.
