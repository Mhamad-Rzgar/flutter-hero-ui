import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/color_swatch_picker_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets(
    'color swatch picker demo renders the playground and every example',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final ComponentDemo demo = colorSwatchPickerDemo;
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
      expect(find.byType(HeroColorSwatchPicker), findsWidgets);
      expect(demo.examples.map((DemoExample e) => e.title), <String>[
        'Usage',
        'Variants',
        'Sizes',
        'Disabled',
        'Stack Layout',
        'Default Value',
        'Controlled',
        'Custom Indicator',
        'Render Function',
        'Customization',
      ]);
      // The controlled example reports the selection.
      expect(
        find.text('Selected: #F43F5E', findRichText: true),
        findsOneWidget,
      );
      for (final DemoExample example in demo.examples) {
        expect(example.code, isNotEmpty);
      }
    },
  );
}
