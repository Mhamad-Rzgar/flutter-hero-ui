import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/toast_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('toast demo renders every example and shows toasts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        theme: HeroThemeData.light(),
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: toastDemo.playground!),
              for (final DemoExample example in toastDemo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(toastDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Variants',
      'Placements',
      'Expanded Stack',
      'Simple Toasts',
      'Custom Indicators',
      'Custom Toast Rendering',
      'Promise & Loading',
      'Callbacks',
      'Custom Queues',
      'Custom Styles',
    ]);

    // One app-wide region renders the default queue once.
    await tester.tap(find.text('Success'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Operation completed'), findsOneWidget);

    await tester.tap(find.text('Danger toast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Storage is full'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Storage is full'), findsNothing);

    await tester.tap(find.text('top end'));
    await tester.tap(find.text('Show 3 toasts'));
    await tester.tap(find.text('Custom toast'));
    await tester.tap(find.text('Fetch user'));
    await tester.tap(find.text('Persistent toast'));
    await tester.tap(find.text('Add error (max 3)'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Event created'), findsOneWidget);
    expect(find.text('Custom layout toast'), findsOneWidget);
    expect(find.text('Loading user...'), findsOneWidget);
    expect(find.text('Error occurred'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Welcome back, John Doe!'), findsOneWidget);

    // Let every countdown and exit finish.
    heroToast.clear();
    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();
    expect(
      find.text('No toasts closed yet. Try closing one above!'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
