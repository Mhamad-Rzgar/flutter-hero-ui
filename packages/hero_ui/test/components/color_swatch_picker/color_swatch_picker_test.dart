import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<Color> _palette = <Color>[
  Color(0xFFF43F5E),
  Color(0xFFD946EF),
  Color(0xFF8B5CF6),
  Color(0xFF3B82F6),
  Color(0xFF06B6D4),
  Color(0xFF10B981),
  Color(0xFF84CC16),
];

void main() {
  Finder item(int index) => find.byType(HeroColorSwatchPickerItem).at(index);

  ShapeDecoration decorationOf(WidgetTester tester, int index) {
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find
          .descendant(of: item(index), matching: find.byType(DecoratedBox))
          .first,
    );
    return box.decoration as ShapeDecoration;
  }

  bool isSelected(WidgetTester tester, int index) {
    final OutlinedBorder shape =
        decorationOf(tester, index).shape as OutlinedBorder;
    return shape.side.color.a > 0;
  }

  FocusNode focusOf(WidgetTester tester, int index) => Focus.of(
    tester.element(
      find.descendant(of: item(index), matching: find.byType(CustomPaint)).last,
    ),
  );

  void useKeyboardHighlight() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
  }

  testWidgets('sizes, gap and default parts', (WidgetTester tester) async {
    for (final (HeroColorSwatchSize size, double extent)
        in <(HeroColorSwatchSize, double)>[
          (HeroColorSwatchSize.xs, 16),
          (HeroColorSwatchSize.md, 32),
          (HeroColorSwatchSize.xl, 40),
        ]) {
      await pumpHero(
        tester,
        HeroColorSwatchPicker(colors: _palette.take(2).toList(), size: size),
      );
      expect(tester.getSize(item(0)), Size.square(extent));
      expect(tester.getTopLeft(item(1)).dx - tester.getTopRight(item(0)).dx, 8);
    }
    expect(find.byType(HeroColorSwatchPickerSwatch), findsNWidgets(2));
    expect(find.byType(HeroColorSwatchPickerIndicator), findsNWidgets(2));
  });

  testWidgets('tapping selects; the selection cannot be emptied', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      HeroColorSwatchPicker(colors: _palette, onChanged: changes.add),
    );
    expect(isSelected(tester, 2), isFalse);
    await tester.tap(item(2));
    await tester.pumpAndSettle();
    expect(changes, <Color>[_palette[2]]);
    expect(isSelected(tester, 2), isTrue);
    final OutlinedBorder shape =
        decorationOf(tester, 2).shape as OutlinedBorder;
    expect(shape.side.color, _palette[2]);
    expect(shape.side.width, 2);
    // The swatch shrinks and the check mark appears.
    final AnimatedScale swatchScale = tester.widget<AnimatedScale>(
      find
          .descendant(
            of: find.byType(HeroColorSwatchPickerSwatch).at(2),
            matching: find.byType(AnimatedScale),
          )
          .first,
    );
    expect(swatchScale.scale, 0.77);

    await tester.tap(item(2));
    await tester.pumpAndSettle();
    expect(changes, hasLength(1));
  });

  testWidgets('default value and controlled value', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroColorSwatchPicker(
        colors: _palette,
        defaultValue: Color(0xFF8B5CF6),
      ),
    );
    expect(isSelected(tester, 2), isTrue);

    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      HeroColorSwatchPicker(
        colors: _palette,
        value: const Color(0xFFF43F5E),
        onChanged: changes.add,
      ),
    );
    await tester.tap(item(3));
    await tester.pumpAndSettle();
    expect(changes, <Color>[_palette[3]]);
    expect(isSelected(tester, 0), isTrue);
    expect(isSelected(tester, 3), isFalse);
  });

  testWidgets('disabled items are faded and not selectable', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      HeroColorSwatchPicker(
        onChanged: changes.add,
        children: <HeroColorSwatchPickerItem>[
          for (final Color color in _palette.take(3))
            HeroColorSwatchPickerItem(color: color, isDisabled: true),
        ],
      ),
    );
    await tester.tap(item(1));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    final Opacity opacity = tester.widget<Opacity>(
      find.descendant(of: item(1), matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('keyboard: tab to the selection, arrows move, enter selects', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      HeroColorSwatchPicker(
        defaultValue: _palette[1],
        onChanged: changes.add,
        children: <HeroColorSwatchPickerItem>[
          for (int i = 0; i < 4; i++)
            HeroColorSwatchPickerItem(color: _palette[i], isDisabled: i == 2),
        ],
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 1).hasPrimaryFocus, isTrue);

    // The disabled third item is skipped.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 3).hasPrimaryFocus, isTrue);
    expect(changes, isEmpty);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(changes, <Color>[_palette[3]]);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 0).hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(changes.last, _palette[0]);

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 3).hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 1).hasPrimaryFocus, isTrue);
  });

  testWidgets('keyboard: arrows follow reading order in right to left', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    await pumpHero(
      tester,
      HeroColorSwatchPicker(colors: _palette.take(3).toList()),
      textDirection: TextDirection.rtl,
    );
    expect(
      tester.getCenter(item(0)).dx,
      greaterThan(tester.getCenter(item(1)).dx),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 0).hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 1).hasPrimaryFocus, isTrue);
  });

  testWidgets('keyboard: up and down move between wrapped rows', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    // Three 32px items fit per 112px row.
    await pumpHero(
      tester,
      SizedBox(
        width: 112,
        child: HeroColorSwatchPicker(colors: _palette.take(6).toList()),
      ),
    );
    expect(
      tester.getTopLeft(item(3)).dy,
      greaterThan(tester.getTopLeft(item(0)).dy),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 1).hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 4).hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 1).hasPrimaryFocus, isTrue);
  });

  testWidgets('stack layout is a column navigated with up and down', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    await pumpHero(
      tester,
      HeroColorSwatchPicker(
        colors: _palette.take(3).toList(),
        layout: HeroColorSwatchPickerLayout.stack,
      ),
    );
    expect(tester.getTopLeft(item(1)).dy - tester.getBottomLeft(item(0)).dy, 8);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 1).hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 1).hasPrimaryFocus, isTrue);
  });

  testWidgets('semantics: selectable buttons named after their color', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const HeroColorSwatchPicker(
        semanticLabel: 'Palette',
        colors: <Color>[Color(0xFFEF4444), Color(0xFFFFFFFF)],
        defaultValue: Color(0xFFEF4444),
      ),
    );
    expect(
      tester.getSemantics(item(0)),
      matchesSemantics(
        label: 'vibrant red',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        isFocusable: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(tester.getSemantics(item(1)).label, 'white');
    handle.dispose();
  });

  testWidgets('binds to the color picker scope without a value', (
    WidgetTester tester,
  ) async {
    HeroColorValue value = const HeroColorValue.hsb(0, 0, 0);
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) =>
            HeroColorPickerScope(
              value: value,
              onChanged: (HeroColorValue next) => setState(() => value = next),
              child: const HeroColorSwatchPicker(colors: _palette),
            ),
      ),
    );
    await tester.tap(item(4));
    await tester.pumpAndSettle();
    expect(value.space, HeroColorSpace.hsb);
    expect(heroColorsEqual(value.toColor(), _palette[4]), isTrue);
    expect(isSelected(tester, 4), isTrue);
  });

  testWidgets('indicator: white on dark colors, black on light ones', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroColorSwatchPicker(
        children: <HeroColorSwatchPickerItem>[
          HeroColorSwatchPickerItem(color: Color(0xFF3B82F6)),
          HeroColorSwatchPickerItem(
            color: Color(0xFFFDE047),
            children: <Widget>[
              HeroColorSwatchPickerSwatch(),
              HeroColorSwatchPickerIndicator(
                child: HeroIcon(HeroIcons.heartFill),
              ),
            ],
          ),
          HeroColorSwatchPickerItem(
            color: Color(0xFF10B981),
            children: <Widget>[HeroColorSwatchPickerSwatch()],
          ),
        ],
      ),
    );
    IconThemeData iconTheme(int index) => tester
        .widget<IconTheme>(
          find
              .descendant(of: item(index), matching: find.byType(IconTheme))
              .last,
        )
        .data;
    final HeroColors colors = HeroThemeData.light().colors;
    expect(iconTheme(0).color, colors.white);
    expect(iconTheme(1).color, colors.black);
    expect(iconTheme(1).size, closeTo(28 / 3, 1e-9));
    expect(
      find.descendant(of: item(1), matching: find.byType(HeroIcon)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: item(2),
        matching: find.byType(HeroColorSwatchPickerIndicator),
      ),
      findsNothing,
    );
  });

  testWidgets('item builder receives the state', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroColorSwatchPicker(
        defaultValue: _palette[1],
        children: <HeroColorSwatchPickerItem>[
          for (final Color color in _palette.take(2))
            HeroColorSwatchPickerItem(
              color: color,
              builder:
                  (
                    BuildContext context,
                    HeroColorSwatchPickerItemState state,
                  ) => Text(state.isSelected ? 'on' : 'off'),
            ),
        ],
      ),
    );
    expect(find.text('off'), findsOneWidget);
    expect(find.text('on'), findsOneWidget);
  });

  testWidgets('no overflow at 2x text scale', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        child: HeroColorSwatchPicker(colors: _palette),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
