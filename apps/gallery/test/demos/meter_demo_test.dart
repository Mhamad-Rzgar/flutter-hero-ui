import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/meter_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('meter demo renders every example', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        home: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            PlaygroundView(playground: meterDemo.playground!),
            for (final DemoExample example in meterDemo.examples)
              Builder(builder: example.builder),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(meterDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Sizes',
      'Colors',
      'Without Label',
      'Custom Value Scale',
      'Customization',
    ]);
    for (final DemoExample example in meterDemo.examples) {
      expect(example.code, isNotEmpty);
    }
    expect(find.byType(HeroMeter), findsNWidgets(13));
    expect(find.text(r'$750.00'), findsOneWidget);
    expect(find.text('68%'), findsOneWidget);
  });
}
