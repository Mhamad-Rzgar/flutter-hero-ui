import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/tag_group_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('tag group demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, tagGroupDemo);
    expect(tagGroupDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Sizes',
      'Variants',
      'Disabled',
      'Selection Modes',
      'Controlled',
      'With List Data',
      'With Prefix',
      'With Remove Button',
      'Render Function',
      'Customization',
    ]);
    expect(find.text('Selected: news, travel'), findsOneWidget);
    await tester.tap(find.text('Gaming').at(11));
    await tester.pumpAndSettle();
    expect(find.text('Selected: news, travel, gaming'), findsOneWidget);
    // Removing every framework shows the empty state.
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.byType(HeroTagRemoveButton).last);
      await tester.pumpAndSettle();
    }
    expect(find.text('No frameworks found'), findsOneWidget);
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
