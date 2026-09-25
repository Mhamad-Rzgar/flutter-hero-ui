import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../helpers/hero_test_app.dart';

void main() {
  testWidgets('of reports the nearest scope, and nested scopes stay disabled', (
    WidgetTester tester,
  ) async {
    final List<bool> seen = <bool>[];
    Widget probe() => Builder(
      builder: (BuildContext context) {
        seen.add(HeroDisabledScope.of(context));
        return const SizedBox();
      },
    );
    await pumpHero(tester, probe());
    await pumpHero(tester, HeroDisabledScope(child: probe()));
    await pumpHero(
      tester,
      HeroDisabledScope(
        isDisabled: false,
        child: HeroDisabledScope(isDisabled: false, child: probe()),
      ),
    );
    await pumpHero(
      tester,
      HeroDisabledScope(
        child: HeroDisabledScope(isDisabled: false, child: probe()),
      ),
    );
    expect(seen, <bool>[false, true, false, true]);
  });

  testWidgets('interactables inside a disabled scope ignore presses', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    HeroInteractionState? last;
    Widget build({required bool disabled}) => HeroDisabledScope(
      isDisabled: disabled,
      child: HeroInteractable(
        onPressed: () => presses++,
        builder: (BuildContext context, HeroInteractionState state, _) {
          last = state;
          return const SizedBox(width: 40, height: 40);
        },
      ),
    );

    await pumpHero(tester, build(disabled: true));
    expect(last!.isDisabled, isTrue);
    await tester.tap(find.byType(HeroInteractable), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(presses, 0);

    await pumpHero(tester, build(disabled: false));
    expect(last!.isDisabled, isFalse);
    await tester.tap(find.byType(HeroInteractable));
    await tester.pumpAndSettle();
    expect(presses, 1);
  });
}
