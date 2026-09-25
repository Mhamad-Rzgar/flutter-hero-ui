import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const Size _surface = Size(600, 400);

Widget _button(String label, {VoidCallback? onPressed}) =>
    HeroButton(onPressed: onPressed ?? () {}, child: Text(label));

/// Lets a state change reach the overlay (the portal opens one frame
/// later) and the enter transition finish.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

Future<TestGesture> _mouse(WidgetTester tester) async {
  final TestGesture gesture = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
  );
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

Rect _bubble(WidgetTester tester, String text) => tester.getRect(
  find.ancestor(of: find.text(text), matching: find.byType(HeroOverlaySurface)),
);

void main() {
  testWidgets('hover opens after the theme delay and closes after the close '
      'delay', (WidgetTester tester) async {
    final List<bool> changes = <bool>[];
    await pumpHero(
      tester,
      HeroTooltip(
        content: const Text('Tip'),
        onOpenChanged: changes.add,
        child: _button('Hover me'),
      ),
      surfaceSize: _surface,
    );
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Hover me')));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('Tip'), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    await _settle(tester);
    expect(find.text('Tip'), findsOneWidget);
    expect(changes, <bool>[true]);

    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 400));
    expect(changes, <bool>[true]);
    await tester.pump(const Duration(milliseconds: 100));
    await _settle(tester);
    expect(find.text('Tip'), findsNothing);
    expect(changes, <bool>[true, false]);
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('a delay of zero opens at once; the pointer can move onto the '
      'tooltip', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroTooltip(
        delay: Duration.zero,
        content: const Text('Tip'),
        child: _button('Hover me'),
      ),
      surfaceSize: _surface,
    );
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Hover me')));
    await _settle(tester);
    expect(find.text('Tip'), findsOneWidget);

    // Leave the trigger for the tooltip before the close delay ends.
    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 200));
    await mouse.moveTo(tester.getCenter(find.text('Tip')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Tip'), findsOneWidget);

    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 500));
    await _settle(tester);
    expect(find.text('Tip'), findsNothing);
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('warm-up: the next tooltip opens at once and replaces the '
      'first; after the cooldown the delay applies again', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroTooltip(content: const Text('First tip'), child: _button('One')),
          const SizedBox(width: 40),
          HeroTooltip(content: const Text('Second tip'), child: _button('Two')),
        ],
      ),
      surfaceSize: _surface,
    );
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('One')));
    await tester.pump(const Duration(milliseconds: 1500));
    await _settle(tester);
    expect(find.text('First tip'), findsOneWidget);

    await mouse.moveTo(tester.getCenter(find.text('Two')));
    await _settle(tester);
    expect(find.text('Second tip'), findsOneWidget);
    expect(find.text('First tip'), findsNothing);

    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 500));
    await _settle(tester);
    expect(find.text('Second tip'), findsNothing);
    // Still warm right after closing.
    await mouse.moveTo(tester.getCenter(find.text('One')));
    await _settle(tester);
    expect(find.text('First tip'), findsOneWidget);

    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(milliseconds: 500));
    await _settle(tester);
    await tester.pump(HeroTooltip.warmUpCooldown);
    await mouse.moveTo(tester.getCenter(find.text('Two')));
    await _settle(tester);
    expect(find.text('Second tip'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1500));
    await _settle(tester);
    expect(find.text('Second tip'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('keyboard focus opens at once, blur closes, pointer focus '
      'does not open', (WidgetTester tester) async {
    await pumpHero(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroTooltip(content: const Text('Tip'), child: _button('First')),
          _button('Second'),
        ],
      ),
      surfaceSize: _surface,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(find.text('Tip'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(find.text('Tip'), findsNothing);

    // A touch press focuses without a focus ring: no tooltip.
    await tester.tap(find.text('First'));
    await _settle(tester);
    expect(find.text('Tip'), findsNothing);
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('pressing the trigger and Escape close the tooltip', (
    WidgetTester tester,
  ) async {
    int pressed = 0;
    await pumpHero(
      tester,
      HeroTooltip(
        delay: Duration.zero,
        content: const Text('Tip'),
        child: _button('Save', onPressed: () => pressed++),
      ),
      surfaceSize: _surface,
    );
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Save')));
    await _settle(tester);
    expect(find.text('Tip'), findsOneWidget);
    await mouse.down(tester.getCenter(find.text('Save')));
    await mouse.up();
    await _settle(tester);
    expect(pressed, 1);
    expect(find.text('Tip'), findsNothing);
    // Still hovered, but it stays closed until the pointer comes back.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Tip'), findsNothing);

    await mouse.moveTo(Offset.zero);
    await tester.pump();
    await mouse.moveTo(tester.getCenter(find.text('Save')));
    await _settle(tester);
    expect(find.text('Tip'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(find.text('Tip'), findsNothing);
    await mouse.moveTo(Offset.zero);
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('trigger: focus ignores hover', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroTooltip(
        delay: Duration.zero,
        trigger: HeroTooltipTriggerMode.focus,
        content: const Text('Tip'),
        child: _button('Field'),
      ),
      surfaceSize: _surface,
    );
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Field')));
    await tester.pump(const Duration(seconds: 2));
    await _settle(tester);
    expect(find.text('Tip'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(find.text('Tip'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('a long press on touch opens it without pressing the '
      'trigger; the next tap outside closes it', (WidgetTester tester) async {
    int pressed = 0;
    await pumpHero(
      tester,
      HeroTooltip(
        content: const Text('Tip'),
        child: _button('Save', onPressed: () => pressed++),
      ),
      surfaceSize: _surface,
    );
    await tester.longPress(find.text('Save'));
    await _settle(tester);
    expect(find.text('Tip'), findsOneWidget);
    expect(pressed, 0);
    // Stays after the finger lifts.
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Tip'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await _settle(tester);
    expect(find.text('Tip'), findsNothing);
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('isDisabled never opens', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroTooltip(
        isDisabled: true,
        delay: Duration.zero,
        content: const Text('Tip'),
        child: _button('Save'),
      ),
      surfaceSize: _surface,
    );
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('Save')));
    await _settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    await tester.longPress(find.text('Save'));
    await _settle(tester);
    expect(find.text('Tip'), findsNothing);
  });

  testWidgets('controlled and default open', (WidgetTester tester) async {
    final List<bool> changes = <bool>[];
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroTooltip(
            isOpen: true,
            onOpenChanged: changes.add,
            content: const Text('Controlled'),
            child: _button('A'),
          ),
          const SizedBox(height: 80),
          HeroTooltip(
            defaultOpen: true,
            content: const Text('Initially open'),
            child: _button('B'),
          ),
        ],
      ),
      surfaceSize: _surface,
    );
    expect(find.text('Controlled'), findsOneWidget);
    expect(find.text('Initially open'), findsOneWidget);

    // Escape asks the controlled tooltip to close; it stays open.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(changes, contains(false));
    expect(find.text('Controlled'), findsOneWidget);
    expect(find.text('Initially open'), findsNothing);
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('placements, offsets and flipping', (WidgetTester tester) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroTooltip(
            isOpen: true,
            content: const Text('Above'),
            child: _button('Top'),
          ),
          const SizedBox(height: 60),
          HeroTooltip(
            isOpen: true,
            content: const HeroTooltipContent(
              placement: HeroPlacement.bottom,
              showArrow: true,
              child: Text('Below'),
            ),
            child: _button('Bottom'),
          ),
          const SizedBox(height: 60),
          HeroTooltip(
            isOpen: true,
            content: const HeroTooltipContent(
              placement: HeroPlacement.end,
              offset: 12,
              child: Text('After'),
            ),
            child: _button('End'),
          ),
        ],
      ),
      surfaceSize: _surface,
    );
    final Rect top = tester.getRect(find.byType(HeroButton).at(0));
    final Rect above = _bubble(tester, 'Above');
    expect(above.bottom, moreOrLessEquals(top.top - 3));
    expect(above.center.dx, moreOrLessEquals(top.center.dx));

    final Rect bottom = tester.getRect(find.byType(HeroButton).at(1));
    final Rect below = _bubble(tester, 'Below');
    expect(below.top, moreOrLessEquals(bottom.bottom + 7));
    // The arrow sits in the gap, pointing up at the trigger.
    final Rect arrow = tester.getRect(find.byType(HeroOverlayArrow));
    expect(arrow.size, const Size(12, 12));
    expect(arrow.bottom, moreOrLessEquals(below.top));
    expect(arrow.center.dx, moreOrLessEquals(bottom.center.dx));
    expect(
      tester.widget<HeroOverlayArrow>(find.byType(HeroOverlayArrow)).side,
      HeroOverlaySide.bottom,
    );

    final Rect end = tester.getRect(find.byType(HeroButton).at(2));
    final Rect after = _bubble(tester, 'After');
    expect(after.left, moreOrLessEquals(end.right + 12));
  });

  testWidgets('start and end follow the reading direction; no room flips', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Align(
        alignment: Alignment.topCenter,
        child: HeroTooltip(
          isOpen: true,
          content: const HeroTooltipContent(
            placement: HeroPlacement.start,
            child: Text('Start'),
          ),
          child: HeroTooltip(
            isOpen: true,
            content: const Text('Flipped'),
            child: _button('Trigger'),
          ),
        ),
      ),
      textDirection: TextDirection.rtl,
      surfaceSize: _surface,
    );
    final Rect trigger = tester.getRect(find.byType(HeroButton));
    expect(_bubble(tester, 'Start').left, moreOrLessEquals(trigger.right + 3));
    // `top` does not fit above a trigger at the top edge.
    expect(
      _bubble(tester, 'Flipped').top,
      moreOrLessEquals(trigger.bottom + 3),
    );
  });

  testWidgets('bubble style: overlay fill, 12 px text, 8 px padding, 320 px '
      'max width', (WidgetTester tester) async {
    final HeroThemeData theme = HeroThemeData.light();
    const String long =
        'A long tooltip text that wraps onto more than one line because the '
        'tooltip is at most 320 logical pixels wide.';
    await pumpHero(
      tester,
      HeroTooltip(
        isOpen: true,
        placement: HeroPlacement.bottom,
        content: const Text(long),
        child: _button('Trigger'),
      ),
      theme: theme,
      surfaceSize: _surface,
    );
    final Rect bubble = _bubble(tester, long);
    expect(bubble.width, lessThanOrEqualTo(320));
    expect(bubble.width, greaterThan(300));
    final Rect text = tester.getRect(find.text(long));
    expect(text.left - bubble.left, 8);
    expect(text.top - bubble.top, 8);
    final DefaultTextStyle style = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text(long),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(style.style.fontSize, 12);
    expect(style.style.color, theme.colors.overlayForeground);
    expect(
      tester.widget<HeroOverlaySurface>(find.byType(HeroOverlaySurface)).color,
      theme.colors.overlay,
    );
  });

  testWidgets('custom styles, custom arrow and builder', (
    WidgetTester tester,
  ) async {
    final HeroThemeData theme = HeroThemeData.light();
    final List<HeroOverlaySide> placements = <HeroOverlaySide>[];
    await pumpHero(
      tester,
      HeroTooltip(
        isOpen: true,
        content: HeroTooltipContent(
          placement: HeroPlacement.left,
          showArrow: true,
          arrow: const HeroTooltipArrow(child: SizedBox(key: Key('arrow'))),
          backgroundColor: theme.colors.surface,
          side: BorderSide(color: theme.colors.border),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          builder: (BuildContext context, HeroTooltipRenderState state, tip) {
            placements.add(state.placement);
            return KeyedSubtree(key: const Key('custom'), child: tip);
          },
          child: const Text('Copied'),
        ),
        child: _button('Share'),
      ),
      theme: theme,
      surfaceSize: _surface,
    );
    expect(find.byKey(const Key('custom')), findsOneWidget);
    expect(find.byKey(const Key('arrow')), findsOneWidget);
    expect(placements.last, HeroOverlaySide.left);
    final HeroOverlaySurface surface = tester.widget(
      find.byType(HeroOverlaySurface),
    );
    expect(surface.color, theme.colors.surface);
    expect(surface.side.color, theme.colors.border);
    final Rect bubble = _bubble(tester, 'Copied');
    expect(tester.getRect(find.text('Copied')).left - bubble.left, 10);
    // The arrow is rotated to point right, at the trigger.
    expect(
      tester.widget<HeroOverlayArrow>(find.byType(HeroOverlayArrow)).side,
      HeroOverlaySide.left,
    );
    expect(tester.getRect(find.byKey(const Key('arrow'))).left, bubble.right);
  });

  testWidgets('HeroTooltipTrigger makes content focusable with a focus ring', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroTooltip(
        content: Text('Jane Doe'),
        child: HeroTooltipTrigger(
          semanticsLabel: 'User avatar',
          child: HeroAvatar(name: 'Jane Doe'),
        ),
      ),
      surfaceSize: _surface,
    );
    expect(
      tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
      isFalse,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await _settle(tester);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(
      tester.widget<HeroFocusRing>(find.byType(HeroFocusRing).first).visible,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('semantics: the trigger carries the tooltip text', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      HeroTooltip(
        content: const Text('More information'),
        child: HeroButton(
          onPressed: () {},
          isIconOnly: true,
          semanticLabel: 'Info',
          child: const HeroIcon(HeroIcons.circleInfo),
        ),
      ),
      surfaceSize: _surface,
    );
    expect(
      tester.getSemantics(find.byType(HeroButton)),
      matchesSemantics(
        label: 'Info',
        tooltip: 'More information',
        isButton: true,
        isFocusable: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('shouldSkipAnimation swaps warm tooltips without a '
      'transition', (WidgetTester tester) async {
    await pumpHero(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroTooltip(
            delay: Duration.zero,
            shouldSkipAnimation: true,
            content: const Text('First tip'),
            child: _button('One'),
          ),
          const SizedBox(width: 40),
          HeroTooltip(
            delay: Duration.zero,
            shouldSkipAnimation: true,
            content: const Text('Second tip'),
            child: _button('Two'),
          ),
        ],
      ),
      surfaceSize: _surface,
    );
    final TestGesture mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('One')));
    await tester.pump();
    await tester.pump();
    // The first one (not warm yet) fades in.
    double opacity(String text) => tester
        .widget<Opacity>(
          find.ancestor(of: find.text(text), matching: find.byType(Opacity)),
        )
        .opacity;
    expect(opacity('First tip'), lessThan(1));
    await tester.pump(const Duration(milliseconds: 200));
    await mouse.moveTo(tester.getCenter(find.text('Two')));
    await tester.pump();
    await tester.pump();
    expect(opacity('Second tip'), 1);
    expect(find.text('First tip'), findsNothing);
    await mouse.moveTo(Offset.zero);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(HeroTooltip.warmUpCooldown);
  });

  testWidgets('text scale 2 does not overflow', (WidgetTester tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpHero(
      tester,
      HeroTooltip(
        isOpen: true,
        content: const HeroTooltipContent(
          showArrow: true,
          placement: HeroPlacement.bottom,
          child: Text('Tooltip with arrow indicator'),
        ),
        child: _button('With Arrow'),
      ),
      textScale: 2,
      surfaceSize: _surface,
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Tooltip with arrow indicator'), findsOneWidget);
  });

  testWidgets('scrolls instead of overflowing when the space is short', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroTooltip(
        isOpen: true,
        content: const Text(
          'A long tooltip that needs more lines than fit above the trigger '
          'on this very short screen, so it has to scroll.',
        ),
        child: _button('Trigger'),
      ),
      surfaceSize: const Size(240, 120),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });
}
