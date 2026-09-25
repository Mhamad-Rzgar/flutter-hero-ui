import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

const String _sarahAvatar =
    'https://img.heroui.chat/image/avatar?w=400&h=400&u=1';

/// The title and muted paragraph of the basic examples.
List<Widget> _basicDialog(HeroThemeData theme, String title, String text) =>
    <Widget>[
      HeroPopoverHeading(child: Text(title)),
      SizedBox(height: theme.spacing(2)),
      Text(text, style: TextStyle(color: theme.colors.muted)),
    ];

/// A placement example trigger: a full-width tertiary button whose popover
/// has an arrow.
Widget _placed(String label, HeroPlacement placement) => HeroPopover(
  content: HeroPopoverContent(
    placement: placement,
    child: HeroPopoverDialog(
      children: <Widget>[const HeroPopoverArrow(), Text('$label placement')],
    ),
  ),
  child: HeroButton(
    variant: HeroButtonVariant.tertiary,
    fullWidth: true,
    child: Text(label),
  ),
);

/// The profile card of the "Interactive Content" example.
class _ProfileCard extends StatefulWidget {
  const _ProfileCard();

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    const TextStyle bold = TextStyle(fontWeight: HeroTypography.semibold);
    Widget stat(String value, String label) => Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: value, style: bold),
          TextSpan(text: ' $label', style: muted),
        ],
      ),
    );
    return HeroPopoverDialog(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        HeroPopoverHeading(
          child: Row(
            spacing: theme.spacing(3),
            children: <Widget>[
              HeroAvatar(
                children: <Widget>[
                  HeroAvatarImage.network(
                    _sarahAvatar,
                    semanticLabel: 'Sarah Johnson',
                  ),
                  const HeroAvatarFallback(child: Text('SJ')),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Sarah Johnson', style: bold),
                    Text('@sarahj', style: muted),
                  ],
                ),
              ),
              HeroButton(
                size: HeroSize.sm,
                variant: _following
                    ? HeroButtonVariant.tertiary
                    : HeroButtonVariant.primary,
                onPressed: () => setState(() => _following = !_following),
                child: Text(_following ? 'Following' : 'Follow'),
              ),
            ],
          ),
        ),
        SizedBox(height: theme.spacing(3)),
        Text(
          'Product designer and creative director. Building beautiful '
          'experiences that matter.',
          style: muted,
        ),
        SizedBox(height: theme.spacing(3)),
        Wrap(
          spacing: theme.spacing(4),
          children: <Widget>[
            stat('892', 'Following'),
            stat('12.5K', 'Followers'),
          ],
        ),
      ],
    );
  }
}

/// One shortcut row of the custom styles example.
class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow(this.label, this.keys);

  final String label;
  final String keys;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Row(
      spacing: theme.spacing(4),
      children: <Widget>[
        Expanded(
          child: Text(label, style: TextStyle(color: theme.colors.muted)),
        ),
        Text(
          keys,
          style: theme.typography.code.copyWith(
            // Tailwind neutral-700 / neutral-300.
            color: theme.isDark
                ? const Color(0xFFD4D4D4)
                : const Color(0xFF404040),
          ),
        ),
      ],
    );
  }
}

