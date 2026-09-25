import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/color_picker_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('color picker demo renders the playground and every example', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ComponentDemo demo = colorPickerDemo;
    await tester.pumpWidget(
      HeroApp(
        debugShowCheckedModeBanner: false,
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: demo.playground!),
              for (final DemoExample example in demo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(HeroColorPicker), findsNWidgets(5));
    expect(demo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Controlled',
      'With Swatches',
      'Customization',
    ]);
    for (final DemoExample example in demo.examples) {
      expect(example.code, isNotEmpty);
    }

    // The controlled example opens, shuffles and reports the color.
    expect(find.text('Selected: #325578', findRichText: true), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byWidgetPredicate(
          (Widget w) => w is HeroColorPicker && w.value != null,
        ),
        matching: find.byType(HeroColorPickerTrigger),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HeroColorArea), findsOneWidget);
    await tester.tap(
      find.byWidgetPredicate(
        (Widget w) => w is HeroButton && w.semanticLabel == 'Shuffle color',
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Selected: #325578', findRichText: true), findsNothing);
  });
}
