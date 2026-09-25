# Fieldset

Group related form controls with legends, descriptions, and actions.

HeroUI docs: [heroui.com/en/docs/react/components/fieldset](https://heroui.com/en/docs/react/components/fieldset)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroForm(
  onSubmit: (Map<String, Object?> data) => showSuccess(),
  child: SizedBox(
    width: 384,
    child: HeroFieldset(
      children: <Widget>[
        const HeroFieldsetLegend.text('Profile Settings'),
        const HeroDescription.text('Update your profile information.'),
        HeroFieldGroup(
          children: <Widget>[
            HeroTextField(
              name: 'name',
              isRequired: true,
              validator: (String? value) => (value ?? '').length < 3
                  ? 'Name must be at least 3 characters'
                  : null,
              children: const <Widget>[
                HeroLabel.text('Name'),
                HeroInput(placeholder: 'John Doe'),
                HeroFieldError(),
              ],
            ),
            const HeroTextField(
              name: 'email',
              type: HeroInputType.email,
              isRequired: true,
              children: <Widget>[
                HeroLabel.text('Email'),
                HeroInput(placeholder: 'john@example.com'),
                HeroFieldError(),
              ],
            ),
            HeroTextField(
              name: 'bio',
              isRequired: true,
              validator: (String? value) => (value ?? '').length < 10
                  ? 'Bio must be at least 10 characters'
                  : null,
              children: const <Widget>[
                HeroLabel.text('Bio'),
                HeroTextArea(placeholder: 'Tell us about yourself...'),
                HeroDescription.text('Minimum 10 characters'),
                HeroFieldError(),
              ],
            ),
          ],
        ),
        const HeroFieldsetActions(
          children: <Widget>[
            HeroButton(
              type: HeroButtonType.submit,
              startContent: HeroIcon(HeroIcons.floppyDisk),
              child: Text('Save changes'),
            ),
            HeroButton(
              type: HeroButtonType.reset,
              variant: HeroButtonVariant.secondary,
              child: Text('Cancel'),
            ),
          ],
        ),
      ],
    ),
  ),
)
```

The same structure from the convenience parameters:

```dart
HeroFieldset(
  legend: 'Profile Settings',
  description: 'Update your profile information.',
  actions: <Widget>[
    HeroButton(onPressed: save, child: const Text('Save changes')),
  ],
  children: const <Widget>[
    HeroFieldGroup(
      children: <Widget>[
        HeroTextField(label: 'Name', name: 'name'),
        HeroTextField(label: 'Email', name: 'email'),
      ],
    ),
  ],
)
```

## Anatomy

```dart
HeroFieldset(
  children: <Widget>[
    HeroFieldsetLegend.text('...'),
    HeroDescription.text('...'),
    HeroFieldsetGroup(
      children: <Widget>[
        // form fields go here
      ],
    ),
    HeroFieldsetActions(
      children: <Widget>[
        // action buttons go here
      ],
    ),
  ],
)
```

| Part | HeroUI | Look |
| --- | --- | --- |
| `HeroFieldset` | `Fieldset` / `Fieldset.Root` | Column with a 24 px gap (`gap-6`); fills the available width. |
| `HeroFieldsetLegend` | `Fieldset.Legend` | `text-base font-medium` in `--foreground`. Like a browser `<legend>` it sits on top of the content with no gap after it. |
| `HeroFieldsetGroup` / `HeroFieldGroup` | `Fieldset.Group` / `FieldGroup` | Full width, 16 px between fields (`space-y-4`); fields stretch to its width. |
| `HeroFieldsetActions` | `Fieldset.Actions` | Row of actions, centred, 8 px apart, 4 px top padding (`flex items-center gap-2 pt-1`); wraps when it does not fit. |

In a CSS flex row HeroUI's fieldset grows to share the space (`grow basis-0`);
wrap it in `Expanded` for the same effect.

## Disabled

`isDisabled` works like `<fieldset disabled>`: every control inside the
fieldset is disabled. Text fields and inputs stop editing and leave the focus
order, buttons, links and toggles stop responding, and all of them fade to the
disabled opacity and are announced as disabled; labels dim. Disabled fields are
not validated and not submitted by a `HeroForm`. The legend and descriptions
keep their look.

The fieldset publishes a `HeroDisabledScope`, which any widget can use to
disable the hero_ui controls below it. A nested scope cannot re-enable the
controls of a disabled fieldset.

```dart
HeroFieldset(
  legend: 'Billing',
  isDisabled: true,
  children: const <Widget>[
    HeroFieldGroup(children: <Widget>[HeroTextField(label: 'Card number')]),
  ],
)
```

## Examples

### In Surface

Inside a [Surface](surface.md), use `variant: HeroFieldVariant.secondary` on
the form controls for the lower emphasis look suited to surface backgrounds.

```dart
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: SizedBox(
    width: 380,
    child: HeroForm(
      child: HeroFieldset(
        children: <Widget>[
          const HeroFieldsetLegend.text('Profile Settings'),
          const HeroDescription.text('Update your profile information.'),
          HeroFieldsetGroup(
            children: const <Widget>[
              HeroTextField(
                name: 'name',
                children: <Widget>[
                  HeroLabel.text('Name'),
                  HeroInput(
                    placeholder: 'John Doe',
                    variant: HeroFieldVariant.secondary,
                  ),
                ],
              ),
            ],
          ),
          const HeroFieldsetActions(
            children: <Widget>[
              HeroButton(
                type: HeroButtonType.submit,
                child: Text('Save changes'),
              ),
              HeroButton(
                type: HeroButtonType.reset,
                variant: HeroButtonVariant.tertiary,
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
)
```

### Customization

`padding` and `decoration` style the fieldset shell (HeroUI's `className`),
`HeroFieldsetLegend.style` and `HeroDescription.style` the texts, and
`HeroFieldStyle` the inputs:

```dart
HeroFieldset(
  padding: EdgeInsets.all(theme.spacing(4)),
  decoration: ShapeDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xE6FAFAFA), Color(0xFFFFFFFF)],
    ),
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: theme.colors.border.withValues(alpha: 0.7)),
    ),
    shadows: const <BoxShadow>[
      BoxShadow(color: Color(0x0D000000), spreadRadius: 1),
    ],
  ),
  children: <Widget>[
    const HeroFieldsetLegend.text(
      'Profile Settings',
      style: TextStyle(color: Color(0xFF262626)),
    ),
    const HeroDescription.text(
      'Update your profile information.',
      style: TextStyle(color: Color(0xFF525252)),
    ),
    HeroFieldsetGroup(
      children: <Widget>[
        HeroTextField(
          name: 'name',
          children: <Widget>[
            const HeroLabel.text('Name'),
            HeroInput(placeholder: 'John Doe', style: fieldStyle),
          ],
        ),
      ],
    ),
  ],
)
```

Spacing overrides: `HeroFieldset.spacing` (gap between parts),
`HeroFieldsetGroup.spacing` (between fields), `HeroFieldsetActions.spacing`
and `alignment` (for example `WrapAlignment.end` for `justify-end`).

## Accessibility

- The fieldset is a semantics group named by its legend text (or
  `semanticLabel`), like `<fieldset>` named by its `<legend>`; the legend is
  announced once, as the group name.
- A disabled fieldset disables every control inside it: they are removed from
  the focus order and announced as disabled.
- Fields inside keep their own labels, descriptions and errors.

## API

### HeroFieldset

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Parts: legend, description, groups, actions or any widget. |
| `legend` | `String?` | – | Legend text, placed first. |
| `description` | `String?` | – | Description text, placed after the legend. |
| `actions` | `List<Widget>?` | – | Actions placed in a `HeroFieldsetActions` after `children`. |
| `isDisabled` | `bool` | `false` | Disables every control inside (`<fieldset disabled>`). |
| `spacing` | `double?` | `24` | Gap between the parts (`gap-6`). |
| `padding` | `EdgeInsetsGeometry?` | – | Padding inside the decoration. |
| `decoration` | `Decoration?` | – | Shell painted behind the fieldset. |
| `legendStyle` | `TextStyle?` | – | Style of the `legend` text. |
| `semanticLabel` | `String?` | legend text | Accessibility label of the group. |

### HeroFieldsetLegend

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` / `data` (`.text`) | `Widget` / `String` | required | Legend content. The text of `.text` names the fieldset. |
| `style` | `TextStyle?` | – | Merged over `text-base font-medium` `--foreground`. |

### HeroFieldsetGroup (`HeroFieldGroup`)

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The fields. |
| `spacing` | `double?` | `16` | Gap between fields (`space-y-4`). |

### HeroFieldsetActions

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The actions. |
| `spacing` | `double?` | `8` | Gap between actions (`gap-2`). |
| `alignment` | `WrapAlignment` | `start` | Horizontal alignment. |
| `padding` | `EdgeInsetsGeometry?` | `4` top | Padding around the actions (`pt-1`). |

### HeroDisabledScope

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The subtree. |
| `isDisabled` | `bool` | `true` | Whether the controls below are disabled. |
| `HeroDisabledScope.of(context)` | `bool` | – | Whether an enclosing scope disables controls. |
