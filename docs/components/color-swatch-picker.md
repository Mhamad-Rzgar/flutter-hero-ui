# ColorSwatchPicker

A list of color swatches that allows users to select a color from a predefined palette.

HeroUI reference: <https://heroui.com/en/docs/react/components/color-swatch-picker>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const List<Color> colors = <Color>[
  Color(0xFFF43F5E), Color(0xFFD946EF), Color(0xFF8B5CF6), Color(0xFF3B82F6),
  Color(0xFF06B6D4), Color(0xFF10B981), Color(0xFF84CC16),
];

HeroColorSwatchPicker(colors: colors, onChanged: (Color color) => debugPrint('$color'))
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `ColorSwatchPicker` | `HeroColorSwatchPicker` |
| `ColorSwatchPicker.Item` | `HeroColorSwatchPickerItem(color: ...)` |
| `ColorSwatchPicker.Swatch` | `HeroColorSwatchPickerSwatch` |
| `ColorSwatchPicker.Indicator` | `HeroColorSwatchPickerIndicator` |

`colors` builds one item with a swatch and an indicator per color. Pass `children` to compose
the items yourself:

```dart
HeroColorSwatchPicker(
  children: <HeroColorSwatchPickerItem>[
    for (final Color color in colors)
      HeroColorSwatchPickerItem(
        color: color,
        children: const <Widget>[
          HeroColorSwatchPickerSwatch(),
          HeroColorSwatchPickerIndicator(),
        ],
      ),
  ],
)
```

## Variants, sizes and layouts

| Size | Item | Border | Circle radius | Square radius (item / swatch) |
| --- | --- | --- | --- | --- |
| `xs` | 16 | 1 | `rounded-lg` | `rounded-md` / `rounded-md` |
| `sm` | 24 | 2 | `rounded-xl` | `rounded-lg` / `rounded-lg` (`rounded-md` selected) |
| `md` (default) | 32 | 2 | `rounded-2xl` | `rounded-xl` / `rounded-lg` |
| `lg` | 36 | 3 | `rounded-3xl` | `rounded-xl` / `rounded-lg` |
| `xl` | 40 | 3 | `rounded-3xl` | `rounded-xl` / `rounded-lg` |

- `variant`: `HeroColorSwatchShape.circle` (default) or `square`.
- `layout`: `HeroColorSwatchPickerLayout.grid` (default, a wrapping row with 8 px gaps, centred
  on the cross axis; `alignment` sets the main-axis alignment) or `stack` (a column).

States:

- **Selected**: the item border takes the item color, the item gets the field shadow (100 ms
  ease-out), the swatch shrinks to 77% and the check mark scales in (150 ms ease-out).
- **Hover** (pointer devices): the swatch grows to 110%.
- **Focus-visible**: HeroUI's 2 px focus ring with a 2 px offset.
- **Disabled** items: 50% opacity, not focusable or selectable.

The check mark is white, or black on light colors (`(0.2126 R + 0.7152 G + 0.0722 B) / 255 >
0.5`).

## Examples

### Variants

```dart
HeroColorSwatchPicker(colors: colors, variant: HeroColorSwatchShape.square)
```

### Sizes

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 24,
  children: <Widget>[
    for (final HeroColorSwatchSize size in HeroColorSwatchSize.values)
      HeroColorSwatchPicker(colors: colors, size: size),
  ],
)
```

### Disabled

```dart
HeroColorSwatchPicker(
  children: <HeroColorSwatchPickerItem>[
    for (final Color color in colors) HeroColorSwatchPickerItem(color: color, isDisabled: true),
  ],
)
```

### Stack layout

```dart
HeroColorSwatchPicker(colors: colors, layout: HeroColorSwatchPickerLayout.stack)
```

### Default value

```dart
HeroColorSwatchPicker(colors: colors, defaultValue: const Color(0xFF8B5CF6))
```

### Controlled

```dart
Color value = heroParseColor('#F43F5E');

