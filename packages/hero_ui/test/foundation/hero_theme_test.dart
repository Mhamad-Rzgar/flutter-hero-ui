import 'package:flutter/material.dart' show Theme, ThemeData, ThemeExtension;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  testWidgets('HeroTheme.of falls back to the default light theme', (
    WidgetTester tester,
  ) async {
    late HeroThemeData data;
    await tester.pumpWidget(
      Builder(
        builder: (BuildContext context) {
          data = HeroTheme.of(context);
          return const SizedBox();
        },
      ),
    );
    expect(data.brightness, Brightness.light);
    expect(data.colors, HeroColors.light);
  });

  testWidgets('HeroTheme.of reads the nearest HeroTheme', (
    WidgetTester tester,
  ) async {
    late HeroThemeData data;
    await tester.pumpWidget(
      HeroTheme(
        data: HeroThemeData.light(),
        child: HeroTheme(
          data: HeroThemeData.dark(),
          child: Builder(
            builder: (BuildContext context) {
              data = HeroTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(data.isDark, isTrue);
  });

  testWidgets('HeroTheme.of reads a Material theme extension', (
    WidgetTester tester,
  ) async {
    late HeroThemeData data;
    await tester.pumpWidget(
      Theme(
        data: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            HeroThemeData.dark(),
          ],
        ),
        child: Builder(
          builder: (BuildContext context) {
            data = HeroTheme.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(data.isDark, isTrue);
  });

  test('lerp and copyWith', () {
    final HeroThemeData light = HeroThemeData.light();
    final HeroThemeData dark = HeroThemeData.dark();
    expect(light.lerp(dark, 0).colors, light.colors);
    expect(light.lerp(dark, 1).colors, dark.colors);
    expect(light.lerp(dark, 1).brightness, Brightness.dark);
    expect(light.copyWith(borderWidth: 2).borderWidth, 2);
    expect(light.copyWith(borderWidth: 2).colors, light.colors);
    expect(light, HeroThemeData.light());
  });

  testWidgets('density adapts at the md breakpoint', (
    WidgetTester tester,
  ) async {
    late HeroDensity density;
    Widget probe() => Builder(
      builder: (BuildContext context) {
        density = HeroTheme.of(context).resolveDensity(context);
        return const SizedBox();
      },
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(390, 800)),
        child: probe(),
      ),
    );
    expect(density, HeroDensity.touch);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1024, 800)),
        child: probe(),
      ),
    );
    expect(density, HeroDensity.desktop);
  });

  test('corner style selects the border type', () {
    final HeroThemeData theme = HeroThemeData.light();
    expect(theme.shapeAll(12), isA<RoundedSuperellipseBorder>());
    expect(
      theme.copyWith(cornerStyle: HeroCornerStyle.circular).shapeAll(12),
      isA<RoundedRectangleBorder>(),
    );
  });

  testWidgets('AnimatedHeroTheme animates between themes', (
    WidgetTester tester,
  ) async {
    late HeroThemeData data;
    Widget build(HeroThemeData theme) => AnimatedHeroTheme(
      data: theme,
      duration: const Duration(milliseconds: 100),
      child: Builder(
        builder: (BuildContext context) {
          data = HeroTheme.of(context);
          return const SizedBox();
        },
      ),
    );
    await tester.pumpWidget(build(HeroThemeData.light()));
    await tester.pumpWidget(build(HeroThemeData.dark()));
    await tester.pump(const Duration(milliseconds: 50));
    expect(data.colors.background, isNot(HeroColors.light.background));
    expect(data.colors.background, isNot(HeroColors.dark.background));
    await tester.pumpAndSettle();
    expect(data.colors.background, HeroColors.dark.background);
  });
}
