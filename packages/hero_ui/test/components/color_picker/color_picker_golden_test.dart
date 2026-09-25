import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Widget topStart(Widget child) => SizedBox(
    width: 328,
    height: 448,
    child: Align(alignment: AlignmentDirectional.topStart, child: child),
  );

  heroGoldenTest(
    'basic anatomy, open',
    name: 'color_picker_basic',
    size: const Size(360, 480),
    builder: (HeroThemeData theme) => topStart(
      const HeroColorPicker(
        label: 'Pick a color',
        defaultValue: Color(0xFF0485F7),
        defaultOpen: true,
      ),
    ),
  );

  heroGoldenTest(
    'swatches, slider, shuffle and field, open',
    name: 'color_picker_controlled',
    size: const Size(360, 480),
    builder: (HeroThemeData theme) => topStart(
      HeroColorPicker(
        defaultValue: const Color(0xFF325578),
        defaultOpen: true,
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
                  for (final Color color in const <Color>[
                    Color(0xFFEF4444),
                    Color(0xFFF97316),
                    Color(0xFFEAB308),
                    Color(0xFF22C55E),
                    Color(0xFF06B6D4),
                    Color(0xFF3B82F6),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                    Color(0xFFF43F5E),
                  ])
                    HeroColorSwatchPickerItem(
                      color: color,
                      children: const <Widget>[HeroColorSwatchPickerSwatch()],
                    ),
                ],
              ),
            ),
            const HeroColorArea(maxSize: double.infinity),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
              child: Row(
                spacing: theme.spacing(2),
                children: <Widget>[
                  const Expanded(
                    child: HeroColorSlider(
                      channel: HeroColorChannel.hue,
                      colorSpace: HeroColorSpace.hsb,
                      semanticLabel: 'Hue slider',
                    ),
                  ),
                  HeroButton(
                    isIconOnly: true,
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.tertiary,
                    semanticLabel: 'Shuffle color',
                    onPressed: () {},
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
    ),
  );

  heroGoldenTest(
    'custom trigger and keyboard focus, closed',
    name: 'color_picker_trigger',
    size: const Size(320, 220),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    },
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        const HeroColorPicker(
          label: 'Pick a color',
          defaultValue: Color(0xFF0485F7),
        ),
        HeroColorPicker(
          defaultValue: const Color(0xFF0485F7),
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
        ),
        const HeroColorPicker(
          label: 'Disabled',
          isDisabled: true,
          defaultValue: Color(0xFFF43F5E),
        ),
      ],
    ),
  );
}
