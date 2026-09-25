import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/alert_dialog_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  testWidgets('alert dialog demo renders every example and opens dialogs', (
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
              PlaygroundView(playground: alertDialogDemo.playground!),
              for (final DemoExample example in alertDialogDemo.examples)
                Builder(builder: example.builder),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(alertDialogDemo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Statuses',
      'Placements',
      'Sizes',
      'Controlled State',
      'Custom Icon',
      'Custom Trigger',
      'Backdrop Variants',
      'Custom Backdrop',
      'Dismiss Behavior',
      'Close Methods',
      'Custom Animations',
      'Custom Portal',
      'Custom Styles',
    ]);

    // Usage: Escape and the backdrop do not close it; the action does.
    await tester.tap(find.text('Delete Project'));
    await tester.pumpAndSettle();
    expect(find.text('Delete project permanently?'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Delete project permanently?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(HeroAlertDialogDialog), findsNothing);

    // Statuses.
    for (final String trigger in <String>['Sign Out', 'Complete Task']) {
      await tester.tap(find.text(trigger).first);
      await tester.pumpAndSettle();
      expect(find.byType(HeroAlertDialogIcon), findsWidgets);
      await tester.tap(find.byType(HeroCloseButton));
      await tester.pumpAndSettle();
    }

    // Controlled with the controller.
    await tester.tap(find.text('Toggle').last);
    await tester.pumpAndSettle();
    expect(find.text('Controlled with HeroOverlayController'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Status: closed', findRichText: true), findsNWidgets(2));

    // Custom styles and backdrop.
    await tester.tap(find.text('Sign out').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Stay signed in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Account').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep Account'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
