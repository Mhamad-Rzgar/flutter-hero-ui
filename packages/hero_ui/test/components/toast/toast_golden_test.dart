import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

HeroToastQueue _queue(List<HeroToastData> toasts) {
  final HeroToastQueue queue = HeroToastQueue();
  // Oldest first so the first entry ends up at the back.
  for (final HeroToastData data in toasts.reversed) {
    queue.add(data, timeout: Duration.zero);
  }
  return queue;
}

const List<HeroToastData> _variants = <HeroToastData>[
  HeroToastData(
    title: 'You have been invited to join a team',
    description: 'Bob sent you an invitation to join HeroUI team',
    indicator: HeroIcon(HeroIcons.persons),
  ),
  HeroToastData(
    title: 'You have 2 credits left',
    description: 'Get a paid plan for more credits',
    variant: HeroToastVariant.accent,
  ),
  HeroToastData(
    title: 'You have upgraded your plan',
    variant: HeroToastVariant.success,
  ),
  HeroToastData(
    title: 'You have no credits left',
    variant: HeroToastVariant.warning,
  ),
  HeroToastData(title: 'Storage is full', variant: HeroToastVariant.danger),
];

void main() {
  heroGoldenTest(
    'toast variants, expanded stack',
    name: 'toast_variants',
    size: const Size(400, 520),
    builder: (HeroThemeData theme) => HeroToastProvider(
      queue: _queue(_variants),
      isExpanded: true,
      maxVisibleToasts: 5,
    ),
  );

  heroGoldenTest(
    'toast collapsed stack',
    name: 'toast_collapsed',
    size: const Size(400, 260),
    builder: (HeroThemeData theme) => HeroToastProvider(
      queue: _queue(const <HeroToastData>[
        HeroToastData(title: 'Simple message'),
        HeroToastData(
          title: 'Operation completed',
          variant: HeroToastVariant.success,
        ),
        HeroToastData(
          title: 'New update available',
          description: 'Version 3.2 is ready to install',
          variant: HeroToastVariant.accent,
        ),
      ]),
    ),
  );

  heroGoldenTest(
    'toast with action from 768 px, top end',
    name: 'toast_desktop',
    size: const Size(520, 200),
    builder: (HeroThemeData theme) => HeroTheme(
      data: theme.copyWith(density: HeroDensity.desktop),
      child: HeroToastProvider(
        placement: HeroToastPlacement.topEnd,
        queue: _queue(<HeroToastData>[
          HeroToastData(
            title: 'You have been invited to join a team',
            description: 'Bob sent you an invitation to join HeroUI team',
            indicator: const HeroIcon(HeroIcons.persons),
            action: HeroToastAction(
              label: 'Dismiss',
              variant: HeroButtonVariant.tertiary,
              onPressed: () {},
            ),
          ),
        ]),
      ),
    ),
  );

  heroGoldenTest(
    'toast loading and hovered close button, action below the text',
    name: 'toast_loading',
    size: const Size(400, 260),
    // Reduced motion stops the spinner so the stack can settle.
    builder: (HeroThemeData theme) => HeroTheme(
      data: theme.copyWith(motion: const HeroMotion(reduceMotion: true)),
      child: HeroToastProvider(
        queue: _queue(<HeroToastData>[
          const HeroToastData(
            title: 'Uploading file...',
            description: 'Please wait while we upload your file',
            isLoading: true,
          ),
          HeroToastData(
            title: 'You have 2 credits left',
            description: 'Get a paid plan for more credits',
            variant: HeroToastVariant.accent,
            action: HeroToastAction(label: 'Upgrade', onPressed: () {}),
          ),
        ]),
        isExpanded: true,
      ),
    ),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(
        location: tester.getCenter(find.text('Uploading file...')),
      );
      addTearDown(mouse.removePointer);
      await tester.pump(const Duration(milliseconds: 400));
    },
  );
}
