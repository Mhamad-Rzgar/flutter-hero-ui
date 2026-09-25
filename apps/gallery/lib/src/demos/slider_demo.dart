import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// `w-full max-w-xs`.
Widget _maxXs(BuildContext context, Widget child) => ConstrainedBox(
  constraints: BoxConstraints(maxWidth: HeroTheme.of(context).spacing(80)),
  child: child,
);

/// `flex h-64 items-center justify-center`.
Widget _h64(BuildContext context, Widget child) => SizedBox(
  height: HeroTheme.of(context).spacing(64),
  child: Center(child: child),
);

HeroSliderTrack _rangeTrack() => HeroSliderTrack(
  builder: (BuildContext context, HeroSliderState state) => <Widget>[
    const HeroSliderFill(),
    for (int i = 0; i < state.values.length; i++) HeroSliderThumb(index: i),
  ],
);

const String _rangeTrackCode = '''
HeroSliderTrack(
  builder: (BuildContext context, HeroSliderState state) => <Widget>[
    const HeroSliderFill(),
    for (int i = 0; i < state.values.length; i++)
      HeroSliderThumb(index: i),
  ],
)''';

/// "Controlled Value": a slider and the value it reports.
class _ControlledSlider extends StatefulWidget {
  const _ControlledSlider();

  @override
  State<_ControlledSlider> createState() => _ControlledSliderState();
}

class _ControlledSliderState extends State<_ControlledSlider> {
  double _value = 25;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return _maxXs(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(4),
        children: <Widget>[
          HeroSlider(
            value: _value,
            onChanged: (double value) => setState(() => _value = value),
            label: const Text('Volume'),
          ),
          Text('Current value: ${_value.round()}'),
        ],
      ),
    );
  }
}

