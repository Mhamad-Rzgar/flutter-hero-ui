import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  const List<HeroColor> colors = <HeroColor>[
    HeroColor.accent,
    HeroColor.standard,
    HeroColor.success,
    HeroColor.warning,
    HeroColor.danger,
  ];

  heroGoldenTest(
    'badge variants and colors',
    name: 'badge_variants',
    size: const Size(360, 240),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: <Widget>[
        for (final HeroBadgeVariant variant in HeroBadgeVariant.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 24,
            children: <Widget>[
              for (final HeroColor color in colors)
                HeroBadgeAnchor(
                  badge: HeroBadge(
                    label: '5',
                    size: HeroSize.sm,
                    color: color,
                    variant: variant,
                  ),
                  child: const HeroAvatar(fallback: Text('JD')),
                ),
            ],
          ),
      ],
    ),
  );

  heroGoldenTest(
    'badge sizes, placements and content',
    name: 'badge_content',
    size: const Size(440, 220),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: <Widget>[
            for (final HeroSize size in HeroSize.values)
              HeroBadgeAnchor(
                badge: HeroBadge(
                  label: '5',
                  color: HeroColor.danger,
                  size: size,
                ),
                child: HeroAvatar(size: size, fallback: const Text('JD')),
              ),
            const HeroBadge(label: 'New', color: HeroColor.accent),
            const HeroBadge(color: HeroColor.success),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: <Widget>[
            for (final HeroBadgePlacement placement
                in HeroBadgePlacement.values)
              HeroBadgeAnchor(
                badge: HeroBadge(
                  color: HeroColor.accent,
                  size: HeroSize.sm,
                  placement: placement,
                ),
                child: const HeroAvatar(fallback: Text('JD')),
              ),
            const HeroBadgeAnchor(
              badge: HeroBadge(
                label: '99+',
                color: HeroColor.danger,
                size: HeroSize.sm,
              ),
              child: HeroAvatar(fallback: Text('JD')),
            ),
            const HeroBadgeAnchor(
              badge: HeroBadge(
                color: HeroColor.accent,
                size: HeroSize.sm,
                child: HeroIcon(HeroIcons.bell, size: 10),
              ),
              child: HeroAvatar(fallback: Text('JD')),
            ),
          ],
        ),
      ],
    ),
  );
}
