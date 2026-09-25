import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/checkbox_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('checkbox demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, checkboxDemo);
    expect(checkboxDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Variants',
      'Full Rounded',
      'Disabled',
      'External Label',
      'With Description',
      'Default Selected',
      'Invalid',
      'Controlled',
      'Indeterminate',
      'Form Integration',
      'Render Props',
      'Render Function',
      'Custom Indicator',
      'Customization',
    ]);

    // Controlled: the caption follows the checkbox.
    expect(find.text('Status: Enabled', findRichText: true), findsOneWidget);
    await tester.tap(find.text('Email notifications').last);
    await tester.pumpAndSettle();
    expect(find.text('Status: Disabled', findRichText: true), findsOneWidget);

    // Form: only checked boxes are submitted.
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Form submitted with:\nnewsletter: on'), findsOneWidget);

    // External label toggles its checkbox.
    await tester.tap(find.text('Send me marketing emails'));
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
