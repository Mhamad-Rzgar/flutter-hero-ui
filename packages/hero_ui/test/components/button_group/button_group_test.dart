import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroThemeData _light = HeroThemeData.light().copyWith(
  density: HeroDensity.touch,
);

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  double textScale = 1,
}) => pumpHero(
  tester,
  child,
  theme: _light,
  textDirection: textDirection,
  textScale: textScale,
);

Finder _button(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(HeroButton));

ShapeDecoration _decoration(WidgetTester tester, String label) {
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find
        .descendant(of: _button(label), matching: find.byType(DecoratedBox))
        .first,
  );
  return box.decoration as ShapeDecoration;
}

BorderRadiusGeometry _radius(WidgetTester tester, String label) =>
    (_decoration(tester, label).shape as RoundedSuperellipseBorder)
        .borderRadius;

CustomPainter? _chrome(WidgetTester tester, String label) => tester
    .widget<CustomPaint>(
      find
          .descendant(
            of: find.descendant(
              of: _button(label),
              matching: find.byType(HeroButtonSurface),
            ),
            matching: find.byType(CustomPaint),
          )
          .first,
    )
    .foregroundPainter;

Widget _group({
  HeroButtonVariant? variant,
  HeroSize? size,
  Axis orientation = Axis.horizontal,
  bool isDisabled = false,
  bool fullWidth = false,
  bool? thirdDisabled,
  List<int>? presses,
}) {
  return HeroButtonGroup(
    variant: variant,
    size: size,
    orientation: orientation,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    semanticLabel: 'Actions',
    children: <Widget>[
      HeroButton(onPressed: () => presses?.add(1), child: const Text('First')),
      const HeroButtonGroupSeparator(),
      HeroButton(onPressed: () => presses?.add(2), child: const Text('Second')),
      const HeroButtonGroupSeparator(),
      HeroButton(
        isDisabled: thirdDisabled,
        onPressed: () => presses?.add(3),
        child: const Text('Third'),
      ),
    ],
  );
}

