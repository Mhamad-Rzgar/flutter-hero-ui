import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/slider_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('slider demo renders every example', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        home: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            PlaygroundView(playground: sliderDemo.playground!),
            for (final DemoExample example in sliderDemo.examples)
              Builder(builder: example.builder),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(sliderDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Disabled',
      'Range Slider Anatomy',
      'Vertical',
      'Range',
      'Render Function',
      'Customization',
      'Basic Usage',
      'Range Slider',
      'Controlled Value',
      'Custom Value Formatting',
      'Vertical Orientation',
      'Custom Output Display',
    ]);
    for (final DemoExample example in sliderDemo.examples) {
      expect(example.code, isNotEmpty);
    }
    expect(find.byType(HeroSlider), findsNWidgets(14));
    expect(find.text(r'$100.00 – $500.00'), findsNWidgets(2));
    expect(find.text(r'$60.00'), findsOneWidget);

    // The controlled example reports its value.
    expect(find.text('Current value: 25'), findsOneWidget);
    final Finder controlled = find.ancestor(
      of: find.text('Current value: 25'),
      matching: find.byType(Column),
    );
    final Finder track = find.descendant(
      of: controlled.first,
      matching: find.byType(HeroSliderTrack),
    );
    final Rect rect = tester.getRect(track);
    await tester.tapAt(
      Offset(rect.left + 12 + 0.5 * (rect.width - 24), rect.center.dy),
    );
    await tester.pumpAndSettle();
    expect(find.text('Current value: 50'), findsOneWidget);
  });
}
