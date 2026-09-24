import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// Spinners animate forever; golden tests render them still, as HeroUI does
/// under reduced motion.
Widget _still(HeroThemeData theme, Widget child) => HeroTheme(
  data: theme.copyWith(motion: const HeroMotion(reduceMotion: true)),
  child: child,
);

Widget _labelled(HeroThemeData theme, String label, Widget spinner) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    spacing: theme.spacing(2),
    children: <Widget>[
      spinner,
      Text(
        label,
        style: theme.typography.xs.copyWith(color: theme.colors.muted),
      ),
    ],
  );
}

void main() {
  heroGoldenTest(
    'spinner sizes',
    name: 'spinner_sizes',
    size: const Size(360, 120),
    builder: (HeroThemeData theme) => _still(
      theme,
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(8),
        children: <Widget>[
          for (final HeroSpinnerSize size in HeroSpinnerSize.values)
            _labelled(theme, size.name, HeroSpinner(size: size)),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'spinner colors',
    name: 'spinner_colors',
    size: const Size(480, 120),
    builder: (HeroThemeData theme) => _still(
      theme,
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(6),
        children: <Widget>[
          for (final HeroSpinnerColor color in HeroSpinnerColor.values)
            _labelled(theme, color.name, HeroSpinner(color: color)),
          _labelled(
            theme,
            'override',
            HeroSpinner(colorOverride: theme.colors.muted),
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'spinner glyph enlarged',
    name: 'spinner_glyph',
    size: const Size(160, 160),
    builder: (HeroThemeData theme) => _still(
      theme,
      const SizedBox.square(
        dimension: 96,
        child: FittedBox(child: HeroSpinner(size: HeroSpinnerSize.xl)),
      ),
    ),
  );
}
