import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

enum _Pages { all, ellipsis, compact }

/// A stateful pagination reproducing the docs examples.
class _PaginationExample extends StatefulWidget {
  const _PaginationExample({
    super.key,
    this.total = 3,
    this.initialPage = 1,
    this.size = HeroSize.md,
    this.pages = _Pages.all,
    this.alignment = MainAxisAlignment.center,
    this.summary,
    this.showPages = true,
    this.disabledNav = false,
    this.previousLabel = 'Previous',
    this.nextLabel = 'Next',
    this.previousIcon,
    this.nextIcon,
    this.custom = false,
  });

  final int total;
  final int initialPage;
  final HeroSize size;
  final _Pages pages;
  final MainAxisAlignment alignment;
  final String Function(int page)? summary;
  final bool showPages;
  final bool disabledNav;
  final String? previousLabel;
  final String? nextLabel;
  final HeroIconData? previousIcon;
  final HeroIconData? nextIcon;
  final bool custom;

  @override
  State<_PaginationExample> createState() => _PaginationExampleState();
}

class _PaginationExampleState extends State<_PaginationExample> {
  late int _page = widget.initialPage;

  List<int?> get _pageNumbers => switch (widget.pages) {
    _Pages.all => <int?>[for (int i = 1; i <= widget.total; i++) i],
    _Pages.ellipsis => heroPaginationRange(page: _page, total: widget.total),
    // The controlled example lists every page up to 7 pages.
    _Pages.compact =>
      widget.total <= 7
          ? <int?>[for (int i = 1; i <= widget.total; i++) i]
          : heroPaginationRange(page: _page, total: widget.total),
  };

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    // `text-muted hover:bg-surface hover:text-foreground` and the active
    // `bg-accent text-accent-foreground hover:bg-accent-hover`.
    final HeroPaginationLinkStyle? linkStyle = widget.custom
        ? HeroPaginationLinkStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> s) => s.contains(WidgetState.selected)
                  ? (s.contains(WidgetState.hovered)
                        ? colors.accentHover
                        : colors.accent)
                  : s.contains(WidgetState.hovered)
                  ? colors.surface
                  : null,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> s) => s.contains(WidgetState.selected)
                  ? colors.accentForeground
                  : s.contains(WidgetState.hovered)
                  ? colors.foreground
                  : colors.muted,
            ),
          )
        : null;
    // Like the docs' `overflow-x-auto` wrapper: long paginations scroll on
    // narrow screens instead of overflowing.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : 0,
              ),
              child: _pagination(theme, colors, linkStyle),
            ),
          ),
    );
  }

  Widget _pagination(
    HeroThemeData theme,
    HeroColors colors,
    HeroPaginationLinkStyle? linkStyle,
  ) {
    return HeroPagination(
      size: widget.size,
      mainAxisAlignment: widget.alignment,
      children: <Widget>[
        if (widget.summary != null)
          HeroPaginationSummary(child: Text(widget.summary!(_page))),
        HeroPaginationContent(
          decoration: widget.custom
              ? ShapeDecoration(
                  color: colors.defaultColor,
                  shape: theme.shapeAll(theme.radii.xl),
                )
              : null,
          padding: widget.custom ? EdgeInsets.all(theme.spacing(1)) : null,
          children: <Widget>[
            HeroPaginationItem(
              child: HeroPaginationPrevious(
                isDisabled: widget.disabledNav || _page == 1,
                style: linkStyle,
                semanticLabel: widget.previousLabel == null
                    ? 'Previous page'
                    : null,
                onPressed: () => setState(() => _page--),
                children: <Widget>[
                  HeroPaginationPreviousIcon(
                    child: widget.previousIcon == null
                        ? null
                        : HeroIcon(widget.previousIcon!),
                  ),
                  if (widget.previousLabel != null) Text(widget.previousLabel!),
                ],
              ),
            ),
            if (widget.showPages)
              for (final int? p in _pageNumbers)
                HeroPaginationItem(
                  child: p == null
                      ? const HeroPaginationEllipsis()
                      : HeroPaginationLink(
                          isActive: p == _page,
                          style: linkStyle,
                          onPressed: () => setState(() => _page = p),
                          child: Text('$p'),
                        ),
                ),
            HeroPaginationItem(
              child: HeroPaginationNext(
                isDisabled: widget.disabledNav || _page == widget.total,
                style: linkStyle,
                semanticLabel: widget.nextLabel == null ? 'Next page' : null,
                onPressed: () => setState(() => _page++),
                children: <Widget>[
                  if (widget.nextLabel != null) Text(widget.nextLabel!),
                  HeroPaginationNextIcon(
                    child: widget.nextIcon == null
                        ? null
                        : HeroIcon(widget.nextIcon!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const String _basicCode = r'''
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
            children: const <Widget>[
              HeroPaginationPreviousIcon(),
              Text('Previous'),
            ],
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
            children: const <Widget>[
              Text('Next'),
              HeroPaginationNextIcon(),
            ],
          ),
        ),
      ],
    ),
  ],
)''';

const String _ellipsisCode = r'''
int page = 1;
const int totalPages = 12;

HeroPaginationContent(
  children: <Widget>[
    HeroPaginationItem(child: previousButton),
    for (final int? p in heroPaginationRange(page: page, total: totalPages))
      HeroPaginationItem(
        child: p == null
            ? const HeroPaginationEllipsis()
            : HeroPaginationLink(
                isActive: p == page,
                onPressed: () => setState(() => page = p),
                child: Text('$p'),
              ),
      ),
    HeroPaginationItem(child: nextButton),
  ],
)''';

final ComponentDemo paginationDemo = ComponentDemo(
  slug: 'pagination',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      ToggleControl('withEllipsis'),
      ToggleControl('withSummary'),
    ],
    builder: (BuildContext context, PlaygroundValues values) =>
        _PaginationExample(
          key: ValueKey<String>(
            '${values.toggle('withEllipsis')}${values.toggle('withSummary')}',
          ),
          size: values.pick('size', HeroSize.values),
          total: values.toggle('withEllipsis') ? 12 : 3,
          pages: values.toggle('withEllipsis') ? _Pages.ellipsis : _Pages.all,
          alignment: values.toggle('withSummary')
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          summary: values.toggle('withSummary')
              ? (int page) => 'Page $page'
              : null,
        ),
    code: (PlaygroundValues values) =>
        '''
HeroPagination(
  size: HeroSize.${values.option('size')},
  children: <Widget>[
${values.toggle('withSummary') ? "    HeroPaginationSummary(child: Text('Page \$page')),\n" : ''}    HeroPaginationContent(
      children: <Widget>[
        // Previous, ${values.toggle('withEllipsis') ? 'heroPaginationRange(page: page, total: 12)' : 'pages 1 to 3'}, Next.
      ],
    ),
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _PaginationExample(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: <Widget>[
            for (final HeroSize size in HeroSize.values)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: <Widget>[
                  Text(
                    size.name,
                    style: theme.typography
                        .style(HeroFontSize.xs, weight: HeroTypography.medium)
                        .copyWith(color: theme.colors.muted),
                  ),
                  _PaginationExample(size: size),
                ],
              ),
          ],
        );
      },
      code: '''
HeroPagination(
  size: HeroSize.sm, // HeroSize.md, HeroSize.lg
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
    HeroPaginationContent(children: items),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) =>
          const _PaginationExample(disabledNav: true),
      code: '''
HeroPaginationPrevious(
  isDisabled: true,
  onPressed: () => setState(() => page--),
  children: const <Widget>[
    HeroPaginationPreviousIcon(),
    Text('Previous'),
  ],
)''',
    ),
    DemoExample(
      title: 'Simple (Previous / Next)',
      builder: (BuildContext context) => _PaginationExample(
        total: 10,
        showPages: false,
        alignment: MainAxisAlignment.spaceBetween,
        previousLabel: 'Prev',
        summary: (int page) =>
            '${(page - 1) * 5 + 1} to ${page * 5 > 50 ? 50 : page * 5} of 50 '
            'invoices',
      ),
      code: r'''
int page = 1;
const int totalPages = 10;
const int itemsPerPage = 5;
const int totalItems = 50;
final int startItem = (page - 1) * itemsPerPage + 1;
final int endItem = math.min(page * itemsPerPage, totalItems);

HeroPagination(
  children: <Widget>[
    HeroPaginationSummary(
      child: Text('$startItem to $endItem of $totalItems invoices'),
    ),
    HeroPaginationContent(
      children: <Widget>[
        HeroPaginationItem(
          child: HeroPaginationPrevious(
            isDisabled: page == 1,
            onPressed: () => setState(() => page--),
            children: const <Widget>[
              HeroPaginationPreviousIcon(),
              Text('Prev'),
            ],
          ),
        ),
        HeroPaginationItem(
          child: HeroPaginationNext(
            isDisabled: page == totalPages,
            onPressed: () => setState(() => page++),
            children: const <Widget>[
              Text('Next'),
              HeroPaginationNextIcon(),
            ],
          ),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => _PaginationExample(
        total: 12,
        pages: _Pages.compact,
        alignment: MainAxisAlignment.spaceBetween,
        summary: (int page) =>
            'Showing ${(page - 1) * 10 + 1}-${page * 10} of 120 results',
      ),
      code: r'''
int page = 1;
const int totalPages = 12;

List<int?> pageNumbers() => totalPages <= 7
    ? <int?>[for (int i = 1; i <= totalPages; i++) i]
    : heroPaginationRange(page: page, total: totalPages);

HeroPagination(
  children: <Widget>[
    HeroPaginationSummary(
      child: Text(
        'Showing ${(page - 1) * 10 + 1}-${page * 10} of 120 results',
      ),
    ),
    HeroPaginationContent(
      children: <Widget>[
        // Previous, pageNumbers() (null = HeroPaginationEllipsis), Next.
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'With Ellipsis',
      builder: (BuildContext context) =>
          const _PaginationExample(total: 12, pages: _Pages.ellipsis),
      code: _ellipsisCode,
    ),
    DemoExample(
      title: 'With Summary',
      builder: (BuildContext context) => _PaginationExample(
        total: 12,
        pages: _Pages.ellipsis,
        alignment: MainAxisAlignment.spaceBetween,
        summary: (int page) =>
            'Showing ${(page - 1) * 10 + 1}-${page * 10} of 120 results',
      ),
      code: r'''
HeroPagination(
  children: <Widget>[
    HeroPaginationSummary(
      child: Text(
        'Showing ${(page - 1) * 10 + 1}-${page * 10} of 120 results',
      ),
    ),
    HeroPaginationContent(children: items),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Icons',
      description:
          'Pass a child to HeroPaginationPreviousIcon and '
          'HeroPaginationNextIcon to replace the chevrons.',
      builder: (BuildContext context) => const _PaginationExample(
        previousLabel: 'Back',
        nextLabel: 'Forward',
        previousIcon: HeroIcons.arrowLeft,
        nextIcon: HeroIcons.arrowRight,
      ),
      code: '''
HeroPaginationPrevious(
  isDisabled: page == 1,
  onPressed: () => setState(() => page--),
  children: const <Widget>[
    HeroPaginationPreviousIcon(child: HeroIcon(HeroIcons.arrowLeft)),
    Text('Back'),
  ],
)

HeroPaginationNext(
  isDisabled: page == totalPages,
  onPressed: () => setState(() => page++),
  children: const <Widget>[
    Text('Forward'),
    HeroPaginationNextIcon(child: HeroIcon(HeroIcons.arrowRight)),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => const _PaginationExample(
        initialPage: 2,
        previousLabel: null,
        nextLabel: null,
        custom: true,
      ),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final HeroColors colors = theme.colors;
final HeroPaginationLinkStyle linkStyle = HeroPaginationLinkStyle(
  backgroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> s) => s.contains(WidgetState.selected)
        ? (s.contains(WidgetState.hovered) ? colors.accentHover : colors.accent)
        : s.contains(WidgetState.hovered)
        ? colors.surface
        : null,
  ),
  foregroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> s) => s.contains(WidgetState.selected)
        ? colors.accentForeground
        : s.contains(WidgetState.hovered)
        ? colors.foreground
        : colors.muted,
  ),
);

HeroPaginationContent(
  padding: const EdgeInsets.all(4),
  decoration: ShapeDecoration(
    color: colors.defaultColor,
    shape: theme.shapeAll(theme.radii.xl),
  ),
  children: <Widget>[
    HeroPaginationItem(
      child: HeroPaginationPrevious(
        style: linkStyle,
        semanticLabel: 'Previous page',
        onPressed: () => setState(() => page--),
        children: const <Widget>[HeroPaginationPreviousIcon()],
      ),
    ),
    // Links 1-3 and Next with the same style.
  ],
)''',
    ),
  ],
);