void main() {
  group('HeroGroupPosition', () {
    test('rounds only the outer corners', () {
      const Radius r = Radius.circular(24);
      expect(
        const HeroGroupPosition(
          orientation: Axis.horizontal,
          index: 0,
          count: 3,
        ).borderRadius(24),
        const BorderRadiusDirectional.horizontal(start: r),
      );
      expect(
        const HeroGroupPosition(
          orientation: Axis.horizontal,
          index: 1,
          count: 3,
        ).borderRadius(24),
        BorderRadiusDirectional.zero,
      );
      expect(
        const HeroGroupPosition(
          orientation: Axis.vertical,
          index: 2,
          count: 3,
        ).borderRadius(24),
        const BorderRadiusDirectional.vertical(bottom: r),
      );
      expect(
        const HeroGroupPosition(
          orientation: Axis.vertical,
          index: 0,
          count: 1,
        ).borderRadius(24),
        const BorderRadiusDirectional.all(r),
      );
    });

    test('merges outlines between neighbours', () {
      const HeroGroupPosition first = HeroGroupPosition(
        orientation: Axis.horizontal,
        index: 0,
        count: 3,
      );
      const HeroGroupPosition middle = HeroGroupPosition(
        orientation: Axis.horizontal,
        index: 1,
        count: 3,
      );
      const HeroGroupPosition last = HeroGroupPosition(
        orientation: Axis.vertical,
        index: 2,
        count: 3,
      );
      expect(
        first.borderWidths(1),
        const EdgeInsetsDirectional.fromSTEB(1, 1, 0, 1),
      );
      expect(
        middle.borderWidths(1),
        const EdgeInsetsDirectional.fromSTEB(0, 1, 0, 1),
      );
      expect(
        last.borderWidths(1),
        const EdgeInsetsDirectional.fromSTEB(1, 0, 1, 1),
      );
      expect(first, isNot(middle));
      expect(first.toString(), contains('1 of 3'));
    });
  });

  group('HeroButtonGroup', () {
    testWidgets('lays out attached buttons with outer corners only', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _group());
      final Rect first = tester.getRect(_button('First'));
      final Rect second = tester.getRect(_button('Second'));
      final Rect third = tester.getRect(_button('Third'));
      expect(second.left, first.right);
      expect(third.left, second.right);
      const Radius r = Radius.circular(24);
      expect(_radius(tester, 'First'), const BorderRadius.horizontal(left: r));
      expect(_radius(tester, 'Second'), BorderRadius.zero);
      expect(_radius(tester, 'Third'), const BorderRadius.horizontal(right: r));
    });

    testWidgets('mirrors in right-to-left', (WidgetTester tester) async {
      await _pump(tester, _group(), textDirection: TextDirection.rtl);
      expect(
        tester.getRect(_button('First')).left,
        greaterThan(tester.getRect(_button('Third')).left),
      );
      const Radius r = Radius.circular(24);
      expect(_radius(tester, 'First'), const BorderRadius.horizontal(right: r));
    });

    testWidgets('stacks vertically and centres buttons', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _group(orientation: Axis.vertical));
      final Rect first = tester.getRect(_button('First'));
      final Rect second = tester.getRect(_button('Second'));
      expect(second.top, first.bottom);
      expect(first.center.dx, closeTo(second.center.dx, 0.01));
      const Radius r = Radius.circular(24);
      expect(_radius(tester, 'First'), const BorderRadius.vertical(top: r));
    });

    testWidgets('passes variant and size to its buttons', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _group(variant: HeroButtonVariant.secondary, size: HeroSize.lg),
      );
      expect(_decoration(tester, 'Second').color, _light.colors.defaultColor);
      expect(tester.getSize(_button('Second')).height, 44);
    });

    testWidgets('a button keeps its own props over the group', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButtonGroup(
          variant: HeroButtonVariant.secondary,
          size: HeroSize.lg,
          children: <Widget>[
            HeroButton(onPressed: () {}, child: const Text('First')),
            HeroButton(
              variant: HeroButtonVariant.danger,
              size: HeroSize.sm,
              onPressed: () {},
              child: const Text('Second'),
            ),
          ],
        ),
      );
      expect(_decoration(tester, 'Second').color, _light.colors.danger);
      expect(tester.getSize(_button('Second')).height, 36);
    });

    testWidgets('disables every button unless one opts out', (
      WidgetTester tester,
    ) async {
      final List<int> presses = <int>[];
      await _pump(
        tester,
        _group(isDisabled: true, thirdDisabled: false, presses: presses),
      );
      await tester.tap(_button('First'), warnIfMissed: false);
      await tester.tap(_button('Second'), warnIfMissed: false);
      await tester.tap(_button('Third'));
      await tester.pumpAndSettle();
      expect(presses, <int>[3]);
    });

    testWidgets('separators mark the following button', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButtonGroup(
          children: <Widget>[
            HeroButton(onPressed: () {}, child: const Text('First')),
            HeroButton(onPressed: () {}, child: const Text('Second')),
            const HeroButtonGroupSeparator(),
            HeroButton(onPressed: () {}, child: const Text('Third')),
          ],
        ),
      );
      expect(find.byType(HeroButton), findsNWidgets(3));
      expect(_chrome(tester, 'First'), isNull);
      expect(_chrome(tester, 'Second'), isNull);
      expect(_chrome(tester, 'Third'), isNotNull);
      // The separator is not an item: Third is the last, rounded item.
      expect(
        _radius(tester, 'Third'),
        const BorderRadius.horizontal(right: Radius.circular(24)),
      );
    });

    testWidgets('outline buttons share borders', (WidgetTester tester) async {
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _group(variant: HeroButtonVariant.outline),
            HeroButton(
              variant: HeroButtonVariant.outline,
              onPressed: () {},
              child: const Text('Second'),
            ),
          ],
        ),
      );
      final List<double> widths = find
          .byType(HeroButton)
          .evaluate()
          .map((Element e) => tester.getSize(find.byWidget(e.widget)).width)
          .toList();
      // The grouped middle button drops both inline borders (2 px narrower
      // than a standalone outline button); first and last drop one.
      expect(widths[1], widths[3] - 2);
      // Natural sizes are rounded up to whole pixels.
      expect(
        widths[0],
        tester.getSize(find.text('First').first).width.ceilToDouble() +
            16 * 2 +
            1,
      );
      expect(widths.every((double w) => w == w.roundToDouble()), isTrue);
    });

    testWidgets('does not scale pressed buttons', (WidgetTester tester) async {
      await _pump(tester, _group());
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(_button('Second')),
      );
      await tester.pump();
      final AnimatedScale scale = tester.widget<AnimatedScale>(
        find.descendant(
          of: _button('Second'),
          matching: find.byType(AnimatedScale),
        ),
      );
      expect(scale.scale, 1);
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('fullWidth shares a row equally and stretches a column', (
      WidgetTester tester,
    ) async {
      await _pump(tester, SizedBox(width: 390, child: _group(fullWidth: true)));
      for (final String label in <String>['First', 'Second', 'Third']) {
        expect(tester.getSize(_button(label)).width, 130);
      }
      // Fractional shares are moved to whole-pixel boundaries.
      await _pump(tester, SizedBox(width: 400, child: _group(fullWidth: true)));
      final Rect first = tester.getRect(_button('First'));
      final Rect second = tester.getRect(_button('Second'));
      final Rect third = tester.getRect(_button('Third'));
      expect(second.left, first.right);
      expect(third.left, second.right);
      expect(third.right - first.left, 400);
      for (final Rect r in <Rect>[first, second, third]) {
        expect(r.width, r.width.roundToDouble());
        expect(r.width, closeTo(400 / 3, 1));
      }
      await _pump(
        tester,
        SizedBox(
          width: 200,
          child: _group(fullWidth: true, orientation: Axis.vertical),
        ),
      );
      for (final String label in <String>['First', 'Second', 'Third']) {
        expect(tester.getSize(_button(label)).width, 200);
      }
    });

    testWidgets('Tab moves through the buttons in order', (
      WidgetTester tester,
    ) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      final List<int> presses = <int>[];
      await _pump(tester, _group(presses: presses));
      for (int i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
      }
      expect(presses, <int>[1, 2, 3]);
      final HeroFocusRing ring = tester.widget<HeroFocusRing>(
        find.descendant(
          of: _button('Third'),
          matching: find.byType(HeroFocusRing),
        ),
      );
      expect(ring.visible, isTrue);
    });

    testWidgets('wrapped buttons take the group props, nested ones do not', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        HeroButtonGroup(
          variant: HeroButtonVariant.secondary,
          children: <Widget>[
            // A wrapper, like a dropdown around its trigger.
            Builder(
              builder: (BuildContext context) =>
                  HeroButton(onPressed: () {}, child: const Text('First')),
            ),
            HeroButton(
              onPressed: () {},
              endContent: HeroButton(
                onPressed: () {},
                child: const Text('Inner'),
              ),
              child: const Text('Second'),
            ),
            HeroButtonGroupScope.reset(
              child: HeroButton(onPressed: () {}, child: const Text('Third')),
            ),
          ],
        ),
      );
      expect(_decoration(tester, 'First').color, _light.colors.defaultColor);
      expect(_decoration(tester, 'Inner').color, _light.colors.accent);
      expect(_decoration(tester, 'Third').color, _light.colors.accent);
      expect(
        _radius(tester, 'Inner'),
        const BorderRadius.all(Radius.circular(24)),
      );
    });

    testWidgets('exposes a labelled group', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(tester, _group());
      expect(
        tester.getSemantics(find.byType(HeroButtonGroup)),
        matchesSemantics(
          label: 'Actions',
          children: <Matcher>[
            for (final String label in <String>['First', 'Second', 'Third'])
              matchesSemantics(
                label: label,
                isButton: true,
                hasEnabledState: true,
                isEnabled: true,
                isFocusable: true,
                hasTapAction: true,
              ),
          ],
        ),
      );
      handle.dispose();
    });

    testWidgets('grows with 2x text without overflowing', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _group(orientation: Axis.vertical), textScale: 2);
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(_button('Second')).height,
        greaterThanOrEqualTo(40),
      );
    });

    testWidgets('a separator outside a group renders nothing', (
      WidgetTester tester,
    ) async {
      await _pump(tester, const HeroButtonGroupSeparator());
      expect(tester.getSize(find.byType(HeroButtonGroupSeparator)), Size.zero);
      expect(
        HeroButtonGroupScope.maybeOf(
          tester.element(find.byType(HeroButtonGroupSeparator)),
        ),
        isNull,
      );
    });

    testWidgets('keyed children keep their state when reordered', (
      WidgetTester tester,
    ) async {
      final FocusNode a = FocusNode();
      final FocusNode b = FocusNode();
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      Widget build(bool swapped) {
        final List<Widget> buttons = <Widget>[
          HeroButton(
            key: const ValueKey<String>('a'),
            focusNode: a,
            onPressed: () {},
            child: const Text('A'),
          ),
          HeroButton(
            key: const ValueKey<String>('b'),
            focusNode: b,
            onPressed: () {},
            child: const Text('B'),
          ),
        ];
        return HeroButtonGroup(
          children: swapped ? buttons.reversed.toList() : buttons,
        );
      }

      await _pump(tester, build(false));
      a.requestFocus();
      await tester.pump();
      await _pump(tester, build(true));
      expect(a.hasFocus, isTrue);
      expect(
        tester.getRect(_button('A')).left,
        greaterThan(tester.getRect(_button('B')).left),
      );
    });
  });
}
