import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/scroll_shadow_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('scroll shadow demo renders every example', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        debugShowCheckedModeBanner: false,
        // A Column builds every example (a ListView would skip those outside
        // the viewport).
        home: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 24,
            children: <Widget>[
              PlaygroundView(playground: scrollShadowDemo.playground!),
              for (final DemoExample example in scrollShadowDemo.examples)
                Center(child: Builder(builder: example.builder)),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(scrollShadowDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Orientation',
      'Shadow Size',
      'With Card',
      'Hide Scroll Bar',
      'Visibility Change',
      'Customization',
    ]);
    for (final DemoExample example in scrollShadowDemo.examples) {
      expect(example.code, isNotEmpty);
    }
    expect(find.byType(HeroScrollShadow), findsWidgets);
    // The status boxes show the reported visibility.
    expect(find.text('Vertical Shadow State: bottom'), findsOneWidget);
    expect(find.text('Horizontal Shadow State: right'), findsOneWidget);
  });
}
