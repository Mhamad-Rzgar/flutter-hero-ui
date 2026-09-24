# Input

Primitive single-line text input.

HeroUI docs: [heroui.com/en/docs/react/components/input](https://heroui.com/en/docs/react/components/input)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroInput(
  semanticLabel: 'Name',
  width: 256,
  placeholder: 'Enter your name',
)
```

For labels, descriptions and error messages around an input, compose it with
`HeroLabel` and `HeroDescription` (and, when it lands, `HeroTextField`).

## Anatomy

`HeroInput` is a single widget built from three reusable layers, which other
text fields (TextArea, TextField, InputGroup, SearchField, NumberField,
ComboBox) share:

| Layer | Widget | Role |
| --- | --- | --- |
| State | `HeroTextInputCore` | controller / focus ownership, controlled and uncontrolled value, `FormField<String>` registration, native validation |
| Look | `HeroFieldBox` | field background, border, field shadow, focus ring, invalid outline, disabled opacity and their transitions |
| Text | `HeroEditableText` | `EditableText` with the field text style, placeholder, iOS-style selection handles, token-styled context menu, gestures and semantics |

`HeroFieldScope` lets a field root (a TextField) share its variant, states,
controller and focus node with the input inside it.

## Styles

| Part | Value |
| --- | --- |
| Box | `rounded-field` (12), `px-3 py-2`, `--field-background`, `shadow-field`, border `--field-border-width` (0) |
| Text | `text-base` (16/24) below 640 px, `sm:text-sm` (14/20) from 640 px, `--field-foreground`; height 40 / 36 |
| Placeholder | `--field-placeholder` |
| Hover (mouse) | `--field-hover`, `--field-border-hover` |
| Focus | 2 px `--focus` ring with no offset, `--field-focus`, `--field-border-focus` |
| Invalid | 1 px `--danger` outline; 2 px `--danger` ring while focused |
| Disabled | `--disabled-opacity` (0.5), not focusable |
| Read-only | no visual change, focusable and selectable |
| Motion | background and border 150 ms `ease`, ring and shadow 150 ms `ease-out`; none under reduced motion |

The caret uses the text color (CSS `caret-color: auto`), selection handles use
`--focus` and the selection highlight is `--focus` at 20%.

## Variants

| Variant | Background (rest / hover / focus) | Shadow |
| --- | --- | --- |
| `HeroFieldVariant.primary` (default) | `--field-background` / `--field-hover` / `--field-focus` | `shadow-field` |
| `HeroFieldVariant.secondary` | `--default` / `--default-hover` / `--default` | none |

Use `secondary` on surfaces (`HeroSurface`, cards).

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 8,
  children: <Widget>[
    HeroInput(fullWidth: true, placeholder: 'Primary input'),
    HeroInput(
      fullWidth: true,
      placeholder: 'Secondary input',
      variant: HeroFieldVariant.secondary,
    ),
  ],
)
```

## Examples

### Full width

```dart
const SizedBox(
  width: 400,
  child: HeroInput(fullWidth: true, placeholder: 'Full width input'),
)
```

### Input types

`type` picks the keyboard, obscures passwords, filters number input and adds
the browser's type validation.

```dart
const HeroInput(placeholder: 'jane@example.com', type: HeroInputType.email)
const HeroInput(placeholder: '30', type: HeroInputType.number, min: 0)
const HeroInput(placeholder: '••••••••', type: HeroInputType.password)
```

### Controlled

```dart
HeroInput(
  semanticLabel: 'Domain',
  placeholder: 'domain',
  value: value,
  onChanged: (String next) => setState(() => value = next),
)
```

A `TextEditingController` works too (`controller:`), and `defaultValue`
makes the input uncontrolled.

### Forms

Every standalone input registers a `FormField<String>` with the nearest
`Form`. Native constraints are validated first, then `validator`.

```dart
Form(
  key: formKey,
  child: HeroInput(
    isRequired: true,
    type: HeroInputType.email,
    validator: (String? value) =>
        value!.endsWith('@example.com') ? null : 'Use your work email',
    onSaved: (String? value) => email = value,
  ),
)
```

Default messages follow the browser (`Please fill out this field.`, `Please
enter an email address.`, ...); pass a `HeroValidationMessages` subclass to
`validationMessages` to localize them.

