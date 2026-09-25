# Disclosure

A disclosure is a collapsible section with a header containing a heading and a trigger
button, and a panel that wraps the content.

HeroUI reference: <https://heroui.com/en/docs/react/components/disclosure>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
bool isExpanded = true;

HeroDisclosure(
  isExpanded: isExpanded,
  onExpandedChanged: (bool value) => setState(() => isExpanded = value),
  children: <Widget>[
    HeroDisclosureHeading(
      child: Center(
        child: HeroDisclosureTrigger.builder(
          builder: (BuildContext context, HeroDisclosureState state) =>
              HeroButton(
                variant: HeroButtonVariant.secondary,
                onPressed: state.toggle,
                startContent: const HeroIcon(HeroIcons.qrCode),
                endContent: const HeroDisclosureIndicator(),
                child: const Text('Preview HeroUI Native'),
              ),
        ),
      ),
    ),
    HeroDisclosureContent(
      child: HeroDisclosureBody(
        child: HeroSurface(
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: const EdgeInsets.all(16),
          child: const Text('Scan this QR code with your camera app ...'),
        ),
      ),
    ),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `Disclosure` | `HeroDisclosure` |
| `Disclosure.Heading` | `HeroDisclosureHeading` |
| `Disclosure.Trigger` | `HeroDisclosureTrigger` |
| `<Button slot="trigger">` | `HeroDisclosureTrigger.builder` returning a `HeroButton` whose `onPressed` is `state.toggle` |
| `Disclosure.Indicator` | `HeroDisclosureIndicator` |
| `Disclosure.Content` | `HeroDisclosureContent` |
| `Disclosure.Body` | `HeroDisclosureBody` |

`HeroDisclosure.of(context)` returns the state of the enclosing disclosure (`isExpanded`,
`isDisabled`, `toggle()`, `expand()`, `collapse()`), so any widget inside it can drive it.

## Styles

- **Heading:** spans the disclosure and holds the trigger at its start, at its natural
  width; wrap the trigger in a `Center` to center it.
- **Trigger:** no fill of its own; keyboard focus shows the focus ring, disabled triggers
  fade to 50%.
- **Indicator:** 16 px chevron in the surrounding icon color, turned upside down while
  expanded (250 ms).
- **Content:** height (200 ms, ease-out-quad) and opacity (200 ms, ease-out) transitions,
  clipped.
- **Body:** 8 px padding.

## Examples

### Render function

`builder` receives the disclosure state instead of fixed `children`:

```dart
HeroDisclosure(
  builder: (BuildContext context, HeroDisclosureState state) => Column(
    children: <Widget>[
      heading,
      HeroDisclosureContent(
        builder: (BuildContext context, HeroDisclosureState state) =>
            Text(state.isExpanded ? 'Shown' : 'Hidden'),
      ),
    ],
  ),
)
```

### Customization

```dart
HeroDisclosureTrigger.builder(
  builder: (BuildContext context, HeroDisclosureState state) => HeroButton(
    variant: HeroButtonVariant.ghost,
    fullWidth: true,
    onPressed: state.toggle,
    style: HeroButtonStyle(
      borderRadius: BorderRadius.circular(theme.radii.xl),
      side: BorderSide(color: colors.border.withValues(alpha: 0.7)),
      backgroundColor: WidgetStatePropertyAll<Color>(colors.surface),
    ),
    child: Row(
      spacing: 8,
      children: <Widget>[
        HeroIcon(HeroIcons.shoppingBag, color: colors.muted),
        const Text('Shipping details'),
        const Spacer(),
        HeroDisclosureIndicator(color: colors.muted),
      ],
    ),
  ),
)
```

## Behavior

- Pressing the trigger, Enter or Space toggles the content. `isExpanded` +
  `onExpandedChanged` control it; `defaultExpanded` sets the initial state.
- Disabled disclosures ignore toggles.
- Collapsed content is removed from focus traversal and semantics; under reduced motion it
  opens and closes instantly.

## Accessibility

- The heading is announced as a heading; the trigger as a button with an expanded state
  (for `HeroDisclosureTrigger.builder`, the built control is merged with that state).
- The indicator is decorative.

## API

### HeroDisclosure

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Heading and content parts. |
| `builder` | `HeroDisclosureWidgetBuilder?` | `null` | Builds the parts from the state. |
| `id` | `Object?` | `null` | Identifies the disclosure in a group. |
| `isExpanded` | `bool?` | `null` | Controlled expansion. |
| `defaultExpanded` | `bool` | `false` | Initial expansion when uncontrolled. |
| `onExpandedChanged` | `ValueChanged<bool>?` | `null` | Called with the new expansion. |
| `isDisabled` | `bool` | `false` | Ignore toggles. |

### HeroDisclosureHeading

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The trigger. |

### HeroDisclosureTrigger

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Content of the plain trigger. |
| `semanticLabel` | `String?` | content text | Accessibility label. |
| `builder` | `HeroDisclosureWidgetBuilder` | required | `HeroDisclosureTrigger.builder`: builds the control acting as the trigger. |

### HeroDisclosureIndicator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | chevron | Custom icon. |
| `color` | `Color?` | surrounding icon color | Icon color. |

### HeroDisclosureContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Content, usually a `HeroDisclosureBody`. |
| `builder` | `HeroDisclosureWidgetBuilder?` | `null` | Builds the content from the state. |

### HeroDisclosureBody

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Content. |
| `padding` | `EdgeInsetsGeometry?` | 8 all round | Padding. |

### HeroDisclosureState

| Member | Description |
| --- | --- |
| `isExpanded` | Whether the content is shown. |
| `isDisabled` | Whether toggles are ignored. |
| `toggle()` / `expand()` / `collapse()` | Change the expansion. |
