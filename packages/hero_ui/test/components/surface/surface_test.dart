import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

ShapeDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .descendant(
                    of: find.byType(HeroSurface),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as ShapeDecoration;

void main() {
  final HeroColors colors = HeroThemeData.light().colors;

  testWidgets('variants paint their background and foreground', (
    WidgetTester tester,
  ) async {
    final Map<HeroSurfaceVariant, (Color?, Color)> expected =
        <HeroSurfaceVariant, (Color?, Color)>{
          HeroSurfaceVariant.transparent: (null, colors.foreground),
          HeroSurfaceVariant.standard: (
            colors.surface,
            colors.surfaceForeground,
          ),
          HeroSurfaceVariant.secondary: (
            colors.surfaceSecondary,
            colors.surfaceSecondaryForeground,
          ),
          HeroSurfaceVariant.tertiary: (
            colors.surfaceTertiary,
            colors.surfaceTertiaryForeground,
          ),
        };
    for (final MapEntry<HeroSurfaceVariant, (Color?, Color)> entry
        in expected.entries) {
      await pumpHero(
        tester,
        HeroSurface(variant: entry.key, child: const Text('Content')),
      );
      expect(_decoration(tester).color, entry.value.$1);
      final DefaultTextStyle text = DefaultTextStyle.of(
        tester.element(find.text('Content')),
      );
      expect(text.style.color, entry.value.$2);
      expect(
        IconTheme.of(tester.element(find.text('Content'))).color,
        entry.value.$2,
      );
    }
  });

  testWidgets('default variant is standard', (WidgetTester tester) async {
    await pumpHero(tester, const HeroSurface(child: SizedBox.square()));
    expect(_decoration(tester).color, colors.surface);
  });

  testWidgets('publishes the surface variant to descendants', (
    WidgetTester tester,
  ) async {
    HeroSurfaceVariant? outer;
    HeroSurfaceVariant? inner;
    HeroSurfaceVariant? none;
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(
            builder: (BuildContext context) {
              none = HeroSurfaceScope.variantOf(context);
              return const SizedBox.shrink();
            },
          ),
          HeroSurface(
            variant: HeroSurfaceVariant.secondary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Builder(
                  builder: (BuildContext context) {
                    outer = HeroSurfaceScope.variantOf(context);
                    return const SizedBox.shrink();
                  },
                ),
                HeroSurface(
                  variant: HeroSurfaceVariant.tertiary,
                  child: Builder(
                    builder: (BuildContext context) {
                      inner = HeroSurfaceScope.variantOf(context);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    expect(none, isNull);
    expect(outer, HeroSurfaceVariant.secondary);
    expect(inner, HeroSurfaceVariant.tertiary);
  });

  testWidgets('padding, border, radius and size', (WidgetTester tester) async {
    final HeroThemeData theme = HeroThemeData.light();
    await pumpHero(
      tester,
      HeroSurface(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(24),
        border: BorderSide(color: colors.border),
        constraints: const BoxConstraints(minWidth: 320),
        child: const SizedBox(width: 10, height: 10),
      ),
    );
    // The border takes room inside the surface, like CSS.
    expect(tester.getSize(find.byType(HeroSurface)), const Size(320, 60));
    final ShapeDecoration decoration = _decoration(tester);
    expect(
      decoration.shape,
      theme.shape(
        BorderRadius.circular(24),
        side: BorderSide(color: colors.border),
      ),
    );
    await pumpHero(
      tester,
      const HeroSurface(width: 200, height: 100, child: SizedBox.shrink()),
    );
    expect(tester.getSize(find.byType(HeroSurface)), const Size(200, 100));
  });

  testWidgets('gradient paints over the background color', (
    WidgetTester tester,
  ) async {
    const LinearGradient gradient = LinearGradient(
      colors: <Color>[Color(0x00000000), Color(0x00000000)],
    );
    await pumpHero(
      tester,
      const HeroSurface(gradient: gradient, child: SizedBox.square()),
    );
    final List<DecoratedBox> boxes = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(HeroSurface),
            matching: find.byType(DecoratedBox),
          ),
        )
        .toList();
    expect((boxes[0].decoration as ShapeDecoration).color, colors.surface);
    expect((boxes[1].decoration as ShapeDecoration).gradient, gradient);
  });

  testWidgets('clips its child when asked', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroSurface(
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: const SizedBox(width: 40, height: 40),
      ),
    );
    expect(
      find.descendant(
        of: find.byType(HeroSurface),
        matching: find.byType(ClipPath),
      ),
      findsOneWidget,
    );
  });

  testWidgets('RTL padding and text scale 2.0', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        child: HeroSurface(
          padding: EdgeInsetsDirectional.only(start: 20),
          child: Text('Scaled surface content that wraps'),
        ),
      ),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopRight(find.byType(HeroSurface)).dx -
          tester.getTopRight(find.byType(Text)).dx,
      20,
    );
  });
}
