import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

final ComponentDemo chipDemo = ComponentDemo(
  slug: 'chip',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>[
        'primary',
        'secondary',
        'tertiary',
        'soft',
      ], initial: 'secondary'),
      OptionsControl('color', <String>[
        'standard',
        'accent',
        'success',
        'warning',
        'danger',
      ]),
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      ToggleControl('startContent'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroChip(
      variant: values.pick('variant', HeroChipVariant.values),
      color: values.pick('color', HeroColor.values),
      size: values.pick('size', HeroSize.values),
      startContent: values.toggle('startContent')
          ? const HeroIcon(HeroIcons.circleDashed)
          : null,
      label: 'Label',
    ),
    code: (PlaygroundValues values) {
      final List<String> args = <String>[
        if (values.option('variant') != 'secondary')
          'variant: HeroChipVariant.${values.option('variant')}',
        if (values.option('color') != 'standard')
          'color: HeroColor.${values.option('color')}',
        if (values.option('size') != 'md')
          'size: HeroSize.${values.option('size')}',
        if (values.toggle('startContent'))
          'startContent: HeroIcon(HeroIcons.circleDashed)',
        "label: 'Label'",
      ];
      return 'HeroChip(\n${args.map((String a) => '  $a,\n').join()})';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          HeroChip(label: 'Default'),
          HeroChip(color: HeroColor.accent, label: 'Accent'),
          HeroChip(color: HeroColor.success, label: 'Success'),
          HeroChip(color: HeroColor.warning, label: 'Warning'),
          HeroChip(color: HeroColor.danger, label: 'Danger'),
        ],
      ),
      code: '''
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: <Widget>[
    HeroChip(label: 'Default'),
    HeroChip(color: HeroColor.accent, label: 'Accent'),
    HeroChip(color: HeroColor.success, label: 'Success'),
    HeroChip(color: HeroColor.warning, label: 'Warning'),
    HeroChip(color: HeroColor.danger, label: 'Danger'),
  ],
)''',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) => const _VariantsMatrix(),
      code: r'''
for (final HeroSize size in <HeroSize>[HeroSize.lg, HeroSize.md, HeroSize.sm])
  for (final HeroChipVariant variant in HeroChipVariant.values)
    Row(
      spacing: 12,
      children: <Widget>[
        SizedBox(width: 96, child: Text(variant.name)),
        for (final HeroColor color in colors)
          SizedBox(
            width: 130,
            child: Center(
              child: HeroChip(
                color: color,
                size: size,
                variant: variant,
                startContent: HeroIcon(HeroIcons.circleDashed),
                label: 'Label',
                endContent: HeroIcon(HeroIcons.circleDashed),
              ),
            ),
          ),
      ],
    ),
// Sizes are separated with a HeroSeparator.''',
    ),
    DemoExample(
      title: 'Statuses',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              HeroChip(
                variant: HeroChipVariant.primary,
                startContent: HeroIcon(HeroIcons.circleFill, size: 6),
                label: 'Default',
              ),
              HeroChip(
                color: HeroColor.success,
                variant: HeroChipVariant.primary,
                startContent: HeroIcon(HeroIcons.circleFill, size: 6),
                label: 'Active',
              ),
              HeroChip(
                color: HeroColor.warning,
                variant: HeroChipVariant.primary,
                startContent: HeroIcon(HeroIcons.circleFill, size: 6),
                label: 'Pending',
              ),
              HeroChip(
                color: HeroColor.danger,
                variant: HeroChipVariant.primary,
                startContent: HeroIcon(HeroIcons.circleFill, size: 6),
                label: 'Inactive',
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              HeroChip(
                startContent: HeroIcon(HeroIcons.circleInfo, size: 12),
                label: 'New Feature',
              ),
              HeroChip(
                color: HeroColor.success,
                startContent: HeroIcon(HeroIcons.check, size: 12),
                label: 'Available',
              ),
              HeroChip(
                color: HeroColor.warning,
                startContent: HeroIcon(HeroIcons.triangleExclamation, size: 12),
                label: 'Beta',
              ),
              HeroChip(
                color: HeroColor.danger,
                startContent: HeroIcon(HeroIcons.ban, size: 12),
                label: 'Deprecated',
              ),
            ],
          ),
        ],
      ),
      code: '''
HeroChip(
  color: HeroColor.success,
  variant: HeroChipVariant.primary,
  startContent: HeroIcon(HeroIcons.circleFill, size: 6),
  label: 'Active',
)

HeroChip(
  color: HeroColor.warning,
  startContent: HeroIcon(HeroIcons.triangleExclamation, size: 12),
  label: 'Beta',
)''',
    ),
    DemoExample(
      title: 'With Icons',
      builder: (BuildContext context) => const Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          HeroChip(
            startContent: HeroIcon(HeroIcons.circleFill, size: 6),
            label: 'Information',
          ),
          HeroChip(
            color: HeroColor.success,
            startContent: HeroIcon(HeroIcons.circleCheckFill, size: 12),
            label: 'Completed',
          ),
          HeroChip(
            color: HeroColor.warning,
            startContent: HeroIcon(HeroIcons.clock, size: 12),
            label: 'Pending',
          ),
          HeroChip(
            color: HeroColor.danger,
            startContent: HeroIcon(HeroIcons.xmark, size: 12),
            label: 'Failed',
          ),
          HeroChip(
            color: HeroColor.accent,
            label: 'Label',
            endContent: HeroIcon(HeroIcons.chevronDown, size: 12),
          ),
        ],
      ),
      code: '''
Wrap(
  spacing: 12,
  runSpacing: 12,
  children: <Widget>[
    HeroChip(
      startContent: HeroIcon(HeroIcons.circleFill, size: 6),
      label: 'Information',
    ),
    HeroChip(
      color: HeroColor.success,
      startContent: HeroIcon(HeroIcons.circleCheckFill, size: 12),
      label: 'Completed',
    ),
    HeroChip(
      color: HeroColor.warning,
      startContent: HeroIcon(HeroIcons.clock, size: 12),
      label: 'Pending',
    ),
    HeroChip(
      color: HeroColor.danger,
      startContent: HeroIcon(HeroIcons.xmark, size: 12),
      label: 'Failed',
    ),
    HeroChip(
      color: HeroColor.accent,
      label: 'Label',
      endContent: HeroIcon(HeroIcons.chevronDown, size: 12),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final EdgeInsets padding = EdgeInsets.symmetric(
          horizontal: theme.spacing(3),
          vertical: theme.spacing(0.5),
        );
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final (HeroColor color, String label)
                in const <(HeroColor, String)>[
                  (HeroColor.standard, 'Draft'),
                  (HeroColor.warning, 'In review'),
                  (HeroColor.success, 'Published'),
                ])
              HeroChip(
                variant: HeroChipVariant.soft,
                color: color,
                radius: theme.radii.full,
                padding: padding,
                label: label,
              ),
          ],
        );
      },
      code: '''
