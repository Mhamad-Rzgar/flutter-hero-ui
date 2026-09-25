# RadioGroup

Radio group for selecting a single option from a list.

HeroUI docs: [heroui.com/en/docs/react/components/radio-group](https://heroui.com/en/docs/react/components/radio-group)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
const HeroRadioGroup(
  name: 'plan',
  defaultValue: 'premium',
  label: 'Plan selection',
  description: 'Choose the plan that suits you best',
  children: <Widget>[
    HeroRadio(
      value: 'basic',
      label: 'Basic Plan',
      description: 'Includes 100 messages per month',
    ),
    HeroRadio(
      value: 'premium',
      label: 'Premium Plan',
      description: 'Includes 200 messages per month',
    ),
    HeroRadio(
      value: 'business',
      label: 'Business Plan',
      description: 'Unlimited messages',
    ),
  ],
)
```

## Anatomy

```dart
HeroRadioGroup(
  children: <Widget>[
    HeroLabel.text('...'),
    HeroDescription.text('...'),
    HeroRadio(
      value: 'option1',
      children: <Widget>[
        HeroRadioContent( // the pressable row: control + label
          children: <Widget>[
            HeroRadioControl(
              child: HeroRadioIndicator(), // the default child
            ),
            Text('Label'),
          ],
        ),
        HeroDescription.text('...'), // indented under the label
        HeroFieldError(), // optional per-radio message
      ],
    ),
    HeroFieldError(), // optional group message
  ],
)
```

`label`, `description` and `errorMessage` on the group, and `label` and `description` on a
radio, are shortcuts for these parts. Radios can be nested in other widgets (a grid of cards,
for example).

## Styles

| Part | Style |
| --- | --- |
| Group | vertical: column, every radio 16 px below the previous part (`itemMargin`); horizontal: wrapping row with a 16 px gap (`spacing`) |
| Radio | column with a 4 px gap; description and error indented 28 px under the label, the error in `--muted`; disabled at `--disabled-opacity` (help text dimmed once more) |
| Content | control and label in a row with a 12 px gap, `text-sm font-medium` |
| Control | 16 px, `rounded-lg` (a circle), `--field-background`, field shadow; secondary: `--default`, no shadow |
| Selected | control `--accent` (`--accent-hover` while pressed); the indicator shrinks to a 43% `--accent-foreground` dot (57% while pressed) over 200 ms |
| Hover | `--field-border-hover`; an unselected indicator turns `--field-hover` (`--default-hover` for secondary) |
| Pressed | the control scales to 95% (100 ms) |
| Invalid | 1 px `--danger` outline on every radio; the group label turns `--danger` |
| Keyboard focus | focus ring with a 2 px offset around the control |

## Variants

`variant` (`HeroFieldVariant.primary` by default, `secondary`) applies to every radio; use
`secondary` on surfaces. `orientation`: `Axis.vertical` (default) or `Axis.horizontal`.

## Examples

### Horizontal orientation

```dart
const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroLabel.text('Subscription plan'),
    HeroRadioGroup(
      name: 'plan-orientation',
      defaultValue: 'pro',
      orientation: Axis.horizontal,
      children: <Widget>[
        HeroRadio(value: 'starter', label: 'Starter', description: 'For side projects'),
        HeroRadio(value: 'pro', label: 'Pro', description: 'Advanced reporting'),
        HeroRadio(value: 'teams', label: 'Teams', description: 'Up to 10 teammates'),
      ],
    ),
  ],
)
```

### Variants, in Surface

```dart
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const HeroRadioGroup(
    name: 'plan-on-surface',
    defaultValue: 'premium',
    variant: HeroFieldVariant.secondary,
    label: 'Plan selection',
    children: <Widget>[/* radios */],
  ),
)
```

### Disabled

```dart
const HeroRadioGroup(
  name: 'plan-disabled',
  isDisabled: true,
  defaultValue: 'pro',
  label: 'Subscription plan',
  children: <Widget>[/* radios */],
)
```

A single radio can be disabled with `HeroRadio(isDisabled: true)`; the arrow keys skip it.

### Controlled and uncontrolled

```dart
HeroRadioGroup(
  name: 'plan-controlled',
  value: value,
  onChanged: (String next) => setState(() => value = next),
  label: 'Subscription plan',
  children: plans,
)

