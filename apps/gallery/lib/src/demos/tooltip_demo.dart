import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _janeAvatar =
    'https://img.heroui.chat/image/avatar?w=400&h=400&u=4';

/// Tailwind `shadow-sm`.
const List<BoxShadow> _shadowSm = <BoxShadow>[
  BoxShadow(color: Color(0x1A000000), offset: Offset(0, 1), blurRadius: 3),
  BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: -1,
  ),
];

/// A placement example trigger: a full-width tertiary button whose tooltip
/// has an arrow.
Widget _placed(String label, HeroPlacement placement) => HeroTooltip(
  delay: Duration.zero,
  content: HeroTooltipContent(
    showArrow: true,
    placement: placement,
    child: Text('$label placement'),
  ),
  child: HeroButton(
    variant: HeroButtonVariant.tertiary,
    fullWidth: true,
    child: Text(label),
  ),
);

/// The pinging status dot of the custom trigger example (`animate-ping`).
class _PingDot extends StatefulWidget {
  const _PingDot();

  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot>
    with SingleTickerProviderStateMixin {
  // Tailwind's `animate-ping`: 1 s, cubic-bezier(0, 0, .2, 1).
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final HeroThemeData theme = HeroTheme.of(context);
    if (theme.motion.shouldReduceMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double size = theme.spacing(2);
    final Widget dot = DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colors.success,
        shape: const CircleBorder(),
      ),
      child: SizedBox.square(dimension: size),
    );
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              // Keyframes: 75%, 100% { scale: 2; opacity: 0 }.
              final double t = HeroMotion.easeOut.transform(
                (_controller.value / 0.75).clamp(0.0, 1.0),
              );
              return Opacity(
                opacity: 0.75 * (1 - t),
                child: Transform.scale(scale: 1 + t, child: child),
              );
            },
            child: dot,
          ),
          dot,
        ],
      ),
    );
  }
}

