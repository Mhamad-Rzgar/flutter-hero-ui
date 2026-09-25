# Tabs

Tabs organize content into multiple sections and allow users to navigate between them.

HeroUI reference: <https://heroui.com/en/docs/react/components/tabs>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroTabs(
  children: <Widget>[
    HeroTabListContainer(
      child: HeroTabList(
        semanticLabel: 'Options',
        children: const <Widget>[
          HeroTab(id: 'overview', child: Text('Overview')),
          HeroTab(id: 'analytics', child: Text('Analytics')),
          HeroTab(id: 'reports', child: Text('Reports')),
        ],
      ),
    ),
    const HeroTabPanel(id: 'overview', child: Text('View your project overview.')),
    const HeroTabPanel(id: 'analytics', child: Text('Track your metrics.')),
    const HeroTabPanel(id: 'reports', child: Text('Download detailed reports.')),
  ],
)
```

## Anatomy

| HeroUI | Flutter | Role |
| --- | --- | --- |
| `Tabs` | `HeroTabs` | Owns the selection, orientation, variant and alignment. |
| `Tabs.ListContainer` | `HeroTabListContainer` | The `--default` track; makes the list scroll with fading edges and chevrons when it overflows. |
| `Tabs.List` | `HeroTabList` | The row (or column) of tabs, a single Tab stop. |
| `Tabs.Tab` | `HeroTab` | One tab, matched to its panel by `id`. |
| `Tabs.Indicator` | `HeroTabIndicator` | The sliding selection marker; every `HeroTab` shows one by default (`indicator:`). |
| `Tabs.Separator` | `HeroTabSeparator` | Optional divider, passed as `separator:` to every tab but the first. |
| `Tabs.Panel` | `HeroTabPanel` | Content shown while its tab is selected. |

## Look

- **Primary** (default): the container is a `--default` track with a 20 px radius
  (`--radius × 2.5`) and 4 px padding. Tabs are 32 px tall, 16 px horizontal padding, 14 px
  medium text in `--muted`; the selected tab's text is `--segment-foreground` on a `--segment`
  indicator (24 px radius, surface shadow). Hovered tabs fade to 70%, disabled tabs to 50%.
- **Secondary**: no track; a 1 px `--border` rule under the list (at its start when vertical)
  and a 2 px `--accent` line under (beside) the selected tab, whose text is `--foreground`.
  Separators are hidden.
- **Indicator motion**: when the selection changes, the new tab's indicator starts at the old
  indicator's position and size and moves there over 250 ms with `--ease-out-fluid`, like
  React Aria's `SelectionIndicator`.
- **Layout**: horizontal lists are at least as wide as their container and share its width
  equally (never below a tab's natural width); vertical lists are as wide as the widest tab
  (80 px minimum) with 4 px gaps, and stretch to the height of the panel. Panels have 8 px
  padding and start 24 px after the list (8 px gap plus 16 px margin).
- **Overflow**: inside a `HeroTabListContainer`, an overflowing list scrolls without a
  scrollbar, fades 64 px at the scrollable edges and shows 16 px chevrons 4 px from the ends;
  a chevron scrolls by 80% of the visible length.
- Colors, opacity and the indicator transition 150 ms / 250 ms and nothing animates under
  reduced motion.

## Examples

### Vertical

```dart
HeroTabs(
  orientation: Axis.vertical,
  children: <Widget>[
    HeroTabListContainer(
      child: HeroTabList(
        semanticLabel: 'Vertical tabs',
        children: const <Widget>[
          HeroTab(id: 'account', child: Text('Account')),
          HeroTab(id: 'security', child: Text('Security')),
        ],
      ),
    ),
    const HeroTabPanel(id: 'account', child: Text('Account settings')),
    const HeroTabPanel(id: 'security', child: Text('Security settings')),
  ],
)
```

### Overflow

Nothing to configure: a list that does not fit its container scrolls, fades and shows chevrons.
Give a vertical `HeroTabs` a fixed height to make a long vertical list scroll.

### Disabled tab

```dart
HeroTab(id: 'disabled', isDisabled: true, child: const Text('Disabled'))
```

`HeroTabs.disabledKeys` and `HeroTabs.isDisabled` disable tabs from the root.

### With separator

```dart
HeroTab(
  id: 'analytics',
  separator: const HeroTabSeparator(),
  child: const Text('Analytics'),
)
```

The separators of the selected tab and of the tab after it fade out.

### Secondary variant

```dart
HeroTabs(variant: HeroTabsVariant.secondary, children: <Widget>[...])
```

### Alignment

```dart
HeroTabs(
  align: HeroTabsAlign.start,
  orientation: Axis.vertical,
  variant: HeroTabsVariant.secondary,
  children: <Widget>[...],
)
```

### Render function

```dart
HeroTab(
  id: 'components',
  builder: (BuildContext context, HeroTabState state) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: <Widget>[
      const Text('Components'),
      if (state.isHovered) const HeroIcon(HeroIcons.externalLink, size: 12),
    ],
  ),
)
```

### Customization

```dart
HeroTabListContainer(
  decoration: ShapeDecoration(
    color: colors.accentSoft.withValues(alpha: 0.3),
    shape: theme.shapeAll(theme.radii.xl),
  ),
  child: HeroTabList(
    semanticLabel: 'Billing cycle',
    children: <Widget>[
      HeroTab(
        id: 'monthly',
        indicator: HeroTabIndicator(
          color: colors.accent,
          borderRadius: BorderRadius.circular(8),
          shadows: const <BoxShadow>[],
        ),
        style: HeroTabStyle(
          borderRadius: BorderRadius.circular(8),
          opacity: const WidgetStatePropertyAll<double>(1),
          foregroundColor: WidgetStateProperty.resolveWith(
            (Set<WidgetState> s) => s.contains(WidgetState.selected)
                ? colors.accentForeground
                : colors.muted,
          ),
        ),
        child: const Text('Monthly'),
      ),
    ],
  ),
)
```

## Accessibility

- The list is a tab bar (`SemanticsRole.tabBar`, labelled by `semanticLabel`), each tab a
  `SemanticsRole.tab` with its selected state and a tap action, each panel a
  `SemanticsRole.tabPanel`.
- The list is a single Tab stop: the selected tab. Arrow Left/Right (horizontal, flipped in
  right-to-left layouts) or Up/Down (vertical) move between tabs and wrap around; Home and End
  jump to the first and last tab; disabled tabs are skipped. With automatic activation the
  focused tab is selected; with `HeroTabsKeyboardActivation.manual` Enter or Space selects.
- The focused tab is scrolled into view; the focus ring shows only for keyboard focus.

## API

### HeroTabs

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The list container (or list) and the panels. |
| `variant` | `HeroTabsVariant` | `primary` | `primary` or `secondary`. |
| `orientation` | `Axis` | `Axis.horizontal` | Tabs above or beside the panels. |
| `align` | `HeroTabsAlign` | `center` | Content alignment inside each tab. |
| `selectedKey` | `Object?` | `null` | Controlled selection. |
| `defaultSelectedKey` | `Object?` | `null` | Initial selection; defaults to the first enabled tab. |
| `onSelectionChanged` | `ValueChanged<Object>?` | `null` | Called with the newly selected id. |
| `disabledKeys` | `Set<Object>` | `{}` | Ids of disabled tabs. |
| `isDisabled` | `bool` | `false` | Disables every tab. |
| `keyboardActivation` | `HeroTabsKeyboardActivation` | `automatic` | Whether focus selects. |

### HeroTabListContainer

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The `HeroTabList`. |
| `decoration` | `Decoration?` | `null` | Replaces the track (primary) or rule (secondary). |

### HeroTabList

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The tabs. |
| `semanticLabel` | `String?` | `null` | Tab bar label (`aria-label`). |

### HeroTab

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `Object` | required | Identifies the tab and its panel. |
| `child` | `Widget?` | `null` | Label. |
| `builder` | `HeroTabWidgetBuilder?` | `null` | Builds the label from the `HeroTabState`. |
| `isDisabled` | `bool` | `false` | Disables the tab. |
| `indicator` | `Widget?` | `HeroTabIndicator()` | Selection indicator; `null` for none. |
| `separator` | `Widget?` | `null` | Leading divider, usually `HeroTabSeparator`. |
| `style` | `HeroTabStyle?` | `null` | Style overrides. |
| `focusNode` | `FocusNode?` | `null` | Focus node. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### HeroTabIndicator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color?` | `--segment` / `--accent` | Fill. |
| `borderRadius` | `BorderRadiusGeometry?` | 24 / square | Corner radii. |
| `shadows` | `List<BoxShadow>?` | surface shadow / none | Shadows. |

### HeroTabSeparator

No parameters.

### HeroTabPanel

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `Object` | required | Id of the tab this panel belongs to. |
| `child` | `Widget?` | `null` | Content. |
| `builder` | `WidgetBuilder?` | `null` | Builds the content lazily. |
| `padding` | `EdgeInsetsGeometry?` | 8 on all sides | Panel padding. |

### HeroTabStyle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backgroundColor` | `WidgetStateProperty<Color?>?` | `null` | Tab fill below the indicator. |
| `foregroundColor` | `WidgetStateProperty<Color?>?` | `null` | Text and icon color. |
| `opacity` | `WidgetStateProperty<double?>?` | `null` | Opacity of enabled tabs (0.7 on hover by default). |
| `borderRadius` | `BorderRadiusGeometry?` | `null` | Tab corner radii. |

`HeroTabState` is an alias of `HeroInteractionState` (`isSelected`, `isHovered`, `isPressed`,
`isFocused`, `isFocusVisible`, `isDisabled`).
