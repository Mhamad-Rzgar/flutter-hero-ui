import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// The app-wide region for [heroToast]. Every example that uses the
/// default queue includes one; only the first mounted one renders.
const Widget _appRegion = HeroToastProvider();

Widget _centered(List<Widget> children) => Column(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    _appRegion,
    Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: children,
    ),
  ],
);

HeroButton _button(
  String label,
  VoidCallback onPressed, {
  HeroButtonVariant variant = HeroButtonVariant.secondary,
  HeroButtonStyle? style,
}) => HeroButton(
  size: HeroSize.sm,
  variant: variant,
  style: style,
  onPressed: onPressed,
  child: Text(label),
);

HeroButtonStyle _fill(Color background, Color foreground) => HeroButtonStyle(
  backgroundColor: WidgetStatePropertyAll<Color>(background),
  foregroundColor: WidgetStatePropertyAll<Color>(foreground),
);

HeroButtonStyle _text(Color foreground) =>
    HeroButtonStyle(foregroundColor: WidgetStatePropertyAll<Color>(foreground));

void _invite() {
  late final String id;
  id = heroToast(
    'You have been invited to join a team',
    description: 'Bob sent you an invitation to join HeroUI team',
    indicator: const HeroIcon(HeroIcons.persons),
    action: HeroToastAction(
      label: 'Dismiss',
      variant: HeroButtonVariant.tertiary,
      onPressed: () => heroToast.close(id),
    ),
  );
}

const List<HeroToastPlacement> _placements = <HeroToastPlacement>[
  HeroToastPlacement.topStart,
  HeroToastPlacement.top,
  HeroToastPlacement.topEnd,
  HeroToastPlacement.bottomStart,
  HeroToastPlacement.bottom,
  HeroToastPlacement.bottomEnd,
];

/// One queue per placement.
final Map<HeroToastPlacement, HeroToastQueue> _placementQueues =
    <HeroToastPlacement, HeroToastQueue>{
      for (final HeroToastPlacement placement in _placements)
        placement: HeroToastQueue(maxVisibleToasts: 3),
    };

final HeroToastQueue _expandedQueue = HeroToastQueue();
final HeroToastQueue _customToastQueue = HeroToastQueue();
final HeroToastQueue _stylesQueue = HeroToastQueue();
final HeroToastQueue _notificationQueue = HeroToastQueue(maxVisibleToasts: 2);
final HeroToastQueue _errorQueue = HeroToastQueue(maxVisibleToasts: 3);
final HeroToastQueue _successQueue = HeroToastQueue(maxVisibleToasts: 1);

String _placementLabel(HeroToastPlacement placement) => switch (placement) {
  HeroToastPlacement.topStart => 'top start',
  HeroToastPlacement.top => 'top',
  HeroToastPlacement.topEnd => 'top end',
  HeroToastPlacement.bottomStart => 'bottom start',
  HeroToastPlacement.bottom => 'bottom',
  HeroToastPlacement.bottomEnd => 'bottom end',
};

/// Gallery page of `HeroToast`.
final ComponentDemo toastDemo = ComponentDemo(
  slug: 'toast',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>[
        'standard',
        'accent',
        'success',
        'warning',
        'danger',
      ]),
      ToggleControl('description', initial: true),
      ToggleControl('action'),
      ToggleControl('isLoading'),
      ToggleControl('persistent'),
    ],
    builder: (BuildContext context, PlaygroundValues values) =>
        _centered(<Widget>[
          _button('Show toast', () {
            late final String id;
            id = heroToast(
              'Notification title',
              description: values.toggle('description')
                  ? 'A short description of what happened'
                  : null,
              variant: values.pick('variant', HeroToastVariant.values),
              isLoading: values.toggle('isLoading'),
              timeout: values.toggle('persistent')
                  ? Duration.zero
                  : HeroToastQueue.defaultTimeout,
              action: values.toggle('action')
                  ? HeroToastAction(
                      label: 'Undo',
                      variant: HeroButtonVariant.tertiary,
                      onPressed: () => heroToast.close(id),
                    )
                  : null,
            );
          }),
        ]),
    code: (PlaygroundValues values) =>
        '''
heroToast(
  'Notification title',${values.toggle('description') ? "\n  description: 'A short description of what happened'," : ''}
  variant: HeroToastVariant.${values.option('variant')},${values.toggle('isLoading') ? '\n  isLoading: true,' : ''}${values.toggle('persistent') ? '\n  timeout: Duration.zero,' : ''}${values.toggle('action') ? "\n  action: HeroToastAction(\n    label: 'Undo',\n    variant: HeroButtonVariant.tertiary,\n    onPressed: () => heroToast.close(id),\n  )," : ''}
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) =>
          _centered(<Widget>[_button('Show toast', _invite)]),
      code: '''