Wrap(
  spacing: 8,
  children: <Widget>[
    HeroChip(
      variant: HeroChipVariant.soft,
      radius: theme.radii.full,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      label: 'Draft',
    ),
    HeroChip(
      variant: HeroChipVariant.soft,
      color: HeroColor.warning,
      radius: theme.radii.full,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      label: 'In review',
    ),
    HeroChip(
      variant: HeroChipVariant.soft,
      color: HeroColor.success,
      radius: theme.radii.full,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      label: 'Published',
    ),
  ],
)''',
    ),
  ],
);

const List<HeroColor> _colors = <HeroColor>[
  HeroColor.accent,
  HeroColor.standard,
  HeroColor.success,
  HeroColor.warning,
  HeroColor.danger,
];

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _colorName(HeroColor color) =>
    color == HeroColor.standard ? 'Default' : _capitalize(color.name);

class _VariantsMatrix extends StatelessWidget {
  const _VariantsMatrix();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    const double column = 130;
    final double labelWidth = theme.spacing(24);
    final double gap = theme.spacing(3);
    final double width = labelWidth + (column + gap) * _colors.length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(8),
          children: <Widget>[
            for (final (int index, HeroSize size) in const <HeroSize>[
              HeroSize.lg,
              HeroSize.md,
              HeroSize.sm,
            ].indexed) ...<Widget>[
              if (index > 0) const HeroSeparator(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: theme.spacing(4),
                children: <Widget>[
                  Text(
                    _capitalize(size.name),
                    style: muted.copyWith(fontWeight: HeroTypography.semibold),
                  ),
                  Row(
                    spacing: gap,
                    children: <Widget>[
                      SizedBox(width: labelWidth),
                      for (final HeroColor color in _colors)
                        SizedBox(
                          width: column,
                          child: Center(
                            child: Text(
                              _colorName(color),
                              style: theme.typography.xs.copyWith(
                                color: theme.colors.muted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  for (final HeroChipVariant variant in HeroChipVariant.values)
                    Row(
                      spacing: gap,
                      children: <Widget>[
                        SizedBox(
                          width: labelWidth,
                          child: Text(_capitalize(variant.name), style: muted),
                        ),
                        for (final HeroColor color in _colors)
                          SizedBox(
                            width: column,
                            child: Center(
                              child: HeroChip(
                                color: color,
                                size: size,
                                variant: variant,
                                startContent: const HeroIcon(
                                  HeroIcons.circleDashed,
                                ),
                                label: 'Label',
                                endContent: const HeroIcon(
                                  HeroIcons.circleDashed,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
