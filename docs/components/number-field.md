# NumberField

Number input with increment and decrement buttons, validation and internationalized formatting.

HeroUI docs: [heroui.com/en/docs/react/components/number-field](https://heroui.com/en/docs/react/components/number-field)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroNumberField(
  name: 'width',
  defaultValue: 1024,
  minValue: 0,
  children: <Widget>[
    HeroLabel.text('Width'),
    HeroNumberFieldGroup(
      children: <Widget>[
        HeroNumberFieldDecrementButton(),
        HeroNumberFieldInput(width: 120),
        HeroNumberFieldIncrementButton(),
      ],
    ),
  ],
)
```

The same field from the convenience parameters:

```dart
const HeroNumberField(
  name: 'width',
  label: 'Width',
  defaultValue: 1024,
  minValue: 0,
  inputWidth: 120,
)
```

## Anatomy

```dart
HeroNumberField(
  children: <Widget>[
    HeroLabel.text('...'),
    HeroNumberFieldGroup(
      children: <Widget>[
        HeroNumberFieldDecrementButton(),
        HeroNumberFieldInput(),
        HeroNumberFieldIncrementButton(),
      ],
    ),
    HeroDescription.text('...'),
    HeroFieldError(),
  ],
)
```

| Part | HeroUI | Look |
| --- | --- | --- |
| `HeroNumberField` | `NumberField` | Column, 4 px gap; description hidden while invalid. |
| `HeroNumberFieldGroup` | `NumberField.Group` | 36 px (`h-9`) field box: `rounded-field`, `--field-background`, field shadow; hover background, focus ring, invalid outline, disabled opacity; clips its parts to its corners. |
| `HeroNumberFieldInput` | `NumberField.Input` | `px-3`, tabular figures, `text-base` (`text-sm` from 640 px), centred in the group. |
| `HeroNumberFieldDecrementButton` | `NumberField.DecrementButton` | 40 px wide, full height, 16 px minus icon in `--field-foreground`, 1 px end divider in `--field-placeholder` at 15%. Pressed: `--field-foreground` at 10% and scale 0.97. Disabled at the minimum. |
| `HeroNumberFieldIncrementButton` | `NumberField.IncrementButton` | The same with a plus icon and a start divider; disabled at the maximum. |

Without `children` (or `builder`) the field builds this layout from `label`,
`placeholder`, `description`, `errorMessage`, `showStepper` and `inputWidth`.

## Behavior

- **Typing** accepts only text that can become a number in the field's format
  (digits, the locale's separators, the format's symbols, and a minus sign
  when `minValue` allows negatives).
- **Commit** happens when the input loses focus or on Enter: the text is
  parsed, clamped to `minValue`..`maxValue`, snapped to `step` (when set) and
  reformatted, and `onChanged` receives the new value (null when emptied).
  `onChanged` does not fire on every keystroke. Enter also submits the
  enclosing `HeroForm`.
- **Stepping**: the buttons, ArrowUp / ArrowDown, PageUp / PageDown and the
  mouse wheel (while focused, unless `isWheelDisabled`) step by `step` (1, or
  0.01 for percentages) and commit at once; Home / End go to `minValue` /
  `maxValue`. Holding a button steps immediately, then repeats after 400 ms
  every 60 ms. From an empty field incrementing starts at `minValue` (or 0)
  and decrementing at `maxValue` (or 0).
- The buttons are not in the focus order; they are disabled at the limits and
  while the field is disabled or read-only.
- A controlled value outside the range is shown as is.

## Formatting

`formatOptions` is the counterpart of `Intl.NumberFormatOptions`:

| Option | Values | Example |
| --- | --- | --- |
| `style` | `decimal` (default), `currency`, `percent`, `unit` | – |
| `currency` | ISO 4217 code | `'EUR'` → "€99.00" |
| `currencySign` | `standard`, `accounting` | accounting: -99 → "(€99.00)" |
| `currencyDisplay` | `symbol`, `code` | code: "EUR 99.00" |
| `unit` / `unitDisplay` | `'kilogram'`, ... / `short`, `long`, `narrow` | "1,000 kg", "1,000 kilograms", "1,000kg" |
| `minimumFractionDigits` / `maximumFractionDigits` | `int` | 2 / 2: "1,234.56" |
| `useGrouping` | `bool` | false: "1024" |

Percent values are fractions (0.5 shows as "50%"). The field formats in its
`locale` (default: the app locale), with that locale's digits, separators and
currency patterns; unit names are English. An intl `NumberFormat` can be
passed as `numberFormat` instead.

## Variants

| `variant` | Look |
| --- | --- |
| `HeroFieldVariant.primary` (default) | `--field-background` with the field shadow. |
| `HeroFieldVariant.secondary` | `--default` background, no shadow; for surfaces. |

## Examples

### With format options

```dart
const HeroNumberField(
  name: 'currency-eur',
  label: 'Currency (EUR - Accounting)',
  defaultValue: 99,
  minValue: 0,
  formatOptions: HeroNumberFormatOptions(
    style: HeroNumberFormatStyle.currency,
    currency: 'EUR',
    currencySign: HeroCurrencySign.accounting,
  ),
)

