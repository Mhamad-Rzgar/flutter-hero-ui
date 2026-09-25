import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/list_box_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('list box demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, listBoxDemo);
    expect(listBoxDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'With Disabled Items',
      'With Sections',
      'Multi Select',
      'Controlled',
      'Virtualization',
      'Custom Check Icon',
      'Render Function',
      'Customization',
    ]);
    expect(find.text('Selected: 1'), findsOneWidget);
    await tester.tap(find.text('Fred').at(3));
    await tester.pumpAndSettle();
    expect(find.text('Selected: 1, 2'), findsOneWidget);
    expect(find.text('Emma Smith'), findsOneWidget);
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
