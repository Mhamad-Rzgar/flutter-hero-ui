import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  for (final HeroSize size in HeroSize.values) {
    heroGoldenTest(
      'chip variants and colors (${size.name})',
      name: 'chip_matrix_${size.name}',
      size: const Size(500, 200),
      builder: (HeroThemeData theme) => Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final HeroChipVariant variant in HeroChipVariant.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: <Widget>[
                for (final HeroColor color in HeroColor.values)
                  HeroChip(
                    variant: variant,
                    color: color,
                    size: size,
                    startContent: const HeroIcon(HeroIcons.circleDashed),
                    label: 'Label',
                  ),
              ],
            ),
        ],
      ),
    );
  }

  heroGoldenTest(
    'chip content',
    name: 'chip_content',
    size: const Size(420, 160),
    builder: (HeroThemeData theme) => Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        const HeroChip(label: 'Default'),
        const HeroChip(
          variant: HeroChipVariant.primary,
          color: HeroColor.success,
          startContent: HeroIcon(HeroIcons.circleFill, size: 6),
          label: 'Active',
        ),
        const HeroChip(
          color: HeroColor.warning,
          startContent: HeroIcon(HeroIcons.triangleExclamation, size: 12),
          label: 'Beta',
        ),
        const HeroChip(
          color: HeroColor.accent,
          label: 'Label',
          endContent: HeroIcon(HeroIcons.chevronDown, size: 12),
        ),
        HeroChip(
          variant: HeroChipVariant.soft,
          color: HeroColor.success,
          radius: theme.radii.full,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          label: 'Published',
        ),
      ],
    ),
  );
}