final ComponentDemo popoverDemo = ComponentDemo(
  slug: 'popover',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('placement', <String>[
        'bottom',
        'top',
        'left',
        'right',
        'start',
        'end',
        'bottomStart',
        'bottomEnd',
      ]),
      ToggleControl('arrow', initial: true),
      ToggleControl('isNonModal'),
      ToggleControl('shouldFlip', initial: true),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final HeroThemeData theme = HeroTheme.of(context);
      return HeroPopover(
        content: HeroPopoverContent(
          placement: values.pick('placement', HeroPlacement.values),
          isNonModal: values.toggle('isNonModal'),
          shouldFlip: values.toggle('shouldFlip'),
          constraints: BoxConstraints(maxWidth: theme.spacing(64)),
          child: HeroPopoverDialog(
            children: <Widget>[
              if (values.toggle('arrow')) const HeroPopoverArrow(),
              ..._basicDialog(
                theme,
                'Popover Title',
                'This is the popover content. You can put any content here.',
              ),
            ],
          ),
        ),
        child: const HeroButton(child: Text('Click me')),
      );
    },
    code: (PlaygroundValues values) {
      final List<String> args = <String>[
        if (values.option('placement') != 'bottom')
          'placement: HeroPlacement.${values.option('placement')}',
        if (values.toggle('isNonModal')) 'isNonModal: true',
        if (!values.toggle('shouldFlip')) 'shouldFlip: false',
        'constraints: const BoxConstraints(maxWidth: 256)',
      ];
      return '''
HeroPopover(
  content: HeroPopoverContent(
${args.map((String a) => '    $a,\n').join()}    child: HeroPopoverDialog(
      children: [${values.toggle('arrow') ? '\n        const HeroPopoverArrow(),' : ''}
        const HeroPopoverHeading(child: Text('Popover Title')),
        const SizedBox(height: 8),
        Text(
          'This is the popover content. You can put any content here.',
          style: TextStyle(color: theme.colors.muted),
        ),
      ],
    ),
  ),
  child: const HeroButton(child: Text('Click me')),
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroPopover(
          content: HeroPopoverContent(
            constraints: BoxConstraints(maxWidth: theme.spacing(64)),
            child: HeroPopoverDialog(
              children: _basicDialog(
                theme,
                'Popover Title',
                'This is the popover content. You can put any content here.',
              ),
            ),
          ),
          child: const HeroButton(child: Text('Click me')),
        );
      },
      code: '''
HeroPopover(
  content: HeroPopoverContent(
    constraints: const BoxConstraints(maxWidth: 256),
    child: HeroPopoverDialog(
      children: [
        const HeroPopoverHeading(child: Text('Popover Title')),
        const SizedBox(height: 8),
        Text(
          'This is the popover content. You can put any content here.',
          style: TextStyle(color: theme.colors.muted),
        ),
      ],
    ),
  ),
  child: const HeroButton(child: Text('Click me')),
)''',
    ),
    DemoExample(
      title: 'With Arrow',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        HeroPopoverDialog dialog() => HeroPopoverDialog(
          children: <Widget>[
            const HeroPopoverArrow(),
            ..._basicDialog(
              theme,
              'Popover with Arrow',
              'The arrow shows which element triggered the popover.',
            ),
          ],
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: theme.spacing(4),
          children: <Widget>[
            HeroPopover(
              content: HeroPopoverContent(
                constraints: BoxConstraints(maxWidth: theme.spacing(64)),
                child: dialog(),
              ),
              child: const HeroButton(
                variant: HeroButtonVariant.secondary,
                child: Text('With Arrow'),
              ),
            ),
            HeroPopover(
              content: HeroPopoverContent(
                offset: 10,
                constraints: BoxConstraints(maxWidth: theme.spacing(64)),
                child: dialog(),
              ),
              child: const HeroButton(
                isIconOnly: true,
                semanticLabel: 'More options',
                variant: HeroButtonVariant.tertiary,
                child: HeroIcon(HeroIcons.ellipsis),
              ),
            ),
          ],
        );
      },
      code: '''
HeroPopover(
  content: HeroPopoverContent(
    offset: 10,
    constraints: const BoxConstraints(maxWidth: 256),
    child: HeroPopoverDialog(
      children: [
        const HeroPopoverArrow(),
        const HeroPopoverHeading(child: Text('Popover with Arrow')),
        const SizedBox(height: 8),
        Text(
          'The arrow shows which element triggered the popover.',
          style: TextStyle(color: theme.colors.muted),
        ),
      ],
    ),
  ),
  child: const HeroButton(
    isIconOnly: true,
    semanticLabel: 'More options',
    variant: HeroButtonVariant.tertiary,
    child: HeroIcon(HeroIcons.ellipsis),
  ),
)''',
    ),
    DemoExample(
      title: 'Interactive Content',
      description:
          'HeroPopoverTrigger makes any content a trigger; the card inside '
          'stays interactive.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroPopover(
          content: HeroPopoverContent(
            constraints: BoxConstraints.tightFor(width: theme.spacing(80)),
            child: const _ProfileCard(),
          ),
          child: HeroPopoverTrigger(
            semanticsLabel: 'User profile',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: theme.spacing(2),
              children: <Widget>[
                HeroAvatar(
                  size: HeroSize.sm,
                  children: <Widget>[
                    HeroAvatarImage.network(
                      _sarahAvatar,
                      semanticLabel: 'Sarah Johnson',
                    ),
                    const HeroAvatarFallback(child: Text('SJ')),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Sarah Johnson',
                      style: theme.typography.sm.copyWith(
                        fontWeight: HeroTypography.medium,
                        color: theme.colors.foreground,
                      ),
                    ),
                    Text(
                      '@sarahj',
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      code: '''
HeroPopover(
  content: const HeroPopoverContent(
    constraints: BoxConstraints.tightFor(width: 320),
    child: ProfileCard(), // a HeroPopoverDialog with a Follow button
  ),
  child: HeroPopoverTrigger(
    semanticsLabel: 'User profile',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        HeroAvatar(
          size: HeroSize.sm,
          children: [
            HeroAvatarImage.network(avatarUrl, semanticLabel: 'Sarah Johnson'),
            const HeroAvatarFallback(child: Text('SJ')),
          ],
        ),
        const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Sarah Johnson'), Text('@sarahj')],
        ),
      ],
    ),
  ),
)

