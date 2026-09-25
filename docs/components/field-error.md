# FieldError

Displays validation error messages for form fields.

HeroUI docs: [heroui.com/en/docs/react/components/field-error](https://heroui.com/en/docs/react/components/field-error)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
final bool invalid = username.isNotEmpty && username.length < 3;

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[
    HeroLabel.text('Username', isInvalid: invalid),
    HeroInput(isInvalid: invalid, placeholder: 'Enter username'),
    HeroFieldError.text(
      'Username must be at least 3 characters',
      isInvalid: invalid,
    ),
  ],
)
```

The error is only rendered while its field is invalid. Inside a field root
(any `HeroFieldScope`) it follows the field's validation state; `isInvalid`
overrides it.

## Anatomy

A single widget, placed after the control (and description) of a field:

- `HeroFieldError.text('...')` shows a fixed message.
- `HeroFieldError(child: ...)` shows any content; text inherits the error style.
- `HeroFieldError(builder: (context, validation) => ...)` builds the content
  from the field's `HeroValidationResult` (HeroUI's render-function children).
- `HeroFieldError()` shows the field's validation messages joined with spaces
  (validator results, built-in constraint messages or server errors).

When there is nothing to show, nothing is rendered.

## Styles

| Part | Style |
| --- | --- |
| Text | `text-xs` (12/16), `--danger`, wraps and breaks long words |
| Padding | 4 px on both horizontal sides (`px-1`) |
| Visibility | instant; HeroUI declares opacity/height transitions but mounts the error already visible |

## Examples

### With dynamic messages

```dart
HeroFieldError(
  builder: (BuildContext context, HeroValidationResult validation) =>
      Text(validation.validationErrors.join(', ')),
)
```

### Multiple error messages

```dart
HeroFieldError(
  builder: (BuildContext context, HeroValidationResult validation) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (final String error in validation.validationErrors) Text(error),
    ],
  ),
)
```

### Customization

`style` is merged over the error style (like `className`).

```dart
const HeroFieldError.text(
  'Handle must be at least 3 characters',
  // font-medium
  style: TextStyle(fontWeight: HeroTypography.medium),
)
```

## Accessibility

- The error is a live region, so it is announced when it appears.
- It is read as text in the field; `HeroFieldScope.semanticHint` lets a field
  root also describe its control with the message (`aria-describedby`).

## API

### HeroFieldError

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | – | Content; text inherits the error style. |
| `builder` | `HeroFieldErrorBuilder?` | – | Builds the content from the field's validation; wins over `child`. |
| `data` (`HeroFieldError.text`) | `String` | required | Error text. |
| `isInvalid` | `bool?` | inherited | Whether the error is shown; null follows the field. |
| `style` | `TextStyle?` | – | Style merged over the error style. |

### HeroValidationResult

| Member | Type | Description |
| --- | --- | --- |
| `isInvalid` | `bool` | Whether the value is invalid. |
| `validationErrors` | `List<String>` | The validation messages. |
| `HeroValidationResult.invalid([errors])` | constructor | An invalid result. |
| `HeroValidationResult.valid` | constant | A valid result without messages. |

### HeroFieldScope (additions)

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `validationErrors` | `List<String>` | `[]` | Messages shown by `HeroFieldError` while the field is invalid. |
| `validation` (getter) | `HeroValidationResult` | – | `isInvalid` and `validationErrors` together. |