// Once, around the app:
HeroApp(builder: (context, child) => HeroToastProvider(child: child!), ...);

HeroButton(
  size: HeroSize.sm,
  variant: HeroButtonVariant.secondary,
  onPressed: () {
    late final String id;
    id = heroToast(
      'You have been invited to join a team',
      description: 'Bob sent you an invitation to join HeroUI team',
      indicator: const HeroIcon(HeroIcons.persons),
      action: HeroToastAction(
        label: 'Dismiss',
        variant: HeroButtonVariant.tertiary,
        onPressed: () => heroToast.close(id),
      ),
    );
  },
  child: const Text('Show toast'),
)''',
    ),
    DemoExample(
      title: 'Variants',
      builder: (BuildContext context) {
        final HeroColors colors = HeroTheme.of(context).colors;
        return _centered(<Widget>[
          _button(
            'Default toast',
            _invite,
            variant: HeroButtonVariant.tertiary,
          ),
          _button('Accent toast', () {
            late final String id;
            id = heroToast.info(
              'You have 2 credits left',
              description: 'Get a paid plan for more credits',
              action: HeroToastAction(
                label: 'Upgrade',
                onPressed: () => heroToast.close(id),
              ),
            );
          }),
          _button(
            'Success toast',
            () {
              late final String id;
              id = heroToast.success(
                'You have upgraded your plan',
                description: 'You can continue using HeroUI Chat',
                action: HeroToastAction(
                  label: 'Billing',
                  style: _fill(colors.success, colors.successForeground),
                  onPressed: () => heroToast.close(id),
                ),
              );
            },
            variant: HeroButtonVariant.tertiary,
            style: _text(colors.successSoftForeground),
          ),
          _button(
            'Warning toast',
            () {
              late final String id;
              id = heroToast.warning(
                'You have no credits left',
                description: 'Upgrade to a paid plan to continue',
                action: HeroToastAction(
                  label: 'Upgrade',
                  style: _fill(colors.warning, colors.warningForeground),
                  onPressed: () => heroToast.close(id),
                ),
              );
            },
            variant: HeroButtonVariant.tertiary,
            style: _text(colors.warningSoftForeground),
          ),
          _button('Danger toast', () {
            late final String id;
            id = heroToast.danger(
              'Storage is full',
              description:
                  'Remove files to release space. Adding more text to '
                  'demonstrate longer content display',
              indicator: const HeroIcon(HeroIcons.hardDrive),
              action: HeroToastAction(
                label: 'Remove',
                variant: HeroButtonVariant.danger,
                onPressed: () => heroToast.close(id),
              ),
            );
          }, variant: HeroButtonVariant.dangerSoft),
        ]);
      },
      code: '''
