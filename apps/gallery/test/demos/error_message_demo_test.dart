import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/error_message_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('error message demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, errorMessageDemo);
    expect(errorMessageDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Customization',
    ]);
    Finder error(String text) => find.descendant(
      of: find.byType(HeroErrorMessage),
      matching: find.text(text),
    );
    // The playground shows the same text as the first example.
    expect(error('Please select at least one category'), findsNWidgets(2));
    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();
    expect(error('Please select at least one category'), findsOneWidget);
    expect(error('Choose at least one topic'), findsOneWidget);
    await tester.tap(find.text('Docs'));
    await tester.pumpAndSettle();
    expect(error('Choose at least one topic'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDemo(WidgetTester tester, ComponentDemo demo) async {
  tester.view.physicalSize = const Size(600, 2000);
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
