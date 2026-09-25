import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/tooltip_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('tooltip demo renders every example and shows tooltips', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        theme: HeroThemeData.light(),
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: tooltipDemo.playground!),
              for (final DemoExample example in tooltipDemo.examples)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Builder(builder: example.builder),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tooltipDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Placement',
      'With Arrow',
      'Custom Triggers',
      'Render Function',
      'Custom Styles',
    ]);
    for (final DemoExample example in tooltipDemo.examples) {
      expect(example.code, isNotEmpty);
    }

    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    Future<void> hover(Finder finder) async {
      await mouse.moveTo(tester.getCenter(finder));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
    }

    await hover(find.text('Left'));
    expect(find.text('Left placement'), findsOneWidget);
    await hover(find.text('Custom Offset'));
    expect(find.text('Custom offset from trigger'), findsOneWidget);
    expect(find.text('Left placement'), findsNothing);
    await hover(find.text('Active'));
    expect(find.text('Jane is currently online'), findsOneWidget);
    await hover(find.text('Share link'));
    expect(find.text('Copied to clipboard'), findsOneWidget);

    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(find.text('Copied to clipboard'), findsNothing);
    await tester.pump(HeroTooltip.warmUpCooldown);
    expect(tester.takeException(), isNull);
  });
}
