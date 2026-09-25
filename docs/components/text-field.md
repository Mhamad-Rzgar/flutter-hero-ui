# TextField

Composition-friendly text fields with labels, descriptions, and inline validation.

HeroUI docs: [heroui.com/en/docs/react/components/text-field](https://heroui.com/en/docs/react/components/text-field)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'email',
    type: HeroInputType.email,
    children: const <Widget>[
      HeroLabel.text('Email'),
      HeroInput(placeholder: 'Enter your email'),
    ],
  ),
)
```

The same field from the convenience parameters:

```dart
const HeroTextField(
  name: 'email',
  type: HeroInputType.email,
  label: 'Email',
  placeholder: 'Enter your email',
)
```

## Anatomy

```dart
HeroTextField(
  children: <Widget>[
    HeroLabel.text('...'),
    HeroInput(), // or HeroTextArea()
    HeroDescription.text('...'),
    HeroFieldError(),
  ],
)
```

`HeroTextField` combines a label, an input, a description and an error into a
single accessible field. For standalone inputs use [`HeroInput`](input.md) or
[`HeroTextArea`](text-area.md).

Without `children` (or `builder`) the field builds this layout from `label`,
`placeholder`, `description`, `errorMessage` and `isMultiline` (+ `rows`); the
error defaults to the validation messages.

The field shares its state with the parts through a `HeroFieldScope`: the
text controller and focus node (the input edits them; pressing the label
focuses the input), `variant`, `type`, and the disabled, read-only, required
and invalid states.

## Styles

| Part | Style |
| --- | --- |
| Root | column, 4 px gap (`gap-1`, `spacing`), parts stretched to one width |
| Width | shrink-wraps its widest part (an unsized input is 192 wide); fills a tight width; `fullWidth` fills the available width |
| Invalid | label `--danger`, input invalid outline, description hidden, error shown |
| Disabled | label and input at `--disabled-opacity`; the description keeps its look |
| Required | label asterisk |

Parts that render nothing (a hidden description, a valid field's error) take
no gap, like `display: none` in CSS.

## Variants

`variant` (`HeroFieldVariant.primary` by default, `secondary`) is passed to the
input or text area inside the field; use `secondary` on surfaces.

## Validation

| Source | Shown |
| --- | --- |
| `isInvalid: true` / `false` | always; overrides every other source (no message, so give `HeroFieldError` a text) |
| `validationErrors` (or the form's `validationErrors[name]`) | immediately; cleared once the user edits the field; a new list shows them again |
| `validator` | native: once committed; aria: in realtime |
| built-in constraints: `isRequired`, `type`, `minLength`, `pattern`, `min`, `max`, `step` (on the field or its input) | native only, once committed, after the validator |

`validationBehavior` (inherited from the `HeroForm`, `native` by default):

- **native**: the value is committed when the input loses focus after an
  edit, or when the form validates (submission); errors then stay until the
  next commit. Invalid fields block `HeroForm` submission. `autovalidateMode`
  shows errors without a commit.
- **aria**: errors update while the user types; built-in constraints only
  set semantics (`isRequired` is announced, not validated) and nothing blocks
  submission.

The field is a `FormField<String>` of the nearest `Form`: `validator`,
`onSaved` and `autovalidateMode` work as in Flutter, `Form.validate()`,
`save()` and `reset()` reach it, and inside a `HeroForm` its `name` keys the
submitted data.

## Examples

### In Surface

```dart
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      HeroTextField(
        name: 'name',
        variant: HeroFieldVariant.secondary,
        children: <Widget>[
          HeroLabel.text('Your name'),
          HeroInput(placeholder: 'John'),
          HeroDescription.text("We'll never share this with anyone else"),
        ],
      ),
      HeroTextField(
        name: 'bio',
        variant: HeroFieldVariant.secondary,
        children: <Widget>[
          HeroLabel.text('Bio'),
          HeroTextArea(placeholder: 'Tell us about yourself...', rows: 4),
          HeroDescription.text('Minimum 4 rows'),
        ],
      ),
    ],
  ),
)
```

### With description, required, disabled

```dart
const HeroTextField(
  name: 'fullName',
  isRequired: true,
  children: <Widget>[
    HeroLabel.text('Full Name'),
    HeroInput(placeholder: 'John Doe'),
    HeroDescription.text('This field is required'),
  ],
)

