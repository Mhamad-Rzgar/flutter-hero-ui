import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _person1 = 'https://img.heroui.chat/image/avatar?w=400&h=400&u=3';
const String _assets = 'https://heroui-assets.nyc3.cdn.digitaloceanspaces.com';
const String _blue = '$_assets/avatars/blue.jpg';

final ComponentDemo avatarDemo = ComponentDemo(
  slug: 'avatar',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('color', <String>[
        'standard',
        'accent',
        'success',
        'warning',
        'danger',
      ]),
      OptionsControl('variant', <String>['standard', 'soft']),
      OptionsControl('content', <String>['image', 'initials', 'icon']),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final String content = values.option('content');
      return HeroAvatar(
        size: values.pick('size', HeroSize.values),
        color: values.pick('color', HeroColor.values),
        variant: values.pick('variant', HeroAvatarVariant.values),
        src: content == 'image' ? _person1 : null,
        name: 'John Doe',
        fallback: content == 'icon' ? const HeroIcon(HeroIcons.person) : null,
      );
    },
    code: (PlaygroundValues values) {
      final String content = values.option('content');
      final List<String> args = <String>[
        if (values.option('size') != 'md')
          'size: HeroSize.${values.option('size')}',
        if (values.option('color') != 'standard')
          'color: HeroColor.${values.option('color')}',
        if (values.option('variant') != 'standard')
          'variant: HeroAvatarVariant.${values.option('variant')}',
        if (content == 'image') "src: '$_person1'",
        "name: 'John Doe'",
        if (content == 'icon') 'fallback: HeroIcon(HeroIcons.person)',
      ];
      return 'HeroAvatar(\n${args.map((String a) => '  $a,\n').join()})';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          HeroAvatar(
            children: <Widget>[
              HeroAvatarImage.network(_person1, semanticLabel: 'John Doe'),
              const HeroAvatarFallback(child: Text('JD')),
            ],
          ),
          HeroAvatar(
            children: <Widget>[
              HeroAvatarImage.network(_blue, semanticLabel: 'Blue'),
              const HeroAvatarFallback(child: Text('B')),
            ],
          ),
          const HeroAvatar(
            children: <Widget>[HeroAvatarFallback(child: Text('JR'))],
          ),
        ],
      ),
      code:
          '''
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
        HeroAvatarFallback(child: Text('JD')),
      ],
    ),
    // Shorthand: an image URL and a name for initials and semantics.
    HeroAvatar(src: '$_blue', name: 'Blue'),
    HeroAvatar(fallback: Text('JR')),
  ],
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          HeroAvatar(
            size: HeroSize.sm,
            src: '$_assets/avatars/blue.jpg',
            semanticLabel: 'Small Avatar',
            fallback: Text('SM'),
          ),
          HeroAvatar(
            src: '$_assets/avatars/purple.jpg',
            semanticLabel: 'Medium Avatar',
            fallback: Text('MD'),
          ),
          HeroAvatar(
            size: HeroSize.lg,
            src: '$_assets/avatars/red.jpg',
            semanticLabel: 'Large Avatar',
            fallback: Text('LG'),
          ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: <Widget>[
    HeroAvatar(size: HeroSize.sm, src: blueUrl, fallback: Text('SM')),
    HeroAvatar(size: HeroSize.md, src: purpleUrl, fallback: Text('MD')),
    HeroAvatar(size: HeroSize.lg, src: redUrl, fallback: Text('LG')),
  ],
)''',
    ),
    DemoExample(
      title: 'Colors',
      builder: (BuildContext context) => const Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          HeroAvatar(fallback: Text('DF')),
          HeroAvatar(color: HeroColor.accent, fallback: Text('AC')),
          HeroAvatar(color: HeroColor.success, fallback: Text('SC')),
          HeroAvatar(color: HeroColor.warning, fallback: Text('WR')),
          HeroAvatar(color: HeroColor.danger, fallback: Text('DG')),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: <Widget>[
    HeroAvatar(color: HeroColor.standard, fallback: Text('DF')),
    HeroAvatar(color: HeroColor.accent, fallback: Text('AC')),
    HeroAvatar(color: HeroColor.success, fallback: Text('SC')),
    HeroAvatar(color: HeroColor.warning, fallback: Text('WR')),
    HeroAvatar(color: HeroColor.danger, fallback: Text('DG')),
  ],
)''',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) => const _VariantsMatrix(),
      code: r'''
