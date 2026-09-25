# InputGroup

Group related input controls with prefix and suffix elements for enhanced form fields.

HeroUI docs: [heroui.com/en/docs/react/components/input-group](https://heroui.com/en/docs/react/components/input-group)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const SizedBox(
  width: 280,
  child: HeroTextField(
    name: 'email',
    children: <Widget>[
      HeroLabel.text('Email address'),
      HeroInputGroup(
        children: <Widget>[
          HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
          HeroInputGroupInput(placeholder: 'name@email.com'),
        ],
      ),
    ],
  ),
)
```

The same group from the convenience parameters:

```dart
const HeroInputGroup(
  startContent: HeroIcon(HeroIcons.envelope),
  child: HeroInputGroupInput(placeholder: 'name@email.com'),
)
```

## Anatomy

```dart
HeroTextField(
  children: <Widget>[
    HeroLabel.text('...'),
    HeroInputGroup(
      children: <Widget>[
        HeroInputGroupPrefix(child: ...),
        HeroInputGroupInput(), // or HeroInputGroupTextArea() for multiline input
        HeroInputGroupSuffix(child: ...),
      ],
    ),
  ],
)
```

`HeroInputGroup` wraps an input with optional prefix and suffix addons in one
field box. It is typically a part of a [`HeroTextField`](text-field.md), whose
label, variant, type, validation, required and disabled states it takes; the
text field owns the text and the form state. `HeroInputGroupInput` is the
single-line input, `HeroInputGroupTextArea` the multiline one.

| Part | HeroUI | Look |
| --- | --- | --- |
| `HeroInputGroup` | `InputGroup` / `InputGroup.Root` | `rounded-field`, `--field-background`, field shadow, `min-h-9`; hover, focus ring (while its input is focused), invalid outline, disabled opacity. |
| `HeroInputGroupPrefix` | `InputGroup.Prefix` | Transparent, full height, centred, `px-3`, `--field-placeholder` text (`text-sm`) and 16 px icons. |
| `HeroInputGroupInput` | `InputGroup.Input` | Transparent, `px-3 py-2`, no start padding after a prefix and no end padding before a suffix; `text-base` (`text-sm` from 640 px). Fills the space left by the addons. |
| `HeroInputGroupTextArea` | `InputGroup.TextArea` | Like the input, `rows` lines, `min-height: 38px`; the addons then align to the top with 8 px of top padding. |
| `HeroInputGroupSuffix` | `InputGroup.Suffix` | Like the prefix. |

A themed field border width (`--border-width-field`, 0 by default) draws a
divider on the inner side of each addon.

Pressing the group outside a control (for example on a prefix icon) focuses
the input; buttons in an addon keep their own press. Outside a field the group
shrink-wraps its parts (an input without `width` is 192 wide); inside a field,
or with `fullWidth`, it fills the available width.

## Variants

| `variant` | Look |
| --- | --- |
| `HeroFieldVariant.primary` (default) | `--field-background` with the field shadow. |
| `HeroFieldVariant.secondary` | `--default` background, no shadow; for use on surfaces. |

A group without `variant` takes the variant of its text field.

## Examples

### Variants

```dart
HeroInputGroup(
  variant: HeroFieldVariant.secondary,
  startContent: const HeroIcon(HeroIcons.envelope),
  child: const HeroInputGroupInput(placeholder: 'name@email.com'),
)
```

### In Surface

```dart
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl2),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const SizedBox(
    width: 280,
    child: HeroTextField(
      name: 'email',
      children: <Widget>[
        HeroLabel.text('Email address'),
        HeroInputGroup(
          variant: HeroFieldVariant.secondary,
          startContent: HeroIcon(HeroIcons.envelope),
          child: HeroInputGroupInput(placeholder: 'name@email.com'),
        ),
        HeroDescription.text("We'll never share this with anyone else"),
      ],
    ),
  ),
)
```

### Loading state

```dart
const HeroTextField(
  defaultValue: 'Sending...',
  children: <Widget>[
    HeroInputGroup(endContent: HeroSpinner(size: HeroSpinnerSize.sm)),
  ],
)
```

### Required, disabled and invalid

The group follows its text field:

```dart
const HeroTextField(
  name: 'price',
  isRequired: true, // or isDisabled / isInvalid
  type: HeroInputType.number,
  children: <Widget>[
    HeroLabel.text('Set a price'),
    HeroInputGroup(
      startContent: Text(r'$'),
      endContent: Text('USD'),
      child: HeroInputGroupInput(placeholder: '0'),
    ),
    HeroDescription.text('What customers would pay'),
    HeroFieldError.text('Price must be greater than 0'),
  ],
)
```

### Full width

```dart
const HeroTextField(
  fullWidth: true,
  children: <Widget>[
    HeroLabel.text('Password'),
    HeroInputGroup(
      fullWidth: true,
      endContent: HeroIcon(HeroIcons.eye),
      child: HeroInputGroupInput(
        placeholder: 'Enter password',
        type: HeroInputType.password,
      ),
    ),
  ],
)
```

### Text and icon addons

```dart
const HeroInputGroup(startContent: Text('https://'))
const HeroInputGroup(endContent: Text('.com'))
const HeroInputGroup(
  startContent: HeroIcon(HeroIcons.globe),
  endContent: Text('.com'),
)
```

### Buttons, keyboard shortcuts and chips

`padding` on an addon replaces its `px-3`: HeroUI's `pe-0` next to a button,
`pe-2` next to a `Kbd` or a `Chip`.

```dart
HeroInputGroup(
  children: <Widget>[
    const HeroInputGroupInput(),
    HeroInputGroupSuffix(
      padding: const EdgeInsetsDirectional.only(start: 12), // pe-0
      child: HeroButton(
        isIconOnly: true,
        size: HeroSize.sm,
        variant: HeroButtonVariant.ghost,
        semanticLabel: 'Copy',
        onPressed: copy,
        child: const HeroIcon(HeroIcons.copy),
      ),
    ),
  ],
)

