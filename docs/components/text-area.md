# TextArea

Primitive multiline text input.

HeroUI docs: [heroui.com/en/docs/react/components/text-area](https://heroui.com/en/docs/react/components/text-area)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroTextArea(
  semanticLabel: 'Quick project update',
  width: 384,
  height: 128,
  placeholder: 'Share a quick project update...',
)
```

For labels, descriptions and errors, compose it with `HeroLabel` and
`HeroDescription` (and, when it lands, `HeroTextField`).

## Anatomy

A single widget built on the same layers as `HeroInput`: `HeroTextInputCore`
(state, value, form), `HeroFieldBox` (look) and `HeroEditableText` (editable
text), plus an optional resize grip.

## Styles

Identical to Input, plus a minimum height.

| Part | Value |
| --- | --- |
| Box | `rounded-field` (12), `px-3 py-2`, `--field-background`, `shadow-field`, `min-height: 38px` |
| Text | `text-base` (16/24) below 640 px, `sm:text-sm` (14/20) from 640 px |
| Height | `rows × line height + 16` (2 rows by default), or an explicit `height` |
| Hover / focus / invalid / disabled | as Input (field hover, 2 px focus ring with no offset, danger outline, 0.5 opacity) |
| Resize grip | two `--muted` strokes at the bottom-end corner when `resize` is `vertical` |

## Variants

| Variant | Background (rest / hover / focus) | Shadow |
| --- | --- | --- |
| `HeroFieldVariant.primary` (default) | `--field-background` / `--field-hover` / `--field-focus` | `shadow-field` |
| `HeroFieldVariant.secondary` | `--default` / `--default-hover` / `--default` | none |

## Examples

### Full width

```dart
const SizedBox(
  width: 400,
  child: HeroTextArea(fullWidth: true, placeholder: 'Full width textarea'),
)
```

### Controlled

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 8,
  children: <Widget>[
    HeroTextArea(
      semanticLabel: 'Announcement',
      placeholder: 'Compose an announcement...',
      value: value,
      onChanged: (String next) => setState(() => value = next),
    ),
    HeroDescription.text('Characters: ${value.length} / 280'),
  ],
)
```

### Rows and resizing

```dart
HeroTextArea(rows: 3, placeholder: "This week's highlights...")
HeroTextArea(
  rows: 6,
  resize: HeroTextAreaResize.vertical,
  placeholder: 'Write out the full meeting notes...',
)
```

Dragging the grip changes the height (never below 38 px); longer text scrolls
inside the field.

### Customization

```dart
HeroTextArea(
  fullWidth: true,
  height: 112,
  placeholder: 'Add a note...',
  style: HeroFieldStyle(
    borderRadius: BorderRadius.circular(theme.radii.xl),
    borderWidth: theme.borderWidth,
    borderColor: theme.colors.border.withValues(alpha: 0.8),
    backgroundColor: theme.colors.surface,
    focusRingColor: theme.colors.muted.withValues(alpha: 0.3),
    textStyle: theme.typography.sm,
  ),
)
```

## Accessibility

- A multi-line text field with `semanticLabel` as label and the placeholder
  as hint; reports enabled, read-only, required and invalid.
- Enter inserts a new line; Tab moves focus.
- Right-to-left layouts align the text to the right and put the grip in the
  bottom-left corner.
- Text scaling grows the rows.

## API

### HeroTextArea

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController?` | – | Controls the text. |
| `focusNode` | `FocusNode?` | – | Focus node. |
| `value` | `String?` | – | Controlled value. |
| `defaultValue` | `String?` | – | Uncontrolled initial value. |
| `onChanged` | `ValueChanged<String>?` | – | Called on every edit. |
| `onTap` | `VoidCallback?` | – | Called on each tap. |
| `placeholder` | `String?` | – | Placeholder text. |
| `rows` | `int` | `2` | Visible lines. |
| `cols` | `int?` | – | Visible width in average characters. |
| `variant` | `HeroFieldVariant?` | `primary` | Visual variant (inherits from `HeroFieldScope`). |
| `fullWidth` | `bool` | `false` | Take the full available width. |
| `width` | `double?` | 192 | Explicit width. |
| `height` | `double?` | – | Explicit height (overrides `rows`). |
| `resize` | `HeroTextAreaResize` | `none` | `none` or `vertical`. |
| `isDisabled` | `bool` | `false` | Disables the text area. |
| `isReadOnly` | `bool` | `false` | Selectable but not editable. |
| `isRequired` | `bool` | `false` | Requires a value (validation). |
| `isInvalid` | `bool` | `false` | Forces the invalid look. |
| `name` | `String?` | – | Name of the value in a form. |
| `autofillHints` | `Iterable<String>?` | – | `autoComplete`. |
| `maxLength` | `int?` | – | Maximum characters (truncates input). |
| `minLength` | `int?` | – | Minimum characters (validation). |
| `validator` | `FormFieldValidator<String>?` | – | Extra validation. |
| `onSaved` | `FormFieldSetter<String>?` | – | Called when the form is saved. |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | When to validate. |
| `validationMessages` | `HeroValidationMessages` | English | Native validation messages. |
| `autofocus` | `bool` | `false` | Focus when first built. |
| `textCapitalization` | `TextCapitalization` | `sentences` | Capitalization. |
| `autocorrect` | `bool?` | `true` | Autocorrect and suggestions. |
| `inputFormatters` | `List<TextInputFormatter>?` | – | Extra formatters. |
| `textAlign` | `TextAlign` | `start` | Text alignment. |
| `semanticLabel` | `String?` | – | Accessibility label. |
| `style` | `HeroFieldStyle?` | – | Visual overrides (see Input). |
| `scrollController` | `ScrollController?` | – | Scroll controller of the text. |

`wrap` has no equivalent: Flutter always soft-wraps.
