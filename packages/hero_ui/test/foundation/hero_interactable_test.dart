import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../helpers/hero_test_app.dart';

void main() {
  Widget target({
    VoidCallback? onPressed,
    bool isDisabled = false,
    bool isPending = false,
    ValueChanged<HeroInteractionState>? onState,
    FocusNode? focusNode,
  }) {
    return HeroInteractable(
      onPressed: onPressed,
      isDisabled: isDisabled,
      isPending: isPending,
      focusNode: focusNode,
      semanticsLabel: 'Target',
      builder: (BuildContext context, HeroInteractionState state, _) {
        onState?.call(state);
        return const SizedBox(width: 100, height: 40);
      },
    );
  }

  testWidgets('tap calls onPressed and shows the pressed state', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    HeroInteractionState? last;
    await pumpHero(
      tester,
      target(
        onPressed: () => presses++,
        onState: (HeroInteractionState s) => last = s,
      ),
    );
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(HeroInteractable)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(last!.isPressed, isTrue);
    await gesture.up();
    await tester.pump();
    expect(presses, 1);
    await tester.pump(const Duration(milliseconds: 200));
    expect(last!.isPressed, isFalse);
  });

  testWidgets('quick taps keep the pressed state for a minimum duration', (
    WidgetTester tester,
  ) async {
    HeroInteractionState? last;
    await pumpHero(
      tester,
      target(onPressed: () {}, onState: (HeroInteractionState s) => last = s),
    );
    await tester.tap(find.byType(HeroInteractable));
    await tester.pump();
    expect(last!.isPressed, isTrue);
    await tester.pump(const Duration(milliseconds: 120));
    expect(last!.isPressed, isFalse);
  });

  testWidgets('disabled ignores taps and keyboard', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      target(onPressed: () => presses++, isDisabled: true),
    );
    await tester.tap(find.byType(HeroInteractable));
    await tester.pump(const Duration(milliseconds: 200));
    expect(presses, 0);
  });

  testWidgets('pending ignores taps', (WidgetTester tester) async {
    int presses = 0;
    await pumpHero(tester, target(onPressed: () => presses++, isPending: true));
    await tester.tap(find.byType(HeroInteractable));
    await tester.pump(const Duration(milliseconds: 200));
    expect(presses, 0);
  });

  testWidgets('Enter and Space activate when focused and show focus-visible', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    HeroInteractionState? last;
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpHero(
      tester,
      target(
        onPressed: () => presses++,
        focusNode: node,
        onState: (HeroInteractionState s) => last = s,
      ),
    );
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    node.requestFocus();
    await tester.pump();
    await tester.pump();
    expect(last!.isFocused, isTrue);
    expect(last!.isFocusVisible, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump(const Duration(milliseconds: 200));
    expect(presses, 2);
  });

  testWidgets('touch focus does not show the focus ring', (
    WidgetTester tester,
  ) async {
    HeroInteractionState? last;
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpHero(
      tester,
      target(
        onPressed: () {},
        focusNode: node,
        onState: (HeroInteractionState s) => last = s,
      ),
    );
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTouch;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    node.requestFocus();
    await tester.pump();
    await tester.pump();
    expect(last!.isFocused, isTrue);
    expect(last!.isFocusVisible, isFalse);
  });

  testWidgets('exposes button semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, target(onPressed: () {}));
    expect(
      tester.getSemantics(find.byType(HeroInteractable)),
      matchesSemantics(
        label: 'Target',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('hover is reported for mouse pointers', (
    WidgetTester tester,
  ) async {
    HeroInteractionState? last;
    await pumpHero(
      tester,
      target(onPressed: () {}, onState: (HeroInteractionState s) => last = s),
    );
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(HeroInteractable)));
    await tester.pump();
    await tester.pump();
    expect(last!.isHovered, isTrue);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    await tester.pump();
    expect(last!.isHovered, isFalse);
  });

  testWidgets('pending stays focusable, disabled does not, both unavailable', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, target(onPressed: () {}, isPending: true));
    expect(
      tester.getSemantics(find.byType(HeroInteractable)),
      matchesSemantics(
        label: 'Target',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        isFocusable: true,
      ),
    );
    await pumpHero(tester, target(onPressed: () {}, isDisabled: true));
    expect(
      tester.getSemantics(find.byType(HeroInteractable)),
      matchesSemantics(label: 'Target', isButton: true, hasEnabledState: true),
    );
    handle.dispose();
  });

  testWidgets('disabled opacity keeps the subtree when toggled', (
    WidgetTester tester,
  ) async {
    _InitCounter.inits = 0;
    Widget build(bool disabled) =>
        HeroDisabledOpacity(disabled: disabled, child: const _InitCounter());
    await pumpHero(tester, build(false));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    await pumpHero(tester, build(true));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.5);
    await pumpHero(tester, build(false));
    expect(_InitCounter.inits, 1);
  });

  testWidgets('focus ring paints outside the child', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroFocusRing(
        visible: true,
        shape: HeroThemeData.light().shapeAll(12),
        child: const SizedBox(width: 80, height: 40),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.getSize(find.byType(HeroFocusRing)), const Size(80, 40));
  });
}

class _InitCounter extends StatefulWidget {
  const _InitCounter();

  static int inits = 0;

  @override
  State<_InitCounter> createState() => _InitCounterState();
}

class _InitCounterState extends State<_InitCounter> {
  @override
  void initState() {
    super.initState();
    _InitCounter.inits++;
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 10);
}
