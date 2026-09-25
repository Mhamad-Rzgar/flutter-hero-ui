import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroThemeData _light = HeroThemeData.light();

Finder get _button => find.byType(HeroCloseButton);

Color? _fill(WidgetTester tester) {
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(of: _button, matching: find.byType(DecoratedBox)).first,
  );
  return (box.decoration as ShapeDecoration).color;
}

Color? _iconColor(WidgetTester tester) {
  final BuildContext context = tester.element(
    find.descendant(of: _button, matching: find.byType(HeroIcon)),
  );
  return IconTheme.of(context).color;
}

double _scale(WidgetTester tester) => tester
    .widget<AnimatedScale>(
      find.descendant(of: _button, matching: find.byType(AnimatedScale)),
    )
    .scale;

void main() {
  testWidgets('renders a 24 px round button with the close icon', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, HeroCloseButton(onPressed: () {}));
    expect(tester.getSize(_button), const Size.square(24));
    final HeroIcon icon = tester.widget(find.byType(HeroIcon));
    expect(icon.icon, HeroIcons.close);
    expect(tester.getSize(find.byType(HeroIcon)), const Size.square(16));
    expect(tester.getCenter(find.byType(HeroIcon)), tester.getCenter(_button));
    expect(_fill(tester), _light.colors.defaultColor);
    expect(_iconColor(tester), _light.colors.muted);
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find.descendant(of: _button, matching: find.byType(DecoratedBox)).first,
    );
    final RoundedSuperellipseBorder shape =
        (box.decoration as ShapeDecoration).shape as RoundedSuperellipseBorder;
    expect(shape.borderRadius, BorderRadius.circular(12));
  });

  testWidgets('tap calls onPressed and scales to 0.93', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(tester, HeroCloseButton(onPressed: () => presses++));
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(_button),
    );
    await tester.pump();
    expect(_scale(tester), 0.93);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(presses, 1);
    expect(_scale(tester), 1);
  });

  testWidgets('hover shows the hover fill', (WidgetTester tester) async {
    await pumpHero(tester, HeroCloseButton(onPressed: () {}));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(_button));
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    expect(_fill(tester), _light.colors.defaultHover);
    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();
    expect(_fill(tester), _light.colors.defaultColor);
  });

  testWidgets('Enter activates and keyboard focus shows the ring', (
    WidgetTester tester,
  ) async {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    int presses = 0;
    await pumpHero(tester, HeroCloseButton(onPressed: () => presses++));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(presses, 2);
    expect(
      tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
      isTrue,
    );
  });

  testWidgets('disabled buttons are dimmed and ignore presses', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      HeroCloseButton(isDisabled: true, onPressed: () => presses++),
    );
    await tester.tap(_button, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(presses, 0);
    expect(
      tester
          .widget<Opacity>(
            find.descendant(of: _button, matching: find.byType(Opacity)),
          )
          .opacity,
      0.5,
    );
  });

  testWidgets('pending buttons ignore presses without dimming', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      HeroCloseButton(isPending: true, onPressed: () => presses++),
    );
    await tester.tap(_button);
    await tester.pumpAndSettle();
    expect(presses, 0);
    expect(
      tester
          .widget<Opacity>(
            find.descendant(of: _button, matching: find.byType(Opacity)),
          )
          .opacity,
      1,
    );
  });

  testWidgets('custom icons and builders replace the close icon', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroCloseButton(
        onPressed: () {},
        child: const HeroIcon(HeroIcons.circleXmark),
      ),
    );
    expect(
      tester.widget<HeroIcon>(find.byType(HeroIcon)).icon,
      HeroIcons.circleXmark,
    );
    expect(_iconColor(tester), _light.colors.muted);

    await pumpHero(
      tester,
      HeroCloseButton(
        onPressed: () {},
        builder: (BuildContext context, HeroButtonState state) => HeroIcon(
          state.isPressed ? HeroIcons.circleXmarkFill : HeroIcons.xmark,
        ),
      ),
    );
    expect(
      tester.widget<HeroIcon>(find.byType(HeroIcon)).icon,
      HeroIcons.xmark,
    );
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(_button),
    );
    await tester.pump();
    expect(
      tester.widget<HeroIcon>(find.byType(HeroIcon)).icon,
      HeroIcons.circleXmarkFill,
    );
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('style overrides size, shape, hover color and scale', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroCloseButton(
        onPressed: () {},
        style: HeroButtonStyle(
          height: 32,
          borderRadius: BorderRadius.circular(9999),
          foregroundColor: WidgetStateProperty.resolveWith(
            (Set<WidgetState> states) => states.contains(WidgetState.hovered)
                ? _light.colors.foreground
                : null,
          ),
          pressedScale: 0.95,
        ),
      ),
    );
    expect(tester.getSize(_button), const Size.square(32));
    expect(_iconColor(tester), _light.colors.muted);
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(_button));
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    expect(_iconColor(tester), _light.colors.foreground);
    await mouse.down(tester.getCenter(_button));
    await tester.pump();
    expect(_scale(tester), 0.95);
    await mouse.up();
    await tester.pumpAndSettle();
  });

  testWidgets('the icon color transitions over 150 ms', (
    WidgetTester tester,
  ) async {
    Widget build(Color color) => HeroCloseButton(
      onPressed: () {},
      style: HeroButtonStyle(
        foregroundColor: WidgetStatePropertyAll<Color>(color),
      ),
    );
    await pumpHero(tester, build(_light.colors.muted));
    await tester.pumpWidget(heroTestApp(build(_light.colors.danger)));
    await tester.pump(const Duration(milliseconds: 60));
    expect(_iconColor(tester), isNot(_light.colors.danger));
    await tester.pump(const Duration(milliseconds: 120));
    expect(_iconColor(tester), _light.colors.danger);
  });

  testWidgets('is announced as a "Close" button', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, HeroCloseButton(onPressed: () {}));
    expect(
      tester.getSemantics(_button),
      matchesSemantics(
        label: 'Close',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    await pumpHero(
      tester,
      HeroCloseButton(
        semanticLabel: 'Close (clicked 2 times)',
        onPressed: () {},
      ),
    );
    expect(
      tester.getSemantics(_button),
      matchesSemantics(
        label: 'Close (clicked 2 times)',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('keeps its size in right-to-left and at 2x text', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroCloseButton(onPressed: () {}),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(_button), const Size.square(24));
  });
}
