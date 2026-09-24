import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// A spinner with a muted caption below it (`text-xs text-muted`).
class _Captioned extends StatelessWidget {
  const _Captioned({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(2),
      children: <Widget>[
        child,
        Text(
          label,
          style: theme.typography.xs.copyWith(color: theme.colors.muted),
        ),
      ],
    );
  }
}

Widget _row(BuildContext context, List<Widget> children, {double gap = 8}) {
  return Wrap(
    spacing: HeroTheme.of(context).spacing(gap),
    runSpacing: HeroTheme.of(context).spacing(4),
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
}

/// Gallery page of `HeroSpinner`.
final ComponentDemo spinnerDemo = ComponentDemo(
  slug: 'spinner',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('size', <String>['sm', 'md', 'lg', 'xl'], initial: 'md'),
      OptionsControl('color', <String>[
        'current',
        'accent',
        'success',
        'warning',
        'danger',
      ], initial: 'accent'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroSpinner(
      size: values.pick('size', HeroSpinnerSize.values),
      color: values.pick('color', HeroSpinnerColor.values),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroSpinner(
  size: HeroSpinnerSize.${values.option('size')},
  color: HeroSpinnerColor.${values.option('color')},
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const HeroSpinner(),
      code: 'const HeroSpinner()',
    ),
    DemoExample(
      title: 'Colors',
      builder: (BuildContext context) => _row(context, const <Widget>[
        _Captioned(
          label: 'Current',
          child: HeroSpinner(color: HeroSpinnerColor.current),
        ),
        _Captioned(
          label: 'Accent',
          child: HeroSpinner(color: HeroSpinnerColor.accent),
        ),
        _Captioned(
          label: 'Success',
          child: HeroSpinner(color: HeroSpinnerColor.success),
        ),
        _Captioned(
          label: 'Warning',
          child: HeroSpinner(color: HeroSpinnerColor.warning),
        ),
        _Captioned(
          label: 'Danger',
          child: HeroSpinner(color: HeroSpinnerColor.danger),
        ),
      ]),
      code: '''
Wrap(
  spacing: 32,
  children: [
    HeroSpinner(color: HeroSpinnerColor.current),
    HeroSpinner(color: HeroSpinnerColor.accent),
    HeroSpinner(color: HeroSpinnerColor.success),
    HeroSpinner(color: HeroSpinnerColor.warning),
    HeroSpinner(color: HeroSpinnerColor.danger),
  ],
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => _row(context, const <Widget>[
        _Captioned(
          label: 'Small',
          child: HeroSpinner(size: HeroSpinnerSize.sm),
        ),
        _Captioned(
          label: 'Medium',
          child: HeroSpinner(size: HeroSpinnerSize.md),
        ),
        _Captioned(
          label: 'Large',
          child: HeroSpinner(size: HeroSpinnerSize.lg),
        ),
        _Captioned(
          label: 'Extra Large',
          child: HeroSpinner(size: HeroSpinnerSize.xl),
        ),
      ]),
      code: '''
Wrap(
  spacing: 32,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: [
    HeroSpinner(size: HeroSpinnerSize.sm),
    HeroSpinner(size: HeroSpinnerSize.md),
    HeroSpinner(size: HeroSpinnerSize.lg),
    HeroSpinner(size: HeroSpinnerSize.xl),
  ],
)''',
    ),
    DemoExample(
      title: 'Speed',
      description:
          'Change how fast a single spinner rotates with period. '
          'Spinners stay still when the platform asks for reduced motion.',
      builder: (BuildContext context) => _row(context, const <Widget>[
        _Captioned(
          label: 'Slow',
          child: HeroSpinner(period: Duration(milliseconds: 1500)),
        ),
        _Captioned(label: 'Default', child: HeroSpinner()),
        _Captioned(
          label: 'Fast',
          child: HeroSpinner(period: Duration(milliseconds: 400)),
        ),
      ]),
      code: '''
Wrap(
  spacing: 32,
  children: [
    HeroSpinner(period: Duration(milliseconds: 1500)), // Slow
    HeroSpinner(), // Default (750 ms)
    HeroSpinner(period: Duration(milliseconds: 400)), // Fast
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Styles',
      description: 'Customization',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return DecoratedBox(
          decoration: ShapeDecoration(
            color: theme.colors.surface,
            shape: theme.shapeAll(
              theme.radii.xl,
              side: BorderSide(color: theme.colors.border),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing(5),
              vertical: theme.spacing(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: theme.spacing(4),
              children: <Widget>[
                const HeroSpinner(size: HeroSpinnerSize.sm),
                HeroSpinner(colorOverride: theme.colors.muted),
                const HeroSpinner(
                  size: HeroSpinnerSize.lg,
                  color: HeroSpinnerColor.success,
                ),
              ],
            ),
          ),
        );
      },
      code: '''
final theme = HeroTheme.of(context);
DecoratedBox(
  decoration: ShapeDecoration(
    color: theme.colors.surface,
    shape: theme.shapeAll(
      theme.radii.xl,
      side: BorderSide(color: theme.colors.border),
    ),
  ),
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        HeroSpinner(size: HeroSpinnerSize.sm),
        HeroSpinner(colorOverride: theme.colors.muted),
        HeroSpinner(
          size: HeroSpinnerSize.lg,
          color: HeroSpinnerColor.success,
        ),
      ],
    ),
  ),
)''',
    ),
  ],
);
