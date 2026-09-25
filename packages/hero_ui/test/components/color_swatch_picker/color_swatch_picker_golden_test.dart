import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<Color> _palette = <Color>[
  Color(0xFFF43F5E),
  Color(0xFFD946EF),
  Color(0xFF8B5CF6),
  Color(0xFF3B82F6),
  Color(0xFF06B6D4),
  Color(0xFF10B981),
  Color(0xFF84CC16),
];

void main() {
  heroGoldenTest(
    'sizes with a selection',
    name: 'color_swatch_picker_sizes',
    size: const Size(400, 300),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroColorSwatchSize size in HeroColorSwatchSize.values)
          HeroColorSwatchPicker(
            colors: _palette,
            size: size,
            defaultValue: _palette[2],
          ),
      ],
    ),
  );

  heroGoldenTest(
    'square variant, custom indicator and light colors',
    name: 'color_swatch_picker_variants',
    size: const Size(400, 240),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        HeroColorSwatchPicker(
          colors: _palette,
          variant: HeroColorSwatchShape.square,
          defaultValue: _palette[2],
        ),
        HeroColorSwatchPicker(
          colors: _palette,
          variant: HeroColorSwatchShape.square,
          size: HeroColorSwatchSize.sm,
          defaultValue: _palette[2],
        ),
        HeroColorSwatchPicker(
          defaultValue: _palette[0],
          children: <HeroColorSwatchPickerItem>[
            for (final Color color in _palette)
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
        const HeroColorSwatchPicker(
          colors: <Color>[
            Color(0xFFFDE047),
            Color(0xFFFFFFFF),
            Color(0x803B82F6),
            Color(0xFF18181B),
          ],
          defaultValue: Color(0xFFFDE047),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'disabled, stack layout and keyboard focus',
    name: 'color_swatch_picker_states',
    size: const Size(400, 240),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    },
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: <Widget>[
            HeroColorSwatchPicker(
              colors: _palette.take(4).toList(),
              defaultValue: _palette[0],
            ),
            HeroColorSwatchPicker(
              defaultValue: _palette[1],
              children: <HeroColorSwatchPickerItem>[
                for (final Color color in _palette.take(4))
                  HeroColorSwatchPickerItem(color: color, isDisabled: true),
              ],
            ),
          ],
        ),
        HeroColorSwatchPicker(
          colors: _palette.take(4).toList(),
          layout: HeroColorSwatchPickerLayout.stack,
          defaultValue: _palette[3],
        ),
      ],
    ),
  );
}
