import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroColorSlider`, reproducing
/// heroui.com/docs/components/color-slider.
final ComponentDemo colorSliderDemo = ComponentDemo(
  slug: 'color-slider',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('channel', <String>[
        'hue',
        'saturation',
        'lightness',
        'brightness',
        'red',
        'green',
        'blue',
        'alpha',
      ]),
      OptionsControl('orientation', <String>['horizontal', 'vertical']),
      ToggleControl('isDisabled'),
      TextControl('label', initial: 'Hue'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final HeroColorChannel channel = values.pick(
        'channel',
        HeroColorChannel.values,
      );
      final bool vertical = values.option('orientation') == 'vertical';
      final String label = values.text('label');
      final Widget slider = HeroColorSlider(
        key: ValueKey<String>('${channel.name}-$vertical'),
        channel: channel,
        orientation: vertical ? Axis.vertical : Axis.horizontal,
        isDisabled: values.toggle('isDisabled'),
        label: label.isEmpty ? null : label,
        semanticLabel: label.isEmpty ? channel.label : null,
        defaultValue: heroParseColor('hsla(200, 80%, 50%, 0.8)'),
      );
      return vertical
          ? SizedBox(height: 192, child: slider)
          : SizedBox(width: 320, child: slider);
    },
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroColorSlider(\n')
        ..writeln('  channel: HeroColorChannel.${values.option('channel')},')
        ..writeln(
          "  defaultValue: heroParseColor('hsla(200, 80%, 50%, 0.8)'),",
        );
      if (values.text('label').isNotEmpty) {
        out.writeln("  label: '${values.text('label')}',");
      }
      if (values.option('orientation') == 'vertical') {
        out.writeln('  orientation: Axis.vertical,');
      }
      if (values.toggle('isDisabled')) out.writeln('  isDisabled: true,');
      out.write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: HeroColorSlider(
          channel: HeroColorChannel.hue,
          label: 'Hue',
          defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
        ),
      ),
      code: '''
SizedBox(
  width: 320,
  child: HeroColorSlider(
    channel: HeroColorChannel.hue,
    label: 'Hue',
    defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
  ),
)

// The same slider composed from its parts:
HeroColorSlider(
  channel: HeroColorChannel.hue,
  defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
  children: const <Widget>[
    HeroLabel.text('Hue'),
    HeroColorSliderOutput(),
    HeroColorSliderTrack(thumb: HeroColorSliderThumb()),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: HeroColorSlider(
          channel: HeroColorChannel.hue,
          label: 'Hue',
          isDisabled: true,
          defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
        ),
      ),
      code: '''
SizedBox(
  width: 320,
  child: HeroColorSlider(
    channel: HeroColorChannel.hue,
    label: 'Hue',
    isDisabled: true,
    defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
  ),
)''',
    ),
    DemoExample(
      title: 'Vertical',
      builder: (BuildContext context) => SizedBox(
        height: 192,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            for (final HeroColorChannel channel in <HeroColorChannel>[
              HeroColorChannel.hue,
              HeroColorChannel.saturation,
              HeroColorChannel.lightness,
            ])
              HeroColorSlider(
                channel: channel,
                orientation: Axis.vertical,
                semanticLabel: channel.label,
                defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
              ),
          ],
        ),
      ),
      code: '''
SizedBox(
  height: 192,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: <Widget>[
      for (final HeroColorChannel channel in <HeroColorChannel>[
        HeroColorChannel.hue,
        HeroColorChannel.saturation,
        HeroColorChannel.lightness,
      ])
        HeroColorSlider(
          channel: channel,
          orientation: Axis.vertical,
          semanticLabel: channel.label,
          defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
        ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _SharedColor(
        initial: 'hsl(200, 100%, 50%)',
        channels: <HeroColorChannel>[HeroColorChannel.hue],
        format: HeroColorFormat.hsl,
      ),
      code: _sharedCode(
        initial: 'hsl(200, 100%, 50%)',
        channels: <String>['hue'],
        format: 'hsl',
      ),
    ),
    DemoExample(
      title: 'HSL Channels',
      description:
          'Several sliders share one color; each adjusts one channel. The '
          'hue stays put when saturation reaches zero.',
      builder: (BuildContext context) => const _SharedColor(
        initial: 'hsl(0, 100%, 50%)',
        channels: <HeroColorChannel>[
          HeroColorChannel.hue,
          HeroColorChannel.saturation,
          HeroColorChannel.lightness,
        ],
        format: HeroColorFormat.hsl,
      ),
      code: _sharedCode(
        initial: 'hsl(0, 100%, 50%)',
        channels: <String>['hue', 'saturation', 'lightness'],
        format: 'hsl',
      ),
    ),
    DemoExample(
      title: 'Alpha Channel',
      description:
          'The alpha track shows the transparency checkerboard under the '
          'gradient.',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: HeroColorSlider(
          channel: HeroColorChannel.alpha,
          label: 'Alpha',
          defaultValue: heroParseColor('hsla(0, 100%, 50%, 0.5)'),
        ),
      ),
      code: '''
SizedBox(
  width: 320,
  child: HeroColorSlider(
    channel: HeroColorChannel.alpha,
    label: 'Alpha',
    defaultValue: heroParseColor('hsla(0, 100%, 50%, 0.5)'),
  ),
)''',
    ),
    DemoExample(
      title: 'RGB Channels',
      builder: (BuildContext context) => const _SharedColor(
        initial: 'rgb(255, 100, 50)',
        channels: <HeroColorChannel>[
          HeroColorChannel.red,
          HeroColorChannel.green,
          HeroColorChannel.blue,
        ],
        format: HeroColorFormat.rgb,
      ),
      code: _sharedCode(
        initial: 'rgb(255, 100, 50)',
        channels: <String>['red', 'green', 'blue'],
        format: 'rgb',
      ),
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'builder receives the slider state (value, channel, orientation, '
          'isDisabled, isDragging) and composes the parts.',
      builder: (BuildContext context) => SizedBox(
        width: 320,
        child: HeroColorSlider(
          channel: HeroColorChannel.hue,
          defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
          builder: _renderSlider,
        ),
      ),
      code: '''
SizedBox(
  width: 320,
  child: HeroColorSlider(
    channel: HeroColorChannel.hue,
    defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
    builder: (BuildContext context, HeroColorSliderState state) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: HeroLabel.text(state.isDragging ? 'Hue (dragging)' : 'Hue')),
            const HeroColorSliderOutput(),
          ],
        ),
        const HeroColorSliderTrack(),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A 16 px track with small end caps and a border, and a square '
          'thumb with a background-colored border and a ring.',
      builder: (BuildContext context) => const _CustomStyles(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
SizedBox(
  width: 384,
  child: HeroColorSlider(
    channel: HeroColorChannel.hue,
    defaultValue: heroParseColor('hsl(220, 70%, 50%)'),
    children: <Widget>[
      HeroLabel.text('Hue', style: TextStyle(color: theme.colors.foreground)),
      HeroColorSliderOutput(style: TextStyle(color: theme.colors.muted)),
      HeroColorSliderTrack(
        thickness: theme.spacing(4),
        capRadius: theme.radii.sm,
        borderColor: theme.colors.border,
        thumb: HeroColorSliderThumb(
          borderRadius: BorderRadius.circular(theme.radii.sm),
          borderWidth: theme.spacing(0.5),
          borderColor: theme.colors.background,
          shadows: <BoxShadow>[
            // shadow-md
            const BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
            const BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
            // ring-1 ring-black/10 (ring-white/20 in dark mode)
            BoxShadow(
              color: theme.isDark ? const Color(0x33FFFFFF) : const Color(0x1A000000),
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    ],
  ),
)''',
    ),
  ],
);

Widget _renderSlider(BuildContext context, HeroColorSliderState state) =>
    Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: HeroLabel.text(
                  state.isDragging ? 'Hue (dragging)' : 'Hue',
                ),
              ),
            ),
            const HeroColorSliderOutput(),
          ],
        ),
        const HeroColorSliderTrack(),
      ],
    );

String _sharedCode({
  required String initial,
  required List<String> channels,
  required String format,
}) =>
    '''
class SharedColorSliders extends StatefulWidget {
  const SharedColorSliders({super.key});

  @override
  State<SharedColorSliders> createState() => _SharedColorSlidersState();
}

class _SharedColorSlidersState extends State<SharedColorSliders> {
  Color color = heroParseColor('$initial');

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final HeroColorChannel channel in <HeroColorChannel>[
${channels.map((String c) => '            HeroColorChannel.$c,').join('\n')}
          ])
            HeroColorSlider(
              channel: channel,
              label: channel.label,
              value: color,
              onChanged: (Color next) => setState(() => color = next),
            ),
          Row(
            spacing: 8,
            children: <Widget>[
              HeroColorSwatch(color: color, size: HeroColorSwatchSize.sm),
              Text.rich(
                TextSpan(
                  text: 'Current color: ',
                  children: <InlineSpan>[
                    TextSpan(
                      text: heroColorToString(color, HeroColorFormat.$format),
                      style: theme.typography.style(HeroFontSize.sm, mono: true),
                    ),
                  ],
                ),
                style: theme.typography.sm.copyWith(color: theme.colors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}''';

class _SharedColor extends StatefulWidget {
  const _SharedColor({
    required this.initial,
    required this.channels,
    required this.format,
  });

  final String initial;
  final List<HeroColorChannel> channels;
  final HeroColorFormat format;

  @override
  State<_SharedColor> createState() => _SharedColorState();
}

class _SharedColorState extends State<_SharedColor> {
  late Color _color = heroParseColor(widget.initial);

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          for (final HeroColorChannel channel in widget.channels)
            HeroColorSlider(
              channel: channel,
              label: channel.label,
              value: _color,
              onChanged: (Color next) => setState(() => _color = next),
            ),
          Row(
            spacing: 8,
            children: <Widget>[
              HeroColorSwatch(color: _color, size: HeroColorSwatchSize.sm),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: 'Current color: ',
                    children: <InlineSpan>[
                      TextSpan(
                        text: heroColorToString(_color, widget.format),
                        style: theme.typography.style(
                          HeroFontSize.sm,
                          mono: true,
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
    return SizedBox(
      width: 384,
      child: HeroColorSlider(
        channel: HeroColorChannel.hue,
        defaultValue: heroParseColor('hsl(220, 70%, 50%)'),
        children: <Widget>[
          HeroLabel.text(
            'Hue',
            style: TextStyle(color: theme.colors.foreground),
          ),
          HeroColorSliderOutput(style: TextStyle(color: theme.colors.muted)),
          HeroColorSliderTrack(
            thickness: theme.spacing(4),
            capRadius: theme.radii.sm,
            borderColor: theme.colors.border,
            thumb: HeroColorSliderThumb(
              borderRadius: BorderRadius.circular(theme.radii.sm),
              borderWidth: theme.spacing(0.5),
              borderColor: theme.colors.background,
              shadows: <BoxShadow>[
                const BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -1,
                ),
                const BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: theme.isDark
                      ? const Color(0x33FFFFFF)
                      : const Color(0x1A000000),
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
