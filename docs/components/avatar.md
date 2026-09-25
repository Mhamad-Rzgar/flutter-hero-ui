# Avatar

Display user profile images with customizable fallback content.

HeroUI reference: [Avatar](https://heroui.com/en/docs/react/components/avatar)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: <Widget>[
    HeroAvatar(
      children: <Widget>[
        HeroAvatarImage.network(
          'https://img.heroui.chat/image/avatar?w=400&h=400&u=3',
          semanticLabel: 'John Doe',
        ),
        const HeroAvatarFallback(child: Text('JD')),
      ],
    ),
    const HeroAvatar(src: 'https://example.com/blue.jpg', name: 'Blue'),
    const HeroAvatar(fallback: Text('JR')),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `Avatar` | `HeroAvatar` (`children`, or the `image` / `src` / `name` / `fallback` shorthand) |
| `Avatar.Image` | `HeroAvatarImage(image:)`, `HeroAvatarImage.network(src)` |
| `Avatar.Fallback` | `HeroAvatarFallback(child:)` |

The image reports its loading state (`idle`, `loading`, `loaded`, `error`) to the avatar. The
fallback is shown until the image has loaded, and stays when it fails; the image then fades in
over 250 ms. Images already in the image cache appear at once. Load errors are handled (they
are passed to `onError`, not reported as framework errors).

With the shorthand, `name` provides the initials (`HeroAvatar.initialsOf('John Doe')` is
`JD`) and the accessibility label.

## Sizes, colors and variants

| Size | Side | Radius | Fallback text |
| --- | --- | --- | --- |
| `sm` | 32 | `xl2` (16) | 12 medium |
| `md` (default) | 40 | `xl3` (24) | 14 medium |
| `lg` | 48 | `xl3` (24) | 16 medium |

With the default `--radius` the avatars are circles; the corners follow the theme radius.

| Variant | Root | Fallback fill | Fallback text and icons |
| --- | --- | --- | --- |
| `standard` (default) | `defaultColor` | `defaultColor` | role soft foreground |
| `soft` | transparent | role soft color (`defaultSoft` for `standard`) | role soft foreground |

Colors: `HeroColor.standard` (default), `accent`, `success`, `warning`, `danger`. They only
affect the fallback. `HeroAvatarFallback(color:)` overrides the avatar's color.

Inside an avatar group, size, color and variant default to the group's values through
`HeroAvatarScope`.

## Examples

### Fallback content

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: <Widget>[
    const HeroAvatar(fallback: Text('JD')),
    const HeroAvatar(fallback: HeroIcon(HeroIcons.person)),
    HeroAvatar(
      children: <Widget>[
        HeroAvatarImage.network('https://invalid-url-to-show-fallback.com/image.jpg'),
        const HeroAvatarFallback(delay: Duration(milliseconds: 600), child: Text('NA')),
      ],
    ),
    HeroAvatar(
      children: <Widget>[
        HeroAvatarFallback(
          gradient: const LinearGradient(colors: <Color>[pink, purple]),
          foregroundColor: theme.colors.white,
          child: const Text('GB'),
        ),
      ],
    ),
  ],
)
```

### Custom image component

`builder` renders the loaded image with your own widget (HeroUI's `asChild`):

```dart
HeroAvatar(
  children: <Widget>[
    HeroAvatarImage.network(
      url,
      builder: (BuildContext context, ImageProvider image) =>
          Image(image: image, fit: BoxFit.cover),
    ),
    const HeroAvatarFallback(child: Text('JD')),
  ],
)
```

### Customization

```dart
HeroAvatar(radius: theme.radii.lg, src: url, fallback: const Text('JD'))
```

## Accessibility

- A loaded image is exposed as an image with its `semanticLabel` (`alt`).
- The fallback's text is read when no image is shown; `semanticsLabel` (the `name` with the
  shorthand) replaces initials with a full name.
- The avatar is one semantics node.
- The image covers the avatar (`BoxFit.cover`); fallback text is clipped, never overflowing,
  at large text scales.

## API

### HeroAvatar

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `ImageProvider?` | `null` | Image to show. |
| `src` | `String?` | `null` | Network image URL, used when `image` is null. |
| `name` | `String?` | `null` | Name for the initials fallback and the accessibility label. |
| `fallback` | `Widget?` | initials of `name` | Fallback content. |
| `fallbackDelay` | `Duration?` | `null` | Delay before the fallback appears. |
| `semanticLabel` | `String?` | `name` | Image accessibility label. |
| `children` | `List<Widget>` | `[]` | Parts; replace the shorthand when not empty. |
| `size` | `HeroSize?` | scope, else `md` | Size. |
| `color` | `HeroColor?` | scope, else `standard` | Fallback color role. |
| `variant` | `HeroAvatarVariant?` | scope, else `standard` | `standard` or `soft`. |
| `radius` | `double?` | `null` | Overrides the corner radius. |

`HeroAvatar.initialsOf(name)` and `HeroAvatar.dimensionOf(theme, size)` are helpers.

### HeroAvatarImage

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `image` | `ImageProvider` | required | Image to load (`HeroAvatarImage.network(src)` for URLs). |
| `semanticLabel` | `String?` | `null` | Accessibility label (`alt`). |
| `builder` | `Widget Function(BuildContext, ImageProvider)?` | `null` | Custom image widget. |
| `onLoad` | `VoidCallback?` | `null` | Called when the image has loaded. |
| `onError` | `ImageErrorListener?` | `null` | Called when loading fails. |

### HeroAvatarFallback

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | `null` | Initials, an icon or any widget. |
| `delay` | `Duration?` | `null` | Delay before it appears (`delayMs`). |
| `color` | `HeroColor?` | avatar color | Overrides the color role. |
| `backgroundColor` | `Color?` | `null` | Overrides the fill. |
| `foregroundColor` | `Color?` | `null` | Overrides the text and icon color. |
| `gradient` | `Gradient?` | `null` | Paints a gradient instead of the fill. |
| `semanticsLabel` | `String?` | `null` | Replaces the fallback's own text for assistive technologies. |

### HeroAvatarScope

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `size`, `color`, `variant` | nullable | `null` | Defaults for avatars below. |
| `fallbackPadding` | `EdgeInsetsGeometry?` | `null` | Extra fallback padding (the group's optical nudge). |
| `child` | `Widget` | required | The subtree. |
