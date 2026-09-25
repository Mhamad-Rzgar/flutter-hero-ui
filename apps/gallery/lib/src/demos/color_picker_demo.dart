import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const List<Color> _presets = <Color>[
  Color(0xFFEF4444),
  Color(0xFFF97316),
  Color(0xFFEAB308),
  Color(0xFF22C55E),
  Color(0xFF06B6D4),
  Color(0xFF3B82F6),
  Color(0xFF8B5CF6),
  Color(0xFFEC4899),
  Color(0xFFF43F5E),
];

const String _presetsCode = '''
const List<Color> presets = <Color>[
  Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFEAB308),
  Color(0xFF22C55E), Color(0xFF06B6D4), Color(0xFF3B82F6),
  Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFF43F5E),
];
''';

/// Gallery page of `HeroColorPicker`, reproducing
/// heroui.com/docs/components/color-picker.
final ComponentDemo colorPickerDemo = ComponentDemo(
  slug: 'color-picker',
  playground: Playground(
    controls: const <PlaygroundControl>[
      TextControl('label', initial: 'Pick a color'),
      TextControl('defaultValue', initial: '#0485F7'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroColorPicker(
      key: ValueKey<String>(values.text('defaultValue')),
      label: values.text('label'),
      defaultValue: HeroColorValue.tryParse(
        values.text('defaultValue'),
      )?.toColor(),
      isDisabled: values.toggle('isDisabled'),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroColorPicker(\n')
        ..writeln("  label: '${values.text('label')}',")
        ..writeln(
          "  defaultValue: heroParseColor('${values.text('defaultValue')}'),",
        );
      if (values.toggle('isDisabled')) out.writeln('  isDisabled: true,');
      out.write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _Basic(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroColorPicker(
  defaultValue: heroParseColor('#0485F7'),
  trigger: const HeroColorPickerTrigger(
    children: <Widget>[
      HeroColorSwatch(size: HeroColorSwatchSize.lg),
      HeroLabel.text('Pick a color'),
    ],
  ),
  popover: HeroColorPickerPopover(
    children: <Widget>[
      const HeroColorArea(
        semanticLabel: 'Color area',
        maxSize: double.infinity,
        colorSpace: HeroColorSpace.hsb,
        xChannel: HeroColorChannel.saturation,
        yChannel: HeroColorChannel.brightness,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
        child: HeroColorSlider(
          channel: HeroColorChannel.hue,
          colorSpace: HeroColorSpace.hsb,
          children: <Widget>[
            const HeroLabel.text('Hue'),
            HeroColorSliderOutput(style: TextStyle(color: theme.colors.muted)),
            const HeroColorSliderTrack(),
          ],
        ),
      ),
    ],
  ),
)

// The same anatomy, built from the label:
HeroColorPicker(label: 'Pick a color', defaultValue: heroParseColor('#0485F7'))''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _Controlled(),
      code:
          '''
${_presetsCode}Color color = heroParseColor('#325578');

void shuffle() {
  final math.Random random = math.Random();
  setState(() {
    color = HeroColorValue.hsl(
      random.nextInt(360).toDouble(),
      50 + random.nextInt(50).toDouble(),
      40 + random.nextInt(30).toDouble(),
    ).toColor();
  });
}

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroColorPicker(
      value: color,
      onChanged: (Color next) => setState(() => color = next),
      trigger: const HeroColorPickerTrigger(
        children: <Widget>[
          HeroColorSwatch(size: HeroColorSwatchSize.lg),
          HeroLabel.text('Pick a color'),
        ],
      ),
      popover: HeroColorPickerPopover(
        spacing: theme.spacing(2),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: theme.spacing(2)),
            child: HeroColorSwatchPicker(
              size: HeroColorSwatchSize.xs,
              alignment: WrapAlignment.center,
              children: <HeroColorSwatchPickerItem>[
                for (final Color preset in presets)
                  HeroColorSwatchPickerItem(
                    color: preset,
                    children: const <Widget>[HeroColorSwatchPickerSwatch()],
                  ),
              ],
            ),
          ),
          const HeroColorArea(
            semanticLabel: 'Color area',
            maxSize: double.infinity,
            colorSpace: HeroColorSpace.hsb,
            xChannel: HeroColorChannel.saturation,
            yChannel: HeroColorChannel.brightness,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
            child: Row(
              spacing: theme.spacing(2),
              children: <Widget>[
                const Expanded(
                  child: HeroColorSlider(
                    semanticLabel: 'Hue slider',
                    channel: HeroColorChannel.hue,
                    colorSpace: HeroColorSpace.hsb,
                  ),
                ),
                HeroButton(
                  isIconOnly: true,
                  size: HeroSize.sm,
                  variant: HeroButtonVariant.tertiary,
                  semanticLabel: 'Shuffle color',
                  onPressed: shuffle,
                  child: const HeroIcon(HeroIcons.shuffle),
                ),
              ],
            ),
          ),
          const HeroColorField(
            semanticLabel: 'Color field',
            variant: HeroFieldVariant.secondary,
            showSwatch: true,
          ),
        ],
      ),
    ),
    Text.rich(
      TextSpan(
        text: 'Selected: ',
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
)''',
    ),
    DemoExample(
      title: 'With Swatches',
      builder: (BuildContext context) => const _WithSwatches(),
      code:
          '''
${_presetsCode}HeroColorPicker(
  defaultValue: heroParseColor('#F43F5E'),
  trigger: const HeroColorPickerTrigger(
    children: <Widget>[
      HeroColorSwatch(size: HeroColorSwatchSize.lg),
      HeroLabel.text('Brand Color'),
    ],
  ),
  popover: HeroColorPickerPopover(
    children: <Widget>[
      const HeroColorArea(
        semanticLabel: 'Color area',
        maxSize: double.infinity,
        colorSpace: HeroColorSpace.hsb,
        xChannel: HeroColorChannel.saturation,
        yChannel: HeroColorChannel.brightness,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
        child: HeroColorSlider(
          semanticLabel: 'Hue slider',
          channel: HeroColorChannel.hue,
          colorSpace: HeroColorSpace.hsb,
          children: <Widget>[
            const HeroLabel.text('Hue'),
            HeroColorSliderOutput(style: TextStyle(color: theme.colors.muted)),
            const HeroColorSliderTrack(),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
        child: HeroColorSwatchPicker(
          size: HeroColorSwatchSize.xs,
          alignment: WrapAlignment.center,
          children: <HeroColorSwatchPickerItem>[
            for (final Color preset in presets)
              HeroColorSwatchPickerItem(
                color: preset,
                children: const <Widget>[HeroColorSwatchPickerSwatch()],
              ),
          ],
        ),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A rounded-xl trigger on default-soft with 12×8 padding, and the '
          'popover on the surface color.',
      builder: (BuildContext context) => const _CustomStyles(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroColorPicker(
  defaultValue: heroParseColor('#0485F7'),
  trigger: HeroColorPickerTrigger(
    borderRadius: BorderRadius.circular(theme.radii.xl),
    backgroundColor: theme.colors.defaultSoft,
    padding: EdgeInsets.symmetric(
      horizontal: theme.spacing(3),
      vertical: theme.spacing(2),
    ),
    children: <Widget>[
      const HeroColorSwatch(size: HeroColorSwatchSize.lg),
      HeroLabel.text('Theme color', style: TextStyle(color: theme.colors.foreground)),
    ],
  ),
  popover: HeroColorPickerPopover(
    backgroundColor: theme.colors.surface,
    children: <Widget>[
      const HeroColorArea(
        semanticLabel: 'Color area',
        maxSize: double.infinity,
        colorSpace: HeroColorSpace.hsb,
        xChannel: HeroColorChannel.saturation,
        yChannel: HeroColorChannel.brightness,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
        child: HeroColorSlider(
          channel: HeroColorChannel.hue,
          colorSpace: HeroColorSpace.hsb,
          children: <Widget>[
            const HeroLabel.text('Hue'),
            HeroColorSliderOutput(style: TextStyle(color: theme.colors.muted)),
            const HeroColorSliderTrack(),
          ],
        ),
      ),
    ],
  ),
)''',
    ),
  ],
);

HeroColorSwatchPicker _presetPicker() => HeroColorSwatchPicker(
  size: HeroColorSwatchSize.xs,
  alignment: WrapAlignment.center,
  children: <HeroColorSwatchPickerItem>[
    for (final Color preset in _presets)
      HeroColorSwatchPickerItem(
        color: preset,
        children: const <Widget>[HeroColorSwatchPickerSwatch()],
      ),
  ],
);

const HeroColorArea _area = HeroColorArea(
  semanticLabel: 'Color area',
  maxSize: double.infinity,
  colorSpace: HeroColorSpace.hsb,
  xChannel: HeroColorChannel.saturation,
  yChannel: HeroColorChannel.brightness,
);

Widget _hueSlider(BuildContext context, {String? semanticLabel}) {
  final HeroThemeData theme = HeroTheme.of(context);
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
    child: HeroColorSlider(
      semanticLabel: semanticLabel,
      channel: HeroColorChannel.hue,
      colorSpace: HeroColorSpace.hsb,
      children: <Widget>[
        const HeroLabel.text('Hue'),
        HeroColorSliderOutput(style: TextStyle(color: theme.colors.muted)),
        const HeroColorSliderTrack(),
      ],
    ),
  );
}

class _Basic extends StatelessWidget {
  const _Basic();

  @override
  Widget build(BuildContext context) {
    return HeroColorPicker(
      defaultValue: heroParseColor('#0485F7'),
      trigger: const HeroColorPickerTrigger(
        children: <Widget>[
          HeroColorSwatch(size: HeroColorSwatchSize.lg),
          HeroLabel.text('Pick a color'),
        ],
      ),
      popover: HeroColorPickerPopover(
        children: <Widget>[_area, _hueSlider(context)],
      ),
    );
  }
}

class _Controlled extends StatefulWidget {
  const _Controlled();

  @override
  State<_Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<_Controlled> {
  Color _color = heroParseColor('#325578');
  final math.Random _random = math.Random();

  void _shuffle() {
    setState(() {
      _color = HeroColorValue.hsl(
        _random.nextInt(360).toDouble(),
        50 + _random.nextInt(50).toDouble(),
        40 + _random.nextInt(30).toDouble(),
      ).toColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroColorPicker(
          value: _color,
          onChanged: (Color next) => setState(() => _color = next),
          trigger: const HeroColorPickerTrigger(
            children: <Widget>[
              HeroColorSwatch(size: HeroColorSwatchSize.lg),
              HeroLabel.text('Pick a color'),
            ],
          ),
          popover: HeroColorPickerPopover(
            spacing: theme.spacing(2),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: theme.spacing(2)),
                child: _presetPicker(),
              ),
              _area,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
                child: Row(
                  spacing: theme.spacing(2),
                  children: <Widget>[
                    const Expanded(
                      child: HeroColorSlider(
                        semanticLabel: 'Hue slider',
                        channel: HeroColorChannel.hue,
                        colorSpace: HeroColorSpace.hsb,
                      ),
                    ),
                    HeroButton(
                      isIconOnly: true,
                      size: HeroSize.sm,
                      variant: HeroButtonVariant.tertiary,
                      semanticLabel: 'Shuffle color',
                      onPressed: _shuffle,
                      child: const HeroIcon(HeroIcons.shuffle),
                    ),
                  ],
                ),
              ),
              const HeroColorField(
                semanticLabel: 'Color field',
                variant: HeroFieldVariant.secondary,
                showSwatch: true,
              ),
            ],
          ),
        ),
        SizedBox(
          width: theme.spacing(60),
          child: Text.rich(
            TextSpan(
              text: 'Selected: ',
              children: <InlineSpan>[
                TextSpan(
                  text: heroColorToString(_color, HeroColorFormat.hex),
                  style: const TextStyle(fontWeight: HeroTypography.medium),
                ),
              ],
            ),
            style: theme.typography.sm.copyWith(color: theme.colors.muted),
          ),
        ),
      ],
    );
  }
}

