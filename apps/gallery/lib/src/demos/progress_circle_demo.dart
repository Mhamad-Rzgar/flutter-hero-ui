import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// `flex items-center gap-6` (or `items-end` for the custom SVG example).
Widget _row(
  BuildContext context,
  List<Widget> children, {
  WrapCrossAlignment alignment = WrapCrossAlignment.center,
}) {
  final HeroThemeData theme = HeroTheme.of(context);
  return Wrap(
    spacing: theme.spacing(6),
    runSpacing: theme.spacing(4),
    crossAxisAlignment: alignment,
    children: children,
  );
}

/// The "Custom SVG Props" example: thin, default and thick circles.
const List<Widget> _customSvg = <Widget>[
  HeroProgressCircle(
    value: 60,
    semanticLabel: 'Thin circle',
    child: HeroProgressCircleTrack(
      strokeWidth: 2,
      children: <Widget>[
        HeroProgressCircleTrackCircle(
          center: Offset(18, 18),
          radius: 17,
          strokeWidth: 2,
        ),
        HeroProgressCircleFillCircle(
          center: Offset(18, 18),
          radius: 17,
          strokeWidth: 2,
        ),
      ],
    ),
  ),
  HeroProgressCircle(value: 60, semanticLabel: 'Default circle'),
  HeroProgressCircle(
    value: 60,
    semanticLabel: 'Thick circle',
    child: HeroProgressCircleTrack(
      strokeWidth: 6,
      children: <Widget>[
        HeroProgressCircleTrackCircle(
          center: Offset(18, 18),
          radius: 15,
          strokeWidth: 6,
        ),
        HeroProgressCircleFillCircle(
          center: Offset(18, 18),
          radius: 15,
          strokeWidth: 6,
        ),
      ],
    ),
  ),
];

