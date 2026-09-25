import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/pagination_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('pagination demo renders every example', (
    WidgetTester tester,
  ) async {
    await _pumpDemo(tester, paginationDemo);
    expect(paginationDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Sizes',
      'Disabled',
      'Simple (Previous / Next)',
      'Controlled',
      'With Ellipsis',
      'With Summary',
      'Custom Icons',
      'Customization',
    ]);
    expect(find.text('1 to 5 of 50 invoices'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.text('1 to 5 of 50 invoices'),
          matching: find.byType(HeroPagination),
        ),
        matching: find.text('Next'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('6 to 10 of 50 invoices'), findsOneWidget);
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
