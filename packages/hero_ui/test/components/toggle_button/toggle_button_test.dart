import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData light = HeroThemeData.light();

  ShapeDecoration decorationOf(WidgetTester tester, [Finder? button]) {
    final AnimatedContainer container = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: button ?? find.byType(HeroToggleButton),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    return container.decoration! as ShapeDecoration;
  }

  Size sizeOf(WidgetTester tester, [Finder? button]) => tester.getSize(
    find
        .descendant(
          of: button ?? find.byType(HeroToggleButton),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  );

  void useKeyboardHighlight() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
  }

  testWidgets('renders the label and the start icon', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroToggleButton(
        startContent: HeroIcon(HeroIcons.heart),
        child: Text('Like'),
      ),
    );
    expect(find.text('Like'), findsOneWidget);
    expect(find.byType(HeroIcon), findsOneWidget);
    expect(decorationOf(tester).color, light.colors.defaultColor);
    final Text text = tester.widget<Text>(find.text('Like'));
    expect(text.data, 'Like');
    final DefaultTextStyle style = DefaultTextStyle.of(
      tester.element(find.text('Like')),
    );
    expect(style.style.fontSize, 14);
    expect(style.style.fontWeight, FontWeight.w500);
    expect(style.style.color, light.colors.foreground);
  });

  testWidgets('uncontrolled button toggles on tap and reports changes', (
    WidgetTester tester,
  ) async {
    final List<bool> changes = <bool>[];
    int presses = 0;
    await pumpHero(
      tester,
      HeroToggleButton(
        onChanged: changes.add,
        onPressed: () => presses++,
        child: const Text('Like'),
      ),
    );
    await tester.tap(find.byType(HeroToggleButton));
    await tester.pumpAndSettle();
    expect(changes, <bool>[true]);
    expect(presses, 1);
    expect(decorationOf(tester).color, light.colors.accentSoft);
    final DefaultTextStyle style = DefaultTextStyle.of(
      tester.element(find.text('Like')),
    );
    expect(style.style.color, light.colors.accentSoftForeground);

    await tester.tap(find.byType(HeroToggleButton));
    await tester.pumpAndSettle();
    expect(changes, <bool>[true, false]);
    expect(decorationOf(tester).color, light.colors.defaultColor);
  });

  testWidgets('defaultSelected starts selected', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroToggleButton(defaultSelected: true, child: Text('Like')),
    );
    expect(decorationOf(tester).color, light.colors.accentSoft);
  });

  testWidgets('controlled button follows isSelected', (
    WidgetTester tester,
  ) async {
    final List<bool> changes = <bool>[];
    await pumpHero(
      tester,
      HeroToggleButton(
        isSelected: false,
        onChanged: changes.add,
        child: const Text('Like'),
      ),
    );
    await tester.tap(find.byType(HeroToggleButton));
    await tester.pumpAndSettle();
    expect(changes, <bool>[true]);
    // The parent did not update isSelected, so the button stays off.
    expect(decorationOf(tester).color, light.colors.defaultColor);

    bool selected = false;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) =>
            HeroToggleButton(
              isSelected: selected,
              onChanged: (bool value) => setState(() => selected = value),
              builder: (BuildContext context, HeroToggleButtonState state) =>
                  Text(state.isSelected ? 'Liked' : 'Like'),
            ),
      ),
    );
    expect(find.text('Like'), findsOneWidget);
    await tester.tap(find.byType(HeroToggleButton));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
    expect(find.text('Liked'), findsOneWidget);
  });

  testWidgets('ghost variant is transparent until hovered', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroToggleButton(
        variant: HeroToggleButtonVariant.ghost,
        child: Text('Ghost'),
      ),
    );
    expect(decorationOf(tester).color!.a, 0);
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(HeroToggleButton)));
    await tester.pumpAndSettle();
    expect(decorationOf(tester).color, light.colors.defaultColor);
    final DefaultTextStyle style = DefaultTextStyle.of(
      tester.element(find.text('Ghost')),
    );
    expect(style.style.color, light.colors.defaultForeground);
  });

  testWidgets('hover and press use the hover fills', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const HeroToggleButton(child: Text('Like')));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(HeroToggleButton)));
    await tester.pumpAndSettle();
    expect(decorationOf(tester).color, light.colors.defaultHover);

    final TestGesture press = await tester.startGesture(
      tester.getCenter(find.byType(HeroToggleButton)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final AnimatedScale scale = tester.widget<AnimatedScale>(
      find.byType(AnimatedScale),
    );
    expect(scale.scale, 0.97);
    await press.up();
    await tester.pumpAndSettle();
    expect(decorationOf(tester).color, light.colors.accentSoftHover);
  });

  testWidgets('Enter and Space toggle and show the focus ring', (
    WidgetTester tester,
  ) async {
    final List<bool> changes = <bool>[];
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpHero(
      tester,
      HeroToggleButton(
        focusNode: node,
        onChanged: changes.add,
        child: const Text('Like'),
      ),
    );
    useKeyboardHighlight();
    node.requestFocus();
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (Widget w) =>
            w is CustomPaint && w.foregroundPainter is HeroFocusRingPainter,
      ),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(changes, <bool>[true, false]);
  });

  testWidgets('exposes toggle button semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const HeroToggleButton(
        isIconOnly: true,
        semanticLabel: 'Like',
        defaultSelected: true,
        child: HeroIcon(HeroIcons.heart),
      ),
    );
    expect(
      tester.getSemantics(find.byType(HeroToggleButton)),
      matchesSemantics(
        label: 'Like',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('disabled buttons ignore input and fade', (
    WidgetTester tester,
  ) async {
    final List<bool> changes = <bool>[];
    await pumpHero(
      tester,
      HeroToggleButton(
        isDisabled: true,
        onChanged: changes.add,
        child: const Text('Like'),
      ),
    );
    await tester.tap(find.byType(HeroToggleButton));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    final Opacity opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(HeroToggleButton),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, light.disabledOpacity);
    final FocusNode node = Focus.of(tester.element(find.text('Like')));
    expect(node.canRequestFocus, isFalse);
  });

  testWidgets('sizes follow HeroUI below and above the md breakpoint', (
    WidgetTester tester,
  ) async {
    Future<void> check(Size surface, Map<HeroSize, double> heights) async {
      for (final MapEntry<HeroSize, double> entry in heights.entries) {
        await pumpHero(
          tester,
          HeroToggleButton(
            size: entry.key,
            isIconOnly: true,
            semanticLabel: 'Like',
            child: const HeroIcon(HeroIcons.heart),
          ),
          surfaceSize: surface,
        );
        expect(sizeOf(tester), Size.square(entry.value));
      }
    }

    await check(const Size(400, 600), <HeroSize, double>{
      HeroSize.sm: 36,
      HeroSize.md: 40,
      HeroSize.lg: 44,
    });
    await check(const Size(1024, 600), <HeroSize, double>{
      HeroSize.sm: 32,
      HeroSize.md: 36,
      HeroSize.lg: 40,
    });
  });

  testWidgets('icons are 20 on narrow screens and 16 from sm up', (
    WidgetTester tester,
  ) async {
    const Widget button = HeroToggleButton(
      startContent: HeroIcon(HeroIcons.heart),
      child: Text('Like'),
    );
    await pumpHero(tester, button, surfaceSize: const Size(400, 600));
    expect(tester.getSize(find.byType(HeroIcon)), const Size.square(20));
    await pumpHero(tester, button, surfaceSize: const Size(700, 600));
    expect(tester.getSize(find.byType(HeroIcon)), const Size.square(16));
    await pumpHero(
      tester,
      const HeroToggleButton(
        size: HeroSize.sm,
        startContent: HeroIcon(HeroIcons.heart),
        child: Text('Like'),
      ),
      surfaceSize: const Size(400, 600),
    );
    expect(tester.getSize(find.byType(HeroIcon)), const Size.square(16));
  });

  testWidgets('padding and icon bleed match the CSS', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroToggleButton(
        startContent: HeroIcon(HeroIcons.heart),
        child: Text('Like'),
      ),
      surfaceSize: const Size(400, 600),
    );
    final Rect button = tester.getRect(
      find.descendant(
        of: find.byType(HeroToggleButton),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final Rect icon = tester.getRect(find.byType(HeroIcon));
    final Rect label = tester.getRect(find.text('Like'));
    // px-4 with a -mx-0.5 icon: the icon starts 14 from the edge and the
    // label 6 after the icon.
    expect(icon.left - button.left, 14);
    expect(label.left - icon.right, 6);
    expect(button.right - label.right, 16);
  });

  testWidgets('lays out right to left', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroToggleButton(
        startContent: HeroIcon(HeroIcons.heart),
        child: Text('Like'),
      ),
      textDirection: TextDirection.rtl,
    );
    expect(
      tester.getCenter(find.byType(HeroIcon)).dx,
      greaterThan(tester.getCenter(find.text('Like')).dx),
    );
  });

  testWidgets('text scale 2.0 grows the button without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroToggleButton(
        size: HeroSize.lg,
        startContent: HeroIcon(HeroIcons.heart),
        child: Text('Like'),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(sizeOf(tester).height, greaterThanOrEqualTo(48));
  });

  testWidgets('style overrides colors, border and radius', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroToggleButton(
        defaultSelected: true,
        style: HeroToggleButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? light.colors.accentSoft
                : light.colors.surface,
          ),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: light.colors.border),
          ),
          iconColor: WidgetStatePropertyAll<Color>(light.colors.accent),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        startContent: const HeroIcon(HeroIcons.heart),
        child: const Text('Save'),
      ),
    );
    final ShapeDecoration decoration = decorationOf(tester);
    expect(decoration.color, light.colors.accentSoft);
    final OutlinedBorder shape = decoration.shape as OutlinedBorder;
    expect(shape.side.color, light.colors.border);
    expect(
      IconTheme.of(tester.element(find.byType(HeroIcon))).color,
      light.colors.accent,
    );
  });

  testWidgets('skips transitions under reduced motion', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroToggleButton(child: Text('Like')),
      theme: light.copyWith(motion: const HeroMotion(reduceMotion: true)),
    );
    final AnimatedContainer container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(container.duration, Duration.zero);
  });

  testWidgets('does not register render overflow in a narrow box', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 90,
        child: HeroToggleButton(
          startContent: HeroIcon(HeroIcons.heart),
          child: Text('A very long label'),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.text('A very long label'),
    );
    expect(paragraph.didExceedMaxLines, isTrue);
  });
}
