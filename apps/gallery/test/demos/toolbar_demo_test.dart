import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/toolbar_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('toolbar demo renders every example', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        home: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            PlaygroundView(playground: toolbarDemo.playground!),
            for (final DemoExample example in toolbarDemo.examples)
              Center(child: Builder(builder: example.builder)),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(toolbarDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Vertical',
      'Attached',
      'With ButtonGroup',
      'Customization',
    ]);
    for (final DemoExample example in toolbarDemo.examples) {
      expect(example.code, isNotEmpty);
    }
    expect(find.byType(HeroToolbar), findsNWidgets(6));
    expect(find.text('Undo'), findsOneWidget);
    expect(find.byType(HeroToggleButton), findsNWidgets(18));
  });
}
