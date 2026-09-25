# ColorPicker

A composable color picker that synchronizes the color value between multiple color components.

HeroUI reference: <https://heroui.com/en/docs/react/components/color-picker>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroColorPicker(label: 'Pick a color', defaultValue: heroParseColor('#0485F7'))
```

With only a `label`, the picker builds HeroUI's basic anatomy: a large swatch and the label as
trigger, and a saturation × brightness area with a hue slider in the popover.

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `ColorPicker` | `HeroColorPicker` (state owner and `HeroColorPickerScope`) |
| `ColorPicker.Trigger` | `HeroColorPickerTrigger` (the `trigger` parameter) |
| `ColorPicker.Popover` | `HeroColorPickerPopover` (the `popover` parameter) |

```dart
HeroColorPicker(
  defaultValue: heroParseColor('#0485F7'),
  trigger: const HeroColorPickerTrigger(
    children: <Widget>[
      HeroColorSwatch(size: HeroColorSwatchSize.lg),
      HeroLabel.text('Pick a color'),
    ],
  ),
  popover: const HeroColorPickerPopover(
    children: <Widget>[
      HeroColorArea(
        maxSize: double.infinity,
        colorSpace: HeroColorSpace.hsb,
        xChannel: HeroColorChannel.saturation,
        yChannel: HeroColorChannel.brightness,
      ),
      HeroColorSlider(channel: HeroColorChannel.hue, colorSpace: HeroColorSpace.hsb),
    ],
  ),
)
```

Every `HeroColorSwatch`, `HeroColorArea`, `HeroColorSlider`, `HeroColorField` and
`HeroColorSwatchPicker` inside the trigger or the popover that has no value of its own shows and
edits the picker's color. The picker shares a `HeroColorValue`, so the hue and saturation stay
put while the user drags brightness to zero or saturation to gray.

## Look

- Trigger: an inline row with a 12 px gap, `rounded-sm`, `text-sm`; HeroUI's focus ring for
  keyboard focus and the disabled opacity. `padding`, `backgroundColor` and `borderRadius`
  replace `className` (`rounded-xl bg-default-soft px-3 py-2`).
- Popover: 248 wide (`min-w-62`), `--overlay` background, the overlay shadow,
  `min(32, radius × 2.5)` corners (20 by default), 8 / 8 / 12 padding and a 12 px gap between
  the children (`spacing`, `padding`, `width`, `backgroundColor`). It opens below the trigger's
  start edge (`placement: HeroPlacement.bottomStart`), 8 px away, flipping when there is no
  room, with HeroUI's popover entrance (150 ms fade, zoom from 95%, 4 px slide) and exit
  (100 ms fade, zoom to 95%). The content scrolls vertically without a scrollbar when it does
  not fit.

## Examples

### Controlled

```dart
Color color = heroParseColor('#325578');