HeroColorSwatchPicker(
  colors: colors,
  value: value,
  onChanged: (Color color) => setState(() => value = color),
)
Text('Selected: ${heroColorToString(value, HeroColorFormat.hex)}')
```

### Custom indicator

```dart
HeroColorSwatchPickerItem(
  color: color,
  children: const <Widget>[
    HeroColorSwatchPickerSwatch(),
    HeroColorSwatchPickerIndicator(child: HeroIcon(HeroIcons.heartFill)),
  ],
)
```

Icons in the indicator take its color and a third of the item size.

### Render function

```dart
HeroColorSwatchPickerItem(
  color: color,
  builder: (BuildContext context, HeroColorSwatchPickerItemState state) => const Stack(
    fit: StackFit.expand,
    children: <Widget>[HeroColorSwatchPickerSwatch(), HeroColorSwatchPickerIndicator()],
  ),
)
```

### Customization

```dart
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl2),
  border: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
  padding: EdgeInsets.all(theme.spacing(4)),
  shadow: theme.shadows.surface,
  child: HeroColorSwatchPicker(
    colors: colors,
    variant: HeroColorSwatchShape.square,
    defaultValue: const Color(0xFF8B5CF6),
  ),
)
```

## Accessibility

- The picker is a semantics container labelled `semanticLabel`; each item is a button named
  after its color (`heroColorName`, or the item's `semanticLabel`) with its selected state.
- Keyboard: Tab reaches the selected item (or the last focused, or the first enabled item);
  arrow keys move focus (left/right in reading order, mirrored in right-to-left layouts; up and
  down to the item above or below in the wrapped grid, or to the previous/next item in the
  stack layout); Home and End jump to the first and last item; Enter or Space selects.
  Disabled items are skipped. Focus does not wrap around.
- The selection cannot be emptied: pressing the selected item does nothing.
- Inside a `HeroColorPicker`, a picker without `value` selects and edits the picker's color.

## API

### HeroColorSwatchPicker

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `colors` | `List<Color>?` | – | The palette; one default item per color. |
| `children` | `List<HeroColorSwatchPickerItem>?` | – | Custom items, used instead of `colors`. |
| `value` | `Color?` | – | Selected color (controlled). |
| `defaultValue` | `Color?` | – | Initially selected color (uncontrolled). |
| `onChanged` | `ValueChanged<Color>?` | – | Called with the selected item color. |
| `size` | `HeroColorSwatchSize` | `md` | `xs`, `sm`, `md`, `lg`, `xl`. |
| `variant` | `HeroColorSwatchShape` | `circle` | `circle` or `square`. |
| `layout` | `HeroColorSwatchPickerLayout` | `grid` | `grid` or `stack`. |
| `alignment` | `WrapAlignment` | `start` | Main-axis alignment of the grid. |
| `semanticLabel` | `String?` | – | Accessibility label of the list. |

### HeroColorSwatchPickerItem

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color` | required | The color the item selects. |
| `isDisabled` | `bool` | `false` | Whether the item is disabled. |
| `children` | `List<Widget>?` | swatch + indicator | Parts stacked inside the item border. |
| `builder` | `Widget Function(BuildContext, HeroColorSwatchPickerItemState)?` | – | Builds the content from the item state. |
| `semanticLabel` | `String?` | color name | Accessibility label. |

`HeroColorSwatchPickerItemState` has `color`, `isSelected`, `isDisabled`, `isHovered`,
`isPressed`, `isFocused`, `isFocusVisible` and `isLightColor`.

### HeroColorSwatchPickerSwatch

No parameters. Paints the item color over the transparency checkerboard.

### HeroColorSwatchPickerIndicator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | check mark | Replaces the check mark. |
| `builder` | `Widget Function(BuildContext, HeroColorSwatchPickerItemState)?` | – | Builds the mark from the item state. |
