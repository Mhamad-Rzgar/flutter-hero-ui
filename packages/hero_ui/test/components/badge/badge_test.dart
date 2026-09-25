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
                      of: find.byType(HeroBadge),
                      matching: find.byType(DecoratedBox),
                    )
                    .first,
              )
              .decoration
          as ShapeDecoration;

  const Widget target = SizedBox(width: 40, height: 40);

  testWidgets('dots are circles of the size minimum', (
    WidgetTester tester,
  ) async {
    for (final (HeroSize size, double side) in <(HeroSize, double)>[
      (HeroSize.sm, 16),
      (HeroSize.md, 28),
      (HeroSize.lg, 32),
    ]) {
      await pumpHero(tester, HeroBadge(size: size), theme: theme);
      expect(tester.getSize(find.byType(HeroBadge)), Size.square(side));
    }
  });

  testWidgets('labels use the size text and grow horizontally', (
    WidgetTester tester,
  ) async {
    for (final (HeroSize size, double font) in <(HeroSize, double)>[
      (HeroSize.sm, 10),
      (HeroSize.md, 12),
      (HeroSize.lg, 14),
    ]) {
      await pumpHero(
        tester,
        HeroBadge(label: '5', size: size),
        theme: theme,
      );
      final TextStyle style = DefaultTextStyle.of(
        tester.element(find.text('5')),
      ).style;
      expect(style.fontSize, font);
      expect(style.fontWeight, FontWeight.w500);
    }
    await pumpHero(tester, const HeroBadge(label: '99+', size: HeroSize.sm));
    final Size badge = tester.getSize(find.byType(HeroBadge));
    final Size text = tester.getSize(find.text('99+'));
    expect(badge.height, 16);
    expect(badge.width, closeTo(text.width + 2 * 2 + 2, 0.01));
  });

  testWidgets('variant x color matrix and the background outline', (
    WidgetTester tester,
  ) async {
    final HeroColors c = theme.colors;
    final Map<(HeroBadgeVariant, HeroColor), (Color, Color)> expected =
        <(HeroBadgeVariant, HeroColor), (Color, Color)>{
          (HeroBadgeVariant.primary, HeroColor.standard): (
            c.defaultColor,
            c.defaultForeground,
          ),
          (HeroBadgeVariant.primary, HeroColor.danger): (
            c.danger,
            c.dangerForeground,
          ),
          (HeroBadgeVariant.secondary, HeroColor.accent): (
            c.defaultColor,
            c.accentSoftForeground,
          ),
          (HeroBadgeVariant.secondary, HeroColor.standard): (
            c.defaultColor,
            c.defaultForeground,
          ),
          (HeroBadgeVariant.soft, HeroColor.success): (
            c.successSoft,
            c.successSoftForeground,
          ),
          (HeroBadgeVariant.soft, HeroColor.standard): (
            c.defaultSoft,
            c.defaultSoftForeground,
          ),
        };
    for (final MapEntry<(HeroBadgeVariant, HeroColor), (Color, Color)> e
        in expected.entries) {
      await pumpHero(
        tester,
        HeroBadge(label: '5', variant: e.key.$1, color: e.key.$2),
        theme: theme,
      );
      final ShapeDecoration decoration = decorationOf(tester);
      expect(decoration.color, e.value.$1, reason: '${e.key}');
      expect((decoration.shape as OutlinedBorder).side.color, c.background);
      expect(
        DefaultTextStyle.of(tester.element(find.text('5'))).style.color,
        e.value.$2,
        reason: '${e.key}',
      );
    }
  });

  testWidgets('placements push the badge a quarter outside each corner', (
    WidgetTester tester,
  ) async {
    for (final (HeroBadgePlacement placement, Offset expected)
        in <(HeroBadgePlacement, Offset)>[
          (HeroBadgePlacement.topRight, const Offset(40 - 12, -4)),
          (HeroBadgePlacement.topLeft, const Offset(-4, -4)),
          (HeroBadgePlacement.bottomRight, const Offset(40 - 12, 40 - 12)),
          (HeroBadgePlacement.bottomLeft, const Offset(-4, 40 - 12)),
        ]) {
      await pumpHero(
        tester,
        HeroBadgeAnchor(
          badge: HeroBadge(size: HeroSize.sm, placement: placement),
          child: target,
        ),
      );
      final Offset anchor = tester.getTopLeft(find.byType(HeroBadgeAnchor));
      final Offset badge = tester.getTopLeft(find.byType(HeroBadge));
      expect(badge - anchor, expected, reason: '$placement');
      expect(tester.getSize(find.byType(HeroBadgeAnchor)), const Size(40, 40));
    }
  });

  testWidgets('placement is physical in right-to-left layouts', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroBadgeAnchor(
        badge: HeroBadge(size: HeroSize.sm),
        child: target,
      ),
      textDirection: TextDirection.rtl,
    );
    final Rect anchor = tester.getRect(find.byType(HeroBadgeAnchor));
    expect(tester.getTopRight(find.byType(HeroBadge)).dx, anchor.right + 4);
  });

  testWidgets('custom content, min width and style', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroBadge(
        color: HeroColor.accent,
        size: HeroSize.sm,
        variant: HeroBadgeVariant.soft,
        minWidth: 20,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
        ),
        label: '5',
      ),
      theme: theme,
    );
    expect(tester.getSize(find.byType(HeroBadge)).width, 20);
    expect(
      DefaultTextStyle.of(tester.element(find.text('5'))).style.fontWeight,
      FontWeight.w600,
    );

    await pumpHero(
      tester,
      const HeroBadge(
        color: HeroColor.accent,
        size: HeroSize.sm,
        child: HeroIcon(HeroIcons.bell, size: 10),
      ),
      theme: theme,
    );
    expect(
      IconTheme.of(tester.element(find.byType(HeroIcon))).color,
      theme.colors.accentForeground,
    );
    expect(tester.getSize(find.byType(HeroBadge)), const Size.square(16));
  });

  testWidgets('semantics merge the badge into the anchor', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const HeroBadgeAnchor(
        badge: HeroBadge(label: '5', semanticLabel: '5 notifications'),
        child: Text('Inbox'),
      ),
    );
    expect(
      tester.getSemantics(find.byType(HeroBadgeAnchor)).label,
      'Inbox\n5 notifications',
    );
    await pumpHero(
      tester,
      const HeroBadgeAnchor(badge: HeroBadge(), child: Text('Online')),
    );
    expect(tester.getSemantics(find.byType(HeroBadgeAnchor)).label, 'Online');
    handle.dispose();
  });

  testWidgets('2x text scale grows the badge without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroBadgeAnchor(
        badge: HeroBadge(label: 'New', size: HeroSize.sm),
        child: target,
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(HeroBadge)).height, greaterThan(16));
  });
}
