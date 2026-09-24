import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  RenderHeroSeparator line(WidgetTester tester) =>
      tester.renderObject<RenderHeroSeparator>(
        find.descendant(
          of: find.byType(HeroSeparator),
          matching: find.byWidgetPredicate(
            (Widget w) => w.runtimeType.toString() == '_SeparatorLine',
          ),
        ),
      );

  testWidgets('horizontal separator is 1px tall and fills the width', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const SizedBox(width: 300, child: HeroSeparator()));
    expect(tester.getSize(find.byType(HeroSeparator)), const Size(300, 1));
    expect(line(tester).axis, Axis.horizontal);
  });

  testWidgets('vertical separator stretches to a bounded height', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        height: 20,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Blog'),
            HeroSeparator(orientation: Axis.vertical),
            Text('Docs'),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(HeroSeparator)), const Size(1, 20));
  });

  testWidgets('vertical separator falls back to min-h-2 when unbounded', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SingleChildScrollView(
        child: HeroSeparator(orientation: Axis.vertical),
      ),
    );
    expect(tester.getSize(find.byType(HeroSeparator)), const Size(1, 8));
  });

  testWidgets('IntrinsicHeight makes a vertical separator match its row', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SingleChildScrollView(
        child: IntrinsicHeight(
          child: Row(
            children: <Widget>[
              SizedBox(width: 40, height: 36),
              HeroSeparator(orientation: Axis.vertical),
              SizedBox(width: 40, height: 12),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(HeroSeparator)).height, 36);
  });

  testWidgets('fixed length, thickness and margin', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        height: 100,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroSeparator(
              orientation: Axis.vertical,
              length: 16,
              thickness: 2,
              margin: EdgeInsets.symmetric(horizontal: 12),
            ),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(HeroSeparator)), const Size(26, 16));
    expect(line(tester).size, const Size(2, 16));
  });

  testWidgets('variant colors follow the separator tokens', (
    WidgetTester tester,
  ) async {
    final HeroThemeData theme = HeroThemeData.light();
    for (final (HeroSeparatorVariant variant, Color expected)
        in <(HeroSeparatorVariant, Color)>[
          (HeroSeparatorVariant.standard, theme.colors.separator),
          (HeroSeparatorVariant.secondary, theme.colors.separatorSecondary),
          (HeroSeparatorVariant.tertiary, theme.colors.separatorTertiary),
        ]) {
      await pumpHero(
        tester,
        SizedBox(width: 100, child: HeroSeparator(variant: variant)),
        theme: theme,
      );
      expect(line(tester).color, expected);
    }
    await pumpHero(
      tester,
      SizedBox(width: 100, child: HeroSeparator(color: theme.colors.accent)),
      theme: theme,
    );
    expect(line(tester).color, theme.colors.accent);
  });

  testWidgets('dark theme uses the dark separator token', (
    WidgetTester tester,
  ) async {
    final HeroThemeData dark = HeroThemeData.dark();
    await pumpHero(
      tester,
      const SizedBox(width: 100, child: HeroSeparator()),
      theme: dark,
    );
    expect(line(tester).color, dark.colors.separator);
  });

  testWidgets('scope provides orientation and relative length', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        height: 40,
        child: HeroSeparatorScope(
          orientation: Axis.vertical,
          lengthFactor: 0.5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[HeroSeparator()],
          ),
        ),
      ),
    );
    expect(line(tester).axis, Axis.vertical);
    expect(tester.getSize(find.byType(HeroSeparator)), const Size(1, 20));
  });

  testWidgets('explicit orientation wins over the scope', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        child: HeroSeparatorScope(
          orientation: Axis.vertical,
          child: HeroSeparator(orientation: Axis.horizontal),
        ),
      ),
    );
    expect(line(tester).axis, Axis.horizontal);
  });

  testWidgets('stretched separators center the line', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        height: 30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[HeroSeparator()],
        ),
      ),
    );
    expect(tester.getSize(find.byType(HeroSeparator)), const Size(200, 1));
  });

  testWidgets('separator is excluded from semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Above'),
          SizedBox(width: 100, child: HeroSeparator()),
          Text('Below'),
        ],
      ),
    );
    final SemanticsNode root = tester.getSemantics(find.text('Above'));
    expect(root.label, 'Above');
    expect(
      find.bySemanticsLabel(RegExp('separator', caseSensitive: false)),
      findsNothing,
    );
    handle.dispose();
  });

  testWidgets('renders in RTL and at 2x text scale', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 240,
        height: 24,
        child: Row(
          children: <Widget>[
            Text('Blog'),
            SizedBox(width: 16),
            HeroSeparator(orientation: Axis.vertical),
            SizedBox(width: 16),
            Text('Docs'),
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    final Offset blog = tester.getCenter(find.text('Blog'));
    final Offset separator = tester.getCenter(find.byType(HeroSeparator));
    expect(blog.dx, greaterThan(separator.dx));
  });
}
