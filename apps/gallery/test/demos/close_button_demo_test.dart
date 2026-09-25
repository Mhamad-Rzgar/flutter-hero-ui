import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/close_button_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('close button demo renders and counts presses', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        theme: HeroThemeData.light(),
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: closeButtonDemo.playground!),
              for (final DemoExample example in closeButtonDemo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(closeButtonDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Interactive',
      'With Custom Icon',
      'Custom Styles',
    ]);
    expect(find.text('Clicked: 0 times'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close (clicked 0 times)'));
    await tester.pumpAndSettle();
    expect(find.text('Clicked: 1 times'), findsOneWidget);
  });
}