HeroRadioGroup(
  name: 'plan-uncontrolled',
  defaultValue: 'pro',
  onChanged: (String next) => setState(() => selection = next),
  label: 'Subscription plan',
  children: plans,
)
```

### Validation

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => debugPrint('${data['plan-validation']}'),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      HeroRadioGroup(
        name: 'plan-validation',
        isRequired: true,
        children: <Widget>[
          HeroLabel.text('Subscription plan'),
          HeroRadio(value: 'starter', label: 'Starter'),
          HeroRadio(value: 'pro', label: 'Pro'),
          HeroFieldError.text('Choose a subscription before continuing.'),
        ],
      ),
      HeroButton(type: HeroButtonType.submit, child: Text('Submit')),
    ],
  ),
)
```

### Delivery & payment

Card radios: `HeroRadioContent` with `fullWidth`, a state-dependent `decoration` (surface
card, 2 px accent border and accent/10 fill when selected) and a `HeroRadioControl` placed in
a `Stack`. The example overrides the theme (`HeroTheme` with a `#006FEE` accent and 2 px
field borders); the brand logos of the payment options are replaced by neutral icons.

```dart
HeroRadio(
  value: 'express',
  children: <Widget>[
    HeroRadioContent(
      fullWidth: true,
      decoration: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => ShapeDecoration(
          color: states.contains(WidgetState.selected)
              ? theme.colors.accent.withValues(alpha: 0.1)
              : theme.colors.surface,
          shape: theme.shapeAll(
            theme.radii.xl,
            side: BorderSide(
              width: 2,
              color: states.contains(WidgetState.selected)
                  ? theme.colors.accent
                  : const Color(0x00000000),
            ),
          ),
        ),
      ),
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text('Express'),
              ),
              PositionedDirectional(
                top: theme.spacing(3),
                end: theme.spacing(4),
                child: HeroRadioControl(size: theme.spacing(5)),
              ),
            ],
          ),
        ),
      ],
    ),
  ],
)
```

### Custom indicator

```dart
HeroRadioControl(
  child: HeroRadioIndicator(
    builder: (BuildContext context, HeroRadioState state) => state.isSelected
        ? Text(
            '✓',
            style: theme.typography.xs.copyWith(
              height: 1,
              color: theme.colors.background,
            ),
          )
        : null,
  ),
)
```

### Render function

React's `render` prop replaces the DOM element; the Flutter group is composed like any other
widget, so the example is identical to the basic one. `builder` receives the
`HeroRadioGroupState` (value, disabled, read-only, invalid, required); `HeroRadio(builder:)`
receives the `HeroRadioState`.

### Customization

```dart
HeroRadioControl(
  size: theme.spacing(5),
  borderRadius: BorderRadius.circular(theme.radii.full),
  selectedColor: theme.colors.success,
  pressedColor: theme.colors.successHover,
  side: BorderSide(color: theme.colors.border),
  child: HeroRadioIndicator(
    selectedColor: theme.colors.successForeground,
    selectedScale: 0.5,
    pressedScale: 0.57,
  ),
)
```

