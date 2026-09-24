import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/button_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  Future<void> pumpDemo(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        theme: HeroThemeData.light().copyWith(
          motion: const HeroMotion(reduceMotion: true),
        ),
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: buttonDemo.playground!),
              for (final DemoExample example in buttonDemo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('button demo renders the playground and every example', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);
    expect(tester.takeException(), isNull);
    expect(buttonDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Variants',
      'Sizes',
      'With Icons',
      'Icon Only',
      'Loading',
      'Loading State',
      'Full Width',
      'Disabled State',
      'Social Buttons',
      'Render Function',
      'Adding custom variants',
      'Adding Ripple Effect',
      'Custom Styles',
    ]);
    expect(find.text('Sign in with GitHub'), findsOneWidget);
  });

  testWidgets('loading state example is pending for two seconds', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);
    await tester.tap(find.text('Upload File'));
    await tester.pumpAndSettle();
    expect(find.text('Uploading...'), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Upload File'), findsOneWidget);
  });

  testWidgets('ripple example grows and fades a ripple', (
    WidgetTester tester,
  ) async {
    await pumpDemo(tester);
    final Finder target = find.text('Click me').last;
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(target),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
