import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData light = HeroThemeData.light();

  List<Widget> formatting({
    bool separators = true,
    Map<String, bool?> disabled = const <String, bool?>{},
    HeroSize? size,
  }) {
    const List<(String, HeroIconData)> items = <(String, HeroIconData)>[
      ('bold', HeroIcons.bold),
      ('italic', HeroIcons.italic),
      ('underline', HeroIcons.underline),
    ];
    return <Widget>[
      for (int i = 0; i < items.length; i++)
        HeroToggleButton(
          id: items[i].$1,
          size: size,
          isIconOnly: true,
          isDisabled: disabled[items[i].$1],
          semanticLabel: items[i].$1,
          separator: separators && i > 0
              ? const HeroToggleButtonGroupSeparator()
              : null,
          child: HeroIcon(items[i].$2),
        ),
    ];
  }

  Finder button(String label) => find.byWidgetPredicate(
    (Widget w) => w is HeroToggleButton && w.semanticLabel == label,
  );

  ShapeDecoration decorationOf(WidgetTester tester, String label) {
    final AnimatedContainer container = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: button(label),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    return container.decoration! as ShapeDecoration;
  }

  BorderRadius radiusOf(
    WidgetTester tester,
    String label, [
    TextDirection direction = TextDirection.ltr,
  ]) {
    final OutlinedBorder shape =
        decorationOf(tester, label).shape as OutlinedBorder;
    return switch (shape) {
      RoundedSuperellipseBorder(:final BorderRadiusGeometry borderRadius) =>
        borderRadius.resolve(direction),
      RoundedRectangleBorder(:final BorderRadiusGeometry borderRadius) =>
        borderRadius.resolve(direction),
      _ => throw StateError('unexpected shape $shape'),
    };
  }

  Rect rectOf(WidgetTester tester, String label) => tester.getRect(
    find
        .descendant(of: button(label), matching: find.byType(AnimatedContainer))
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

  testWidgets('single selection selects one button at a time', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    await pumpHero(
      tester,
      HeroToggleButtonGroup(
        onSelectionChanged: changes.add,
        children: formatting(),
      ),
    );
    await tester.tap(button('bold'));
    await tester.pumpAndSettle();
    await tester.tap(button('italic'));
    await tester.pumpAndSettle();
    expect(decorationOf(tester, 'bold').color, light.colors.defaultColor);
    expect(decorationOf(tester, 'italic').color, light.colors.accentSoft);
    await tester.tap(button('italic'));
    await tester.pumpAndSettle();
    expect(changes, <Set<Object>>[
      <Object>{'bold'},
      <Object>{'italic'},
      <Object>{},
    ]);
  });

  testWidgets('disallowEmptySelection keeps the last selection', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    await pumpHero(
      tester,
      HeroToggleButtonGroup(
        defaultSelectedKeys: const <Object>{'bold'},
        disallowEmptySelection: true,
        onSelectionChanged: changes.add,
        children: formatting(),
      ),
    );
    await tester.tap(button('bold'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(decorationOf(tester, 'bold').color, light.colors.accentSoft);
  });

  testWidgets('multiple selection toggles independently', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    final List<bool> italicChanges = <bool>[];
    await pumpHero(
      tester,
      HeroToggleButtonGroup(
        selectionMode: HeroSelectionMode.multiple,
        defaultSelectedKeys: const <Object>{'bold'},
        onSelectionChanged: changes.add,
        children: <Widget>[
          ...formatting().take(1),
          HeroToggleButton(
            id: 'italic',
            isIconOnly: true,
            semanticLabel: 'italic',
            onChanged: italicChanges.add,
            child: const HeroIcon(HeroIcons.italic),
          ),
        ],
      ),
    );
    await tester.tap(button('italic'));
    await tester.pumpAndSettle();
    await tester.tap(button('bold'));
    await tester.pumpAndSettle();
    expect(changes, <Set<Object>>[
      <Object>{'bold', 'italic'},
      <Object>{'italic'},
    ]);
    expect(italicChanges, <bool>[true]);
  });

  testWidgets('controlled selection follows selectedKeys', (
    WidgetTester tester,
  ) async {
    Set<Object> selected = <Object>{'bold'};
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroToggleButtonGroup(
              selectionMode: HeroSelectionMode.multiple,
              selectedKeys: selected,
              onSelectionChanged: (Set<Object> keys) =>
                  setState(() => selected = keys),
              children: formatting(),
            ),
            Text(selected.isEmpty ? 'None' : selected.join(', ')),
          ],
        ),
      ),
    );
    expect(find.text('bold'), findsOneWidget);
    await tester.tap(button('underline'));
    await tester.pumpAndSettle();
    expect(find.text('bold, underline'), findsOneWidget);
    expect(decorationOf(tester, 'underline').color, light.colors.accentSoft);

    // Without an update from the parent nothing changes.
    await pumpHero(
      tester,
      HeroToggleButtonGroup(
        selectedKeys: const <Object>{'bold'},
        children: formatting(),
      ),
    );
    await tester.tap(button('italic'));
    await tester.pumpAndSettle();
    expect(decorationOf(tester, 'italic').color, light.colors.defaultColor);
    expect(decorationOf(tester, 'bold').color, light.colors.accentSoft);
  });

  testWidgets('attached buttons round only the outer corners', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, HeroToggleButtonGroup(children: formatting()));
    const Radius r = Radius.circular(24);
    expect(radiusOf(tester, 'bold'), const BorderRadius.horizontal(left: r));
    expect(radiusOf(tester, 'italic'), BorderRadius.zero);
    expect(
      radiusOf(tester, 'underline'),
      const BorderRadius.horizontal(right: r),
    );
    expect(rectOf(tester, 'italic').left, rectOf(tester, 'bold').right);
    // Separators are drawn inside the second and third buttons.
    expect(find.byType(FractionallySizedBox), findsNWidgets(2));
    // No press scale inside groups.
    await tester.startGesture(tester.getCenter(button('italic')));
    await tester.pump(const Duration(milliseconds: 300));
    for (final AnimatedScale scale in tester.widgetList<AnimatedScale>(
      find.byType(AnimatedScale),
    )) {
      expect(scale.scale, 1);
    }
  });

  testWidgets('right to left flips the rounded corners', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroToggleButtonGroup(children: formatting()),
      textDirection: TextDirection.rtl,
    );
    const Radius r = Radius.circular(24);
    expect(
      radiusOf(tester, 'bold', TextDirection.rtl),
      const BorderRadius.horizontal(right: r),
    );
    expect(
      rectOf(tester, 'bold').left,
      greaterThan(rectOf(tester, 'italic').left),
    );
  });

  testWidgets('detached buttons have a gap, full radius and no separators', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroToggleButtonGroup(isDetached: true, children: formatting()),
    );
    expect(
      rectOf(tester, 'italic').left - rectOf(tester, 'bold').right,
      light.spacing(1),
    );
    expect(
      radiusOf(tester, 'italic'),
      const BorderRadius.all(Radius.circular(24)),
    );
    expect(find.byType(FractionallySizedBox), findsNothing);
  });

  testWidgets('vertical groups stack and round top and bottom', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroToggleButtonGroup(orientation: Axis.vertical, children: formatting()),
    );
    const Radius r = Radius.circular(24);
    expect(radiusOf(tester, 'bold'), const BorderRadius.vertical(top: r));
    expect(
      radiusOf(tester, 'underline'),
      const BorderRadius.vertical(bottom: r),
    );
    expect(rectOf(tester, 'italic').top, rectOf(tester, 'bold').bottom);
  });

  testWidgets('size propagates unless a button sets its own', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroToggleButtonGroup(
        size: HeroSize.lg,
        children: <Widget>[
          ...formatting().take(2),
          const HeroToggleButton(
            id: 'small',
            size: HeroSize.sm,
            isIconOnly: true,
            semanticLabel: 'small',
            child: HeroIcon(HeroIcons.bold),
          ),
        ],
      ),
      surfaceSize: const Size(400, 400),
    );
    expect(rectOf(tester, 'bold').size, const Size.square(44));
    expect(rectOf(tester, 'small').size, const Size.square(36));
  });

  testWidgets('full width stretches the buttons', (WidgetTester tester) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        child: HeroToggleButtonGroup(fullWidth: true, children: formatting()),
      ),
    );
    expect(rectOf(tester, 'bold').width, 100);
    expect(rectOf(tester, 'underline').width, 100);
  });

  testWidgets('a disabled group disables buttons unless they opt out', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    await pumpHero(
      tester,
      HeroToggleButtonGroup(
        isDisabled: true,
        onSelectionChanged: changes.add,
        children: formatting(disabled: <String, bool?>{'underline': false}),
      ),
    );
    await tester.tap(button('bold'));
    await tester.tap(button('underline'));
    await tester.pumpAndSettle();
    expect(changes, <Set<Object>>[
      <Object>{'underline'},
    ]);
  });

  testWidgets('arrow keys move focus, Tab leaves the group', (
    WidgetTester tester,
  ) async {
    final FocusNode after = FocusNode(debugLabel: 'after');
    addTearDown(after.dispose);
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroToggleButtonGroup(
            selectionMode: HeroSelectionMode.multiple,
            children: formatting(disabled: <String, bool?>{'italic': true}),
          ),
          Focus(focusNode: after, child: const SizedBox(width: 10, height: 10)),
        ],
      ),
    );
    useKeyboardHighlight();
    FocusNode focusOf(String label) => Focus.of(
      tester.element(
        find.descendant(of: button(label), matching: find.byType(HeroIcon)),
      ),
    );

    // Tab enters the group on its first enabled button.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(focusOf('bold').hasPrimaryFocus, isTrue);

    // Disabled buttons are skipped.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(focusOf('underline').hasPrimaryFocus, isTrue);

    // No wrapping at the end.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(focusOf('underline').hasPrimaryFocus, isTrue);

    // Space toggles the focused button.
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(decorationOf(tester, 'underline').color, light.colors.accentSoft);

    // The focused button shows an inset ring.
    expect(
      find.descendant(
        of: button('underline'),
        matching: find.byWidgetPredicate(
          (Widget w) =>
              w is CustomPaint &&
              w.foregroundPainter != null &&
              w.foregroundPainter is! HeroFocusRingPainter,
        ),
      ),
      findsOneWidget,
    );

    // Tab leaves the group.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(after.hasPrimaryFocus, isTrue);

    // Shift+Tab comes back to the last focused button.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(focusOf('underline').hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(focusOf('bold').hasPrimaryFocus, isTrue);
  });

  testWidgets('arrow keys follow the reading and layout direction', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroToggleButtonGroup(children: formatting()),
      textDirection: TextDirection.rtl,
    );
    useKeyboardHighlight();
    FocusNode focusOf(String label) => Focus.of(
      tester.element(
        find.descendant(of: button(label), matching: find.byType(HeroIcon)),
      ),
    );
    focusOf('bold').requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(focusOf('italic').hasPrimaryFocus, isTrue);

    await pumpHero(
      tester,
      HeroToggleButtonGroup(orientation: Axis.vertical, children: formatting()),
    );
    focusOf('bold').requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(focusOf('italic').hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(focusOf('bold').hasPrimaryFocus, isTrue);
  });

  testWidgets('single selection exposes a radio group', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      HeroToggleButtonGroup(
        semanticLabel: 'Text formatting',
        defaultSelectedKeys: const <Object>{'bold'},
        children: formatting(),
      ),
    );
    expect(
      tester.getSemantics(button('bold')),
      matchesSemantics(
        label: 'bold',
        hasCheckedState: true,
        isChecked: true,
        isInMutuallyExclusiveGroup: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    final SemanticsNode group = tester.getSemantics(
      find.byType(HeroToggleButtonGroup),
    );
    expect(group.label, 'Text formatting');
    expect(group.role, SemanticsRole.radioGroup);
    handle.dispose();
  });

  testWidgets('multiple selection exposes toggle buttons', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      HeroToggleButtonGroup(
        selectionMode: HeroSelectionMode.multiple,
        defaultSelectedKeys: const <Object>{'italic'},
        children: formatting(),
      ),
    );
    expect(
      tester.getSemantics(button('italic')),
      matchesSemantics(
        label: 'italic',
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

  testWidgets('text scale 2.0 lays out without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 360,
        child: HeroToggleButtonGroup(
          fullWidth: true,
          children: <Widget>[
            HeroToggleButton(
              id: 'left',
              startContent: HeroIcon(HeroIcons.textAlignLeft),
              child: Text('Left'),
            ),
            HeroToggleButton(
              id: 'center',
              separator: HeroToggleButtonGroupSeparator(),
              startContent: HeroIcon(HeroIcons.textAlignCenter),
              child: Text('Center'),
            ),
            HeroToggleButton(
              id: 'right',
              separator: HeroToggleButtonGroupSeparator(),
              startContent: HeroIcon(HeroIcons.textAlignRight),
              child: Text('Right'),
            ),
          ],
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
