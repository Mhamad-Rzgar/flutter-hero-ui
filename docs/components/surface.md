# Surface

Container component that provides surface-level styling and context for child
components.

HeroUI docs: [heroui.com/en/docs/react/components/surface](https://heroui.com/en/docs/react/components/surface)

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  constraints: const BoxConstraints(minWidth: 320),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: <Widget>[
      Text(
        'Surface Content',
        style: theme.typography
            .style(HeroFontSize.base, weight: HeroTypography.semibold)
            .copyWith(color: theme.colors.foreground),
      ),
      Text(
        'This is a default surface variant. It uses bg-surface styling.',
        style: theme.typography.sm.copyWith(color: theme.colors.muted),
      ),
    ],
  ),
)
```

## Anatomy

`HeroSurface` is a single container. It publishes a `HeroSurfaceScope` (the
counterpart of HeroUI's `SurfaceContext`) so descendants know which surface
they sit on:

```dart
final HeroSurfaceVariant? surface = HeroSurfaceScope.variantOf(context);
```

Other surface-like containers (cards, alerts, popovers, modals, drawers) publish
the same scope.

## Variants

| Variant | Background | Text and icons |
| --- | --- | --- |
| `HeroSurfaceVariant.standard` (default, HeroUI `default`) | `--surface` | `--surface-foreground` |
| `HeroSurfaceVariant.secondary` | `--surface-secondary` | `--surface-secondary-foreground` |
| `HeroSurfaceVariant.tertiary` | `--surface-tertiary` | `--surface-tertiary-foreground` |
| `HeroSurfaceVariant.transparent` | none | `--foreground` |

Like HeroUI, a surface has no radius, padding or shadow by default; pass
`borderRadius`, `padding`, `border` and `shadow` as needed (the counterpart of
`className`). A border takes room inside the surface like a CSS border, and
corners follow the theme's corner style.

## Examples

### With form components

Use the secondary variant of form fields on surfaces.

```dart
HeroSurface(
  constraints: const BoxConstraints(minWidth: 320),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const IntrinsicWidth(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        HeroInput(
          placeholder: 'Input with secondary variant',
          variant: HeroFieldVariant.secondary,
        ),
        HeroTextArea(
          placeholder: 'TextArea with secondary variant',
          variant: HeroFieldVariant.secondary,
        ),
      ],
    ),
  ),
)
```

### Customization

A gradient is painted over the variant background, like a CSS
`background-image` over `background-color`.

```dart
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl),
  border: BorderSide(
    color: theme.colors.accent.withValues(alpha: 0.15),
    width: theme.borderWidth,
  ),
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color.alphaBlend(
        theme.colors.accent.withValues(alpha: 0.08),
        theme.colors.surface,
      ),
      theme.colors.surface,
      theme.colors.surfaceSecondary,
    ],
  ),
  padding: EdgeInsets.all(theme.spacing(4)),
  child: content,
)
```

## Accessibility

A surface is a visual container and adds nothing to the semantics tree.
Padding given as `EdgeInsetsDirectional` follows the text direction.

## API

### HeroSurface

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Surface content. |
| `variant` | `HeroSurfaceVariant` | `standard` | Surface variant. |
| `padding` | `EdgeInsetsGeometry?` | – | Inner padding. |
| `borderRadius` | `BorderRadiusGeometry?` | – | Corner radius. |
| `border` | `BorderSide?` | – | Border drawn inside the surface. |
| `width` / `height` | `double?` | – | Fixed size. |
| `constraints` | `BoxConstraints?` | – | Extra constraints (for example a minimum width). |
| `color` | `Color?` | variant background | Background override. |
| `gradient` | `Gradient?` | – | Gradient over the background. |
| `shadow` | `HeroShadow?` | – | Shadow (for example `theme.shadows.surface`). |
| `alignment` | `AlignmentGeometry?` | – | Aligns the child inside the surface. |
| `clipBehavior` | `Clip` | `none` | Clips the child to the surface shape. |

### HeroSurfaceScope

| Member | Description |
| --- | --- |
| `variant` | The surface variant descendants sit on. |
| `HeroSurfaceScope.maybeOf(context)` | The closest scope, or null. |
| `HeroSurfaceScope.variantOf(context)` | The closest surface variant, or null. |

### HeroSurfaceVariant

`transparent`, `standard`, `secondary`, `tertiary`, with `background(colors)`
and `foreground(colors)` helpers.