final ComponentDemo tooltipDemo = ComponentDemo(
  slug: 'tooltip',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('placement', <String>[
        'top',
        'bottom',
        'left',
        'right',
        'start',
        'end',
      ]),
      OptionsControl('trigger', <String>['hover', 'focus']),
      OptionsControl('delay', <String>['0', 'theme']),
      ToggleControl('showArrow', initial: true),
      ToggleControl('isDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroTooltip(
      delay: values.option('delay') == '0' ? Duration.zero : null,
      trigger: values.pick('trigger', HeroTooltipTriggerMode.values),
      isDisabled: values.toggle('isDisabled'),
      content: HeroTooltipContent(
        placement: values.pick('placement', HeroPlacement.values),
        showArrow: values.toggle('showArrow'),
        child: const Text('Helpful information about this element'),
      ),
      child: const HeroButton(
        variant: HeroButtonVariant.secondary,
        child: Text('Hover for tooltip'),
      ),
    ),
    code: (PlaygroundValues values) {
      final List<String> args = <String>[
        if (values.option('delay') == '0') 'delay: Duration.zero',
        if (values.option('trigger') != 'hover')
          'trigger: HeroTooltipTriggerMode.${values.option('trigger')}',
        if (values.toggle('isDisabled')) 'isDisabled: true',
      ];
      final List<String> content = <String>[
        if (values.option('placement') != 'top')
          'placement: HeroPlacement.${values.option('placement')}',
        if (values.toggle('showArrow')) 'showArrow: true',
      ];
      return '''
HeroTooltip(
${args.map((String a) => '  $a,\n').join()}  content: const HeroTooltipContent(
${content.map((String a) => '    $a,\n').join()}    child: Text('Helpful information about this element'),
  ),
  child: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Hover for tooltip'),
  ),
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      description:
          'Hover or focus a trigger. On touch screens, long-press it; the '
          'next tap closes the tooltip.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing(4),
          children: const <Widget>[
            HeroTooltip(
              delay: Duration.zero,
              content: Text('This is a tooltip'),
              child: HeroButton(
                variant: HeroButtonVariant.secondary,
                child: Text('Hover me'),
              ),
            ),
            HeroTooltip(
              delay: Duration.zero,
              content: Text('More information'),
              child: HeroButton(
                isIconOnly: true,
                semanticLabel: 'More information',
                variant: HeroButtonVariant.tertiary,
                child: HeroIcon(HeroIcons.circleInfo),
              ),
            ),
          ],
        );
      },
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: const [
    HeroTooltip(
      delay: Duration.zero,
      content: Text('This is a tooltip'),
      child: HeroButton(
        variant: HeroButtonVariant.secondary,
        child: Text('Hover me'),
      ),
    ),
    HeroTooltip(
      delay: Duration.zero,
      content: Text('More information'),
      child: HeroButton(
        isIconOnly: true,
        semanticLabel: 'More information',
        variant: HeroButtonVariant.tertiary,
        child: HeroIcon(HeroIcons.circleInfo),
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Placement',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final double gap = theme.spacing(4);
        Widget cell(Widget child) => Expanded(child: child);
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: theme.spacing(96)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: gap,
            children: <Widget>[
              Row(
                spacing: gap,
                children: <Widget>[
                  cell(const SizedBox()),
                  cell(_placed('Top', HeroPlacement.top)),
                  cell(const SizedBox()),
                ],
              ),
              Row(
                spacing: gap,
                children: <Widget>[
                  cell(_placed('Left', HeroPlacement.left)),
                  cell(
                    Text(
                      'Hover buttons',
                      textAlign: TextAlign.center,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.muted,
                      ),
                    ),
                  ),
                  cell(_placed('Right', HeroPlacement.right)),
                ],
              ),
              Row(
                spacing: gap,
                children: <Widget>[
                  cell(const SizedBox()),
                  cell(_placed('Bottom', HeroPlacement.bottom)),
                  cell(const SizedBox()),
                ],
              ),
            ],
          ),
        );
      },
      code: '''
Widget placed(String label, HeroPlacement placement) => HeroTooltip(
  delay: Duration.zero,
  content: HeroTooltipContent(
    showArrow: true,
    placement: placement,
    child: Text('\$label placement'),
  ),
  child: HeroButton(
    variant: HeroButtonVariant.tertiary,
    fullWidth: true,
    child: Text(label),
  ),
);

Column(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: [
    Row(spacing: 16, children: [
      const Expanded(child: SizedBox()),
      Expanded(child: placed('Top', HeroPlacement.top)),
      const Expanded(child: SizedBox()),
    ]),
    Row(spacing: 16, children: [
      Expanded(child: placed('Left', HeroPlacement.left)),
      const Expanded(
        child: Text('Hover buttons', textAlign: TextAlign.center),
      ),
      Expanded(child: placed('Right', HeroPlacement.right)),
    ]),
    Row(spacing: 16, children: [
      const Expanded(child: SizedBox()),
      Expanded(child: placed('Bottom', HeroPlacement.bottom)),
      const Expanded(child: SizedBox()),
    ]),
  ],
)''',
    ),
    DemoExample(
      title: 'With Arrow',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing(4),
          children: const <Widget>[
            HeroTooltip(
              delay: Duration.zero,
              content: HeroTooltipContent(
                showArrow: true,
                child: Text('Tooltip with arrow indicator'),
              ),
              child: HeroButton(
                variant: HeroButtonVariant.secondary,
                child: Text('With Arrow'),
              ),
            ),
            HeroTooltip(
              delay: Duration.zero,
              content: HeroTooltipContent(
                showArrow: true,
                offset: 12,
                child: Text('Custom offset from trigger'),
              ),
              child: HeroButton(child: Text('Custom Offset')),
            ),
          ],
        );
      },
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: const [
    HeroTooltip(
      delay: Duration.zero,
      content: HeroTooltipContent(
        showArrow: true,
        child: Text('Tooltip with arrow indicator'),
      ),
      child: HeroButton(
        variant: HeroButtonVariant.secondary,
        child: Text('With Arrow'),
      ),
    ),
    HeroTooltip(
      delay: Duration.zero,
      content: HeroTooltipContent(
        showArrow: true,
        offset: 12,
        child: Text('Custom offset from trigger'),
      ),
      child: HeroButton(child: Text('Custom Offset')),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Triggers',
      description:
          'HeroTooltipTrigger makes any content a focusable trigger with a '
          'focus ring.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final TextStyle muted = TextStyle(color: theme.colors.muted);
        return Wrap(
          spacing: theme.spacing(6),
          runSpacing: theme.spacing(4),
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            HeroTooltip(
              delay: Duration.zero,
              content: HeroTooltipContent(
                showArrow: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: theme.spacing(1)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Jane Doe',
                        style: TextStyle(fontWeight: HeroTypography.semibold),
                      ),
                      Text('jane@example.com', style: muted),
                    ],
                  ),
                ),
              ),
              child: HeroTooltipTrigger(
                semanticsLabel: 'User avatar',
                child: HeroAvatar(
                  size: HeroSize.sm,
                  children: <Widget>[
                    HeroAvatarImage.network(
                      _janeAvatar,
                      semanticLabel: 'Jane Doe',
                    ),
                    const HeroAvatarFallback(child: Text('JD')),
                  ],
                ),
              ),
            ),
            HeroTooltip(
              delay: Duration.zero,
              content: HeroTooltipContent(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: theme.spacing(1.5),
                  children: const <Widget>[
                    _PingDot(),
                    Text('Jane is currently online'),
                  ],
                ),
              ),
              child: HeroTooltipTrigger(
                semanticsLabel: 'Status chip',
                child: HeroChip(
                  color: HeroColor.success,
                  startContent: HeroIcon(
                    HeroIcons.circleCheckFill,
                    size: theme.spacing(3),
                  ),
                  label: 'Active',
                ),
              ),
            ),
            HeroTooltip(
              delay: Duration.zero,
              content: HeroTooltipContent(
                showArrow: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: theme.spacing(80)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing(1),
                      vertical: theme.spacing(1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: theme.spacing(1),
                      children: <Widget>[
                        const Text(
                          'Help Information',
                          style: TextStyle(fontWeight: HeroTypography.semibold),
                        ),
                        Text(
                          'This is a helpful tooltip with more detailed '
                          'information about this feature.',
                          style: theme.typography.sm.merge(muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: HeroTooltipTrigger(
                semanticsLabel: 'Info icon',
                shape: const CircleBorder(),
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: theme.colors.accentSoft,
                    shape: const CircleBorder(),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacing(2)),
                    child: HeroIcon(
                      HeroIcons.circleQuestion,
                      color: theme.colors.accentSoftForeground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      code: '''
// Avatar: name and email.
HeroTooltip(
  delay: Duration.zero,
  content: HeroTooltipContent(
    showArrow: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jane Doe',
          style: TextStyle(fontWeight: HeroTypography.semibold),
        ),
        Text('jane@example.com', style: TextStyle(color: theme.colors.muted)),
      ],
    ),
  ),
  child: HeroTooltipTrigger(
    semanticsLabel: 'User avatar',
    child: HeroAvatar(
      size: HeroSize.sm,
      children: [
        HeroAvatarImage.network(avatarUrl, semanticLabel: 'Jane Doe'),
        const HeroAvatarFallback(child: Text('JD')),
      ],
    ),
  ),
)

