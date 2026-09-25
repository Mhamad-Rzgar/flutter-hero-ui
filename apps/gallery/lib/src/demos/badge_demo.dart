import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _avatars =
    'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com/avatars';
const String _green = '$_avatars/green.jpg';

const List<HeroColor> _colors = <HeroColor>[
  HeroColor.accent,
  HeroColor.standard,
  HeroColor.success,
  HeroColor.warning,
  HeroColor.danger,
];

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

Widget _avatar({String src = _green, HeroSize? size, String initials = 'JD'}) =>
    HeroAvatar(src: src, size: size, fallback: Text(initials));

final ComponentDemo badgeDemo = ComponentDemo(
  slug: 'badge',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary', 'soft']),
      OptionsControl('color', <String>[
        'standard',
        'accent',
        'success',
        'warning',
        'danger',
      ], initial: 'danger'),
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('placement', <String>[
        'topRight',
        'topLeft',
        'bottomRight',
        'bottomLeft',
      ]),
      OptionsControl('content', <String>['5', 'New', '99+', 'dot']),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final String content = values.option('content');
      final HeroSize size = values.pick('size', HeroSize.values);
      return HeroBadgeAnchor(
        badge: HeroBadge(
          variant: values.pick('variant', HeroBadgeVariant.values),
          color: values.pick('color', HeroColor.values),
          size: size,
          placement: values.pick('placement', HeroBadgePlacement.values),
          label: content == 'dot' ? null : content,
        ),
        child: _avatar(size: size),
      );
    },
    code: (PlaygroundValues values) {
      final String content = values.option('content');
      final List<String> args = <String>[
        if (values.option('variant') != 'primary')
          'variant: HeroBadgeVariant.${values.option('variant')}',
        if (values.option('color') != 'standard')
          'color: HeroColor.${values.option('color')}',
        if (values.option('size') != 'md')
          'size: HeroSize.${values.option('size')}',
        if (values.option('placement') != 'topRight')
          'placement: HeroBadgePlacement.${values.option('placement')}',
        if (content != 'dot') "label: '$content'",
      ];
      return '''
HeroBadgeAnchor(
  badge: HeroBadge(
${args.map((String a) => '    $a,\n').join()}  ),
  child: HeroAvatar(src: avatarUrl, fallback: Text('JD')),
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          HeroBadgeAnchor(
            badge: const HeroBadge(
              label: '5',
              color: HeroColor.danger,
              size: HeroSize.sm,
            ),
            child: _avatar(),
          ),
          HeroBadgeAnchor(
            badge: const HeroBadge(
              label: 'New',
              color: HeroColor.accent,
              size: HeroSize.sm,
            ),
            child: _avatar(src: '$_avatars/orange.jpg', initials: 'AB'),
          ),
          HeroBadgeAnchor(
            badge: const HeroBadge(
              color: HeroColor.success,
              placement: HeroBadgePlacement.bottomRight,
              size: HeroSize.sm,
            ),
            child: _avatar(src: '$_avatars/blue.jpg', initials: 'CD'),
          ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 24,
  children: <Widget>[
    HeroBadgeAnchor(
      badge: HeroBadge(label: '5', color: HeroColor.danger, size: HeroSize.sm),
      child: HeroAvatar(src: greenUrl, fallback: Text('JD')),
    ),
    HeroBadgeAnchor(
      badge: HeroBadge(label: 'New', color: HeroColor.accent, size: HeroSize.sm),
      child: HeroAvatar(src: orangeUrl, fallback: Text('AB')),
    ),
    HeroBadgeAnchor(
      badge: HeroBadge(
        color: HeroColor.success,
        placement: HeroBadgePlacement.bottomRight,
        size: HeroSize.sm,
      ),
      child: HeroAvatar(src: blueUrl, fallback: Text('CD')),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: theme.spacing(8),
          children: <Widget>[
            for (final (int index, HeroBadgeVariant variant)
                in HeroBadgeVariant.values.indexed) ...<Widget>[
              if (index > 0) const HeroSeparator(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: theme.spacing(4),
                children: <Widget>[
                  Text(
                    _capitalize(variant.name),
                    style: theme.typography
                        .style(HeroFontSize.sm, weight: HeroTypography.semibold)
                        .copyWith(color: theme.colors.muted),
                  ),
                  Wrap(
                    spacing: theme.spacing(6),
                    runSpacing: theme.spacing(4),
                    children: <Widget>[
                      for (final HeroColor color in _colors)
                        HeroBadgeAnchor(
                          badge: HeroBadge(
                            label: '5',
                            color: color,
                            size: HeroSize.sm,
                            variant: variant,
                          ),
                          child: _avatar(),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        );
      },
      code: '''
for (final HeroBadgeVariant variant in HeroBadgeVariant.values)
  Row(
    spacing: 24,
    children: <Widget>[
      for (final HeroColor color in colors)
        HeroBadgeAnchor(
          badge: HeroBadge(
            label: '5',
            color: color,
            size: HeroSize.sm,
            variant: variant,
          ),
          child: HeroAvatar(src: avatarUrl, fallback: Text('JD')),
        ),
    ],
  ),
// Variants are separated with a HeroSeparator.''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          for (final HeroSize size in HeroSize.values)
            HeroBadgeAnchor(
              badge: HeroBadge(label: '5', color: HeroColor.danger, size: size),
              child: _avatar(size: size),
            ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 24,
  children: <Widget>[
    for (final HeroSize size in HeroSize.values)
      HeroBadgeAnchor(
        badge: HeroBadge(label: '5', color: HeroColor.danger, size: size),
        child: HeroAvatar(size: size, src: avatarUrl, fallback: Text('JD')),
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Colors',
      builder: (BuildContext context) => Wrap(
        spacing: 24,
        runSpacing: 16,
        children: <Widget>[
          for (final HeroColor color in <HeroColor>[
            HeroColor.standard,
            HeroColor.accent,
            HeroColor.success,
            HeroColor.warning,
            HeroColor.danger,
          ])
            HeroBadgeAnchor(
              badge: HeroBadge(color: color, size: HeroSize.sm),
              child: _avatar(),
            ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 24,
  children: <Widget>[
    for (final HeroColor color in HeroColor.values)
      HeroBadgeAnchor(
        badge: HeroBadge(color: color, size: HeroSize.sm),
        child: HeroAvatar(src: avatarUrl, fallback: Text('JD')),
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Placements',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return Wrap(
          spacing: theme.spacing(8),
          runSpacing: theme.spacing(4),
          children: <Widget>[
            for (final (HeroBadgePlacement placement, String label)
                in const <(HeroBadgePlacement, String)>[
                  (HeroBadgePlacement.topRight, 'top-right'),
                  (HeroBadgePlacement.topLeft, 'top-left'),
                  (HeroBadgePlacement.bottomRight, 'bottom-right'),
                  (HeroBadgePlacement.bottomLeft, 'bottom-left'),
                ])
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: theme.spacing(2),
                children: <Widget>[
                  HeroBadgeAnchor(
                    badge: HeroBadge(
                      color: HeroColor.accent,
                      placement: placement,
                      size: HeroSize.sm,
                    ),
                    child: _avatar(),
                  ),
                  Text(
                    label,
                    style: theme.typography.xs.copyWith(
                      color: theme.colors.muted,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
      code: '''
HeroBadgeAnchor(
  badge: HeroBadge(
    color: HeroColor.accent,
    placement: HeroBadgePlacement.bottomLeft,
    size: HeroSize.sm,
  ),
  child: HeroAvatar(src: avatarUrl, fallback: Text('JD')),
)''',
    ),
    DemoExample(
      title: 'Dot Badge',
      builder: (BuildContext context) => Wrap(
        spacing: 24,
        runSpacing: 16,
        children: <Widget>[
          for (final HeroColor color in const <HeroColor>[
            HeroColor.accent,
            HeroColor.success,
            HeroColor.warning,
            HeroColor.danger,
          ])
            HeroBadgeAnchor(
              badge: HeroBadge(
                color: color,
                placement: HeroBadgePlacement.bottomRight,
                size: HeroSize.sm,
              ),
              child: _avatar(),
            ),
        ],
      ),
      code: '''
HeroBadgeAnchor(
  badge: HeroBadge(
    color: HeroColor.success,
    placement: HeroBadgePlacement.bottomRight,
    size: HeroSize.sm,
    semanticLabel: 'Online',
  ),
  child: HeroAvatar(src: avatarUrl, fallback: Text('JD')),
)''',
    ),
    DemoExample(
      title: 'With Content',
      builder: (BuildContext context) => Wrap(
        spacing: 24,
        runSpacing: 16,
        children: <Widget>[
          for (final String label in const <String>['5', 'New', '99+'])
            HeroBadgeAnchor(
              badge: HeroBadge(
                label: label,
                color: HeroColor.danger,
                size: HeroSize.sm,
              ),
              child: _avatar(),
            ),
          HeroBadgeAnchor(
            badge: HeroBadge(
              color: HeroColor.accent,
              size: HeroSize.sm,
              child: HeroIcon(
                HeroIcons.bell,
                size: HeroTheme.of(context).spacing(2.5),
              ),
            ),
            child: _avatar(),
          ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 24,
  children: <Widget>[
    HeroBadgeAnchor(
      badge: HeroBadge(label: '99+', color: HeroColor.danger, size: HeroSize.sm),
      child: HeroAvatar(src: avatarUrl, fallback: Text('JD')),
    ),
    HeroBadgeAnchor(
      badge: HeroBadge(
        color: HeroColor.accent,
        size: HeroSize.sm,
        child: HeroIcon(HeroIcons.bell, size: 10),
      ),
      child: HeroAvatar(src: avatarUrl, fallback: Text('JD')),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => HeroBadgeAnchor(
        badge: HeroBadge(
          label: '5',
          color: HeroColor.accent,
          size: HeroSize.sm,
          variant: HeroBadgeVariant.soft,
          minWidth: HeroTheme.of(context).spacing(5),
          style: const TextStyle(
            fontWeight: HeroTypography.semibold,
            fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
        child: const HeroAvatar(
          src: '$_avatars/blue.jpg',
          semanticLabel: 'Kate Wilson',
          fallback: Text('KW'),
        ),
      ),
      code: '''
HeroBadgeAnchor(
  badge: HeroBadge(
    label: '5',
    color: HeroColor.accent,
    size: HeroSize.sm,
    variant: HeroBadgeVariant.soft,
    minWidth: 20,
    style: TextStyle(
      fontWeight: HeroTypography.semibold,
      fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
    ),
  ),
  child: HeroAvatar(
    src: blueUrl,
    semanticLabel: 'Kate Wilson',
    fallback: Text('KW'),
  ),
)''',
    ),
  ],
);
