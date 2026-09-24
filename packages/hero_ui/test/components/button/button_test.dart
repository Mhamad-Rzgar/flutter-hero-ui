import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// Touch density (HeroUI below `md`), independent of the test surface.
final HeroThemeData _light = HeroThemeData.light().copyWith(
  density: HeroDensity.touch,
);

/// Reduced motion: no transitions and still spinners, so `pumpAndSettle`
/// completes with pending buttons.
final HeroThemeData _still = _light.copyWith(
  motion: const HeroMotion(reduceMotion: true),
);

Finder _button([Finder? of]) => of ?? find.byType(HeroButton);

Color? _fill(WidgetTester tester, [Finder? of]) {
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(of: _button(of), matching: find.byType(DecoratedBox)).first,
  );
  return (box.decoration as ShapeDecoration).color;
}

ShapeBorder _shape(WidgetTester tester) {
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(of: _button(), matching: find.byType(DecoratedBox)).first,
  );
  return (box.decoration as ShapeDecoration).shape;
}

double _scale(WidgetTester tester) => tester
    .widget<AnimatedScale>(
      find.descendant(of: _button(), matching: find.byType(AnimatedScale)),
    )
    .scale;

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(of: _button(), matching: find.byType(Opacity)),
    )
    .opacity;

Color? _textColor(WidgetTester tester, String text) {
  final RichText rich = tester.widget<RichText>(
    find.descendant(of: find.text(text), matching: find.byType(RichText)),
  );
  return rich.text.style?.color;
}

/// [pumpHero] with the touch-density theme by default.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  HeroThemeData? theme,
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
  Size? surfaceSize,
}) => pumpHero(
  tester,
  child,
  theme: theme ?? _light,
  textDirection: textDirection,
  textScale: textScale,
  surfaceSize: surfaceSize,
);

Future<void> _useKeyboard(WidgetTester tester) async {
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic,
  );
}

