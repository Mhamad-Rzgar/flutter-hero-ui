# Checkbox

Checkboxes allow users to select multiple items from a list of individual items, or to mark
one individual item as selected.

HeroUI docs: [heroui.com/en/docs/react/components/checkbox](https://heroui.com/en/docs/react/components/checkbox)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroCheckbox(
  name: 'basic-terms',
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[
        HeroCheckboxControl(),
        Text('Accept terms and conditions'),
      ],
    ),
  ],
)
```

The same checkbox from the convenience parameters:

```dart
const HeroCheckbox(name: 'basic-terms', label: 'Accept terms and conditions')
```

## Anatomy

```dart
HeroCheckbox(
  children: <Widget>[
    HeroCheckboxContent( // the pressable row: control + label
      children: <Widget>[
        HeroCheckboxControl(
          child: HeroCheckboxIndicator(), // the default child
        ),
        Text('Label'),
      ],
    ),
    HeroDescription.text('...'), // optional help text
    HeroFieldError(), // optional validation message
  ],
)
```

- `HeroCheckbox` is the field root: a column with a 4 px gap whose parts keep their own
  width (`items-start`). It owns the selection and the form state.
- `HeroCheckboxContent` is the clickable label: the control and the label text in a row with
  a 12 px gap (`text-sm font-medium`). It is the checkbox's accessibility node. Long labels
  wrap next to the control.
- `HeroCheckboxControl` is the 16 px box; `HeroCheckboxIndicator` the checkmark inside it.
- A `HeroDescription` or `HeroFieldError` placed directly in the checkbox is indented 28 px
  under the label; the error is `--muted`, not `--danger`, as in HeroUI.

Without `children` (or `builder`) the checkbox builds this layout from `label`,
`description` and `errorMessage`; the error defaults to the validation messages.

## Styles

| Part | Style |
| --- | --- |
| Control | 16 × 16, `rounded-md` (6), `--field-background`, field shadow, field border (0 px by default) |
| Checked | an accent fill grows from 70% (100 ms linear) and fades in (200 ms linear); the checkmark is drawn from its start (150 ms linear after 15 ms) in `--accent-foreground` |
| Unchecked | the checkmark is erased (200 ms) and the fill fades out |
| Indeterminate | control `--accent` (`--accent-hover` while pressed) with a 12 px dash |
| Hover | `--field-border-hover`; the fill turns `--accent-hover` (anywhere over the field) |
| Keyboard focus | 2 px focus ring with a 2 px background-colored offset around the control |
| Invalid | unchecked: 1 px `--danger` outline; checked or indeterminate: `--danger` with `--danger-foreground` glyph |
| Disabled | the field at `--disabled-opacity`; its description and error dimmed once more |

## Variants

`variant` (`HeroFieldVariant.primary` by default, `secondary`): the secondary control has no
shadow and a `--default` background, for use on surfaces. Inside a checkbox group the group's
variant applies unless the checkbox sets its own.

## Examples

### Variants

```dart
const HeroCheckbox(
  name: 'secondary',
  variant: HeroFieldVariant.secondary,
  label: 'Secondary checkbox',
  description: 'Lower emphasis variant for use in surfaces',
)
```

### Full rounded

`size` and `borderRadius` resize and reshape the control; `HeroCheckboxIndicator(size:)`
resizes the checkmark.

```dart
HeroCheckbox(
  name: 'xl-rounded',
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[
        HeroCheckboxControl(
          size: theme.spacing(6),
          borderRadius: BorderRadius.circular(theme.radii.full),
          child: HeroCheckboxIndicator(size: theme.spacing(4)),
        ),
        const Text('Extra large size'),
      ],
    ),
  ],
)
```

### Disabled

```dart
const HeroCheckbox(
  isDisabled: true,
  label: 'Premium Feature',
  description: 'This feature is coming soon',
)
```

### External label

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: <Widget>[
    HeroCheckbox(
      isSelected: marketing,
      onChanged: (bool value) => setState(() => marketing = value),
      semanticLabel: 'Send me marketing emails',
      children: const <Widget>[
        HeroCheckboxContent(children: <Widget>[HeroCheckboxControl()]),
      ],
    ),
    HeroLabel.text(
      'Send me marketing emails',
      onPressed: () => setState(() => marketing = !marketing),
    ),
  ],
)
```