// Inside ProfileCard:
HeroButton(
  size: HeroSize.sm,
  variant: following ? HeroButtonVariant.tertiary : HeroButtonVariant.primary,
  onPressed: () => setState(() => following = !following),
  child: Text(following ? 'Following' : 'Follow'),
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
                      'Click buttons',
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
Widget placed(String label, HeroPlacement placement) => HeroPopover(
  content: HeroPopoverContent(
    placement: placement,
    child: HeroPopoverDialog(
      children: [const HeroPopoverArrow(), Text('\$label placement')],
    ),
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
        child: Text('Click buttons', textAlign: TextAlign.center),
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
      title: 'Render Function',
      description:
          'builder wraps the styled popover and receives its resolved '
          'placement.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroPopover(
          content: HeroPopoverContent(
            constraints: BoxConstraints(maxWidth: theme.spacing(64)),
            builder:
                (
                  BuildContext context,
                  HeroPopoverRenderState state,
                  Widget popover,
                ) => Semantics(identifier: 'foo', child: popover),
            child: HeroPopoverDialog(
              children: _basicDialog(
                theme,
                'Popover Title',
                'This is the popover content. You can put any content here.',
              ),
            ),
          ),
          child: const HeroButton(child: Text('Click me')),
        );
      },
      code: '''
HeroPopover(
  content: HeroPopoverContent(
    constraints: const BoxConstraints(maxWidth: 256),
    builder: (context, state, popover) =>
        Semantics(identifier: 'foo', child: popover),
    child: HeroPopoverDialog(
      children: [
        const HeroPopoverHeading(child: Text('Popover Title')),
        const SizedBox(height: 8),
        Text(
          'This is the popover content. You can put any content here.',
          style: TextStyle(color: theme.colors.muted),
        ),
      ],
    ),
  ),
  child: const HeroButton(child: Text('Click me')),
)''',
    ),
    DemoExample(
      title: 'Custom Styles',
      description:
          'A translucent, blurred surface with a border, a ring, a large '
          'shadow and a soft gradient at the top.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final bool dark = theme.isDark;
        return HeroPopover(
          content: HeroPopoverContent(
            constraints: BoxConstraints(maxWidth: theme.spacing(56)),
            clipBehavior: Clip.antiAlias,
            borderRadius: theme.radii.xl,
            backgroundColor: theme.colors.surface.withValues(
              alpha: dark ? 0.85 : 0.9,
            ),
            side: BorderSide(
              color: theme.colors.border.withValues(alpha: dark ? 0.9 : 0.8),
              width: theme.borderWidth,
            ),
            backdropBlur: theme.spacing(6),
            shadows: <BoxShadow>[
              // Tailwind `shadow-xl`.
              const BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 20),
                blurRadius: 25,
                spreadRadius: -5,
              ),
              const BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 8),
                blurRadius: 10,
                spreadRadius: -6,
              ),
              // `ring-1 ring-black/5` (`ring-white/10` in dark mode).
              BoxShadow(
                color: dark ? const Color(0x1AFFFFFF) : const Color(0x0D000000),
                spreadRadius: 1,
              ),
            ],
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: theme.spacing(12),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            // neutral-500/6 (neutral-400/8 in dark mode).
                            dark
                                ? const Color(0x14A3A3A3)
                                : const Color(0x0F737373),
                            const Color(0x00737373),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                HeroPopoverDialog(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    HeroPopoverHeading(
                      style: TextStyle(
                        // neutral-800 (neutral-100 in dark mode).
                        color: dark
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF262626),
                      ),
                      child: const Text('Keyboard shortcuts'),
                    ),
                    SizedBox(height: theme.spacing(3)),
                    const _ShortcutRow('Save', '⌘ S'),
                    SizedBox(height: theme.spacing(2)),
                    const _ShortcutRow('Search', '⌘ K'),
                  ],
                ),
              ],
            ),
          ),
          child: const HeroButton(
            variant: HeroButtonVariant.secondary,
            child: Text('Details'),
          ),
        );
      },
      code: '''
HeroPopover(
  content: HeroPopoverContent(
    constraints: const BoxConstraints(maxWidth: 224),
    clipBehavior: Clip.antiAlias,
    borderRadius: theme.radii.xl,
    backgroundColor: theme.colors.surface.withValues(alpha: 0.9),
    side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
    backdropBlur: 24,
    shadows: shadowXlWithRing,
    child: Stack(
      children: [
        const Positioned(
          left: 0, right: 0, top: 0, height: 48,
          child: TopGradient(),
        ),
        HeroPopoverDialog(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            HeroPopoverHeading(child: Text('Keyboard shortcuts')),
            SizedBox(height: 12),
            ShortcutRow('Save', '⌘ S'),
            SizedBox(height: 8),
            ShortcutRow('Search', '⌘ K'),
          ],
        ),
      ],
    ),
  ),
  child: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Details'),
  ),
)''',
    ),
  ],
);
