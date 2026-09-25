# Switch

A toggle switch component for boolean states.

HeroUI docs: [heroui.com/en/docs/react/components/switch](https://heroui.com/en/docs/react/components/switch)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroSwitch(
  children: <Widget>[
    HeroSwitchContent(
      children: <Widget>[HeroSwitchControl(), Text('Enable notifications')],
    ),
  ],
)
```

The same switch from the convenience parameters:

```dart
const HeroSwitch(label: 'Enable notifications')
```

## Anatomy

```dart
HeroSwitch(
  children: <Widget>[
    HeroSwitchContent( // the pressable row: control + label
      children: <Widget>[
        HeroSwitchControl( // the track
          child: HeroSwitchThumb( // the default child
            child: HeroSwitchIcon(child: HeroIcon(HeroIcons.check)), // optional
          ),
        ),
        Text('Label'),
      ],
    ),
    HeroDescription.text('...'), // optional
    HeroFieldError(), // optional
  ],
)
```

HeroUI's docs snippet places `Switch.Control` outside `Switch.Content`; the demos and the
source put it inside, which is followed here. Put the label before the control for a leading
label (`labelPosition: HeroSwitchLabelPosition.start` with the convenience parameters).

`HeroSwitchGroup` lays several switches out in a column or a row.

## Styles

| Size | Track | Thumb | Description indent |
| --- | --- | --- | --- |
| `sm` | 32 × 16, radius 8 | 16.5 × 12, radius 6 | 44 |
| `md` (default) | 40 × 20, radius 12 | 22 × 16, radius 8 | 52 |
| `lg` | 48 × 24, radius 12 | 27.5 × 20, radius 12 | 60 |

| State | Style |
| --- | --- |
| Off | track `--default`; thumb white with the field shadow, 2 px from the start |
| On | track `--accent`; thumb `--accent-foreground` with a lifted shadow, 2 px from the end |
| Hover / pressed | off: track 80% opaque; on: `--accent-hover` (hovering anywhere over the field) |
| Keyboard focus | focus ring with a 2 px offset around the track |
| Disabled | the field at `--disabled-opacity`; an off thumb `--default-foreground` at 20%, an on thumb 40% opaque |

The thumb slides over 300 ms with `ease-out-fluid`, its color changes over 200 ms and the
track color over 250 ms (`ease`); nothing animates under reduced motion. Like an iOS switch,
the thumb also follows a horizontal drag; releasing past the middle, or flicking, toggles the
switch. Thumb icons are 12 px, black while off and `--accent` while on.

## Examples

### Sizes

```dart
const Row(
  spacing: 24,
  children: <Widget>[
    HeroSwitch(size: HeroSize.sm, label: 'Small'),
    HeroSwitch(size: HeroSize.md, label: 'Medium'),
    HeroSwitch(size: HeroSize.lg, label: 'Large'),
  ],
)
```

### With icons

```dart
HeroSwitch(
  size: HeroSize.lg,
  defaultSelected: true,
  semanticLabel: 'Dark mode',
  builder: (BuildContext context, HeroSwitchState state) => <Widget>[
    HeroSwitchContent(
      children: <Widget>[
        HeroSwitchControl(
          child: HeroSwitchThumb(
            child: HeroSwitchIcon(
              child: state.isSelected
                  ? const HeroIcon(HeroIcons.sun)
                  : const Opacity(opacity: 0.7, child: HeroIcon(HeroIcons.moon)),
            ),
          ),
        ),
      ],
    ),
  ],
)
```

### Disabled, without label, with description, default selected

```dart
const HeroSwitch(isDisabled: true, label: 'Enable notifications')

const HeroSwitch(
  semanticLabel: 'Enable notifications',
  children: <Widget>[
    HeroSwitchContent(children: <Widget>[HeroSwitchControl()]),
  ],
)

const HeroSwitch(
  label: 'Public profile',
  description: 'Allow others to see your profile information',
)

const HeroSwitch(defaultSelected: true, label: 'Enable notifications')
```

### Controlled

```dart
HeroSwitch(
  label: 'Enable notifications',
  isSelected: isSelected,
  onChanged: (bool value) => setState(() => isSelected = value),
)
```

### Label position

```dart
const HeroSwitch(
  label: 'Label before',
  labelPosition: HeroSwitchLabelPosition.start,
)
```

### Group

```dart
const HeroSwitchGroup(
  children: <Widget>[
    HeroSwitch(name: 'notifications', label: 'Allow Notifications'),
    HeroSwitch(name: 'marketing', label: 'Marketing emails'),
    HeroSwitch(name: 'social', label: 'Social media updates'),
  ],
)

const SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: HeroSwitchGroup(
    orientation: Axis.horizontal,
    children: <Widget>[/* switches */],
  ),
)
```

### Form integration

A switch that is on submits its `value` (`'on'` by default) under its `name`; switches that
are off are left out.

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => debugPrint('$data'),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      HeroSwitchGroup(
        children: <Widget>[
          HeroSwitch(name: 'notifications', label: 'Enable notifications'),
          HeroSwitch(
            name: 'newsletter',
            defaultSelected: true,
            label: 'Subscribe to newsletter',
          ),
        ],
      ),
      HeroButton(
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
HeroSwitch(
  builder: (BuildContext context, HeroSwitchState state) => <Widget>[
    HeroSwitchContent(
      children: <Widget>[
        const HeroSwitchControl(),
        Text(state.isSelected ? 'Enabled' : 'Disabled'),
      ],
    ),
  ],
)
```

