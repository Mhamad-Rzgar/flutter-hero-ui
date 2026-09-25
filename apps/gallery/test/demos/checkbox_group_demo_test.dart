import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/checkbox_group_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('checkbox group demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, checkboxGroupDemo);
    expect(checkboxGroupDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'In Surface',
      'Disabled',
      'Indeterminate',
      'Controlled',
      'Validation',
      'Features and Add-ons Example',
      'With Custom Indicator',
      'Render Function',
      'Customization',
    ]);

    // Controlled: the caption follows the selection.
    expect(find.text('Selected: coding, design'), findsOneWidget);

    // Validation: submitting without a selection shows the error.
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(
      find.text('Please select at least one notification method.'),
      findsOneWidget,
    );
    await tester.tap(find.text('SMS notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Selected preferences: sms'), findsOneWidget);

    // Indeterminate: "Select all" checks every option.
    await tester.tap(find.text('Select all'));
    await tester.pumpAndSettle();
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
