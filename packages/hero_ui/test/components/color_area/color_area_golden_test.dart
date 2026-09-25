import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Widget area(
    String color, {
    HeroColorSpace? space,
    HeroColorChannel? x,
    HeroColorChannel? y,
  }) => HeroColorArea(
    size: 112,
    defaultValue: heroParseColor(color),
    colorSpace: space,
    xChannel: x,
    yChannel: y,
  );

  heroGoldenTest(
    'channel pairs',
    name: 'color_area_channels',
    size: const Size(420, 300),
    builder: (HeroThemeData theme) => Wrap(
      spacing: 16,
      runSpacing: 16,
      children: <Widget>[
        area('hsb(219, 58%, 93%)'),
        area(
          'hsl(200, 60%, 40%)',
          space: HeroColorSpace.hsl,
          x: HeroColorChannel.saturation,
          y: HeroColorChannel.lightness,
        ),
        area(
          'rgb(116, 52, 255)',
          space: HeroColorSpace.rgb,
          x: HeroColorChannel.red,
          y: HeroColorChannel.green,
        ),
        area(
          'hsb(120, 70%, 80%)',
          space: HeroColorSpace.hsb,
          x: HeroColorChannel.hue,
          y: HeroColorChannel.saturation,
        ),
        area(
          'hsb(300, 70%, 80%)',
          space: HeroColorSpace.hsb,
          x: HeroColorChannel.hue,
          y: HeroColorChannel.brightness,
        ),
        area(
          'hsl(40, 90%, 30%)',
          space: HeroColorSpace.hsl,
          x: HeroColorChannel.lightness,
          y: HeroColorChannel.hue,
        ),
      ],
    ),
  );

  heroGoldenTest(
    'dots, disabled, custom styles and focus',
    name: 'color_area_states',
    size: const Size(440, 220),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    },
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        HeroColorArea(
          size: 120,
          showDots: true,
          defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
        ),
        HeroColorArea(
          size: 120,
          isDisabled: true,
          defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
        ),
        HeroColorArea(
          size: 120,
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          defaultValue: heroParseColor('rgb(116, 52, 255)'),
          thumb: HeroColorAreaThumb(
            size: theme.spacing(5),
            borderWidth: theme.spacing(1),
            borderRadius: BorderRadius.circular(theme.radii.full),
          ),
        ),
      ],
    ),
  );
}
