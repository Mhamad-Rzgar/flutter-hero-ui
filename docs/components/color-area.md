# ColorArea

A 2D color picker that allows users to select colors from a gradient area.

HeroUI reference: <https://heroui.com/en/docs/react/components/color-area>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroColorArea(
  colorSpace: HeroColorSpace.rgb,
  xChannel: HeroColorChannel.red,
  yChannel: HeroColorChannel.green,
  defaultValue: heroParseColor('rgb(116, 52, 255)'),
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `ColorArea` | `HeroColorArea` |
| `ColorArea.Thumb` | `HeroColorAreaThumb` (the `thumb` parameter, default) |

```dart
HeroColorArea(thumb: const HeroColorAreaThumb())
```

## Color space and channels

`colorSpace`, `xChannel` and `yChannel` choose the two channels the area edits; the third
channel of the space stays fixed and sets the gradient.

- Without any of them the area edits saturation (x) and brightness (y) in hsb, the defaults of
  HeroUI's API table. (React Aria derives them from the value's own space; a Flutter `Color`
  has none, so name the axes to edit rgb or hsl channels.)
- A missing axis takes the first remaining channel of the space (rgb: red, green, blue; hsl:
  hue, saturation, lightness; hsb: hue, saturation, brightness).
- A channel that needs another space switches the space (red/green/blue → rgb, lightness → hsl,
  brightness → hsb; hue or saturation with rgb → hsl). `HeroColorArea.resolveAxes` returns the
  effective space and axes.

Every pair is painted exactly: saturation × brightness (white → hue, faded to black),
saturation × lightness (gray → hue, with white above and black below the middle), hue with any
channel (a rainbow faded to gray, black or white), and rgb pairs (additive red, green and blue
layers over the fixed channel).

## Look

- Square, fills the available width up to 224 (`w-full max-w-56 aspect-square`); `size` fixes
  the side, `maxSize: double.infinity` fills any width (`max-w-full`).
- `rounded-2xl` corners (`borderRadius`) and a 1 px `rgba(0,0,0,.1)` inset ring.
- `showDots`: white 20% dots of 1 px radius on an 8 px grid.
- Thumb: 16 px circle filled with the opaque current color, 3 px white border, 1 px
  `rgba(0,0,0,.1)` rings outside and inside the border; 20 px while dragged (150 ms ease-out);
  centred on the value, so it can overhang the edges.
- Disabled: 50% opacity (the thumb fades again, as in the CSS).

## Examples

### With dots

```dart
HeroColorArea(showDots: true, defaultValue: heroParseColor('hsl(200, 100%, 50%)'))
```

### Disabled

```dart
HeroColorArea(isDisabled: true, defaultValue: heroParseColor('hsl(200, 100%, 50%)'))
```

### Controlled

```dart
Color color = heroParseColor('#9B80FF');

HeroColorArea(
  colorSpace: HeroColorSpace.rgb,
  xChannel: HeroColorChannel.red,
  yChannel: HeroColorChannel.green,
  value: color,
  onChanged: (Color next) => setState(() => color = next),
)
Row(
  spacing: 12,
  children: <Widget>[
    HeroColorSwatch(color: color),
    Text('Current color: ${heroColorToString(color, HeroColorFormat.hex)}'),
  ],
)
```

### Render function

```dart
HeroColorArea(
  thumb: HeroColorAreaThumb(
    builder: (BuildContext context, HeroColorAreaState state) => HeroColorSwatch(
      color: state.color,
      size: state.isDragging ? HeroColorSwatchSize.sm : HeroColorSwatchSize.xs,
    ),
  ),
)
```

### Customization

```dart
HeroColorArea(
  size: theme.spacing(44),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  defaultValue: heroParseColor('rgb(116, 52, 255)'),
  thumb: HeroColorAreaThumb(
    size: theme.spacing(5),
    borderWidth: theme.spacing(1),
    borderRadius: BorderRadius.circular(theme.radii.full),
  ),
)
```

## Accessibility

- The area is a group labelled `semanticLabel` ("Color picker" by default) whose value is the
  color name, with two adjustable slider nodes, one per axis ("Saturation 58%",
  "Brightness 93%"), each with increase and decrease actions.
- Keyboard (Tab focuses the thumb; HeroUI's focus ring shows for keyboard focus): left/right
  change x by one step (mirrored in right-to-left layouts), up/down change y, Shift makes it a
  page, Page Up / Page Down change y by a page, Home / End change x by a page. `onChangeEnd`
  fires after each keyboard change.
- Pointer: pressing anywhere moves the thumb there and focuses it; the area claims the drag
  immediately, so dragging inside it never scrolls the page (`touch-action: none`). Grabbing
  the thumb keeps it under the pointer.
- Hue and saturation are kept when a color turns gray, black or white.

## API

### HeroColorArea

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `Color?` | – | Current color (controlled); null inside a picker uses the picker color. |
| `defaultValue` | `Color?` | white | Initial color (uncontrolled). |
| `onChanged` | `ValueChanged<Color>?` | – | Called while the thumb moves. |
| `onChangeEnd` | `ValueChanged<Color>?` | – | Called when the user stops moving the thumb. |
| `colorSpace` | `HeroColorSpace?` | `hsb` | Space of the axes. |
| `xChannel` | `HeroColorChannel?` | `saturation` | Horizontal channel. |
| `yChannel` | `HeroColorChannel?` | `brightness` | Vertical channel. |
| `isDisabled` | `bool` | `false` | Disables the area. |
| `showDots` | `bool` | `false` | Shows the dot grid. |
| `size` | `double?` | – | Fixed side length. |
| `maxSize` | `double?` | 224 | Largest side when filling the width. |
| `borderRadius` | `BorderRadiusGeometry?` | `rounded-2xl` | Corner radius. |
| `thumb` | `Widget?` | `HeroColorAreaThumb()` | The thumb. |
| `focusNode` | `FocusNode?` | – | Focus node of the thumb. |
| `autofocus` | `bool` | `false` | Focus the thumb when first built. |
| `semanticLabel` | `String?` | "Color picker" | Accessibility label. |

`HeroColorAreaState` has `value` (`HeroColorValue`), `color`, `colorSpace`, `xChannel`,
`yChannel`, `zChannel`, `xValue`, `yValue`, `fraction`, `isDisabled`, `isDragging`, `isFocused`
and `isFocusVisible`.

### HeroColorAreaThumb

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `size` | `double?` | 16 | Side length. |
| `draggingSize` | `double?` | 20 | Side length while dragged. |
| `borderWidth` | `double?` | 3 | Border width. |
| `borderColor` | `Color?` | white | Border color. |
| `borderRadius` | `BorderRadiusGeometry?` | `rounded-xl` | Corner radius. |
| `builder` | `Widget Function(BuildContext, HeroColorAreaState)?` | – | Builds the thumb from the area state. |
