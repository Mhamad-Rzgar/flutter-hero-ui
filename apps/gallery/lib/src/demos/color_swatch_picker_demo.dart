import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const List<Color> _colors = <Color>[
  Color(0xFFF43F5E),
  Color(0xFFD946EF),
  Color(0xFF8B5CF6),
  Color(0xFF3B82F6),
  Color(0xFF06B6D4),
  Color(0xFF10B981),
  Color(0xFF84CC16),
];

const String _colorsCode = '''
const List<Color> colors = <Color>[
  Color(0xFFF43F5E), Color(0xFFD946EF), Color(0xFF8B5CF6), Color(0xFF3B82F6),
  Color(0xFF06B6D4), Color(0xFF10B981), Color(0xFF84CC16),
];
''';

/// Gallery page of `HeroColorSwatchPicker`, reproducing
/// heroui.com/docs/components/color-swatch-picker.
final ComponentDemo colorSwatchPickerDemo = ComponentDemo(
  slug: 'color-swatch-picker',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('size', <String>[
        'xs',
        'sm',
        'md',
        'lg',
        'xl',
      ], initial: 'md'),
      OptionsControl('variant', <String>['circle', 'square']),
      OptionsControl('layout', <String>['grid', 'stack']),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) =>
        HeroColorSwatchPicker(
          semanticLabel: 'Playground colors',
          defaultValue: _colors[2],
          size: values.pick('size', HeroColorSwatchSize.values),
          variant: values.pick('variant', HeroColorSwatchShape.values),
          layout: values.pick('layout', HeroColorSwatchPickerLayout.values),
          children: <HeroColorSwatchPickerItem>[
            for (final Color color in _colors)
              HeroColorSwatchPickerItem(
                color: color,
                isDisabled: values.toggle('isDisabled'),
              ),
          ],
        ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroColorSwatchPicker(\n');
      if (values.option('size') != 'md') {
        out.writeln('  size: HeroColorSwatchSize.${values.option('size')},');
      }
      if (values.option('variant') != 'circle') {
        out.writeln(
          '  variant: HeroColorSwatchShape.${values.option('variant')},',
        );
      }
      if (values.option('layout') != 'grid') {
        out.writeln(
          '  layout: HeroColorSwatchPickerLayout.${values.option('layout')},',
        );
      }
      if (values.toggle('isDisabled')) {
        out
          ..writeln('  children: <HeroColorSwatchPickerItem>[')
          ..writeln('    for (final Color color in colors)')
          ..writeln(
            '      HeroColorSwatchPickerItem(color: color, isDisabled: true),',
          )
          ..writeln('  ],');
      } else {
        out.writeln('  colors: colors,');
      }
      out.write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) =>
          const HeroColorSwatchPicker(colors: _colors),
      code: '${_colorsCode}HeroColorSwatchPicker(colors: colors)',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) => const _Captioned(
        rows: <(String, Widget)>[
          ('Circle (default)', HeroColorSwatchPicker(colors: _colors)),
          (
            'Square',
            HeroColorSwatchPicker(
              colors: _colors,
              variant: HeroColorSwatchShape.square,
            ),
          ),
        ],
      ),
      code:
          '''
${_colorsCode}Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 24,
  children: <Widget>[
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text('Circle (default)', style: caption),
        HeroColorSwatchPicker(colors: colors),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text('Square', style: caption),
        HeroColorSwatchPicker(
          colors: colors,
          variant: HeroColorSwatchShape.square,
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => const _Sizes(),
      code:
          '''
${_colorsCode}Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 24,
  children: <Widget>[
    for (final HeroColorSwatchSize size in HeroColorSwatchSize.values)
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          SizedBox(width: 32, child: Text(size.name, style: caption)),
          HeroColorSwatchPicker(colors: colors, size: size),
        ],
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => HeroColorSwatchPicker(
        children: <HeroColorSwatchPickerItem>[
          for (final Color color in _colors)
            HeroColorSwatchPickerItem(color: color, isDisabled: true),
        ],
      ),
      code:
          '''
${_colorsCode}HeroColorSwatchPicker(
  children: <HeroColorSwatchPickerItem>[
    for (final Color color in colors)
      HeroColorSwatchPickerItem(color: color, isDisabled: true),
  ],
)''',
    ),
    DemoExample(
      title: 'Stack Layout',
      builder: (BuildContext context) => const HeroColorSwatchPicker(
        colors: _colors,
        layout: HeroColorSwatchPickerLayout.stack,
      ),
      code:
          '''
${_colorsCode}HeroColorSwatchPicker(
  colors: colors,
  layout: HeroColorSwatchPickerLayout.stack,
)''',
    ),
    DemoExample(
      title: 'Default Value',
      builder: (BuildContext context) => const HeroColorSwatchPicker(
        colors: _colors,
        defaultValue: Color(0xFF8B5CF6),
      ),
      code:
          '''
${_colorsCode}HeroColorSwatchPicker(
  colors: colors,
  defaultValue: const Color(0xFF8B5CF6),
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _Controlled(),
      code: '''
class ControlledSwatchPicker extends StatefulWidget {
  const ControlledSwatchPicker({super.key});

  @override
  State<ControlledSwatchPicker> createState() => _ControlledSwatchPickerState();
}

class _ControlledSwatchPickerState extends State<ControlledSwatchPicker> {
  Color value = heroParseColor('#F43F5E');

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = theme.typography.sm.copyWith(color: theme.colors.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroColorSwatchPicker(
          colors: colors,
          value: value,
          onChanged: (Color color) => setState(() => value = color),
        ),
        Text.rich(
          TextSpan(
            text: 'Selected: ',
            children: <InlineSpan>[
              TextSpan(
                text: heroColorToString(value, HeroColorFormat.hex),
                style: const TextStyle(fontWeight: HeroTypography.medium),
              ),
            ],
          ),
          style: muted,
        ),
      ],
    );
  }
}''',
    ),
    DemoExample(
      title: 'Custom Indicator',
      builder: (BuildContext context) => HeroColorSwatchPicker(
        children: <HeroColorSwatchPickerItem>[
          for (final Color color in _colors)
            HeroColorSwatchPickerItem(
              color: color,
              children: const <Widget>[
                HeroColorSwatchPickerSwatch(),
                HeroColorSwatchPickerIndicator(
                  child: HeroIcon(HeroIcons.heartFill),
                ),
              ],
            ),
        ],
      ),
      code:
          '''