HeroColorPicker(
  value: color,
  onChanged: (Color next) => setState(() => color = next),
  trigger: const HeroColorPickerTrigger(
    children: <Widget>[
      HeroColorSwatch(size: HeroColorSwatchSize.lg),
      HeroLabel.text('Pick a color'),
    ],
  ),
  popover: HeroColorPickerPopover(
    spacing: theme.spacing(2),
    children: <Widget>[
      HeroColorSwatchPicker(
        size: HeroColorSwatchSize.xs,
        alignment: WrapAlignment.center,
        children: <HeroColorSwatchPickerItem>[
          for (final Color preset in presets)
            HeroColorSwatchPickerItem(
              color: preset,
              children: const <Widget>[HeroColorSwatchPickerSwatch()],
            ),
        ],
      ),
      const HeroColorArea(maxSize: double.infinity),
      Row(
        spacing: theme.spacing(2),
        children: <Widget>[
          const Expanded(
            child: HeroColorSlider(
              semanticLabel: 'Hue slider',
              channel: HeroColorChannel.hue,
              colorSpace: HeroColorSpace.hsb,
            ),
          ),
          HeroButton(
            isIconOnly: true,
            size: HeroSize.sm,
            variant: HeroButtonVariant.tertiary,
            semanticLabel: 'Shuffle color',
            onPressed: shuffle,
            child: const HeroIcon(HeroIcons.shuffle),
          ),
        ],
      ),
      const HeroColorField(
        semanticLabel: 'Color field',
        variant: HeroFieldVariant.secondary,
        showSwatch: true,
      ),
    ],
  ),
)
```

### With swatches

```dart
HeroColorPicker(
  defaultValue: heroParseColor('#F43F5E'),
  trigger: const HeroColorPickerTrigger(
    children: <Widget>[
      HeroColorSwatch(size: HeroColorSwatchSize.lg),
      HeroLabel.text('Brand Color'),
    ],
  ),
  popover: HeroColorPickerPopover(
    children: <Widget>[
      const HeroColorArea(maxSize: double.infinity),
      const HeroColorSlider(channel: HeroColorChannel.hue, colorSpace: HeroColorSpace.hsb, label: 'Hue'),
      HeroColorSwatchPicker(size: HeroColorSwatchSize.xs, alignment: WrapAlignment.center, colors: presets),
    ],
  ),
)
```

### Customization

```dart
HeroColorPicker(
  defaultValue: heroParseColor('#0485F7'),
  trigger: HeroColorPickerTrigger(
    borderRadius: BorderRadius.circular(theme.radii.xl),
    backgroundColor: theme.colors.defaultSoft,
    padding: EdgeInsets.symmetric(horizontal: theme.spacing(3), vertical: theme.spacing(2)),
    children: <Widget>[
      const HeroColorSwatch(size: HeroColorSwatchSize.lg),
      HeroLabel.text('Theme color', style: TextStyle(color: theme.colors.foreground)),
    ],
  ),
  popover: HeroColorPickerPopover(
    backgroundColor: theme.colors.surface,
    children: const <Widget>[
      HeroColorArea(maxSize: double.infinity),
      HeroColorSlider(channel: HeroColorChannel.hue, colorSpace: HeroColorSpace.hsb, label: 'Hue'),
    ],
  ),
)
```

## Accessibility

- The trigger is a button with its expanded state. Tap, Enter or Space opens the popover and
  moves focus to its first control (the area thumb); Escape or a tap outside closes it and
  returns focus to the trigger.
- The popover is a named route scope labelled `semanticLabel` ("Color picker" by default),
  the counterpart of React Aria's dialog.
- `isDisabled` fades the trigger and keeps the popover closed.

## API

### HeroColorPicker

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `trigger` | `Widget?` | built from `label` | The trigger, usually a `HeroColorPickerTrigger`. |
| `popover` | `Widget?` | area + hue slider | The popover, usually a `HeroColorPickerPopover`. |
| `label` | `String?` | – | Label of the built trigger. |
| `value` | `Color?` | – | Current color (controlled). |
| `defaultValue` | `Color?` | white | Initial color (uncontrolled). |
| `onChanged` | `ValueChanged<Color>?` | – | Called whenever a component inside edits the color. |
| `isOpen` | `bool?` | – | Whether the popover is open (controlled). |
| `defaultOpen` | `bool` | `false` | Initial open state (uncontrolled). |
| `onOpenChanged` | `ValueChanged<bool>?` | – | Called when the user opens or closes the popover. |
| `isDisabled` | `bool` | `false` | Disables the trigger. |

### HeroColorPickerTrigger

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Content laid out in a row. |
| `builder` | `Widget Function(BuildContext, HeroColorPickerTriggerState)?` | – | Builds the content from the color, the interaction state and `isOpen`. |
| `padding` | `EdgeInsetsGeometry?` | none | Inner padding. |
| `backgroundColor` | `Color?` | transparent | Background. |
| `borderRadius` | `BorderRadiusGeometry?` | `rounded-sm` | Corner radius. |
| `focusNode` | `FocusNode?` | – | Focus node. |
| `semanticLabel` | `String?` | content text | Accessibility label. |

### HeroColorPickerPopover

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The popover content. |
| `placement` | `HeroPlacement` | `bottomStart` | Placement relative to the trigger. |
| `width` | `double?` | 248 | Popover width. |
| `spacing` | `double?` | 12 | Gap between the children. |
| `padding` | `EdgeInsetsGeometry?` | 8 / 8 / 12 | Inner padding. |
| `backgroundColor` | `Color?` | `overlay` | Background. |
| `semanticLabel` | `String?` | "Color picker" | Accessibility label. |