const HeroNumberField(
  name: 'percentage',
  label: 'Percentage',
  defaultValue: 0.5,
  minValue: 0,
  maxValue: 1,
  step: 0.01,
  formatOptions: HeroNumberFormatOptions(style: HeroNumberFormatStyle.percent),
)
```

### With step

```dart
const HeroNumberField(
  label: 'Step: 5',
  defaultValue: 0,
  minValue: 0,
  maxValue: 100,
  step: 5,
)
```

### Controlled

```dart
HeroNumberField(
  label: 'Width',
  value: value,
  minValue: 0,
  onChanged: (double? v) => setState(() => value = v ?? 0),
  description: 'Current value: ${value.round()}',
)
```

Pass `double.nan` as `value` for an empty controlled field.

### Validation and forms

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => order(data['quantity']),
  child: HeroNumberField(
    name: 'quantity',
    isRequired: true,
    label: 'Order quantity',
    minValue: 1,
    maxValue: 5,
    validator: (double? value) =>
        value != null && value > 3 ? 'Only 3 items left in stock' : null,
  ),
)
```

The validator receives the committed number; a step validates at once, typed
text on commit. `HeroForm` submits the number (a `double`, or null) under
`name`.

### Custom icons and chevrons

```dart
HeroNumberFieldGroup(
  children: <Widget>[
    const HeroNumberFieldInput(),
    DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(
            color: theme.colors.fieldPlaceholder.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: HeroNumberFieldIncrementButton(
              width: theme.spacing(6),
              showDivider: false,
              child: const HeroIcon(HeroIcons.chevronUp, size: 11),
            ),
          ),
          Expanded(
            child: HeroNumberFieldDecrementButton(
              width: theme.spacing(6),
              showDivider: false,
              child: const HeroIcon(HeroIcons.chevronDown, size: 11),
            ),
          ),
        ],
      ),
    ),
  ],
)
```

### Customization

```dart
HeroNumberField(
  defaultValue: 2,
  minValue: 1,
  variant: HeroFieldVariant.secondary,
  children: <Widget>[
    const HeroLabel.text('Guests'),
    HeroNumberFieldGroup(
      style: HeroFieldStyle(
        borderRadius: BorderRadius.circular(theme.radii.xl),
        backgroundColor: theme.colors.defaultColor,
      ),
      children: <Widget>[
        HeroNumberFieldDecrementButton(style: mutedButtons),
        const HeroNumberFieldInput(textAlign: TextAlign.center),
        HeroNumberFieldIncrementButton(style: mutedButtons),
      ],
    ),
  ],
)
```

`builder` receives `HeroNumberFieldState` (the text field states plus
`value`, `minValue`, `maxValue` and `step`), like HeroUI's render-function
children.

## Accessibility

- The input is one text field node labelled by the label and described by
  the description or error. It is adjustable: assistive technologies can
  increase and decrease it and hear the value it would take (React Aria's
  spin button).
- The buttons are announced as "Increase" and "Decrease"
  (`incrementLabel` / `decrementLabel`) and are left out of the focus order.
- The on-screen keyboard is numeric, with a sign key when negatives are
  allowed and a decimal key when fractions are shown.

## API

