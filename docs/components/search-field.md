# SearchField

Search input field with clear button and search icon.

HeroUI docs: [heroui.com/en/docs/react/components/search-field](https://heroui.com/en/docs/react/components/search-field)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroSearchField(
  name: 'search',
  children: <Widget>[
    HeroLabel.text('Search'),
    HeroSearchFieldGroup(
      children: <Widget>[
        HeroSearchFieldSearchIcon(),
        HeroSearchFieldInput(placeholder: 'Search...', width: 280),
        HeroSearchFieldClearButton(),
      ],
    ),
  ],
)
```

The same field from the convenience parameters:

```dart
const HeroSearchField(
  name: 'search',
  label: 'Search',
  placeholder: 'Search...',
  inputWidth: 280,
)
```

## Anatomy

```dart
HeroSearchField(
  children: <Widget>[
    HeroLabel.text('...'),
    HeroSearchFieldGroup(
      children: <Widget>[
        HeroSearchFieldSearchIcon(),
        HeroSearchFieldInput(),
        HeroSearchFieldClearButton(),
      ],
    ),
    HeroDescription.text('...'),
    HeroFieldError(),
  ],
)
```

| Part | HeroUI | Look |
| --- | --- | --- |
| `HeroSearchField` | `SearchField` | Column, 4 px gap; description hidden while invalid. |
| `HeroSearchFieldGroup` | `SearchField.Group` | 36 px (`h-9`) field box: `rounded-field`, `--field-background`, field shadow; hover background, focus ring, invalid outline, disabled opacity. |
| `HeroSearchFieldSearchIcon` | `SearchField.SearchIcon` | 16 px magnifier in `--field-placeholder`, 12 px from the start. |
| `HeroSearchFieldInput` | `SearchField.Input` | `px-3`, `ps-2` after the icon, `pe-2` before the clear button; `text-base` (`text-sm` from 640 px), centred in the 36 px group. |
| `HeroSearchFieldClearButton` | `SearchField.ClearButton` | A 20 px `HeroCloseButton` with a 12 px icon, 8 px from the end; invisible while empty. |

Without `children` (or `builder`) the field builds this layout from `label`,
`placeholder`, `description`, `errorMessage`, `searchIcon`, `clearIcon`,
`showSearchIcon`, `showClearButton` and `inputWidth`.

## Behavior

- **Enter** (or the keyboard's search action) calls `onSubmitted` with the
  value and submits the enclosing `HeroForm`.
- **Escape** clears a non-empty value (`onChanged('')`, then `onClear`); on an
  empty field it is left to the ancestors, so a page shortcut can take it.
- The **clear button** clears the value and keeps the focus in the input. It
  is not in the focus order, is hidden and inert while the value is empty
  (keeping its space), and is disabled when the field is disabled or
  read-only.
- Pressing the group outside the input (for example the search icon) focuses
  the input.
- Value, validation and form behavior are those of
  [`HeroTextField`](text-field.md): `value`/`onChanged`, `defaultValue` or a
  `controller`; `validator`, `isRequired`, `validationBehavior`,
  `validationErrors` and `isInvalid`; `name`, `onSaved` and `HeroForm`
  submission.

## Variants

| `variant` | Look |
| --- | --- |
| `HeroFieldVariant.primary` (default) | `--field-background` with the field shadow. |
| `HeroFieldVariant.secondary` | `--default` background, no shadow; for surfaces. |

## Examples

### In Surface

```dart
HeroSurface(
  width: 384,
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const HeroSearchField(
    name: 'search',
    variant: HeroFieldVariant.secondary,
    label: 'Search',
    placeholder: 'Search...',
    description: 'Enter keywords to search',
    fullWidth: true,
  ),
)
```

### With description, required, disabled, full width

```dart
const HeroSearchField(
  name: 'search-query',
  isRequired: true, // or isDisabled: true, fullWidth: true
  label: 'Search query',
  placeholder: 'Enter search query...',
  description: 'Minimum 3 characters required',
  inputWidth: 280,
)
```

### Validation

```dart
const HeroSearchField(
  name: 'search',
  isInvalid: true,
  isRequired: true,
  value: 'ab',
  label: 'Search',
  errorMessage: 'Search query must be at least 3 characters',
  inputWidth: 280,
)
```

### Controlled

```dart
HeroSearchField(
  name: 'search',
  value: value,
  onChanged: (String v) => setState(() => value = v),
  label: 'Search',
  description: 'Current value: ${value.isEmpty ? '(empty)' : value}',
  inputWidth: 280,
)
```

### Form example

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => search(data['search']),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      HeroSearchField(
        name: 'search',
        isRequired: true,
        isInvalid: value.isNotEmpty && value.length < 3,
        value: value,
        onChanged: (String v) => setState(() => value = v),
        fullWidth: true,
        label: 'Search products',
        description: 'Enter at least 3 characters to search',
        errorMessage: 'Search query must be at least 3 characters',
      ),
      HeroButton(
        type: HeroButtonType.submit,
        fullWidth: true,
        isDisabled: value.length < 3,
        isPending: isSubmitting,
        child: Text(isSubmitting ? 'Searching...' : 'Search'),
      ),
    ],
  ),
)
```

### Custom icons

```dart
const HeroSearchFieldGroup(
  children: <Widget>[
    HeroSearchFieldSearchIcon(child: HeroIcon(HeroIcons.funnel)),
    HeroSearchFieldInput(placeholder: 'Search...'),
    HeroSearchFieldClearButton(
      child: HeroIcon(HeroIcons.circleXmarkFill, size: 16),
    ),
  ],
)
```

