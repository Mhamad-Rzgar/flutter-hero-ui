# Drawer

Slide-out panel for supplementary content and actions.

HeroUI docs: [heroui.com/en/docs/react/components/drawer](https://heroui.com/en/docs/react/components/drawer)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroDrawer(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Drawer'),
  ),
  child: const HeroDrawerBackdrop(
    child: HeroDrawerContent(
      placement: HeroDrawerPlacement.right,
      child: HeroDrawerDialog(
        children: [
          HeroDrawerHeader(children: [
            HeroDrawerHeading(child: Text('Drawer Title')),
          ]),
          HeroDrawerBody(child: Text('Supplementary content.')),
          HeroDrawerFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.secondary,
              child: Text('Cancel'),
            ),
            HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
          ]),
        ],
      ),
    ),
  ),
)
```

## Anatomy

```dart
HeroDrawer(
  trigger: HeroButton(child: Text('Open Drawer')),
  child: HeroDrawerBackdrop(                  // Drawer.Backdrop
    child: HeroDrawerContent(                 // Drawer.Content (edge)
      child: HeroDrawerDialog(children: [     // Drawer.Dialog (panel)
        HeroDrawerHandle(),                   // optional drag handle
        HeroDrawerCloseTrigger(),             // optional close button
        HeroDrawerHeader(children: [HeroDrawerHeading(child: ...)]),
        HeroDrawerBody(child: ...),
        HeroDrawerFooter(children: [...]),
      ]),
    ),
  ),
)
```

`HeroDrawerTrigger` is a custom pressable trigger (`Drawer.Trigger`). The drawer opens in the
shared modal route ([Modal](modal.md)): focus trap, Escape, outside press, close buttons,
`slot: HeroButtonSlot.close`, controlled and uncontrolled state and `HeroOverlayController`.

## Placement

| `HeroDrawerPlacement` | Panel |
| --- | --- |
| `bottom` (default) | full width, up to 85% of the screen height, 16 px top corners |
| `top` | full width, up to 85% of the screen height, 16 px bottom corners, 8 px bottom padding |
| `left` | full height, 320 wide (384 from 640 px, at most 85% of the width), square corners |
| `right` | same as `left`, on the other edge |

`left` and `right` follow the reading direction like HeroUI's `justify-start` / `justify-end`:
in right-to-left layouts a `left` drawer opens from the right edge (and is dragged to the right
to close). The panel keeps the safe area clear on the screen edges it touches and sits above the
keyboard.

## Motion and drag to dismiss

- The backdrop fades in over 250 ms and out over 200 ms, `ease-out-fluid`.
- The panel slides in from its edge over 250 ms and back out over 200 ms, `ease-out-fluid`.
- When the backdrop `isDismissable`, the panel can be dragged towards its edge from anywhere
  except the body (which scrolls). The drag starts after 8 px and only moves towards the edge.
  Releasing past 30% of the panel size, or flicking towards the edge faster than 0.5 px/ms,
  closes the drawer and the exit continues from the released position; otherwise the panel
  springs back over 300 ms `ease-out-fluid`.

## Examples

### Non-dismissable

```dart
const HeroDrawerBackdrop(
  isDismissable: false,   // no outside press, no drag
  child: HeroDrawerContent(child: HeroDrawerDialog(children: [...])),
)
```

### Scrollable content

```dart
HeroDrawerDialog(children: [
  const HeroDrawerHandle(),
  const HeroDrawerHeader(children: [HeroDrawerHeading(child: Text('Terms'))]),
  HeroDrawerBody(children: [for (final p in paragraphs) Text(p)]),
  const HeroDrawerFooter(children: [...]),
])
```

### Controlled state

```dart
HeroDrawerBackdrop(
  isOpen: isOpen,
  onOpenChanged: (value) => setState(() => isOpen = value),
  child: const HeroDrawerContent(
    placement: HeroDrawerPlacement.right,
    child: HeroDrawerDialog(children: [...]),
  ),
)
```

### Navigation drawer

```dart
HeroDrawer(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    startContent: HeroIcon(HeroIcons.bars),
    child: Text('Menu'),
  ),
  child: HeroDrawerBackdrop(
    child: HeroDrawerContent(
      placement: HeroDrawerPlacement.left,
      child: HeroDrawerDialog(children: [
        const HeroDrawerCloseTrigger(),
        const HeroDrawerHeader(children: [HeroDrawerHeading(child: Text('Navigation'))]),
        HeroDrawerBody(child: Column(children: navItems)),
      ]),
    ),
  ),
)
```

### Custom styles

```dart
HeroDrawerDialog(
  backgroundColor: theme.colors.surface,
  side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)), // edge facing the page
  children: [...],
)
```

### Imperative API

```dart
final int? choice = await HeroDrawer.show<int>(
  context,
  placement: HeroDrawerPlacement.bottom,
  builder: (context, close) => HeroDrawerDialog(children: [...]),
);
```

## Accessibility

- The panel is announced as a dialog (`SemanticsRole.dialog`) named by its heading.
- Focus moves into the drawer, Tab cycles inside it and focus returns to the trigger on close.
- Escape closes it unless `isKeyboardDismissDisabled`.
- The handle is decorative and hidden from assistive technologies; dragging is an additional
  way to close, the close trigger and buttons remain available.

## API

### HeroDrawer

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The overlay: a `HeroDrawerBackdrop`. |
| `trigger` | `Widget?` | `null` | Opens the drawer when pressed. |
| `isOpen` | `bool?` | backdrop's `isOpen` | Controlled open state. |
| `defaultOpen` | `bool` | `false` | Initial state when uncontrolled. |
| `onOpenChanged` | `ValueChanged<bool>?` | `null` | Called when the state should change. |
| `controller` | `HeroOverlayController?` | `null` | External open state (`state`). |
| `useRootNavigator` | `bool` | `true` | Open in the root navigator or the nearest one. |

`HeroDrawer.show<T>(context, {builder, placement, backdropVariant, isDismissable,
isKeyboardDismissDisabled, useRootNavigator, settings})`.

### HeroDrawerBackdrop

Same parameters as `HeroModalBackdrop` (`variant`, `isDismissable` (also enables dragging),
`isKeyboardDismissDisabled`, `isOpen`, `onOpenChanged`, `color`, `decoration`, `motion`); the
default fade is 250 / 200 ms `ease-out-fluid`.

### HeroDrawerContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The panel. |
| `placement` | `HeroDrawerPlacement` | `bottom` | Edge the drawer slides from. |
| `motion` | `HeroModalMotion` | 250 / 200 ms `ease-out-fluid` | Slide timing. |

### HeroDrawerDialog

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | The parts. |
| `builder` | `HeroDialogPartsBuilder?` | `null` | Builds the parts with `close`. |
| `role` | `SemanticsRole` | `dialog` | Semantics role. |
| `semanticLabel` | `String?` | heading | Accessibility label. |
| `padding` | `EdgeInsets?` | 24 (8 at the bottom of top drawers) | Panel padding. |
| `backgroundColor` | `Color?` | `overlay` | Fill. |
| `side` | `BorderSide` | none | Border on the edge facing the page. |
| `shadows` | `List<BoxShadow>?` | overlay shadow | Drop shadows. |
| `width` | `double?` | 320 / 384 | Width of left and right drawers. |

### HeroDrawerHandle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `Color?` | `separator` | Bar color (36 × 4, radius 2). |

### Other parts

`HeroDrawerTrigger`, `HeroDrawerHeader`, `HeroDrawerHeading`, `HeroDrawerBody`,
`HeroDrawerFooter` and `HeroDrawerCloseTrigger` take the parameters of their `HeroModal*`
counterparts. `HeroDrawerBody` always scrolls and never starts a drag.
