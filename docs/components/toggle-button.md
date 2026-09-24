# ToggleButton

An interactive toggle control for on/off or selected/unselected states.

HeroUI reference: <https://heroui.com/en/docs/react/components/toggle-button>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroToggleButton(
  startContent: const HeroIcon(HeroIcons.heart),
  child: const Text('Like'),
)
```

## Anatomy

`HeroToggleButton` is a single widget (React Aria's `ToggleButton`). Its content is laid out
in a row with an 8 px gap:

| Slot | Description |
| --- | --- |
| `startContent` | Content before the label, usually a `HeroIcon`. |
| `child` / `builder` | The label, or the icon of an icon-only button. `builder` receives the `HeroToggleButtonState`. |
| `endContent` | Content after the label. |
| `separator` | Divider on the leading edge inside an attached `HeroToggleButtonGroup`. |

Icons pick up the button's foreground color and size (20 px below 640 px, 16 px from 640 px
and for `sm`), and bleed 2 px into the padding like HeroUI's `-mx-0.5`.

## Variants

| Variant | Unselected | Hover / pressed | Selected |
| --- | --- | --- | --- |
| `standard` (HeroUI `default`) | `--default` fill, `--foreground` text | `--default-hover` | `--accent-soft` fill, `--accent-soft-foreground` text, `--accent-soft-hover` on hover |
| `ghost` | transparent, `--default-foreground` text | `--default` | same as above |

## Sizes

| Size | Height (< 768 / ≥ 768) | Padding | Text | Pressed scale |
| --- | --- | --- | --- | --- |
| `sm` | 36 / 32 | 12 | 14 | 0.98 |
| `md` (default) | 40 / 36 | 16 | 14 | 0.97 |
| `lg` | 44 / 40 | 16 | 16 | 0.96 |

Icon-only buttons are squares of the same height. Heights are minimums, so the button grows
with the text scale.

## Examples

### Variants

```dart
Row(
  spacing: 12,
  children: <Widget>[
    HeroToggleButton(
      startContent: const HeroIcon(HeroIcons.heart),
      child: const Text('Default'),
    ),
    HeroToggleButton(
      variant: HeroToggleButtonVariant.ghost,
      startContent: const HeroIcon(HeroIcons.heart),
      child: const Text('Ghost'),
    ),
  ],
)
```

### Icon only

```dart
HeroToggleButton(
  isIconOnly: true,
  semanticLabel: 'Bookmark',
  variant: HeroToggleButtonVariant.ghost,
  child: const HeroIcon(HeroIcons.bookmark),
)
```

### Sizes

```dart
HeroToggleButton(
  size: HeroSize.lg,
  startContent: const HeroIcon(HeroIcons.heart),
  child: const Text('Large'),
)
```

### Disabled

```dart
HeroToggleButton(
  isDisabled: true,
  defaultSelected: true,
  startContent: const HeroIcon(HeroIcons.heartFill),
  child: const Text('Like'),
)
```

### Controlled

```dart
bool isSelected = false;

HeroToggleButton(
  isSelected: isSelected,
  onChanged: (bool value) => setState(() => isSelected = value),
  startContent: HeroIcon(isSelected ? HeroIcons.heartFill : HeroIcons.heart),
  builder: (BuildContext context, HeroToggleButtonState state) =>
      Text(state.isSelected ? 'Liked' : 'Like'),
)
```

### Customization

`HeroToggleButtonStyle` overrides colors (resolved per `WidgetState`, including
`WidgetState.selected`), the border, shadows, radius and padding:

```dart
HeroToggleButton(
  style: HeroToggleButtonStyle(
    borderRadius: const BorderRadius.all(Radius.circular(9999)),
    backgroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? colors.accentSoft
          : colors.surface,
    ),
    iconColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? colors.accent
          : colors.muted,
    ),
    side: WidgetStatePropertyAll<BorderSide>(BorderSide(color: colors.border)),
  ),
  startContent: const HeroIcon(HeroIcons.heart),
  child: const Text('Save article'),
)
```

## Accessibility

- Exposes a toggle button (`button: true`, `toggled`: the selected state), like
  `aria-pressed`. Inside a single-selection `HeroToggleButtonGroup` it is a radio
  (`checked`, `inMutuallyExclusiveGroup`), like React Aria's `role="radio"`.
- Toggles with a tap, Enter or Space; the focus ring shows only for keyboard focus.
- Icon-only buttons need a `semanticLabel`.
- Disabled buttons are faded to `--disabled-opacity`, ignore input and leave the focus order.
- Hover fills apply only to hovering pointers; nothing animates under reduced motion.

## API

### HeroToggleButton

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `Object?` | `null` | Key of the button inside a `HeroToggleButtonGroup`. |
| `child` | `Widget?` | `null` | Label, or the icon of an icon-only button. |
| `builder` | `HeroToggleButtonWidgetBuilder?` | `null` | Builds the label from the `HeroToggleButtonState` (render prop). |
| `startContent` | `Widget?` | `null` | Content before the label. |
| `endContent` | `Widget?` | `null` | Content after the label. |
| `separator` | `Widget?` | `null` | Divider shown on the leading edge inside an attached group. |
| `variant` | `HeroToggleButtonVariant` | `standard` | Unselected look. |
| `size` | `HeroSize?` | group size, else `md` | Size. |
| `isIconOnly` | `bool` | `false` | Square button holding only an icon. |
| `isSelected` | `bool?` | `null` | Controlled selected state (ignored inside a group). |
| `defaultSelected` | `bool` | `false` | Initial state when uncontrolled. |
| `isDisabled` | `bool?` | group state, else `false` | Disables the button. |
| `onChanged` | `ValueChanged<bool>?` | `null` | Called with the new selected state. |
| `onPressed` | `VoidCallback?` | `null` | Called on every press. |
| `focusNode` | `FocusNode?` | `null` | Focus node. |
| `autofocus` | `bool` | `false` | Focus on first build. |
| `semanticLabel` | `String?` | `null` | Accessibility label (`aria-label`). |
| `style` | `HeroToggleButtonStyle?` | `null` | Style overrides. |

### HeroToggleButtonStyle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backgroundColor` | `WidgetStateProperty<Color?>?` | `null` | Fill. |
| `foregroundColor` | `WidgetStateProperty<Color?>?` | `null` | Text (and icon) color. |
| `iconColor` | `WidgetStateProperty<Color?>?` | `null` | Icon color. |
| `side` | `WidgetStateProperty<BorderSide?>?` | `null` | Outline. |
| `shadows` | `List<BoxShadow>?` | `null` | Outer shadows. |
| `borderRadius` | `BorderRadiusGeometry?` | `null` | Corner radii (also inside groups). |
| `padding` | `EdgeInsetsGeometry?` | `null` | Content padding. |

### HeroToggleButtonState

Alias of `HeroInteractionState`: `isSelected`, `isHovered`, `isPressed`, `isFocused`,
`isFocusVisible`, `isDisabled`.
