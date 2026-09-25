# Popover

Displays rich content in a portal triggered by a button or any custom element.

HeroUI docs: [heroui.com/en/docs/react/components/popover](https://heroui.com/en/docs/react/components/popover)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroPopover(
  content: HeroPopoverContent(
    constraints: const BoxConstraints(maxWidth: 256),
    child: HeroPopoverDialog(
      children: [
        const HeroPopoverHeading(child: Text('Popover Title')),
        const SizedBox(height: 8),
        Text(
          'This is the popover content. You can put any content here.',
          style: TextStyle(color: theme.colors.muted),
        ),
      ],
    ),
  ),
  child: const HeroButton(child: Text('Click me')),
)
```

## Anatomy

```dart
HeroPopover(                          // Popover
  content: HeroPopoverContent(        // Popover.Content
    child: HeroPopoverDialog(         // Popover.Dialog
      children: [
        HeroPopoverArrow(),           // Popover.Arrow (anywhere inside the content)
        HeroPopoverHeading(child: ...), // Popover.Heading
        ...
      ],
    ),
  ),
  child: HeroPopoverTrigger(child: ...), // Popover.Trigger, or any button
)
```

`HeroPopoverArrow` takes no space where it is placed; the content draws it on the edge that faces
the trigger.

## Look

- Panel: `overlay` fill, `overlay-foreground` 14 px text, no padding, radius
  `min(32, radius-3xl)` (24 by default), overlay shadow, 8 px from the trigger.
- Dialog: 16 px padding. Heading: medium weight.
- Arrow: HeroUI's 12 × 12 curved triangle in the panel color, rotated towards the trigger.
- Motion: enter 150 ms (fade in, zoom from 90%, 4 px slide from the trigger side), exit 100 ms
  (fade out, zoom to 95%), from the trigger anchor point; nothing animates under reduced motion.
- `HeroPopoverTrigger`: pointer cursor, focus ring on keyboard focus, 50% opacity when disabled.

## Behaviour

- Pressing the trigger toggles the popover; the trigger is announced as expanded while it is
  open.
- Pressing outside, pressing Escape or pressing a `HeroButton(slot: HeroButtonSlot.close)` inside
  closes it. `HeroPopoverDialog(builder: (context, close) => ...)` hands out a close callback.
- Modal by default: the page behind does not react to presses, Tab stays inside the popover,
  focus moves into it on open (unless a descendant autofocuses) and returns to the trigger on
  close. `isNonModal: true` keeps the page interactive; pressing outside still closes it.
- Placements flip to the opposite side when there is not enough room (`shouldFlip`), stay 12 px
  inside the screen (`containerPadding`) and follow the reading direction for `start` / `end`.
  Content taller than the available space scrolls.

## Examples

### With arrow

```dart
HeroPopover(
  content: HeroPopoverContent(
    offset: 10,
    child: HeroPopoverDialog(
      children: const [
        HeroPopoverArrow(),
        HeroPopoverHeading(child: Text('Popover with Arrow')),
      ],
    ),
  ),
  child: const HeroButton(
    isIconOnly: true,
    semanticLabel: 'More options',
    variant: HeroButtonVariant.tertiary,
    child: HeroIcon(HeroIcons.ellipsis),
  ),
)
```

### Interactive content

```dart
HeroPopover(
  content: const HeroPopoverContent(
    constraints: BoxConstraints.tightFor(width: 320),
    child: ProfileCard(), // a HeroPopoverDialog with a Follow button
  ),
  child: const HeroPopoverTrigger(
    semanticsLabel: 'User profile',
    child: UserSummary(),
  ),
)
```

### Placement

```dart
HeroPopover(
  content: const HeroPopoverContent(
    placement: HeroPlacement.left,
    child: HeroPopoverDialog(
      children: [HeroPopoverArrow(), Text('Left placement')],
    ),
  ),
  child: const HeroButton(
    variant: HeroButtonVariant.tertiary,
    child: Text('Left'),
  ),
)
```

### Render function

```dart
HeroPopoverContent(
  builder: (context, state, popover) =>
      Semantics(identifier: 'foo', child: popover),
  child: ...,
)
```

### Custom styles

```dart
HeroPopoverContent(
  constraints: const BoxConstraints(maxWidth: 224),
  clipBehavior: Clip.antiAlias,
  borderRadius: theme.radii.xl,
  backgroundColor: theme.colors.surface.withValues(alpha: 0.9),
  side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
  backdropBlur: 24,
  shadows: shadowXl,
  child: ...,
)
```

### Controlled

```dart
final controller = HeroOverlayController();

