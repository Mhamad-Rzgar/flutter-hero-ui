# Label

Renders an accessible label associated with form controls.

HeroUI docs: [heroui.com/en/docs/react/components/label](https://heroui.com/en/docs/react/components/label)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
// A FocusNode owned by your State (dispose it in dispose()).
final FocusNode nameFocus = FocusNode();

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[
    HeroLabel.text('Name', focusNode: nameFocus),
    HeroInput(focusNode: nameFocus, width: 256, placeholder: 'Enter your name'),
  ],
)
```

Pressing the label focuses the control whose `FocusNode` it is given (the
counterpart of `htmlFor`).

## Anatomy

A single widget: `HeroLabel(child: ...)` or `HeroLabel.text('...')`. Inside a
field root (TextField, Checkbox group, ...) the label reads the field's
`HeroFieldScope`, so it picks up the required, disabled and invalid states and
the control to focus without extra parameters.

## Styles

| State | Style |
| --- | --- |
| Base | `text-sm` (14/20), `font-medium`, `--foreground` |
| Required | `*` in `--danger` with a 2 px start margin (`ms-0.5`) |
| Disabled | `--disabled-opacity` (0.5) |
| Invalid | text in `--danger` |

The asterisk appears when the label is required, or when the enclosing field
is required and shows its required indicator (group roots do; single checkbox
and radio items do not).

## Examples

### With required indicator

```dart
HeroLabel.text('Email Address', focusNode: emailFocus, isRequired: true),
HeroInput(focusNode: emailFocus, type: HeroInputType.email),
```

### With disabled state

```dart
HeroLabel.text('Username', focusNode: usernameFocus, isDisabled: true),
HeroInput(focusNode: usernameFocus, isDisabled: true),
```

### With invalid state

```dart
HeroLabel.text('Password', focusNode: passwordFocus, isInvalid: true),
HeroInput(focusNode: passwordFocus, isInvalid: true),
```

### Customization

`style` is merged over the label style (like `className`); its color wins over
the invalid color.

```dart
HeroLabel.text(
  'REPOSITORY',
  focusNode: repoFocus,
  style: theme.typography
      .style(HeroFontSize.xs, weight: HeroTypography.semibold, tracking: 0.025)
      .copyWith(color: theme.colors.accent),
)
```

## Accessibility

- The label text is exposed to assistive technologies; the asterisk is not
  (the control reports its required state itself).
- Inside a field whose control is labelled through `HeroFieldScope.semanticLabel`
  the label is excluded, so it is not announced twice.
- Pressing the label focuses or activates the associated control; the label is
  not focusable itself.
- In right-to-left layouts the asterisk follows the text on the left.

## API

### HeroLabel

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Label content; text inherits the label style. |
| `data` (`HeroLabel.text`) | `String` | required | Label text. |
| `isRequired` | `bool?` | from field, else `false` | Shows the required asterisk. |
| `isDisabled` | `bool?` | from field, else `false` | Disabled look. |
| `isInvalid` | `bool?` | from field, else `false` | Invalid look. |
| `focusNode` | `FocusNode?` | from field | Control focused on press (`htmlFor`). |
| `onPressed` | `VoidCallback?` | from field | Action on press; wins over `focusNode`. |
| `style` | `TextStyle?` | – | Style merged over the label style. |
