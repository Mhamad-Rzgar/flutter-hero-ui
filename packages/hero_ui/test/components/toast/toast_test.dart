import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const Size _phone = Size(390, 700);

Finder get _toasts => find.byType(HeroToast);

/// Pumps a provider for [queue] (created and disposed by the test).
Future<HeroToastQueue> _pumpProvider(
  WidgetTester tester, {
  HeroToastQueue? queue,
  HeroToastPlacement placement = HeroToastPlacement.bottom,
  bool isExpanded = false,
  int? maxVisibleToasts,
  HeroToastBuilder? builder,
  Size size = _phone,
  TextDirection textDirection = TextDirection.ltr,
}) async {
  final HeroToastQueue q = queue ?? HeroToastQueue();
  addTearDown(q.dispose);
  await pumpHero(
    tester,
    HeroToastProvider(
      queue: q,
      placement: placement,
      isExpanded: isExpanded,
      maxVisibleToasts: maxVisibleToasts,
      builder: builder,
    ),
    surfaceSize: size,
    textDirection: textDirection,
  );
  return q;
}

Rect _rectOf(WidgetTester tester, String title) =>
    tester.getRect(find.ancestor(of: find.text(title), matching: _toasts));

void main() {
  testWidgets('shows queued toasts at the bottom, 16 px from the edges', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    expect(_toasts, findsNothing);
    queue.add(
      const HeroToastData(title: 'Saved', description: 'Draft synced'),
      timeout: Duration.zero,
    );
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Draft synced'), findsOneWidget);
    final Rect rect = _rectOf(tester, 'Saved');
    expect(rect.left, 16);
    expect(rect.width, _phone.width - 32);
    expect(rect.bottom, _phone.height - 16);
    // The default info icon.
    expect(
      tester
          .widget<HeroIcon>(
            find.descendant(
              of: find.byType(HeroToastIndicator),
              matching: find.byType(HeroIcon),
            ),
          )
          .icon,
      HeroIcons.info,
    );
  });

  testWidgets('auto-dismisses after 4 s; onClose fires at dismissal', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    int closed = 0;
    queue.add(const HeroToastData(title: 'Hello'), onClose: () => closed++);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3900));
    expect(find.text('Hello'), findsOneWidget);
    expect(closed, 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(closed, 1);
    // Still mounted for the exit animation.
    expect(queue.visibleToasts.single.isExiting, isTrue);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
    expect(queue.visibleToasts, isEmpty);
  });

  testWidgets('persistent toasts stay; close() and clear() remove them', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    final String a = queue.add(
      const HeroToastData(title: 'A'),
      timeout: Duration.zero,
    );
    queue.add(const HeroToastData(title: 'B'), timeout: Duration.zero);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 20));
    expect(queue.visibleToasts, hasLength(2));
    queue.close(a);
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      queue.visibleToasts.map((HeroQueuedToast t) => t.data.title),
      <String?>['B'],
    );
    queue.clear();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(_toasts, findsNothing);
  });

  testWidgets('the close button appears on hover and closes the toast', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    queue.add(const HeroToastData(title: 'Hover me'), timeout: Duration.zero);
    await tester.pumpAndSettle();
    double closeOpacity() => tester
        .widget<AnimatedOpacity>(
          find
              .ancestor(
                of: find.byType(HeroCloseButton),
                matching: find.byType(AnimatedOpacity),
              )
              .first,
        )
        .opacity;
    expect(closeOpacity(), 0);
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(find.text('Hover me')));
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    expect(closeOpacity(), 1);
    await tester.tap(find.byType(HeroCloseButton));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(queue.visibleToasts, isEmpty);
  });

  testWidgets('hovering the stack pauses the countdown', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    queue.add(const HeroToastData(title: 'Paused'));
    await tester.pumpAndSettle();
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(find.text('Paused')));
    addTearDown(mouse.removePointer);
    await tester.pump();
    expect(queue.isPaused, isTrue);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Paused'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(queue.isPaused, isFalse);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Paused'), findsNothing);
  });

  testWidgets('collapsed stack peeks 12 px; hovering expands it', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    queue
      ..add(const HeroToastData(title: 'First'), timeout: Duration.zero)
      ..add(const HeroToastData(title: 'Second'), timeout: Duration.zero);
    await tester.pumpAndSettle();
    final Rect front = _rectOf(tester, 'Second');
    Rect back = tester.getRect(_toasts.first);
    // The older toast is folded behind: shifted up 12 px, 95% wide, same
    // height as the front toast.
    expect(front.bottom - back.bottom, closeTo(12, 0.5));
    expect(back.width, closeTo(front.width * 0.95, 0.5));
    expect(back.height, closeTo(front.height * 0.95, 0.5));

    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: front.center);
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    back = _rectOf(tester, 'First');
    expect(back.bottom, closeTo(front.top - 12, 0.5));
    expect(back.width, front.width);
    // Moving through the gap keeps the stack expanded.
    await mouse.moveTo(Offset(front.center.dx, front.top - 6));
    await tester.pumpAndSettle();
    expect(_rectOf(tester, 'First').bottom, closeTo(front.top - 12, 0.5));
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(
      front.bottom - tester.getRect(_toasts.first).bottom,
      closeTo(12, 0.5),
    );
  });

  testWidgets('toasts beyond maxVisibleToasts fade out', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(
      tester,
      maxVisibleToasts: 2,
      isExpanded: true,
    );
    for (final String title in <String>['1', '2', '3']) {
      queue.add(HeroToastData(title: title), timeout: Duration.zero);
    }
    await tester.pumpAndSettle();
    double opacityOf(String title) => tester
        .widget<AnimatedOpacity>(
          find
              .ancestor(
                of: find.text(title),
                matching: find.byType(AnimatedOpacity),
              )
              .last,
        )
        .opacity;
    expect(opacityOf('3'), 1);
    expect(opacityOf('2'), 1);
    expect(opacityOf('1'), 0);
  });

  testWidgets('update() replaces content in place and restarts the timer', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    final HeroToaster toaster = HeroToaster(queue);
    final String key = toaster(
      'Uploading...',
      isLoading: true,
      timeout: Duration.zero,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(HeroSpinner), findsOneWidget);
    expect(
      toaster.update(key, 'Uploaded', variant: HeroToastVariant.success),
      key,
    );
    await tester.pump();
    expect(find.text('Uploaded'), findsOneWidget);
    expect(find.byType(HeroSpinner), findsNothing);
    expect(
      tester
          .widget<HeroIcon>(
            find.descendant(
              of: find.byType(HeroToastIndicator),
              matching: find.byType(HeroIcon),
            ),
          )
          .icon,
      HeroIcons.success,
    );
    // No timeout given: still persistent.
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Uploaded'), findsOneWidget);
    toaster.update(key, 'Done', timeout: const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsNothing);
    // Updating a gone toast adds a new one.
    final String again = toaster.update(key, 'Back', timeout: Duration.zero);
    expect(again, isNot(key));
    await tester.pumpAndSettle();
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('promise toasts settle to success or danger', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    final HeroToaster toaster = HeroToaster(queue);
    toaster.promise<int>(
      Future<int>.delayed(const Duration(seconds: 1), () => 42),
      loading: 'Saving...',
      success: (int value) => 'Saved $value items',
      error: (Object e) => 'Failed',
    );
    toaster.promise<int>(
      Future<int>.delayed(
        const Duration(seconds: 1),
        () => throw StateError('Network error'),
      ),
      loading: 'Creating...',
      success: (int value) => 'Created',
      error: (Object e) => 'Network error',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HeroSpinner), findsNWidgets(2));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Saved 42 items'), findsOneWidget);
    expect(find.text('Network error'), findsOneWidget);
    expect(
      queue.visibleToasts.map((HeroQueuedToast t) => t.data.variant),
      containsAll(<HeroToastVariant>[
        HeroToastVariant.success,
        HeroToastVariant.danger,
      ]),
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(queue.visibleToasts, isEmpty);
  });

  testWidgets('variants color the title and indicator', (
    WidgetTester tester,
  ) async {
    final HeroColors colors = HeroThemeData.light().colors;
    final HeroToastQueue queue = await _pumpProvider(tester, isExpanded: true);
    final HeroToaster toaster = HeroToaster(queue);
    toaster.success('Success', timeout: Duration.zero);
    toaster.info('Info', timeout: Duration.zero);
    toaster.danger('Danger', timeout: Duration.zero);
    await tester.pumpAndSettle();
    Color? titleColor(String text) =>
        DefaultTextStyle.of(tester.element(find.text(text))).style.color;
    expect(titleColor('Success'), colors.successSoftForeground);
    expect(titleColor('Info'), colors.accentSoftForeground);
    expect(titleColor('Danger'), colors.dangerSoftForeground);
  });

  testWidgets('action buttons sit below the text on touch layouts', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    int pressed = 0;
    queue.add(
      HeroToastData(
        title: 'Invite',
        action: HeroToastAction(label: 'Dismiss', onPressed: () => pressed++),
      ),
      timeout: Duration.zero,
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Dismiss')).dy,
      greaterThan(tester.getBottomLeft(find.text('Invite')).dy),
    );
    await tester.tap(find.text('Dismiss'));
    expect(pressed, 1);
  });

  testWidgets('placements and RTL', (WidgetTester tester) async {
    const Size wide = Size(1000, 700);
    for (final (
          HeroToastPlacement placement,
          TextDirection direction,
          Offset corner,
        )
        in <(HeroToastPlacement, TextDirection, Offset)>[
          (
            HeroToastPlacement.topStart,
            TextDirection.ltr,
            const Offset(16, 16),
          ),
          (
            HeroToastPlacement.topEnd,
            TextDirection.ltr,
            const Offset(1000 - 16 - 460, 16),
          ),
          (
            HeroToastPlacement.bottomStart,
            TextDirection.rtl,
            const Offset(1000 - 16 - 460, 700 - 16 - _heightOfOneLine),
          ),
          (
            HeroToastPlacement.top,
            TextDirection.ltr,
            const Offset((1000 - 460) / 2, 16),
          ),
        ]) {
      final HeroToastQueue queue = await _pumpProvider(
        tester,
        placement: placement,
        size: wide,
        textDirection: direction,
      );
      queue.add(const HeroToastData(title: 'Placed'), timeout: Duration.zero);
      await tester.pumpAndSettle();
      final Rect rect = _rectOf(tester, 'Placed');
      expect(rect.width, 460, reason: '$placement');
      expect(rect.left, closeTo(corner.dx, 0.5), reason: '$placement');
      if (placement.isTop) expect(rect.top, 16);
      queue.clear();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Alt+T focuses and expands the region; Escape folds it', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    queue
      ..add(const HeroToastData(title: 'First'), timeout: Duration.zero)
      ..add(const HeroToastData(title: 'Second'), timeout: Duration.zero);
    await tester.pumpAndSettle();
    final Rect front = _rectOf(tester, 'Second');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
    await tester.pumpAndSettle();
    expect(queue.isPaused, isTrue);
    expect(_rectOf(tester, 'First').bottom, closeTo(front.top - 12, 0.5));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(queue.isPaused, isFalse);
    expect(
      front.bottom - tester.getRect(_toasts.first).bottom,
      closeTo(12, 0.5),
    );
  });

  testWidgets('the app going to the background pauses the countdown', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(tester);
    queue.add(const HeroToastData(title: 'Background'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(queue.isPaused, isTrue);
    await tester.pump(const Duration(seconds: 10));
    expect(queue.visibleToasts, hasLength(1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(queue.isPaused, isFalse);
    queue.clear();
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('custom builder renders custom toasts', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = await _pumpProvider(
      tester,
      builder: (BuildContext context, HeroQueuedToast toast) => HeroToast(
        variant: toast.data.variant,
        borderRadius: 12,
        children: <Widget>[
          HeroToastContent(
            children: <Widget>[
              HeroToastTitle(child: Text('Custom ${toast.data.title}')),
            ],
          ),
          const HeroToastCloseButton(alwaysVisible: true),
        ],
      ),
    );
    queue.add(const HeroToastData(title: 'layout'), timeout: Duration.zero);
    await tester.pumpAndSettle();
    expect(find.text('Custom layout'), findsOneWidget);
    await tester.tap(find.byType(HeroCloseButton));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(queue.visibleToasts, isEmpty);
  });

  testWidgets('only the first provider of a queue renders it', (
    WidgetTester tester,
  ) async {
    final HeroToastQueue queue = HeroToastQueue();
    addTearDown(queue.dispose);
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroToastProvider(queue: queue),
          HeroToastProvider(queue: queue),
        ],
      ),
      surfaceSize: _phone,
    );
    queue.add(const HeroToastData(title: 'Once'), timeout: Duration.zero);
    await tester.pumpAndSettle();
    expect(find.text('Once'), findsOneWidget);
  });

  testWidgets('wraps the app and heroToast shows on top of routes', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = _phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      HeroApp(
        builder: (BuildContext context, Widget? child) =>
            HeroToastProvider(child: child!),
        home: Builder(
          builder: (BuildContext context) => Center(
            child: HeroButton(
              onPressed: () => HeroToast.show(context, 'From the page'),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );
    heroToast('Global', timeout: Duration.zero);
    await tester.pumpAndSettle();
    expect(find.text('Global'), findsOneWidget);
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.text('From the page'), findsOneWidget);
    heroToast.clear();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(heroToastQueue.visibleToasts, isEmpty);
  });

  testWidgets('HeroToast.show adds a region when none renders the queue', (
    WidgetTester tester,
  ) async {
    late BuildContext page;
    await pumpHero(
      tester,
      Builder(
        builder: (BuildContext context) {
          page = context;
          return const SizedBox();
        },
      ),
      surfaceSize: _phone,
    );
    HeroToast.show(page, 'Installed', timeout: Duration.zero);
    await tester.pumpAndSettle();
    expect(find.text('Installed'), findsOneWidget);
    heroToast.clear();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  });

  testWidgets('semantics: a labelled notifications region', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final HeroToastQueue queue = await _pumpProvider(tester);
    queue.add(const HeroToastData(title: 'Announce'), timeout: Duration.zero);
    await tester.pumpAndSettle();
    final SemanticsNode region = tester.getSemantics(
      find.bySemanticsLabel('Notifications'),
    );
    expect(region.role, SemanticsRole.region);
    final SemanticsNode toast = tester.getSemantics(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics && (widget.properties.liveRegion ?? false),
      ),
    );
    expect(toast.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  testWidgets('text scale 2 does not overflow', (WidgetTester tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final HeroToastQueue queue = await _pumpProvider(tester);
    queue.add(
      HeroToastData(
        title: 'You have been invited to join a team',
        description: 'Bob sent you an invitation to join HeroUI team',
        action: HeroToastAction(label: 'Dismiss', onPressed: () {}),
      ),
      timeout: Duration.zero,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

const double _heightOfOneLine = 44;
