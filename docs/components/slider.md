# Slider

A slider allows a user to select one or more values within a range.

HeroUI docs: [heroui.com/en/docs/react/components/slider](https://heroui.com/en/docs/react/components/slider)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroSlider(
  defaultValue: 30,
  label: const Text('Volume'),
  onChanged: (double value) => debugPrint('$value'),
)
```

## Anatomy

| HeroUI | Flutter | Role |
| --- | --- | --- |
| `Slider` | `HeroSlider` / `HeroSlider.range` | Owns the values; lays out label, output and track. |
| `Label` | `HeroLabel` | The label; pressing it focuses the first thumb. |
| `Slider.Output` | `HeroSliderOutput` | The formatted value(s). |
| `Slider.Track` | `HeroSliderTrack` | The bar; pressing it moves the closest thumb. |
| `Slider.Fill` | `HeroSliderFill` | The selected part of the track. |
| `Slider.Thumb` | `HeroSliderThumb` | A draggable, focusable handle for one value (`index`). |

With `label` (and no `children`) the slider builds the standard layout: label, output
(`showOutput`, on by default when there is a label) and a track with a fill and one thumb per
value. From its parts:

```dart
const HeroSlider(
  defaultValue: 30,
  children: <Widget>[
    HeroLabel.text('Volume'),
    HeroSliderOutput(),
    HeroSliderTrack(
      children: <Widget>[HeroSliderFill(), HeroSliderThumb()],
    ),
  ],
)
```

`HeroSliderTrack()` without children renders the fill and every thumb. (`Slider.Marks` is an
unfinished stub in HeroUI's source and is not ported.)

## Look

- Horizontal: a full-width grid, label at the start and output at the end of the first row,
  the track below (4 px gap). Unbounded widths fall back to 256.
- Track: `--default`, 20 tall, radius 12, with 12 px end caps that leave room for the thumbs at
  the ends; a cap turns `--accent` when the fill reaches it (single slider: start cap when the
  value is above the minimum, end cap at the maximum; range: start cap when the first thumb is
  at the minimum, end cap when the last is at the maximum).
- Fill: `--accent`, from the minimum (or the first thumb of a range) to the last thumb.
- Thumb: a 28 × 20 `--accent` pill around a 24 × 16 `--accent-foreground` knob with the field
  shadow. The knob shrinks to 90% while dragged (150 ms); keyboard focus shows the focus ring.
- Vertical: output on top, the track (20 wide, full height) in the middle and the label below,
  centered, 8 px apart; the minimum is at the bottom. Unbounded heights fall back to 256.
- Right-to-left: the minimum is at the right and the fill grows leftwards (HeroUI's CSS leaves
  this as a TODO; it is implemented here).
- Disabled: the whole slider at 50% opacity (the label is not dimmed a second time).

## Behaviour

- Pressing the track moves the closest thumb to the pointer and keeps dragging it; dragging a
  thumb moves it by the pointer's travel (React Aria).
- Thumbs cannot pass each other; values snap to `step` within `minValue`–`maxValue`.
- Keyboard on a focused thumb: arrows ±`step` (Left/Right swapped in right-to-left layouts),
  Page Up / Page Down ± a tenth of the range (at least one step), Home / End to the lowest /
  highest allowed value.
- `onChanged` reports every change; `onChangeEnd` the value when a drag, press or key press
  ends.

## Examples

### Disabled

```dart
const HeroSlider(defaultValue: 30, isDisabled: true, label: Text('Volume'))
```

### Range slider anatomy

```dart
HeroSlider.range(
  defaultValues: const <double>[25, 75],
  children: <Widget>[
    const HeroLabel.text('Range'),
    const HeroSliderOutput(),
    HeroSliderTrack(
      builder: (BuildContext context, HeroSliderState state) => <Widget>[
        const HeroSliderFill(),
        for (int i = 0; i < state.values.length; i++) HeroSliderThumb(index: i),
      ],
    ),
  ],
)
```

### Vertical

```dart
SizedBox(
  height: 256,
  child: const HeroSlider(
    defaultValue: 30,
    orientation: Axis.vertical,
    label: Text('Volume'),
  ),
)
```

### Range

```dart
HeroSlider.range(
  defaultValues: const <double>[100, 500],
  minValue: 0,
  maxValue: 1000,
  step: 50,
  numberFormat: NumberFormat.simpleCurrency(name: 'USD'), // $100.00 – $500.00
  label: const Text('Price Range'),
)
```

### Render function

```dart
HeroSlider(
  defaultValue: 30,
  builder: (BuildContext context, HeroSliderState state) => const <Widget>[
    HeroLabel.text('Volume'),
    HeroSliderOutput(),
    HeroSliderTrack(),
  ],
)
```

### Customization

```dart
HeroSlider(
  defaultValue: 40,
  children: <Widget>[
    const HeroLabel.text('Brightness'),
    HeroSliderOutput(
      style: TextStyle(fontSize: 12, height: 16 / 12, color: theme.colors.muted),
    ),
    HeroSliderTrack(
      color: theme.colors.defaultColor,
      children: <Widget>[
        HeroSliderFill(color: theme.colors.accent),
        HeroSliderThumb(
          color: theme.colors.accent,
          knobColor: theme.colors.accentForeground,
        ),
      ],
    ),
  ],
)
```

`style: HeroSliderStyle(trackColor:, fillColor:, thumbColor:, knobColor:, outputStyle:)` sets
the same colors for the standard layout; a part's own parameters win.

### Controlled value

```dart
double value = 25;

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    HeroSlider(
      value: value,
      onChanged: (double v) => setState(() => value = v),
      label: const Text('Volume'),
    ),
    Text('Current value: ${value.round()}'),
  ],
)
```

### Custom value formatting

```dart
HeroSlider(
  defaultValue: 60,
  numberFormat: NumberFormat.simpleCurrency(name: 'USD'), // $60.00
  label: const Text('Price'),
)
```

### Custom output display

```dart
HeroSliderOutput(
  builder: (BuildContext context, HeroSliderState state) => Text(
    <String>[
      for (int i = 0; i < state.values.length; i++) state.getThumbValueLabel(i),
    ].join(' – '),
  ),
)
```

### Forms

The slider registers with the enclosing `Form` / `HeroForm`; its form value is the list of
thumb values. A `name` (on the slider, or per thumb with `HeroSliderThumb.name`) adds the
thumb values to the data `HeroForm` submits, a list when several thumbs share a name, like the
hidden inputs of HeroUI's thumbs. Disabled sliders submit nothing.

```dart
Form(
  child: HeroSlider(
    defaultValue: 30,
    label: const Text('Volume'),
    validator: (List<double>? values) => values!.first < 10 ? 'Too quiet' : null,
    onSaved: (List<double>? values) => volume = values!.first,
  ),
)
```

## Accessibility

- Each thumb is focusable (a Tab stop) and announced as a slider with the label text (or
  `semanticLabel`), its formatted value, and increase / decrease actions with the next values.
- The visible label and output are not announced twice.
- Disabled sliders and thumbs are skipped by focus traversal.

## API

### HeroSlider

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double?` | `null` | Controlled value. |
| `defaultValue` | `double?` | `minValue` | Initial uncontrolled value. |
| `onChanged` | `ValueChanged<double>?` | `null` | Called on every change. |
| `onChangeEnd` | `ValueChanged<double>?` | `null` | Called when a drag or key press ends. |
| `minValue` | `double` | `0` | Lower end of the range. |
| `maxValue` | `double` | `100` | Upper end of the range. |
| `step` | `double` | `1` | Snapping granularity. |
| `numberFormat` | `NumberFormat?` | decimal | Formats the value labels (`formatOptions`). |
| `orientation` | `Axis` | `horizontal` | Track direction. |
| `isDisabled` | `bool` | `false` | Disables the slider. |
| `label` | `Widget?` | `null` | Label of the standard layout. |
| `showOutput` | `bool?` | `label != null` | Whether the standard layout shows the output. |
| `semanticLabel` | `String?` | label text | Accessibility label of the thumbs. |
| `children` | `List<Widget>?` | `null` | The parts. |
| `builder` | `HeroSliderPartsBuilder?` | `null` | Builds the parts from the state. |
| `style` | `HeroSliderStyle?` | `null` | Color and text overrides. |
| `validator` | `FormFieldValidator<List<double>>?` | `null` | Form validation. |
| `onSaved` | `FormFieldSetter<List<double>>?` | `null` | Form save. |
| `autovalidateMode` | `AutovalidateMode?` | `null` | When to validate. |
| `name` | `String?` | `null` | Form name of every thumb without its own. |

