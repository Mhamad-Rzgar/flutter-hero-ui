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
