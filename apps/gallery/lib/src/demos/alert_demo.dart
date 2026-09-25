import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Whether HeroUI's `sm:` utilities apply (640 and wider, unless the
/// theme pins a density).
bool _smUp(BuildContext context) => switch (HeroTheme.of(context).density) {
  HeroDensity.touch => false,
  HeroDensity.desktop => true,
  HeroDensity.adaptive =>
    (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= HeroBreakpoints.sm,
};

/// `w-full max-w-xl`.
Widget _maxXl(BuildContext context, Widget child) => ConstrainedBox(
  constraints: BoxConstraints(maxWidth: HeroTheme.of(context).spacing(144)),
  child: child,
);

/// An alert action placed like HeroUI's responsive examples: under the
/// text below the `sm` breakpoint (`mt-*` inside the content), after it
/// from `sm` up.
List<Widget> _responsive(
  BuildContext context, {
  required List<Widget> content,
  required Widget action,
  required double gap,
  List<Widget> trailing = const <Widget>[],
}) {
  final bool smUp = _smUp(context);
  return <Widget>[
    HeroAlertContent(
      children: <Widget>[
        ...content,
        if (!smUp)
          Padding(
            padding: EdgeInsets.only(top: gap),
            child: action,
          ),
      ],
    ),
    if (smUp) action,
    ...trailing,
  ];
}

/// The `list-inside list-disc` steps of the danger example.
class _Bullets extends StatelessWidget {
  const _Bullets(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: theme.spacing(2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: theme.spacing(1),
        children: <Widget>[for (final String item in items) Text('•  $item')],
      ),
    );
  }
}