### HeroSlider.range

The same parameters with `values` / `defaultValues` (`List<double>?`, default
`[minValue, maxValue]`) and `onChanged` / `onChangeEnd` of type `ValueChanged<List<double>>?`
(stored as `onRangeChanged` / `onRangeChangeEnd`).

### HeroSliderOutput

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | labels joined by " – " | Replaces the text. |
| `builder` | `HeroSliderOutputBuilder?` | `null` | Builds the content from the state. |
| `style` | `TextStyle?` | `null` | Merged over the output style. |

### HeroSliderTrack

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | fill + one thumb per value | The parts. |
| `builder` | `HeroSliderPartsBuilder?` | `null` | Builds the parts from the state. |
| `color` | `Color?` | `--default` | Background. |

### HeroSliderFill

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color?` | `--accent` | Fill color. |

### HeroSliderThumb

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `int` | `0` | The value this thumb controls. |
| `isDisabled` | `bool` | `false` | Whether this thumb is fixed. |
| `color` | `Color?` | `--accent` | Frame color. |
| `knobColor` | `Color?` | `--accent-foreground` | Knob color. |
| `name` | `String?` | slider `name` | Form name of this thumb's value. |
| `child` | `Widget?` | `null` | Content on the knob. |

### HeroSliderState

`values`, `valueLabels`, `minValue`, `maxValue`, `orientation`, `isDisabled`,
`getThumbValueLabel(index)` and `getThumbPercent(index)` (0–1).

### HeroSliderStyle

`trackColor`, `fillColor` (also the end caps), `thumbColor`, `knobColor`, `outputStyle`.