const HeroTextField(
  name: 'accountId',
  value: 'USR-12345',
  isDisabled: true,
  children: <Widget>[
    HeroLabel.text('Account ID'),
    HeroInput(placeholder: 'Auto-generated'),
    HeroDescription.text('This field cannot be edited'),
  ],
)
```

### Full width

```dart
SizedBox(
  width: 400,
  child: HeroTextField(
    name: 'password',
    type: HeroInputType.password,
    fullWidth: true,
    isInvalid: true,
    isRequired: true,
    children: const <Widget>[
      HeroLabel.text('Password'),
      HeroInput(),
      HeroFieldError.text('Password must be longer than 8 characters'),
    ],
  ),
)
```

### Validation

Use `isInvalid` together with `HeroFieldError` to surface validation messages.

```dart
final bool isUsernameInvalid = username.isNotEmpty && username.length < 3;

HeroTextField(
  name: 'username',
  isRequired: true,
  isInvalid: isUsernameInvalid,
  value: username,
  onChanged: (String value) => setState(() => username = value),
  children: <Widget>[
    const HeroLabel.text('Username'),
    const HeroInput(placeholder: 'jane_doe'),
    if (isUsernameInvalid)
      const HeroFieldError.text('Username must be at least 3 characters.')
    else
      const HeroDescription.text('Choose a unique username for your profile.'),
  ],
)
```

Or let the field validate:

```dart
HeroTextField(
  label: 'Username',
  isRequired: true,
  minLength: 3,
  validator: (String? value) =>
      value == 'admin' ? 'This username is reserved' : null,
)
```

### Controlled

```dart
HeroTextField(
  name: 'name',
  value: name,
  onChanged: (String value) => setState(() => name = value),
  children: <Widget>[
    const HeroLabel.text('Display name'),
    const HeroInput(placeholder: 'Jane'),
    HeroDescription.text('Characters: ${name.length}'),
  ],
)
```

A `TextEditingController` (and a `FocusNode`) can be passed instead.

### TextArea

```dart
const HeroTextField(
  name: 'message',
  children: <Widget>[
    HeroLabel.text('Message'),
    HeroTextArea(placeholder: 'Write your message here...', rows: 4),
    HeroDescription.text('Maximum 500 characters'),
  ],
)
```

### Input types

`type` reaches the input inside the field (keyboard, obscuring, validation);
constraints set on the input are validated by the field.

```dart
const HeroTextField(
  name: 'age',
  type: HeroInputType.number,
  children: <Widget>[
    HeroLabel.text('Age'),
    HeroInput(min: 0, max: 150, placeholder: '21'),
  ],
)
```

### Render function

```dart
HeroTextField(
  builder: (BuildContext context, HeroTextFieldState state) => <Widget>[
    HeroLabel.text(state.isFocusWithin ? 'Email (editing)' : 'Email'),
    const HeroInput(placeholder: 'Enter your email'),
  ],
)
```

### Customization

`spacing` changes the gap; the input takes a `HeroFieldStyle` (`inputStyle`
for the built input).

```dart
HeroTextField(
  spacing: theme.spacing(1.5), // gap-1.5
  children: <Widget>[
    const HeroLabel.text('Email'),
    HeroInput(
      placeholder: 'you@email.com',
      style: HeroFieldStyle(
        borderRadius: BorderRadius.circular(theme.radii.xl),
        borderWidth: theme.borderWidth,
        borderColor: theme.colors.border.withValues(alpha: 0.8),
        backgroundColor: theme.colors.surface,
        focusRingColor: theme.colors.muted.withValues(alpha: 0.3),
      ),
    ),
  ],
)
```

## Accessibility

- The input is one text-field node labelled by the label text (or
  `semanticLabel`) and described by the description, or by the error while
  invalid (`aria-describedby`); the label and description are not announced
  twice.
- Required, invalid, disabled and read-only states and the input type are
  reported on the input.
- The error is a live region, announced when it appears. A blocked
  `HeroForm` submission focuses the first invalid field.
- Pressing the label focuses the input; Tab reaches it with the keyboard.

## API

### HeroTextField

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | The parts of the field. |
| `builder` | `HeroTextFieldBuilder?` | – | Builds the parts from `HeroTextFieldState`; wins over `children`. |
| `label` | `String?` | – | Label of the built field. |
| `placeholder` | `String?` | – | Placeholder of the built input. |
| `description` | `String?` | – | Description of the built field. |
| `errorMessage` | `String?` | – | Error of the built field; defaults to the validation messages. |
| `isMultiline` | `bool` | `false` | Build a `HeroTextArea` instead of a `HeroInput`. |
| `rows` | `int` | `2` | Rows of the built text area. |
| `value` | `String?` | – | Current value (controlled). |
| `defaultValue` | `String?` | – | Initial value (uncontrolled). |
| `onChanged` | `ValueChanged<String>?` | – | Called when the user edits the value. |
| `onSubmitted` | `ValueChanged<String>?` | – | Keyboard submit of the built input. |
| `controller` | `TextEditingController?` | – | Controls the text. |
| `focusNode` | `FocusNode?` | – | Focus of the input. |
| `variant` | `HeroFieldVariant` | `primary` | Variant of the inputs inside. |
| `fullWidth` | `bool` | `false` | Fill the available width. |
| `spacing` | `double?` | `4` | Gap between the parts. |
| `inputStyle` | `HeroFieldStyle?` | – | Style of the built input. |
| `type` | `HeroInputType` | `text` | Input type (keyboard, obscuring, validation). |
| `isDisabled` | `bool` | `false` | Disable the field. |
| `isReadOnly` | `bool` | `false` | Selectable but not editable. |
| `isRequired` | `bool` | `false` | Label asterisk; native: required validation. |
| `isInvalid` | `bool?` | – | Overrides the displayed validation. |
| `name` | `String?` | – | Key in the `HeroForm` data and its server errors. |
| `validator` | `FormFieldValidator<String>?` | – | Custom validation (`validate`). |
| `validationBehavior` | `HeroValidationBehavior?` | form, then `native` | When errors show. |
| `validationErrors` | `List<String>?` | – | Server-side errors. |
| `onSaved` | `FormFieldSetter<String>?` | – | Called when the form saves. |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | Native: show errors without a commit. |
| `minLength` / `pattern` | `int?` / `RegExp?` | – | Built-in constraints. |
| `min` / `max` / `step` | `num?` | – | Number constraints. |
| `maxLength` | `int?` | – | Truncates the built input. |
| `validationMessages` | `HeroValidationMessages` | English | Built-in messages. |
| `autofocus` | `bool` | `false` | Focus the input on first build. |
| `autofillHints`, `inputFormatters`, `keyboardType`, `textInputAction`, `textCapitalization` | – | – | Options of the built input. |
| `semanticLabel` | `String?` | label text | Accessibility label (`aria-label`). |

### HeroTextFieldState

| Field | Type | Description |
| --- | --- | --- |
| `isDisabled` | `bool` | The field is disabled. |
| `isInvalid` | `bool` | The field shows as invalid. |
| `isReadOnly` | `bool` | The field is read-only. |
| `isRequired` | `bool` | The field is required. |
| `isFocusWithin` | `bool` | The input has focus. |
| `isFocusVisible` | `bool` | The focus is visible (keyboard). |
| `validation` | `HeroValidationResult` | The displayed validation. |

### HeroFieldLayout

The field column, reusable by other field roots.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | The parts. |
| `spacing` | `double` | required | Gap between rendered parts. |
| `fullWidth` | `bool` | `false` | Fill a bounded width. |

### HeroFieldScope (additions)

| Parameter | Type | Description |
| --- | --- | --- |
| `inputType` | `HeroInputType?` | The field's type, used by an input inside that keeps the default `text`. |
| `onInputConstraintsChanged` | `ValueSetter<HeroTextConstraints?>?` | Receives the constraints of the input inside, so the field root validates them. |
