import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/radio_group_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('radio group demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, radioGroupDemo);
    expect(radioGroupDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Horizontal Orientation',
      'Variants',
      'In Surface',
      'Disabled',
      'Controlled',
      'Uncontrolled',
      'Validation',
      'Delivery & Payment',
      'Custom Indicator',
      'Render Function',
      'Customization',
    ]);

    // Controlled: the caption follows the selection.
    expect(find.text('Selected plan: pro', findRichText: true), findsOneWidget);

    // Validation: submitting without a selection shows the error, then
    // submits the chosen plan.
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(
      find.text('Choose a subscription before continuing.'),
      findsOneWidget,
    );
    final Finder validation = find.ancestor(
      of: find.text('Choose a subscription before continuing.'),
      matching: find.byType(HeroRadioGroup),
    );
    await tester.tap(
      find.descendant(of: validation, matching: find.text('Teams')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Your chosen plan is: teams'), findsOneWidget);

    // Delivery: a card radio is selectable.
    await tester.tap(find.text('Super Fast'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDemo(WidgetTester tester, ComponentDemo demo) async {
  tester.view.physicalSize = const Size(600, 6000);
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
