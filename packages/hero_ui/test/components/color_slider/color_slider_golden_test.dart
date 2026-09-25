import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  heroGoldenTest(
    'channels',
    name: 'color_slider_channels',
    size: const Size(360, 520),
    builder: (HeroThemeData theme) => SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final HeroColorChannel channel in <HeroColorChannel>[
            HeroColorChannel.hue,
            HeroColorChannel.saturation,
            HeroColorChannel.lightness,
            HeroColorChannel.alpha,
          ])
            HeroColorSlider(
              channel: channel,
              label: channel.label,
              defaultValue: heroParseColor('hsla(200, 80%, 45%, 0.6)'),
            ),
          for (final HeroColorChannel channel in <HeroColorChannel>[
            HeroColorChannel.red,
            HeroColorChannel.green,
            HeroColorChannel.blue,
          ])
            HeroColorSlider(
              channel: channel,
              label: channel.label,
              defaultValue: heroParseColor('rgb(255, 100, 50)'),
            ),
          HeroColorSlider(
            channel: HeroColorChannel.brightness,
            label: 'Brightness',
            defaultValue: heroParseColor('hsb(219, 58%, 93%)'),
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'vertical, disabled and no label',
    name: 'color_slider_layouts',
    size: const Size(400, 260),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: <Widget>[
        SizedBox(
          height: 192,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              HeroColorSlider(
                channel: HeroColorChannel.hue,
                orientation: Axis.vertical,
                defaultValue: heroParseColor('hsl(120, 100%, 50%)'),
              ),
              HeroColorSlider(
                channel: HeroColorChannel.saturation,
                orientation: Axis.vertical,
                defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
              ),
              HeroColorSlider(
                channel: HeroColorChannel.lightness,
                orientation: Axis.vertical,
                label: 'L',
                showOutput: true,
                defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: <Widget>[
              HeroColorSlider(
                channel: HeroColorChannel.hue,
                label: 'Hue',
                isDisabled: true,
                defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
              ),
              HeroColorSlider(
                channel: HeroColorChannel.hue,
                defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
              ),
              HeroColorSlider(
                channel: HeroColorChannel.hue,
                showOutput: true,
                defaultValue: heroParseColor('hsl(300, 100%, 50%)'),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'keyboard focus, right to left and custom parts',
    name: 'color_slider_states',
    size: const Size(360, 240),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    },
    builder: (HeroThemeData theme) => SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          HeroColorSlider(
            channel: HeroColorChannel.hue,
            label: 'Hue',
            defaultValue: heroParseColor('hsl(60, 100%, 50%)'),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: HeroColorSlider(
              channel: HeroColorChannel.alpha,
              label: 'Alpha',
              defaultValue: heroParseColor('hsla(0, 100%, 50%, 0.5)'),
            ),
          ),
          HeroColorSlider(
            channel: HeroColorChannel.hue,
            defaultValue: heroParseColor('hsl(220, 70%, 50%)'),
            children: <Widget>[
              HeroLabel.text(
                'Hue',
                style: TextStyle(color: theme.colors.foreground),
              ),
              HeroColorSliderOutput(
                style: TextStyle(color: theme.colors.muted),
              ),
              HeroColorSliderTrack(
                thickness: theme.spacing(4),
                capRadius: theme.radii.sm,
                borderColor: theme.colors.border,
                thumb: HeroColorSliderThumb(
                  borderRadius: BorderRadius.circular(theme.radii.sm),
                  borderWidth: theme.spacing(0.5),
                  borderColor: theme.colors.background,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
