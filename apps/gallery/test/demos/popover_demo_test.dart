import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/popover_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('popover demo renders every example and opens popovers', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        theme: HeroThemeData.light(),
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: popoverDemo.playground!),
              for (final DemoExample example in popoverDemo.examples)
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
    expect(popoverDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'With Arrow',
      'Interactive Content',
      'Placement',
      'Render Function',
      'Custom Styles',
    ]);
    for (final DemoExample example in popoverDemo.examples) {
      expect(example.code, isNotEmpty);
    }

    Future<void> close() async {
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('With Arrow'));
    await tester.pumpAndSettle();
    expect(find.byType(HeroOverlayArrow), findsOneWidget);
    await close();

    // The profile card stays open while its button toggles.
    await tester.tap(find.text('Sarah Johnson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();
    expect(find.text('Following'), findsOneWidget);
    await close();

    await tester.tap(find.text('Left'));
    await tester.pumpAndSettle();
    expect(find.text('Left placement'), findsOneWidget);
    await close();

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    await close();
    expect(find.text('Keyboard shortcuts'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
