# ColorSwatch

A visual preview of a color value with accessibility support.

HeroUI reference: <https://heroui.com/en/docs/react/components/color-swatch>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroColorSwatch(color: Color(0xFF0485F7), semanticLabel: 'Blue'),
    HeroColorSwatch(color: Color(0xFFEF4444), semanticLabel: 'Red'),
    HeroColorSwatch(color: Color(0xFFF59E0B), semanticLabel: 'Amber'),
    HeroColorSwatch(color: Color(0xFF10B981), semanticLabel: 'Green'),
    HeroColorSwatch(color: Color(0xFFD946EF), semanticLabel: 'Fuchsia'),
  ],
)
```

Colors are Flutter `Color`s. Parse CSS notations with `heroParseColor('#0485F7')`,
`heroParseColor('rgba(4, 133, 247, 0.5)')` or `heroParseColor('hsl(200, 100%, 50%)')`.

## Anatomy

`HeroColorSwatch` is a single widget. It paints the color over HeroUI's transparency
checkerboard (16 px tiles of `#EFEFEF` and `#F7F7F7` squares, centred on the swatch) and draws a
1 px `rgba(0, 0, 0, 0.1)` inset ring so light colors stay visible on light backgrounds.

Without a `color`, a swatch inside a `HeroColorPicker` shows the picker's color; elsewhere it
shows a transparent swatch (React Aria's `#fff0`).

## Sizes and shapes

| Size | Side | Circle radius |
| --- | --- | --- |
| `HeroColorSwatchSize.xs` | 16 (`size-4`) | `rounded-lg` |
| `HeroColorSwatchSize.sm` | 24 (`size-6`) | `rounded-xl` |
| `HeroColorSwatchSize.md` (default) | 32 (`size-8`) | `rounded-2xl` |
| `HeroColorSwatchSize.lg` | 36 (`size-9`) | `rounded-3xl` |
| `HeroColorSwatchSize.xl` | 40 (`size-10`) | `rounded-3xl` |

`HeroColorSwatchShape.circle` (default) uses the radii above, which make circles at the default
`--radius`; `HeroColorSwatchShape.square` uses `rounded-md` at every size. Corners follow the
theme's corner style.

## Examples

### Sizes

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroColorSwatch(color: Color(0xFF0485F7), size: HeroColorSwatchSize.xs),
    HeroColorSwatch(color: Color(0xFFEF4444), size: HeroColorSwatchSize.sm),
    HeroColorSwatch(color: Color(0xFFF59E0B), size: HeroColorSwatchSize.md),
    HeroColorSwatch(color: Color(0xFF10B981), size: HeroColorSwatchSize.lg),
    HeroColorSwatch(color: Color(0xFFD946EF), size: HeroColorSwatchSize.xl),
  ],
)
```

### Shapes

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroColorSwatch(color: Color(0xFF0485F7)),
    HeroColorSwatch(color: Color(0xFF0485F7), shape: HeroColorSwatchShape.square),
  ],
)
```

### Transparency

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: <Widget>[
    for (final double alpha in <double>[1, 0.75, 0.5, 0.25, 0])
      HeroColorSwatch(
        color: heroParseColor('rgba(4, 133, 247, $alpha)'),
        semanticLabel: '${(alpha * 100).round()}% opacity',
      ),
  ],
)
```

### Render function

`styleBuilder` receives the displayed color (React's `style` render props) and returns style
overrides:

```dart
HeroColorSwatch(
  color: const Color(0xFF0485F7),
  semanticLabel: 'Blue',
  styleBuilder: (Color color) => HeroColorSwatchStyle(
    shadows: <BoxShadow>[
      BoxShadow(color: color.withValues(alpha: 0.5), offset: const Offset(0, 4), blurRadius: 14),
    ],
  ),
)
```

### Accessibility

```dart
const HeroColorSwatch(
  color: Color(0xFF0485F7),
  colorName: 'Ocean Blue',
  semanticLabel: 'Primary brand color',
)
```

### Customization

`HeroColorSwatchStyle` stands in for `className` / `style`. `shadows` replaces the box shadow
(HeroUI's only shadow is the inset ring, so it disappears, as in CSS); `gradient` replaces the
background.

```dart
HeroColorSwatch(
  color: color,
  size: HeroColorSwatchSize.xl,
  style: HeroColorSwatchStyle(
    shadows: <BoxShadow>[BoxShadow(color: color, blurRadius: 20, spreadRadius: 2)],
  ),
)