HeroInputGroup(
  children: <Widget>[
    const HeroInputGroupInput(placeholder: 'Command'),
    HeroInputGroupSuffix(
      padding: const EdgeInsetsDirectional.only(start: 12, end: 8), // pe-2
      child: const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K'),
    ),
  ],
)
```

### Password toggle

```dart
HeroInputGroup(
  children: <Widget>[
    HeroInputGroupInput(
      type: isVisible ? HeroInputType.text : HeroInputType.password,
    ),
    HeroInputGroupSuffix(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: HeroButton(
        isIconOnly: true,
        size: HeroSize.sm,
        variant: HeroButtonVariant.ghost,
        semanticLabel: isVisible ? 'Hide password' : 'Show password',
        onPressed: () => setState(() => isVisible = !isVisible),
        child: HeroIcon(isVisible ? HeroIcons.eye : HeroIcons.eyeSlash),
      ),
    ),
  ],
)
```

### With TextArea

With a `HeroInputGroupTextArea` the group grows with the text area and its
addons align to the top. `direction: Axis.vertical` stacks the parts (a prompt
box with actions under the text); `spacing`, `padding` and
`style.borderRadius` shape the box.

```dart
HeroTextField(
  fullWidth: true,
  semanticLabel: 'Prompt input',
  children: <Widget>[
    HeroInputGroup(
      direction: Axis.vertical,
      spacing: theme.spacing(2),
      padding: EdgeInsets.symmetric(vertical: theme.spacing(2)),
      style: HeroFieldStyle(
        borderRadius: BorderRadius.circular(theme.radii.xl3),
      ),
      children: <Widget>[
        HeroInputGroupPrefix(
          padding: EdgeInsets.symmetric(horizontal: theme.spacing(3)),
          child: HeroButton(
            size: HeroSize.sm,
            variant: HeroButtonVariant.outline,
            startContent: const HeroIcon(HeroIcons.at),
            onPressed: addContext,
            child: const Text('Add Context'),
          ),
        ),
        HeroInputGroupTextArea(
          placeholder: 'Assign tasks or ask anything...',
          rows: 5,
          style: HeroFieldStyle(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing(3.5)),
          ),
        ),
        HeroInputGroupSuffix(
          padding: EdgeInsets.symmetric(horizontal: theme.spacing(3)),
          child: Row(children: <Widget>[/* action buttons */]),
        ),
      ],
    ),
  ],
)
```

### TextArea usage example

```dart
HeroTextField(
  name: 'feedback',
  fullWidth: true,
  isInvalid: feedback.length > 500,
  onChanged: (String value) => setState(() => feedback = value),
  children: <Widget>[
    const HeroLabel.text('Your Feedback'),
    const HeroInputGroup(
      fullWidth: true,
      children: <Widget>[
        HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
        HeroInputGroupTextArea(
          placeholder: 'Share your thoughts, suggestions, or issues...',
          rows: 5,
        ),
      ],
    ),
    HeroDescription(
      child: Row(
        children: <Widget>[
          const Expanded(child: Text('Maximum 500 characters.')),
          Text('${feedback.length}/500'),
        ],
      ),
    ),
    const HeroFieldError.text('Feedback must be less than 500 characters'),
  ],
)
```

### Customization

`style` (`HeroFieldStyle`) restyles the box, like HeroUI's `className`:

```dart
HeroInputGroup(
  style: HeroFieldStyle(
    borderRadius: BorderRadius.circular(theme.radii.xl),
    borderWidth: theme.borderWidth,
    borderColor: theme.colors.border.withValues(alpha: 0.8),
    backgroundColor: theme.colors.defaultColor,
    shadow: theme.shadows.surface,
  ),
  startContent: const HeroIcon(HeroIcons.envelope),
  child: const HeroInputGroupInput(placeholder: 'you@company.com'),
)
```

`builder` builds the parts from the group state (`isHovered`,
`isFocusWithin`, `isFocusVisible`, `isDisabled`, `isInvalid`), like HeroUI's
render-function children.

## Accessibility

- The group is a semantics container (`semanticLabel` names it, like
  `aria-label`); the input inside is the text field node, labelled by the
  field's label and described by its description or error.
- HeroUI's `role` prop (`group`, `region`, `presentation`) has no Flutter
  equivalent; the group is always a plain container.
- Addon icons and text are not focusable; buttons in an addon are regular
  buttons in the focus order.
- A disabled group ignores the pointer and its input leaves the focus order.

## API

### HeroInputGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | Parts: prefix, input or text area, suffix. |
| `builder` | `HeroInputGroupBuilder?` | – | Builds the parts from `HeroInputGroupState`. |
| `startContent` | `Widget?` | – | Content of a built prefix. |
| `endContent` | `Widget?` | – | Content of a built suffix. |
| `child` | `Widget?` | `HeroInputGroupInput()` | Input of the built group. |
| `variant` | `HeroFieldVariant?` | field's, then `primary` | Visual variant. |
| `fullWidth` | `bool` | `false` | Fill the available width. |
| `isDisabled` | `bool` | `false` | Disabled look; also from the field. |
| `isInvalid` | `bool` | `false` | Invalid outline; also from the field. |
| `direction` | `Axis` | `horizontal` | Row or column of parts. |
| `spacing` | `double` | `0` | Gap between parts. |
| `padding` | `EdgeInsetsGeometry?` | – | Padding inside the box. |
| `style` | `HeroFieldStyle?` | – | Box overrides (background, border, radius, shadow, ring). |
| `semanticLabel` | `String?` | – | Accessibility label (`aria-label`). |

### HeroInputGroupState

| Field | Type | Description |
| --- | --- | --- |
| `isHovered` | `bool` | A mouse hovers the group. |
| `isFocusWithin` | `bool` | A control inside has focus. |
| `isFocusVisible` | `bool` | The focus is keyboard focus. |
| `isDisabled` | `bool` | The group is disabled. |
| `isInvalid` | `bool` | The group is invalid. |

### HeroInputGroupPrefix / HeroInputGroupSuffix

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Addon content. |
| `padding` | `EdgeInsetsGeometry?` | `px-3` (+ `pt-2` next to a text area) | Padding around the content. |
| `alignment` | `AlignmentGeometry?` | centre (top next to a text area, start in a column) | Alignment of the content. |
| `style` | `TextStyle?` | – | Merged over `text-sm` `--field-placeholder`. |

### HeroInputGroupInput

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `TextEditingController?` | field's | Text controller. |
| `focusNode` | `FocusNode?` | field's | Focus node. |
| `value` / `defaultValue` | `String?` | – | Controlled / initial value (standalone). |
| `onChanged` | `ValueChanged<String>?` | – | Called on every edit. |
| `onSubmitted` | `ValueChanged<String>?` | – | Called on the keyboard action. |
| `placeholder` | `String?` | – | Text shown while empty. |
| `type` | `HeroInputType` | field's type | Keyboard, obscuring and validation. |
| `obscureText` | `bool?` | passwords | Obscure the text. |
| `width` | `double?` | `192` | Width when the group shrink-wraps. |
| `isDisabled` / `isReadOnly` / `isRequired` / `isInvalid` | `bool` | `false` | States. |
| `name`, `validator`, `onSaved`, `autovalidateMode` | – | – | Form integration of a standalone group. |
| `maxLength`, `minLength`, `pattern`, `autofillHints`, `inputFormatters`, `keyboardType`, `textInputAction`, `textCapitalization`, `textAlign`, `autofocus` | – | – | As on `HeroInput`. |
| `semanticLabel` | `String?` | field label | Accessibility label. |
| `style` | `HeroFieldStyle?` | – | Text, placeholder, caret and padding overrides. |

### HeroInputGroupTextArea

As `HeroInputGroupInput` (without `type`, `obscureText`, `onSubmitted`), plus:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `rows` | `int` | `2` | Visible lines. |
| `height` | `double?` | – | Explicit height. |
| `resize` | `HeroTextAreaResize` | `none` | `vertical` shows a drag grip. |
| `textCapitalization` | `TextCapitalization` | `sentences` | Automatic capitalization. |

### HeroTextAreaResizeGrip

The drag grip of resizable text areas (`HeroTextArea`,
`HeroInputGroupTextArea`): `onDrag` receives vertical drag updates.
