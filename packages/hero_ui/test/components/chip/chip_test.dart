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
                find
                    .descendant(
                      of: find.byType(HeroChip),
                      matching: find.byType(DecoratedBox),
                    )
                    .first,
              )
              .decoration
          as ShapeDecoration;

  Color textColor(WidgetTester tester, String text) =>
      DefaultTextStyle.of(tester.element(find.text(text))).style.color!;

  testWidgets('sizes follow the CSS geometry', (WidgetTester tester) async {
    for (final (HeroSize size, double height, double padding, double font)
        in <(HeroSize, double, double, double)>[
          (HeroSize.sm, 20, 4, 12),
          (HeroSize.md, 24, 8, 12),
          (HeroSize.lg, 28, 12, 14),
        ]) {
      await pumpHero(
        tester,
        HeroChip(label: 'Label', size: size),
        theme: theme,
      );
      expect(tester.getSize(find.byType(HeroChip)).height, height);
      final Rect chip = tester.getRect(find.byType(HeroChip));
      final Rect text = tester.getRect(find.text('Label'));
      // Chip padding plus the label's 2 px padding.
      expect(text.left - chip.left, padding + 2);
      final TextStyle style = DefaultTextStyle.of(
        tester.element(find.text('Label')),
      ).style;
      expect(style.fontSize, font);
      expect(style.fontWeight, FontWeight.w500);
    }
  });

  testWidgets('variant x color matrix follows the chip CSS', (
    WidgetTester tester,
  ) async {
    final HeroColors c = theme.colors;
    final Map<(HeroChipVariant, HeroColor), (Color, Color)> expected =
        <(HeroChipVariant, HeroColor), (Color, Color)>{
          (HeroChipVariant.secondary, HeroColor.standard): (
            c.defaultColor,
            c.defaultForeground,
          ),
          (HeroChipVariant.secondary, HeroColor.accent): (
            c.defaultColor,
            c.accentSoftForeground,
          ),
          (HeroChipVariant.primary, HeroColor.standard): (
            c.defaultColor,
            c.defaultForeground,
          ),
          (HeroChipVariant.primary, HeroColor.danger): (
            c.danger,
            c.dangerForeground,
          ),
          (HeroChipVariant.tertiary, HeroColor.success): (
            const Color(0x00000000),
            c.successSoftForeground,
          ),
          (HeroChipVariant.soft, HeroColor.warning): (
            c.warningSoft,
            c.warningSoftForeground,
          ),
          (HeroChipVariant.soft, HeroColor.standard): (
            c.defaultSoft,
            c.defaultSoftForeground,
          ),
        };
    for (final MapEntry<(HeroChipVariant, HeroColor), (Color, Color)> e
        in expected.entries) {
      await pumpHero(
        tester,
        HeroChip(label: 'Chip', variant: e.key.$1, color: e.key.$2),
        theme: theme,
      );
      expect(decorationOf(tester).color, e.value.$1, reason: '${e.key}');
      expect(textColor(tester, 'Chip'), e.value.$2, reason: '${e.key}');
    }
  });

  testWidgets('icons take the foreground color; slots are ordered', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroChip(
        color: HeroColor.success,
        startContent: HeroIcon(HeroIcons.check, size: 12),
        label: 'Available',
        endContent: HeroIcon(HeroIcons.chevronDown, size: 12),
      ),
      theme: theme,
    );
    final IconThemeData icons = IconTheme.of(
      tester.element(find.byType(HeroIcon).first),
    );
    expect(icons.color, theme.colors.successSoftForeground);
    final double start = tester.getCenter(find.byType(HeroIcon).first).dx;
    final double label = tester.getCenter(find.text('Available')).dx;
    final double end = tester.getCenter(find.byType(HeroIcon).last).dx;
    expect(start, lessThan(label));
    expect(label, lessThan(end));
  });

  testWidgets('custom child, radius and padding', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroChip(
        variant: HeroChipVariant.soft,
        radius: theme.radii.full,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: const HeroChipLabel(Text('Draft')),
      ),
      theme: theme,
    );
    expect(find.byType(HeroChipLabel), findsOneWidget);
    final Rect chip = tester.getRect(find.byType(HeroChip));
    expect(tester.getRect(find.text('Draft')).left - chip.left, 14);
  });

  testWidgets('semantics expose the label text', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, const HeroChip(label: 'Beta'));
    expect(find.bySemanticsLabel('Beta'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('RTL puts the start content on the right; 2x scale fits', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroChip(
        startContent: HeroIcon(HeroIcons.circleInfo, size: 12),
        label: 'New Feature',
      ),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getCenter(find.byType(HeroIcon)).dx,
      greaterThan(tester.getCenter(find.text('New Feature')).dx),
    );
    expect(tester.getSize(find.byType(HeroChip)).height, 44);
  });

  testWidgets('long labels wrap inside a narrow parent', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 80,
        child: HeroChip(label: 'A long chip label that wraps'),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