### Render function

React's `render` prop replaces the DOM element; a Flutter switch is composed like any other
widget, so the example is identical to the basic one.

### Customization

`HeroSwitchControl` takes the track colors (HeroUI's `--switch-control-bg*` variables):
`color`, `hoverColor`, `selectedColor` and `selectedHoverColor`.

```dart
HeroSwitch(
  children: <Widget>[
    HeroSwitchContent(
      children: <Widget>[
        HeroSwitchControl(
          selectedColor: theme.colors.success,
          selectedHoverColor: theme.colors.success,
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: <Widget>[
            HeroLabel.text('Auto-save drafts'),
            HeroDescription.text('Changes are saved as you type.'),
          ],
        ),
      ],
    ),
  ],
)
```

## Validation

The switch is a `FormField<bool>` of the nearest `Form`, like `HeroCheckbox`: `isRequired`
("Please check this box if you want to proceed." while off, native only), `validator`,
`validationErrors` and `isInvalid`; errors show after a toggle or a submission with the native
behaviour, and in realtime with aria. HeroUI has no invalid style for the track; the
`HeroFieldError` shows the message in `--muted`.

## Accessibility

- The content is one switch node (toggled on or off), labelled by its text (or
  `semanticLabel`) and described by the description and, while invalid, the error.
- Space toggles the focused switch (Enter does not); Tab reaches it. The focus ring shows for
  keyboard focus only.
- A `HeroLabel` inside the switch toggles it when pressed.

## API

### HeroSwitch

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | The parts. |
| `builder` | `HeroSwitchBuilder?` | – | Builds the parts from `HeroSwitchState`; wins over `children`. |
| `label` | `String?` | – | Label of the built switch. |
| `description` | `String?` | – | Description of the built switch. |
| `errorMessage` | `String?` | – | Error of the built switch; defaults to the validation messages. |
| `labelPosition` | `HeroSwitchLabelPosition` | `end` | Label after or before the built control. |
| `size` | `HeroSize` | `md` | Size of the control. |
| `isSelected` | `bool?` | – | On (controlled). |
| `defaultSelected` | `bool` | `false` | Initially on (uncontrolled). |
| `onChanged` | `ValueChanged<bool>?` | – | Called when the user toggles the switch. |
| `onPressed` | `VoidCallback?` | – | Called when the switch is pressed. |
| `isDisabled` | `bool` | `false` | Disables the switch. |
| `isReadOnly` | `bool` | `false` | Focusable but not toggleable. |
| `isRequired` | `bool` | `false` | Must be on (native validation). |
| `isInvalid` | `bool?` | – | Overrides the displayed validation. |
| `name` | `String?` | – | Key in the `HeroForm` data. |
| `value` | `String?` | `'on'` | Submitted value. |
| `validator` | `FormFieldValidator<bool>?` | – | Custom validation. |
| `validationBehavior` | `HeroValidationBehavior?` | form, then `native` | When errors show. |
| `validationErrors` | `List<String>?` | – | Server-side errors. |
| `validationMessages` | `HeroValidationMessages` | English | Built-in messages. |
| `onSaved` | `FormFieldSetter<bool>?` | – | Called when the form saves. |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | Native: show errors before a change. |
| `focusNode` | `FocusNode?` | – | Focus of the content. |
| `autofocus` | `bool` | `false` | Focus on first build. |
| `semanticLabel` | `String?` | label text | Accessibility label (`aria-label`). |

### HeroSwitchState

`isSelected`, `isHovered`, `isPressed`, `isFocused`, `isFocusVisible`, `isDisabled`,
`isReadOnly`, `isInvalid`, `isRequired` (all `bool`).

### HeroSwitchContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | The control and the label. |
| `builder` | `HeroToggleContentBuilder?` | – | Builds the parts from the `HeroInteractionState`. |
| `spacing` | `double?` | `12` | Gap between the parts. |
| `padding` | `EdgeInsetsGeometry?` | – | Padding around the parts. |
| `decoration` | `WidgetStateProperty<Decoration?>?` | – | Background by state. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Vertical alignment. |
| `fullWidth` | `bool` | `false` | Fill the available width. |

### HeroSwitchControl

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `HeroSwitchThumb()` | The thumb. |
| `color` | `Color?` | `--default` | Track while off. |
| `hoverColor` | `Color?` | `color` at 80% | Track while off and hovered or pressed. |
| `selectedColor` | `Color?` | `--accent` | Track while on. |
| `selectedHoverColor` | `Color?` | `selectedColor`, else `--accent-hover` | Track while on and hovered or pressed. |

### HeroSwitchThumb / HeroSwitchIcon

| Widget | Parameter | Description |
| --- | --- | --- |
| `HeroSwitchThumb` | `child` | Content drawn on the thumb, usually a `HeroSwitchIcon`. |
| `HeroSwitchIcon` | `child` (required) | An icon centred on the thumb. |

### HeroSwitchGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The switches. |
| `orientation` | `Axis` | `vertical` | Column or row. |
| `spacing` | `double?` | `16` | Gap between the switches. |

`HeroSwitchScope`, `HeroSwitchThumbScope` and `HeroSwitchMetrics` share the switch state,
the thumb position and the size geometry with the parts.
