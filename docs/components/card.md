# Card

Flexible container component for grouping related content and actions.

HeroUI docs: [heroui.com/en/docs/react/components/card](https://heroui.com/en/docs/react/components/card)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
final HeroThemeData theme = HeroTheme.of(context);
HeroCard(
  width: 400,
  children: <Widget>[
    HeroIcon(
      HeroIcons.circleDollar,
      size: theme.spacing(6),
      semanticLabel: 'Dollar sign icon',
    ),
    const HeroCardHeader(
      children: <Widget>[
        HeroCardTitle.text('Become an Acme Creator!'),
        HeroCardDescription.text(
          'Visit the Acme Creator Hub to sign up today and start earning '
          'credits from your fans and followers.',
        ),
      ],
    ),
    HeroCardFooter(
      children: <Widget>[
        HeroLink(
          href: Uri.parse('https://heroui.com'),
          target: HeroLinkTarget.blank,
          children: const <Widget>[Text('Creator Hub'), HeroLinkIcon()],
        ),
      ],
    ),
  ],
)
```

The shorthand parameters build the usual layout:

```dart
const HeroCard(
  title: Text('Login'),
  description: Text('Enter your credentials to access your account'),
  content: Text('...'),
  footer: Text('...'),
)
```

## Anatomy

| HeroUI | Flutter | Role |
| --- | --- | --- |
| `Card` | `HeroCard` | Column container (padding 16, gap 12, radius `min(32px, --radius-3xl)`) |
| `Card.Header` | `HeroCardHeader` | Column, usually title and description |
| `Card.Title` | `HeroCardTitle` | `text-sm leading-6 font-medium`, a level-3 heading |
| `Card.Description` | `HeroCardDescription` | `text-sm leading-5` in `--muted` |
| `Card.Content` | `HeroCardContent` | Column with a 4 px gap |
| `Card.Footer` | `HeroCardFooter` | Row, children vertically centered |

```dart
HeroCard(
  children: <Widget>[
    HeroCardHeader(
      children: <Widget>[HeroCardTitle(...), HeroCardDescription(...)],
    ),
    HeroCardContent(children: <Widget>[...]),
    HeroCardFooter(children: <Widget>[...]),
  ],
)
```

Like block elements, the card and its header, content and footer fill the width they are
given. In a `Row` (unbounded width) a card takes the width of its content. Children of the card
itself keep their own width (an icon or image stays at the start), so there is no need to
stretch the column.

## Variants

| Variant | Background | Shadow |
| --- | --- | --- |
| `HeroCardVariant.transparent` | none | none |
| `HeroCardVariant.standard` (default, HeroUI `default`) | `--surface` | `--surface-shadow` |
| `HeroCardVariant.secondary` | `--surface-secondary` | `--surface-shadow` |
| `HeroCardVariant.tertiary` | `--surface-tertiary` | `--surface-shadow` |

The surface shadow is empty in dark mode. The HeroUI docs text says the default card uses
`surface-secondary`; the CSS and the variants example use `--surface`, which is followed.

Non-transparent cards publish a `HeroSurfaceScope` with the matching `HeroSurfaceVariant`
(HeroUI's `SurfaceContext`), so descendants can pick on-surface colors. A transparent card keeps
the surface of its parent.

## Examples

### Variants

```dart
Column(
  spacing: 16,
  children: const <Widget>[
    HeroCard(
      width: 320,
      variant: HeroCardVariant.transparent,
      title: Text('Transparent'),
      description: Text('Minimal prominence with transparent background'),
      content: Text('Use for less important content or nested cards'),
    ),
    HeroCard(width: 320, title: Text('Default'), ...),
    HeroCard(width: 320, variant: HeroCardVariant.secondary, ...),
    HeroCard(width: 320, variant: HeroCardVariant.tertiary, ...),
  ],
)
```

### Horizontal layout

`direction: Axis.horizontal` lays the children out in a row. With
`CrossAxisAlignment.stretch` every child takes the height of the tallest one (CSS
`items-stretch`). `overlays` are stacked over the content, like HeroUI's absolutely positioned
close button.

```dart
HeroCard(
  direction: Axis.horizontal,
  crossAxisAlignment: CrossAxisAlignment.stretch,
  overlays: <Widget>[
    PositionedDirectional(
      end: 12,
      top: 12,
      child: HeroCloseButton(semanticLabel: 'Close banner', onPressed: close),
    ),
  ],
  children: <Widget>[
    ClipPath(
      clipper: ShapeBorderClipper(shape: theme.shapeAll(theme.radii.xl2)),
      child: Image.network(cherriesUrl, width: 120, height: 120, fit: BoxFit.cover),
    ),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // `mt-auto` on the footer.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 12,
        children: <Widget>[
          HeroCardHeader(
            gap: 4,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 32),
                child: const HeroCardTitle.text('Become an ACME Creator!'),
              ),
              const HeroCardDescription.text('Lorem ipsum dolor sit amet.'),
            ],
          ),
          HeroCardFooter(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('Only 10 spots'),
              HeroButton(onPressed: apply, child: const Text('Apply Now')),
            ],
          ),
        ],
      ),
    ),
  ],
)
```

### With avatar

```dart
HeroCard(
  width: 200,
  gap: 8,
  children: <Widget>[
    communityImage,
    const HeroCardHeader(
      children: <Widget>[
        HeroCardTitle.text('Indie Hackers'),
        HeroCardDescription.text('148 members'),
      ],
    ),
    HeroCardFooter(
      gap: 8,
      children: <Widget>[
        SizedBox.square(dimension: 20, child: HeroAvatar(src: marthaUrl)),
        const Text('By Martha'),
      ],
    ),
  ],
)
```

### With images

`background` fills the card behind its content and is clipped to the card's shape. With a
minimum height, `MainAxisAlignment.spaceBetween` keeps the header at the top and the footer at
the bottom.

```dart
HeroCard(
  constraints: const BoxConstraints(minHeight: 200),
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  background: Image.network(neoUrl, fit: BoxFit.cover),
  children: <Widget>[
    const HeroCardHeader(
      children: <Widget>[
        HeroCardTitle.text('NEO'),
        HeroCardDescription.text('Home Robot'),
      ],
    ),
    HeroCardFooter(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Text('Available soon'),
        HeroButton(
          size: HeroSize.sm,
          variant: HeroButtonVariant.tertiary,
          onPressed: notify,
          child: const Text('Notify me'),
        ),
      ],
    ),
  ],
)
```

### With form

```dart
HeroCard(
  constraints: const BoxConstraints(maxWidth: 448),
  children: <Widget>[
    const HeroCardHeader(
      children: <Widget>[
        HeroCardTitle.text('Login'),
        HeroCardDescription.text('Enter your credentials to access your account'),
      ],
    ),
    HeroForm(
      onSubmit: (Map<String, Object?> data) {},
      child: Column(
        spacing: 16,
        children: <Widget>[
          const HeroCardContent(
            gap: 16,
            children: <Widget>[
              HeroTextField(
                name: 'email',
                type: HeroInputType.email,
                fullWidth: true,
                children: <Widget>[
                  HeroLabel.text('Email'),
                  HeroInput(
                    placeholder: 'email@example.com',
                    variant: HeroFieldVariant.secondary,
                  ),
                ],
              ),
            ],
          ),
          HeroCardFooter(
            direction: Axis.vertical,
            gap: 8,
            children: <Widget>[
              const HeroButton(
                type: HeroButtonType.submit,
                fullWidth: true,
                child: Text('Sign In'),
              ),
              HeroLink(href: Uri.parse('#'), child: const Text('Forgot password?')),
            ],
          ),
        ],
      ),
    ),
  ],
)
```

### Interactive cards

HeroUI renders an interactive card as a link with the card classes. `href` (and `target`)
make the whole card a link handed to the nearest `HeroLinkHandler`; `onPressed` alone makes
it a button. The card shows the focus ring for keyboard focus, scales to 0.97 while pressed and
fades when `isDisabled`.

```dart
HeroCard(
  href: Uri.parse('/details'),
  semanticLabel: 'View product details',
  title: const Text('Product Name'),
)
```

### Customization

`HeroCardStyle` replaces the container classes: background color, gradient, border, radius
and shadows. `clipBehavior` clips the content (`overflow-hidden`) without clipping the card's
own shadow.

```dart
HeroCard(
  constraints: const BoxConstraints(maxWidth: 448),
  clipBehavior: Clip.antiAlias,
  style: HeroCardStyle(
    border: BorderSide(color: accent.withValues(alpha: 0.2)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color.alphaBlend(accent.withValues(alpha: 0.12), colors.surface),
        colors.surface,
        colors.surfaceSecondary,
      ],
    ),
    shadows: <BoxShadow>[
      BoxShadow(
        color: accent.withValues(alpha: 0.1),
        offset: const Offset(0, 10),
        blurRadius: 15,
        spreadRadius: -3,
      ),
    ],
  ),
  background: blurredBlobs,
  children: <Widget>[...],
)
```

## Accessibility

- The card is a semantics container; `semanticLabel` labels it (`aria-label`). Flutter has
  no article role.
- `HeroCardTitle` is announced as a level-3 heading (`h3`).
- Interactive cards are a single focus stop with link semantics and the URL (with `href`) or
  button semantics (with `onPressed` only). Link cards activate with Enter, button cards with
  Enter and Space. Disabled cards are not focusable.
- Padding, overlays positioned with `PositionedDirectional` and row layouts follow the text
  direction.

## API

### HeroCard

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>?` | – | Parts and other content; replaces the shorthand parameters. |
| `title` | `Widget?` | – | Title of the default layout. |
| `description` | `Widget?` | – | Description of the default layout. |
| `content` | `Widget?` | – | Content of the default layout. |
| `footer` | `Widget?` | – | Footer content of the default layout. |
| `variant` | `HeroCardVariant` | `standard` | Prominence. |
| `direction` | `Axis` | `vertical` | Column or row layout (`flex-row`). |
| `mainAxisAlignment` | `MainAxisAlignment` | `start` | Placement along `direction` (`justify-*`). |
| `crossAxisAlignment` | `CrossAxisAlignment` | `start` | Placement across `direction` (`items-*`); `stretch` in a row equalizes heights. |
| `gap` | `double?` | 12 | Space between the children. |
| `padding` | `EdgeInsetsGeometry?` | 16 | Inner padding. |
| `width` / `height` | `double?` | – | Fixed size. |
| `constraints` | `BoxConstraints?` | – | Extra constraints (`min-h-*`, `max-w-*`). |
| `background` | `Widget?` | – | Layer behind the content, clipped to the card. |
| `overlays` | `List<Widget>` | `[]` | Widgets stacked over the content (use `PositionedDirectional`). |
| `clipBehavior` | `Clip` | `none` | Clips the content to the card shape. |
| `style` | `HeroCardStyle?` | – | Container overrides. |
| `onPressed` | `VoidCallback?` | – | Makes the card pressable. |
| `href` | `Uri?` | – | Makes the card a link. |
| `target` | `HeroLinkTarget` | `self` | Where `href` opens. |
| `isDisabled` | `bool` | `false` | Disables an interactive card. |
| `focusNode` | `FocusNode?` | – | Focus node of an interactive card. |
| `autofocus` | `bool` | `false` | Focuses an interactive card when first built. |
| `semanticLabel` | `String?` | – | Accessibility label. |

