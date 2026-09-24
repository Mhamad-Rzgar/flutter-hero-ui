import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

final ComponentDemo typographyDemo = ComponentDemo(
  slug: 'typography',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('type', <String>[
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
        'body',
        'bodySm',
        'bodyXs',
        'code',
      ], initial: 'h3'),
      OptionsControl('color', <String>['standard', 'muted']),
      OptionsControl('weight', <String>[
        'none',
        'normal',
        'medium',
        'semibold',
        'bold',
      ]),
      OptionsControl('align', <String>['start', 'center', 'end', 'justify']),
      ToggleControl('truncate'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      return SizedBox(
        width: 280,
        child: HeroText(
          values.option('type') == 'code'
              ? 'pnpm add @heroui/react'
              : 'Typography that stays semantic',
          type: values.pick('type', HeroTextType.values),
          color: values.pick('color', HeroTextColor.values),
          weight: _weights[values.option('weight')],
          align: values.pick('align', TextAlign.values),
          truncate: values.toggle('truncate'),
        ),
      );
    },
    code: (PlaygroundValues values) {
      final String type = values.option('type');
      final String color = values.option('color');
      final String weight = values.option('weight');
      final String align = values.option('align');
      final List<String> args = <String>[
        if (type != 'body') 'type: HeroTextType.$type',
        if (color != 'standard') 'color: HeroTextColor.$color',
        if (weight != 'none') 'weight: HeroTypography.$weight',
        if (align != 'start') 'align: TextAlign.$align',
        if (values.toggle('truncate')) 'truncate: true',
      ];
      final String text = type == 'code'
          ? 'pnpm add @heroui/react'
          : 'Typography that stays semantic';
      if (args.isEmpty) return "HeroText('$text')";
      return "HeroText(\n  '$text',\n${args.map((String a) => '  $a,\n').join()})";
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _Column(
        maxWidth: 576,
        spacing: 16,
        children: <Widget>[
          HeroText('Build better interfaces', type: HeroTextType.h1),
          HeroText('Typography that stays semantic', type: HeroTextType.h2),
          HeroText('Composable by default', type: HeroTextType.h3),
          HeroText('Small heading', type: HeroTextType.h4),
          HeroText(
            'HeroUI Typography uses React Aria Components Text as the '
            'primitive, with semantic typography types and render-prop '
            'polymorphism.',
          ),
          HeroText(
            'Smaller muted body copy for secondary descriptions.',
            color: HeroTextColor.muted,
            type: HeroTextType.bodySm,
          ),
          HeroText('pnpm add @heroui/react', type: HeroTextType.code),
        ],
      ),
      code: '''
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 576),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      HeroText('Build better interfaces', type: HeroTextType.h1),
      HeroText('Typography that stays semantic', type: HeroTextType.h2),
      HeroText('Composable by default', type: HeroTextType.h3),
      HeroText('Small heading', type: HeroTextType.h4),
      HeroText(
        'HeroUI Typography uses React Aria Components Text as the '
        'primitive, with semantic typography types and render-prop '
        'polymorphism.',
      ),
      HeroText(
        'Smaller muted body copy for secondary descriptions.',
        color: HeroTextColor.muted,
        type: HeroTextType.bodySm,
      ),
      HeroText('pnpm add @heroui/react', type: HeroTextType.code),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Scale',
      builder: (BuildContext context) => const _Scale(),
      code: r'''
const List<(String, String, String, HeroTextType)> scale = [
  ('h1', '36px / 600 / 1.11 / tight', 'Build better interfaces', HeroTextType.h1),
  ('h2', '30px / 600 / 1.17 / tight', 'Built for the intelligence age', HeroTextType.h2),
  // ... h3 to h6, body, body-sm, body-xs
  ('code', '14px / mono', 'pnpm add @heroui/react', HeroTextType.code),
];

Column(
  children: <Widget>[
    for (final (String label, String meta, String sample, HeroTextType type)
        in scale)
      DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: theme.colors.border)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            spacing: 32,
            children: <Widget>[
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: <Widget>[
                    HeroText(label, type: HeroTextType.bodySm,
                        weight: HeroTypography.semibold),
                    HeroText(meta, type: HeroTextType.bodyXs,
                        color: HeroTextColor.muted),
                  ],
                ),
              ),
              Expanded(child: HeroText(sample, type: type)),
            ],
          ),
        ),
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Primitives',
      description:
          'HeroHeading maps level 1 to 6 to the h1 to h6 types, HeroParagraph '
          'maps base, sm and xs to the body types, HeroCode is the inline code '
          'style and HeroProse styles authored content.',
      builder: (BuildContext context) => const _Column(
        maxWidth: 576,
        spacing: 16,
        children: <Widget>[
          HeroHeading('Dashboard'),
          HeroParagraph(
            'Convenience primitives are thin wrappers over Typography, so you '
            'can choose explicit composition without learning a second '
            'styling system.',
          ),
          HeroParagraph(
            'Paragraph supports base, sm, and xs sizes.',
            color: HeroTextColor.muted,
            size: HeroParagraphSize.sm,
          ),
          HeroCode('Typography.Code'),
        ],
      ),
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 16,
  children: <Widget>[
    HeroHeading('Dashboard', level: 1),
    HeroParagraph(
      'Convenience primitives are thin wrappers over Typography, so you '
      'can choose explicit composition without learning a second '
      'styling system.',
    ),
    HeroParagraph(
      'Paragraph supports base, sm, and xs sizes.',
      color: HeroTextColor.muted,
      size: HeroParagraphSize.sm,
    ),
    HeroCode('Typography.Code'),
  ],
)''',
    ),
    DemoExample(
      title: 'Prose',
      builder: (BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 576),
        child: HeroProse(
          spacing: 12,
          children: <Widget>[
            const HeroHeading('Prose title'),
            const HeroParagraph(
              'Prose is for authored content where the markup is already '
              'semantic and HeroUI applies the default typography rhythm.',
            ),
            const HeroHeading('Section title', level: 2),
            HeroParagraph.rich(
              TextSpan(
                children: <InlineSpan>[
                  const TextSpan(text: 'Inline code like '),
                  HeroCode.span('render'),
                  const TextSpan(
                    text:
                        ' receives the same code treatment as the Typography '
                        'primitive.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      code: '''
