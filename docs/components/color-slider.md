# ColorSlider

A color slider allows users to adjust an individual channel of a color value.

HeroUI reference: <https://heroui.com/en/docs/react/components/color-slider>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
SizedBox(
  width: 320,
  child: HeroColorSlider(
    channel: HeroColorChannel.hue,
    label: 'Hue',
    defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
  ),
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `ColorSlider` | `HeroColorSlider` |
| `Label` | `HeroLabel` (or the `label` parameter) |
| `ColorSlider.Output` | `HeroColorSliderOutput` (or `showOutput`) |
| `ColorSlider.Track` | `HeroColorSliderTrack` |
| `ColorSlider.Thumb` | `HeroColorSliderThumb` (the track's `thumb`) |

```dart
HeroColorSlider(
  channel: HeroColorChannel.hue,
  defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
  children: const <Widget>[
    HeroLabel.text('Hue'),
    HeroColorSliderOutput(),
    HeroColorSliderTrack(thumb: HeroColorSliderThumb()),
  ],
)
```

With `label` (and `showOutput`, true by default when there is a label) the slider builds this
anatomy itself. `children` are laid out like HeroUI's grid: the label (start) and output (end)
share the first row, 4 px above the track; without both the track stands alone. Vertical
sliders stack output / track / label, centred, 8 px apart. `builder` replaces the layout with
your own composition of the parts.

## Channels and color spaces

| Channel | Range | Step | Page | Output |
| --- | --- | --- | --- | --- |
| `hue` | 0–360 | 1 | 15 | `200°` |
| `saturation`, `lightness`, `brightness` | 0–100 | 1 | 10 | `50%` |
| `red`, `green`, `blue` | 0–255 | 1 | 17 | `255` |
| `alpha` | 0–1 | 0.01 | 0.1 | `50%` |

`colorSpace` sets the space the channel is read in. Like HeroUI, invalid combinations are
corrected: red/green/blue use rgb, lightness hsl, brightness hsb, and hue or saturation with rgb
use hsl. Without a space, the slider uses the space of the picker's color when the channel
exists there, else hsl (hsb for brightness, rgb for red/green/blue).

Values are Flutter `Color`s, but every slider keeps its own `HeroColorValue`: when saturation
reaches 0 or brightness reaches 0 the hue (and saturation) stay where the user left them, even
across several sliders sharing one `Color`.

## Look

- Track: 20 px thick (`h-5`), the gradient over the transparency checkerboard between two
  10 px end caps that continue the minimum color (over the checkerboard) and the maximum color,
  with `rounded-2xl` outer corners and a 1 px `rgba(0,0,0,.1)` inset border. The hue track
  shows the 7 stops of `hsl(0…360, 100%, 50%)`; lightness has a middle stop at 50%; alpha fades
  the color from transparent. Gradients run from the start side (right in right-to-left
  layouts) or from the bottom when vertical.
- Thumb: 16 px circle, 3 px white border, the overlay shadow, filled with the display color
  (the pure hue for the hue channel, the opaque color for the other channels, the translucent
  color for alpha); the default gray while disabled. Grab cursor (grabbing while dragging).
- Label and output: `text-sm font-medium`, the output with tabular figures.
- Disabled: 50% opacity.

## Examples

### Disabled

```dart
HeroColorSlider(
  channel: HeroColorChannel.hue,
  label: 'Hue',
  isDisabled: true,
  defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
)
```

### Vertical

```dart
SizedBox(
  height: 192,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: <Widget>[
      for (final HeroColorChannel channel in <HeroColorChannel>[
        HeroColorChannel.hue,
        HeroColorChannel.saturation,
        HeroColorChannel.lightness,
      ])
        HeroColorSlider(
          channel: channel,
          orientation: Axis.vertical,
          semanticLabel: channel.label,
          defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
        ),
    ],
  ),
)
```

### Controlled

```dart
Color color = heroParseColor('hsl(200, 100%, 50%)');

HeroColorSlider(
  channel: HeroColorChannel.hue,
  label: 'Hue',
  value: color,
  onChanged: (Color next) => setState(() => color = next),
)
Row(
  spacing: 8,
  children: <Widget>[
    HeroColorSwatch(color: color, size: HeroColorSwatchSize.sm),
    Text('Current color: ${heroColorToString(color, HeroColorFormat.hsl)}'),
  ],
)
```

### HSL channels

```dart
for (final HeroColorChannel channel in <HeroColorChannel>[
  HeroColorChannel.hue,
  HeroColorChannel.saturation,
  HeroColorChannel.lightness,
])
  HeroColorSlider(
    channel: channel,
    label: channel.label,
    value: color,
    onChanged: (Color next) => setState(() => color = next),
  )
```

### Alpha channel

```dart
HeroColorSlider(
  channel: HeroColorChannel.alpha,
  label: 'Alpha',
  defaultValue: heroParseColor('hsla(0, 100%, 50%, 0.5)'),
)
```

### RGB channels

The same as the HSL channels with `HeroColorChannel.red`, `green` and `blue` and an initial
`heroParseColor('rgb(255, 100, 50)')`.

### Render function

```dart
HeroColorSlider(
  channel: HeroColorChannel.hue,
  defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
  builder: (BuildContext context, HeroColorSliderState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 4,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(child: HeroLabel.text(state.isDragging ? 'Hue (dragging)' : 'Hue')),
          const HeroColorSliderOutput(),
        ],
      ),
      const HeroColorSliderTrack(),
    ],
  ),
)
```

### Customization

```dart
HeroColorSlider(
  channel: HeroColorChannel.hue,
  defaultValue: heroParseColor('hsl(220, 70%, 50%)'),
  children: <Widget>[
    HeroLabel.text('Hue', style: TextStyle(color: theme.colors.foreground)),
    HeroColorSliderOutput(style: TextStyle(color: theme.colors.muted)),
    HeroColorSliderTrack(
      thickness: theme.spacing(4),
      capRadius: theme.radii.sm,
      borderColor: theme.colors.border,
      thumb: HeroColorSliderThumb(
        borderRadius: BorderRadius.circular(theme.radii.sm),
        borderWidth: theme.spacing(0.5),
        borderColor: theme.colors.background,
      ),
    ),
  ],
)
```

## Accessibility

- The thumb is an adjustable slider node labelled with `semanticLabel`, the label text or the
  channel name, with the value text ("200°, vibrant cyan"), the increased and decreased values
  and increase/decrease actions.
- Keyboard (Tab focuses the thumb, HeroUI's focus ring shows for keyboard focus): arrow keys
  change the value by one step (Shift: one page; left/right follow the reading direction),
  Page Up / Page Down by one page, Home / End jump to the minimum / maximum. `onChangeEnd`
  fires after each keyboard change.
- Pointer: tapping the track jumps to that value and focuses the thumb; grabbing the thumb
  keeps it under the pointer while dragging; `onChangeEnd` fires on release.
- Pressing the label focuses the thumb. Disabled sliders ignore input and are not focusable.
- Text scaling grows the label and output; the track keeps its size.

## API

### HeroColorSlider

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `channel` | `HeroColorChannel` | required | The channel the slider adjusts. |
| `colorSpace` | `HeroColorSpace?` | from channel | The space the channel is read in (auto-corrected). |
| `value` | `Color?` | – | Current color (controlled); null inside a picker uses the picker color. |
| `defaultValue` | `Color?` | white | Initial color (uncontrolled). |
| `onChanged` | `ValueChanged<Color>?` | – | Called while the user adjusts the value. |
| `onChangeEnd` | `ValueChanged<Color>?` | – | Called when the user stops adjusting. |
| `orientation` | `Axis` | `horizontal` | Track direction. |
| `isDisabled` | `bool` | `false` | Disables the slider. |
| `label` | `String?` | – | Label of the default layout. |
| `showOutput` | `bool?` | `label != null` | Whether the default layout shows the value. |
| `children` | `List<Widget>?` | – | Parts laid out like HeroUI's grid. |
| `builder` | `Widget Function(BuildContext, HeroColorSliderState)?` | – | Builds the content from the state. |
| `focusNode` | `FocusNode?` | – | Focus node of the thumb. |
| `autofocus` | `bool` | `false` | Focus the thumb when first built. |
| `semanticLabel` | `String?` | label / channel | Accessibility label (`aria-label`). |

The slider fills the available width (or height when vertical); without a bound it is 192 px
long.

`HeroColorSliderState` has `value` (`HeroColorValue`), `color`, `channel`, `colorSpace`,
`channelValue`, `fraction`, `valueLabel`, `displayColor`, `orientation`, `isDisabled`,
`isDragging`, `isFocused` and `isFocusVisible`.

### HeroColorSliderOutput

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `Widget Function(BuildContext, HeroColorSliderState)?` | – | Builds the output; defaults to the formatted value. |
| `style` | `TextStyle?` | – | Merged over the output style. |

### HeroColorSliderTrack

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `thumb` | `Widget?` | `HeroColorSliderThumb()` | The thumb. |
| `thickness` | `double?` | 20 | Track height (width when vertical). |
| `capRadius` | `double?` | `rounded-2xl` | Radius of the outer cap corners (at most half the thickness). |
| `borderColor` | `Color?` | `rgba(0,0,0,.1)` | Inset border color. |

### HeroColorSliderThumb

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `size` | `double?` | 16 | Side length. |
| `borderRadius` | `BorderRadiusGeometry?` | `rounded-2xl` | Corner radius. |
| `borderWidth` | `double?` | 3 | Border width. |
| `borderColor` | `Color?` | white | Border color. |
| `shadows` | `List<BoxShadow>?` | overlay shadow | Shadows. |
