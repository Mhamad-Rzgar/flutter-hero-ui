import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/modal_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('modal demo renders every example and opens modals', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        theme: HeroThemeData.light(),
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: modalDemo.playground!),
              for (final DemoExample example in modalDemo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(modalDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Sizes',
      'Placement',
      'Controlled State',
      'Custom Trigger',
      'Backdrop Variants',
      'Custom Backdrop',
      'Dismiss Behavior',
      'Close Methods',
      'Custom Animations',
      'Custom Portal',
      'Custom Styles',
    ]);

    // Usage: open and close with the full-width Continue button.
    await tester.tap(find.text('Open Modal').at(1));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to HeroUI'), findsWidgets);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(HeroModalDialog), findsNothing);

    // Controlled with setState: the status follows the modal.
    expect(find.text('Status: closed', findRichText: true), findsNWidgets(2));
    await tester.tap(find.text('Toggle').first);
    await tester.pumpAndSettle();
    expect(find.text('Controlled with setState()'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Status: closed', findRichText: true), findsNWidgets(2));

    // Controller-driven modal.
    await tester.tap(find.text('Toggle').last);
    await tester.pumpAndSettle();
    expect(find.text('Controlled with HeroOverlayController'), findsOneWidget);
    await tester.tap(find.byType(HeroCloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(HeroModalDialog), findsNothing);

    // Every size opens.
    for (final String size in <String>['Xs', 'Cover', 'Full']) {
      await tester.tap(find.text(size));
      await tester.pumpAndSettle();
      expect(find.text('Size: $size'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
    }

    // Custom animations and styles open without errors.
    await tester.tap(find.text('Kinematic Scale'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Changes saved'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