### With description, default selected

```dart
const HeroCheckbox(
  name: 'description-notifications',
  label: 'Email notifications',
  description: 'Get notified when someone mentions you in a comment',
)

const HeroCheckbox(
  defaultSelected: true,
  label: 'Enable email notifications',
)
```

### Invalid

```dart
const HeroCheckbox(
  name: 'agreement',
  isInvalid: true,
  isRequired: true,
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[HeroCheckboxControl(), Text('I agree to the terms')],
    ),
    HeroFieldError.text('You must accept the terms to continue'),
  ],
)
```

### Controlled

```dart
HeroCheckbox(
  label: 'Email notifications',
  isSelected: isSelected,
  onChanged: (bool value) => setState(() => isSelected = value),
)
```

### Indeterminate

`isIndeterminate` is presentational: pressing the checkbox calls `onChanged` with the
toggled selection and the owner clears the flag.

```dart
HeroCheckbox(
  isIndeterminate: isIndeterminate,
  isSelected: isSelected,
  onChanged: (bool selected) => setState(() {
    isSelected = selected;
    isIndeterminate = false;
  }),
  label: 'Select all',
  description: 'Shows indeterminate state (dash icon)',
)
```

### Form integration

A checked box submits its `value` (`'on'` by default) under its `name`; unchecked boxes are
left out, like the browser's `FormData`.

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => debugPrint('$data'),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      const HeroCheckbox(name: 'notifications', label: 'Enable notifications'),
      const HeroCheckbox(
        name: 'newsletter',
        defaultSelected: true,
        label: 'Subscribe to newsletter',
      ),
      const HeroButton(
        type: HeroButtonType.submit,
        size: HeroSize.sm,
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### Render props

```dart
HeroCheckbox(
  builder: (BuildContext context, HeroCheckboxState state) => <Widget>[
    HeroCheckboxContent(
      children: <Widget>[
        const HeroCheckboxControl(),
        Text(state.isSelected ? 'Terms accepted' : 'Accept terms'),
      ],
    ),
    HeroDescription.text(
      state.isSelected
          ? 'Thank you for accepting'
          : 'Please read and accept the terms',
    ),
  ],
)
```

`HeroCheckboxContent(builder:)` receives the hover, press, focus and selection state
(`HeroInteractionState`) instead.

### Render function

React's `render` prop replaces the DOM element; a Flutter checkbox is composed like any other
widget, so the example is identical to the basic one.

### Custom indicator

```dart
HeroCheckboxControl(
  child: HeroCheckboxIndicator(
    builder: (BuildContext context, HeroCheckboxState state) =>
        state.isSelected ? const HeroIcon(HeroIcons.heartFill) : null,
  ),
)
```

Custom glyphs are laid out in a 12 px box; `HeroIcon`s take that size and the glyph color.

### Customization

```dart
HeroCheckboxControl(
  color: theme.colors.successSoft,
  selectedColor: theme.colors.success,
  child: HeroCheckboxIndicator(color: theme.colors.successForeground),
)
```

`HeroCheckboxContent` takes `padding`, a state-dependent `decoration`
(`WidgetStateProperty<Decoration?>`), `spacing`, `crossAxisAlignment` and `fullWidth` for
card-like checkboxes.

## Validation

| Source | Shown |
| --- | --- |
| `isInvalid: true` / `false` | always; overrides every other source |
| `validationErrors` (or the form's `validationErrors[name]`) | immediately; cleared once the user toggles the checkbox |
| `validator` | native: after a toggle or a form submission; aria: in realtime |
| `isRequired` | native only: "Please check this box if you want to proceed." while unchecked |

The checkbox is a `FormField<bool>` of the nearest `Form`: `validator`, `onSaved` and
`autovalidateMode` work as in Flutter; an invalid checkbox blocks `HeroForm` submission and
takes the focus; `reset()` restores its initial state.

## Accessibility

- The content is one checkbox node: checked, unchecked or mixed; labelled by its text (or
  `semanticLabel`) and described by the description and, while invalid, the error. Required,
  invalid, read-only and disabled states are reported.
- Space toggles the focused checkbox (Enter does not, like a native checkbox); Tab reaches it.
  The focus ring shows for keyboard focus only.
- A `HeroLabel` inside the checkbox toggles it when pressed and never shows the required
  asterisk.
- The error is a live region, announced when it appears.

## API

### HeroCheckbox

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | The parts. |
| `builder` | `HeroCheckboxBuilder?` | – | Builds the parts from `HeroCheckboxState`; wins over `children`. |
| `label` | `String?` | – | Label of the built checkbox. |
| `description` | `String?` | – | Description of the built checkbox. |
| `errorMessage` | `String?` | – | Error of the built checkbox; defaults to the validation messages. |
| `isSelected` | `bool?` | – | Checked state (controlled). |
| `defaultSelected` | `bool` | `false` | Initial state (uncontrolled). |
| `onChanged` | `ValueChanged<bool>?` | – | Called when the user toggles the checkbox. |
| `isIndeterminate` | `bool` | `false` | Shows the mixed state. |
| `variant` | `HeroFieldVariant?` | group, then `primary` | Visual variant. |
| `isDisabled` | `bool` | `false` | Disables the checkbox. |
| `isReadOnly` | `bool` | `false` | Focusable but not toggleable. |
| `isRequired` | `bool` | `false` | Must be checked (native validation). |
| `isInvalid` | `bool?` | – | Overrides the displayed validation. |
| `name` | `String?` | – | Key in the `HeroForm` data. |
| `value` | `String?` | `'on'` | Submitted value; identity inside a checkbox group. |
| `validator` | `FormFieldValidator<bool>?` | – | Custom validation (`validate`). |
| `validationBehavior` | `HeroValidationBehavior?` | form, then `native` | When errors show. |
| `validationErrors` | `List<String>?` | – | Server-side errors. |
| `validationMessages` | `HeroValidationMessages` | English | Built-in messages. |
| `onSaved` | `FormFieldSetter<bool>?` | – | Called when the form saves. |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | Native: show errors before a change. |
| `focusNode` | `FocusNode?` | – | Focus of the content. |
| `autofocus` | `bool` | `false` | Focus on first build. |
| `semanticLabel` | `String?` | label text | Accessibility label (`aria-label`). |

### HeroCheckboxState

| Field | Type | Description |
| --- | --- | --- |
| `isSelected` | `bool` | Checked. |
| `isIndeterminate` | `bool` | Mixed. |
| `isDisabled` | `bool` | Disabled. |
| `isReadOnly` | `bool` | Read-only. |
| `isInvalid` | `bool` | Shows as invalid. |
| `isRequired` | `bool` | Required. |

### HeroCheckboxContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | The control and the label. |
| `builder` | `HeroToggleContentBuilder?` | – | Builds the parts from the `HeroInteractionState`. |
| `spacing` | `double?` | `12` | Gap between the parts. |
| `padding` | `EdgeInsetsGeometry?` | – | Padding around the parts. |
| `decoration` | `WidgetStateProperty<Decoration?>?` | – | Background by state (`selected`, `hovered`, ...). |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Vertical alignment. |
| `fullWidth` | `bool` | `false` | Fill the available width. |

### HeroCheckboxControl

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `HeroCheckboxIndicator()` | The glyph. |
| `size` | `double?` | `16` | Side length. |
| `borderRadius` | `BorderRadiusGeometry?` | `rounded-md` (6) | Corner radii. |
| `color` | `Color?` | `--field-background` / `--default` | Unchecked background. |
| `selectedColor` | `Color?` | `--accent` | Checked fill. |

### HeroCheckboxIndicator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | – | Custom glyph. |
| `builder` | `HeroCheckboxIndicatorBuilder?` | – | Builds the glyph from `HeroCheckboxState` (null draws nothing). |
| `size` | `double?` | `10` / `12` | Size of the checkmark / dash. |
| `color` | `Color?` | `--accent-foreground` | Glyph color. |

### Shared parts

| Widget | Description |
| --- | --- |
| `HeroCheckboxScope` | Shares the checkbox state with its parts. |
| `HeroToggleInteractionScope` | Shares the content's hover, press and focus state with the control. |
| `HeroInlineFlexRow` | The content row: children keep their width and shrink together like CSS `inline-flex`. |
| `HeroFieldHelpTextScope` | Indents the description and error placed directly in a checkbox, radio or switch. |
| `HeroFieldLayout(stretch: false)` | The field column with start-aligned parts. |