${_colorsCode}HeroColorSwatchPicker(
  children: <HeroColorSwatchPickerItem>[
    for (final Color color in colors)
      HeroColorSwatchPickerItem(
        color: color,
        children: const <Widget>[
          HeroColorSwatchPickerSwatch(),
          HeroColorSwatchPickerIndicator(child: HeroIcon(HeroIcons.heartFill)),
        ],
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'A builder renders each item from its state (color, isSelected, '
          'isHovered, isFocusVisible, ...).',
      builder: (BuildContext context) => HeroColorSwatchPicker(
        children: <HeroColorSwatchPickerItem>[
          for (final Color color in _colors)
            HeroColorSwatchPickerItem(color: color, builder: _renderItem),
        ],
      ),
      code:
          '''
${_colorsCode}HeroColorSwatchPicker(
  children: <HeroColorSwatchPickerItem>[
    for (final Color color in colors)
      HeroColorSwatchPickerItem(
        color: color,
        builder: (BuildContext context, HeroColorSwatchPickerItemState state) =>
            const Stack(
              fit: StackFit.expand,
              children: <Widget>[
                HeroColorSwatchPickerSwatch(),
                HeroColorSwatchPickerIndicator(),
              ],
            ),
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'The square variant on a bordered surface card (rounded-2xl, p-4).',
      builder: (BuildContext context) => const _CustomStyles(),
      code:
          '''
${_colorsCode}final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl2),
  border: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
  padding: EdgeInsets.all(theme.spacing(4)),
  shadow: theme.shadows.surface,
  child: HeroColorSwatchPicker(
    colors: colors,
    variant: HeroColorSwatchShape.square,
    defaultValue: const Color(0xFF8B5CF6),
  ),
)''',
    ),
  ],
);

Widget _renderItem(
  BuildContext context,
  HeroColorSwatchPickerItemState state,
) => const Stack(
  fit: StackFit.expand,
  children: <Widget>[
    HeroColorSwatchPickerSwatch(),
    HeroColorSwatchPickerIndicator(),
  ],
);

TextStyle _caption(BuildContext context) {
  final HeroThemeData theme = HeroTheme.of(context);
  return theme.typography.sm.copyWith(color: theme.colors.muted);
}

class _Captioned extends StatelessWidget {
  const _Captioned({required this.rows});

  final List<(String, Widget)> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: <Widget>[
        for (final (String caption, Widget child) in rows)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: <Widget>[
              Text(caption, style: _caption(context)),
              child,
            ],
          ),
      ],
    );
  }
}

class _Sizes extends StatelessWidget {
  const _Sizes();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: <Widget>[
        for (final HeroColorSwatchSize size in HeroColorSwatchSize.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              SizedBox(
                width: theme.spacing(8),
                child: Text(size.name, style: _caption(context)),
              ),
              Flexible(
                child: HeroColorSwatchPicker(colors: _colors, size: size),
              ),
            ],
          ),
      ],
    );
  }
}

class _Controlled extends StatefulWidget {
  const _Controlled();

  @override
  State<_Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<_Controlled> {
  Color _value = heroParseColor('#F43F5E');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroColorSwatchPicker(
          colors: _colors,
          value: _value,
          onChanged: (Color color) => setState(() => _value = color),
        ),
        Text.rich(
          TextSpan(
            text: 'Selected: ',
            children: <InlineSpan>[
              TextSpan(
                text: heroColorToString(_value, HeroColorFormat.hex),
                style: const TextStyle(fontWeight: HeroTypography.medium),
              ),
            ],
          ),
          style: _caption(context),
        ),
      ],
    );
  }
}

class _CustomStyles extends StatelessWidget {
  const _CustomStyles();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroSurface(
      borderRadius: BorderRadius.circular(theme.radii.xl2),
      border: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
      padding: EdgeInsets.all(theme.spacing(4)),
      shadow: theme.shadows.surface,
      child: const HeroColorSwatchPicker(
        colors: _colors,
        variant: HeroColorSwatchShape.square,
        defaultValue: Color(0xFF8B5CF6),
      ),
    );
  }
}
