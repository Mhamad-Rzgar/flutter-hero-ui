import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/tabs_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('tabs demo renders every example', (WidgetTester tester) async {
    await _pumpDemo(tester, tabsDemo);
    expect(tabsDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Vertical',
      'Overflow',
      'Disabled Tab',
      'With Separator',
      'Secondary Variant',
      'Secondary Variant Vertical',
      'Alignment',
      'Render Function',
      'Customization',
    ]);
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    expect(find.text('Save 20% with annual billing.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDemo(WidgetTester tester, ComponentDemo demo) async {
  tester.view.physicalSize = const Size(600, 5000);
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