/// Gallery page of `HeroSlider`.
final ComponentDemo sliderDemo = ComponentDemo(
  slug: 'slider',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('orientation', <String>[
        'horizontal',
        'vertical',
      ], initial: 'horizontal'),
      OptionsControl('step', <String>['1', '5', '10', '25'], initial: '1'),
      ToggleControl('range'),
      ToggleControl('isDisabled'),
      TextControl('label', initial: 'Volume'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final Axis orientation = values.pick('orientation', Axis.values);
      final String text = values.text('label');
      final Widget? label = text.isEmpty ? null : Text(text);
      final double step = double.parse(values.option('step'));
      final Widget slider = values.toggle('range')
          ? HeroSlider.range(
              key: const ValueKey<String>('range'),
              defaultValues: const <double>[25, 75],
              step: step,
              orientation: orientation,
              isDisabled: values.toggle('isDisabled'),
              label: label,
              semanticLabel: text.isEmpty ? 'Range' : null,
            )
          : HeroSlider(
              key: const ValueKey<String>('single'),
              defaultValue: 30,
              step: step,
              orientation: orientation,
              isDisabled: values.toggle('isDisabled'),
              label: label,
              semanticLabel: text.isEmpty ? 'Volume' : null,
            );
      return orientation == Axis.vertical
          ? _h64(context, slider)
          : _maxXs(context, slider);
    },
    code: (PlaygroundValues values) {
      final bool range = values.toggle('range');
      return '''
HeroSlider${range ? '.range' : ''}(
  ${range ? 'defaultValues: const <double>[25, 75]' : 'defaultValue: 30'},
  step: ${values.option('step')},
  orientation: Axis.${values.option('orientation')},
  isDisabled: ${values.toggle('isDisabled')},
  label: const Text('${values.text('label')}'),
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => _maxXs(
        context,
        const HeroSlider(
          defaultValue: 30,
          children: <Widget>[
            HeroLabel.text('Volume'),
            HeroSliderOutput(),
            HeroSliderTrack(
              children: <Widget>[HeroSliderFill(), HeroSliderThumb()],
            ),
          ],
        ),
      ),
      code: '''
ConstrainedBox(
  constraints: const BoxConstraints(maxWidth: 320),
  child: const HeroSlider(
    defaultValue: 30,
    children: <Widget>[
      HeroLabel.text('Volume'),
      HeroSliderOutput(),
      HeroSliderTrack(
        children: <Widget>[HeroSliderFill(), HeroSliderThumb()],
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => _maxXs(
        context,
        const HeroSlider(
          defaultValue: 30,
          isDisabled: true,
          label: Text('Volume'),
        ),
      ),
      code: '''
const HeroSlider(
  defaultValue: 30,
  isDisabled: true,
  label: Text('Volume'),
)''',
    ),
    DemoExample(
      title: 'Range Slider Anatomy',
      description:
          'A range slider renders one thumb per value; the track builder '
          'receives the slider state.',
      builder: (BuildContext context) => _maxXs(
        context,
        HeroSlider.range(
          defaultValues: const <double>[25, 75],
          semanticLabel: 'Range',
          children: <Widget>[const HeroSliderOutput(), _rangeTrack()],
        ),
      ),
      code:
          '''
HeroSlider.range(
  defaultValues: const <double>[25, 75],
  semanticLabel: 'Range',
  children: <Widget>[
    const HeroSliderOutput(),
    $_rangeTrackCode,
  ],
)''',
    ),
    DemoExample(
      title: 'Vertical',
      builder: (BuildContext context) => _h64(
        context,
        const HeroSlider(
          defaultValue: 30,
          orientation: Axis.vertical,
          label: Text('Volume'),
        ),
      ),
      code: '''
SizedBox(
  height: 256,
  child: Center(
    child: HeroSlider(
      defaultValue: 30,
      orientation: Axis.vertical,
      label: const Text('Volume'),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Range',
      builder: (BuildContext context) => _maxXs(
        context,
        HeroSlider.range(
          defaultValues: const <double>[100, 500],
          minValue: 0,
          maxValue: 1000,
          step: 50,
          numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
          children: <Widget>[
            const HeroLabel.text('Price Range'),
            const HeroSliderOutput(),
            _rangeTrack(),
          ],
        ),
      ),
      code:
          '''
HeroSlider.range(
  defaultValues: const <double>[100, 500],
  minValue: 0,
  maxValue: 1000,
  step: 50,
  numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
  children: <Widget>[
    const HeroLabel.text('Price Range'),
    const HeroSliderOutput(),
    $_rangeTrackCode,
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description: 'builder returns the parts from the slider state.',
      builder: (BuildContext context) => _maxXs(
        context,
        HeroSlider(
          defaultValue: 30,
          builder: (BuildContext context, HeroSliderState state) =>
              const <Widget>[
                HeroLabel.text('Volume'),
                HeroSliderOutput(),
                HeroSliderTrack(),
              ],
        ),
      ),
      code: '''
HeroSlider(
  defaultValue: 30,
  builder: (BuildContext context, HeroSliderState state) => const <Widget>[
    HeroLabel.text('Volume'),
    HeroSliderOutput(),
    HeroSliderTrack(),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description: 'A small muted output with explicit track and thumb colors.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return _maxXs(
          context,
          HeroSlider(
            defaultValue: 40,
            children: <Widget>[
              HeroLabel.text(
                'Brightness',
                style: TextStyle(
                  fontWeight: HeroTypography.medium,
                  color: theme.colors.foreground,
                ),
              ),
              HeroSliderOutput(
                style: TextStyle(
                  fontSize: theme.typography.xs.fontSize,
                  height: theme.typography.xs.height,
                  color: theme.colors.muted,
                ),
              ),
              HeroSliderTrack(
                color: theme.colors.defaultColor,
                children: <Widget>[
                  HeroSliderFill(color: theme.colors.accent),
                  HeroSliderThumb(
                    color: theme.colors.accent,
                    knobColor: theme.colors.accentForeground,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);

HeroSlider(
  defaultValue: 40,
  children: <Widget>[
    HeroLabel.text(
      'Brightness',
      style: TextStyle(
        fontWeight: HeroTypography.medium,
        color: theme.colors.foreground,
      ),
    ),
    HeroSliderOutput(
      style: TextStyle(
        fontSize: 12, // text-xs
        height: 16 / 12,
        color: theme.colors.muted,
      ),
    ),
    HeroSliderTrack(
      color: theme.colors.defaultColor,
      children: <Widget>[
        HeroSliderFill(color: theme.colors.accent),
        HeroSliderThumb(
          color: theme.colors.accent,
          knobColor: theme.colors.accentForeground,
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Basic Usage',
      builder: (BuildContext context) => _maxXs(
        context,
        const HeroSlider(defaultValue: 30, label: Text('Volume')),
      ),
      code: '''
const HeroSlider(defaultValue: 30, label: Text('Volume'))''',
    ),
    DemoExample(
      title: 'Range Slider',
      builder: (BuildContext context) => _maxXs(
        context,
        HeroSlider.range(
          defaultValues: const <double>[100, 500],
          maxValue: 1000,
          step: 50,
          numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
          label: const Text('Price Range'),
        ),
      ),
      code: '''
HeroSlider.range(
  defaultValues: const <double>[100, 500],
  maxValue: 1000,
  step: 50,
  numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
  label: const Text('Price Range'),
)''',
    ),
    DemoExample(
      title: 'Controlled Value',
      builder: (BuildContext context) => const _ControlledSlider(),
      code: '''
double value = 25;

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroSlider(
      value: value,
      onChanged: (double v) => setState(() => value = v),
      label: const Text('Volume'),
    ),
    Text('Current value: \${value.round()}'),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Value Formatting',
      builder: (BuildContext context) => _maxXs(
        context,
        HeroSlider(
          defaultValue: 60,
          numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
          label: const Text('Price'),
        ),
      ),
      code: '''
HeroSlider(
  defaultValue: 60,
  numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
  label: const Text('Price'),
)''',
    ),
    DemoExample(
      title: 'Vertical Orientation',
      builder: (BuildContext context) => _h64(
        context,
        const HeroSlider(
          defaultValue: 30,
          orientation: Axis.vertical,
          semanticLabel: 'Volume',
          label: Text('Volume'),
        ),
      ),
      code: '''
const HeroSlider(
  defaultValue: 30,
  orientation: Axis.vertical,
  semanticLabel: 'Volume',
  label: Text('Volume'),
)''',
    ),
    DemoExample(
      title: 'Custom Output Display',
      builder: (BuildContext context) => _maxXs(
        context,
        HeroSlider.range(
          defaultValues: const <double>[25, 75],
          children: <Widget>[
            const HeroLabel.text('Range'),
            HeroSliderOutput(
              builder: (BuildContext context, HeroSliderState state) => Text(
                <String>[
                  for (int i = 0; i < state.values.length; i++)
                    state.getThumbValueLabel(i),
                ].join(' – '),
              ),
            ),
            _rangeTrack(),
          ],
        ),
      ),
      code:
          '''
HeroSlider.range(
  defaultValues: const <double>[25, 75],
  children: <Widget>[
    const HeroLabel.text('Range'),
    HeroSliderOutput(
      builder: (BuildContext context, HeroSliderState state) => Text(
        <String>[
          for (int i = 0; i < state.values.length; i++)
            state.getThumbValueLabel(i),
        ].join(' – '),
      ),
    ),
    $_rangeTrackCode,
  ],
)''',
    ),
  ],
);
