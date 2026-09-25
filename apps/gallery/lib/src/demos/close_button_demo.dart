import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

Widget _captioned(BuildContext context, String caption, Widget child) {
  final HeroThemeData theme = HeroTheme.of(context);
  return Column(
    mainAxisSize: MainAxisSize.min,
    spacing: theme.spacing(2),
    children: <Widget>[
      child,
      Text(
        caption,
        style: theme.typography.xs.copyWith(color: theme.colors.muted),
      ),
    ],
  );
}

/// Gallery page of `HeroCloseButton`.
final ComponentDemo closeButtonDemo = ComponentDemo(
  slug: 'close-button',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['standard']),
      ToggleControl('isDisabled'),
      ToggleControl('isPending'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroCloseButton(
      variant: values.pick('variant', HeroCloseButtonVariant.values),
      isDisabled: values.toggle('isDisabled'),
      isPending: values.toggle('isPending'),
      onPressed: () {},
    ),
    code: (PlaygroundValues values) =>
        '''
HeroCloseButton(${values.toggle('isDisabled') ? '\n  isDisabled: true,' : ''}${values.toggle('isPending') ? '\n  isPending: true,' : ''}
  onPressed: () {},
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => HeroCloseButton(onPressed: () {}),
      code: 'HeroCloseButton(onPressed: () {})',
    ),
    DemoExample(
      title: 'Interactive',
      builder: (BuildContext context) => const _InteractiveExample(),
      code: '''
class Interactive extends StatefulWidget {
  const Interactive({super.key});

  @override
  State<Interactive> createState() => _InteractiveState();
}

class _InteractiveState extends State<Interactive> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        HeroCloseButton(
          semanticLabel: 'Close (clicked \$_count times)',
          onPressed: () => setState(() => _count++),
        ),
        Text(
          'Clicked: \$_count times',
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    );
  }
}''',
    ),
    DemoExample(
      title: 'With Custom Icon',
      builder: (BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          _captioned(
            context,
            'Custom Icon',
            HeroCloseButton(
              onPressed: () {},
              child: const HeroIcon(HeroIcons.circleXmark),
            ),
          ),
          _captioned(
            context,
            'Alternative Icon',
            HeroCloseButton(
              onPressed: () {},
              child: const HeroIcon(HeroIcons.xmark),
            ),
          ),
        ],
      ),
      code: '''
HeroCloseButton(
  onPressed: () {},
  child: const HeroIcon(HeroIcons.circleXmark),
)

HeroCloseButton(
  onPressed: () {},
  child: const HeroIcon(HeroIcons.xmark),
)''',
    ),
    DemoExample(
      title: 'Custom Styles',
      description:
          'Customization: 32 px, fully round, foreground icon on hover and '
          'a 0.95 press scale.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroCloseButton(
          onPressed: () {},
          style: HeroButtonStyle(
            height: theme.spacing(8),
            borderRadius: BorderRadius.circular(theme.radii.full),
            foregroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) => states.contains(WidgetState.hovered)
                  ? theme.colors.foreground
                  : null,
            ),
            pressedScale: 0.95,
          ),
        );
      },
      code: '''
final theme = HeroTheme.of(context);
HeroCloseButton(
  onPressed: () {},
  style: HeroButtonStyle(
    height: theme.spacing(8),
    borderRadius: BorderRadius.circular(theme.radii.full),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.hovered)
          ? theme.colors.foreground
          : null,
    ),
    pressedScale: 0.95,
  ),
)''',
    ),
  ],
);

class _InteractiveExample extends StatefulWidget {
  const _InteractiveExample();

  @override
  State<_InteractiveExample> createState() => _InteractiveExampleState();
}

class _InteractiveExampleState extends State<_InteractiveExample> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(4),
      children: <Widget>[
        HeroCloseButton(
          semanticLabel: 'Close (clicked $_count times)',
          onPressed: () => setState(() => _count++),
        ),
        Text(
          'Clicked: $_count times',
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    );
  }
}
