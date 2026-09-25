# Description

Provides supplementary text for form fields and other components.

HeroUI docs: [heroui.com/en/docs/react/components/description](https://heroui.com/en/docs/react/components/description)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[
    HeroLabel.text('Email', focusNode: emailFocus),
    HeroInput(
      focusNode: emailFocus,
      width: 256,
      placeholder: 'you@example.com',
      type: HeroInputType.email,
    ),
    const HeroDescription.text("We'll never share your email with anyone else."),
  ],
)
```

## Anatomy

A single widget: `HeroDescription(child: ...)` or `HeroDescription.text('...')`,
placed after the control of a field.

## Styles

| Part | Style |
| --- | --- |
| Text | `text-xs` (12/16), `--muted`, wraps and breaks long words |
| In an invalid TextField / SearchField / NumberField | not rendered (the error replaces it), through `HeroFieldScope.hideDescriptionWhenInvalid` |

## Examples

### With form fields

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[
    HeroLabel.text('Password', focusNode: passwordFocus),
    HeroInput(focusNode: passwordFocus, type: HeroInputType.password),
    const HeroDescription.text(
      'Must be at least 8 characters with one uppercase letter',
    ),
  ],
)
```

### Integration with TextField

```dart
HeroTextField(
  type: HeroInputType.email,
  children: const <Widget>[
    HeroLabel.text('Email'),
    HeroInput(placeholder: 'Enter your email'),
    HeroDescription.text("We'll never share your email"),
  ],
)
```

Inside a `HeroTextField` the label and description are linked to the input
automatically and announced with it.

### Customization

`style` is merged over the description style (like `className`).

```dart
HeroDescription.text(
  'Lowercase letters and hyphens only. Used in app.heroui.com/acme',
  // leading-relaxed tracking-wide
  style: theme.typography.style(
    HeroFontSize.xs,
    lineHeight: HeroFontSize.xs.fontSize * 1.625,
    tracking: 0.025,
  ),
)
```

## Accessibility

- Standalone, the description is read as text.
- Inside a field that passes its description as the control's semantics hint
  (`HeroFieldScope.semanticHint`), the description itself is excluded so it is
  announced once, with the control (`aria-describedby`).

## API

### HeroDescription

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Content; text inherits the description style. |
| `data` (`HeroDescription.text`) | `String` | required | Description text. |
| `style` | `TextStyle?` | – | Style merged over the description style. |
