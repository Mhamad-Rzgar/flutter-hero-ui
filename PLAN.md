# hero_ui — Implementation Plan

hero_ui is a Flutter port of the [HeroUI v3](https://heroui.com) component library, plus a Pro
tier (`hero_ui_pro`) and a gallery app. The goal is the same design language, component set,
variant system and a familiar API, in Dart, for iOS, Android and the web.

## 1. Sources of truth

| Source | Used for |
| --- | --- |
| [heroui-inc/heroui](https://github.com/heroui-inc/heroui) `main` @ `7809e16` (v3.2.6) | Tokens (`packages/styles/themes/default/variables.css`, `themes/shared/theme.css`), component CSS (`packages/styles/components/*.css`), variant matrices (`packages/styles/src/components/*/*.styles.ts`), props (`packages/react/src/components/*`) |
| [heroui.com/en/docs/react/components](https://heroui.com/en/docs/react/components) and the docs sources (`apps/docs/content/docs/en/react/components`) | API tables, anatomy, examples (`apps/docs/src/demos/en/*`) reproduced in the gallery |
| [heroui.com/en/themes](https://heroui.com/en/themes) and `apps/docs/src/styles/theme-presets.css` | Named theme presets (Default, Sky, Lavender, Mint, Netflix, Uber, Spotify, Coinbase, Airbnb, Discord, Rabbit) |
| [heroui.pro](https://heroui.pro) public docs, templates and theme stylesheets | Pro component inventory, templates, premium design systems (Brutalism, Glass, Mouve) |

When the docs and the source disagree, the source (CSS and component code) wins; every such
case is logged in [DECISIONS.md](DECISIONS.md).

## 2. Visual priority

1. **HeroUI first.** Exact tokens, geometry, states and motion from the source.
2. **iOS second.** Where HeroUI is silent or Flutter needs an idiom: continuous corners
   (`RoundedSuperellipseBorder`), press feedback by scale/opacity (no ink), iOS page
   transitions and sheets, bouncing scroll physics, iOS curves. The same look on every platform.
3. **Nothing Material by default.** Material is used only as invisible infrastructure
   (`ThemeExtension`, localizations). No ripples, elevation, Material dialogs or typography.
4. **Custom when forced**, logged in DECISIONS.md.

## 3. Repository layout

```
packages/hero_ui        tokens, theme, foundations and all open-source components
packages/hero_ui_pro    Pro components, templates and premium design systems
apps/gallery            showcase app (iOS, Android, web)
docs/components         one page per component (overview, usage, variants, API)
tool/                   repository scripts (gallery registry generator)
```

Melos (pub workspaces) drives `analyze`, `test` and `format` across packages; CI runs
`flutter analyze` and `flutter test` on every push.

## 4. Foundations

| Layer | Flutter API | Notes |
| --- | --- | --- |
| Color math | `oklch()`, `OkLab`, `OkLch`, `colorMix()` | Evaluates HeroUI's OKLCH tokens and CSS `color-mix()` exactly (premultiplied alpha, sub-100% alpha scaling). |
| Tokens | `HeroColors` (74 tokens), `HeroRadii`, `HeroSpacing`, `HeroTypography`, `HeroShadows`, `HeroMotion` | Source tokens in `HeroColorSource`; calculated tokens derived by `HeroColors.derive` with the light/dark formulas of `variables.css`. |
| Theme | `HeroThemeData` (a `ThemeExtension`), `HeroTheme.of(context)`, `AnimatedHeroTheme`, `HeroThemePreset` | Single access point. Works standalone, inside `HeroApp`, or registered in a Material `ThemeData`. |
| Density | `HeroDensity`, `HeroBreakpoints` | Reproduces HeroUI's `sm:`/`md:` responsive sizes (touch sizes below 768, compact from 768). |
| Variants | `HeroColor`, `HeroSize`, `HeroVariant`, `HeroVariants.resolve`, `HeroSizeValues` | The variant × color × size matrix resolved once. |
| Interaction | `HeroInteractable`, `HeroInteractionState`, `HeroFocusRing`, `HeroPressScale`, `HeroDisabledOpacity` | React Aria `usePress`/`useHover`/`useFocusRing` counterpart; keyboard-only focus ring with background offset. |
| Overlay | `HeroAnchoredOverlay`, `HeroPlacement`, `computeHeroOverlayGeometry`, `HeroOverlayTransition` | React Aria placement/flip/shift, outside-press and Escape dismissal, modal barrier, HeroUI popover enter/exit motion. |
| Icons | `HeroIcon`, `HeroIconData`, `HeroIcons` | HeroUI's built-in icons plus Gravity UI icons (the docs' icon set), parsed from SVG path data. |
| App shell | `HeroApp`, `HeroPageRoute`, `HeroScrollBehavior` | `WidgetsApp` based; no Material defaults. |
| Testing | `loadHeroFonts()` (`package:hero_ui/hero_ui_testing.dart`) | Real fonts in golden tests. |

## 5. API conventions

- Widget names: `Hero` + HeroUI name (`Button` → `HeroButton`, `ListBox` → `HeroListBox`).
- Compound parts: `X.Y` → `HeroXY` (`Card.Header` → `HeroCardHeader`). The parent shares state
  with its parts through an `InheritedWidget`. Where HeroUI usage is overwhelmingly a fixed
  layout (label + input + description + error), the main widget also takes convenience slot
  parameters (`label`, `description`, `errorMessage`, `placeholder`, ...).
- Slots: `startContent` / `endContent` (RTL aware). `children` → `child`/`children`;
  render-prop children → `builder`.
- HeroUI's enum value `default` is a reserved word in Dart and is spelled `standard`
  (`HeroColor.standard`, `HeroCardVariant.standard`). Kebab-case values become camelCase
  (`danger-soft` → `dangerSoft`). The `--default` color token is `colors.defaultColor`.
- Shared enums: `HeroColor {accent, standard, success, warning, danger}`, `HeroSize {sm, md, lg}`.
  Components with other sets define their own enum (`HeroSpinnerSize {sm, md, lg, xl}`).
- Booleans keep HeroUI names: `isDisabled`, `isPending`, `isInvalid`, `isReadOnly`,
  `isRequired`, `isSelected`, `isIndeterminate`, `isIconOnly`, `isOpen`, `fullWidth`.
- Events: `onPress` → `onPressed` (`VoidCallback`), `onChange` → `onChanged`
  (`ValueChanged<T>`), `onSelectionChange` → `onSelectionChanged`, `onOpenChange` →
  `onOpenChanged`, `onAction` → `onAction`, `onClose` → `onClose`.
- Controlled and uncontrolled: `value` + `defaultValue` + `onChanged` (likewise `isSelected` /
  `defaultSelected`, `isOpen` / `defaultOpen`, `selectedKeys` / `defaultSelectedKeys`). Text
  inputs also accept a `TextEditingController` and `FocusNode`.
- Collections: item widgets with an `id` (`HeroListBoxItem(id: 'a', textValue: 'Apple')`), or
  `items` + `itemBuilder`. Selection via `HeroSelectionMode {none, single, multiple}`,
  `disabledKeys`.
- Overlays: declarative (`isOpen` / `onOpenChanged` + trigger) and imperative helpers
  (`HeroModal.show`, `HeroToast.show`) returning futures.
- Dates: `DateTime` (date-only values at midnight), `HeroTime`, `HeroDateRange`; formatting via
  `intl`. Colors: `Color` + `HSVColor`, channel enums for sliders.
- Forms: every form control accepts `validator`, `onSaved`, `autovalidateMode` and registers
  with the nearest Flutter `Form` through `FormField<T>`. `Form` → `HeroForm`.
- No hard-coded colors, sizes, radii or durations inside components: everything comes from
  `HeroTheme.of(context)`.

## 6. Definition of a slice

One component = one slice = one commit. A slice re-reads the component's docs and source,
implements every variant, color, size, state and slot, adds widget tests plus light and dark
golden tests, a gallery page reproducing every docs example (with playground and code sheet),
`docs/components/<name>.md`, dartdoc on every public member, passes `flutter analyze` with no
issues and `flutter test`, and updates PROGRESS.md and CHANGELOG.md.

## 7. Build order

Slices are ordered so that every dependency lands before its dependents. Status is tracked in [PROGRESS.md](PROGRESS.md).

### Foundations

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| F1 | Design tokens & HeroTheme | `HeroThemeData, HeroTheme, HeroColors, HeroRadii, HeroSpacing, HeroTypography, HeroShadows, HeroMotion` | — |
| F2 | Theme presets (light/dark + named presets) | `HeroThemePreset` | F1 |
| F3 | App shell & test harness | `HeroApp, HeroPageRoute, HeroScrollBehavior, loadHeroFonts` | F1, F2 |
| F4 | Interaction layer | `HeroInteractable, HeroFocusRing, HeroPressScale, HeroDisabledOpacity` | F1 |
| F5 | Variant system | `HeroColor, HeroSize, HeroVariant, HeroVariants, HeroSizeValues` | F1, F4 |
| F6 | Icon set | `HeroIcon, HeroIconData, HeroIcons` | F1 |
| F7 | Overlay & positioning layer | `HeroAnchoredOverlay, HeroPlacement, HeroOverlayTransition` | F1, F4 |
| F8 | Gallery skeleton | apps/gallery | F1–F7 |

### Buttons & typography

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| C01 | Spinner | `HeroSpinner` | F3 |
| C02 | Typography | `HeroText` | F1 |
| C03 | Label | `HeroLabel` | F1 |
| C04 | Description | `HeroDescription` | F1 |
| C05 | FieldError | `HeroFieldError` | F1 |
| C06 | ErrorMessage | `HeroErrorMessage` | F1 |
| C07 | Button | `HeroButton` | Spinner, F3, F4 |
| C08 | CloseButton | `HeroCloseButton` | Button |
| C09 | ButtonGroup | `HeroButtonGroup` | Button |
| C10 | ToggleButton | `HeroToggleButton` | Button |
| C11 | ToggleButtonGroup | `HeroToggleButtonGroup` | ToggleButton |
| C12 | Kbd | `HeroKbd` | F1 |
| C13 | Link | `HeroLink` | F4, F6 |

### Data display

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| C14 | Badge | `HeroBadge` | F3 |
| C15 | Chip | `HeroChip` | F3 |
| C16 | Avatar | `HeroAvatar` | F3 |
| C17 | AvatarGroup | `HeroAvatarGroup` | Avatar |
| C18 | Skeleton | `HeroSkeleton` | F1 |
| C19 | ProgressBar | `HeroProgressBar` | Label |
| C20 | ProgressCircle | `HeroProgressCircle` | F3 |
| C21 | Meter | `HeroMeter` | ProgressBar |
| C22 | Separator | `HeroSeparator` | F1 |
| C23 | Surface | `HeroSurface` | F1 |
| C24 | Card | `HeroCard` | Surface |
| C25 | Alert | `HeroAlert` | CloseButton |
| C26 | ScrollShadow | `HeroScrollShadow` | F1 |
| C27 | EmptyState | `HeroEmptyState` | F1 |
| C28 | Toolbar | `HeroToolbar` | ButtonGroup, ToggleButtonGroup, Separator |

### Forms

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| C29 | Input | `HeroInput` | F4 |
| C30 | TextArea | `HeroTextArea` | Input |
| C31 | InputGroup | `HeroInputGroup` | Input |
| C32 | TextField | `HeroTextField` | Label, Description, FieldError, Input, TextArea, InputGroup |
| C33 | SearchField | `HeroSearchField` | TextField, CloseButton |
| C34 | NumberField | `HeroNumberField` | TextField, InputGroup |
| C35 | InputOTP | `HeroInputOTP` | Input |
| C36 | Checkbox | `HeroCheckbox` | Label, Description, FieldError |
| C37 | CheckboxGroup | `HeroCheckboxGroup` | Checkbox |
| C38 | RadioGroup | `HeroRadioGroup, HeroRadio` | Label, Description, FieldError |
| C39 | Switch | `HeroSwitch, HeroSwitchGroup` | Label, Description |
| C40 | Slider | `HeroSlider` | Label |
| C41 | Fieldset | `HeroFieldset` | Label, Description, FieldError |
| C42 | Form | `HeroForm` | form controls |

### Overlays

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| C43 | Tooltip | `HeroTooltip` | F5 |
| C44 | Popover | `HeroPopover` | F5 |
| C45 | Modal | `HeroModal` | Button, CloseButton |
| C46 | AlertDialog | `HeroAlertDialog` | Modal |
| C47 | Drawer | `HeroDrawer` | Modal |
| C48 | Toast | `HeroToast` | Button, CloseButton, Spinner |

### Collections & navigation

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| C49 | ListBox | `HeroListBox, HeroHeader` | F4 |
| C50 | Dropdown | `HeroDropdown, HeroMenu` | ListBox, Popover, Kbd |
| C51 | Select | `HeroSelect` | ListBox, Popover, TextField parts |
| C52 | ComboBox | `HeroComboBox` | ListBox, Popover, Input |
| C53 | Autocomplete | `HeroAutocomplete` | ComboBox, TagGroup parts, SearchField |
| C54 | TagGroup | `HeroTagGroup, HeroTag` | F4, CloseButton |
| C55 | Tabs | `HeroTabs` | F4 |
| C56 | Accordion | `HeroAccordion` | Surface |
| C57 | Disclosure | `HeroDisclosure` | Button |
| C58 | DisclosureGroup | `HeroDisclosureGroup` | Disclosure |
| C59 | Breadcrumbs | `HeroBreadcrumbs` | Link |
| C60 | Pagination | `HeroPagination` | Button |
| C61 | Table | `HeroTable` | Checkbox, ScrollShadow |

### Date & time

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| C62 | Calendar | `HeroCalendar` | Button |
| C63 | RangeCalendar | `HeroRangeCalendar` | Calendar |
| C64 | DateField | `HeroDateField` | InputGroup, Label |
| C65 | TimeField | `HeroTimeField` | DateField |
| C66 | DatePicker | `HeroDatePicker` | DateField, Calendar, Popover |
| C67 | DateRangePicker | `HeroDateRangePicker` | DateField, RangeCalendar, Popover |

### Color

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| C68 | ColorSwatch | `HeroColorSwatch` | F1 |
| C69 | ColorSlider | `HeroColorSlider` | Slider |
| C70 | ColorArea | `HeroColorArea` | F4 |
| C71 | ColorField | `HeroColorField` | InputGroup |
| C72 | ColorSwatchPicker | `HeroColorSwatchPicker` | ColorSwatch |
| C73 | ColorPicker | `HeroColorPicker` | ColorArea, ColorSlider, ColorField, ColorSwatchPicker, Popover |

### Pro foundations

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P00 | Pro chart kit | `HeroProChartScope, axes, grid, series painters` | hero_ui |

### Pro charts

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P01 | AreaChart | `HeroProAreaChart` | P00 |
| P02 | BarChart | `HeroProBarChart` | P00 |
| P03 | LineChart | `HeroProLineChart` | P00 |
| P04 | ComposedChart | `HeroProComposedChart` | P01–P03 |
| P05 | PieChart | `HeroProPieChart` | P00 |
| P06 | RadarChart | `HeroProRadarChart` | P00 |
| P07 | RadialChart | `HeroProRadialChart` | P00 |
| P08 | ChartTooltip | `HeroProChartTooltip, HeroProChartCrosshair, HeroProChartIndicator` | P00 |

### Pro data display

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P09 | NumberValue | `HeroProNumberValue` | hero_ui |
| P10 | TrendChip | `HeroProTrendChip` | Chip |
| P11 | KPI | `HeroProKpi` | Card, TrendChip, NumberValue |
| P12 | KPIGroup | `HeroProKpiGroup` | KPI |
| P13 | Widget | `HeroProWidget` | Card, charts |
| P14 | ItemCard | `HeroProItemCard` | Card |
| P15 | ItemCardGroup | `HeroProItemCardGroup` | ItemCard |
| P16 | EmptyState (Pro) | `HeroProEmptyState` | EmptyState, Button |
| P17 | ListView | `HeroProListView` | ListBox |
| P18 | ActionBar | `HeroProActionBar` | Toolbar, Button |
| P19 | Timeline | `HeroProTimeline` | Avatar |
| P20 | Carousel | `HeroProCarousel` | Button |
| P21 | FileTree | `HeroProFileTree` | Disclosure |
| P22 | FloatingToc | `HeroProFloatingToc` | Popover |
| P23 | HoverCard | `HeroProHoverCard` | Popover |
| P24 | HoloCard | `HeroProHoloCard` | Card |
| P25 | Map | `HeroProMap` | Card |
| P26 | DataGrid | `HeroProDataGrid, HeroProCell*` | Table, Checkbox, Select, Slider, Switch |
| P27 | Kanban | `HeroProKanban, HeroProKanbanColumn` | Card, ScrollShadow |
| P28 | Agenda | `HeroProAgenda` | Calendar |

### Pro feedback

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P29 | Rating | `HeroProRating` | F4 |
| P30 | EmojiReactionButton | `HeroProEmojiReactionButton` | Button, Popover |
| P31 | PressableFeedback | `HeroProPressableFeedback` | F4 |

### Pro forms

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P32 | NumberStepper | `HeroProNumberStepper` | Button |
| P33 | InlineSelect | `HeroProInlineSelect` | Select |
| P34 | NativeSelect | `HeroProNativeSelect` | Select |
| P35 | DropZone | `HeroProDropZone` | Button |
| P36 | RichTextEditor | `HeroProRichTextEditor` | Toolbar, TextArea |
| P37 | CheckboxButtonGroup | `HeroProCheckboxButtonGroup` | CheckboxGroup |
| P38 | RadioButtonGroup | `HeroProRadioButtonGroup` | RadioGroup |
| P39 | PhoneNumberField | `HeroProPhoneNumberField` | InputGroup, Select |
| P40 | NumberPad | `HeroProNumberPad` | Button |

### Pro navigation

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P41 | Segment | `HeroProSegment` | ToggleButtonGroup |
| P42 | Stepper | `HeroProStepper` | F4 |
| P43 | Navbar | `HeroProNavbar` | Link, Button |
| P44 | Sidebar | `HeroProSidebar` | ListBox, Drawer |
| P45 | AppLayout | `HeroProAppLayout` | Sidebar, Navbar |
| P46 | Resizable | `HeroProResizable` | F4 |
| P47 | SplitView | `HeroProSplitView` | Resizable |
| P48 | Command | `HeroProCommand` | Modal, ListBox, SearchField, Kbd |
| P49 | ContextMenu | `HeroProContextMenu` | Dropdown |

### Pro overlays

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P50 | Sheet | `HeroProSheet` | Drawer |
| P51 | EmojiPicker | `HeroProEmojiPicker` | Popover, SearchField |

### Pro mobile

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P52 | Fab | `HeroProFab` | Button |
| P53 | MorphButton | `HeroProMorphButton` | Button |
| P54 | ProgressButton | `HeroProProgressButton` | Button |
| P55 | SlideButton | `HeroProSlideButton` | F4 |
| P56 | SocialAuthButton | `HeroProSocialAuthButton` | Button |
| P57 | FlipCard | `HeroProFlipCard` | Card |
| P58 | WheelPicker | `HeroProWheelPicker, HeroProWheelPickerGroup` | F4 |
| P59 | WheelTimePicker | `HeroProWheelTimePicker` | WheelPicker |
| P60 | WheelDateTimePicker | `HeroProWheelDateTimePicker` | WheelPicker |
| P61 | DateTimePicker | `HeroProDateTimePicker` | WheelDateTimePicker, Sheet |

### Pro AI

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P62 | TextShimmer | `HeroProTextShimmer` | F1 |
| P63 | ChatLoader | `HeroProChatLoader` | TextShimmer |
| P64 | Markdown | `HeroProMarkdown` | Typography |
| P65 | CodeBlock | `HeroProCodeBlock` | Button |
| P66 | PromptSuggestion | `HeroProPromptSuggestion` | Button |
| P67 | PromptInput | `HeroProPromptInput` | TextArea, Button |
| P68 | ChatAttachment | `HeroProChatAttachment` | Chip, DropZone |
| P69 | ChatMessage | `HeroProChatMessage, HeroProChatMessageActions, HeroProChatSource(s), HeroProChatTool(Group)` | Avatar, Markdown, Disclosure |
| P70 | ChainOfThought | `HeroProChainOfThought` | Disclosure |
| P71 | ChatConversation | `HeroProChatConversation` | ChatMessage, ScrollShadow |
| P72 | ChatListView | `HeroProChatListView` | ListView |

### Pro composites

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| P73 | Filters | `HeroProFilters` | Slider, Chip, ToggleButtonGroup |

### Pro templates

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| T1 | Dashboard template | `HeroProDashboardTemplate` | AppLayout, KPI, charts, DataGrid |
| T2 | Mail template | `HeroProMailTemplate` | AppLayout, ListView, SplitView |
| T3 | Chat template | `HeroProChatTemplate` | AI components |
| T4 | Finances template | `HeroProFinancesTemplate` | KPI, charts, Table |
| T5 | CRM template | `HeroProCrmTemplate` | Kanban, DataGrid, Mouve theme |

### Premium themes

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| Z1 | Brutalism design system | `HeroProThemes.brutalism` | hero_ui tokens |
| Z2 | Glass design system | `HeroProThemes.glass` | hero_ui tokens |
| Z3 | Mouve design system | `HeroProThemes.mouve` | hero_ui tokens |

### Polish

| # | Slice | Flutter API | Depends on |
| --- | --- | --- | --- |
| G1 | Gallery chrome on hero_ui components | apps/gallery | all |

## 8. Component inventory by category

Grouped like [heroui.com/en/docs/react/components](https://heroui.com/en/docs/react/components). The full props → Flutter mapping of every component is in Part II.

### Buttons

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Button | `HeroButton` | - `variant: primary* \| secondary \| tertiary \| outline \| ghost \| danger \| danger-soft` (`danger-soft` → `dangerSoft`; exists in styles + `button-variants` demo but not in the docs API table) - `size: sm \| md* \| lg` - `fullWidth: false*`, `isIconOnly: fa… | `HeroInteractable` (hover/press/focus-visible state machine), `HeroFocusRing`, theme tokens, `HeroButtonGroup` inherited scope, `HeroSpinner` (demos), `IconTheme` sizing. |
| ButtonGroup | `HeroButtonGroup` | `orientation: horizontal* \| vertical`; `fullWidth: false*`; `variant` (any Button variant, no default → Button default); `size: sm \| md \| lg` (no default). | `HeroButton`, `HeroDropdown` + `HeroLabel`/`HeroDescription` (basic demo), `HeroChip` (demo). |
| CloseButton | `HeroCloseButton` | `variant: default*` (only value → `HeroCloseButtonVariant.standard`; can be omitted from the Flutter API or kept for parity). | `HeroInteractable`, `HeroFocusRing`, `HeroIcons.close`. |
| ToggleButton | `HeroToggleButton` | `variant: default* \| ghost` (→ `HeroToggleButtonVariant.standard \| ghost`); `size: sm \| md* \| lg` (null → inherit from `HeroToggleButtonGroup`); `isIconOnly: false*`. | `HeroInteractable`, `HeroFocusRing`, `HeroToggleButtonGroup` scope. |
| ToggleButtonGroup | `HeroToggleButtonGroup` | `orientation: horizontal* \| vertical`; `isDetached: false*`; `fullWidth: false*`; `size: sm \| md* \| lg` (propagated); `selectionMode: single* \| multiple`. | `HeroToggleButton`, shared `HeroGroupPosition` inherited scope (with ButtonGroup), roving-focus helper (shared with Toolbar), `HeroSelectionMode`. |

### Collections

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Dropdown | `HeroDropdown` | `trigger` `HeroMenuTriggerType {press*, longPress}`; popover `placement` (docs: bottom*; RAC MenuTrigger context actually supplies `bottomStart` when unset — verify visually, default to `bottomStart`), offset 8; menu `selectionMode` `{none*, single, multiple}`… | HeroPositioner/pop animation, collection model, HeroLabel, HeroDescription, HeroKbd, HeroHeader, HeroSeparator, HeroButton, HeroAvatar, icon set. |
| ListBox | `HeroListBox` | `selectionMode` `{none, single, multiple}` (docs claim single*; source passes RAC default **none***); root `variant` `{standard*, danger}` (no CSS effect at root); item `variant` `{standard*, danger}`. | collection model, HeroLabel, HeroDescription, HeroHeader, HeroSeparator, HeroKbd, HeroAvatar, HeroSurface. |
| TagGroup | `HeroTagGroup` | `size` `HeroSize {sm, md*, lg}`; `variant` `HeroTagVariant {standard*, surface}` (both set on group, inherited by tags); `selectionMode` `{none*, single, multiple}`; `isDisabled`. | collection model, HeroCloseButton, HeroLabel, HeroDescription, HeroErrorMessage, HeroEmptyState (p 8, 14px muted), HeroAvatar. |

### Colors

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| ColorArea | `HeroColorArea` | `showDots` (bool, false). `isDisabled`. | color foundations (HSV/HSL conversion, channel ranges, formatting), gradient painter, drag/gesture + focus foundation (shared with Slider), focus ring, HeroColorPickerScope. Demos use Select, ListBox, Label, ColorSwatch. |
| ColorField | `HeroColorField` | Group `variant`: primary* \| secondary. `fullWidth` (false) on field and group. Booleans `isRequired`, `isInvalid`, `isDisabled`, `isReadOnly`, `isWheelDisabled`. | field-surface foundation (shared with InputGroup/DateInputGroup), HeroTextField/EditableText, number-field stepping logic (shared with NumberField), Label, Description, FieldError, Form, ColorSwatch, color parse/format utils, HeroColorPickerScope. Demos use Su… |
| ColorPicker | `HeroColorPicker` | none. The Flutter API adds `isOpen`/`defaultOpen`/`onOpenChanged` (the React DialogTrigger is uncontrolled). | Popover/overlay foundation (anchored, animated, focus trap/restore), pressable/focus ring, HeroColorPickerScope, ColorSwatch, ColorArea, ColorSlider, ColorField, ColorSwatchPicker, Label. Demos use Button (icon-only), Select, ListBox, and a shuffle icon. |
| ColorSlider | `HeroColorSlider` | `orientation`: horizontal* \| vertical → `Axis`. `isDisabled`. | Label, color foundations, checkerboard + gradient painters, slider interaction foundation (shared with HeroSlider), focus ring, HeroColorPickerScope. Demos use ColorSwatch. |
| ColorSwatch | `HeroColorSwatch` | `size`: xs \| sm \| md* \| lg \| xl → `HeroColorSwatchSize {xs, sm, md, lg, xl}`. `shape`: circle* \| square → `HeroColorSwatchShape {circle, square}`. | checkerboard painter, `heroColorName`, `heroParseColor`, HeroColorPickerScope. |
| ColorSwatchPicker | `HeroColorSwatchPicker` | - `size`: xs \| sm \| md* \| lg \| xl → reuse `HeroColorSwatchSize` - `variant` (shape): circle* \| square → `HeroColorSwatchShape` - `layout`: grid* (row wrap) \| stack (column) → `HeroColorSwatchPickerLayout {grid, stack}` - Item `isDisabled` | checkerboard painter, color equality/name utils, focus traversal (ListBox-like roving focus), focus ring, check icon, HeroColorPickerScope. |

### Controls

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Slider | `HeroSlider` | `orientation: horizontal* \| vertical` (`Axis`); `isDisabled`. | `HeroLabel`, shared `HeroNumberFormatOptions`/formatter, focus-ring painter. |
| Switch | `HeroSwitch` | `size: sm \| md* \| lg` (`HeroSize`); SwitchGroup `orientation: vertical* \| horizontal`. | `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSize` enum, icons (gravity-ui BellFill, BellSlash, Check, Microphone, MicrophoneSlash, Moon, Power, Sun, VolumeFill, VolumeSlashFill). |

### Data Display

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Badge | `HeroBadge` | `variant: primary* \| secondary \| soft`; `color: default* \| accent \| success \| warning \| danger`; `size: sm \| md* \| lg`; `placement: top-right* \| top-left \| bottom-right \| bottom-left` (→ `HeroBadgePlacement.topRight…`). | `HeroAvatar` (demos), `HeroSeparator` (demo), theme tokens. |
| Chip | `HeroChip` | `variant: primary \| secondary* \| tertiary \| soft`; `color: default* \| accent \| success \| warning \| danger`; `size: sm \| md* \| lg`. | theme soft tokens, icon set, `HeroSeparator` (demo). |
| Table | `HeroTable` | `variant` `HeroTableVariant {primary*, secondary}`; `selectionMode` `{none*, single, multiple}`; column `allowsSorting`, `isRowHeader`; `HeroSortDirection {ascending, descending}`. | collection/selection model, HeroCheckbox (slot selection), HeroButton (slot chevron, icon buttons), HeroChip, HeroAvatar, HeroSpinner, HeroPagination, HeroEmptyState, icon set. |

### Date and Time

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Calendar | `HeroCalendar` | none (no tv variants). Booleans: `isDisabled`, `isReadOnly`, `isInvalid`. Layout modifiers from `visibleDuration`: month view* (`{months:1}`), `calendar--week-view` (`weeks`), `calendar--day-view` (`days`). `selectionMode`: single* \| multiple. | theme tokens (accent, accent-soft(-hover/-foreground), default, muted, focus), focus-ring & pressable foundation (scale-on-press), chevron icons, `intl`, HeroCalendarSystem, HeroCalendarScope. Demos use Button, ButtonGroup, Description, Select, ListBox, Label. |
| DateField | `HeroDateField` | Group `variant`: primary* \| secondary. `fullWidth` (bool, false) on both the field and the group. States: `isRequired`, `isInvalid`, `isDisabled`, `isReadOnly`. Note: docs list `variant` on `DateField.Input` too, but the source only honours it on Group. | Label, Description, FieldError, HeroForm/FormField, the field-surface foundation shared with InputGroup (tokens, focus/invalid rings), segment engine, `intl`. Demos use Surface, Button, Form, Select, ListBox, Tooltip, and calendar/chevron/circle-question icons… |
| DatePicker | `HeroDatePicker` | none on the picker (the Group keeps primary*/secondary and `fullWidth`). Booleans `isDisabled`, `isInvalid`, `isRequired`, `isReadOnly`, `isOpen`/`defaultOpen`. | HeroDateField parts (DateInputGroup, segment engine), HeroCalendar (+ year picker), Popover/overlay foundation (anchored positioning, enter/exit animation, focus trap and restore), pressable Button primitive, focus ring, calendar icon. Demos use TimeField, Sel… |
| DateRangePicker | `HeroDateRangePicker` | none (the Group keeps variant/fullWidth). Booleans `isDisabled`, `isInvalid`, `isRequired`, `isReadOnly`. | HeroDateInputGroup + segment engine, HeroRangeCalendar, Popover/overlay foundation, focus ring, calendar icon. Demos use TimeField, Select, ListBox, Switch, Form, Button, Label, Description, FieldError. |
| RangeCalendar | `HeroRangeCalendar` | none. Booleans `isDisabled`, `isReadOnly`, `isInvalid`, `allowsNonContiguousRanges`. Layout modifiers week/day view as in Calendar. | everything HeroCalendar needs (shared HeroCalendarScope + year picker). Demos use Button, ButtonGroup, Description, Select, ListBox, Label. |
| TimeField | `HeroTimeField` | Group `variant`: primary* \| secondary. `fullWidth` (false) on field and group. Booleans `isRequired`, `isInvalid`, `isDisabled`, `isReadOnly`. | everything DateField uses (HeroDateInputGroup + segment engine, Label, Description, FieldError, Form); clock icon. |

### Feedback

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Alert | `HeroAlert` | `status: default* \| accent \| success \| warning \| danger` → `HeroColor` (`standard` default). | `HeroSurface` context (variant default), `HeroIcons` status icons, `HeroButton`, `HeroCloseButton`, `HeroSpinner` (demo), responsive breakpoint helper. |
| Meter | `HeroMeter` | `size: sm \| md* \| lg`; `color: default \| accent* \| success \| warning \| danger` (→ `HeroColor`, default `accent`). | `HeroLabel` (forms), `intl` NumberFormat, theme tokens. |
| ProgressBar | `HeroProgressBar` | `size: sm \| md* \| lg`; `color: default \| accent* \| success \| warning \| danger`; `isIndeterminate: false*`. | `HeroLabel`, `intl`; demo needs `HeroNumberField`, `HeroSelect`, `HeroListBox`, `HeroSeparator`. |
| ProgressCircle | `HeroProgressCircle` | `size: sm \| md* \| lg`; `color: default \| accent* \| success \| warning \| danger`; `isIndeterminate: false*`. | `CustomPainter`, `HeroLabel` (demo), theme tokens. |
| Skeleton | `HeroSkeleton` | `animationType: shimmer* \| pulse \| none` (default resolved from theme `HeroThemeData.skeletonAnimation`, mirroring the `--skeleton-animation` CSS variable, default `shimmer`; prop overrides). | theme (`skeletonAnimation`, `--surface-tertiary`), a shared shimmer `AnimationController` helper. |
| Spinner | `HeroSpinner` | `size: sm \| md* \| lg \| xl` (→ `HeroSpinnerSize`); `color: current \| accent* \| success \| warning \| danger` (→ `HeroSpinnerColor`, `current` = inherit `DefaultTextStyle`/`IconTheme` color). | `CustomPainter`, reduced-motion helper; used by Button (pending), Alert, Toast, etc. |

### Forms

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Checkbox | `HeroCheckbox` | `variant: primary* \| secondary` (inherits `HeroCheckboxGroup` variant); booleans `isSelected`, `isIndeterminate`, `isDisabled`, `isInvalid`, `isReadOnly`, `isRequired`. | `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, focus-ring painter, path-draw animation helper. |
| CheckboxGroup | `HeroCheckboxGroup` | `variant: primary* \| secondary` (in source/demos, not in docs API table; propagated to child checkboxes). | `HeroCheckbox`, `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSurface`, icons (Envelope, Comment, Bell). |
| Description | `HeroDescription` | none. | theme, `HeroFieldScope`. |
| ErrorMessage | `HeroErrorMessage` | none. | `HeroTagGroup`/`HeroTag` (collections group), `HeroLabel`, `HeroDescription`. |
| FieldError | `HeroFieldError` | none. | `HeroFieldScope`, `HeroTextField`, `HeroLabel`, `HeroInput`. |
| Fieldset | `HeroFieldset` | none (`isDisabled` boolean via native `disabled`). | `HeroForm`, `HeroTextField`, `HeroInput`, `HeroTextArea`, `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroButton`, `HeroSurface`, icon (FloppyDisk). |
| Form | `HeroForm` | none. No styles (layout only via the child). | Flutter `Form`, all form controls above, `HeroButton` (submit/reset types), `HeroTextField`, `HeroFieldError`, icons (Check). |
| Input | `HeroInput` | `variant: primary* \| secondary` (`HeroFieldVariant`); `fullWidth: false*`. | theme field tokens, focus/invalid ring painter, `HeroFieldScope`, `HeroLabel`, `HeroSurface` (demo). |
| InputGroup | `HeroInputGroup` | `variant: primary* \| secondary` (inherits TextField scope); `fullWidth: false*`. | `HeroTextField`, `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroButton`, `HeroChip`, `HeroKbd`, `HeroSpinner`, `HeroTooltip`, `HeroSurface`, icon set (gravity-ui: Envelope, Eye, EyeSlash, Globe, Copy, At, Plus, PlugConnection, Microphone, ArrowUp). |
| InputOTP | `HeroInputOTP` | `variant: primary* \| secondary`; booleans `isDisabled`, `isInvalid`. | `HeroLabel`, `HeroDescription`, `HeroFieldError` styling, `HeroForm`, `HeroButton`, `HeroSpinner`, `HeroLink`, `HeroSurface`. |
| Label | `HeroLabel` | booleans `isRequired: false*`, `isDisabled: false*`, `isInvalid: false*` (each also inherited from `HeroFieldScope`). | theme typography/colours, `HeroFieldScope`, `HeroInput` (demos). |
| NumberField | `HeroNumberField` | `variant: primary* \| secondary`; `fullWidth: false*` (root + group `w-full`). | `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSpinner`, `HeroSurface`, icons (plus, minus, chevrons), `intl` number formatting (+ custom accounting/unit handling), shared `HeroNumberFormatOptions`. |
| RadioGroup | `HeroRadioGroup` | `variant: primary* \| secondary` (group only; Radio has no variant); `orientation: vertical* \| horizontal` (Flutter `Axis`). | `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSurface`, theme override scope (demo 9), brand SVG assets. |
| SearchField | `HeroSearchField` | `variant: primary* \| secondary`; `fullWidth: false*` (root and group `w-full`). | `HeroCloseButton`, `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSpinner`, `HeroKbd`, `HeroSurface`, icons (search, close). |
| TextArea | `HeroTextArea` | `variant: primary* \| secondary`; `fullWidth: false*`. | same as Input. |
| TextField | `HeroTextField` | `variant: primary* \| secondary` (passed to child Input/TextArea/InputGroup via scope; not in docs API table but in source & on-surface demo); `fullWidth: false*` (also forces child input/textarea full width). | `HeroLabel`, `HeroInput`, `HeroTextArea`, `HeroDescription`, `HeroFieldError`, `HeroInputGroup`, `HeroForm`, `HeroSurface` (demo). |

### Layout

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Card | `HeroCard` | `variant: transparent \| default* \| secondary \| tertiary` (→ `HeroCardVariant.transparent/standard/secondary/tertiary`). | `HeroSurface` scope, theme shadows, `HeroLink`, `HeroCloseButton`, `HeroButton`, `HeroAvatar`, `HeroForm`/`HeroTextField`/`HeroInput`/`HeroLabel` (demos), network images. |
| Separator | `HeroSeparator` | `orientation: horizontal* \| vertical` (null → inherit from toolbar scope, else horizontal); `variant: default* \| secondary \| tertiary` (→ `HeroSeparatorVariant.standard/secondary/tertiary`). | theme separator tokens, `HeroToolbar` scope, `HeroSurface` (demo). |
| Surface | `HeroSurface` | `variant: transparent \| default* \| secondary \| tertiary` (→ `HeroSurfaceVariant.transparent/standard/secondary/tertiary`). | theme surface tokens; `HeroInput`, `HeroTextArea` (demo). |
| Toolbar | `HeroToolbar` | `orientation: horizontal* \| vertical`; `isAttached: false*`. | `HeroToggleButtonGroup`, `HeroButtonGroup`, `HeroSeparator` (orientation scopes), shared roving-focus helper, theme overlay shadow. |

### Media

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Avatar | `HeroAvatar` | `size: sm \| md* \| lg`; `color: default* \| accent \| success \| warning \| danger` (→ `HeroColor`, affects fallback); `variant: default* \| soft` (→ `HeroAvatarVariant.standard \| soft`). Size/color/variant inherit from a parent `HeroAvatarGroup` when null (… | theme soft tokens, `HeroAvatarGroup` scope, `HeroSeparator` (demo), icons (Person). |
| AvatarGroup | `HeroAvatarGroup` | `isGrid: false*`; `overlap: clip* \| ring` (→ `HeroAvatarGroupOverlap`); `size: sm \| md* \| lg`; `color` (none default); `variant` (none default); `max: int?`. | `HeroAvatar`, custom clipper, theme `--background`. |

### Navigation

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Accordion | `HeroAccordion` | `variant` `HeroAccordionVariant {standard*, surface}`; `hideSeparator` false*; `allowsMultipleExpanded` false*; `isDisabled` (group and item). | Disclosure primitives (shared expand animation), HeroButton (demo), icon set. |
| Breadcrumbs | `HeroBreadcrumbs` | `isDisabled` false*; custom `separator` widget. | HeroLink, icon set. |
| Disclosure | `HeroDisclosure` | none; booleans `isExpanded`/`defaultExpanded`, `isDisabled`. | HeroButton (slot trigger), HeroSeparator (group demo), icon set; shared expand/collapse animation (also Accordion). |
| DisclosureGroup | `HeroDisclosureGroup` | `allowsMultipleExpanded` false*; `isDisabled` false*. | HeroDisclosure, HeroButton, HeroSeparator. |
| Link | `HeroLink` | no variant enum; decoration controls needed for the docs demo: `underline` `HeroLinkUnderline {hover*, always, none}`, `underlineOffset` (4*), `decorationColor`; `isDisabled`. | icon set (external-link), focus ring foundation. |
| Pagination | `HeroPagination` | `size` `HeroSize {sm, md*, lg}`; link `isActive` false*; `isDisabled` false*. | icon set (chevrons), focus ring. |
| Tabs | `HeroTabs` | `variant` `HeroTabsVariant {primary*, secondary}`; `orientation` `Axis {horizontal*, vertical}`; `align` `HeroTabsAlign {start, center*, end}`; tab `isDisabled`. | HeroScrollShadow (fading edges, 64px), collection/keyboard model, icon set (chevrons). |

### Overlays

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| AlertDialog | `HeroAlertDialog` | backdrop `HeroBackdropVariant {opaque*, blur, transparent}`; placement `{auto*, center, top, bottom}`; size `HeroAlertDialogSize {xs, sm, md*, lg, cover}` (no `full`, no `scroll` prop); icon `status` `HeroColor {standard, accent, success, warning, danger*}`; `… | Modal internals, HeroCloseButton, HeroButton, icon set (Info/Success/Warning/Danger). |
| Drawer | `HeroDrawer` | backdrop `HeroBackdropVariant {opaque*, blur, transparent}`; placement `HeroDrawerPlacement {top, bottom*, left, right}` (CSS uses flex start/end → mirrored in RTL; use `AlignmentDirectional` start/end); `isDismissable` true*; `isKeyboardDismissDisabled` false… | overlay route, HeroCloseButton, HeroButton, HeroTextField/HeroInput/HeroLabel (demos). |
| Modal | `HeroModal` | backdrop `variant` `HeroBackdropVariant {opaque*, blur, transparent}`; `placement` `HeroModalPlacement {auto*, center, top, bottom}`; `scroll` `HeroModalScroll {inside*, outside}`; `size` `HeroModalSize {xs, sm, md*, lg, cover, full}`; `isDismissable` true*; `… | overlay route + HeroOverlayController, HeroCloseButton, HeroButton (slot close), HeroRadioGroup, HeroTextField/HeroInput/ HeroLabel, HeroSurface (demos). |
| Popover | `HeroPopover` | placement (bottom*); `offset` 8*; `shouldFlip` true*; RAC extras `crossOffset` 0*, `containerPadding` 12*, `isNonModal` false*. | HeroPositioner, HeroOverlayArrow, HeroButton, HeroAvatar. |
| Toast | `HeroToast` | toast `variant` `HeroToastVariant {standard*, accent, success, warning, danger}` (`toast.info` → accent); provider `placement` `HeroToastPlacement {topStart, top, topEnd, bottomStart, bottom*, bottomEnd}`; `isExpanded` false*; `maxVisibleToasts` 3*; `gap` 12*;… | root overlay host (topmost), HeroButton, HeroCloseButton, HeroSpinner, icon set. |
| Tooltip | `HeroTooltip` | placement `HeroPlacement` (top*); `showArrow` (false*); `trigger` `HeroTooltipTriggerMode {hover*, focus}`; `isDisabled` (false*); `shouldSkipAnimation` (false*). No size/color variants. | HeroPositioner/overlay layer, HeroOverlayArrow, HeroButton, HeroAvatar, HeroChip (demos). |

### Pickers

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Autocomplete | `HeroAutocomplete` | `variant` `HeroFieldVariant {primary*, secondary}`; `fullWidth` false*; `selectionMode` `{single*, multiple}`; `allowsEmptyCollection` false*; popover placement bottom*; `HeroFilterSensitivity {base*, accent, case, variant}`. | Select trigger styling (share code), HeroSearchField (secondary), HeroListBox (virtualized), HeroTagGroup/HeroTag (sm), HeroEmptyState, HeroSpinner, HeroAvatar, HeroPositioner, HeroLabel/HeroDescription/HeroFieldError, HeroSurface. |
| ComboBox | `HeroComboBox` | `variant` `HeroFieldVariant {primary*, secondary}` (exists in source, missing from API table; forwarded to the Input); `fullWidth` false*; `selectionMode` `{single*, multiple}`; `menuTrigger` `HeroComboBoxMenuTrigger {focus*, input, manual}` (HeroUI default fo… | HeroInput (field styles), HeroListBox (+ load-more), HeroPositioner, HeroLabel, HeroDescription, HeroFieldError, HeroForm, HeroEmptyState, HeroAvatar, HeroSurface. |
| Select | `HeroSelect` | `variant` `HeroFieldVariant {primary*, secondary}`; `fullWidth` false*; `selectionMode` `{single*, multiple}`; popover `placement` bottom*; booleans `isDisabled`, `isRequired`, `isInvalid`. | HeroPositioner/pop animation, HeroListBox (+ load-more), HeroLabel, HeroDescription, HeroFieldError, HeroForm, HeroHeader, HeroSeparator, HeroSpinner, HeroSurface, HeroAvatar, HeroButton. |

### Typography

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| Kbd | `HeroKbd` | `variant: default* \| light` (→ `HeroKbdVariant.standard \| light`). | theme tokens only; `HeroTypography` for demo text. |
| Typography | `HeroTypography` | - `type: h1 \| h2 \| h3 \| h4 \| h5 \| h6 \| body* \| body-sm \| body-xs \| code` (→ `HeroTypographyType.h1…bodySm, bodyXs, code`) - `align: start* \| center \| end \| justify` (→ `TextAlign.start/center/end/justify`) - `color: default* \| muted` (→ `HeroTypog… | theme text styles (`HeroTextTheme` with these exact sizes), mono font family, `HeroSeparator` (prose hr), link color. |

### Utilities

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| ScrollShadow | `HeroScrollShadow` | `orientation: vertical* \| horizontal` (→ `Axis`); `variant: fade*` (only value); `hideScrollBar: false*`; `visibility: auto* \| both \| top \| bottom \| left \| right \| none` (controlled mode); `isEnabled: true*`. | `HeroCard`, `HeroButton` (demos); theme scrollbar colors. |

### Other (no docs page)

| Component | Flutter | Variants | Depends on |
| --- | --- | --- | --- |
| EmptyState | `HeroEmptyState` | none. | theme only; consumed by `HeroListBox.emptyStateBuilder`, `HeroTable.emptyStateBuilder`, etc. |
| Header | `HeroHeader` | none. | theme only; consumed by `HeroListBoxSection`, `HeroMenuSection`, `HeroDropdownSection`. |

# Part II — Component specifications

Each specification lists anatomy, variants, exact styles from the HeroUI CSS, the props → Flutter mapping, behaviour, the docs examples reproduced in the gallery, and dependencies. Token names are HeroUI CSS variables, which map 1:1 to `HeroThemeData.colors` fields in camelCase.

## Buttons, typography, feedback, layout, media and data display

Conventions: see section 5. Token names below are HeroUI CSS variables (e.g. `--accent`, `--default-hover`)
which map 1:1 to `HeroThemeData` color tokens. Spacing uses the Tailwind scale (1 unit = 4px). Radius tokens:
`--radius` = 8px; `rounded-sm` 4 · `md` 6 · `lg` 8 · `xl` 12 · `2xl` 16 · `3xl` 24 · `4xl` 32 · `full` = stadium.
Responsive prefixes: `sm:` ≥ 640px, `md:` ≥ 768px (read from `MediaQuery` width; "desktop" = md+).

Shared status utilities used by many components below:
- `status-focused` = focus ring: 2px `--focus` ring with 2px offset (`--ring-offset-width`) against `--background`.
- `status-disabled` = `opacity: --disabled-opacity` (0.5), cursor `not-allowed`, no pointer events.
- `status-pending` = no pointer events (but not dimmed).
- Easing: `--ease-smooth` = CSS `ease` (`Cubic(0.25,0.1,0.25,1)`); `--ease-out` (Tailwind) = `Cubic(0,0,0.2,1)`;
  `--ease-out-quart` = `Cubic(0.165,0.84,0.44,1)`; `--ease-out-fluid` = `Cubic(0.32,0.72,0,1)`; `--ease-linear` = linear.
- All transitions are disabled under reduced motion (`MediaQuery.disableAnimations`).
- Animations: `--animate-spin-fast` = 750ms linear infinite rotation; `--animate-skeleton` = 2s linear infinite translateX → 200%.

---

### Buttons

#### Button → `HeroButton`
- **Docs:** https://heroui.com/en/docs/react/components/button · **Category:** Buttons
- **Anatomy:** single widget (RAC `Button`). Children = any mix of icon + text; render-prop children → `builder: (context, HeroButtonState state)`.
- **Variants:**
  - `variant: primary* | secondary | tertiary | outline | ghost | danger | danger-soft` (`danger-soft` → `dangerSoft`; exists in styles + `button-variants` demo but not in the docs API table)
  - `size: sm | md* | lg`
  - `fullWidth: false*`, `isIconOnly: false*`
- **Key styles:**
  - Base: inline-flex, centered, `gap-2` (8), `rounded-3xl` (24 → effectively stadium), `px-4` (16), `text-sm` (14) `font-medium` (500), nowrap, no text selection. Height `h-10` (40) mobile / `md:h-9` (36) desktop.
  - Sizes: `sm` → h 36 / md: 32, `px-3` (12), icon 16. `md` → h 40 / md: 36, px 16, icon 20 (mobile) / `sm:` 16. `lg` → h 44 / md: 40, `text-base` (16), px 16.
  - Icons (any svg except spinner): size 20 (`size-5`), `sm:size-4` (16) on ≥640px; `-mx-0.5` (−2px horizontal margin), `my-0.5`/`sm:my-1`; `sm` size → always 16.
  - Icon-only: `p-0`, square: sm 36/md:32, md 40/md:36, lg 44/md:40.
  - Colors (`bg` / `bg-hover` = `bg-pressed` / `fg`):
    - primary: `--accent` / `--accent-hover` / `--accent-foreground`
    - secondary: `--default` / `--default-hover` / `--accent-soft-foreground`
    - tertiary: `--default` / `--default-hover` / currentColor (inherits → `--foreground`)
    - outline: transparent / `color-mix(--default 60%, transparent)` (pressed = `--default`) / `--default-foreground`; plus 1px border `--border`
    - ghost: transparent / `--default` / `--default-foreground`
    - danger: `--danger` / `--danger-hover` / `--danger-foreground`
    - danger-soft: `--danger-soft` / `--danger-soft-hover` / `--danger-soft-foreground`
  - Pressed: `scale(0.97)` (sm 0.98, lg 0.96), origin center.
  - Transitions: transform 250ms `ease`; background-color 100ms `ease-out`; box-shadow 100ms `ease-out`.
  - Hover background only applied on hover-capable pointers (mouse), not touch.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `variant` | `'primary'\|'secondary'\|'tertiary'\|'outline'\|'ghost'\|'danger'\|'danger-soft'` | `HeroButtonVariant? variant` (default primary; null → inherit from `HeroButtonGroup`) |
  | `size` | `'sm'\|'md'\|'lg'` | `HeroSize? size` (default md; null → inherit from group) |
  | `fullWidth` | `boolean` | `bool? fullWidth` |
  | `isDisabled` | `boolean` | `bool? isDisabled` (null → inherit group) |
  | `isPending` | `boolean` | `bool isPending = false` |
  | `isIconOnly` | `boolean` | `bool isIconOnly = false` |
  | `onPress` | `(e) => void` | `VoidCallback? onPressed` |
  | `children` | `ReactNode \| (renderProps) => ReactNode` | `Widget? child` / `HeroButtonWidgetBuilder? builder` (gets `HeroButtonState{isPending,isPressed,isHovered,isFocused,isFocusVisible,isDisabled}`) |
  | `render` | DOM render function | n/a (use `builder`) |
  | (convenience) | — | `Widget? startContent`, `Widget? endContent`, `FocusNode? focusNode`, `bool autofocus`, `String? semanticLabel` (for `aria-label` on icon-only) |

- **States & behaviour:** hover (mouse only), pressed (scale + pressed bg), focus-visible (keyboard focus → focus ring), disabled (opacity 0.5, not focusable/pressable), pending (no pointer events, NOT dimmed, stays focusable; `aria-disabled` semantics). Activates on Enter/Space (Space on key-up). Semantics: `button: true`, `enabled: !isDisabled`, label from child text or `semanticLabel`.
- **Docs examples:**
  1. `button-basic` — single primary "Click me" logging on press.
  2. `button-variants` — Primary, Secondary, Tertiary, Outline, Ghost, Danger, Danger Soft in a wrap row.
  3. `button-sizes` — Small / Medium / Large.
  4. `button-with-icons` — leading icon + label: Globe "Search" (primary), Plus "Add Member" (secondary), Envelope "Email" (tertiary), TrashBin "Delete" (danger).
  5. `button-icon-only` — Ellipsis (tertiary), Gear (secondary), TrashBin (danger), all `isIconOnly` with aria-labels.
  6. `button-loading` — `isPending` with builder showing `Spinner(color: current, size: sm)` + "Uploading...".
  7. `button-loading-state` — press → pending for 2s; shows Spinner + "Uploading..." else Paperclip icon + "Upload File".
  8. `button-full-width` — 400px container, two fullWidth buttons ("Primary Button", Plus "With Icon").
  9. `button-disabled` — the 6 variants (no danger-soft) disabled.
  10. `button-social` — max-w-xs column of full-width tertiary buttons: Google / GitHub / Apple sign-in with brand icons.
  11. `button-render-function` — custom render element keyed on `isPressed` → Flutter: `builder` using `state.isPressed` ("Press me").
  12. `button-custom-variants` — wrapper adding `radius` (full*/lg/md/sm) and size xl (h 52 px 40; lg h48 px32; md h44 px24; sm h40 px16), semibold text, shadow-md → gallery shows a `CustomButton` built via style overrides.
  13. `button-ripple-effect` — secondary button with nested ripple child → Flutter: `InkRipple`-style splash overlay inside HeroButton.
  14. `button-custom-styles` (Customization) — "Upgrade" ghost pill, px 40 py 12, vertical gradient neutral-100→white, 1.5px gradient border (315deg #e5e5e5→#fafafa→#c4c4c4), layered soft shadows, press scale 0.95 with 300ms `Cubic(0.34,1.56,0.64,1)`.
- **Depends on:** `HeroInteractable` (hover/press/focus-visible state machine), `HeroFocusRing`, theme tokens, `HeroButtonGroup` inherited scope, `HeroSpinner` (demos), `IconTheme` sizing.

#### ButtonGroup → `HeroButtonGroup`
- **Docs:** https://heroui.com/en/docs/react/components/button-group · **Category:** Buttons
- **Anatomy:** `ButtonGroup` → `HeroButtonGroup` (RAC `Group`); `ButtonGroup.Separator` → `HeroButtonGroupSeparator` (placed *inside* each non-first Button). Group provides `size`, `variant`, `isDisabled`, `fullWidth` to **direct child** buttons via InheritedWidget (explicit Button props win; `isDisabled: false` on a child re-enables it).
- **Variants:** `orientation: horizontal* | vertical`; `fullWidth: false*`; `variant` (any Button variant, no default → Button default); `size: sm | md | lg` (no default).
- **Key styles:**
  - Container: inline-flex, centered, `gap-0`, height auto; `flex-row` / `flex-col`; fullWidth → `w-full` (children Expanded since buttons get fullWidth).
  - Child buttons: radius 0 except outer edges: horizontal first → start radius 24 (`rounded-s-3xl`), last → end radius 24; vertical first → top 24, last → bottom 24; single child → all 24. RTL aware.
  - Pressed scale disabled inside group (`transform: none`). Focus-visible child raised (z-10) so ring overlaps neighbours.
  - Outline variant: inner borders removed — horizontal: first `border-e-0`, last `border-s-0`, middle `border-x-0`; vertical: first `border-b-0`, last `border-t-0`, middle `border-y-0`.
  - Separator: absolutely positioned inside the button, `bg-current` (button fg color), opacity 0.15, radius 4, no pointer events, `transition: opacity 150ms ease`. Horizontal: start −1px, top 25%, width 1px, height 50%. Vertical: start 25%, top −1px, width 50%, height 1px. `aria-hidden`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `variant` | Button variant | `HeroButtonVariant? variant` |
  | `size` | `'sm'\|'md'\|'lg'` | `HeroSize? size` |
  | `orientation` | `'horizontal'\|'vertical'` | `Axis orientation = Axis.horizontal` |
  | `fullWidth` | `boolean` | `bool fullWidth = false` |
  | `isDisabled` | `boolean` | `bool isDisabled = false` |
  | `children` | ReactNode | `List<Widget> children` |
  | `ButtonGroup.Separator className` | string | `HeroButtonGroupSeparator()` (no params) |

- **States & behaviour:** No own interaction; group semantics (`role=group`) → `Semantics(container: true, explicitChildNodes: true)`. Disabled propagates. Group position (first/middle/last/single + orientation) exposed to children through an InheritedWidget so `HeroButton` can pick its border radius/borders and the separator its geometry. Also used by `HeroToggleButtonGroup` (reads orientation from it).
- **Docs examples:**
  1. `button-group-basic` — split buttons: "Merge pull request" + chevron dropdown (Dropdown with 3 two-line items); tertiary groups: Fork + Chip "24" + chevron; QR icon + "Scan to pay"; ThumbsUp "2.4K" + ThumbsDown; Star + Chip "104"; Pin "Pinned" + chevron; Previous/Next with chevrons; Photos/Videos/ellipsis; Left/Center/Right text; 4 icon-only alignment buttons.
  2. `button-group-variants` — Primary/Secondary/Tertiary/Outline/Ghost/Danger groups of First/Second/Third with separators, each captioned.
  3. `button-group-sizes` — sm/md/lg secondary groups.
  4. `button-group-orientation` — horizontal vs vertical tertiary groups of 4 alignment icon buttons.
  5. `button-group-with-icons` — secondary Search/Add/Delete with icons; tertiary icon-only Globe/Plus/Trash.
  6. `button-group-full-width` — 400px wide: First/Second/Third and 3 icon-only alignment buttons stretched.
  7. `button-group-disabled` — whole group disabled; group disabled with third button `isDisabled: false`.
  8. `button-group-without-separator` — First/Second/Third with no separators.
  9. `button-group-custom-styles` (Customization) — square-cornered green (#08872B, hover #0FBF3E) merge split-button with dropdown.
- **Depends on:** `HeroButton`, `HeroDropdown` + `HeroLabel`/`HeroDescription` (basic demo), `HeroChip` (demo).

#### CloseButton → `HeroCloseButton`
- **Docs:** https://heroui.com/en/docs/react/components/close-button · **Category:** Buttons
- **Anatomy:** single widget; child defaults to the built-in `CloseIcon` (16×16 viewBox "X", path `M3.47 3.47a.75.75 0 0 1 1.06 0L8 6.94l3.47-3.47…`) → ship as `HeroIcons.close`.
- **Variants:** `variant: default*` (only value → `HeroCloseButtonVariant.standard`; can be omitted from the Flutter API or kept for parity).
- **Key styles:**
  - 24×24 (`h-6 w-6`), `p-1` (4), `rounded-xl` (12 → circle at this size), centered, shrink-0.
  - Icon: 16×16, `-mx-0.5 my-0.5`.
  - `default` variant: bg `--default`, fg `--muted`; hover (mouse) bg `--default-hover`; pressed `scale(0.93)`.
  - Transitions: transform 250ms `ease-out-quart`; color 150ms `ease-out`; background-color 100ms `ease-out`; box-shadow 150ms `ease-out`.
  - Focus-visible ring (status-focused), disabled (status-disabled), pending (no pointer events).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `variant` | `'default'` | `HeroCloseButtonVariant variant = standard` |
  | `children` | `ReactNode \| (renderProps) => ReactNode` | `Widget? child` (default close icon) / `builder` with `HeroButtonState` |
  | `onPress` | `() => void` | `VoidCallback? onPressed` |
  | `isDisabled` | `boolean` | `bool isDisabled = false` |
  | `aria-label` | string (default `"Close"`) | `String semanticLabel = 'Close'` |
  | `aria-labelledby` / `aria-describedby` | string | n/a (use `semanticLabel`/`Semantics`) |

- **States & behaviour:** hover/pressed/focus-visible/disabled as Button. Enter/Space activate. Semantics: `button: true`, label "Close" by default. Used as the dismiss control inside Alert, Chip, Modal, Drawer, Toast, Popover.
- **Docs examples:**
  1. `close-button-default` — bare `CloseButton`.
  2. `close-button-interactive` — counts presses; label below "Clicked: N times" (aria-label includes count).
  3. `close-button-with-custom-icon` — two buttons with CircleXmark and Xmark icons, captions "Custom Icon" / "Alternative Icon".
  4. `close-button-custom-styles` (Customization) — 32×32 fully round, hover text `--foreground`, press scale 0.95.
- **Depends on:** `HeroInteractable`, `HeroFocusRing`, `HeroIcons.close`.

#### ToggleButton → `HeroToggleButton`
- **Docs:** https://heroui.com/en/docs/react/components/toggle-button · **Category:** Buttons
- **Anatomy:** single widget (RAC `ToggleButton`). Children or builder with `HeroToggleButtonState` (adds `isSelected`).
- **Variants:** `variant: default* | ghost` (→ `HeroToggleButtonVariant.standard | ghost`); `size: sm | md* | lg` (null → inherit from `HeroToggleButtonGroup`); `isIconOnly: false*`.
- **Key styles:** geometry identical to Button (h 40/md:36, px 16, gap 8, radius 24, text 14 medium; sm h36/md:32 px12 icon16 press 0.98; lg h44/md:40 text16 press 0.96; md press 0.97; icon 20 / sm: 16; icon-only square 40/36, sm 36/32, lg 44/40).
  - Unselected: `default` → bg `--default`, hover/pressed `--default-hover`, fg currentColor (`--foreground`). `ghost` → bg transparent, hover/pressed `--default`, fg `--default-foreground`.
  - Selected (both variants): bg `--accent-soft`, hover/pressed `--accent-soft-hover`, fg `--accent-soft-foreground`.
  - Transitions: transform 250ms `ease`; background-color 100ms `ease-out`; box-shadow 100ms `ease-out`. (fg color switches instantly.)
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `variant` | `'default'\|'ghost'` | `HeroToggleButtonVariant variant = standard` |
  | `size` | `'sm'\|'md'\|'lg'` | `HeroSize? size` |
  | `isIconOnly` | `boolean` | `bool isIconOnly = false` |
  | `isSelected` | `boolean` | `bool? isSelected` (controlled) |
  | `defaultSelected` | `boolean` | `bool defaultSelected = false` |
  | `isDisabled` | `boolean` | `bool? isDisabled` (null → group) |
  | `onChange` | `(isSelected) => void` | `ValueChanged<bool>? onChanged` |
  | `onPress` | `(e) => void` | `VoidCallback? onPressed` |
  | `children` | node \| render fn | `Widget? child` / `builder(context, HeroToggleButtonState)` |
  | `id` (RAC, needed inside group) | `Key` | `Object? id` |
  | — | — | `String? semanticLabel`, `FocusNode? focusNode` |

- **States & behaviour:** toggles on press (Enter/Space). Inside a group, selection is owned by the group (id-keyed). Hover/pressed/focus-visible/disabled like Button. Semantics: `button: true, toggled: isSelected` (aria-pressed). In single-selection groups RAC renders `role=radio` → Flutter `inMutuallyExclusiveGroup: true, checked: isSelected`.
- **Docs examples:**
  1. `toggle-button-basic` — Heart icon + "Like".
  2. `toggle-button-variants` — Default and Ghost with heart.
  3. `toggle-button-icon-only` — Heart (default) and Bookmark (ghost) icon-only.
  4. `toggle-button-sizes` — sm/md/lg with label; row of sm/md/lg icon-only.
  5. `toggle-button-disabled` — disabled unselected (Heart) and disabled `defaultSelected` (HeartFill).
  6. `toggle-button-controlled` — builder swaps Heart/HeartFill and "Like"/"Liked"; status text "Selected"/"Not selected".
  7. `toggle-button-custom-styles` (Customization) — pill with border `--border` 80%, `--surface` bg, shadow-sm; selected → border accent 30%, bg `--accent-soft`, icon `--accent` ("Save article").
- **Depends on:** `HeroInteractable`, `HeroFocusRing`, `HeroToggleButtonGroup` scope.

#### ToggleButtonGroup → `HeroToggleButtonGroup`
- **Docs:** https://heroui.com/en/docs/react/components/toggle-button-group · **Category:** Buttons
- **Anatomy:** `ToggleButtonGroup` → `HeroToggleButtonGroup`; children `HeroToggleButton(id: ...)`; `ToggleButtonGroup.Separator` → `HeroToggleButtonGroupSeparator` (inside each non-first button).
- **Variants:** `orientation: horizontal* | vertical`; `isDetached: false*`; `fullWidth: false*`; `size: sm | md* | lg` (propagated); `selectionMode: single* | multiple`.
- **Key styles:**
  - Container inline-flex, gap 0, `w-fit`; row/column. fullWidth → full width and each button `flex-1` (Expanded).
  - Attached (default): buttons radius 0 except outer edges 24 (start/end for horizontal, top/bottom for vertical, all for single). Pressed scale disabled. Focus ring becomes **inset** (offset 0, ring drawn inside bounds).
  - Detached: `gap-1` (4), every button full radius 24, separators hidden.
  - Separator: identical to ButtonGroup separator (currentColor, opacity 0.15, radius 4, 1px × 50% at start −1px / top 25% horizontal; 50% × 1px at start 25% / top −1px vertical; opacity transition 150ms ease).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `selectionMode` | `'single'\|'multiple'` | `HeroSelectionMode selectionMode = single` (only single/multiple allowed) |
  | `selectedKeys` | `Iterable<Key>` | `Set<Object>? selectedKeys` |
  | `defaultSelectedKeys` | `Iterable<Key>` | `Set<Object>? defaultSelectedKeys` |
  | `onSelectionChange` | `(keys: Set<Key>) => void` | `ValueChanged<Set<Object>>? onSelectionChanged` |
  | `disallowEmptySelection` | `boolean` | `bool disallowEmptySelection = false` |
  | `orientation` | `'horizontal'\|'vertical'` | `Axis orientation = Axis.horizontal` |
  | `size` | `'sm'\|'md'\|'lg'` | `HeroSize size = HeroSize.md` |
  | `isDetached` | `boolean` | `bool isDetached = false` |
  | `fullWidth` | `boolean` | `bool fullWidth = false` |
  | `isDisabled` | `boolean` | `bool isDisabled = false` |
  | `children` | ToggleButtons | `List<Widget> children` |
  | — | — | `String? semanticLabel` (aria-label) |

- **States & behaviour:** single mode = radio group (pressing selected item deselects unless `disallowEmptySelection`); multiple = independent toggles. Keyboard: roving focus — Arrow Left/Right (horizontal) or Up/Down (vertical) move focus between buttons (RTL flips), Tab leaves the group; Enter/Space toggle. Disabled group disables all; child `isDisabled: false` overrides. Semantics: `role=toolbar/radiogroup` → `Semantics(container: true, label: semanticLabel)` with children `toggled`/`checked`.
- **Docs examples:**
  1. `toggle-button-group-basic` — multiple: Bold/Italic/Underline/Strikethrough icon-only with separators.
  2. `toggle-button-group-sizes` — sm / md / lg rows of the 4 formatting buttons.
  3. `toggle-button-group-orientation` — horizontal vs vertical (Bold/Italic/Underline).
  4. `toggle-button-group-full-width` — max-w-md: 4 icon-only stretched (multiple); Left/Center/Right with icons (single).
  5. `toggle-button-group-disabled` — whole group disabled; only Italic disabled.
  6. `toggle-button-group-without-separator` — 4 formatting buttons without separators.
  7. `toggle-button-group-attached` ("Detached") — attached (default) vs `isDetached`.
  8. `toggle-button-group-selection-mode` — single with default "center"; multiple with default {bold, underline}.
  9. `toggle-button-group-controlled` — controlled multiple starting {bold}; text "Selected: bold, …" or "None".
  10. `toggle-button-group-custom-styles` (Customization) — detached-look toolbar: gap 4, radius 12 container with border, `--surface` bg, p 4, shadow-sm; buttons radius 8, muted fg, selected accent-soft.
- **Depends on:** `HeroToggleButton`, shared `HeroGroupPosition` inherited scope (with ButtonGroup), roving-focus helper (shared with Toolbar), `HeroSelectionMode`.

---

### Typography

#### Typography → `HeroTypography`
- **Docs:** https://heroui.com/en/docs/react/components/typography · **Category:** Typography
- **Anatomy:** `Typography` → `HeroTypography(type: ...)`; primitives: `Typography.Heading(level 1–6)` → `HeroHeading` (maps to h1…h6), `Typography.Paragraph(size base|sm|xs)` → `HeroParagraph` (maps to body/body-sm/body-xs), `Typography.Code` → `HeroCode`, `Typography.Prose` → `HeroProse` (styles arbitrary rich children; in Flutter: a `DefaultTextStyle` + `HeroProseTheme` InheritedWidget consumed by prose element widgets `HeroProse.h1…h6/p/code/a/blockquote/ul/ol/li/hr/pre/strong/em/img` — or accept `List<InlineSpan>`/markdown-like element list).
- **Variants:**
  - `type: h1 | h2 | h3 | h4 | h5 | h6 | body* | body-sm | body-xs | code` (→ `HeroTypographyType.h1…bodySm, bodyXs, code`)
  - `align: start* | center | end | justify` (→ `TextAlign.start/center/end/justify`)
  - `color: default* | muted` (→ `HeroTypographyColor.standard | muted`)
  - `weight: normal | medium | semibold | bold` (no default → type's weight) (→ `FontWeight.w400/w500/w600/w700`)
  - `truncate: bool` (single line + ellipsis, block)
- **Key styles** (Tailwind v4 defaults; tracking-tight = −0.025em; all headings `font-semibold` 600):
  - h1 36px / line-height 40px · h2 30 / 36 · h3 24 / 32 · h4 20 / 28 · h5 18 / 28 · h6 16 / 24 (all letterSpacing −0.025em).
  - body 16 / 28 (`leading-7`) · body-sm 14 / 24 · body-xs 12 / 20 (weight 400).
  - code: 14 / 20 mono, fg `--foreground`, bg `--default`, radius 6 (`rounded-md`), padding h 6 / v 2 (`px-1.5 py-0.5`) — inline (use `WidgetSpan` or background `Paint` span).
  - color default `--foreground`, muted `--muted`.
  - NB: the `typography-scale` demo's captions state line heights 1.11/1.17/1.25/1.33/1.39/1.50 and body 1.75/1.50/1.25 — these are docs text; the CSS values above (40/36/32/28/28/24, 28/24/20) are authoritative except body-xs (CSS 20px = 1.67).
  - Prose: h1–h6 as above; `p`, `li` 16/28; `code` as inline code; `a` medium, `--link`, underline offset 4; `blockquote` mt 16, start border 4px `--border`, ps 16, `--muted`, italic; `ul` disc / `ol` decimal, my 16, item spacing 8, ps 24; `hr` my 32 `--separator`; `pre` my 16, horizontal scroll, radius 12, bg `--default`, p 16, mono 14, line-height 1.625; `strong` 600 `--foreground`; `em` italic; `img` my 16 radius 12.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `type` | h1…h6 \| body \| body-sm \| body-xs \| code | `HeroTypographyType type = body` |
  | `align` | start \| center \| end \| justify | `TextAlign align = TextAlign.start` |
  | `color` | default \| muted | `HeroTypographyColor color = standard` |
  | `weight` | normal \| medium \| semibold \| bold | `FontWeight? weight` |
  | `truncate` | boolean | `bool truncate = false` (maxLines 1, `TextOverflow.ellipsis`) |
  | `render` | DOM render fn | n/a (semantics via `isHeader`/`headingLevel` override: `int? semanticHeadingLevel`) |
  | `children` | ReactNode | `String? text` / `InlineSpan? span` / `Widget? child` (`HeroTypography('text')` positional) |
  | `Heading.level` | 1–6 | `HeroHeading(level: 1, ...)` |
  | `Paragraph.size` | base \| sm \| xs | `HeroParagraph(size: HeroParagraphSize.base)` |
  | `Prose.children` | HTML | `HeroProse(children: [...])` |

- **States & behaviour:** static text; `SelectableText` optional. Semantics: headings → `Semantics(header: true, headingLevel: n)`; code → plain text.
- **Docs examples:**
  1. `typography-default` — h1 "Build better interfaces", h2, h3, h4, body paragraph, muted body-sm, code "pnpm add @heroui/react".
  2. `typography-typography-scale` — divided rows (160px label column: name + meta, then sample) for h1…h6, body, body-sm, body-xs, code.
  3. `typography-primitives` — Heading level 1 "Dashboard", Paragraph, muted sm Paragraph, Code.
  4. `typography-prose` — Prose with h1, p, h2, p with inline `code`.
  5. `typography-render-props` — h1 style rendered as h2 element; body rendered as span → Flutter: style vs semantic level decoupled.
  6. `typography-custom-styles` (Customization) — changelog card: radius 12, border 80%, `--surface-secondary`, p 16, gap 8; uppercase accent 12px "Changelog", h4 title, muted 14px body with relaxed leading.
- **Depends on:** theme text styles (`HeroTextTheme` with these exact sizes), mono font family, `HeroSeparator` (prose hr), link color.

#### Kbd → `HeroKbd`
- **Docs:** https://heroui.com/en/docs/react/components/kbd · **Category:** Typography
- **Anatomy:** `Kbd` (`<kbd>`) → `HeroKbd`; `Kbd.Abbr` → `HeroKbdAbbr(keyValue: HeroKbdKey.command)` (renders the symbol, tooltip/semantics label = key name); `Kbd.Content` → `HeroKbdContent(child)`. (Docs table also lists `Kbd.Key` and an `Abbr.title` prop — source only has `Abbr(keyValue)` + `Content`; follow source.) Convenience: `HeroKbd(keys: [HeroKbdKey.command], text: 'K')`.
- **Variants:** `variant: default* | light` (→ `HeroKbdVariant.standard | light`).
- **Key styles:** inline-flex, height 24 (`h-6`), items center, children spaced 2px (`space-x-0.5`, reversed in RTL), radius 8 (`rounded-lg`), bg `--default`, px 8, `text-sm` 14 `font-medium`, sans font, nowrap, fg `--muted`, word-spacing −4px. `light` → transparent bg. Abbr/Content are centered flex boxes; Abbr has no underline decoration.
- **Key map (`HeroKbdKey` → symbol / label):** command ⌘ Command · shift ⇧ Shift · ctrl ⌃ Control · option ⌥ Option · alt ⌥ Alt · win ⌘ Win · enter ↵ Enter · delete ⌫ Delete · escape ⎋ Escape · tab ⇥ Tab · capslock ⇪ Caps Lock · space ␣ Space · help ? Help · up ↑ · down ↓ · left ← · right → · pageup ⇞ Page Up · pagedown ⇟ Page Down · home ↖ Home · end ↘ End · fn "Fn" Fn.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `Kbd.children` | ReactNode | `List<Widget> children` |
  | `Kbd.variant` | `'default'\|'light'` | `HeroKbdVariant variant = standard` |
  | `Kbd.Abbr.keyValue` (docs: `title`+children) | `KbdKey` | `HeroKbdKey keyValue` |
  | `Kbd.Content.children` | ReactNode | `Widget child` / `String text` |
  | exported `kbdKeysMap` / `kbdKeysLabelMap` | maps | `HeroKbdKey.symbol` / `.label` extension getters |

- **States & behaviour:** static. Semantics: Abbr → `Semantics(label: keyLabel)` + `Tooltip`-free (abbr title) with `excludeSemantics` on the glyph; whole Kbd readable as "Command K".
- **Docs examples:**
  1. `kbd-basic` — ⌘K, ⇧P, ⌃C, ⌥D.
  2. `kbd-variants` — Copy/Paste/Cut/Undo/Redo rows each showing default and light (Redo = ⌘⇧Z).
  3. `kbd-navigation-keys` — "Arrow Keys:" ↑↓←→; "Page Navigation:" ⇞⇟↖↘.
  4. `kbd-inline-usage` — Kbd inline inside 14px sentences (Esc, ⌘K, ↑/↓, ⌘S) → needs `WidgetSpan` alignment middle.
  5. `kbd-instructional-text` — `--surface` card radius 8 p 16, "Quick Actions" title, bullet list with ⌘K/⌘B/⌘N/⌘S.
  6. `kbd-special-keys` — sentences with ↵, ⎋, ⇥, ⇧⇥, ␣.
  7. `kbd-custom-styles` (Customization) — accent-soft ⌘K and default/muted ⇧P with px 10.
- **Depends on:** theme tokens only; `HeroTypography` for demo text.

---

### Feedback

#### Alert → `HeroAlert`
- **Docs:** https://heroui.com/en/docs/react/components/alert · **Category:** Feedback
- **Anatomy:** `Alert` → `HeroAlert` (row container; provides status + a Surface context of variant `default` to descendants); `Alert.Indicator` → `HeroAlertIndicator` (defaults to status icon); `Alert.Content` → `HeroAlertContent` (column, `grow`); `Alert.Title` → `HeroAlertTitle`; `Alert.Description` → `HeroAlertDescription`. Convenience slots on `HeroAlert`: `title`, `description`, `indicator` (null → default icon, `showIndicator`), `endContent` (actions / CloseButton).
- **Variants:** `status: default* | accent | success | warning | danger` → `HeroColor` (`standard` default).
- **Key styles:**
  - Root: row, `items-start`, `gap-4` (16), full width, bg `--surface`, `px-4 py-3` (16/12), shadow `--surface-shadow` (light theme only; none in dark), radius `min(32px, radius-3xl)` = 24.
  - Indicator: centered, `p-1` (4); default icon 16×16 (`box-content size-4` → 24 box). Color: default `--foreground`; accent `--accent-soft-foreground`; success `--success-soft-foreground`; warning `--warning-soft-foreground`; danger `--danger-soft-foreground`.
  - Content: column, `items-start`, grows.
  - Title: 14px / line-height 24px, weight 500, same color as indicator.
  - Description: 14px (line 20), `--muted`.
  - Default icons (16×16 viewBox): default & accent → `InfoIcon` (circle-i); success → `SuccessIcon` (circle-check); warning → `WarningIcon` (triangle-!); danger → `DangerIcon` (circle-!). Ship in `HeroIcons`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `status` | default \| accent \| success \| warning \| danger | `HeroColor status = HeroColor.standard` |
  | `children` | ReactNode | `List<Widget>? children` (compound) or slots below |
  | `Alert.Indicator.children` | ReactNode | `HeroAlertIndicator(child: ...)` / `Widget? indicator` |
  | `Alert.Content.children` | ReactNode | `HeroAlertContent(children: ...)` |
  | `Alert.Title.children` | ReactNode | `HeroAlertTitle(child)` / `Widget? title` |
  | `Alert.Description.children` | ReactNode | `HeroAlertDescription(child)` / `Widget? description` |
  | — | — | `Widget? endContent` (trailing actions) |

- **States & behaviour:** non-interactive; semantics: container with `liveRegion: false` (HeroUI sets no role; optionally allow `role=alert` → `liveRegion: true` param `isLive`). Children may include Buttons/CloseButton.
- **Docs examples:**
  1. `alert-basic` — max-w-xl stack of 6 alerts: default "New features available"; accent "Update available" with sm primary "Refresh" button (trailing on ≥sm, below content on mobile); danger "Unable to connect to server" with bullet list + sm danger "Retry" (same responsive placement); success "Profile updated successfully" title-only + trailing `CloseButton`; accent with custom indicator `Spinner(size: sm)` "Processing your request"; warning "Scheduled maintenance".
  2. `alert-custom-styles` (Customization) — warning alert, radius 12, border warning/20, gradient (to-br) warning/10 → surface → surface-secondary, blurred warning/15 blob (112px) at top-right, indicator `--warning`, sm tertiary "Update billing" (responsive placement) + CloseButton.
- **Depends on:** `HeroSurface` context (variant default), `HeroIcons` status icons, `HeroButton`, `HeroCloseButton`, `HeroSpinner` (demo), responsive breakpoint helper.

#### Meter → `HeroMeter`
- **Docs:** https://heroui.com/en/docs/react/components/meter · **Category:** Feedback
- **Anatomy:** `Meter` → `HeroMeter` (2×2 grid: areas `"label output" / "track track"`, columns `1fr auto`); `Label` (forms `HeroLabel`, placed in label area); `Meter.Output` → `HeroMeterOutput` (defaults to formatted `valueText`); `Meter.Track` → `HeroMeterTrack`; `Meter.Fill` → `HeroMeterFill`. Convenience: `HeroMeter(value: 60, label: Text('Storage'), showValueLabel: true)` builds the standard layout.
- **Variants:** `size: sm | md* | lg`; `color: default | accent* | success | warning | danger` (→ `HeroColor`, default `accent`).
- **Key styles:**
  - Root grid gap 4 (`gap-1`), full width.
  - Label: fit width, 14px medium. Output: 14px medium, tabular figures (`FontFeature.tabularFigures()`), end-aligned.
  - Track: bg `--default`, clip, height/radius: sm 4 / 2 (`rounded-xs`) · md 8 / 4 (`rounded-sm`) · lg 12 / 6 (`rounded-md`).
  - Fill: anchored at start (RTL aware), full height, same radius as track, width = percentage; color default `--default-foreground`, accent `--accent`, success `--success`, warning `--warning`, danger `--danger`. Width transition 300ms `ease-out`.
  - Disabled (`isDisabled` not in docs but CSS supports `data-disabled`): opacity 0.5 but label stays at full opacity.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `value` | number (0) | `double value = 0` |
  | `minValue` | number (0) | `double minValue = 0` |
  | `maxValue` | number (100) | `double maxValue = 100` |
  | `size` | sm \| md \| lg | `HeroSize size = md` |
  | `color` | default \| accent \| success \| warning \| danger | `HeroColor color = HeroColor.accent` |
  | `formatOptions` | `Intl.NumberFormatOptions` ({style:'percent'}) | `NumberFormat? numberFormat` (intl; default `NumberFormat.percentPattern()` applied to fraction) |
  | `valueLabel` | ReactNode | `String? valueLabel` (overrides valueText / semantics value) |
  | `children` | node \| (values)=>node | `List<Widget>? children` / `builder(context, HeroMeterState{percentage, valueText})` |
  | `aria-label` | string | `String? semanticLabel` |

- **States & behaviour:** static; value clamped to [min,max]; percentage = (v−min)/(max−min)·100. Semantics: `role=meter` → `Semantics(label, value: valueText)` (no increase/decrease actions).
- **Docs examples:**
  1. `meter-basic` — 256px wide, "Storage" label, output 60%.
  2. `meter-sizes` — sm success 40 "Small", md accent 60 "Medium", lg warning 80 "Large".
  3. `meter-colors` — default/accent/success/warning/danger at 50.
  4. `meter-without-label` — track+fill only, aria-label "Storage usage", 45.
  5. `meter-custom-value` — "Revenue", 0–1000, value 750, currency USD → "$750.00".
  6. `meter-custom-styles` (Customization) — "Storage used" 68, muted output, fully-rounded track, warning fill.
- **Depends on:** `HeroLabel` (forms), `intl` NumberFormat, theme tokens.

#### ProgressBar → `HeroProgressBar`
- **Docs:** https://heroui.com/en/docs/react/components/progress-bar · **Category:** Feedback
- **Anatomy:** identical to Meter: `ProgressBar` → `HeroProgressBar`; `Label`; `ProgressBar.Output` → `HeroProgressBarOutput`; `ProgressBar.Track` → `HeroProgressBarTrack`; `ProgressBar.Fill` → `HeroProgressBarFill`. Same convenience params as Meter.
- **Variants:** `size: sm | md* | lg`; `color: default | accent* | success | warning | danger`; `isIndeterminate: false*`.
- **Key styles:** same grid / label / output / track / fill geometry & colors as Meter (track sm 4 r2, md 8 r4, lg 12 r6; bg `--default`; fill width transition 300ms ease-out).
  - Indeterminate: fill width 40% of track (`w-2/5`), animated `translateX(-100%) → translateX(350%)` (percent of fill width), 1.5s, `Cubic(0.65, 0, 0.35, 1)`, infinite; no animation under reduced motion. Output shows nothing meaningful when indeterminate (demo omits Output).
  - Disabled: opacity 0.5 with label kept opaque.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `value` | number | `double value = 0` |
  | `minValue` | number | `double minValue = 0` |
  | `maxValue` | number | `double maxValue = 100` |
  | `isIndeterminate` | boolean | `bool isIndeterminate = false` |
  | `size` | sm \| md \| lg | `HeroSize size = md` |
  | `color` | 5 colors | `HeroColor color = accent` |
  | `formatOptions` | `Intl.NumberFormatOptions` | `NumberFormat? numberFormat` |
  | `valueLabel` | ReactNode | `String? valueLabel` |
  | `children` | node \| render fn | `children` / `builder(context, HeroProgressState{percentage, valueText, isIndeterminate})` |
  | `aria-label` | string | `String? semanticLabel` |

- **States & behaviour:** Semantics `role=progressbar` → `Semantics(label, value: valueText)`; indeterminate → no value, maybe `liveRegion`. 
- **Docs examples:**
  1. `progress-bar-basic` — "Loading" 60%, 256px.
  2. `progress-bar-sizes` — sm 40 / md 60 / lg 80 with labels.
  3. `progress-bar-colors` — 5 colors at 50.
  4. `progress-bar-without-label` — track only, 45.
  5. `progress-bar-indeterminate` — "Loading..." label, no output, sliding fill.
  6. `progress-bar-custom-value` — interactive playground: ProgressBar ("Progress") next to an "Options" panel (Separator horizontal on mobile / vertical on md+) with NumberFields Value (750) / Min Value (0) / Max Value (1000) and a Select "Format" (Currency USD / Percent* / Decimal / Unit "mile").
  7. `progress-bar-custom-styles` (Customization) — "Uploading resume.pdf" 45, 12px muted output, rounded-full track & accent fill.
- **Depends on:** `HeroLabel`, `intl`; demo needs `HeroNumberField`, `HeroSelect`, `HeroListBox`, `HeroSeparator`.

#### ProgressCircle → `HeroProgressCircle`
- **Docs:** https://heroui.com/en/docs/react/components/progress-circle · **Category:** Feedback
- **Anatomy:** `ProgressCircle` → `HeroProgressCircle` (RAC ProgressBar); `ProgressCircle.Track` → `HeroProgressCircleTrack` (the SVG canvas, viewBox 36×36); `ProgressCircle.TrackCircle` → `HeroProgressCircleTrackCircle`; `ProgressCircle.FillCircle` → `HeroProgressCircleFillCircle`. In Flutter implement as a single `CustomPainter`; the part widgets exist to accept overrides (`strokeWidth`, `radius`, `center`, `viewBox`, color, `strokeCap`). Default constructor renders all three parts.
- **Variants:** `size: sm | md* | lg`; `color: default | accent* | success | warning | danger`; `isIndeterminate: false*`.
- **Key styles:**
  - Root inline-flex centered. Rendered SVG size: sm 20 (`size-5`) · md 28 (`size-7`) · lg 36 (`size-9`).
  - Geometry in 36×36 viewBox: center 18, stroke width 4, radius 16, circumference 2π·16. Scales with widget size.
  - Track circle stroke `--default`; fill stroke: default `--default-foreground`, accent `--accent`, success `--success`, warning `--warning`, danger `--danger`. Fill: round caps, starts at 12 o'clock (rotate −90°), clockwise, dashoffset = C − pct·C; transition `stroke-dashoffset` 300ms ease-out.
  - Indeterminate: fill shows a 25% arc (dashoffset = 0.75·C) and the whole SVG rotates 360° in 1s linear infinite (none with reduced motion).
  - Disabled → opacity 0.5.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `value` | number | `double value = 0` |
  | `minValue` | number | `double minValue = 0` |
  | `maxValue` | number | `double maxValue = 100` |
  | `isIndeterminate` | boolean | `bool isIndeterminate = false` |
  | `size` | sm \| md \| lg | `HeroSize size = md` |
  | `color` | 5 colors | `HeroColor color = accent` |
  | `formatOptions` | Intl options | `NumberFormat? numberFormat` (semantics value only) |
  | `children` | node \| render fn | `children` / `builder(context, HeroProgressState)` |
  | TrackCircle/FillCircle SVG attrs `strokeWidth`, `r`, `cx`, `cy`; Track `viewBox` | numbers | `double? strokeWidth`, `double? radius`, `Offset? center`, `Size viewBox = Size(36,36)`, `Color? color`, `StrokeCap strokeCap` |
  | `aria-label` | string | `String? semanticLabel` |
  | — (className sizing, e.g. `size-14`) | — | `double? dimension` override |

- **States & behaviour:** Semantics progressbar (label + value text).
- **Docs examples:**
  1. `progress-circle-basic` — md accent 60%.
  2. `progress-circle-sizes` — sm 40, md 60, lg 80.
  3. `progress-circle-colors` — 5 colors at 60.
  4. `progress-circle-indeterminate` — spinning 25% arc.
  5. `progress-circle-with-label` — circle 75 + `Label` "75% Complete" in a row gap 12.
  6. `progress-circle-custom-svg` — thin (stroke 2, r 17), default (4, 16), thick (6, r 15), bottom-aligned row.
  7. `progress-circle-custom-styles` (Customization) — 56px, neutral-200 track / neutral-700 fill (dark: 800 / 300), round cap, value 68.
- **Depends on:** `CustomPainter`, `HeroLabel` (demo), theme tokens.

#### Skeleton → `HeroSkeleton`
- **Docs:** https://heroui.com/en/docs/react/components/skeleton · **Category:** Feedback
- **Anatomy:** single block widget (`div`); sized by the caller (`width`/`height`/`borderRadius` params, or a `child` to size to). Group shimmer: `HeroSkeletonGroup` (Flutter equivalent of applying `.skeleton--shimmer` to a parent + children `animationType: none`) that paints one synchronized sweep over all descendant skeletons.
- **Variants:** `animationType: shimmer* | pulse | none` (default resolved from theme `HeroThemeData.skeletonAnimation`, mirroring the `--skeleton-animation` CSS variable, default `shimmer`; prop overrides).
- **Key styles:**
  - Base: no pointer events, clip, radius 4 (`rounded-sm`), bg `--surface-tertiary` @ 70% opacity.
  - Shimmer: overlay pseudo-element full-size, starts at `translateX(-100%)`, animates to `translateX(200%)` over 2s linear infinite; horizontal gradient transparent → `--surface-tertiary` → transparent.
  - Group shimmer (parent contains skeletons): one overlay over the whole parent with gradient `transparent 0% → rgba(255,255,255,0.5) 50% → transparent 100%`, `mix-blend-mode: overlay` (Flutter: `ShaderMask`/`BlendMode.overlay`, clipped to skeleton shapes), z above children; children's own shimmer suppressed.
  - Pulse: Tailwind `animate-pulse` = opacity 1 → 0.5 (at 50%) → 1, 2s, `Cubic(0.4, 0, 0.6, 1)`, infinite.
  - None: static.
  - Reduced motion: the CSS has no `motion-reduce` guard for skeleton shimmer/pulse; Flutter should still stop the animation when `disableAnimations` is set (render as `none`).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `animationType` | shimmer \| pulse \| none | `HeroSkeletonAnimation? animationType` (null → theme default) |
  | `className` (size/radius) | string | `double? width`, `double? height`, `BorderRadiusGeometry? borderRadius`, `BoxShape shape` (circle for avatars), `Widget? child` |
  | `--skeleton-animation` (global CSS var) | shimmer \| pulse \| none | `HeroThemeData.skeletonAnimation` |

- **States & behaviour:** decorative; `ExcludeSemantics` (or `Semantics(label: 'Loading')` opt-in). Should respect `TickerMode`.
- **Docs examples:**
  1. `skeleton-basic` — 250px card (p 16, radius 8, panel shadow): 128px image block radius 8; lines 12px tall at 60%/80%/40% width, radius 8, spacing 12 (block→lines 20).
  2. `skeleton-text-content` — max-w-md, five 16px lines (100%, 83%, 67%, 100%, 50%) radius 4, spacing 12.
  3. `skeleton-user-profile` — 40px circle + two lines 144px & 96px (12px tall).
  4. `skeleton-list` — max-w-sm, 3 rows: 40×40 radius 8 square + 2 lines (100%, 80%), gap 12, row spacing 16.
  5. `skeleton-grid` — max-w-xl 3-column grid, gap 16, 96px tall radius 12 tiles.
  6. `skeleton-single-shimmer` — same grid wrapped in group shimmer (children `none`).
  7. `skeleton-animation-types` — 3 columns (1 / sm:2 / lg:3) "Shimmer", "Pulse", "None" cards each with 80px block + 2 lines.
  8. `skeleton-custom-styles` (Customization) — basic layout inside radius 12 `--surface` card with border + ring; bones neutral-200/90 (dark neutral-800/90) radius 8 with a custom "shine" animation.
- **Depends on:** theme (`skeletonAnimation`, `--surface-tertiary`), a shared shimmer `AnimationController` helper.

#### Spinner → `HeroSpinner`
- **Docs:** https://heroui.com/en/docs/react/components/spinner · **Category:** Feedback
- **Anatomy:** single widget; `span role=status aria-label="Loading"` wrapping a 24×24 viewBox SVG → Flutter `CustomPainter` in a `RotationTransition`.
- **Variants:** `size: sm | md* | lg | xl` (→ `HeroSpinnerSize`); `color: current | accent* | success | warning | danger` (→ `HeroSpinnerColor`, `current` = inherit `DefaultTextStyle`/`IconTheme` color).
- **Key styles:**
  - Size: sm 16 · md 24 · lg 32 · xl 40. Non-interactive, shrink-0.
  - Color: current → inherited; accent `--accent`; success `--success`; warning `--warning`; danger `--danger`.
  - Glyph (24 viewBox, both paths translated by (1.5, 1.625)): two arcs forming a ring 21 wide, ~3 thick with rounded ends:
    - Left arc path `M8.749.021a1.5 1.5 0 0 1 .497 2.958A7.5 7.5 0 0 0 3 10.375a7.5 7.5 0 0 0 7.5 7.5v3c-5.799 0-10.5-4.7-10.5-10.5C0 5.23 3.726.865 8.749.021`, filled with vertical linear gradient (y 5.271% → 91.793%) color@1.0 → color@0.55.
    - Right arc path `M15.392 2.673a1.5 1.5 0 0 1 2.119-.115A10.48 10.48 0 0 1 21 10.375c0 5.8-4.701 10.5-10.5 10.5v-3a7.5 7.5 0 0 0 5.007-13.084a1.5 1.5 0 0 1-.115-2.118`, gradient (y 15.24% → 87.15%) color@0 → color@0.55.
    - (A third tiny path in the SVG is an invisible artifact — skip.)
  - Animation: `animate-spin-fast` = full rotation 750ms linear infinite; none with reduced motion.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `size` | sm \| md \| lg \| xl | `HeroSpinnerSize size = md` |
  | `color` | current \| accent \| success \| warning \| danger | `HeroSpinnerColor color = accent` |
  | `className` (speed override, text color) | string | `Duration period = 750ms`, `Color? colorOverride` |
  | `aria-label` (default "Loading") | string | `String semanticLabel = 'Loading'` |

- **States & behaviour:** Semantics `role=status` → `Semantics(label: 'Loading', liveRegion: true)`; glyph excluded.
- **Docs examples:**
  1. `spinner-basic` — default md accent.
  2. `spinner-colors` — Current / Accent / Success / Warning / Danger with 12px muted captions.
  3. `spinner-sizes` — Small / Medium / Large / Extra Large.
  4. `spinner-speed` — Slow (1.5s), Default (0.75s), Fast (0.4s) → `period` param.
  5. `spinner-custom-styles` (Customization) — bordered `--surface` card radius 12 px 20 py 16: sm accent, md muted, lg success.
- **Depends on:** `CustomPainter`, reduced-motion helper; used by Button (pending), Alert, Toast, etc.

---

### Layout

#### Card → `HeroCard`
- **Docs:** https://heroui.com/en/docs/react/components/card · **Category:** Layout
- **Anatomy:** `Card` → `HeroCard` (column; provides `HeroSurfaceScope(variant)` to descendants unless `transparent`); `Card.Header` → `HeroCardHeader`; `Card.Title` → `HeroCardTitle` (h3 semantics); `Card.Description` → `HeroCardDescription`; `Card.Content` → `HeroCardContent`; `Card.Footer` → `HeroCardFooter`. Convenience: `HeroCard(title:, description:, content:, footer:)` builds header/content/footer. Optional `onPressed` to make an interactive card (docs "interactive cards" pattern) wrapping in `HeroInteractable` + link semantics.
- **Variants:** `variant: transparent | default* | secondary | tertiary` (→ `HeroCardVariant.transparent/standard/secondary/tertiary`).
- **Key styles:**
  - Root: column, `gap-3` (12), `p-4` (16), overflow visible (children may overflow; images get their own clip), radius `min(32px, radius-3xl)` = 24, shadow `--surface-shadow` (none in dark theme).
  - Background: default `--surface`, secondary `--surface-secondary`, tertiary `--surface-tertiary`, transparent → no bg, no border, no shadow. (Docs prose says default = surface-secondary; CSS + variants demo say `--surface` — follow CSS.)
  - Header: column (no gap). Title: 14px / line 24, weight 500, `--foreground`. Description: 14px / line 20, `--muted`.
  - Content: column, `flex-1`, gap 4. Footer: row, items center (no gap by default).
  - Root is `position: relative` → support `Stack` overlays (CloseButton at end 12 / top 12 in demos) via `HeroCard(overlay:)` or user `Stack`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `variant` | transparent \| default \| secondary \| tertiary | `HeroCardVariant variant = standard` |
  | `children` | ReactNode | `List<Widget> children` (column with gap 12) |
  | `Card.Header/Content/Footer.children` | ReactNode | `children` lists (Header: column; Content: column gap 4; Footer: row) |
  | `Card.Title.children` | ReactNode | `HeroCardTitle(child)` |
  | `Card.Description.children` | ReactNode | `HeroCardDescription(child)` |
  | `className` layout overrides (width, direction, padding, gap) | string | `double? width`, `Axis direction = vertical`, `EdgeInsetsGeometry? padding`, `double? gap`, `Clip clipBehavior = none` |
  | `role="article"`, `aria-labelledby` | — | `String? semanticLabel` |

- **States & behaviour:** static by default; Title → `Semantics(header: true)`.
- **Docs examples:**
  1. `card-default` — 400px: CircleDollar 24px icon, title "Become an Acme Creator!", description, footer Link "Creator Hub" + external-link icon.
  2. `card-variants` — 320px cards: Transparent / Default / Secondary / Tertiary, each with title, description (states bg token) and content paragraph.
  3. `card-horizontal` — full-width, row on md+: 120×120 (mobile full-width × 140) radius 16 image (cherries, scaled 1.25 cover); header with pe-32 title + CloseButton absolutely at end/top 12; footer "Only 10 spots" / "Submission ends Oct 10." + "Apply Now" button (full width on mobile).
  4. `card-with-avatar` — two 200px cards gap 8: 56px radius-16 square image, title "Indie Hackers"/"AI Builders", "148 members"/"362 members", footer 20px Avatar + "By Martha"/"By John".
  5. `card-with-images` — max-w-2xl 12-col grid gap 16: (a) horizontal creator card; (b) left column: PAYMENT card with CircleDollar 32px, close button, "You can now withdraw on crypto", Link "Go to settings"; two small community cards; (c) right: 200px min-height image-background card (NEO robot, rounded-3xl) with black/70 overline title, footer "Available soon"/"Get notified" + white sm tertiary button; row 3: tall (250/300/350 responsive) NEO image card with footer "NEO" "$499/m" + button; stack of 3 transparent row cards (p 4, gap 12) with thumbnails: "Bridging the Future" / "Avocado Hackathon" / "Sound Electro | Beyond art" + times.
  6. `card-with-form` — max-w-md Login card: title/description, Form with TextFields Email + Password (secondary Inputs, gap 16), footer mt 16 column gap 8: full-width "Sign In" submit + centered "Forgot password?" link.
  7. `card-custom-styles` (Customization) — "Upgrade to Pro" card: accent/20 border, br gradient accent/12 → surface → surface-secondary, blurred accent blobs, "Recommended" pill, 40px radius-12 accent/15 icon tile with Star, 3 check-list features (14px muted, accent checks), footer "Upgrade now" (shadow) + secondary "Compare plans" (column on mobile, row on sm+).
- **Depends on:** `HeroSurface` scope, theme shadows, `HeroLink`, `HeroCloseButton`, `HeroButton`, `HeroAvatar`, `HeroForm`/`HeroTextField`/`HeroInput`/`HeroLabel` (demos), network images.

#### Separator → `HeroSeparator`
- **Docs:** https://heroui.com/en/docs/react/components/separator · **Category:** Layout
- **Anatomy:** single widget (RAC `Separator`). Orientation can be inherited from an enclosing `HeroToolbar` (flipped: horizontal toolbar → vertical separators).
- **Variants:** `orientation: horizontal* | vertical` (null → inherit from toolbar scope, else horizontal); `variant: default* | secondary | tertiary` (→ `HeroSeparatorVariant.standard/secondary/tertiary`).
- **Key styles:** thickness 1px, radius 4, shrink-0, no borders. Horizontal: height 1, width 100%. Vertical: width 1, `min-h-2` (8), stretches to cross-axis (`self-stretch`) — Flutter: `IntrinsicHeight`-free approach via `SizedBox(width:1, height: double.infinity)` inside a constrained row, min 8. Colors: default `--separator`, secondary `--separator-secondary`, tertiary `--separator-tertiary`. Inside Toolbar: vertical separator height 50% & centered; horizontal separator width 50% centered.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `orientation` | horizontal \| vertical | `Axis? orientation` |
  | `variant` | default \| secondary \| tertiary | `HeroSeparatorVariant variant = standard` |
  | `render` | DOM render fn | n/a |
  | `className` (margins, size, color) | string | `EdgeInsetsGeometry? margin`, `double? length`, `Color? color`, `double thickness = 1` |

- **States & behaviour:** Semantics: `role=separator` — decorative; `ExcludeSemantics` (Flutter has no separator role).
- **Docs examples:**
  1. `separator-basic` — max-w-md title "HeroUI v3 Components" + subtitle, horizontal separator my 16, then 20px-tall row "Blog | Docs | Source" with vertical separators, spacing 16.
  2. `separator-variants` — centered column: "Default Variant", separator, "Secondary Variant", separator, "Tertiary Variant", separator.
  3. `separator-with-surface` — four Surfaces (default/secondary/tertiary/transparent+border, radius 24, p 24, gap 12) with matching separator variant between heading and text.
  4. `separator-vertical` — "Blog | Docs | Source" row.
  5. `separator-with-content` — list of 3 items (48px 3D icon + title + muted subtitle) separated by my-16 separators.
  6. `separator-render-function` — same as basic with custom render element → gallery shows identical output.
  7. `separator-custom-styles` (Customization) — "Account settings" + secondary-color separator; row Profile | Billing | Security with 16px vertical separators.
- **Depends on:** theme separator tokens, `HeroToolbar` scope, `HeroSurface` (demo).

#### Surface → `HeroSurface`
- **Docs:** https://heroui.com/en/docs/react/components/surface · **Category:** Layout
- **Anatomy:** single container + `SurfaceContext` → `HeroSurfaceScope` InheritedWidget (`HeroSurfaceScope.maybeOf(context)?.variant`), also provided by Card (non-transparent), Alert (default), Modal/Popover/Drawer/Dropdown/Select… so descendants can pick "on-surface" colors.
- **Variants:** `variant: transparent | default* | secondary | tertiary` (→ `HeroSurfaceVariant.transparent/standard/secondary/tertiary`).
- **Key styles:** relative; text `--foreground`; default bg `--surface` fg `--surface-foreground`; secondary bg `--surface-secondary` fg `--surface-secondary-foreground`; tertiary bg `--surface-tertiary` fg `--surface-tertiary-foreground`; transparent → no bg. No radius/padding/shadow by default (demos add radius 24, p 24).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `variant` | transparent \| default \| secondary \| tertiary | `HeroSurfaceVariant variant = standard` |
  | `children` | ReactNode | `Widget child` |
  | `className` (radius, padding, border) | string | `EdgeInsetsGeometry? padding`, `BorderRadiusGeometry? borderRadius`, `BoxBorder? border`, `double? width` |
  | `SurfaceContext` | context | `HeroSurfaceScope` |

- **States & behaviour:** none; sets `DefaultTextStyle` color to the surface foreground.
- **Docs examples:**
  1. `surface-basic` — default surface min-w 320, radius 24, p 24, gap 12: "Surface Content" (16 semibold) + muted 14 text.
  2. `surface-variants` — Default / Secondary / Tertiary / Transparent (with border) each captioned.
  3. `surface-with-form-components` — Surface with `Input` and `TextArea` both `variant: secondary`, gap 16.
  4. `surface-custom-styles` (Customization) — max-w-sm radius 12 accent/15 border, gradient accent/8 → surface → surface-secondary, p 16: "Billing overview".
- **Depends on:** theme surface tokens; `HeroInput`, `HeroTextArea` (demo).

#### Toolbar → `HeroToolbar`
- **Docs:** https://heroui.com/en/docs/react/components/toolbar · **Category:** Layout
- **Anatomy:** single container (RAC `Toolbar`). Provides orientation to child `HeroToggleButtonGroup`/`HeroButtonGroup` (same orientation) and to `HeroSeparator` (flipped orientation).
- **Variants:** `orientation: horizontal* | vertical`; `isAttached: false*`.
- **Key styles:**
  - Base: `w-fit`, grid auto-flow column (→ `Row(mainAxisSize: min)`), items center, gap 8.
  - Vertical: auto-flow row (→ `Column`), items start, justify start; nested ButtonGroup justify start.
  - Separators inside: vertical separator = 50% of toolbar height, centered; horizontal separator = 50% width, centered.
  - Attached: radius 24 (`rounded-3xl`), bg `--surface`, padding 4, shadow `--overlay-shadow`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `isAttached` | boolean | `bool isAttached = false` |
  | `orientation` | horizontal \| vertical | `Axis orientation = Axis.horizontal` |
  | `aria-label` / `aria-labelledby` | string | `String? semanticLabel` |
  | `children` | node \| (renderProps{orientation}) => node | `List<Widget> children` / `builder(context, Axis orientation)` |
  | `className` | string \| fn | `EdgeInsetsGeometry? padding`, `double? gap`, `Decoration? decoration` |

- **States & behaviour:** keyboard: single tab stop — Tab enters toolbar at last-focused/first item; Arrow Left/Right (horizontal, RTL flipped) or Up/Down (vertical) move focus among all focusable descendants (Home/End to first/last); Tab exits. Implement with `FocusTraversalGroup` + custom `Shortcuts`/`Actions`. Semantics: `role=toolbar` → `Semantics(container: true, label: semanticLabel)`.
- **Docs examples:**
  1. `toolbar-basic` — ToggleButtonGroup (Bold/Italic/Underline, multiple, separators) + Separator + tertiary ButtonGroup (Copy / Cut).
  2. `toolbar-vertical` — vertical: same toggle group (renders vertical) + horizontal separator + Undo/Redo group.
  3. `toolbar-attached` — basic content with `isAttached` (surface pill with overlay shadow).
  4. `toolbar-with-button-group` — Undo/Redo labeled group, separator, B/I/U toggles, separator, 3 alignment icon buttons.
  5. `toolbar-custom-styles` (Customization) — gap 4, radius 12 bordered `--surface-secondary`, p 6; toggle group gap 2 with radius-8 toggles, selected bg `--accent` fg `--accent-foreground`.
- **Depends on:** `HeroToggleButtonGroup`, `HeroButtonGroup`, `HeroSeparator` (orientation scopes), shared roving-focus helper, theme overlay shadow.

---

### Media

#### Avatar → `HeroAvatar`
- **Docs:** https://heroui.com/en/docs/react/components/avatar · **Category:** Media
- **Anatomy:** `Avatar` (Radix Avatar root) → `HeroAvatar`; `Avatar.Image` → `HeroAvatarImage` (only painted once loaded; fades in); `Avatar.Fallback` → `HeroAvatarFallback` (shown while not loaded / on error, optionally after `delayMs`). Convenience: `HeroAvatar(image: NetworkImage(...), fallback: Text('JD'))` / `HeroAvatar(src: '...', name: 'John Doe')` (initials auto-derived optional).
- **Variants:** `size: sm | md* | lg`; `color: default* | accent | success | warning | danger` (→ `HeroColor`, affects fallback); `variant: default* | soft` (→ `HeroAvatarVariant.standard | soft`). Size/color/variant inherit from a parent `HeroAvatarGroup` when null (direct children only).
- **Key styles:**
  - Root: centered, clip, shrink-0, bg `--default`. Size/radius: sm 32 / `rounded-2xl` 16 · md 40 / `rounded-3xl` 24 · lg 48 / `rounded-3xl` 24 (= circles at the default `--radius`; radii scale with theme radius). Exposes `--avatar-size` (32/40/48) for AvatarGroup clip math.
  - Image: fills root (`inset-0`, square; use `BoxFit.cover`), `transition-opacity` 250ms (default Tailwind ease `Cubic(0.4,0,0.2,1)`).
  - Fallback: fills root, centered, bg `--default`, 14px medium (sm 12px, lg 16px). Text color: default `--default-soft-foreground`, accent `--accent-soft-foreground`, success `--success-soft-foreground`, warning `--warning-soft-foreground`, danger `--danger-soft-foreground`.
  - Soft variant: root bg transparent; fallback bg = `--{color}-soft` (default → `--default-soft`), fg `--{color}-soft-foreground`.
  - Icons in fallback inherit fg color (demo `Person` icon at default icon size).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `size` | sm \| md \| lg | `HeroSize? size` |
  | `color` | 5 colors | `HeroColor? color` |
  | `variant` | default \| soft | `HeroAvatarVariant? variant` |
  | `Avatar.Image.src` / `srcSet` / `sizes` | string | `ImageProvider image` (`HeroAvatarImage.network(src)`) |
  | `Avatar.Image.alt` | string | `String? semanticLabel` |
  | `Avatar.Image.asChild` | boolean | `Widget Function(BuildContext, ImageProvider)? imageBuilder` (custom image widget) |
  | `Avatar.Image.onLoad` / `onError` | callbacks | `VoidCallback? onLoad`, `ImageErrorListener? onError` |
  | `Avatar.Image.crossOrigin` / `loading` | web attrs | n/a |
  | `Avatar.Fallback.delayMs` | number | `Duration? delay` |
  | `Avatar.Fallback.color` | 5 colors | `HeroColor? color` (override) |
  | `Avatar.Fallback.children` | node | `Widget child` |

- **States & behaviour:** image loading states `idle/loading/loaded/error` via `ImageStream`; fallback visible unless loaded; image fades in (250ms). Semantics: `image: true, label: alt`; fallback text read if no image.
- **Docs examples:**
  1. `avatar-basic` — "JD" fallback, image (blue.jpg) with "B" fallback, "JR" fallback.
  2. `avatar-sizes` — sm / md / lg image avatars (fallbacks SM/MD/LG).
  3. `avatar-colors` — fallback-only DF / AC / SC / WR / DG in default/accent/success/warning/danger.
  4. `avatar-variants` — matrix: header row of color names (80px columns, 96px label column), Separator, rows "letter" (AG), "letter soft", "icon" (Person), "icon soft", "img" (5 different photos).
  5. `avatar-fallback` — text "JD"; icon Person; image with `delayMs: 600` "NA"; custom gradient (pink-500 → purple-500, white text) "GB".
  6. `avatar-custom-image-component` — Image via custom image component (Next Image) 40×40 with "JD" fallback → Flutter `imageBuilder`.
  7. `avatar-custom-styles` (Customization) — square-ish avatar radius 8 with "JD".
- **Depends on:** theme soft tokens, `HeroAvatarGroup` scope, `HeroSeparator` (demo), icons (Person).

#### AvatarGroup → `HeroAvatarGroup`
- **Docs:** https://heroui.com/en/docs/react/components/avatar-group · **Category:** Media
- **Anatomy:** `AvatarGroup` → `HeroAvatarGroup(children: [HeroAvatar...])`; `AvatarGroup.Count` → `HeroAvatarGroupCount(child: Text('+3'))` (an Avatar + Fallback styled as count; not truncated by `max`; suppresses the automatic count). Auto count `+N` rendered when `max` truncates and no explicit Count.
- **Variants:** `isGrid: false*`; `overlap: clip* | ring` (→ `HeroAvatarGroupOverlap`); `size: sm | md* | lg`; `color` (none default); `variant` (none default); `max: int?`.
- **Key styles:**
  - Container inline row, items center. Tokens: overlap 8px (`--avatar-group-overlap: 0.5rem`), seam 2px (`--avatar-group-seam`) — expose as params.
  - Stacked (non-grid): every avatar/count after the first gets `margin-inline-start: -overlap`. Later avatars paint on top (DOM order).
  - Clip overlap (default): each non-last avatar is masked by a radial cut-out circle centered at x = `100% + size/2 − overlap`, y = 50%, radius = `size/2 + seam` (mirrored in RTL: x = `0% − size/2 + overlap`), producing a transparent crescent seam; fallback content gets `padding-inline-end: overlap·0.35` (2.8px) optical nudge. Flutter: `ClipPath` with `PathFillType.evenOdd` / `CustomClipper`.
  - Ring overlap: each avatar/count gets `box-shadow: 0 0 0 seam --background` (2px outline in background color).
  - Grid: `flex-wrap`, gap 12, no overlap, no clip/ring (→ `Wrap(spacing: 12, runSpacing: 12)`).
  - Count: shrink-0; same Avatar styling (color/size/variant from group unless overridden).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `size` | sm \| md \| lg (md) | `HeroSize size = md` |
  | `color` | 5 colors | `HeroColor? color` |
  | `variant` | default \| soft | `HeroAvatarVariant? variant` |
  | `max` | number | `int? max` |
  | `isGrid` | boolean | `bool isGrid = false` |
  | `overlap` | clip \| ring | `HeroAvatarGroupOverlap overlap = clip` |
  | `children` | Avatars + optional Count | `List<Widget> children` |
  | `--avatar-group-overlap` / `--avatar-group-seam` CSS vars | length | `double overlapDistance = 8`, `double seam = 2` |
  | `Count.children` | node | `HeroAvatarGroupCount(child)` |
  | `Count.size/color/variant` | overrides | same-named nullable params |
  | `role="group"` + `aria-label` | — | `String? semanticLabel` (wraps in `Semantics(container: true)` only when set) |

- **States & behaviour:** static. No default group semantics.
- **Docs examples:**
  1. `avatar-group-basic` — 4 image avatars (initials fallbacks) stacked with clip.
  2. `avatar-group-max` — 5 users, `max: 3` → 3 avatars + "+2".
  3. `avatar-group-count` — sm group of 3 + explicit Count "+9" (total 12).
  4. `avatar-group-sizes` — Small / Medium (default) / Large groups of 4, captioned, centered.
  5. `avatar-group-grid` — `isGrid`, `max: 5`, 5 avatars wrapping with gap 12.
  6. `avatar-group-overlap` — "clip" vs "ring" lg groups (JD image, AB, EC image, SM, Count "+2") over an animated diagonal danger-tinted stripe backdrop (radius 12, p 24; stripes move 24px per 2.8s) to show seam transparency.
  7. `avatar-group-custom-styles` (Customization) — pill chip (radius full, border 70%, surface/95, py 4, pr 12, pl 4, gap 10, shadow-sm): sm clip group with overlap 11.2px (0.7rem), 3 avatars + Person-icon avatar + Count "+3", then "Assignees" 14px medium label.
- **Depends on:** `HeroAvatar`, custom clipper, theme `--background`.

---

### Data display

#### Badge → `HeroBadge`
- **Docs:** https://heroui.com/en/docs/react/components/badge · **Category:** Data Display
- **Anatomy:** `Badge.Anchor` → `HeroBadgeAnchor(child: <anchored widget>, badge: HeroBadge(...))` (a `Stack` with `clipBehavior: none`); `Badge` → `HeroBadge` (positioned per `placement` when inside an anchor); `Badge.Label` → `HeroBadgeLabel` (plain text/number children are auto-wrapped). No children → dot. Convenience: `HeroBadge.anchor(child:, content:, ...)`.
- **Variants:** `variant: primary* | secondary | soft`; `color: default* | accent | success | warning | danger`; `size: sm | md* | lg`; `placement: top-right* | top-left | bottom-right | bottom-left` (→ `HeroBadgePlacement.topRight…`).
- **Key styles:**
  - Base: inline-flex centered, gap 2, weight 500, radius 24 (`rounded-3xl`; stadium), 1px border in `--background` (background painted inside the border — `background-clip: padding-box`), shrink-0.
  - Size: sm → min 16×16, radius 12 (`rounded-xl`), 10px text, line-height 1.34 · md → min 28×28, radius 24, 12px, lh 1.34 · lg → min 32×32, radius 16 (`rounded-2xl`), 14px, lh 1.43. Label padding h 2 (`px-0.5`). Empty badge = circle of min size (dot).
  - Colors (bg / fg):
    - primary: default `--default` / `--default-foreground`; accent `--accent` / `--accent-foreground`; success `--success` / `--success-foreground`; warning `--warning` / `--warning-foreground`; danger `--danger` / `--danger-foreground`.
    - secondary: bg `--default`; fg default `--default-foreground`, accent `--accent-soft-foreground`, success `--success-soft-foreground`, warning `--warning-soft-foreground`, danger `--danger-soft-foreground`.
    - soft: bg `--{color}-soft` (default → `--default-soft`), fg `--{color}-soft-foreground` (default → `--default-soft-foreground`).
  - Placement (absolute in anchor): top-right → top 0 right 0, translate(25%, −25%) of badge size; top-left → top 0 left 0, translate(−25%, −25%); bottom-right → translate(25%, 25%); bottom-left → translate(−25%, 25%). (Physical left/right — not RTL-flipped.)
  - Anchor: relative inline-flex, shrink-0.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | node (none → dot) | `Widget? child` / `String? label` |
  | `color` | 5 colors | `HeroColor color = standard` |
  | `variant` | primary \| secondary \| soft | `HeroBadgeVariant variant = primary` |
  | `size` | sm \| md \| lg | `HeroSize size = md` |
  | `placement` | top-right \| top-left \| bottom-right \| bottom-left | `HeroBadgePlacement placement = topRight` |
  | `Badge.Anchor.children` | anchored el + Badge | `HeroBadgeAnchor(child:, badge:)` |
  | `Badge.Label.children` | node | `HeroBadgeLabel(child)` |
  | — | — | `String? semanticLabel` (e.g. "5 notifications") |

- **States & behaviour:** static. Semantics: merge badge text into anchor label or explicit `semanticLabel`; dot badges are decorative unless labelled.
- **Docs examples:**
  1. `badge-basic` — Avatars with sm badges: danger "5", accent "New", success dot bottom-right.
  2. `badge-variants` — sections Primary / Secondary / Soft (separated), each a row of 5 avatars with sm "5" badge in accent/default/success/warning/danger.
  3. `badge-sizes` — sm/md/lg avatars with matching-size danger "5".
  4. `badge-colors` — 5 avatars with sm dots in each color (top-right).
  5. `badge-placements` — accent sm dot at top-right / top-left / bottom-right / bottom-left with 12px captions.
  6. `badge-dot` — accent/success/warning/danger sm dots at bottom-right (status indicators).
  7. `badge-with-content` — danger sm "5", "New", "99+", and accent sm with 10px Bell icon.
  8. `badge-custom-styles` (Customization) — soft accent sm "5", min-width 20, semibold, tabular numbers on Kate Wilson avatar.
- **Depends on:** `HeroAvatar` (demos), `HeroSeparator` (demo), theme tokens.

#### Chip → `HeroChip`
- **Docs:** https://heroui.com/en/docs/react/components/chip · **Category:** Data Display
- **Anatomy:** `Chip` → `HeroChip` (row); `Chip.Label` → `HeroChipLabel` (plain text/number auto-wrapped). Icons are free children before/after the label → also `startContent`/`endContent` convenience slots.
- **Variants:** `variant: primary | secondary* | tertiary | soft`; `color: default* | accent | success | warning | danger`; `size: sm | md* | lg`.
- **Key styles:**
  - Base: inline-flex, w-fit, items center, gap 2 (`gap-0.5`), radius 16 (`rounded-2xl`), padding h 8 / v 2, 12px / line-height 20, weight 500. Label padding h 2.
  - Sizes: sm → px 4, py 0, 12px (height 20) · md → px 8, py 2, 12px (height 24) · lg → px 12, py 4, 14px medium (height 28).
  - Colors (bg / fg):
    - secondary (default variant): bg `--default`; fg default `--default-foreground`, accent `--accent-soft-foreground`, success `--success-soft-foreground`, warning `--warning-soft-foreground`, danger `--danger-soft-foreground`.
    - primary: accent `--accent`/`--accent-foreground`; success `--success`/`--success-foreground`; warning `--warning`/`--warning-foreground`; danger `--danger`/`--danger-foreground`; default → same as secondary (`--default` / `--default-foreground`).
    - tertiary: transparent bg; fg per color as secondary.
    - soft: bg `--{color}-soft`, fg `--{color}-soft-foreground` (default → `--default-soft` / `--default-soft-foreground`).
  - Icons: inherit fg; size set by caller (demos 6px dot, 12px icons; CircleDashed default 16).
  - Theme "vibrant palette" (`data-vibrant-palette`) swaps soft foregrounds to `color 92% + foreground 8%` — expose as `HeroThemeData.vibrantPalette` (only used in a release demo not on the docs page).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | node | `Widget? child` / `String? label` (positional) |
  | `color` | 5 colors | `HeroColor color = standard` |
  | `variant` | primary \| secondary \| tertiary \| soft | `HeroChipVariant variant = secondary` |
  | `size` | sm \| md \| lg | `HeroSize size = md` |
  | `Chip.Label.children` | node | `HeroChipLabel(child)` |
  | — | — | `Widget? startContent`, `Widget? endContent` |

- **States & behaviour:** static (no press/close in v3 Chip; use TagGroup for interactive tags). Semantics: plain text.
- **Docs examples:**
  1. `chip-basic` — Default, Accent, Success, Warning, Danger (secondary).
  2. `chip-variants` — for sizes lg / md / sm (separated): header of 5 color columns (130px) + rows primary/secondary/tertiary/soft, each chip = CircleDashed + "Label" + CircleDashed.
  3. `chip-statuses` — primary with 6px CircleFill: Default / Active (success) / Pending (warning) / Inactive (danger); secondary with 12px icons: CircleInfo "New Feature", Check "Available", TriangleExclamation "Beta", Ban "Deprecated".
  4. `chip-with-icon` — CircleFill "Information"; CircleCheckFill "Completed" (success); Clock "Pending" (warning); Xmark "Failed" (danger); accent "Label" + trailing ChevronDown.
  5. `chip-custom-styles` (Customization) — fully-rounded px 12 soft pills: "Draft" (default-soft), "In review" (warning-soft), "Published" (success-soft).
- **Depends on:** theme soft tokens, icon set, `HeroSeparator` (demo).

---

### Utilities

#### ScrollShadow → `HeroScrollShadow`
- **Docs:** https://heroui.com/en/docs/react/components/scroll-shadow · **Category:** Utilities
- **Anatomy:** single scroll container (`div` with overflow) → `HeroScrollShadow` = `ShaderMask` (linear-gradient alpha mask) around a `SingleChildScrollView`/`Scrollable` child, listening to its `ScrollController`/`ScrollMetricsNotification`. Optionally accept an external `ScrollController` or a `builder` for list views.
- **Variants:** `orientation: vertical* | horizontal` (→ `Axis`); `variant: fade*` (only value); `hideScrollBar: false*`; `visibility: auto* | both | top | bottom | left | right | none` (controlled mode); `isEnabled: true*`.
- **Key styles / behaviour of the fade:**
  - Tokens: `size` 40px (fade length), `offset` 0px, scrollbar gutter 10px (0 when `hideScrollBar`) — the gutter strip (right edge for vertical, bottom edge for horizontal) is always fully opaque so the scrollbar isn't faded. Expose `scrollbarGutter` param (default 10).
  - Auto mode (continuous, matches the scroll-driven CSS path): start fade length = clamp(scrollPos − offset, 0, size); end fade length = clamp(maxScroll − scrollPos − offset, 0, size). Mask = transparent at edge → opaque at fade length (linear). Zero fades when content does not overflow. Horizontal fades are logical (start/end), flipped in RTL.
  - Discrete state (fallback/attribute path + callback): `hasScrollBefore = pos > offset`; `hasScrollAfter = pos + viewport + offset < extent − 1`. Visibility reported: both → `both`; only before → `top`/`left`; only after → `bottom`/`right`; neither → `none`.
  - Controlled `visibility` (≠ auto) or `isEnabled: false` → "manual" mode: fixed full-size (`size`) fades on the requested edges (`both` → both edges; `none` → no mask), no scroll tracking.
  - Hide scrollbar → `ScrollConfiguration(behavior: ...copyWith(scrollbars: false))`. Otherwise thin themed scrollbar (`scrollbar` utility).
  - No background, border or padding of its own (demos add padding 16 inside the scroll area).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `orientation` | vertical \| horizontal | `Axis orientation = Axis.vertical` |
  | `variant` | `'fade'` | `HeroScrollShadowVariant variant = fade` |
  | `size` | number (40) | `double size = 40` |
  | `offset` | number (0) | `double offset = 0` |
  | `hideScrollBar` | boolean | `bool hideScrollBar = false` |
  | `isEnabled` | boolean (true) | `bool isEnabled = true` |
  | `visibility` | auto \| both \| top \| bottom \| left \| right \| none | `HeroScrollShadowVisibility visibility = auto` |
  | `onVisibilityChange` | `(visibility) => void` | `ValueChanged<HeroScrollShadowVisibility>? onVisibilityChanged` |
  | `children` | ReactNode | `Widget child` |
  | `className` (max-h, padding) | string | `EdgeInsetsGeometry? padding`, `double? maxHeight` / constraints from parent, `ScrollController? controller` |
  | `--scroll-shadow-scrollbar-size` | CSS var | `double scrollbarGutter = 10` |

- **States & behaviour:** callback fires only when the discrete state changes. Fade updates every scroll frame. Keyboard/mouse scrolling as native `Scrollable`.
- **Docs examples:**
  1. `scroll-shadow-default` — sm:max-w-sm, max-height 240, p 16, ten lorem paragraphs (spacing 16).
  2. `scroll-shadow-orientation` — "Vertical" (inside Card p 0, same text) and "Horizontal" (Card p 0 with a row of 10 transparent mini-cards min-w 200: 64/80px radius-12 image + "Bridging the Future" / "Today, 6:30 PM").
  3. `scroll-shadow-size` — `size: 80`.
  4. `scroll-shadow-with-card` — Card max-w 400 "Terms and Conditions" / "Please review before proceeding", content with 300px-tall ScrollShadow (px 16, size 80), footer Cancel (secondary) + Accept, both full width.
  5. `scroll-shadow-hide-scroll-bar` — `hideScrollBar: true`.
  6. `scroll-shadow-visibility-change` — status boxes ("Vertical Shadow State: …", "Horizontal Shadow State: …", bg `--default`, radius 4, p 16) updated from `onVisibilityChanged` for vertical text and horizontal card row.
  7. `scroll-shadow-custom-styles` (Customization) — hideScrollBar, size 48, max-h 192, radius 12 bordered gradient (neutral-50/90 → white) box with 6 changelog lines (14px relaxed).
- **Depends on:** `HeroCard`, `HeroButton` (demos); theme scrollbar colors.

---

### Non-docs public components (exported from `@heroui/react`, no docs page)

#### EmptyState → `HeroEmptyState`
- **Docs:** none (exported from `packages/react/src/components/empty-state`) · **Category:** Collections helper
- **Anatomy:** single `div` (`EmptyState` / `EmptyState.Root`). Used as the `renderEmptyState` content of ListBox / Autocomplete / ComboBox / Select / Table / TagGroup / Dropdown demos.
- **Variants:** none.
- **Key styles:** padding 8 (`p-2`), 14px (`text-sm`, line 20), color `--muted`. Children default to the text **"No results found"** when empty.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | ReactNode | `Widget? child` (default `Text('No results found')`, localizable via `HeroLocalizations.noResultsFound`) |

- **States & behaviour:** static; semantics plain text (consider `liveRegion: true` when shown after filtering).
- **Docs examples:** none of its own — appears in 28 demo files: autocomplete (24), tag-group (2), combo-box (1), table (1), as `renderEmptyState: (_) => HeroEmptyState(child: Text('No results found'))`.
- **Depends on:** theme only; consumed by `HeroListBox.emptyStateBuilder`, `HeroTable.emptyStateBuilder`, etc.

#### Header → `HeroHeader`
- **Docs:** none (exported from `packages/react/src/components/header`, wraps RAC `Header`) · **Category:** Collections helper
- **Anatomy:** single element (`<header>` in RAC collections) — the section title inside `ListBox.Section` / `Menu.Section` / `Dropdown.Section` / Autocomplete sections (e.g. `<Header>North America</Header>`).
- **Variants:** none.
- **Key styles:** full width, padding start/end 8 (`px-2`), top 6 (`pt-1.5`), bottom 4 (`pb-1`), text-start, 12px (`text-xs`, line 16) weight 500, color `--muted`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | ReactNode | `Widget child` / `String text` |

- **States & behaviour:** non-focusable; Semantics `header: true`; in a RAC section it labels the section group (`aria-labelledby`) → the parent `HeroListBoxSection` should use it as the section's semantic label.
- **Docs examples:** none of its own — used in 11 section demo files: dropdown (6), list-box (2), autocomplete `with-sections`, combo-box, select (1 each).
- **Depends on:** theme only; consumed by `HeroListBoxSection`, `HeroMenuSection`, `HeroDropdownSection`.

---

### Cross-cutting foundations needed by Group A

- `HeroInteractable` — hover (mouse only, `(hover: hover)`), pressed, focus-visible (keyboard modality only), disabled/pending gating; exposes `HeroInteractionState` to builders; activates on Enter/Space.
- `HeroFocusRing` — 2px `--focus` ring, 2px gap (offset) in `--background`; inset variant (ToggleButtonGroup); follows widget radius.
- Group-position scope (`first/middle/last/single` × orientation) shared by ButtonGroup and ToggleButtonGroup; orientation scope from Toolbar (flipped for Separator).
- Roving-focus helper (Toolbar, ToggleButtonGroup).
- `HeroSurfaceScope` (Surface/Card/Alert/overlays).
- Theme tokens: accent/default/success/warning/danger + `-hover`, `-soft`, `-soft-hover`, `-soft-foreground`, surfaces (+secondary/tertiary), separator (+secondary/tertiary), border, muted, focus, link, background, `--surface-shadow`, `--overlay-shadow`, radius scale, `disabledOpacity 0.5`, `skeletonAnimation`, `vibrantPalette`.
- `HeroIcons`: close, info, success, warning, danger, chevrons, external link (from `packages/react/src/components/icons.tsx`).
- Responsive helper: `sm` (≥640) / `md` (≥768) breakpoints (Button/ToggleButton heights & icon sizes change at these).
- Reduced motion: every transition/animation above respects `MediaQuery.disableAnimationsOf(context)`.

## Forms and controls

Source of truth: HeroUI v3 (`packages/styles/components/*.css`, `packages/react/src/components/*`, `apps/docs/src/demos/en/*`).
Units: 1 Tailwind step = 4 px, 1 rem = 16 px. Type scale (TW4): `text-xs` 12/16, `text-sm` 14/20, `text-base` 16/24, `text-lg` 18/28 (size/line-height px). `font-medium` = w500, `font-semibold` = w600.

### 0. Shared foundations used by every section below

**Field tokens** (theme `:root`, light / dark differ only in colour values):
- `field` = `--field-background` (light `white`, dark `oklch(0.2103 0.0059 285.89)`), `field-foreground`, `field-placeholder` (= `muted`).
- `field-hover` = `color-mix(oklab, field 90%, field-foreground 2%)` — percentages sum to 92 %, so the result is the normalised mix at **alpha 0.92** (not opaque).
- `field-focus` = `field`. `field-border` = `transparent`; `field-border-hover` = mix(border 88 %, fg 10 %) (alpha .98); `field-border-focus` = mix(border 74 %, fg 22 %) (alpha .96).
- `field-border-width` = **0 px** by default (`--field-border-width: 0px`), so border colours above are invisible unless a theme sets a width. Keep all border paths but default width 0.
- `field-radius` (`rounded-field`) = `radius × 1.5` = **12 px** (`--radius` 8 px). Other radii: `sm` 4, `md` 6, `lg` 8, `xl` 12, `2xl` 16, `3xl` 24.
- `shadow-field` light = `0 2 4 0 rgba(0,0,0,.04), 0 1 2 0 rgba(0,0,0,.06), 0 0 1 0 rgba(0,0,0,.06)`; dark = none.
- Secondary ("on surface") field backgrounds: `default` / hover `default-hover` (= mix(default 96 %, default-fg 4 %)) / focus `default`, and **no shadow**.
- `--color-field-border-invalid` is referenced by InputGroup/SearchField/NumberField CSS but **never defined** (invalid border colour is thus unset; harmless at 0 px width). Use `danger` if a border width is themed.

**State utilities** (implement once as painters/decorations):
- `status-focused` (buttons/toggles): 2 px ring `focus` (= `accent`) with a **2 px offset** filled with `background`.
- `status-focused-field` (text fields): 2 px ring `focus`, **0 offset**.
- `status-invalid-field`: unfocused → 1 px `danger` outline (offset 0); focused / focus-within → 2 px `danger` ring, 0 offset.
- `status-disabled`: opacity `.5` (`--disabled-opacity`), cursor not-allowed, ignores pointer. Note opacity **compounds** when both a parent and a child apply it (e.g. Description inside a disabled Checkbox renders at .25).
- Hover styles are wrapped in `@media (hover: hover)` → apply only for mouse/stylus pointers (use `MouseRegion`; never on touch).
- Motion: every transition is disabled under reduced motion (`MediaQuery.disableAnimations` / a `HeroTheme.reduceMotion` flag).

**Curves:** `ease-smooth` = CSS `ease` = `Curves.ease`; TW `ease-out` = `Cubic(0, 0, 0.2, 1)`; TW default (`transition-all` w/o curve) = 150 ms `Cubic(0.4, 0, 0.2, 1)` (= `Curves.fastOutSlowIn`); `ease-linear` = linear; `ease-out-fluid` = `Cubic(0.32, 0.72, 0, 1)`; `ease-out-quart` = `Cubic(0.165, 0.84, 0.44, 1)`.

**Responsive text in inputs:** every text input (`Input`, `TextArea`, `InputGroup.Input`, `SearchField.Input`, `NumberField.Input`) is `text-base` (16/24) below 640 px viewport width and `sm:text-sm` (14/20) at ≥ 640 px. Consequence: standalone `Input` height is 40 px on narrow screens and 36 px on wide ones. Implement via `MediaQuery.sizeOf(context).width >= 640`.

**Shared Flutter API pieces (proposed):**
- `enum HeroFieldVariant { primary, secondary }` — shared by Input, TextArea, TextField, InputGroup, SearchField, NumberField, InputOTP, Checkbox, CheckboxGroup, RadioGroup (all use exactly `primary* | secondary`).
- `HeroFieldScope` (InheritedWidget) published by every field root (TextField, SearchField, NumberField, Checkbox, CheckboxGroup, RadioGroup, Radio, Switch, Fieldset): `isDisabled, isInvalid, isRequired, isReadOnly, variant, validation (HeroValidationResult), showRequiredIndicator, labelFocusNode`. Children (`HeroLabel`, `HeroDescription`, `HeroFieldError`, inputs) read it — this replaces the CSS ancestor selectors (`[data-disabled] .label`, `[data-invalid] .label`, `[data-required] > .label`).
- `class HeroValidationResult { bool isInvalid; List<String> validationErrors; }`.
- `enum HeroValidationBehavior { native, aria }` — `native` (default): errors appear after a submit attempt (`HeroForm.submit()` / `Form.validate()`), then re-validate on each user change (`AutovalidateMode.onUserInteraction` after first submit); submission is blocked and the first invalid field is focused. `aria`: realtime validation (`onUserInteraction` from the start), submission not blocked.
- Validation prop mapping (applies to every form control): `validate` → `validator` (`FormFieldValidator<T>`), `validationErrors` → `validationErrors: List<String>?` (server errors, shown immediately, cleared on next user change), `isInvalid` → forces invalid regardless of validator, `isRequired` → built-in required rule (default messages mirror Chrome: text "Please fill out this field.", checkbox "Please check this box if you want to proceed.", radio "Please select one of these options."; overridable via localizations), `name` → key in `HeroForm.onSubmit` data map, plus `onSaved`, `autovalidateMode` (conventions). Every field root is a `FormField<T>` registered with the nearest `Form`.
- `render` (DOM element override, "Render Function" demos) and `className` have **no Flutter equivalent**; the gallery reproduces "render-function" demos visually identical to the basic demo. "Custom styles" demos are reproduced through the per-part `style`/override params named in each section.

---

#### Label → `HeroLabel`
- **Docs:** https://heroui.com/en/docs/react/components/label · **Category:** Forms
- **Anatomy:** single widget `HeroLabel(child)`. Used as the first child of every field compound (`HeroTextField`, `HeroSearchField`, `HeroNumberField`, `HeroCheckboxGroup`, `HeroRadioGroup`, `HeroSlider`, `HeroInputOTP` demos).
- **Variants:** booleans `isRequired: false*`, `isDisabled: false*`, `isInvalid: false*` (each also inherited from `HeroFieldScope`).
- **Key styles:** `text-sm` (14/20) `font-medium` (w500) `foreground`. Required: appends `*` with 2 px start margin (`ms-0.5`) in `danger`, same font. Disabled: `status-disabled` (opacity .5). Invalid: text colour `danger`. Asterisk logic: shown when own `isRequired`, or when the enclosing field root is required **and** the label is the root's direct field label (TextField/SearchField/NumberField/CheckboxGroup/RadioGroup labels get it; labels inside a single Checkbox/Radio item never do). Inside Slider: `w-fit`, grid-area "label"; inside SearchField/NumberField: `w-fit`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `htmlFor` | `string` | `focusNode: FocusNode?` (tap requests focus) + `onPressed: VoidCallback?` (tap action, e.g. toggle an external checkbox). Inside a field compound it auto-associates via `HeroFieldScope`. |
  | `isRequired` | `boolean` | `isRequired: bool?` (null → inherit scope) |
  | `isDisabled` | `boolean` | `isDisabled: bool?` |
  | `isInvalid` | `boolean` | `isInvalid: bool?` |
  | `children` | `ReactNode` | `child: Widget` (+ `HeroLabel.text(String)` convenience) |
  | `className` | `string` | `style: TextStyle?` override (needed by custom-styles demo: 12 px, w600, letter-spacing wide, `accent`, uppercase) |
- **States & behaviour:** tapping the label focuses/activates the associated control (native `<label>`). Semantics: excluded from the tree and merged into the associated control's `Semantics.label` (+ ", required" hint when required). Not focusable itself.
- **Docs examples:**
  1. `label-basic` — Label "Name" above a w-64 Input (gap 4).
  2. `label-custom-styles` — "Repository" label restyled (xs, semibold, tracking-wide, accent, uppercase) above a `bg-field` Input, gap 6.
  - Code-only snippets on the page (add to gallery): *With Required Indicator* (Email Address + asterisk), *With Disabled State* (Username label + disabled input), *With Invalid State* (Password label + invalid input).
- **Depends on:** theme typography/colours, `HeroFieldScope`, `HeroInput` (demos).

#### Description → `HeroDescription`
- **Docs:** https://heroui.com/en/docs/react/components/description · **Category:** Forms
- **Anatomy:** single widget `HeroDescription(child)`; placed inside field compounds after the control.
- **Variants:** none.
- **Key styles:** `text-xs` (12/16), `muted`, wraps (break-word). No padding by default (the docs' `px-1` snippet is only an example). Context overrides: inside Checkbox/Radio item → start padding 28 px (`ps-7` = control 16 + gap 12), `cursor-default`, non-selectable; inside Switch → start padding `2.5rem+0.75rem` = 52 px (sm 44 px, lg 60 px). Hidden (not rendered) while the enclosing TextField / SearchField / NumberField is invalid. Inside a disabled Checkbox/Radio/Switch it gets its own `status-disabled` (compounds → .25).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode` | `child: Widget` (+ `.text(String)`) |
  | `className` | `string` | `style: TextStyle?` (custom-styles demo: relaxed line-height 1.625, tracking-wide) |
- **States & behaviour:** passive text. Semantics: its text is appended to the owning control's `Semantics.hint` (aria-describedby); itself excluded.
- **Docs examples:**
  1. `description-basic` — Email label, Input, description "We'll never share your email with anyone else."
  2. `description-custom-styles` — "Workspace URL" field with relaxed/tracking-wide description.
  - Code-only: *With Form Fields* (password + hint), *Integration with TextField*.
- **Depends on:** theme, `HeroFieldScope`.

#### FieldError → `HeroFieldError`
- **Docs:** https://heroui.com/en/docs/react/components/field-error · **Category:** Forms
- **Anatomy:** single widget; child of a field compound (TextField, SearchField, NumberField, Checkbox, CheckboxGroup, RadioGroup, Radio, Switch). Only renders while the field's validation `isInvalid` is true.
- **Variants:** none.
- **Key styles:** `text-xs` (12/16), `danger`, horizontal padding 4 px (`px-1`), wraps. CSS declares collapse transitions (opacity 150 ms `ease-out`, height 350 ms `ease`) but because the element mounts already visible, the observable result is instant show/hide — implement instant (optionally a 150 ms fade-in). **Inside Checkbox/Radio/Switch roots:** padding 0 except start indent (28 px checkbox/radio, 52/44/60 px switch md/sm/lg), colour **`muted`** (not danger), no transition.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode \| (ValidationResult) => ReactNode` | `child: Widget?` or `builder: Widget Function(BuildContext, HeroValidationResult)`; when both null renders `validationErrors.join(' ')` |
  | `className` | `string` | `style: TextStyle?` (custom-styles: w500) |
- **States & behaviour:** visible iff scope `validation.isInvalid` (explicit `isInvalid`, validator error, required failure or server `validationErrors`). Semantics: `liveRegion: true` so errors are announced; text also appended to control's semantics hint.
- **Docs examples:**
  1. `field-error-basic` — controlled Username TextField (initial "jr") invalid while length 1–2; error "Username must be at least 3 characters".
  2. `field-error-custom-styles` — "Handle" field with monospace `bg-field` input and medium-weight error.
  - Code-only: *Basic Validation*, *With Dynamic Messages* (builder joins `validationErrors`), *Custom Validation Logic* (email must include @), *Multiple Error Messages* (one line per error).
- **Depends on:** `HeroFieldScope`, `HeroTextField`, `HeroLabel`, `HeroInput`.

#### ErrorMessage → `HeroErrorMessage`
- **Docs:** https://heroui.com/en/docs/react/components/error-message · **Category:** Forms
- **Anatomy:** single widget; for **non-form** components (TagGroup, Calendar). Sibling of `HeroLabel`/`HeroDescription` inside those roots.
- **Variants:** none.
- **Key styles:** `text-xs` (12/16), `danger`, wraps, height auto; same (practically inert) opacity 150 ms / height 350 ms transitions. No padding.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode` | `child: Widget?` (null/empty → `SizedBox.shrink()`) |
  | `className` | `string` | `style: TextStyle?` (custom-styles: w500) |
- **States & behaviour:** no form integration, always renders its child. Semantics `liveRegion: true`.
- **Docs examples:**
  1. `error-message-basic` — multi-select TagGroup "Required Categories" (News/Travel/Gaming/Shopping) + Description; ErrorMessage "Please select at least one category" while nothing selected.
  2. `error-message-custom-styles` — "Topics" TagGroup (API/Design/Docs), max-w-xs, gap 6, medium-weight error.
- **Depends on:** `HeroTagGroup`/`HeroTag` (collections group), `HeroLabel`, `HeroDescription`.

#### Input → `HeroInput`
- **Docs:** https://heroui.com/en/docs/react/components/input · **Category:** Forms
- **Anatomy:** single primitive text input. Standalone or as a child of `HeroTextField` (then it is a pure view bound to the field scope; variant inherited from the TextField/ComboBox scope unless set).
- **Variants:** `variant: primary* | secondary` (`HeroFieldVariant`); `fullWidth: false*`.
- **Key styles:**
  - Box: radius 12 (`rounded-field`), padding 12 h / 8 v, bg `field`, text `field-foreground`, placeholder `field-placeholder`, `shadow-field`, border width `field-border-width` (0) colour `field-border`. Font 16/24 (<640 px) → 14/20 (≥640 px); height therefore 40 / 36 px. Default width = native input intrinsic (~20 ch ≈ 190 px at 14 px); `fullWidth` → `double.infinity`.
  - Hover (not focused): bg `field-hover`, border `field-border-hover`.
  - Focus: `status-focused-field` (2 px `focus` ring, no offset), border `field-border-focus`, bg `field-focus`.
  - Invalid: `status-invalid-field` (1 px danger outline; 2 px danger ring when focused), bg `field-focus`.
  - Disabled: `status-disabled`.
  - `secondary`: no shadow, bg `default`, hover `default-hover`, focus `default`, invalid bg `default`.
  - Transitions: background 150 ms `ease`, border-color 150 ms `ease`, ring/shadow 150 ms `Cubic(0,0,.2,1)`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `type` | `string` (`"text"`) | `type: HeroInputType` {`text`*, `email`, `password`, `number`, `url`, `tel`, `search`} → keyboardType / obscureText / type-mismatch validation |
  | `value` / `defaultValue` | `string` | `value: String?` / `defaultValue: String?` (+ `controller: TextEditingController?`) |
  | `onChange` | `(ChangeEvent) => void` | `onChanged: ValueChanged<String>?` |
  | `placeholder` | `string` | `placeholder: String?` |
  | `disabled` | `boolean` | `isDisabled: bool` |
  | `readOnly` | `boolean` | `isReadOnly: bool` |
  | `required` | `boolean` | `isRequired: bool` |
  | `name` | `string` | `name: String?` |
  | `autoComplete` | `string` | `autofillHints: Iterable<String>?` |
  | `maxLength` / `minLength` | `number` | `maxLength: int?` (length formatter, no counter) / `minLength: int?` (validation) |
  | `pattern` | `string` | `pattern: RegExp?` (validation) |
  | `min` / `max` / `step` | `number \| string` | `min: num?` / `max: num?` / `step: num?` (validation for `number` type) |
  | `fullWidth` | `boolean` | `fullWidth: bool` |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant?` (null → inherit) |
  | `aria-label` (demos) | `string` | `semanticLabel: String?` |
  | (Flutter extras) | – | `focusNode`, `autofocus`, `onSubmitted`, `textInputAction`, `inputFormatters`, `width`, `style: HeroFieldStyle?` (bg/radius/border/text/placeholder overrides for custom-styles demos) |

  Form: standalone `HeroInput` with `name`/`validator` registers its own `FormField<String>`; inside `HeroTextField` the TextField owns the FormField.
- **States & behaviour:** hover, focused (keyboard or pointer — web `:focus`, so ring shows on click too), invalid (from scope or `aria-invalid`), disabled, read-only (no visual change). Built on `EditableText` (or Material `TextField` with collapsed decoration) inside a painted container. Semantics: `textField: true`, label from scope/`semanticLabel`, `hint` = placeholder, `enabled`, `readOnly`, `obscured` for password, validation state.
- **Docs examples:**
  1. `input-basic` — w-64 input, placeholder "Enter your name".
  2. `input-variants` — primary & secondary full-width inputs in a 240 px column, gap 8.
  3. `input-on-surface` — secondary input centred inside a 280×180 Surface (radius 24, p 16).
  4. `input-full-width` — full-width input in a 400 px box.
  5. `input-types` — labelled Email / Age (number, min 0) / Password inputs, w-80, gap 16.
  6. `input-controlled` — "heroui.com" controlled input + live "https://{value}" muted caption.
  7. `input-custom-styles` — "Search projects..." input with radius 12, 1 px `border`/80 border, `default` bg.
- **Depends on:** theme field tokens, focus/invalid ring painter, `HeroFieldScope`, `HeroLabel`, `HeroSurface` (demo).

#### TextArea → `HeroTextArea`
- **Docs:** https://heroui.com/en/docs/react/components/text-area · **Category:** Forms
- **Anatomy:** single multiline primitive; standalone or child of `HeroTextField` (variant inherited from TextField scope).
- **Variants:** `variant: primary* | secondary`; `fullWidth: false*`.
- **Key styles:** identical to Input (radius 12, padding 12/8, bg `field`, `shadow-field`, 16→14 px text, hover/focus/invalid/disabled/secondary rules and 150 ms transitions) plus `min-height: 38px`. Height = `rows × lineHeight + 16` (rows not set by source → native default **2 rows**; docs table claims default 3). Native textarea shows a resize grip (resize both) unless styled; demos use `resize: vertical`/`resize-none`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `rows` | `number` | `rows: int` (fixed visible lines; scrolls beyond) |
  | `cols` | `number` | `cols: int?` (width ≈ cols × avg char width + 24) |
  | `value` / `defaultValue` | `string` | `value` / `defaultValue` / `controller` |
  | `onChange` | `(ChangeEvent) => void` | `onChanged: ValueChanged<String>?` |
  | `placeholder` | `string` | `placeholder: String?` |
  | `disabled` / `readOnly` / `required` | `boolean` | `isDisabled` / `isReadOnly` / `isRequired` |
  | `name` | `string` | `name: String?` |
  | `autoComplete` | `string` | `autofillHints` |
  | `maxLength` / `minLength` | `number` | `maxLength` / `minLength` |
  | `wrap` | `'soft' \| 'hard'` | — (no equivalent; Flutter always soft-wraps) |
  | `fullWidth` | `boolean` | `fullWidth: bool` |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant?` |
  | `style={{resize}}` (demos) | CSS | `resize: HeroTextAreaResize {none*, vertical}` (drag grip bottom-end) |
  | `aria-label` | `string` | `semanticLabel` |
  | (Flutter extras) | – | `height`, `focusNode`, `style: HeroFieldStyle?` |

  Form: same as Input (own `FormField<String>` when standalone with name/validator).
- **States & behaviour:** as Input; Enter inserts newline. Semantics: `textField: true, multiline: true`.
- **Docs examples:**
  1. `textarea-basic` — 384×128 textarea "Share a quick project update...".
  2. `textarea-variants` — primary & secondary full-width in 280 px column.
  3. `textarea-on-surface` — secondary textarea (min-w 280) in Surface (radius 24, p 24).
  4. `textarea-full-width` — full width in 400 px box.
  5. `textarea-controlled` — announcement textarea + Description "Characters: n / 280".
  6. `textarea-rows` — "Short feedback" rows 3 and "Detailed notes" rows 6 with vertical resize, labels gap 8.
  7. `text-area-custom-styles` — h-28 max-w-xs note field: radius 12, 1 px border/80, `surface` bg, shadow-sm, 1 px black/5 ring, focus ring neutral-400/25.
- **Depends on:** same as Input.

#### TextField → `HeroTextField`
- **Docs:** https://heroui.com/en/docs/react/components/text-field · **Category:** Forms
- **Anatomy:** `HeroTextField` + `HeroLabel` + (`HeroInput` | `HeroTextArea` | `HeroInputGroup`) + `HeroDescription` + `HeroFieldError`. Compound via `children`; convenience slots `label`, `placeholder`, `description`, `errorMessage`, `isMultiline` (+ `rows`) build the standard layout.
- **Variants:** `variant: primary* | secondary` (passed to child Input/TextArea/InputGroup via scope; not in docs API table but in source & on-surface demo); `fullWidth: false*` (also forces child input/textarea full width).
- **Key styles:** column, gap 4 px, cross-axis start. When invalid: `HeroDescription` children are hidden. `fullWidth` → root and `[data-slot=input|textarea]` children `w-full`. No other visuals (children style themselves).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode \| (TextFieldRenderProps) => ReactNode` | `children: List<Widget>` or `builder: (ctx, HeroTextFieldState)` (state: isDisabled, isInvalid, isReadOnly, isRequired, isFocusWithin, isFocusVisible) |
  | `fullWidth` | `boolean` | `fullWidth: bool` |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant` |
  | `type` (demos) | `text/email/password/number/url/tel` | `type: HeroInputType` |
  | `isRequired` | `boolean` | `isRequired: bool` |
  | `isInvalid` | `boolean` | `isInvalid: bool?` |
  | `validate` | `(string) => ValidationError \| true \| null` | `validator: FormFieldValidator<String>?` |
  | `validationBehavior` | `'native' \| 'aria'` | `validationBehavior: HeroValidationBehavior?` (null → inherit HeroForm → native) |
  | `validationErrors` | `string[]` | `validationErrors: List<String>?` |
  | `value` / `defaultValue` | `string` | `value: String?` / `defaultValue: String?` / `controller` |
  | `onChange` | `(string) => void` | `onChanged: ValueChanged<String>?` |
  | `isDisabled` / `isReadOnly` | `boolean` | `isDisabled` / `isReadOnly` |
  | `name` | `string` | `name: String?` |
  | `autoFocus` | `boolean` | `autofocus: bool` |
  | `minLength`/`maxLength`/`pattern` (RAC) | – | `minLength` / `maxLength` / `pattern` |
  | `aria-label` / `aria-describedby` … | `string` | `semanticLabel` / (auto from Description) |
  | `id`, `style`, `className`, `render` | – | — |
  | (Flutter) | – | `focusNode`, `onSaved`, `autovalidateMode`, `label`, `placeholder`, `description`, `errorMessage` |

  Form: `FormField<String>`; validator result feeds `HeroFieldError`; `onSaved` receives text; `name` → HeroForm data map.
- **States & behaviour:** exposes disabled, invalid, read-only, required, focus-within, focus-visible to children. Required → label asterisk. Invalid → description hidden, input invalid ring, label text `danger` (`[data-invalid] .label`). Disabled → label & input at .5 opacity, description unchanged (no disabled rule for Description here). Semantics: one text field node labelled by Label, hint = description/error.
- **Docs examples:**
  1. `textfield-basic` — Email field (max-w-64), placeholder "Enter your email".
  2. `textfield-on-surface` — Surface (radius 24, p 24, min-w 340) with 3 secondary fields: name+description, email, bio textarea rows 4 + "Minimum 4 rows".
  3. `textfield-with-description` — Username + "Choose a unique username for your account".
  4. `textfield-required` — Full Name required (asterisk) + "This field is required".
  5. `textfield-disabled` — disabled "Account ID" with value "USR-12345" + description.
  6. `textfield-full-width` — 400 px: full-width name; full-width invalid required password with FieldError.
  7. `textfield-validation` — username (<3 chars) & bio textarea (<20 chars) swap Description ↔ FieldError live.
  8. `textfield-controlled` — Display name + bio textarea with live character counters.
  9. `textfield-with-error` — always-invalid email with FieldError "Please enter a valid email address".
  10. `textfield-textarea` — Message textarea rows 4 + "Maximum 500 characters".
  11. `textfield-input-types` — password, number (0–150), email, url, tel fields.
  12. `textfield-render-function` — same as basic (render override).
  13. `text-field-custom-styles` — gap 6, custom input (radius 12, border/80, surface bg, shadow-sm, ring black/5).
- **Depends on:** `HeroLabel`, `HeroInput`, `HeroTextArea`, `HeroDescription`, `HeroFieldError`, `HeroInputGroup`, `HeroForm`, `HeroSurface` (demo).

#### InputGroup → `HeroInputGroup`
- **Docs:** https://heroui.com/en/docs/react/components/input-group · **Category:** Forms
- **Anatomy:** `HeroInputGroup` + `HeroInputGroupPrefix` + (`HeroInputGroupInput` | `HeroInputGroupTextArea`) + `HeroInputGroupSuffix`; normally inside `HeroTextField` (with Label/Description/FieldError siblings). Convenience: `HeroInputGroup(startContent:, endContent:, child: HeroInputGroupInput(...))`.
- **Variants:** `variant: primary* | secondary` (inherits TextField scope); `fullWidth: false*`.
- **Key styles:**
  - Group: inline row, `min-h-9` (36 px), items centred, radius 12, bg `field`, text 14 px `field-foreground`, `shadow-field`, border `field-border-width`/`field-border`. With a TextArea: items top-aligned, height auto.
  - Hover (not focus-within): bg `field-hover`, border `field-border-hover`. Focus (inner input focused): `status-focused-field`, border `field-border-focus`, bg `field-focus`. Invalid (from TextField): `status-invalid-field`, bg `field-focus`. Disabled: `status-disabled`. Transitions: bg/border 150 ms `ease`, ring 150 ms `Cubic(0,0,.2,1)`.
  - Input/TextArea: flex 1, radius 0, no border, transparent bg, padding 12 h / 8 v, 16→14 px text, placeholder `field-placeholder`. With prefix → start padding 0; with suffix → end padding 0. TextArea: min-height 38 px, vertical resize.
  - Prefix/Suffix: full height, centred, horizontal padding 12, transparent, text `field-placeholder` (muted); prefix start radius 12 / suffix end radius 12; divider border on the inner side with `field-border-width` (0 → invisible). With TextArea: top-aligned, padding-top 8. Transitions bg/border 150 ms `ease`.
  - `secondary`: no shadow, bg `default`, hover `default-hover`, focus `default`; inner inputs transparent.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode \| (GroupRenderProps) => ReactNode` | `children: List<Widget>` / `builder` (state: isHovered, isFocusWithin, isFocusVisible, isDisabled, isInvalid) |
  | `fullWidth` | `boolean` | `fullWidth: bool` |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant?` |
  | `role` | `'group' \| 'region' \| 'presentation'` | `semanticsRole` (container / none) |
  | `aria-label` … | `string` | `semanticLabel` |
  | Input: `type`,`value`,`defaultValue`,`placeholder`,`disabled`,`readOnly`,`variant` | as Input | `HeroInputGroupInput(type, value, defaultValue, controller, focusNode, placeholder, isDisabled, isReadOnly, onChanged)` (docs list `variant` on Input but source ignores it) |
  | TextArea: + `rows` | `number` | `HeroInputGroupTextArea(rows, resize, …)` |
  | Prefix / Suffix `children` | `ReactNode` | `HeroInputGroupPrefix(child)` / `HeroInputGroupSuffix(child)` + `padding: EdgeInsetsDirectional?` (demos use `pe-0`, `pe-2`, `px-3 py-0`) |
  | (Flutter, for with-textarea demo) | – | `direction: Axis` (default horizontal; vertical = stacked prefix/textarea/suffix), `gap`, `borderRadius`, `padding` overrides |

  Form: the enclosing `HeroTextField` owns `FormField<String>`; the group inherits invalid/disabled/required.
- **States & behaviour:** tapping anywhere on the group (prefix/suffix not being interactive children) focuses the input. Hover/focus-within/invalid/disabled as above. Semantics: `container: true` group; input is the text field node.
- **Docs examples:**
  1. `input-group-default` — email with envelope icon prefix (16 px muted icon).
  2. `input-group-variants` — primary and secondary groups with envelope prefix (w 280).
  3. `input-group-on-surface` — secondary group + description inside Surface (radius 16, p 24).
  4. `input-group-with-loading-suffix` — "Sending..." value with 16 px Spinner suffix.
  5. `input-group-required` — required email; required "$ … USD" price with description.
  6. `input-group-disabled` — disabled email (value) and disabled "$ 10 USD".
  7. `input-group-full-width` — 400 px: envelope+email; password with eye icon suffix.
  8. `input-group-with-text-prefix` — "https://" prefix, value "heroui.com".
  9. `input-group-with-text-suffix` — value "heroui", ".com" suffix.
  10. `input-group-with-icon-prefix-and-text-suffix` — globe icon + ".com".
  11. `input-group-with-copy-suffix` — suffix (pe-0) with ghost sm icon-only Copy button.
  12. `input-group-with-icon-prefix-and-copy-suffix` — globe prefix + copy button.
  13. `input-group-password-with-toggle` — ghost sm eye/eye-slash button toggles obscure text.
  14. `input-group-with-keyboard-shortcut` — suffix (pe-2) Kbd "⌘ K".
  15. `input-group-with-badge-suffix` — suffix (pe-2) accent soft md Chip "Pro".
  16. `input-group-invalid` — invalid required email + invalid "$ … USD" with FieldErrors.
  17. `input-group-with-prefix-icon` — envelope prefix + description.
  18. `input-group-with-suffix-icon` — envelope suffix + "We don't send spam".
  19. `input-group-with-prefix-and-suffix` — "$" / number input / "USD" + description.
  20. `input-group-with-textarea` — AI prompt box: vertical group, radius 24, py 8, gap 8; prefix outline sm "Add Context" button; textarea rows 5 no-resize; suffix row with tertiary icon buttons (+, plug) and ghost mic + primary send (pending spinner), each with Tooltip (delay 0).
  21. `input-group-custom-styles` — "Work email": radius 12, 1 px border/80, `default` bg, shadow-sm.
  - Code-only: *Usage Example* (envelope + ghost confirm button), *TextArea Usage Example* (feedback with 500-char counter + FieldError).
- **Depends on:** `HeroTextField`, `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroButton`, `HeroChip`, `HeroKbd`, `HeroSpinner`, `HeroTooltip`, `HeroSurface`, icon set (gravity-ui: Envelope, Eye, EyeSlash, Globe, Copy, At, Plus, PlugConnection, Microphone, ArrowUp).

#### SearchField → `HeroSearchField`
- **Docs:** https://heroui.com/en/docs/react/components/search-field · **Category:** Forms
- **Anatomy:** `HeroSearchField` + `HeroLabel` + `HeroSearchFieldGroup` (`HeroSearchFieldSearchIcon`, `HeroSearchFieldInput`, `HeroSearchFieldClearButton`) + `HeroDescription` + `HeroFieldError`. Convenience: `label`, `placeholder`, `description`, `errorMessage`, `searchIcon`, `clearIcon`, `showClearButton: true`.
- **Variants:** `variant: primary* | secondary`; `fullWidth: false*` (root and group `w-full`).
- **Key styles:**
  - Root: column gap 4; label `w-fit`; description hidden when invalid; when empty the clear button is `opacity 0` + non-interactive (still occupies space).
  - Group: `h-9` (36 px) row, centred, clip, radius 12, bg `field`, 14 px `field-foreground`, `shadow-field`, border field width/colour. Hover (not focus-within): bg `field-hover`, border `field-border-hover`. Focus-within: `status-focused-field` only (no bg/border change, unlike Input). Invalid: `status-invalid-field`, bg `field-focus`. Disabled `.5`. Transitions bg/border 150 ms `ease`, ring 150 ms `Cubic(0,0,.2,1)`.
  - Search icon: 16 px, start margin 12, end 0, colour `field-placeholder`, non-interactive. Default glyph = 16×16 magnifier path `M11.5 7a4.5 4.5 0 1 1-9 0…`.
  - Input: flex 1, transparent, padding 12 h / 8 v, 16→14 px; with icon → start padding 8; with clear button → end padding 8. Native search decorations hidden.
  - Clear button: `HeroCloseButton` at 20×20 (overrides 24), end margin 8, icon 12 px (overrides 16); close-button default look: bg `default`, icon `muted`, radius 12 (circle), padding 4, hover `default-hover`, pressed scale .93 (transform 250 ms ease-out-quart, colour 150 ms, bg 100 ms), focus-visible `status-focused`.
  - `secondary`: group no shadow, bg `default`, hover `default-hover`, focus `default`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode \| (SearchFieldRenderProps) => ReactNode` | `children` / `builder` (state: + `value`, `isEmpty`) |
  | `fullWidth` | `boolean` | `fullWidth: bool` |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant` |
  | `value` / `defaultValue` | `string` | `value` / `defaultValue` / `controller` |
  | `onChange` | `(string) => void` | `onChanged: ValueChanged<String>?` |
  | `isRequired`, `isInvalid`, `validate`, `validationBehavior`, `validationErrors` | – | as §0 (`FormField<String>`) |
  | `isDisabled` / `isReadOnly` | `boolean` | `isDisabled` / `isReadOnly` |
  | `name` / `autoFocus` | – | `name` / `autofocus` |
  | `onSubmit` | `(string) => void` | `onSubmitted: ValueChanged<String>?` |
  | `onClear` | `() => void` | `onClear: VoidCallback?` |
  | `aria-*` | `string` | `semanticLabel` |
  | Group `children`/`className` | – | `HeroSearchFieldGroup(children)` |
  | Input `placeholder`, `variant`, `type` | – | `HeroSearchFieldInput(placeholder, width, focusNode, controller)` (`type` fixed = search) |
  | SearchIcon `children` | `ReactNode` (default magnifier) | `HeroSearchFieldSearchIcon(child: Widget?)` |
  | ClearButton `children` | `ReactNode` (default ✕) | `HeroSearchFieldClearButton(child: Widget?)` |
- **States & behaviour:** Enter → `onSubmitted(value)`; Escape → clears value, fires `onChanged('')` + `onClear` (no-op if already empty); clear button press → same as Escape then refocus input; clear button is excluded from focus traversal and disabled when field disabled/read-only. Keyboard shortcut demo: app-level `Shift+S` focuses the input, `Esc` blurs (gallery wires a `Shortcuts`/`CallbackShortcuts` around the demo). Semantics: `textField: true` with search `textInputAction`, clear button `button: true, label: "Clear search"`.
- **Docs examples:**
  1. `search-field-basic` — Label "Search", icon, 280 px input, clear button.
  2. `search-field-variants` — primary and secondary.
  3. `search-field-on-surface` — two secondary fields + descriptions in Surface (radius 24, p 24).
  4. `search-field-with-description` — products/users fields with descriptions.
  5. `search-field-required` — two required fields (one with description).
  6. `search-field-disabled` — disabled with value "Disabled search" and disabled empty.
  7. `search-field-full-width` — full width in 400 px.
  8. `search-field-validation` — invalid required value "ab" + error; invalid "invalid@query" + error.
  9. `search-field-controlled` — value echoed in Description; tertiary buttons "Clear" / "Set example".
  10. `search-field-form-example` — Form: required, invalid when 1–2 chars (error vs description swap), full-width primary submit button disabled <3 chars, pending "Searching..." with spinner 1.5 s.
  11. `search-field-with-validation` — live min-3 validation with Description↔FieldError.
  12. `search-field-custom-icons` — custom funnel search icon and filled circle-x clear icon.
  13. `search-field-with-keyboard-shortcut` — Shift+S focuses, Esc blurs; hint row with Kbd "⇧ S".
  14. `search-field-render-function` — same as basic.
  15. `search-field-custom-styles` — secondary, max-w-64, group radius 12 `default` bg, muted icon/clear, muted placeholder.
- **Depends on:** `HeroCloseButton`, `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSpinner`, `HeroKbd`, `HeroSurface`, icons (search, close).

#### NumberField → `HeroNumberField`
- **Docs:** https://heroui.com/en/docs/react/components/number-field · **Category:** Forms
- **Anatomy:** `HeroNumberField` + `HeroLabel` + `HeroNumberFieldGroup` (`HeroNumberFieldDecrementButton`, `HeroNumberFieldInput`, `HeroNumberFieldIncrementButton`) + `HeroDescription` + `HeroFieldError`. Convenience: `label`, `description`, `errorMessage`, `showStepper: true`.
- **Variants:** `variant: primary* | secondary`; `fullWidth: false*` (root + group `w-full`).
- **Key styles:**
  - Root: column gap 4, label `w-fit`, description hidden when invalid.
  - Group: grid, `h-9` (36 px), centred, clip, radius 12, bg `field`, 14 px `field-foreground`, `shadow-field`, border field width/colour. Columns: `1fr` / `40px 1fr` (decrement only) / `1fr 40px` (increment only) / `40px 1fr 40px`. Hover (not focus-within): `field-hover` + `field-border-hover`. Focus-within (input **or** button): `status-focused-field`, border `field-border-focus`, bg `field-focus`. Invalid: `status-invalid-field`, bg `field-focus`. Disabled `.5`. Transitions as Input.
  - Input: `min-w-0`, transparent, padding 12 h / 8 v, 16→14 px, **tabular figures**, start-aligned text; inner radius removed on sides with buttons.
  - Buttons: 40 px wide × full height, centred 16 px icon (`IconMinus` / `IconPlus`, 16-unit paths), colour `field-foreground`, transparent, cursor pointer. Decrement: start radius 12 + **1 px end divider** `field-placeholder` @15 % alpha; Increment: end radius 12 + 1 px start divider same colour. Pressed: bg `field-foreground` @10 %, scale .97. Disabled (at min/max or field disabled): `.5`. Transitions bg/border 150 ms `ease`.
  - `secondary`: group no shadow, bg `default`, hover `default-hover`, focus `default`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode \| (NumberFieldRenderProps) => ReactNode` | `children` / `builder` (state: + value, minValue, maxValue, step) |
  | `fullWidth` / `variant` | – | `fullWidth` / `variant: HeroFieldVariant` |
  | `value` / `defaultValue` | `number` | `value: double?` / `defaultValue: double?` |
  | `onChange` | `(number \| undefined) => void` | `onChanged: ValueChanged<double?>?` (fires on commit, not per keystroke) |
  | `formatOptions` | `Intl.NumberFormatOptions` | `formatOptions: HeroNumberFormatOptions?` {style: decimal/currency/percent/unit, currency, currencySign: standard/accounting, minimum/maximumFractionDigits, unit, unitDisplay} — shared with Slider |
  | `locale` | `string` | `locale: String?` (else `Localizations.localeOf`) |
  | `minValue` / `maxValue` / `step` | `number` | `minValue` / `maxValue` / `step` (default 1; **0.01 when style = percent**) |
  | `isRequired`, `isInvalid`, `validate`, `validationBehavior`, `validationErrors` | – | as §0 (`FormField<double?>`) |
  | `isDisabled` / `isReadOnly` | `boolean` | `isDisabled` / `isReadOnly` |
  | `name` / `autoFocus` | – | `name` / `autofocus` |
  | `aria-*` | – | `semanticLabel` |
  | Input `variant`/`className` | – | `HeroNumberFieldInput(width, textAlign, focusNode)` |
  | Increment/Decrement `children` | `ReactNode` (plus / minus icon) | `HeroNumberFieldIncrementButton(child)` / `…DecrementButton(child)` + `width`, `height`, `padding` (chevrons demo: 24 px wide, half height) |
- **States & behaviour:** typing restricted to characters valid for the locale/format; commit on blur or Enter: parse → clamp to [min,max] → snap to step (when step set) → reformat (e.g. `0.5` + percent → "50%", EUR accounting → "€99.00", negatives "(€99.00)", unit kilogram short → "1,000 kg"). ArrowUp/ArrowDown ±step, Home/End → min/max, mouse wheel while focused steps. Increment from empty → `minValue ?? 0`, decrement from empty → `maxValue ?? 0`. Press-and-hold on a button auto-repeats (first step immediately, repeat after 400 ms every 60 ms). Buttons excluded from focus traversal; increment disabled when value ≥ max, decrement when ≤ min. Controlled value outside range (validation demo) is displayed as-is. Semantics: text field with `value`, `increasedValue`/`decreasedValue`, `onIncrease`/`onDecrease` (spinbutton); buttons labelled "Increase"/"Decrease".
- **Docs examples:**
  1. `number-field-basic` — "Width" 1024, min 0, 120 px input with −/+.
  2. `number-field-variants` — primary and secondary (100).
  3. `number-field-on-surface` — secondary width + percent fields in Surface (radius 24, p 24, max 280).
  4. `number-field-with-description` — width (px) and percent (0–1, step .1) with descriptions.
  5. `number-field-required` — required empty quantity; required rating 1–10.
  6. `number-field-disabled` — disabled width and percent.
  7. `number-field-full-width` — full width in 400 px.
  8. `number-field-validation` — invalid value −5 (min 0) and 150 % (max 1) with errors.
  9. `number-field-controlled` — 1024 echoed; tertiary buttons "Reset to 0" / "Set to 2048".
  10. `number-field-with-step` — steps 1, 5, 10 (0–100).
  11. `number-field-with-format-options` — EUR accounting 99; USD 99.99; percent 0.5 step .01; decimal 2 dp 1234.56; unit kilogram 1000.
  12. `number-field-form-example` — Form: order quantity 1–5, invalid when > 3 ("Only 3 items left in stock"), submit disabled/pending "Processing...".
  13. `number-field-with-validation` — percent field invalid outside 0–100.
  14. `number-field-custom-icons` — zoom-out / zoom-in magnifier icons.
  15. `number-field-with-chevrons` — EUR field, group as flex; input flex 1; right column (1 px start divider @15 %) with 24 px-wide stacked chevron-up/down buttons (11 px icons).
  16. `number-field-render-function` — same as basic.
  17. `number-field-custom-styles` — "Guests" min 1, secondary, max-w-48, group radius 12 `default`, muted buttons → foreground on hover, centred tabular text.
- **Depends on:** `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSpinner`, `HeroSurface`, icons (plus, minus, chevrons), `intl` number formatting (+ custom accounting/unit handling), shared `HeroNumberFormatOptions`.

#### InputOTP → `HeroInputOTP`
- **Docs:** https://heroui.com/en/docs/react/components/input-otp · **Category:** Forms
- **Anatomy:** `HeroInputOTP(maxLength)` containing `HeroInputOTPGroup`(s) of `HeroInputOTPSlot(index)` separated by `HeroInputOTPSeparator`. One hidden `EditableText` spans the container; slots only render state. Convenience: `HeroInputOTP(maxLength: 6, groupSizes: [3, 3])` auto-builds groups + separators.
- **Variants:** `variant: primary* | secondary`; booleans `isDisabled`, `isInvalid`.
- **Key styles:**
  - Root: row, full width, gap 8, centred.
  - Group: row, gap 8, `min-w-0`.
  - Slot: 40 px tall, base width 38 px but **flex 1** (slots grow to share available width), `min-w-0`, radius 12, bg `field`, `shadow-field`, text 14 px w600 `field-foreground`, border field width/colour. Hover: bg `field-hover`, border `field-border-hover`. Active (caret slot): z-raised, bg `field-focus`, `status-focused-field`. Filled: bg `field-focus`. Invalid: `status-invalid-field` (1 px danger outline), bg `field-focus`. Disabled: `status-disabled`. Transitions bg/border 150 ms `ease`, ring 150 ms `Cubic(0,0,.2,1)`.
  - Slot value: 18 px, line-height 24, letter-spacing −0.27 px; enter animation 250 ms `ease`: opacity 0→1, translateY 8→0, scale .8→1, origin bottom-centre.
  - Fake caret (active & empty slot): 2×16 px, radius 4, colour `field-placeholder`, blink 1.2 s `ease-out` infinite (opacity 1 at 0 %/70 %/100 %, 0 at 20–50 %).
  - Separator: 6×2 px, radius 4, colour `separator`, no shrink.
  - `secondary`: slots no shadow, bg `default`, hover `default-hover`, active/filled `default`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `maxLength` | `number` (required) | `maxLength: int` (required) |
  | `value` / (uncontrolled) | `string` | `value: String?` / `defaultValue: String?` / `controller` |
  | `onChange` | `(string) => void` | `onChanged: ValueChanged<String>?` |
  | `onComplete` | `(string) => void` | `onCompleted: ValueChanged<String>?` (value.length == maxLength) |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant` |
  | `children` | Group/Slot/Separator | `children: List<Widget>` / `groupSizes: List<int>?` |
  | `isDisabled` / `isInvalid` | `boolean` | `isDisabled` / `isInvalid` |
  | `validationErrors` / `validationDetails` | `string[]` / `ValidityState` | `validationErrors: List<String>?` (feeds child `HeroFieldError`) / — |
  | `pattern` | `string` | `pattern: String?` + constants `HeroInputOTP.regexpOnlyDigits = r'^\d+$'`, `regexpOnlyChars = r'^[a-zA-Z]+$'`, `regexpOnlyDigitsAndChars = r'^[a-zA-Z0-9]+$'` |
  | `textAlign` | `left/center/right` | `textAlign: TextAlign` (hidden-input caret placement; no visual) |
  | `inputMode` | `'numeric'`* … | `keyboardType: TextInputType` (default number) |
  | `placeholder` | `string` | `placeholder: String?` (per-slot placeholder char) |
  | `pasteTransformer` | `(string) => string` | `pasteTransformer: String Function(String)?` |
  | `name` / `autoFocus` | – | `name` / `autofocus` |
  | `className` / `containerClassName` | – | — |
  | Slot `index` | `number` | `HeroInputOTPSlot(index: int)` + `style` override (custom-styles demo) |
  | Separator | – | `HeroInputOTPSeparator(color?)` |

  Form: `FormField<String>` (validator, onSaved, name); `isInvalid` + `validationErrors` drive a sibling/child `HeroFieldError`.
- **States & behaviour:** characters not matching `pattern` rejected; typing advances; Backspace removes the previous char; ArrowLeft/Right move the active slot; paste fills from the start (after `pasteTransformer`); tapping focuses (caret at first empty slot, last slot when full); `autofillHints: [AutofillHints.oneTimeCode]`. `onCompleted` when full. Disabled: non-focusable, slots .5. Semantics: single `textField` labelled by the external Label, value = entered code, `maxValueLength = maxLength`.
- **Docs examples:**
  1. `input-otp-basic` — "Verify account" label + muted "We've sent a code to a****@gmail.com"; 3+3 slots with separator; "Didn't receive a code? Resend" link row.
  2. `input-otp-variants` — primary and secondary 6-slot inputs.
  3. `input-otp-on-surface` — basic layout, secondary, inside Surface (radius 24, p 24).
  4. `input-otp-disabled` — disabled label + description + disabled OTP.
  5. `input-otp-four-digits` — "Enter PIN", single group of 4.
  6. `input-otp-controlled` — Description shows "Value: x (n/6) • Clear" link-button, else "Enter a 6-digit code".
  7. `input-otp-on-complete` — Form; "Verify Code" primary button enabled only when complete; pending 2 s.
  8. `input-otp-form-example` — 2FA form: error "Please enter all 6 digits" / "Invalid code. Please try again." (styled as field-error), verify button pending, "Having trouble? Use backup code".
  9. `input-otp-with-pattern` — letters only (`REGEXP_ONLY_CHARS`).
  10. `input-otp-with-validation` — hint "The code is 123456"; submit validates, invalid state + field-error text; button disabled until 6 chars.
  11. `input-otp-custom-styles` — slots radius 8, border/80, `default` bg, active: accent/40 border + `accent-soft` bg; separator `border` colour; "Resend code" link.
- **Depends on:** `HeroLabel`, `HeroDescription`, `HeroFieldError` styling, `HeroForm`, `HeroButton`, `HeroSpinner`, `HeroLink`, `HeroSurface`.

#### Checkbox → `HeroCheckbox`
- **Docs:** https://heroui.com/en/docs/react/components/checkbox · **Category:** Forms
- **Anatomy:** `HeroCheckbox` (field root) → `HeroCheckboxContent` (the pressable row: control + label text) → `HeroCheckboxControl` → `HeroCheckboxIndicator`; `HeroDescription` / `HeroFieldError` are siblings of Content. Convenience: `HeroCheckbox(label: Widget?, description:, errorMessage:)` builds the default tree.
- **Variants:** `variant: primary* | secondary` (inherits `HeroCheckboxGroup` variant); booleans `isSelected`, `isIndeterminate`, `isDisabled`, `isInvalid`, `isReadOnly`, `isRequired`.
- **Key styles:**
  - Root: column, start-aligned, gap 4, cursor pointer. Description/FieldError children: start padding 28, 12 px `muted`, wrap, non-selectable (FieldError here is **muted**, not danger). Disabled: root `.5` and description/error another `.5`.
  - Content: inline row, centred, **gap 12**, text 14 px w500 `foreground`, non-selectable.
  - Control: 16×16, radius 6 (`rounded-md`), clip, bg `field`, `shadow-field`, border field width/colour. Inner accent fill layer (`::before`): same radius, colour `accent`, scale .7 & opacity 0 → selected: scale 1, opacity 1. Transitions: control bg 200 ms / border 200 ms `Cubic(0,0,.2,1)`, transform 100 ms; fill scale 100 ms linear, opacity 200 ms linear, colour 200 ms `Cubic(0,0,.2,1)`.
  - Hover (anywhere on root/content): border `field-border-hover`, fill colour `accent-hover` (visible only when selected).
  - Focus-visible (keyboard): `status-focused` on control (2 px ring + 2 px offset).
  - Selected: border transparent, fill visible, glyph `accent-foreground`. Indeterminate: control bg `accent`, glyph `accent-foreground`; pressed → `accent-hover`.
  - Invalid & unselected: `status-invalid-field` (1 px danger outline). Invalid & selected: bg + fill `danger`, glyph `danger-foreground`. Invalid & indeterminate: bg `danger`, glyph `danger-foreground`.
  - Indicator box: 12×12, above fill. Default checkmark: 10×10 SVG, viewBox 17×18, polyline `1,9 7,14 15,4`, stroke 2.5 px (CSS overrides 2), round caps/joins, `dasharray 22`, `dashoffset 66` (hidden) → `44` (drawn) — i.e. path drawn 0→100 %; draw transition 150 ms linear with 15 ms delay; un-draw 200 ms `Cubic(.4,0,.2,1)`. Indeterminate glyph: 12×12, viewBox 24, horizontal line 3→21 at y 12, stroke 3, round cap.
  - `secondary`: control no shadow, bg `default` when unselected; selected fill `accent`; indeterminate bg `accent`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `isSelected` / `defaultSelected` | `boolean` | `isSelected: bool?` / `defaultSelected: bool` |
  | `onChange` | `(boolean) => void` | `onChanged: ValueChanged<bool>?` |
  | `isIndeterminate` | `boolean` | `isIndeterminate: bool` |
  | `isDisabled` / `isInvalid` / `isReadOnly` / `isRequired` | `boolean` | same names |
  | `validate` / `validationBehavior` | – | `validator: FormFieldValidator<bool>?` / `validationBehavior` |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant?` |
  | `name` | `string` | `name: String?` |
  | `value` | `string` | `value: Object?` (form value when selected; group membership id) |
  | `children` | `ReactNode \| (CheckboxFieldRenderProps) => ReactNode` | `children` / `builder: (ctx, HeroCheckboxState)` (isSelected, isIndeterminate, isDisabled, isReadOnly, isInvalid, isRequired) |
  | `aria-label` | `string` | `semanticLabel` (for label-less checkbox) |
  | `render` | – | — |
  | Content `children` / `className` fn | `ReactNode \| (CheckboxButtonRenderProps)` | `HeroCheckboxContent(children / builder: (ctx, HeroToggleButtonState))` (isHovered, isPressed, isFocusVisible, isSelected, isDisabled) + `padding`, `decoration` overrides |
  | Control `className` | – | `HeroCheckboxControl(size: 16, borderRadius, color, selectedColor)` (full-rounded demo 12/16/20/24 px circles) |
  | Indicator `children` | `ReactNode \| (CheckboxFieldRenderProps) => ReactNode` | `HeroCheckboxIndicator(child / builder, size, color)` |

  Form: `FormField<bool>`; required → must be `true`; form value = `value ?? 'on'` when selected; inside `HeroCheckboxGroup` it is not its own FormField (group owns it).
- **States & behaviour:** tap/click anywhere on Content (or root) toggles; Space toggles when focused; read-only ignores input; indeterminate is presentation-only (toggling clears it via `onChanged`). Pressed has no visual beyond hover. Focus ring only on keyboard focus. Semantics: `checked: isSelected`, `mixed: isIndeterminate`, `enabled`, label = content text / `semanticLabel`, hint = description/error.
- **Docs examples:**
  1. `checkbox-basic` — "Accept terms and conditions".
  2. `checkbox-variants` — primary/secondary each with caption + description.
  3. `checkbox-full-rounded` — circular controls 12 (checkmark 8), 16, 20, 24 (checkmark 16) px with labels Small/Default/Large/Extra large.
  4. `checkbox-disabled` — "Premium Feature" + description.
  5. `checkbox-external-label` — label-less checkbox + separate `Label` (gap 12) that toggles it.
  6. `checkbox-with-description` — "Email notifications" + description.
  7. `checkbox-default-selected` — "Enable email notifications" pre-checked.
  8. `checkbox-invalid` — invalid required "I agree to the terms" + FieldError (muted).
  9. `checkbox-controlled` — "Email notifications" + "Status: Enabled/Disabled".
  10. `checkbox-indeterminate` — "Select all" starts indeterminate, first toggle clears it.
  11. `checkbox-form` — native form with 3 checkboxes (newsletter default on) + sm primary Submit alerting name/value pairs.
  12. `checkbox-render-props` — label & description text depend on `isSelected`.
  13. `checkbox-render-function` — same as basic.
  14. `checkbox-custom-indicator` — heart (filled), plus, and indeterminate-line custom indicators.
  15. `checkbox-custom-styles` — control bg `success-soft`, fill `success`, checkmark `success-foreground`.
- **Depends on:** `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, focus-ring painter, path-draw animation helper.

#### CheckboxGroup → `HeroCheckboxGroup`
- **Docs:** https://heroui.com/en/docs/react/components/checkbox-group · **Category:** Forms
- **Anatomy:** `HeroCheckboxGroup` + `HeroLabel` + optional `HeroDescription` + `HeroCheckbox(value: …)` items + optional `HeroFieldError`. Convenience: `label`, `description`, `errorMessage`.
- **Variants:** `variant: primary* | secondary` (in source/demos, not in docs API table; propagated to child checkboxes).
- **Key styles:** column, no gap; every child `HeroCheckbox` gets **top margin 16** (so first item is 16 px below the label/description; Label and Description touch). Group label gets the required asterisk; disabled → label `.5` (group itself has no opacity; items dim themselves).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `value` / `defaultValue` | `string[]` | `value: Set<Object>?` / `defaultValue: Set<Object>` |
  | `onChange` | `(string[]) => void` | `onChanged: ValueChanged<Set<Object>>?` |
  | `isDisabled` / `isRequired` / `isReadOnly` / `isInvalid` | `boolean` | same names (propagate to items) |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant` |
  | `name` | `string` | `name: String?` (form value = list of selected values) |
  | `children` | `ReactNode \| (CheckboxGroupRenderProps) => ReactNode` | `children` / `builder: (ctx, HeroCheckboxGroupState)` (value, isDisabled, isReadOnly, isInvalid, isRequired) |
  | `validate` / `validationBehavior` / `validationErrors` (RAC) | – | as §0 |
  | `render` | – | — |

  Form: `FormField<Set<Object>>`; required → at least one selected.
- **States & behaviour:** each child toggles membership of its `value`; group invalid → every item invalid styling; Tab moves through each checkbox (no roving). Semantics: `container` with label (role group), items as checkboxes.
- **Docs examples:**
  1. `checkbox-group-basic` — "Select your interests" + description; Coding/Design/Writing each with description.
  2. `checkbox-group-on-surface` — same, `secondary`, in Surface (radius 24, p 24).
  3. `checkbox-group-disabled` — disabled "Features" with two described items.
  4. `checkbox-group-indeterminate` — "Select all" checkbox (indeterminate when partial) above a 24 px-indented controlled group.
  5. `checkbox-group-controlled` — ["coding","design"] with "Selected: …" caption.
  6. `checkbox-group-validation` — Form, required preferences group + FieldError "Please select at least one notification method." + Submit.
  7. `checkbox-group-features-and-addons` — secondary checkbox cards: `surface` bg, radius 24, px 20 py 16, selected bg accent/10; icon + title + description; 20 px circular control top-end (12 px from top, 16 from end).
  8. `checkbox-group-with-custom-indicator` — "×" glyph indicators.
  9. `checkbox-group-render-function` — same as basic.
  10. `checkbox-group-custom-styles` — gap 12, items without top margin, success-coloured controls, default ["email"].
- **Depends on:** `HeroCheckbox`, `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSurface`, icons (Envelope, Comment, Bell).

#### RadioGroup → `HeroRadioGroup` (incl. Radio → `HeroRadio`)
- **Docs:** https://heroui.com/en/docs/react/components/radio-group · **Category:** Forms
- **Anatomy:** `HeroRadioGroup` + `HeroLabel` + `HeroDescription` + `HeroRadio(value)` items + group `HeroFieldError`. Each `HeroRadio` → `HeroRadioContent` (pressable row) → `HeroRadioControl` → `HeroRadioIndicator`; per-radio `HeroDescription`/`HeroFieldError` are siblings of Content. Convenience: `HeroRadio(value:, label:, description:)`, group `label`, `description`, `errorMessage`.
- **Variants:** `variant: primary* | secondary` (group only; Radio has no variant); `orientation: vertical* | horizontal` (Flutter `Axis`).
- **Key styles:**
  - Group: column; vertical → every `HeroRadio` top margin 16; horizontal → row, wrap, gap 16.
  - Radio root: column, start, gap 4, cursor pointer; Description/FieldError start padding 28, 12 px `muted`. Disabled: `.5` (+ description `.5`).
  - Content: inline row, centred, gap 12, 14 px w500 `foreground`.
  - Control: 16×16 circle (radius 8), bg `field`, `shadow-field`, border field width/colour. Transitions bg/border 200 ms `Cubic(0,0,.2,1)`, transform 100 ms. Hover: border `field-border-hover`; unselected hover → indicator colour `field-hover`. Pressed: scale .95. Selected: border transparent, bg `accent`; selected+pressed bg `accent-hover`. Invalid (selected or not): `status-invalid-field`. Focus-visible: `status-focused`.
  - Indicator (default, when no custom child): full-size circle `field` at scale 1 → selected: colour `accent-foreground`, scale 0.4286 (≈ 6.9 px dot; CSS comment says 6 px); selected+pressed scale 0.5714 (≈ 9.1 px). Transitions scale 200 ms, colour 200 ms `Cubic(0,0,.2,1)`.
  - `secondary`: control no shadow, bg `default`; unselected dot `default`, hover `default-hover`.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | RadioGroup `value` / `defaultValue` | `string` | `value: Object?` / `defaultValue: Object?` |
  | `onChange` | `(string) => void` | `onChanged: ValueChanged<Object?>?` |
  | `isDisabled` / `isRequired` / `isReadOnly` / `isInvalid` | `boolean` | same names |
  | `variant` | `"primary" \| "secondary"` | `variant: HeroFieldVariant` |
  | `name` | `string` | `name: String?` |
  | `orientation` | `'horizontal' \| 'vertical'` | `orientation: Axis` (default vertical) |
  | `children` | `ReactNode \| (RadioGroupRenderProps) => ReactNode` | `children` / `builder` |
  | `validate` / `validationBehavior` / `validationErrors` (RAC) | – | as §0 |
  | Radio `value` | `string` | `HeroRadio(value: Object)` |
  | Radio `isDisabled` | `boolean` | `isDisabled` |
  | Radio `name` | `string` | — (group name used) |
  | Radio `children` | `ReactNode \| (RadioFieldRenderProps)` | `children` / `builder: (ctx, HeroRadioState)` |
  | Radio.Content `children`/`className` fn | `(RadioButtonRenderProps)` | `HeroRadioContent(children / builder: (ctx, HeroToggleButtonState))` + `padding`/`decoration` |
  | Radio.Control | span | `HeroRadioControl(size: 16, color, selectedColor)` |
  | Radio.Indicator `children` | `ReactNode \| (RadioButtonRenderProps)` | `HeroRadioIndicator(child / builder, dotScale, color)` |
  | `render` | – | — |

  Form: `FormField<Object?>`; required → a value must be selected.
- **States & behaviour:** single selection; Tab focuses the selected radio (or first) — roving focus; Arrow Up/Left & Down/Right move focus **and** select the previous/next enabled radio (wrapping; RTL flips Left/Right); Space selects focused. Read-only blocks changes. Group invalid → every radio invalid ring. Semantics: group container labelled (radiogroup); each radio `inMutuallyExclusiveGroup: true`, `checked`.
- **Docs examples:**
  1. `radio-group-basic` — "Plan selection" + description; Basic/Premium(default)/Business each with description.
  2. `radio-group-horizontal` — external label; Starter/Pro(default)/Teams in a row.
  3. `radio-group-variants` — primary and secondary groups (Option 1/2).
  4. `radio-group-on-surface` — secondary basic group in Surface (radius 24, p 24).
  5. `radio-group-disabled` — disabled group, Pro selected.
  6. `radio-group-controlled` — "Selected plan: pro" caption.
  7. `radio-group-uncontrolled` — defaultValue + onChange caption "Last chosen plan".
  8. `radio-group-validation` — Form, required group + FieldError "Choose a subscription before continuing." + Submit + result text.
  9. `radio-group-delivery-and-payment` — themed overrides (accent #006FEE, field border width 2 px); card radios (surface bg, radius 12, px 20 py 16, selected border accent + bg accent/10), 20 px control top-end; delivery 3-col grid (md), payment 2-col grid with brand icons (Mastercard, Visa, PayPal).
  10. `radio-group-custom-indicator` — "✓" (12 px, `background` colour) indicator when selected.
  11. `radio-group-render-function` — same as basic.
  12. `radio-group-custom-styles` — "Billing cycle" success-tinted cards (radius 12, px 16 py 12, success-soft states), 20 px controls, dot scale .5 / pressed .57.
- **Depends on:** `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSurface`, theme override scope (demo 9), brand SVG assets.

#### Switch → `HeroSwitch` (incl. SwitchGroup → `HeroSwitchGroup`)
- **Docs:** https://heroui.com/en/docs/react/components/switch · **Category:** Controls
- **Anatomy:** `HeroSwitch` (field root) → `HeroSwitchContent` (pressable row wrapping control + label; label may be before or after the control) → `HeroSwitchControl` (track) → `HeroSwitchThumb` → optional `HeroSwitchIcon`; `HeroDescription`/`HeroFieldError` siblings of Content. `HeroSwitchGroup` lays out several switches. (Docs anatomy snippet shows Control outside Content — demos/source put Control **inside** Content; follow the demos.) Convenience: `HeroSwitch(label:, description:, labelPosition: end*/start)`.
- **Variants:** `size: sm | md* | lg` (`HeroSize`); SwitchGroup `orientation: vertical* | horizontal`.
- **Key styles:**
  - Root: column, start, gap 4, cursor pointer. Description start padding 52 px (sm 44, lg 60); FieldError same padding, 12 px `muted`.
  - Content: inline row, centred, gap 12, 14 px w500 `foreground`.
  - Track sizes: sm 32×16 radius 8; **md 40×20 radius 12**; lg 48×24 radius 12. Clip.
  - Thumb sizes: sm 16.5×12 radius 6; **md 22×16 radius 8**; lg 27.5×20 radius 12. Start margin 2 px (off); on: `margin-start = trackWidth − (thumbWidth + 2)` (sm 13.5, md 16, lg 18.5 px). Off: bg `white`, glyph colour black, `shadow-field`. On: bg `accent-foreground`, glyph `accent`, shadow `0 0 5 0 rgba(0,0,0,.02), 0 2 10 0 rgba(0,0,0,.06), 0 0 1 0 rgba(0,0,0,.3)`. Thumb transitions: margin 300 ms `Cubic(0.32,0.72,0,1)`, bg 200 ms `Cubic(0,0,.2,1)`.
  - Track colours (overridable tokens): off `default`; hover/pressed `default` at 80 % alpha; on `accent`; on+hover/pressed `accent-hover`. Transition bg 250 ms `ease`, ring 150 ms.
  - Focus-visible: `status-focused` on track. Disabled: root `.5`, thumb bg `default-foreground` @20 %; disabled+on thumb opacity .4.
  - Icon: fills thumb, centred (demo icons 12 px, inherit thumb glyph colour).
  - SwitchGroup: root column gap 24; items container gap 16, column (vertical) or row (horizontal).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `size` | `'sm' \| 'md' \| 'lg'` | `size: HeroSize` (default md) |
  | `isSelected` / `defaultSelected` | `boolean` | `isSelected: bool?` / `defaultSelected: bool` |
  | `onChange` | `(boolean) => void` | `onChanged: ValueChanged<bool>?` |
  | `onPress` | `(PressEvent) => void` | `onPressed: VoidCallback?` |
  | `isDisabled` / `isInvalid` / `isReadOnly` / `isRequired` | `boolean` | same names |
  | `validate` / `validationBehavior` | – | `validator: FormFieldValidator<bool>?` / `validationBehavior` |
  | `name` / `value` | `string` | `name: String?` / `value: Object?` (form value when on) |
  | `children` | `ReactNode \| (SwitchRenderProps) => ReactNode` | `children` / `builder: (ctx, HeroSwitchState)` (isSelected, isHovered, isPressed, isFocused, isFocusVisible, isDisabled, isReadOnly, isInvalid, isRequired) |
  | `aria-label` | `string` | `semanticLabel` |
  | Control `className` / CSS vars `--switch-control-bg*` | – | `HeroSwitchControl(style: HeroSwitchStyle(trackColor, trackHoverColor, trackPressedColor, trackSelectedColor, trackSelectedHoverColor))` (custom-styles + with-icons demos) |
  | Thumb / Icon `children` | `ReactNode` | `HeroSwitchThumb(child)` / `HeroSwitchIcon(child)` |
  | SwitchGroup `orientation` | `'horizontal' \| 'vertical'` | `HeroSwitchGroup(orientation: Axis)` |
  | SwitchGroup `children` | `ReactNode` | `children: List<Widget>` |
  | `render` | – | — |

  Form: `FormField<bool>`; required → must be on.
- **States & behaviour:** tap on Content toggles; Space toggles when focused; hover/pressed tint the track; read-only ignores input. Semantics: `toggled: isSelected`, label = content text / `semanticLabel`, `enabled`.
- **Docs examples:**
  1. `switch-basic` — "Enable notifications".
  2. `switch-sizes` — sm / md / lg in a row (gap 24).
  3. `switch-with-icons` — five lg label-less switches (default on) with thumb icons swapping on/off (check/power, sun/moon, mic-slash/mic, bell-fill/bell-slash, volume-slash/volume); selected track tints green/red/purple/blue @80 %.
  4. `switch-disabled` — disabled off switch.
  5. `switch-without-label` — `aria-label` only.
  6. `switch-with-description` — "Public profile" + description (52 px indent).
  7. `switch-default-selected` — on by default.
  8. `switch-controlled` — "Switch is on/off" caption.
  9. `switch-label-position` — "Label after" and "Label before" (text before control).
  10. `switch-group` — vertical group of three.
  11. `switch-group-horizontal` — horizontal, horizontally scrollable group of three.
  12. `switch-form` — native form, SwitchGroup of three (newsletter on) + sm primary Submit alerting values.
  13. `switch-render-props` — label text "Enabled"/"Disabled" from `isSelected`.
  14. `switch-render-function` — same as basic.
  15. `switch-custom-styles` — "Auto-save drafts" with Label + Description inside Content; selected track `success`.
- **Depends on:** `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroForm`, `HeroButton`, `HeroSize` enum, icons (gravity-ui BellFill, BellSlash, Check, Microphone, MicrophoneSlash, Moon, Power, Sun, VolumeFill, VolumeSlashFill).

#### Slider → `HeroSlider`
- **Docs:** https://heroui.com/en/docs/react/components/slider · **Category:** Controls
- **Anatomy:** `HeroSlider` + `HeroLabel` + `HeroSliderOutput` + `HeroSliderTrack` (`HeroSliderFill` + one `HeroSliderThumb(index)` per value). `HeroSliderTrack()` without children renders Fill + all thumbs automatically. Convenience: `HeroSlider(label:, showOutput: true)`; `HeroSlider.range(values: …)` for multi-thumb. (`Slider.Marks` exists in source as TODO — skip.)
- **Variants:** `orientation: horizontal* | vertical` (`Axis`); `isDisabled`.
- **Key styles:**
  - Root (horizontal): grid, full width, gap 4; areas `"label output" / "track track"`, columns `1fr auto`. Label `w-fit` 14 px w500; Output 14 px w500 tabular figures, end-aligned (auto column), colour inherits `foreground`.
  - Track: `default` bg, radius 12, 20 px tall, full width, with **12 px transparent end caps** on both sides (usable length = width − 24; value 0 sits 12 px in). Cap colours: start cap `accent` when fill starts at min (single: value > min; range: first thumb at min); end cap `accent` when fill reaches max.
  - Fill: `accent`, full track height, positioned from start% to end% (single thumb: from 0), no radius, ignores pointer.
  - Thumb: 28×20 (`1.5rem + 0.25rem` wide), radius 12, bg `accent`, centred on the value (translate −50 %, −50 %), cursor grab/grabbing; inner knob (`::after`) 24×16, radius 8, `accent-foreground`, `shadow-field` → a 2 px accent frame around a white pill. Dragging: knob scale .9. Focus-visible: `status-focused` ring, raised z. Transitions: bg 250 ms `ease`, transform 250 ms `Cubic(0,0,.2,1)`, ring 150 ms; knob all 150 ms `Cubic(.4,0,.2,1)`.
  - Vertical: root gap 8, rows `output / track / label` (auto 1fr auto), text centred; track 20 px wide, full height, centred, 12 px caps top/bottom (start cap = bottom); thumb 20×28, knob 16×24; min at bottom.
  - Disabled: root `status-disabled` (.5, no pointer); the label's own disabled dimming is reset to opacity 1, so it is dimmed only once (by the root).
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `value` / `defaultValue` | `number \| number[]` | `value: double?` / `defaultValue: double?`; `.range(values: List<double>?, defaultValues: List<double>?)` |
  | `onChange` | `(number \| number[]) => void` | `onChanged: ValueChanged<double>?` (range: `ValueChanged<List<double>>`) |
  | `onChangeEnd` | same | `onChangeEnd` (same types) |
  | `minValue` / `maxValue` / `step` | `number` (0 / 100 / 1) | `minValue: 0` / `maxValue: 100` / `step: 1` |
  | `formatOptions` | `Intl.NumberFormatOptions` | `formatOptions: HeroNumberFormatOptions?` (+ `locale`) |
  | `orientation` | `'horizontal' \| 'vertical'` | `orientation: Axis` |
  | `isDisabled` | `boolean` | `isDisabled: bool` |
  | `aria-label` / `aria-labelledby` | `string` | `semanticLabel` |
  | `children` | `ReactNode \| RenderFunction` | `children` / `builder: (ctx, HeroSliderState)` |
  | Output `children` | `ReactNode \| (SliderRenderProps)` | `HeroSliderOutput(child / builder)`; default text = thumb labels joined by `" – "` |
  | Track `children` | `ReactNode \| (SliderRenderProps)` | `HeroSliderTrack(children / builder)`; `HeroSliderState {values, getThumbValueLabel(i), getThumbPercent(i), orientation, isDisabled}` |
  | Fill `style` | `CSSProperties` | `HeroSliderFill(color?)` |
  | Thumb `index` / `isDisabled` / `name` / `children` | – | `HeroSliderThumb(index: 0, isDisabled, name, child)` |
  | `className` (custom-styles) | – | `style: HeroSliderStyle(trackColor, fillColor, thumbColor, knobColor, outputTextStyle)` |
  | `render` | – | — |

  Form: `FormField<List<double>>` (onSaved/name; `validator` accepted per conventions, not used by docs).
- **States & behaviour:** drag thumb; tap on track moves the nearest thumb there and starts dragging; thumbs cannot cross; values snap to step. Keyboard on focused thumb: Left/Down −step, Right/Up +step (horizontal arrows flipped in RTL — source has RTL TODO, implement correctly), PageUp/PageDown ± max(step, range/10), Home/End → min/max. `onChangeEnd` on drag end / key commit. Each thumb is focusable. Semantics per thumb: `slider: true`, `value` = formatted label, `increasedValue`/`decreasedValue`, `onIncrease`/`onDecrease`, label from Label.
- **Docs examples:**
  1. `slider-default` — "Volume" 30, max-w-xs.
  2. `slider-disabled` — same, disabled.
  3. `slider-vertical` — vertical Volume 30 in a 256 px tall box.
  4. `slider-range` — "Price Range" [100, 500], 0–1000, step 50, USD currency output "$100 – $500".
  5. `slider-render-function` — same as default.
  6. `slider-custom-styles` — "Brightness" 40, output 12 px `muted`, explicit track/fill/thumb colours.
  - Code-only on page: *Range Slider Anatomy*, *Basic Usage*, *Range Slider*, *Controlled Value* (with "Current value" text), *Custom Value Formatting* (USD 60), *Vertical Orientation*, *Custom Output Display* (joined range labels).
- **Depends on:** `HeroLabel`, shared `HeroNumberFormatOptions`/formatter, focus-ring painter.

#### Fieldset → `HeroFieldset`
- **Docs:** https://heroui.com/en/docs/react/components/fieldset · **Category:** Forms
- **Anatomy:** `HeroFieldset` + `HeroFieldsetLegend` + (`HeroDescription`) + `HeroFieldsetGroup` (also exported as `FieldGroup`) + `HeroFieldsetActions`. Convenience: `legend`, `description`, `actions: List<Widget>`, `children` (fields).
- **Variants:** none (`isDisabled` boolean via native `disabled`).
- **Key styles:** root column, gap 24, flexible (`shrink grow basis-0`). Legend 16/24 w500 `foreground` (in browsers the `<legend>` is rendered outside the flex content box, so there is **no gap** between legend and the next child — verify against the live demo). Field group: full width, 16 px vertical spacing between children (`space-y-4`). Actions: row, centred, gap 8, top padding 4.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode` | `children: List<Widget>` |
  | `nativeProps.disabled` | `boolean` | `isDisabled: bool` — publishes a disabled `HeroFieldScope`/`HeroDisabledScope` so every descendant (TextField, Checkbox(Group), RadioGroup, Slider, Button, ToggleButton, Link) behaves disabled and labels dim |
  | `className` | `string` | `padding`, `decoration` overrides (custom-styles demo) |
  | Legend `children` | `ReactNode` | `HeroFieldsetLegend(child)` + `style` |
  | Group `children` | `ReactNode` | `HeroFieldsetGroup(children, spacing: 16)` |
  | Actions `children` | `ReactNode` | `HeroFieldsetActions(children, spacing: 8)` |
- **States & behaviour:** purely structural; disabled cascade as above. Semantics: `Semantics(container: true, explicitChildNodes: true, label: legend text)` (group).
- **Docs examples:**
  1. `fieldset-basic` — Form max-w-96: "Profile Settings" legend, description, group with required Name (min 3 via validator), Email (type email), Bio TextArea (min 10) each with FieldError; actions: primary "Save changes" (floppy-disk icon) + secondary reset "Cancel".
  2. `fieldset-on-surface` — same inside Surface (min-w 380) with secondary inputs and tertiary Cancel.
  3. `fieldset-custom-styles` — shell radius 12, border/70, vertical gradient neutral-50/90 → white (dark neutral-900), p 16, ring black/5; custom field style.
- **Depends on:** `HeroForm`, `HeroTextField`, `HeroInput`, `HeroTextArea`, `HeroLabel`, `HeroDescription`, `HeroFieldError`, `HeroButton`, `HeroSurface`, icon (FloppyDisk).

#### Form → `HeroForm`
- **Docs:** https://heroui.com/en/docs/react/components/form · **Category:** Forms
- **Anatomy:** `HeroForm(child)` wrapping Flutter `Form`; fields register as `FormField`s; submit/reset triggered by `HeroButton(type: HeroButtonType.submit|reset)` or `HeroForm.of(context).submit()/reset()`.
- **Variants:** none. No styles (layout only via the child).
- **Key styles:** none (native `<form>`); demos use column gap 16 (w-96) etc.
- **Props → Flutter:**

  | React prop | Type | Flutter param |
  |---|---|---|
  | `children` | `ReactNode` | `child: Widget` |
  | `onSubmit` | `(FormEvent) => void` | `onSubmit: ValueChanged<Map<String, Object?>>?` — called only when valid (native) with name→value data (FormData analogue; multi-value fields → `List`) |
  | `onInvalid` | `(FormEvent) => void` | `onInvalid: VoidCallback?` (default behaviour: focus first invalid field; return/flag to suppress) |
  | `onReset` | `(FormEvent) => void` | `onReset: VoidCallback?` (resets every field to its default value) |
  | `validationBehavior` | `'native' \| 'aria'` | `validationBehavior: HeroValidationBehavior` (default native; inherited by fields via scope) |
  | `validationErrors` | `ValidationErrors` | `validationErrors: Map<String, List<String>>?` (server errors by field name; cleared when that field changes) |
  | `aria-label` / `aria-labelledby` | `string` | `semanticLabel: String?` |
  | `action`, `method`, `encType`, `target` | – | — (no equivalent) |
  | `render`, `className` | – | — |
  | (Flutter) | – | `key: GlobalKey<HeroFormState>` (`submit()`, `reset()`, `validate()`, `save()`), `autovalidateMode`, `onChanged` |
- **States & behaviour:** native: submit → validate all → if any invalid show errors, focus first invalid, call `onInvalid`, don't call `onSubmit`; afterwards fields re-validate on change. aria: errors show while typing; `onSubmit` always called. Reset restores defaults and clears errors. Semantics: labelled container when `semanticLabel` given.
- **Docs examples:**
  1. `form-basic` — w-96 column gap 16: required email (regex validator), required password (≥8, uppercase, digit) + description + FieldError; Submit (check icon) + secondary Reset; alerts submitted JSON.
  2. `form-render-function` — same as basic.
  3. `form-custom-styles` — w-80 card: radius 12, border/80, `surface` bg, p 16, shadow-sm, gap 12; required "Work email" + full-width Continue.
- **Depends on:** Flutter `Form`, all form controls above, `HeroButton` (submit/reset types), `HeroTextField`, `HeroFieldError`, icons (Check).

## Overlays, collections, pickers, navigation and table

Source of truth: HeroUI v3 (`packages/styles/components/*.css`, `packages/react/src/components/*`, docs mdx + demos).
Conventions from section 5 (API conventions) apply (`Hero` prefix, `X.Y` → `HeroXY`, `default` → `standard`,
`onPress` → `onPressed`, `onOpenChange` → `onOpenChanged`, `onSelectionChange` → `onSelectionChanged`, etc.).
Default values are marked with `*`.

### 0. Shared foundations used by group C (build these first)

- **Units / tokens.** Tailwind spacing unit = 4px. Radius base `--radius` = 8px → `xs 2, sm 4, md 6, lg 8, xl 12, 2xl 16, 3xl 24, 4xl 32`
  ("`min(32px, radius-3xl)`" = token clamped to ≤32). `rounded-field` = 12. Text: `xs 12/16, sm 14/20, base 16/24, lg 18/28`.
  Max widths: `max-w-xs 320, sm 384, md 448, lg 512`. Breakpoints: `sm ≥640`, `md ≥768` (MediaQuery width).
- **Colors used** (theme tokens): `overlay` (white / oklch(.2103 .0059 285.89) dark), `overlay-foreground`, `surface`, `surface-secondary`,
  `default`, `default-hover`, `default-foreground`, `muted`, `separator`, `separator-tertiary`, `border`, `segment`, `segment-foreground`,
  `accent(-soft,-soft-foreground,-soft-hover)`, `success/warning/danger(-soft,-soft-foreground)`, `field*`, `focus`, `link`,
  `backdrop` = rgba(0,0,0,.5) light / rgba(0,0,0,.6) dark.
- **Shadows.** `overlay` light: `0 2 8 0 rgba(0,0,0,.06), 0 -6 12 0 rgba(0,0,0,.03), 0 14 28 0 rgba(0,0,0,.08)`; dark: inset `0 0 1 0 rgba(255,255,255,.3)`.
  `surface` light: `0 2 4 0 rgba(0,0,0,.04), 0 1 2 0 rgba(0,0,0,.06), 0 0 1 0 rgba(0,0,0,.06)`. `field` = same as surface (light), none (dark).
- **Focus ring** (`status-focused`): 2px `focus` ring outside a 2px `background`-colored gap. `status-focused-field`: 2px ring, no gap.
  `status-invalid-field`: 1px `danger` outline, becomes 2px danger ring when focused. `status-disabled`: opacity .5, not-allowed cursor, no hit-testing.
- **Easing constants.** CSS `ease` = `Curves.ease`; Tailwind `ease-out` = `Cubic(0,0,.2,1)`; Tailwind default transition = `Cubic(.4,0,.2,1)`
  (150ms unless a duration is set); `ease-out-quad` = `Cubic(.25,.46,.45,.94)`; `ease-out-quart` = `Cubic(.165,.84,.44,1)`;
  `ease-out-fluid` = `Cubic(.32,.72,0,1)`. Honour reduced motion (`MediaQuery.disableAnimationsOf`) → no transitions/animations.
- **`HeroOverlayController`** (= `useOverlayState`): `ChangeNotifier` with `isOpen`, `open()`, `close()`, `toggle()`, `setOpen(bool)`,
  ctor `HeroOverlayController({bool defaultOpen = false, ValueChanged<bool>? onOpenChanged})`.
- **Overlay host.** Floating UI renders in the root `Overlay` (`OverlayPortal`). Modal family (Modal, AlertDialog, Drawer) uses a custom
  `PopupRoute`-like route: barrier (backdrop), focus trap (`FocusScope` + Tab cycling), background inert (`BlockSemantics`), background
  scroll/pointer lock, focus restore to trigger. z-order: overlays (100000) < toast region (100001) → toast host must be the last entry of
  the root overlay. `HeroOverlayHost` (optional nested `Overlay`) replaces `UNSTABLE_portalContainer`.
- **`HeroPositioner`** (Tooltip/Popover/Dropdown/submenus/Select/ComboBox/Autocomplete): inputs trigger rect, content size, `placement`,
  `offset` (main axis), `crossOffset` 0, `containerPadding` 12, `shouldFlip` true, optional arrow; outputs resolved placement (drives
  arrow rotation + slide direction), `maxHeight` = available space − padding, arrow position, and transform-origin = point of the content
  nearest the trigger ("trigger anchor point"). `HeroPlacement` enum (RAC set): `top, topStart, topEnd, topLeft, topRight, bottom,
  bottomStart, bottomEnd, bottomLeft, bottomRight, left, leftTop, leftBottom, right, rightTop, rightBottom, start, startTop, startBottom,
  end, endTop, endBottom` (start/end are RTL-aware; left/right physical).
- **Pop animation** (Tooltip/Popover/Dropdown/Select/ComboBox; Autocomplete differs): enter 150ms `ease`: opacity 0→1, scale `s0`→1
  (s0 = .90 tooltip/popover/dropdown, .95 select/combobox/autocomplete), translate 4px coming from the trigger side
  (placement top → from +4px y, bottom → −4px y, left → +4px x, right → −4px x). Exit 100ms `ease`: opacity →0, scale →.95; content
  ignores pointer during exit.
- **Overlay arrow** (`HeroOverlayArrow`): 12×12 path `M0 0C5.48483 8 6.5 8 12 0Z` (points down for `top`), fill `overlay`;
  rotate 180° for bottom, −90° left, +90° right. Custom child replaces the shape.
- **Backdrop** `HeroBackdropVariant {opaque*, blur, transparent}`: opaque = `backdrop` color; blur = `backdrop` color + `BackdropFilter`
  blur 12px (CSS `backdrop-blur-md`, ≈ sigma 6); transparent = no fill (still hit-testable).
- **Collection model** (ListBox, Menu, TagGroup, Select, ComboBox, Autocomplete, Tabs, Table): items carry `id` (Object), `textValue`,
  `isDisabled`; `HeroSelectionMode {none, single, multiple}`; `disabledKeys`; selection manager (controlled/uncontrolled); keyboard focus
  manager (arrows, Home/End, PageUp/PageDown, typeahead: accumulate chars, reset after 1000ms, match `textValue` prefix,
  case-insensitive); "virtual focus" mode (ComboBox/Autocomplete keep real focus in the text field). `items` + `itemBuilder` and static
  children both supported; `HeroCollection(items, builder)` = RAC `Collection`; `HeroListBoxLoadMoreItem(isLoading, onLoadMore, child)`
  = sentinel that fires when scrolled into view.
- **Checkmark indicator painter** (ListBox/Menu): polyline `1 9 7 14 15 4` in 17×18 viewBox, stroke 2 `currentColor`, round cap/join,
  dash 22; dashoffset 66 (hidden) → 44 (drawn) when selected (line-draw animation).
- **Section header** `Header` → `HeroHeader` (other group owns it): padding x8, top 6, bottom 4, text-xs medium `muted`, start aligned.
- **`slot` props.** `Button slot="close"` inside any dialog closes it → `HeroButton(slot: HeroButtonSlot.close)` reading
  `HeroDialogScope.of(context).close()`. Also `slot="trigger"` (Disclosure), `slot="chevron"` (Table tree), `Checkbox slot="selection"`
  (Table), `Kbd slot="keyboard"` (menu item shortcut, pushed to end).
- **`render` prop / "Render Function" demos:** no DOM in Flutter; each such part gets a `builder` receiving its render state
  (`isHovered`, `isPressed`, `isFocused`, `isFocusVisible`, `isSelected`, `isDisabled`, ...). Gallery shows these demos via `builder`.
- **"Custom styles" demos** use `className`; to reproduce them each part accepts an optional `style` override object
  (`HeroXStyle`: decoration/padding/radius/textStyle) — keep minimal, used only by the gallery "Customization" sections.

---

#### Tooltip → `HeroTooltip`
- **Docs:** https://heroui.com/en/docs/react/components/tooltip · **Category:** Overlays
- **Anatomy:** `Tooltip` → `HeroTooltip` (state root; first child/`child` = trigger); `Tooltip.Trigger` → `HeroTooltipTrigger` (makes arbitrary
  content focusable, Semantics button); `Tooltip.Content` → `HeroTooltipContent`; `Tooltip.Arrow` → `HeroTooltipArrow`.
  Convenience: `HeroTooltip(content: Widget, showArrow:, placement:, child: trigger)`.
- **Variants:** placement `HeroPlacement` (top*); `showArrow` (false*); `trigger` `HeroTooltipTriggerMode {hover*, focus}`; `isDisabled` (false*);
  `shouldSkipAnimation` (false*). No size/color variants.
- **Key styles:** bg `overlay`, padding 8, text-xs 12/16, max-width 320, wraps anywhere (`break-all`), radius 12 (`min(32, radius-xl)`),
  shadow `overlay`. Offset from trigger 3px, 7px when `showArrow` (explicit `offset` wins). Arrow 12×12, fill `overlay`, stroke `border`@40%.
  Enter 150ms `ease`: fade 0→1, scale .9→1, 4px slide from trigger side; exit 100ms `ease`: scale→.95, fade→0. Origin = trigger anchor.
  `HeroTooltipTrigger`: inline, focus ring on keyboard focus; color/bg transition 150ms ease, shadow 150ms ease-out.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `children` (Tooltip) | ReactNode | `child` (trigger) + `content` |
| `delay` | number (docs: 700; effective 1500 via `--tooltip-delay`) | `delay: Duration` (1500ms) |
| `closeDelay` | number (docs: 0; effective 500 via `--tooltip-close-delay`) | `closeDelay: Duration` (500ms) |
| `trigger` | `"hover" \| "focus"` | `trigger: HeroTooltipTriggerMode` |
| `isDisabled` | boolean | `isDisabled` |
| `shouldSkipAnimation` | boolean | `shouldSkipAnimation` |
| (RAC) `isOpen`/`defaultOpen`/`onOpenChange` | | `isOpen`, `defaultOpen`, `onOpenChanged` |
| `Content.children` | ReactNode | `HeroTooltipContent.child` |
| `Content.showArrow` | boolean | `showArrow` |
| `Content.offset` | number (3 / 7) | `offset: double?` |
| `Content.placement` | placement | `placement: HeroPlacement` |
| `Content.render` | render fn | `builder` |
| `Trigger.children` | ReactNode | `HeroTooltipTrigger.child` |
| `Arrow.children` | ReactNode | `HeroTooltipArrow.child` (custom shape) |

- **States & behaviour:** mouse hover opens after `delay`; keyboard focus opens immediately; leave/blur closes after `closeDelay`; Esc closes;
  pressing the trigger closes; `trigger: focus` → only focus opens. Global warm-up: while any tooltip is open (and 500ms after), another
  trigger opens instantly (animation still plays unless `shouldSkipAnimation`). Touch: RAC does not open on touch; optional long-press.
  Not focusable itself. Semantics: trigger `Semantics(tooltip: text)`; content `SemanticsRole.tooltip`.
- **Docs examples:** `tooltip-basic` (secondary button + icon-only button, delay 0) · `tooltip-placement` (3×3 grid top/left/right/bottom with
  arrows) · `tooltip-with-arrow` (arrow; custom offset 12) · `tooltip-custom-trigger` (Tooltip.Trigger around Avatar, Chip, round icon; rich
  content with name/email, pinging dot, title+paragraph) · `tooltip-render-function` (custom element via render) · `tooltip-custom-styles`
  (surface bg, 1px border, radius 8, px10 py4, small shadow).
- **Depends on:** HeroPositioner/overlay layer, HeroOverlayArrow, HeroButton, HeroAvatar, HeroChip (demos).

#### Popover → `HeroPopover`
- **Docs:** https://heroui.com/en/docs/react/components/popover · **Category:** Overlays
- **Anatomy:** `Popover` → `HeroPopover` (trigger child + content); `Popover.Trigger` → `HeroPopoverTrigger`; `Popover.Content` →
  `HeroPopoverContent`; `Popover.Arrow` → `HeroPopoverArrow` (may sit anywhere inside content); `Popover.Dialog` → `HeroPopoverDialog`;
  `Popover.Heading` → `HeroPopoverHeading` (labels the dialog).
- **Variants:** placement (bottom*); `offset` 8*; `shouldFlip` true*; RAC extras `crossOffset` 0*, `containerPadding` 12*, `isNonModal` false*.
- **Key styles:** content bg `overlay`, text-sm, padding 0, radius 24 (`min(32, radius-3xl)`), shadow `overlay`; dialog padding 16, no outline;
  heading font-weight 500. Arrow fill `overlay` (no stroke). Animation = pop animation (150ms enter, scale .9, 4px; 100ms exit, .95).
  Trigger: inline, pointer cursor, focus ring, disabled opacity .5, color/bg 150ms ease, shadow 150ms ease-out.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `children` | ReactNode | `child` (trigger) + `content: HeroPopoverContent` |
| `isOpen` / `defaultOpen` / `onOpenChange` | boolean / fn | `isOpen`, `defaultOpen`, `onOpenChanged`, `controller` |
| `Content.children` | ReactNode | `child` |
| `Content.placement` | placement | `placement: HeroPlacement` (bottom) |
| `Content.offset` | number | `offset` (8) |
| `Content.shouldFlip` | boolean | `shouldFlip` (true) |
| `Content.render` | render fn | `builder` |
| `Dialog.children` | ReactNode | `HeroPopoverDialog.child` / `builder(context, close)` |
| `Trigger.children` | ReactNode | `HeroPopoverTrigger.child` |
| `Arrow.children` / `render` | ReactNode | `HeroPopoverArrow.child` |
| `Heading.children` | ReactNode | `HeroPopoverHeading.child` |

- **States & behaviour:** trigger press toggles; outside press and Esc dismiss; on open focus moves into the dialog (dialog node itself unless a
  child autofocuses), restored to trigger on close; modal by default (outside inert for a11y, page scroll blocked). Semantics:
  `SemanticsRole.dialog`, `namesRoute` from Heading, `scopesRoute`.
- **Docs examples:** `popover-basic` (title + muted text, max-w 256) · `popover-with-arrow` (arrow; icon-only trigger with offset 10) ·
  `popover-interactive` (Popover.Trigger around avatar+name; 320px profile card with Follow/Following toggle button and stats) ·
  `popover-placement` (3×3 grid, 4 placements with arrow) · `popover-render-function` · `popover-custom-styles` (translucent surface, border,
  blur, top gradient, stat rows).
- **Depends on:** HeroPositioner, HeroOverlayArrow, HeroButton, HeroAvatar.

#### Modal → `HeroModal`
- **Docs:** https://heroui.com/en/docs/react/components/modal · **Category:** Overlays
- **Anatomy:** `Modal` → `HeroModal` (trigger + overlay tree; takes `controller`); `Modal.Trigger` → `HeroModalTrigger` (custom pressable trigger);
  `Modal.Backdrop` → `HeroModalBackdrop`; `Modal.Container` → `HeroModalContainer`; `Modal.Dialog` → `HeroModalDialog`; `Modal.Header` →
  `HeroModalHeader`; `Modal.Icon` → `HeroModalIcon`; `Modal.Heading` → `HeroModalHeading`; `Modal.Body` → `HeroModalBody`;
  `Modal.Footer` → `HeroModalFooter`; `Modal.CloseTrigger` → `HeroModalCloseTrigger`; `useOverlayState` → `HeroOverlayController`.
  Imperative: `HeroModal.show<T>(context, {backdropVariant, placement, scroll, size, isDismissable, isKeyboardDismissDisabled,
  required builder: (context, close) => HeroModalDialog})` → `Future<T?>`. `HeroModalBackdrop` is built lazily into the modal route.
- **Variants:** backdrop `variant` `HeroBackdropVariant {opaque*, blur, transparent}`; `placement` `HeroModalPlacement {auto*, center, top, bottom}`;
  `scroll` `HeroModalScroll {inside*, outside}`; `size` `HeroModalSize {xs, sm, md*, lg, cover, full}`; `isDismissable` true*;
  `isKeyboardDismissDisabled` false*.
- **Key styles:**
  - Backdrop: full viewport (height = visual viewport, i.e. minus keyboard inset); fill per variant; enter fade 150ms tw-`ease-out`, exit fade 100ms.
  - Container: column, centered horizontally, full viewport height; padding 16 (<640) / 40 (≥640); width 100% (<640) / fit-content (≥640);
    not hit-testable except dialog. Enter 250ms `ease-out-quad`: opacity 0→1, scale 1.05→1, translateY: auto → +4px (<640) / 0 (≥640),
    top → −4px, center → 0, bottom → +4px. Exit 100ms `ease-out-quad`: opacity→0, scale→.95. Size `full`: container padding 0 and no
    scale/slide (fade only) on enter/exit.
  - Dialog: column, `width: 100%` capped by size: xs 320, sm 384, md 448, lg 512; `cover` = fills padded container (100%×100%); `full` =
    100%×100%, radius 0, no shadow. bg `overlay`, shadow `overlay`, radius 24, padding 24. Vertical position: auto = bottom (<640, i.e.
    bottom sheet-like) / centered (≥640); center = centered; top = top; bottom = bottom.
  - Scroll inside: dialog max-height = container inner height, clipped; body scrolls (overscroll contained). Scroll outside: backdrop
    scrolls, container min-height = viewport, dialog natural height, body not scrollable.
  - Header: column, gap 12. Heading: 16/24, weight 500, `foreground`. Icon: 40×40, radius 24 (circle), centered, colors from consumer.
  - Body: flex 1, 14px, line-height 1.43, `muted`; 3px padding with −3px horizontal margin (focus rings not clipped).
  - Footer: row, end-aligned, gap 8. Spacing: header→body 8, header→footer 20, body→footer 20.
  - CloseTrigger: HeroCloseButton (24×24, radius 12, padding 4) positioned top 16 / end 16.
  - Trigger (`HeroModalTrigger`): pointer cursor, focus ring, pressed scale .97 (transform 250ms `ease-out-quart`), bg 150ms ease.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `Modal.children` | ReactNode | `trigger` + `child: HeroModalBackdrop` |
| `Modal.state` | UseOverlayStateReturn | `controller: HeroOverlayController` |
| `Trigger.children` | ReactNode | `HeroModalTrigger.child` |
| `Backdrop.variant` | opaque/blur/transparent | `variant: HeroBackdropVariant` |
| `Backdrop.isDismissable` | boolean (true) | `isDismissable` |
| `Backdrop.isKeyboardDismissDisabled` | boolean (false) | `isKeyboardDismissDisabled` |
| `Backdrop.isOpen` / `onOpenChange` | boolean / fn | `isOpen`, `onOpenChanged` (also on `HeroModal`, + `defaultOpen`) |
| `Backdrop.className` fn | | `style` / `decoration` override (custom backdrop demo uses gradient) |
| `Backdrop.UNSTABLE_portalContainer` | HTMLElement | `overlayHost: GlobalKey<HeroOverlayHostState>?` |
| `Container.placement` | auto/center/top/bottom | `placement: HeroModalPlacement` |
| `Container.scroll` | inside/outside | `scroll: HeroModalScroll` |
| `Container.size` | xs…full | `size: HeroModalSize` |
| `Dialog.children` | node \| `({close})=>node` | `children` or `builder: (context, VoidCallback close)` |
| `Dialog.role` | string ("dialog") | `role` (dialog) |
| `Dialog.aria-label` / `-labelledby` / `-describedby` | string | `semanticLabel` (defaults to Heading text) |
| `Header/Body/Footer/Icon/Heading.children` | ReactNode | `children` / `child` |
| `CloseTrigger.children` | ReactNode | `child` (custom close button) |
| (demo override) `sm:max-w-[360px]` | | `HeroModalDialog.maxWidth` |

- **States & behaviour:** trigger press opens; Esc closes unless `isKeyboardDismissDisabled`; backdrop press closes if `isDismissable`;
  `slot=close` buttons and `builder` `close()` close. Focus trapped (Tab/Shift-Tab cycle), initial focus = dialog, restore to trigger;
  background inert + scroll-locked; keyboard inset shrinks viewport (form demo). Semantics: `SemanticsRole.dialog`, `scopesRoute`,
  `namesRoute`, label = Heading. Animations reversed on close before route pop.
- **Docs examples:** `modal-default` (rocket icon, heading, text, full-width Continue) · `modal-sizes` (xs, sm, md, lg, cover, full) ·
  `modal-placements` (auto, top, center, bottom) · `modal-scroll-comparison` (radio inside/outside, 30 paragraphs) · `modal-controlled`
  (useState + useOverlayState: status text, Open/Toggle buttons) · `modal-with-form` (contact form of 5 secondary TextFields in Surface) ·
  `modal-custom-trigger` (card-style Modal.Trigger "Settings") · `modal-backdrop-variants` (opaque, blur, transparent) ·
  `modal-custom-backdrop` (blur + black→transparent bottom-up gradient, centered header, stacked footer) · `modal-dismiss-behavior`
  (isDismissable=false; isKeyboardDismissDisabled) · `modal-close-methods` (slot close; Dialog render-prop close) ·
  `modal-custom-animations` ("Kinematic Scale": 400ms `Cubic(.16,1,.3,1)` fade + zoom .95, exit 200ms `Cubic(.7,0,.84,0)`;
  "Fluid Slide": 500ms `Cubic(.25,1,.5,1)` fade + slide-from-bottom 16px, exit 200ms `Cubic(.5,0,.75,0)` slide-to-bottom 8px) →
  expose `enterDuration/exitDuration/enterCurve/exitCurve/transitionBuilder` · `modal-custom-portal` (renders inside a 380px-high bounded box) ·
  `modal-custom-styles` (blurred translucent surface, border, top gradient).
- **Depends on:** overlay route + HeroOverlayController, HeroCloseButton, HeroButton (slot close), HeroRadioGroup, HeroTextField/HeroInput/
  HeroLabel, HeroSurface (demos).

#### AlertDialog → `HeroAlertDialog`
- **Docs:** https://heroui.com/en/docs/react/components/alert-dialog · **Category:** Overlays
- **Anatomy:** same as Modal: `HeroAlertDialog`, `HeroAlertDialogTrigger`, `HeroAlertDialogBackdrop`, `HeroAlertDialogContainer`,
  `HeroAlertDialogDialog`, `HeroAlertDialogHeader`, `HeroAlertDialogIcon`, `HeroAlertDialogHeading`, `HeroAlertDialogBody`,
  `HeroAlertDialogFooter`, `HeroAlertDialogCloseTrigger`; `HeroAlertDialog.show(context, ...)` → `Future<T?>`. Implement by sharing Modal internals.
- **Variants:** backdrop `HeroBackdropVariant {opaque*, blur, transparent}`; placement `{auto*, center, top, bottom}`; size
  `HeroAlertDialogSize {xs, sm, md*, lg, cover}` (no `full`, no `scroll` prop); icon `status` `HeroColor {standard, accent, success, warning, danger*}`;
  `isDismissable` **false***; `isKeyboardDismissDisabled` **true***.
- **Key styles:** identical to Modal (backdrop, container animations/padding/responsive auto placement, dialog radius 24/padding 24/overlay
  shadow, header gap 12, heading 16 medium, body 14/1.43 muted, footer gap 8, spacing 8/20/20, close trigger top16/end16) except:
  dialog always `max-height: 100%`, clipped, body always scrollable (overscroll contained). Icon 40×40 circle; default glyph 20px by status:
  standard → Info icon on `default`/`foreground`; accent → Info on `accent-soft`/`accent-soft-foreground`; success → Success (check circle) on
  `success-soft`/`success-soft-foreground`; warning → Warning triangle on `warning-soft`/`warning-soft-foreground`; danger → Danger (exclamation
  circle) on `danger-soft`/`danger-soft-foreground`.
- **Props → Flutter:** as Modal, plus/minus:

| React prop | Type | Flutter param |
|---|---|---|
| `Backdrop.isDismissable` | boolean (false) | `isDismissable` (false) |
| `Backdrop.isKeyboardDismissDisabled` | boolean (true) | `isKeyboardDismissDisabled` (true) |
| `Backdrop.variant` / `isOpen` / `onOpenChange` / `UNSTABLE_portalContainer` | | `variant`, `isOpen`, `onOpenChanged`, `overlayHost` |
| `Container.placement` | auto/center/top/bottom | `placement: HeroModalPlacement` |
| `Container.size` | xs/sm/md/lg/cover | `size: HeroAlertDialogSize` |
| `Dialog.children` | node \| fn | `children` / `builder(context, close)` |
| `Dialog.role` | "alertdialog" | `role` |
| `Icon.status` | default/accent/success/warning/danger (danger) | `status: HeroColor` (danger) |
| `Icon.children` | ReactNode | `child` (custom glyph) |
| `Trigger/Header/Heading/Body/Footer/CloseTrigger.children` | ReactNode | `child`/`children` |

- **States & behaviour:** like Modal but by default requires explicit action (no backdrop / Esc dismiss). Semantics: `SemanticsRole.alertDialog`
  (+ `scopesRoute`, `namesRoute`), announce heading/body.
- **Docs examples:** `alert-dialog-default` (danger "Delete project permanently?", Cancel tertiary / Delete danger) · `alert-dialog-statuses`
  (accent Sign Out, success Complete Task, warning Discard, danger Delete Account) · `alert-dialog-placements` (auto, top, center, bottom) ·
  `alert-dialog-sizes` (xs, sm, md, lg, cover) · `alert-dialog-controlled` (useState / useOverlayState) · `alert-dialog-custom-icon` (warning
  status with LockOpen icon) · `alert-dialog-custom-trigger` (card trigger "Delete Item") · `alert-dialog-backdrop-variants` ·
  `alert-dialog-custom-backdrop` (blur + red-950 gradient) · `alert-dialog-dismiss-behavior` (isDismissable=false; isKeyboardDismissDisabled) ·
  `alert-dialog-close-methods` (slot close; render-prop close) · `alert-dialog-custom-animations` (Kinematic Scale, Fluid Slide as Modal) ·
  `alert-dialog-custom-portal` · `alert-dialog-custom-styles` (blur backdrop, bordered surface, accent top gradient).
- **Depends on:** Modal internals, HeroCloseButton, HeroButton, icon set (Info/Success/Warning/Danger).

#### Drawer → `HeroDrawer`
- **Docs:** https://heroui.com/en/docs/react/components/drawer · **Category:** Overlays
- **Anatomy:** `Drawer` → `HeroDrawer` (`controller`); `Drawer.Trigger` → `HeroDrawerTrigger`; `Drawer.Backdrop` → `HeroDrawerBackdrop`;
  `Drawer.Content` → `HeroDrawerContent` (edge positioning); `Drawer.Dialog` → `HeroDrawerDialog` (panel); `Drawer.Handle` → `HeroDrawerHandle`;
  `Drawer.CloseTrigger` → `HeroDrawerCloseTrigger`; `Drawer.Header` → `HeroDrawerHeader`; `Drawer.Heading` → `HeroDrawerHeading`;
  `Drawer.Body` → `HeroDrawerBody`; `Drawer.Footer` → `HeroDrawerFooter`. `HeroDrawer.show(context, ...)` → `Future<T?>`.
- **Variants:** backdrop `HeroBackdropVariant {opaque*, blur, transparent}`; placement `HeroDrawerPlacement {top, bottom*, left, right}`
  (CSS uses flex start/end → mirrored in RTL; use `AlignmentDirectional` start/end); `isDismissable` true*; `isKeyboardDismissDisabled` false*.
- **Key styles:**
  - Backdrop: full viewport; opacity 0→1 over 250ms `Cubic(.32,.72,0,1)`; exit →0 over 200ms same curve.
  - Panel: column, bg `overlay`, shadow `overlay`, padding 24. bottom/top: full width, max-height 85% viewport, radius 16
    (`min(32, radius-2xl)`) on the inner (top resp. bottom) corners only. left/right: full height, width 320 (<640) / 384 (≥640),
    max-width 85% viewport, radius 0. Top placement: panel padding-bottom 8 and handle padding-bottom 0.
  - Slide: from 100% off-edge to 0 (`translate`) 250ms `Cubic(.32,.72,0,1)`; exit back to 100% in 200ms same curve (continues from dragged offset).
  - Handle: centered row, padding-bottom 8; bar 36×4, radius 2, color `separator`.
  - Header column gap 12; Heading 16 medium foreground; Body flex 1, 14/1.43 muted, scrollable, 3px padding/−3px margin; Footer row end gap 8;
    spacing header→body 8, header→footer 20, body→footer 20, handle→header/body 0. CloseTrigger top 16 / end 16.
  - Trigger: pressed scale .97 (250ms ease-out-quart), focus ring.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `Drawer.children` | ReactNode | `trigger` + `child: HeroDrawerBackdrop` |
| `Drawer.state` | UseOverlayStateReturn | `controller` |
| `Trigger.children` | ReactNode | `child` |
| `Backdrop.variant` | opaque/blur/transparent | `variant: HeroBackdropVariant` |
| `Backdrop.isDismissable` | boolean (true) | `isDismissable` (also disables drag) |
| `Backdrop.isKeyboardDismissDisabled` | boolean (false) | `isKeyboardDismissDisabled` |
| `Backdrop.isOpen` / `onOpenChange` | | `isOpen`, `onOpenChanged` (+ `defaultOpen` on root) |
| `Content.placement` | top/bottom/left/right (bottom) | `placement: HeroDrawerPlacement` |
| `Dialog.children` / `role` / `aria-label(ledby)` | | `children` / `builder(context, close)`, `role`, `semanticLabel` |
| `Header/Heading/Body/Footer.children` | ReactNode | `child`/`children` |
| `Handle.className` | string | `HeroDrawerHandle()` (optional `color`) |
| `CloseTrigger.children` | ReactNode | `child` |

- **States & behaviour:** Esc, backdrop press (if dismissable), slot-close, drag-to-dismiss. Drag: pointer down on panel (not body, not
  buttons/inputs/links) → activates after 8px movement, only in the dismiss direction (bottom: +y, top: −y, right: +x, left: −x), panel
  follows pointer without transition; release dismisses if offset > 30% of panel height/width or velocity > 0.5 px/ms, else snaps back
  over 300ms `Cubic(.32,.72,0,1)`. Focus trap, scroll lock, restore focus. Semantics `SemanticsRole.dialog`, scopesRoute/namesRoute.
- **Docs examples:** `drawer-basic` (right drawer, Cancel/Confirm) · `drawer-placements` (bottom with top handle, top with handle at end, left,
  right) · `drawer-non-dismissable` · `drawer-scrollable-content` (handle + 20 paragraphs, Decline/Accept) · `drawer-controlled`
  (useState / useOverlayState, right) · `drawer-with-form` (Edit Profile: 3 TextFields, right) · `drawer-navigation` (left nav list of 6
  icon rows, hover bg-default radius 12) · `drawer-backdrop-variants` · `drawer-custom-styles` (right, bordered surface panel).
- **Depends on:** overlay route, HeroCloseButton, HeroButton, HeroTextField/HeroInput/HeroLabel (demos).

#### Toast → `HeroToast`
- **Docs:** https://heroui.com/en/docs/react/components/toast · **Category:** Overlays
- **Anatomy:** `Toast.Provider` → `HeroToastProvider` (region; wrap app or place once near root, may take custom `queue` and `builder`);
  `Toast` → `HeroToast` (one queued toast); `Toast.Indicator` → `HeroToastIndicator`; `Toast.Content` → `HeroToastContent`;
  `Toast.Title` → `HeroToastTitle`; `Toast.Description` → `HeroToastDescription`; `Toast.ActionButton` → `HeroToastActionButton`;
  `Toast.CloseButton` → `HeroToastCloseButton`; `ToastQueue` → `HeroToastQueue`; `toast()` → global `heroToast` (a `HeroToaster` object with
  `call()`, `.success/.info/.warning/.danger/.promise/.update/.close/.clear/.pauseAll/.resumeAll`) and `HeroToast.show(context, ...)`.
- **Variants:** toast `variant` `HeroToastVariant {standard*, accent, success, warning, danger}` (`toast.info` → accent); provider `placement`
  `HeroToastPlacement {topStart, top, topEnd, bottomStart, bottom*, bottomEnd}`; `isExpanded` false*; `maxVisibleToasts` 3*; `gap` 12*;
  `scaleFactor` 0.05*; `width` 460*; `hotkey` [alt, KeyT]*; content `isLoading` false*; `timeout` 4000ms* (0 = persistent).
- **Key styles:**
  - Region: 16px from the placement edges (top/bottom 16; start/end 16; centered horizontally for top/bottom); width = screen − 32 (<640) or
    ≥ `width` (460) (≥640); not hit-testable except toasts.
  - Toast: absolutely stacked, row, align start, gap 6, padding 16×12, bg `surface`, shadow `overlay`, radius 24. Indicator: padding 4,
    icon 16px (`overlay-foreground`, spinner 16px when loading). Content column grows. Title 14/20 medium `overlay-foreground`;
    description 14 `muted`. Variant colors: accent → title `accent-soft-foreground`; success/warning/danger → title + indicator
    `<color>-soft-foreground`. Action button (HeroButton, default size) at end on ≥768 width, inside content below text (margin-top 8) on
    <768. Close button: 20×20 circle-ish (radius 12) at top −4 / end −4, glyph 14 (<640) / 12 (≥640), bg `default` (<640) or `overlay` +
    1px `border` (≥640), hover `default`; hidden (opacity 0, no hit) until the front/expanded toast is hovered; fade 150ms.
  - Stack (bottom placements stack upward, `dir = −1`; top placements downward, `dir = +1`): collapsed toast `i` (0 = newest/front):
    translateY = dir·(i·gap), scale = 1 − i·scaleFactor, height forced to the front toast's height, its content opacity 0 (200ms), origin
    bottom-center (top-center for top). Expanded (hover/focus or `isExpanded`, only if >1 toast): translateY = dir·(Σheights of newer
    toasts + i·gap), scale 1, natural height. Toasts with i ≥ maxVisibleToasts: opacity 0, no hit. z-order newest on top.
  - Motion: enter translate from dir·(−100%) (i.e. from below for bottom) → 0 over 350ms `ease-out-fluid`; height 350ms; opacity 150ms.
    Exit: opacity →0 (150ms); front toast also slides back 100% over 250ms with scale 1; non-front exit 200ms with scale ×0.96. Queue keeps
    closing toast mounted 300ms (`exitDuration`). Indicator swap (loading → result) plays fade 150ms + scale .92→1 200ms.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `Provider.placement` | 6 placements (bottom) | `placement: HeroToastPlacement` |
| `Provider.gap` | number (12) | `gap` |
| `Provider.isExpanded` | boolean (false) | `isExpanded` |
| `Provider.maxVisibleToasts` | number (3) | `maxVisibleToasts` |
| `Provider.hotkey` | string[] (["altKey","KeyT"]) | `hotkey: SingleActivator?` (Alt+T; null disables) |
| `Provider.scaleFactor` | number (0.05) | `scaleFactor` |
| `Provider.width` | number \| string (460) | `width: double` |
| `Provider.queue` | ToastQueue | `queue: HeroToastQueue?` (default global) |
| `Provider.children` | node \| `({toast})=>node` | `builder: (context, HeroQueuedToast) => Widget`, `child` (app) |
| `Provider.aria-label` | string | `semanticLabel` ("Notifications") |
| `Toast.toast` | QueuedToast | `toast: HeroQueuedToast` |
| `Toast.variant` | 5 variants | `variant: HeroToastVariant` |
| `Toast.placement` / `scaleFactor` | inherited | `placement`, `scaleFactor` |
| `Indicator.variant` / `children` | | `variant`, `child` |
| `Title/Description/Content.children` | ReactNode | `child`/`children` |
| `ActionButton` | Button props | HeroButton params (`onPressed`, `variant`, `child`) |
| `CloseButton` | CloseButton props | HeroCloseButton params |
| `ToastQueue({exitDuration, maxVisibleToasts, wrapUpdate})` | 300 / 3 / fn | `HeroToastQueue({Duration exitDuration, int maxVisibleToasts})` |
| `queue.add/update/close/pauseAll/resumeAll/clear/subscribe` | methods | same names; `subscribe` → `ChangeNotifier.addListener` |
| `toast(title, {description, variant, indicator, actionProps, isLoading, timeout, onClose})` | | `heroToast(title, description:, variant:, indicator:, action: HeroToastAction(label, onPressed, variant), isLoading:, timeout: Duration, onClose:)` → `String` key |
| `toast.success/info/warning/danger` | | `heroToast.success(...)` etc. |
| `toast.promise(p, {loading, success, error})` | | `heroToast.promise<T>(Future<T>, loading:, success: (T)=>String, error: (Object)=>String)` |
| `toast.update(id, msg, opts)` | | `heroToast.update(key, title, ...)` |

- **States & behaviour:** auto-dismiss after `timeout` (4s); timers pause while region hovered/focused and while app is in background
  (`AppLifecycleState`); `onClose` fires when exit starts. Region expands on pointer hover (not touch) or focus-within; Esc collapses.
  Alt+T focuses region & expands; F6 landmark cycling (optional). Dismissing a focused toast moves focus to nearest remaining toast. Promise:
  loading toast (spinner, persistent) updates in place to success/danger with 4s timeout. Semantics: region `SemanticsRole.region`/label
  "Notifications"; each toast `liveRegion: true` + alertDialog role.
- **Docs examples:** `toast-default` (Persons indicator, title+description, "Dismiss" tertiary action) · `toast-variants` (default, accent/info
  "Upgrade", success "Billing", warning, danger) · `toast-placements` (6 providers/queues, one per placement) · `toast-expanded`
  (isExpanded provider, 3 staggered toasts at 0/400/800ms) · `toast-simple` (Default, Success, Info, Warning, Error title-only) ·
  `toast-custom-indicator` (Star icon) · `toast-custom-toast` (provider builder with bordered radius-12 toast, close button vertically
  centered at end) · `toast-promise` (toast.promise success/failure/random + manual isLoading then update) · `toast-callbacks` (3s/10s
  timeouts, onClose history list) · `toast-custom-queue` (3 queues: max 2 bottom, max 3 bottom-start danger, max 1 bottom-end success) ·
  `toast-custom-styles` (bordered surface, shadow-lg, custom icon/title layout).
- **Depends on:** root overlay host (topmost), HeroButton, HeroCloseButton, HeroSpinner, icon set.

#### Dropdown (+ Menu, MenuItem, MenuSection) → `HeroDropdown`
- **Docs:** https://heroui.com/en/docs/react/components/dropdown · **Category:** Collections
- **Anatomy:** `Dropdown` → `HeroDropdown` (MenuTrigger state; first child = trigger); `Dropdown.Trigger` → `HeroDropdownTrigger` (custom
  pressable trigger, `builder` gets press/hover/focus state); `Dropdown.Popover` → `HeroDropdownPopover`; `Dropdown.Menu` → `HeroDropdownMenu`;
  `Dropdown.Section` → `HeroDropdownSection`; `Dropdown.Item` → `HeroDropdownItem`; `Dropdown.ItemIndicator` → `HeroDropdownItemIndicator`;
  `Dropdown.SubmenuTrigger` → `HeroDropdownSubmenuTrigger` (children: item + nested popover); `Dropdown.SubmenuIndicator` →
  `HeroDropdownSubmenuIndicator`. Item content uses `HeroLabel`, `HeroDescription`, `HeroKbd(slot: keyboard)`, `HeroHeader`, `HeroSeparator`.
  Source-only primitives (Dropdown parts are thin wrappers): `Menu` → `HeroMenu`, `MenuItem` → `HeroMenuItem`, `MenuItem.Indicator` →
  `HeroMenuItemIndicator`, `MenuItem.SubmenuIndicator` → `HeroMenuItemSubmenuIndicator`, `MenuSection` → `HeroMenuSection` (usable inline
  without a popover).
- **Variants:** `trigger` `HeroMenuTriggerType {press*, longPress}`; popover `placement` (docs: bottom*; RAC MenuTrigger context actually
  supplies `bottomStart` when unset — verify visually, default to `bottomStart`), offset 8; menu `selectionMode` `{none*, single, multiple}`;
  item `variant` `HeroMenuItemVariant {standard*, danger}`; item indicator `type` `HeroMenuItemIndicatorType {checkmark*, dot}`.
- **Key styles:**
  - Popover: bg `overlay`, radius 24, shadow `overlay`, padding 0, text-sm, max-width 48% of screen width, min-width 220 at ≥768,
    vertical scroll (scroll padding 4). Pop animation (150ms, scale .9, 4px; exit 100ms .95). Menu inside popover: padding 6, column gap 2;
    items inside popover use horizontal padding 10. Separator inside menu: 94% width, start margin 3%.
  - Standalone `HeroMenu`: column gap 4, padding 4, clip; `HeroMenuSection`: column, gap 0.
  - Item: min-height 36, row gap 12, radius 16, padding 8×6 (10 in popover), pointer; hover bg `default`; pressed scale .98
    (transform 250ms ease-out-quart); keyboard focus → focus ring; disabled opacity .5; label/description not selectable.
  - With selection indicator: item start padding 28; indicator absolute at start 8, 16×16 box, color `muted`, vertically centered.
    checkmark 10×10 (dash draw 66→44; 100ms linear when selected, 300ms transition-all in multiple mode); dot 8×8 filled circle, hidden
    scale .7 opacity 0 → selected scale 1 opacity 1 (250ms).
  - Submenu item: padding start 8 / end 28, submenu indicator (chevron-right) at end 8, glyph 14px, `muted`.
  - Danger variant: label + indicator `danger`.
  - Dropdown.Trigger (custom): focus ring, pressed scale .97 (250ms ease-out-quart), disabled .5, pending → no hit.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `Dropdown.isOpen` / `defaultOpen` / `onOpenChange` | | `isOpen`, `defaultOpen`, `onOpenChanged` |
| `Dropdown.trigger` | "press" \| "longPress" | `trigger: HeroMenuTriggerType` |
| `Dropdown.children` | ReactNode | `child` (trigger) + `popover: HeroDropdownPopover` |
| `Trigger.children` | node \| render fn | `child` / `builder` |
| `Popover.placement` | 22 placements | `placement: HeroPlacement` |
| `Popover.children` (+ RAC Popover props: offset, shouldFlip…) | | `child`/`children`, `offset`, `shouldFlip` |
| `Menu.selectionMode` | none/single/multiple | `selectionMode: HeroSelectionMode` (none) |
| `Menu.selectedKeys` / `defaultSelectedKeys` / `onSelectionChange` | Selection | `selectedKeys`, `defaultSelectedKeys`, `onSelectionChanged` (Set<Object>) |
| `Menu.disabledKeys` | Iterable<Key> | `disabledKeys: Set<Object>` |
| `Menu.onAction` | (key)=>void | `onAction: ValueChanged<Object>` |
| `Menu.children` / `items` | | `children` / `items` + `itemBuilder` |
| `Section.selectionMode` / `selectedKeys` / `defaultSelectedKeys` / `onSelectionChange` / `disabledKeys` | | same names (section-scoped selection) |
| `Item.id` | Key | `id: Object` |
| `Item.textValue` | string | `textValue` (typeahead + a11y) |
| `Item.variant` | default/danger | `variant: HeroMenuItemVariant` |
| `Item.children` | node \| render fn | `children` / `builder(context, HeroMenuItemState{isSelected,isFocused,isDisabled,isPressed})` |
| (RAC) `Item.isDisabled` / `onAction` / `href` / `shouldCloseOnSelect` | | `isDisabled`, `onAction`, `href`/`onPressed`, `shouldCloseOnSelect` |
| `ItemIndicator.type` | checkmark/dot | `type: HeroMenuItemIndicatorType` |
| `ItemIndicator.children` | node \| fn({isSelected,isIndeterminate}) | `child` / `builder(context, isSelected, isIndeterminate)` |
| `SubmenuIndicator.children` | ReactNode | `child` (default chevron-right) |
| `SubmenuTrigger.children` (+ RAC `delay`) | item + popover | `item`, `popover`, `delay` (200ms) |

- **States & behaviour:** press (or long-press ≥500ms for `longPress`; Alt+ArrowDown with keyboard) opens; Enter/Space/ArrowDown open and
  focus first item, ArrowUp focuses last. In menu: Up/Down move (no wrap), Home/End, typeahead, Enter/Space activate → `onAction` then close
  (stays open in `multiple` mode); Esc / outside press / Tab close; focus returns to trigger. Selection toggles per mode (sections may own
  their own mode). Submenus: hover 200ms, ArrowRight (LTR) / Enter / Space open (focus first child); ArrowLeft / Esc close submenu; submenu
  popover placement `endTop`, non-modal. Semantics: menu `SemanticsRole.menu`; item `menuItem` / `menuItemCheckbox` (multiple) /
  `menuItemRadio` (single) with `checked`; section = group labelled by header.
- **Docs examples:** `dropdown-default` (4 actions, last danger) · `dropdown-with-icons` (leading icons + ⌘ shortcuts Kbd light) ·
  `dropdown-with-descriptions` (icon + label/description + Kbd) · `dropdown-with-disabled-items` (sections, disabledKeys delete-file) ·
  `dropdown-with-sections` (Actions / separator / Danger zone) · `dropdown-with-multiple-selection` (fruits, checkmark indicators, min-w 256) ·
  `dropdown-controlled` (multiple Bold/Italic/Underline, "Selected:" text) · `dropdown-controlled-open-state` (isOpen state text) ·
  `dropdown-with-single-selection` (fruits single) · `dropdown-single-with-custom-indicator` (render-fn indicator with filled check-circle) ·
  `dropdown-with-section-level-selection` (Actions + Text Style multiple + Text Alignment single with dot indicators) ·
  `dropdown-with-keyboard-shortcuts` · `dropdown-with-submenus` (Share → WhatsApp/Telegram/Discord/Email → Work/Personal) ·
  `dropdown-with-custom-submenu-indicator` (ArrowRight icon / custom svg chevron) · `dropdown-custom-trigger` (avatar trigger, profile header
  above menu, trailing icons, danger Log Out) · `dropdown-long-press-trigger` · `dropdown-custom-styles` (surface popover radius 12, border,
  items radius 8 with focused bg).
- **Depends on:** HeroPositioner/pop animation, collection model, HeroLabel, HeroDescription, HeroKbd, HeroHeader, HeroSeparator, HeroButton,
  HeroAvatar, icon set.

#### ListBox (+ ListBoxItem, ListBoxSection) → `HeroListBox`
- **Docs:** https://heroui.com/en/docs/react/components/list-box · **Category:** Collections
- **Anatomy:** `ListBox` → `HeroListBox`; `ListBox.Item` → `HeroListBoxItem`; `ListBox.ItemIndicator` → `HeroListBoxItemIndicator`;
  `ListBox.Section` → `HeroListBoxSection` (with `HeroHeader`); `ListBoxLoadMoreItem` → `HeroListBoxLoadMoreItem`; `Virtualizer`+`ListLayout`
  → `HeroListBox(virtualized: true, rowHeight: 48, headingHeight: 48)` (lazy `ListView.builder`).
- **Variants:** `selectionMode` `{none, single, multiple}` (docs claim single*; source passes RAC default **none***); root `variant`
  `{standard*, danger}` (no CSS effect at root); item `variant` `{standard*, danger}`.
- **Key styles:** root padding 4, full width, clip; 4px spacing between direct children (not flex gap); horizontal separator 94% width,
  start 3%. Item: min-height 36, row gap 12, radius 16, padding 8×6, pointer; with indicator end padding 28; hover bg `default`; pressed
  scale .98 (250ms ease-out-quart); keyboard focus ring; disabled .5; danger → label + indicator `danger`. Indicator: absolute end 8, 16×16,
  `default-foreground`; checkmark 10×10 with dash draw 66→44 (250ms linear; transition-all 300ms). No selected background (indicator only).
  Inside Select/ComboBox/Autocomplete popovers: list padding 6, item horizontal padding 10, and the checkmark animation is disabled for
  single-select lists.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `aria-label` / `aria-labelledby` | string | `semanticLabel` |
| `selectionMode` | none/single/multiple | `selectionMode: HeroSelectionMode` |
| `selectedKeys` / `defaultSelectedKeys` / `onSelectionChange` | Selection | `selectedKeys`, `defaultSelectedKeys`, `onSelectionChanged` |
| `disabledKeys` | Iterable<Key> | `disabledKeys` |
| `onAction` | (key)=>void | `onAction` |
| `variant` | default/danger | `variant: HeroListBoxVariant` |
| `children` / `items` | ReactNode / Iterable | `children` / `items` + `itemBuilder` |
| (RAC) `renderEmptyState` | ()=>node | `emptyStateBuilder` |
| `render` | render fn | `builder` |
| `Item.id` / `textValue` / `isDisabled` / `variant` | | `id`, `textValue`, `isDisabled`, `variant` |
| `Item.children` | node \| render fn | `children` / `builder(context, HeroListBoxItemState)` |
| `Item.render` | fn | `builder` |
| `ItemIndicator.children` | node \| fn({isSelected}) | `child` / `builder(context, isSelected)` |
| `Section.children` | ReactNode | `header` + `children` |
| `ListLayout.rowHeight`/`headingHeight`/`gap`/`padding` | numbers (48/48/0/0) | `rowHeight`, `headingHeight`, `itemSpacing`, `padding` (virtualized) |

- **States & behaviour:** Up/Down move focus (no wrap), Home/End, PageUp/PageDown, typeahead; single: press/Enter/Space selects (replace);
  multiple: toggle (checkbox-like), Shift+arrows extend, Ctrl/Cmd+A select all; `none` + `onAction` → action list. Disabled items skipped.
  Semantics: list `SemanticsRole.list` (listbox), item `selected`/`enabled`, `onTap`.
- **Docs examples:** `list-box-default` (3 users: avatar + name/email + indicator, single, w 220) · `list-box-with-disabled-items` (sections with
  icon/label/description/Kbd, delete disabled, in Surface 256 radius 24) · `list-box-with-sections` (Actions / separator / Danger zone) ·
  `list-box-multi-select` · `list-box-controlled` (multiple with custom Check indicator, "Selected" text) · `list-box-virtualization` (1000
  users, rowHeight 50, 400×300) · `list-box-custom-check-icon` (render-fn Check icon accent-soft-foreground) · `list-box-render-function` ·
  `list-box-custom-styles` (surface card radius 12, items radius 8, focused accent/10, selected accent/5).
- **Depends on:** collection model, HeroLabel, HeroDescription, HeroHeader, HeroSeparator, HeroKbd, HeroAvatar, HeroSurface.

#### TagGroup (+ Tag) → `HeroTagGroup`
- **Docs:** https://heroui.com/en/docs/react/components/tag-group · **Category:** Collections
- **Anatomy:** `TagGroup` → `HeroTagGroup` (column with optional `HeroLabel`, list, `HeroDescription`, `HeroErrorMessage`; convenience params
  `label`, `description`, `errorMessage`); `TagGroup.List` → `HeroTagGroupList`; `Tag` → `HeroTag`; `Tag.RemoveButton` → `HeroTagRemoveButton`.
- **Variants:** `size` `HeroSize {sm, md*, lg}`; `variant` `HeroTagVariant {standard*, surface}` (both set on group, inherited by tags);
  `selectionMode` `{none*, single, multiple}`; `isDisabled`.
- **Key styles:** group column gap 4; list wrap, gap 6; description/error padding 4. Tag: inline row gap 4, radius 12, weight 500, not
  selectable; md padding 8×4 text-xs; sm 8×2 text-xs; lg radius 16, 10×6 text-sm; icons 12px current color. standard: bg `default`,
  fg `default-foreground`, hover `default-hover`; surface: bg `surface`, fg `surface-foreground`, hover `surface-hover`; selected: bg
  `accent-soft`, fg `accent-soft-foreground`, hover `accent-soft-hover`; disabled .5; focus ring. Transitions 100ms (`ease`; shadow ease-out).
  Remove button: 12×12 close glyph, inherits color, hit target 24×24 (centered, via padding/`MaterialTapTargetSize`-like).
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `selectionMode` | none/single/multiple | `selectionMode` |
| `selectedKeys` / `defaultSelectedKeys` / `onSelectionChange` | Selection | `selectedKeys`, `defaultSelectedKeys`, `onSelectionChanged` |
| `disabledKeys` | Iterable<Key> | `disabledKeys` |
| `isDisabled` | boolean | `isDisabled` |
| `onRemove` | (keys: Set<Key>)=>void | `onRemove: ValueChanged<Set<Object>>` |
| `size` | sm/md/lg | `size: HeroSize` |
| `variant` | default/surface | `variant: HeroTagVariant` |
| `children` / `render` | node \| fn | `children` (+ `label`, `description`, `errorMessage`), `builder` |
| `List.items` | Iterable<T> | `items` + `itemBuilder` |
| `List.renderEmptyState` | ()=>node | `emptyStateBuilder` |
| `List.children` / `render` | | `children` / `builder` |
| `Tag.id` / `textValue` / `isDisabled` | | `id`, `textValue`, `isDisabled` |
| `Tag.children` | node \| fn(renderProps incl. `allowsRemoving`) | `children` / `builder(context, HeroTagState{isSelected,isDisabled,isHovered,isPressed,isFocused,isFocusVisible,allowsRemoving})` |
| `RemoveButton.children` | ReactNode | `child` (custom icon) |

- **States & behaviour:** tags are a grid list: Left/Right (and Up/Down) move focus, Home/End; Space/Enter/press toggle selection by mode;
  Delete/Backspace remove focused tag (or all selected) when `onRemove` set; with `onRemove` a remove button is auto-appended unless a custom
  `HeroTagRemoveButton` is present. Semantics: group `SemanticsRole.list` labelled by Label; tag `selected`, remove button label "Remove tag".
- **Docs examples:** `tag-group-basic` (icons + text, single) · `tag-group-sizes` (sm/md/lg with labels) · `tag-group-variants` (default,
  surface) · `tag-group-disabled` (isDisabled tags; disabledKeys) · `tag-group-selection-modes` (single, multiple controlled) ·
  `tag-group-controlled` (Selected: text) · `tag-group-with-error-message` (multiple; error when none selected) · `tag-group-with-list-data`
  (avatar tags, removable, selected list below) · `tag-group-with-prefix` (icons; 16px avatars) · `tag-group-with-remove-button` (default X;
  custom CircleXmarkFill via render props; EmptyState when empty) · `tag-group-render-function` · `tag-group-custom-styles` (gap 8 list).
- **Depends on:** collection model, HeroCloseButton, HeroLabel, HeroDescription, HeroErrorMessage, HeroEmptyState (p 8, 14px muted), HeroAvatar.

#### Select → `HeroSelect`
- **Docs:** https://heroui.com/en/docs/react/components/select · **Category:** Pickers
- **Anatomy:** `Select` → `HeroSelect` (column; convenience `label`, `description`, `errorMessage`, `placeholder`, `items`/`itemBuilder`);
  `Select.Trigger` → `HeroSelectTrigger`; `Select.Value` → `HeroSelectValue`; `Select.ClearButton` → `HeroSelectClearButton`;
  `Select.Indicator` → `HeroSelectIndicator`; `Select.Popover` → `HeroSelectPopover` (contains a `HeroListBox`). Label/Description/
  FieldError are the shared form parts.
- **Variants:** `variant` `HeroFieldVariant {primary*, secondary}`; `fullWidth` false*; `selectionMode` `{single*, multiple}`; popover
  `placement` bottom*; booleans `isDisabled`, `isRequired`, `isInvalid`.
- **Key styles:**
  - Root: column gap 4; label hugs content; description hidden while invalid; `fullWidth` → root + trigger width 100%.
  - Trigger: min-height 36, radius 12 (`rounded-field`), border width `field-border-width` (0 default) color `field-border`, bg `field`
    (white / dark field), padding 12×8, text-sm, fg `field-foreground`, shadow `field`; end padding 28 when indicator present. Hover (not over
    clear button): bg `field-hover`, border `field-border-hover`. Keyboard focus: focus ring (2px + 2px gap), border `field-border-focus`,
    bg `field-focus`. Invalid: danger field ring (1px outline / 2px when focused), bg `field-focus`. Disabled .5. Transitions: bg/border 150ms
    ease, shadow 150ms ease-out. Secondary variant: no shadow, bg `default`, hover `default-hover`, focus/invalid bg `default`.
  - Value: flex 1, start aligned, text 16 (<640) / 14 (≥640), wraps; placeholder color `field-placeholder`; list-item indicators hidden.
  - Indicator: chevron-down 16×16, absolute end 8 vertically centered, `field-placeholder`; rotates 180° when open (150ms, tw default curve).
  - ClearButton: 20×20 (hit 24), radius 12, padding 4, `muted`, glyph 14 (close); opacity 0 + no hit when empty (disappears instantly,
    fades in 150ms); hover bg `default-hover`; pressed scale .93.
  - Popover: min-width = trigger width, bg `overlay`, radius 24, shadow `overlay`, scrollable; list padding 6, items padding-x 10.
    Pop animation with scale .95 (enter 150ms ease + 4px slide; exit 100ms). Offset 8.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `placeholder` | string ('Select an item') | `placeholder` |
| `selectionMode` | single/multiple | `selectionMode: HeroSelectionMode` (single) |
| `isOpen` / `defaultOpen` / `onOpenChange` | | `isOpen`, `defaultOpen`, `onOpenChanged` |
| `disabledKeys` | Iterable<Key> | `disabledKeys` |
| `isDisabled` / `isRequired` / `isInvalid` | boolean | same |
| `value` / `defaultValue` | Key \| Key[] \| null | `value` / `defaultValue` (`Object?`; `List<Object>` when multiple) |
| `onChange` | (value)=>void | `onChanged: ValueChanged<Object?>` |
| `onClear` | ()=>void | `onClear: VoidCallback` |
| `name` | string | `name` (HeroForm value key) |
| `autoComplete` | string | `autofillHints` |
| `fullWidth` | boolean | `fullWidth` |
| `variant` | primary/secondary | `variant: HeroFieldVariant` |
| `children` / `render` | node \| fn | `children` / `builder` |
| (forms) | | `validator`, `onSaved`, `autovalidateMode` |
| `Trigger.children` | node \| fn | `children` / `builder` |
| `Value.children` | node \| fn({defaultChildren,isPlaceholder,state,selectedItems}) | `builder(context, HeroSelectValueState{defaultChild,isPlaceholder,selectedItems})` |
| `Indicator.children` | ReactNode | `child` (custom icon; size via `size`) |
| `ClearButton.children` / `onClick` | | `child`, `onPressed` |
| `Popover.placement` / `children` | | `placement`, `child` |

- **States & behaviour:** press/Enter/Space/ArrowDown/ArrowUp on trigger open (focus selected or first/last item); typeahead on the closed
  trigger selects matching item (single); in list: arrows/Home/End/typeahead, Enter/Space/press select; single closes on select, multiple stays
  open (value shows selected item texts joined with locale list separators, e.g. "Argentina, Japan"); Esc/outside press/Tab close and return
  focus to trigger. With a ClearButton, Backspace/Delete on the focused trigger clear; clear button is a pointer-only affordance (excluded from
  semantics) and never opens the popover. Semantics: trigger `button` with `expanded`, value + label; list as ListBox; `SemanticsRole.comboBox` n/a.
- **Docs examples:** `select-default` (State, 6 US states, w 256) · `select-variants` (primary, secondary) · `select-full-width` ·
  `select-with-description` · `select-required` (Form + FieldError, 2 required selects + submit) · `select-disabled` (single & multiple with
  default values) · `select-with-disabled-options` (cat, kangaroo) · `select-multiple-select` (countries) · `select-with-sections`
  (North America / Europe / Asia headers + separators) · `select-controlled` ("Selected:" text) · `select-controlled-multiple` ·
  `select-controlled-open-state` (external Open/Close button) · `select-asynchronous-loading` (paged Pokémon list + load-more spinner row) ·
  `select-custom-indicator` (ChevronsExpandVertical 12px) · `select-with-clear-button` (default california) · `select-custom-value`
  (avatar + name value; "N users selected") · `select-render-function` · `select-on-surface` (secondary inside Surface form) ·
  `select-custom-styles` (w 224, trigger radius 12 bg default, bordered popover).
- **Depends on:** HeroPositioner/pop animation, HeroListBox (+ load-more), HeroLabel, HeroDescription, HeroFieldError, HeroForm, HeroHeader,
  HeroSeparator, HeroSpinner, HeroSurface, HeroAvatar, HeroButton.

#### ComboBox → `HeroComboBox`
- **Docs:** https://heroui.com/en/docs/react/components/combo-box · **Category:** Pickers
- **Anatomy:** `ComboBox` → `HeroComboBox` (convenience `label`, `description`, `errorMessage`, `placeholder`); `ComboBox.InputGroup` →
  `HeroComboBoxInputGroup` (children: `HeroInput` + `HeroComboBoxTrigger`); `ComboBox.Trigger` → `HeroComboBoxTrigger`; `ComboBox.Value` →
  `HeroComboBoxValue` (selected values display, mainly multiple); `ComboBox.Popover` → `HeroComboBoxPopover` (contains `HeroListBox`).
- **Variants:** `variant` `HeroFieldVariant {primary*, secondary}` (exists in source, missing from API table; forwarded to the Input);
  `fullWidth` false*; `selectionMode` `{single*, multiple}`; `menuTrigger` `HeroComboBoxMenuTrigger {focus*, input, manual}` (HeroUI default
  focus; RAC default is input); `formValue` `{key*, text}`; `validationBehavior` `{native*, aria}`; popover placement bottom*.
- **Key styles:** root column gap 4, label hugs content, description hidden while invalid. Input group: relative row, centered; input flexes
  (min-width 0) with end padding 28 when the trigger follows; input focus uses field focus ring (2px, no gap), border `field-border-focus`, bg
  `field-focus`; disabled .5. Trigger: absolute end 0, full height, padding-end 8, transparent, `field-placeholder` color → `field-foreground`
  on hover, pressed opacity .7, disabled opacity .5; keyboard focus → 2px focus ring with 2px offset, radius 4; chevron 16px rotates 180° when
  open (150ms). Value: text-sm, `field-foreground`, hidden when empty; placeholder `field-placeholder`. Popover: min-width = input-group width,
  same look/animation as Select popover (radius 24, overlay shadow, scale .95, list padding 6, items px 10, no checkmark animation).
  `fullWidth` → root + group width 100%.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `inputValue` / `defaultInputValue` / `onInputChange` | string | `inputValue`, `defaultInputValue`, `onInputChanged` (+ `controller: TextEditingController`, `focusNode`) |
| `selectionMode` | single/multiple | `selectionMode` |
| `selectedKey` / `defaultSelectedKey` / `onSelectionChange` | Key \| null | `selectedKey`, `defaultSelectedKey`, `onSelectionChanged: ValueChanged<Object?>` |
| `value` / `defaultValue` / `onChange` | Key \| null \| Key[] | `value`, `defaultValue`, `onChanged` |
| `items` | Iterable<T> | `items` + `itemBuilder` |
| `disabledKeys` | Iterable<Key> | `disabledKeys` |
| `defaultFilter` | (text, input)=>bool | `filter: bool Function(String text, String input)` (default: locale-insensitive `contains`) |
| `isDisabled` / `isReadOnly` / `isRequired` / `isInvalid` | boolean | same |
| `validate` | fn | `validator` (+ `onSaved`, `autovalidateMode`) |
| `validationBehavior` | native/aria | `validationBehavior: HeroValidationBehavior` |
| `name` / `form` | string | `name` (`form` n/a) |
| `formValue` | text/key | `formValue: HeroComboBoxFormValue` |
| `autoComplete` / `autoFocus` | | `autofillHints`, `autofocus` |
| `allowsCustomValue` | boolean | `allowsCustomValue` |
| `allowsEmptyCollection` | boolean | `allowsEmptyCollection` |
| `menuTrigger` | focus/input/manual | `menuTrigger: HeroComboBoxMenuTrigger` |
| `shouldFocusWrap` | boolean | `shouldFocusWrap` |
| `fullWidth` / `variant` | | `fullWidth`, `variant` |
| `children` / `render` | node \| fn(state) | `children` / `builder(context, HeroComboBoxState{inputValue,selectedKey,selectedItem})` |
| `InputGroup.children` | Input + Trigger | `children` |
| `Value.placeholder` / `children` | node / fn(ComboBoxValueRenderProps) | `placeholder`, `builder(context, HeroComboBoxValueState)` |
| `Trigger.children` | ReactNode | `child` (custom icon) |
| `Popover.placement` / `children` | | `placement`, `child` |

- **States & behaviour:** typing filters items (`filter`), opens per `menuTrigger` (focus: on focus; input: on typing; manual: only via trigger
  button / Up/Down arrows); Up/Down move virtual focus (focus stays in text field), Enter selects and closes (single; input text becomes
  item text), Esc closes then resets input to the selected item's text; blur commits (reverts text unless `allowsCustomValue`); multiple mode:
  selecting toggles, popover stays open, input clears, `HeroComboBoxValue` shows comma-joined selection. Empty filtered list hides popover
  unless `allowsEmptyCollection` (shows empty state). Semantics: text field with `SemanticsRole.comboBox`, `expanded`; list as ListBox.
- **Docs examples:** `combo-box-default` (Favorite Animal, "Search animals...") · `combo-box-full-width` · `combo-box-with-description` ·
  `combo-box-required` (Form + FieldError) · `combo-box-disabled` (default cat) · `combo-box-with-disabled-options` · `combo-box-with-sections`
  (countries by region) · `combo-box-controlled` (selectedKey) · `combo-box-controlled-input-value` · `combo-box-asynchronous-loading`
  (Star Wars API, filterText-driven, load-more, EmptyState, allowsEmptyCollection) · `combo-box-default-selected-key` · `combo-box-allows-custom-value`
  · `combo-box-custom-indicator` (ChevronsExpandVertical 12px) · `combo-box-custom-value` (avatar/name/email items) ·
  `combo-box-custom-filtering` (case-insensitive includes) · `combo-box-render-function` · `combo-box-menu-trigger` (focus / input / manual) ·
  `combo-box-multiple-selection` (ComboBox.Value "No animals selected") · `combo-box-on-surface` (secondary in Surface form) ·
  `combo-box-custom-styles` (bordered surface input group with focus-within ring, muted trigger, bordered popover).
- **Depends on:** HeroInput (field styles), HeroListBox (+ load-more), HeroPositioner, HeroLabel, HeroDescription, HeroFieldError, HeroForm,
  HeroEmptyState, HeroAvatar, HeroSurface.

#### Autocomplete → `HeroAutocomplete`
- **Docs:** https://heroui.com/en/docs/react/components/autocomplete · **Category:** Pickers
- **Anatomy:** `Autocomplete` → `HeroAutocomplete` (select-like field whose popover contains a search field + list); `Autocomplete.Trigger` →
  `HeroAutocompleteTrigger` (a group, not a button; value may contain tags); `Autocomplete.Value` → `HeroAutocompleteValue`;
  `Autocomplete.ClearButton` → `HeroAutocompleteClearButton` (real button); `Autocomplete.Indicator` → `HeroAutocompleteIndicator`;
  `Autocomplete.Popover` → `HeroAutocompletePopover`; `Autocomplete.Filter` → `HeroAutocompleteFilter` (wraps `HeroSearchField` +
  `HeroListBox`, connects typing to list filtering with virtual focus); `useFilter` → `HeroFilter({sensitivity})` with
  `contains/startsWith/endsWith`.
- **Variants:** `variant` `HeroFieldVariant {primary*, secondary}`; `fullWidth` false*; `selectionMode` `{single*, multiple}`;
  `allowsEmptyCollection` false*; popover placement bottom*; `HeroFilterSensitivity {base*, accent, case, variant}`.
- **Key styles:** trigger/value/indicator/clear button identical to Select (min-height 36, radius 12, field colors, padding 12×8, end padding 28,
  hover/focus/invalid/disabled, secondary variant bg `default`, value 16/14 responsive, chevron 16 rotating 180°, clear 20×20 radius 12 glyph 14,
  hidden when empty, pressed .93). Indicator is pointer-cursored. Popover: width = trigger width exactly (min = max), column, clip, padding-top 8,
  bg `overlay`, radius 24, shadow `overlay`; enter 250ms `ease-out-fluid` fade + scale .95→1 + 4px slide; exit 100ms `ease-out-quad` scale .95
  fade. Search field row: padding 12×4, never shrinks; list: max-height 320 (can shrink), scrolls, padding 6, items px 10; empty state:
  centered 14px `overlay-foreground`@60%. Single-select lists: checkmark animation off.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `placeholder` | string ('Select an item') | `placeholder` |
| `selectionMode` | single/multiple | `selectionMode` |
| `allowsEmptyCollection` | boolean | `allowsEmptyCollection` |
| `isOpen` / `defaultOpen` / `onOpenChange` | | `isOpen`, `defaultOpen`, `onOpenChanged` |
| `disabledKeys` | Iterable<Key> | `disabledKeys` |
| `isDisabled` / `isRequired` / `isInvalid` | boolean | same (+ `validator`, `onSaved`, `autovalidateMode`) |
| `value` / `defaultValue` / `onChange` | Key \| Key[] \| null | `value`, `defaultValue`, `onChanged` |
| (source) `onClear` | ()=>void | `onClear` |
| `name` | string | `name` |
| `fullWidth` / `variant` | | `fullWidth`, `variant` |
| `children` | node \| fn | `children` / `builder` |
| `Trigger.children` | node \| fn | `children` / `builder` |
| `Value.children` | node \| fn({defaultChildren,isPlaceholder,state,selectedItems,selectedText}) | `builder(context, HeroAutocompleteValueState{defaultChild,isPlaceholder,selectedItems,selectedText})` |
| `Indicator.children` | ReactNode | `child` |
| `ClearButton.onClick` / `ref` | | `onPressed`, `focusNode` |
| `Popover.placement` / `children` | | `placement`, `child` |
| `Filter.filter` | (text,input)=>bool | `filter` |
| `Filter.inputValue` / `onInputChange` | string | `inputValue`, `onInputChanged` |
| `Filter.children` | SearchField + ListBox | `children` |

- **States & behaviour:** press on trigger (or Enter/Space/Arrow keys) opens popover; search field autofocuses; typing filters list; Up/Down
  move virtual focus in list while caret stays in field; Enter/press selects; single closes, multiple stays open (default value text joins
  selected item texts with locale separators; demos render removable `HeroTag`s in the trigger); Esc/outside press close; clear button clears
  and fires `onClear` (pressing it does not open the popover). Semantics: trigger button w/ `expanded`; search field textField; list listbox.
- **Docs examples:** `autocomplete-default` (multiple states with removable sm tags in trigger, search + EmptyState) · `autocomplete-variants` ·
  `autocomplete-full-width` · `autocomplete-with-description` · `autocomplete-required` · `autocomplete-disabled` · `autocomplete-with-disabled-options`
  · `autocomplete-allows-empty-collection` (empty list + "No results found") · `autocomplete-with-sections` · `autocomplete-multiple-select`
  (tags + clear button) · `autocomplete-controlled` · `autocomplete-controlled-multiple` · `autocomplete-controlled-open-state` ·
  `autocomplete-asynchronous-filtering` (Star Wars API, sticky search, spinner swapping with clear button, list max-h 420) ·
  `autocomplete-custom-indicator` · `autocomplete-custom-value` (currency symbol/code/name value) · `autocomplete-on-surface` ·
  `autocomplete-virtualization` (large user list, rowHeight 50, sticky search) · `autocomplete-user-selection` (avatar value) ·
  `autocomplete-user-selection-multiple` (avatar tags) · `autocomplete-location-search` (city/country items, "Searching..." empty state) ·
  `autocomplete-tag-group-selection` · `autocomplete-email-recipients` (email tags) · `autocomplete-custom-styles` (bordered surface trigger with
  accent focus-within ring, accent tags, bordered popover).
- **Depends on:** Select trigger styling (share code), HeroSearchField (secondary), HeroListBox (virtualized), HeroTagGroup/HeroTag (sm),
  HeroEmptyState, HeroSpinner, HeroAvatar, HeroPositioner, HeroLabel/HeroDescription/HeroFieldError, HeroSurface.

#### Accordion → `HeroAccordion`
- **Docs:** https://heroui.com/en/docs/react/components/accordion · **Category:** Navigation
- **Anatomy:** `Accordion` → `HeroAccordion` (DisclosureGroup); `Accordion.Item` → `HeroAccordionItem`; `Accordion.Heading` →
  `HeroAccordionHeading` (header semantics, level 3); `Accordion.Trigger` → `HeroAccordionTrigger`; `Accordion.Indicator` →
  `HeroAccordionIndicator`; `Accordion.Panel` → `HeroAccordionPanel`; `Accordion.Body` → `HeroAccordionBody`. Convenience:
  `HeroAccordionItem(title:, leading:, child:)` builds Heading/Trigger/Indicator/Panel/Body.
- **Variants:** `variant` `HeroAccordionVariant {standard*, surface}`; `hideSeparator` false*; `allowsMultipleExpanded` false*; `isDisabled`
  (group and item).
- **Key styles:** root full width. Item: 1px `separator` line at bottom (full width, radius 2), none on last item or with `hideSeparator`.
  Heading: row. Trigger: expands, row, space-between, padding 16, start-aligned text-sm weight 500, pointer; hover (collapsed only) bg
  `foreground`@3%; keyboard focus ring; disabled .5; opacity/shadow 150ms ease-out. Indicator: default chevron-down 16px, `muted`, pushed to
  end (margin-start auto), rotates −180° when expanded (250ms, `Cubic(.4,0,.2,1)`). Panel: height animates 0 ↔ content height 200ms
  `ease-out-quad` + opacity 0 ↔ 1 200ms tw-`ease-out`, clipped. Body: text-sm; inner padding 16 left/right, 0 top, 16 bottom, `muted`.
  Surface variant: bg `surface`, radius 24; trigger hover bg `default`; first trigger top corners 24; last trigger bottom corners 24 while
  collapsed; separators inset (start 3%, width 94%) color `surface-foreground`@6%.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `allowsMultipleExpanded` | boolean | `allowsMultipleExpanded` |
| `defaultExpandedKeys` / `expandedKeys` / `onExpandedChange` | Iterable<Key> / Set | `defaultExpandedKeys`, `expandedKeys`, `onExpandedChanged: ValueChanged<Set<Object>>` |
| `isDisabled` | boolean | `isDisabled` |
| `variant` | default/surface | `variant: HeroAccordionVariant` |
| `hideSeparator` | boolean | `hideSeparator` |
| `children` / `render` | | `children` / `builder` |
| `Item.id` | Key | `id` |
| `Item.isDisabled` / `defaultExpanded` / `isExpanded` / `onExpandedChange` | | same (`onExpandedChanged: ValueChanged<bool>`) |
| `Item.children` / `render` | | `children` / `builder` |
| `Trigger.children` | node \| fn | `children` / `builder(context, isExpanded)` |
| `Trigger.onPress` / `isDisabled` | | `onPressed`, `isDisabled` |
| `Panel.children` / `render` | | `child` / `builder` |
| `Indicator.children` | ReactNode | `child` (custom icon; still rotates) |
| `Body.children` | ReactNode | `child` |

- **States & behaviour:** trigger press / Enter / Space toggles; single-expand mode collapses others; disabled items/group not toggleable;
  Tab moves between triggers. Semantics: trigger `button` with `expanded` state, heading `header: true`, panel region labelled by trigger.
- **Docs examples:** `accordion-basic` (items with leading icons + ChevronDown indicator) · `accordion-surface` · `accordion-without-separator` ·
  `accordion-multiple` (Getting Started / Core Concepts / Advanced Usage…) · `accordion-disabled` (entire group; individual items) ·
  `accordion-controlled` (expanded keys text + prev/next buttons) · `accordion-custom-indicator` (Plus/Minus swap, CircleChevronDown, …) ·
  `accordion-render-function` · `accordion-faq` (heading + categories of surface accordions) · `accordion-custom-styles` (44px icon tiles that
  scale 1.2/rotate −10° on hover, title+subtitle triggers, radius 16).
- **Depends on:** Disclosure primitives (shared expand animation), HeroButton (demo), icon set.

#### Disclosure → `HeroDisclosure`
- **Docs:** https://heroui.com/en/docs/react/components/disclosure · **Category:** Navigation
- **Anatomy:** `Disclosure` → `HeroDisclosure`; `Disclosure.Heading` → `HeroDisclosureHeading`; `Disclosure.Trigger` → `HeroDisclosureTrigger`
  (or any `HeroButton(slot: HeroButtonSlot.trigger)` inside the heading, as all demos do); `Disclosure.Indicator` → `HeroDisclosureIndicator`;
  `Disclosure.Content` → `HeroDisclosureContent` (animated panel); `Disclosure.Body` (source only) → `HeroDisclosureBody`.
- **Variants:** none; booleans `isExpanded`/`defaultExpanded`, `isDisabled`.
- **Key styles:** root relative; heading row; trigger inline, pointer, focus ring, disabled .5. Indicator: chevron-down 16px, inherits color,
  margin-start auto, rotates −180° when expanded (250ms `Cubic(.4,0,.2,1)`). Content: height 0 ↔ content height 200ms `ease-out-quad`,
  opacity 0 ↔ 1 200ms tw-`ease-out`, clipped. Body padding 8.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `isExpanded` / (RAC) `defaultExpanded` / `onExpandedChange` | boolean / fn | `isExpanded`, `defaultExpanded`, `onExpandedChanged` |
| `isDisabled` | boolean | `isDisabled` |
| (RAC) `id` | Key | `id` (for DisclosureGroup) |
| `children` / `render` | node \| fn({isExpanded,isDisabled}) | `children` / `builder(context, isExpanded, isDisabled)` |
| `Trigger.children` | node \| fn | `child` / `builder` |
| `Content.children` / `render` | | `child` / `builder` |
| `Indicator.children` | ReactNode | `child` |
| `Body.children` | ReactNode | `child` |

- **States & behaviour:** trigger press / Enter / Space toggles; collapsed content is removed from focus traversal and semantics.
  Semantics: trigger button with `expanded`, content labelled by trigger.
- **Docs examples:** `disclosure-basic` (secondary Button trigger "Preview HeroUI Native" + indicator; body card with QR image + App Store
  button) · `disclosure-render-function` · `disclosure-custom-styles` (full-width gradient bordered trigger, bordered translucent body).
- **Depends on:** HeroButton (slot trigger), HeroSeparator (group demo), icon set; shared expand/collapse animation (also Accordion).

#### DisclosureGroup → `HeroDisclosureGroup`
- **Docs:** https://heroui.com/en/docs/react/components/disclosure-group · **Category:** Navigation
- **Anatomy:** `DisclosureGroup` → `HeroDisclosureGroup` with `HeroDisclosure(id: ...)` children (separators allowed between).
- **Variants:** `allowsMultipleExpanded` false*; `isDisabled` false*.
- **Key styles:** full width container (no own visuals); items keep Disclosure styles.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `expandedKeys` / `defaultExpandedKeys` / `onExpandedChange` | Set<Key> | `expandedKeys`, `defaultExpandedKeys`, `onExpandedChanged: ValueChanged<Set<Object>>` |
| `allowsMultipleExpanded` | boolean | `allowsMultipleExpanded` |
| `isDisabled` | boolean | `isDisabled` |
| `children` | node \| fn({expandedKeys,isDisabled}) | `children` / `builder(context, expandedKeys, isDisabled)` |

- **States & behaviour:** expanding one disclosure collapses others unless `allowsMultipleExpanded`; group disable propagates.
- **Docs examples:** `disclosure-group-basic` (two disclosures "Preview HeroUI Native"/"Download App" whose trigger button switches
  secondary↔tertiary (transparent) with expanded state, separator between) · `disclosure-group-controlled` (external prev/next chevron buttons) ·
  `disclosure-group-custom-styles` (default-soft rounded container, full-width triggers).
- **Depends on:** HeroDisclosure, HeroButton, HeroSeparator.

#### Breadcrumbs → `HeroBreadcrumbs`
- **Docs:** https://heroui.com/en/docs/react/components/breadcrumbs · **Category:** Navigation
- **Anatomy:** `Breadcrumbs` → `HeroBreadcrumbs`; `Breadcrumbs.Item` → `HeroBreadcrumbsItem` (renders a `HeroLink` + trailing separator;
  last item = current page, no separator).
- **Variants:** `isDisabled` false*; custom `separator` widget.
- **Key styles:** root row, centered, gap 6. Item row gap 4. Link (HeroLink + overrides): text-sm, line-height 20, weight 500, `muted`, no
  underline; hover underline (1.5px, offset 4, `muted`@50%). Current item: color `link` (foreground), opacity 1, non-interactive. Separator:
  12×12 chevron-right, `muted`, mirrored in RTL. Disabled: non-current links opacity .5, no interaction.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `separator` | ReactNode (chevron-right) | `separator: Widget?` (sized 12, `muted`) |
| `isDisabled` | boolean | `isDisabled` |
| `children` / `render` | | `children` / `builder` |
| `Item.href` | string | `href` (+ `onPressed`) — omitted/null = current page |
| `Item.children` / `render` | node \| fn | `child` / `builder(context, HeroBreadcrumbState{isCurrent,isDisabled})` |

- **States & behaviour:** Tab through links; Enter activates; current item is `aria-current=page` → Semantics `selected`/label "current page",
  not focusable. Root Semantics: navigation landmark (`SemanticsRole.navigation`), label "Breadcrumbs".
- **Docs examples:** `breadcrumbs-basic` (Home › Products › Electronics › Laptop) · `breadcrumbs-level-2` · `breadcrumbs-level-3` ·
  `breadcrumbs-disabled` · `breadcrumbs-custom-separator` (filled caret svg) · `breadcrumbs-render-function` · `breadcrumbs-custom-styles`
  (default-soft pill container px12 py8, links muted→accent on hover, current foreground).
- **Depends on:** HeroLink, icon set.

#### Link → `HeroLink`
- **Docs:** https://heroui.com/en/docs/react/components/link · **Category:** Navigation
- **Anatomy:** `Link` → `HeroLink`; `Link.Icon` → `HeroLinkIcon` (default external-arrow glyph; place before or after text).
- **Variants:** no variant enum; decoration controls needed for the docs demo: `underline` `HeroLinkUnderline {hover*, always, none}`,
  `underlineOffset` (4*), `decorationColor`; `isDisabled`.
- **Key styles:** inline row, centered, hugs content, radius 12 (focus ring shape), weight 500, color `link` (= foreground), no underline;
  decoration thickness 1.5px, offset 4, default decoration color `separator-tertiary`. Hover: underline, decoration `muted`@50%, icon opacity 1.
  Pressed: underline, decoration `muted`, icon opacity 1. Keyboard focus: focus ring, icon opacity 1. Disabled .5. Transitions: color 100ms ease,
  bg 150ms ease, shadow 150ms ease-out, opacity 100ms ease-out. Icon: 0.75em square, current color, opacity .6 (150ms ease-out to 1); default
  icon (7×7 viewBox arrow, path `M1.20592 6.84333L0.379822 6.01723L4.52594 1.8672H1.37819L1.38601 0.731812H6.48742V5.83714H5.34421L5.35203 2.6933L1.20592 6.84333Z`)
  has margin-start 4 and bottom padding 6 (sits raised). Font size inherits (link has no own size).
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `href` | string | `href` (String/Uri; opened via `HeroLinkHandler`/url_launcher) |
| `target` | string ("_self") | `target: HeroLinkTarget {self*, blank}` |
| `rel` / `download` | string / bool | web-only, omit |
| `isDisabled` | boolean | `isDisabled` |
| `children` | ReactNode | `child` / `children` |
| `onPress` | (e)=>void | `onPressed` |
| `autoFocus` | boolean | `autofocus` |
| `render` | fn | `builder(context, HeroLinkState{isHovered,isPressed,isFocusVisible,isDisabled})` |
| `className` underline utilities (demo) | | `underline`, `underlineOffset`, `decorationColor` |
| `Icon.children` / `className` | ReactNode | `HeroLinkIcon(child:, size:)` |

- **States & behaviour:** press / Enter activates (`onPressed` then href); hover/press/focus visuals as above; cursor click. Semantics: `link: true`,
  `linkUrl`, enabled state.
- **Docs examples:** `link-basic` ("Call to action" + icon) · `link-icon-placement` (icon at end; icon at start with gap 4) ·
  `link-underline-and-offset` (default hover underline; always; none; offsets 1/2/3/4) · `link-custom-icon` (ArrowUpRightFromSquare 12px ms 6;
  Link icon) · `link-render-function` · `link-custom-styles` (neutral-700 text, always underline neutral-300, hover darker).
- **Depends on:** icon set (external-link), focus ring foundation.

#### Pagination → `HeroPagination`
- **Docs:** https://heroui.com/en/docs/react/components/pagination · **Category:** Navigation
- **Anatomy:** `Pagination` → `HeroPagination`; `Pagination.Summary` → `HeroPaginationSummary`; `Pagination.Content` → `HeroPaginationContent`;
  `Pagination.Item` → `HeroPaginationItem`; `Pagination.Link` → `HeroPaginationLink`; `Pagination.Previous` → `HeroPaginationPrevious`;
  `Pagination.Next` → `HeroPaginationNext`; `Pagination.PreviousIcon` → `HeroPaginationPreviousIcon`; `Pagination.NextIcon` →
  `HeroPaginationNextIcon`; `Pagination.Ellipsis` → `HeroPaginationEllipsis`. (Optional helper for demos: `heroPaginationRange(page, total)`
  returning pages + ellipsis markers: 1, …(if page>3), page−1..page+1, …(if page<total−2), total.)
- **Variants:** `size` `HeroSize {sm, md*, lg}`; link `isActive` false*; `isDisabled` false*.
- **Key styles:** root column gap 16 (<640) → row, space-between, centered (≥640), full width. Summary: row gap 8, 14px `muted`, aligned start
  (<640) / center (≥640). Content: row gap 4. Link (ghost button): square, radius 24, 14px weight 500, `default-foreground`, transparent bg →
  hover `default-hover`, pressed `default-hover` + scale .97, active page bg `default`; focus ring; disabled .5; transitions transform 250ms
  ease, bg/shadow 100ms ease-out. Sizes (width=height): md 36 (<768) / 32 (≥768); sm 32/28 text 12, pressed .98; lg 40/36 text 16, pressed .96.
  Prev/Next: auto width, gap 6, padding-x 10 (sm 8, lg 12), chevron icons 16px mirrored in RTL. Ellipsis: same square size, "…", `muted`
  (text size per size), non-interactive, excluded from semantics. Summary text: sm 12, lg 16.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `size` | sm/md/lg | `size: HeroSize` |
| `children` | Summary, Content | `children` |
| `Summary.children` / `Content.children` / `Item.children` | ReactNode | `child` / `children` |
| `Link.isActive` | boolean | `isActive` |
| `Link.isDisabled` | boolean | `isDisabled` |
| `Link.onPress` | (e)=>void | `onPressed` |
| `Link.children` | ReactNode | `child` (page number) |
| `Previous/Next.isDisabled` / `onPress` / `children` | | `isDisabled`, `onPressed`, `children` (icon + label) |
| `PreviousIcon/NextIcon.children` | ReactNode (chevron) | `child` |
| `Ellipsis` | — | `HeroPaginationEllipsis()` |

- **States & behaviour:** stateless — consumer keeps page state. Tab moves through controls; Enter/Space press. Semantics: root navigation
  landmark label "pagination"; active link `selected` ("current page"); ellipsis `ExcludeSemantics`.
- **Docs examples:** `pagination-basic` (Previous 1 2 3 Next) · `pagination-sizes` (sm/md/lg) · `pagination-disabled` (prev/next disabled) ·
  `pagination-simple-prev-next` (summary "1 to 5 of 50 invoices" + Prev/Next) · `pagination-controlled` (12 pages, ellipsis logic, summary) ·
  `pagination-with-ellipsis` · `pagination-with-summary` ("Showing 1-10 of 120 results") · `pagination-custom-icons` (arrow icons, Back/Forward)
  · `pagination-custom-styles` (content in rounded-12 `default` pill with padding 4).
- **Depends on:** icon set (chevrons), focus ring.

#### Tabs → `HeroTabs`
- **Docs:** https://heroui.com/en/docs/react/components/tabs · **Category:** Navigation
- **Anatomy:** `Tabs` → `HeroTabs`; `Tabs.ListContainer` → `HeroTabsListContainer` (pill background + overflow scroll/chevrons);
  `Tabs.List` → `HeroTabsList`; `Tabs.Tab` → `HeroTab`; `Tabs.Indicator` → `HeroTabsIndicator` (shared sliding selection indicator);
  `Tabs.Separator` → `HeroTabsSeparator`; `Tabs.Panel` → `HeroTabsPanel`.
- **Variants:** `variant` `HeroTabsVariant {primary*, secondary}`; `orientation` `Axis {horizontal*, vertical}`; `align` `HeroTabsAlign
  {start, center*, end}`; tab `isDisabled`.
- **Key styles:** root flex gap 8 (column when horizontal, row when vertical). List container: bg `default`, radius 20 (radius×2.5); list
  padding 4; horizontal list at least full width (grows with content); vertical list column gap 4, tabs min-width 80. Tab: height 32, full
  width of its flex slot, radius 24, padding-x 16, centered (start/end per `align`), text-sm weight 500 `muted`; selected text
  `segment-foreground`; hover (unselected, enabled) opacity .7; disabled .5; focus ring; transitions color/bg/opacity 150ms ease, shadow
  ease-out. Indicator: fills the selected tab, radius 24, bg `segment`, shadow `surface`, behind label; moves/resizes between tabs 250ms
  `ease-out-fluid` (translate + width + height). Separator: horizontal lists → 1px wide, 50% tall, top 25%, at tab start; vertical lists →
  1px tall, 90% wide, start 5%, top 0; color `muted`@25%, radius 4; hidden (opacity 150ms) on the selected tab and the tab right after it.
  Panel: full width, padding 8, margin-top 16 (horizontal) / margin-start 16 (vertical). Overflow: list scrolls (no scrollbar) with 64px
  fading edges; chevron buttons 16×16 (chevron-left/right or up/down) at 4px from the ends, shown only when that direction can scroll,
  hover opacity .7; click scrolls 80% of the viewport smoothly. Secondary variant: container transparent, radius 0, list padding 0, separators
  hidden, tabs radius 0, selected text `foreground`, indicator bg `accent` no shadow no radius: horizontal → 2px bar at bottom + container
  1px bottom border `border`; vertical → 2px bar at start + container 1px start border.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `variant` | primary/secondary | `variant: HeroTabsVariant` |
| `orientation` | horizontal/vertical | `orientation: Axis` |
| `align` | start/center/end | `align: HeroTabsAlign` |
| `selectedKey` / `defaultSelectedKey` / `onSelectionChange` | Key | `selectedKey`, `defaultSelectedKey`, `onSelectionChanged: ValueChanged<Object>` |
| (RAC) `disabledKeys` / `keyboardActivation` / `isDisabled` | | `disabledKeys`, `keyboardActivation {automatic*, manual}`, `isDisabled` |
| `render` | fn | `builder` |
| `List.aria-label` | string | `semanticLabel` |
| `List.render` | fn | `builder` |
| `Tab.id` / `isDisabled` | | `id`, `isDisabled` |
| `Tab.render` / children | | `child` / `builder(context, HeroTabState{isSelected,isHovered,isFocusVisible,isDisabled})` |
| `Separator.className` | | `HeroTabsSeparator()` |
| `Panel.id` / `render` / children | | `id`, `child` / `builder` |

- **States & behaviour:** press selects; Left/Right (horizontal, RTL-aware) or Up/Down (vertical) move focus and select (automatic
  activation), wrap around, Home/End, disabled tabs skipped; only the selected panel is mounted/visible. Semantics: `SemanticsRole.tabBar`,
  `SemanticsRole.tab` (`selected`), `SemanticsRole.tabPanel`.
- **Docs examples:** `tabs-basic` (Overview/Analytics/Reports) · `tabs-vertical` (Account/Security/Notifications/Billing) · `tabs-overflow`
  (9 tabs in 400px, chevrons + fades) · `tabs-disabled` · `tabs-with-separator` · `tabs-secondary` · `tabs-secondary-vertical` ·
  `tabs-vertical-alignment` (secondary vertical, align start, 5 settings tabs) · `tabs-render-function` · `tabs-custom-styles` (transparent
  square list container, custom panels).
- **Depends on:** HeroScrollShadow (fading edges, 64px), collection/keyboard model, icon set (chevrons).

#### Table → `HeroTable`
- **Docs:** https://heroui.com/en/docs/react/components/table · **Category:** Data Display
- **Anatomy:** `Table` → `HeroTable` (root/variant); `Table.ScrollContainer` → `HeroTableScrollContainer` (horizontal scroll);
  `Table.ResizableContainer` → `HeroTableResizableContainer`; `Table.Content` → `HeroTableContent` (the grid: selection/sort/expansion);
  `Table.Header` → `HeroTableHeader`; `Table.Column` → `HeroTableColumn`; `Table.SortableColumnHeader` → `HeroTableSortableColumnHeader`;
  `Table.ColumnResizer` → `HeroTableColumnResizer`; `Table.Body` → `HeroTableBody`; `Table.Row` → `HeroTableRow`; `Table.Cell` → `HeroTableCell`;
  `Table.Collection` → `HeroTableCollection`; `Table.LoadMore` → `HeroTableLoadMore`; `Table.LoadMoreContent` → `HeroTableLoadMoreContent`;
  `Table.Footer` → `HeroTableFooter`; `Virtualizer`+`TableLayout` → `HeroTableContent(virtualized: true, rowHeight:, headingHeight:)`.
- **Variants:** `variant` `HeroTableVariant {primary*, secondary}`; `selectionMode` `{none*, single, multiple}`; column `allowsSorting`,
  `isRowHeader`; `HeroSortDirection {ascending, descending}`.
- **Key styles:**
  - Primary root: bg `surface-secondary`, padding 4 left/right/bottom (0 top), radius 20 (radius×2.5), clip; header row sits on the gray,
    body is a `surface` card with 16px outer corners (first/last row's outer cells).
  - Content: full width, text-sm, separated borders, spacing 0 (layout like HTML auto table; demos set `minWidth` 520–800).
  - Column header cell: padding 16×10, start-aligned 12px weight 500 `muted`; column separator = 1×16 line (radius 4, `separator`) centered on
    the end edge, omitted on the last column and where a resizer exists; sortable → pointer + hover text `foreground`; keyboard focus → inset
    2px `focus` ring, radius 8.
  - Body cell: bg `surface`, padding 16×12, 14px `foreground`, vertically centered, 1px bottom border `separator-tertiary`@50% (every row);
    focus → inset 2px ring radius 8. Row hover (pointer devices): cells bg `surface`@40%; selected: cells bg `surface`@10%; disabled .5;
    dragging .5; drop target `accent-soft`. Row keyboard focus: one continuous inset 2px ring across the row (start cell rounded 8 on start,
    end cell on end).
  - Secondary: no root bg/padding/radius; header cells bg `surface-secondary` forming a pill (first cell start radius 16, last cell end
    radius 16); body cells transparent with 1px bottom border `separator-tertiary`@50%, hover `default`@50%; body corners square.
  - SortableColumnHeader: row space-between; indicator chevron-up 12px, rotates 180° for descending (100ms tw ease-out), absent when unsorted.
  - Tree column cells: padding-start = 16 × level.
  - Footer: row, centered vertically, padding 16×10 (on the gray bg in primary).
  - Column resizer: rest = 1×16 separator line with 8px hit padding each side, col-resize cursor; hover/resizing → full-height 2px `accent`;
    keyboard focus → 2px `focus`.
  - LoadMore row: padding-y 12, centered; LoadMoreContent row gap 8, padding-y 8. Empty state fills body.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `Table.variant` | primary/secondary | `variant: HeroTableVariant` |
| `Table.children` | | `children` (container + optional footer) |
| `ScrollContainer.children` | | `child` (+ `maxHeight` for vertical scroll demo) |
| `Content.aria-label` | string | `semanticLabel` |
| `Content.selectionMode` | none/single/multiple | `selectionMode` |
| `Content.selectedKeys` / (RAC) `defaultSelectedKeys` / `onSelectionChange` | Selection | `selectedKeys`, `defaultSelectedKeys`, `onSelectionChanged` |
| (RAC) `disabledKeys` / `onRowAction` | | `disabledKeys`, `onRowAction: ValueChanged<Object>` |
| `Content.sortDescriptor` / `onSortChange` | {column, direction} | `sortDescriptor: HeroSortDescriptor?`, `onSortChanged` |
| (RAC, demo) `treeColumn` / `expandedKeys` / `onExpandedChange` | | `treeColumn`, `expandedKeys`, `defaultExpandedKeys`, `onExpandedChanged` |
| (demo) `className min-w-[…]` | | `minWidth` |
| `Header.columns` / `children` | T[] / node \| fn | `columns` + `columnBuilder` / `children`; `isSticky` (async demo) |
| `Column.id` | string | `id` |
| `Column.allowsSorting` / `isRowHeader` | boolean | same |
| `Column.defaultWidth` / `minWidth` (+ RAC `width`, `maxWidth`) | string \| number | `defaultWidth: HeroColumnWidth` (`.px(160)` / `.fr(1)`), `minWidth`, `maxWidth` |
| `Column.children` | node \| fn({sortDirection}) | `child` / `builder(context, HeroSortDirection?)` |
| `SortableColumnHeader.sortDirection` / `showIndicator` (true) / `indicator` / `children` | | same names |
| `Body.items` / `children` | T[] / fn | `items` + `rowBuilder` / `children` |
| `Body.renderEmptyState` | ()=>node | `emptyStateBuilder` |
| `Row.id` / `children` (+ RAC `textValue`, `isDisabled`) | | `id`, `children` (cells), `textValue`, `isDisabled` |
| `Cell.children` | node \| fn({hasChildItems,isExpanded,isTreeColumn,isDisabled}) | `child` / `builder(context, HeroTableCellState)` |
| `Cell.textValue` | string | `textValue` |
| `Footer.children` | ReactNode | `child` |
| `ColumnResizer` | — | `HeroTableColumnResizer()` |
| `ResizableContainer.children` (+ RAC `onResize`) | | `child`, `onResize` |
| `LoadMore.isLoading` / `onLoadMore` / (demo) `scrollOffset` / `children` | | `isLoading`, `onLoadMore`, `scrollOffset`, `child` |
| `LoadMoreContent.children` | | `child` |
| `Collection.items` / `children` | | `HeroTableCollection(items:, builder:)` |
| `TableLayout.rowHeight` / `headingHeight` (48/48) | number | `rowHeight`, `headingHeight` (virtualized) |

- **States & behaviour:** grid keyboard nav: Up/Down rows, Left/Right cells (RTL-aware), Home/End, Ctrl+Home/End, PageUp/PageDown; Space
  toggles selection (single replaces; multiple toggles, Shift for range, Ctrl/Cmd+A all); `Checkbox slot="selection"` in header = select-all
  (indeterminate when partial), in rows = row toggle; Enter → `onRowAction`; sortable header press / Enter cycles ascending ↔ descending;
  tree rows: chevron button (`slot=chevron`) or ArrowRight/ArrowLeft expand/collapse; resizer drag (and keyboard Enter + arrows) changes widths
  respecting min widths; LoadMore fires `onLoadMore` when sentinel scrolls into view. Semantics: `SemanticsRole.table`, `row`,
  `columnHeader` (sort in value), `cell`; selected rows `selected`.
- **Docs examples:** `table-basic` (4 team members × Name/Role/Status/Email) · `table-secondary-variant` · `table-async-loading` (sticky
  header, 280px scroll, Chip status, infinite load with spinner) · `table-sorting` (4 sortable columns) · `table-selection` (checkbox column,
  multiple, selected text) · `table-expandable-rows` (file tree with chevron buttons, treeColumn "name") · `table-pagination` (Table.Footer
  with sm Pagination + summary) · `table-column-resizing` (fr widths with min widths, Chip statuses) · `table-empty-state` (tray icon + "No
  results found") · `table-virtualization` (1000 rows, 42px rows/header, 300px) · `table-tanstack-table` (external sorting + pagination) ·
  `table-custom-cells` (selection + sortable ID/Member(avatar+name+email)/Role/Status chip/action icon buttons) · `table-custom-styles`
  (bordered radius-12 card, neutral header).
- **Depends on:** collection/selection model, HeroCheckbox (slot selection), HeroButton (slot chevron, icon buttons), HeroChip, HeroAvatar,
  HeroSpinner, HeroPagination, HeroEmptyState, icon set.

---

### Docs vs. source discrepancies found (use source behaviour)
- Tooltip `delay`/`closeDelay`: docs 700/0 ms; effective defaults come from CSS vars `--tooltip-delay: 1500ms`, `--tooltip-close-delay: 500ms`.
- ListBox `selectionMode`: docs say `single`; the component passes RAC's default `none`.
- Dropdown.Popover `placement`: docs say `bottom`; HeroUI passes `undefined`, so RAC MenuTrigger's context default (`bottom start`) applies.
- ComboBox `variant` (primary/secondary) exists in source and demos but is missing from the API table.
- `toast.info()` maps to the `accent` variant.
- Autocomplete's docs "Usage" demo (`autocomplete-default`) is actually a multiple-select with removable tags.

## Date, time and color

Source of truth: `packages/styles/components/*.css`, `packages/react/src/components/*`, docs mdx + demos (HeroUI 3.2.6, React Aria 1.21).
Tailwind units: 1 = 4px (`size-6` 24px, `w-63` 252px), `text-xs` 12/16, `text-sm` 14/20, `text-base` 16/24, `font-medium` 500.
Radius tokens (default `--radius` 8px): xs 2, sm 4, md 6, lg 8, xl 12, 2xl 16, 3xl 24, 4xl 32, `rounded-field` = radius×1.5 = 12.
Easing: `--ease-out` = Tailwind `cubic-bezier(0,0,.2,1)`, `--ease-smooth` = CSS `ease` (`cubic-bezier(.25,.1,.25,1)`).
`status-focused` = 2px `focus` (=accent) ring, 2px offset (background color gap). `status-focused-field` = 2px focus ring, 0 offset.
`status-invalid-field` = 1px `danger` outline; when focus-within → 2px `danger` ring, 0 offset. `status-disabled` = opacity 0.5 + no pointer.

### Shared foundations for group D (build first)

- **Types:** `HeroTime(hour, minute, second)`; `HeroDateRange(start, end)` (both `DateTime`). Dates are local-midnight `DateTime`; with time granularities the full `DateTime` is used.
- **Enums:** `HeroDayOfWeek {sun, mon, tue, wed, thu, fri, sat}`, `HeroCalendarSelectionMode {single, multiple}`, `HeroCalendarPageBehavior {visible, single}`, `HeroCalendarSelectionAlignment {start, center, end}`, `HeroWeekdayStyle {narrow, short, long}`, `HeroCalendarNavSlot {previous, next}`, `HeroDateGranularity {day, hour, minute, second}`, `HeroTimeGranularity {hour, minute, second}`, `HeroHourCycle {h12, h24}`, `HeroDateInputSlot {start, end}`, `HeroInputGroupVariant {primary, secondary}` (reuse the forms-group enum), `HeroValidationBehavior {native, aria}` (from forms group).
- **`HeroCalendarDuration`** `{int? months, int? weeks, int? days}` with `const .months(n)`, `.weeks(n)`, `.days(n)`; used for `visibleDuration` and part `offset`s.
- **`HeroCalendarScope`** (InheritedWidget, shared by Calendar, RangeCalendar and the year-picker parts): focused date, visible range, selection/anchor, min/max, unavailable predicate, disabled/read-only, `isYearPickerOpen` + setter, calendar system, locale, first day of week, the day-grid `Rect` (for the year-grid overlay).
- **`HeroCalendarSystem`** abstraction: `gregorian` (default) + `indian` (Saka; needed by the "International calendar" demos in 4 docs pages; `intl` has no non-Gregorian calendars). Year offset table for default min/max bounds: buddhist +543, ethiopic/ethioaa −8, coptic −284, hebrew +3760, indian −78, islamic-* −579, persian −600, else 0. Default bounds = (1900+offset)-01-01 … (2099+offset)-12-31.
- **Locale data:** month/weekday names and date patterns from `intl` `DateFormat` (`yMMMM`, `yMd`, `jm`, `jms`, `EEE`…); first day of week from locale (`MaterialLocalizations.firstDayOfWeekIndex` 0=Sun, or intl `DateSymbols.FIRSTDAYOFWEEK` 0=Mon), overridable. `isWeekend(date, locale)` helper (demos use it).
- **Date segment engine** `HeroDateSegmentController` (used by DateField, TimeField, DatePicker, DateRangePicker): segment list derived from the locale pattern + granularity + hourCycle + shouldForceLeadingZeros; see DateField "States & behaviour".
- **Color foundations:** `HeroColorSpace {rgb, hsl, hsb}`, `HeroColorChannel {hue, saturation, brightness, lightness, red, green, blue, alpha}`, `HeroColorFormat {hex, hexa, rgb, rgba, hsl, hsla, hsb, hsba, css}`; `heroParseColor(String) → Color` (hex/rgb[a]/hsl[a]/hsb[a]; mirrors re-exported `parseColor`), `heroColorToString(Color, HeroColorFormat)`, `heroColorName(Color, Locale)` (port of React Aria `Color.getColorName`, OKLCH-based, 'transparent' when alpha 0). Channel ranges `HeroChannelRange(min, max, step, pageSize)`: hue 0–360/1/15, saturation·lightness·brightness 0–100/1/10, red·green·blue 0–255/1/17, alpha 0–1/0.01/0.1. Value formatting: hue `"0°"`, s/l/b and alpha as percent `"50%"`, rgb as integer.
  - Hue preservation: public values are `Color`, but every color widget caches an `HSVColor`/`HSLColor` and re-uses the cached hue/saturation while the incoming `Color` equals the last emitted one (React Aria keeps the value's own color space; Dart `Color` would lose hue at s=0/b=0 and make thumbs jump).
- **Checkerboard painter** (`HeroCheckerboard`): 16×16 tile of four 8px squares, `#EFEFEF` top-right & bottom-left, `#F7F7F7` top-left & bottom-right, tile centered on the box (`repeating-conic-gradient(#efefef 0% 25%, #f7f7f7 0% 50%) 50% / 16px 16px`). Used by ColorSwatch, ColorSlider track.
- **`HeroColorPickerScope`** (InheritedWidget): ColorArea / ColorSlider / ColorField / ColorSwatch / ColorSwatchPicker read and write the nearest picker color when their own `value`/`color` is null.

---

#### Calendar → `HeroCalendar`
- **Docs:** https://heroui.com/en/docs/react/components/calendar · **Category:** Date and Time
- **Anatomy:** `Calendar` → `HeroCalendar`; `Calendar.Header` → `HeroCalendarHeader`; `Calendar.Heading` → `HeroCalendarHeading`; `Calendar.NavButton` → `HeroCalendarNavButton`; `Calendar.Grid` → `HeroCalendarGrid`; `Calendar.GridHeader` → `HeroCalendarGridHeader(builder: (ctx, String weekday))`; `Calendar.GridBody` → `HeroCalendarGridBody(builder: (ctx, DateTime date))`; `Calendar.HeaderCell` → `HeroCalendarHeaderCell`; `Calendar.Cell` → `HeroCalendarCell`; `Calendar.CellIndicator` → `HeroCalendarCellIndicator`; year picker (also exported as `CalendarYearPicker.*`): `Calendar.YearPickerTrigger` → `HeroCalendarYearPickerTrigger`, `.YearPickerTriggerHeading` → `HeroCalendarYearPickerTriggerHeading`, `.YearPickerTriggerIndicator` → `HeroCalendarYearPickerTriggerIndicator`, `.YearPickerGrid` → `HeroCalendarYearPickerGrid`, `.YearPickerGridBody` → `HeroCalendarYearPickerGridBody(builder: (ctx, HeroYearCellState))`, `.YearPickerCell` → `HeroCalendarYearPickerCell`. Convenience: `HeroCalendar` with `child == null` renders the Basic anatomy; `showYearPicker: true` renders the Year-picker anatomy; `cellBuilder` overrides cell content.
- **Variants:** none (no tv variants). Booleans: `isDisabled`, `isReadOnly`, `isInvalid`. Layout modifiers from `visibleDuration`: month view* (`{months:1}`), `calendar--week-view` (`weeks`), `calendar--day-view` (`days`). `selectionMode`: single* | multiple.
- **Key styles:**
  - Root: width 252 (`w-63 max-w-63`); multi-month layouts widen it (demo: `w-full max-w-none`, two 256px columns, gap 32). Expose `width` override. Root is `position: relative` when a year grid exists.
  - Header: Row, `justify-between`, `items-center`, padding `2px` horizontal, `16px` bottom. Heading: `flex-1`, 14px/500, foreground. When the year picker is open nav buttons get opacity 0 + non-interactive (opacity transition 150ms ease-out).
  - NavButton: 24×24, radius 2xl (16 → circle), color `accent-soft-foreground`, icon chevron 16×16 (mirrored in RTL, **not** mirrored inside DatePicker/DateRangePicker popovers). Hover: bg `default`. Pressed: scale 0.95. Transitions: transform 250ms, bg 100ms, shadow 100ms, opacity 150ms (ease-out). Focus: `status-focused`. Disabled: `status-disabled`.
  - Grid: 7 equal columns filling width (→ 36px cells at 252px). Header cells: centered, 12px/500, `muted`, bottom padding 8px, weekday format `short` by default (HeroUI overrides RAC's `narrow`). First body row margin-top 4px; no row gaps.
  - Cell: square (aspect 1), full column width, radius 3xl (24 → circle at 36px), centered 14px/500 text. Transitions: transform 250ms + shadow 100ms ease-out.
    - hover (not selected): bg `default`
    - pressed: bg `default`, scale 0.95; pressed+selected: bg `accent-hover`
    - today: bg `accent-soft`, text `accent-soft-foreground`; today hover (not selected): bg `accent-soft-hover`
    - selected: bg `accent`, text `accent-foreground` (wins over today)
    - outside month: text `muted`, opacity 0.5 (not selectable); selected + outside month: bg `default`
    - unavailable (`isDateUnavailable`): opacity 0.5, non-interactive (no strike-through)
    - disabled & in month (outside min/max or calendar `isDisabled`): opacity 0.5 + `line-through`
    - focus-visible: `status-focused` ring; read-only: cells ignore pointer input
  - CellIndicator: 3×3 dot, radius xs (2), bg `muted`, absolute bottom 4px, horizontally centered; bg `accent-foreground` when the cell is selected.
  - Week view: cells `aspect-square`, `w-full`, centered in their grid slot. Day view: header and body are separate 7-column grids (so < 7 headers do not flow into the date row), body margin-top 4px (first row 0).
  - Year picker (shared with RangeCalendar):
    - Trigger: `flex-1`, row, start-aligned, gap 4, radius lg (8), focus `status-focused`. Heading 14px/500, color transition 150ms; open → `accent-soft-foreground`. Indicator: chevron-right at 1em inside 12px text, `accent-soft-foreground`, rotates 90° when open (RTL base 180°), transform 150ms ease-out.
    - Grid: absolutely overlaid on the day grid (same top/height as the day grid, start/end 0), 3 columns, gap 4, padding 4, vertically scrollable, content-start.
    - Crossfade: opening → day grid opacity→0 over 150ms then hidden; year grid fades in 200ms ease-out after 50ms delay. Closing → year grid hides instantly, day grid fades in 150ms.
    - Year cell: height 32, horizontal padding 10, radius 3xl, 14px/500, centered. Hover (fine pointer, not selected): bg `default`, text `default-foreground`. Selected (= focused date's year): bg `accent`, text `accent-foreground`; selected hover `accent-hover`. Transitions 100ms ease (color, scale, opacity, bg), shadow 100ms ease-out. Focus `status-focused`.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `selectionMode` | `'single'\|'multiple'` (single) | `selectionMode: HeroCalendarSelectionMode` |
| `value` | `DateValue\|null` / `DateValue[]` | `value: DateTime?` / `values: Set<DateTime>?` (multiple) |
| `defaultValue` | same | `defaultValue: DateTime?` / `defaultValues: Set<DateTime>?` |
| `onChange` | `(v) => void` | `onChanged: ValueChanged<DateTime?>` / `onValuesChanged: ValueChanged<Set<DateTime>>` |
| `focusedValue` | `DateValue` | `focusedValue: DateTime?` (+ `defaultFocusedValue`) |
| `onFocusChange` | `(DateValue) => void` | `onFocusChanged: ValueChanged<DateTime>` |
| `minValue` / `maxValue` | `DateValue` (1900-01-01 / 2099-12-31, calendar-aware) | `minValue` / `maxValue: DateTime?` |
| `weeksInMonth` | `number` | `weeksInMonth: int?` |
| `isDateUnavailable` | `(date) => boolean` | `isDateUnavailable: bool Function(DateTime)?` |
| `firstDayOfWeek` | `'sun'…'sat'` | `firstDayOfWeek: HeroDayOfWeek?` |
| `pageBehavior` | `'visible'\|'single'` (visible) | `pageBehavior: HeroCalendarPageBehavior` |
| `selectionAlignment` | `'start'\|'center'\|'end'` (center) | `selectionAlignment: HeroCalendarSelectionAlignment` |
| `isDisabled` / `isReadOnly` / `isInvalid` | `boolean` (false) | same names |
| `visibleDuration` | `{months?,weeks?,days?}` ({months:1}) | `visibleDuration: HeroCalendarDuration` |
| `defaultYearPickerOpen` | `boolean` (false) | `defaultYearPickerOpen: bool` |
| `isYearPickerOpen` | `boolean` | `isYearPickerOpen: bool?` |
| `onYearPickerOpenChange` | `(bool) => void` | `onYearPickerOpenChanged: ValueChanged<bool>?` |
| `aria-label` / `autoFocus` | | `semanticLabel: String?` / `autofocus: bool` |
| `Heading.offset` / `.format` | `{months}` / `DateFormatterOptions` | `HeroCalendarHeading(offset: HeroCalendarDuration?, format: DateFormat?)` |
| `NavButton.slot` / children | `'previous'\|'next'` | `HeroCalendarNavButton(slot:, child: Widget?)` |
| `Grid.offset` / `weekdayStyle` | `{months}` / `'narrow'\|'short'\|'long'` (short) | `HeroCalendarGrid(offset:, weekdayStyle: HeroWeekdayStyle.short)` |
| `Cell.date` / children fn | `CalendarDate` / render props | `HeroCalendarCell(date:, child:, builder: (ctx, HeroCalendarCellState s))` — `formattedDate, isSelected, isUnavailable, isDisabled, isOutsideMonth, isToday, isFocused, isHovered, isPressed` |
| `YearPickerTrigger` children fn | `{isOpen, monthYear, toggle}` | `HeroCalendarYearPickerTrigger(child:, builder:)` |
| `YearPickerTriggerHeading.format` / `.offset` | | `format: DateFormat?`, `offset: HeroCalendarDuration?` |
| `YearPickerGrid.format` / `.visibleYears` | ({year:'numeric'}) / (min–max span or 20) | `format: DateFormat?`, `visibleYears: int?` |
| `YearPickerCell.year` / children fn | `number` / `{year, formattedYear, isSelected, isCurrentYear, isOpen, selectYear}` | `HeroCalendarYearPickerCell(year:, builder:)` |

- **States & behaviour:**
  - Keyboard (grid, RTL flips left/right): ←/→ ±1 day, ↑/↓ ±7 days, PageUp/PageDown previous/next page (month in month view, week in week view, visible range in day view), Shift+PageUp/Down previous/next larger section (year in month view), Home/End start/end of the section (first/last day of month; start/end of week in week view; start/end of visible range in day view), Enter/Space select. Focus moving outside the visible range pages the view. `pageBehavior: single` pages one unit (1 week/1 day) even when several are visible. Nav buttons page by the visible duration and disable at min/max.
  - `selectionMode.multiple`: tapping toggles a date in `values`.
  - min/max: cells outside are disabled (strike-through) and nav disables at the bounds. Default bounds 1900-01-01…2099-12-31, shifted per calendar system. Unavailable dates stay focusable but are not selectable.
  - Locale: weekday labels via `DateFormat.E` (short); `firstDayOfWeek` overrides the locale. `weeksInMonth` pads the grid to a fixed row count (demo: 6). Heading = visible range title (`September 2026`; a range title for week/day/multi-month views); with `offset` it shows the month at start+offset.
  - Week view (`weeks: n`): n rows of 7. Day view (`days: n`): the rolling window is centered on the selection by default (days: 7 around Aug 15 → Aug 12–18). If `days ≥ 7`, rows are week-aligned starting at `startOfWeek(start)`: leading dates before start are shown disabled, cells after end are empty, and the header always has 7 labels. If `days < 7`, one row of n cells in a 7-column grid.
  - Year picker (new in v3.2.0): the trigger toggles open. On open, focus goes to the focused year cell (scrolled into view). Grid keys: ←/→ ±1, ↑/↓ ±3, Home/End first/last, Escape closes (also from the trigger). Selecting a year sets the focused date's year and closes the picker. Years default to the full min–max span (200 years with default bounds), otherwise 20. Only the active cell is tabbable. Trigger semantics label: `"<Month Year>, year selector"`, expanded=isOpen.
  - Multi-month: `visibleDuration.months: 2` + `HeroCalendarGrid(offset: months(1))` + heading offset.
  - International: the calendar system comes from the locale (demo `hi-IN-u-ca-indian` → Indian/Saka months and years). `onChanged` always returns Gregorian `DateTime`.
  - Semantics: root container label `"<semanticLabel>, <visible range>"`, announce the range on page change (`SemanticsService.announce`). Grid is a Semantics container. Each cell: `button`, `selected`, `enabled`, label = full date ("Today, Thursday, September 24, 2026"). Nav buttons are labelled "Previous"/"Next". Year grid is a list; year cells are buttons with a selected state.
- **Docs examples:**
  1. `calendar-basic` — default month grid with heading and prev/next.
  2. `calendar-disabled` — `isDisabled`, defaultValue today, caption "Calendar is disabled".
  3. `calendar-read-only` — `isReadOnly`, defaultValue today.
  4. `calendar-default-value` — defaultValue 2025-02-14.
  5. `calendar-year-picker` — YearPickerTrigger (heading + chevron) replaces Heading, plus a YearPickerGrid.
  6. `calendar-controlled` — `ButtonGroup` (Today/Week/Month, sm tertiary, fullWidth), controlled `value` + `focusedValue` (initial 2025-12-25), a "Selected date:" line, and Set Today / Set Christmas / Clear buttons.
  7. `calendar-min-max-dates` — min today, max today+3 months, with a caption.
  8. `calendar-unavailable-dates` — weekends unavailable.
  9. `calendar-weeks-in-month` — `weeksInMonth: 6`.
  10. `calendar-week-view` — a Select (1,2,3,4,5,6,8 weeks) drives `visibleDuration.weeks` (default 1).
  11. `calendar-day-view` — a Select (1,5,7,8,10,14,21 days) drives `days` (default 5).
  12. `calendar-multiple-selection` — `selectionMode: multiple`, caption "N date(s) selected".
  13. `calendar-focused-value` — controlled focus with Go to Jan / Jun / Christmas buttons (2025).
  14. `calendar-with-indicators` — CellIndicator on today and on days 3, 7, 12, 15, 21, 28.
  15. `calendar-custom-icons` — custom SVG chevrons (24px paths) in the NavButtons.
  16. `calendar-multiple-months` — two 256px month columns, gap 32, prev on the left header, next on the right header, second grid offset by 1 month.
  17. `calendar-booking-calendar` — min today, weekends and booked days (5, 6, 12, 13, 14, 20) unavailable, indicators on booked weekdays, a legend, and a "Book <date>" primary sm button.
  18. `calendar-international-calendar` — `hi-IN-u-ca-indian` locale with the year picker.
  19. `calendar-custom-styles` — surface card (border, p-3, shadow) with overridden cell colors (needs part-level style overrides / scoped theme).
- **Depends on:** theme tokens (accent, accent-soft(-hover/-foreground), default, muted, focus), focus-ring & pressable foundation (scale-on-press), chevron icons, `intl`, HeroCalendarSystem, HeroCalendarScope. Demos use Button, ButtonGroup, Description, Select, ListBox, Label.

#### RangeCalendar → `HeroRangeCalendar`
- **Docs:** https://heroui.com/en/docs/react/components/range-calendar · **Category:** Date and Time
- **Anatomy:** `RangeCalendar` → `HeroRangeCalendar`; `.Header` → `HeroRangeCalendarHeader`; `.Heading` → `HeroRangeCalendarHeading`; `.NavButton` → `HeroRangeCalendarNavButton`; `.Grid` → `HeroRangeCalendarGrid`; `.GridHeader` → `HeroRangeCalendarGridHeader`; `.GridBody` → `HeroRangeCalendarGridBody`; `.HeaderCell` → `HeroRangeCalendarHeaderCell`; `.Cell` → `HeroRangeCalendarCell` (inner `range-calendar__cell-button`); `.CellIndicator` → `HeroRangeCalendarCellIndicator`; `.YearPicker*` → the same `HeroCalendarYearPicker*` widgets (export `HeroRangeCalendarYearPicker*` typedef aliases). Same convenience defaults as HeroCalendar.
- **Variants:** none. Booleans `isDisabled`, `isReadOnly`, `isInvalid`, `allowsNonContiguousRanges`. Layout modifiers week/day view as in Calendar.
- **Key styles:** root, header, heading, grid, header cells, week/day view, year picker: identical to Calendar, except **NavButton radius is xl (12)** here (Calendar uses 2xl).
  - Cell (the track piece, `td > div`): vertical margin 2px (row pitch = cell + 4px), radius 3xl, z 1, transitions shadow/border 100ms. The inner button is square, full width, radius 3xl, 14px/500 `foreground`, scale transition 200ms ease-out.
  - today: button bg `accent-soft`, text `accent-soft-foreground`; hover (not selected) `accent-soft-hover`.
  - in range (selected, not outside month): cell bg `accent-soft`, radius 0 (continuous track).
  - track ends: first column, or a cell right after a disabled cell → start corners 8px (lg). Last column, or right before a disabled cell → end corners 8px. The same 8px rounding applies next to an outside-month cell. If the cell is also the selection start/end, that corner is 24px (3xl).
  - start/end caps (not outside month): z 2, button bg `accent`, text `accent-foreground`. The start cap has start corners 3xl; the end cap has end corners 3xl.
  - pressed: button scale 0.9; pressed cap: bg `accent-hover`.
  - hover (not selected): button bg `default`.
  - outside month: text `muted`, opacity 0.5; selected in-range outside-month (not a cap): bg `default` at 20% alpha.
  - unavailable: opacity 0.5; disabled in month: opacity 0.5 + line-through.
  - focus-visible: z 2, focus ring on the button.
  - `isInvalid`: no visual in CSS (semantics only).
  - CellIndicator: 3px dot, `muted`, bottom 4px. Turns `accent-foreground` only inside start/end caps (it is a child of the cap button).
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `RangeValue<DateValue>\|null` | `value` / `defaultValue: HeroDateRange?` |
| `onChange` | `(RangeValue) => void` | `onChanged: ValueChanged<HeroDateRange>` |
| `focusedValue` / `onFocusChange` | `DateValue` | `focusedValue: DateTime?`, `onFocusChanged` |
| `minValue` / `maxValue` | (1900-01-01 / 2099-12-31) | `minValue` / `maxValue: DateTime?` |
| `weeksInMonth` | `number` | `weeksInMonth: int?` |
| `isDateUnavailable` | `(date, anchorDate: CalendarDate\|null) => boolean` | `isDateUnavailable: bool Function(DateTime date, DateTime? anchor)?` |
| `firstDayOfWeek` | `'sun'…'sat'` | `firstDayOfWeek: HeroDayOfWeek?` |
| `pageBehavior` / `selectionAlignment` | (visible / center) | same enums as Calendar |
| `allowsNonContiguousRanges` | `boolean` (false) | `allowsNonContiguousRanges: bool` |
| `isDisabled` / `isReadOnly` / `isInvalid` | `boolean` | same |
| `visibleDuration` | ({months:1}) | `visibleDuration: HeroCalendarDuration` |
| `defaultYearPickerOpen` / `isYearPickerOpen` / `onYearPickerOpenChange` | | same as Calendar |
| part props (`Heading.offset/format`, `Grid.offset/weekdayStyle`, NavButton slot) | | as Calendar |
| `Cell` children fn | `formattedDate, isSelected, isSelectionStart, isSelectionEnd, isUnavailable, isDisabled, isOutsideMonth` | `HeroRangeCalendarCell(date:, builder: (ctx, HeroRangeCalendarCellState))` |

- **States & behaviour:** keyboard as Calendar. The first Enter/tap sets the anchor, focus/hover previews the range (highlight follows the pointer or focus), the second Enter/tap commits `HeroDateRange` ordered start ≤ end. Escape cancels a pending anchor. `isDateUnavailable(date, anchor)` is re-evaluated while the anchor is set (demo: only ±7 days of the anchor). Without `allowsNonContiguousRanges` a range can't span unavailable dates (the selectable extent is clamped at the first unavailable date from the anchor). With it, the range may cross them and the track breaks visually at disabled cells. Semantics: the cell's `selected` flag covers the whole range, and caps add "range start/end" to the label. The rest (year picker, views, locale) is as Calendar.
- **Docs examples:**
  1. `range-calendar-basic` — `firstDayOfWeek: mon`.
  2. `range-calendar-disabled` — `isDisabled`, caption.
  3. `range-calendar-year-picker` — year picker header plus grid.
  4. `range-calendar-default-value` — 2025-02-03 → 2025-02-12, Monday first.
  5. `range-calendar-controlled` — ButtonGroup (This week / Next week / Next month) moves focus, controlled value, a "Selected range:" line, and Set 1 week / Set Holidays (2025-12-20→31) / Clear.
  6. `range-calendar-min-max-dates` — today … +3 months.
  7. `range-calendar-unavailable-dates` — blocked today+2…+5 and +12…+13, default +6→+9, Monday first.
  8. `range-calendar-anchor-unavailable-dates` — min today, only ±7 days from the anchor are selectable.
  9. `range-calendar-weeks-in-month` — 6 weeks.
  10. `range-calendar-week-view` — weeks Select (1–6, 8).
  11. `range-calendar-day-view` — days Select (1, 5, 7, 8, 10, 14, 21).
  12. `range-calendar-allows-non-contiguous-ranges` — blocked ranges, default +1→+9 spanning a block.
  13. `range-calendar-read-only` — today → +4.
  14. `range-calendar-invalid` — controlled; invalid when longer than 7 days, shows danger text "Maximum stay duration is 1 week".
  15. `range-calendar-focused-value` — Go to Jan / Jun / Christmas.
  16. `range-calendar-with-indicators` — dots on today and days 3, 7, 12, 15, 21, 28.
  17. `range-calendar-booking-calendar` — weekends and blocked days unavailable, legend, "Book start -> end" button.
  18. `range-calendar-multiple-months` — two 256px months, gap 32.
  19. `range-calendar-international-calendar` — `hi-IN-u-ca-indian`.
  20. `range-calendar-custom-styles` — 252px card, xl radius, success-tinted nav buttons and cells.
- **Depends on:** everything HeroCalendar needs (shared HeroCalendarScope + year picker). Demos use Button, ButtonGroup, Description, Select, ListBox, Label.

#### DateField (incl. DateInputGroup) → `HeroDateField`
- **Docs:** https://heroui.com/en/docs/react/components/date-field · **Category:** Date and Time
- **Anatomy:** `DateField` → `HeroDateField` (root, FormField). `DateField.Group` (= `DateInputGroup`) → `HeroDateInputGroup`. `DateField.Input` → `HeroDateInput(slot: HeroDateInputSlot?, segmentBuilder:)`. `DateField.Segment` → `HeroDateSegment(segment:)`. `DateField.InputContainer` → `HeroDateInputContainer` (horizontal scroll for start/end inputs). `DateField.Prefix` / `.Suffix` → `HeroDateInputPrefix` / `HeroDateInputSuffix`. Uses `HeroLabel`, `HeroDescription`, `HeroFieldError`. Convenience params on `HeroDateField`: `label`, `description`, `errorMessage`, `startContent` (→ Prefix), `endContent` (→ Suffix), `variant`, so `HeroDateField(label: 'Date')` renders the full anatomy. (`DateInputGroup` isn't a top-level React export; in Flutter it is public so TimeField/DatePicker can reuse it.)
- **Variants:** Group `variant`: primary* | secondary. `fullWidth` (bool, false) on both the field and the group. States: `isRequired`, `isInvalid`, `isDisabled`, `isReadOnly`. Note: docs list `variant` on `DateField.Input` too, but the source only honours it on Group.
- **Key styles:**
  - Field root: column, gap 4. When invalid, Description is hidden (FieldError shows instead). Label is `w-fit`. `fullWidth` → width 100%.
  - Group:
    - Box: inline row, height 36, radius `field` (12), bg `field-background`, text 14px `field-foreground`, shadow `field-shadow` (light: `0 2 4 0 #0000000A, 0 1 2 0 #0000000F, 0 0 1 0 #0000000F`; dark: none).
    - Border: width `--field-border-width` (0 by default), color `field-border`.
    - Transitions: bg 150ms ease, border 150ms ease, shadow 150ms ease-out.
    - hover (not focus-within): bg `field-hover`, border `field-border-hover`
    - focus-within: `status-focused-field` (2px focus ring, 0 offset), except when the focused element is the picker trigger
    - invalid: `status-invalid-field` + bg `field-focus` + border `field-border-invalid`
    - disabled: `status-disabled`
    - secondary variant: no shadow, bg `default` (hover `default-hover`, focus `default`), invalid bg `default`
  - Input: row, `flex-1`, gap 1px between segments, padding 12 horizontal / 8 vertical, text 16px below 640px width and 14px above, text cursor. With Prefix → start padding 8; with Suffix → end padding 8. In a range (with separator): the start input is `flex-none` with end padding 0; the end input has start padding 0.
  - Segment: inline, padding 2 horizontal, radius md (6), end-aligned text, tabular figures, no wrap.
    - literal: padding 0, `muted`
    - placeholder: `field-placeholder`
    - focused: bg `accent-soft`, text `accent-soft-foreground`
    - disabled: opacity 0.5
    - invalid: text `danger`; invalid + focused: bg `danger-soft`, text `danger-soft-foreground`
  - Prefix: start margin 12, `field-placeholder` color, not hit-testable (hit-testable inside DatePicker). Suffix: end margin 12, same.
  - InputContainer: `flex-1`, horizontal scroll, hidden scrollbar, vertical clip.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `DateValue\|null` | `value` / `defaultValue: DateTime?` |
| `onChange` | `(DateValue\|null) => void` | `onChanged: ValueChanged<DateTime?>` |
| `placeholderValue` | `DateValue\|null` | `placeholderValue: DateTime?` |
| `isRequired` / `isInvalid` | `boolean` | same |
| `minValue` / `maxValue` | `DateValue` | `minValue` / `maxValue: DateTime?` |
| `isDateUnavailable` | `(date) => boolean` | `isDateUnavailable: bool Function(DateTime)?` |
| `validate` | `(value) => error\|true\|null` | `validator: String? Function(DateTime?)` (+ `onSaved`, `autovalidateMode`) |
| `validationBehavior` | `'native'\|'aria'` (native) | `validationBehavior: HeroValidationBehavior` |
| `granularity` | `'day'\|'hour'\|'minute'\|'second'` (day) | `granularity: HeroDateGranularity` |
| `hourCycle` | `12\|24` (locale) | `hourCycle: HeroHourCycle?` |
| `hideTimeZone` | `boolean` (false) | `hideTimeZone: bool` |
| `shouldForceLeadingZeros` | `boolean` | `shouldForceLeadingZeros: bool?` |
| `isDisabled` / `isReadOnly` | `boolean` | same |
| `name` / `autoFocus` / `autoComplete` | | `name: String?` / `autofocus: bool` / `autofillHints` |
| `fullWidth` | `boolean` (false) | `fullWidth: bool` |
| `aria-label` / `-describedby` | | `semanticLabel: String?` |
| `children` fn (render props) | `isDisabled, isInvalid, isReadOnly, isRequired, isFocused, isFocusWithin, isFocusVisible` | `builder: (ctx, HeroFieldState)` |
| `Group.variant` / `Group.fullWidth` | `'primary'\|'secondary'` / bool | `HeroDateInputGroup(variant:, fullWidth:)` / `HeroDateField(variant:)` |
| `Input` segment render fn | `(segment) => Segment` | `HeroDateInput(segmentBuilder: (ctx, HeroDateSegmentData s) => HeroDateSegment(segment: s))` |
| `Segment.segment` | `DateSegment` | `segment: HeroDateSegmentData` (type, text, value, min, max, isPlaceholder, isEditable) |
| `Prefix` / `Suffix` children | | `child` (or root `startContent` / `endContent`) |

- **States & behaviour (segment engine, shared):**
  - Segments: the locale pattern gives order and literals (en-US `mm/dd/yyyy`; with time `mm/dd/yyyy, ––:–– AM`). Types: era, year, month, day, hour, minute, second, dayPeriod, timeZoneName, literal. Placeholders: `yyyy`/`mm`/`dd` (localized), `––` for time fields, dayPeriod shows `AM`. `shouldForceLeadingZeros` pads month/day/hour. `hourCycle` h24 drops dayPeriod. Time-zone segment: shown for time granularities as `DateTime.timeZoneName` (`UTC` for utc values), read-only, hidden by `hideTimeZone`.
  - Keys: ←/→ move between editable segments (RTL-aware) and each segment is a tab stop. ↑/↓ inc/dec with wrap; an empty segment starts from the placeholder value. PageUp/PageDown step: year 5, month 2, day 7, hour 2, minute/second 15. Home/End go to the segment min/max. Backspace/Delete remove the last digit; an empty segment clears and moves focus back.
  - Typing digits accumulates and auto-advances when no further digit fits (e.g. month `2` → next, `1` waits for 10–12). Typing `a`/`p` sets the day period. Tapping the group focuses the nearest segment.
  - The value commits only when all segments are filled; partial entry keeps `value == null`. Day is clamped to the month length.
  - Validation: out of min/max or unavailable → invalid (segments `danger`, group invalid ring). Messages: "Value must be {min} or later." / "Value must be {max} or earlier." / "Selected date unavailable." / required. `native` behaviour shows errors after form validate/submit, `aria` shows them live. `isInvalid` forces the invalid state.
  - Disabled/read-only: segments are not editable (read-only stays focusable).
  - Semantics: group = container labelled by Label, hint from Description. Each segment is an adjustable spinbutton (`value`, `increasedValue`/`decreasedValue`, `onIncrease`/`onDecrease`, label = localized segment name). Literals are excluded.
- **Docs examples:**
  1. `date-field-basic` — label + group, 256px.
  2. `date-field-with-prefix-icon` — calendar icon (16px, muted) prefix.
  3. `date-field-with-suffix-icon` — calendar icon suffix.
  4. `date-field-with-prefix-and-suffix` — calendar prefix, chevron-down suffix, description.
  5. `date-field-variants` — primary vs secondary group.
  6. `date-field-on-surface` — two secondary fields inside a Surface (rounded-3xl, p-6), one with a prefix.
  7. `date-field-with-description` — two fields with descriptions.
  8. `date-field-required` — required, with and without description.
  9. `date-field-disabled` — disabled with value today, and empty.
  10. `date-field-full-width` — 400px container, fullWidth, plain and with prefix+suffix.
  11. `date-field-invalid` — `isInvalid` + FieldError (required, and "Date must be in the future").
  12. `date-field-granularity` — Select (Day/Hour/Minute/Second) plus a Tooltip info icon. Value is 2025-02-03 or 2025-02-03 08:45 America/Los_Angeles (shows the tz segment).
  13. `date-field-controlled` — "Current value" description, Set today / Clear.
  14. `date-field-form-example` — Form 280px, required, min today, calendar prefix, conditional FieldError/Description, Submit (isPending for 1.5s).
  15. `date-field-with-validation` — min today, conditional error.
  16. `date-field-render-function` — custom root/label/group/input elements (Flutter: builder wrappers, visually identical to basic).
  17. `date-field-custom-styles` — secondary group with xl radius, border, bg default, shadow-sm.
- **Depends on:** Label, Description, FieldError, HeroForm/FormField, the field-surface foundation shared with InputGroup (tokens, focus/invalid rings), segment engine, `intl`. Demos use Surface, Button, Form, Select, ListBox, Tooltip, and calendar/chevron/circle-question icons.

#### TimeField → `HeroTimeField`
- **Docs:** https://heroui.com/en/docs/react/components/time-field · **Category:** Date and Time
- **Anatomy:** `TimeField` → `HeroTimeField`. `TimeField.Group` / `.Input` / `.InputContainer` / `.Segment` / `.Prefix` / `.Suffix` are the same DateInputGroup parts: `HeroDateInputGroup`, `HeroDateInput`, `HeroDateInputContainer`, `HeroDateSegment`, `HeroDateInputPrefix`, `HeroDateInputSuffix` (optionally export `HeroTimeInput*` typedefs). Convenience params `label`, `description`, `errorMessage`, `startContent`, `endContent`, `variant`.
- **Variants:** Group `variant`: primary* | secondary. `fullWidth` (false) on field and group. Booleans `isRequired`, `isInvalid`, `isDisabled`, `isReadOnly`.
- **Key styles:** root `.time-field`: column, gap 4, Description hidden when invalid, label `w-fit`, fullWidth → 100%. Group, input and segment styles are identical to DateField (height 36, radius 12, segment focus `accent-soft`, and so on).
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `TimeValue\|null` | `value` / `defaultValue: HeroTime?` |
| `onChange` | `(TimeValue\|null) => void` | `onChanged: ValueChanged<HeroTime?>` |
| `placeholderValue` | `TimeValue` (12:00 AM / 00:00) | `placeholderValue: HeroTime?` |
| `isRequired` / `isInvalid` | `boolean` | same |
| `minValue` / `maxValue` | `TimeValue` | `minValue` / `maxValue: HeroTime?` |
| `validate` | fn | `validator: String? Function(HeroTime?)` (+ `onSaved`, `autovalidateMode`) |
| `validationBehavior` | `'native'\|'aria'` (native) | `validationBehavior: HeroValidationBehavior` |
| `granularity` | `'hour'\|'minute'\|'second'` (minute) | `granularity: HeroTimeGranularity` |
| `hourCycle` | `12\|24` | `hourCycle: HeroHourCycle?` |
| `hideTimeZone` | `boolean` (false) | `hideTimeZone: bool` (no-op for `HeroTime` values; kept for parity and forwarded by pickers) |
| `shouldForceLeadingZeros` | `boolean` | `shouldForceLeadingZeros: bool?` |
| `isDisabled` / `isReadOnly` | `boolean` | same |
| `name` / `autoFocus` | | `name` / `autofocus` |
| `fullWidth` | `boolean` | `fullWidth: bool` |
| `aria-label` | | `semanticLabel` |
| `children` fn | field render props | `builder: (ctx, HeroFieldState)` |
| `Group.variant` / `fullWidth` | | `HeroDateInputGroup(variant:, fullWidth:)` |

- **States & behaviour:** segment engine as DateField with time segments only (hour, minute, second, dayPeriod). Hour wraps 1–12 (h12) or 0–23 (h24). ↑/↓ on minute/second step 1, PageUp/Down step 15, hour step 2. Validation: "Value must be {min} or later." / "… or earlier." (demo range 09:00–17:00). Semantics as DateField.
- **Docs examples:**
  1. `time-field-basic` — label + group, 256px.
  2. `time-field-with-prefix-icon` — clock prefix.
  3. `time-field-with-suffix-icon` — clock suffix.
  4. `time-field-with-prefix-and-suffix` — clock + chevron-down, description.
  5. `time-field-on-surface` — two secondary fields in a Surface.
  6. `time-field-with-description` — start/end time descriptions.
  7. `time-field-required` — required, with and without description.
  8. `time-field-disabled` — disabled with the current time, and empty.
  9. `time-field-full-width` — 400px container, fullWidth field and group.
  10. `time-field-invalid` — FieldError ("Please enter a valid time", "Time must be within business hours").
  11. `time-field-controlled` — "Current value" description, Set now / Clear.
  12. `time-field-form-example` — Form, min 09:00, max 17:00, clock prefix, Submit pending.
  13. `time-field-with-validation` — 09:00–17:00 with conditional error.
  14. `time-field-render-function` — custom elements.
  15. `time-field-custom-styles` — max-w-48 (192px), description above the group, xl radius, surface bg, focus ring accent/15.
- **Depends on:** everything DateField uses (HeroDateInputGroup + segment engine, Label, Description, FieldError, Form); clock icon.

#### DatePicker → `HeroDatePicker`
- **Docs:** https://heroui.com/en/docs/react/components/date-picker · **Category:** Date and Time
- **Anatomy:** `DatePicker` (`.Root`) → `HeroDatePicker` (state owner; provides the DateField and Calendar scopes). `DatePicker.Trigger` → `HeroDatePickerTrigger`. `DatePicker.TriggerIndicator` → `HeroDatePickerTriggerIndicator` (default calendar icon). `DatePicker.Popover` → `HeroDatePickerPopover`. Composed with `HeroLabel`, `HeroDateInputGroup` / `HeroDateInput` / `HeroDateSegment` / `HeroDateInputSuffix`, and `HeroCalendar` (+ year picker parts). Convenience: `HeroDatePicker(label:, description:, errorMessage:, calendar: Widget?)`. If `calendar` is null it renders the docs default (group + suffix trigger + popover with a year-picker Calendar). Render-prop `children({state})` → `builder: (ctx, HeroDatePickerState state)` exposing `value`, `dateValue`, `timeValue`, `setTimeValue`, `isOpen`, `open()`, `close()`.
- **Variants:** none on the picker (the Group keeps primary*/secondary and `fullWidth`). Booleans `isDisabled`, `isInvalid`, `isRequired`, `isReadOnly`, `isOpen`/`defaultOpen`.
- **Key styles:**
  - Root: inline column, gap 4. Prefix/suffix become hit-testable inside the picker.
  - Trigger: inline row, full width, radius `field` (12), padding 4, 14px text, transition shadow 150ms ease-out. Focus-visible: `status-focused` (the group's focus ring is suppressed while the trigger has focus). Disabled: `status-disabled`.
  - TriggerIndicator: 16×16 centered, color `field-placeholder`.
  - Popover:
    - Box: width fit-content, bg `overlay`, padding 12, radius `min(32, radius×2.5)` = 20, shadow `overlay-shadow` (light `0 2 8 0 #0000000F, 0 −6 12 0 #00000008, 0 14 28 0 #00000014`; dark `inset 0 0 1 0 #FFFFFF4D`), vertical scroll with hidden scrollbar, placement `bottom`, transform origin = trigger anchor.
    - Enter: 150ms `ease`, opacity 0→1, scale 0.95→1, slide 4px from the trigger side. Exit: 100ms `ease`, opacity→0, scale→0.95, non-interactive while exiting.
  - Calendar nav icons are not RTL-mirrored inside the popover.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `DateValue\|null` | `value` / `defaultValue: DateTime?` |
| `onChange` | `(DateValue\|null) => void` | `onChanged: ValueChanged<DateTime?>` |
| `isOpen` / `defaultOpen` (false) | `boolean` | `isOpen: bool?` / `defaultOpen: bool` |
| `onOpenChange` | `(bool) => void` | `onOpenChanged: ValueChanged<bool>?` |
| `isDisabled` / `isInvalid` / `isRequired` / `isReadOnly` | `boolean` | same |
| `minValue` / `maxValue` | `DateValue` | `minValue` / `maxValue: DateTime?` (forwarded to field and calendar) |
| `isDateUnavailable` | fn | `isDateUnavailable: bool Function(DateTime)?` |
| `granularity` / `hourCycle` / `hideTimeZone` / `shouldForceLeadingZeros` | (RAC format props, used in demo) | same as HeroDateField |
| `placeholderValue` / `validate` / `validationBehavior` | | `placeholderValue` / `validator` / `validationBehavior` |
| `shouldCloseOnSelect` (RAC) | `boolean` (true) | `shouldCloseOnSelect: bool` |
| `firstDayOfWeek` / `pageBehavior` (RAC) | | forwarded to the default calendar |
| `name` | `string` | `name: String?` |
| `children` fn / `render` | `DatePickerRenderProps` | `builder:` / n/a |
| `Popover.placement` | (bottom) | `HeroDatePickerPopover(placement: HeroPlacement.bottom)` |
| `TriggerIndicator` children | | `child: Widget?` (default calendar icon) |

- **States & behaviour:**
  - Opening: trigger tap, Enter/Space on the trigger, or Alt+↓ in the field. On open, focus moves into the calendar (selected or today's cell).
  - Closing: selecting a date commits and closes (`shouldCloseOnSelect`). With time granularity the date merges with the current time value (placeholder time if none). Escape or an outside tap closes. After a keyboard-driven close, focus returns to the trigger.
  - Typing in the field keeps the calendar in sync (focusedValue follows value).
  - Validation merges field and calendar min/max/unavailable. Invalid → group invalid ring and FieldError.
  - Disabled: field and trigger disabled, popover can't open.
  - International calendar via locale. Semantics: trigger `button` labelled "Calendar" plus the field label, `expanded` = isOpen; the popover is a dialog route with a focus trap.
- **Docs examples:**
  1. `date-picker-basic` — 288px, fullWidth group with suffix trigger, popover Calendar with year picker.
  2. `date-picker-disabled` — isDisabled, value today, description.
  3. `date-picker-controlled` — value today, "Current value" line, Set today / Clear.
  4. `date-picker-with-validation` — required, min today, FieldError.
  5. `date-picker-format-options` — Select granularity (Day/Hour/Minute/Second, default minute), Select hour cycle (12/24), Switches "Hide timezone" / "Force leading zeros". Value is a zoned 2026-02-03 08:45. When the granularity is a time unit, the popover adds a secondary TimeField bound to `state.timeValue` (builder).
  6. `date-picker-form-example` — Form, min today, conditional error/description, Submit pending 1.2s.
  7. `date-picker-with-custom-indicator` — chevron-down icon indicator.
  8. `date-picker-render-function` — custom element wrappers.
  9. `date-picker-international-calendar` — `hi-IN-u-ca-indian`, default today.
  10. `date-picker-custom-styles` — secondary xl group with border, muted trigger, popover border + shadow-sm, calendar surface p-2 with lg-radius cells.
- **Depends on:** HeroDateField parts (DateInputGroup, segment engine), HeroCalendar (+ year picker), Popover/overlay foundation (anchored positioning, enter/exit animation, focus trap and restore), pressable Button primitive, focus ring, calendar icon. Demos use TimeField, Select, ListBox, Switch, Form, Button, Description, FieldError.

#### DateRangePicker → `HeroDateRangePicker`
- **Docs:** https://heroui.com/en/docs/react/components/date-range-picker · **Category:** Date and Time
- **Anatomy:** `DateRangePicker` (`.Root`) → `HeroDateRangePicker`. `.Trigger` → `HeroDateRangePickerTrigger`. `.TriggerIndicator` → `HeroDateRangePickerTriggerIndicator`. `.RangeSeparator` → `HeroDateRangePickerRangeSeparator` (default text `" - "`, excluded from semantics). `.Popover` → `HeroDateRangePickerPopover`. Composed with `HeroDateInputGroup` > `HeroDateInputContainer` > `HeroDateInput(slot: start)` + separator + `HeroDateInput(slot: end)` + `HeroDateInputSuffix`, and `HeroRangeCalendar`. Convenience `label`/`description`/`errorMessage`/`calendar`; `builder` exposes `HeroDateRangePickerState` (`value`, `dateRange`, `timeRange`, `setTimeRange`, `isOpen`, `open/close`).
- **Variants:** none (the Group keeps variant/fullWidth). Booleans `isDisabled`, `isInvalid`, `isRequired`, `isReadOnly`.
- **Key styles:** root, trigger, indicator and popover are identical to DatePicker (trigger radius 12, padding 4; indicator 16px `field-placeholder`; popover padding 12, radius 20, overlay shadow, 150/100ms animations, placement bottom). RangeSeparator: horizontal padding 4, color `field-placeholder`, not selectable. The separator changes input paddings: start input `flex-none` with end padding 0, end input start padding 0. InputContainer scrolls horizontally with a hidden scrollbar.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `{start, end}\|null` | `value` / `defaultValue: HeroDateRange?` |
| `onChange` | `(range\|null) => void` | `onChanged: ValueChanged<HeroDateRange?>` |
| `isOpen` / `defaultOpen` (false) / `onOpenChange` | | `isOpen` / `defaultOpen` / `onOpenChanged` |
| `isDisabled` / `isInvalid` / `isRequired` / `isReadOnly` | `boolean` | same |
| `minValue` / `maxValue` | `DateValue` | `minValue` / `maxValue: DateTime?` |
| `startName` / `endName` | `string` | `startName` / `endName: String?` |
| `isDateUnavailable` / `allowsNonContiguousRanges` (RAC) | | forwarded to the field and RangeCalendar |
| `granularity` / `hourCycle` / `hideTimeZone` / `shouldForceLeadingZeros` | (used in demo) | same as HeroDateField |
| `validate` / `validationBehavior` / `shouldCloseOnSelect` | | `validator: String? Function(HeroDateRange?)` / … |
| `children` fn / `render` | | `builder:` |
| `RangeSeparator` children | (`" - "`) | `child: Widget?` |

- **States & behaviour:** as DatePicker. Each input is its own segment group; ← from the first segment of the end input moves to the start input. The calendar commits the range after the second pick and then closes. The end is auto-ordered. Validation adds "end before start" invalidity (demo checks it manually). Time granularity: `timeRange` start/end TimeFields inside the popover (builder). Form: `startName`/`endName` keys.
- **Docs examples:**
  1. `date-range-picker-basic` — 320px, InputContainer with start/end + separator, RangeCalendar with year picker.
  2. `date-range-picker-disabled` — value today→+4, description.
  3. `date-range-picker-controlled` — today→+4, "Current value", Set week / Clear.
  4. `date-range-picker-with-validation` — required, min today, FieldError.
  5. `date-range-picker-format-options` — granularity/hour-cycle Selects + Switches. The popover (max 252px) adds Start/End TimeFields bound to `state.timeRange` and a "Selected: …" formatted range line (12px muted).
  6. `date-range-picker-form-example` — Form with tripStartDate/tripEndDate, Submit pending.
  7. `date-range-picker-with-custom-indicator` — chevron-down icon.
  8. `date-range-picker-render-function` — custom wrappers.
  9. `date-range-picker-international-calendar` — `hi-IN-u-ca-indian`, default today→+7.
  10. `date-range-picker-custom-styles` — secondary xl group, muted separator/trigger, bordered popover, surface calendar.
  (`release-input-container.tsx` exists in the demo folder but is not on the docs page; optional.)
- **Depends on:** HeroDateInputGroup + segment engine, HeroRangeCalendar, Popover/overlay foundation, focus ring, calendar icon. Demos use TimeField, Select, ListBox, Switch, Form, Button, Label, Description, FieldError.

#### ColorSwatch → `HeroColorSwatch`
- **Docs:** https://heroui.com/en/docs/react/components/color-swatch · **Category:** Colors
- **Anatomy:** single part `ColorSwatch` (`.Root`) → `HeroColorSwatch`.
- **Variants:** `size`: xs | sm | md* | lg | xl → `HeroColorSwatchSize {xs, sm, md, lg, xl}`. `shape`: circle* | square → `HeroColorSwatchShape {circle, square}`.
- **Key styles:**
  - Sizes: xs 16, sm 24, md 32, lg 36, xl 40 (square box, `shrink-0`).
  - Radius, circle: xs lg (8), sm xl (12), md 2xl (16), lg 3xl (24), xl 3xl (24). These tokens give circles at the default `--radius`; implement as tokenized radii, not `BoxShape.circle`. Square: md (6) at every size.
  - Paint order: checkerboard (see foundations; `#EFEFEF`/`#F7F7F7`, 16px tile, centered), then the color (with alpha) on top, then an inset 1px `rgba(0,0,0,0.1)` border (drawn inside, clipped to the radius).
  - Custom-styles demo overrides the box shadow (glow `0 0 20px 2px color`) and the background (135° gradient color→white). Expose `decoration`/`shadows` overrides or a `styleBuilder: (Color) → BoxDecoration`.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `color` | `string\|Color` | `color: Color?` (null → nearest HeroColorPickerScope) |
| `colorName` | `string` | `colorName: String?` |
| `shape` | `'circle'\|'square'` (circle) | `shape: HeroColorSwatchShape` |
| `size` | `'xs'…'xl'` (md) | `size: HeroColorSwatchSize` |
| `style` (fn with `{color}`) | `CSSProperties\|fn` | `decorationBuilder: BoxDecoration Function(Color)?` |
| `aria-label` | `string` | `semanticLabel: String?` |

- **States & behaviour:** static and not focusable. Semantics: image, label = `[colorName ?? heroColorName(color), semanticLabel].join(', ')` ("transparent" when alpha 0). Transparency renders over the checkerboard (demo alphas 1/.75/.5/.25/0).
- **Docs examples:**
  1. `color-swatch-basic` — five swatches (#0485F7, #EF4444, #F59E0B, #10B981, #D946EF) with aria-labels.
  2. `color-swatch-sizes` — xs…xl.
  3. `color-swatch-shapes` — circle vs square (#0485F7).
  4. `color-swatch-transparency` — rgba(4,133,247) at alpha 1/.75/.5/.25/0.
  5. `color-swatch-render-function` — custom element (same visuals).
  6. `color-swatch-accessibility` — colorName ("Ocean Blue" …) + aria-label context.
  7. `color-swatch-custom-styles` — glow row and gradient row (xl).
- **Depends on:** checkerboard painter, `heroColorName`, `heroParseColor`, HeroColorPickerScope.

#### ColorSwatchPicker → `HeroColorSwatchPicker`
- **Docs:** https://heroui.com/en/docs/react/components/color-swatch-picker · **Category:** Colors
- **Anatomy:** `ColorSwatchPicker` (`.Root`) → `HeroColorSwatchPicker`. `.Item` → `HeroColorSwatchPickerItem(color:)`. `.Swatch` → `HeroColorSwatchPickerSwatch`. `.Indicator` → `HeroColorSwatchPickerIndicator`. Convenience: `HeroColorSwatchPicker(colors: [...])` builds Item(Swatch + Indicator) per color.
- **Variants:**
  - `size`: xs | sm | md* | lg | xl → reuse `HeroColorSwatchSize`
  - `variant` (shape): circle* | square → `HeroColorSwatchShape`
  - `layout`: grid* (row wrap) | stack (column) → `HeroColorSwatchPickerLayout {grid, stack}`
  - Item `isDisabled`
- **Key styles:**
  - Root: `Wrap`, center-aligned, gap 8. Stack → column, gap 8.
  - Item size / border / circle radius: xs 16 / 1px / lg 8; sm 24 / 2px / xl 12; md 32 / 2px / 2xl 16; lg 36 / 3px / 3xl 24; xl 40 / 3px / 3xl 24. The border is transparent by default.
  - Square radii (item / swatch): xs md 6 / md 6; sm lg 8 / lg 8 (selected swatch md 6); md, lg and xl xl 12 / lg 8.
  - Swatch: fills the item's content box (item minus border, e.g. 28px at md) and inherits the item radius. It paints the RAC default swatch background (color over a checkerboard, no inset ring). Hover (hover devices): scale 1.1. Transition transform 100ms ease-out.
  - Selected item: border color = the item color, box shadow `field-shadow`, swatch scale 0.77 (reveals a gap of about 3px). Item transitions: border-color and shadow 100ms ease-out.
  - Focus-visible: `status-focused` ring. Disabled: `status-disabled`.
  - Indicator: overlay centered on the item, z 10, not hit-testable. Child is ⅓ of the item size, color white (black when luminance `(0.2126R+0.7152G+0.0722B)/255 > 0.5`; the CSS selector for this is broken in HeroUI, so implement the intent). Scale 0 → 1 when selected, 150ms ease-out.
  - Default checkmark: 12×12 viewBox polyline `2.5,6 5,8.5 9.5,3`, stroke 1.5, round caps and joins, no fill.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `string\|Color` | `value` / `defaultValue: Color?` (null value → picker scope) |
| `onChange` | `(Color) => void` | `onChanged: ValueChanged<Color>` |
| `size` | `'xs'…'xl'` (md) | `size: HeroColorSwatchSize` |
| `variant` | `'circle'\|'square'` (circle) | `variant: HeroColorSwatchShape` |
| `layout` | `'grid'\|'stack'` (grid) | `layout: HeroColorSwatchPickerLayout` |
| `children` | Items | `children: List<HeroColorSwatchPickerItem>` / `colors: List<Color>` |
| `Item.color` (required) / `Item.isDisabled` | `string\|Color` / bool | `HeroColorSwatchPickerItem(color:, isDisabled:, child:)` |
| `Item` children fn | `{color, isSelected, isDisabled, isFocusVisible…}` | `builder: (ctx, HeroSwatchItemState)` |
| `Indicator` children / fn | node / `(itemState) => node` | `HeroColorSwatchPickerIndicator(child:, builder:)` |
| `aria-label` | | `semanticLabel: String?` |

- **States & behaviour:** single selection that can't be emptied. Items match `value` by color equality (RGBA ignoring format). Keyboard: grid layout → 2D arrow navigation over the wrapped positions; stack → ↑/↓. Enter/Space selects; tap selects. Disabled items are skipped. Semantics: list container with the label; items are selectable buttons labelled `heroColorName(color)` with the selected state. Inside HeroColorPicker it reads and writes the picker color.
- **Docs examples:** all use the palette #F43F5E, #D946EF, #8B5CF6, #3B82F6, #06B6D4, #10B981, #84CC16.
  1. `color-swatch-picker-basic` — swatches with indicator.
  2. `color-swatch-picker-variants` — circle vs square with captions.
  3. `color-swatch-picker-sizes` — xs…xl rows with size labels.
  4. `color-swatch-picker-disabled` — all items disabled.
  5. `color-swatch-picker-stack-layout` — vertical.
  6. `color-swatch-picker-default-value` — #8B5CF6.
  7. `color-swatch-picker-controlled` — "Selected: #hex".
  8. `color-swatch-picker-custom-indicator` — heart-fill icon indicator.
  9. `color-swatch-picker-render-function` — custom element.
  10. `color-swatch-picker-custom-styles` — square variant in a bordered surface card (p-4, rounded-2xl), default #8B5CF6.
- **Depends on:** checkerboard painter, color equality/name utils, focus traversal (ListBox-like roving focus), focus ring, check icon, HeroColorPickerScope.

#### ColorArea → `HeroColorArea`
- **Docs:** https://heroui.com/en/docs/react/components/color-area · **Category:** Colors
- **Anatomy:** `ColorArea` (`.Root`) → `HeroColorArea`; `ColorArea.Thumb` → `HeroColorAreaThumb` (default thumb when `thumb` is null).
- **Variants:** `showDots` (bool, false). `isDisabled`.
- **Key styles:**
  - Area: width 100% capped at 224 (`max-w-56`), aspect 1:1, radius 2xl (16), inset 1px `rgba(0,0,0,0.1)` ring. Disabled: `status-disabled`.
  - Background: 2D gradient over x/y channels with the z channel fixed:
    - HSB s×b: horizontal white→pure hue, overlaid with vertical transparent (top) → black (bottom)
    - HSL s×l: horizontal hsl(h,0%,50%)→hsl(h,100%,50%), overlaid with vertical white (top) → transparent (middle) → black (bottom)
    - RGB channel pairs: base color with z, plus x and y 0→max gradients combined with `BlendMode.screen`
    - Hue axis: rainbow gradient
    - Implement with a CustomPainter (or a FragmentShader / cached `ui.Image`).
  - Dots overlay (`showDots`): white 20% alpha dots of 1px radius on an 8px grid, clipped to the radius.
  - Thumb:
    - Box: 16×16, radius xl (12 → circle), fill = current color at alpha 1, 3px solid white border.
    - Shadow: `0 0 0 1px rgba(0,0,0,.1)` + inset `0 0 0 1px rgba(0,0,0,.1)`.
    - Center sits at (x%, 100%−y%).
    - Dragging: 20×20, width/height transition 150ms ease-out. Focus-visible: `status-focused` ring. Disabled: `status-disabled`.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `string\|Color` | `value` / `defaultValue: Color?` (null → picker scope, else white) |
| `onChange` | `(Color) => void` (while dragging) | `onChanged: ValueChanged<Color>` |
| `onChangeEnd` | `(Color) => void` | `onChangeEnd: ValueChanged<Color>?` |
| `xChannel` | `ColorChannel` (docs: saturation) | `xChannel: HeroColorChannel?` |
| `yChannel` | `ColorChannel` (docs: brightness) | `yChannel: HeroColorChannel?` |
| `colorSpace` | `'rgb'\|'hsl'\|'hsb'` | `colorSpace: HeroColorSpace?` (default hsb) |
| `isDisabled` | `boolean` (false) | `isDisabled: bool` |
| `showDots` | `boolean` (false) | `showDots: bool` |
| `aria-label` | | `semanticLabel: String?` |
| `Thumb.style` / render props | | `thumb: Widget?`, `HeroColorAreaThumb(size:, decoration:)` (custom-styles demo: 20px thumb, full radius, 4px white border) |

- **States & behaviour:**
  - Pointer: tap or drag anywhere moves the thumb and updates both channels; `onChangeEnd` fires on release.
  - Keyboard (focus on thumb): ←/→ x ±step (RTL flips), ↑/↓ y ±step, Shift+arrows ±pageSize, PageUp/PageDown y ±pageSize, Home/End x −/+ pageSize.
  - Channel defaults: in Flutter, when `colorSpace`, `xChannel` and `yChannel` are all null, use hsb with x=saturation, y=brightness (the docs-table defaults). If only some are given, fill the missing axis from the space's channel list (hsb: hue/saturation/brightness; hsl: hue/saturation/lightness; rgb: red/green/blue), skipping the channel already used, as RAC `getColorSpaceAxes` does.
  - Caveat: React actually derives the defaults from the value's own color space, so the `rgb(116,52,255)` basic demo most likely renders x=red, y=green with blue fixed at 255. To pixel-match, the gallery passes `colorSpace: rgb, xChannel: red, yChannel: green` explicitly for the basic and render-function demos.
  - Semantics: two adjustable slider nodes (x and y) with value texts (e.g. "Saturation 58%"), grouped under a "2D slider" container label.
- **Docs examples:**
  1. `color-area-basic` — default rgb(116, 52, 255).
  2. `color-area-with-dots` — showDots, hsl(200,100%,50%).
  3. `color-area-space-and-channels` — Selects for space (RGB/HSL/HSB) and X/Y channels (the same channel can't be on both axes), plus a 32px preview box and a `toString(space)` code chip. Initial hsb(219,58%,93%).
  4. `color-area-disabled` — isDisabled.
  5. `color-area-controlled` — rgb space, x=red y=green, #9B80FF, ColorSwatch md + "Current color: #hex".
  6. `color-area-render-function` — custom elements.
  7. `color-area-custom-styles` — 176px area, radius 3xl, custom thumb.
- **Depends on:** color foundations (HSV/HSL conversion, channel ranges, formatting), gradient painter, drag/gesture + focus foundation (shared with Slider), focus ring, HeroColorPickerScope. Demos use Select, ListBox, Label, ColorSwatch.

#### ColorSlider → `HeroColorSlider`
- **Docs:** https://heroui.com/en/docs/react/components/color-slider · **Category:** Colors
- **Anatomy:** `ColorSlider` (`.Root`) → `HeroColorSlider`; `.Output` → `HeroColorSliderOutput`; `.Track` → `HeroColorSliderTrack`; `.Thumb` → `HeroColorSliderThumb`. The label is a composed `HeroLabel`. Convenience params: `label: String?`, `showOutput: bool` (default true when label given); default track + thumb when `child` is null.
- **Variants:** `orientation`: horizontal* | vertical → `Axis`. `isDisabled`.
- **Key styles:**
  - Layout: grid with areas `label | output` (output auto-width, end-aligned) over `track` spanning both. Gap 4. Collapses when label/output are absent (track only → gap 0).
  - Label: 14px/500, `w-fit`. Output: 14px/500, tabular figures.
  - Vertical layout: centered column `output / track / label`, gap 8, fills the height.
  - Horizontal track:
    - Height 20, width = 100% − 20px, centered, main part square-cornered.
    - Border: inset top and bottom 1px `rgba(0,0,0,.1)`.
    - Background: the channel gradient over the checkerboard.
    - Edge caps: 10px wide pieces outside each end with radius 2xl on the outer corners and 1px `rgba(0,0,0,.1)` inset borders on the outer sides. The start cap is the channel-min color over the checkerboard; the end cap is the channel-max color (no checkerboard). This makes the track visually full-width with rounded ends.
  - Vertical track: width 20, height = 100% − 20px, left/right inset borders. The bottom cap (start/min) has bottom radius 999; the top cap (end/max) has top radius 999. Gradient runs bottom→top.
  - Gradients: hue → 7 stops hsl(0,60,…,360, 100%, 50%). Other channels → displayColor with the channel at min → max. Alpha → the color at alpha 0 → 1. Direction follows RTL.
  - Thumb:
    - Box: 16×16, radius 2xl (circle), 3px white border, shadow `overlay-shadow`.
    - Fill = display color: pure hue for the hue channel, the value at alpha 1 for s/l/b/rgb, the value including alpha for alpha.
    - Centered on the value position (cross-axis centered). Transitions: transform 250ms ease-out, shadow 150ms ease-out.
    - Cursor grab (grabbing while dragging). Focus-visible: ring, z 10. Disabled: fill `default` (gray).
  - Disabled root: `status-disabled`.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `channel` | `ColorChannel` | `channel: HeroColorChannel` (required) |
| `colorSpace` | `ColorSpace` (value's space) | `colorSpace: HeroColorSpace?` |
| `value` / `defaultValue` | `string\|Color` | `value` / `defaultValue: Color?` (null → picker scope) |
| `onChange` / `onChangeEnd` | `(Color) => void` | `onChanged` / `onChangeEnd: ValueChanged<Color>?` |
| `orientation` | `'horizontal'\|'vertical'` (horizontal) | `orientation: Axis` |
| `isDisabled` | `boolean` | `isDisabled: bool` |
| `name` | `string` | `name: String?` |
| `aria-label` | `string` | `semanticLabel: String?` |
| `children` fn | `{state, color, orientation, isDisabled}` | `builder: (ctx, HeroColorSliderState)` |
| `Output` children fn | | `HeroColorSliderOutput(builder:)` (default = formatted channel value) |
| `Track.style` / `Thumb.style` | | `HeroColorSliderTrack(thickness:, radius:)` / `HeroColorSliderThumb(size:, decoration:)` |

- **States & behaviour:**
  - Channel/space auto-correction (debug-only warning): red/green/blue → rgb, lightness → hsl, brightness → hsb, hue/saturation with rgb → hsl. Default when null: hue/saturation/lightness/alpha → hsl, brightness → hsb, rgb channels → rgb.
  - Keyboard: ←/→ (horizontal, RTL-aware) or ↑/↓ ±step, PageUp/PageDown ±pageSize, Home/End min/max. Tapping the track jumps there; drag updates; `onChangeEnd` fires on release.
  - Output text: "0°", "100%", "255", "50%" (alpha).
  - Semantics: slider (`value` text, `increasedValue`/`decreasedValue`), label from Label/semanticLabel. Disabled blocks input.
- **Docs examples:**
  1. `color-slider-basic` — hue with Label + Output, max-w-xs (320px).
  2. `color-slider-disabled` — hue at 200.
  3. `color-slider-vertical` — three 192px-high vertical sliders (hue, saturation, lightness) without labels.
  4. `color-slider-controlled` — hue with a sm ColorSwatch + "Current color: hsl(...)".
  5. `color-slider-channels` — H/S/L sliders sharing one value.
  6. `color-slider-alpha-channel` — hsla(0,100%,50%,.5).
  7. `color-slider-rgb-channels` — R/G/B from rgb(255,100,50).
  8. `color-slider-render-function` — custom element.
  9. `color-slider-custom-styles` — 16px track with sm cap radii and a ring, 16px thumb with sm radius and 2px background-colored border.
- **Depends on:** Label, color foundations, checkerboard + gradient painters, slider interaction foundation (shared with HeroSlider), focus ring, HeroColorPickerScope. Demos use ColorSwatch.

#### ColorField (incl. ColorInputGroup) → `HeroColorField`
- **Docs:** https://heroui.com/en/docs/react/components/color-field · **Category:** Colors
- **Anatomy:** `ColorField` (`.Root`) → `HeroColorField` (FormField). `ColorField.Group` (= `ColorInputGroup`) → `HeroColorInputGroup`. `.Input` → `HeroColorInput` (TextField). `.Prefix` / `.Suffix` → `HeroColorInputPrefix` / `HeroColorInputSuffix`. Uses HeroLabel, HeroDescription, HeroFieldError, and `HeroColorSwatch` in the prefix. Convenience params `label`, `description`, `errorMessage`, `placeholder`, `startContent`, `endContent`, `variant`, `showSwatch` (xs swatch prefix bound to the value).
- **Variants:** Group `variant`: primary* | secondary. `fullWidth` (false) on field and group. Booleans `isRequired`, `isInvalid`, `isDisabled`, `isReadOnly`, `isWheelDisabled`.
- **Key styles:**
  - Root: column, gap 4, Description hidden when invalid, label `w-fit`.
  - Group: identical to the DateInputGroup box (height 36, radius field 12, bg `field-background`, text 14 `field-foreground`, `field-shadow`, border `--field-border-width`/`field-border`, transitions 150ms, hover `field-hover`/`field-border-hover`, focus-within `status-focused-field`, invalid `status-invalid-field` + bg `field-focus` + border `field-border-invalid`, disabled `status-disabled`). Secondary: no shadow, bg `default`/`default-hover`/`default`.
  - Input: fills the height, `flex-1`, padding 12×8, text 16px (<640) / 14px, placeholder `field-placeholder`, text cursor. With Prefix → start padding 8; with Suffix → end padding 8.
  - Prefix: start margin 12, color `field-placeholder`. Suffix: end margin 12. Both are hit-testable (unlike date prefix/suffix).
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `Color\|string\|null` | `value` / `defaultValue: Color?` (null value → picker scope) |
| `onChange` | `(Color\|null) => void` | `onChanged: ValueChanged<Color?>` |
| `colorSpace` | `ColorSpace` | `colorSpace: HeroColorSpace?` |
| `channel` | `ColorChannel` (hex when absent) | `channel: HeroColorChannel?` |
| `isRequired` / `isInvalid` | `boolean` | same |
| `validate` / `validationBehavior` | fn / (native) | `validator: String? Function(Color?)` / `validationBehavior` |
| `isDisabled` / `isReadOnly` / `isWheelDisabled` | `boolean` | same |
| `name` / `autoFocus` | | `name` / `autofocus` |
| `fullWidth` | `boolean` (false) | `fullWidth: bool` |
| `aria-label` | | `semanticLabel` |
| `children` fn | field render props | `builder: (ctx, HeroFieldState)` |
| `Group.variant` / `fullWidth` | `'primary'\|'secondary'` | `HeroColorInputGroup(variant:, fullWidth:)` |
| `Input.placeholder` | `string` | `placeholder: String?` (+ `controller`, `focusNode`) |

- **States & behaviour:**
  - Hex mode: free text. On blur/Enter it parses (`#RGB`, `#RRGGBB`, with or without `#`), commits and reformats to `#RRGGBB`. Invalid text reverts to the last valid value, or null if empty. ↑/↓ ±1 on the hex integer, PageUp/Down larger step, Home/End #000000/#FFFFFF. The mouse wheel steps while focused unless `isWheelDisabled`.
  - Channel mode: numeric field for that channel (range/step from the channel table, no unit rendered; the demo adds a "%" suffix), with ↑/↓/PageUp/PageDown/Home/End stepping.
  - `isInvalid` or failing validation → invalid ring + FieldError.
  - Semantics: text field (channel mode adjustable: increase/decrease).
- **Docs examples:**
  1. `color-field-basic` — controlled #0485F7 with an xs swatch prefix, 280px.
  2. `color-field-variants` — primary #0485F7 / secondary #F43F5E.
  3. `color-field-on-surface` — secondary inside a Surface (320px, p-4).
  4. `color-field-with-description` — two fields.
  5. `color-field-required` — placeholder "#000000".
  6. `color-field-disabled` — with value, and empty.
  7. `color-field-full-width` — 400px container.
  8. `color-field-invalid` — FieldError; the second field has invalid text "not-a-color".
  9. `color-field-channel-editing` — three 100px HSL channel fields (hue, saturation %, lightness %) sharing #7F007F + md swatch + "Current: #hex".
  10. `color-field-controlled` — Set Red / Set Green / Clear.
  11. `color-field-form-example` — Form, required, swatch prefix, "Save Color" pending 1.5s.
  12. `color-field-render-function` — custom elements.
  13. `color-field-custom-styles` — secondary xl group, md-radius swatch, monospace input.
- **Depends on:** field-surface foundation (shared with InputGroup/DateInputGroup), HeroTextField/EditableText, number-field stepping logic (shared with NumberField), Label, Description, FieldError, Form, ColorSwatch, color parse/format utils, HeroColorPickerScope. Demos use Surface and Button.

#### ColorPicker → `HeroColorPicker`
- **Docs:** https://heroui.com/en/docs/react/components/color-picker · **Category:** Colors
- **Anatomy:** `ColorPicker` (`.Root`) → `HeroColorPicker` (state owner + `HeroColorPickerScope` + popover controller). `ColorPicker.Trigger` → `HeroColorPickerTrigger`. `ColorPicker.Popover` → `HeroColorPickerPopover`. Children (ColorSwatch, ColorArea, ColorSlider, ColorField, ColorSwatchPicker) without their own value bind to the picker color. Convenience: `HeroColorPicker(label:, popoverChildren:)`. If only `label` is given it renders the Basic anatomy (lg swatch + label trigger; popover with an HSB area and hue slider).
- **Variants:** none. The Flutter API adds `isOpen`/`defaultOpen`/`onOpenChanged` (the React DialogTrigger is uncontrolled).
- **Key styles:**
  - Root: inline row.
  - Trigger: inline row, center-aligned, gap 12, radius sm (4), 14px text, pointer cursor (label too). Transitions bg 150ms ease, shadow 150ms ease-out. Focus-visible `status-focused`; disabled `status-disabled`.
  - Popover:
    - Box: min width 248 (`min-w-62`), bg `overlay`, padding 8 top / 8 horizontal / 12 bottom, radius `min(32, radius×2.5)` = 20, shadow `overlay-shadow`.
    - Content: column with gap 12, vertical scroll with hidden scrollbar, horizontal clip.
    - Placement `bottom left` (bottom-start), origin = trigger anchor.
    - Enter: 150ms `ease`, fade from 0, scale 0.95→1, 4px slide from the trigger side. Exit: 100ms, fade out, scale→0.95.
  - Nested fields render with the surface "default" context.
- **Props → Flutter:**

| React prop | Type | Flutter param |
|---|---|---|
| `value` / `defaultValue` | `string\|Color` | `value` / `defaultValue: Color?` |
| `onChange` | `(Color) => void` | `onChanged: ValueChanged<Color>` |
| `children` | Trigger + Popover | `trigger: Widget` + `popover: Widget`, or `child` with parts |
| `Trigger.children` (fn) | node / render props | `HeroColorPickerTrigger(child:, builder:)` |
| `Popover.placement` | `Placement` (`'bottom left'`) | `HeroColorPickerPopover(placement: HeroPlacement.bottomStart, children:)` |
| (added) | | `isOpen`, `defaultOpen`, `onOpenChanged` |

- **States & behaviour:**
  - A trigger tap, Enter or Space opens the popover and moves focus to its first focusable child (ColorArea thumb). Escape or an outside tap closes it and returns focus to the trigger.
  - All bound children update live. The value keeps its HSV/HSL hue via the scope cache (e.g. dragging brightness to 0 keeps the hue).
  - Semantics: trigger is a button with `expanded`; the popover is a dialog.
- **Docs examples:**
  1. `color-picker-basic` — #0485F7, trigger (lg swatch + "Pick a color"), popover with a full-width HSB area and a hue slider (Label + muted Output).
  2. `color-picker-controlled` — #325578 controlled. Popover gap 8: xs ColorSwatchPicker of 9 presets, area, hue slider (no label) + sm tertiary icon-only shuffle button (random HSL, s 50–100, l 40–70), secondary ColorField with xs swatch prefix. "Selected: #hex" below.
  3. `color-picker-with-swatches` — #F43F5E, area + hue slider + xs preset swatch picker.
  4. `color-picker-with-fields` — hsla(220,90%,50%,.8), popover max-w 248 gap 8, area + hue slider + secondary Select (hsl/hsb/rgb, uppercase) + 3-column grid of secondary channel ColorFields.
  5. `color-picker-with-sliders` — hsl(219,58%,93%), color-space Select + 4 channel sliders (3 channels + alpha) with capitalized labels.
  6. `color-picker-custom-styles` — trigger xl radius bg `default-soft` padding 12×8, popover bg surface.
- **Depends on:** Popover/overlay foundation (anchored, animated, focus trap/restore), pressable/focus ring, HeroColorPickerScope, ColorSwatch, ColorArea, ColorSlider, ColorField, ColorSwatchPicker, Label. Demos use Button (icon-only), Select, ListBox, and a shuffle icon.

# Part III — HeroUI Pro

Research date: 2026-09-24. Scope: HeroUI **Pro v3** (`@heroui-pro/react` 1.0.0-beta.10, Sept 2026, built on
HeroUI OSS 3.2.6 + React Aria), its templates, and its premium themes, reconstructed only from public material.

**What is publicly available (and what isn't).** Pro source and the npm package are license-gated, but a lot is public:

- `https://heroui.pro/llms.txt`, `/docs/react/llms.txt`, `/docs/react/llms-full.txt` (660 KB, every Pro React doc page:
  anatomy, props tables, CSS class lists, CSS variables), `/docs/native/llms.txt`, plus per-page `.mdx` endpoints.
- The templates run live and unauthenticated at `heroui.pro/templates/{dashboard,email,chat,finances,crm}/…`. Their
  server-rendered HTML shows every page's content. The same stylesheet ships the **compiled Pro component CSS**, which gives
  exact paddings, radii, sizes and colours.
- The theme builder loads **`https://heroui.pro/themes/{brutalism,glass,mouve}.css`**. These are the complete premium
  theme files, and their exact values are quoted in §3.
- Nothing was blocked by the proxy (no 403s). A few requests hit transient TLS resets and succeeded on retry. `robots.txt`
  disallows `/docs/_next/` and `/docs/react/demos/`, so nothing under those paths was fetched.

**Totals (React Pro):** 66 documented component pages (47 at beta.1, plus 14 AI components in beta.5, then Agenda, Rich Text
Editor, Timeline, Map and HoloCard). There are 5 web templates (Dashboard, Mail/Email, Chat, Finances, CRM) and 3 premium
themes (Brutalism, Glass, Mouve) on top of Default. The marketing names **"Stats"** and **"Filters"** on the home page map to
KPI and a composite filter panel; see §1.10.

---

### 0. Conventions to mirror (apply to every `HeroPro*` widget)

- **Compound parts.** Every Pro component uses dot-notation parts (`Kanban.Column`, `KPI.Chart`). Per API_CONVENTIONS,
  `X.Y` becomes `HeroProXY` (for example `HeroProKanbanColumn`). The parent shares state with its parts through an
  InheritedWidget, and the common fixed layouts also get convenience params.
- **Sizes and variants.** Sizes are almost always `sm | md | lg` (default `md`). Surface variants are `primary | secondary`,
  or `default | secondary | tertiary | outline | transparent` for cards. Secondary is for use on top of a
  Surface/Modal/Sheet. `default` maps to `standard` in Dart.
- **Tokens.** Pro reads the same OSS tokens (`--background`, `--surface*`, `--overlay`, `--default`, `--accent`, `--muted`,
  `--border`, `--separator`, `--field-*`, `--*-soft`, `--surface-shadow`, `--overlay-shadow`, `--radius`,
  `--field-radius`). It adds only:
  - **Chart palette**, centred on the accent:
    `--chart-1 = oklch(from accent l-0.24)`, `--chart-2 = l-0.12`, `--chart-3 = accent`, `--chart-4 = l+0.12`,
    `--chart-5 = l+0.24`.
  - **Theme-specific tokens:** `--glass-blur`, `--background-gradient`, `--glass-pinned-surface[-secondary]`,
    `--brutalism-font-body/-display`, and `--mouve-raised-shadow`, `--mouve-pressed-shadow`, `--mouve-accent-fill-shadow`.
- **Spacing unit** is 4 px (`--spacing: .25rem`).
- **Radius scale:** `xs = .25R`, `sm = .5R`, `md = .75R`, `lg = 1R`, `xl = 1.5R`, `2xl = 2R`, `3xl = 3R`, `4xl = 4R`, where
  `R = --radius` (default 0.5rem = 8 px). `field-radius` defaults to 1.5R. Pro CSS mostly uses `2R` (16 px) for cards and
  surfaces, `1.5R` for inner cards, and `1R` for rows and items.
- **Motion.** CSS-only enter/exit via `data-entering`/`data-exiting`. Typical timings are fade/zoom-95 at 150–200 ms enter and
  100 ms exit, and the sidebar/aside at 200 ms ease. Everything honours reduced motion via `reduceMotion` props and the
  platform setting.
- **Icons.** Gravity UI icons are bundled.
- **Numbers.** NumberFlow animates numbers in NumberValue, NumberStepper and KPI.
- **RTL.** Logical properties are used throughout; mirror them with `EdgeInsetsDirectional` and `AlignmentDirectional`.
- **Pro → OSS.** The OSS `Typography`/`Text` compound component was ported from Pro in OSS 3.0.4, so it is not Pro any more.

---

### 1. Pro components

Format per entry: **Flutter name**, then **What / anatomy / variants** (with CSS metrics where extracted), then **Built from**
(OSS hero_ui primitives). "R" = `--radius`. Sizes are shown as mobile/desktop pairs where they differ.

#### 1.1 Charts (web: Recharts; Flutter: a CustomPainter-based chart kit, or a wrapped charting package)

All cartesian charts share the same root props: `data` (list of maps), `height` = 300, `width` = 100%, and
`margin {top: 8, right: 8, bottom: 0, left: 0}`. Parts are `Grid`, `XAxis`, `YAxis`, `Tooltip` and `TooltipContent`.

Shared theming:

- Axis tick labels are 10 px in the muted colour.
- Axis lines and tick lines are hidden.
- Grid lines use the muted stroke at 0.15 opacity.
- The hover cursor is a dashed vertical line; bar charts use a subtle filled rectangle instead.
- The active dot is outlined in the surface colour.
- Series colours are `--chart-1…5`.

**`HeroProAreaChart`** (AreaChart)
- **What:** trend area with gradient fill (`linearGradient` from colour at about 20–40% to 0).
- **Variants:** single, multi-area, stacked, sparkline (no axes/grid), custom tooltip, and "KPI with area chart".
- **Data:** `null` values create gaps; `connectNulls` bridges them.
- **Built from:** chart painter + `HeroProChartTooltip`.

**`HeroProBarChart`** (BarChart)
- **What:** categorical bars.
- **Variants:** `layout: horizontal | vertical`, grouped, stacked, horizontal-stacked, comparison, waterfall, and "KPI with bar
  chart".
- **Look:** rounded bar tops, as in the dashboard's "Sales Performance".
- **Built from:** painter + ChartTooltip.

**`HeroProLineChart`** (LineChart)
- **What:** multi-series lines.
- **Variants:** dashed comparison (previous period dashed), with dots, sparkline, portfolio (step-ish line), traffic source
  (two series), "stats with chart", and custom tooltip.

**`HeroProComposedChart`** (ComposedChart)
- **What:** mixes `Bar`, `Line` and `Area` series on shared axes.
- **Demos:** stacked-bar + line, area + line, bar + area, and multi-type.

**`HeroProPieChart`** (PieChart)
- **What:** pie and donut.
- **Variants:** donut, donut with centre content, donut with centre label, nested donut (two rings), and "with breakdown"
  (legend list with values and %).
- **Details:** no sector strokes (use `paddingAngle` for gaps). Outside labels are 11 px muted, with connector lines in muted
  at 0.3 opacity.

**`HeroProRadarChart`** (RadarChart)
- **What:** polar grid (concentric polygons or circles at 0.2 opacity), angle axis labels 11 px, radius axis 10 px.
- **Variants:** multi-series, comparison, dots-only, and with radius axis.

**`HeroProRadialChart`** (RadialChart)
- **What:** concentric radial bars.
- **Props:** `barSize` 10, `innerRadius` 30%, `outerRadius` 80%, `startAngle` 90, `endAngle` −270.
- **Look:** the track uses the separator colour.
- **Variants:** gauge, gauge grid, progress ring, and with legend.

**`HeroProChartTooltip`** (ChartTooltip)
- **Anatomy:** `Header`, `Item` → `Indicator` + `Label` + `Value`.
- **Look:** card with R radius, 1 px separator border, overlay background, overlay shadow, 12×8 padding, min width 140,
  tabular numbers.
- **Details:** header is 12 px medium muted. The indicator is `dot` (8 px circle) or `line` (4×12 pill). Label is 12 px muted
  (flex 1); value is 12 px semibold.
- **Auto content:** `hideHeader`, `labelFormatter`, `valueFormatter`.
- **Built from:** Surface/Card look, Popover positioning.

**`HeroProWidget`** (Widget)
- **What:** dashboard container. The shell is `surface-secondary`, radius 2R, with a flex column. It holds a header (min height
  32, padding-x 16, title 14 semibold + description 12 muted, legend or actions on the right), an inset **content** card
  (`surface`, radius 1.5R, 6 px margin, padding 16, hairline shadow `0 0 0 1px #00000008, 0 1px 2px #0000000a`), an optional
  footer, and a `Legend` of `LegendItem`s (10 px dot + 12 px muted label).
- **Used for:** charts, tables (with the Table `secondary` variant and `p-0`), and KPI groups. A "dashboard grid" pattern
  composes several widgets.
- **Built from:** Surface, Card, Separator.

#### 1.2 Data display

**`HeroProKpi`** (KPI, "Stats")
- **What:** metric card built on Card. Radius 2R, padding 16, column layout.
- **Anatomy:**
  - `Header`: icon, title and actions, gap 8.
  - `Icon`: 32 px square, radius R, status-tinted success/warning/danger at 10%.
  - `Title`: 14 medium muted.
  - `Content`: grid of value | trend.
  - `Value`: 24 px semibold, tight tracking; wraps NumberValue with currency, percent and compact formats.
  - `Trend`: a TrendChip.
  - `Progress`: full-width bar with status colour.
  - `Chart`: area sparkline, default height 80, stroke 2, fill 20%, edge-fade mask 10%. At the bottom of the card it bleeds
    to the edges.
  - `Separator`: edge to edge.
  - `Actions`: absolute top-end ghost icon button with the "…" icon.
  - `Footer`.
- **Variants:** with icon, chart inline, chart bottom, chart tooltip, progress, footer, and actions.
- **Built from:** Card, Chip, ProgressBar, Button, Separator, AreaChart.

**`HeroProKpiGroup`** (KPIGroup)
- **What:** one surface (surface background + surface shadow, radius 2R) holding several KPIs.
- **Layout:** horizontal with equal-width children and 1 px vertical separators inset 16 px, or vertical. Children lose their
  own border, shadow and radius.
- **Built from:** Surface, Separator.

**`HeroProTrendChip`** (TrendChip)
- **What:** Chip with `trend: up | down | neutral`. Up gets success colour and an up arrow; down gets danger and a down arrow;
  neutral gets warning.
- **Props:** `variant` primary/secondary/**soft** (default)/tertiary; size sm (default)/md/lg with an arrow of 12, 14 or 16 px.
- **Parts:** `Prefix`, `Indicator`, `Suffix` (muted). The value uses tabular numbers.
- **Built from:** Chip.

**`HeroProNumberValue`** (NumberValue)
- **What:** locale-aware number formatting.
- **Props:** `style` decimal/currency/percent/unit, `notation` standard/compact/…, `signDisplay`, fraction digits, `locale`.
- **Parts:** `Prefix` and `Suffix`. Can animate between values.
- **Built from:** `intl` NumberFormat and an animated digit roller.

**`HeroProDataGrid`** (DataGrid)
- **What:** full-featured grid on top of Table; not a compound component. You pass `data`, `columns: DataGridColumn<T>` and
  `getRowId`.
- **Column definition:** `id`, `header` (string or `builder(sortDirection)`), `accessorKey`, `cell(item)`, `isRowHeader`,
  `allowsSorting`, `sortFn`, `allowsResizing`, `width`/`minWidth`/`maxWidth`, `align`, `pinned: start | end`.
- **Selection:** none/single/multiple with checkbox column (40 px) and toggle/replace behaviour.
- **Sorting:** controlled or uncontrolled; the sort chevron is 12 px and rotates 180°.
- **Other features:**
  - Column resize.
  - Pinned columns: sticky, pinned header on surface-secondary, pinned cells on surface, and a separator shown when detached.
  - Drag reorder: 32 px handle column, grab cursor, 2 px accent drop line, dragged row at 0.5 opacity.
  - Tree rows via `getChildren`: 24 px chevron toggle rotating 90°, indent 20 px per level.
  - Editable cells (any widget in `cell`).
  - `renderEmptyState` (48 px vertical padding).
  - Infinite `onLoadMore` sentinel.
  - Virtualisation (`rowHeight` 42, `headingHeight` 36).
  - `footer` slot (pagination/totals, full width, does not scroll horizontally).
  - `verticalAlign`.
- **Variants:** primary/secondary.
- **Demos:**
  - "Users" (secondary, read-only).
  - "Team members": sort, select, pin, resize, column toggle, search, filters, pagination.
  - "Servers": status chips, ProgressCircle cells, sparkline cells. This is the home "DataGrid" preview, with a toolbar of
    Filter / Sort / Columns pill buttons plus search.
- **Built from:** Table, Checkbox, Chip, Pagination, SearchField, Dropdown/Menu (column toggle), ProgressCircle, Spinner,
  ScrollShadow, EmptyState.

**`HeroProActionBar`** (ActionBar)
- **What:** floating pill toolbar fixed bottom-centre, 24 px from the bottom. It animates in and out on `isOpen`.
- **Anatomy:** Toolbar with radius 3R and padding 6×12 (4×8 on mobile), split into `Prefix` (count chip, gap 10), `Content`
  (ghost buttons, gap 4) and `Suffix` (clear ×), with Separators between them.
- **Props:** `isAttached` (surface + rounding), `orientation`.
- **Labels:** the `action-bar__label` class collapses to screen-reader-only text below 640 px, so buttons become icon-only.
- **Paired with:** DataGrid or ListView selection.
- **Built from:** Toolbar, Chip, Button, Separator, Tooltip.

**`HeroProKanban`** (Kanban)
- **What:** horizontally scrolling, snap-aligned board of columns.
- **Sizes:**

  | Size | Min column width | Gap | Card padding | Card text |
  | ---- | ---------------- | --- | ------------ | --------- |
  | sm   | 240              | 12  | 8            | xs        |
  | md   | 280              | 16  | 12           | sm        |
  | lg   | 320              | 20  | 16           | base      |

- **Anatomy:**
  - `Column`.
  - `ColumnHeader` (padding 4×6, gap 8), containing:
    - `ColumnIndicator`: 10 px status dot, or a 16 px icon.
    - `ColumnTitle`: 14 semibold.
    - `ColumnCount`: 12 medium muted.
    - `ColumnActions`: "…" and "+" buttons that fade in on header hover.
  - `ColumnBody`: `default` background, radius 2xl + sm, min height 100.
  - `ScrollShadow` (optional).
  - `CardList`: gap 8, padding 8 with 16 at the bottom, backed by a grid list with selection.
  - `Card`: radius 1.5R; content on overlay background with a shadow on hover and accent-soft when selected; 0.5 opacity
    while dragging; drag handle revealed on keyboard focus.
  - `DropIndicator`: card-height placeholder with a 1 px separator border and animated height.
- **State hooks:** `useKanban` (items, column getter/setter, `moveItem`), `useKanbanColumn`, `useKanbanCardPlaceholder`.
- **Demos:** "Project board" and "Notion board".
- **Typical card** (per the home preview and the Tracker template): title, 2-line muted description, footer row with icon
  counters (comments, attachments) and an avatar. Tracker cards add a tag chip, due date, subtask "1 / 4" and an avatar group.
- **Built from:** ScrollShadow, Card, Chip, Avatar/AvatarGroup, Button, Dropdown.

**`HeroProListView`** (ListView)
- **What:** single-column interactive list (grid list) with keyboard navigation, typeahead, selection (checkboxes
  auto-rendered), `disabledKeys`, `href` items, `onAction`, virtualisation (row 48), and an empty state.
- **Variants:**
  - `primary`: gray `surface-secondary` wrapper with padding 4 and radius 2.5R. White surface rows, 16×12 padding, gap 12,
    `separator-tertiary` dividers; first and last rows rounded 2R.
  - `secondary`: transparent rows with bottom borders; hover is `default`, selected is `accent-soft`.
- **Parts:** `Item`, `ItemContent` (16 px muted icon plus text), `Title` (14 medium, truncates), `Description` (12 muted),
  `ItemAction`.
- **Paired with:** ActionBar.
- **Built from:** ListBox-style collection, Checkbox, Button.

**`HeroProItemCard`** (ItemCard)
- **What:** horizontal settings/list card. Radius 2R, padding 16×12, gap 12.
- **Parts:**
  - `Icon`: 36 px, radius R, `default` background, 16 px glyph.
  - `Content`: `Title` (14 medium, truncates) and `Description` (12 muted).
  - `Action`: trailing slot for a Switch, Select, Button or Chip.
- **Variants:** default (surface + shadow), secondary, tertiary, outline, transparent. Can be pressable.
- **Demos:** device list, email setting, wallet card, with switch / select / multi-select.
- **Built from:** Surface, Switch, Select, Button.

**`HeroProItemCardGroup`** (ItemCardGroup)
- **What:** groups ItemCards into a `list` (single surface, auto-dividers, children flattened) or a `grid` (2 or 3 columns,
  gap 12, each card its own surface).
- **Parts:** `Header` (16 px padding), `Title` (14 semibold), `Description` (12 muted).
- **Variants:** same as ItemCard.
- **Demos:** linked accounts, notification preferences, permission levels, wallet list.
- **Built from:** Surface, Separator.

**`HeroProEmptyState`** (EmptyState)
- **What:** centred column. `Media` is either `default` or `icon`; the icon variant is a circle on the `default` background.
- **Sizes:**

  | Size | Padding | Gap | Icon circle | Glyph | Title     |
  | ---- | ------- | --- | ----------- | ----- | --------- |
  | sm   | 16×24   | 12  | 40          | 16    | 14 px     |
  | md   | 24×32   | 16  | 48          | 20    | 16 px     |
  | lg   | 32×48   | 20  | 56          | 24    | 18 px     |

- **Parts:** `Header`, `Title` (semibold), `Description` (14 muted; 12 at sm), `Content` (actions).
- **Demos:** outline, full height, with avatar, with avatar group, with background.
- **Note:** OSS also now has an `empty-state`, so reuse it if the APIs match.
- **Built from:** Avatar, Button.

**`HeroProTimeline`** (Timeline)
- **What:** read-only chronology rendered as an ordered list.
- **Props:** `axis: start | center`, `placement: start | end | alternate` (centred layouts fall back to start on small
  screens), `size` sm/md/lg, `density` compact/comfortable, `itemAlign`.
- **Parts:** `Item` has `status` default/current/success/warning/danger/muted (`current` sets aria-current). `Rail` holds
  `Marker` (dot or custom icon) and `Connector` (hidden on the last item). `Content` holds event content.
- **Demos:** centred milestones, studio review, compact log, incident response, version history, repository activity, split
  content.
- **Built from:** Card, Chip, Avatar inside content.

**`HeroProAgenda`** (Agenda)
- **What:** Notion-Calendar-style calendar with **day, week and month** views.
- **Header:** `Heading` ("May 2026", 20 medium), `ViewSelector` (a Segment, sm), and `Navigation` with prev/next `NavButton`s
  and a `TodayButton`.
- **Week header:** day name 12 muted plus date. Today's date is a danger-red pill with white text.
- **All-day section:**
  - Collapsible (20 px chevron), "all-day" label at 11 px.
  - Spanning bars: radius .75R, 12 medium, accent background, white text.
  - When collapsed it shows "N events" per day.
- **Time grid:**
  - Sticky hour labels (58 px column, 11 px muted).
  - Slot height 60 px (48 on mobile); weekend columns tinted `default`.
  - Events are absolutely positioned: radius md, padding 8×4, background from the event colour (default accent-soft) with a
    3 px start border in the accent. Title 12 medium, time 10 muted. A bottom resize handle shows a 24×2 bar.
  - Current-time indicator: danger label badge (10 px) plus a faded 2 px line across columns, solid on today.
- **Month grid:**
  - Sticky weekday row; rows at least 100 px tall.
  - Date button top-right (today uses the danger pill).
  - Spanning event bars; per-cell events 10 px on accent-soft.
  - "N more" overflow (`maxEvents` 2) navigates to the day view; out-of-month days at 40% opacity.
- **Interactions:** drag-to-create (dashed accent preview), move (including across days), resize, Delete/Backspace to delete,
  select. `status: unconfirmed` renders a dashed border and transparent fill; `isReadOnly` disables editing.
- **Mobile:** `weekDays` (for example a 3-day window), a smaller header grid, and dragging disabled.
- **Hook:** `useAgenda` (events, view, date, `startHour`/`endHour`, `slotDuration`, CRUD callbacks, layout helpers).
- **Home preview:** a mobile day list of rounded event pills with a coloured left bar, a "Join" action and a dashed red
  now-line.
- **Built from:** Segment, Button, Calendar date maths, ScrollShadow, Chip.

**`HeroProCarousel`** (Carousel)
- **What:** Embla-style pager (Flutter: PageView).
- **Props:** `type` in-place (default: arrows inside) / modal (arrows outside) / miniatures (arrows inline with thumbnails).
  Also `opts.loop`, autoplay plugin, and multiple slides per view via item basis.
- **Parts:** `Content`, `Item`, `Previous`/`Next` (tertiary sm icon buttons), `Dots` (`default` background, `accent` when
  selected), `Thumbnails`/`Thumbnail` (64 px, radius 2xl; selected shows an accent ring; pressed scales to 0.95).
- **Other:** `--carousel-gap` is 16; RTL aware; `useCarousel` exposes the API.
- **Built from:** Button, Tabs semantics for the thumbnails.

**`HeroProFileTree`** (FileTree)
- **What:** tree grid.
- **Props:** size sm/md/lg (item text xs/sm/base plus indent), `showGuideLines` true/false/`hover` (guide colour: text colour
  at 10%).
- **Parts:** `Section`/`Header` (muted uppercase), `Item` (`title`, `icon` or icon builder with `isExpanded`, drag icon),
  `Indicator` (chevron rotating 90°).
- **States:** hover and selected use the `default` background, and adjacent selected rows merge their radii. Checkboxes appear
  when `selectionBehavior` is toggle. Drag-and-drop (0.4 opacity; drop target gets an accent background and outline). Empty
  state is italic.
- **Hooks:** `useFileTree` (`expandableKeys`, `filterTree`, `leaves`) and `useFileTreeDrag`.
- **Demos:** icons, DnD, dynamic collection, multiple selection, PR file review.
- **Built from:** Checkbox, Button.

**`HeroProFloatingToc`** (FloatingToc)
- **What:** an edge-docked stack of short horizontal bars (16 px wide, 24 when active; 2 px thick; 12 px gap; 3 px shorter
  per nesting level). Hovering (or pressing, with `triggerMode: press`) opens a popover list of section items: accent when
  active, indented .75rem per level.
- **Props:** `placement` left/right, `openDelay` 200, `closeDelay` 300. Virtualised for long pages.
- **Built from:** Popover, Button.

**`HeroProHoverCard`** (HoverCard)
- **What:** preview popover on hover (`openDelay` 700, `closeDelay` 300), keyboard focus, or long-press.
- **Props:** `placement` defaults to top, `offset` 8, optional `Arrow`. Delays are shared with Tooltip.
- **Demos:** profile card, with image.
- **Built from:** Popover, Tooltip timing.

**`HeroProHoloCard`** (HoloCard)
- **What:** 3D tilting card (a transform with perspective) with a pointer-tracked holographic glare.
- **Layers:** `Rotator` → `Frame` → `Surface`, then `Image`, `Inset` (hairline), `Pattern` (texture at 0.1), any number of
  `Content` parallax layers, and `Shine` / `ShinePattern` (rainbow sheen at 0.9).
- **Defaults:** 302×453, radius 20, perspective 600, bleed 36, `parallaxStrength` 10. `isInteractive=false` or reduced motion
  freezes the card.
- **Demos:** membership card, credit card (landscape ID-1), image gallery.
- **Built from:** Card, gesture detector, shaders/gradients.

**`HeroProMap`** (Map)
- **What:** MapLibre map (Flutter: `maplibre_gl` or `flutter_map`) with light/dark `styles`.
- **Parts:**
  - `Marker` + `MarkerContent`/`MarkerDot`/`MarkerLabel`/`MarkerTooltip`/`MarkerPopup`.
  - `Popup`.
  - `Route` (coordinates, colour/width/opacity, dash).
  - `Arc`, `ClusterLayer`.
  - `Controls` (corner position) with `ZoomControl`/`CompassControl`/`LocateControl`/`FullscreenControl`/`ControlGroup`.
- **Other:** loading veil.
- **Demos:** live visitors, property listings, live tracking, store locator, fleet dispatch, coverage zones, heatmap, flight
  paths, incident monitor.
- **Built from:** Button/ButtonGroup (controls), Popover, Tooltip, CloseButton.

#### 1.3 AI components (beta.5+)

**`HeroProPromptInput`** (PromptInput)
- **What:** chat composer.
- **Props:** `variant` primary (field background) / secondary (`default` background); `layout` stacked (default) / compact
  (single-row pill that expands when text wraps or files are added) / inline (attach + input + send in one row, min 48, radius
  3R); `size` sm/md/lg; `status` ready/submitted/streaming/error (Send becomes Stop/Spinner/Error); `lockInputOnRun`;
  `maxHeight` 240.
- **Shell:** radius 2R, 1 px field border; while dragging files it shows a dotted accent border on accent-soft.
- **TextArea:** autosizes, min 56, reserves 56 px at the bottom for the absolute toolbar.
- **Toolbar:** `ToolbarStart` holds `Action`s (attach, model/"Deep Search" select); `ToolbarEnd` holds `Send`. Inset 12 px from
  the bottom and sides.
- **Footer:** disclaimer, 12 muted, for example "AI can make mistakes. Check important info."
- **Queue:** queued prompts above the shell with drag-to-reorder rows (handle, icon, 2-line clamped text, remove/more
  actions).
- **TokenInput:** inline `@mention` / `/command` token pills (accent-soft, radius .75R) plus a caret-anchored suggestion
  menu.
- **Built from:** TextArea, Button, Tooltip, Select, Menu, Popover, Chip-like tokens.

**`HeroProPromptSuggestion`** (PromptSuggestion)
- **What:** empty-state starters.
- **Parts:** `Header` (Title + Description) and `Items`, where each `Item` is a button (list or cards) with Title,
  Description, Meta, Tags and Footer slots.
- **Built from:** Button, Card, Chip.

**`HeroProChatConversation`** (ChatConversation)
- **What:** stick-to-bottom scroll viewport. `Content` is a centred column; `ScrollAnchor` holds the bottom; the optional
  `ScrollButton` jumps to the bottom.
- **Behaviour:** respects the user scrolling up during streaming.
- **Built from:** ScrollShadow, Button.

**`HeroProChatMessage`** (ChatMessage)
- **Assistant:** row with gap 12 and padding-y 8. `Avatar` (32 px, or a spacer), then `Body` (column, gap 8, 48 px end
  padding) containing `Content` (14 px relaxed), `Media` and `Actions` (0.5 opacity, 1 on hover).
- **User:** right-aligned `Bubble` (`default` background, radius 2R, padding 16×8).
- **Built from:** Avatar, Button.

**`HeroProChatMessageActions`** (ChatMessageActions)
- **What:** row of ghost icon buttons (copy, like, dislike, regenerate, share, more), muted colour.
- **Built from:** Button, Tooltip.

**`HeroProChatAttachment`** (ChatAttachment, plus `Group` and `Input`)
- **Media variant:** 64 px square thumbnail, radius 1.5R, 1 px border. The name shows as a gradient overlay on hover, and the
  remove × appears top-end on hover.
- **File variant:** 64 px tall card, max width 256, type icon (PDF, archive, spreadsheet, doc, code, audio, video, image),
  name (14 medium), size (12 muted), remove.
- **Group:** wrapping row.
- **Input:** file picker plus drag-drop zone that wraps `PromptInput.Shell`; also accepts pasted images.
- **Built from:** CloseButton, file picker.

**`HeroProChatSource` / `HeroProChatSources`** (ChatSource)
- **Chip:** 20 px pill on the `default` background, max width 128, 14 px favicon or initial fallback, 12 px muted title.
  Hover shows a HoverCard preview (320 px: favicon, title, description).
- **`sourceType`:** url or document.
- **Group:** `ChatSources` is a Disclosure ("3 sources"), optionally with stacked favicons.
- **Built from:** Chip, HoverCard, Disclosure, Avatar.

**`HeroProChatTool` / `HeroProChatToolGroup`** (ChatTool)
- **What:** collapsible tool-call card. Radius 1.5R, 1 px `default` border.
- **Trigger:** min height 36, padding 12×8, 12 px text; status icon plus "Used tool: **name**". The text shimmers while
  streaming.
- **States:** input-streaming, input-available, output-available, output-error (danger border), requires-action (warning
  border with Approve/Reject buttons).
- **Body:** `Args` and `Result` as 10 px uppercase labels plus CodeBlock JSON (11 px); `Error` in danger colour.
- **Group:** `ChatToolGroup` shows "2 tool calls".
- **Built from:** Disclosure, Button, CodeBlock, Spinner.

**`HeroProChainOfThought`** (ChainOfThought)
- **What:** Disclosure titled "Thought for 4 seconds". The trigger is muted and shimmers while `isStreaming`.
- **Steps:** vertical timeline with a 1 px start border and 12 px padding. Each `Step` has a label (muted) and content.
- **Built from:** Disclosure, Button, TextShimmer.

**`HeroProChatListView`** (ChatListView)
- **What:** thread rows for chat sidebars.
- **Row:** 16 px icon, `Title` (14 medium, truncates), `Preview` (12 muted), `Meta` (11 px). The `compact` variant hides
  preview and meta.
- **Built from:** ListBox rows.

**`HeroProChatLoader`** (ChatLoader)
- **What:** loading placeholders: `Dots`, `Pulse`, `Spinner`, and `Skeleton` (avatar + lines), plus `SkeletonAvatar`,
  `SkeletonBlock` and `SkeletonLine`.
- **Built from:** Skeleton, Spinner.

**`HeroProMarkdown`** (Markdown, StreamMarkdown)
- **What:** renders AI markdown with Pro typography: headings, lists, inline code chip, fenced code → CodeBlock.
- **Streaming:** memoised per block; the streaming variant repairs incomplete markdown and draws a caret.
- **Flutter:** a `markdown` package parser plus HeroTypography.

**`HeroProCodeBlock`** (CodeBlock)
- **What:** Shiki-highlighted code.
- **Parts:** `Header` (language label and `CopyButton` with a copied check) and `Code` (`language`, `theme` default
  github-light, dark variant).
- **Flutter:** syntax highlighter plus Clipboard.

**`HeroProTextShimmer`** (TextShimmer)
- **What:** text at 45% alpha with a sweeping full-strength highlight masked to the glyphs. The width is set by `--spread`;
  under reduced motion the text is static.
- **Flutter:** ShaderMask with an animated gradient.

#### 1.4 Feedback

**`HeroProRating`** (Rating)
- **What:** radio-group of stars.
- **Props:** size sm/md/lg (gap 0/1/2 px); active colour `warning`, inactive `surface-tertiary`; fractional read-only
  (partial overlay); custom icon (heart) or per-item icon; pressed scale 0.8.
- **Demos:** product review.
- **Built from:** RadioGroup semantics.

**`HeroProEmojiReactionButton`** (EmojiReactionButton)
- **What:** toggle pill (fully rounded, `default` background, gap 6) containing `Emoji` and `Count` (medium, muted).
- **States:** selected gets an accent border, a light accent tint and accent-coloured count. `isReadOnly`, disabled. Sizes
  sm/md/lg; press scales down.
- **Built from:** ToggleButton.

**`HeroProPressableFeedback`** (PressableFeedback)
- **What:** wrapper that adds press-feedback layers.
- **Layers:** `Highlight` (hover 0.08, pressed 0.12); `Ripple` (Material-3-style, 150 ms grow); `HoldConfirm` (clip-path sweep
  right/left/up/down over 2000 ms, then `onComplete`); `ProgressFeedback` (click-to-progress, 2000 ms, auto-reset after
  1500).
- **Built from:** Flutter InkWell/ClipRect plus an animation controller.

#### 1.5 Layout

**`HeroProResizable`** (Resizable)
- **What:** panel groups, horizontal or vertical, nestable.
- **Panel:** `defaultSize`/`minSize`/`maxSize` as a % number or px/rem string, `collapsible` + `collapsedSize`,
  `groupResizeBehavior: preserve-pixel-size`.
- **Handle:** `type` line (1 px) / drag (line + grip chip) / pill (line + pill) / handle (floating pill, no line); `variant`
  primary/secondary/tertiary maps to the separator tokens.
- **Handle metrics:** hit area 8 px, hover = separator-secondary, active = accent-soft, pill 6×32.
- **Persistence:** `autoSaveId`.
- **Flutter:** custom `MultiSplitView`-like widget.

**`HeroProAppLayout`** (AppLayout)
- **What:** the application shell:
  - Full-height `sidebar` slot (with `Sidebar.Mobile` for phones).
  - Sticky `navbar` header, plus optional `toolbar` second row (56 px) and a `footer`.
  - `main` area.
  - Right `aside` panel: 320 px, 1 px start border, collapses to 0 width with a slide over 200 ms, hidden below 1024 px unless
    `asideMobile: sheet`.
- **Props:** `sidebarVariant` sidebar/floating/inset; `sidebarCollapsible` icon/offcanvas/none; ⌘B toggles the sidebar and
  `asideToggleShortcut` toggles the aside; `sidebarResizable` / `asideResizable`; `scrollMode` page/content; open state
  persisted.
- **Triggers:** `MenuToggle` (mobile-only) and `AsideTrigger`.
- **Hook:** `useAppLayout`.
- **Demos:** inset dashboard, docs site, breadcrumbs, with aside, complex.
- **Built from:** Sidebar, Navbar, Resizable, Sheet, Button, Tooltip.

#### 1.6 Forms

**`HeroProCellSwitch`, `HeroProCellSelect`, `HeroProCellSlider`, `HeroProCellColorPicker`** (Cell*)
- **What:** iOS-settings-style 36 px rows (radius field-radius, field background or `default` for the `secondary` variant,
  padding 12, 14 medium label on the left) for preference panels, usually stacked in "settings groups".
- **CellSwitch:** a Switch on the right; the whole row toggles.
- **CellSelect:** value (14 muted) plus a 12 px ⇅ indicator; the popover is placed bottom-end.
- **CellSlider:** the whole row is the track. The fill is a `default` tint; the thumb is an invisible hit area with a 2×16 px
  pill (70% opacity, scaled 1.5× while dragging). Label on the left, tabular output on the right.
- **CellColorPicker:** swatch plus hex value, opening a ColorPicker popover with presets.
- **Built from:** Switch, Select/ListBox/Popover, Slider, ColorPicker/ColorSwatch.

**`HeroProRadioButtonGroup` / `HeroProCheckboxButtonGroup`**
- **What:** card-style options.
- **Item:** 1 px border, surface background, radius 2xl, padding 20×16, gap 16. Selected shows an accent ring. `ItemIcon` is
  24 px, `ItemContent` holds title and description, and `Indicator` sits top-end (the radio/checkbox control, or a custom
  20 px accent icon shown only when selected).
- **Layout:** `flex` or `grid`.
- **Demos:** subscription plans, delivery & payment, icon cards, with ripple.
- **Built from:** RadioGroup/Radio, CheckboxGroup/Checkbox.

**`HeroProNumberStepper`** (NumberStepper)
- **What:** pill group (`default` background, 2 px padding) with round surface −/+ buttons (32/36 px at md, 28/32 at sm, 16 px
  icons) and an animated tabular value (semibold, min width 24/28).
- **Props:** min/max, step, format options, reversed layout, custom buttons.
- **Demos:** guest picker (Adults/Children rows).
- **Built from:** NumberField, Button.

**`HeroProInlineSelect`** (InlineSelect)
- **What:** ghost Select that sits inside running text or breadcrumbs. Value max width 12rem, inline 12 px ⇅ indicator, hover
  darkens the text. Multi-select is supported.
- **Demos:** team switcher, workspace/project/timezone pickers in the navbar.
- **Built from:** Select, ListBox, Popover.

**`HeroProNativeSelect`** (NativeSelect)
- **What:** styled platform `<select>` with label, description, invalid, full-width, OptGroup, and primary/secondary variants.
- **Flutter:** a platform picker (Cupertino picker / Material dropdown) using the field styling.

**`HeroProDropZone`** (DropZone)
- **Area:** dashed 1 px border, radius 2R, padding 24×32, 32 px cloud icon, label (14 medium), description (12 muted),
  "Select files" outline button. As a drop target it turns accent-soft with an accent border.
- **File list:** items with 1 px border, radius 2R, padding 12. Each has a format icon (32×40 page with a coloured badge
  "PDF"/"JPG"), name, meta (size/status), ProgressBar, Retry (danger) and remove.
- **Status:** uploading / complete (success fill) / failed (danger border).
- **Built from:** Button, ProgressBar, CloseButton, file_picker/desktop_drop.

**`HeroProRichTextEditor`** (RichTextEditor)
- **What:** Tiptap/ProseMirror editor (Flutter: `super_editor`, `appflowy_editor` or `fleather`) with a JSON value.
- **Parts:**
  - `Shell` (primary/secondary variant).
  - `Toolbar` with `ToolbarGroup`s:
    - `ToggleButton`: bold, italic, underline, strike, code, blockquote, lists, codeBlock, H1–H3.
    - `ActionButton`: undo, redo, clear formatting.
    - `CommandButton`.
    - `LinkPopover`: Input, Unset, Apply.
  - `Content`.
  - `BubbleMenu` (appears on selection).
  - `FloatingMenu` (appears on an empty line).
  - `SuggestionMenu` (for example a "/" slash menu with keyword filtering and a no-results state).
  - `Footer` with `CharacterCount` (warns when over the limit).
- **Built from:** Toolbar, ToggleButton, Button, Popover, TextField, Menu, Separator.

#### 1.7 Navigation

**`HeroProCommand`** (Command palette)
- **Backdrop:** full screen, `variant` opaque (black 50%, 60% in dark), blur, or transparent. Entry is fade + zoom-95 + slide
  from the top in 200 ms; exit is 100 ms.
- **Container:** 15vh from the top.
- **Dialog:** overlay background, radius 2R, overlay shadow, animated height. Sizes: sm = max width 384 / max height 300,
  md = 512 / 356, lg = 576 / 440.
- **`InputGroup`:** bottom border; `Prefix` (16 px search icon), `Input` (14 px, padding 16×12, placeholder "Search
  commands..."), `ClearButton`, `Suffix`.
- **`Header`:** breadcrumbs or tabs.
- **`List`:** padding 6. `Group` has a heading (12 medium muted). `Item` has radius R, padding 12×8, gap 10, a 16 px muted icon,
  a label and trailing `kbd` shortcuts; hover or focus uses the `default` background. `Separator` inset 12.
- **`Footer`:** `default` background, top border, 12 px muted text, key hints such as "↓ ↑ Open ↵ · Options ⌘ K".
- **Empty state:** "No results".
- **Other:** fuzzy/custom filter.
- **Demos:** clean, dev toolbar, launcher, minimal, **split view** (list + preview), multiple search terms, and nested groups
  (an Actions sub-menu popover in the home preview).
- **Built from:** Modal, SearchField, ListBox/Menu, Kbd, Separator, CloseButton, Popover.

**`HeroProContextMenu`** (ContextMenu)
- **What:** right-click or long-press menu anchored at the pointer. The popover has an overlay background and shadow, and
  zooms from the click point.
- **Parts:** `Trigger`, `Popover`, `Menu` holding `Section`, `Item` (Dropdown item), `ItemIndicator` (check/radio selection),
  `SubmenuTrigger` + `SubmenuIndicator`, and `Separator`.
- **Built from:** Dropdown/Menu, Popover.

**`HeroProNavbar`** (Navbar)
- **Header:** height 4rem (3rem sm, 5rem lg), padding-x 24, gap 16, `maxWidth` sm…full.
- **Parts:**
  - `Brand`.
  - `Content` holding `Item` (14 muted, becomes foreground when hovered or current; padding 12×6; radius R), `Label`,
    `Separator` (24 px vertical) and `Spacer`.
  - `MenuToggle`: 36 px animated hamburger ↔ ×.
  - `Menu`: mobile full-height dropdown whose `MenuItem`s are 16 medium, padding 12×10.
- **Props:** `position` sticky/static/floating (floating is inset 8 px with radius 2R, a border and the surface shadow);
  `hideOnScroll`; compact density via `--spacing` + height.
- **Inside AppLayout:** drops its own positioning.
- **Demos:** docs site (search + theme Segment), with dropdowns (team switcher, user), dashboard breadcrumbs (InlineSelects),
  compact.
- **Built from:** Button, Link, Separator, Dropdown, SearchField.

**`HeroProSidebar`** (Sidebar)
- **Widths:** 240 px expanded, 48 px in the collapsed icon rail. The `offcanvas` variant slides fully off-screen. Mobile uses a
  Sheet at 80vw (max 500) with a blur backdrop.
- **Variants:** `sidebar` (a hairline edge `#00000014`), `floating` (8 px margin, radius 2R, border, surface), `inset` (the
  sidebar is transparent and the main content becomes a bordered, rounded surface card).
- **Sections:** `Header` (padding 16/16/8), `Content` (scrolling, padding-x 12, gap 4), `Footer` (padding 12, 8/16), `Group`
  and `GroupLabel` (12 medium muted), `Separator`, `Rail` (16 px edge toggle strip), `Trigger` (ghost sm button).
- **Menu** (a tree):
  - `MenuSection` / `MenuHeader`: 12 medium uppercase muted.
  - `MenuItem` content: min height 36, radius 2R, padding 8×6, gap 12. It holds `MenuIcon` (20 px box, 16 px glyph, muted),
    `MenuLabel` (14), `MenuChip` (12 muted, tabular numbers, a count or "New"), `MenuActions` (shown on hover), `MenuTrigger`
    and `MenuIndicator` (chevron rotating 90°), and a `Submenu`.
  - Nested items indent 16 px per level and show guide lines (always or on hover).
  - Current or hover state uses the `default` background, with the current label in medium weight.
- **Collapsed:** in collapsed mode labels hide and the tooltip shows the label.
- **Pages:** `Sidebar.Pages` slides between main and settings panels.
- **Demos:** complex, compact with user menu, meeting notes, agent hub, agent workspace, collapsible groups, with avatar, right
  side.
- **Built from:** Button, Tooltip, Avatar, Chip, Dropdown, ScrollShadow, Separator, Sheet.

**`HeroProSegment`** (Segment)
- **Track:** `default` background, padding 4 (2 at sm), radius 2xl + .25rem.
- **Item:** height 28/32/40 for sm/md/lg; padding-x 10/16/20; text 12/14/14 medium muted; the selected item uses
  `segment-foreground`; icon 16.
- **Indicator:** a sliding `segment` surface with radius 3xl and the surface shadow.
- **Other:** optional `Separator` inside items (hidden next to the selection); `ghost` variant (transparent track, accent
  indicator, accent-foreground text); "icon expand" variant (icon-only unless selected).
- **Demos:** theme switcher, two items.
- **Built from:** ToggleButtonGroup / Tabs.

**`HeroProStepper`** (Stepper)
- **Indicator:** circle of 22/28/36 px for sm/md/lg. Inactive has a border with muted number; active and complete are accent
  (complete shows an animated check).
- **Layout:** horizontal or vertical, with vertical gaps of 12/16/24.
- **Parts:** `Title`, `Description`, `Content`, `Icon`.
- **Separator:** 2 px track with an accent fill that animates by progress.
- **Props:** `currentStep` / `onStepChange` (clickable steps).
- **Demos:** package tracking, bullet steps, free-trial and onboarding timelines, custom colours.
- **Built from:** Button, Separator.

#### 1.8 Overlays

**`HeroProSheet`** (Sheet, Vaul-like)
- **Placement:** bottom/top/left/right. Rounded 2xl on the inner edge; max 96vh or 96vw.
- **Snap points:** `snapPoints` + `activeSnapPoint` + `fadeFromIndex`; swipe to dismiss with `closeThreshold` 0.25.
- **Other props:** `isDetached` (8 px inset, fully rounded), nested sheets (the parent scales down), `isHandleOnly`,
  `shouldScaleBackground`, non-dismissable.
- **Backdrop:** opaque, blur or transparent.
- **Parts:** `Handle` (a 32×4.8 `default` pill; tapping cycles snap points), `CloseTrigger` (top-right ×), `Header` (padding
  16×20), `Heading` (18 semibold), `Body` (scrolls), `Footer` (end-aligned row, gap 8).
- **Demos:** emoji picker sheet, professions picker, Slack message actions, with form.
- **Flutter:** DraggableScrollableSheet or a custom route.
- **Built from:** Modal/Drawer, CloseButton, Button.

**`HeroProEmojiPicker`** (EmojiPicker)
- **Trigger:** shows the selected `Value`.
- **Popover:** overlay background, radius 2xl, sizes 240×280 / 280×350 / 320×420.
- **Content:** search input; a virtualised category `Grid` (36 px cells, emoji at 20/24/28 px; hover or focus uses `default`);
  category navigation; recents.
- **Footer:** preview plus `SkinTonePicker` (a 24 px trigger opening a row of swatches).
- **Other:** inline variant.
- **Built from:** Popover, SearchField, ListBox grid, Button.

#### 1.9 React-Native-only Pro components (useful for Flutter mobile)

These are listed on the public Native docs index. Several of them are OSS on web.

| Component | Description |
| --- | --- |
| `HeroProFab` | Expands to an action list with a shared progress-driven animation and a blur overlay under Glass. |
| `HeroProMorphButton` | Morphs between collapsed and expanded content in 8 directions. |
| `HeroProProgressButton` | Press-and-hold fill to confirm. |
| `HeroProSlideButton` | Slide to confirm. |
| `HeroProSocialAuthButton` | Provider icon plus label. |
| `HeroProFlipCard` | Spring 3D front/back flip. |
| `HeroProNumberPad` | PIN/amount keypad. |
| `HeroProPhoneNumberField` | Country picker, as-you-type formatting, E.164 output. |
| `HeroProWheelPicker`, `HeroProWheelPickerGroup`, `HeroProWheelTimePicker`, `HeroProWheelDateTimePicker`, `HeroProDateTimePicker` | Wheel pickers. |
| `HeroProSplitView` | Vertical split with a draggable divider. |
| `HeroProChartCrosshair`, `HeroProChartIndicator` | Touch crosshair and halo dot for charts. |

Mobile **Agenda** is a collapsible month calendar on top of a horizontally paged day/week/month body.

#### 1.10 Marketing-only names (home-page "Pro components" grid: Command, Kanban, Stats, Filters, Agenda, DataGrid)

**Stats** is the KPI card: an icon plus title ("Total Clicks"), a big value ("2,441"), a green trend "↑ 3.5% last 30d", and a
right-side sparkline fading at the edges. Implement it as `HeroProKpi`, with an inline-chart layout preset.

**`HeroProFilters`** (Filters) is not a documented component. It is a composite filter panel, shown as "What are you looking
for?", with these sections:

- **Type of place:** a Segment (Any type / Room / Entire home).
- **Price Range:** a histogram of bars (accent inside the range, muted outside), a range Slider with pill thumbs, and Min/Max
  number fields ("$ 500", "$ 2,000").
- **Amenities:** wrapping selectable Chips with icons (Wifi, Air conditioning, Kitchen, Pool, Dedicated workspace, Gym).

The DataGrid demos also use "Filter / Sort / Columns" pill buttons. Build it from Segment, Slider, NumberField, TagGroup/Chip
and a BarChart mini-histogram. Worth shipping as a recipe or composite.

---

### 2. Pro templates

All web templates share one shell:

- **`HeroProAppLayout`** with a 240 px `Sidebar` and a `Navbar` holding the page title, action icons and `MenuToggle` on
  mobile.
- Background: `--background` (light #F5F5F5). Cards are white surfaces with radius 2R (16 px) and the surface shadow.
- Page content is centred at max width about 7xl (1280), padding 20, gap 16 between rows.

The live demos run at `heroui.pro/templates/<name>/…` and at `template-{dashboard,email,chat,crm}.heroui.pro`. Native templates
also exist; they are listed only as a showcase.

#### 2.1 Dashboard ("Analytics dashboard with orders, tracker, settings, and help pages")

**Sidebar:**
- Header: user block (gradient avatar "KM", "Kate Moore", "Admin").
- Menu: Dashboard, Orders, Tracker (with a "New" chip), Analytics, Settings.
- Footer: Help & Information, Log out.
- Collapsible offcanvas.

**Navbar:** greeting title "Good morning, Kate"; round icon buttons for Search and Notifications; an "Invite" button (user-plus
icon).

**Page `/` (Dashboard):**
1. Toolbar row:
   - Left: Tabs/Segment Overview | Sales | Expenses.
   - Right: Refresh icon button; a "Monthly" period select (calendar icon + chevron, "Change period"); primary "Download"
     button.
2. KPI row, 4 cards in a grid (1/2/4 columns). Each card has title, big value and a TrendChip, with no chart:
   - Revenue $228,441 ↑3.3%
   - Expenses $25,108 ↓3.3% (danger)
   - Sales 458 ↑3.3%
   - Profit $203,133 ↑4.1%
3. Two cards side by side (lg: 2 columns):
   - **Sales Performance:** title plus a "Last 2 weeks" select (Last week / Last 2 weeks / Last month / Last 3 months). Three
     inline stats: $28,441 ↑3.3% Weekly Sales, $4,063 Daily Sales, 278 Total Sales. A 12-bar BarChart (x 01–12, y 0–60) with
     rounded accent bars.
   - **Traffic Source:** title, legend (Organic `chart-2`, Paid Ads `chart-4`) and a "…" menu. Big value 231,856 "Sessions".
     A 2-series LineChart, Mar–Dec, y 0–20k.
4. **All Employees (32)** table section:
   - Header row: "Filter", "Sort", "Columns" pill buttons plus a SearchField ("Search...").
   - DataGrid with selection checkboxes. Columns: Worker ID (e.g. "#4586936" with a copy-ID icon), Member (avatar + name +
     email), Role, Worker Type ("Employee"), Actions (View/eye, Edit/pencil, Delete/red trash icon buttons).
   - Rows: Alex Turner / Product Manager, Emma Davis / Senior Designer, John Smith / CTO, Kate Moore / CEO, Mike Wilson /
     VP Eng, Sara Johnson / CMO.

**`/orders`:**
- Subtitle "Manage and track customer orders."
- Toolbar: SearchField "Search orders...", a "Status" filter, a "Date range" picker.
- DataGrid columns: Order ID (#ORD-48291…), Customer (avatar + name + email), Status Chip (Paid = success, Pending = warning,
  Refunded = default, Failed = danger), Total, Date, Actions (view/edit/delete).

**`/tracker`:**
- Subtitle "Track work across your team."
- Summary row: To Do 2, In Progress 2, Completed 1.
- Kanban with columns To Do / In Progress / Done, each with a count and a "+" ("Add … task").
- Each card: category chip (Engineering / Design / Frontend / Product), due date ("Dec 12"), title ("Fix onboarding flow"),
  description, subtask progress "1 / 4", and an avatar or avatar group.

**`/analytics`:**
- Subtitle "Explore how your product is performing."
- Period segment 7D / 30D / 90D / 12M.
- KpiGroup: Sessions 84,210 ↑14%, Unique users 47,382 ↑6%, Bounce rate 41.3% −2.1%, Avg. session 3m 42s ↑12%.
- **Sessions over time:** 116,650 ↑18.3% "vs. previous 30 days"; LineChart with Sessions and Users series.
- **Traffic by device:** donut with 84.2k Sessions in the centre; legend Mobile 52.3k 62%, Desktop 27.2k 32%, Tablet 4.7k 6%.
- **Top channels:** bar chart, "Sessions by acquisition channel."
- **Top pages:** table with Path, Views, Avg. time, Bounce, and Trend (TrendChip). Rows include /, /pricing,
  /blog/intro-to-pro, /signup, /docs/getting-started, /changelog.

**`/settings`:**
- Subtitle "Manage your organization profile and preferences."
- Two-column form rows, with the label + helper text on the left and the field on the right:
  - Organization Name.
  - Organization Bio (TextArea, max 240).
  - Organization Email, plus a Switch "Show email on public profile".
  - Address: Street, City, Province/State select, Postal/ZIP.
  - Currency select (CAD/USD/EUR/GBP/MXN).
- Footer: Reset and "Save changes".

**`/help`:**
- Three cards (Documentation, Community, Contact support), each with an "Open" button.
- "Frequently asked questions" Accordion with 4 items.
- "Still stuck? support@example.com".

#### 2.2 Mail ("Email client with folders, message threads, and compose views")

Three-pane layout: sidebar, list pane (about 340 px) and reading pane (a rounded surface card).

**Sidebar:**
- User block: avatar "You", you@heroui.dev.
- Folder menu with count chips: Inbox (4), Starred (2), Sent, Drafts, Snoozed, Archive, Spam, Trash. The preview also shows
  Flag and Scheduled plus a "Less/More" toggle.
- "Labels" group: Work, Personal, Billing, Travel, Urgent (coloured dots).
- Full-width primary **"New email"** button (pencil icon) pinned at the bottom.

**List pane:**
- SearchField "Search..." ("Search inbox").
- Rows: avatar (initials or gradient), sender (bold when unread), time (10:21 AM / Yesterday / Apr 22), subject, one-line
  preview, unread blue dot, star toggle ("Remove star"). The selected row is a white raised card.
- Sample senders: Carlos Iglesias "Launch recap + next steps", Stripe "Invoice INV-0241 is due tomorrow", Flights, GitHub,
  Maya Okafor, Linear, and others.
- Drafts rows show a "Draft" chip.

**Reading pane:**
- Empty state: "## Nothing open – Pick a conversation from inbox to read it here."
- Thread view:
  - Toolbar: Close/back ×, Move to trash, Spam, Archive, More (⋮); "2 of 831" with Previous/Next arrows.
  - Message count ("1 messages").
  - Subject H1 ("Launch recap + next steps").
  - Message header: avatar, name, email, "to me ▾" disclosure, timestamp, Reply, Star, More.
  - Body paragraphs, with bullet lists in the preview.
- Loading skeletons ("Loading email").

**Other routes:** `/templates/email/{inbox,starred,sent,drafts,…}/<slug>`.

**Compose:** "New email" opens a compose view. It is not visible in SSR; build it as a Sheet/Modal with To, Subject and body
(RichTextEditor, secondary variant) plus Send/Discard. This is inferred.

**Mobile:** "Open navigation" menu toggle and "Back to list".

#### 2.3 Chat ("AI chat interface with conversations, library, and exploration views")

**Sidebar:**
- User (Darnell Howe).
- Actions: New Chat, Search Chats (opens a Command-style search), Library, Explore.
- "Recent" group: a `ChatListView` of threads (Pro AI components showcase, Quick recipes for dinner, Launch plan for Q3
  rollout, Rewrite homepage value prop, Weekly team update summary), each with a "More actions" menu.
- Toggle sidebar.

**Header:**
- Thread title plus "Updated Just now".
- A model Select (four placeholder model names such as "Atlas 2 / Atlas 2 Mini / Nova Pro / Orion"; the preview shows it as a pill at top left).
- Search and Share (link) buttons, and an add-person button.

**Conversation** (`ChatConversation`, max width about 720, centred). The showcase thread demonstrates:
- User bubbles right-aligned (`default` background).
- Assistant rows with an "AI" avatar.
- A `ChainOfThought` "Thought for 4 seconds" with steps "Search" and "Plan".
- Markdown with a list and a `CodeBlock` (language label "ts", copy).
- `TextShimmer` "Thinking...".
- A `ChatToolGroup` "2 tool calls" (searchDocs, fetchPage) with JSON args/results.
- An approval tool "Approval needed: sendEmail" with Reject/Approve.
- `ChatLoader` skeleton.
- Image media in the assistant body.
- Compact actions: Copy, Good response, Bad response, Regenerate, More.
- An attachment chip "dashboard-wireframe.png" on the user message.
- `ChatSources` "3 sources" (HeroUI Pro, Tailwind Variants, design-system-audit.pdf).

**Composer:** `PromptInput` (placeholder "What do you want to know?"):
- Attach button (paperclip).
- "Deep Search" select pill (globe icon + chevron).
- Model Select.
- Round Send button (↑) at the end.
- Footer "AI can make mistakes. Check important info."

**`/library`:** "Saved prompts and reusable setups". A grid of cards, each with title, description, tag chips (Demo /
Components, Cooking / Everyday, Product / GTM…) and a relative date.

**`/explore`:** "Starter prompts for everyday work". Grouped `PromptSuggestion` sections (At work / Writing & editing / Planning
& ops), each with 3 prompt cards (title + description).

#### 2.4 Finances ("Finance dashboard with portfolio, spending, and transaction views")

**Sidebar:**
- Logo plus avatar.
- SearchField "Search for an asset".
- Menu: Dashboard, Portfolio, Spending, Transactions, Earn (with a "New" chip).
- Footer: Settings, Help & Support (Help & Information), Log out.

**Header on every page:** "Good afternoon, Fred" (or the page title), plus Swap, Receive and Send buttons.

**`/` Dashboard:**
- Tabs Overview / Holdings / DeFi and a "Buy with card" soft button (from the preview).
- KPI row: Total balance $5,427.48 ↑5.32%; 24h change $120.18 ↑2.24%; Top performer · SOL 4.72%; Holdings 8 Assets.
- **Portfolio** card:
  - Subtitle "Sample holdings and historical performance".
  - Total balance plus a +8.16% chip.
  - Time-range segment 1D/1W/1M/3M/1Y/All.
  - Stepped LineChart.
- **Holdings (8)** list card: coin avatar, symbol, name, USD value, %-change (green or red), plus "See all holdings".
- **Recent activity (8)** table:
  - Filter/Sort buttons.
  - Columns: Txn # (truncated hash + external-link icon), Type (icon + Contract Interaction / Received / Sent / Swapped),
    Asset (coin avatar + symbol), Value (amount + USD), Date.
  - Pagination "1 to 6 of 10 transactions".

**`/portfolio`:**
- Portfolio chart.
- **Allocation:** donut plus a legend list (USDC 38.5% $2,087.25, BTC 23.7%, ETH 20.0%, ARB, LINK, SOL).
- Holdings list (8) with "Manage assets".

**`/spending`:**
- **Spending by category:** "All time" donut with $3,597.00 Total in the centre; legend of Housing / Food & Drinks / Shopping /
  Travel / Entertainment with $ and %.
- **Transactions:** grouped by day, with a date header and daily total. Rows show merchant, category, account ("Checking
  (...4821)" / "Credit (...7392)") and amount.
- **Summary** card: total transactions 11, largest $1,840, average $327, total $3,597, first/last dates; "Download CSV".

**`/transactions`:** "All transactions (8)", Filter, Sort, SearchField "Search transactions...", and the full DataGrid.

**`/earn`:**
- KPIs: Opportunities 6 Active, Average APY 9.24%, Top APY 18.20%.
- **Earn opportunities** table: Asset, Protocol (Lido/Jito/Aave/Uniswap v4/Yearn/Pendle), Type (Staking/Lending/Liquidity/
  Vault), APY, TVL, Risk chip (Low/Medium/High), and a "Stake" button.

**`/settings`:** Email; Base currency select; Default network select (Ethereum/Arbitrum/Optimism/Polygon/Solana/Base);
Notifications switch; Biometric approvals switch; Cancel / Save changes.

#### 2.5 CRM (beta.10; Mouve theme, CRM variant: Eclipse light accent / Snow dark accent)

"Sales CRM workspace with pipeline filters, account health, and company profiles."

**Shell:** inset or compact sidebar.

**Sidebar:**
- Header: workspace switcher ("HeroUI Team") plus a Search icon.
- Menu: Home, Up next, Notifications (count chip 2).
- Group "Records": Accounts, Opportunities, Contacts.
- Group "Resources": Tasks, Meetings, Notes.
- Group "Lists": + New list, Sponsor gaps, At risk, Warm contacts.
- Footer: user menu (Jordan Ellis).

**Navbar:** sidebar toggle plus a small page title. On Opportunities it also has an "All" filter and a primary "+ Create
opportunity" button.

**AI aside:** a single resizable `AppLayout.aside` with suggested skills, threads, retrieved-record context and chat messaging
(the same parts as the Chat template). "Ask" actions open and focus it.

**Details and create flows:** records open in **right-side Sheets** (account, opportunity, contact, owner, note, sequence,
profile). New Company and New Opportunity open as **Modals**. The Sheet and the aside are mutually exclusive.

**Home:**
- "Pipeline" heading, subtitle "Coverage, velocity, and follow-through this quarter.", and a DateRangePicker (8/26/2026 –
  9/24/2026).
- KPI group of 6:

  | KPI | Value | Detail |
  | --- | --- | --- |
  | Pipeline | $8.4M, ↑8% | 20 open · $1M won |
  | Meetings Today | 5 | Stripe · Adobe |
  | Lost This Quarter | 1 | $276K · Zoom |
  | Win Rate | 67%, 4% | 2 won · 1 lost |
  | At Risk | 2 | $549K slipping · 2 of 20 open |
  | Overdue Follow-ups | 5 | Figma · Snowflake past due |

- Charts:
  - **Created vs Closed:** 2 series.
  - **Days to Close:** Typical / Slow / Stalled.
  - **Weighted Forecast $6M:** segmented bar with Open pipeline $1M 17%, Best case $2.7M 44%, Commit $2.3M 39%.
  - **Pipeline Funnel:** rows Lead $594K 6%, Qualification $1.4M 15%, Demo $2.3M 24%, Trial $1.8M 20%, Proposal $2.2M 23%,
    Won $1M 11%, drawn as horizontal bars.
- **Accounts** top-4 list (logo initial, name, "3 open · Procurement", value).
- **Opportunities** top-4 list (name, account · owner, value).

**Up next:**
- **Suggested tasks** ("10 recommendations"): rows with text, an account chip and Dismiss/Accept buttons; "Load 5 more".
- **Meetings Today:** time, title, account, owner avatar.
- **Tasks:** Overdue and Upcoming lists with title, account, relative due date and owner initials.

**Notifications:** feed items with actor, text and relative time ("Maya moved the opportunity from Qualification to Demo. 8m").

**Accounts:**
- Toolbar: Filter, "Sort: Pipeline value", Owner, Stage, Last activity, Export CSV, Display.
- Full-height DataGrid with select-row checkboxes and resizable columns.
- Columns: Account (logo + name + domain), Industry (chips), Owner (avatar + name), Open deals, Pipeline value, Win
  probability (bar + %), Activity (sparkline), Last interaction.
- Dense cells (padding 4×8, row 45 px).

**Opportunities:**
- **Kanban** with stages Lead / Qualification / Demo / Trial / Proposal / Won / Lost. Each column header shows a coloured dot,
  stage name, count and stage total ($594K…).
- Cards show:
  - logo + opportunity name + account;
  - forecast chip (Pipeline / Best case / Commit);
  - value ($184K);
  - owner avatar + name;
  - segmented win-probability bar + %;
  - "Close Oct 18" and "5 d in stage".
- Column footer: "Create opportunity" and a "Stage total".

**Contacts:** DataGrid with a Filter input and Display. Columns: Name (avatar + email), Account (logo + domain), Last
interaction, Job title, Email.

**Tasks:** Today / Overdue / Upcoming grouped lists with checkbox, title, account chip, due and owner.

**Meetings:** activity log grouped by day (Today, Yesterday, Sun Sep 13…). Each item has title, a type chip
(Email/Note/Meeting/Call), summary, owner avatar, participants · account · owner, time, and a "Completed" status. Filters:
"All owners", "30 days".

**Notes:** grouped This week / Earlier; each row has account initial, note title, account, excerpt and date.

**Lists (for example At risk):** DataGrid with Opportunity, Account, Stage, Value, Owner; footer "8 opportunities".

**CRM-specific styling (from the page CSS):** cards, widget content, Kanban cards and item-card groups use the surface with a
1 px border and no shadow. Kanban column bodies are `surface-secondary` with no border. DataGrid selected rows use accent at 10%
over the surface. The sidebar current item is accent-soft with accent text and icon.

---

### 3. Premium design systems and themes

All themes ship `<name>-light` and `<name>-dark` modes, selected by class or `data-theme`, and are imported after the Pro CSS.
In Flutter, model each theme as `HeroThemeData` token overrides plus a per-component "treatment" layer (shadows, borders, fonts,
blur). Web theme files: `https://heroui.pro/themes/{brutalism,glass,mouve}.css` (read in full). The Figma sync plugin does not
support the three premium themes yet.

**Theme-builder knobs** (Design Systems editor, from the public JS):

| Knob | Values |
| --- | --- |
| accent / success / warning / danger | hex |
| base tone and lightness/chroma/hue | Default: hue 253.83, lightness .6204, chroma .195 |
| `radius` and `formRadius` | none=0, extra-small=.125rem, small=.25rem, medium=.5rem, large=.75rem, extra-large=1rem |
| bodyFont / headingFont | e.g. Inter |
| fontSizeScale, lineHeightScale, letterSpacing, spacingScale | scales |
| borderScale, fieldBorderScale | scales |
| ringOffsetScale | scale |
| glassBlurLight / glassBlurDark | 20 / 36 |
| iconSet | gravity |
| menuStyle, tooltipStyle | styles |
| vibrantPalette | on/off |

Component-style presets:

- Button: default / pill / sharp / uppercase / elevated.
- Card: default / outlined / flat / elevated.
- Input: default / pill / sharp.

Preview tabs: brand, components, dashboard, crm, mail, chat, finances.

#### 3.1 Default (the HeroUI v3 base look; exact values from OSS `packages/styles/themes/default/variables.css`)

**Shared across modes:**
- `--radius` .5rem (8 px); `--field-radius` 1.5R (12 px).
- `--accent` oklch(.6204 .195 253.83) = **#0485F7**; `--success` #17C964.
- `--snow` #FCFCFC; `--eclipse` #18181B.
- Field border transparent (0 px); disabled opacity .5; ring offset 2 px.
- Font Inter.

| token | light | dark |
|---|---|---|
| background | #F5F5F5 | #060607 (oklch 12% .005 285.8) |
| surface / overlay | #FFFFFF | #18181B |
| surface-secondary | #EFEFF0 | #232325 |
| surface-tertiary | #EAEAEB | #262728 |
| default | #EBEBEC | #27272A |
| muted | #71717A | #9F9FA9 |
| foreground | #18181B | #FCFCFC |
| border / separator | #DEDEE0 / #E4E4E7 | #28282C / #212124 |
| warning | #F5A524 | #F7B750 |
| danger | #FF383C | #DB3B3E |
| segment | #FFFFFF | #46464C |
| backdrop | rgba(0,0,0,.5) | rgba(0,0,0,.6) |
| surface-shadow | 0 2 4 #0000000A, 0 1 2 #0000000F, 0 0 1 #0000000F | none |
| overlay-shadow | 0 2 8 #0000000F, 0 −6 12 #00000008, 0 14 28 #00000014 | inset 0 0 1 rgba(255,255,255,.3) |

**Derived formulas** (mix in oklab):

| Token | Formula |
| --- | --- |
| `hover` | 90% base + 10% its foreground |
| `default-hover` | 96/4 |
| `surface-hover` | 92/8 |
| `*-soft` | 15% of the colour over transparent (12% in dark) |
| `*-soft-hover` | 20% (16% in dark) |
| `accent-soft-foreground` | 70% accent + 30% foreground (80/30 in dark) |
| `background-secondary` | 96/4 background/foreground |
| `background-tertiary` | 92/8 background/foreground |
| `separator-secondary` | 85/15 surface/surface-foreground |
| `separator-tertiary` | 81/19 surface/surface-foreground |
| `border-secondary` | 78/22 surface/surface-foreground |
| `border-tertiary` | 66/34 surface/surface-foreground |
| `field-border-hover` | 88/10 |
| `field-border-focus` | 74/22 |

**Pro chart palette:** accent lightness −.24, −.12, 0, +.12, +.24. The native Default theme is described as "clean surfaces,
soft radii, balanced typography".

#### 3.2 Brutalism

**Visual language:** bold and high-contrast. **Zero radius everywhere**; **monochrome accent** (accent = foreground, black on
light and white on dark); 1 px borders instead of shadows; uppercase display type; fast linear 80 ms transitions and no press
scale. Colours otherwise inherit Default. Web fonts are **Anton** (display) and **Share Tech Mono** (body). The native build
uses JetBrains Mono for body and Anton for display; the native docs say "bold borders, hard shadows, display typography".
Theme-builder preset: accent #222222 (#111111 swatch), `radius` none, `formRadius` none, `fieldBorderScale` 1.

**Tokens (light / dark):**

```
--accent: var(--foreground); --accent-foreground: var(--background);
--radius: 0px; --field-radius: 0px; --field-border-width: 1px; --field-border: var(--border);
--surface-shadow: none; --field-shadow: none;
--overlay-shadow (light): 0 0 0 1px #0000000F, 0 1px 2px -1px #0000000F, 0 2px 4px 0 #0000000A
--overlay-shadow (dark):  0 0 0 1px #FFFFFF0F, 0 1px 2px -1px #FFFFFF0F, 0 2px 4px 0 #FFFFFF0A
--brutalism-font-body: "Share Tech Mono", monospace; --brutalism-font-display: "Anton", sans-serif;
body font = body font; h1–h6 = display font, UPPERCASE, letter-spacing .05em, weight 700
```

**Component treatments:**

- **Display font, uppercase, tracking .05em, weight 700:** Button, Link, Tabs tab, Badge, Chip, ListBox item (its description
  stays in the body font), Table column header, Alert title, Pagination link, Select trigger, Toast title, Drawer and Modal
  headings.
- **1 px `--border` borders:** secondary, tertiary and outline buttons; Select trigger; Modal and Drawer dialogs. The
  danger-soft button gets a danger border. ButtonGroup removes the inner borders between items.
- **Radius 0:** accordion, tabs separator, meter, slider track/fill/thumb, checkbox, radio, switch control/thumb, avatar,
  table column divider, drawer handle bar and drawer corners.
- **No scale animation** on modal enter/exit or pagination press.
- **HoverCard arrow:** muted outline stroke.
- **Marketing preview treatments:** square cards with a 20% foreground border, `font-brutalist-display` uppercase titles,
  inverted (foreground-background) uppercase primary buttons.

#### 3.3 Glass

**Visual language:** glassmorphism. Translucent surfaces over a colourful **ambient background gradient**, a real **backdrop
blur** on almost every surface (20 px light, 36 px dark), near-invisible field borders, soft overlay shadows and no surface
shadow. Typography stays Inter. It needs something behind it to blur: use `--background-gradient` or an image. Theme-builder
preset: accent #3F4042 (swatch #EAF6FF), blur 20/36.

**Tokens:**

```
glass-light:
  --glass-blur: 20px; --border-width-field: 1px
  --accent: oklch(30% .006 240) ≈ #2B2E31   (accent-foreground inherits snow)
  --background: oklch(97% .0029 264.54) ≈ #F4F5F7
  --background-gradient: linear-gradient(#3040C833 0%, #408CF01A 50%, #7CD2E400 100%)   (blue→cyan wash from top)
  --surface: white @ 80%        --surface-secondary: (surface + 6% foreground) @ 50%   --surface-tertiary: same @ 70%
  --overlay: white @ 75%        --default: black @ 7%       --field-background: oklch(14% .05 255) @ 6%
  --field-border: black @ 4%    --separator: black @ 10%    --backdrop: oklch(77.21% .0036 247.87) @ 60% (≈ #B3B5B7 99)
  --surface-shadow: none; --field-shadow: none
  --overlay-shadow: 0 2px 8px #0000000F, 0 -6px 12px #00000008, 0 14px 28px #00000014
  --glass-pinned-surface: #FCFCFC; --glass-pinned-surface-secondary: ≈ #F0F1F2
  --chart-1..5: oklch(.65/.55/.45/.35/.75, chroma .06→.03, hue 240) ≈ #6E95B0 #57768C #41596A #2C3D49 #8CB4D1
glass-dark:
  --glass-blur: 36px; --accent: oklch(98% .001 240) ≈ #F8F8F9; --accent-foreground: eclipse
  --background: oklch(15% .003 240) ≈ #0A0B0C
  --background-gradient: linear-gradient(#195EB429 0%, #005E500A 50%, #00786E00 100%)   (blue→teal)
  --surface: white @ 4%   --surface-secondary: … @ 10%   --surface-tertiary: … @ 20%
  --overlay: white @ 5%   --default: white @ 8%   --field-background: white @ 8%
  --field-border: white @ 4%   --separator: white @ 12%   --backdrop: black @ 30%
  --glass-pinned-surface ≈ #2B2C2D; --glass-pinned-surface-secondary ≈ #222324
  --chart-1..5 from accent: l−.4, l−.2, accent, l+.06, l+.12
```

**Components that get `backdrop-filter: blur(var(--glass-blur))`** (in Flutter, use `ClipRRect` + `BackdropFilter` under a
theme flag):

- **OSS:** card, alert, tabs list (radius 2.5R) and indicator, tooltip, popover, dropdown, modal, drawer, alert-dialog, select
  trigger and popover, autocomplete, combo-box, date and date-range pickers, color-picker popover, toast, attached toolbar,
  input, textarea, input-group, number-field group, date-input group, color-input group, search-field group, OTP slot,
  checkbox and radio controls, secondary and tertiary buttons, toggle button (accent when selected), close button, active
  pagination link, switch control, tag, chip, badge (no border), kbd, avatar, table rows and header, accordion trigger,
  slider/progress/meter tracks.
- **Pro:** hover card, context menu, command dialog, emoji picker popover (the footer becomes a transparent blurred pill),
  floating TOC, sheet dialog, chart tooltip (background-secondary with overlay shadow, no border), map popup and tooltip,
  item-card and item-card-group, KPI group, widget and widget content (no shadow), floating sidebar, inset-sidebar main area,
  RTE bubble/floating/suggestion menus, native select, all Cell* rows, Segment, NumberStepper, EmojiReactionButton, Kanban
  column body.

**Special cases:**
- DataGrid pinned cells use the opaque `glass-pinned-surface` tokens so scrolled content doesn't show through.
- Carousel arrows are white with `mix-blend-mode: difference`.
- Table headers follow the card's rounded corners.

**Native Glass notes:** real blur exists only on iOS; other platforms use an opaque fallback composited over the background.
Overlay backdrops default to a `blur` variant (intensity 50 light / 75 dark). Input gains a `Background` layer part. Avoid
stacking blur layers: Widget.Content only tints over the widget's blur. Flutter can blur on every platform, but keep the "don't
nest blurs" rule for performance.

#### 3.4 Mouve

**Visual language:** refined mauve / warm purple (hue 300) with a tactile, "physical" finish.

- Tinted-lavender neutrals (light) and deep aubergine (dark).
- A medium radius (.54rem light / .75rem dark) and very round fields (1.5rem).
- **Saturated accent fills are "raised":** a layered drop-shadow stack plus inset specular highlights, a 1 px accent border and
  a 5%-opacity white top-light gradient overlay (`linear-gradient(#fff, #ffffff80)`). This applies to primary and danger
  buttons, selected calendar and range-calendar cells, slider fill and thumb, the switch when on, the segment ghost indicator,
  progress-bar and meter fills, and completed stepper indicators.
- **Neutral pill buttons** (secondary, tertiary, ghost, calendar nav) get an **inset "pressed" shadow** while pressed.
- Close button is fully round (raised in dark).
- Checkbox and radio controls have a 1 px field-border (accent when checked); checkbox inner radius .5R.
- Tabs and segment hover fill is `default` mixed with 7% foreground; the progress-circle stroke is the accent.
- Slider track is 8 px (0.5rem) thick.
- Theme-builder preset: accent #7B3FE4, hue 300, lightness .55, chroma .18, radius large, formRadius extra-large. Typography
  stays Inter.

**Tokens (oklch from `/themes/mouve.css`; hex from the compiled CSS):**

| token | mouve-light | mouve-dark |
|---|---|---|
| eclipse (fg light) | oklch(25% .02 300) #23202A | same |
| snow | #FCFCFC | #FCFCFC (fg dark) |
| background | oklch(95.5% .012 300) #F1EEF7 | oklch(16% .02 300) #0F0B15 |
| surface / overlay | #F7F6FB | #17141E |
| surface-secondary | #EFEDF6 | #211D27 |
| surface-tertiary | #EBE7F3 | #28242F |
| default | #E6E3EC | #25222C |
| muted | #7D778A | #918D9A |
| **accent** | oklch(55% .18 300) **#8451C9** (fg snow) | oklch(70% .16 300) **#AE84F2** (fg #0C0912) |
| field-background / field-border | #F6F4F9 / #D9D5E3 (1 px) | #1C1922 / #35303E |
| border / separator | #D9D5E0 / #E5E3EA | #2F2C37 / #2A2731 |
| segment | white | #2B2634 |
| success / warning / danger | #17C964 / #F5A524 / #FF383C | #17C964 / #F7B750 / #DB3B3E |
| backdrop | #665E7766 | #00000080 |
| radius / field-radius | .54rem / 1.5rem | .75rem / (1.5rem) |
| chart-1…5 | #5A358C #7347AF #8451C9 #9D79D7 #B7A0E4 | #6E519D #8E6AC7 #AE84F2 #C3A5F9 #D5C2FB |

**Shadows:**

```
light --surface-shadow: 0 0 5px 0 #00000005, 0 2px 10px 0 #0000000F, 0 0 1px 0 #00000033
light --overlay-shadow: 0 24px 40px -12px #00000014, 0 16px 28px -8px #0000000A, 0 4px 6px -2px #0000000A, 0 0 2px #0000000A, 0 0 0 1px #0000000A
light --field-shadow:   inset 0 0 2px #0000000A, inset 0 0 4px #00000008, inset 0 0 2px #00000008
light --mouve-raised-shadow: inset 0 1px 2px -.5px #FFFFFF1F, inset 0 .5px .5px #FFFFFF29, inset 0 8px 24px -4px #FFFFFF29,
       0 8px 8px -3px #00000008, 0 5px 5px -2.5px #00000008, 0 3px 3px -1.5px #00000008, 0 2px 2px -1px #00000008, 0 1px 1px -.5px #00000008, 0 .5px .5px #00000008
light --mouve-accent-fill-shadow: (the three inset highlights only)
light --mouve-pressed-shadow: inset 0 1px 2px #00000014, inset 0 0 4px #0000000F, inset 0 1px 1px #0000000D
dark  --surface-shadow: inset 0 1px 0 #FFFFFF0A, inset 0 0 0 1px #FFFFFF0A, 0 0 0 1px #00000029, 0 1px 1px -.5px #0000002E, 0 3px 3px -1.5px #0000002E, 0 6px 6px -3px #0000002E, 0 12px 12px -6px #0000002E
dark  --overlay-shadow: inset 0 1px 3px #FFFFFF0A, inset 0 .5px .5px #FFFFFF0A, 0 16px 56px #0000003D, 0 4px 16px #0000003D, 0 1px 2px #0000003D, 0 0 0 1px #0000001A
dark  --field-shadow:   inset 0 1px 1px #FFFFFF05, inset 0 -.5px 1px #FFFFFF0F, inset 1px 1.5px 4px #0000000F, inset 1px 1.5px 4px #00000014
dark  --mouve-raised-shadow: inset 0 1px 0 #FFFFFF33, inset 0 1px 2px -.5px #FFFFFF24, inset 0 8px 24px -4px #FFFFFF1A,
       0 0 0 1px #00000066, 0 1px 1px -.5px #0000004D, 0 3px 3px -1.5px #0000004D, 0 6px 6px -3px #0000004D, 0 12px 12px -6px #0000004D
dark  --mouve-pressed-shadow: inset 0 1px 2px #FFFFFF0D, inset 0 1px 1px #FFFFFF1A
```

Flutter needs inset shadows, which `BoxShadow` doesn't provide. Implement a small `HeroInsetShadowPainter` (or a decoration)
for the raised and pressed looks.

**CRM "Mouve" variant** (template override: "Eclipse light / Snow dark"):
- Neutral greys replace the mauve: light background #F3F3F3, surface #FAFAFA, default #E1E1E1, muted #696969, border #D1D1D1;
  dark background #0A0A0A, surface #1B1B1B, default #2E2E2E, border #292929.
- Accent = eclipse #222 (light) / snow (dark).
- Muted status colours: success #318B81, warning #6A8B5F, danger #9C5A4D (light).
- Mauve-grey charts: #302B39 → #BAB3CB.
- `--radius` .25rem, field radius .375rem, surface shadow none; cards bordered and flat.
- In dark mode the primary button sheen overlay is stronger (28%).

#### 3.5 Other theme presets (theme builder only, not "premium themes")

Default, Sky #7DD3FC, Lavender #C084FC, Mint #86EFAC, and several brand-imitation presets (streaming/music/crypto/travel/chat
brands). Don't replicate the brand presets. The colour-only ones (Sky/Lavender/Mint) are just accent + base-tint parameter sets
over Default.

---

### 4. Sources (URLs actually read)

**heroui.pro**

- Discovery and reference:
  - https://heroui.pro/robots.txt
  - https://heroui.pro/sitemap.xml
  - https://heroui.pro/llms.txt
  - https://heroui.pro/docs/react/llms.txt
  - https://heroui.pro/docs/react/llms-full.txt (all React Pro component, template, release and theming pages; the component
    list in §1 follows this)
  - https://heroui.pro/docs/native/llms.txt
- Native docs pages:
  - https://heroui.pro/docs/native/themes/brutalism.mdx
  - https://heroui.pro/docs/native/themes/glass.mdx
  - https://heroui.pro/docs/native/themes/default.mdx
  - https://heroui.pro/docs/native/themes.mdx
  - https://heroui.pro/docs/native/templates.mdx
- Marketing and docs pages:
  - https://heroui.pro/ (www.heroui.pro redirects here)
  - https://heroui.pro/pricing
  - https://heroui.pro/docs/react/components
  - https://heroui.pro/docs/react/components/kanban (HTML)
  - https://heroui.pro/docs/react/components/kanban.mdx
  - https://heroui.pro/docs/react/templates
- Live templates (SSR HTML):
  - Dashboard:
    - https://heroui.pro/templates/dashboard
    - https://heroui.pro/templates/dashboard/orders
    - https://heroui.pro/templates/dashboard/tracker
    - https://heroui.pro/templates/dashboard/analytics
    - https://heroui.pro/templates/dashboard/settings
    - https://heroui.pro/templates/dashboard/help
  - Email:
    - https://heroui.pro/templates/email (redirects to /inbox/launch-recap-next-steps)
    - https://heroui.pro/templates/email/starred
    - https://heroui.pro/templates/email/sent
    - https://heroui.pro/templates/email/drafts
  - Chat:
    - https://heroui.pro/templates/chat (redirects to /pro-ai-showcase)
    - https://heroui.pro/templates/chat/library
    - https://heroui.pro/templates/chat/explore
  - Finances:
    - https://heroui.pro/templates/finances
    - https://heroui.pro/templates/finances/portfolio
    - https://heroui.pro/templates/finances/spending
    - https://heroui.pro/templates/finances/transactions
    - https://heroui.pro/templates/finances/earn
    - https://heroui.pro/templates/finances/settings
  - CRM:
    - https://heroui.pro/templates/crm
    - https://heroui.pro/templates/crm/up-next
    - https://heroui.pro/templates/crm/notifications
    - https://heroui.pro/templates/crm/accounts
    - https://heroui.pro/templates/crm/opportunities
    - https://heroui.pro/templates/crm/contacts
    - https://heroui.pro/templates/crm/tasks
    - https://heroui.pro/templates/crm/meetings
    - https://heroui.pro/templates/crm/notes
    - https://heroui.pro/templates/crm/lists/at-risk
  - Returned 404: https://heroui.pro/templates and https://heroui.pro/templates/mail (the Mail template lives at /email).
- Theme and component CSS:
  - https://heroui.pro/themes/brutalism.css
  - https://heroui.pro/themes/glass.css
  - https://heroui.pro/themes/mouve.css
  - https://heroui.pro/_next/static/immutable/chunks/44jhcigbfmai2.css (compiled OSS + Pro component CSS; source of the
    metrics in §1)
  - https://heroui.pro/_next/static/immutable/chunks/2ed4hl38v0-q_.css (Mouve + CRM overrides)
  - https://heroui.pro/_next/static/immutable/chunks/0cgm-gqjijco_.css (home theme-preview tokens)
  - https://heroui.pro/_next/static/immutable/chunks/2d_a-euav-ak7.css
- Home-page JS chunks under https://heroui.pro/_next/static/immutable/chunks/*.js (theme-builder presets and knobs, and the
  design-token catalogue; mainly 146_kwb63qrjr.js, 1gucbn-wxu3lh.js, 2p2p5yuaw2hhk.js, 38p3_w2whh68t.js, 0w8ncd_3sl_zp.js,
  1o_tzmah4bdpz.js).
- Home-page component previews:
  - https://heroui.pro/images/pro-filters.png
  - https://heroui.pro/images/pro-stats.png
  - https://heroui.pro/images/pro-command.png
  - https://heroui.pro/images/pro-kanban.png
  - https://heroui.pro/images/pro-agenda.png
  - https://heroui.pro/images/pro-datagrid.png

**Template screenshots (CDN)**

- https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/templates/dashboard-light.webp
- https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/templates/mail-light.webp
- https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/templates/chat-light.webp
- https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/templates/finance-light.webp
- https://heroui.pro/templates/crm-light.webp

**Local open-source clone (read-only), a local clone of heroui-inc/heroui**

- apps/docs/content/blog/en/build-react-dashboard-with-heroui.mdx (Pro dashboard template composition: AppShell,
  DashboardNavbar/Sidebar, KpiRow, SalesPerformanceCard, TrafficSourceCard, EmployeesTable)
- apps/docs/content/docs/en/react/releases/v3-0-0.mdx (Pro section: "Command palette, Kanban board, Stats dashboard,
  Filters, Agenda, DataGrid"; templates Dashboard, Mail, Chat, Finances)
- apps/docs/content/docs/en/react/releases/v3-0-3.mdx and v3-0-4.mdx (the `brutalism-light` theme name; Typography ported
  from Pro)
- packages/styles/themes/default/variables.css and packages/styles/themes/shared/theme.css (Default token values and the
  radius scale)
- A grep of apps/docs/src for "Kanban", "DataGrid", "Agenda" and "Command palette" found no Pro component code, only
  Pro URLs and banners.

**Not fetched:** anything under the robots-disallowed `/docs/_next/` and `/docs/react/demos/` paths. No host returned 403.
