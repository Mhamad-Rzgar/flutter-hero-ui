# Pagination

Page navigation with composable page links, previous/next buttons, and ellipsis indicators.

HeroUI reference: <https://heroui.com/en/docs/react/components/pagination>

## Import

```dart
import 'package:hero_ui/hero_ui.dart';
```

## Usage

```dart
int page = 1;
const int totalPages = 3;

HeroPagination(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
    HeroPaginationContent(
      children: <Widget>[
        HeroPaginationItem(
          child: HeroPaginationPrevious(
            isDisabled: page == 1,
            onPressed: () => setState(() => page--),
            children: const <Widget>[HeroPaginationPreviousIcon(), Text('Previous')],
          ),
        ),
        for (int p = 1; p <= totalPages; p++)
          HeroPaginationItem(
            child: HeroPaginationLink(
              isActive: p == page,
              onPressed: () => setState(() => page = p),
              child: Text('$p'),
            ),
          ),
        HeroPaginationItem(
          child: HeroPaginationNext(
            isDisabled: page == totalPages,
            onPressed: () => setState(() => page++),
            children: const <Widget>[Text('Next'), HeroPaginationNextIcon()],
          ),
        ),
      ],
    ),
  ],
)
```

## Anatomy

| HeroUI | Flutter |
| --- | --- |
| `Pagination` | `HeroPagination` |
| `Pagination.Summary` | `HeroPaginationSummary` |
| `Pagination.Content` | `HeroPaginationContent` |
| `Pagination.Item` | `HeroPaginationItem` |
| `Pagination.Link` | `HeroPaginationLink` |
| `Pagination.Previous` / `Pagination.Next` | `HeroPaginationPrevious` / `HeroPaginationNext` |
| `Pagination.PreviousIcon` / `Pagination.NextIcon` | `HeroPaginationPreviousIcon` / `HeroPaginationNextIcon` |
| `Pagination.Ellipsis` | `HeroPaginationEllipsis` |

The component is stateless: keep the page in your state. `heroPaginationRange(page:, total:)`
returns the page numbers of HeroUI's ellipsis examples, with `null` for an ellipsis
(`[1, null, 5, 6, 7, null, 12]`).

## Layout and sizes

- Below 640 px the summary sits above the content, both aligned to the start, 16 px apart.
  From 640 px they share a row distributed by `mainAxisAlignment` (`spaceBetween` by default;
  the docs examples center a lone content row).
- Content items are 4 px apart. Links are ghost buttons: transparent, `--default-hover` on
  hover and press, `--default` for the active page, `--default-foreground` medium text, 24 px
  radius, press scale.

| Size | Link (< 768 / ≥ 768) | Text | Previous/Next padding | Pressed scale |
| --- | --- | --- | --- | --- |
| `sm` | 32 / 28 | 12 | 8 | 0.98 |
| `md` (default) | 36 / 32 | 14 | 10 | 0.97 |
| `lg` | 40 / 36 | 16 | 12 | 0.96 |

Previous/Next are as wide as their content with a 6 px gap and 16 px chevrons that mirror in
right-to-left layouts. The summary text is 14 px `--muted` (12 / 16 for `sm` / `lg`). Sizes are
minimums, so links grow with the text scale.

## Examples

### Sizes

```dart
HeroPagination(size: HeroSize.lg, children: <Widget>[...])
```

### Disabled

```dart
HeroPaginationPrevious(
  isDisabled: true,
  children: const <Widget>[HeroPaginationPreviousIcon(), Text('Previous')],
)
```

### Simple (Previous / Next)

```dart
HeroPagination(
  children: <Widget>[
    HeroPaginationSummary(child: Text('$startItem to $endItem of 50 invoices')),
    HeroPaginationContent(children: <Widget>[previousItem, nextItem]),
  ],
)
```

### With ellipsis

```dart
for (final int? p in heroPaginationRange(page: page, total: 12))
  HeroPaginationItem(
    child: p == null
        ? const HeroPaginationEllipsis()
        : HeroPaginationLink(
            isActive: p == page,
            onPressed: () => setState(() => page = p),
            child: Text('$p'),
          ),
  )
```

Long paginations can be wrapped in a horizontal `SingleChildScrollView` on narrow screens, as
the HeroUI example does with `overflow-x-auto`.

### With summary

```dart
HeroPaginationSummary(child: Text('Showing 1-10 of 120 results'))
```

### Custom icons

```dart
HeroPaginationPreviousIcon(child: HeroIcon(HeroIcons.arrowLeft))
```

### Customization

```dart
HeroPaginationContent(
  padding: const EdgeInsets.all(4),
  decoration: ShapeDecoration(
    color: colors.defaultColor,
    shape: theme.shapeAll(theme.radii.xl),
  ),
  children: <Widget>[
    HeroPaginationItem(
      child: HeroPaginationLink(
        isActive: true,
        style: HeroPaginationLinkStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(colors.accent),
          foregroundColor: WidgetStatePropertyAll<Color>(colors.accentForeground),
        ),
        child: const Text('2'),
      ),
    ),
  ],
)
```

## Accessibility

- The root is a navigation landmark (`SemanticsRole.navigation`) labelled "pagination"; the
  content is a list of list items.
- Links and previous/next are buttons; the active page is exposed as selected
  (`aria-current="page"`). Disabled buttons are faded and leave the focus order.
- Tab moves through the buttons; Enter and Space press them. The focus ring shows only for
  keyboard focus.
- The ellipsis is hidden from assistive technologies. Icon-only previous/next buttons need a
  `semanticLabel`.

## API

### HeroPagination

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Summary and content. |
| `size` | `HeroSize` | `md` | Size of links, ellipsis and summary. |
| `mainAxisAlignment` | `MainAxisAlignment` | `spaceBetween` | Distribution from 640 px. |
| `semanticLabel` | `String` | `'pagination'` | Landmark label. |

### HeroPaginationSummary

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Summary content. |

### HeroPaginationContent

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | The items. |
| `decoration` | `Decoration?` | `null` | Background of the row. |
| `padding` | `EdgeInsetsGeometry?` | `null` | Padding inside the decoration. |

### HeroPaginationItem

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Link, previous/next or ellipsis. |

### HeroPaginationLink

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget` | required | Page number. |
| `isActive` | `bool` | `false` | Current page. |
| `isDisabled` | `bool` | `false` | Disables the link. |
| `onPressed` | `VoidCallback?` | `null` | Press handler. |
| `style` | `HeroPaginationLinkStyle?` | `null` | Style overrides. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### HeroPaginationPrevious / HeroPaginationNext

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `children` | `List<Widget>` | required | Icon and label. |
| `isDisabled` | `bool` | `false` | Disables the button. |
| `onPressed` | `VoidCallback?` | `null` | Press handler. |
| `style` | `HeroPaginationLinkStyle?` | `null` | Style overrides. |
| `semanticLabel` | `String?` | `null` | Accessibility label. |

### HeroPaginationPreviousIcon / HeroPaginationNextIcon

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `child` | `Widget?` | chevron | Replaces the chevron. |

### HeroPaginationEllipsis

No parameters.

### HeroPaginationLinkStyle

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `backgroundColor` | `WidgetStateProperty<Color?>?` | `null` | Fill (`selected` = active page). |
| `foregroundColor` | `WidgetStateProperty<Color?>?` | `null` | Text and icon color. |
| `borderRadius` | `BorderRadiusGeometry?` | `null` | Corner radii. |

### heroPaginationRange

`List<int?> heroPaginationRange({required int page, required int total})` — page numbers with
`null` for ellipses.
