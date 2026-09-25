# ErrorMessage

A low-level error message component for displaying errors.

HeroUI reference: <https://heroui.com/en/docs/react/components/error-message>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Set<Object> selected = <Object>{};

HeroTagGroup(
  label: 'Required Categories',
  selectionMode: HeroSelectionMode.multiple,
  selectedKeys: selected,
  onSelectionChanged: (Set<Object> keys) => setState(() => selected = keys),
  children: <Widget>[
    const HeroTagGroupList(
      children: <Widget>[
        HeroTag(id: 'news', label: 'News'),
        HeroTag(id: 'travel', label: 'Travel'),
        HeroTag(id: 'gaming', label: 'Gaming'),
        HeroTag(id: 'shopping', label: 'Shopping'),
      ],
    ),
    const HeroDescription.text('Select at least one category'),
    if (selected.isEmpty)
      const HeroErrorMessage.text('Please select at least one category'),
  ],
)
```

`HeroErrorMessage` displays errors in **non-form components** such as `HeroTagGroup` and
calendars. It is not tied to any validation: it shows its content, and nothing when it has
none. `HeroTagGroup` also takes the text directly as `errorMessage`.

## Anatomy

```dart
HeroTagGroup(
  children: <Widget>[
    HeroLabel.text('...'),
    HeroTagGroupList(children: tags),
    HeroDescription.text('...'),
    HeroErrorMessage.text('...'),
  ],
)
```

## When to use

| Component | Use case | Form integration | Example components |
| --- | --- | --- | --- |
| `HeroErrorMessage` | Non-form components | No | `HeroTagGroup`, calendars |
| `HeroFieldError` | Form fields | Yes | `HeroTextField` and other fields |

## Styles

`text-xs` (12/16) in `--danger`, wrapping long words, no padding of its own. Inside a tag
group it gets 4 px of padding.

## Examples

### Customization

```dart
HeroErrorMessage.text(
  'Choose at least one topic',
  style: const TextStyle(fontWeight: HeroTypography.medium),
)
```

## Accessibility

The message is a polite live region, so assistive technologies announce it when it appears.

## API

### HeroErrorMessage

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | The content; null shows nothing. |
| `data` | `String` | required | The text, for `HeroErrorMessage.text`; empty shows nothing. |
| `style` | `TextStyle?` | `null` | Merged over the error style (`className`). |
