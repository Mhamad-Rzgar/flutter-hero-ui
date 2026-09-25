import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/button_group_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('button group demo renders the playground and every example', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        theme: HeroThemeData.light(),
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: buttonGroupDemo.playground!),
              for (final DemoExample example in buttonGroupDemo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(buttonGroupDemo.examples.map((DemoExample e) => e.title), <String>[
      'Variants',
      'Sizes',
      'Orientation',
      'With Icons',
      'Full Width',
      'Disabled State',
      'Without Separator',
    ]);
    expect(find.text('Third (enabled)'), findsOneWidget);
  });
}