Row(
  spacing: 12,
  children: <Widget>[
    SizedBox(width: 96, child: Text('letter soft')),
    for (final HeroColor color in colors)
      SizedBox(
        width: 80,
        child: Center(
          child: HeroAvatar(
            color: color,
            variant: HeroAvatarVariant.soft,
            fallback: Text('AG'),
          ),
        ),
      ),
  ],
)
// Rows: letter, letter soft, icon (HeroIcons.person), icon soft and img.''',
    ),
    DemoExample(
      title: 'Fallback Content',
      builder: (BuildContext context) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: <Widget>[
            const HeroAvatar(fallback: Text('JD')),
            const HeroAvatar(fallback: HeroIcon(HeroIcons.person)),
            HeroAvatar(
              children: <Widget>[
                HeroAvatarImage.network(
                  'https://invalid-url-to-show-fallback.com/image.jpg',
                  semanticLabel: 'Delayed Avatar',
                ),
                const HeroAvatarFallback(
                  delay: Duration(milliseconds: 600),
                  child: Text('NA'),
                ),
              ],
            ),
            HeroAvatar(
              children: <Widget>[
                HeroAvatarFallback(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    // Tailwind pink-500 to purple-500.
                    colors: <Color>[
                      oklch(0.656, 0.241, 354.308),
                      oklch(0.627, 0.265, 303.9),
                    ],
                  ),
                  foregroundColor: HeroTheme.of(context).colors.white,
                  child: const Text('GB'),
                ),
              ],
            ),
          ],
        );
      },
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: <Widget>[
    // Text fallback
    HeroAvatar(fallback: Text('JD')),
    // Icon fallback
    HeroAvatar(fallback: HeroIcon(HeroIcons.person)),
    // Fallback with delay
    HeroAvatar(
      children: <Widget>[
        HeroAvatarImage.network(
          'https://invalid-url-to-show-fallback.com/image.jpg',
        ),
        HeroAvatarFallback(
          delay: Duration(milliseconds: 600),
          child: Text('NA'),
        ),
      ],
    ),
    // Custom styled fallback
    HeroAvatar(
      children: <Widget>[
        HeroAvatarFallback(
          gradient: LinearGradient(colors: <Color>[pink500, purple500]),
          foregroundColor: theme.colors.white,
          child: Text('GB'),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Image Component',
      description:
          'builder renders the loaded image with any widget; the avatar '
          'still tracks the image to show the fallback until it is ready.',
      builder: (BuildContext context) => HeroAvatar(
        children: <Widget>[
          HeroAvatarImage.network(
            _blue,
            semanticLabel: 'John Doe',
            builder: (BuildContext context, ImageProvider image) =>
                Image(image: image, width: 40, height: 40, fit: BoxFit.cover),
          ),
          const HeroAvatarFallback(child: Text('JD')),
        ],
      ),
      code:
          '''
HeroAvatar(
  children: <Widget>[
    HeroAvatarImage.network(
      '$_blue',
      semanticLabel: 'John Doe',
      builder: (BuildContext context, ImageProvider image) => Image(
        image: image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    ),
    HeroAvatarFallback(child: Text('JD')),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) => HeroAvatar(
        radius: HeroTheme.of(context).radii.lg,
        src: _person1,
        semanticLabel: 'John Doe',
        fallback: const Text('JD'),
      ),
      code: '''
HeroAvatar(
  radius: theme.radii.lg,
  src: 'https://img.heroui.chat/image/avatar?w=400&h=400&u=3',
  semanticLabel: 'John Doe',
  fallback: Text('JD'),
)''',
    ),
  ],
);

const List<HeroColor> _colors = <HeroColor>[
  HeroColor.accent,
  HeroColor.standard,
  HeroColor.success,
  HeroColor.warning,
  HeroColor.danger,
];

const List<String> _photos = <String>[
  'https://img.heroui.chat/image/avatar?w=400&h=400&u=3',
  'https://img.heroui.chat/image/avatar?w=400&h=400&u=4',
  'https://img.heroui.chat/image/avatar?w=400&h=400&u=5',
  'https://img.heroui.chat/image/avatar?w=400&h=400&u=8',
  'https://img.heroui.chat/image/avatar?w=400&h=400&u=16',
];

class _VariantsMatrix extends StatelessWidget {
  const _VariantsMatrix();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double labelWidth = theme.spacing(24);
    final double column = theme.spacing(20);
    final double gap = theme.spacing(3);
    String colorName(HeroColor color) =>
        color == HeroColor.standard ? 'default' : color.name;
    Widget row(
      Widget label,
      Widget Function(int index, HeroColor color) cell,
    ) => Row(
      spacing: gap,
      children: <Widget>[
        SizedBox(width: labelWidth, child: label),
        for (final (int index, HeroColor color) in _colors.indexed)
          SizedBox(
            width: column,
            child: Center(child: cell(index, color)),
          ),
      ],
    );
    final TextStyle muted = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: labelWidth + (column + gap) * _colors.length,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(4),
          children: <Widget>[
            row(
              const SizedBox.shrink(),
              (int index, HeroColor color) => Text(
                colorName(color)[0].toUpperCase() +
                    colorName(color).substring(1),
                style: theme.typography.xs.copyWith(color: theme.colors.muted),
              ),
            ),
            const HeroSeparator(),
            for (final (String label, bool soft, bool icon)
                in const <(String, bool, bool)>[
                  ('letter', false, false),
                  ('letter soft', true, false),
                  ('icon', false, true),
                  ('icon soft', true, true),
                ])
              row(
                Text(label, style: muted),
                (int index, HeroColor color) => HeroAvatar(
                  color: color,
                  variant: soft ? HeroAvatarVariant.soft : null,
                  fallback: icon
                      ? const HeroIcon(HeroIcons.person)
                      : const Text('AG'),
                ),
              ),
            row(
              Text('img', style: muted),
              (int index, HeroColor color) => HeroAvatar(
                color: color,
                src: _photos[index],
                semanticLabel: 'Avatar ${colorName(color)}',
                fallback: Text(colorName(color)[0].toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
