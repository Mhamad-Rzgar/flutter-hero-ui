import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// `max-w-xs` sliders stacked with `gap-6`.
Widget _stack(HeroThemeData theme, List<Widget> children) => SizedBox(
  width: theme.spacing(80),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    spacing: theme.spacing(6),
    children: children,
  ),
);

void main() {
  heroGoldenTest(
    'slider values',
    name: 'slider_values',
    size: const Size(360, 360),
    builder: (HeroThemeData theme) => _stack(theme, <Widget>[
      const HeroSlider(defaultValue: 30, label: Text('Volume')),
      const HeroSlider(defaultValue: 0, label: Text('Minimum')),
      const HeroSlider(defaultValue: 100, label: Text('Maximum')),
      HeroSlider.range(
        defaultValues: const <double>[100, 500],
        maxValue: 1000,
        step: 50,
        numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
        label: const Text('Price Range'),
      ),
      const HeroSlider.range(
        defaultValues: <double>[0, 60],
        label: Text('From the minimum'),
      ),
    ]),
  );

  heroGoldenTest(
    'slider states',
    name: 'slider_states',
    size: const Size(360, 150),
    builder: (HeroThemeData theme) => _stack(theme, <Widget>[
      const HeroSlider(
        defaultValue: 30,
        isDisabled: true,
        label: Text('Disabled'),
      ),
      const HeroSlider(defaultValue: 50, label: Text('Focused')),
    ]),
    whilePerforming: (WidgetTester tester) async {
      // Keyboard focus lands on the second slider (the first is disabled).
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    },
  );

  heroGoldenTest(
    'slider dragging',
    name: 'slider_dragging',
    size: const Size(360, 80),
    builder: (HeroThemeData theme) => _stack(theme, const <Widget>[
      HeroSlider(defaultValue: 70, label: Text('Dragging')),
    ]),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(HeroSliderThumb)),
      );
      await gesture.moveBy(const Offset(1, 0));
    },
  );

  heroGoldenTest(
    'slider vertical',
    name: 'slider_vertical',
    size: const Size(240, 300),
    builder: (HeroThemeData theme) => SizedBox(
      height: theme.spacing(64),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(10),
        children: const <Widget>[
          HeroSlider(
            defaultValue: 30,
            orientation: Axis.vertical,
            label: Text('Volume'),
          ),
          HeroSlider.range(
            defaultValues: <double>[20, 100],
            orientation: Axis.vertical,
            label: Text('Range'),
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'slider right-to-left and custom styles',
    name: 'slider_custom',
    size: const Size(360, 170),
    builder: (HeroThemeData theme) => _stack(theme, <Widget>[
      const Directionality(
        textDirection: TextDirection.rtl,
        child: HeroSlider(defaultValue: 30, label: Text('Volume')),
      ),
      HeroSlider(
        defaultValue: 40,
        children: <Widget>[
          HeroLabel.text(
            'Brightness',
            style: TextStyle(color: theme.colors.foreground),
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
    ]),
  );
}
