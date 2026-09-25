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
- `HeroColorSwatch` (five sizes, circle and square, alpha checkerboard) and the shared color model (`HeroColorValue`, channels and ranges, parsing and formatting, `heroColorName`).
- `HeroColorSwatchPicker` with sizes, shapes, grid and stack layouts, selection indicator and roving keyboard focus.
- `HeroColorSlider` for all eight channels with gradient track, both orientations and keyboard support.
- `HeroColorArea`: two-dimensional gradients for every channel pair, keyboard support, hue preserved at zero saturation.
- `HeroColorField` and the color input group: hex or channel entry with stepping and form validation.
- `HeroColorPicker` with trigger and popover; bound children share one color value.
- `HeroEmptyState`: the "No results found" placeholder for empty collections.
- `HeroListBox` with `HeroListBoxItem`, `HeroListBoxSection`, `HeroHeader` and a load-more item: selection, keyboard navigation, typeahead, virtual focus and virtualised rendering, on the shared `HeroSelectionManager`, `HeroTypeahead` and `HeroCollection`.
- `HeroTagGroup` and `HeroTag` with sizes, variants, selection, remove buttons and keyboard support.
- `HeroErrorMessage` for non-form components, and `errorMessage` on `HeroTagGroup`.
- `HeroAccordion` with items, triggers and animated panels on the shared `HeroCollapsible`.
- `HeroDisclosure` with heading, trigger and animated content.
- `HeroDisclosureGroup` with coordinated expansion and group keyboard navigation.
- `HeroModal` with the shared modal route: backdrop variants, sizes, placements, scroll behaviour, mobile bottom sheet, focus trapping, declarative and imperative APIs; `HeroOverlayController`, `HeroDialogScope` and `HeroButton(slot: close)`.
- `HeroAlertDialog` with status icons and confirm/cancel actions.
- `HeroDrawer` with placements (swapped in RTL) and drag to dismiss.
- `HeroToast` with queue, placements, stacking with expand on hover, timeouts and promise toasts.
- `HeroTooltip` with warm-up delays, arrow, placements and long press on touch.
- `HeroPopover` with dialog, heading, arrow and placements.
- `HeroCard` with `HeroCardHeader`, `HeroCardTitle`, `HeroCardDescription`, `HeroCardContent`, `HeroCardFooter` and `HeroCardStyle`: four variants, surface scope, row layouts, background and overlay layers, pressable and link cards.
- `HeroScrollShadow` with continuous scroll-driven fades, size, offset, controlled visibility, hidden scrollbar and a list-view builder.
- `HeroCheckbox` with content, control and indicator parts, checkmark-draw and indeterminate animations, variants, invalid, read-only and form validation.
- `HeroCheckboxGroup` (`FormField<Set<String>>`) with shared states and validation.
- `HeroRadioGroup` and `HeroRadio`: one Tab stop, arrow keys that select and wrap, orientation and `FormField<String>` validation.
- `HeroSwitch` (three sizes, thumb icons, label position, drag to toggle, `FormField<bool>`) and `HeroSwitchGroup`.
- `HeroFieldset` with legend, description, field groups, actions and disabled propagation through the new `HeroDisabledScope`.
- `HeroInputGroup` with prefix and suffix addons, text-area and vertical layouts; `HeroTextAreaResizeGrip` is public.
- `HeroSearchField` with search icon, clear button, Escape to clear and `onSubmitted`.
