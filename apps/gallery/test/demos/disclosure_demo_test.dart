import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/disclosure_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('disclosure demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, disclosureDemo);
    expect(disclosureDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Render Function',
      'Customization',
    ]);
    expect(
      find.text('Expo must be installed on your device.'),
      findsNWidgets(2),
    );
    await tester.tap(find.text('Preview HeroUI Native').first);
    await tester.pumpAndSettle();
    expect(find.text('Expo must be installed on your device.'), findsOneWidget);
    expect(
      find.textContaining('Orders ship within 2 business days.'),
      findsNothing,
    );
    await tester.tap(find.text('Shipping details').last);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('express is available at checkout'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDemo(WidgetTester tester, ComponentDemo demo) async {
  tester.view.physicalSize = const Size(600, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    HeroApp(
      home: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          if (demo.playground != null)
            PlaygroundView(playground: demo.playground!),
          for (final DemoExample example in demo.examples) ...<Widget>[
            Text(example.title),
            Builder(builder: example.builder),
          ],
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  for (final DemoExample example in demo.examples) {
    expect(example.code, isNotEmpty);
  }
}
