import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/drawer_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('drawer demo renders every example and opens drawers', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(600, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        theme: HeroThemeData.light(),
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              PlaygroundView(playground: drawerDemo.playground!),
              for (final DemoExample example in drawerDemo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(drawerDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Placement',
      'Non-Dismissable',
      'Scrollable Content',
      'Controlled State',
      'Navigation Drawer',
      'Backdrop Variants',
      'Custom Styles',
    ]);

    for (final String trigger in <String>['Bottom', 'Top', 'Left', 'Right']) {
      await tester.tap(find.text(trigger));
      await tester.pumpAndSettle();
      expect(find.text('$trigger Drawer'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(HeroDrawerDialog), findsNothing);
    }

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    await tester.tap(find.byType(HeroCloseButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Toggle').first);
    await tester.pumpAndSettle();
    expect(find.text('Controlled with setState()'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Status: closed', findRichText: true), findsNWidgets(2));

    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