heroToast.info(
  'You have 2 credits left',
  description: 'Get a paid plan for more credits',
  action: HeroToastAction(label: 'Upgrade', onPressed: () => heroToast.close(id)),
);
heroToast.success(
  'You have upgraded your plan',
  description: 'You can continue using HeroUI Chat',
  action: HeroToastAction(
    label: 'Billing',
    style: HeroButtonStyle(
      backgroundColor: WidgetStatePropertyAll(theme.colors.success),
      foregroundColor: WidgetStatePropertyAll(theme.colors.successForeground),
    ),
    onPressed: () => heroToast.close(id),
  ),
);
heroToast.warning('You have no credits left', ...);
heroToast.danger(
  'Storage is full',
  description: 'Remove files to release space...',
  indicator: const HeroIcon(HeroIcons.hardDrive),
  action: HeroToastAction(
    label: 'Remove',
    variant: HeroButtonVariant.danger,
    onPressed: () => heroToast.close(id),
  ),
);''',
    ),
    DemoExample(
      title: 'Placements',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final HeroToastPlacement placement in _placements)
            HeroToastProvider(
              placement: placement,
              queue: _placementQueues[placement],
            ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: HeroTheme.of(context).spacing(80),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final HeroToastPlacement placement in _placements)
                  _button(
                    _placementLabel(placement),
                    () => _placementQueues[placement]!.add(
                      const HeroToastData(
                        title: 'Event created',
                        description: 'Event has been created',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      code: '''
// A queue and a provider per placement.
final queues = {
  for (final placement in HeroToastPlacement.values)
    placement: HeroToastQueue(maxVisibleToasts: 3),
};

for (final placement in HeroToastPlacement.values)
  HeroToastProvider(placement: placement, queue: queues[placement]),

HeroButton(
  size: HeroSize.sm,
  variant: HeroButtonVariant.secondary,
  onPressed: () => queues[HeroToastPlacement.topStart]!.add(
    const HeroToastData(
      title: 'Event created',
      description: 'Event has been created',
    ),
  ),
  child: const Text('top start'),
)''',
    ),
    DemoExample(
      title: 'Expanded Stack',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroToastProvider(
            queue: _expandedQueue,
            isExpanded: true,
            semanticLabel: 'Expanded notifications',
          ),
          _button('Show 3 toasts', () {
            _expandedQueue.add(const HeroToastData(title: 'Simple message'));
            Timer(const Duration(milliseconds: 400), () {
              _expandedQueue.add(
                const HeroToastData(
                  title: 'Operation completed',
                  variant: HeroToastVariant.success,
                ),
              );
            });
            Timer(const Duration(milliseconds: 800), () {
              _expandedQueue.add(
                const HeroToastData(
                  title: 'New update available',
                  variant: HeroToastVariant.accent,
                ),
              );
            });
          }),
        ],
      ),
      code: '''
final queue = HeroToastQueue();

HeroToastProvider(
  queue: queue,
  isExpanded: true,
  semanticLabel: 'Expanded notifications',
),
HeroButton(
  size: HeroSize.sm,
  variant: HeroButtonVariant.secondary,
  onPressed: () {
    queue.add(const HeroToastData(title: 'Simple message'));
    Timer(const Duration(milliseconds: 400), () => queue.add(
      const HeroToastData(
        title: 'Operation completed',
        variant: HeroToastVariant.success,
      ),
    ));
    Timer(const Duration(milliseconds: 800), () => queue.add(
      const HeroToastData(
        title: 'New update available',
        variant: HeroToastVariant.accent,
      ),
    ));
  },
  child: const Text('Show 3 toasts'),
)''',
    ),
    DemoExample(
      title: 'Simple Toasts',
      builder: (BuildContext context) => _centered(<Widget>[
        _button('Default', () => heroToast('Simple message')),
        _button('Success', () => heroToast.success('Operation completed')),
        _button('Info', () => heroToast.info('New update available')),
        _button(
          'Warning',
          () => heroToast.warning('Please check your settings'),
        ),
        _button('Error', () => heroToast.danger('Something went wrong')),
      ]),
      code: '''