The group takes `spacing` (gap between parts) and `itemMargin` (the radios' `mt-4`).

## Validation

The group is a `FormField<String>` of the nearest `Form`:

| Source | Shown |
| --- | --- |
| `isInvalid: true` / `false` | always; overrides every other source |
| `validationErrors` (or the form's `validationErrors[name]`) | immediately; cleared once the user selects a radio |
| `validator` | native: after a selection or a form submission; aria: in realtime |
| `isRequired` | native only: "Please select one of these options." while nothing is selected |

The selected value is submitted under `name`; `reset()` restores the initial value.

## Accessibility

- The group is a radio group node labelled by its label (or `semanticLabel`) and described by
  its description and error; every radio is a checked or unchecked node in a mutually
  exclusive group, labelled by its text and described by its own description.
- The group is a single Tab stop: the selected radio, the last focused one, or the first
  enabled one. Up/Down and Left/Right move the focus and the selection to the previous or next
  enabled radio and wrap around; Left and Right are flipped in right-to-left horizontal groups.
  Space selects the focused radio. A read-only group moves the focus without selecting.

## API

### HeroRadioGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Radios and other parts. |
| `builder` | `HeroRadioGroupBuilder?` | – | Builds the parts from `HeroRadioGroupState`; replaces `children`. |
| `label` | `String?` | – | Label before the parts. |
| `description` | `String?` | – | Description after the label. |
| `errorMessage` | `String?` | – | Error after the parts, shown while invalid. |
| `value` | `String?` | – | Selected value (controlled; null leaves it to the group). |
| `defaultValue` | `String?` | – | Initial value (uncontrolled). |
| `onChanged` | `ValueChanged<String>?` | – | Called when the user selects a radio. |
| `variant` | `HeroFieldVariant` | `primary` | Variant of the radios. |
| `orientation` | `Axis` | `vertical` | Column or wrapping row. |
| `isDisabled` | `bool` | `false` | Disables every radio. |
| `isReadOnly` | `bool` | `false` | Focusable, selection fixed. |
| `isRequired` | `bool` | `false` | A selection is required. |
| `isInvalid` | `bool?` | – | Overrides the displayed validation. |
| `name` | `String?` | – | Key in the `HeroForm` data. |
| `validator` | `FormFieldValidator<String>?` | – | Custom validation. |
| `validationBehavior` | `HeroValidationBehavior?` | form, then `native` | When errors show. |
| `validationErrors` | `List<String>?` | – | Server-side errors. |
| `validationMessages` | `HeroValidationMessages` | English | Built-in messages. |
| `onSaved` | `FormFieldSetter<String>?` | – | Called when the form saves. |
| `autovalidateMode` | `AutovalidateMode?` | `disabled` | Native: show errors before a change. |
| `spacing` | `double?` | `0` / `16` | Gap between the parts (vertical / horizontal). |
| `itemMargin` | `EdgeInsetsGeometry?` | 16 px top | Space around every radio of a vertical group. |
| `fullWidth` | `bool` | `false` | Fill the available width. |
| `semanticLabel` | `String?` | label text | Accessibility label. |

### HeroRadio

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `String` | required | The group's value when selected. |
| `children` | `List<Widget>?` | – | The parts. |
| `builder` | `HeroRadioBuilder?` | – | Builds the parts from `HeroRadioState`. |
| `label` | `String?` | – | Label of the built radio. |
| `description` | `String?` | – | Description of the built radio. |
| `isDisabled` | `bool` | `false` | Disables this radio. |
| `focusNode` | `FocusNode?` | – | Focus of the content. |
| `autofocus` | `bool` | `false` | Focus on first build. |
| `semanticLabel` | `String?` | label text | Accessibility label. |

### HeroRadioContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | The control and the label. |
| `builder` | `HeroToggleContentBuilder?` | – | Builds the parts from the `HeroInteractionState`. |
| `spacing` | `double?` | `12` | Gap between the parts. |
| `padding` | `EdgeInsetsGeometry?` | – | Padding around the parts. |
| `decoration` | `WidgetStateProperty<Decoration?>?` | – | Background by state. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Vertical alignment. |
| `fullWidth` | `bool` | `false` | Fill the available width. |

### HeroRadioControl

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `HeroRadioIndicator()` | The indicator. |
| `size` | `double?` | `16` | Side length. |
| `borderRadius` | `BorderRadiusGeometry?` | `rounded-lg` (8) | Corner radii. |
| `color` | `Color?` | `--field-background` / `--default` | Unselected background. |
| `selectedColor` | `Color?` | `--accent` | Selected background. |
| `pressedColor` | `Color?` | `--accent-hover` | Selected and pressed background. |
| `side` | `BorderSide?` | field border | Border. |

### HeroRadioIndicator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | – | Custom content instead of the dot. |
| `builder` | `HeroRadioIndicatorBuilder?` | – | Builds custom content from `HeroRadioState`. |
| `color` | `Color?` | control background | Unselected dot. |
| `selectedColor` | `Color?` | `--accent-foreground` | Selected dot. |
| `selectedScale` | `double?` | `0.4286` | Selected dot scale. |
| `pressedScale` | `double?` | `0.5714` | Selected and pressed dot scale. |

### HeroRadioGroupState / HeroRadioState

| Field | Type | Description |
| --- | --- | --- |
| `value` (group) | `String?` | Selected value. |
| `isSelected` (radio) | `bool` | The radio is selected. |
| `isDisabled` | `bool` | Disabled. |
| `isReadOnly` | `bool` | Read-only. |
| `isInvalid` | `bool` | Shows as invalid. |
| `isRequired` | `bool` | Required. |

`HeroRadioGroupScope`, `HeroRadioGroupController` and `HeroRadioScope` share the group and
radio state with the parts.
