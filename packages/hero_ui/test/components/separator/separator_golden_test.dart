import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  TextStyle text(HeroThemeData theme) =>
      theme.typography.sm.copyWith(color: theme.colors.foreground);

  heroGoldenTest(
    'separator variants',
    name: 'separator_variants',
    size: const Size(320, 200),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        Text('Default Variant', style: text(theme)),
        const HeroSeparator(),
        Text('Secondary Variant', style: text(theme)),
        const HeroSeparator(variant: HeroSeparatorVariant.secondary),
        Text('Tertiary Variant', style: text(theme)),
        const HeroSeparator(variant: HeroSeparatorVariant.tertiary),
      ],
    ),
  );

  heroGoldenTest(
    'separator orientations',
    name: 'separator_orientations',
    size: const Size(320, 200),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'HeroUI v3 Components',
          style: theme.typography
              .style(HeroFontSize.base, weight: HeroTypography.medium)
              .copyWith(color: theme.colors.foreground),
        ),
        const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 16)),
        SizedBox(
          height: 20,
          child: Row(
            spacing: 16,
            children: <Widget>[
              Text('Blog', style: text(theme)),
              const HeroSeparator(orientation: Axis.vertical),
              Text('Docs', style: text(theme)),
              const HeroSeparator(orientation: Axis.vertical),
              Text('Source', style: text(theme)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: HeroSeparatorScope(
            orientation: Axis.vertical,
            lengthFactor: 0.5,
            child: Row(
              spacing: 12,
              children: <Widget>[
                Text('Toolbar', style: text(theme)),
                const HeroSeparator(),
                HeroSeparator(thickness: 4, color: theme.colors.accent),
                const HeroSeparator(variant: HeroSeparatorVariant.tertiary),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
