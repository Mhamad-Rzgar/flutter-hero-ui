import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// The filled caret of the docs' custom separator (a 256×512 SVG, centered
/// in a square view box so it keeps its aspect ratio at 12 px).
const HeroIconData _caret = HeroIconData(
  <HeroIconPath>[
    HeroIconPath(
      'M377.3 235.8c10.2 12.6 9.5 31.1-2.2 42.8l-128 128c-9.2 9.2-22.9 '
      '11.9-34.9 6.9S192.5 396.9 192.5 384l0-256c0-12.9 7.8-24.6 '
      '19.8-29.6s25.7-2.2 34.9 6.9l128 128 2.2 2.4z',
    ),
  ],
  viewBoxWidth: 512,
  viewBoxHeight: 512,
  matchTextDirection: true,
);

Widget _breadcrumbs(
  List<String> labels, {
  bool isDisabled = false,
  Widget? separator,
}) => HeroBreadcrumbs(
  isDisabled: isDisabled,
  separator: separator,
  children: <Widget>[
    for (int i = 0; i < labels.length; i++)
      HeroBreadcrumbsItem(
        href: i == labels.length - 1 ? null : '#',
        onPressed: i == labels.length - 1 ? null : () {},
        child: Text(labels[i]),
      ),
  ],
);

const List<String> _products = <String>[
  'Home',
  'Products',
  'Electronics',
  'Laptop',
];

final ComponentDemo breadcrumbsDemo = ComponentDemo(
  slug: 'breadcrumbs',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('levels', <String>['2', '3', '4'], initial: '4'),
      ToggleControl('isDisabled'),
      ToggleControl('customSeparator'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _breadcrumbs(
      _products.sublist(4 - int.parse(values.option('levels'))),
      isDisabled: values.toggle('isDisabled'),
      separator: values.toggle('customSeparator')
          ? const HeroIcon(_caret)
          : null,
    ),
    code: (PlaygroundValues values) =>
        '''
HeroBreadcrumbs(
  isDisabled: ${values.toggle('isDisabled')},${values.toggle('customSeparator') ? '\n  separator: const HeroIcon(caret),' : ''}
  children: <Widget>[
${_products.sublist(4 - int.parse(values.option('levels'))).map((String l) => l == 'Laptop' ? "    const HeroBreadcrumbsItem(child: Text('$l'))," : "    HeroBreadcrumbsItem(href: '#', onPressed: open, child: const Text('$l')),").join('\n')}
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => _breadcrumbs(_products),
      code: '''
HeroBreadcrumbs(
  children: <Widget>[
    HeroBreadcrumbsItem(href: '#', onPressed: open, child: const Text('Home')),
    HeroBreadcrumbsItem(
      href: '#',
      onPressed: open,
      child: const Text('Products'),
    ),
    HeroBreadcrumbsItem(
      href: '#',
      onPressed: open,
      child: const Text('Electronics'),
    ),
    const HeroBreadcrumbsItem(child: Text('Laptop')),
  ],
)''',
    ),
    DemoExample(
      title: 'Navigation Levels',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          _breadcrumbs(const <String>['Home', 'Current Page']),
          _breadcrumbs(const <String>['Home', 'Category', 'Current Page']),
        ],
      ),
      code: '''
HeroBreadcrumbs(
  children: <Widget>[
    HeroBreadcrumbsItem(href: '#', onPressed: open, child: const Text('Home')),
    const HeroBreadcrumbsItem(child: Text('Current Page')),
  ],
)

HeroBreadcrumbs(
  children: <Widget>[
    HeroBreadcrumbsItem(href: '#', onPressed: open, child: const Text('Home')),
    HeroBreadcrumbsItem(
      href: '#',
      onPressed: open,
      child: const Text('Category'),
    ),
    const HeroBreadcrumbsItem(child: Text('Current Page')),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      builder: (BuildContext context) =>
          _breadcrumbs(_products, isDisabled: true),
      code: '''
HeroBreadcrumbs(
  isDisabled: true,
  children: <Widget>[
    HeroBreadcrumbsItem(href: '#', onPressed: open, child: const Text('Home')),
    // ...
    const HeroBreadcrumbsItem(child: Text('Laptop')),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Separator',
      builder: (BuildContext context) =>
          _breadcrumbs(_products, separator: const HeroIcon(_caret)),
      code: '''
const HeroIconData caret = HeroIconData(
  <HeroIconPath>[HeroIconPath('M377.3 235.8c10.2 12.6 ... 2.2 2.4z')],
  viewBoxWidth: 512,
  viewBoxHeight: 512,
  matchTextDirection: true,
);

HeroBreadcrumbs(
  separator: const HeroIcon(caret),
  children: <Widget>[
    HeroBreadcrumbsItem(href: '#', onPressed: open, child: const Text('Home')),
    // ...
    const HeroBreadcrumbsItem(child: Text('Laptop')),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'A builder renders each item from its state; the last item is the '
          'current page.',
      builder: (BuildContext context) => HeroBreadcrumbs(
        children: <Widget>[
          for (final String label in _products)
            HeroBreadcrumbsItem(
              onPressed: () {},
              builder: (BuildContext context, HeroBreadcrumbState state) =>
                  Text(label),
            ),
        ],
      ),
      code: '''
HeroBreadcrumbs(
  children: <Widget>[
    for (final String label in <String>['Home', 'Products', 'Electronics', 'Laptop'])
      HeroBreadcrumbsItem(
        onPressed: open,
        builder: (BuildContext context, HeroBreadcrumbState state) =>
            Text(label),
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A tinted container, links that turn accent on hover and a '
          'foreground current page.',
      builder: (BuildContext context) => const _CustomBreadcrumbs(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final HeroColors colors = theme.colors;
final HeroBreadcrumbsItemStyle linkStyle = HeroBreadcrumbsItemStyle(
  foregroundColor: WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) =>
        states.contains(WidgetState.hovered) ? colors.accent : colors.muted,
  ),
);

DecoratedBox(
  decoration: ShapeDecoration(
    color: colors.defaultSoft,
    shape: theme.shapeAll(theme.radii.lg),
  ),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: HeroBreadcrumbs(
      children: <Widget>[
        HeroBreadcrumbsItem(
          href: '#',
          onPressed: open,
          style: linkStyle,
          child: const Text('Home'),
        ),
        HeroBreadcrumbsItem(
          href: '#',
          onPressed: open,
          style: linkStyle,
          child: const Text('Products'),
        ),
        const HeroBreadcrumbsItem(child: Text('Laptop')),
      ],
    ),
  ),
)''',
    ),
  ],
);

class _CustomBreadcrumbs extends StatelessWidget {
  const _CustomBreadcrumbs();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroBreadcrumbsItemStyle linkStyle = HeroBreadcrumbsItemStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.hovered) ? colors.accent : colors.muted,
      ),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.defaultSoft,
        shape: theme.shapeAll(theme.radii.lg),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing(3),
          vertical: theme.spacing(2),
        ),
        child: HeroBreadcrumbs(
          children: <Widget>[
            HeroBreadcrumbsItem(
              href: '#',
              onPressed: () {},
              style: linkStyle,
              child: const Text('Home'),
            ),
            HeroBreadcrumbsItem(
              href: '#',
              onPressed: () {},
              style: linkStyle,
              child: const Text('Products'),
            ),
            HeroBreadcrumbsItem(
              style: HeroBreadcrumbsItemStyle(
                foregroundColor: WidgetStatePropertyAll<Color>(
                  colors.foreground,
                ),
              ),
              child: const Text('Laptop'),
            ),
          ],
        ),
      ),
    );
  }
}
