import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData theme = HeroThemeData.light();

  HeroColorSwatchPainter painterOf(WidgetTester tester, [int index = 0]) {
    final CustomPaint paint = tester.widget<CustomPaint>(
      find
          .descendant(
            of: find.byType(HeroColorSwatch).at(index),
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    return paint.painter! as HeroColorSwatchPainter;
  }

  BorderRadius radiusOf(WidgetTester tester, [int index = 0]) {
    final ShapeBorder shape = painterOf(tester, index).shape;
    return switch (shape) {
      RoundedSuperellipseBorder(:final BorderRadiusGeometry borderRadius) =>
        borderRadius.resolve(TextDirection.ltr),
      RoundedRectangleBorder(:final BorderRadiusGeometry borderRadius) =>
        borderRadius.resolve(TextDirection.ltr),
      _ => throw StateError('unexpected shape $shape'),
    };
  }

  testWidgets('sizes and circle radii follow the CSS', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final HeroColorSwatchSize size in HeroColorSwatchSize.values)
            HeroColorSwatch(color: const Color(0xFF0485F7), size: size),
        ],
      ),
    );
    const List<double> sizes = <double>[16, 24, 32, 36, 40];
    final List<double> radii = <double>[
      theme.radii.lg,
      theme.radii.xl,
      theme.radii.xl2,
      theme.radii.xl3,
      theme.radii.xl3,
    ];
    for (int i = 0; i < sizes.length; i++) {
      expect(
        tester.getSize(find.byType(HeroColorSwatch).at(i)),
        Size.square(sizes[i]),
      );
      expect(radiusOf(tester, i), BorderRadius.circular(radii[i]));
    }
  });

  testWidgets('square swatches use rounded-md', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroColorSwatch(
        color: Color(0xFF0485F7),
        shape: HeroColorSwatchShape.square,
        size: HeroColorSwatchSize.xl,
      ),
    );
    expect(radiusOf(tester), BorderRadius.circular(theme.radii.md));
    expect(painterOf(tester).ringColor, heroColorInsetRing(theme.colors));
    expect(painterOf(tester).ringColor!.a, closeTo(0.1, 1e-9));
  });

  testWidgets('semantics: an image labelled with the color name', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroColorSwatch(
            color: Color(0xFF0485F7),
            colorName: 'Ocean Blue',
            semanticLabel: 'Primary brand color',
          ),
          HeroColorSwatch(color: Color(0xFFEF4444), semanticLabel: 'Red'),
          HeroColorSwatch(
            color: Color(0x000485F7),
            semanticLabel: '0% opacity',
          ),
        ],
      ),
    );
    expect(
      tester.getSemantics(find.byType(HeroColorSwatch).first),
      matchesSemantics(label: 'Ocean Blue, Primary brand color', isImage: true),
    );
    expect(
      tester.getSemantics(find.byType(HeroColorSwatch).at(1)),
      matchesSemantics(label: 'vibrant red, Red', isImage: true),
    );
    expect(
      tester.getSemantics(find.byType(HeroColorSwatch).at(2)),
      matchesSemantics(label: 'transparent, 0% opacity', isImage: true),
    );
    handle.dispose();
  });

  testWidgets('without a color it shows the picker color, else transparent', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroColorPickerScope(
        value: const HeroColorValue.rgb(16, 185, 129),
        onChanged: (_) {},
        child: const HeroColorSwatch(),
      ),
    );
    expect(
      heroColorsEqual(painterOf(tester).color, const Color(0xFF10B981)),
      isTrue,
    );

    await pumpHero(tester, const HeroColorSwatch());
    expect(painterOf(tester).color, HeroColorSwatch.transparent);
  });

  testWidgets('styleBuilder receives the color and overrides the look', (
    WidgetTester tester,
  ) async {
    final List<Color> seen = <Color>[];
    await pumpHero(
      tester,
      HeroColorSwatch(
        color: const Color(0xFFD946EF),
        size: HeroColorSwatchSize.xl,
        style: const HeroColorSwatchStyle(size: 48),
        styleBuilder: (Color color) {
          seen.add(color);
          return HeroColorSwatchStyle(
            shadows: <BoxShadow>[BoxShadow(color: color, blurRadius: 20)],
            gradient: LinearGradient(
              colors: <Color>[color, const Color(0xFFFFFFFF)],
            ),
          );
        },
      ),
    );
    expect(seen, <Color>[const Color(0xFFD946EF)]);
    expect(tester.getSize(find.byType(HeroColorSwatch)), const Size.square(48));
    final HeroColorSwatchPainter painter = painterOf(tester);
    expect(painter.shadows, hasLength(1));
    expect(painter.gradient, isA<LinearGradient>());
  });

  testWidgets('does not take focus and keeps its size at 2x text', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroColorSwatch(color: Color(0xFF0485F7)),
          Text('Blue'),
        ],
      ),
      textScale: 2,
      textDirection: TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: find.byType(HeroColorSwatch),
        matching: find.byType(Focus),
      ),
      findsNothing,
    );
    expect(tester.getSize(find.byType(HeroColorSwatch)), const Size.square(32));
    // In right-to-left rows the swatch comes first on the right.
    expect(
      tester.getCenter(find.byType(HeroColorSwatch)).dx,
      greaterThan(tester.getCenter(find.text('Blue')).dx),
    );
  });

  test('style merge and equality', () {
    const HeroColorSwatchStyle a = HeroColorSwatchStyle(size: 10);
    const HeroColorSwatchStyle b = HeroColorSwatchStyle(
      ringColor: Color(0x00000000),
    );
    final HeroColorSwatchStyle merged = a.merge(b);
    expect(merged.size, 10);
    expect(merged.ringColor, const Color(0x00000000));
    expect(
      merged,
      const HeroColorSwatchStyle(size: 10, ringColor: Color(0x00000000)),
    );
    expect(a.merge(null), same(a));
  });
}
