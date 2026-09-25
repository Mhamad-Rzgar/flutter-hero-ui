import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

HeroThemeData _still() => HeroThemeData.light().copyWith(
  motion: const HeroMotion(reduceMotion: true),
);

Finder _track() => find.byType(HeroProgressCircleTrack);

Finder _rotation() =>
    find.descendant(of: _track(), matching: find.byType(RotationTransition));

void main() {
  testWidgets('renders every size', (WidgetTester tester) async {
    const Map<HeroSize, double> expected = <HeroSize, double>{
      HeroSize.sm: 20,
      HeroSize.md: 28,
      HeroSize.lg: 36,
    };
    for (final MapEntry<HeroSize, double> entry in expected.entries) {
      await pumpHero(tester, HeroProgressCircle(size: entry.key, value: 40));
      expect(tester.getSize(_track()), Size.square(entry.value));
    }
  });

  testWidgets('defaults to md, accent and 0–100', (WidgetTester tester) async {
    const HeroProgressCircle circle = HeroProgressCircle();
    expect(circle.size, HeroSize.md);
    expect(circle.color, HeroColor.accent);
    expect(circle.value, 0);
    expect(circle.minValue, 0);
    expect(circle.maxValue, 100);
    expect(circle.isIndeterminate, isFalse);
    await pumpHero(tester, circle);
    expect(tester.getSize(_track()), const Size.square(28));
    expect(find.byType(HeroProgressCircleTrackCircle), findsOneWidget);
    expect(find.byType(HeroProgressCircleFillCircle), findsOneWidget);
  });

  testWidgets('dimension overrides the size', (WidgetTester tester) async {
    await pumpHero(tester, const HeroProgressCircle(value: 68, dimension: 56));
    expect(tester.getSize(_track()), const Size.square(56));
    await pumpHero(
      tester,
      const HeroProgressCircle(
        value: 68,
        child: HeroProgressCircleTrack(dimension: 48),
      ),
    );
    expect(tester.getSize(_track()), const Size.square(48));
  });

  test('fill colors follow the CSS color variants', () {
    final HeroColors colors = HeroThemeData.light().colors;
    expect(
      HeroProgressCircle.fillColorOf(colors, HeroColor.standard),
      colors.defaultForeground,
    );
    expect(
      HeroProgressCircle.fillColorOf(colors, HeroColor.accent),
      colors.accent,
    );
    expect(
      HeroProgressCircle.fillColorOf(colors, HeroColor.success),
      colors.success,
    );
    expect(
      HeroProgressCircle.fillColorOf(colors, HeroColor.warning),
      colors.warning,
    );
    expect(
      HeroProgressCircle.fillColorOf(colors, HeroColor.danger),
      colors.danger,
    );
  });

  testWidgets('builder receives the percentage and value text', (
    WidgetTester tester,
  ) async {
    final List<HeroProgressCircleState> states = <HeroProgressCircleState>[];
    await pumpHero(
      tester,
      HeroProgressCircle(
        value: 750,
        maxValue: 1000,
        builder: (BuildContext context, HeroProgressCircleState state) {
          states.add(state);
          return const HeroProgressCircleTrack();
        },
      ),
    );
    expect(
      states.last,
      const HeroProgressCircleState(
        percentage: 75,
        valueText: '75%',
        isIndeterminate: false,
      ),
    );

    await pumpHero(
      tester,
      HeroProgressCircle(
        isIndeterminate: true,
        builder: (BuildContext context, HeroProgressCircleState state) {
          states.add(state);
          return const SizedBox();
        },
      ),
      theme: _still(),
    );
    expect(states.last.isIndeterminate, isTrue);
    expect(states.last.valueText, isNull);
    expect(states.last.percentage, 0);
  });

  testWidgets('clamps the value to the range', (WidgetTester tester) async {
    HeroProgressCircleState? state;
    Widget circle(double value) => HeroProgressCircle(
      value: value,
      minValue: 10,
      maxValue: 20,
      builder: (BuildContext context, HeroProgressCircleState s) {
        state = s;
        return const SizedBox();
      },
    );
    await pumpHero(tester, circle(40));
    expect(state!.percentage, 100);
    expect(state!.valueText, '100%');
    await pumpHero(tester, circle(-5));
    expect(state!.percentage, 0);
    await pumpHero(tester, circle(15));
    expect(state!.percentage, 50);
  });

  testWidgets('announces a progress bar with its value', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const HeroProgressCircle(value: 60, semanticLabel: 'Loading'),
    );
    expect(
      tester.getSemantics(find.byType(HeroProgressCircle)),
      matchesSemantics(
        label: 'Loading',
        value: '60%',
        role: SemanticsRole.progressBar,
        minValue: '0',
        maxValue: '100',
      ),
    );

    // A currency value text is announced without the progress bar role,
    // whose value must be a number or a percentage.
    await pumpHero(
      tester,
      HeroProgressCircle(
        value: 750,
        maxValue: 1000,
        numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
        semanticLabel: 'Revenue',
      ),
    );
    expect(
      tester.getSemantics(find.byType(HeroProgressCircle)),
      matchesSemantics(label: 'Revenue', value: r'$750.00'),
    );

    await pumpHero(
      tester,
      const HeroProgressCircle(value: 3, valueLabel: '3 of 4 steps'),
    );
    expect(
      tester.getSemantics(find.byType(HeroProgressCircle)),
      matchesSemantics(value: '3 of 4 steps'),
    );

    await pumpHero(
      tester,
      const HeroProgressCircle(isIndeterminate: true, semanticLabel: 'Loading'),
      theme: _still(),
    );
    expect(
      tester.getSemantics(find.byType(HeroProgressCircle)),
      matchesSemantics(label: 'Loading', role: SemanticsRole.loadingSpinner),
    );
    handle.dispose();
  });

  testWidgets('animates value changes over 300 ms', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const HeroProgressCircle(value: 20));
    await tester.pumpWidget(heroTestApp(const HeroProgressCircle(value: 80)));
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 160));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('value changes are instant under reduced motion', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroProgressCircle(value: 20),
      theme: _still(),
    );
    await tester.pumpWidget(
      heroTestApp(const HeroProgressCircle(value: 80), theme: _still()),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('an indeterminate circle turns once per second', (
    WidgetTester tester,
  ) async {
    expect(HeroMotion.progressSpin, const Duration(seconds: 1));
    await tester.pumpWidget(
      heroTestApp(const HeroProgressCircle(isIndeterminate: true)),
    );
    expect(tester.widget<RotationTransition>(_rotation()).turns.value, 0);
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester.widget<RotationTransition>(_rotation()).turns.value,
      closeTo(0.5, 0.01),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      tester.widget<RotationTransition>(_rotation()).turns.value,
      closeTo(0.75, 0.01),
    );

    // Becoming determinate stops the rotation.
    await tester.pumpWidget(heroTestApp(const HeroProgressCircle(value: 50)));
    await tester.pumpAndSettle();
    expect(_rotation(), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('does not spin under reduced motion', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroProgressCircle(isIndeterminate: true),
      theme: _still(),
    );
    expect(_rotation(), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('disabled circles fade to the disabled opacity', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroProgressCircle(value: 40, isDisabled: true),
    );
    final Opacity opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(HeroProgressCircle),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('custom tracks paint their own geometry', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroProgressCircle(
        value: 60,
        child: HeroProgressCircleTrack(
          strokeWidth: 6,
          children: <Widget>[
            HeroProgressCircleTrackCircle(radius: 15),
            HeroProgressCircleFillCircle(
              radius: 15,
              strokeCap: StrokeCap.butt,
              color: Color(0xFF123456),
            ),
          ],
        ),
      ),
    );
    expect(find.byType(HeroProgressCircleFillCircle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps its size in right-to-left and at 2x text', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroProgressCircle(value: 75, size: HeroSize.lg),
          SizedBox(width: 12),
          HeroLabel.text('75% Complete'),
        ],
      ),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.getSize(_track()), const Size.square(36));
    expect(tester.takeException(), isNull);
  });

  group('HeroRangeFormat', () {
    test('fraction clamps and handles empty ranges', () {
      expect(HeroRangeFormat.fraction(50, 0, 100), 0.5);
      expect(HeroRangeFormat.fraction(150, 0, 100), 1);
      expect(HeroRangeFormat.fraction(-1, 0, 100), 0);
      expect(HeroRangeFormat.fraction(5, 5, 5), 0);
    });

    test('plain renders whole numbers without decimals', () {
      expect(HeroRangeFormat.plain(0), '0');
      expect(HeroRangeFormat.plain(1000), '1000');
      expect(HeroRangeFormat.plain(12.5), '12.5');
    });

    testWidgets('formats progress and slider values', (
      WidgetTester tester,
    ) async {
      late BuildContext context;
      await pumpHero(
        tester,
        Builder(
          builder: (BuildContext c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      expect(
        HeroRangeFormat.progressText(
          context,
          value: 60,
          minValue: 0,
          maxValue: 100,
        ),
        '60%',
      );
      expect(
        HeroRangeFormat.progressText(
          context,
          value: 250,
          minValue: 0,
          maxValue: 1000,
          format: NumberFormat.percentPattern(),
        ),
        '25%',
      );
      expect(
        HeroRangeFormat.progressText(
          context,
          value: 750,
          minValue: 0,
          maxValue: 1000,
          format: NumberFormat.simpleCurrency(name: 'USD'),
        ),
        r'$750.00',
      );
      expect(HeroRangeFormat.valueText(context, 30), '30');
      expect(HeroRangeFormat.valueText(context, 1250.5), '1,250.5');
      expect(HeroRangeFormat.localeOf(context), 'en_US');
    });
  });
}
