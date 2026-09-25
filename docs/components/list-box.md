# ListBox

A listbox displays a list of options and allows a user to select one or more of them.

HeroUI reference: <https://heroui.com/en/docs/react/components/list-box>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
SizedBox(
  width: 220,
  child: HeroListBox(
    semanticLabel: 'Users',
    selectionMode: HeroSelectionMode.single,
    children: <Widget>[
      HeroListBoxItem(
        id: '1',
        textValue: 'Bob',
        startContent: HeroAvatar(
          size: HeroSize.sm,
          src: 'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/avatars/blue.jpg',
          name: 'Bob',
          fallback: const Text('B'),
        ),
        label: 'Bob',
        description: 'bob@heroui.com',
        indicator: const HeroListBoxItemIndicator(),
      ),
      // Fred and Martha alike.
    ],
  ),
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `ListBox` | `HeroListBox` (`HeroListBox.builder` for data-built items) |
| `ListBox.Item` | `HeroListBoxItem` |
| `Label` / `Description` in an item | `label` / `description` of `HeroListBoxItem` (or `HeroLabel` / `HeroDescription` in `child`) |
| `ListBox.ItemIndicator` | `HeroListBoxItemIndicator`, passed as the item's `indicator` |
| `ListBox.Section` | `HeroListBoxSection` |
| `Header` | `HeroHeader`, the section's `header` |
| `Separator` | `HeroSeparator` between sections |
| `Collection` | `HeroCollection` |
| `ListBoxLoadMoreItem` | `HeroListBoxLoadMoreItem` |
| `Virtualizer` + `ListLayout` | `HeroListBox(virtualized: true, rowHeight: ..., headingHeight: ...)` |
| `renderEmptyState` | `emptyStateBuilder`, usually returning a `HeroEmptyState` |

An item lays its content out in a row with a 12 px gap: `startContent` (icon or avatar), the
main content (`builder`, `child`, or `label` over `description`) and `endContent` pushed to
the end (for example a `HeroKbd` shortcut). The `indicator` sits 8 px from the end edge.

## Styles

- **List:** fills the available width (as wide as its widest item when the width is
  unbounded), 4 px padding, 4 px between its children, clipped. Horizontal separators cover
  94% of the width, centered. When its height is limited the list scrolls.
- **Item:** at least 36 px tall, 8 × 6 padding (28 px end padding with an indicator), 16 px
  corners, `text-sm`. Hover fills it with `--default` (no transition); pressing scales it to
  0.98 (250 ms, ease-out-quart); keyboard focus shows the focus ring; disabled items fade to
  50%. Selected items have no fill: the indicator marks them.
- **Indicator:** 16 × 16 in `--default-foreground`. The default checkmark (10 × 10) strokes
  itself in over 300 ms when selected and out when deselected.
- **Section:** items follow each other without a gap. **Header:** `text-xs` medium `--muted`,
  8 px horizontal, 6 px top and 4 px bottom padding.
- **Danger variant:** the item's label and indicator use `--danger`.

## Variants

| Variant | Look |
| --- | --- |
| `HeroListBoxVariant.standard` | Regular items. |
| `HeroListBoxVariant.danger` | Destructive items: `--danger` label and indicator. |

Set it per item; the list's `variant` is the default of its items.

## Examples

### With disabled items

```dart
HeroSurface(
  width: 256,
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  shadow: theme.shadows.surface,
  child: HeroListBox(
    semanticLabel: 'File actions',
    padding: EdgeInsets.all(theme.spacing(2)),
    disabledKeys: const <Object>{'delete-file'},
    onAction: (Object key) => debugPrint('Selected item: $key'),
    children: const <Widget>[
      HeroListBoxSection(
        header: HeroHeader.text('Actions'),
        children: <Widget>[
          HeroListBoxItem(
            id: 'new-file',
            startContent: HeroIcon(HeroIcons.squarePlus),
            label: 'New file',
            description: 'Create a new file',
            endContent: HeroKbd(
              variant: HeroKbdVariant.light,
              keys: <HeroKbdKey>[HeroKbdKey.command],
              text: 'N',
            ),
          ),
        ],
      ),
      HeroSeparator(),
      HeroListBoxSection(
        header: HeroHeader.text('Danger zone'),
        children: <Widget>[
          HeroListBoxItem(
            id: 'delete-file',
            variant: HeroListBoxVariant.danger,
            startContent: HeroIcon(HeroIcons.trashBin),
            label: 'Delete file',
            description: 'Move to trash',
          ),
        ],
      ),
    ],
  ),
)
```

### With sections

The same list without `disabledKeys`. Sections take a `header` (usually a `HeroHeader`) and
are separated by a `HeroSeparator`.

### Multi select

```dart
HeroListBox(
  semanticLabel: 'Users',
  selectionMode: HeroSelectionMode.multiple,
  children: userItems,
)
```

### Controlled

```dart
Set<Object> selected = <Object>{'1'};

HeroListBox(
  semanticLabel: 'Users',
  selectionMode: HeroSelectionMode.multiple,
  selectedKeys: selected,
  onSelectionChanged: (Set<Object> keys) => setState(() => selected = keys),
  children: userItems,
)
```

### Virtualization

Virtualized lists build only the rows in view. Rows have fixed heights (`rowHeight`,
`headingHeight`, `loaderHeight`, 48 by default, scaled with the text size), so the list needs
a bounded size.

```dart
SizedBox(
  width: 300,
  height: 400,
  child: HeroListBox.builder(
    semanticLabel: 'Virtualized list with 1000 items',
    virtualized: true,
    rowHeight: 50,
    itemCount: users.length,
    itemBuilder: (BuildContext context, int index) => HeroListBoxItem(
      id: users[index].id,
      label: users[index].name,
      description: users[index].email,
      indicator: const HeroListBoxItemIndicator(),
    ),
  ),
)
```

### Custom check icon

```dart
HeroListBoxItem(
  id: '1',
  label: 'Bob',
  indicator: HeroListBoxItemIndicator(
    builder: (BuildContext context, bool isSelected) => isSelected
        ? HeroIcon(HeroIcons.check, color: theme.colors.accentSoftForeground)
        : null,
  ),
)
```

### Render function

`builder` receives the item state (`isSelected`, `isFocused`, `isFocusVisible`, `isHovered`,
`isPressed`, `isDisabled`):

```dart
HeroListBoxItem(
  id: '1',
  builder: (BuildContext context, HeroListBoxItemState state) => Text(
    state.isSelected ? 'Bob (selected)' : 'Bob',
  ),
)
```

### Customization

```dart
HeroListBox(
  semanticLabel: 'Assignee',
  selectionMode: HeroSelectionMode.single,
  itemStyle: HeroListBoxItemStyle(
    borderRadius: BorderRadius.circular(theme.radii.lg),
    backgroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.focused)
          ? theme.colors.accent.withValues(alpha: 0.1)
          : states.contains(WidgetState.selected)
          ? theme.colors.accent.withValues(alpha: 0.05)
          : null,
    ),
  ),
  children: userItems,
)
```

### Empty state and loading more

```dart
HeroListBox(
  semanticLabel: 'Results',
  emptyStateBuilder: (BuildContext context) => const HeroEmptyState(),
  children: <Widget>[
    HeroCollection<Pokemon>(
      items: pokemon,
      itemBuilder: (BuildContext context, Pokemon item) =>
          HeroListBoxItem(id: item.name, label: item.name),
    ),
    HeroListBoxLoadMoreItem(isLoading: loading, onLoadMore: loadMore),
  ],
)
```

## Behavior

- **Selection** (`selectionMode`, `none` by default like React Aria): pressing an item toggles
  it. Single selection replaces the selection, and pressing the selected item clears it unless
  `disallowEmptySelection`. Multiple selection toggles; Shift-press extends from the last
  pressed item. Disabled items (`isDisabled`, `disabledKeys`) cannot be focused or pressed.
- **Actions:** `onAction` (and the item's `onAction`) run when an item is pressed, after the
  selection changed.
- **Keyboard:** the list is one Tab stop and focuses the last focused item, else the first
  selected one, else the first. Up/Down move between enabled items (wrapping only with
  `shouldFocusWrap`), Home/End and PageUp/PageDown jump, typing focuses the first item whose
  text (`textValue`, else `label`) starts with the typed characters (the search resets after a
  second), Enter and Space press the focused item, Shift + arrows and Shift + Home/End extend a
  multiple selection, Ctrl/Cmd + A selects all and Escape clears the selection. The focused
  item scrolls into view.
- **Pickers and menus:** `shouldFocusOnHover` focuses items on hover; `shouldUseVirtualFocus`
  with a `HeroListBoxController` keeps the keyboard focus in another widget (a combo box
  input) and forwards keys with `controller.handleKeyEvent`. `padding`, `itemStyle` and
  `animateIndicator: false` reproduce the list inside Select/ComboBox popovers.

## Accessibility

- The list is a `SemanticsRole.list` labelled by `semanticLabel`. Items are buttons with their
  label and description as text, `selected` when selected, focusable and focused while they
  have the list's focus; disabled items are announced as disabled.
- Headers are announced as headings. The indicator is hidden from assistive technologies.
- The focus ring only shows for keyboard focus.

## API

### HeroListBox

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Items, sections, separators, collections and a load-more sentinel. |
| `itemCount` / `itemBuilder` | `int` / `IndexedWidgetBuilder` | required | Data-built items (`HeroListBox.builder`). |
| `selectionMode` | `HeroSelectionMode` | `none` | `none`, `single` or `multiple`. |
| `selectedKeys` | `Set<Object>?` | `null` | Controlled selection. |
| `defaultSelectedKeys` | `Set<Object>?` | `null` | Initial selection when uncontrolled. |
| `onSelectionChanged` | `ValueChanged<Set<Object>>?` | `null` | Called with the new selection. |
| `disabledKeys` | `Set<Object>` | `{}` | Items that cannot be focused, selected or pressed. |
| `disallowEmptySelection` | `bool` | `false` | Keeps at least one item selected. |
| `onAction` | `ValueChanged<Object>?` | `null` | Called with the id of a pressed item. |
| `variant` | `HeroListBoxVariant` | `standard` | Default variant of the items. |
| `emptyStateBuilder` | `WidgetBuilder?` | `null` | Content shown when there are no items. |
| `semanticLabel` | `String?` | `null` | Accessibility label (`aria-label`). |
| `padding` | `EdgeInsetsGeometry?` | 4 all round | Padding around the items. |
| `itemStyle` | `HeroListBoxItemStyle?` | `null` | Style overrides for every item. |
| `animateIndicator` | `bool` | `true` | Whether the checkmark animates. |
| `virtualized` | `bool` | `false` | Build only the rows in view. |
| `rowHeight` / `headingHeight` / `loaderHeight` | `double?` | 48 | Row heights when virtualized. |
| `itemSpacing` | `double` | `0` | Gap between rows when virtualized. |
| `shouldFocusOnHover` | `bool` | `false` | Focus items on hover. |
| `shouldFocusWrap` | `bool` | `false` | Arrow keys wrap around. |
| `shouldUseVirtualFocus` | `bool` | `false` | Leave the keyboard focus elsewhere. |
| `controller` | `HeroListBoxController?` | `null` | Drives the focused item. |
| `focusNode` | `FocusNode?` | `null` | Focus node of the list. |
| `autofocus` | `bool` | `false` | Focus the list when first built. |
| `scrollController` | `ScrollController?` | `null` | Controller of the list's scroll view. |

### HeroListBoxItem

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `Object` | required | Key in the selection, disabled keys and actions. |
| `textValue` | `String?` | `label` / text of `child` | Text used for typeahead. |
| `label` | `String?` | `null` | Label (`HeroLabel`, `text-sm` medium). |
| `description` | `String?` | `null` | Description below the label (`HeroDescription`). |
| `startContent` | `Widget?` | `null` | Icon or avatar before the content. |
| `endContent` | `Widget?` | `null` | Content at the end of the row (shortcut). |
| `child` | `Widget?` | `null` | Main content; replaces `label` and `description`. |
| `builder` | `HeroListBoxItemWidgetBuilder?` | `null` | Builds the main content from the item state. |
| `indicator` | `Widget?` | `null` | Selection indicator (`HeroListBoxItemIndicator`). |
| `isDisabled` | `bool` | `false` | Disables the item. |
| `variant` | `HeroListBoxVariant?` | list's | `standard` or `danger`. |
| `onAction` | `VoidCallback?` | `null` | Called when pressed. |
| `style` | `HeroListBoxItemStyle?` | `null` | Style overrides. |
| `semanticLabel` | `String?` | content text | Accessibility label. |

### HeroListBoxItemIndicator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | checkmark | Replaces the checkmark. |
| `builder` | `Widget? Function(BuildContext, bool isSelected)?` | `null` | Builds the indicator for the selection state; null shows nothing. |

### HeroListBoxSection

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `header` | `Widget?` | `null` | Section title, usually a `HeroHeader`. |
| `children` | `List<Widget>` | required | Items and collections. |

### HeroHeader

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` / `data` | `Widget` / `String` | required | Content (`HeroHeader.text` for a string). |
| `style` | `TextStyle?` | `null` | Merged over the header style. |

### HeroListBoxLoadMoreItem

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `isLoading` | `bool` | `false` | Whether more items are loading. |
| `onLoadMore` | `VoidCallback?` | `null` | Called when the sentinel nears the visible area. |
| `scrollOffset` | `double` | `1` | Distance in viewport heights at which loading starts. |
| `child` | `Widget?` | spinner | Shown while loading. |

### HeroListBoxItemStyle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backgroundColor` | `WidgetStateProperty<Color?>?` | `--default` on hover | Fill per state (`hovered`, `pressed`, `focused`, `selected`, `disabled`). |
| `borderRadius` | `BorderRadiusGeometry?` | 16 | Corner radii. |
| `padding` | `EdgeInsetsGeometry?` | 8 × 6 | Inner padding. |
| `minHeight` | `double?` | 36 | Minimum height. |
| `pressedScale` | `double?` | 0.98 | Scale while pressed. |

### HeroListBoxController

| Member | Description |
| --- | --- |
| `focusedKey` | The focused item's id. |
| `focusKey(key)` / `focusFirst()` / `focusLast()` | Moves the focus and scrolls the item into view. |
| `activateFocused()` | Presses the focused item. |
| `handleKeyEvent(event)` | Handles a navigation or selection key as the list would. |

### HeroEmptyState

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` / `data` | `Widget?` / `String` | "No results found" | Content (`HeroEmptyState.text` for a string). |
| `style` | `TextStyle?` | `null` | Merged over `text-sm` `--muted`. |
| `padding` | `EdgeInsetsGeometry?` | 8 all round | Padding. |

### HeroCollection

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `items` | `Iterable<T>` | required | The data. |
| `itemBuilder` | `Widget Function(BuildContext, T)` | required | Builds the widget of one element. |
