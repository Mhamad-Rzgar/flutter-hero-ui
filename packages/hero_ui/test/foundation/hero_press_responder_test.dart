import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../helpers/hero_test_app.dart';

void main() {
  testWidgets(
    'forwards taps and keyboard activation of the nearest pressable',
    (WidgetTester tester) async {
      final List<String> log = <String>[];
      await pumpHero(
        tester,
        HeroPressResponder(
          onPressed: () => log.add('responder'),
          child: HeroButton(
            onPressed: () => log.add('button'),
            child: const Text('Trigger'),
          ),
        ),
      );
      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();
      expect(log, <String>['button', 'responder']);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(log, <String>['button', 'responder', 'button', 'responder']);
    },
  );

  testWidgets('a pressable without a handler becomes pressable', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    int presses = 0;
    await pumpHero(
      tester,
      HeroPressResponder(
        onPressed: () => presses++,
        isExpanded: false,
        child: const HeroButton(child: Text('Trigger')),
      ),
    );
    expect(
      tester.getSemantics(find.byType(HeroButton)),
      matchesSemantics(
        label: 'Trigger',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasExpandedState: true,
      ),
    );
    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();
    expect(presses, 1);
    handle.dispose();
  });

  testWidgets('nested pressables and disabled triggers do not respond', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      HeroPressResponder(
        onPressed: () => presses++,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroInteractable(
              onPressed: () {},
              builder: (BuildContext context, HeroInteractionState state, _) =>
                  HeroButton(onPressed: () {}, child: const Text('Inner')),
            ),
            const HeroButton(isDisabled: true, child: Text('Disabled')),
          ],
        ),
      ),
    );
    await tester.tap(find.text('Inner'));
    await tester.tap(find.text('Disabled'), warnIfMissed: false);
    await tester.pumpAndSettle();
    // Only the outer interactable consumes the responder; the inner button
    // does not, and the tap reaches only the inner button.
    expect(presses, 0);
  });

  testWidgets('HeroPressResponder.reset hides an enclosing responder', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      HeroPressResponder(
        onPressed: () => presses++,
        child: const HeroPressResponder.reset(
          child: HeroButton(child: Text('Trigger')),
        ),
      ),
    );
    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();
    expect(presses, 0);
  });
}
