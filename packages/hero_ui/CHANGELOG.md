# Changelog

## 0.1.0 (unreleased)

- Initial package skeleton.
- Design tokens and `HeroThemeData` / `HeroTheme` with HeroUI's default light and dark
  themes, OKLCH color math and CSS `color-mix()` evaluation.
- `HeroThemePreset` with every HeroUI theme-builder preset in light and dark.
- `HeroApp`, `HeroPageRoute`, `HeroScrollBehavior` and `package:hero_ui/hero_ui_testing.dart`.
- Interaction layer: `HeroInteractable`, `HeroFocusRing`, `HeroPressScale`, `HeroDisabledOpacity`.
- Variant system: `HeroColor`, `HeroSize`, `HeroVariant`, `HeroVariants`, `HeroSizeValues`.
- `HeroIcon`, `HeroIconData`, `HeroIcons` and an SVG path-data parser.
- Overlay layer: `HeroAnchoredOverlay`, `HeroPlacement`, `computeHeroOverlayGeometry`, `HeroOverlayTransition`.
- `HeroSpinner`: two-arc gradient ring in four sizes and five colors, static under reduced motion.
- `HeroButton`: seven variants (including `dangerSoft`), three sizes with touch and desktop heights, icon-only, full width, pending spinner, disabled state and `HeroButtonStyle` overrides.
- `HeroButtonGroup` and `HeroButtonGroupSeparator`: attached horizontal or vertical groups with shared borders, separators, full width and group-wide props.
- `HeroCloseButton`: the 24 px dismiss button with custom icon and style overrides.
- `HeroSeparator` (horizontal and vertical; default, secondary and tertiary) and `HeroSeparatorScope`.
- `HeroText` with `HeroHeading`, `HeroParagraph`, `HeroCode` and `HeroProse` for HeroUI's Typography component.
- `HeroKbd`, `HeroKbdAbbr`, `HeroKbdContent` and the `HeroKbdKey` symbol map.
- `HeroLink`, `HeroLinkIcon` and `HeroLinkHandler`; link semantics in `HeroInteractable`.
- `HeroChip` and `HeroChipLabel` with every variant, color and size.
- `HeroAvatar`, `HeroAvatarImage`, `HeroAvatarFallback` and `HeroAvatarScope` with image loading and fallbacks.
- `HeroAvatarGroup` (clip and ring overlap, grid layout, max count) and `HeroAvatarGroupCount`.
- `HeroBadge`, `HeroBadgeAnchor` and `HeroBadgeLabel`.
- `HeroInput`: single-line text input with field tokens, focus and invalid rings, `Form` integration and browser-style validation, plus the shared field primitives (`HeroFieldScope`, `HeroFieldBox`, `HeroTextInputCore`).
- `HeroLabel`: required asterisk, disabled and invalid states; tapping it focuses its control.
- `HeroDescription`: muted helper text, hidden while its field is invalid.
