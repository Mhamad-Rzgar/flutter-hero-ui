# Spinner

A loading indicator component to show pending states.

HeroUI docs: [heroui.com/en/docs/react/components/spinner](https://heroui.com/en/docs/react/components/spinner)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroSpinner()
```

## Anatomy

`HeroSpinner` is a single widget: HeroUI's two-arc ring glyph painted in the spinner color and
rotated once every `period`. It has no parts.

## Sizes

| Size | Dimension |
| --- | --- |
| `HeroSpinnerSize.sm` | 16 × 16 |
| `HeroSpinnerSize.md` (default) | 24 × 24 |
| `HeroSpinnerSize.lg` | 32 × 32 |
| `HeroSpinnerSize.xl` | 40 × 40 |

## Colors

| Color | Token |
| --- | --- |
| `HeroSpinnerColor.current` | the ambient icon / text color (`currentColor`) |
| `HeroSpinnerColor.accent` (default) | `accent` |
| `HeroSpinnerColor.success` | `success` |
| `HeroSpinnerColor.warning` | `warning` |
| `HeroSpinnerColor.danger` | `danger` |

`colorOverride` replaces the role color with any color, like adding a `text-*` class in HeroUI.

## Examples

### Colors

```dart
Wrap(
  spacing: 32,
  children: const [
    HeroSpinner(color: HeroSpinnerColor.current),
    HeroSpinner(color: HeroSpinnerColor.accent),
    HeroSpinner(color: HeroSpinnerColor.success),
    HeroSpinner(color: HeroSpinnerColor.warning),
    HeroSpinner(color: HeroSpinnerColor.danger),
  ],
)
```

### Sizes

```dart
Wrap(
  spacing: 32,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: const [
    HeroSpinner(size: HeroSpinnerSize.sm),
    HeroSpinner(size: HeroSpinnerSize.md),
    HeroSpinner(size: HeroSpinnerSize.lg),
    HeroSpinner(size: HeroSpinnerSize.xl),
  ],
)
```

### Speed

One turn takes 750 ms (`animate-spin-fast`). Change it per spinner with `period`. Spinners
always stand still when the platform asks for reduced motion.

```dart
const HeroSpinner(period: Duration(milliseconds: 1500)); // slow
const HeroSpinner(); // default
const HeroSpinner(period: Duration(milliseconds: 400)); // fast
```

### Custom styles

```dart
final theme = HeroTheme.of(context);
DecoratedBox(
  decoration: ShapeDecoration(
    color: theme.colors.surface,
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: theme.colors.border),
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        const HeroSpinner(size: HeroSpinnerSize.sm),
        HeroSpinner(colorOverride: theme.colors.muted),
        const HeroSpinner(
          size: HeroSpinnerSize.lg,
          color: HeroSpinnerColor.success,
        ),
      ],
    ),
  ),
)
```

Inside buttons and other colored content, use
`HeroSpinner(size: HeroSpinnerSize.sm, color: HeroSpinnerColor.current)` so the spinner takes
the surrounding foreground color.

## Accessibility

- Exposed as a live status region (`role="status"`) labelled `Loading`; change the label with
  `semanticLabel`. The glyph itself is excluded from semantics.
- Honours reduced motion (`MediaQuery.disableAnimations` or `HeroMotion(reduceMotion: true)`):
  the glyph does not rotate.

## API

### HeroSpinner

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `size` | `HeroSpinnerSize` | `md` | Size of the spinner (16 / 24 / 32 / 40). |
| `color` | `HeroSpinnerColor` | `accent` | Color role of the spinner. |
| `colorOverride` | `Color?` | `null` | Custom color replacing `color`. |
| `period` | `Duration` | `750 ms` | Duration of one full turn. |
| `semanticLabel` | `String` | `'Loading'` | Label announced by screen readers. |

`HeroSpinner.dimensionOf(theme, size)` returns the side length of a size.
