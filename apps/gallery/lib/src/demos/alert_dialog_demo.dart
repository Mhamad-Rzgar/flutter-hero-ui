import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

String _capitalize(String value) => value[0].toUpperCase() + value.substring(1);

Widget _wrap(List<Widget> children) =>
    Wrap(spacing: 16, runSpacing: 16, children: children);

List<Widget> _actions(
  String cancel,
  String confirm, {
  HeroButtonVariant confirmVariant = HeroButtonVariant.primary,
}) => <Widget>[
  HeroButton(
    slot: HeroButtonSlot.close,
    variant: HeroButtonVariant.tertiary,
    child: Text(cancel),
  ),
  HeroButton(
    slot: HeroButtonSlot.close,
    variant: confirmVariant,
    child: Text(confirm),
  ),
];

/// One alert dialog of the examples: trigger, status icon, heading, body
/// and actions.
Widget _alert({
  required Widget trigger,
  required String heading,
  required Widget body,
  HeroColor status = HeroColor.danger,
  Widget? icon,
  List<Widget>? actions,
  HeroBackdropVariant variant = HeroBackdropVariant.opaque,
  HeroModalPlacement placement = HeroModalPlacement.auto,
  HeroAlertDialogSize size = HeroAlertDialogSize.md,
  double? maxWidth = 400,
  bool closeTrigger = true,
  List<Widget> headerExtras = const <Widget>[],
  HeroModalMotion backdropMotion = const HeroModalMotion(),
  HeroModalMotion containerMotion = const HeroModalMotion(),
}) {
  return HeroAlertDialog(
    trigger: trigger,
    child: HeroAlertDialogBackdrop(
      variant: variant,
      motion: backdropMotion,
      child: HeroAlertDialogContainer(
        placement: placement,
        size: size,
        motion: containerMotion,
        child: HeroAlertDialogDialog(
          maxWidth: maxWidth,
          children: <Widget>[
            if (closeTrigger) const HeroAlertDialogCloseTrigger(),
            HeroAlertDialogHeader(
              children: <Widget>[
                HeroAlertDialogIcon(status: status, child: icon),
                HeroAlertDialogHeading(child: Text(heading)),
                ...headerExtras,
              ],
            ),
            HeroAlertDialogBody(child: body),
            HeroAlertDialogFooter(
              children: actions ?? _actions('Cancel', 'Confirm'),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _secondary(String label) =>
    HeroButton(variant: HeroButtonVariant.secondary, child: Text(label));

/// A titled block of the "Controlled State", "Dismiss Behavior" and
/// "Close Methods" examples.
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

typedef _Status = ({
  HeroColor status,
  String trigger,
  String header,
  String body,
  String cancel,
  String confirm,
});

const List<_Status> _statuses = <_Status>[
  (
    status: HeroColor.accent,
    trigger: 'Sign Out',
    header: 'Sign out of your account?',
    body:
        "You'll need to sign in again to access your account. Any unsaved "
        'changes will be lost.',
    cancel: 'Stay Signed In',
    confirm: 'Sign Out',
  ),
  (
    status: HeroColor.success,
    trigger: 'Complete Task',
    header: 'Complete this task?',
    body:
        'This will mark the task as complete and notify all team members. '
        'The task will be moved to your completed list.',
    cancel: 'Not Yet',
    confirm: 'Mark Complete',
  ),
  (
    status: HeroColor.warning,
    trigger: 'Discard Changes',
    header: 'Discard unsaved changes?',
    body:
        'You have unsaved changes that will be permanently lost. Are you '
        'sure you want to discard them?',
    cancel: 'Keep Editing',
    confirm: 'Discard',
  ),
  (
    status: HeroColor.danger,
    trigger: 'Delete Account',
    header: 'Delete your account?',
    body:
        'This will permanently delete your account and remove all your data '
        'from our servers. This action is irreversible.',
    cancel: 'Cancel',
    confirm: 'Delete Account',
  ),
];

/// Gallery page of `HeroAlertDialog`.
final ComponentDemo alertDialogDemo = ComponentDemo(
  slug: 'alert-dialog',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('status', <String>[
        'danger',
        'standard',
        'accent',
        'success',
        'warning',
      ]),
      OptionsControl('variant', <String>['opaque', 'blur', 'transparent']),
      OptionsControl('placement', <String>['auto', 'center', 'top', 'bottom']),
      OptionsControl('size', <String>[
        'xs',
        'sm',
        'md',
        'lg',
        'cover',
      ], initial: 'md'),
      ToggleControl('isDismissable'),
      ToggleControl('isKeyboardDismissDisabled', initial: true),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroAlertDialog(
      trigger: _secondary('Open Alert Dialog'),
      child: HeroAlertDialogBackdrop(
        variant: values.pick('variant', HeroBackdropVariant.values),
        isDismissable: values.toggle('isDismissable'),
        isKeyboardDismissDisabled: values.toggle('isKeyboardDismissDisabled'),
        child: HeroAlertDialogContainer(
          placement: values.pick('placement', HeroModalPlacement.values),
          size: values.pick('size', HeroAlertDialogSize.values),
          child: HeroAlertDialogDialog(
            children: <Widget>[
              const HeroAlertDialogCloseTrigger(),
              HeroAlertDialogHeader(
                children: <Widget>[
                  HeroAlertDialogIcon(
                    status: values.pick('status', HeroColor.values),
                  ),
                  const HeroAlertDialogHeading(
                    child: Text('Delete project permanently?'),
                  ),
                ],
              ),
              const HeroAlertDialogBody(
                child: Text(
                  'This will permanently delete the project and all of '
                  'its data. This action cannot be undone.',
                ),
              ),
              HeroAlertDialogFooter(
                children: _actions(
                  'Cancel',
                  'Confirm',
                  confirmVariant: values.option('status') == 'danger'
                      ? HeroButtonVariant.danger
                      : HeroButtonVariant.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroAlertDialog(
  trigger: const HeroButton(
    variant: HeroButtonVariant.secondary,
    child: Text('Open Alert Dialog'),
  ),
  child: HeroAlertDialogBackdrop(
    variant: HeroBackdropVariant.${values.option('variant')},${values.toggle('isDismissable') ? '\n    isDismissable: true,' : ''}${values.toggle('isKeyboardDismissDisabled') ? '' : '\n    isKeyboardDismissDisabled: false,'}
    child: HeroAlertDialogContainer(
      placement: HeroModalPlacement.${values.option('placement')},
      size: HeroAlertDialogSize.${values.option('size')},
      child: HeroAlertDialogDialog(
        children: const [
          HeroAlertDialogCloseTrigger(),
          HeroAlertDialogHeader(children: [
            HeroAlertDialogIcon(status: HeroColor.${values.option('status')}),
            HeroAlertDialogHeading(child: Text('Delete project permanently?')),
          ]),
          HeroAlertDialogBody(child: Text('This will permanently delete...')),
          HeroAlertDialogFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.tertiary,
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
      builder: (BuildContext context) => _alert(
        trigger: const HeroButton(
          variant: HeroButtonVariant.danger,
          child: Text('Delete Project'),
        ),
        heading: 'Delete project permanently?',
        body: const Text.rich(
          TextSpan(
            text: 'This will permanently delete ',
            children: <InlineSpan>[
              TextSpan(
                text: 'My Awesome Project',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: ' and all of its data. This action cannot be undone.',
              ),
            ],
          ),
        ),
        actions: _actions(
          'Cancel',
          'Delete Project',
          confirmVariant: HeroButtonVariant.danger,
        ),
      ),
      code: '''
HeroAlertDialog(
  trigger: const HeroButton(
    variant: HeroButtonVariant.danger,
    child: Text('Delete Project'),
  ),
  child: HeroAlertDialogBackdrop(
    child: HeroAlertDialogContainer(
      child: HeroAlertDialogDialog(
        maxWidth: 400,
        children: const [
          HeroAlertDialogCloseTrigger(),
          HeroAlertDialogHeader(children: [
            HeroAlertDialogIcon(status: HeroColor.danger),
            HeroAlertDialogHeading(child: Text('Delete project permanently?')),
          ]),
          HeroAlertDialogBody(
            child: Text.rich(TextSpan(
              text: 'This will permanently delete ',
              children: [
                TextSpan(
                  text: 'My Awesome Project',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: ' and all of its data. This action cannot be undone.'),
              ],
            )),
          ),
          HeroAlertDialogFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.tertiary,
              child: Text('Cancel'),
            ),
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.danger,
              child: Text('Delete Project'),
            ),
          ]),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Statuses',
      builder: (BuildContext context) {
        final HeroColors colors = HeroTheme.of(context).colors;
        HeroButtonStyle soft(HeroColor status) {
          final HeroColorRole role = colors.role(status);
          return HeroButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(role.soft),
            foregroundColor: WidgetStatePropertyAll<Color>(role.softForeground),
          );
        }

        return _wrap(<Widget>[
          for (final _Status example in _statuses)
            _alert(
              trigger: HeroButton(
                style: soft(example.status),
                child: Text(example.trigger),
              ),
              status: example.status,
              heading: example.header,
              body: Text(example.body),
              actions: _actions(
                example.cancel,
                example.confirm,
                confirmVariant: example.status == HeroColor.danger
                    ? HeroButtonVariant.danger
                    : HeroButtonVariant.primary,
              ),
            ),
        ]);
      },
      code: '''
HeroAlertDialog(
  trigger: HeroButton(
    style: HeroButtonStyle(
      backgroundColor: WidgetStatePropertyAll(theme.colors.accentSoft),
      foregroundColor: WidgetStatePropertyAll(theme.colors.accentSoftForeground),
    ),
    child: const Text('Sign Out'),
  ),
  child: HeroAlertDialogBackdrop(
    child: HeroAlertDialogContainer(
      child: HeroAlertDialogDialog(
        maxWidth: 400,
        children: const [
          HeroAlertDialogCloseTrigger(),
          HeroAlertDialogHeader(children: [
            HeroAlertDialogIcon(status: HeroColor.accent),
            HeroAlertDialogHeading(child: Text('Sign out of your account?')),
          ]),
          HeroAlertDialogBody(child: Text("You'll need to sign in again...")),
          HeroAlertDialogFooter(children: [
            HeroButton(
              slot: HeroButtonSlot.close,
              variant: HeroButtonVariant.tertiary,
              child: Text('Stay Signed In'),
            ),
            HeroButton(slot: HeroButtonSlot.close, child: Text('Sign Out')),
          ]),
        ],
      ),
    ),
  ),
)
// Likewise with HeroColor.success, warning and danger.''',
    ),
    DemoExample(
      title: 'Placements',
      builder: (BuildContext context) => _wrap(<Widget>[
        for (final HeroModalPlacement placement in HeroModalPlacement.values)
          _alert(
            trigger: _secondary(_capitalize(placement.name)),
            status: HeroColor.accent,
            placement: placement,
            heading: placement == HeroModalPlacement.auto
                ? 'Auto Placement'
                : '${_capitalize(placement.name)} Position',
            body: Text(
              placement == HeroModalPlacement.auto
                  ? 'Automatically positions at the bottom on mobile and '
                        'center on desktop for optimal user experience.'
                  : 'This dialog is positioned at the ${placement.name} of '
                        'the viewport. Critical confirmations are typically '
                        'centered for maximum attention.',
            ),
          ),
      ]),
      code: '''
for (final placement in HeroModalPlacement.values)
  HeroAlertDialog(
    trigger: HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text(capitalize(placement.name)),
    ),
    child: HeroAlertDialogBackdrop(
      child: HeroAlertDialogContainer(
        placement: placement,
        child: HeroAlertDialogDialog(maxWidth: 400, children: [...]),
      ),
    ),
  )''',
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return _wrap(<Widget>[
          for (final HeroAlertDialogSize size in HeroAlertDialogSize.values)
            _alert(
              trigger: _secondary(_capitalize(size.name)),
              size: size,
              maxWidth: null,
              icon: HeroIcon(HeroIcons.rocket, color: theme.colors.foreground),
              status: HeroColor.standard,
              heading: 'Size: ${_capitalize(size.name)}',
              body: Text(
                size == HeroAlertDialogSize.cover
                    ? 'This alert dialog uses the cover size variant. It spans '
                          'the full screen with margins: 16px on mobile and '
                          '40px on desktop. Maintains rounded corners and '
                          'standard padding. Perfect for critical '
                          'confirmations that need maximum width while '
                          'preserving alert dialog aesthetics.'
                    : 'This alert dialog uses the ${size.name} size variant. '
                          'On mobile devices, all sizes adapt to near '
                          'full-width for optimal viewing. On desktop, each '
                          'size provides a different maximum width to suit '
                          'various content needs.',
              ),
            ),
        ]);
      },
      code: '''
for (final size in HeroAlertDialogSize.values)
  HeroAlertDialog(
    trigger: HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text(capitalize(size.name)),
    ),
    child: HeroAlertDialogBackdrop(
      child: HeroAlertDialogContainer(
        size: size,
        child: HeroAlertDialogDialog(
          children: [
            const HeroAlertDialogCloseTrigger(),
            HeroAlertDialogHeader(children: [
              const HeroAlertDialogIcon(
                status: HeroColor.standard,
                child: HeroIcon(HeroIcons.rocket),
              ),
              HeroAlertDialogHeading(child: Text('Size: \${capitalize(size.name)}')),
            ]),
            HeroAlertDialogBody(child: Text('This alert dialog uses the \${size.name} size variant...')),
            const HeroAlertDialogFooter(children: [...]),
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
HeroAlertDialogBackdrop(
  isOpen: isOpen,
  onOpenChanged: (value) => setState(() => isOpen = value),
  child: HeroAlertDialogContainer(
    child: HeroAlertDialogDialog(maxWidth: 400, children: [...]),
  ),
)

// With HeroOverlayController.
final state = HeroOverlayController();
HeroButton(onPressed: state.open, child: const Text('Open Dialog'));
HeroAlertDialogBackdrop(
  isOpen: state.isOpen,
  onOpenChanged: state.setOpen,
  child: HeroAlertDialogContainer(
    child: HeroAlertDialogDialog(maxWidth: 400, children: [...]),
  ),
)''',
    ),
    DemoExample(
      title: 'Custom Icon',
      builder: (BuildContext context) => _alert(
        trigger: _secondary('Reset Password'),
        status: HeroColor.warning,
        icon: const HeroIcon(HeroIcons.lockOpen),
        heading: 'Reset your password?',
        body: const Text(
          "We'll send a password reset link to your email address. You'll "
          'need to create a new password to regain access to your account.',
        ),
        actions: _actions('Cancel', 'Send Reset Link'),
      ),
      code: '''
const HeroAlertDialogIcon(
  status: HeroColor.warning,
  child: HeroIcon(HeroIcons.lockOpen),
)''',
    ),
    DemoExample(
      title: 'Custom Trigger',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroAlertDialog(
          trigger: HeroAlertDialogTrigger(
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
                          color: theme.colors.dangerSoft,
                          shape: theme.shapeAll(theme.radii.xl),
                        ),
                        child: SizedBox.square(
                          dimension: theme.spacing(12),
                          child: Center(
                            child: HeroIcon(
                              HeroIcons.trashBin,
                              size: theme.spacing(6),
                              color: theme.colors.dangerSoftForeground,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: theme.spacing(0.5),
                        children: <Widget>[
                          Text(
                            'Delete Item',
                            style: theme.typography
                                .style(
                                  HeroFontSize.sm,
                                  weight: HeroTypography.semibold,
                                )
                                .copyWith(color: theme.colors.foreground),
                          ),
                          Text(
                            'Permanently remove this item',
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
          child: HeroAlertDialogBackdrop(
            child: HeroAlertDialogContainer(
              child: HeroAlertDialogDialog(
                maxWidth: 400,
                children: <Widget>[
                  const HeroAlertDialogCloseTrigger(),
                  const HeroAlertDialogHeader(
                    children: <Widget>[
                      HeroAlertDialogIcon(child: HeroIcon(HeroIcons.trashBin)),
                      HeroAlertDialogHeading(child: Text('Delete this item?')),
                    ],
                  ),
                  const HeroAlertDialogBody(
                    child: Text(
                      'Use HeroAlertDialogTrigger to create custom trigger '
                      'elements beyond standard buttons. This example shows '
                      'a card-style trigger with icons and descriptive text.',
                    ),
                  ),
                  HeroAlertDialogFooter(
                    children: _actions(
                      'Cancel',
                      'Delete Item',
                      confirmVariant: HeroButtonVariant.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      code: '''
HeroAlertDialog(
  trigger: HeroAlertDialogTrigger(
    borderRadius: BorderRadius.circular(16),
    builder: (context, state) => AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: state.isHovered
            ? theme.colors.surfaceSecondary
            : theme.colors.surface,
        shape: theme.shapeAll(16),
      ),
      child: const Row(children: [/* trash tile */ Text('Delete Item')]),
    ),
  ),
  child: HeroAlertDialogBackdrop(
    child: HeroAlertDialogContainer(
      child: HeroAlertDialogDialog(maxWidth: 400, children: [...]),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Backdrop Variants',
      builder: (BuildContext context) => _wrap(<Widget>[
        for (final HeroBackdropVariant variant in HeroBackdropVariant.values)
          _alert(
            trigger: _secondary(_capitalize(variant.name)),
            variant: variant,
            status: HeroColor.accent,
            heading: 'Backdrop: ${_capitalize(variant.name)}',
            body: Text(switch (variant) {
              HeroBackdropVariant.opaque =>
                'An opaque dark backdrop that completely obscures the '
                    'background, providing maximum focus on the dialog.',
              HeroBackdropVariant.blur =>
                'A blurred backdrop that softly obscures the background '
                    'while maintaining visual context.',
              HeroBackdropVariant.transparent =>
                'A transparent backdrop that keeps the background fully '
                    'visible, useful for less critical confirmations.',
            }),
          ),
      ]),
      code: '''
HeroAlertDialogBackdrop(
  variant: HeroBackdropVariant.blur,
  child: HeroAlertDialogContainer(child: ...),
)''',
    ),
    DemoExample(
      title: 'Custom Backdrop',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        // from-red-950/90 via-red-950/50 (dark: /95, /60) to transparent.
        const Color red950 = Color(0xFF460809);
        return HeroAlertDialog(
          trigger: const HeroButton(
            variant: HeroButtonVariant.danger,
            child: Text('Delete Account'),
          ),
          child: HeroAlertDialogBackdrop(
            variant: HeroBackdropVariant.blur,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[
                  red950.withValues(alpha: theme.isDark ? 0.95 : 0.9),
                  red950.withValues(alpha: theme.isDark ? 0.6 : 0.5),
                  red950.withValues(alpha: 0),
                ],
              ),
            ),
            child: HeroAlertDialogContainer(
              child: HeroAlertDialogDialog(
                maxWidth: 420,
                children: <Widget>[
                  const HeroAlertDialogCloseTrigger(),
                  const HeroAlertDialogHeader(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      HeroAlertDialogIcon(
                        child: HeroIcon(HeroIcons.triangleExclamation),
                      ),
                      HeroAlertDialogHeading(
                        textAlign: TextAlign.center,
                        child: Text('Permanently delete your account?'),
                      ),
                    ],
                  ),
                  const HeroAlertDialogBody(
                    child: Text(
                      'This action cannot be undone. All your data, settings, '
                      'and content will be permanently removed from our '
                      'servers. The dramatic red backdrop emphasizes the '
                      'severity and irreversibility of this decision.',
                    ),
                  ),
                  HeroAlertDialogFooter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: theme.spacing(2),
                      children: const <Widget>[
                        HeroButton(
                          slot: HeroButtonSlot.close,
                          variant: HeroButtonVariant.danger,
                          fullWidth: true,
                          child: Text('Delete Forever'),
                        ),
                        HeroButton(
                          slot: HeroButtonSlot.close,
                          fullWidth: true,
                          child: Text('Keep Account'),
                        ),
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
HeroAlertDialogBackdrop(
  variant: HeroBackdropVariant.blur,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        red950.withValues(alpha: 0.9),
        red950.withValues(alpha: 0.5),
        red950.withValues(alpha: 0),
      ],
    ),
  ),
  child: HeroAlertDialogContainer(
    child: HeroAlertDialogDialog(
      maxWidth: 420,
      children: [
        const HeroAlertDialogCloseTrigger(),
        const HeroAlertDialogHeader(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HeroAlertDialogIcon(child: HeroIcon(HeroIcons.triangleExclamation)),
            HeroAlertDialogHeading(child: Text('Permanently delete your account?')),
          ],
        ),
        const HeroAlertDialogBody(child: Text('This action cannot be undone...')),
        HeroAlertDialogFooter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: const [
              HeroButton(
                slot: HeroButtonSlot.close,
                variant: HeroButtonVariant.danger,
                child: Text('Delete Forever'),
              ),
              HeroButton(slot: HeroButtonSlot.close, child: Text('Keep Account')),
            ],
          ),
        ),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Dismiss Behavior',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        Widget subtitle(String text) => Text(
          text,
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        );
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: theme.spacing(96)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: theme.spacing(6),
            children: <Widget>[
              _Section(
                title: 'isDismissable',
                description:
                    'Controls whether the alert dialog can be dismissed by '
                    'clicking the overlay backdrop. Alert dialogs typically '
                    'require explicit action, so this defaults to false. Set '
                    'to true for less critical confirmations.',
                child: _alert(
                  trigger: _secondary('Open Alert Dialog'),
                  icon: const HeroIcon(HeroIcons.circleInfo),
                  heading: 'isDismissable = false',
                  headerExtras: <Widget>[
                    subtitle(
                      "Clicking the backdrop won't close this alert dialog",
                    ),
                  ],
                  body: const Text(
                    'Try clicking outside this alert dialog on the overlay - '
                    "it won't close. You must use the action buttons to "
                    'dismiss it.',
                  ),
                ),
              ),
              _Section(
                title: 'isKeyboardDismissDisabled',
                description:
                    'Controls whether the ESC key can dismiss the alert '
                    'dialog. Alert dialogs typically require explicit action, '
                    'so this defaults to true. When set to false, the ESC key '
                    'will be enabled.',
                child: _alert(
                  trigger: _secondary('Open Alert Dialog'),
                  status: HeroColor.accent,
                  icon: const HeroIcon(HeroIcons.circleInfo),
                  heading: 'isKeyboardDismissDisabled = true',
                  headerExtras: <Widget>[subtitle('ESC key is disabled')],
                  body: const Text(
                    'Press ESC - nothing happens. You must use the action '
                    'buttons to dismiss this alert dialog.',
                  ),
                ),
              ),
            ],
          ),
        );
      },
      code: '''
// Both are the defaults of HeroAlertDialogBackdrop.
const HeroAlertDialogBackdrop(
  isDismissable: false,
  isKeyboardDismissDisabled: true,
  child: ...,
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
                    'The simplest way to close a dialog. Give any HeroButton '
                    'inside the dialog slot: HeroButtonSlot.close. When '
                    'pressed, it will automatically close the dialog.',
                child: _alert(
                  trigger: _secondary('Open Dialog'),
                  closeTrigger: false,
                  status: HeroColor.accent,
                  heading: 'Using slot: close',
                  body: const Text(
                    'Click either button below - both have slot: '
                    'HeroButtonSlot.close and will close the dialog '
                    'automatically.',
                  ),
                ),
              ),
              _Section(
                title: 'Using the dialog builder',
                description:
                    "Access the close function from the dialog's builder. "
                    'This gives you full control over when and how to close '
                    'the dialog, allowing you to add custom logic before '
                    'closing.',
                child: HeroAlertDialog(
                  trigger: _secondary('Open Dialog'),
                  child: HeroAlertDialogBackdrop(
                    child: HeroAlertDialogContainer(
                      child: HeroAlertDialogDialog(
                        maxWidth: 400,
                        builder: (BuildContext context, VoidCallback close) =>
                            <Widget>[
                              const HeroAlertDialogHeader(
                                children: <Widget>[
                                  HeroAlertDialogIcon(
                                    status: HeroColor.success,
                                  ),
                                  HeroAlertDialogHeading(
                                    child: Text('Using the dialog builder'),
                                  ),
                                ],
                              ),
                              const HeroAlertDialogBody(
                                child: Text(
                                  'The buttons below use the close function '
                                  'from the builder. You can add validation '
                                  'or other logic before calling close().',
                                ),
                              ),
                              HeroAlertDialogFooter(
                                children: <Widget>[
                                  HeroButton(
                                    variant: HeroButtonVariant.tertiary,
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
const HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm'))

// The dialog builder
HeroAlertDialogDialog(
  builder: (context, close) => [
    const HeroAlertDialogHeader(children: [...]),
    const HeroAlertDialogBody(child: Text('...')),
    HeroAlertDialogFooter(children: [
      HeroButton(
        variant: HeroButtonVariant.tertiary,
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
        const Curve kinematicIn = Cubic(0.16, 1, 0.3, 1);
        const Curve kinematicOut = Cubic(0.7, 0, 0.84, 0);
        const Curve fluidIn = Cubic(0.25, 1, 0.5, 1);
        const Curve fluidOut = Cubic(0.5, 0, 0.75, 0);
        Widget example({
          required String name,
          required HeroIconData icon,
          required String description,
          required HeroModalMotion backdrop,
          required HeroModalMotion container,
        }) => _alert(
          trigger: _secondary(name),
          status: HeroColor.accent,
          icon: HeroIcon(icon),
          heading: '$name Animation',
          body: Padding(
            padding: EdgeInsets.only(top: theme.spacing(1)),
            child: Text(description),
          ),
          actions: _actions('Close', 'Try Again'),
          backdropMotion: backdrop,
          containerMotion: container,
        );
        return _wrap(<Widget>[
          example(
            name: 'Kinematic Scale',
            icon: HeroIcons.sparkles,
            description:
                'Physics-based elastic scaling. Simulates a high-damping '
                'spring system with fast transient response and prolonged '
                'settling time. Ideal for Alert Dialogs and Modals.',
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
          example(
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
HeroAlertDialogBackdrop(
  motion: const HeroModalMotion(
    enterDuration: Duration(milliseconds: 400),
    exitDuration: Duration(milliseconds: 200),
    enterCurve: Cubic(0.16, 1, 0.3, 1),
    exitCurve: Cubic(0.7, 0, 0.84, 0),
  ),
  child: HeroAlertDialogContainer(
    motion: const HeroModalMotion(
      enterDuration: Duration(milliseconds: 400),
      exitDuration: Duration(milliseconds: 200),
      enterCurve: Cubic(0.16, 1, 0.3, 1),
      exitCurve: Cubic(0.7, 0, 0.84, 0),
      enterScale: 0.95,
      exitScale: 0.95,
      enterOffset: Offset.zero,
    ),
    child: HeroAlertDialogDialog(maxWidth: 400, children: [...]),
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
                  'Render alert dialogs inside a bounded area instead of over '
                  'the whole app',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
                Text(
                  'Wrap the area in a HeroOverlayHost and open the dialog '
                  'with useRootNavigator: false.',
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
                    child: HeroAlertDialog(
                      useRootNavigator: false,
                      trigger: const HeroButton(
                        child: Text('Open Alert Dialog'),
                      ),
                      child: HeroAlertDialogBackdrop(
                        child: HeroAlertDialogContainer(
                          size: HeroAlertDialogSize.cover,
                          child: HeroAlertDialogDialog(
                            maxWidth: theme.spacing(112),
                            children: <Widget>[
                              const HeroAlertDialogCloseTrigger(),
                              const HeroAlertDialogHeader(
                                children: <Widget>[
                                  HeroAlertDialogIcon(status: HeroColor.accent),
                                  HeroAlertDialogHeading(
                                    child: Text('Custom Portal'),
                                  ),
                                ],
                              ),
                              const HeroAlertDialogBody(
                                children: <Widget>[
                                  Text(lorem),
                                  Text(lorem),
                                  Text(lorem),
                                ],
                              ),
                              HeroAlertDialogFooter(
                                children: _actions('Cancel', 'Confirm'),
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
      child: HeroAlertDialog(
        useRootNavigator: false,
        trigger: const HeroButton(child: Text('Open Alert Dialog')),
        child: HeroAlertDialogBackdrop(
          child: HeroAlertDialogContainer(
            size: HeroAlertDialogSize.cover,
            child: HeroAlertDialogDialog(maxWidth: 448, children: [...]),
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
        final Color accent = theme.colors.accent;
        return HeroAlertDialog(
          trigger: _secondary('Sign out'),
          child: HeroAlertDialogBackdrop(
            variant: HeroBackdropVariant.blur,
            color: theme.colors.overlay.withValues(alpha: dark ? 0.6 : 0.5),
            child: HeroAlertDialogContainer(
              child: HeroAlertDialogDialog(
                maxWidth: 400,
                backgroundColor: theme.colors.surface,
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
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: theme.spacing(24),
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              accent.withValues(alpha: dark ? 0.1 : 0.06),
                              accent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: theme.spacing(8),
                    right: theme.spacing(8),
                    top: 0,
                    height: 1,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              accent.withValues(alpha: 0),
                              accent.withValues(alpha: dark ? 0.45 : 0.35),
                              accent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const HeroAlertDialogHeader(
                    children: <Widget>[
                      HeroAlertDialogIcon(status: HeroColor.accent),
                      HeroAlertDialogHeading(
                        child: Text('Sign out of your account?'),
                      ),
                    ],
                  ),
                  HeroAlertDialogBody(
                    child: Text.rich(
                      TextSpan(
                        text:
                            'You will be signed out on this device. Unsaved '
                            'work in ',
                        children: <InlineSpan>[
                          TextSpan(
                            text: 'Acme Workspace',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: theme.colors.foreground,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' may be lost unless it was saved to the '
                                'cloud.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  HeroAlertDialogFooter(
                    children: _actions('Stay signed in', 'Sign out'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      code: '''
HeroAlertDialogBackdrop(
  variant: HeroBackdropVariant.blur,
  color: theme.colors.overlay.withValues(alpha: 0.5),
  child: HeroAlertDialogContainer(
    child: HeroAlertDialogDialog(
      maxWidth: 400,
      backgroundColor: theme.colors.surface,
      side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
      shadows: const [
        BoxShadow(
          color: Color(0x40000000),
          offset: Offset(0, 25),
          blurRadius: 50,
          spreadRadius: -12,
        ),
      ],
      children: [
        // Accent glow behind the header.
        Positioned(left: 0, right: 0, top: 0, height: 96, child: accentGradient),
        const HeroAlertDialogHeader(children: [
          HeroAlertDialogIcon(status: HeroColor.accent),
          HeroAlertDialogHeading(child: Text('Sign out of your account?')),
        ]),
        const HeroAlertDialogBody(child: Text('You will be signed out...')),
        const HeroAlertDialogFooter(children: [
          HeroButton(
            slot: HeroButtonSlot.close,
            variant: HeroButtonVariant.tertiary,
            child: Text('Stay signed in'),
          ),
          HeroButton(slot: HeroButtonSlot.close, child: Text('Sign out')),
        ]),
      ],
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
                child: const Text('Open Dialog'),
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

  Widget _dialog(HeroColor status, String heading, String text) =>
      HeroAlertDialogContainer(
        child: HeroAlertDialogDialog(
          maxWidth: 400,
          children: <Widget>[
            const HeroAlertDialogCloseTrigger(),
            HeroAlertDialogHeader(
              children: <Widget>[
                HeroAlertDialogIcon(status: status),
                HeroAlertDialogHeading(child: Text(heading)),
              ],
            ),
            HeroAlertDialogBody(child: Text(text)),
            HeroAlertDialogFooter(children: _actions('Cancel', 'Confirm')),
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
                'Control the alert dialog with a State field for simple '
                'state management. Perfect for basic use cases.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _card(
                  theme,
                  _isOpen,
                  () => setState(() => _isOpen = true),
                  () => setState(() => _isOpen = !_isOpen),
                ),
                HeroAlertDialogBackdrop(
                  isOpen: _isOpen,
                  onOpenChanged: (bool value) =>
                      setState(() => _isOpen = value),
                  child: _dialog(
                    HeroColor.accent,
                    'Controlled with setState()',
                    'This alert dialog is controlled by a State field. Pass '
                        'isOpen and onOpenChanged to manage the dialog state '
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
                  HeroAlertDialogBackdrop(
                    isOpen: _state.isOpen,
                    onOpenChanged: _state.setOpen,
                    child: _dialog(
                      HeroColor.success,
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
