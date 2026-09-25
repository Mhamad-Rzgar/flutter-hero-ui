import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// `w-64`.
Widget _w64(BuildContext context, Widget child) =>
    SizedBox(width: HeroTheme.of(context).spacing(64), child: child);

/// `flex w-64 flex-col gap-6`.
Widget _stack(BuildContext context, List<Widget> children) => _w64(
  context,
  Column(
    mainAxisSize: MainAxisSize.min,
    spacing: HeroTheme.of(context).spacing(6),
    children: children,
  ),
);

/// Gallery page of `HeroMeter`.
final ComponentDemo meterDemo = ComponentDemo(
  slug: 'meter',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('value', <String>['0', '25', '60', '100'], initial: '60'),
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('color', <String>[
        'standard',
        'accent',
        'success',
        'warning',
        'danger',
      ], initial: 'accent'),
      TextControl('label', initial: 'Storage'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _w64(
      context,
      HeroMeter(
        value: double.parse(values.option('value')),
        size: values.pick('size', HeroSize.values),
        color: values.pick('color', HeroColor.values),
        isDisabled: values.toggle('isDisabled'),
        label: values.text('label').isEmpty ? null : Text(values.text('label')),
        semanticLabel: values.text('label').isEmpty ? 'Meter' : null,
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroMeter(
  value: ${values.option('value')},
  size: HeroSize.${values.option('size')},
  color: HeroColor.${values.option('color')},
  isDisabled: ${values.toggle('isDisabled')},
  label: const Text('${values.text('label')}'),
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => _w64(
        context,
        const HeroMeter(
          value: 60,
          semanticLabel: 'Storage',
          children: <Widget>[
            HeroLabel.text('Storage'),
            HeroMeterOutput(),
            HeroMeterTrack(child: HeroMeterFill()),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroMeter(
    value: 60,
    semanticLabel: 'Storage',
    children: const <Widget>[
      HeroLabel.text('Storage'),
      HeroMeterOutput(),
      HeroMeterTrack(child: HeroMeterFill()),
    ],
  ),
)

// Or the same layout from the label alone:
const HeroMeter(value: 60, label: Text('Storage'))''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => _stack(context, const <Widget>[
        HeroMeter(
          color: HeroColor.success,
          size: HeroSize.sm,
          value: 40,
          label: Text('Small'),
        ),
        HeroMeter(value: 60, label: Text('Medium')),
        HeroMeter(
          color: HeroColor.warning,
          size: HeroSize.lg,
          value: 80,
          label: Text('Large'),
        ),
      ]),
      code: '''
SizedBox(
  width: 256,
  child: Column(
    spacing: 24,
    children: const <Widget>[
      HeroMeter(
        color: HeroColor.success,
        size: HeroSize.sm,
        value: 40,
        label: Text('Small'),
      ),
      HeroMeter(size: HeroSize.md, value: 60, label: Text('Medium')),
      HeroMeter(
        color: HeroColor.warning,
        size: HeroSize.lg,
        value: 80,
        label: Text('Large'),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Colors',
      builder: (BuildContext context) => _stack(context, <Widget>[
        for (final (HeroColor color, String label) in <(HeroColor, String)>[
          (HeroColor.standard, 'Default'),
          (HeroColor.accent, 'Accent'),
          (HeroColor.success, 'Success'),
          (HeroColor.warning, 'Warning'),
          (HeroColor.danger, 'Danger'),
        ])
          HeroMeter(color: color, value: 50, label: Text(label)),
      ]),
      code: '''
SizedBox(
  width: 256,
  child: Column(
    spacing: 24,
    children: const <Widget>[
      HeroMeter(color: HeroColor.standard, value: 50, label: Text('Default')),
      HeroMeter(color: HeroColor.accent, value: 50, label: Text('Accent')),
      HeroMeter(color: HeroColor.success, value: 50, label: Text('Success')),
      HeroMeter(color: HeroColor.warning, value: 50, label: Text('Warning')),
      HeroMeter(color: HeroColor.danger, value: 50, label: Text('Danger')),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Without Label',
      description:
          'When no visible label is needed, use semanticLabel for '
          'accessibility.',
      builder: (BuildContext context) => _w64(
        context,
        const HeroMeter(value: 45, semanticLabel: 'Storage usage'),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroMeter(
    value: 45,
    semanticLabel: 'Storage usage',
    children: const <Widget>[HeroMeterTrack(child: HeroMeterFill())],
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Value Scale',
      description:
          'Use minValue, maxValue and numberFormat to customize the value '
          'range and display format.',
      builder: (BuildContext context) => _w64(
        context,
        HeroMeter(
          value: 750,
          minValue: 0,
          maxValue: 1000,
          numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
          label: const Text('Revenue'),
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroMeter(
    value: 750,
    minValue: 0,
    maxValue: 1000,
    numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
    label: const Text('Revenue'),
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A muted output and a fully rounded track with a warning fill.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final BorderRadius full = BorderRadius.all(
          Radius.circular(theme.radii.full),
        );
        return _w64(
          context,
          HeroMeter(
            value: 68,
            semanticLabel: 'Storage used',
            children: <Widget>[
              HeroLabel.text(
                'Storage used',
                style: TextStyle(
                  fontWeight: HeroTypography.medium,
                  color: theme.colors.foreground,
                ),
              ),
              HeroMeterOutput(style: TextStyle(color: theme.colors.muted)),
              HeroMeterTrack(
                color: theme.colors.defaultColor,
                borderRadius: full,
                child: HeroMeterFill(
                  color: theme.colors.warning,
                  borderRadius: full,
                ),
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final BorderRadius full = BorderRadius.all(Radius.circular(theme.radii.full));

SizedBox(
  width: 256,
  child: HeroMeter(
    value: 68,
    semanticLabel: 'Storage used',
    children: <Widget>[
      HeroLabel.text(
        'Storage used',
        style: TextStyle(
          fontWeight: HeroTypography.medium,
          color: theme.colors.foreground,
        ),
      ),
      HeroMeterOutput(style: TextStyle(color: theme.colors.muted)),
      HeroMeterTrack(
        color: theme.colors.defaultColor,
        borderRadius: full,
        child: HeroMeterFill(color: theme.colors.warning, borderRadius: full),
      ),
    ],
  ),
)''',
    ),
  ],
);
