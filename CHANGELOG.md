# Changelog

All notable changes to this repository. Package changelogs live in
`packages/*/CHANGELOG.md`.

## Unreleased

### Added

- Project plan, progress tracker, decision log and Melos workspace with `hero_ui`,
  `hero_ui_pro` and the gallery app.
- Design tokens (`HeroColors`, `HeroRadii`, `HeroSpacing`, `HeroTypography`, `HeroShadows`,
  `HeroMotion`) evaluated from HeroUI's OKLCH variables, `HeroThemeData` and
  `HeroTheme.of(context)`.
- `HeroThemePreset`: HeroUI's named theme presets (Default, Sky, Lavender, Mint, Netflix, Uber,
  Spotify, Coinbase, Airbnb, Discord, Rabbit) in light and dark.
- `HeroApp` application shell (WidgetsApp based, iOS page transitions, bouncing scroll) and
  `loadHeroFonts()` for golden tests.
- Interaction layer: `HeroInteractable` (press, hover, focus-visible, keyboard activation,
  semantics), `HeroFocusRing`, `HeroPressScale` and `HeroDisabledOpacity`.
- Variant system: `HeroColor`, `HeroSize`, `HeroVariant`, `HeroVariants.resolve` and
  `HeroSizeValues`.
- Icon set: `HeroIcon`, `HeroIconData` and `HeroIcons` (HeroUI's built-in icons plus Gravity UI
  icons) rendered from SVG path data.
- Overlay layer: `HeroAnchoredOverlay` with React Aria placement, flipping and shifting,
  outside-press and Escape dismissal, modal barrier and HeroUI's popover motion.
- Gallery app skeleton: searchable component index grouped like the HeroUI docs, adaptive
  split view on wide screens, component pages with playground and code sheet, templates
  section and theme switcher (mode, preset, text direction).
