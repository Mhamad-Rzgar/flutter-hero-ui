import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/progress_circle_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('progress circle demo renders every example', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Indeterminate circles spin forever; reduced motion lets the test
    // settle.
    final HeroThemeData theme = HeroThemeData.light().copyWith(
      motion: const HeroMotion(reduceMotion: true),
    );
    await tester.pumpWidget(
      HeroApp(
        theme: theme,
        home: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            PlaygroundView(playground: progressCircleDemo.playground!),
            for (final DemoExample example in progressCircleDemo.examples)
              Builder(builder: example.builder),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      progressCircleDemo.examples.map((DemoExample e) => e.title),
      <String>[
        'Usage',
        'Sizes',
        'Colors',
        'Indeterminate',
        'With Label',
        'Custom SVG Props',
        'Customization',
      ],
    );
    for (final DemoExample example in progressCircleDemo.examples) {
      expect(example.code, isNotEmpty);
    }
    expect(find.byType(HeroProgressCircle), findsNWidgets(16));
    expect(find.text('75% Complete'), findsOneWidget);
  });
}
