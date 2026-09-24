import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

final ComponentDemo toggleButtonDemo = ComponentDemo(
  slug: 'toggle-button',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['standard', 'ghost']),
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      ToggleControl('isIconOnly'),
      ToggleControl('defaultSelected'),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final bool iconOnly = values.toggle('isIconOnly');
      return HeroToggleButton(
        // A new key restarts the uncontrolled state when the default changes.
        key: ValueKey<bool>(values.toggle('defaultSelected')),
        variant: values.pick('variant', HeroToggleButtonVariant.values),
        size: values.pick('size', HeroSize.values),
        isIconOnly: iconOnly,
        defaultSelected: values.toggle('defaultSelected'),
        isDisabled: values.toggle('isDisabled'),
        semanticLabel: iconOnly ? 'Like' : null,
        startContent: iconOnly ? null : const HeroIcon(HeroIcons.heart),
        child: iconOnly ? const HeroIcon(HeroIcons.heart) : const Text('Like'),
      );
    },
    code: (PlaygroundValues values) {
      final bool iconOnly = values.toggle('isIconOnly');
      return '''
HeroToggleButton(
  variant: HeroToggleButtonVariant.${values.option('variant')},
  size: HeroSize.${values.option('size')},
  isIconOnly: $iconOnly,
  defaultSelected: ${values.toggle('defaultSelected')},
  isDisabled: ${values.toggle('isDisabled')},
${iconOnly ? "  semanticLabel: 'Like',\n  child: const HeroIcon(HeroIcons.heart)," : "  startContent: const HeroIcon(HeroIcons.heart),\n  child: const Text('Like'),"}
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const HeroToggleButton(
        startContent: HeroIcon(HeroIcons.heart),
        child: Text('Like'),
      ),
      code: '''
HeroToggleButton(
  startContent: const HeroIcon(HeroIcons.heart),
  child: const Text('Like'),
)''',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) => const Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          HeroToggleButton(
            startContent: HeroIcon(HeroIcons.heart),
            child: Text('Default'),
          ),
          HeroToggleButton(
            variant: HeroToggleButtonVariant.ghost,
            startContent: HeroIcon(HeroIcons.heart),
            child: Text('Ghost'),
          ),
        ],
      ),
      code: '''
Row(
  spacing: 12,
  children: <Widget>[
    HeroToggleButton(
      startContent: const HeroIcon(HeroIcons.heart),
      child: const Text('Default'),
    ),
    HeroToggleButton(
      variant: HeroToggleButtonVariant.ghost,
      startContent: const HeroIcon(HeroIcons.heart),
      child: const Text('Ghost'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Icon Only',
      builder: (BuildContext context) => const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          HeroToggleButton(
            isIconOnly: true,
            semanticLabel: 'Like',
            child: HeroIcon(HeroIcons.heart),
          ),
          HeroToggleButton(
            isIconOnly: true,
            semanticLabel: 'Bookmark',
            variant: HeroToggleButtonVariant.ghost,
            child: HeroIcon(HeroIcons.bookmark),
          ),
        ],
      ),
      code: '''
Row(
  spacing: 12,
  children: <Widget>[
    HeroToggleButton(
      isIconOnly: true,
      semanticLabel: 'Like',
      child: const HeroIcon(HeroIcons.heart),
    ),
    HeroToggleButton(
      isIconOnly: true,
      semanticLabel: 'Bookmark',
      variant: HeroToggleButtonVariant.ghost,
      child: const HeroIcon(HeroIcons.bookmark),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final (HeroSize size, String label) in <(HeroSize, String)>[
                (HeroSize.sm, 'Small'),
                (HeroSize.md, 'Medium'),
                (HeroSize.lg, 'Large'),
              ])
                HeroToggleButton(
                  size: size,
                  startContent: const HeroIcon(HeroIcons.heart),
                  child: Text(label),
                ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              for (final HeroSize size in HeroSize.values)
                HeroToggleButton(
                  size: size,
                  isIconOnly: true,
                  semanticLabel: 'Like',
                  child: const HeroIcon(HeroIcons.heart),
                ),
            ],
          ),
        ],
      ),
      code: '''
Column(
  spacing: 24,
  children: <Widget>[
    Row(
      spacing: 12,
      children: <Widget>[
        HeroToggleButton(
          size: HeroSize.sm,
          startContent: const HeroIcon(HeroIcons.heart),
          child: const Text('Small'),
        ),
        HeroToggleButton(
          size: HeroSize.md,
          startContent: const HeroIcon(HeroIcons.heart),
          child: const Text('Medium'),
        ),
        HeroToggleButton(
          size: HeroSize.lg,
          startContent: const HeroIcon(HeroIcons.heart),
          child: const Text('Large'),
        ),
      ],
    ),
    Row(
      spacing: 12,
      children: <Widget>[
        for (final HeroSize size in HeroSize.values)
          HeroToggleButton(
            size: size,
            isIconOnly: true,
            semanticLabel: 'Like',
            child: const HeroIcon(HeroIcons.heart),
          ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => const Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          HeroToggleButton(
            isDisabled: true,
            startContent: HeroIcon(HeroIcons.heart),
            child: Text('Like'),
          ),
          HeroToggleButton(
            isDisabled: true,
            defaultSelected: true,
            startContent: HeroIcon(HeroIcons.heartFill),
            child: Text('Like'),
          ),
        ],
      ),
      code: '''
Row(
  spacing: 12,
  children: <Widget>[
    HeroToggleButton(
      isDisabled: true,
      startContent: const HeroIcon(HeroIcons.heart),
      child: const Text('Like'),
    ),
    HeroToggleButton(
      isDisabled: true,
      defaultSelected: true,
      startContent: const HeroIcon(HeroIcons.heartFill),
      child: const Text('Like'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledToggleButton(),
      code: r'''
bool isSelected = false;

Column(
  spacing: 16,
  children: <Widget>[
    HeroToggleButton(
      isSelected: isSelected,
      onChanged: (bool value) => setState(() => isSelected = value),
      startContent: HeroIcon(
        isSelected ? HeroIcons.heartFill : HeroIcons.heart,
      ),
      builder: (BuildContext context, HeroToggleButtonState state) =>
          Text(state.isSelected ? 'Liked' : 'Like'),
    ),
    Text('Status: ${isSelected ? 'Selected' : 'Not selected'}'),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'Style overrides replace the pill fill with a bordered surface.',
      builder: (BuildContext context) => const _CustomToggleButton(),
      code: '''
final HeroColors colors = HeroTheme.of(context).colors;

HeroToggleButton(
  style: HeroToggleButtonStyle(
    borderRadius: const BorderRadius.all(Radius.circular(9999)),
    shadows: HeroTheme.of(context).shadows.surface.boxShadows,
    backgroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? colors.accentSoft
          : colors.surface,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? colors.accentSoftForeground
          : colors.foreground,
    ),
    iconColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.selected)
          ? colors.accent
          : colors.muted,
    ),
    side: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => BorderSide(
        color: states.contains(WidgetState.selected)
            ? colors.accent.withValues(alpha: 0.3)
            : colors.border.withValues(alpha: 0.8),
      ),
    ),
  ),
  startContent: const HeroIcon(HeroIcons.heart),
  child: const Text('Save article'),
)''',
    ),
  ],
);

class _ControlledToggleButton extends StatefulWidget {
  const _ControlledToggleButton();

  @override
  State<_ControlledToggleButton> createState() =>
      _ControlledToggleButtonState();
}

class _ControlledToggleButtonState extends State<_ControlledToggleButton> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        HeroToggleButton(
          isSelected: _isSelected,
          onChanged: (bool value) => setState(() => _isSelected = value),
          startContent: HeroIcon(
            _isSelected ? HeroIcons.heartFill : HeroIcons.heart,
          ),
          builder: (BuildContext context, HeroToggleButtonState state) =>
              Text(state.isSelected ? 'Liked' : 'Like'),
        ),
        Text.rich(
          TextSpan(
            text: 'Status: ',
            children: <InlineSpan>[
              TextSpan(
                text: _isSelected ? 'Selected' : 'Not selected',
                style: const TextStyle(fontWeight: HeroTypography.medium),
              ),
            ],
          ),
          style: muted,
        ),
      ],
    );
  }
}

class _CustomToggleButton extends StatelessWidget {
  const _CustomToggleButton();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    bool selected(Set<WidgetState> states) =>
        states.contains(WidgetState.selected);
    return HeroToggleButton(
      style: HeroToggleButtonStyle(
        borderRadius: BorderRadius.all(Radius.circular(theme.radii.full)),
        shadows: theme.shadows.surface.boxShadows,
        backgroundColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              selected(states) ? colors.accentSoft : colors.surface,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => selected(states)
              ? colors.accentSoftForeground
              : colors.foreground,
        ),
        iconColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) =>
              selected(states) ? colors.accent : colors.muted,
        ),
        side: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => BorderSide(
            color: selected(states)
                ? colors.accent.withValues(alpha: colors.accent.a * 0.3)
                : colors.border.withValues(alpha: colors.border.a * 0.8),
          ),
        ),
      ),
      startContent: const HeroIcon(HeroIcons.heart),
      child: const Text('Save article'),
    );
  }
}
