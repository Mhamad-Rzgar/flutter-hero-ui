# CheckboxGroup

A checkbox group component for managing multiple checkbox selections.

HeroUI docs: [heroui.com/en/docs/react/components/checkbox-group](https://heroui.com/en/docs/react/components/checkbox-group)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroCheckboxGroup(
  name: 'interests',
  label: 'Select your interests',
  description: 'Choose all that apply',
  children: <Widget>[
    HeroCheckbox(
      value: 'coding',
      label: 'Coding',
      description: 'Love building software',
    ),
    HeroCheckbox(
      value: 'design',
      label: 'Design',
      description: 'Enjoy creating beautiful interfaces',
    ),
    HeroCheckbox(
      value: 'writing',
      label: 'Writing',
      description: 'Passionate about content creation',
    ),
  ],
)
```

## Anatomy

```dart
HeroCheckboxGroup(
  name: 'interests',
  children: <Widget>[
    HeroLabel.text('...'),
    HeroDescription.text('...'), // optional
    HeroCheckbox(
      value: 'option1',
      children: <Widget>[
        HeroCheckboxContent(
          children: <Widget>[HeroCheckboxControl(), Text('Label')],
        ),
        HeroDescription.text('...'), // optional per-checkbox help text
      ],
    ),
    HeroFieldError(), // optional
  ],
)
```

`label`, `description` and `errorMessage` are shortcuts: they are placed before and after
`children`. Every [`HeroCheckbox`](checkbox.md) in the group needs a `value`; it may be nested
in other widgets (a column of cards, for example).

## Styles

| Part | Style |
| --- | --- |
| Root | column, no gap (`spacing`); parts stretched to the widest one |
| Checkboxes | 16 px top margin (`itemMargin`, HeroUI's `mt-4`), so the label and description touch and the first checkbox sits 16 px below them |
| Label | required asterisk while `isRequired`; `--danger` while invalid; dimmed while disabled |
| Checkboxes | the group's variant, disabled, read-only and invalid states |

## Examples

### In Surface

```dart
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const HeroCheckboxGroup(
    name: 'interests',
    variant: HeroFieldVariant.secondary,
    label: 'Select your interests',
    description: 'Choose all that apply',
    children: <Widget>[
      HeroCheckbox(value: 'coding', label: 'Coding'),
      HeroCheckbox(value: 'design', label: 'Design'),
    ],
  ),
)
```

### Disabled

```dart
const HeroCheckboxGroup(
  name: 'disabled-features',
  isDisabled: true,
  label: 'Features',
  description: 'Feature selection is temporarily disabled',
  children: <Widget>[
    HeroCheckbox(
      value: 'feature1',
      label: 'Feature 1',
      description: 'This feature is coming soon',
    ),
  ],
)
```

### Indeterminate

```dart
HeroCheckbox(
  label: 'Select all',
  isIndeterminate: selected.isNotEmpty && selected.length < allOptions.length,
  isSelected: selected.length == allOptions.length,
  onChanged: (bool isSelected) => setState(
    () => selected = isSelected ? allOptions.toSet() : <String>{},
  ),
),
Padding(
  padding: EdgeInsetsDirectional.only(start: theme.spacing(6)),
  child: HeroCheckboxGroup(
    value: selected,
    onChanged: (Set<String> value) => setState(() => selected = value),
    children: const <Widget>[
      HeroCheckbox(value: 'coding', label: 'Coding'),
      HeroCheckbox(value: 'design', label: 'Design'),
      HeroCheckbox(value: 'writing', label: 'Writing'),
    ],
  ),
)
```

### Controlled

```dart
HeroCheckboxGroup(
  name: 'skills',
  value: selected,
  onChanged: (Set<String> value) => setState(() => selected = value),
  children: <Widget>[
    const HeroLabel.text('Your skills'),
    const HeroCheckbox(value: 'coding', label: 'Coding'),
    const HeroCheckbox(value: 'design', label: 'Design'),
    Text('Selected: ${selected.join(', ')}'),
  ],
)
```

### Validation

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => debugPrint('${data['preferences']}'),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      HeroCheckboxGroup(
        name: 'preferences',
        isRequired: true,
        children: <Widget>[
          HeroLabel.text('Preferences'),
          HeroCheckbox(value: 'email', label: 'Email notifications'),
          HeroCheckbox(value: 'sms', label: 'SMS notifications'),
          HeroFieldError.text(
            'Please select at least one notification method.',
          ),
        ],
      ),
      HeroButton(type: HeroButtonType.submit, child: Text('Submit')),
    ],
  ),
)
```

### Features and add-ons

Card checkboxes use `HeroCheckboxContent`'s `fullWidth`, state-dependent `decoration` and a
round `HeroCheckboxControl` positioned in a `Stack`:

