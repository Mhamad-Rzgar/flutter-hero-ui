# TagGroup

A focusable list of tags with support for keyboard navigation, selection, and removal.

HeroUI reference: <https://heroui.com/en/docs/react/components/tag-group>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroTagGroup(
  semanticLabel: 'Tags',
  selectionMode: HeroSelectionMode.single,
  children: const <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        HeroTag(
          id: 'news',
          startContent: HeroIcon(HeroIcons.squareArticle),
          label: 'News',
        ),
        HeroTag(
          id: 'travel',
          startContent: HeroIcon(HeroIcons.planetEarth),
          label: 'Travel',
        ),
      ],
    ),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `TagGroup` | `HeroTagGroup` (column of its parts with a 4 px gap) |
| `Label` | `label` (or a `HeroLabel` in `children`) |
| `TagGroup.List` | `HeroTagGroupList` |
| `Tag` | `HeroTag` |
| `Tag.RemoveButton` | `HeroTagRemoveButton` (automatic with `onRemove`) |
| `Description` | `description` (or a `HeroDescription` in `children`) |
| `EmptyState` (`renderEmptyState`) | `HeroTagGroupList.emptyStateBuilder` |

Size, variant and the disabled state are set on the group and inherited by the tags.

## Styles

- **Group:** column with a 4 px gap; descriptions get 4 px padding.
- **List:** wraps with a 6 px gap between tags and lines.
- **Tag:** row with a 4 px gap, `font-medium`, 12 px icons in the text color.

| Size | Padding | Text | Corners | Height |
| --- | --- | --- | --- | --- |
| `sm` | 8 × 2 | `text-xs` | 12 | 20 |
| `md` (default) | 8 × 4 | `text-xs` | 12 | 24 |
| `lg` | 10 × 6 | `text-sm` | 16 | 32 |

| Variant | Fill | Hover | Text |
| --- | --- | --- | --- |
| `HeroTagVariant.standard` | `--default` | `--default-hover` | `--default-foreground` |
| `HeroTagVariant.surface` | `--surface` | `--surface-hover` | `--surface-foreground` |
| selected | `--accent-soft` | `--accent-soft-hover` | `--accent-soft-foreground` |

Colors change over 100 ms; disabled tags fade to 50%; keyboard focus shows the focus ring.
The remove button is a 12 px close button (on a `--default` circle, `--default-hover` on hover)
in the tag's text color, with a 24 px touch target.

## Examples

### Sizes

```dart
HeroTagGroup(
  label: 'Small',
  size: HeroSize.sm,
  selectionMode: HeroSelectionMode.single,
  children: const <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        HeroTag(id: 'news', label: 'News'),
        HeroTag(id: 'travel', label: 'Travel'),
        HeroTag(id: 'gaming', label: 'Gaming'),
      ],
    ),
  ],
)
```

### Variants

```dart
HeroTagGroup(
  label: 'Surface',
  variant: HeroTagVariant.surface,
  selectionMode: HeroSelectionMode.single,
  children: <Widget>[HeroTagGroupList(children: tags)],
)
```

### Disabled

```dart
HeroTagGroup(
  label: 'Disabled Keys',
  description: 'Tags disabled via disabledKeys prop',
  disabledKeys: const <Object>{'travel'},
  selectionMode: HeroSelectionMode.single,
  children: const <Widget>[
    HeroTagGroupList(
      children: <Widget>[
        HeroTag(id: 'news', label: 'News', isDisabled: true),
        HeroTag(id: 'travel', label: 'Travel'),
      ],
    ),
  ],
)
```

`isDisabled` on the group disables every tag.

### Selection modes and controlled selection

```dart
Set<Object> selected = <Object>{'news', 'travel'};

HeroTagGroup(
  label: 'Categories (controlled)',
  description: 'Selected: ${selected.isEmpty ? 'None' : selected.join(', ')}',
  selectionMode: HeroSelectionMode.multiple,
  selectedKeys: selected,
  onSelectionChanged: (Set<Object> keys) => setState(() => selected = keys),
  children: <Widget>[HeroTagGroupList(children: tags)],
)
```

### With list data

```dart
HeroTagGroup(
  label: 'Team Members',
  selectionMode: HeroSelectionMode.multiple,
  onRemove: (Set<Object> keys) =>
      setState(() => users.removeWhere((User u) => keys.contains(u.id))),
  children: <Widget>[
    HeroTagGroupList(
      emptyStateBuilder: (BuildContext context) => const HeroEmptyState(
        padding: EdgeInsets.all(4),
        child: Text('No team members'),
      ),
      children: <Widget>[
        HeroCollection<User>(
          items: users,
          itemBuilder: (BuildContext context, User user) => HeroTag(
            id: user.id,
            startContent: SizedBox.square(
              dimension: 16,
              child: HeroAvatar(size: HeroSize.sm, src: user.avatar),
            ),
            label: user.name,
          ),
        ),
      ],
    ),
  ],
)
```

### With remove button

With `onRemove` every tag gets a remove button. Replace its icon with `removeButton`, or
place a `HeroTagRemoveButton` yourself in a `builder`:

```dart
HeroTag(
  id: 'react',
  label: 'React',
  removeButton: const HeroTagRemoveButton(
    child: HeroIcon(HeroIcons.circleXmarkFill),
  ),
)

HeroTag(
  id: 'vue',
  builder: (BuildContext context, HeroTagState state) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: <Widget>[
      const Text('Vue'),
      if (state.allowsRemoving) const HeroTagRemoveButton(),
    ],
  ),
)
```

