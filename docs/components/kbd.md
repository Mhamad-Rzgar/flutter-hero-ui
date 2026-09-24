# Kbd

Display keyboard shortcuts and key combinations.

HeroUI reference: [Kbd](https://heroui.com/en/docs/react/components/kbd)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: const <Widget>[
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K'),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.shift], text: 'P'),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.ctrl], text: 'C'),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.option], text: 'D'),
  ],
)
```

## Anatomy

```dart
const HeroKbd(
  children: <Widget>[
    HeroKbdAbbr(HeroKbdKey.command),
    HeroKbdContent(Text('K')),
  ],
)
```

| HeroUI | Flutter |
| --- | --- |
| `Kbd` | `HeroKbd` (`keys` + `text` shorthand, or `children`) |
| `Kbd.Abbr` | `HeroKbdAbbr(keyValue)` |
| `Kbd.Content` | `HeroKbdContent(child)` |

The docs describe `Kbd.Abbr` with a `title` and children and list a `Kbd.Key` part; the
component renders a symbol from its built-in key map (`keyValue`) plus `Kbd.Content`, which
is what hero_ui follows.

## Keys

`HeroKbdKey` holds HeroUI's key map; each value has a `symbol` and an accessible `label`.

| Key | Symbol | Label | Key | Symbol | Label |
| --- | --- | --- | --- | --- | --- |
| `command` | ⌘ | Command | `up` | ↑ | Up |
| `shift` | ⇧ | Shift | `down` | ↓ | Down |
| `ctrl` | ⌃ | Control | `left` | ← | Left |
| `option` | ⌥ | Option | `right` | → | Right |
| `alt` | ⌥ | Alt | `pageup` | ⇞ | Page Up |
| `win` | ⌘ | Win | `pagedown` | ⇟ | Page Down |
| `enter` | ↵ | Enter | `home` | ↖ | Home |
| `delete` | ⌫ | Delete | `end` | ↘ | End |
| `escape` | ⎋ | Escape | `help` | ? | Help |
| `tab` | ⇥ | Tab | `space` | ␣ | Space |
| `capslock` | ⇪ | Caps Lock | `fn` | Fn | Fn |

## Variants

| Variant | Look |
| --- | --- |
| `HeroKbdVariant.standard` (default) | `defaultColor` fill, radius `lg` (8) |
| `HeroKbdVariant.light` | No fill |

Both use 14 px medium text in `muted`, 8 px horizontal padding, a minimum height of 24 and
2 px between parts.

## Examples

### Variants

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 8,
  children: const <Widget>[
    Text('Copy:'),
    HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'C'),
    HeroKbd(
      keys: <HeroKbdKey>[HeroKbdKey.command],
      text: 'C',
      variant: HeroKbdVariant.light,
    ),
  ],
)
```

### Inline usage

`HeroKbd.span` wraps a key in a baseline-aligned `WidgetSpan`:

```dart
Text.rich(
  TextSpan(
    children: <InlineSpan>[
      const TextSpan(text: 'Press '),
      HeroKbd.span(const HeroKbd(text: 'Esc')),
      const TextSpan(text: ' to close the dialog.'),
    ],
  ),
)
```

### Special keys

```dart
const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.shift, HeroKbdKey.tab])
```

### Customization

```dart
HeroKbd(
  keys: const <HeroKbdKey>[HeroKbdKey.command],
  text: 'K',
  backgroundColor: theme.colors.accentSoft,
  foregroundColor: theme.colors.accentSoftForeground,
  padding: const EdgeInsets.symmetric(horizontal: 10),
)
```

## Accessibility

- A key is read as one label, for example "Command Shift Z": `HeroKbdAbbr` announces the key
  name (the `title` of HeroUI's `<abbr>`) instead of the symbol.
- The parts are laid out in reading order, so right-to-left layouts reverse them like
  `rtl:space-x-reverse`.
- The minimum height grows with the text scale.

## API

### HeroKbd

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | `List<HeroKbdKey>` | `[]` | Keys shown first, as `HeroKbdAbbr`s. |
| `text` | `String?` | `null` | Text shown after the keys, as a `HeroKbdContent`. |
| `children` | `List<Widget>` | `[]` | Parts shown after `keys` and `text`. |
| `variant` | `HeroKbdVariant` | `standard` | Visual variant. |
| `backgroundColor` | `Color?` | `null` | Overrides the fill. |
| `foregroundColor` | `Color?` | `null` | Overrides the text color. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Overrides the 8 px horizontal padding. |

`HeroKbd.span(HeroKbd kbd)` returns a baseline-aligned inline span.

### HeroKbdAbbr

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keyValue` | `HeroKbdKey` | required | The key (positional). |

### HeroKbdContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The content (positional), usually a `Text`. |

### HeroKbdKey

Enum with `symbol` and `label` getters (HeroUI's `kbdKeysMap` and `kbdKeysLabelMap`).