### HeroNumberField

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | Parts of the field. |
| `builder` | `HeroNumberFieldBuilder?` | – | Builds the parts from `HeroNumberFieldState`. |
| `label` / `placeholder` / `description` / `errorMessage` | `String?` | – | Convenience texts of the built field. |
| `showStepper` | `bool` | `true` | Built group has the buttons. |
| `inputWidth` | `double?` | `192` | Width of the built input. |
| `value` | `double?` | – | Controlled value (NaN: empty). |
| `defaultValue` | `double?` | – | Initial value (uncontrolled). |
| `onChanged` | `ValueChanged<double?>?` | – | Called with each committed value. |
| `minValue` / `maxValue` | `double?` | – | Limits; committed values are clamped. |
| `step` | `double?` | 1 (0.01 for percent) | Step; committed values snap to an explicit step. |
| `formatOptions` | `HeroNumberFormatOptions?` | decimal | Formatting (`Intl.NumberFormatOptions`). |
| `numberFormat` | `NumberFormat?` | – | An intl format instead of `formatOptions`. |
| `locale` | `Locale?` | app locale | Formatting locale. |
| `variant` | `HeroFieldVariant` | `primary` | Visual variant. |
| `fullWidth` | `bool` | `false` | Fill the available width. |
| `spacing` | `double?` | `4` | Gap between the parts. |
| `focusNode` | `FocusNode?` | own | Focus node of the input. |
| `isDisabled` / `isReadOnly` / `isRequired` | `bool` | `false` | States. |
| `isInvalid` | `bool?` | – | Overrides the displayed validation. |
| `isWheelDisabled` | `bool` | `false` | Ignore the mouse wheel. |
| `name` | `String?` | – | Key of the number in the form data. |
| `validator` | `FormFieldValidator<double>?` | – | Validates the committed number. |
| `validationBehavior`, `validationErrors`, `autovalidateMode` | – | – | As `HeroTextField`. |
| `onSaved` | `FormFieldSetter<double>?` | – | Called with the number on save. |
| `validationMessages` | `HeroValidationMessages` | English | Built-in messages. |
| `autofocus` | `bool` | `false` | Focus when first built. |
| `semanticLabel` | `String?` | label text | Accessibility label. |
| `incrementLabel` / `decrementLabel` | `String` | `'Increase'` / `'Decrease'` | Button labels. |

### HeroNumberFieldGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Buttons, input, or other widgets. |
| `style` | `HeroFieldStyle?` | – | Box overrides. |

### HeroNumberFieldInput

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `placeholder` | `String?` | – | Text shown while empty. |
| `width` | `double?` | `192` | Width when the field shrink-wraps. |
| `textAlign` | `TextAlign` | `start` | Text alignment. |
| `style` | `HeroFieldStyle?` | – | Text, placeholder, caret and padding overrides. |

### HeroNumberFieldIncrementButton / HeroNumberFieldDecrementButton

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | plus / minus icon | The icon. |
| `width` | `double?` | `40` | Button width. |
| `padding` | `EdgeInsetsGeometry?` | – | Padding around the icon. |
| `showDivider` | `bool` | `true` | Divider next to the input. |
| `style` | `HeroButtonStyle?` | – | Background / foreground per state, icon size, press scale. |
| `semanticLabel` | `String?` | field's labels | Accessibility label. |

### HeroNumberFormatOptions

| Parameter | Type | Default |
| --- | --- | --- |
| `style` | `HeroNumberFormatStyle` | `decimal` |
| `currency` | `String?` | – (required for `currency`) |
| `currencySign` | `HeroCurrencySign` | `standard` |
| `currencyDisplay` | `HeroCurrencyDisplay` | `symbol` |
| `unit` | `String?` | – (required for `unit`) |
| `unitDisplay` | `HeroUnitDisplay` | `short` |
| `minimumFractionDigits` / `maximumFractionDigits` | `int?` | per style |
| `useGrouping` | `bool` | `true` |

### HeroNumberFormatter

`HeroNumberFormatter(options, locale:)` / `.fromNumberFormat(format)`:
`format(double)`, `parse(String)` (NaN when invalid), `isValidPartial(text,
minValue:, maxValue:)`. `heroSnapValueToStep` and `heroDecimalOperation`
reproduce React Aria's step arithmetic.
