import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

/// Wraps [child] in a [HeroApp] with the given [theme] for widget tests.
Widget heroTestApp(
  Widget child, {
  HeroThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  bool center = true,
}) {
  final HeroThemeData data = theme ?? HeroThemeData.light();
  return HeroApp(
    debugShowCheckedModeBanner: false,
    theme: data,
    darkTheme: data,
    themeMode: data.isDark ? HeroThemeMode.dark : HeroThemeMode.light,
    home: Directionality(
      textDirection: textDirection,
      child: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: center ? Center(child: child) : child,
        ),
      ),
    ),
  );
}

/// Pumps [child] inside [heroTestApp] and settles animations.
Future<void> pumpHero(
  WidgetTester tester,
  Widget child, {
  HeroThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  Size? surfaceSize,
}) async {
  if (surfaceSize != null) {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    heroTestApp(
      child,
      theme: theme,
      textDirection: textDirection,
      textScale: textScale,
    ),
  );
  await tester.pumpAndSettle();
}

/// Declares a golden test rendered once in light and once in dark mode.
///
/// The goldens are written to `goldens/<name>_light.png` and
/// `goldens/<name>_dark.png` next to the test file. [builder] receives the
/// active theme; the widget is centred on a [size] canvas painted with the
/// theme background. [surfaceWidth] sets the logical viewport width, which
/// drives HeroUI's responsive (`sm:`/`md:`) sizing.
void heroGoldenTest(
  String description, {
  required String name,
  required Widget Function(HeroThemeData theme) builder,
  Size size = const Size(480, 320),
  HeroThemePreset preset = HeroThemePreset.standard,
  Future<void> Function(WidgetTester tester)? whilePerforming,
}) {
  for (final Brightness brightness in Brightness.values) {
    final String mode = brightness == Brightness.dark ? 'dark' : 'light';
    // Goldens are generated on Linux; glyph rasterisation differs slightly on
    // other hosts, so they are only compared there.
    testWidgets('$description ($mode)', skip: !Platform.isLinux, (
      WidgetTester tester,
    ) async {
      final HeroThemeData theme = HeroThemeData.fromPreset(
        preset,
        brightness: brightness,
      );
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      debugDisableShadows = false;
      try {
        await tester.pumpWidget(
          RepaintBoundary(
            child: heroTestApp(
              Padding(padding: const EdgeInsets.all(16), child: builder(theme)),
              theme: theme,
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (whilePerforming != null) {
          await whilePerforming(tester);
          await tester.pumpAndSettle();
        }
        await expectLater(
          find.byType(RepaintBoundary).first,
          matchesGoldenFile('goldens/${name}_$mode.png'),
        );
      } finally {
        debugDisableShadows = true;
      }
    });
  }
}
