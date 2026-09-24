# Link

A styled link for navigation with built-in icon support.

HeroUI reference: [Link](https://heroui.com/en/docs/react/components/link)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
HeroLink(
  href: Uri.parse('https://heroui.com'),
  children: const <Widget>[Text('Call to action'), HeroLinkIcon()],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `Link` | `HeroLink` (`child`, `children` or `builder`) |
| `Link.Icon` | `HeroLinkIcon` (default external-link arrow, or a custom `child`) |

Activating a link (tap, click or Enter) calls `onPressed` and then passes `href` and `target`
to the nearest `HeroLinkHandler`, the counterpart of React Aria's `RouterProvider`. Wire it to
your router or a URL launcher once, near the root of the app:

```dart
HeroLinkHandler(
  onOpen: (Uri href, HeroLinkTarget target) => openUrl(href, newTab: target == HeroLinkTarget.blank),
  child: app,
)
```

## Look and states

The link takes the font size of the surrounding text and renders it in medium weight in the
`link` color, without padding. Its text is underlined 1.5 px thick, 4 px below the baseline.

| State | Look |
| --- | --- |
| Rest | No underline (`underline: hover`); icon at 60% opacity. |
| Hovered | Underline in `muted` at 50%; icon fully opaque. |
| Pressed | Underline in `muted`; icon fully opaque. |
| Keyboard focus | Focus ring around the link (radius 12); icon fully opaque. |
| Disabled | 50% opacity, no interaction. |

The text color transitions over 100 ms, the icon opacity over 150 ms and the disabled fade
over 100 ms (none of them under reduced motion). The underline is drawn by the link itself so
the CSS offset and thickness are exact; it covers every line of wrapped text and skips the
icon.

## Examples

### Icon placement

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 12,
  children: const <Widget>[
    HeroLink(children: <Widget>[Text('Icon at end (default)'), HeroLinkIcon()]),
    HeroLink(gap: 4, children: <Widget>[HeroLinkIcon(), Text('Icon at start')]),
  ],
)
```

### Text decoration

```dart
const HeroLink(
  underline: HeroLinkUnderline.always, // or none; hover is the default
  underlineOffset: 2,
  children: <Widget>[Text('Offset 2 (2px space)'), HeroLinkIcon()],
)
```

### Custom icon

```dart
HeroLink(
  gap: 4,
  children: const <Widget>[
    Text('Go to page'),
    HeroLinkIcon(size: 12, child: HeroIcon(HeroIcons.link)),
  ],
)
```

### Render function

```dart
HeroLink(
  builder: (BuildContext context, HeroInteractionState state) =>
      Text(state.isHovered ? 'Open the docs' : 'Docs'),
)
```

### Customization

`color` and `decorationColor` accept a `WidgetStateColor` to vary by state:

```dart
HeroLink(
  underline: HeroLinkUnderline.always,
  color: WidgetStateColor.resolveWith(
    (Set<WidgetState> states) => states.contains(WidgetState.hovered)
        ? theme.colors.foreground
        : theme.colors.foreground.withValues(alpha: 0.8),
  ),
  decorationColor: theme.colors.border.withValues(alpha: 0.8),
  children: const <Widget>[Text('Call to action'), HeroLinkIcon()],
)
```

## Accessibility

- Exposed as a link (not a button) with its `href` as the link URL and its text as label.
- Keyboard: focusable with Tab, activated with Enter. Space does not activate it, like a
  native anchor.
- The focus ring only shows for keyboard focus.
- `start`/`end` icon placement and the default arrow follow right-to-left layouts.
- Text wraps instead of overflowing when space runs out (for example at a 2× text scale).

## API

### HeroLink

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Single content widget, usually a `Text`. |
| `children` | `List<Widget>` | `[]` | Content widgets laid out in a row. |
| `builder` | `Widget Function(BuildContext, HeroInteractionState)?` | `null` | Builds the content from the interaction state. |
| `href` | `Uri?` | `null` | Destination passed to the `HeroLinkHandler`. |
| `target` | `HeroLinkTarget` | `self` | `self` or `blank`. |
| `onPressed` | `VoidCallback?` | `null` | Called when the link is activated. |
| `isDisabled` | `bool` | `false` | Disables interaction and fades the link. |
| `autofocus` | `bool` | `false` | Requests focus when first built. |
| `focusNode` | `FocusNode?` | `null` | Externally managed focus node. |
| `underline` | `HeroLinkUnderline` | `hover` | `hover`, `always` or `none`. |
| `underlineOffset` | `double` | `4` | Distance from the baseline to the underline. |
| `decorationColor` | `Color?` | `null` | Underline color; may be a `WidgetStateColor`. |
| `color` | `Color?` | `null` | Text color; may be a `WidgetStateColor`. |
| `gap` | `double` | `0` | Space between content widgets. |
| `semanticsLabel` | `String?` | `null` | Accessibility label. |

### HeroLinkIcon

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Custom icon; defaults to the external-link arrow. |
| `size` | `double?` | 0.75 em | Size of the icon box (custom icons get it through `IconTheme`). |
| `margin` | `EdgeInsetsGeometry?` | `start: 4` for the default icon | Space around the icon. |

### HeroLinkHandler

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `onOpen` | `void Function(Uri href, HeroLinkTarget target)` | required | Opens a link destination. |
| `child` | `Widget` | required | The subtree. |
