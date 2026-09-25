# CloseButton

Button component for closing dialogs, modals, or dismissing content.

HeroUI docs: [heroui.com/en/docs/react/components/close-button](https://heroui.com/en/docs/react/components/close-button)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroCloseButton(onPressed: () => Navigator.of(context).pop())
```

## Anatomy

`HeroCloseButton` is a single widget: a 24 × 24 circle (`rounded-xl`, 12) on the `defaultColor`
fill with a 16 px icon in `muted`. The icon defaults to HeroUI's close icon
(`HeroIcons.close`); pass a `child` or a `builder` to replace it.

## Variants

| Variant | Fill | Hover fill | Icon |
| --- | --- | --- | --- |
| `HeroCloseButtonVariant.standard` (default) | `defaultColor` | `defaultHover` | `muted` |

States: hover (mouse only), pressed (`scale(0.93)` over 250 ms `ease-out-quart`), keyboard
focus ring, disabled (50% opacity, not focusable) and pending (ignores presses, not dimmed).
The fill transitions over 100 ms and the icon color over 150 ms.

## Examples

### Interactive

```dart
HeroCloseButton(
  semanticLabel: 'Close (clicked $count times)',
  onPressed: () => setState(() => count++),
)
```

### With custom icon

```dart
HeroCloseButton(
  onPressed: () {},
  child: const HeroIcon(HeroIcons.circleXmark),
)
```

### Custom styles

```dart
final theme = HeroTheme.of(context);
HeroCloseButton(
  onPressed: () {},
  style: HeroButtonStyle(
    height: theme.spacing(8),
    borderRadius: BorderRadius.circular(theme.radii.full),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.hovered)
          ? theme.colors.foreground
          : null,
    ),
    pressedScale: 0.95,
  ),
)
```

## Accessibility

- Announced as a button labelled "Close"; change it with `semanticLabel` (`aria-label`).
- Focusable with Tab; Enter and Space activate it; keyboard focus shows the focus ring.
- The icon is decorative and excluded from semantics.
- HeroUI keeps the 24 px size, below the 44–48 px touch guideline; give it room or a larger
  `style.height` on touch-first screens.

## API

### HeroCloseButton

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | close icon | Content, usually a `HeroIcon`. |
| `builder` | `HeroButtonWidgetBuilder?` | `null` | Builds the content from `HeroButtonState`. |
| `onPressed` | `VoidCallback?` | `null` | Called on activation. |
| `variant` | `HeroCloseButtonVariant` | `standard` | Visual style. |
| `isDisabled` | `bool` | `false` | Disable the button. |
| `isPending` | `bool` | `false` | Ignore presses while staying focusable. |
| `focusNode` | `FocusNode?` | `null` | Focus node. |
| `autofocus` | `bool` | `false` | Focus on first build. |
| `semanticLabel` | `String` | `'Close'` | Accessibility label. |
| `style` | `HeroButtonStyle?` | `null` | Size (`height`), `borderRadius`, `backgroundColor`, `foregroundColor`, `side`, `shadows`, `iconSize` and `pressedScale` overrides. |
