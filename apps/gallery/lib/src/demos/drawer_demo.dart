import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

String _capitalize(String value) => value[0].toUpperCase() + value.substring(1);

Widget _secondary(String label) =>
    HeroButton(variant: HeroButtonVariant.secondary, child: Text(label));

const List<Widget> _cancelConfirm = <Widget>[
  HeroButton(
    slot: HeroButtonSlot.close,
    variant: HeroButtonVariant.secondary,
    child: Text('Cancel'),
  ),
  HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
];

/// A titled block of the "Controlled State" example.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.spacing(3),
      children: <Widget>[
        Text(
          title,
          style: theme.typography
              .style(HeroFontSize.lg, weight: HeroTypography.semibold)
              .copyWith(color: theme.colors.foreground),
        ),
        Text(
          description,
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
        child,
      ],
    );
  }
}

/// One row of the navigation drawer example.
class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label});

  final HeroIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroInteractable(
      onPressed: () {},
      builder: (BuildContext context, HeroInteractionState state, _) =>
          AnimatedContainer(
            duration: theme.motion.resolve(context, HeroMotion.normal),
            curve: HeroMotion.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing(3),
              vertical: theme.spacing(2.5),
            ),
            decoration: ShapeDecoration(
              color: state.isHovered
                  ? theme.colors.defaultColor
                  : theme.colors.defaultColor.withValues(alpha: 0),
              shape: theme.shapeAll(theme.radii.xl),
            ),
            child: Row(
              spacing: theme.spacing(3),
              children: <Widget>[
                HeroIcon(
                  icon,
                  size: theme.spacing(5),
                  color: theme.colors.muted,
                ),
                Text(
                  label,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

/// Gallery page of `HeroDrawer`.
final ComponentDemo drawerDemo = ComponentDemo(
  slug: 'drawer',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('placement', <String>['bottom', 'top', 'left', 'right']),
      OptionsControl('variant', <String>['opaque', 'blur', 'transparent']),
      ToggleControl('isDismissable', initial: true),
      ToggleControl('isKeyboardDismissDisabled'),
      ToggleControl('handle', initial: true),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final HeroDrawerPlacement placement = values.pick(
        'placement',
        HeroDrawerPlacement.values,
      );
      final bool handle = values.toggle('handle');
      return HeroDrawer(
        trigger: _secondary('Open Drawer'),
        child: HeroDrawerBackdrop(
          variant: values.pick('variant', HeroBackdropVariant.values),
          isDismissable: values.toggle('isDismissable'),
          isKeyboardDismissDisabled: values.toggle('isKeyboardDismissDisabled'),
          child: HeroDrawerContent(
            placement: placement,
            child: HeroDrawerDialog(
              children: <Widget>[
                if (handle && placement != HeroDrawerPlacement.top)
                  const HeroDrawerHandle(),
                const HeroDrawerCloseTrigger(),
                const HeroDrawerHeader(
                  children: <Widget>[
                    HeroDrawerHeading(child: Text('Drawer Title')),
                  ],
                ),
                const HeroDrawerBody(
                  child: Text(
                    'Drag the drawer towards its edge, press outside or '
                    'press Escape to close it.',
                  ),
                ),
                const HeroDrawerFooter(children: _cancelConfirm),
                if (handle && placement == HeroDrawerPlacement.top)
                  const HeroDrawerHandle(),
              ],
            ),
          ),
        ),
      );
    },
    code: (PlaygroundValues values) {
      final bool handle = values.toggle('handle');
      final bool top = values.option('placement') == 'top';
      return '''
HeroDrawer(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Drawer'),
  ),
  child: HeroDrawerBackdrop(
    variant: HeroBackdropVariant.${values.option('variant')},${values.toggle('isDismissable') ? '' : '\n    isDismissable: false,'}${values.toggle('isKeyboardDismissDisabled') ? '\n    isKeyboardDismissDisabled: true,' : ''}
    child: HeroDrawerContent(
      placement: HeroDrawerPlacement.${values.option('placement')},
      child: HeroDrawerDialog(
        children: const [${handle && !top ? '\n          HeroDrawerHandle(),' : ''}
          HeroDrawerCloseTrigger(),
          HeroDrawerHeader(children: [
            HeroDrawerHeading(child: Text('Drawer Title')),
          ]),
          HeroDrawerBody(child: Text('...')),
          HeroDrawerFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.secondary,
              child: Text('Cancel'),
            ),
            HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
          ]),${handle && top ? '\n          HeroDrawerHandle(),' : ''}
        ],
      ),
    ),
  ),
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => HeroDrawer(
        trigger: _secondary('Open Drawer'),
        child: const HeroDrawerBackdrop(
          child: HeroDrawerContent(
            placement: HeroDrawerPlacement.right,
            child: HeroDrawerDialog(
              children: <Widget>[
                HeroDrawerHeader(
                  children: <Widget>[
                    HeroDrawerHeading(child: Text('Drawer Title')),
                  ],
                ),
                HeroDrawerBody(
                  child: Text(
                    'This is a drawer built on the hero_ui modal route. It '
                    'slides in from the edge of the screen with a smooth '
                    'transition.',
                  ),
                ),
                HeroDrawerFooter(children: _cancelConfirm),
              ],
            ),
          ),
        ),
      ),
      code: '''
HeroDrawer(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Drawer'),
  ),
  child: const HeroDrawerBackdrop(
    child: HeroDrawerContent(
      placement: HeroDrawerPlacement.right,
      child: HeroDrawerDialog(
        children: [
          HeroDrawerHeader(children: [
            HeroDrawerHeading(child: Text('Drawer Title')),
          ]),
          HeroDrawerBody(child: Text('This is a drawer built on...')),
          HeroDrawerFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.secondary,
              child: Text('Cancel'),
            ),
            HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
          ]),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Placement',
      builder: (BuildContext context) => Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          for (final HeroDrawerPlacement placement in <HeroDrawerPlacement>[
            HeroDrawerPlacement.bottom,
            HeroDrawerPlacement.top,
            HeroDrawerPlacement.left,
            HeroDrawerPlacement.right,
          ])
            HeroDrawer(
              trigger: _secondary(_capitalize(placement.name)),
              child: HeroDrawerBackdrop(
                child: HeroDrawerContent(
                  placement: placement,
                  child: HeroDrawerDialog(
                    children: <Widget>[
                      const HeroDrawerCloseTrigger(),
                      if (placement == HeroDrawerPlacement.bottom)
                        const HeroDrawerHandle(),
                      HeroDrawerHeader(
                        children: <Widget>[
                          HeroDrawerHeading(
                            child: Text(
                              '${_capitalize(placement.name)} Drawer',
                            ),
                          ),
                        ],
                      ),
                      HeroDrawerBody(
                        child: Text.rich(
                          TextSpan(
                            text: 'This drawer slides in from the ',
                            children: <InlineSpan>[
                              TextSpan(
                                text: placement.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: ' edge of the screen.'),
                            ],
                          ),
                        ),
                      ),
                      const HeroDrawerFooter(
                        children: <Widget>[
                          HeroButton(
                            slot: HeroButtonSlot.close,
                            variant: HeroButtonVariant.secondary,
                            child: Text('Cancel'),
                          ),
                          HeroButton(
                            slot: HeroButtonSlot.close,
                            child: Text('Done'),
                          ),
                        ],
                      ),
                      if (placement == HeroDrawerPlacement.top)
                        const HeroDrawerHandle(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      code: '''
for (final placement in [
  HeroDrawerPlacement.bottom,
  HeroDrawerPlacement.top,
  HeroDrawerPlacement.left,
  HeroDrawerPlacement.right,
])
  HeroDrawer(
    trigger: HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text(capitalize(placement.name)),
    ),
    child: HeroDrawerBackdrop(
      child: HeroDrawerContent(
        placement: placement,
        child: HeroDrawerDialog(
          children: [
            const HeroDrawerCloseTrigger(),
            if (placement == HeroDrawerPlacement.bottom) const HeroDrawerHandle(),
            HeroDrawerHeader(children: [
              HeroDrawerHeading(child: Text('\${capitalize(placement.name)} Drawer')),
            ]),
            HeroDrawerBody(
              child: Text('This drawer slides in from the \${placement.name} edge of the screen.'),
            ),
            const HeroDrawerFooter(children: [...]),
            if (placement == HeroDrawerPlacement.top) const HeroDrawerHandle(),
          ],
        ),
      ),
    ),
  )''',
    ),
    DemoExample(
      title: 'Non-Dismissable',
      description:
          'isDismissable: false prevents closing by pressing outside or '
          "dragging. The user must use the drawer's action buttons.",
      builder: (BuildContext context) => HeroDrawer(
        trigger: _secondary('Important Action'),
        child: const HeroDrawerBackdrop(
          isDismissable: false,
          child: HeroDrawerContent(
            child: HeroDrawerDialog(
              children: <Widget>[
                HeroDrawerHeader(
                  children: <Widget>[
                    HeroDrawerHeading(child: Text('Confirm Action')),
                  ],
                ),
                HeroDrawerBody(
                  child: Text(
                    'This drawer cannot be dismissed by clicking outside or '
                    'dragging. You must use one of the buttons below.',
                  ),
                ),
                HeroDrawerFooter(children: _cancelConfirm),
              ],
            ),
          ),
        ),
      ),
      code: '''
HeroDrawer(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Important Action'),
  ),
  child: const HeroDrawerBackdrop(
    isDismissable: false,
    child: HeroDrawerContent(
      child: HeroDrawerDialog(children: [...]),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Scrollable Content',
      description:
          'HeroDrawerBody scrolls when its content is too tall. Dragging '
          'inside the body scrolls instead of moving the drawer.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroDrawer(
          trigger: _secondary('Terms & Conditions'),
          child: HeroDrawerBackdrop(
            child: HeroDrawerContent(
              child: HeroDrawerDialog(
                children: <Widget>[
                  const HeroDrawerHandle(),
                  const HeroDrawerCloseTrigger(),
                  const HeroDrawerHeader(
                    children: <Widget>[
                      HeroDrawerHeading(child: Text('Terms & Conditions')),
                    ],
                  ),
                  HeroDrawerBody(
                    children: <Widget>[
                      for (int i = 0; i < 20; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: theme.spacing(3)),
                          child: Text(
                            'Paragraph ${i + 1}: Lorem ipsum dolor sit amet, '
                            'consectetur adipiscing elit. Nullam pulvinar '
                            'risus non risus hendrerit venenatis. '
                            'Pellentesque sit amet hendrerit risus, sed '
                            'porttitor quam.',
                          ),
                        ),
                    ],
                  ),
                  const HeroDrawerFooter(
                    children: <Widget>[
                      HeroButton(
                        slot: HeroButtonSlot.close,
                        variant: HeroButtonVariant.secondary,
                        child: Text('Decline'),
                      ),
                      HeroButton(
                        slot: HeroButtonSlot.close,
                        child: Text('Accept'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      code: '''
HeroDrawer(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Terms & Conditions'),
  ),
  child: HeroDrawerBackdrop(
    child: HeroDrawerContent(
      child: HeroDrawerDialog(
        children: [
          const HeroDrawerHandle(),
          const HeroDrawerCloseTrigger(),
          const HeroDrawerHeader(children: [
            HeroDrawerHeading(child: Text('Terms & Conditions')),
          ]),
          HeroDrawerBody(children: [
            for (int i = 0; i < 20; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Paragraph \${i + 1}: Lorem ipsum...'),
              ),
          ]),
          const HeroDrawerFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.secondary,
              child: Text('Decline'),
            ),
            HeroButton(slot: HeroButtonSlot.close, child: Text('Accept')),
          ]),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Controlled State',
      builder: (BuildContext context) => const _ControlledExample(),
      code: '''
// With setState.
HeroDrawerBackdrop(
  isOpen: isOpen,
  onOpenChanged: (value) => setState(() => isOpen = value),
  child: HeroDrawerContent(
    placement: HeroDrawerPlacement.right,
    child: HeroDrawerDialog(children: [...]),
  ),
)

// With HeroOverlayController.
final state = HeroOverlayController();
HeroButton(onPressed: state.open, child: const Text('Open Drawer'));
HeroDrawerBackdrop(
  isOpen: state.isOpen,
  onOpenChanged: state.setOpen,
  child: HeroDrawerContent(
    placement: HeroDrawerPlacement.right,
    child: HeroDrawerDialog(children: [...]),
  ),
)''',
    ),
    DemoExample(
      title: 'Navigation Drawer',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroDrawer(
          trigger: const HeroButton(
            variant: HeroButtonVariant.secondary,
            startContent: HeroIcon(HeroIcons.bars),
            child: Text('Menu'),
          ),
          child: HeroDrawerBackdrop(
            child: HeroDrawerContent(
              placement: HeroDrawerPlacement.left,
              child: HeroDrawerDialog(
                children: <Widget>[
                  const HeroDrawerCloseTrigger(),
                  const HeroDrawerHeader(
                    children: <Widget>[
                      HeroDrawerHeading(child: Text('Navigation')),
                    ],
                  ),
                  HeroDrawerBody(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: theme.spacing(1),
                      children: const <Widget>[
                        _NavItem(icon: HeroIcons.house, label: 'Home'),
                        _NavItem(icon: HeroIcons.magnifier, label: 'Search'),
                        _NavItem(icon: HeroIcons.bell, label: 'Notifications'),
                        _NavItem(icon: HeroIcons.envelope, label: 'Messages'),
                        _NavItem(icon: HeroIcons.person, label: 'Profile'),
                        _NavItem(icon: HeroIcons.gear, label: 'Settings'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      code: '''
HeroDrawer(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    startContent: HeroIcon(HeroIcons.bars),
    child: Text('Menu'),
  ),
  child: HeroDrawerBackdrop(
    child: HeroDrawerContent(
      placement: HeroDrawerPlacement.left,
      child: HeroDrawerDialog(
        children: [
          const HeroDrawerCloseTrigger(),
          const HeroDrawerHeader(children: [
            HeroDrawerHeading(child: Text('Navigation')),
          ]),
          HeroDrawerBody(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final item in navItems)
                  // Row with a 20 px muted icon and a label; hover fills
                  // it with theme.colors.defaultColor (radius 12).
                  NavItem(icon: item.icon, label: item.label),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Backdrop Variants',
      builder: (BuildContext context) => Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          for (final HeroBackdropVariant variant in HeroBackdropVariant.values)
            HeroDrawer(
              trigger: _secondary(_capitalize(variant.name)),
              child: HeroDrawerBackdrop(
                variant: variant,
                child: HeroDrawerContent(
                  child: HeroDrawerDialog(
                    children: <Widget>[
                      const HeroDrawerHandle(),
                      const HeroDrawerCloseTrigger(),
                      HeroDrawerHeader(
                        children: <Widget>[
                          HeroDrawerHeading(
                            child: Text(
                              'Backdrop: ${_capitalize(variant.name)}',
                            ),
                          ),
                        ],
                      ),
                      HeroDrawerBody(
                        child: Text(
                          'This drawer uses the ${variant.name} backdrop '
                          'variant.',
                        ),
                      ),
                      const HeroDrawerFooter(
                        children: <Widget>[
                          HeroButton(
                            slot: HeroButtonSlot.close,
                            fullWidth: true,
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      code: '''
HeroDrawerBackdrop(
  variant: HeroBackdropVariant.blur,
  child: HeroDrawerContent(
    child: HeroDrawerDialog(
      children: [
        const HeroDrawerHandle(),
        const HeroDrawerCloseTrigger(),
        const HeroDrawerHeader(children: [
          HeroDrawerHeading(child: Text('Backdrop: Blur')),
        ]),
        const HeroDrawerBody(child: Text('This drawer uses the blur backdrop variant.')),
        const HeroDrawerFooter(children: [
          HeroButton(
            slot: HeroButtonSlot.close,
            fullWidth: true,
            child: Text('Close'),
          ),
        ]),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Styles',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroDrawer(
          trigger: _secondary('Open filters'),
          child: HeroDrawerBackdrop(
            variant: HeroBackdropVariant.blur,
            child: HeroDrawerContent(
              placement: HeroDrawerPlacement.right,
              child: HeroDrawerDialog(
                backgroundColor: theme.colors.surface,
                side: BorderSide(
                  color: theme.colors.border.withValues(alpha: 0.8),
                ),
                children: <Widget>[
                  const HeroDrawerHeader(
                    children: <Widget>[
                      HeroDrawerHeading(child: Text('Filters')),
                    ],
                  ),
                  HeroDrawerBody(
                    child: Text(
                      'Narrow results by status, owner, or date.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.muted,
                      ),
                    ),
                  ),
                  const HeroDrawerFooter(
                    children: <Widget>[
                      HeroButton(
                        slot: HeroButtonSlot.close,
                        variant: HeroButtonVariant.secondary,
                        child: Text('Cancel'),
                      ),
                      HeroButton(
                        slot: HeroButtonSlot.close,
                        child: Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      code: '''
HeroDrawer(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open filters'),
  ),
  child: HeroDrawerBackdrop(
    variant: HeroBackdropVariant.blur,
    child: HeroDrawerContent(
      placement: HeroDrawerPlacement.right,
      child: HeroDrawerDialog(
        backgroundColor: theme.colors.surface,
        side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
        children: const [
          HeroDrawerHeader(children: [HeroDrawerHeading(child: Text('Filters'))]),
          HeroDrawerBody(child: Text('Narrow results by status, owner, or date.')),
          HeroDrawerFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.secondary,
              child: Text('Cancel'),
            ),
            HeroButton(slot: HeroButtonSlot.close, child: Text('Apply')),
          ]),
        ],
      ),
    ),
  ),
)''',
    ),
  ],
);

class _ControlledExample extends StatefulWidget {
  const _ControlledExample();

  @override
  State<_ControlledExample> createState() => _ControlledExampleState();
}

class _ControlledExampleState extends State<_ControlledExample> {
  bool _isOpen = false;
  final HeroOverlayController _state = HeroOverlayController();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Widget _card(
    HeroThemeData theme,
    bool open,
    VoidCallback onOpen,
    VoidCallback onToggle,
  ) => DecoratedBox(
    decoration: ShapeDecoration(
      color: theme.colors.surface,
      shape: theme.shapeAll(theme.radii.xl2),
      shadows: theme.shadows.surface.boxShadows,
    ),
    child: Padding(
      padding: EdgeInsets.all(theme.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.spacing(3),
        children: <Widget>[
          Text.rich(
            TextSpan(
              text: 'Status: ',
              children: <InlineSpan>[
                TextSpan(
                  text: open ? 'open' : 'closed',
                  style: theme.typography
                      .style(
                        HeroFontSize.xs,
                        weight: HeroTypography.medium,
                        mono: true,
                      )
                      .copyWith(color: theme.colors.foreground),
                ),
              ],
            ),
            style: theme.typography.xs.copyWith(color: theme.colors.muted),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: theme.spacing(2),
            children: <Widget>[
              HeroButton(
                size: HeroSize.sm,
                variant: HeroButtonVariant.secondary,
                onPressed: onOpen,
                child: const Text('Open Drawer'),
              ),
              HeroButton(
                size: HeroSize.sm,
                variant: HeroButtonVariant.tertiary,
                onPressed: onToggle,
                child: const Text('Toggle'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _content(String heading, String text) => HeroDrawerContent(
    placement: HeroDrawerPlacement.right,
    child: HeroDrawerDialog(
      children: <Widget>[
        const HeroDrawerCloseTrigger(),
        HeroDrawerHeader(
          children: <Widget>[HeroDrawerHeading(child: Text(heading))],
        ),
        HeroDrawerBody(child: Text(text)),
        const HeroDrawerFooter(
          children: <Widget>[
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.secondary,
              child: Text('Close'),
            ),
          ],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: theme.spacing(112)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: theme.spacing(8),
        children: <Widget>[
          _Section(
            title: 'With setState()',
            description:
                'Control the drawer with a State field for simple state '
                'management.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _card(
                  theme,
                  _isOpen,
                  () => setState(() => _isOpen = true),
                  () => setState(() => _isOpen = !_isOpen),
                ),
                HeroDrawerBackdrop(
                  isOpen: _isOpen,
                  onOpenChanged: (bool value) =>
                      setState(() => _isOpen = value),
                  child: _content(
                    'Controlled with setState()',
                    'This drawer is controlled by a State field. Pass isOpen '
                        'and onOpenChanged to manage the drawer state '
                        'externally.',
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'With HeroOverlayController',
            description:
                'Use a HeroOverlayController (useOverlayState) for a cleaner '
                'API with convenient methods like open(), close(), and '
                'toggle().',
            child: ListenableBuilder(
              listenable: _state,
              builder: (BuildContext context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _card(theme, _state.isOpen, _state.open, _state.toggle),
                  HeroDrawerBackdrop(
                    isOpen: _state.isOpen,
                    onOpenChanged: _state.setOpen,
                    child: _content(
                      'Controlled with HeroOverlayController',
                      'The controller provides dedicated methods for common '
                          'operations. No need to manually create callbacks '
                          '- just use state.open(), state.close(), or '
                          'state.toggle().',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
