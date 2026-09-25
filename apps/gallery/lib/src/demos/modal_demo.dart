import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

String _capitalize(String value) => value[0].toUpperCase() + value.substring(1);

Widget _wrap(List<Widget> children) =>
    Wrap(spacing: 16, runSpacing: 16, children: children);

/// `Modal.Icon className="bg-default text-foreground"` and friends.
Widget _icon(
  BuildContext context,
  HeroIconData icon, {
  Color? background,
  Color? foreground,
}) {
  final HeroThemeData theme = HeroTheme.of(context);
  return HeroModalIcon(
    backgroundColor: background ?? theme.colors.defaultColor,
    foregroundColor: foreground ?? theme.colors.foreground,
    child: HeroIcon(icon),
  );
}

const Widget _continue = HeroButton(
  slot: HeroButtonSlot.close,
  fullWidth: true,
  child: Text('Continue'),
);

const List<Widget> _cancelConfirm = <Widget>[
  HeroButton(
    slot: HeroButtonSlot.close,
    variant: HeroButtonVariant.secondary,
    child: Text('Cancel'),
  ),
  HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
];

/// A titled block of the "Controlled", "Dismiss Behavior" and "Close
/// Methods" examples.
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
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.spacing(2),
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

Widget _rocketModal(
  BuildContext context, {
  required String label,
  required String heading,
  required String text,
  HeroBackdropVariant variant = HeroBackdropVariant.opaque,
  HeroModalPlacement placement = HeroModalPlacement.auto,
  HeroModalSize size = HeroModalSize.md,
  double? maxWidth = 360,
  List<Widget> footer = const <Widget>[_continue],
}) {
  return HeroModal(
    trigger: HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text(label),
    ),
    child: HeroModalBackdrop(
      variant: variant,
      child: HeroModalContainer(
        placement: placement,
        size: size,
        child: HeroModalDialog(
          maxWidth: maxWidth,
          children: <Widget>[
            const HeroModalCloseTrigger(),
            HeroModalHeader(
              children: <Widget>[
                _icon(context, HeroIcons.rocket),
                HeroModalHeading(child: Text(heading)),
              ],
            ),
            HeroModalBody(child: Text(text)),
            HeroModalFooter(children: footer),
          ],
        ),
      ),
    ),
  );
}

String _sizeText(HeroModalSize size) => switch (size) {
  HeroModalSize.cover =>
    'This modal uses the cover size variant. It spans the full screen with '
        'margins: 16px on mobile and 40px on desktop. Maintains rounded '
        'corners and standard padding. Perfect for cover-style content that '
        'needs maximum width while preserving modal aesthetics.',
  HeroModalSize.full =>
    'This modal uses the full size variant. It occupies the entire viewport '
        'without any margins, rounded corners, or shadows, creating a true '
        'fullscreen experience. Ideal for immersive content or full-page '
        'interactions.',
  _ =>
    'This modal uses the ${size.name} size variant. On mobile devices, all '
        'sizes adapt to near full-width for optimal viewing. On desktop, each '
        'size provides a different maximum width to suit various content '
        'needs.',
};