### Render function

`builder` receives a `HeroTagState` (`isSelected`, `isDisabled`, `isHovered`, `isPressed`,
`isFocused`, `isFocusVisible`, `allowsRemoving`).

### Customization

```dart
HeroTag(
  id: 'news',
  startContent: const HeroIcon(HeroIcons.squareArticle),
  label: 'News',
  style: HeroTagStyle(
    borderRadius: BorderRadius.circular(theme.radii.full),
    textStyle: theme.typography.sm,
    iconSize: 16,
    backgroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? colors.foreground
          : colors.surface,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? colors.background
          : colors.foreground,
    ),
  ),
)
```

`HeroTagGroupList.spacing` changes the gap between tags.

## Behavior

- **Selection:** `selectionMode` is `none` by default. Pressing a tag, Enter or Space toggle
  it; single selection replaces the selection.
- **Removal:** with `onRemove`, pressing a tag's remove button calls it with that tag;
  Delete or Backspace on the focused tag calls it with the whole selection when the tag is
  selected, else with the tag. After a removal the focus moves to the tag that took its place.
- **Keyboard:** the list is one Tab stop (the last focused tag, else the first selected one,
  else the first). Left/Right (mirrored in right-to-left layouts) and Up/Down move between
  enabled tags, Home/End jump to the ends, typing focuses a tag by its text, Escape clears
  the selection and Ctrl/Cmd + A selects every tag in multiple selection. Remove buttons are
  not Tab stops.

## Accessibility

- The list is a `SemanticsRole.list` labelled by `label` (or `semanticLabel`).
- Tags are buttons announced as selected when selected; disabled tags as disabled.
- Remove buttons are buttons labelled "Remove tag".

## API

### HeroTagGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The parts: a `HeroTagGroupList` and other content. |
| `label` | `String?` | `null` | Label above the parts; labels the list. |
| `description` | `String?` | `null` | Description below the parts. |
| `selectionMode` | `HeroSelectionMode` | `none` | `none`, `single` or `multiple`. |
| `selectedKeys` | `Set<Object>?` | `null` | Controlled selection. |
| `defaultSelectedKeys` | `Set<Object>?` | `null` | Initial selection when uncontrolled. |
| `onSelectionChanged` | `ValueChanged<Set<Object>>?` | `null` | Called with the new selection. |
| `disabledKeys` | `Set<Object>` | `{}` | Tags that cannot be focused, selected or removed. |
| `disallowEmptySelection` | `bool` | `false` | Keeps at least one tag selected. |
| `isDisabled` | `bool` | `false` | Disables every tag. |
| `onRemove` | `ValueChanged<Set<Object>>?` | `null` | Called with the tags to remove; shows remove buttons. |
| `size` | `HeroSize` | `md` | Size of the tags. |
| `variant` | `HeroTagVariant` | `standard` | Look of the tags. |
| `semanticLabel` | `String?` | `label` | Accessibility label of the list. |

### HeroTagGroupList

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Tags and `HeroCollection`s of tags. |
| `emptyStateBuilder` | `WidgetBuilder?` | `null` | Content shown when there are no tags. |
| `spacing` | `double?` | 6 | Gap between tags and lines. |
| `focusNode` | `FocusNode?` | `null` | Focus node of the list. |
| `autofocus` | `bool` | `false` | Focus the list when first built. |

### HeroTag

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `Object` | required | Key in the selection, disabled keys and removal. |
| `textValue` | `String?` | `label` | Text for typeahead and accessibility. |
| `label` | `String?` | `null` | The tag text. |
| `child` | `Widget?` | `null` | Content; replaces `label`. |
| `startContent` | `Widget?` | `null` | Icon or avatar before the label. |
| `builder` | `HeroTagWidgetBuilder?` | `null` | Builds the whole content from the tag state. |
| `removeButton` | `Widget?` | `HeroTagRemoveButton()` | Replaces the automatic remove button. |
| `isDisabled` | `bool` | `false` | Disables the tag. |
| `style` | `HeroTagStyle?` | `null` | Style overrides. |
| `semanticLabel` | `String?` | content text | Accessibility label. |

### HeroTagRemoveButton

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | close icon | Custom icon. |
| `semanticLabel` | `String` | `'Remove tag'` | Accessibility label. |

### HeroTagStyle

| Parameter | Type | Description |
| --- | --- | --- |
| `backgroundColor` | `WidgetStateProperty<Color?>?` | Fill per state. |
| `foregroundColor` | `WidgetStateProperty<Color?>?` | Text and icon color per state. |
| `side` | `WidgetStateProperty<BorderSide?>?` | Border per state. |
| `borderRadius` | `BorderRadiusGeometry?` | Corner radii. |
| `padding` | `EdgeInsetsGeometry?` | Inner padding. |
| `textStyle` | `TextStyle?` | Merged over the size's text style. |
| `iconSize` | `double?` | Icon size (12 by default). |
| `iconColor` | `WidgetStateProperty<Color?>?` | Icon color per state; defaults to the text color. |
| `gap` | `double?` | Gap between the parts (4 by default). |
| `shadows` | `List<BoxShadow>?` | Shadows behind the tag. |