HeroColorSwatch(
  color: color,
  size: HeroColorSwatchSize.xl,
  styleBuilder: (Color c) => HeroColorSwatchStyle(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[c, const Color(0xFFFFFFFF)],
    ),
  ),
)
```

## Accessibility

- The swatch is an image for assistive technology. Its label is `colorName`, or a generated
  English name (`heroColorName`: "vibrant red", "dark blue", "light gray", "transparent", with
  "50% transparent" appended for translucent colors), followed by `semanticLabel`.
- It is not focusable and does not react to pointers.
- The swatch keeps its size under text scaling and is not mirrored in right-to-left layouts.

## Color utilities

The color components share a small color model (exported with every color component):

| API | Description |
| --- | --- |
| `HeroColorValue` | A color kept in a color space (`rgb`, `hsl`, `hsb`) with React Aria's channel units; `parse`, `tryParse`, `fromColor`, `channelValue`, `withChannelValue`, `toSpace`, `toColor`, `toHSVColor`, `toHSLColor`, `toFormat`, `formatChannelValue`. |
| `HeroColorSpace` | `rgb`, `hsl`, `hsb` and their `channels`. |
| `HeroColorChannel` | `hue`, `saturation`, `brightness`, `lightness`, `red`, `green`, `blue`, `alpha`, with `range` and `label`. |
| `HeroChannelRange` | `min`, `max`, `step`, `pageSize` (hue 0–360/1/15, percentages 0–100/1/10, rgb 0–255/1/17, alpha 0–1/0.01/0.1). |
| `HeroColorFormat` | `hex`, `hexa`, `rgb`, `rgba`, `hsl`, `hsla`, `hsb`, `hsba`, `css`. |
| `heroParseColor` / `heroColorToString` | Parse a color string into a `Color` / format a `Color`. |
| `heroColorsEqual` | 8-bit RGBA equality of two colors. |
| `heroColorName` | The English name of a color for screen readers. |
| `HeroCheckerboard` | Paints the transparency checkerboard. |
| `HeroColorPickerScope` | Shares a picker's color with the color components inside it. |

## API

### HeroColorSwatch

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color?` | – | The color to preview; null uses the enclosing picker's color, else transparent. |
| `colorName` | `String?` | – | Accessible color name, replacing the generated one. |
| `shape` | `HeroColorSwatchShape` | `circle` | `circle` or `square`. |
| `size` | `HeroColorSwatchSize` | `md` | `xs`, `sm`, `md`, `lg`, `xl`. |
| `style` | `HeroColorSwatchStyle?` | – | Visual overrides. |
| `styleBuilder` | `HeroColorSwatchStyle Function(Color)?` | – | Overrides built from the displayed color, merged over `style`. |
| `semanticLabel` | `String?` | – | Accessibility context appended to the color name (`aria-label`). |

### HeroColorSwatchStyle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `size` | `double?` | from `size` | Side length. |
| `borderRadius` | `BorderRadiusGeometry?` | from `shape` | Corner radius. |
| `gradient` | `Gradient?` | – | Replaces the color and checkerboard fill. |
| `shadows` | `List<BoxShadow>?` | – | Replaces the box shadow (removes the inset ring). |
| `ringColor` | `Color?` | `rgba(0,0,0,.1)` | Inset ring color; transparent removes it. |
