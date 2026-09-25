# Progress

Every slice from [PLAN.md](PLAN.md) in build order. A slice is **Done** when the widget, its
widget and golden tests, gallery page, docs page and dartdoc have landed on `main` with
`flutter analyze` and `flutter test` green.

Legend: ✅ Done · 🚧 In progress · ⬜ Planned

## Summary

<!-- summary:start -->
**50 of 164 slices done**, 0 in progress.
<!-- summary:end -->


## Foundations

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| F1 | Design tokens & HeroTheme | `HeroThemeData, HeroTheme, HeroColors, HeroRadii, HeroSpacing, HeroTypography, HeroShadows, HeroMotion` | ✅ Done |
| F2 | Theme presets (light/dark + named presets) | `HeroThemePreset` | ✅ Done |
| F3 | App shell & test harness | `HeroApp, HeroPageRoute, HeroScrollBehavior, loadHeroFonts` | ✅ Done |
| F4 | Interaction layer | `HeroInteractable, HeroFocusRing, HeroPressScale, HeroDisabledOpacity` | ✅ Done |
| F5 | Variant system | `HeroColor, HeroSize, HeroVariant, HeroVariants, HeroSizeValues` | ✅ Done |
| F6 | Icon set | `HeroIcon, HeroIconData, HeroIcons` | ✅ Done |
| F7 | Overlay & positioning layer | `HeroAnchoredOverlay, HeroPlacement, HeroOverlayTransition` | ✅ Done |
| F8 | Gallery skeleton | apps/gallery | ✅ Done |

## Buttons & typography

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C01 | Spinner | `HeroSpinner` | ✅ Done |
| C02 | Typography | `HeroText` | ✅ Done |
| C03 | Label | `HeroLabel` | ✅ Done |
| C04 | Description | `HeroDescription` | ✅ Done |
| C05 | FieldError | `HeroFieldError` | ✅ Done |
| C06 | ErrorMessage | `HeroErrorMessage` | ✅ Done |
| C07 | Button | `HeroButton` | ✅ Done |
| C08 | CloseButton | `HeroCloseButton` | ✅ Done |
| C09 | ButtonGroup | `HeroButtonGroup` | ✅ Done |
| C10 | ToggleButton | `HeroToggleButton` | ✅ Done |
| C11 | ToggleButtonGroup | `HeroToggleButtonGroup` | ✅ Done |
| C12 | Kbd | `HeroKbd` | ✅ Done |
| C13 | Link | `HeroLink` | ✅ Done |

## Data display

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C14 | Badge | `HeroBadge` | ✅ Done |
| C15 | Chip | `HeroChip` | ✅ Done |
| C16 | Avatar | `HeroAvatar` | ✅ Done |
| C17 | AvatarGroup | `HeroAvatarGroup` | ✅ Done |
| C18 | Skeleton | `HeroSkeleton` | ✅ Done |
| C19 | ProgressBar | `HeroProgressBar` | ⬜ Planned |
| C20 | ProgressCircle | `HeroProgressCircle` | ✅ Done |
| C21 | Meter | `HeroMeter` | ✅ Done |
| C22 | Separator | `HeroSeparator` | ✅ Done |
| C23 | Surface | `HeroSurface` | ✅ Done |
| C24 | Card | `HeroCard` | ⬜ Planned |
| C25 | Alert | `HeroAlert` | ✅ Done |
| C26 | ScrollShadow | `HeroScrollShadow` | ⬜ Planned |
| C27 | EmptyState | `HeroEmptyState` | ✅ Done |
| C28 | Toolbar | `HeroToolbar` | ✅ Done |

## Forms

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C29 | Input | `HeroInput` | ✅ Done |
| C30 | TextArea | `HeroTextArea` | ✅ Done |
| C31 | InputGroup | `HeroInputGroup` | ⬜ Planned |
| C32 | TextField | `HeroTextField` | ✅ Done |
| C33 | SearchField | `HeroSearchField` | ⬜ Planned |
| C34 | NumberField | `HeroNumberField` | ⬜ Planned |
| C35 | InputOTP | `HeroInputOTP` | ⬜ Planned |
| C36 | Checkbox | `HeroCheckbox` | ⬜ Planned |
| C37 | CheckboxGroup | `HeroCheckboxGroup` | ⬜ Planned |
| C38 | RadioGroup | `HeroRadioGroup, HeroRadio` | ⬜ Planned |
| C39 | Switch | `HeroSwitch, HeroSwitchGroup` | ⬜ Planned |
| C40 | Slider | `HeroSlider` | ✅ Done |
| C41 | Fieldset | `HeroFieldset` | ⬜ Planned |
| C42 | Form | `HeroForm` | ✅ Done |

