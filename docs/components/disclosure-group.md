# DisclosureGroup

Container that manages multiple Disclosure items with coordinated expanded states.

HeroUI reference: <https://heroui.com/en/docs/react/components/disclosure-group>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Set<Object> expandedKeys = <Object>{'preview'};

HeroDisclosureGroup(
  expandedKeys: expandedKeys,
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
  children: <Widget>[
    HeroDisclosure(
      id: 'preview',
      children: <Widget>[
        HeroDisclosureHeading(
          child: HeroDisclosureTrigger.builder(
            builder: (BuildContext context, HeroDisclosureState state) =>
                HeroButton(
                  variant: state.isExpanded
                      ? HeroButtonVariant.secondary
                      : HeroButtonVariant.tertiary,
                  fullWidth: true,
                  isDisabled: state.isDisabled,
                  onPressed: state.toggle,
                  child: Row(
                    spacing: 8,
                    children: <Widget>[
                      const HeroIcon(HeroIcons.qrCode),
                      const Expanded(child: Text('Preview HeroUI Native')),
                      HeroDisclosureIndicator(color: theme.colors.muted),
                    ],
                  ),
                ),
          ),
        ),
        const HeroDisclosureContent(
          child: HeroDisclosureBody(child: Text('Scan this QR code ...')),
        ),
      ],
    ),
    const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 8)),
    HeroDisclosure(id: 'download', children: downloadParts),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `DisclosureGroup` | `HeroDisclosureGroup` |
| `Disclosure id="..."` | `HeroDisclosure(id: ...)` (an id is required inside a group) |
| `useDisclosureGroupNavigation` | `HeroDisclosureGroupNavigation` |

The group fills the available width, lays its children out in a column and has no look of
its own; separators and other widgets can sit between the disclosures.

## Examples

### Controlled

Control which disclosures are expanded with external navigation controls through
`expandedKeys` and `onExpandedChanged`; `HeroDisclosureGroupNavigation` computes the previous
and next items:

```dart
final HeroDisclosureGroupNavigation navigation = HeroDisclosureGroupNavigation(
  expandedKeys: expandedKeys,
  itemIds: const <Object>['preview', 'download'],
  onExpandedChanged: (Set<Object> keys) => setState(() => expandedKeys = keys),
);

HeroButton(
  isIconOnly: true,
  size: HeroSize.sm,
  variant: HeroButtonVariant.secondary,
  semanticLabel: 'Next disclosure',
  isDisabled: navigation.isNextDisabled,
  onPressed: navigation.next,
  child: const HeroIcon(HeroIcons.chevronDown),
)
```

### Customization

```dart
HeroSurface(
  color: theme.colors.defaultSoft,
  borderRadius: BorderRadius.circular(theme.radii.xl),
  padding: const EdgeInsets.all(8),
  child: HeroDisclosureGroup(
    children: <Widget>[
      HeroDisclosure(id: 'billing', children: billingParts),
      const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 4)),
      HeroDisclosure(id: 'support', children: supportParts),
    ],
  ),
)
```

## Behavior

- Expanding a disclosure collapses the others unless `allowsMultipleExpanded`.
- Inside a group, the group decides which disclosures are expanded (by `id`); a
  disclosure's own `isExpanded` and `defaultExpanded` are ignored, its `onExpandedChanged`
  still runs.
- `isDisabled` disables every disclosure.

## Accessibility

Each disclosure keeps its heading and expanded-button semantics; the group adds no
semantics of its own.

## API

### HeroDisclosureGroup

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Disclosures and anything between them. |
| `builder` | `HeroDisclosureGroupWidgetBuilder?` | `null` | Builds the content from `expandedKeys` and `isDisabled`. |
| `expandedKeys` | `Set<Object>?` | `null` | Controlled expanded ids. |
| `defaultExpandedKeys` | `Set<Object>?` | `null` | Initially expanded ids when uncontrolled. |
| `onExpandedChanged` | `ValueChanged<Set<Object>>?` | `null` | Called with the expanded ids. |
| `allowsMultipleExpanded` | `bool` | `false` | Allow several expanded disclosures. |
| `isDisabled` | `bool` | `false` | Disable every disclosure. |

### HeroDisclosureGroupNavigation

| Member | Description |
| --- | --- |
| `expandedKeys`, `itemIds`, `onExpandedChanged`, `allowsMultipleExpanded` | Constructor parameters. |
| `currentIndex` | Index of the first expanded item, else 0 (-1 without items). |
| `isPrevDisabled` / `isNextDisabled` | Whether there is no previous / next item. |
| `previous()` / `next()` | Expand the neighbouring item. |

### HeroDisclosureGroupScope

The inherited state the group shares with its disclosures (`expandedKeys`, `isDisabled`,
`onToggle`), for custom disclosure-like widgets.
