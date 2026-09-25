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
- `HeroTextArea`: rows, explicit height and an optional vertical resize grip.
- `HeroSurface` and `HeroSurfaceScope` with the four surface variants.
- `HeroSkeleton` and `HeroSkeletonGroup`: shimmer, pulse or no animation, with a synchronised group shimmer.
- `HeroToggleButton` (standard and ghost, three sizes, icon-only, controlled or uncontrolled, style overrides) and the shared `HeroSelectionMode`.
- `HeroToggleButtonGroup` and `HeroToggleButtonGroupSeparator`: single or multiple selection, attached or detached, orientation and roving arrow-key focus.
- `HeroTabs` with `HeroTabListContainer`, `HeroTabList`, `HeroTab`, `HeroTabIndicator`, `HeroTabSeparator` and `HeroTabPanel`: sliding indicator, overflow scrolling with fades and chevrons, variants, alignment, orientation and keyboard navigation.
- `HeroPagination` with its parts and the `heroPaginationRange` helper.
- `HeroBreadcrumbs` and `HeroBreadcrumbsItem`.
- `HeroFieldError` and `HeroValidationResult`.
- `HeroForm` with native and aria validation behaviour (`HeroValidationBehavior`), server errors, submit and reset, and `HeroButton.type`.
- `HeroTextField` (convenience and composed forms, `FormField<String>` validation) and `HeroFieldLayout`.
- `HeroProgressCircle`: determinate and indeterminate circular progress with composable track and fill circles.
- `HeroMeter`: label, output, track and fill with sizes, colors and intl value formatting.
- `HeroSlider`: single and range thumbs, vertical orientation, keyboard, RTL and `FormField` / `HeroForm` integration.
- `HeroAlert`: status alerts with default icons, indicator, content, title, description, actions and a live-region option.
- `HeroToolbar`: a single Tab stop with arrow, Home and End navigation and the attached pill style; button and toggle groups follow the toolbar orientation.