// Chip: a pinging status dot.
HeroTooltip(
  delay: Duration.zero,
  content: const HeroTooltipContent(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [PingDot(), Text('Jane is currently online')],
    ),
  ),
  child: const HeroTooltipTrigger(
    semanticsLabel: 'Status chip',
    child: HeroChip(
      color: HeroColor.success,
      startContent: HeroIcon(HeroIcons.circleCheckFill, size: 12),
      label: 'Active',
    ),
  ),
)

// Round icon: title and paragraph.
HeroTooltip(
  delay: Duration.zero,
  content: HeroTooltipContent(
    showArrow: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text('Help Information', style: TextStyle(fontWeight: HeroTypography.semibold)),
        Text('This is a helpful tooltip with more detailed information about this feature.', style: ...),
      ],
    ),
  ),
  child: HeroTooltipTrigger(
    semanticsLabel: 'Info icon',
    shape: const CircleBorder(),
    child: /* accent-soft circle with HeroIcons.circleQuestion */,
  ),
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'builder wraps the styled tooltip and receives its resolved '
          'placement.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        Widget render(
          BuildContext context,
          HeroTooltipRenderState state,
          Widget tooltip,
        ) => Semantics(identifier: 'foo', child: tooltip);
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing(4),
          children: <Widget>[
            HeroTooltip(
              delay: Duration.zero,
              content: HeroTooltipContent(
                builder: render,
                child: const Text('This is a tooltip'),
              ),
              child: const HeroButton(
                variant: HeroButtonVariant.secondary,
                child: Text('Hover me'),
              ),
            ),
            HeroTooltip(
              delay: Duration.zero,
              content: HeroTooltipContent(
                builder: render,
                child: const Text('More information'),
              ),
              child: const HeroButton(
                isIconOnly: true,
                semanticLabel: 'More information',
                variant: HeroButtonVariant.tertiary,
                child: HeroIcon(HeroIcons.circleInfo),
              ),
            ),
          ],
        );
      },
      code: '''
HeroTooltip(
  delay: Duration.zero,
  content: HeroTooltipContent(
    builder: (context, state, tooltip) =>
        Semantics(identifier: 'foo', child: tooltip),
    child: const Text('This is a tooltip'),
  ),
  child: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Hover me'),
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Styles',
      description:
          'A surface-colored tooltip with a border, 8 px radius and a small '
          'shadow.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroTooltip(
          delay: Duration.zero,
          content: HeroTooltipContent(
            backgroundColor: theme.colors.surface,
            foregroundColor: theme.colors.foreground,
            side: BorderSide(
              color: theme.colors.border.withValues(alpha: 0.8),
              width: theme.borderWidth,
            ),
            borderRadius: theme.radii.lg,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing(2.5),
              vertical: theme.spacing(1),
            ),
            shadows: _shadowSm,
            child: const Text('Copied to clipboard'),
          ),
          child: const HeroButton(
            variant: HeroButtonVariant.secondary,
            child: Text('Share link'),
          ),
        );
      },
      code: '''
HeroTooltip(
  delay: Duration.zero,
  content: HeroTooltipContent(
    backgroundColor: theme.colors.surface,
    foregroundColor: theme.colors.foreground,
    side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
    borderRadius: theme.radii.lg,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shadows: shadowSm,
    child: const Text('Copied to clipboard'),
  ),
  child: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Share link'),
  ),
)''',
    ),
  ],
);
