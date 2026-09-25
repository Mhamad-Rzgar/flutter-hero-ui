import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  const List<Color> palette = <Color>[
    Color(0xFF0485F7),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFD946EF),
  ];

  heroGoldenTest(
    'sizes and shapes',
    name: 'color_swatch_sizes',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroColorSwatchShape shape in HeroColorSwatchShape.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              for (int i = 0; i < HeroColorSwatchSize.values.length; i++)
                HeroColorSwatch(
                  color: palette[i],
                  shape: shape,
                  size: HeroColorSwatchSize.values[i],
                ),
            ],
          ),
      ],
    ),
  );

  heroGoldenTest(
    'transparency and light colors',
    name: 'color_swatch_transparency',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            for (final double alpha in <double>[1, 0.75, 0.5, 0.25, 0])
              HeroColorSwatch(
                color: const Color(0xFF0485F7).withValues(alpha: alpha),
                size: HeroColorSwatchSize.xl,
              ),
          ],
        ),
        const Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            HeroColorSwatch(color: Color(0xFFFFFFFF)),
            HeroColorSwatch(color: Color(0xFFF4F4F5)),
            HeroColorSwatch(color: Color(0xFF000000)),
            HeroColorSwatch(),
          ],
        ),
      ],
    ),
  );

  heroGoldenTest(
    'custom styles',
    name: 'color_swatch_custom_styles',
    size: const Size(360, 160),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            for (final Color color in palette)
              HeroColorSwatch(
                color: color,
                size: HeroColorSwatchSize.xl,
                styleBuilder: (Color color) => HeroColorSwatchStyle(
                  shadows: <BoxShadow>[
                    BoxShadow(color: color, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
              ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            for (final Color color in palette)
              HeroColorSwatch(
                color: color,
                size: HeroColorSwatchSize.xl,
                styleBuilder: (Color color) => HeroColorSwatchStyle(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[color, const Color(0xFFFFFFFF)],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
