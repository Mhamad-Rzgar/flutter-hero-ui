# ColorField

Color input field with labels, descriptions, and validation.

HeroUI reference: <https://heroui.com/en/docs/react/components/color-field>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Color? color = heroParseColor('#0485F7');

SizedBox(
  width: 280,
  child: HeroColorField(
    name: 'color',
    label: 'Color',
    showSwatch: true,
    value: color,
    onChanged: (Color? next) => setState(() => color = next),
  ),
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `ColorField` | `HeroColorField` (a `FormField<Color?>`) |
| `Label` | `HeroLabel` (or `label`) |
| `ColorField.Group` (`ColorInputGroup`) | `HeroColorInputGroup` |
| `ColorField.Prefix` | `HeroColorInputPrefix` (or `showSwatch` / `startContent`) |
| `ColorField.Input` | `HeroColorInput` (or `placeholder`) |
| `ColorField.Suffix` | `HeroColorInputSuffix` (or `endContent`) |
| `Description` | `HeroDescription` (or `description`) |
| `FieldError` | `HeroFieldError` (or `errorMessage`) |

```dart
HeroColorField(
  defaultValue: const Color(0xFF3B82F6),
  children: const <Widget>[
    HeroLabel.text('Primary Color'),
    HeroColorInputGroup(
      children: <Widget>[
        HeroColorInputPrefix(child: HeroColorSwatch(size: HeroColorSwatchSize.xs)),
        HeroColorInput(),
      ],
    ),
    HeroDescription.text("Enter your brand's primary color"),
    HeroFieldError(),
  ],
)
```

A `HeroColorSwatch` without a color inside the field shows the field's color. Parts are
stacked with a 4 px gap (`spacing`) and stretched to one width; an unsized field is as wide as
a native input (192) plus its prefix and suffix.

## Hex and channel editing

- **Hex** (default): typing is limited to hex digits and an optional `#`. On Enter or when the
  input loses focus the text is parsed (`#RGB` or `#RRGGBB`, with or without `#`), committed
  and shown as `#RRGGBB`. Empty text clears the value; invalid text reverts to the last value.
  Up / Page Up and Down / Page Down add or subtract one from the hex number, Home and End jump
  to `#000000` and `#FFFFFF`.
- **Channel** (`channel` + `colorSpace`): the input edits that channel as a plain number, with
  the channel's range, step and page size (hue 0–360, percentages 0–100, rgb 0–255, alpha
  0–1). Add a unit with a suffix (`endContent: Text('%')`). Invalid or empty text reverts.
- The mouse wheel steps the value while the input has focus, unless `isWheelDisabled`.
- `onChanged` fires when a value is committed (Enter, blur, keys, wheel), not on every
  keystroke, like React Aria's ColorField.

## Variants

| Group variant | Look |
| --- | --- |
| `HeroFieldVariant.primary` (default) | `--field-background`, field shadow |
| `HeroFieldVariant.secondary` | `--default` background, no shadow; for surfaces |

The group is 36 tall (`h-9`, growing with the text scale) with the field radius, HeroUI's hover
background, a 2 px focus ring while the input has focus, the danger outline while invalid and
the disabled opacity. Prefix and suffix sit 12 px from the edges in the placeholder color; the
input's padding next to them is 8.

## Examples

### Variants

```dart
HeroColorField(label: 'Primary variant', defaultValue: const Color(0xFF0485F7))
HeroColorField(
  label: 'Secondary variant',
  variant: HeroFieldVariant.secondary,
  defaultValue: const Color(0xFFF43F5E),
)
```

### On surface

```dart
HeroSurface(
  width: 320,
  padding: EdgeInsets.all(theme.spacing(4)),
  child: const HeroColorField(
    defaultValue: Color(0xFF3B82F6),
    children: <Widget>[
      HeroLabel.text('Theme Color'),
      HeroColorInputGroup(variant: HeroFieldVariant.secondary),
      HeroDescription.text('Select your theme color'),
    ],
  ),
)
```

### With description, required and disabled

