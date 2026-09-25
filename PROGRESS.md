# Progress

Every slice from [PLAN.md](PLAN.md) in build order. A slice is **Done** when the widget, its
widget and golden tests, gallery page, docs page and dartdoc have landed on `main` with
`flutter analyze` and `flutter test` green.

Legend: ✅ Done · 🚧 In progress · ⬜ Planned

## Summary

<!-- summary:start -->
**11 of 164 slices done**, 0 in progress.
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
| C02 | Typography | `HeroTypographyText` | ⬜ Planned |
| C03 | Label | `HeroLabel` | ⬜ Planned |
| C04 | Description | `HeroDescription` | ⬜ Planned |
| C05 | FieldError | `HeroFieldError` | ⬜ Planned |
| C06 | ErrorMessage | `HeroErrorMessage` | ⬜ Planned |
| C07 | Button | `HeroButton` | ✅ Done |
| C08 | CloseButton | `HeroCloseButton` | ⬜ Planned |
| C09 | ButtonGroup | `HeroButtonGroup` | ✅ Done |
| C10 | ToggleButton | `HeroToggleButton` | ⬜ Planned |
| C11 | ToggleButtonGroup | `HeroToggleButtonGroup` | ⬜ Planned |
| C12 | Kbd | `HeroKbd` | ⬜ Planned |
| C13 | Link | `HeroLink` | ⬜ Planned |

## Data display

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C14 | Badge | `HeroBadge` | ⬜ Planned |
| C15 | Chip | `HeroChip` | ⬜ Planned |
| C16 | Avatar | `HeroAvatar` | ⬜ Planned |
| C17 | AvatarGroup | `HeroAvatarGroup` | ⬜ Planned |
| C18 | Skeleton | `HeroSkeleton` | ⬜ Planned |
| C19 | ProgressBar | `HeroProgressBar` | ⬜ Planned |
| C20 | ProgressCircle | `HeroProgressCircle` | ⬜ Planned |
| C21 | Meter | `HeroMeter` | ⬜ Planned |
| C22 | Separator | `HeroSeparator` | ⬜ Planned |
| C23 | Surface | `HeroSurface` | ⬜ Planned |
| C24 | Card | `HeroCard` | ⬜ Planned |
| C25 | Alert | `HeroAlert` | ⬜ Planned |
| C26 | ScrollShadow | `HeroScrollShadow` | ⬜ Planned |
| C27 | EmptyState | `HeroEmptyState` | ⬜ Planned |
| C28 | Toolbar | `HeroToolbar` | ⬜ Planned |

## Forms

| # | Slice | Flutter API | Status |
| --- | --- | --- | --- |
| C29 | Input | `HeroInput` | ⬜ Planned |
| C30 | TextArea | `HeroTextArea` | ⬜ Planned |
| C31 | InputGroup | `HeroInputGroup` | ⬜ Planned |
| C32 | TextField | `HeroTextField` | ⬜ Planned |
| C33 | SearchField | `HeroSearchField` | ⬜ Planned |
| C34 | NumberField | `HeroNumberField` | ⬜ Planned |
| C35 | InputOTP | `HeroInputOTP` | ⬜ Planned |
| C36 | Checkbox | `HeroCheckbox` | ⬜ Planned |
| C37 | CheckboxGroup | `HeroCheckboxGroup` | ⬜ Planned |
| C38 | RadioGroup | `HeroRadioGroup, HeroRadio` | ⬜ Planned |
| C39 | Switch | `HeroSwitch, HeroSwitchGroup` | ⬜ Planned |
| C40 | Slider | `HeroSlider` | ⬜ Planned |
| C41 | Fieldset | `HeroFieldset` | ⬜ Planned |
| C42 | Form | `HeroForm` | ⬜ Planned |

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
| C49 | ListBox | `HeroListBox, HeroHeader` | ⬜ Planned |
| C50 | Dropdown | `HeroDropdown, HeroMenu` | ⬜ Planned |
| C51 | Select | `HeroSelect` | ⬜ Planned |
| C52 | ComboBox | `HeroComboBox` | ⬜ Planned |
| C53 | Autocomplete | `HeroAutocomplete` | ⬜ Planned |
| C54 | TagGroup | `HeroTagGroup, HeroTag` | ⬜ Planned |
| C55 | Tabs | `HeroTabs` | ⬜ Planned |
| C56 | Accordion | `HeroAccordion` | ⬜ Planned |
| C57 | Disclosure | `HeroDisclosure` | ⬜ Planned |
| C58 | DisclosureGroup | `HeroDisclosureGroup` | ⬜ Planned |
| C59 | Breadcrumbs | `HeroBreadcrumbs` | ⬜ Planned |
| C60 | Pagination | `HeroPagination` | ⬜ Planned |
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
| C68 | ColorSwatch | `HeroColorSwatch` | ⬜ Planned |
| C69 | ColorSlider | `HeroColorSlider` | ⬜ Planned |
| C70 | ColorArea | `HeroColorArea` | ⬜ Planned |
| C71 | ColorField | `HeroColorField` | ⬜ Planned |
| C72 | ColorSwatchPicker | `HeroColorSwatchPicker` | ⬜ Planned |
| C73 | ColorPicker | `HeroColorPicker` | ⬜ Planned |

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