```dart
HeroCheckbox(
  value: 'email',
  variant: HeroFieldVariant.secondary,
  children: <Widget>[
    HeroCheckboxContent(
      fullWidth: true,
      decoration: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => ShapeDecoration(
          color: states.contains(WidgetState.selected)
              ? theme.colors.accent.withValues(alpha: 0.1)
              : theme.colors.surface,
          shape: theme.shapeAll(theme.radii.xl3),
        ),
      ),
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing(5),
                  vertical: theme.spacing(4),
                ),
                child: const Text('Email Notifications'),
              ),
              PositionedDirectional(
                top: theme.spacing(3),
                end: theme.spacing(4),
                child: HeroCheckboxControl(
                  size: theme.spacing(5),
                  borderRadius: BorderRadius.circular(theme.radii.full),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ],
)
```

### With custom indicator

```dart
HeroCheckboxControl(
  child: HeroCheckboxIndicator(
    builder: (BuildContext context, HeroCheckboxState state) =>
        state.isSelected ? const HeroIcon(HeroIcons.xmark) : null,
  ),
)
```

### Render function

React's `render` prop replaces the DOM element; the Flutter group is composed like any other
widget, so the example is identical to the basic one. `builder` receives the
`HeroCheckboxGroupState` (value, disabled, read-only, invalid, required).

### Customization

```dart
HeroCheckboxGroup(
  name: 'notification-channels',
  defaultValue: const <String>{'email'},
  spacing: theme.spacing(3), // gap-3
  itemMargin: EdgeInsets.zero, // no mt-4 on the checkboxes
  label: 'Notification channels',
  description: 'Choose how we should reach you for account updates.',
  children: <Widget>[/* success-colored checkboxes */],
)
```

## Validation

The group is a `FormField<Set<String>>` of the nearest `Form`:

| Source | Shown |
| --- | --- |
| `isInvalid: true` / `false` | always; overrides every other source |
| `validationErrors` (or the form's `validationErrors[name]`) | immediately; cleared once the user toggles a checkbox |
| `validator` | native: after a toggle or a form submission; aria: in realtime |
| `isRequired` | native only: "Please check this box if you want to proceed." while nothing is checked |

The checked values are submitted as a `List<String>` under `name` (nothing when empty);
`reset()` restores the initial selection. Checkboxes inside the group are not form fields of
their own.

## Accessibility

- The group is a labelled container (the label text, or `semanticLabel`) described by its
  description and, while invalid, its error; every checkbox is its own checkbox node.
- Tab moves through the checkboxes; Space toggles the focused one.

## API

### HeroCheckboxGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Checkboxes and other parts. |
| `builder` | `HeroCheckboxGroupBuilder?` | – | Builds the parts from `HeroCheckboxGroupState`; replaces `children`. |
| `label` | `String?` | – | Label before the parts. |
| `description` | `String?` | – | Description after the label. |
| `errorMessage` | `String?` | – | Error after the parts, shown while invalid. |
| `value` | `Set<String>?` | – | Checked values (controlled). |
| `defaultValue` | `Set<String>` | `{}` | Initial values (uncontrolled). |
| `onChanged` | `ValueChanged<Set<String>>?` | – | Called when the user toggles a checkbox. |
| `variant` | `HeroFieldVariant` | `primary` | Variant of the checkboxes. |
| `isDisabled` | `bool` | `false` | Disables every checkbox. |
| `isReadOnly` | `bool` | `false` | Focusable but not toggleable. |
| `isRequired` | `bool` | `false` | At least one must be checked. |
| `isInvalid` | `bool?` | – | Overrides the displayed validation. |
| `name` | `String?` | – | Key in the `HeroForm` data. |
| `validator` | `FormFieldValidator<Set<String>>?` | – | Custom validation. |
| `validationBehavior` | `HeroValidationBehavior?` | form, then `native` | When errors show. |
| `validationErrors` | `List<String>?` | – | Server-side errors. |
| `validationMessages` | `HeroValidationMessages` | English | Built-in messages. |
| `onSaved` | `FormFieldSetter<Set<String>>?` | – | Called when the form saves. |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | Native: show errors before a change. |
| `spacing` | `double?` | `0` | Gap between the parts. |
| `itemMargin` | `EdgeInsetsGeometry?` | 16 px top | Space around every checkbox. |
| `fullWidth` | `bool` | `false` | Fill the available width. |
| `semanticLabel` | `String?` | label text | Accessibility label. |

### HeroCheckboxGroupState

| Field | Type | Description |
| --- | --- | --- |
| `value` | `Set<String>` | Checked values. |
| `isDisabled` | `bool` | Disabled. |
| `isReadOnly` | `bool` | Read-only. |
| `isInvalid` | `bool` | Shows as invalid. |
| `isRequired` | `bool` | Required. |

### HeroCheckboxGroupScope

Shares the group's selection and states with its checkboxes (`value`, `toggle`, `variant`,
`isDisabled`, `isReadOnly`, `isRequired`, `isInvalid`, `validationErrors`, `itemMargin`).
