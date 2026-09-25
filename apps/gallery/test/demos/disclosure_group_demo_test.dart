import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/disclosure_group_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('disclosure group demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, disclosureGroupDemo);
    expect(
      disclosureGroupDemo.examples.map((DemoExample e) => e.title),
      <String>['Usage', 'Controlled', 'Customization'],
    );
    expect(find.text('Preview on Expo Go'), findsNWidgets(2));
    await tester.tap(find.bySemanticsLabel('Next disclosure'));
    await tester.pumpAndSettle();
    expect(find.text('Preview on Expo Go'), findsOneWidget);
    await tester.tap(find.text('Download App'));
    await tester.pumpAndSettle();
    expect(find.text('Preview on Expo Go'), findsNothing);
    expect(find.text('Available on iOS and Android devices.'), findsOneWidget);
    await tester.tap(find.text('Support').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Typical response time'), findsOneWidget);
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