```dart
HeroColorField(
  label: 'Primary Color',
  description: "Enter your brand's primary color",
  defaultValue: const Color(0xFF3B82F6),
)
HeroColorField(label: 'Brand Color', isRequired: true, placeholder: '#000000')
HeroColorField(label: 'Color', isDisabled: true, defaultValue: const Color(0xFF0485F7))
```

### Full width

```dart
SizedBox(
  width: 400,
  child: HeroColorField(label: 'Brand Color', fullWidth: true, defaultValue: const Color(0xFF10B981)),
)
```

### Validation

```dart
HeroColorField(
  isInvalid: true,
  isRequired: true,
  children: const <Widget>[
    HeroLabel.text('Color'),
    HeroColorInputGroup(children: <Widget>[HeroColorInput(placeholder: '#000000')]),
    HeroFieldError.text('Please enter a valid hex color'),
  ],
)
```

### Channel editing

```dart
for (final HeroColorChannel channel in <HeroColorChannel>[
  HeroColorChannel.hue,
  HeroColorChannel.saturation,
  HeroColorChannel.lightness,
])
  SizedBox(
    width: 100,
    child: HeroColorField(
      channel: channel,
      colorSpace: HeroColorSpace.hsl,
      label: channel.label,
      value: color,
      onChanged: (Color? next) => setState(() => color = next),
      endContent: channel == HeroColorChannel.hue ? null : const Text('%'),
    ),
  )
```

Fields sharing one color keep its hue when saturation reaches 0.

### Controlled

```dart
HeroColorField(
  label: 'Color',
  showSwatch: true,
  value: value,
  onChanged: (Color? next) => setState(() => value = next),
)
HeroButton(
  variant: HeroButtonVariant.tertiary,
  onPressed: () => setState(() => value = null), // clears the field
  child: const Text('Clear'),
)
```

