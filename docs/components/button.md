# Button

A clickable button component with multiple variants and states.

HeroUI docs: [heroui.com/en/docs/react/components/button](https://heroui.com/en/docs/react/components/button)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroButton(
  onPressed: () => debugPrint('Button pressed'),
  child: const Text('Click me'),
)
```

## Anatomy

`HeroButton` is a single widget with three content slots laid out in a centred row with an
8 px gap:

| Slot | Parameter | Notes |
| --- | --- | --- |
| Start content | `startContent` | Usually a `HeroIcon`; replaced by a spinner while pending. |
| Label | `child` or `builder` | `builder` receives the `HeroButtonState` (HeroUI's render props). |
| End content | `endContent` | Usually a `HeroIcon`. |

Slot icons take the button's foreground color and icon size (20 below 640 px, 16 from 640 px
and in small buttons) and HeroUI's `-mx-0.5` margin. Labels stay on one line and ellipsize
when space runs out.

## Variants

| Variant | Fill | Hover / pressed fill | Foreground |
| --- | --- | --- | --- |
| `primary` (default) | `accent` | `accentHover` | `accentForeground` |
| `secondary` | `defaultColor` | `defaultHover` | `accentSoftForeground` |
| `tertiary` | `defaultColor` | `defaultHover` | inherited text color |
| `outline` | transparent + 1 px `border` | `defaultColor` 60% / `defaultColor` | `defaultForeground` |
| `ghost` | transparent | `defaultColor` | `defaultForeground` |
| `danger` | `danger` | `dangerHover` | `dangerForeground` |
| `dangerSoft` | `dangerSoft` | `dangerSoftHover` | `dangerSoftForeground` |

`dangerSoft` exists in HeroUI's styles and variants example but not in its API table.

## Sizes

| Size | Height (below 768 / from 768) | Padding | Text | Pressed scale |
| --- | --- | --- | --- | --- |
| `HeroSize.sm` | 36 / 32 | 12 | 14 medium | 0.98 |
| `HeroSize.md` (default) | 40 / 36 | 16 | 14 medium | 0.97 |
| `HeroSize.lg` | 44 / 40 | 16 | 16 medium | 0.96 |

Heights are minimums, so buttons grow with large text. `HeroThemeData.density` pins the touch
or desktop sizes. Icon-only buttons are square. The corner radius is `rounded-3xl`
(`theme.radii.xl3`), which makes a pill.

## Examples

### Variants

```dart
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: [
    HeroButton(onPressed: () {}, child: const Text('Primary')),
    HeroButton(
      variant: HeroButtonVariant.secondary,
      onPressed: () {},
      child: const Text('Secondary'),
    ),
    HeroButton(
      variant: HeroButtonVariant.tertiary,
      onPressed: () {},
      child: const Text('Tertiary'),
    ),
    HeroButton(
      variant: HeroButtonVariant.outline,
      onPressed: () {},
      child: const Text('Outline'),
    ),
    HeroButton(
      variant: HeroButtonVariant.ghost,
      onPressed: () {},
      child: const Text('Ghost'),
    ),
    HeroButton(
      variant: HeroButtonVariant.danger,
      onPressed: () {},
      child: const Text('Danger'),
    ),
    HeroButton(
      variant: HeroButtonVariant.dangerSoft,
      onPressed: () {},
      child: const Text('Danger Soft'),
    ),
  ],
)
```

### Sizes

```dart
HeroButton(size: HeroSize.sm, onPressed: () {}, child: const Text('Small'));
HeroButton(size: HeroSize.md, onPressed: () {}, child: const Text('Medium'));
HeroButton(size: HeroSize.lg, onPressed: () {}, child: const Text('Large'));
```

### With icons

```dart
HeroButton(
  startContent: const HeroIcon(HeroIcons.globe),
  onPressed: () {},
  child: const Text('Search'),
)
```

### Icon only

```dart
HeroButton(
  isIconOnly: true,
  semanticLabel: 'Settings',
  variant: HeroButtonVariant.secondary,
  onPressed: () {},
  child: const HeroIcon(HeroIcons.gear),
)
```

### Loading

A pending button ignores presses without dimming, stays focusable and shows
`HeroSpinner(size: sm, color: current)` in place of its start content (or of the icon of an
icon-only button).

```dart
HeroButton(
  isPending: true,
  onPressed: () {},
  child: const Text('Uploading...'),
)
```

### Loading state

```dart
HeroButton(
  isPending: loading,
  onPressed: upload, // sets loading for two seconds
  startContent: const HeroIcon(HeroIcons.paperclip),
  child: Text(loading ? 'Uploading...' : 'Upload File'),
)
```

### Full width

```dart
SizedBox(
  width: 400,
  child: HeroButton(
    fullWidth: true,
    onPressed: () {},
    child: const Text('Primary Button'),
  ),
)
```

`fullWidth` fills a bounded width and shrink-wraps when the width is unbounded.

### Disabled

```dart
HeroButton(isDisabled: true, onPressed: () {}, child: const Text('Primary'))
```

### Render function

```dart
HeroButton(
  onPressed: () {},
  builder: (context, state) => Text(state.isPressed ? 'Pressed' : 'Press me'),
)
```

When `builder` is set, it renders the pending state itself (no automatic spinner).

### Form buttons

`type` makes a button submit or reset the enclosing [`HeroForm`](form.md), like
HTML's `type="submit"` / `type="reset"`; `onPressed` still runs first.

```dart
HeroButton(type: HeroButtonType.submit, child: const Text('Submit'))
HeroButton(
  type: HeroButtonType.reset,
  variant: HeroButtonVariant.secondary,
  child: const Text('Reset'),
)
```

### Custom variants and styles

`HeroButtonStyle` overrides colors per state, shape, geometry and text, the Flutter
counterpart of adding Tailwind classes:

```dart
HeroButton(
  style: HeroButtonStyle(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    borderRadius: BorderRadius.circular(9999),
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
    shadows: shadowMd,
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.hovered)
          ? const Color(0xFF0FBF3E)
          : const Color(0xFF08872B),
    ),
    pressedScale: 0.95,
  ),
  onPressed: () {},
  child: const Text('Custom Button'),
)
```

Completely custom buttons (gradients, ripples) are composed from `HeroInteractable`,
`HeroFocusRing`, `HeroPressScale` and `HeroButtonSurface`; the gallery shows the ripple and
"Upgrade" examples of the HeroUI docs built that way.

## Accessibility

- Button semantics with the label taken from the text; icon-only buttons need a
  `semanticLabel`.
- Keyboard: focusable with Tab, activates with Enter and Space; keyboard focus shows HeroUI's
  2 px focus ring with a 2 px offset.
- Disabled buttons are not focusable and are announced as disabled. Pending buttons stay
  focusable and are announced as unavailable (React Aria's `aria-disabled`).
- Hover styles only apply to mouse pointers; touch shows the pressed state for at least
  100 ms.
- Right-to-left layouts swap start and end content.
- Transitions (100 ms fill, 250 ms scale) are skipped under reduced motion.

## API

### HeroButton

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | The label (or the icon of an icon-only button). |
| `builder` | `HeroButtonWidgetBuilder?` | `null` | Builds the label from `HeroButtonState`; replaces `child`. |
| `startContent` | `Widget?` | `null` | Content before the label. |
| `endContent` | `Widget?` | `null` | Content after the label. |
| `variant` | `HeroButtonVariant?` | `primary` | Visual style. |
| `size` | `HeroSize?` | `md` | Size. |
| `fullWidth` | `bool?` | `false` | Fill a bounded width. |
| `isDisabled` | `bool?` | `false` | Disable the button. |
| `isPending` | `bool` | `false` | Loading state. |
| `isIconOnly` | `bool` | `false` | Square button with only an icon. |
| `type` | `HeroButtonType` | `button` | `submit` / `reset` also submit / reset the enclosing `HeroForm`. |
| `onPressed` | `VoidCallback?` | `null` | Called on activation. |
| `onPressStart` | `VoidCallback?` | `null` | Called when a press starts. |
| `onPressEnd` | `VoidCallback?` | `null` | Called when a press ends. |
| `onHoverChanged` | `ValueChanged<bool>?` | `null` | Mouse hover changes. |
| `onFocusChanged` | `ValueChanged<bool>?` | `null` | Focus changes. |
| `focusNode` | `FocusNode?` | `null` | Focus node. |
| `autofocus` | `bool` | `false` | Focus on first build. |
| `semanticLabel` | `String?` | `null` | Accessibility label (`aria-label`). |
| `style` | `HeroButtonStyle?` | `null` | Style overrides. |

### HeroButtonState

Alias of `HeroInteractionState`: `isHovered`, `isPressed`, `isFocused`, `isFocusVisible`,
`isDisabled`, `isPending`.

### HeroButtonStyle

| Field | Type | Description |
| --- | --- | --- |
| `backgroundColor` | `WidgetStateProperty<Color?>?` | Fill per state. |
| `foregroundColor` | `WidgetStateProperty<Color?>?` | Text and icon color per state. |
| `side` | `BorderSide?` | Outline; `BorderSide.none` removes it. |
| `shadows` | `List<BoxShadow>?` | Shadows. |
| `borderRadius` | `BorderRadiusGeometry?` | Corner radii. |
| `height` | `double?` | Minimum height (and icon-only width). |
| `padding` | `EdgeInsetsGeometry?` | Content padding. |
| `textStyle` | `TextStyle?` | Merged onto the label style. |
| `iconSize` | `double?` | Slot icon size. |
| `pressedScale` | `double?` | Scale while pressed; `1` disables it. |

### Building blocks

| Widget / class | Description |
| --- | --- |
| `HeroButtonMetrics.of(context, size)` | The resolved geometry of a size (height, padding, gap, icon size, radius, text style, pressed scale). |
| `HeroButtonContent` | The start / label / end row with HeroUI's gap, icon margins and label shrinking. |
| `HeroButtonSurface` | The animated fill, shadows and per-side outline of a button. |