## Overlays

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C43 | Tooltip | `HeroTooltip` | ⬜ Planned |
| C44 | Popover | `HeroPopover` | ⬜ Planned |
| C45 | Modal | `HeroModal` | ⬜ Planned |
| C46 | AlertDialog | `HeroAlertDialog` | ⬜ Planned |
| C47 | Drawer | `HeroDrawer` | ⬜ Planned |
| C48 | Toast | `HeroToast` | ⬜ Planned |

## Collections & navigation

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C49 | ListBox | `HeroListBox, HeroHeader` | ✅ Done |
| C50 | Dropdown | `HeroDropdown, HeroMenu` | ⬜ Planned |
| C51 | Select | `HeroSelect` | ⬜ Planned |
| C52 | ComboBox | `HeroComboBox` | ⬜ Planned |
| C53 | Autocomplete | `HeroAutocomplete` | ⬜ Planned |
| C54 | TagGroup | `HeroTagGroup, HeroTag` | ✅ Done |
| C55 | Tabs | `HeroTabs` | ✅ Done |
| C56 | Accordion | `HeroAccordion` | ✅ Done |
| C57 | Disclosure | `HeroDisclosure` | ⬜ Planned |
| C58 | DisclosureGroup | `HeroDisclosureGroup` | ⬜ Planned |
| C59 | Breadcrumbs | `HeroBreadcrumbs` | ✅ Done |
| C60 | Pagination | `HeroPagination` | ✅ Done |
| C61 | Table | `HeroTable` | ⬜ Planned |

## Date & time

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C62 | Calendar | `HeroCalendar` | ⬜ Planned |
| C63 | RangeCalendar | `HeroRangeCalendar` | ⬜ Planned |
| C64 | DateField | `HeroDateField` | ⬜ Planned |
| C65 | TimeField | `HeroTimeField` | ⬜ Planned |
| C66 | DatePicker | `HeroDatePicker` | ⬜ Planned |
| C67 | DateRangePicker | `HeroDateRangePicker` | ⬜ Planned |

## Color

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C68 | ColorSwatch | `HeroColorSwatch` | ✅ Done |
| C69 | ColorSlider | `HeroColorSlider` | ✅ Done |
| C70 | ColorArea | `HeroColorArea` | ✅ Done |
| C71 | ColorField | `HeroColorField` | ✅ Done |
| C72 | ColorSwatchPicker | `HeroColorSwatchPicker` | ✅ Done |
| C73 | ColorPicker | `HeroColorPicker` | ✅ Done |

## Pro foundations

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P00 | Pro chart kit | `HeroProChartScope, axes, grid, series painters` | ⬜ Planned |

## Pro charts

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P01 | AreaChart | `HeroProAreaChart` | ⬜ Planned |
| P02 | BarChart | `HeroProBarChart` | ⬜ Planned |
| P03 | LineChart | `HeroProLineChart` | ⬜ Planned |
| P04 | ComposedChart | `HeroProComposedChart` | ⬜ Planned |
| P05 | PieChart | `HeroProPieChart` | ⬜ Planned |
| P06 | RadarChart | `HeroProRadarChart` | ⬜ Planned |
| P07 | RadialChart | `HeroProRadialChart` | ⬜ Planned |
| P08 | ChartTooltip | `HeroProChartTooltip, HeroProChartCrosshair, HeroProChartIndicator` | ⬜ Planned |

## Pro data display

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P09 | NumberValue | `HeroProNumberValue` | ⬜ Planned |
| P10 | TrendChip | `HeroProTrendChip` | ⬜ Planned |
| P11 | KPI | `HeroProKpi` | ⬜ Planned |
| P12 | KPIGroup | `HeroProKpiGroup` | ⬜ Planned |
| P13 | Widget | `HeroProWidget` | ⬜ Planned |
| P14 | ItemCard | `HeroProItemCard` | ⬜ Planned |
| P15 | ItemCardGroup | `HeroProItemCardGroup` | ⬜ Planned |
| P16 | EmptyState (Pro) | `HeroProEmptyState` | ⬜ Planned |
| P17 | ListView | `HeroProListView` | ⬜ Planned |
| P18 | ActionBar | `HeroProActionBar` | ⬜ Planned |
| P19 | Timeline | `HeroProTimeline` | ⬜ Planned |
| P20 | Carousel | `HeroProCarousel` | ⬜ Planned |
| P21 | FileTree | `HeroProFileTree` | ⬜ Planned |
| P22 | FloatingToc | `HeroProFloatingToc` | ⬜ Planned |
| P23 | HoverCard | `HeroProHoverCard` | ⬜ Planned |
| P24 | HoloCard | `HeroProHoloCard` | ⬜ Planned |
| P25 | Map | `HeroProMap` | ⬜ Planned |
| P26 | DataGrid | `HeroProDataGrid, HeroProCell*` | ⬜ Planned |
| P27 | Kanban | `HeroProKanban, HeroProKanbanColumn` | ⬜ Planned |
| P28 | Agenda | `HeroProAgenda` | ⬜ Planned |

