import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/switch_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('switch demo renders every example', (WidgetTester tester) async {
    await _pumpDemo(tester, switchDemo);
    expect(switchDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Sizes',
      'With Icons',
      'Disabled',
      'Without Label',
      'With Description',
      'Default Selected',
      'Controlled',
      'Label Position',
      'Group',
      'Group Horizontal',
      'Form Integration',
      'Render Props',
      'Render Function',
      'Customization',
    ]);

    // Controlled: the caption follows the switch.
    expect(find.text('Switch is off'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find
            .ancestor(
              of: find.text('Switch is off'),
              matching: find.byType(Column),
            )
            .first,
        matching: find.byType(HeroSwitchControl),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Switch is on'), findsOneWidget);

    // Render props: the label follows the state.
    await tester.tap(find.text('Disabled').last);
    await tester.pumpAndSettle();
    expect(find.text('Enabled'), findsOneWidget);

    // Form: only switches that are on are submitted.
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Form submitted with:\nnewsletter: on'), findsOneWidget);
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
