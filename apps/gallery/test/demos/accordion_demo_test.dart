import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/accordion_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('accordion demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, accordionDemo);
    expect(accordionDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Surface',
      'Without Separator',
      'Multiple Expanded',
      'Disabled State',
      'Controlled',
      'Custom Indicator',
      'Render Function',
      'FAQ Layout',
      'Customization',
    ]);
    expect(
      find.textContaining('Expanded: getting-started', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel('Next item'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Expanded: core-concepts', findRichText: true),
      findsOneWidget,
    );
    await tester.tap(find.text('Using Plus/Minus Icon'));
    await tester.pumpAndSettle();
    expect(find.textContaining('rotates 45 degrees'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDemo(WidgetTester tester, ComponentDemo demo) async {
  tester.view.physicalSize = const Size(600, 8000);
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