## Pro feedback

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P29 | Rating | `HeroProRating` | ⬜ Planned |
| P30 | EmojiReactionButton | `HeroProEmojiReactionButton` | ⬜ Planned |
| P31 | PressableFeedback | `HeroProPressableFeedback` | ⬜ Planned |

## Pro forms

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P32 | NumberStepper | `HeroProNumberStepper` | ⬜ Planned |
| P33 | InlineSelect | `HeroProInlineSelect` | ⬜ Planned |
| P34 | NativeSelect | `HeroProNativeSelect` | ⬜ Planned |
| P35 | DropZone | `HeroProDropZone` | ⬜ Planned |
| P36 | RichTextEditor | `HeroProRichTextEditor` | ⬜ Planned |
| P37 | CheckboxButtonGroup | `HeroProCheckboxButtonGroup` | ⬜ Planned |
| P38 | RadioButtonGroup | `HeroProRadioButtonGroup` | ⬜ Planned |
| P39 | PhoneNumberField | `HeroProPhoneNumberField` | ⬜ Planned |
| P40 | NumberPad | `HeroProNumberPad` | ⬜ Planned |

## Pro navigation

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P41 | Segment | `HeroProSegment` | ⬜ Planned |
| P42 | Stepper | `HeroProStepper` | ⬜ Planned |
| P43 | Navbar | `HeroProNavbar` | ⬜ Planned |
| P44 | Sidebar | `HeroProSidebar` | ⬜ Planned |
| P45 | AppLayout | `HeroProAppLayout` | ⬜ Planned |
| P46 | Resizable | `HeroProResizable` | ⬜ Planned |
| P47 | SplitView | `HeroProSplitView` | ⬜ Planned |
| P48 | Command | `HeroProCommand` | ⬜ Planned |
| P49 | ContextMenu | `HeroProContextMenu` | ⬜ Planned |

## Pro overlays

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P50 | Sheet | `HeroProSheet` | ⬜ Planned |
| P51 | EmojiPicker | `HeroProEmojiPicker` | ⬜ Planned |

## Pro mobile

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P52 | Fab | `HeroProFab` | ⬜ Planned |
| P53 | MorphButton | `HeroProMorphButton` | ⬜ Planned |
| P54 | ProgressButton | `HeroProProgressButton` | ⬜ Planned |
| P55 | SlideButton | `HeroProSlideButton` | ⬜ Planned |
| P56 | SocialAuthButton | `HeroProSocialAuthButton` | ⬜ Planned |
| P57 | FlipCard | `HeroProFlipCard` | ⬜ Planned |
| P58 | WheelPicker | `HeroProWheelPicker, HeroProWheelPickerGroup` | ⬜ Planned |
| P59 | WheelTimePicker | `HeroProWheelTimePicker` | ⬜ Planned |
| P60 | WheelDateTimePicker | `HeroProWheelDateTimePicker` | ⬜ Planned |
| P61 | DateTimePicker | `HeroProDateTimePicker` | ⬜ Planned |

## Pro AI

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P62 | TextShimmer | `HeroProTextShimmer` | ⬜ Planned |
| P63 | ChatLoader | `HeroProChatLoader` | ⬜ Planned |
| P64 | Markdown | `HeroProMarkdown` | ⬜ Planned |
| P65 | CodeBlock | `HeroProCodeBlock` | ⬜ Planned |
| P66 | PromptSuggestion | `HeroProPromptSuggestion` | ⬜ Planned |
| P67 | PromptInput | `HeroProPromptInput` | ⬜ Planned |
| P68 | ChatAttachment | `HeroProChatAttachment` | ⬜ Planned |
| P69 | ChatMessage | `HeroProChatMessage, HeroProChatMessageActions, HeroProChatSource(s), HeroProChatTool(Group)` | ⬜ Planned |
| P70 | ChainOfThought | `HeroProChainOfThought` | ⬜ Planned |
| P71 | ChatConversation | `HeroProChatConversation` | ⬜ Planned |
| P72 | ChatListView | `HeroProChatListView` | ⬜ Planned |

## Pro composites

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| P73 | Filters | `HeroProFilters` | ⬜ Planned |

## Pro templates

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| T1 | Dashboard template | `HeroProDashboardTemplate` | ⬜ Planned |
| T2 | Mail template | `HeroProMailTemplate` | ⬜ Planned |
| T3 | Chat template | `HeroProChatTemplate` | ⬜ Planned |
| T4 | Finances template | `HeroProFinancesTemplate` | ⬜ Planned |
| T5 | CRM template | `HeroProCrmTemplate` | ⬜ Planned |

## Premium themes

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| Z1 | Brutalism design system | `HeroProThemes.brutalism` | ⬜ Planned |
| Z2 | Glass design system | `HeroProThemes.glass` | ⬜ Planned |
| Z3 | Mouve design system | `HeroProThemes.mouve` | ⬜ Planned |

## Polish

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| G1 | Gallery chrome on hero_ui components | apps/gallery | ⬜ Planned |
