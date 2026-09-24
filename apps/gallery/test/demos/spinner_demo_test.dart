import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/spinner_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('spinner demo renders the playground and every example', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final HeroThemeData theme = HeroThemeData.light().copyWith(
      motion: const HeroMotion(reduceMotion: true),
    );
    await tester.pumpWidget(
      HeroApp(
        theme: theme,
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: spinnerDemo.playground!),
              for (final DemoExample example in spinnerDemo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(spinnerDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Colors',
      'Sizes',
      'Speed',
      'Custom Styles',
    ]);
    expect(find.byType(HeroSpinner), findsNWidgets(17));
  });
}