### Keyboard shortcut

A page-wide Shift+S handler focuses the field; Escape first clears the value,
then reaches an ancestor handler that leaves the field:

```dart
WidgetsBinding.instance.keyboard.addHandler((KeyEvent event) {
  if (event.character == 'S' && !focusNode.hasFocus) {
    focusNode.requestFocus();
    return true;
  }
  return false;
});

Focus(
  canRequestFocus: false,
  onKeyEvent: (FocusNode node, KeyEvent event) {
    if (event.logicalKey.keyLabel == 'Escape' && focusNode.hasFocus) {
      focusNode.unfocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  },
  child: HeroSearchField(focusNode: focusNode, label: 'Search'),
)
```

### Render function

React renders the field through a custom element (`render`). In Flutter the
field is composed like any widget; `builder` receives `HeroSearchFieldState`
(the text field states plus `value` and `isEmpty`) to build the parts.

### Customization

```dart
HeroSearchField(
  variant: HeroFieldVariant.secondary,
  children: <Widget>[
    const HeroLabel.text('Search docs'),
    HeroSearchFieldGroup(
      style: HeroFieldStyle(
        borderRadius: BorderRadius.circular(theme.radii.xl),
        backgroundColor: theme.colors.defaultColor,
      ),
      children: <Widget>[
        HeroSearchFieldSearchIcon(color: theme.colors.muted),
        HeroSearchFieldInput(
          placeholder: 'Components, guides...',
          style: HeroFieldStyle(
            placeholderStyle: TextStyle(color: theme.colors.muted),
          ),
        ),
        HeroSearchFieldClearButton(
          style: HeroButtonStyle(
            foregroundColor: WidgetStatePropertyAll<Color?>(theme.colors.muted),
          ),
        ),
      ],
    ),
  ],
)
```

## Accessibility

- The input is a single text field node with the search input type,
  labelled by the label and described by the description or the error.
- The clear button is announced as "Clear search", is not in the focus order
  (like React Aria's `excludeFromTabOrder`) and is left out of the semantics
  tree while the field is empty.
- The search icon is decorative.
- Escape clears the field before it closes enclosing overlays.

## API

### HeroSearchField

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | Parts of the field. |
| `builder` | `HeroSearchFieldBuilder?` | – | Builds the parts from `HeroSearchFieldState`. |
| `label` / `placeholder` / `description` / `errorMessage` | `String?` | – | Convenience texts of the built field. |
| `searchIcon` / `clearIcon` | `Widget?` | magnifier / close | Icons of the built group. |
| `showSearchIcon` / `showClearButton` | `bool` | `true` | Parts of the built group. |
| `inputWidth` | `double?` | `192` | Width of the built input. |
| `controller` | `TextEditingController?` | own | Text controller. |
| `focusNode` | `FocusNode?` | own | Focus node of the input. |
| `value` / `defaultValue` | `String?` | – | Controlled / initial value. |
| `onChanged` | `ValueChanged<String>?` | – | Called on edits and clears. |
| `onSubmitted` | `ValueChanged<String>?` | – | Called on Enter (`onSubmit`). |
| `onClear` | `VoidCallback?` | – | Called when Escape or the clear button clears the value. |
| `variant` | `HeroFieldVariant` | `primary` | Visual variant. |
| `fullWidth` | `bool` | `false` | Fill the available width. |
| `spacing` | `double?` | `4` | Gap between the parts. |
| `isDisabled` / `isReadOnly` / `isRequired` | `bool` | `false` | States. |
| `isInvalid` | `bool?` | – | Overrides the displayed validation. |
| `name`, `validator`, `validationBehavior`, `validationErrors`, `onSaved`, `autovalidateMode` | – | – | Form integration (as `HeroTextField`). |
| `minLength` / `maxLength` / `pattern` | – | – | Built-in constraints. |
| `validationMessages` | `HeroValidationMessages` | English | Built-in validation messages. |
| `autofocus` | `bool` | `false` | Focus when first built. |
| `semanticLabel` | `String?` | label text | Accessibility label. |

### HeroSearchFieldState

The `HeroTextFieldState` fields (`isDisabled`, `isInvalid`, `isReadOnly`,
`isRequired`, `isFocusWithin`, `isFocusVisible`, `validation`) plus `value`
and `isEmpty`.

### HeroSearchFieldGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Icon, input and clear button. |
| `style` | `HeroFieldStyle?` | – | Box overrides. |

### HeroSearchFieldSearchIcon

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `HeroIcon(HeroIcons.search)` | The icon. |
| `color` | `Color?` | `--field-placeholder` | Icon color. |

### HeroSearchFieldInput

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `placeholder` | `String?` | – | Text shown while empty. |
| `width` | `double?` | `192` | Width when the field shrink-wraps. |
| `maxLength` | `int?` | – | Maximum number of characters. |
| `textAlign` | `TextAlign` | `start` | Text alignment. |
| `style` | `HeroFieldStyle?` | – | Text, placeholder, caret and padding overrides. |

### HeroSearchFieldClearButton

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | close icon | The icon. |
| `style` | `HeroButtonStyle?` | 20 px, 12 px icon | Close button overrides. |
| `semanticLabel` | `String` | `'Clear search'` | Accessibility label. |
