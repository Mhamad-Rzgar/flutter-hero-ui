# ScrollShadow

Apply visual shadows to indicate scrollable content overflow with automatic detection of scroll
position.

HeroUI docs: [heroui.com/en/docs/react/components/scroll-shadow](https://heroui.com/en/docs/react/components/scroll-shadow)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroScrollShadow(
  constraints: const BoxConstraints(maxHeight: 240),
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      for (int i = 0; i < 10; i++) const Text('Lorem ipsum dolor sit amet...'),
    ],
  ),
)
```

## Anatomy

`HeroScrollShadow` is a single scroll container: a `SingleChildScrollView` (or the scroll view
of `HeroScrollShadow.builder`) painted through a gradient alpha mask. It has no background,
border or padding of its own. Like a block element it fills the width it is given (the width
of its content where the width is unbounded) and is as tall as its content up to its
constraints.

## How the fade works

The fade follows the scroll position continuously, as HeroUI's scroll-driven mask does:

| Edge | Fade length |
| --- | --- |
| Start (top, or the start side of a horizontal scroll shadow) | `clamp(scrolled - offset, 0, size)` |
| End (bottom, or the end side) | `clamp(remaining - offset, 0, size)` |

So each fade grows gradually over the first `size` pixels of scrolling instead of appearing at
once, and content that does not overflow is not faded. The mask goes from transparent at the
edge to opaque at the fade length. A `scrollbarGutter` strip (10 by default, 0 with
`hideScrollBar`) along the scrollbar edge is never faded, so the scrollbar stays crisp; it
follows the scrollbar to the left edge in right-to-left layouts. Horizontal fades are logical:
the start edge is on the right in right-to-left layouts.

The scroll view uses iOS bouncing physics (`BouncingScrollPhysics`), and the themed scrollbar
of `HeroScrollBehavior` on desktop platforms.

## Options

| Option | Values |
| --- | --- |
| `orientation` | `Axis.vertical` (default), `Axis.horizontal` |
| `variant` | `HeroScrollShadowVariant.fade` (the only HeroUI variant) |
| `size` | fade length, 40 by default |
| `offset` | scroll distance before a fade starts, 0 by default |
| `hideScrollBar` | hides the scrollbar and the gutter |
| `visibility` | `auto` (follow the scroll position), `both`, `top`, `bottom`, `left`, `right`, `none` |
| `isEnabled` | `false` turns the automatic fade off |

A `visibility` other than `auto` shows fixed, full-size fades on the given edges without
tracking the scroll position (`top`/`bottom` apply to vertical scroll shadows, `left`/`right`
to horizontal ones).

## Examples

### Orientation

```dart
HeroCard(
  padding: EdgeInsets.zero,
  children: <Widget>[
    HeroScrollShadow(
      orientation: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 16,
        children: <Widget>[for (final Event event in events) EventCard(event)],
      ),
    ),
  ],
)
```

### Shadow size

```dart
const HeroScrollShadow(
  size: 80,
  constraints: BoxConstraints(maxHeight: 240),
  padding: EdgeInsets.all(16),
  child: paragraphs,
)
```

### With card

```dart
HeroCard(
  constraints: const BoxConstraints(maxWidth: 400),
  children: <Widget>[
    const HeroCardHeader(
      children: <Widget>[
        HeroCardTitle.text('Terms and Conditions'),
        HeroCardDescription.text('Please review before proceeding'),
      ],
    ),
    const HeroCardContent(
      children: <Widget>[
        HeroScrollShadow(
          height: 300,
          size: 80,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: paragraphs,
        ),
      ],
    ),
    footer,
  ],
)
```

### Hide scroll bar

```dart
const HeroScrollShadow(
  hideScrollBar: true,
  constraints: BoxConstraints(maxHeight: 240),
  child: paragraphs,
)
```

### Visibility change

`onVisibilityChanged` reports which edges have content beyond them: `both`, `top`/`left`
(only content before), `bottom`/`right` (only content after) or `none`. It is called once
after the first layout and then only when the value changes. Content before counts when it is
more than `offset` pixels away, content after when it is more than `offset + 1` pixels away
(HeroUI's thresholds).

```dart
HeroScrollShadow(
  constraints: const BoxConstraints(maxHeight: 240),
  onVisibilityChanged: (HeroScrollShadowVisibility visibility) =>
      setState(() => state = visibility),
  child: paragraphs,
)
```

### List views

`HeroScrollShadow.builder` fades any scroll view built with the given controller:

```dart
HeroScrollShadow.builder(
  height: 320,
  builder: (BuildContext context, ScrollController controller) => ListView.builder(
    controller: controller,
    itemCount: items.length,
    itemBuilder: (BuildContext context, int index) => ItemTile(items[index]),
  ),
)
```

### Customization

`decoration` is painted behind the content inside the mask, so it fades with the content, like
CSS backgrounds and borders on HeroUI's masked element. A border takes room inside and the
content is clipped to the decoration's shape.

```dart
HeroScrollShadow(
  hideScrollBar: true,
  size: 48,
  constraints: const BoxConstraints(maxHeight: 192),
  padding: const EdgeInsets.all(16),
  decoration: ShapeDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Color(0xE6FAFAFA), Color(0xFFFFFFFF)],
    ),
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
    ),
  ),
  child: changelog,
)
```

## Accessibility

- The scroll view exposes Flutter's scrollable semantics (scroll actions for assistive
  technologies).
- Content that overflows and contains no focusable widgets can be focused with Tab, like a
  keyboard-focusable scroller in the browser, and then scrolled with Page Up/Page Down and
  the arrow keys; the focus ring shows for keyboard focus.
- Scrolling reacts to touch, mouse wheel, trackpad and scrollbar dragging.

## API

### HeroScrollShadow

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Scrolled content (default constructor). |
| `builder` | `HeroScrollShadowBuilder` | required | Builds the scroll view around the given controller (`.builder`). |
| `orientation` | `Axis` | `vertical` | Scroll direction. |
| `variant` | `HeroScrollShadowVariant` | `fade` | Visual effect. |
| `size` | `double?` | 40 | Fade length. |
| `offset` | `double` | 0 | Scroll distance before a fade starts. |
| `hideScrollBar` | `bool` | `false` | Hides the scrollbar and the gutter. |
| `isEnabled` | `bool` | `true` | Whether the automatic fade is on. |
| `visibility` | `HeroScrollShadowVisibility` | `auto` | Which edges fade. |
| `onVisibilityChanged` | `ValueChanged<HeroScrollShadowVisibility>?` | – | Reports the edges with content beyond them. |
| `controller` | `ScrollController?` | – | Scroll controller. |
| `physics` | `ScrollPhysics?` | bouncing | Scroll physics (default constructor). |
| `padding` | `EdgeInsetsGeometry?` | – | Padding inside the scroll view (default constructor). |
| `width` / `height` | `double?` | – | Fixed size. |
| `constraints` | `BoxConstraints?` | – | Extra constraints (`max-h-*`). |
| `decoration` | `Decoration?` | – | Background and border, faded with the content. |
| `scrollbarGutter` | `double?` | 10 | Strip along the scrollbar that never fades. |
| `focusNode` | `FocusNode?` | – | Focus node of the scroll area (default constructor). |

`HeroScrollShadow.fadesOf(metrics, size:, offset:)` returns the start and end fade lengths and
`HeroScrollShadow.visibilityOf(metrics, offset:)` the reported visibility for a set of
`ScrollMetrics`.

### HeroScrollShadowVisibility

`auto`, `both`, `top`, `bottom`, `left`, `right`, `none`.

### HeroScrollShadowVariant

`fade`.
