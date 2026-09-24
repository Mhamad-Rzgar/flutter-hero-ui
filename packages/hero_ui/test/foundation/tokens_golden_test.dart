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
}
