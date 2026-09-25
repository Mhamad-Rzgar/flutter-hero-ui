import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/alert_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // The processing alert's spinner turns forever; reduced motion lets the
  // test settle.
  await tester.pumpWidget(
    HeroApp(
      theme: HeroThemeData.light().copyWith(
        motion: const HeroMotion(reduceMotion: true),
      ),
      home: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          PlaygroundView(playground: alertDemo.playground!),
          for (final DemoExample example in alertDemo.examples)
            Builder(builder: example.builder),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('alert demo renders every example', (WidgetTester tester) async {
    await _pump(tester, const Size(400, 3000));
    expect(alertDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Customization',
    ]);
    for (final DemoExample example in alertDemo.examples) {
      expect(example.code, isNotEmpty);
    }
    expect(find.byType(HeroAlert), findsNWidgets(8));
    expect(find.text('Unable to connect to server'), findsOneWidget);
    expect(find.text('•  Refresh the page'), findsOneWidget);

    // Below `sm` the action sits under the text, inside the content.
    expect(
      find.descendant(
        of: find.byType(HeroAlertContent),
        matching: find.text('Refresh'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('from sm up the actions follow the content', (
    WidgetTester tester,
  ) async {
    await _pump(tester, const Size(700, 3000));
    expect(
      find.descendant(
        of: find.byType(HeroAlertContent),
        matching: find.text('Refresh'),
      ),
      findsNothing,
    );
    expect(find.text('Refresh'), findsOneWidget);
  });
}
