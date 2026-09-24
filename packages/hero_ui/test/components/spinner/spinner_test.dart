import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// A theme whose motion is reduced, so spinners stand still and
/// `pumpAndSettle` completes.
HeroThemeData _still() => HeroThemeData.light().copyWith(
  motion: const HeroMotion(reduceMotion: true),
);

double _turns(WidgetTester tester) => tester
    .widget<RotationTransition>(
      find.descendant(
        of: find.byType(HeroSpinner),
        matching: find.byType(RotationTransition),
      ),
    )
    .turns
    .value;

void main() {
  testWidgets('renders every size', (WidgetTester tester) async {
    const Map<HeroSpinnerSize, double> expected = <HeroSpinnerSize, double>{
      HeroSpinnerSize.sm: 16,
      HeroSpinnerSize.md: 24,
      HeroSpinnerSize.lg: 32,
      HeroSpinnerSize.xl: 40,
    };
    for (final MapEntry<HeroSpinnerSize, double> entry in expected.entries) {
      await pumpHero(tester, HeroSpinner(size: entry.key), theme: _still());
      expect(
        tester.getSize(find.byType(HeroSpinner)),
        Size.square(entry.value),
      );
    }
  });

  testWidgets('defaults to md and accent', (WidgetTester tester) async {
    const HeroSpinner spinner = HeroSpinner();
    expect(spinner.size, HeroSpinnerSize.md);
    expect(spinner.color, HeroSpinnerColor.accent);
    expect(spinner.period, const Duration(milliseconds: 750));
    await pumpHero(tester, spinner, theme: _still());
    expect(tester.getSize(find.byType(HeroSpinner)), const Size.square(24));
  });

  testWidgets('rotates once per period', (WidgetTester tester) async {
    await tester.pumpWidget(heroTestApp(const HeroSpinner()));
    expect(_turns(tester), 0);
    await tester.pump(const Duration(milliseconds: 375));
    expect(_turns(tester), closeTo(0.5, 0.01));
    await tester.pump(const Duration(milliseconds: 375));
    expect(_turns(tester), closeTo(0, 0.01));
    // Removing the spinner disposes its controller.
    await tester.pumpWidget(heroTestApp(const SizedBox()));
  });

  testWidgets('a custom period changes the speed', (WidgetTester tester) async {
    await tester.pumpWidget(
      heroTestApp(const HeroSpinner(period: Duration(milliseconds: 1500))),
    );
    await tester.pump(const Duration(milliseconds: 375));
    expect(_turns(tester), closeTo(0.25, 0.01));

    await tester.pumpWidget(
      heroTestApp(const HeroSpinner(period: Duration(milliseconds: 400))),
    );
    // The turn continues from where it was, now four times as fast.
    await tester.pump(const Duration(milliseconds: 100));
    expect(_turns(tester), closeTo(0.5, 0.01));
    await tester.pumpWidget(heroTestApp(const SizedBox()));
  });

  testWidgets('stands still under reduced motion', (WidgetTester tester) async {
    await pumpHero(tester, const HeroSpinner(), theme: _still());
    expect(
      find.descendant(
        of: find.byType(HeroSpinner),
        matching: find.byType(RotationTransition),
      ),
      findsNothing,
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('honours the platform reduce-motion setting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      heroTestApp(
        Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const HeroSpinner(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('announces a loading status', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, const HeroSpinner(), theme: _still());
    expect(
      tester.getSemantics(find.byType(HeroSpinner)),
      matchesSemantics(label: 'Loading', isLiveRegion: true),
    );
    await pumpHero(
      tester,
      const HeroSpinner(semanticLabel: 'Saving'),
      theme: _still(),
    );
    expect(
      tester.getSemantics(find.byType(HeroSpinner)),
      matchesSemantics(label: 'Saving', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('keeps its size in right-to-left and at 2x text', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroSpinner(size: HeroSpinnerSize.lg),
      theme: _still(),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.getSize(find.byType(HeroSpinner)), const Size.square(32));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dimensionOf follows the spacing scale', (
    WidgetTester tester,
  ) async {
    final HeroThemeData theme = HeroThemeData.light();
    expect(HeroSpinner.dimensionOf(theme, HeroSpinnerSize.sm), 16);
    expect(HeroSpinner.dimensionOf(theme, HeroSpinnerSize.xl), 40);
  });
}