HeroPopover(
  controller: controller,
  content: ...,
  child: const HeroButton(child: Text('Open')),
)
// controller.open(), controller.close(), controller.toggle()
```

## Accessibility

- The dialog is announced as a dialog (`SemanticsRole.dialog`) and named by its
  `HeroPopoverHeading`; set `HeroPopoverDialog.semanticLabel` when there is no heading.
- The trigger exposes the expanded state.
- Keyboard: Enter / Space on the trigger opens it, Tab cycles inside a modal popover, Escape
  closes it and focus returns to the trigger.

## API

### HeroPopover

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The trigger (a button or `HeroPopoverTrigger`). |
| `content` | `Widget` | required | A `HeroPopoverContent`, or a widget wrapped in one. |
| `isOpen` | `bool?` | `null` | Controlled open state. |
| `defaultOpen` | `bool` | `false` | Initial open state (uncontrolled). |
| `onOpenChanged` | `ValueChanged<bool>?` | `null` | Called when it should open or close. |
| `controller` | `HeroOverlayController?` | `null` | External open state; wins over `isOpen`. |

### HeroPopoverContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The content, usually a `HeroPopoverDialog`. |
| `placement` | `HeroPlacement` | `bottom` | Preferred placement. |
| `offset` | `double?` | 8 | Distance from the trigger. |
| `crossOffset` | `double` | `0` | Shift along the trigger edge. |
| `shouldFlip` | `bool` | `true` | Flip when there is not enough room. |
| `containerPadding` | `double?` | 12 | Minimum distance to the screen edges. |
| `isNonModal` | `bool` | `false` | Keep the page behind interactive. |
| `constraints` | `BoxConstraints?` | `null` | Size limits (`w-*`, `max-w-*`). |
| `backgroundColor` | `Color?` | `overlay` | Fill (also fills the arrow). |
| `borderRadius` | `double?` | `min(32, radius-3xl)` | Corner radius. |
| `side` | `BorderSide` | none | Border. |
| `shadows` | `List<BoxShadow>?` | overlay shadow | Drop shadows. |
| `backdropBlur` | `double` | `0` | Blur behind a translucent panel. |
| `padding` | `EdgeInsetsGeometry?` | none | Padding. |
| `clipBehavior` | `Clip` | `none` | Clip the content to the panel (`overflow-hidden`). |
| `builder` | `HeroPopoverContentBuilder?` | `null` | Wraps the styled popover (`render`). |

### HeroPopoverDialog

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | `[]` | Content, stacked vertically. |
| `builder` | `HeroPopoverDialogBuilder?` | `null` | Builds the content with a close callback. |
| `padding` | `EdgeInsetsGeometry?` | 16 | Padding. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `start` | Alignment of `children`. |
| `semanticLabel` | `String?` | `null` | Label when there is no heading. |

### HeroPopoverHeading

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The title. |
| `style` | `TextStyle?` | `null` | Merged over the medium weight. |

### HeroPopoverArrow

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | curved triangle | Custom shape, drawn pointing down and rotated. |

### HeroPopoverTrigger

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The content. |
| `onPressed` | `VoidCallback?` | `null` | Called before the popover toggles. |
| `isDisabled` | `bool` | `false` | Disables the trigger. |
| `shape` | `ShapeBorder?` | rectangle | Focus ring outline. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. |
| `focusNode` | `FocusNode?` | `null` | External focus node. |
| `autofocus` | `bool` | `false` | Focus when first built. |