class _BasicAlerts extends StatelessWidget {
  const _BasicAlerts();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return _maxXl(
      context,
      Column(
        spacing: theme.spacing(4),
        children: <Widget>[
          const HeroAlert(
            title: Text('New features available'),
            description: Text(
              'Check out our latest updates including dark mode support and '
              'improved accessibility features.',
            ),
          ),
          HeroAlert(
            status: HeroColor.accent,
            children: <Widget>[
              const HeroAlertIndicator(),
              ..._responsive(
                context,
                gap: theme.spacing(2),
                content: const <Widget>[
                  HeroAlertTitle.text('Update available'),
                  HeroAlertDescription.text(
                    'A new version of the application is available. Please '
                    'refresh to get the latest features and bug fixes.',
                  ),
                ],
                action: HeroButton(
                  size: HeroSize.sm,
                  onPressed: () {},
                  child: const Text('Refresh'),
                ),
              ),
            ],
          ),
          HeroAlert(
            status: HeroColor.danger,
            children: <Widget>[
              const HeroAlertIndicator(),
              ..._responsive(
                context,
                gap: theme.spacing(2),
                content: const <Widget>[
                  HeroAlertTitle.text('Unable to connect to server'),
                  HeroAlertDescription(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "We're experiencing connection issues. Please try "
                          'the following:',
                        ),
                        _Bullets(<String>[
                          'Check your internet connection',
                          'Refresh the page',
                          'Clear your browser cache',
                        ]),
                      ],
                    ),
                  ),
                ],
                action: HeroButton(
                  size: HeroSize.sm,
                  variant: HeroButtonVariant.danger,
                  onPressed: () {},
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
          HeroAlert(
            status: HeroColor.success,
            title: const Text('Profile updated successfully'),
            endContent: HeroCloseButton(onPressed: () {}),
          ),
          const HeroAlert(
            status: HeroColor.accent,
            indicator: HeroSpinner(size: HeroSpinnerSize.sm),
            title: Text('Processing your request'),
            description: Text(
              'Please wait while we sync your data. This may take a few '
              'moments.',
            ),
          ),
          const HeroAlert(
            status: HeroColor.warning,
            title: Text('Scheduled maintenance'),
            description: Text(
              'Our services will be unavailable on Sunday, March 15th from '
              '2:00 AM to 6:00 AM UTC for scheduled maintenance.',
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAlert extends StatelessWidget {
  const _CustomAlert();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final bool dark = theme.isDark;
    Color warning(double alpha) =>
        colors.warning.withValues(alpha: colors.warning.a * alpha);
    return _maxXl(
      context,
      HeroAlert(
        status: HeroColor.warning,
        style: HeroAlertStyle(
          borderRadius: BorderRadius.all(Radius.circular(theme.radii.xl)),
          border: BorderSide(color: warning(dark ? 0.3 : 0.2)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              warning(dark ? 0.15 : 0.1),
              colors.surface,
              if (dark) warning(0.05) else colors.surfaceSecondary,
            ],
          ),
          // Tailwind's `shadow-sm`.
          shadows: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 1),
              blurRadius: 3,
            ),
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: -1,
            ),
          ],
        ),
        // The blurred `size-28` glow at `-top-8 -right-8`.
        background: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned(
              top: -theme.spacing(8),
              right: -theme.spacing(8),
              width: theme.spacing(28),
              height: theme.spacing(28),
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  shape: const CircleBorder(),
                  shadows: <BoxShadow>[
                    BoxShadow(
                      color: warning(dark ? 0.25 : 0.15),
                      blurRadius: 68,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        children: <Widget>[
          HeroAlertIndicator(color: colors.warning),
          ..._responsive(
            context,
            gap: theme.spacing(3),
            content: const <Widget>[
              HeroAlertTitle.text('Payment method expires soon'),
              HeroAlertDescription.text(
                'Your Visa ending in 4242 expires on March 28. Update billing '
                'to avoid interrupting your Pro subscription.',
              ),
            ],
            action: HeroButton(
              size: HeroSize.sm,
              variant: HeroButtonVariant.tertiary,
              onPressed: () {},
              child: const Text('Update billing'),
            ),
            trailing: <Widget>[HeroCloseButton(onPressed: () {})],
          ),
        ],
      ),
    );
  }
}

/// Gallery page of `HeroAlert`.
final ComponentDemo alertDemo = ComponentDemo(
  slug: 'alert',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('status', <String>[
        'standard',
        'accent',
        'success',
        'warning',
        'danger',
      ], initial: 'standard'),
      TextControl('title', initial: 'New features available'),
      TextControl(
        'description',
        initial: 'Check out our latest updates and improvements.',
      ),
      ToggleControl('showIndicator', initial: true),
      ToggleControl('closeButton'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _maxXl(
      context,
      HeroAlert(
        status: values.pick('status', HeroColor.values),
        showIndicator: values.toggle('showIndicator'),
        title: values.text('title').isEmpty ? null : Text(values.text('title')),
        description: values.text('description').isEmpty
            ? null
            : Text(values.text('description')),
        endContent: values.toggle('closeButton')
            ? HeroCloseButton(onPressed: () {})
            : null,
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroAlert(
  status: HeroColor.${values.option('status')},
  showIndicator: ${values.toggle('showIndicator')},
  title: const Text('${values.text('title')}'),
  description: const Text('${values.text('description')}'),${values.toggle('closeButton') ? '\n  endContent: HeroCloseButton(onPressed: dismiss),' : ''}
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _BasicAlerts(),
      code: '''
Column(
  spacing: 16,
  children: <Widget>[
    const HeroAlert(
      title: Text('New features available'),
      description: Text(
        'Check out our latest updates including dark mode support and '
        'improved accessibility features.',
      ),
    ),
    HeroAlert(
      status: HeroColor.accent,
      children: <Widget>[
        const HeroAlertIndicator(),
        const HeroAlertContent(
          children: <Widget>[
            HeroAlertTitle.text('Update available'),
            HeroAlertDescription.text(
              'A new version of the application is available. Please '
              'refresh to get the latest features and bug fixes.',
            ),
            // Below 640 px the button sits here, 8 px under the text.
          ],
        ),
        // From 640 px up it follows the content.
        HeroButton(
          size: HeroSize.sm,
          onPressed: refresh,
          child: const Text('Refresh'),
        ),
      ],
    ),
    HeroAlert(
      status: HeroColor.danger,
      children: <Widget>[
        const HeroAlertIndicator(),
        HeroAlertContent(
          children: <Widget>[
            const HeroAlertTitle.text('Unable to connect to server'),
            HeroAlertDescription(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "We're experiencing connection issues. "
                    'Please try the following:',
                  ),
                  // Bulleted steps, 8 px below and 4 px apart.
                ],
              ),
            ),
          ],
        ),
        HeroButton(
          size: HeroSize.sm,
          variant: HeroButtonVariant.danger,
          onPressed: retry,
          child: const Text('Retry'),
        ),
      ],
    ),
    HeroAlert(
      status: HeroColor.success,
      title: const Text('Profile updated successfully'),
      endContent: HeroCloseButton(onPressed: dismiss),
    ),
    const HeroAlert(
      status: HeroColor.accent,
      indicator: HeroSpinner(size: HeroSpinnerSize.sm),
      title: Text('Processing your request'),
      description: Text(
        'Please wait while we sync your data. This may take a few moments.',
      ),
    ),
    const HeroAlert(
      status: HeroColor.warning,
      title: Text('Scheduled maintenance'),
      description: Text(
        'Our services will be unavailable on Sunday, March 15th from '
        '2:00 AM to 6:00 AM UTC for scheduled maintenance.',
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A warning alert with a tinted gradient, a hairline border, a '
          'soft glow in the corner and a tertiary action.',
      builder: (BuildContext context) => const _CustomAlert(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final HeroColors colors = theme.colors;
final bool dark = theme.isDark;
Color warning(double alpha) => colors.warning.withValues(alpha: alpha);

HeroAlert(
  status: HeroColor.warning,
  style: HeroAlertStyle(
    borderRadius: BorderRadius.circular(12),
    border: BorderSide(color: warning(dark ? 0.3 : 0.2)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        warning(dark ? 0.15 : 0.1),
        colors.surface,
        if (dark) warning(0.05) else colors.surfaceSecondary,
      ],
    ),
    shadows: shadowSm,
  ),
  background: Stack(
    clipBehavior: Clip.none,
    children: <Widget>[
      Positioned(
        top: -32,
        right: -32,
        width: 112,
        height: 112,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            shadows: <BoxShadow>[
              BoxShadow(color: warning(dark ? 0.25 : 0.15), blurRadius: 68),
            ],
          ),
        ),
      ),
    ],
  ),
  children: <Widget>[
    HeroAlertIndicator(color: colors.warning),
    const HeroAlertContent(
      children: <Widget>[
        HeroAlertTitle.text('Payment method expires soon'),
        HeroAlertDescription.text(
          'Your Visa ending in 4242 expires on March 28. Update billing '
          'to avoid interrupting your Pro subscription.',
        ),
      ],
    ),
    HeroButton(
      size: HeroSize.sm,
      variant: HeroButtonVariant.tertiary,
      onPressed: updateBilling,
      child: const Text('Update billing'),
    ),
    HeroCloseButton(onPressed: dismiss),
  ],
)''',
    ),
  ],
);
