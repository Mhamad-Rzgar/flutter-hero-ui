import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../helpers/hero_test_app.dart';

Widget _swatch(HeroThemeData theme, String name, Color color) {
  return SizedBox(
    width: 112,
    child: Row(
      children: <Widget>[
        DecoratedBox(
          decoration: ShapeDecoration(
            color: color,
            shape: theme.shapeAll(
              theme.radii.sm,
              side: BorderSide(color: theme.colors.border),
            ),
          ),
          child: const SizedBox.square(dimension: 20),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.xs.copyWith(color: theme.colors.foreground),
          ),
        ),
      ],
    ),
  );
}

void main() {
  heroGoldenTest(
    'color tokens',
    name: 'tokens/colors',
    size: const Size(520, 560),
    builder: (HeroThemeData theme) {
      final Map<String, Color> tokens = theme.colors.toMap();
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: <Widget>[
          for (final MapEntry<String, Color> e in tokens.entries)
            _swatch(theme, e.key, e.value),
        ],
      );
    },
  );

  heroGoldenTest(
    'typography, icons and focus ring',
    name: 'tokens/typography',
    size: const Size(520, 420),
    builder: (HeroThemeData theme) {
      final TextStyle fg = TextStyle(color: theme.colors.foreground);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Heading 1', style: theme.typography.h1.merge(fg)),
          Text('Heading 3', style: theme.typography.h3.merge(fg)),
          Text('Body text in Inter', style: theme.typography.body.merge(fg)),
          Text(
            'Muted small text',
            style: theme.typography.sm.copyWith(color: theme.colors.muted),
          ),
          Text('const code = true;', style: theme.typography.code.merge(fg)),
          const SizedBox(height: 12),
          IconTheme(
            data: IconThemeData(color: theme.colors.foreground, size: 20),
            child: const Wrap(
              spacing: 12,
              children: <Widget>[
                HeroIcon(HeroIcons.chevronDown),
                HeroIcon(HeroIcons.close),
                HeroIcon(HeroIcons.info),
                HeroIcon(HeroIcons.warning),
                HeroIcon(HeroIcons.success),
                HeroIcon(HeroIcons.danger),
                HeroIcon(HeroIcons.search),
                HeroIcon(HeroIcons.bell),
                HeroIcon(HeroIcons.gear),
                HeroIcon(HeroIcons.heart),
                HeroIcon(HeroIcons.calendarPicker),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              HeroFocusRing(
                visible: true,
                shape: theme.shapeAll(theme.radii.xl3),
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: theme.colors.accent,
                    shape: theme.shapeAll(theme.radii.xl3),
                  ),
                  child: const SizedBox(width: 96, height: 36),
                ),
              ),
              const SizedBox(width: 24),
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: theme.colors.surface,
                  shape: theme.shapeAll(theme.radii.xl3),
                  shadows: theme.shadows.surface.boxShadows,
                ),
                child: const SizedBox(width: 120, height: 64),
              ),
            ],
          ),
        ],
      );
    },
  );
}
