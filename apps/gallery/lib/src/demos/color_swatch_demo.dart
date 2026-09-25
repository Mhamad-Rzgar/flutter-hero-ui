import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const List<(Color, String)> _palette = <(Color, String)>[
  (Color(0xFF0485F7), 'Blue'),
  (Color(0xFFEF4444), 'Red'),
  (Color(0xFFF59E0B), 'Amber'),
  (Color(0xFF10B981), 'Green'),
  (Color(0xFFD946EF), 'Fuchsia'),
];

/// Gallery page of `HeroColorSwatch`, reproducing
/// heroui.com/docs/components/color-swatch.
final ComponentDemo colorSwatchDemo = ComponentDemo(
  slug: 'color-swatch',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('size', <String>[
        'xs',
        'sm',
        'md',
        'lg',
        'xl',
      ], initial: 'md'),
      OptionsControl('shape', <String>['circle', 'square']),
      TextControl('color', initial: '#0485F7'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroColorSwatch(
      color: HeroColorValue.tryParse(values.text('color'))?.toColor(),
      size: values.pick('size', HeroColorSwatchSize.values),
      shape: values.pick('shape', HeroColorSwatchShape.values),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroColorSwatch(\n')
        ..writeln("  color: heroParseColor('${values.text('color')}'),");
      if (values.option('size') != 'md') {
        out.writeln('  size: HeroColorSwatchSize.${values.option('size')},');
      }
      if (values.option('shape') != 'circle') {
        out.writeln('  shape: HeroColorSwatchShape.${values.option('shape')},');
      }
      out.write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final (Color color, String name) in _palette)
            HeroColorSwatch(color: color, semanticLabel: name),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroColorSwatch(color: Color(0xFF0485F7), semanticLabel: 'Blue'),
    HeroColorSwatch(color: Color(0xFFEF4444), semanticLabel: 'Red'),
    HeroColorSwatch(color: Color(0xFFF59E0B), semanticLabel: 'Amber'),
    HeroColorSwatch(color: Color(0xFF10B981), semanticLabel: 'Green'),
    HeroColorSwatch(color: Color(0xFFD946EF), semanticLabel: 'Fuchsia'),
  ],
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (int i = 0; i < _palette.length; i++)
            HeroColorSwatch(
              color: _palette[i].$1,
              size: HeroColorSwatchSize.values[i],
            ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroColorSwatch(color: Color(0xFF0485F7), size: HeroColorSwatchSize.xs),
    HeroColorSwatch(color: Color(0xFFEF4444), size: HeroColorSwatchSize.sm),
    HeroColorSwatch(color: Color(0xFFF59E0B), size: HeroColorSwatchSize.md),
    HeroColorSwatch(color: Color(0xFF10B981), size: HeroColorSwatchSize.lg),
    HeroColorSwatch(color: Color(0xFFD946EF), size: HeroColorSwatchSize.xl),
  ],
)''',
    ),
    DemoExample(
      title: 'Shapes',
      builder: (BuildContext context) => const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          HeroColorSwatch(color: Color(0xFF0485F7)),
          HeroColorSwatch(
            color: Color(0xFF0485F7),
            shape: HeroColorSwatchShape.square,
          ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroColorSwatch(color: Color(0xFF0485F7)),
    HeroColorSwatch(
      color: Color(0xFF0485F7),
      shape: HeroColorSwatchShape.square,
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Transparency',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final double alpha in <double>[1, 0.75, 0.5, 0.25, 0])
            HeroColorSwatch(
              color: const Color(0xFF0485F7).withValues(alpha: alpha),
              semanticLabel: '${(alpha * 100).round()}% opacity',
            ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: <Widget>[
    for (final double alpha in <double>[1, 0.75, 0.5, 0.25, 0])
      HeroColorSwatch(
        color: heroParseColor('rgba(4, 133, 247, \$alpha)'),
        semanticLabel: '\${(alpha * 100).round()}% opacity',
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'styleBuilder receives the displayed color (the style render '
          'props), here for a soft colored shadow.',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final (Color color, String name) in _palette)
            HeroColorSwatch(
              color: color,
              semanticLabel: name,
              styleBuilder: _softShadow,
            ),
        ],
      ),
      code: '''
HeroColorSwatch(
  color: const Color(0xFF0485F7),
  semanticLabel: 'Blue',
  styleBuilder: (Color color) => HeroColorSwatchStyle(
    shadows: <BoxShadow>[
      BoxShadow(
        color: color.withValues(alpha: 0.5),
        offset: const Offset(0, 4),
        blurRadius: 14,
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Accessibility',
      description:
          'colorName replaces the generated color name; semanticLabel adds '
          'how the color is used.',
      builder: (BuildContext context) => const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          HeroColorSwatch(
            color: Color(0xFF0485F7),
            colorName: 'Ocean Blue',
            semanticLabel: 'Primary brand color',
          ),
          HeroColorSwatch(
            color: Color(0xFFEF4444),
            colorName: 'Coral Red',
            semanticLabel: 'Error state color',
          ),
          HeroColorSwatch(
            color: Color(0xFFF59E0B),
            colorName: 'Sunset Orange',
            semanticLabel: 'Warning color',
          ),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroColorSwatch(
      color: Color(0xFF0485F7),
      colorName: 'Ocean Blue',
      semanticLabel: 'Primary brand color',
    ),
    HeroColorSwatch(
      color: Color(0xFFEF4444),
      colorName: 'Coral Red',
      semanticLabel: 'Error state color',
    ),
    HeroColorSwatch(
      color: Color(0xFFF59E0B),
      colorName: 'Sunset Orange',
      semanticLabel: 'Warning color',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A glow replaces the box shadow; a 135° gradient replaces the '
          'background.',
      builder: (BuildContext context) => const _CustomStyles(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
const List<Color> colors = <Color>[
  Color(0xFF0485F7), Color(0xFFEF4444), Color(0xFFF59E0B),
  Color(0xFF10B981), Color(0xFFD946EF),
];

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 32,
  children: <Widget>[
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text('Glow Effect', style: theme.typography.sm.copyWith(color: theme.colors.muted)),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            for (final Color color in colors)
              HeroColorSwatch(
                color: color,
                size: HeroColorSwatchSize.xl,
                style: HeroColorSwatchStyle(
                  shadows: <BoxShadow>[
                    BoxShadow(color: color, blurRadius: 20, spreadRadius: 2),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text('Gradient', style: theme.typography.sm.copyWith(color: theme.colors.muted)),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            for (final Color color in colors)
              HeroColorSwatch(
                color: color,
                size: HeroColorSwatchSize.xl,
                styleBuilder: (Color c) => HeroColorSwatchStyle(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[c, const Color(0xFFFFFFFF)],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  ],
)''',
    ),
  ],
);

HeroColorSwatchStyle _softShadow(Color color) => HeroColorSwatchStyle(
  shadows: <BoxShadow>[
    BoxShadow(
      color: color.withValues(alpha: 0.5),
      offset: const Offset(0, 4),
      blurRadius: 14,
    ),
  ],
);

class _CustomStyles extends StatelessWidget {
  const _CustomStyles();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle caption = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            Text('Glow Effect', style: caption),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: <Widget>[
                for (final (Color color, String _) in _palette)
                  HeroColorSwatch(
                    color: color,
                    size: HeroColorSwatchSize.xl,
                    style: HeroColorSwatchStyle(
                      shadows: <BoxShadow>[
                        BoxShadow(
                          color: color,
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            Text('Gradient', style: caption),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: <Widget>[
                for (final (Color color, String _) in _palette)
                  HeroColorSwatch(
                    color: color,
                    size: HeroColorSwatchSize.xl,
                    styleBuilder: (Color c) => HeroColorSwatchStyle(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[c, const Color(0xFFFFFFFF)],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
