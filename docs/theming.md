# Theming

hero_ui reproduces HeroUI's theme architecture: a small set of **source tokens** declared in
OKLCH, and **calculated tokens** (hover states, soft tints, secondary borders) derived from
them with the same `color-mix()` formulas as HeroUI's `variables.css`.

## Access

```dart
final HeroThemeData theme = HeroTheme.of(context);
theme.colors.accent;          // --accent
theme.colors.accentSoft;      // --accent-soft
theme.radii.field;            // --field-radius
theme.typography.h3;          // text-2xl font-semibold tracking-tight
theme.shadows.overlay;        // --overlay-shadow
```

`HeroTheme.of` resolves the nearest `HeroTheme`, then a `HeroThemeData` registered in a
Material `ThemeData.extensions`, then the default light theme.

## Providing a theme

```dart
// Standalone app.
HeroApp(
  theme: HeroThemeData.light(),
  darkTheme: HeroThemeData.dark(),
  themeMode: HeroThemeMode.system,
  home: const HomePage(),
);

// Re-theme a subtree (like HeroUI's data-theme attribute).
HeroTheme(data: HeroThemeData.dark(), child: const Sidebar());

// Inside a MaterialApp.
ThemeData(extensions: <ThemeExtension<dynamic>>[HeroThemeData.light()]);
```

`AnimatedHeroTheme` interpolates between two themes.

## Color tokens

| Group | Tokens |
| --- | --- |
| Base | `background`, `foreground`, `backgroundSecondary`, `backgroundTertiary`, `backgroundInverse` |
| Surface | `surface`, `surfaceForeground`, `surfaceHover`, `surfaceSecondary`, `surfaceTertiary` (+ foregrounds) |
| Overlay | `overlay`, `overlayForeground`, `backdrop` |
| Roles | `accent`, `defaultColor`, `success`, `warning`, `danger`, each with `Foreground`, `Hover`, `Soft`, `SoftForeground`, `SoftHover` |
| Fields | `fieldBackground`, `fieldForeground`, `fieldPlaceholder`, `fieldBorder`, `fieldHover`, `fieldFocus`, `fieldBorderHover`, `fieldBorderFocus` |
| Misc | `muted`, `border`, `borderSecondary`, `borderTertiary`, `separator`, `separatorSecondary`, `separatorTertiary`, `focus`, `link`, `segment`, `segmentForeground`, `scrollbar`, `chart1`–`chart5` |

`HeroColors.toMap()` lists every token by its CSS variable name.

## Custom themes

Start from a source and override what you need; calculated tokens follow automatically:

```dart
final HeroColors colors = HeroColors.derive(
  HeroColorSource.light.copyWith(accent: oklch(0.62, 0.2, 150)),
  brightness: Brightness.light,
);
final HeroThemeData theme = HeroThemeData(
  brightness: Brightness.light,
  colors: colors,
  radii: const HeroRadii(radius: 6, field: 10),
);
```

## Radius, spacing, typography, motion

- `HeroRadii`: `xs` 2 · `sm` 4 · `md` 6 · `lg` 8 · `xl` 12 · `xl2` 16 · `xl3` 24 · `xl4` 32
  (multiples of `--radius`, 8 by default) and `field` (12).
- `HeroSpacing`: Tailwind's 4 px unit; `theme.spacing(2.5)` is 10.
- `HeroTypography`: Inter on Tailwind's type scale (`xs` 12/16 … `xl4` 36/40) plus HeroUI's
  typography roles `h1`–`h6`, `body`, `bodySm`, `bodyXs`, `code`.
- `HeroMotion`: durations (`fast` 100 ms … `slowest` 350 ms) and every easing curve from
  `theme.css` (`smooth`, `easeOut`, `easeOutQuart`, `easeOutFluid`, ...). `resolve()` returns
  zero under reduced motion.

## Corners and density

- `cornerStyle`: `HeroCornerStyle.continuous` (default, iOS superellipse corners) or
  `circular` (identical to CSS). Build shapes with `theme.shape(...)` / `theme.shapeAll(...)`.
- `density`: `HeroDensity.adaptive` (default) uses HeroUI's larger touch sizes below 768 px
  and the compact desktop sizes from 768 px, like its `md:` utilities.