class _WithSwatches extends StatelessWidget {
  const _WithSwatches();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroColorPicker(
      defaultValue: heroParseColor('#F43F5E'),
      trigger: const HeroColorPickerTrigger(
        children: <Widget>[
          HeroColorSwatch(size: HeroColorSwatchSize.lg),
          HeroLabel.text('Brand Color'),
        ],
      ),
      popover: HeroColorPickerPopover(
        children: <Widget>[
          _area,
          _hueSlider(context, semanticLabel: 'Hue slider'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
            child: _presetPicker(),
          ),
        ],
      ),
    );
  }
}

class _CustomStyles extends StatelessWidget {
  const _CustomStyles();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroColorPicker(
      defaultValue: heroParseColor('#0485F7'),
      trigger: HeroColorPickerTrigger(
        borderRadius: BorderRadius.circular(theme.radii.xl),
        backgroundColor: theme.colors.defaultSoft,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing(3),
          vertical: theme.spacing(2),
        ),
        children: <Widget>[
          const HeroColorSwatch(size: HeroColorSwatchSize.lg),
          HeroLabel.text(
            'Theme color',
            style: TextStyle(color: theme.colors.foreground),
          ),
        ],
      ),
      popover: HeroColorPickerPopover(
        backgroundColor: theme.colors.surface,
        children: <Widget>[_area, _hueSlider(context)],
      ),
    );
  }
}
