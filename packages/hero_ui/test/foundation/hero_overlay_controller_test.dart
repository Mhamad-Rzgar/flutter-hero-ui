import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../helpers/hero_test_app.dart';

void main() {
  test('HeroOverlayController tracks and reports the open state', () {
    final List<bool> changes = <bool>[];
    int notifications = 0;
    final HeroOverlayController controller = HeroOverlayController(
      onOpenChanged: changes.add,
    )..addListener(() => notifications++);
    expect(controller.isOpen, isFalse);
    controller
      ..open()
      ..open()
      ..toggle()
      ..toggle()
      ..close()
      ..setOpen(false);
    expect(changes, <bool>[true, false, true, false]);
    expect(notifications, 4);
    expect(HeroOverlayController(defaultOpen: true).isOpen, isTrue);
    controller.dispose();
  });

  testWidgets('slot close buttons close the nearest dialog scope', (
    WidgetTester tester,
  ) async {
    final List<Object?> closed = <Object?>[];
    int presses = 0;
    await pumpHero(
      tester,
      HeroDialogScope(
        close: ([Object? result]) => closed.add(result),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroButton(
              slot: HeroButtonSlot.close,
              onPressed: () => presses++,
              child: const Text('Close'),
            ),
            HeroButton(onPressed: () => presses++, child: const Text('Other')),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Close'));
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    expect(presses, 2);
    expect(closed, <Object?>[null]);
  });

  testWidgets('slot close buttons outside a dialog only press', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      HeroButton(
        slot: HeroButtonSlot.close,
        onPressed: () => presses++,
        child: const Text('Close'),
      ),
    );
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(presses, 1);
  });

  test('icons do not paint their SVG clip rectangle', () {
    for (final HeroIconData icon in <HeroIconData>[
      HeroIcons.chevronsExpandVertical,
      HeroIcons.rocket,
      HeroIcons.volumeFill,
      HeroIcons.volumeSlashFill,
      HeroIcons.chartColumn,
      HeroIcons.chartLine,
      HeroIcons.chartAreaStacked,
      HeroIcons.chartBar,
      HeroIcons.cloudArrowUpIn,
      HeroIcons.bug,
    ]) {
      expect(
        icon.paths.where((HeroIconPath p) => p.data == 'M0 0h16v16H0z'),
        isEmpty,
      );
    }
  });
}