/// Gallery page of `HeroProgressCircle`.
final ComponentDemo progressCircleDemo = ComponentDemo(
  slug: 'progress-circle',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('value', <String>['0', '25', '60', '100'], initial: '60'),
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('color', <String>[
        'standard',
        'accent',
        'success',
        'warning',
        'danger',
      ], initial: 'accent'),
      ToggleControl('isIndeterminate'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) =>
        HeroProgressCircle(
          value: double.parse(values.option('value')),
          size: values.pick('size', HeroSize.values),
          color: values.pick('color', HeroColor.values),
          isIndeterminate: values.toggle('isIndeterminate'),
          isDisabled: values.toggle('isDisabled'),
          semanticLabel: 'Loading',
        ),
    code: (PlaygroundValues values) =>
        '''
HeroProgressCircle(
  value: ${values.option('value')},
  size: HeroSize.${values.option('size')},
  color: HeroColor.${values.option('color')},
  isIndeterminate: ${values.toggle('isIndeterminate')},
  isDisabled: ${values.toggle('isDisabled')},
  semanticLabel: 'Loading',
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) =>
          const HeroProgressCircle(value: 60, semanticLabel: 'Loading'),
      code: '''
const HeroProgressCircle(
  value: 60,
  semanticLabel: 'Loading',
  // The default content, spelled out:
  child: HeroProgressCircleTrack(
    children: <Widget>[
      HeroProgressCircleTrackCircle(),
      HeroProgressCircleFillCircle(),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => _row(context, const <Widget>[
        HeroProgressCircle(
          size: HeroSize.sm,
          value: 40,
          semanticLabel: 'Loading',
        ),
        HeroProgressCircle(value: 60, semanticLabel: 'Loading'),
        HeroProgressCircle(
          size: HeroSize.lg,
          value: 80,
          semanticLabel: 'Loading',
        ),
      ]),
      code: '''
Wrap(
  spacing: 24,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: const <Widget>[
    HeroProgressCircle(size: HeroSize.sm, value: 40, semanticLabel: 'Loading'),
    HeroProgressCircle(size: HeroSize.md, value: 60, semanticLabel: 'Loading'),
    HeroProgressCircle(size: HeroSize.lg, value: 80, semanticLabel: 'Loading'),
  ],
)''',
    ),
    DemoExample(
      title: 'Colors',
      builder: (BuildContext context) => _row(context, <Widget>[
        for (final (HeroColor color, String label) in <(HeroColor, String)>[
          (HeroColor.standard, 'Default'),
          (HeroColor.accent, 'Accent'),
          (HeroColor.success, 'Success'),
          (HeroColor.warning, 'Warning'),
          (HeroColor.danger, 'Danger'),
        ])
          HeroProgressCircle(color: color, value: 60, semanticLabel: label),
      ]),
      code: '''
Wrap(
  spacing: 24,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: const <Widget>[
    HeroProgressCircle(color: HeroColor.standard, value: 60, semanticLabel: 'Default'),
    HeroProgressCircle(color: HeroColor.accent, value: 60, semanticLabel: 'Accent'),
    HeroProgressCircle(color: HeroColor.success, value: 60, semanticLabel: 'Success'),
    HeroProgressCircle(color: HeroColor.warning, value: 60, semanticLabel: 'Warning'),
    HeroProgressCircle(color: HeroColor.danger, value: 60, semanticLabel: 'Danger'),
  ],
)''',
    ),
    DemoExample(
      title: 'Indeterminate',
      description: 'Use isIndeterminate when progress cannot be determined.',
      builder: (BuildContext context) => const HeroProgressCircle(
        isIndeterminate: true,
        semanticLabel: 'Loading',
      ),
      code: '''
const HeroProgressCircle(
  isIndeterminate: true,
  semanticLabel: 'Loading',
)''',
    ),
    DemoExample(
      title: 'With Label',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: HeroTheme.of(context).spacing(3),
        children: const <Widget>[
          HeroProgressCircle(value: 75, semanticLabel: 'Loading'),
          HeroLabel.text('75% Complete'),
        ],
      ),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: const <Widget>[
    HeroProgressCircle(value: 75, semanticLabel: 'Loading'),
    HeroLabel.text('75% Complete'),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom SVG Props',
      description:
          'Each part is composable: override strokeWidth, radius, center and '
          'viewBox directly.',
      builder: (BuildContext context) =>
          _row(context, _customSvg, alignment: WrapCrossAlignment.end),
      code: '''
Wrap(
  spacing: 24,
  crossAxisAlignment: WrapCrossAlignment.end,
  children: const <Widget>[
    HeroProgressCircle(
      value: 60,
      semanticLabel: 'Thin circle',
      child: HeroProgressCircleTrack(
        strokeWidth: 2,
        viewBox: Size(36, 36),
        children: <Widget>[
          HeroProgressCircleTrackCircle(center: Offset(18, 18), radius: 17, strokeWidth: 2),
          HeroProgressCircleFillCircle(center: Offset(18, 18), radius: 17, strokeWidth: 2),
        ],
      ),
    ),
    HeroProgressCircle(value: 60, semanticLabel: 'Default circle'),
    HeroProgressCircle(
      value: 60,
      semanticLabel: 'Thick circle',
      child: HeroProgressCircleTrack(
        strokeWidth: 6,
        viewBox: Size(36, 36),
        children: <Widget>[
          HeroProgressCircleTrackCircle(center: Offset(18, 18), radius: 15, strokeWidth: 6),
          HeroProgressCircleFillCircle(center: Offset(18, 18), radius: 15, strokeWidth: 6),
        ],
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A 56 px sync indicator in neutral grays with a round-capped arc.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final bool dark = theme.isDark;
        return HeroProgressCircle(
          value: 68,
          dimension: theme.spacing(14),
          semanticLabel: 'Sync progress',
          child: HeroProgressCircleTrack(
            children: <Widget>[
              HeroProgressCircleTrackCircle(
                // neutral-800 / neutral-200
                color: dark ? oklch(0.269, 0, 0) : oklch(0.922, 0, 0),
              ),
              HeroProgressCircleFillCircle(
                // neutral-300 / neutral-700
                color: dark ? oklch(0.87, 0, 0) : oklch(0.371, 0, 0),
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final bool dark = theme.isDark;

HeroProgressCircle(
  value: 68,
  dimension: 56, // size-14
  semanticLabel: 'Sync progress',
  child: HeroProgressCircleTrack(
    children: <Widget>[
      HeroProgressCircleTrackCircle(
        color: dark ? oklch(0.269, 0, 0) : oklch(0.922, 0, 0),
      ),
      HeroProgressCircleFillCircle(
        color: dark ? oklch(0.87, 0, 0) : oklch(0.371, 0, 0),
        strokeCap: StrokeCap.round,
      ),
    ],
  ),
)''',
    ),
  ],
);