/// Gallery page of `HeroModal`.
final ComponentDemo modalDemo = ComponentDemo(
  slug: 'modal',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['opaque', 'blur', 'transparent']),
      OptionsControl('placement', <String>['auto', 'center', 'top', 'bottom']),
      OptionsControl('scroll', <String>['inside', 'outside']),
      OptionsControl('size', <String>[
        'xs',
        'sm',
        'md',
        'lg',
        'cover',
        'full',
      ], initial: 'md'),
      ToggleControl('isDismissable', initial: true),
      ToggleControl('isKeyboardDismissDisabled'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroModal(
      trigger: const HeroButton(
        variant: HeroButtonVariant.secondary,
        child: Text('Open Modal'),
      ),
      child: HeroModalBackdrop(
        variant: values.pick('variant', HeroBackdropVariant.values),
        isDismissable: values.toggle('isDismissable'),
        isKeyboardDismissDisabled: values.toggle('isKeyboardDismissDisabled'),
        child: HeroModalContainer(
          placement: values.pick('placement', HeroModalPlacement.values),
          scroll: values.pick('scroll', HeroModalScroll.values),
          size: values.pick('size', HeroModalSize.values),
          child: HeroModalDialog(
            children: <Widget>[
              const HeroModalCloseTrigger(),
              HeroModalHeader(
                children: <Widget>[
                  _icon(context, HeroIcons.rocket),
                  const HeroModalHeading(child: Text('Welcome to HeroUI')),
                ],
              ),
              const HeroModalBody(
                child: Text(
                  'A beautiful, fast, and modern UI library for building '
                  'accessible and customizable applications with ease.',
                ),
              ),
              const HeroModalFooter(children: _cancelConfirm),
            ],
          ),
        ),
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroModal(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Modal'),
  ),
  child: HeroModalBackdrop(
    variant: HeroBackdropVariant.${values.option('variant')},${values.toggle('isDismissable') ? '' : '\n    isDismissable: false,'}${values.toggle('isKeyboardDismissDisabled') ? '\n    isKeyboardDismissDisabled: true,' : ''}
    child: HeroModalContainer(
      placement: HeroModalPlacement.${values.option('placement')},
      scroll: HeroModalScroll.${values.option('scroll')},
      size: HeroModalSize.${values.option('size')},
      child: HeroModalDialog(
        children: [
          const HeroModalCloseTrigger(),
          HeroModalHeader(children: [
            HeroModalIcon(
              backgroundColor: theme.colors.defaultColor,
              child: const HeroIcon(HeroIcons.rocket),
            ),
            const HeroModalHeading(child: Text('Welcome to HeroUI')),
          ]),
          const HeroModalBody(child: Text('A beautiful, fast, and modern UI library...')),
          const HeroModalFooter(children: [
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
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => _rocketModal(
        context,
        label: 'Open Modal',
        heading: 'Welcome to HeroUI',
        text:
            'A beautiful, fast, and modern React UI library for building '
            'accessible and customizable web applications with ease.',
      ),
      code: '''
HeroModal(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Modal'),
  ),
  child: HeroModalBackdrop(
    child: HeroModalContainer(
      child: HeroModalDialog(
        maxWidth: 360,
        children: [
          const HeroModalCloseTrigger(),
          HeroModalHeader(children: [
            HeroModalIcon(
              backgroundColor: theme.colors.defaultColor,
              foregroundColor: theme.colors.foreground,
              child: const HeroIcon(HeroIcons.rocket),
            ),
            const HeroModalHeading(child: Text('Welcome to HeroUI')),
          ]),
          const HeroModalBody(
            child: Text(
              'A beautiful, fast, and modern React UI library for building '
              'accessible and customizable web applications with ease.',
            ),
          ),
          const HeroModalFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              fullWidth: true,
              child: Text('Continue'),
            ),
          ]),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => _wrap(<Widget>[
        for (final HeroModalSize size in HeroModalSize.values)
          _rocketModal(
            context,
            label: _capitalize(size.name),
            heading: 'Size: ${_capitalize(size.name)}',
            text: _sizeText(size),
            size: size,
            maxWidth: null,
            footer: _cancelConfirm,
          ),
      ]),
      code: '''
Wrap(
  spacing: 16,
  runSpacing: 16,
  children: [
    for (final size in HeroModalSize.values)
      HeroModal(
        trigger: HeroButton(
          variant: HeroButtonVariant.secondary,
          child: Text(capitalize(size.name)),
        ),
        child: HeroModalBackdrop(
          child: HeroModalContainer(
            size: size,
            child: HeroModalDialog(
              children: [
                const HeroModalCloseTrigger(),
                HeroModalHeader(children: [
                  HeroModalIcon(
                    backgroundColor: theme.colors.defaultColor,
                    child: const HeroIcon(HeroIcons.rocket),
                  ),
                  HeroModalHeading(
                    child: Text('Size: \${capitalize(size.name)}'),
                  ),
                ]),
                HeroModalBody(
                  child: Text('This modal uses the \${size.name} size variant...'),
                ),
                const HeroModalFooter(children: [
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
      ),
  ],
)''',
    ),
    DemoExample(
      title: 'Placement',
      builder: (BuildContext context) => _wrap(<Widget>[
        for (final HeroModalPlacement placement in HeroModalPlacement.values)
          _rocketModal(
            context,
            label: _capitalize(placement.name),
            heading: 'Placement: ${_capitalize(placement.name)}',
            text:
                'This modal uses the ${placement.name} placement option. Try '
                'different placements to see how the modal positions itself '
                'on the screen.',
            placement: placement,
          ),
      ]),
      code: '''
for (final placement in HeroModalPlacement.values)
  HeroModal(
    trigger: HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text(capitalize(placement.name)),
    ),
    child: HeroModalBackdrop(
      child: HeroModalContainer(
        placement: placement,
        child: HeroModalDialog(
          maxWidth: 360,
          children: [
            const HeroModalCloseTrigger(),
            HeroModalHeader(children: [
              HeroModalIcon(
                backgroundColor: theme.colors.defaultColor,
                child: const HeroIcon(HeroIcons.rocket),
              ),
              HeroModalHeading(
                child: Text('Placement: \${capitalize(placement.name)}'),
              ),
            ]),
            HeroModalBody(
              child: Text(
                'This modal uses the \${placement.name} placement option. '
                'Try different placements to see how the modal positions '
                'itself on the screen.',
              ),
            ),
            const HeroModalFooter(children: [
              HeroButton(
                slot: HeroButtonSlot.close,
                fullWidth: true,
                child: Text('Continue'),
              ),
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
bool isOpen = false;

HeroButton(
  size: HeroSize.sm,
  variant: HeroButtonVariant.secondary,
  onPressed: () => setState(() => isOpen = true),
  child: const Text('Open Modal'),
),
HeroModalBackdrop(
  isOpen: isOpen,
  onOpenChanged: (value) => setState(() => isOpen = value),
  child: HeroModalContainer(
    child: HeroModalDialog(maxWidth: 360, children: [...]),
  ),
)

// With HeroOverlayController (useOverlayState).
final state = HeroOverlayController();

HeroButton(onPressed: state.open, child: const Text('Open Modal')),
HeroButton(onPressed: state.toggle, child: const Text('Toggle')),
HeroModal(
  controller: state,
  child: HeroModalBackdrop(
    child: HeroModalContainer(
      child: HeroModalDialog(maxWidth: 360, children: [...]),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Trigger',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroModal(
          trigger: HeroModalTrigger(
            borderRadius: BorderRadius.circular(theme.radii.xl2),
            builder: (BuildContext context, HeroButtonState state) =>
                AnimatedContainer(
                  duration: theme.motion.resolve(context, HeroMotion.normal),
                  curve: HeroMotion.smooth,
                  padding: EdgeInsets.all(theme.spacing(4)),
                  decoration: ShapeDecoration(
                    color: state.isHovered
                        ? theme.colors.surfaceSecondary
                        : theme.colors.surface,
                    shape: theme.shapeAll(theme.radii.xl2),
                    shadows: theme.shadows.surface.boxShadows,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: theme.spacing(3),
                    children: <Widget>[
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          color: theme.colors.accentSoft,
                          shape: theme.shapeAll(theme.radii.xl),
                        ),
                        child: SizedBox.square(
                          dimension: theme.spacing(12),
                          child: Center(
                            child: HeroIcon(
                              HeroIcons.gear,
                              size: theme.spacing(6),
                              color: theme.colors.accentSoftForeground,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: theme.spacing(0.5),
                        children: <Widget>[
                          Text(
                            'Settings',
                            style: theme.typography
                                .style(
                                  HeroFontSize.sm,
                                  weight: HeroTypography.semibold,
                                )
                                .copyWith(color: theme.colors.foreground),
                          ),
                          Text(
                            'Manage your preferences',
                            style: theme.typography.xs.copyWith(
                              color: theme.colors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
          child: HeroModalBackdrop(
            child: HeroModalContainer(
              child: HeroModalDialog(
                maxWidth: 360,
                children: <Widget>[
                  const HeroModalCloseTrigger(),
                  HeroModalHeader(
                    children: <Widget>[
                      _icon(
                        context,
                        HeroIcons.gear,
                        background: theme.colors.accentSoft,
                        foreground: theme.colors.accentSoftForeground,
                      ),
                      const HeroModalHeading(child: Text('Settings')),
                    ],
                  ),
                  const HeroModalBody(
                    child: Text(
                      'Use HeroModalTrigger to create custom trigger elements '
                      'beyond standard buttons. This example shows a '
                      'card-style trigger with icons and descriptive text.',
                    ),
                  ),
                  const HeroModalFooter(
                    children: <Widget>[
                      HeroButton(
                        slot: HeroButtonSlot.close,
                        variant: HeroButtonVariant.secondary,
                        child: Text('Cancel'),
                      ),
                      HeroButton(
                        slot: HeroButtonSlot.close,
                        child: Text('Save'),
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
HeroModal(
  trigger: HeroModalTrigger(
    borderRadius: BorderRadius.circular(theme.radii.xl2),
    builder: (context, state) => AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: state.isHovered
            ? theme.colors.surfaceSecondary
            : theme.colors.surface,
        shape: theme.shapeAll(theme.radii.xl2),
        shadows: theme.shadows.surface.boxShadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          // 48 px accent-soft tile with a 24 px gear icon.
          settingsTile,
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('Settings'), Text('Manage your preferences')],
          ),
        ],
      ),
    ),
  ),
  child: HeroModalBackdrop(
    child: HeroModalContainer(
      child: HeroModalDialog(
        maxWidth: 360,
        children: [
          const HeroModalCloseTrigger(),
          HeroModalHeader(children: [
            HeroModalIcon(
              backgroundColor: theme.colors.accentSoft,
              foregroundColor: theme.colors.accentSoftForeground,
              child: const HeroIcon(HeroIcons.gear),
            ),
            const HeroModalHeading(child: Text('Settings')),
          ]),
          const HeroModalBody(child: Text('Use HeroModalTrigger to create...')),
          const HeroModalFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.secondary,
              child: Text('Cancel'),
            ),
            HeroButton(slot: HeroButtonSlot.close, child: Text('Save')),
          ]),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Backdrop Variants',
      builder: (BuildContext context) => _wrap(<Widget>[
        for (final HeroBackdropVariant variant in HeroBackdropVariant.values)
          _rocketModal(
            context,
            label: _capitalize(variant.name),
            heading: 'Backdrop: ${_capitalize(variant.name)}',
            text:
                'This modal uses the ${variant.name} backdrop variant. Compare '
                'the different visual effects: opaque provides full opacity, '
                'blur adds a backdrop filter, and transparent removes the '
                'background.',
            variant: variant,
          ),
      ]),
      code: '''
for (final variant in HeroBackdropVariant.values)
  HeroModal(
    trigger: HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text(capitalize(variant.name)),
    ),
    child: HeroModalBackdrop(
      variant: variant,
      child: HeroModalContainer(
        child: HeroModalDialog(maxWidth: 360, children: [...]),
      ),
    ),
  )''',
    ),
    DemoExample(
      title: 'Custom Backdrop',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        // from-black/80 via-black/40 (dark: zinc-800) to transparent, bottom
        // to top.
        final Color base = theme.isDark
            ? const Color(0xFF27272A)
            : const Color(0xFF000000);
        return HeroModal(
          trigger: const HeroButton(
            variant: HeroButtonVariant.secondary,
            child: Text('Custom Backdrop'),
          ),
          child: HeroModalBackdrop(
            variant: HeroBackdropVariant.blur,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[
                  base.withValues(alpha: 0.8),
                  base.withValues(alpha: 0.4),
                  base.withValues(alpha: 0),
                ],
              ),
            ),
            child: HeroModalContainer(
              child: HeroModalDialog(
                maxWidth: 360,
                children: <Widget>[
                  HeroModalHeader(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _icon(
                        context,
                        HeroIcons.sparkles,
                        background: theme.colors.accentSoft,
                        foreground: theme.colors.accentSoftForeground,
                      ),
                      const HeroModalHeading(
                        textAlign: TextAlign.center,
                        child: Text('Premium Backdrop'),
                      ),
                    ],
                  ),
                  const HeroModalBody(
                    child: Text(
                      'This backdrop features a sophisticated gradient that '
                      'transitions from a dark color at the bottom to '
                      'complete transparency at the top, combined with a '
                      'smooth blur effect. The gradient automatically adapts '
                      'its intensity for optimal contrast in both light and '
                      'dark modes.',
                    ),
                  ),
                  HeroModalFooter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: theme.spacing(2),
                      children: const <Widget>[
                        HeroButton(
                          slot: HeroButtonSlot.close,
                          variant: HeroButtonVariant.secondary,
                          fullWidth: true,
                          child: Text('Close'),
                        ),
                        HeroButton(
                          slot: HeroButtonSlot.close,
                          fullWidth: true,
                          child: Text('Amazing!'),
                        ),
                      ],
                    ),
                  ),
                  const HeroModalCloseTrigger(),
                ],
              ),
            ),
          ),
        );
      },
      code: '''
HeroModal(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Custom Backdrop'),
  ),
  child: HeroModalBackdrop(
    variant: HeroBackdropVariant.blur,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.black.withValues(alpha: 0.8),
          Colors.black.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0),
        ],
      ),
    ),
    child: HeroModalContainer(
      child: HeroModalDialog(
        maxWidth: 360,
        children: [
          HeroModalHeader(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeroModalIcon(
                backgroundColor: theme.colors.accentSoft,
                foregroundColor: theme.colors.accentSoftForeground,
                child: const HeroIcon(HeroIcons.sparkles),
              ),
              const HeroModalHeading(child: Text('Premium Backdrop')),
            ],
          ),
          const HeroModalBody(child: Text('This backdrop features...')),
          HeroModalFooter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: const [
                HeroButton(
                  slot: HeroButtonSlot.close,
                  variant: HeroButtonVariant.secondary,
                  child: Text('Close'),
                ),
                HeroButton(slot: HeroButtonSlot.close, child: Text('Amazing!')),
              ],
            ),
          ),
          const HeroModalCloseTrigger(),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Dismiss Behavior',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        Widget modal({
          required String heading,
          required String subtitle,
          required String text,
          bool isDismissable = true,
          bool isKeyboardDismissDisabled = false,
        }) {
          return HeroModal(
            trigger: const HeroButton(
              variant: HeroButtonVariant.secondary,
              child: Text('Open Modal'),
            ),
            child: HeroModalBackdrop(
              isDismissable: isDismissable,
              isKeyboardDismissDisabled: isKeyboardDismissDisabled,
              child: HeroModalContainer(
                child: HeroModalDialog(
                  maxWidth: 360,
                  children: <Widget>[
                    const HeroModalCloseTrigger(),
                    HeroModalHeader(
                      children: <Widget>[
                        _icon(context, HeroIcons.circleInfo),
                        HeroModalHeading(child: Text(heading)),
                        Text(
                          subtitle,
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.muted,
                          ),
                        ),
                      ],
                    ),
                    HeroModalBody(child: Text(text)),
                    const HeroModalFooter(
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
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: theme.spacing(96)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.spacing(6),
            children: <Widget>[
              _Section(
                title: 'isDismissable',
                description:
                    'Controls whether the modal can be dismissed by clicking '
                    'the overlay backdrop. Defaults to true. Set to false to '
                    'require explicit close action.',
                child: modal(
                  heading: 'isDismissable = false',
                  subtitle: "Clicking the backdrop won't close this modal",
                  text:
                      'Try clicking outside this modal on the overlay - it '
                      "won't close. You must use the close button or press "
                      'ESC to dismiss it.',
                  isDismissable: false,
                ),
              ),
              _Section(
                title: 'isKeyboardDismissDisabled',
                description:
                    'Controls whether the ESC key can dismiss the modal. When '
                    'set to true, the ESC key will be disabled and users must '
                    'use explicit close actions.',
                child: modal(
                  heading: 'isKeyboardDismissDisabled = true',
                  subtitle: 'ESC key is disabled',
                  text:
                      'Press ESC - nothing happens. You must use the close '
                      'button or click the overlay backdrop to dismiss this '
                      'modal.',
                  isKeyboardDismissDisabled: true,
                ),
              ),
            ],
          ),
        );
      },
      code: '''
HeroModal(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Modal'),
  ),
  child: HeroModalBackdrop(
    isDismissable: false,
    child: HeroModalContainer(
      child: HeroModalDialog(maxWidth: 360, children: [...]),
    ),
  ),
)

HeroModal(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Modal'),
  ),
  child: HeroModalBackdrop(
    isKeyboardDismissDisabled: true,
    child: HeroModalContainer(
      child: HeroModalDialog(maxWidth: 360, children: [...]),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Close Methods',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: theme.spacing(168)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.spacing(8),
            children: <Widget>[
              _Section(
                title: 'Using slot: HeroButtonSlot.close',
                description:
                    'The simplest way to close a modal. Give any HeroButton '
                    'inside the modal slot: HeroButtonSlot.close. When '
                    'pressed, it will automatically close the modal.',
                child: HeroModal(
                  trigger: const HeroButton(
                    variant: HeroButtonVariant.secondary,
                    child: Text('Open Modal'),
                  ),
                  child: HeroModalBackdrop(
                    child: HeroModalContainer(
                      child: HeroModalDialog(
                        maxWidth: 360,
                        children: <Widget>[
                          HeroModalHeader(
                            children: <Widget>[
                              _icon(
                                context,
                                HeroIcons.circleInfo,
                                background: theme.colors.accentSoft,
                                foreground: theme.colors.accentSoftForeground,
                              ),
                              const HeroModalHeading(
                                child: Text('Using slot: close'),
                              ),
                            ],
                          ),
                          const HeroModalBody(
                            child: Text(
                              'Click either button below - both have slot: '
                              'HeroButtonSlot.close and will close the modal '
                              'automatically.',
                            ),
                          ),
                          const HeroModalFooter(children: _cancelConfirm),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _Section(
                title: 'Using the dialog builder',
                description:
                    "Access the close function from the dialog's builder. "
                    'This gives you full control over when and how to close '
                    'the modal, allowing you to add custom logic before '
                    'closing.',
                child: HeroModal(
                  trigger: const HeroButton(
                    variant: HeroButtonVariant.secondary,
                    child: Text('Open Modal'),
                  ),
                  child: HeroModalBackdrop(
                    child: HeroModalContainer(
                      child: HeroModalDialog(
                        maxWidth: 360,
                        builder: (BuildContext context, VoidCallback close) =>
                            <Widget>[
                              HeroModalHeader(
                                children: <Widget>[
                                  _icon(
                                    context,
                                    HeroIcons.circleCheck,
                                    background: theme.colors.successSoft,
                                    foreground:
                                        theme.colors.successSoftForeground,
                                  ),
                                  const HeroModalHeading(
                                    child: Text('Using the dialog builder'),
                                  ),
                                ],
                              ),
                              const HeroModalBody(
                                child: Text(
                                  'The buttons below use the close function '
                                  'from the builder. You can add validation '
                                  'or other logic before calling close().',
                                ),
                              ),
                              HeroModalFooter(
                                children: <Widget>[
                                  HeroButton(
                                    variant: HeroButtonVariant.secondary,
                                    onPressed: close,
                                    child: const Text('Cancel'),
                                  ),
                                  HeroButton(
                                    onPressed: close,
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      code: '''
// slot: HeroButtonSlot.close
const HeroModalFooter(children: [
  HeroButton(
    slot: HeroButtonSlot.close,
    variant: HeroButtonVariant.secondary,
    child: Text('Cancel'),
  ),
  HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
])

// The dialog builder's close function
HeroModalDialog(
  builder: (context, close) => [
    HeroModalHeader(children: [...]),
    const HeroModalBody(child: Text('...')),
    HeroModalFooter(children: [
      HeroButton(
        variant: HeroButtonVariant.secondary,
        onPressed: close,
        child: const Text('Cancel'),
      ),
      HeroButton(onPressed: close, child: const Text('Confirm')),
    ]),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Animations',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        Widget modal({
          required String name,
          required HeroIconData icon,
          required String description,
          required HeroModalMotion backdrop,
          required HeroModalMotion container,
        }) {
          return HeroModal(
            trigger: HeroButton(
              variant: HeroButtonVariant.secondary,
              child: Text(name),
            ),
            child: HeroModalBackdrop(
              motion: backdrop,
              child: HeroModalContainer(
                motion: container,
                child: HeroModalDialog(
                  maxWidth: 360,
                  children: <Widget>[
                    const HeroModalCloseTrigger(),
                    HeroModalHeader(
                      children: <Widget>[
                        _icon(context, icon),
                        HeroModalHeading(child: Text('$name Animation')),
                      ],
                    ),
                    HeroModalBody(
                      child: Padding(
                        padding: EdgeInsets.only(top: theme.spacing(1)),
                        child: Text(description),
                      ),
                    ),
                    const HeroModalFooter(
                      children: <Widget>[
                        HeroButton(
                          slot: HeroButtonSlot.close,
                          variant: HeroButtonVariant.tertiary,
                          child: Text('Close'),
                        ),
                        HeroButton(
                          slot: HeroButtonSlot.close,
                          child: Text('Try Again'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        const Curve kinematicIn = Cubic(0.16, 1, 0.3, 1);
        const Curve kinematicOut = Cubic(0.7, 0, 0.84, 0);
        const Curve fluidIn = Cubic(0.25, 1, 0.5, 1);
        const Curve fluidOut = Cubic(0.5, 0, 0.75, 0);
        return _wrap(<Widget>[
          modal(
            name: 'Kinematic Scale',
            icon: HeroIcons.sparkles,
            description:
                'Physics-based elastic scaling. Simulates a high-damping '
                'spring system with fast transient response and prolonged '
                'settling time. Ideal for Modals and Popovers.',
            backdrop: const HeroModalMotion(
              enterDuration: Duration(milliseconds: 400),
              exitDuration: Duration(milliseconds: 200),
              enterCurve: kinematicIn,
              exitCurve: kinematicOut,
            ),
            container: const HeroModalMotion(
              enterDuration: Duration(milliseconds: 400),
              exitDuration: Duration(milliseconds: 200),
              enterCurve: kinematicIn,
              exitCurve: kinematicOut,
              enterScale: 0.95,
              exitScale: 0.95,
              enterOffset: Offset.zero,
            ),
          ),
          modal(
            name: 'Fluid Slide',
            icon: HeroIcons.arrowUpFromLine,
            description:
                'Simulates movement through a medium with fluid resistance. '
                'Eliminates mechanical linearity for a natural, grounded '
                'feel. Perfect for Bottom Sheets or Toasts.',
            backdrop: const HeroModalMotion(
              enterDuration: Duration(milliseconds: 500),
              exitDuration: Duration(milliseconds: 200),
              enterCurve: fluidIn,
              exitCurve: fluidOut,
            ),
            container: const HeroModalMotion(
              enterDuration: Duration(milliseconds: 500),
              exitDuration: Duration(milliseconds: 200),
              enterCurve: fluidIn,
              exitCurve: fluidOut,
              enterScale: 1,
              exitScale: 1,
              enterOffset: Offset(0, 16),
              exitOffset: Offset(0, 8),
            ),
          ),
        ]);
      },
      code: '''
// Kinematic Scale
HeroModalBackdrop(
  motion: const HeroModalMotion(
    enterDuration: Duration(milliseconds: 400),
    exitDuration: Duration(milliseconds: 200),
    enterCurve: Cubic(0.16, 1, 0.3, 1),
    exitCurve: Cubic(0.7, 0, 0.84, 0),
  ),
  child: HeroModalContainer(
    motion: const HeroModalMotion(
      enterDuration: Duration(milliseconds: 400),
      exitDuration: Duration(milliseconds: 200),
      enterCurve: Cubic(0.16, 1, 0.3, 1),
      exitCurve: Cubic(0.7, 0, 0.84, 0),
      enterScale: 0.95,
      exitScale: 0.95,
      enterOffset: Offset.zero,
    ),
    child: HeroModalDialog(maxWidth: 360, children: [...]),
  ),
)

// Fluid Slide
HeroModalBackdrop(
  motion: const HeroModalMotion(
    enterDuration: Duration(milliseconds: 500),
    exitDuration: Duration(milliseconds: 200),
    enterCurve: Cubic(0.25, 1, 0.5, 1),
    exitCurve: Cubic(0.5, 0, 0.75, 0),
  ),
  child: HeroModalContainer(
    motion: const HeroModalMotion(
      enterDuration: Duration(milliseconds: 500),
      exitDuration: Duration(milliseconds: 200),
      enterCurve: Cubic(0.25, 1, 0.5, 1),
      exitCurve: Cubic(0.5, 0, 0.75, 0),
      enterScale: 1,
      exitScale: 1,
      enterOffset: Offset(0, 16),
      exitOffset: Offset(0, 8),
    ),
    child: HeroModalDialog(maxWidth: 360, children: [...]),
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Portal',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        const String lorem =
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do '
            'eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut '
            'enim ad minim veniam, quis nostrud exercitation ullamco laboris '
            'nisi ut aliquip ex ea commodo consequat.';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(4),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Render modals inside a bounded area instead of over the '
                  'whole app',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
                Text(
                  'Wrap the area in a HeroOverlayHost and open the modal with '
                  'useRootNavigator: false.',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.muted,
                  ),
                ),
              ],
            ),
            DecoratedBox(
              decoration: ShapeDecoration(
                color: theme.colors.muted.withValues(alpha: 0.2),
                shape: theme.shapeAll(theme.radii.sm),
              ),
              child: SizedBox(
                height: 380,
                child: HeroOverlayHost(
                  child: Center(
                    child: HeroModal(
                      useRootNavigator: false,
                      trigger: const HeroButton(child: Text('Open Modal')),
                      child: HeroModalBackdrop(
                        child: HeroModalContainer(
                          size: HeroModalSize.cover,
                          child: HeroModalDialog(
                            maxWidth: theme.spacing(112),
                            children: const <Widget>[
                              HeroModalCloseTrigger(),
                              HeroModalHeader(
                                children: <Widget>[
                                  HeroModalHeading(
                                    child: Text('Custom Portal'),
                                  ),
                                ],
                              ),
                              HeroModalBody(
                                children: <Widget>[
                                  Text(lorem),
                                  Text(lorem),
                                  Text(lorem),
                                ],
                              ),
                              HeroModalFooter(
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
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      code: '''
SizedBox(
  height: 380,
  child: HeroOverlayHost(
    child: Center(
      child: HeroModal(
        useRootNavigator: false,
        trigger: const HeroButton(child: Text('Open Modal')),
        child: HeroModalBackdrop(
          child: HeroModalContainer(
            size: HeroModalSize.cover,
            child: HeroModalDialog(
              maxWidth: 448,
              children: const [
                HeroModalCloseTrigger(),
                HeroModalHeader(children: [
                  HeroModalHeading(child: Text('Custom Portal')),
                ]),
                HeroModalBody(children: [Text(lorem), Text(lorem), Text(lorem)]),
                HeroModalFooter(children: [
                  HeroButton(
                    slot: HeroButtonSlot.close,
                    variant: HeroButtonVariant.secondary,
                    child: Text('Close'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Styles',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final bool dark = theme.isDark;
        // Tailwind neutral-100/200/400/500/700/800.
        const Color neutral100 = Color(0xFFF5F5F5);
        const Color neutral200 = Color(0xFFE5E5E5);
        const Color neutral400 = Color(0xFFA3A3A3);
        const Color neutral500 = Color(0xFF737373);
        const Color neutral700 = Color(0xFF404040);
        const Color neutral800 = Color(0xFF262626);
        return HeroModal(
          trigger: const HeroButton(
            variant: HeroButtonVariant.secondary,
            child: Text('Open'),
          ),
          child: HeroModalBackdrop(
            variant: HeroBackdropVariant.blur,
            color: theme.colors.overlay.withValues(alpha: dark ? 0.65 : 0.5),
            child: HeroModalContainer(
              child: HeroModalDialog(
                maxWidth: 340,
                backgroundColor: theme.colors.surface.withValues(
                  alpha: dark ? 0.85 : 0.9,
                ),
                side: BorderSide(
                  color: theme.colors.border.withValues(
                    alpha: dark ? 0.9 : 0.8,
                  ),
                ),
                // shadow-2xl.
                shadows: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x40000000),
                    offset: Offset(0, 25),
                    blurRadius: 50,
                    spreadRadius: -12,
                  ),
                ],
                backdropBlur: theme.spacing(6),
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: theme.spacing(20),
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              (dark ? neutral400 : neutral500).withValues(
                                alpha: dark ? 0.1 : 0.08,
                              ),
                              const Color(0x00000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: theme.spacing(10),
                    right: theme.spacing(10),
                    top: 0,
                    height: 1,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              const Color(0x00000000),
                              (dark ? neutral500 : neutral400).withValues(
                                alpha: dark ? 0.35 : 0.4,
                              ),
                              const Color(0x00000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const HeroModalCloseTrigger(),
                  HeroModalHeader(
                    children: <Widget>[
                      _icon(
                        context,
                        HeroIcons.circleCheck,
                        background: dark ? neutral800 : neutral100,
                        foreground: dark ? neutral200 : neutral700,
                      ),
                      const HeroModalHeading(child: Text('Changes saved')),
                    ],
                  ),
                  HeroModalBody(
                    child: Text(
                      'Your draft is synced across devices.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.muted,
                      ),
                    ),
                  ),
                  const HeroModalFooter(
                    children: <Widget>[
                      HeroButton(
                        slot: HeroButtonSlot.close,
                        fullWidth: true,
                        child: Text('Done'),
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
HeroModal(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open'),
  ),
  child: HeroModalBackdrop(
    variant: HeroBackdropVariant.blur,
    color: theme.colors.overlay.withValues(alpha: 0.5),
    child: HeroModalContainer(
      child: HeroModalDialog(
        maxWidth: 340,
        backgroundColor: theme.colors.surface.withValues(alpha: 0.9),
        side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
        shadows: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 25),
            blurRadius: 50,
            spreadRadius: -12,
          ),
        ],
        backdropBlur: 24,
        children: [
          // Positioned children are decorations behind the content.
          Positioned(left: 0, right: 0, top: 0, height: 80, child: topGradient),
          const HeroModalCloseTrigger(),
          HeroModalHeader(children: [
            HeroModalIcon(
              backgroundColor: const Color(0xFFF5F5F5),
              foregroundColor: const Color(0xFF404040),
              child: const HeroIcon(HeroIcons.circleCheck),
            ),
            const HeroModalHeading(child: Text('Changes saved')),
          ]),
          const HeroModalBody(
            child: Text('Your draft is synced across devices.'),
          ),
          const HeroModalFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              fullWidth: true,
              child: Text('Done'),
            ),
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

  Widget _status(HeroThemeData theme, bool open) => Text.rich(
    TextSpan(
      text: 'Status: ',
      children: <InlineSpan>[
        TextSpan(
          text: open ? 'open' : 'closed',
          style: theme.typography
              .style(HeroFontSize.xs, weight: HeroTypography.medium, mono: true)
              .copyWith(color: theme.colors.foreground),
        ),
      ],
    ),
    style: theme.typography.xs.copyWith(color: theme.colors.muted),
  );

  Widget _card(HeroThemeData theme, bool open, List<Widget> buttons) =>
      DecoratedBox(
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
              _status(theme, open),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: theme.spacing(2),
                children: buttons,
              ),
            ],
          ),
        ),
      );

  Widget _dialog(
    BuildContext context, {
    required String heading,
    required String text,
    required Color background,
    required Color foreground,
  }) {
    return HeroModalContainer(
      child: HeroModalDialog(
        maxWidth: 360,
        children: <Widget>[
          const HeroModalCloseTrigger(),
          HeroModalHeader(
            children: <Widget>[
              _icon(
                context,
                HeroIcons.circleCheck,
                background: background,
                foreground: foreground,
              ),
              HeroModalHeading(child: Text(heading)),
            ],
          ),
          HeroModalBody(child: Text(text)),
          const HeroModalFooter(children: _cancelConfirm),
        ],
      ),
    );
  }

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
                'Control the modal with a State field for simple state '
                'management. Perfect for basic use cases.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _card(theme, _isOpen, <Widget>[
                  HeroButton(
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.secondary,
                    onPressed: () => setState(() => _isOpen = true),
                    child: const Text('Open Modal'),
                  ),
                  HeroButton(
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.tertiary,
                    onPressed: () => setState(() => _isOpen = !_isOpen),
                    child: const Text('Toggle'),
                  ),
                ]),
                HeroModalBackdrop(
                  isOpen: _isOpen,
                  onOpenChanged: (bool value) =>
                      setState(() => _isOpen = value),
                  child: _dialog(
                    context,
                    heading: 'Controlled with setState()',
                    text:
                        'This modal is controlled by a State field. Pass '
                        'isOpen and onOpenChanged to manage the modal state '
                        'externally.',
                    background: theme.colors.accentSoft,
                    foreground: theme.colors.accentSoftForeground,
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
                  _card(theme, _state.isOpen, <Widget>[
                    HeroButton(
                      size: HeroSize.sm,
                      variant: HeroButtonVariant.secondary,
                      onPressed: _state.open,
                      child: const Text('Open Modal'),
                    ),
                    HeroButton(
                      size: HeroSize.sm,
                      variant: HeroButtonVariant.tertiary,
                      onPressed: _state.toggle,
                      child: const Text('Toggle'),
                    ),
                  ]),
                  HeroModal(
                    controller: _state,
                    child: HeroModalBackdrop(
                      child: _dialog(
                        context,
                        heading: 'Controlled with HeroOverlayController',
                        text:
                            'The controller provides dedicated methods for '
                            'common operations. No need to manually create '
                            'callbacks - just use state.open(), '
                            'state.close(), or state.toggle().',
                        background: theme.colors.successSoft,
                        foreground: theme.colors.successSoftForeground,
                      ),
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