heroToast('Simple message');
heroToast.success('Operation completed');
heroToast.info('New update available');
heroToast.warning('Please check your settings');
heroToast.danger('Something went wrong');''',
    ),
    DemoExample(
      title: 'Custom Indicators',
      builder: (BuildContext context) => _centered(<Widget>[
        _button(
          'Custom indicator',
          () => heroToast(
            'Custom icon indicator',
            indicator: const HeroIcon(HeroIcons.star),
          ),
        ),
      ]),
      code: '''
heroToast(
  'Custom icon indicator',
  indicator: const HeroIcon(HeroIcons.star),
);''',
    ),
    DemoExample(
      title: 'Custom Toast Rendering',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroToastProvider(
            queue: _customToastQueue,
            builder: (BuildContext context, HeroQueuedToast toast) {
              final HeroThemeData theme = HeroTheme.of(context);
              final HeroToastData data = toast.data;
              return HeroToast(
                variant: data.variant,
                borderRadius: theme.radii.xl,
                side: BorderSide(color: theme.colors.border),
                children: <Widget>[
                  HeroToastContent(
                    children: <Widget>[
                      Row(
                        spacing: theme.spacing(2),
                        children: <Widget>[
                          HeroToastIndicator(
                            variant: data.variant,
                            child: HeroIcon(
                              HeroToastIndicator.iconFor(data.variant),
                              color: theme.colors.accentSoftForeground,
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                end: theme.spacing(6),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  if (data.title != null)
                                    HeroToastTitle(
                                      child: Text(
                                        data.title!,
                                        style: TextStyle(
                                          color:
                                              theme.colors.accentSoftForeground,
                                        ),
                                      ),
                                    ),
                                  if (data.description != null)
                                    HeroToastDescription(
                                      child: Text(data.description!),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PositionedDirectional(
                    end: theme.spacing(2),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: HeroToastCloseButton(
                        alwaysVisible: true,
                        style: HeroButtonStyle(
                          height: theme.spacing(6),
                          iconSize: theme.spacing(4),
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            theme.colors.defaultColor.withValues(alpha: 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          _button(
            'Custom toast',
            () => _customToastQueue.add(
              const HeroToastData(
                title: 'Custom layout toast',
                description: 'This uses a custom render function',
              ),
            ),
          ),
        ],
      ),
      code: '''
