# Accordion

A collapsible content panel for organizing information in a compact space.

HeroUI reference: <https://heroui.com/en/docs/react/components/accordion>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroAccordion(
  children: <Widget>[
    HeroAccordionItem(
      startContent: HeroIcon(HeroIcons.shoppingBag, color: theme.colors.muted),
      title: const Text('How do I place an order?'),
      child: const Text('Browse our products, add items to your cart, ...'),
    ),
    HeroAccordionItem(
      startContent: HeroIcon(HeroIcons.receipt, color: theme.colors.muted),
      title: const Text('Can I modify or cancel my order?'),
      child: const Text("Yes, you can modify or cancel your order before it's shipped."),
    ),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `Accordion` | `HeroAccordion` |
| `Accordion.Item` | `HeroAccordionItem` |
| `Accordion.Heading` | `HeroAccordionHeading` |
| `Accordion.Trigger` | `HeroAccordionTrigger` |
| `Accordion.Indicator` | `HeroAccordionIndicator` (the trigger's `indicator`) |
| `Accordion.Panel` | `HeroAccordionPanel` |
| `Accordion.Body` | `HeroAccordionBody` |

The convenience parameters of `HeroAccordionItem` (`title`, `startContent`, `indicator`,
`child`) build the heading, trigger, panel and body. Pass the parts as `children` to compose
them yourself:

```dart
HeroAccordionItem(
  children: <Widget>[
    HeroAccordionHeading(
      child: HeroAccordionTrigger(
        indicator: const HeroAccordionIndicator(),
        child: const Text('Getting Started'),
      ),
    ),
    const HeroAccordionPanel(
      child: HeroAccordionBody(child: Text('Learn the basics of HeroUI ...')),
    ),
  ],
)
```

## Styles

- **Item:** a 1 px `--separator` line along its bottom edge, except on the last item or with
  `hideSeparator`.
- **Trigger:** fills the width with 16 px padding, `text-sm` medium; the start content is
  12 px from the label and the indicator is pushed to the end. Hovering a collapsed trigger
  tints it with `--foreground` at 3%; keyboard focus shows the focus ring; disabled triggers
  fade to 50% over 150 ms.
- **Indicator:** 16 px chevron in `--muted`, turned upside down while expanded (250 ms).
- **Panel:** height (200 ms, ease-out-quad) and opacity (200 ms, ease-out) transitions,
  clipped.
- **Body:** `text-sm` `--muted` with 16 px start, end and bottom padding.

## Variants

| Variant | Look |
| --- | --- |
| `HeroAccordionVariant.standard` | Transparent with full-width separators. |
| `HeroAccordionVariant.surface` | `--surface` card with 24 px corners (`borderRadius`), inset separators (94% wide, `--surface-foreground` at 6%), `--default` hover and rounded outer triggers. |

## Examples

### Surface

```dart
HeroAccordion(variant: HeroAccordionVariant.surface, children: items)
```

### Without separator

```dart
HeroAccordion(hideSeparator: true, children: items)
```

### Multiple expanded

```dart
HeroAccordion(allowsMultipleExpanded: true, children: items)
```

### Disabled state

```dart
HeroAccordion(isDisabled: true, children: items)

HeroAccordionItem(isDisabled: true, title: const Text('Disabled Item'), child: body)
```

### Controlled

```dart
Set<Object> expandedKeys = <Object>{'getting-started'};

HeroAccordion(
  expandedKeys: expandedKeys,
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
  children: const <Widget>[
    HeroAccordionItem(
      id: 'getting-started',
      title: Text('Getting Started'),
      child: Text('Learn the basics of HeroUI ...'),
    ),
    HeroAccordionItem(
      id: 'core-concepts',
      title: Text('Core Concepts'),
      child: Text('Understand the fundamental concepts ...'),
    ),
  ],
)
```

Items without an `id` are identified by their index.

### Custom indicator

```dart
HeroAccordionItem(
  id: '1',
  title: const Text('Using Plus/Minus Icon'),
  indicator: HeroAccordionIndicator(
    child: HeroIcon(expandedKeys.contains('1') ? HeroIcons.minus : HeroIcons.plus),
  ),
  child: const Text('...'),
)
```

Any icon passed to the indicator turns over when the item expands.

### Render function

`HeroAccordionTrigger.builder` receives a `HeroAccordionTriggerState` (`isExpanded`,
`isHovered`, `isPressed`, `isFocused`, `isFocusVisible`, `isDisabled`):

```dart
HeroAccordionTrigger(
  builder: (BuildContext context, HeroAccordionTriggerState state) => Text(
    'How do I place an order?',
    style: state.isExpanded ? TextStyle(color: colors.accent) : null,
  ),
)
```

### FAQ layout

Headings and category titles above several surface accordions.

### Customization

```dart
HeroAccordion(
  variant: HeroAccordionVariant.surface,
  borderRadius: theme.radii.xl2,
  children: <Widget>[
    HeroAccordionItem(
      children: <Widget>[
        HeroAccordionHeading(
          child: HeroAccordionTrigger(
            style: HeroAccordionTriggerStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(colors.surface),
            ),
            indicator: HeroAccordionIndicator(color: colors.muted.withValues(alpha: 0.5)),
            builder: (BuildContext context, HeroAccordionTriggerState state) =>
                AnimatedScale(scale: state.isHovered ? 1.2 : 1, ...),
          ),
        ),
        HeroAccordionPanel(child: HeroAccordionBody(child: Text(content))),
      ],
    ),
  ],
)
```

## Behavior

- Pressing a trigger, Enter or Space toggles its item. Without `allowsMultipleExpanded`,
  expanding an item collapses the others.
- Tab moves between triggers; collapsed panels are skipped and hidden from assistive
  technologies.
- Disabled items (and every item of a disabled accordion) do not toggle.
- Under reduced motion panels and indicators change instantly.

## Accessibility

- Each heading is announced as a heading; its trigger is a button with an expanded state.
- The indicator is decorative and excluded from semantics.

## API

### HeroAccordion

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The items. |
| `variant` | `HeroAccordionVariant` | `standard` | Transparent or surface look. |
| `hideSeparator` | `bool` | `false` | Hide the separators. |
| `allowsMultipleExpanded` | `bool` | `false` | Allow several expanded items. |
| `expandedKeys` | `Set<Object>?` | `null` | Controlled expanded item ids. |
| `defaultExpandedKeys` | `Set<Object>?` | `null` | Initially expanded ids when uncontrolled. |
| `onExpandedChanged` | `ValueChanged<Set<Object>>?` | `null` | Called with the expanded ids. |
| `isDisabled` | `bool` | `false` | Disable every item. |
| `borderRadius` | `double?` | 24 | Corner radius of the surface variant. |

### HeroAccordionItem

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | `Object?` | index | Key in the expanded ids. |
| `children` | `List<Widget>?` | `null` | Heading and panel parts. |
| `title` | `Widget?` | `null` | Trigger label. |
| `startContent` | `Widget?` | `null` | Content before the title. |
| `indicator` | `Widget?` | `HeroAccordionIndicator()` | Indicator; null shows none. |
| `child` | `Widget?` | `null` | Panel content (in a `HeroAccordionBody`). |
| `isDisabled` | `bool` | `false` | Disable the item. |
| `isExpanded` | `bool?` | `null` | Control this item's expansion directly. |
| `defaultExpanded` | `bool` | `false` | Start expanded. |
| `onExpandedChanged` | `ValueChanged<bool>?` | `null` | Called when the trigger is pressed. |

### HeroAccordionHeading

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The trigger. |

### HeroAccordionTrigger

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Label. |
| `builder` | `HeroAccordionTriggerBuilder?` | `null` | Builds the label from the trigger state. |
| `startContent` | `Widget?` | `null` | Content before the label. |
| `indicator` | `Widget?` | `HeroAccordionIndicator()` | Indicator; null shows none. |
| `onPressed` | `VoidCallback?` | `null` | Called after the item toggles. |
| `isDisabled` | `bool?` | item's | Disable the trigger. |
| `style` | `HeroAccordionTriggerStyle?` | `null` | Fill, padding and text overrides. |
| `semanticLabel` | `String?` | label text | Accessibility label. |

### HeroAccordionIndicator

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | chevron | Custom icon. |
| `color` | `Color?` | `--muted` | Icon color. |

### HeroAccordionPanel

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Content, usually a `HeroAccordionBody`. |
| `builder` | `WidgetBuilder?` | `null` | Builds the content. |

### HeroAccordionBody

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Content. |
| `padding` | `EdgeInsetsGeometry?` | 16 start, end, bottom | Padding. |
| `style` | `TextStyle?` | `null` | Merged over `text-sm` `--muted`. |

### HeroCollapsible

The panel animation is available on its own as `HeroCollapsible(isExpanded:, child:)`.
