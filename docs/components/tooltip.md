# Tooltip

Displays informative text when users hover over or focus on an element.

HeroUI docs: [heroui.com/en/docs/react/components/tooltip](https://heroui.com/en/docs/react/components/tooltip)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroTooltip(
  delay: Duration.zero,
  content: const Text('This is a tooltip'),
  child: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Hover me'),
  ),
)
```

## Anatomy

```dart
HeroTooltip(                          // Tooltip (state root)
  content: HeroTooltipContent(        // Tooltip.Content
    showArrow: true,                  // Tooltip.Arrow (drawn for you)
    arrow: HeroTooltipArrow(),        // optional custom arrow
    child: Text('Helpful information about this element'),
  ),
  child: HeroTooltipTrigger(          // Tooltip.Trigger, for non-focusable content
    child: ...,
  ),
)
```

| HeroUI | Flutter |
| --- | --- |
| `Tooltip` | `HeroTooltip` (`child` is the trigger, `content` the tooltip) |
| `Tooltip.Content` | `HeroTooltipContent` (a plain widget passed as `content` is wrapped in one) |
| `Tooltip.Arrow` | `HeroTooltipContent.showArrow`; `HeroTooltipArrow(child:)` for a custom shape |
| `Tooltip.Trigger` | `HeroTooltipTrigger` |

The arrow has to sit outside the bubble at the trigger's anchor point, so the content draws it
when `showArrow` is set instead of taking it as a child.

## Look

- Bubble: `overlay` fill, `overlay-foreground` 12/16 text, 8 px padding, at most 320 px wide,
  radius `min(32, radius-xl)` (12 by default), overlay shadow.
- Offset from the trigger: 3 px, 7 px with the arrow; `offset` overrides both.
- Arrow: HeroUI's 12 × 12 curved triangle, filled with the bubble color and outlined with
  `border` at 40%, rotated to point at the trigger.
- Motion: enter 150 ms (fade in, zoom from 90%, 4 px slide from the trigger side), exit 100 ms
  (fade out, zoom to 95%), both from the trigger anchor point. Nothing animates under reduced
  motion.

## Behaviour

- A mouse hovering the trigger opens the tooltip after `delay` (the theme's `tooltipDelay`,
  1500 ms); leaving closes it after `closeDelay` (`tooltipCloseDelay`, 500 ms). Moving the pointer
  onto the tooltip keeps it open.
- Keyboard focus opens it at once and blur closes it. Pointer focus does not.
- Pressing the trigger, pressing Escape or pressing outside closes it.
- Global warm-up: while a tooltip is open, and for `HeroTooltip.warmUpCooldown` (500 ms) after the
  last one closed, other tooltips open at once. Only one tooltip shows at a time.
  `shouldSkipAnimation` drops the transitions when tooltips swap this way.
- `trigger: HeroTooltipTriggerMode.focus` opens only on keyboard focus.
- Touch screens have no hover: a long press on the trigger opens the tooltip (the trigger is not
  pressed) and the next tap closes it.
- Placements flip to the opposite side when there is not enough room; `start` / `end` follow the
  reading direction.

## Examples

### Placement

```dart
HeroTooltip(
  delay: Duration.zero,
  content: const HeroTooltipContent(
    showArrow: true,
    placement: HeroPlacement.left,
    child: Text('Left placement'),
  ),
  child: const HeroButton(
    variant: HeroButtonVariant.tertiary,
    child: Text('Left'),
  ),
)
```

### With arrow

```dart
HeroTooltip(
  delay: Duration.zero,
  content: const HeroTooltipContent(
    showArrow: true,
    offset: 12,
    child: Text('Custom offset from trigger'),
  ),
  child: const HeroButton(child: Text('Custom Offset')),
)
```

### Custom triggers

`HeroTooltipTrigger` makes any content focusable (button semantics, focus ring on keyboard
focus):

```dart
HeroTooltip(
  delay: Duration.zero,
  content: HeroTooltipContent(
    showArrow: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Jane Doe', style: TextStyle(fontWeight: HeroTypography.semibold)),
        Text('jane@example.com', style: TextStyle(color: theme.colors.muted)),
      ],
    ),
  ),
  child: const HeroTooltipTrigger(
    semanticsLabel: 'User avatar',
    child: HeroAvatar(size: HeroSize.sm, name: 'Jane Doe'),
  ),
)
```

### Render function

`builder` wraps the styled tooltip and receives the resolved placement:

```dart
HeroTooltipContent(
  builder: (context, state, tooltip) =>
      Semantics(identifier: 'foo', child: tooltip),
  child: const Text('This is a tooltip'),
)
```

### Custom styles

```dart
HeroTooltipContent(
  backgroundColor: theme.colors.surface,
  foregroundColor: theme.colors.foreground,
  side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
  borderRadius: theme.radii.lg,
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  shadows: shadowSm,
  child: const Text('Copied to clipboard'),
)
```

### Controlled

```dart
HeroTooltip(
  isOpen: open,
  onOpenChanged: (value) => setState(() => open = value),
  content: const Text('Controlled tooltip'),
  child: const HeroButton(child: Text('Trigger')),
)
```

## Accessibility

- The tooltip text is attached to the trigger's semantics node (`tooltip`), so screen readers
  announce it with the trigger. Set `semanticLabel` when the content is not a plain `Text`.
- The trigger must be focusable for keyboard users: use a button or wrap the content in
  `HeroTooltipTrigger`.
- Escape closes the tooltip without moving focus.

## API

### HeroTooltip

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The trigger. |
| `content` | `Widget` | required | A `HeroTooltipContent`, or a widget wrapped in one. |
| `delay` | `Duration?` | theme `tooltipDelay` (1500 ms) | Hover time before opening. |
| `closeDelay` | `Duration?` | theme `tooltipCloseDelay` (500 ms) | Time before closing after the pointer left. |
| `trigger` | `HeroTooltipTriggerMode` | `hover` | `hover` (hover, focus, long press on touch) or `focus`. |
| `isDisabled` | `bool` | `false` | Never opens. |
| `shouldSkipAnimation` | `bool` | `false` | Skip transitions while the warm-up is active. |
| `isOpen` | `bool?` | `null` | Controlled open state. |
| `defaultOpen` | `bool` | `false` | Initial open state (uncontrolled). |
| `onOpenChanged` | `ValueChanged<bool>?` | `null` | Called when it opens or closes. |
| `placement` | `HeroPlacement` | `top` | Placement when `content` is not a `HeroTooltipContent`. |
| `showArrow` | `bool` | `false` | Arrow when `content` is not a `HeroTooltipContent`. |
| `offset` | `double?` | 3 / 7 | Offset when `content` is not a `HeroTooltipContent`. |
| `semanticLabel` | `String?` | text of `content` | Tooltip text announced with the trigger. |

`HeroTooltip.warmUpCooldown` (500 ms) is how long other tooltips keep opening at once after the
last one closed.

### HeroTooltipContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The content. |
| `placement` | `HeroPlacement` | `top` | Preferred placement. |
| `offset` | `double?` | 3, 7 with arrow | Distance from the trigger. |
| `crossOffset` | `double` | `0` | Shift along the trigger edge. |
| `shouldFlip` | `bool` | `true` | Flip when there is not enough room. |
| `showArrow` | `bool` | `false` | Draw the arrow. |
| `arrow` | `Widget?` | `HeroTooltipArrow()` | Custom arrow. |
| `backgroundColor` | `Color?` | `overlay` | Fill (also fills the arrow). |
| `foregroundColor` | `Color?` | `overlayForeground` | Text and icon color. |
| `textStyle` | `TextStyle?` | `null` | Merged over `text-xs`. |
| `borderRadius` | `double?` | `min(32, radius-xl)` | Corner radius. |
| `side` | `BorderSide` | none | Border. |
| `padding` | `EdgeInsetsGeometry?` | 8 | Padding. |
| `maxWidth` | `double?` | 320 | Maximum width. |
| `shadows` | `List<BoxShadow>?` | overlay shadow | Drop shadows. |
| `builder` | `HeroTooltipContentBuilder?` | `null` | Wraps the styled tooltip (`render`). |

### HeroTooltipArrow

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | curved triangle | Custom shape, drawn pointing down and rotated. |

### HeroTooltipTrigger

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | The content. |
| `shape` | `ShapeBorder?` | rectangle | Focus ring outline. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. |
| `focusNode` | `FocusNode?` | `null` | External focus node. |
| `autofocus` | `bool` | `false` | Focus when first built. |

### HeroOverlayArrow

The shared arrow shape used by tooltips and popovers.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `side` | `HeroOverlaySide` | required | Side of the trigger the overlay is on. |
| `color` | `Color?` | `overlay` | Fill. |
| `strokeColor` | `Color?` | `null` | Outline. |
| `child` | `Widget?` | curved triangle | Custom shape pointing down. |

`HeroOverlayArrow.positioned(geometry:, extent:, arrow:)` places an arrow outside the overlay edge
that faces the trigger, inside a `Stack` the size of the overlay.
