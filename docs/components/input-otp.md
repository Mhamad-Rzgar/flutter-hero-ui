# InputOTP

A one-time password input component for verification codes and secure authentication.

HeroUI docs: [heroui.com/en/docs/react/components/input-otp](https://heroui.com/en/docs/react/components/input-otp)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: <Widget>[
    const HeroLabel.text('Verify account'),
    HeroInputOTP(
      maxLength: 6,
      semanticLabel: 'Verify account',
      onCompleted: (String code) => verify(code),
      children: const <Widget>[
        HeroInputOTPGroup(
          children: <Widget>[
            HeroInputOTPSlot(index: 0),
            HeroInputOTPSlot(index: 1),
            HeroInputOTPSlot(index: 2),
          ],
        ),
        HeroInputOTPSeparator(),
        HeroInputOTPGroup(
          children: <Widget>[
            HeroInputOTPSlot(index: 3),
            HeroInputOTPSlot(index: 4),
            HeroInputOTPSlot(index: 5),
          ],
        ),
      ],
    ),
  ],
)
```

The same input from group sizes:

```dart
const HeroInputOTP(maxLength: 6, groupSizes: <int>[3, 3])
```

## Anatomy

```dart
HeroInputOTP(
  maxLength: 6,
  children: <Widget>[
    HeroInputOTPGroup(
      children: <Widget>[
        HeroInputOTPSlot(index: 0),
        HeroInputOTPSlot(index: 1),
        // ...rest of the slots
      ],
    ),
    HeroInputOTPSeparator(),
    HeroInputOTPGroup(
      children: <Widget>[
        HeroInputOTPSlot(index: 3),
        // ...rest of the slots
      ],
    ),
  ],
)
```

| Part | HeroUI | Look |
| --- | --- | --- |
| `HeroInputOTP` | `InputOTP` | Full-width row, 8 px gap, centred; one hidden text input edits the code. |
| `HeroInputOTPGroup` | `InputOTP.Group` | Row of slots, 8 px gap. |
| `HeroInputOTPSlot` | `InputOTP.Slot` | 38 × 40 field box (`rounded-field`, `--field-background`, field shadow); the character in `text-lg` semibold, `tracking -0.27px`. Slots shrink evenly when the row does not fit. |
| `HeroInputOTPSeparator` | `InputOTP.Separator` | 6 × 2 bar in `--separator`. |

Without `children` the input builds its groups from `groupSizes` (default:
one group of `maxLength` slots) with separators between them.

## States

- **Active** (the slot holding the caret or the selected character): 2 px
  focus ring and `--field-focus`; while empty it shows a 2 × 16 caret in
  `--field-placeholder` blinking every 1.2 s.
- **Filled**: `--field-focus` background, also while hovered. A new
  character fades in, rises 8 px and scales from 0.8 over 250 ms.
- **Hover** (mouse): `--field-hover` on empty, inactive slots.
- **Invalid**: 1 px `--danger` outline on every slot (a 2 px danger ring on
  the active one).
- **Disabled**: slots at the disabled opacity; the input cannot be focused.
- `secondary`: `--default` slots without shadow.
- Nothing animates under reduced motion; the caret stays visible.

## Behavior

Like the `input-otp` library HeroUI builds on:

- Typing fills the active slot and moves to the next; the code never exceeds
  `maxLength`.
- `pattern` (a regular expression source) rejects edits whose result does not
  match. `HeroInputOTP.regexpOnlyDigits`, `regexpOnlyChars` and
  `regexpOnlyDigitsAndChars` mirror `REGEXP_ONLY_DIGITS`, `REGEXP_ONLY_CHARS`
  and `REGEXP_ONLY_DIGITS_AND_CHARS`.
- Backspace removes the previous character. ArrowLeft / ArrowRight move the
  active slot; a filled active slot is selected and typing replaces it.
- Pasted text (Ctrl/Cmd+V or the context menu on long press) and autofilled
  one-time codes pass through `pasteTransformer` and fill the slots from the
  caret.
- Tapping the input focuses the first empty slot, or the last slot when the
  code is complete.
- `onCompleted` runs whenever an edit leaves `maxLength` characters; Enter
  calls `onSubmitted` and submits the enclosing `HeroForm`.
- The keyboard is numeric by default, or a text keyboard when `pattern`
  allows letters; `autofillHints` is `oneTimeCode`.

## Examples

### Variants and In Surface

```dart
const HeroInputOTP(
  maxLength: 6,
  groupSizes: <int>[3, 3],
  variant: HeroFieldVariant.secondary,
)
```

### Disabled state

```dart
const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: <Widget>[
    HeroLabel.text('Verify account', isDisabled: true),
    HeroDescription.text('Code verification is currently disabled'),
    HeroInputOTP(maxLength: 6, groupSizes: <int>[3, 3], isDisabled: true),
  ],
)
```

### Four digits

```dart
const HeroInputOTP(maxLength: 4, semanticLabel: 'Enter PIN')
```

### Controlled

```dart
HeroInputOTP(
  maxLength: 6,
  groupSizes: const <int>[3, 3],
  value: value,
  onChanged: (String v) => setState(() => value = v),
)
```

### On complete

```dart
HeroInputOTP(
  maxLength: 6,
  groupSizes: const <int>[3, 3],
  value: value,
  onCompleted: (String code) => setState(() => isComplete = true),
  onChanged: (String v) => setState(() {
    value = v;
    isComplete = false;
  }),
)
```

### Form example and validation

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) {
    if (data['code'] != '123456') setState(() => isInvalid = true);
  },
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: <Widget>[
      const HeroLabel.text('Verify account'),
      HeroInputOTP(
        maxLength: 6,
        groupSizes: const <int>[3, 3],
        name: 'code',
        isInvalid: isInvalid,
        value: value,
        onChanged: (String v) => setState(() {
          value = v;
          isInvalid = false;
        }),
      ),
      HeroFieldError.text(
        'Invalid code. Please try again.',
        isInvalid: isInvalid,
      ),
      HeroButton(
        type: HeroButtonType.submit,
        isDisabled: value.length != 6,
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

The input is a `FormField<String>`: `validator` (its error invalidates the
slots and feeds a `HeroFieldError` placed among its children), `onSaved`,
`autovalidateMode`, and `name` in the data a `HeroForm` submits.
`validationErrors` are shown by such a `HeroFieldError`.

### With pattern

```dart
const HeroInputOTP(
  maxLength: 6,
  groupSizes: <int>[3, 3],
  pattern: HeroInputOTP.regexpOnlyChars,
)
```

### Customization

`HeroInputOTPSlot.style` (a `HeroFieldStyle`) and
`HeroInputOTPSeparator.color` stand in for HeroUI's `className`:

```dart
final HeroFieldStyle slot = HeroFieldStyle(
  borderRadius: BorderRadius.circular(theme.radii.lg),
  backgroundColor: theme.colors.defaultColor,
  focusBackgroundColor: theme.colors.accentSoft, // active slot
);

