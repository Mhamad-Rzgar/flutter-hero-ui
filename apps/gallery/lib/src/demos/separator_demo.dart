import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

final ComponentDemo separatorDemo = ComponentDemo(
  slug: 'separator',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('orientation', <String>['horizontal', 'vertical']),
      OptionsControl('variant', <String>['standard', 'secondary', 'tertiary']),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final HeroThemeData theme = HeroTheme.of(context);
      final Axis axis = values.pick('orientation', Axis.values);
      final HeroSeparatorVariant variant = values.pick(
        'variant',
        HeroSeparatorVariant.values,
      );
      final TextStyle style = _text(theme, HeroFontSize.sm);
      if (axis == Axis.vertical) {
        return SizedBox(
          height: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              Text('Blog', style: style),
              HeroSeparator(orientation: axis, variant: variant),
              Text('Docs', style: style),
              HeroSeparator(orientation: axis, variant: variant),
              Text('Source', style: style),
            ],
          ),
        );
      }
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            Text('Above', style: style),
            HeroSeparator(variant: variant),
            Text('Below', style: style),
          ],
        ),
      );
    },
    code: (PlaygroundValues values) {
      final String variant = values.option('variant');
      final String variantArg = variant == 'standard'
          ? ''
          : ', variant: HeroSeparatorVariant.$variant';
      if (values.option('orientation') == 'vertical') {
        return '''
SizedBox(
  height: 20,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: <Widget>[
      Text('Blog'),
      HeroSeparator(orientation: Axis.vertical$variantArg),
      Text('Docs'),
      HeroSeparator(orientation: Axis.vertical$variantArg),
      Text('Source'),
    ],
  ),
)''';
      }
      final String args = variantArg.isEmpty ? '' : variantArg.substring(2);
      return '''
Column(
  spacing: 12,
  children: <Widget>[
    Text('Above'),
    HeroSeparator($args),
    Text('Below'),
  ],
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _Basic(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final TextStyle style = _text(theme, HeroFontSize.base);
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              Text('Default Variant', style: style),
              const HeroSeparator(),
              Text('Secondary Variant', style: style),
              const HeroSeparator(variant: HeroSeparatorVariant.secondary),
              Text('Tertiary Variant', style: style),
              const HeroSeparator(variant: HeroSeparatorVariant.tertiary),
            ],
          ),
        );
      },
      code: '''
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 448),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 12,
    children: <Widget>[
      Text('Default Variant'),
      HeroSeparator(),
      Text('Secondary Variant'),
      HeroSeparator(variant: HeroSeparatorVariant.secondary),
      Text('Tertiary Variant'),
      HeroSeparator(variant: HeroSeparatorVariant.tertiary),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'With Surface',
      description:
          'Match the separator variant to the surface it sits on: default on '
          'default and transparent surfaces, secondary on secondary and '
          'tertiary on tertiary.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 32,
        children: <Widget>[
          _SurfaceWithSeparator(
            variant: HeroSurfaceVariant.standard,
            title: 'Default Surface',
          ),
          _SurfaceWithSeparator(
            variant: HeroSurfaceVariant.secondary,
            separator: HeroSeparatorVariant.secondary,
            title: 'Secondary Surface',
          ),
          _SurfaceWithSeparator(
            variant: HeroSurfaceVariant.tertiary,
            separator: HeroSeparatorVariant.tertiary,
            title: 'Tertiary Surface',
          ),
          _SurfaceWithSeparator(
            variant: HeroSurfaceVariant.transparent,
            title: 'Transparent Surface',
          ),
        ],
      ),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  variant: HeroSurfaceVariant.secondary,
  constraints: const BoxConstraints(minWidth: 320),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: <Widget>[
      Text(
        'Secondary Surface',
        style: theme.typography
            .style(HeroFontSize.base, weight: HeroTypography.semibold)
            .copyWith(color: theme.colors.foreground),
      ),
      const HeroSeparator(variant: HeroSeparatorVariant.secondary),
      Text(
        'Surface Content',
        style: theme.typography.sm.copyWith(color: theme.colors.muted),
      ),
    ],
  ),
)

