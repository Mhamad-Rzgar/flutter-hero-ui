# Foundations

Building blocks shared by every hero_ui component.

## Variant system

HeroUI components share a `variant` × `color` × `size` matrix.

```dart
final HeroVariantStyle style = HeroVariants.resolve(
  theme.colors,
  HeroVariant.soft,
  HeroColor.accent,
);
style.backgroundFor(state); // resting / hover / pressed fill
style.foreground;
```

| Variant | Fill | Foreground |
| --- | --- | --- |
| `primary` | role color (`--accent`) | `--accent-foreground` |
| `secondary` | `--default` | role soft foreground |
| `tertiary` | transparent | role soft foreground |
| `soft` | `--accent-soft` | `--accent-soft-foreground` |
| `outline` | transparent + `--border` | default foreground |
| `ghost` | transparent (`--default` on hover) | default foreground |

`HeroColor` is `accent`, `standard` (HeroUI's `default`), `success`, `warning`, `danger`;
`HeroSize` is `sm`, `md`, `lg`. `HeroSizeValues` declares a per-size table.

## Interaction

`HeroInteractable` is the counterpart of React Aria's press, hover and focus-ring hooks. It
reports a `HeroInteractionState` (`isHovered`, `isPressed`, `isFocused`, `isFocusVisible`,
`isDisabled`, `isPending`, `isSelected`) to a builder, activates on tap, Enter and Space,
exposes button semantics and shows the pointer cursor. There is no ink splash.

```dart
HeroInteractable(
  onPressed: save,
  builder: (context, state, child) => HeroFocusRing(
    visible: state.isFocusVisible,
    shape: theme.shapeAll(theme.radii.xl3),
    child: HeroPressScale(pressed: state.isPressed, child: child!),
  ),
  child: const Text('Save'),
);
```

- `HeroFocusRing`: HeroUI's 2 px focus ring with a 2 px background-colored offset, following
  the component shape.
- `HeroPressScale`: `scale(0.97)` press feedback with HeroUI's 250 ms ease.
- `HeroDisabledOpacity`: the `--disabled-opacity` fade.

## Overlays

`HeroAnchoredOverlay` positions content next to a trigger with React Aria's rules
(`placement`, `offset`, `crossOffset`, flipping, shifting, container padding), dismisses on
outside press and Escape, optionally blocks the page (`isModal`) and plays HeroUI's popover
motion (150 ms fade + zoom from 90% + 4 px slide in; 100 ms fade + zoom to 95% out).

```dart
HeroAnchoredOverlay(
  isOpen: open,
  onDismiss: () => setState(() => open = false),
  placement: HeroPlacement.bottomStart,
  overlayBuilder: (context, geometry) => const MenuContent(),
  child: trigger,
);
```

## Icons

`HeroIcon(HeroIcons.bell)` paints vector icons with the ambient `IconTheme` color and size.
`HeroIcons` holds HeroUI's built-in component icons and a Gravity UI set; custom icons are
`HeroIconData` from SVG path data.

## App shell

`HeroApp` is a `WidgetsApp` with the hero_ui theme, iOS page transitions (`HeroPageRoute`),
bouncing scroll physics and a default text style from the tokens.

## Testing

```dart
// test/flutter_test_config.dart
import 'package:hero_ui/hero_ui_testing.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadHeroFonts();
  await testMain();
}
```
