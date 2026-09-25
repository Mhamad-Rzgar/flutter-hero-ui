# ProgressCircle

A circular progress indicator that shows determinate or indeterminate progress.

HeroUI docs: [heroui.com/en/docs/react/components/progress-circle](https://heroui.com/en/docs/react/components/progress-circle)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroProgressCircle(value: 60, semanticLabel: 'Loading')
```

## Anatomy

| HeroUI | Flutter | Role |
| --- | --- | --- |
| `ProgressCircle` | `HeroProgressCircle` | Resolves the value, size and color; announces the progress. |
| `ProgressCircle.Track` | `HeroProgressCircleTrack` | The drawing area (the SVG, `viewBox` 36 × 36); spins while indeterminate. |
| `ProgressCircle.TrackCircle` | `HeroProgressCircleTrackCircle` | The `--default` background ring. |
| `ProgressCircle.FillCircle` | `HeroProgressCircleFillCircle` | The progress arc. |

`HeroProgressCircle()` renders a track with both circles. Spelled out:

```dart
const HeroProgressCircle(
  value: 60,
  semanticLabel: 'Loading',
  child: HeroProgressCircleTrack(
    children: <Widget>[
      HeroProgressCircleTrackCircle(),
      HeroProgressCircleFillCircle(),
    ],
  ),
)
```

## Look

- The circle is 28 × 28 (`md`); the geometry lives in a 36 × 36 view box scaled to that size:
  center (18, 18), radius 16, stroke width 4.
- The arc starts at 12 o'clock, runs clockwise with round caps and animates its length over
  300 ms with `ease-out` when the value changes.
- Indeterminate: a quarter arc; the whole track turns once per second (linear,
  `HeroMotion.progressSpin`).
- Disabled: 50% opacity.
- Under reduced motion nothing animates or spins.

## Sizes

| Size | Dimension |
| --- | --- |
| `HeroSize.sm` | 20 × 20 (`size-5`) |
| `HeroSize.md` (default) | 28 × 28 (`size-7`) |
| `HeroSize.lg` | 36 × 36 (`size-9`) |

`dimension` sets any other size (a `size-*` class).

## Colors

The track is `--default`; the arc color follows `color`:

| Color | Arc token |
| --- | --- |
| `HeroColor.standard` | `defaultForeground` |
| `HeroColor.accent` (default) | `accent` |
| `HeroColor.success` | `success` |
| `HeroColor.warning` | `warning` |
| `HeroColor.danger` | `danger` |

## Examples

### Sizes

```dart
Wrap(
  spacing: 24,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: const <Widget>[
    HeroProgressCircle(size: HeroSize.sm, value: 40, semanticLabel: 'Loading'),
    HeroProgressCircle(size: HeroSize.md, value: 60, semanticLabel: 'Loading'),
    HeroProgressCircle(size: HeroSize.lg, value: 80, semanticLabel: 'Loading'),
  ],
)
```

### Colors

```dart
Wrap(
  spacing: 24,
  children: const <Widget>[
    HeroProgressCircle(color: HeroColor.standard, value: 60, semanticLabel: 'Default'),
    HeroProgressCircle(color: HeroColor.accent, value: 60, semanticLabel: 'Accent'),
    HeroProgressCircle(color: HeroColor.success, value: 60, semanticLabel: 'Success'),
    HeroProgressCircle(color: HeroColor.warning, value: 60, semanticLabel: 'Warning'),
    HeroProgressCircle(color: HeroColor.danger, value: 60, semanticLabel: 'Danger'),
  ],
)
```

### Indeterminate

Use `isIndeterminate` when progress cannot be determined.

```dart
const HeroProgressCircle(isIndeterminate: true, semanticLabel: 'Loading')
```

### With label

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroProgressCircle(value: 75, semanticLabel: 'Loading'),
    HeroLabel.text('75% Complete'),
  ],
)
```

### Custom SVG props

Each part is composable, so the SVG attributes can be overridden: `strokeWidth`, `radius`
(`r`), `center` (`cx`, `cy`) and `viewBox`. A track's `strokeWidth` is the default of its
circles.

```dart
const HeroProgressCircle(
  value: 60,
  semanticLabel: 'Thin circle',
  child: HeroProgressCircleTrack(
    strokeWidth: 2,
    viewBox: Size(36, 36),
    children: <Widget>[
      HeroProgressCircleTrackCircle(center: Offset(18, 18), radius: 17),
      HeroProgressCircleFillCircle(center: Offset(18, 18), radius: 17),
    ],
  ),
)
```

### Customization

```dart
final bool dark = HeroTheme.of(context).isDark;

HeroProgressCircle(
  value: 68,
  dimension: 56,
  semanticLabel: 'Sync progress',
  child: HeroProgressCircleTrack(
    children: <Widget>[
      HeroProgressCircleTrackCircle(
        color: dark ? oklch(0.269, 0, 0) : oklch(0.922, 0, 0), // neutral-800 / 200
      ),
      HeroProgressCircleFillCircle(
        color: dark ? oklch(0.87, 0, 0) : oklch(0.371, 0, 0), // neutral-300 / 700
      ),
    ],
  ),
)
```

### Render function

`builder` receives a `HeroProgressCircleState` (`percentage`, `valueText`, `isIndeterminate`):

```dart
HeroProgressCircle(
  value: 42,
  builder: (BuildContext context, HeroProgressCircleState state) => Stack(
    alignment: Alignment.center,
    children: <Widget>[
      const HeroProgressCircleTrack(dimension: 56),
      Text(state.valueText ?? ''),
    ],
  ),
)
```

## Value formatting

The announced value text is a whole percentage of the range ("60%"), like React Aria's default
`formatOptions: {style: 'percent'}`. Pass an intl `NumberFormat` (re-exported by hero_ui) as
`numberFormat` to change it: a percent format formats the fraction, any other format the value
itself (`NumberFormat.simpleCurrency(name: 'USD')` announces "$750.00" for 750). `valueLabel`
replaces the text entirely. `HeroRangeFormat` exposes the same helpers for custom content.

## Accessibility

- Announced as a progress bar (`role="progressbar"`) with `semanticLabel` (`aria-label`), the
  value text and the range. A value text that is neither a number nor a percentage is announced
  without the role.
- Indeterminate circles are announced as a loading indicator without a value.
- Honours reduced motion (`MediaQuery.disableAnimations` or `HeroMotion(reduceMotion: true)`).

## API

### HeroProgressCircle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `double` | `0` | Current value, clamped to the range. |
| `minValue` | `double` | `0` | Value of an empty circle. |
| `maxValue` | `double` | `100` | Value of a full circle. |
| `isIndeterminate` | `bool` | `false` | Spinning quarter arc. |
| `isDisabled` | `bool` | `false` | 50% opacity. |
| `size` | `HeroSize` | `md` | 20 / 28 / 36. |
| `color` | `HeroColor` | `accent` | Arc color. |
| `dimension` | `double?` | `null` | Custom side length. |
| `numberFormat` | `NumberFormat?` | percent | Formats the value text (`formatOptions`). |
| `valueLabel` | `String?` | `null` | Replaces the value text. |
| `semanticLabel` | `String?` | `null` | Accessibility label (`aria-label`). |
| `child` | `Widget?` | track with both circles | Content. |
| `builder` | `HeroProgressCircleWidgetBuilder?` | `null` | Builds the content from the state. |

`HeroProgressCircle.dimensionOf(theme, size)` and `HeroProgressCircle.fillColorOf(colors,
color)` return the resolved size and arc color.

### HeroProgressCircleTrack

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | track + fill circle | Circles, painted in order. |
| `viewBox` | `Size` | `Size(36, 36)` | Coordinate space of the circles. |
| `strokeWidth` | `double?` | `null` | Default stroke width of the circles. |
| `dimension` | `double?` | circle size | Side length. |

### HeroProgressCircleTrackCircle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `center` | `Offset?` | view box center | `cx`, `cy`. |
| `radius` | `double?` | `16` | `r`. |
| `strokeWidth` | `double?` | track's, then `4` | Stroke width. |
| `color` | `Color?` | `--default` | Stroke color. |

### HeroProgressCircleFillCircle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `center` | `Offset?` | view box center | `cx`, `cy`. |
| `radius` | `double?` | `16` | `r`. |
| `strokeWidth` | `double?` | track's, then `4` | Stroke width. |
| `color` | `Color?` | circle color | Stroke color. |
| `strokeCap` | `StrokeCap` | `round` | Arc ends (`strokeLinecap`). |

### HeroProgressCircleState

| Field | Type | Description |
| --- | --- | --- |
| `percentage` | `double` | Progress from 0 to 100. |
| `valueText` | `String?` | Formatted value; null while indeterminate. |
| `isIndeterminate` | `bool` | Whether the progress is unknown. |
