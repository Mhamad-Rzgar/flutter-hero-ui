import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/toggle_button_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('toggle button demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, toggleButtonDemo);
    expect(toggleButtonDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Variants',
      'Icon Only',
      'Sizes',
      'Disabled',
      'Controlled',
      'Customization',
    ]);
    await tester.tap(find.text('Like').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

/// Pumps the playground and every example of [demo] in a scrolling page.
Future<void> _pumpDemo(WidgetTester tester, ComponentDemo demo) async {
  tester.view.physicalSize = const Size(600, 4000);
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
