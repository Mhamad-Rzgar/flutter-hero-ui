import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  Widget probe(void Function(BuildContext context) onBuild) => Builder(
    builder: (BuildContext context) {
      onBuild(context);
      return const Text('home');
    },
  );

  testWidgets('HeroApp provides the light or dark theme', (
    WidgetTester tester,
  ) async {
    late HeroThemeData data;
    await tester.pumpWidget(
      HeroApp(
        themeMode: HeroThemeMode.dark,
        home: probe((BuildContext c) => data = HeroTheme.of(c)),
      ),
    );
    await tester.pumpAndSettle();
    expect(data.isDark, isTrue);

    await tester.pumpWidget(
      HeroApp(
        themeMode: HeroThemeMode.light,
        home: probe((BuildContext c) => data = HeroTheme.of(c)),
      ),
    );
    await tester.pumpAndSettle();
    expect(data.isDark, isFalse);
  });

  testWidgets('system mode follows the platform brightness', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    late HeroThemeData data;
    await tester.pumpWidget(
      HeroApp(home: probe((BuildContext c) => data = HeroTheme.of(c))),
    );
    await tester.pumpAndSettle();
    expect(data.isDark, isTrue);
  });

  testWidgets('default text style and icon theme come from tokens', (
    WidgetTester tester,
  ) async {
    late TextStyle style;
    late IconThemeData icons;
    await tester.pumpWidget(
      HeroApp(
        themeMode: HeroThemeMode.light,
        home: probe((BuildContext c) {
          style = DefaultTextStyle.of(c).style;
          icons = IconTheme.of(c);
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(style.color, HeroColors.light.foreground);
    expect(style.fontSize, 16);
    expect(icons.color, HeroColors.light.foreground);
    expect(icons.size, 16);
  });

  testWidgets('HeroPageRoute paints the background token behind the page', (
    WidgetTester tester,
  ) async {
    final GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      HeroApp(
        navigatorKey: navigator,
        themeMode: HeroThemeMode.dark,
        home: const Text('home'),
      ),
    );
    await tester.pumpAndSettle();
    navigator.currentState!
        .push(HeroPageRoute<void>(builder: (_) => const Text('details')))
        .ignore();
    await tester.pumpAndSettle();
    final ColoredBox page = tester.widget<ColoredBox>(
      find
          .ancestor(of: find.text('details'), matching: find.byType(ColoredBox))
          .first,
    );
    expect(page.color, HeroColors.dark.background);
  });

  test('scroll behaviour always bounces', () {
    expect(
      const HeroScrollBehavior().getScrollPhysics(_FakeContext()),
      isA<BouncingScrollPhysics>(),
    );
  });
}

class _FakeContext extends Fake implements BuildContext {}
