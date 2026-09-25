# Meter

A meter represents a quantity within a known range, or a fractional value.

HeroUI docs: [heroui.com/en/docs/react/components/meter](https://heroui.com/en/docs/react/components/meter)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
SizedBox(
  width: 256,
  child: const HeroMeter(value: 60, label: Text('Storage')),
)
```

## Anatomy

| HeroUI | Flutter | Role |
| --- | --- | --- |
| `Meter` | `HeroMeter` | The grid (`"label output" / "track track"`); resolves value, size and color. |
| `Label` | `HeroLabel` | The label area (start of the first row). |
| `Meter.Output` | `HeroMeterOutput` | The formatted value (end of the first row). |
| `Meter.Track` | `HeroMeterTrack` | The `--default` bar across the second row. |
| `Meter.Fill` | `HeroMeterFill` | The filled part of the track. |

With `label` (and no `children`) the meter builds the standard layout: the label, the output
(`showValueLabel`, on by default when there is a label) and the track. The same meter from its
parts:

```dart
const HeroMeter(
  value: 60,
  children: <Widget>[
    HeroLabel.text('Storage'),
    HeroMeterOutput(),
    HeroMeterTrack(child: HeroMeterFill()),
  ],
)
```

Parts go to their grid area whatever their order; other widgets follow the track as full-width
rows.

## Look

- The grid fills the available width (`w-full`) with a 4 px gap; where the width is unbounded
  it is 256 wide (`w-64`). The label keeps its natural width and wraps before the output.
- Label: 14 px medium in `--foreground`. Output: 14 px medium with tabular figures in the
  surrounding text color.
- Track: `--default`, clipped. The fill grows from the start edge (the right in right-to-left
  layouts) and animates width changes over 300 ms with `ease-out` (instant under reduced
  motion).
- Disabled (`isDisabled`): the whole meter at 50% opacity.

## Sizes

| Size | Track height | Radius |
| --- | --- | --- |
| `HeroSize.sm` | 4 (`h-1`) | `rounded-xs` (2) |
| `HeroSize.md` (default) | 8 (`h-2`) | `rounded-sm` (4) |
| `HeroSize.lg` | 12 (`h-3`) | `rounded-md` (6) |

## Colors

| Color | Fill token |
| --- | --- |
| `HeroColor.standard` | `defaultForeground` |
| `HeroColor.accent` (default) | `accent` |
| `HeroColor.success` | `success` |
| `HeroColor.warning` | `warning` |
| `HeroColor.danger` | `danger` |

## Examples

### Sizes

```dart
SizedBox(
  width: 256,
  child: Column(
    spacing: 24,
    children: const <Widget>[
      HeroMeter(color: HeroColor.success, size: HeroSize.sm, value: 40, label: Text('Small')),
      HeroMeter(size: HeroSize.md, value: 60, label: Text('Medium')),
      HeroMeter(color: HeroColor.warning, size: HeroSize.lg, value: 80, label: Text('Large')),
    ],
  ),
)
```

### Colors

```dart
Column(
  spacing: 24,
  children: const <Widget>[
    HeroMeter(color: HeroColor.standard, value: 50, label: Text('Default')),
    HeroMeter(color: HeroColor.accent, value: 50, label: Text('Accent')),
    HeroMeter(color: HeroColor.success, value: 50, label: Text('Success')),
    HeroMeter(color: HeroColor.warning, value: 50, label: Text('Warning')),
    HeroMeter(color: HeroColor.danger, value: 50, label: Text('Danger')),
  ],
)
```

### Without label

When no visible label is needed, use `semanticLabel` for accessibility.

```dart
const HeroMeter(value: 45, semanticLabel: 'Storage usage')
```

### Custom value scale

Use `minValue`, `maxValue` and `numberFormat` to customize the value range and display format.

```dart
HeroMeter(
  value: 750,
  minValue: 0,
  maxValue: 1000,
  numberFormat: NumberFormat.simpleCurrency(name: 'USD'), // $750.00
  label: const Text('Revenue'),
)
```

### Customization

```dart
final HeroThemeData theme = HeroTheme.of(context);
final BorderRadius full = BorderRadius.all(Radius.circular(theme.radii.full));

HeroMeter(
  value: 68,
  semanticLabel: 'Storage used',
  children: <Widget>[
    const HeroLabel.text('Storage used'),
    HeroMeterOutput(style: TextStyle(color: theme.colors.muted)),
    HeroMeterTrack(
      borderRadius: full,
      child: HeroMeterFill(color: theme.colors.warning, borderRadius: full),
    ),
  ],
)
```

### Render function

`builder` returns the parts from a `HeroMeterState` (`percentage`, `valueText`):

```dart
HeroMeter(
  value: 3,
  maxValue: 4,
  builder: (BuildContext context, HeroMeterState state) => <Widget>[
    const HeroLabel.text('Onboarding'),
    HeroMeterOutput(child: Text('${state.percentage.round()} of 100')),
    const HeroMeterTrack(),
  ],
)
```

## Value formatting

The value text is a whole percentage of the range ("60%"), React Aria's default
`formatOptions: {style: 'percent'}`. `numberFormat` takes an intl `NumberFormat` (re-exported by
hero_ui): a percent format formats the fraction, any other format the value itself.
`valueLabel` replaces the text.

## Accessibility

- Announced as a progress bar (React Aria's `role="meter progressbar"`) with the label text (or
  `semanticLabel`), the value text and the range. A value text that is neither a number nor a
  percentage (a currency) is announced without the role.
- The output is not announced separately; the value is part of the meter.

## API

### HeroMeter

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | `0` | Current value, clamped to the range. |
| `minValue` | `double` | `0` | Lower end of the range. |
| `maxValue` | `double` | `100` | Upper end of the range. |
| `size` | `HeroSize` | `md` | Track thickness. |
| `color` | `HeroColor` | `accent` | Fill color. |
| `isDisabled` | `bool` | `false` | 50% opacity. |
| `numberFormat` | `NumberFormat?` | percent | Formats the value text (`formatOptions`). |
| `valueLabel` | `String?` | `null` | Replaces the value text. |
| `label` | `Widget?` | `null` | Label of the standard layout. |
| `showValueLabel` | `bool?` | `label != null` | Whether the standard layout shows the output. |
| `semanticLabel` | `String?` | label text | Accessibility label (`aria-label`). |
| `children` | `List<Widget>?` | `null` | The parts. |
| `builder` | `HeroMeterChildrenBuilder?` | `null` | Builds the parts from the state. |

`HeroMeter.fillColorOf`, `HeroMeter.trackHeightOf` and `HeroMeter.radiusOf` return the resolved
fill color, track height and radius.

### HeroMeterOutput

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | value text | Replaces the value text. |
| `style` | `TextStyle?` | `null` | Merged over the output style. |

### HeroMeterTrack

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | `HeroMeterFill()` | Content. |
| `color` | `Color?` | `--default` | Background. |
| `borderRadius` | `BorderRadiusGeometry?` | size radius | Corner radii. |
| `height` | `double?` | size height | Height. |

### HeroMeterFill

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color?` | meter color | Fill color. |
| `borderRadius` | `BorderRadiusGeometry?` | size radius | Corner radii. |

### HeroRangeLayout

The grid shared by meters and sliders: `label`, `output`, `track`, extra `children`, `gap`
(4) and `fallbackWidth` (256).