HeroProse(
  spacing: 12,
  children: <Widget>[
    HeroHeading('Prose title', level: 1),
    HeroParagraph(
      'Prose is for authored content where the markup is already '
      'semantic and HeroUI applies the default typography rhythm.',
    ),
    HeroHeading('Section title', level: 2),
    HeroParagraph.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: 'Inline code like '),
          HeroCode.span('render'),
          TextSpan(
            text: ' receives the same code treatment as the Typography '
                'primitive.',
          ),
        ],
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Props',
      description:
          'The visual type and the semantic element are independent: '
          'semanticHeadingLevel sets the heading level announced to '
          'assistive technologies.',
      builder: (BuildContext context) => const _Column(
        maxWidth: 576,
        spacing: 16,
        children: <Widget>[
          HeroText(
            'H1 visual style, h2 semantic element',
            type: HeroTextType.h1,
            semanticHeadingLevel: 2,
          ),
          HeroText(
            'The render prop can swap the underlying element while '
            'preserving HeroUI props and styles.',
          ),
        ],
      ),
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 16,
  children: <Widget>[
    HeroText(
      'H1 visual style, h2 semantic element',
      type: HeroTextType.h1,
      semanticHeadingLevel: 2,
    ),
    HeroText(
      'The render prop can swap the underlying element while '
      'preserving HeroUI props and styles.',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final OutlinedBorder shape = theme.shapeAll(
          theme.radii.xl,
          side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
        );
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: theme.colors.surfaceSecondary,
              shape: shape,
            ),
            child: Padding(
              padding: EdgeInsets.all(theme.spacing(4)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: theme.spacing(2),
                children: <Widget>[
                  HeroText(
                    'Changelog'.toUpperCase(),
                    type: HeroTextType.bodyXs,
                    weight: HeroTypography.medium,
                    style: TextStyle(
                      color: theme.colors.accent,
                      letterSpacing: 0.025 * 12,
                    ),
                  ),
                  const HeroText(
                    'Faster search results',
                    type: HeroTextType.h4,
                  ),
                  const HeroText(
                    'Queries now return in under 200ms thanks to an improved '
                    'index.',
                    type: HeroTextType.bodySm,
                    color: HeroTextColor.muted,
                    style: TextStyle(height: 1.625),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);

DecoratedBox(
  decoration: ShapeDecoration(
    color: theme.colors.surfaceSecondary,
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
    ),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: <Widget>[
        HeroText(
          'CHANGELOG',
          type: HeroTextType.bodyXs,
          weight: HeroTypography.medium,
          style: TextStyle(color: theme.colors.accent, letterSpacing: 0.3),
        ),
        HeroText('Faster search results', type: HeroTextType.h4),
        HeroText(
          'Queries now return in under 200ms thanks to an improved index.',
          type: HeroTextType.bodySm,
          color: HeroTextColor.muted,
          style: TextStyle(height: 1.625),
        ),
      ],
    ),
  ),
)''',
    ),
  ],
);

const Map<String, FontWeight?> _weights = <String, FontWeight?>{
  'none': null,
  'normal': HeroTypography.normal,
  'medium': HeroTypography.medium,
  'semibold': HeroTypography.semibold,
  'bold': HeroTypography.bold,
};

class _Column extends StatelessWidget {
  const _Column({
    required this.maxWidth,
    required this.spacing,
    required this.children,
  });

  final double maxWidth;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing,
        children: children,
      ),
    );
  }
}

const List<(String, String, String, HeroTextType)> _scale =
    <(String, String, String, HeroTextType)>[
      (
        'h1',
        '36px / 600 / 1.11 / tight',
        'Build better interfaces',
        HeroTextType.h1,
      ),
      (
        'h2',
        '30px / 600 / 1.17 / tight',
        'Built for the intelligence age',
        HeroTextType.h2,
      ),
      (
        'h3',
        '24px / 600 / 1.25 / tight',
        'Pricing on your terms',
        HeroTextType.h3,
      ),
      (
        'h4',
        '20px / 600 / 1.33 / tight',
        'Apply to the startup program',
        HeroTextType.h4,
      ),
      ('h5', '18px / 600 / 1.39 / tight', 'Card titles', HeroTextType.h5),
      (
        'h6',
        '16px / 600 / 1.50 / tight',
        'Smaller feature headers',
        HeroTextType.h6,
      ),
      (
        'body',
        '16px / 400 / 1.75',
        'Primary body text used across documentation, marketing copy, and '
            'descriptions.',
        HeroTextType.body,
      ),
      (
        'body-sm',
        '14px / 400 / 1.50',
        'Secondary body, table cells, navigation, and sidebar items.',
        HeroTextType.bodySm,
      ),
      (
        'body-xs',
        '12px / 400 / 1.25',
        'Captions, badges, helper text, and fine print.',
        HeroTextType.bodyXs,
      ),
      ('code', '14px / mono', 'pnpm add @heroui/react', HeroTextType.code),
    ];

class _Scale extends StatelessWidget {
  const _Scale();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // The docs lay rows out as a 160 px label column next to the sample;
        // narrow screens stack the label above the sample instead.
        final bool grid = constraints.maxWidth >= 480;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final (
                  int index,
                  (String label, String meta, String sample, HeroTextType type),
                )
                in _scale.indexed)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: index == 0
                      ? null
                      : Border(top: BorderSide(color: theme.colors.border)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: theme.spacing(5)),
                  child: Flex(
                    direction: grid ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: grid
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.stretch,
                    spacing: grid ? theme.spacing(8) : theme.spacing(3),
                    children: <Widget>[
                      SizedBox(
                        width: grid ? 160 : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: theme.spacing(0.5),
                          children: <Widget>[
                            HeroText(
                              label,
                              type: HeroTextType.bodySm,
                              weight: HeroTypography.semibold,
                              style: const TextStyle(height: 20 / 14),
                            ),
                            HeroText(
                              meta,
                              type: HeroTextType.bodyXs,
                              color: HeroTextColor.muted,
                              truncate: true,
                              style: const TextStyle(height: 16 / 12),
                            ),
                          ],
                        ),
                      ),
                      if (grid)
                        Expanded(child: HeroText(sample, type: type))
                      else
                        HeroText(sample, type: type),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
