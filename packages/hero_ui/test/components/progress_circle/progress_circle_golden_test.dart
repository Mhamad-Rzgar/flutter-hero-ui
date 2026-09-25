import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// Indeterminate circles spin forever; golden tests render them still, as
/// HeroUI does under reduced motion.
Widget _still(HeroThemeData theme, Widget child) => HeroTheme(
  data: theme.copyWith(motion: const HeroMotion(reduceMotion: true)),
  child: child,
);

Widget _captioned(HeroThemeData theme, String label, Widget circle) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    spacing: theme.spacing(2),
    children: <Widget>[
      circle,
      Text(
        label,
        style: theme.typography.xs.copyWith(color: theme.colors.muted),
      ),
    ],
  );
}

void main() {
  heroGoldenTest(
    'progress circle sizes',
    name: 'progress_circle_sizes',
    size: const Size(260, 110),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(6),
      children: <Widget>[
        _captioned(
          theme,
          'sm 40',
          const HeroProgressCircle(size: HeroSize.sm, value: 40),
        ),
        _captioned(theme, 'md 60', const HeroProgressCircle(value: 60)),
        _captioned(
          theme,
          'lg 80',
          const HeroProgressCircle(size: HeroSize.lg, value: 80),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'progress circle colors',
    name: 'progress_circle_colors',
    size: const Size(380, 110),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(6),
      children: <Widget>[
        for (final HeroColor color in HeroColor.values)
          _captioned(
            theme,
            color.name,
            HeroProgressCircle(color: color, value: 60),
          ),
      ],
    ),
  );

  heroGoldenTest(
    'progress circle values and states',
    name: 'progress_circle_states',
    size: const Size(460, 110),
    builder: (HeroThemeData theme) => _still(
      theme,
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(4),
        children: <Widget>[
          for (final double value in <double>[0, 25, 50, 100])
            _captioned(
              theme,
              '${value.toInt()}',
              HeroProgressCircle(value: value, size: HeroSize.lg),
            ),
          _captioned(
            theme,
            'indeterminate',
            const HeroProgressCircle(isIndeterminate: true, size: HeroSize.lg),
          ),
          _captioned(
            theme,
            'disabled',
            const HeroProgressCircle(
              value: 60,
              size: HeroSize.lg,
              isDisabled: true,
            ),
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'progress circle custom geometry',
    name: 'progress_circle_custom',
    size: const Size(320, 120),
    builder: (HeroThemeData theme) {
      final bool dark = theme.isDark;
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: theme.spacing(6),
        children: <Widget>[
          const HeroProgressCircle(
            value: 60,
            child: HeroProgressCircleTrack(
              strokeWidth: 2,
              children: <Widget>[
                HeroProgressCircleTrackCircle(radius: 17),
                HeroProgressCircleFillCircle(radius: 17),
              ],
            ),
          ),
          const HeroProgressCircle(value: 60),
          const HeroProgressCircle(
            value: 60,
            child: HeroProgressCircleTrack(
              strokeWidth: 6,
              children: <Widget>[
                HeroProgressCircleTrackCircle(radius: 15),
                HeroProgressCircleFillCircle(radius: 15),
              ],
            ),
          ),
          HeroProgressCircle(
            value: 68,
            dimension: theme.spacing(14),
            child: HeroProgressCircleTrack(
              children: <Widget>[
                HeroProgressCircleTrackCircle(
                  color: dark
                      ? oklch(0.269, 0, 0) // neutral-800
                      : oklch(0.922, 0, 0), // neutral-200
                ),
                HeroProgressCircleFillCircle(
                  color: dark
                      ? oklch(0.87, 0, 0) // neutral-300
                      : oklch(0.371, 0, 0), // neutral-700
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