### Customization

`HeroFieldStyle` is the counterpart of the `className` overrides of HeroUI's
examples. Like a Tailwind utility, a background or border color without a
state-specific value applies to every state.

```dart
final HeroThemeData theme = HeroTheme.of(context);
HeroInput(
  width: 256,
  placeholder: 'Search projects...',
  style: HeroFieldStyle(
    borderRadius: BorderRadius.circular(theme.radii.xl),
    borderWidth: theme.borderWidth,
    borderColor: theme.colors.border.withValues(alpha: 0.8),
    backgroundColor: theme.colors.defaultColor,
    textStyle: TextStyle(color: theme.colors.foreground),
    placeholderStyle: TextStyle(color: theme.colors.muted),
  ),
)
```

## Accessibility

- Exposed as a text field with `semanticLabel` (or the label of the enclosing
  field) as label and the placeholder as hint; reports enabled, read-only,
  obscured, required, invalid and the input type (email, URL, phone, search).
- Keyboard: Tab focuses the input; all of Flutter's text editing shortcuts
  work. The focus ring shows for pointer and keyboard focus, like a browser's
  `:focus` on inputs.
- Right-to-left layouts align text and padding to the start side.
- Text scaling grows the field height; nothing has a fixed height.
- Selection: iOS-style handles on touch platforms, mouse selection on
  desktop, and a context menu (cut, copy, paste, select all, ...) styled like
  a HeroUI popover.

## API

