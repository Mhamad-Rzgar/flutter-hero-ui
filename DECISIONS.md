# Decisions

Where HeroUI's behaviour or look is ambiguous, cannot be expressed directly in Flutter, or the
docs and source disagree, the option closest to the original is chosen and recorded here.
Newest entries are appended at the end of each section.

## Naming and API

- **`default` is spelled `standard`.** `default` is a reserved word in Dart, so HeroUI enum
  values named `default` become `standard` (`HeroColor.standard`,
  `HeroCardVariant.standard`). The `--default` color token is `HeroColors.defaultColor`; every
  other token keeps its CSS name in camelCase (`--default-hover` → `defaultHover`).
- **`HeroThemeData` is the ThemeExtension, `HeroTheme` is the widget.** Flutter's own pattern
  (`Theme` / `ThemeData`). `HeroTheme.of(context)` resolves the nearest `HeroTheme`, then a
  `HeroThemeData` inside a Material `ThemeData.extensions`, then the default light theme.
- **Boolean props keep HeroUI's names** (`isDisabled`, `isPending`, `isInvalid`, ...) for
  familiarity; callbacks follow Flutter (`onPressed`, `onChanged`).
- **Disabled state is explicit.** Like HeroUI, a button without a handler is still enabled; only
  `isDisabled` disables it (Flutter's "null callback disables" convention is not used).
- **Compound components map to `HeroXY` sub-widgets** plus convenience slot parameters on the
  main widget for the common fixed layouts.

## Tokens and theming

- **OKLCH is evaluated in Dart.** Tokens are declared in OKLCH exactly as in
  `variables.css` and converted to sRGB with the CSS Color 4 matrices. Out-of-gamut channels are
  clipped, which is what browsers do when painting to an sRGB surface. `color-mix()` follows
  CSS Color 5 (premultiplied alpha; percentages summing below 100% scale the alpha, so
  `--field-hover` is 92% opaque exactly as in the browser).
- **Calculated tokens are derived, not copied.** `HeroColors.derive` applies the light or dark
  formulas (soft tints are 15%/20% in light and 12%/16% in dark, except danger which stays
  15%/20%), so custom sources and presets stay consistent.
- **Presets reproduce the theme builder output.** Values come from HeroUI's generated
  `theme-presets.css`, including the brand-inspired presets shipped by the HeroUI theme builder
  (Netflix, Uber, Spotify, Coinbase, Airbnb, Discord, Rabbit) with HeroUI's own labels. When a
  preset overrides `--radius` but not `--field-radius`, the field radius stays 12: in CSS the
  inherited `--field-radius` is computed on `:root` before the preset applies.
- **Chart colors** (`--chart-1..5`) are part of `HeroColors` for every theme, derived from the
  accent with the relative-color lightness offsets used by the presets.
- **Inset shadows.** CSS `inset` box-shadows have no `BoxShadow` equivalent. HeroUI only uses
  one (`0 0 1px rgba(255,255,255,.3) inset` on dark overlays); it is exposed as
  `HeroShadow.insetColor` and painted as an inner hairline.
- **Shadows in light mode** use HeroUI's layered `--surface-shadow`, `--overlay-shadow` and
  `--field-shadow` stacks converted to `BoxShadow` lists (CSS blur radius maps to
  `BoxShadow.blurRadius`).
- **Continuous corners by default.** HeroUI's design language follows iOS; iOS draws rounded
  rectangles with continuous (superellipse) corners, while CSS can only draw circular arcs.
  Radii keep HeroUI's values and are rendered with `RoundedSuperellipseBorder`.
  `HeroCornerStyle.circular` reproduces browser rendering exactly.
- **Responsive sizing.** HeroUI sizes controls with `md:` utilities (e.g. button
  `h-10 md:h-9`). `HeroDensity.adaptive` (default) uses the larger touch sizes below 768
  logical pixels and the compact sizes from 768 up. `HeroDensity.touch`/`desktop` pin one set.
  Components that change at `sm:` (640) use `HeroBreakpoints.sm` the same way.
- **Fonts.** Inter (400/500/600/700, static TTF from Google Fonts, OFL) is bundled so text
  renders identically on every platform and in golden tests. Tailwind's `font-mono` is a
  system stack; JetBrains Mono (one of HeroUI's theme-builder fonts, OFL) is bundled as the
  mono family for the same reason, with the system stack as fallback.
- **Text leading.** Text styles use `TextLeadingDistribution.even` so line boxes centre text
  like CSS half-leading.
- **`intl`** is the only runtime dependency besides Flutter; it provides locale-aware date and
  number formatting (DateField, Calendar, NumberField). It is not a UI kit.

## Interaction

- **Press feedback is scale and color, never ink.** `HeroPressScale` reproduces
  `transform: scale(0.97)` with HeroUI's `250ms ease` transition.
- **Minimum pressed duration.** On touch screens down and up can arrive in the same frame, so
  the pressed state is held for at least 100 ms after a tap to make feedback visible (browsers
  naturally show `:active` for the length of the click).
- **Hover** is tracked with `MouseRegion` for any hovering pointer, like CSS
  `@media (hover: hover)`; touch never produces hover.
- **Focus-visible** follows Flutter's focus highlight mode: keyboard navigation shows the ring,
  pointer and touch focus do not (React Aria's `useFocusRing` behaviour).
- **Focus ring geometry.** `ring-2 ring-offset-2 ring-offset-background` is drawn outside the
  component following its shape; the offset gap is filled with the `background` token exactly
  like Tailwind's offset shadow, and the ring fades in over 100 ms (the box-shadow transition).
- **Keyboard press.** Enter and Space activate and flash the pressed state.

## Overlays

- **Anchored overlays use `OverlayPortal.overlayChildLayoutBuilder`**, so popovers follow
  their trigger through scrolling and transforms without `CompositedTransformFollower`.
- **Positioning** follows React Aria: preferred placement, `offset`, `crossOffset`, flip to the
  opposite side when it does not fit and has more room, shift along the cross axis, 12 px
  container padding inside the safe area, and a max height limited to the chosen side.
- **Showing is deferred by one frame** when `isOpen` flips to true during a build
  (`OverlayPortalController.show()` may not run during build). The entrance starts at opacity 0,
  so the delay is invisible.
- **Escape closes the top-most open overlay even when focus stayed on the page.** React Aria
  relies on focus being inside the overlay; in Flutter focus often remains on the trigger, so the
  key is handled globally for the most recently opened overlay.
- **Modal popovers** (selects, menus) put a transparent barrier behind the overlay, matching
  React Aria's underlay: an outside press closes the overlay without activating what is below.
- **Placement-dependent visuals** (arrow rotation, transform origin) are resolved after layout
  and applied from the next frame; again invisible because the entrance starts transparent.

## App shell

- **`HeroApp` builds on `WidgetsApp`** so no Material or Cupertino styling can leak in. Pages
  use `HeroPageRoute` (iOS push/pop and back swipe) whose page paints the `background` token, so
  the transition's dimming barrier never shows through a transparent page.
- **Scrolling** uses `BouncingScrollPhysics` on every platform, no overscroll glow, and a thin
  scrollbar in the `scrollbar` color on desktop platforms.

## Icons

- **Icons are vector paths, not a font.** `HeroIcon` paints SVG path data with the current
  color (like `fill="currentColor"`). The set contains HeroUI's built-in component icons and
  Gravity UI icons (MIT), the family used throughout HeroUI's docs. No SVG package is needed.
- Directional icons (chevrons, arrows) mirror in right-to-left layouts.

## Testing

- **Goldens are compared on Linux only.** Glyph rasterisation differs slightly between
  operating systems; CI runs on Ubuntu with the pinned Flutter version the goldens were
  generated with. Other hosts skip golden assertions.
- Golden tests load the bundled fonts through `loadHeroFonts()` and render with real shadows.

## Docs vs. source (the source wins)

- Tooltip `delay`/`closeDelay`: the docs say 700/0 ms; the effective defaults are the CSS
  variables `--tooltip-delay: 1500ms` and `--tooltip-close-delay: 500ms`.
- ListBox `selectionMode`: the docs say `single`; the component uses React Aria's default
  `none`.
- Dropdown popover placement: the docs say `bottom`; React Aria's menu trigger default
  `bottom start` applies.
- ComboBox `variant` (primary/secondary) exists in the source and demos but not in the API
  table; it is supported.
- `toast.info()` uses the `accent` variant.
- Button `danger-soft` exists in the styles and the variants demo but not in the API table; it
  is supported as `HeroButtonVariant.dangerSoft`.
- Card: the docs text says the default card uses `surface-secondary`; the CSS and demos use
  `--surface`, which is followed.
- Kbd: the docs describe `Kbd.Abbr(title)`; the code renders a symbol from a built-in key map
  (`Kbd.Abbr(keyValue)`) plus `Kbd.Content`. The code is followed.
- TextArea `rows`: the docs say 3; the source sets none (browser default 2).
- NumberField `onChange` fires on commit (blur, Enter, stepper), not on every keystroke.
- Switch anatomy: the docs snippet places `Control` outside `Content`; the demos and source
  place it inside, which is followed.
- DateField: the docs list `variant` on `DateField.Input`; the source ignores it there.
- Calendar navigation buttons use radius 16 while RangeCalendar uses 12 in the source; both are
  reproduced as-is.
- FieldError text inside Checkbox, Radio and Switch is muted, not danger-colored, as in the CSS.

## Components

- **Button: automatic pending spinner.** A pending `HeroButton` shows a small `HeroSpinner` in
  its start slot automatically (HeroUI v3 leaves the spinner to the caller); a custom
  `builder` opts out.
- **ButtonGroup separators** are `HeroButtonGroupSeparator` children placed between buttons
  (HeroUI renders the separator inside the following button); the next button draws the
  divider.
- **ButtonGroup props reach wrapped buttons.** Buttons inside a wrapper child (such as a
  dropdown trigger) inherit the group's props through an inherited scope; React only passes
  them to direct children.
- **Pixel snapping.** Buttons and groups snap to whole logical pixels like browsers do, so
  attached buttons meet without an anti-aliasing seam. A lone outline button inside a group
  drops its side borders exactly as HeroUI's CSS does.
- **Pending and disabled semantics.** Pending controls are announced as not enabled;
  disabled controls are not announced as focusable.
