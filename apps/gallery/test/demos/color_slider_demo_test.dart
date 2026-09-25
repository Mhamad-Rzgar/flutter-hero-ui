import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/color_slider_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('color slider demo renders the playground and every example', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ComponentDemo demo = colorSliderDemo;
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
    expect(find.byType(HeroColorSlider), findsWidgets);
    expect(demo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Disabled',
      'Vertical',
      'Controlled',
      'HSL Channels',
      'Alpha Channel',
      'RGB Channels',
      'Render Function',
      'Customization',
    ]);
    expect(
      find.text('Current color: hsl(200, 100%, 50%)', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text('Current color: rgb(255, 100, 50)', findRichText: true),
      findsOneWidget,
    );
    for (final DemoExample example in demo.examples) {
      expect(example.code, isNotEmpty);
    }
  });
}