// The transparent surface gets a border instead of a background.
HeroSurface(
  variant: HeroSurfaceVariant.transparent,
  border: BorderSide(color: theme.colors.border, width: theme.borderWidth),
  // ...
)''',
    ),
    DemoExample(
      title: 'Vertical',
      builder: (BuildContext context) => const _LinksRow(),
      code: '''
SizedBox(
  height: 20,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: <Widget>[
      Text('Blog'),
      HeroSeparator(orientation: Axis.vertical),
      Text('Docs'),
      HeroSeparator(orientation: Axis.vertical),
      Text('Source'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'With Content',
      builder: (BuildContext context) => const _WithContent(),
      code: r'''
const List<(String, String, String)> items = <(String, String, String)>[
  ('Set Up Notifications', 'Receive account activity updates',
      '$assets/bell-small.png'),
  ('Set up Browser Extension', 'Connect your browser to your account',
      '$assets/compass-small.png'),
  ('Mint Collectible', 'Create your first collectible',
      '$assets/mint-collective-small.png'),
];

Column(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    for (final (int i, (String title, String subtitle, String url))
        in items.indexed) ...<Widget>[
      Row(
        spacing: 12,
        children: <Widget>[
          Image.network(url, width: 48, height: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: medium14),
                Text(subtitle, style: muted14),
              ],
            ),
          ),
        ],
      ),
      if (i < items.length - 1)
        HeroSeparator(margin: EdgeInsets.symmetric(vertical: 16)),
    ],
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'React renders the separator through a custom element. In Flutter '
          'the separator is composed like any other widget, so the output is '
          'identical to the basic example.',
      builder: (BuildContext context) => const _Basic(wrap: _wrapSeparator),
      code: '''
// Wrap or replace the separator with your own widget.
class CustomElement extends StatelessWidget {
  const CustomElement({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

CustomElement(
  child: HeroSeparator(margin: EdgeInsets.symmetric(vertical: 16)),
);
CustomElement(child: HeroSeparator(orientation: Axis.vertical));''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final TextStyle muted = _text(
          theme,
          HeroFontSize.sm,
        ).copyWith(color: theme.colors.muted);
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: <Widget>[
              Text(
                'Account settings',
                style: _text(
                  theme,
                  HeroFontSize.sm,
                  weight: HeroTypography.medium,
                ),
              ),
              HeroSeparator(color: theme.colors.separatorSecondary),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text('Profile', style: muted),
                  HeroSeparator(
                    orientation: Axis.vertical,
                    length: 16,
                    color: theme.colors.separator,
                  ),
                  Text('Billing', style: muted),
                  HeroSeparator(
                    orientation: Axis.vertical,
                    length: 16,
                    color: theme.colors.separator,
                  ),
                  Text('Security', style: muted),
                ],
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);

ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 320),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      Text('Account settings'),
      HeroSeparator(color: theme.colors.separatorSecondary),
      Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text('Profile'),
          HeroSeparator(
            orientation: Axis.vertical,
            length: 16,
            color: theme.colors.separator,
          ),
          Text('Billing'),
          HeroSeparator(
            orientation: Axis.vertical,
            length: 16,
            color: theme.colors.separator,
          ),
          Text('Security'),
        ],
      ),
    ],
  ),
)''',
    ),
  ],
);

const String _basicCode = '''
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 448),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('HeroUI v3 Components'),
      SizedBox(height: 4),
      Text('Beautiful, fast and modern React UI library.'),
      HeroSeparator(margin: EdgeInsets.symmetric(vertical: 16)),
      SizedBox(
        height: 20,
        child: Row(
          spacing: 16,
          children: <Widget>[
            Text('Blog'),
            HeroSeparator(orientation: Axis.vertical),
            Text('Docs'),
            HeroSeparator(orientation: Axis.vertical),
            Text('Source'),
          ],
        ),
      ),
    ],
  ),
)''';

TextStyle _text(
  HeroThemeData theme,
  HeroFontSize size, {
  FontWeight weight = HeroTypography.normal,
}) => theme.typography
    .style(size, weight: weight)
    .copyWith(color: theme.colors.foreground);

Widget _wrapSeparator(Widget separator) => _CustomElement(child: separator);

class _CustomElement extends StatelessWidget {
  const _CustomElement({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

Widget _identity(Widget separator) => separator;

class _Basic extends StatelessWidget {
  const _Basic({this.wrap = _identity});

  final Widget Function(Widget separator) wrap;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'HeroUI v3 Components',
            style: _text(
              theme,
              HeroFontSize.base,
              weight: HeroTypography.medium,
            ),
          ),
          SizedBox(height: theme.spacing(1)),
          Text(
            'Beautiful, fast and modern React UI library.',
            style: _text(
              theme,
              HeroFontSize.sm,
            ).copyWith(color: theme.colors.muted),
          ),
          wrap(
            HeroSeparator(
              margin: EdgeInsets.symmetric(vertical: theme.spacing(4)),
            ),
          ),
          _LinksRow(wrap: wrap),
        ],
      ),
    );
  }
}

class _LinksRow extends StatelessWidget {
  const _LinksRow({this.wrap = _identity});

  final Widget Function(Widget separator) wrap;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle style = _text(theme, HeroFontSize.sm);
    return SizedBox(
      height: theme.spacing(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(4),
        children: <Widget>[
          Text('Blog', style: style),
          wrap(const HeroSeparator(orientation: Axis.vertical)),
          Text('Docs', style: style),
          wrap(const HeroSeparator(orientation: Axis.vertical)),
          Text('Source', style: style),
        ],
      ),
    );
  }
}

const String _assets =
    'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/docs/3dicons';

const List<(String, String, String, HeroIconData)> _contentItems =
    <(String, String, String, HeroIconData)>[
      (
        'Set Up Notifications',
        'Receive account activity updates',
        '$_assets/bell-small.png',
        HeroIcons.bell,
      ),
      (
        'Set up Browser Extension',
        'Connect your browser to your account',
        '$_assets/compass-small.png',
        HeroIcons.globe,
      ),
      (
        'Mint Collectible',
        'Create your first collectible',
        '$_assets/mint-collective-small.png',
        HeroIcons.sparkles,
      ),
    ];

class _WithContent extends StatelessWidget {
  const _WithContent();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double iconSize = theme.spacing(12);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 448),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final (
                int index,
                (String title, String subtitle, String url, HeroIconData icon),
              )
              in _contentItems.indexed) ...<Widget>[
            Row(
              spacing: theme.spacing(3),
              children: <Widget>[
                Image.network(
                  url,
                  width: iconSize,
                  height: iconSize,
                  semanticLabel: title,
                  errorBuilder: (BuildContext context, _, _) => SizedBox.square(
                    dimension: iconSize,
                    child: Center(
                      child: HeroIcon(
                        icon,
                        size: theme.spacing(8),
                        color: theme.colors.muted,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: _text(
                          theme,
                          HeroFontSize.sm,
                          weight: HeroTypography.medium,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: _text(
                          theme,
                          HeroFontSize.sm,
                        ).copyWith(color: theme.colors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index < _contentItems.length - 1)
              HeroSeparator(
                margin: EdgeInsets.symmetric(vertical: theme.spacing(4)),
              ),
          ],
        ],
      ),
    );
  }
}

/// A rounded, padded surface with a heading, a separator of the matching
/// variant and a line of text (HeroUI's `separator-with-surface`).
class _SurfaceWithSeparator extends StatelessWidget {
  const _SurfaceWithSeparator({
    required this.variant,
    required this.title,
    this.separator = HeroSeparatorVariant.standard,
  });

  final HeroSurfaceVariant variant;
  final HeroSeparatorVariant separator;
  final String title;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroSurface(
      variant: variant,
      constraints: const BoxConstraints(minWidth: 320),
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      padding: EdgeInsets.all(theme.spacing(6)),
      border: variant == HeroSurfaceVariant.transparent
          ? BorderSide(color: theme.colors.border, width: theme.borderWidth)
          : null,
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(3),
          children: <Widget>[
            Text(
              title,
              style: _text(
                theme,
                HeroFontSize.base,
                weight: HeroTypography.semibold,
              ),
            ),
            HeroSeparator(variant: separator),
            Text(
              'Surface Content',
              style: _text(
                theme,
                HeroFontSize.sm,
              ).copyWith(color: theme.colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