### Form example

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => save(data['brand-color']), // '#3B82F6'
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      HeroColorField(
        name: 'brand-color',
        label: 'Brand Color',
        fullWidth: true,
        isRequired: true,
        showSwatch: true,
        placeholder: '#000000',
        description: "Choose your brand's primary color",
        value: value,
        onChanged: (Color? next) => setState(() => value = next),
      ),
      HeroButton(
        type: HeroButtonType.submit,
        isDisabled: value == null,
        isPending: isSubmitting,
        child: Text(isSubmitting ? 'Saving...' : 'Save Color'),
      ),
    ],
  ),
)
```

### Render function

```dart
HeroColorField(
  builder: (BuildContext context, HeroColorFieldState state) => <Widget>[
    HeroLabel.text(state.isFocusWithin ? 'Color (editing)' : 'Color'),
    const HeroColorInputGroup(),
  ],
)
```

### Customization

```dart
HeroColorInputGroup(
  variant: HeroFieldVariant.secondary,
  style: HeroFieldStyle(
    borderRadius: BorderRadius.circular(theme.radii.xl),
    backgroundColor: theme.colors.defaultColor,
    shadow: HeroShadow.none,
    focusRingColor: theme.colors.accent.withValues(alpha: 0.15),
  ),
  children: <Widget>[
    HeroColorInputPrefix(
      child: HeroColorSwatch(
        size: HeroColorSwatchSize.xs,
        style: HeroColorSwatchStyle(borderRadius: BorderRadius.circular(theme.radii.md)),
      ),
    ),
    HeroColorInput(
      style: theme.typography.style(HeroFontSize.sm, mono: true),
      placeholderStyle: TextStyle(color: theme.colors.muted),
    ),
  ],
)
```

## Validation and forms

`HeroColorField` registers a `FormField<Color?>` with the nearest `Form` (`HeroForm`):

- `isRequired` fails while empty ("Please fill out this field."); `validator` runs first.
- Native behaviour (default): errors show after a commit or when the form validates, and block
  submission. Aria behaviour: errors show right away and never block.
- `validationErrors` (or the form's errors for `name`) show immediately and clear on the next
  committed value; `isInvalid` true/false overrides the displayed state.
- While invalid the label turns danger, the group shows the invalid outline, the description
  is hidden and the `HeroFieldError` shows the message.
- A `HeroForm` receives the hex string (or the channel number) under `name`; reset restores
  the initial value.

## Accessibility

- The input is a text field labelled with `semanticLabel` or the label text, with the
  description or error as hint, and reports required, invalid and read-only states. Channel
  fields add increase and decrease actions.
- Pressing the label focuses the input; the focus ring shows for any focus, like a browser
  input.
- Right-to-left layouts put the prefix on the right. Text scaling grows the group.

## API

### HeroColorField

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | The parts; built from the convenience parameters when null. |
| `builder` | `List<Widget> Function(BuildContext, HeroColorFieldState)?` | – | Builds the parts from the state. |
| `label` | `String?` | – | Label of the built field. |
| `description` | `String?` | – | Description of the built field. |
| `errorMessage` | `String?` | – | Error of the built field. |
| `placeholder` | `String?` | – | Placeholder of the built input. |
| `showSwatch` | `bool` | `false` | Starts the built group with an extra-small swatch of the value. |
| `startContent` / `endContent` | `Widget?` | – | Prefix / suffix of the built group. |
| `value` | `Color?` | – | Current color (controlled); null clears a controlled field; inside a picker, null binds to the picker. |
| `defaultValue` | `Color?` | – | Initial color (uncontrolled). |
| `onChanged` | `ValueChanged<Color?>?` | – | Called with the committed color (null when cleared). |
| `colorSpace` | `HeroColorSpace?` | – | Space of `channel`. |
| `channel` | `HeroColorChannel?` | – | Channel to edit; null edits the hex value. |
| `variant` | `HeroFieldVariant` | `primary` | Variant of the groups inside. |
| `fullWidth` | `bool` | `false` | Fill the available width. |
| `spacing` | `double?` | 4 | Gap between the parts. |
| `groupStyle` | `HeroFieldStyle?` | – | Overrides of the built group. |
| `inputStyle` | `TextStyle?` | – | Text style of the built input. |
| `isDisabled` | `bool` | `false` | Disables the field. |
| `isReadOnly` | `bool` | `false` | Selectable but not editable. |
| `isRequired` | `bool` | `false` | Requires a value. |
| `isInvalid` | `bool?` | – | Overrides the displayed validation. |
| `isWheelDisabled` | `bool` | `false` | Disables stepping with the mouse wheel. |
| `name` | `String?` | – | Name of the value in a `HeroForm`. |
| `validator` | `String? Function(Color?)?` | – | Custom validation. |
| `validationBehavior` | `HeroValidationBehavior?` | form's, then native | When errors show. |
| `validationErrors` | `List<String>?` | – | Server-side errors. |
| `onSaved` | `FormFieldSetter<Color?>?` | – | Called when the form is saved. |
| `autovalidateMode` | `AutovalidateMode?` | – | Automatic validation in native mode. |
| `validationMessages` | `HeroValidationMessages` | English | Built-in messages. |
| `focusNode` | `FocusNode?` | – | Focus node of the input. |
| `autofocus` | `bool` | `false` | Focus when first built. |
| `semanticLabel` | `String?` | label | Accessibility label (`aria-label`). |

`HeroColorFieldState` has `value`, `isDisabled`, `isInvalid`, `isReadOnly`, `isRequired`,
`isFocusWithin`, `isFocusVisible` and `validation`.

### HeroColorInputGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[HeroColorInput()]` | Prefix, input and suffix. |
| `variant` | `HeroFieldVariant?` | field's | `primary` or `secondary`. |
| `fullWidth` | `bool?` | field's | Fill the available width. |
| `style` | `HeroFieldStyle?` | – | Visual overrides. |

### HeroColorInput

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `placeholder` | `String?` | – | Text shown while empty. |
| `style` | `TextStyle?` | – | Merged over the input text style. |
| `placeholderStyle` | `TextStyle?` | – | Merged over the placeholder style. |

### HeroColorInputPrefix / HeroColorInputSuffix

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The content (text and icons take the placeholder color). |