HeroToastProvider(
  queue: queue,
  builder: (context, toast) => HeroToast(
    variant: toast.data.variant,
    borderRadius: 12,
    side: BorderSide(color: theme.colors.border),
    children: [
      HeroToastContent(children: [
        Row(spacing: 8, children: [
          HeroToastIndicator(variant: toast.data.variant),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroToastTitle(child: Text(toast.data.title!)),
              HeroToastDescription(child: Text(toast.data.description!)),
            ],
          ),
        ]),
      ]),
      const PositionedDirectional(
        end: 8,
        top: 0,
        bottom: 0,
        child: Center(child: HeroToastCloseButton(alwaysVisible: true)),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Promise & Loading',
      builder: (BuildContext context) => const _PromiseExample(),
      code: '''
heroToast.promise<UploadResult>(
  uploadFile(),
  loading: 'Uploading file...',
  success: (data) => 'File \${data.filename} uploaded (\${data.size}KB)',
  error: (_) => 'Failed to upload file',
);

// Manual loading state
final id = heroToast(
  'Uploading file...',
  description: 'Please wait while we upload your file',
  isLoading: true,
  timeout: Duration.zero,
);
Timer(const Duration(seconds: 3), () {
  heroToast.update(
    id,
    'File uploaded',
    description: 'Your file has been uploaded successfully',
    variant: HeroToastVariant.success,
  );
});''',
    ),
    DemoExample(
      title: 'Callbacks',
      builder: (BuildContext context) => const _CallbacksExample(),
      code: '''
heroToast(
  'File saved',
  timeout: const Duration(seconds: 3),
  onClose: () => addToHistory('File saved (closed after 3 seconds)'),
);
heroToast(
  'Important notification',
  description: 'This toast will stay until dismissed',
  timeout: Duration.zero,
  onClose: () => addToHistory('Important notification (manually closed)'),
);''',
    ),
    DemoExample(
      title: 'Custom Queues',
      builder: (BuildContext context) {
        final HeroColors colors = HeroTheme.of(context).colors;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: <Widget>[
            HeroToastProvider(queue: _notificationQueue),
            _button(
              'Add notification (max 2)',
              () => _notificationQueue.add(
                const HeroToastData(
                  title: 'New notification',
                  description: 'You have a new message',
                ),
              ),
            ),
            HeroToastProvider(
              placement: HeroToastPlacement.bottomStart,
              queue: _errorQueue,
            ),
            _button(
              'Add error (max 3)',
              () => _errorQueue.add(
                const HeroToastData(
                  title: 'Error occurred',
                  description: 'Failed to save changes',
                  variant: HeroToastVariant.danger,
                ),
              ),
              variant: HeroButtonVariant.dangerSoft,
            ),
            HeroToastProvider(
              placement: HeroToastPlacement.bottomEnd,
              queue: _successQueue,
            ),
            _button(
              'Add success (max 1)',
              () => _successQueue.add(
                HeroToastData(
                  title: 'Success!',
                  description:
                      'Operation ${DateTime.now().millisecondsSinceEpoch}',
                  variant: HeroToastVariant.success,
                ),
              ),
              style: _text(colors.successSoftForeground),
            ),
          ],
        );
      },
      code: '''
final notifications = HeroToastQueue(maxVisibleToasts: 2);
final errors = HeroToastQueue(maxVisibleToasts: 3);
final successes = HeroToastQueue(maxVisibleToasts: 1);

HeroToastProvider(queue: notifications),
HeroToastProvider(placement: HeroToastPlacement.bottomStart, queue: errors),
HeroToastProvider(placement: HeroToastPlacement.bottomEnd, queue: successes),

errors.add(const HeroToastData(
  title: 'Error occurred',
  description: 'Failed to save changes',
  variant: HeroToastVariant.danger,
));''',
    ),
    DemoExample(
      title: 'Custom Styles',
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroToastProvider(
            queue: _stylesQueue,
            builder: (BuildContext context, HeroQueuedToast toast) {
              final HeroThemeData theme = HeroTheme.of(context);
              final bool dark = theme.isDark;
              // Tailwind neutral-50/400/600/900.
              const Color neutral50 = Color(0xFFFAFAFA);
              const Color neutral400 = Color(0xFFA3A3A3);
              const Color neutral600 = Color(0xFF525252);
              const Color neutral900 = Color(0xFF171717);
              final Color muted = dark ? neutral400 : neutral600;
              final HeroToastData data = toast.data;
              return HeroToast(
                variant: data.variant,
                borderRadius: theme.radii.xl,
                backgroundColor: theme.colors.surface,
                side: BorderSide(
                  color: theme.colors.border.withValues(alpha: 0.8),
                ),
                // shadow-lg.
                shadows: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 10),
                    blurRadius: 15,
                    spreadRadius: -3,
                  ),
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, 4),
                    blurRadius: 6,
                    spreadRadius: -4,
                  ),
                ],
                children: <Widget>[
                  HeroToastContent(
                    children: <Widget>[
                      Row(
                        spacing: theme.spacing(2.5),
                        children: <Widget>[
                          HeroToastIndicator(
                            variant: data.variant,
                            child: HeroIcon(
                              HeroToastIndicator.iconFor(data.variant),
                              color: muted,
                            ),
                          ),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: theme.spacing(0.5),
                              children: <Widget>[
                                if (data.title != null)
                                  HeroToastTitle(
                                    child: Text(
                                      data.title!,
                                      style: TextStyle(
                                        color: dark ? neutral50 : neutral900,
                                      ),
                                    ),
                                  ),
                                if (data.description != null)
                                  HeroToastDescription(
                                    child: Text(
                                      data.description!,
                                      style: TextStyle(color: muted),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          _button(
            'Show toast',
            () => _stylesQueue.add(
              const HeroToastData(title: 'Saved', description: 'Draft synced'),
            ),
          ),
        ],
      ),
      code: '''
HeroToastProvider(
  queue: queue,
  builder: (context, toast) => HeroToast(
    variant: toast.data.variant,
    borderRadius: 12,
    backgroundColor: theme.colors.surface,
    side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
    shadows: shadowLg,
    children: [
      HeroToastContent(children: [
        Row(spacing: 10, children: [
          HeroToastIndicator(variant: toast.data.variant),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              HeroToastTitle(child: Text(toast.data.title!)),
              HeroToastDescription(child: Text(toast.data.description!)),
            ],
          ),
        ]),
      ]),
    ],
  ),
)''',
    ),
  ],
);

class _PromiseExample extends StatelessWidget {
  const _PromiseExample();

  static Future<T> _later<T>(Duration delay, T Function() compute) =>
      Future<T>.delayed(delay, compute);

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    Widget heading(String title, String subtitle) => Column(
      children: <Widget>[
        Text(
          title,
          style: theme.typography
              .style(HeroFontSize.sm, weight: HeroTypography.medium)
              .copyWith(color: theme.colors.foreground),
        ),
        Text(
          subtitle,
          style: theme.typography.xs.copyWith(color: theme.colors.muted),
        ),
      ],
    );
    const Duration two = Duration(seconds: 2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(8),
      children: <Widget>[
        _appRegion,
        Column(
          spacing: theme.spacing(3),
          children: <Widget>[
            heading(
              'Using heroToast.promise()',
              'Automatically handles loading, success, and error states',
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: <Widget>[
                _button(
                  'Upload file',
                  () => heroToast.promise<(String, int)>(
                    _later(two, () => ('document.pdf', 1024)),
                    loading: 'Uploading file...',
                    success: ((String, int) data) =>
                        'File ${data.$1} uploaded (${data.$2}KB)',
                    error: (_) => 'Failed to upload file',
                  ),
                ),
                _button(
                  'Create event (error)',
                  () => heroToast.promise<void>(
                    _later<void>(
                      two,
                      () =>
                          throw StateError('Network error. Please try again.'),
                    ),
                    loading: 'Creating event...',
                    success: (_) => 'Event created',
                    error: (Object e) => (e as StateError).message,
                  ),
                ),
                _button(
                  'Save data (random)',
                  () => heroToast.promise<int>(
                    _later(two, () {
                      if (math.Random().nextBool()) return 42;
                      throw StateError('Failed to save data');
                    }),
                    loading: 'Saving changes...',
                    success: (int count) => 'Saved $count items',
                    error: (Object e) => (e as StateError).message,
                  ),
                ),
                _button(
                  'Fetch user',
                  () => heroToast.promise<String>(
                    _later(two, () => 'John Doe'),
                    loading: 'Loading user...',
                    success: (String name) => 'Welcome back, $name!',
                    error: (_) => 'Failed to fetch user',
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          spacing: theme.spacing(3),
          children: <Widget>[
            heading(
              'Manual Loading State',
              'Manually control loading state with isLoading',
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: <Widget>[
                _button('Upload with loading', () {
                  final String id = heroToast(
                    'Uploading file...',
                    description: 'Please wait while we upload your file',
                    isLoading: true,
                    timeout: Duration.zero,
                  );
                  Timer(const Duration(seconds: 3), () {
                    heroToast.update(
                      id,
                      'File uploaded',
                      description: 'Your file has been uploaded successfully',
                      variant: HeroToastVariant.success,
                    );
                  });
                }),
                _button('Payment processing', () {
                  final String id = heroToast(
                    'Processing payment...',
                    isLoading: true,
                    timeout: Duration.zero,
                  );
                  Timer(const Duration(milliseconds: 2500), () {
                    heroToast.update(
                      id,
                      'Payment processed',
                      description:
                          'Your payment has been processed successfully',
                      variant: HeroToastVariant.success,
                    );
                  });
                }),
                _button('Loading to error', () {
                  final String id = heroToast(
                    'Saving changes...',
                    isLoading: true,
                    timeout: Duration.zero,
                  );
                  Timer(two, () {
                    heroToast.update(
                      id,
                      'Failed to save',
                      description: 'Please try again',
                      variant: HeroToastVariant.danger,
                    );
                  });
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CallbacksExample extends StatefulWidget {
  const _CallbacksExample();

  @override
  State<_CallbacksExample> createState() => _CallbacksExampleState();
}

class _CallbacksExampleState extends State<_CallbacksExample> {
  final List<(String, String)> _history = <(String, String)>[];

  void _add(String message) {
    if (!mounted) return;
    final DateTime now = DateTime.now();
    final String time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    setState(() {
      _history.insert(0, (message, time));
      if (_history.length > 5) _history.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.spacing(6),
      children: <Widget>[
        _appRegion,
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: <Widget>[
            _button(
              'Custom timeout (3s)',
              () => heroToast(
                'File saved',
                timeout: const Duration(seconds: 3),
                onClose: () => _add('File saved (closed after 3 seconds)'),
              ),
            ),
            _button(
              'Custom timeout (10s)',
              () => heroToast(
                'Changes saved',
                timeout: const Duration(seconds: 10),
                onClose: () => _add('Changes saved (closed after 10 seconds)'),
              ),
            ),
            _button(
              'With onClose callback',
              () => heroToast.success(
                'Event created',
                onClose: () =>
                    _add('Event created (closed after default timeout)'),
              ),
            ),
            _button(
              'Persistent toast',
              () => heroToast(
                'Important notification',
                description: 'This toast will stay until dismissed',
                timeout: Duration.zero,
                onClose: () => _add('Important notification (manually closed)'),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(2),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Closed History',
                  style: theme.typography
                      .style(HeroFontSize.sm, weight: HeroTypography.medium)
                      .copyWith(color: theme.colors.foreground),
                ),
                if (_history.isNotEmpty)
                  HeroButton(
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.tertiary,
                    onPressed: () => setState(_history.clear),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            DecoratedBox(
              decoration: ShapeDecoration(
                color: theme.colors.surface,
                shape: theme.shapeAll(
                  theme.radii.lg,
                  side: BorderSide(color: theme.colors.border),
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: theme.spacing(30)),
                child: Padding(
                  padding: EdgeInsets.all(theme.spacing(4)),
                  child: _history.isEmpty
                      ? Text(
                          'No toasts closed yet. Try closing one above!',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.muted,
                          ),
                        )
                      : Column(
                          spacing: theme.spacing(2),
                          children: <Widget>[
                            for (final (String message, String time)
                                in _history)
                              DecoratedBox(
                                decoration: ShapeDecoration(
                                  color: theme.colors.defaultColor,
                                  shape: theme.shapeAll(
                                    theme.radii.md,
                                    side: BorderSide(
                                      color: theme.colors.border,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: theme.spacing(3),
                                    vertical: theme.spacing(2),
                                  ),
                                  child: Row(
                                    spacing: theme.spacing(3),
                                    children: <Widget>[
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: message,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: '  ($time)',
                                                style: theme.typography.xs
                                                    .copyWith(
                                                      color: theme.colors.muted,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          style: theme.typography.sm.copyWith(
                                            color: theme.colors.foreground,
                                          ),
                                        ),
                                      ),
                                      DecoratedBox(
                                        decoration: ShapeDecoration(
                                          color: theme.colors.success
                                              .withValues(alpha: 0.1),
                                          shape: const CircleBorder(),
                                        ),
                                        child: SizedBox.square(
                                          dimension: theme.spacing(5),
                                          child: Center(
                                            child: HeroIcon(
                                              HeroIcons.check,
                                              size: theme.spacing(3),
                                              color: theme
                                                  .colors
                                                  .successSoftForeground,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