`HeroCard.radiusOf(theme)` returns the default radius, `min(32, radii.xl3)`.

### HeroCardStyle

| Field | Type | Description |
| --- | --- | --- |
| `color` | `Color?` | Background color. |
| `gradient` | `Gradient?` | Background gradient over the color. |
| `border` | `BorderSide?` | Border inside the card. |
| `borderRadius` | `BorderRadiusGeometry?` | Corner radii. |
| `shadows` | `List<BoxShadow>?` | Drop shadows. |

### HeroCardHeader

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Header content, top to bottom. |
| `gap` | `double` | 0 | Space between the children. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `start` | Horizontal alignment. |

### HeroCardTitle / HeroCardDescription

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Content (text inherits the style). |
| `.text(String)` | `String` | – | Named constructor showing a string. |
| `style` | `TextStyle?` | – | Merged over the default style. |

`HeroCardTitle.styleOf(theme)` and `HeroCardDescription.styleOf(theme)` return the default
styles.

### HeroCardContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Content, top to bottom. |
| `gap` | `double?` | 4 | Space between the children. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `start` | Horizontal alignment. |

HeroUI's content grows into free height (`flex-1`); in a card with a fixed height wrap it in
`Expanded`.

### HeroCardFooter

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Footer content. |
| `direction` | `Axis` | `horizontal` | Row or column (`flex-col`). |
| `gap` | `double` | 0 | Space between the children. |
| `mainAxisAlignment` | `MainAxisAlignment` | `start` | Placement along `direction`. |
| `crossAxisAlignment` | `CrossAxisAlignment` | `center` | Placement across `direction`. |

### HeroCardVariant

`transparent`, `standard`, `secondary`, `tertiary`, with `surfaceVariant` and
`background(colors)` helpers.
