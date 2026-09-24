import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData theme = HeroThemeData.light();

  ShapeDecoration decorationOf(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(HeroKbd),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration
          as ShapeDecoration;

  testWidgets('shorthand renders key symbols then text', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K'),
      theme: theme,
    );
    expect(find.text('⌘'), findsOneWidget);
    expect(find.text('K'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('⌘')).dx,
      lessThan(tester.getTopLeft(find.text('K')).dx),
    );
    expect(tester.getSize(find.byType(HeroKbd)).height, 24);
    final double gap =
        tester.getTopLeft(find.text('K')).dx -
        tester.getTopRight(find.text('⌘')).dx;
    expect(gap, 2);
    final Rect kbd = tester.getRect(find.byType(HeroKbd));
    expect(tester.getTopLeft(find.text('⌘')).dx - kbd.left, 8);
  });

  testWidgets('default and light variants', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.shift], text: 'P'),
      theme: theme,
    );
    expect(decorationOf(tester).color, theme.colors.defaultColor);
    final DefaultTextStyle text = DefaultTextStyle.of(
      tester.element(find.text('P')),
    );
    expect(text.style.color, theme.colors.muted);
    expect(text.style.fontSize, 14);
    expect(text.style.fontWeight, FontWeight.w500);
    expect(text.style.wordSpacing, -4);

    await pumpHero(
      tester,
      const HeroKbd(
        keys: <HeroKbdKey>[HeroKbdKey.shift],
        text: 'P',
        variant: HeroKbdVariant.light,
      ),
      theme: theme,
    );
    expect(decorationOf(tester).color!.a, 0);
  });

  testWidgets('style overrides', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroKbd(
        keys: const <HeroKbdKey>[HeroKbdKey.command],
        text: 'K',
        backgroundColor: theme.colors.accentSoft,
        foregroundColor: theme.colors.accentSoftForeground,
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      theme: theme,
    );
    expect(decorationOf(tester).color, theme.colors.accentSoft);
    expect(
      DefaultTextStyle.of(tester.element(find.text('K'))).style.color,
      theme.colors.accentSoftForeground,
    );
    final Rect kbd = tester.getRect(find.byType(HeroKbd));
    expect(tester.getTopLeft(find.text('⌘')).dx - kbd.left, 10);
  });

  testWidgets('compound parts', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroKbd(
        children: <Widget>[
          HeroKbdAbbr(HeroKbdKey.command),
          HeroKbdAbbr(HeroKbdKey.shift),
          HeroKbdContent(Text('Z')),
        ],
      ),
      theme: theme,
    );
    expect(find.byType(HeroKbdAbbr), findsNWidgets(2));
    expect(find.text('Z'), findsOneWidget);
  });

  test('key map matches HeroUI', () {
    expect(HeroKbdKey.values, hasLength(22));
    expect(HeroKbdKey.command.symbol, '⌘');
    expect(HeroKbdKey.capslock.label, 'Caps Lock');
    expect(HeroKbdKey.fn.symbol, 'Fn');
    expect(HeroKbdKey.win.symbol, HeroKbdKey.command.symbol);
    expect(HeroKbdKey.alt.symbol, HeroKbdKey.option.symbol);
    expect(HeroKbdKey.pagedown.label, 'Page Down');
  });

  testWidgets('semantics read the key names', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const HeroKbd(
        keys: <HeroKbdKey>[HeroKbdKey.command, HeroKbdKey.shift],
        text: 'Z',
      ),
    );
    final SemanticsNode node = tester.getSemantics(find.byType(HeroKbd));
    expect(node.label, 'Command\nShift\nZ');
    expect(find.bySemanticsLabel('⌘'), findsNothing);
    handle.dispose();
  });

  testWidgets('inline span aligns to the text baseline', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 360,
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: 'Press '),
              HeroKbd.span(const HeroKbd(text: 'Esc')),
              const TextSpan(text: ' to close the dialog.'),
            ],
          ),
          style: theme.typography.sm,
        ),
      ),
      theme: theme,
    );
    expect(find.byType(HeroKbd), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('RTL reverses the parts and 2x text scale grows the key', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K'),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('⌘')).dx,
      greaterThan(tester.getTopLeft(find.text('K')).dx),
    );
    expect(tester.getSize(find.byType(HeroKbd)).height, 40);
  });
}