### HeroInput

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController?` | – | Controls the text. |
| `focusNode` | `FocusNode?` | – | Focus node. |
| `value` | `String?` | – | Controlled value. |
| `defaultValue` | `String?` | – | Uncontrolled initial value. |
| `onChanged` | `ValueChanged<String>?` | – | Called on every edit (`onChange`). |
| `onSubmitted` | `ValueChanged<String>?` | – | Called on the keyboard action / Enter. |
| `onEditingComplete` | `VoidCallback?` | – | Called when editing completes. |
| `onTap` | `VoidCallback?` | – | Called on each tap. |
| `placeholder` | `String?` | – | Placeholder text. |
| `type` | `HeroInputType` | `text` | `text`, `email`, `password`, `number`, `url`, `tel`, `search`. |
| `variant` | `HeroFieldVariant?` | `primary` | Visual variant (inherits from `HeroFieldScope`). |
| `fullWidth` | `bool` | `false` | Take the full available width. |
| `width` | `double?` | 192 | Explicit width (native `size=20` otherwise). |
| `isDisabled` | `bool` | `false` | Disables the input. |
| `isReadOnly` | `bool` | `false` | Selectable but not editable. |
| `isRequired` | `bool` | `false` | Requires a value (validation). |
| `isInvalid` | `bool` | `false` | Forces the invalid look. |
| `name` | `String?` | – | Name of the value in a form. |
| `autofillHints` | `Iterable<String>?` | – | `autoComplete`. |
| `maxLength` | `int?` | – | Maximum characters (truncates input). |
| `minLength` | `int?` | – | Minimum characters (validation). |
| `pattern` | `RegExp?` | – | Pattern the whole value must match. |
| `min` / `max` / `step` | `num?` | – | Number range and step (validation). |
| `validator` | `FormFieldValidator<String>?` | – | Extra validation. |
| `onSaved` | `FormFieldSetter<String>?` | – | Called when the form is saved. |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | When to validate. |
| `validationMessages` | `HeroValidationMessages` | English | Native validation messages. |
| `autofocus` | `bool` | `false` | Focus when first built. |
| `keyboardType` | `TextInputType?` | from `type` | Keyboard. |
| `textInputAction` | `TextInputAction?` | from `type` | Keyboard action. |
| `textCapitalization` | `TextCapitalization` | `none` | Capitalization. |
| `obscureText` | `bool?` | from `type` | Obscure the text. |
| `autocorrect` | `bool?` | from `type` | Autocorrect and suggestions. |
| `inputFormatters` | `List<TextInputFormatter>?` | – | Extra formatters. |
| `textAlign` | `TextAlign` | `start` | Text alignment. |
| `semanticLabel` | `String?` | – | Accessibility label (`aria-label`). |
| `style` | `HeroFieldStyle?` | – | Visual overrides. |

### HeroFieldStyle

| Parameter | Type | Description |
| --- | --- | --- |
| `backgroundColor` / `hoverBackgroundColor` / `focusBackgroundColor` | `Color?` | Backgrounds per state. |
| `borderColor` / `hoverBorderColor` / `focusBorderColor` | `Color?` | Border colors per state. |
| `borderWidth` | `double?` | Border width (`--field-border-width`). |
| `borderRadius` | `BorderRadiusGeometry?` | Corner radius (`rounded-field`). |
| `shadow` | `HeroShadow?` | Resting shadow (a `ring-1` is a shadow with spread 1). |
| `focusRingColor` / `focusRingWidth` | `Color?` / `double?` | Focus ring. |
| `padding` | `EdgeInsetsGeometry?` | Inner padding. |
| `textStyle` / `placeholderStyle` | `TextStyle?` | Text styles merged over the defaults. |
| `cursorColor` / `selectionColor` | `Color?` | Caret and selection colors. |

### HeroFieldBox

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Field content. |
| `variant` | `HeroFieldVariant` | `primary` | Variant. |
| `isHovered` | `bool` | `false` | Forces the hover look (mouse hover is tracked too). |
| `isFocused` | `bool` | `false` | Focus look and ring. |
| `isInvalid` | `bool` | `false` | Invalid outline / ring. |
| `isDisabled` | `bool` | `false` | Disabled opacity. |
| `style` | `HeroFieldStyle?` | – | Overrides. |
| `padding` | `EdgeInsetsGeometry` | `zero` | Padding around `child`. |
| `mouseCursor` | `MouseCursor` | `defer` | Cursor over the box. |

### HeroEditableText

The editable text core. Takes a required `controller` and `focusNode` plus
`placeholder`, `style`, `placeholderStyle`, `cursorColor`, `selectionColor`,
`padding`, `textAlign`, `keyboardType`, `textInputAction`,
`textCapitalization`, `obscureText`, `obscuringCharacter`, `autocorrect`,
`enableSuggestions`, `maxLines` (1), `minLines`, `expands`, `isReadOnly`,
`isDisabled`, `isInvalid`, `isRequired`, `autofocus`, `inputFormatters`,
`autofillHints`, `onChanged`, `onEditingComplete`, `onSubmitted`, `onTap`,
`onTapOutside`, `scrollController`, `scrollPhysics`,
`enableInteractiveSelection`, `selectionControls`
(`HeroTextSelectionControls.adaptive()`), `contextMenuBuilder`
(`HeroTextSelectionToolbar.contextMenuBuilder`), `semanticLabel`,
`semanticHint` and `semanticsInputType`.

### HeroTextInputCore

Accepts every `HeroInput` parameter plus `height`, `minHeight`, `maxLines`,
`minLines`, `decorated` (paint the `HeroFieldBox`, default `true`),
`onFocusChanged`, `scrollController` and `debugLabel`.

### HeroFieldScope

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `HeroFieldVariant?` | – | Variant inherited by inputs. |
| `isDisabled` / `isInvalid` / `isRequired` / `isReadOnly` | `bool` | `false` | Field states. |
| `showRequiredIndicator` | `bool?` | `isRequired` | Whether labels show the asterisk. |
| `hideDescriptionWhenInvalid` | `bool` | `false` | Hide descriptions while invalid. |
| `fullWidth` | `bool` | `false` | Inputs take the full width. |
| `focusNode` | `FocusNode?` | – | The control's focus node (labels focus it). |
| `controller` | `TextEditingController?` | – | The root's controller; the root then owns the form state. |
| `onLabelPressed` | `VoidCallback?` | – | Action of a pressed label. |
| `semanticLabel` / `semanticHint` | `String?` | – | Accessibility label and hint of the control. |

### Other

- `HeroFieldVariant { primary, secondary }`
- `HeroInputType { text, email, password, number, url, tel, search }`
- `HeroTextConstraints` – native constraint validation (`validate(value)`).
- `HeroValidationMessages` – overridable validation messages.
- `HeroFieldMetrics` – `isSmUp`, `fontSize`, `textStyle`, `placeholderStyle`,
  `padding`, `defaultWidth`, `selectionColor`.
- `HeroTextSelectionControls` – iOS-style handles in `--focus`.
- `HeroTextSelectionToolbar` – the context menu.