HeroInputOTP(
  maxLength: 6,
  children: <Widget>[
    HeroInputOTPGroup(
      children: <Widget>[
        for (int i = 0; i < 3; i++) HeroInputOTPSlot(index: i, style: slot),
      ],
    ),
    HeroInputOTPSeparator(color: theme.colors.border),
    HeroInputOTPGroup(
      children: <Widget>[
        for (int i = 3; i < 6; i++) HeroInputOTPSlot(index: i, style: slot),
      ],
    ),
  ],
)
```

## Accessibility

- The input is one text field node: `semanticLabel` (the visible label's
  text) names it, its value is the code, and it reports the maximum and
  current length and the invalid state.
- The slots are presentation only.
- A disabled input (or one in a disabled `HeroFieldset`) is announced as
  disabled and leaves the focus order.

## API

### HeroInputOTP

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `maxLength` | `int` | required | Number of characters and slots. |
| `children` | `List<Widget>?` | – | Groups, separators and slots. |
| `groupSizes` | `List<int>?` | `[maxLength]` | Built groups when `children` is null. |
| `controller` | `TextEditingController?` | own | Controls the code. |
| `focusNode` | `FocusNode?` | own | Focus node of the hidden input. |
| `value` / `defaultValue` | `String?` | – | Controlled / initial code. |
| `onChanged` | `ValueChanged<String>?` | – | Called on every edit. |
| `onCompleted` | `ValueChanged<String>?` | – | Called when an edit fills every slot (`onComplete`). |
| `onSubmitted` | `ValueChanged<String>?` | – | Called on Enter; the form submits too. |
| `variant` | `HeroFieldVariant` | `primary` | Slot variant. |
| `isDisabled` | `bool` | `false` | Disabled look, not focusable. |
| `isInvalid` | `bool` | `false` | Invalid outline on the slots. |
| `validationErrors` | `List<String>?` | – | Messages for a `HeroFieldError` among the children. |
| `pattern` | `String?` | – | Regular expression the code must match. |
| `pasteTransformer` | `String Function(String)?` | – | Transforms pasted or autofilled text. |
| `placeholder` | `String?` | – | Characters shown in the slots while the code is empty. |
| `textAlign` | `TextAlign` | `start` | Alignment of the hidden input (no visible effect). |
| `keyboardType` | `TextInputType?` | number / text | On-screen keyboard (`inputMode`). |
| `autofocus` | `bool` | `false` | Focus when first built. |
| `name`, `validator`, `onSaved`, `autovalidateMode` | – | – | Form integration. |
| `spacing` | `double?` | `8` | Gap between groups, separators and slots. |
| `semanticLabel` | `String?` | – | Accessibility label. |

Constants: `HeroInputOTP.regexpOnlyDigits` (`^\d+$`),
`HeroInputOTP.regexpOnlyChars` (`^[a-zA-Z]+$`),
`HeroInputOTP.regexpOnlyDigitsAndChars` (`^[a-zA-Z0-9]+$`).

### HeroInputOTPGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The slots. |
| `spacing` | `double?` | input's | Gap between the slots. |

### HeroInputOTPSlot

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `index` | `int` | required | Zero-based position of the character. |
| `style` | `HeroFieldStyle?` | – | Radius, backgrounds (`focusBackgroundColor` when active), border, text style. |

### HeroInputOTPSeparator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color?` | `--separator` | Bar color. |
| `width` | `double?` | `6` | Bar width. |
