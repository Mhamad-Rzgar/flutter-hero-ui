import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const List<String> _channelOptions = <String>[
  'default',
  'hue',
  'saturation',
  'brightness',
  'lightness',
  'red',
  'green',
  'blue',
];

HeroColorChannel? _channel(String name) =>
    name == 'default' ? null : HeroColorChannel.values.byName(name);

/// Gallery page of `HeroColorArea`, reproducing
/// heroui.com/docs/components/color-area.
final ComponentDemo colorAreaDemo = ComponentDemo(
  slug: 'color-area',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('colorSpace', <String>['hsb', 'hsl', 'rgb']),
      OptionsControl('xChannel', _channelOptions),
      OptionsControl('yChannel', _channelOptions),
      ToggleControl('showDots'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroColorArea(
      defaultValue: heroParseColor('hsb(219, 58%, 93%)'),
      colorSpace: values.pick('colorSpace', HeroColorSpace.values),
      xChannel: _channel(values.option('xChannel')),
      yChannel: _channel(values.option('yChannel')),
      showDots: values.toggle('showDots'),
      isDisabled: values.toggle('isDisabled'),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroColorArea(\n')
        ..writeln("  defaultValue: heroParseColor('hsb(219, 58%, 93%)'),")
        ..writeln(
          '  colorSpace: HeroColorSpace.${values.option('colorSpace')},',
        );
      for (final String axis in <String>['xChannel', 'yChannel']) {
        if (values.option(axis) != 'default') {
          out.writeln('  $axis: HeroColorChannel.${values.option(axis)},');
        }
      }
      if (values.toggle('showDots')) out.writeln('  showDots: true,');
      if (values.toggle('isDisabled')) out.writeln('  isDisabled: true,');
      out.write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      description:
          'React Aria takes the axes from the value, so an rgb() value edits '
          'red and green; Flutter colors have no space, so they are named.',
      builder: (BuildContext context) => HeroColorArea(
        colorSpace: HeroColorSpace.rgb,
        xChannel: HeroColorChannel.red,
        yChannel: HeroColorChannel.green,
        defaultValue: heroParseColor('rgb(116, 52, 255)'),
      ),
      code: '''
HeroColorArea(
  colorSpace: HeroColorSpace.rgb,
  xChannel: HeroColorChannel.red,
  yChannel: HeroColorChannel.green,
  defaultValue: heroParseColor('rgb(116, 52, 255)'),
)''',
    ),
    DemoExample(
      title: 'With Dots',
      builder: (BuildContext context) => HeroColorArea(
        showDots: true,
        defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
      ),
      code: '''
HeroColorArea(
  showDots: true,
  defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => HeroColorArea(
        isDisabled: true,
        defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
      ),
      code: '''
HeroColorArea(
  isDisabled: true,
  defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _Controlled(),
      code: '''
class ControlledColorArea extends StatefulWidget {
  const ControlledColorArea({super.key});

  @override
  State<ControlledColorArea> createState() => _ControlledColorAreaState();
}

class _ControlledColorAreaState extends State<ControlledColorArea> {
  Color color = heroParseColor('#9B80FF');

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroColorArea(
          colorSpace: HeroColorSpace.rgb,
          xChannel: HeroColorChannel.red,
          yChannel: HeroColorChannel.green,
          value: color,
          onChanged: (Color next) => setState(() => color = next),
        ),
        SizedBox(
          width: 300,
          child: Row(
            spacing: 12,
            children: <Widget>[
              HeroColorSwatch(color: color),
              Text.rich(
                TextSpan(
                  text: 'Current color: ',
                  children: <InlineSpan>[
                    TextSpan(
                      text: heroColorToString(color, HeroColorFormat.hex),
                      style: const TextStyle(fontWeight: HeroTypography.medium),
                    ),
                  ],
                ),
                style: theme.typography.sm.copyWith(color: theme.colors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'The thumb builder receives the area state (color, isDragging, '
          'isFocusVisible, ...); here a swatch that grows while dragged.',
      builder: (BuildContext context) => HeroColorArea(
        colorSpace: HeroColorSpace.rgb,
        xChannel: HeroColorChannel.red,
        yChannel: HeroColorChannel.green,
        defaultValue: heroParseColor('rgb(116, 52, 255)'),
        thumb: const HeroColorAreaThumb(builder: _swatchThumb),
      ),
      code: '''
HeroColorArea(
  colorSpace: HeroColorSpace.rgb,
  xChannel: HeroColorChannel.red,
  yChannel: HeroColorChannel.green,
  defaultValue: heroParseColor('rgb(116, 52, 255)'),
  thumb: HeroColorAreaThumb(
    builder: (BuildContext context, HeroColorAreaState state) =>
        HeroColorSwatch(
          color: state.color,
          size: state.isDragging ? HeroColorSwatchSize.sm : HeroColorSwatchSize.xs,
        ),
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A 176 px area with rounded-3xl corners and a 20 px round thumb with '
          'a 4 px border.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroColorArea(
          size: theme.spacing(44),
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          defaultValue: heroParseColor('rgb(116, 52, 255)'),
          colorSpace: HeroColorSpace.rgb,
          xChannel: HeroColorChannel.red,
          yChannel: HeroColorChannel.green,
          thumb: HeroColorAreaThumb(
            size: theme.spacing(5),
            borderWidth: theme.spacing(1),
            borderRadius: BorderRadius.circular(theme.radii.full),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroColorArea(
  size: theme.spacing(44),
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  defaultValue: heroParseColor('rgb(116, 52, 255)'),
  colorSpace: HeroColorSpace.rgb,
  xChannel: HeroColorChannel.red,
  yChannel: HeroColorChannel.green,
  thumb: HeroColorAreaThumb(
    size: theme.spacing(5),
    borderWidth: theme.spacing(1),
    borderRadius: BorderRadius.circular(theme.radii.full),
  ),
)''',
    ),
  ],
);

Widget _swatchThumb(BuildContext context, HeroColorAreaState state) =>
    HeroColorSwatch(
      color: state.color,
      size: state.isDragging ? HeroColorSwatchSize.sm : HeroColorSwatchSize.xs,
    );

class _Controlled extends StatefulWidget {
  const _Controlled();

  @override
  State<_Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<_Controlled> {
  Color _color = heroParseColor('#9B80FF');

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroColorArea(
          colorSpace: HeroColorSpace.rgb,
          xChannel: HeroColorChannel.red,
          yChannel: HeroColorChannel.green,
          value: _color,
          onChanged: (Color next) => setState(() => _color = next),
        ),
        SizedBox(
          width: 300,
          child: Row(
            spacing: 12,
            children: <Widget>[
              HeroColorSwatch(color: _color),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: 'Current color: ',
                    children: <InlineSpan>[
                      TextSpan(
                        text: heroColorToString(_color, HeroColorFormat.hex),
                        style: const TextStyle(
                          fontWeight: HeroTypography.medium,
                        ),
                      ),
                    ],
                  ),
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