void main() {
  group('rendering', () {
    testWidgets('renders the label as a primary medium button', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButton(onPressed: () {}, child: const Text('Click me')),
      );
      expect(find.text('Click me'), findsOneWidget);
      expect(tester.getSize(_button()).height, 40);
      expect(_fill(tester), _light.colors.accent);
      expect(_textColor(tester, 'Click me'), _light.colors.accentForeground);
      final RichText text = tester.widget<RichText>(
        find.descendant(
          of: find.text('Click me'),
          matching: find.byType(RichText),
        ),
      );
      expect(text.text.style?.fontSize, 14);
      expect(text.text.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('resolves every variant from button.css', (
      WidgetTester tester,
    ) async {
      final HeroColors c = _light.colors;
      final Map<HeroButtonVariant, (Color, Color)>
      expected = <HeroButtonVariant, (Color, Color)>{
        HeroButtonVariant.primary: (c.accent, c.accentForeground),
        HeroButtonVariant.secondary: (c.defaultColor, c.accentSoftForeground),
        HeroButtonVariant.tertiary: (c.defaultColor, c.foreground),
        HeroButtonVariant.outline: (
          const Color(0x00000000),
          c.defaultForeground,
        ),
        HeroButtonVariant.ghost: (const Color(0x00000000), c.defaultForeground),
        HeroButtonVariant.danger: (c.danger, c.dangerForeground),
        HeroButtonVariant.dangerSoft: (c.dangerSoft, c.dangerSoftForeground),
      };
      for (final MapEntry<HeroButtonVariant, (Color, Color)> e
          in expected.entries) {
        await _pump(
          tester,
          HeroButton(variant: e.key, onPressed: () {}, child: Text(e.key.name)),
        );
        expect(_fill(tester), e.value.$1, reason: e.key.name);
        expect(_textColor(tester, e.key.name), e.value.$2, reason: e.key.name);
      }
    });

    testWidgets('variant styles match the hover and pressed fills', (
      WidgetTester tester,
    ) async {
      final HeroColors c = _light.colors;
      final HeroVariantStyle outline = HeroButtonVariant.outline.resolve(
        c,
        currentColor: c.foreground,
      );
      expect(outline.backgroundHover.a, closeTo(c.defaultColor.a * 0.6, 0.01));
      expect(outline.backgroundPressed, c.defaultColor);
      expect(outline.borderColor, c.border);
      final HeroVariantStyle ghost = HeroButtonVariant.ghost.resolve(
        c,
        currentColor: c.foreground,
      );
      expect(ghost.backgroundHover, c.defaultColor);
      expect(ghost.backgroundPressed, c.defaultColor);
      final HeroVariantStyle danger = HeroButtonVariant.danger.resolve(
        c,
        currentColor: c.foreground,
      );
      expect(danger.backgroundPressed, c.dangerHover);
      final HeroVariantStyle soft = HeroButtonVariant.dangerSoft.resolve(
        c,
        currentColor: c.foreground,
      );
      expect(soft.backgroundHover, c.dangerSoftHover);
    });

    testWidgets('tertiary inherits the surrounding text color', (
      WidgetTester tester,
    ) async {
      final Color inherited = _light.colors.danger;
      await _pump(
        tester,
        DefaultTextStyle.merge(
          style: TextStyle(color: inherited),
          child: HeroButton(
            variant: HeroButtonVariant.tertiary,
            onPressed: () {},
            child: const Text('Tertiary'),
          ),
        ),
      );
      expect(_textColor(tester, 'Tertiary'), inherited);
    });

    testWidgets('sizes follow the touch and desktop heights', (
      WidgetTester tester,
    ) async {
      const Map<HeroSize, (double, double)> heights =
          <HeroSize, (double, double)>{
            HeroSize.sm: (36, 32),
            HeroSize.md: (40, 36),
            HeroSize.lg: (44, 40),
          };
      for (final MapEntry<HeroSize, (double, double)> e in heights.entries) {
        await _pump(
          tester,
          HeroButton(size: e.key, onPressed: () {}, child: const Text('A')),
        );
        expect(tester.getSize(_button()).height, e.value.$1);
        await _pump(
          tester,
          HeroButton(size: e.key, onPressed: () {}, child: const Text('A')),
          theme: _light.copyWith(density: HeroDensity.desktop),
        );
        expect(tester.getSize(_button()).height, e.value.$2);
      }
    });

    testWidgets('adaptive density switches at the md breakpoint', (
      WidgetTester tester,
    ) async {
      final HeroThemeData adaptive = HeroThemeData.light();
      await _pump(
        tester,
        HeroButton(onPressed: () {}, child: const Text('A')),
        theme: adaptive,
        surfaceSize: const Size(800, 600),
      );
      expect(tester.getSize(_button()).height, 36);
      await _pump(
        tester,
        HeroButton(onPressed: () {}, child: const Text('A')),
        theme: adaptive,
        surfaceSize: const Size(700, 600),
      );
      expect(tester.getSize(_button()).height, 40);
    });

    testWidgets('pads the label and lays out icons with the css gap', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButton(
          startContent: const HeroIcon(HeroIcons.plus),
          onPressed: () {},
          child: const SizedBox(width: 50, height: 20),
        ),
      );
      final Rect button = tester.getRect(_button());
      final Rect icon = tester.getRect(find.byType(HeroIcon));
      final Rect label = tester.getRect(find.byType(SizedBox).last);
      // 16 padding, 20 icon with a -2 margin, 8 gap, 50 label, 16 padding.
      expect(button.width, 16 + 16 + 8 + 50 + 16);
      expect(icon.size, const Size.square(20));
      expect(icon.left - button.left, 14);
      expect(label.left - icon.right, 6);
      expect(button.right - label.right, 16);
    });

    testWidgets('icons are 16 from the sm breakpoint and in small buttons', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButton(
          startContent: const HeroIcon(HeroIcons.plus),
          onPressed: () {},
          child: const Text('Add'),
        ),
        theme: HeroThemeData.light(),
        surfaceSize: const Size(700, 400),
      );
      expect(tester.getSize(find.byType(HeroIcon)), const Size.square(16));
      await _pump(
        tester,
        HeroButton(
          size: HeroSize.sm,
          startContent: const HeroIcon(HeroIcons.plus),
          onPressed: () {},
          child: const Text('Add'),
        ),
      );
      expect(tester.getSize(find.byType(HeroIcon)), const Size.square(16));
    });

    testWidgets('icon-only buttons are square', (WidgetTester tester) async {
      for (final HeroSize size in HeroSize.values) {
        await _pump(
          tester,
          HeroButton(
            size: size,
            isIconOnly: true,
            semanticLabel: 'Settings',
            onPressed: () {},
            child: const HeroIcon(HeroIcons.gear),
          ),
        );
        final Size s = tester.getSize(_button());
        expect(s.width, s.height);
        final Rect icon = tester.getRect(find.byType(HeroIcon));
        expect(icon.center, tester.getRect(_button()).center);
      }
    });

    testWidgets('fullWidth fills a bounded width and centres the content', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 400,
          child: HeroButton(
            fullWidth: true,
            onPressed: () {},
            child: const Text('Primary Button'),
          ),
        ),
      );
      final Rect button = tester.getRect(_button());
      expect(button.width, 400);
      expect(
        tester.getCenter(find.text('Primary Button')).dx,
        closeTo(button.center.dx, 0.5),
      );
    });

    testWidgets('fullWidth shrink-wraps in an unbounded row', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroButton(
              fullWidth: true,
              onPressed: () {},
              child: const Text('A'),
            ),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(_button()).width, lessThan(100));
    });

    testWidgets('long labels ellipsize in a narrow space', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 120,
          child: HeroButton(
            onPressed: () {},
            child: const Text('A very long button label'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(_button()).width, 120);
    });

    testWidgets('outline buttons draw a border', (WidgetTester tester) async {
      await _pump(
        tester,
        HeroButton(
          variant: HeroButtonVariant.outline,
          onPressed: () {},
          child: const Text('Outline'),
        ),
      );
      final CustomPaint paint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(HeroButtonSurface),
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      expect(paint.foregroundPainter, isNotNull);
      expect(tester.getSize(_button()).height, 40);
    });

    testWidgets('lays out start and end content in right-to-left', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButton(
          startContent: const HeroIcon(HeroIcons.chevronLeft),
          endContent: const HeroIcon(HeroIcons.chevronRight),
          onPressed: () {},
          child: const Text('Label'),
        ),
        textDirection: TextDirection.rtl,
      );
      final Rect label = tester.getRect(find.text('Label'));
      final List<Rect> icons = find
          .byType(HeroIcon)
          .evaluate()
          .map((Element e) => tester.getRect(find.byWidget(e.widget)))
          .toList();
      // Start content sits on the right in right-to-left.
      expect(icons[0].left, greaterThan(label.right));
      expect(icons[1].right, lessThan(label.left));
    });

    testWidgets('grows with 2x text without overflowing', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButton(
          startContent: const HeroIcon(HeroIcons.plus),
          onPressed: () {},
          child: const Text('Add Member'),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(_button()).height, greaterThanOrEqualTo(40));
      expect(
        tester.getSize(_button()).width,
        greaterThan(tester.getSize(find.text('Add Member')).width),
      );
    });
  });

  group('interaction', () {
    testWidgets('tap calls onPressed and the press callbacks', (
      WidgetTester tester,
    ) async {
      final List<String> log = <String>[];
      await _pump(
        tester,
        HeroButton(
          onPressed: () => log.add('press'),
          onPressStart: () => log.add('start'),
          onPressEnd: () => log.add('end'),
          child: const Text('Tap'),
        ),
      );
      await tester.tap(_button());
      await tester.pumpAndSettle();
      expect(log, <String>['start', 'end', 'press']);
    });

    testWidgets('pressing scales down with the size factor', (
      WidgetTester tester,
    ) async {
      const Map<HeroSize, double> scales = <HeroSize, double>{
        HeroSize.sm: 0.98,
        HeroSize.md: 0.97,
        HeroSize.lg: 0.96,
      };
      for (final MapEntry<HeroSize, double> e in scales.entries) {
        await _pump(
          tester,
          HeroButton(size: e.key, onPressed: () {}, child: const Text('A')),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(_button()),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));
        expect(_scale(tester), e.value);
        expect(_fill(tester), _light.colors.accentHover);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(_scale(tester), 1);
      }
    });

    testWidgets('hover shows the hover fill for mouse pointers', (
      WidgetTester tester,
    ) async {
      final List<bool> hovers = <bool>[];
      await _pump(
        tester,
        HeroButton(
          variant: HeroButtonVariant.secondary,
          onHoverChanged: hovers.add,
          onPressed: () {},
          child: const Text('Hover'),
        ),
      );
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(_button()));
      await tester.pumpAndSettle();
      expect(_fill(tester), _light.colors.defaultHover);
      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(_fill(tester), _light.colors.defaultColor);
      expect(hovers, <bool>[true, false]);
    });

    testWidgets('the fill animates over 100 ms', (WidgetTester tester) async {
      await _pump(tester, HeroButton(onPressed: () {}, child: const Text('A')));
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(_button()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      final Color? mid = _fill(tester);
      expect(mid, isNot(_light.colors.accent));
      expect(mid, isNot(_light.colors.accentHover));
      await tester.pump(const Duration(milliseconds: 80));
      expect(_fill(tester), _light.colors.accentHover);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('Enter and Space activate the focused button', (
      WidgetTester tester,
    ) async {
      int presses = 0;
      final List<bool> focus = <bool>[];
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await _useKeyboard(tester);
      await _pump(
        tester,
        HeroButton(
          focusNode: node,
          onFocusChanged: focus.add,
          onPressed: () => presses++,
          child: const Text('Key'),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(presses, 2);
      expect(focus, <bool>[true]);
    });

    testWidgets('keyboard focus shows the focus ring', (
      WidgetTester tester,
    ) async {
      await _useKeyboard(tester);
      await _pump(
        tester,
        HeroButton(onPressed: () {}, child: const Text('Focus')),
      );
      expect(
        tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
        isFalse,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(
        tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
        isTrue,
      );
    });

    testWidgets('autofocus focuses the button', (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        HeroButton(
          autofocus: true,
          focusNode: node,
          onPressed: () {},
          child: const Text('Auto'),
        ),
      );
      expect(node.hasFocus, isTrue);
    });

    testWidgets('disabled buttons are dimmed and ignore input', (
      WidgetTester tester,
    ) async {
      int presses = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        HeroButton(
          isDisabled: true,
          focusNode: node,
          onPressed: () => presses++,
          child: const Text('Disabled'),
        ),
      );
      expect(_opacity(tester), 0.5);
      await tester.tap(_button(), warnIfMissed: false);
      node.requestFocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(presses, 0);
      expect(node.hasFocus, isFalse);
    });

    testWidgets('pending buttons show a spinner, stay focusable and bright', (
      WidgetTester tester,
    ) async {
      int presses = 0;
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await _pump(
        tester,
        HeroButton(
          isPending: true,
          focusNode: node,
          startContent: const HeroIcon(HeroIcons.paperclip),
          onPressed: () => presses++,
          child: const Text('Uploading...'),
        ),
        theme: _still,
      );
      expect(find.byType(HeroSpinner), findsOneWidget);
      expect(find.byType(HeroIcon), findsNothing);
      expect(_opacity(tester), 1);
      final HeroSpinner spinner = tester.widget(find.byType(HeroSpinner));
      expect(spinner.size, HeroSpinnerSize.sm);
      expect(spinner.color, HeroSpinnerColor.current);
      expect(tester.getSize(find.byType(HeroSpinner)), const Size.square(16));
      await tester.tap(_button());
      await tester.pumpAndSettle();
      expect(presses, 0);
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('pending icon-only buttons replace the icon', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButton(
          isPending: true,
          isIconOnly: true,
          semanticLabel: 'Upload',
          onPressed: () {},
          child: const HeroIcon(HeroIcons.paperclip),
        ),
        theme: _still,
      );
      expect(find.byType(HeroSpinner), findsOneWidget);
      expect(find.byType(HeroIcon), findsNothing);
    });

    testWidgets('builder receives the state and replaces the spinner', (
      WidgetTester tester,
    ) async {
      HeroButtonState? last;
      await _pump(
        tester,
        HeroButton(
          isPending: true,
          onPressed: () {},
          builder: (BuildContext context, HeroButtonState state) {
            last = state;
            return Text(state.isPending ? 'Uploading...' : 'Upload');
          },
        ),
        theme: _still,
      );
      expect(last!.isPending, isTrue);
      expect(find.text('Uploading...'), findsOneWidget);
      expect(find.byType(HeroSpinner), findsNothing);

      await _pump(
        tester,
        HeroButton(
          onPressed: () {},
          builder: (BuildContext context, HeroButtonState state) =>
              Text(state.isPressed ? 'Pressed' : 'Press me'),
        ),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(_button()),
      );
      await tester.pump();
      expect(find.text('Pressed'), findsOneWidget);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('toggling pending keeps the button state', (
      WidgetTester tester,
    ) async {
      Widget build(bool pending) => HeroButton(
        isPending: pending,
        startContent: const HeroIcon(HeroIcons.paperclip),
        onPressed: () {},
        child: Text(pending ? 'Uploading...' : 'Upload File'),
      );
      await _pump(tester, build(false), theme: _still);
      expect(find.byType(HeroIcon), findsOneWidget);
      await _pump(tester, build(true), theme: _still);
      expect(find.byType(HeroSpinner), findsOneWidget);
      await _pump(tester, build(false), theme: _still);
      expect(find.byType(HeroSpinner), findsNothing);
      expect(find.text('Upload File'), findsOneWidget);
    });
  });

  group('style', () {
    testWidgets('overrides colors per state, shape and geometry', (
      WidgetTester tester,
    ) async {
      const Color rest = Color(0xFF08872B);
      const Color hover = Color(0xFF0FBF3E);
      await _pump(
        tester,
        HeroButton(
          style: HeroButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) =>
                  states.contains(WidgetState.hovered) ? hover : rest,
            ),
            foregroundColor: const WidgetStatePropertyAll<Color>(
              Color(0xFFFFFFFF),
            ),
            borderRadius: BorderRadius.zero,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            pressedScale: 0.9,
          ),
          onPressed: () {},
          child: const Text('Custom'),
        ),
      );
      expect(_fill(tester), rest);
      expect(tester.getSize(_button()).height, 52);
      expect(
        tester.getSize(_button()).width,
        tester.getSize(find.text('Custom')).width + 80,
      );
      expect(_textColor(tester, 'Custom'), const Color(0xFFFFFFFF));
      final RoundedSuperellipseBorder shape =
          _shape(tester) as RoundedSuperellipseBorder;
      expect(shape.borderRadius, BorderRadius.zero);

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: tester.getCenter(_button()));
      addTearDown(mouse.removePointer);
      await tester.pumpAndSettle();
      expect(_fill(tester), hover);

      await mouse.down(tester.getCenter(_button()));
      await tester.pump();
      expect(_scale(tester), 0.9);
      await mouse.up();
      await tester.pumpAndSettle();
    });

    testWidgets('BorderSide.none removes the outline', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButton(
          variant: HeroButtonVariant.outline,
          style: const HeroButtonStyle(side: BorderSide.none),
          onPressed: () {},
          child: const Text('Outline'),
        ),
      );
      final CustomPaint paint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(HeroButtonSurface),
              matching: find.byType(CustomPaint),
            )
            .first,
      );
      expect(paint.foregroundPainter, isNull);
    });

    test('merge and copyWith keep unset fields', () {
      const HeroButtonStyle a = HeroButtonStyle(
        height: 44,
        textStyle: TextStyle(fontSize: 12),
      );
      final HeroButtonStyle b = a.merge(
        const HeroButtonStyle(
          pressedScale: 0.95,
          textStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
      expect(b.height, 44);
      expect(b.pressedScale, 0.95);
      expect(b.textStyle?.fontSize, 12);
      expect(b.textStyle?.fontWeight, FontWeight.w600);
      expect(a.merge(null), same(a));
      expect(a.copyWith(height: 48).height, 48);
      expect(
        a,
        const HeroButtonStyle(height: 44, textStyle: TextStyle(fontSize: 12)),
      );
    });
  });

  group('semantics', () {
    testWidgets('exposes an enabled button with its label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        HeroButton(onPressed: () {}, child: const Text('Save')),
      );
      expect(
        tester.getSemantics(_button()),
        matchesSemantics(
          label: 'Save',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('icon-only buttons use the semantic label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        HeroButton(
          isIconOnly: true,
          semanticLabel: 'Settings',
          onPressed: () {},
          child: const HeroIcon(HeroIcons.gear),
        ),
      );
      expect(
        tester.getSemantics(_button()),
        matchesSemantics(
          label: 'Settings',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('disabled and pending buttons are announced as unavailable', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        HeroButton(
          isDisabled: true,
          onPressed: () {},
          child: const Text('Off'),
        ),
      );
      expect(
        tester.getSemantics(_button()),
        matchesSemantics(label: 'Off', isButton: true, hasEnabledState: true),
      );
      await _pump(
        tester,
        HeroButton(
          isPending: true,
          onPressed: () {},
          builder: (BuildContext context, HeroButtonState state) =>
              const Text('Saving'),
        ),
        theme: _still,
      );
      expect(
        tester.getSemantics(_button()),
        matchesSemantics(
          label: 'Saving',
          isButton: true,
          hasEnabledState: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });
  });

  group('HeroButtonMetrics', () {
    testWidgets('resolves the css geometry', (WidgetTester tester) async {
      late HeroButtonMetrics sm;
      late HeroButtonMetrics lg;
      await _pump(
        tester,
        Builder(
          builder: (BuildContext context) {
            sm = HeroButtonMetrics.of(context, HeroSize.sm);
            lg = HeroButtonMetrics.of(context, HeroSize.lg);
            return const SizedBox();
          },
        ),
      );
      expect(sm.height, 36);
      expect(sm.horizontalPadding, 12);
      expect(sm.iconSize, 16);
      expect(sm.pressedScale, 0.98);
      expect(lg.height, 44);
      expect(lg.horizontalPadding, 16);
      expect(lg.iconSize, 20);
      expect(lg.textStyle.fontSize, 16);
      expect(lg.radius, 24);
      expect(lg.gap, 8);
    });
  });

  group('HeroButtonContent', () {
    testWidgets('supports intrinsic sizing and baselines', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        IntrinsicWidth(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              HeroButton(
                startContent: const HeroIcon(HeroIcons.plus),
                onPressed: () {},
                child: const Text('Add'),
              ),
              const Text('Aligned'),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getBottomLeft(find.text('Add')).dy,
        closeTo(tester.getBottomLeft(find.text('Aligned')).dy, 4),
      );
    });

    testWidgets('only icons get the negative margin', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        const HeroButtonContent(
          gap: 8,
          iconInset: 2,
          startContent: SizedBox(width: 20, height: 20),
          label: SizedBox(width: 30, height: 20),
        ),
      );
      expect(tester.getSize(find.byType(HeroButtonContent)).width, 58);
      await _pump(
        tester,
        const HeroButtonContent(
          gap: 8,
          iconInset: 2,
          startContent: HeroIcon(HeroIcons.plus, size: 20),
          label: SizedBox(width: 30, height: 20),
        ),
      );
      expect(tester.getSize(find.byType(HeroButtonContent)).width, 54);
    });
  });
}
