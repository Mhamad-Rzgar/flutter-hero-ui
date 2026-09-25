import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

HeroToggleButtonGroup _textStyle({Axis? orientation}) => HeroToggleButtonGroup(
  selectionMode: HeroSelectionMode.multiple,
  orientation: orientation,
  semanticLabel: 'Text style',
  children: const <Widget>[
    HeroToggleButton(
      id: 'bold',
      isIconOnly: true,
      semanticLabel: 'Bold',
      child: HeroIcon(HeroIcons.bold),
    ),
    HeroToggleButton(
      id: 'italic',
      isIconOnly: true,
      semanticLabel: 'Italic',
      separator: HeroToggleButtonGroupSeparator(),
      child: HeroIcon(HeroIcons.italic),
    ),
    HeroToggleButton(
      id: 'underline',
      isIconOnly: true,
      semanticLabel: 'Underline',
      separator: HeroToggleButtonGroupSeparator(),
      child: HeroIcon(HeroIcons.underline),
    ),
  ],
);

HeroButtonGroup _clipboard({bool cutDisabled = false}) => HeroButtonGroup(
  variant: HeroButtonVariant.tertiary,
  children: <Widget>[
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Copy',
      onPressed: () {},
      child: const HeroIcon(HeroIcons.copy),
    ),
    const HeroButtonGroupSeparator(),
    HeroButton(
      isIconOnly: true,
      semanticLabel: 'Cut',
      isDisabled: cutDisabled,
      onPressed: () {},
      child: const HeroIcon(HeroIcons.scissors),
    ),
  ],
);

HeroToolbar _toolbar({
  Axis orientation = Axis.horizontal,
  bool isAttached = false,
  bool cutDisabled = false,
}) => HeroToolbar(
  orientation: orientation,
  isAttached: isAttached,
  semanticLabel: 'Text formatting',
  children: <Widget>[
    _textStyle(),
    const HeroSeparator(),
    _clipboard(cutDisabled: cutDisabled),
  ],
);

/// A toolbar between two plain buttons, to check Tab traversal.
Widget _between(Widget toolbar) => Column(
  mainAxisSize: MainAxisSize.min,
  spacing: 16,
  children: <Widget>[
    HeroButton(onPressed: () {}, child: const Text('Before')),
    toolbar,
    HeroButton(onPressed: () {}, child: const Text('After')),
  ],
);

/// The label of the control that has the primary focus.
String? _focused() {
  final BuildContext? context = FocusManager.instance.primaryFocus?.context;
  if (context == null) return null;
  final HeroToggleButton? toggle = context
      .findAncestorWidgetOfExactType<HeroToggleButton>();
  if (toggle != null) return toggle.semanticLabel;
  final HeroButton? button = context
      .findAncestorWidgetOfExactType<HeroButton>();
  if (button == null) return null;
  if (button.semanticLabel != null) return button.semanticLabel;
  final Widget? child = button.child;
  return child is Text ? child.data : null;
}

Future<void> _press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lays controls out in a row with centered half separators', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _toolbar(), surfaceSize: const Size(400, 300));
    final Rect toolbar = tester.getRect(find.byType(HeroToolbar));
    final Rect toggles = tester.getRect(find.byType(HeroToggleButtonGroup));
    final Rect separator = tester.getRect(find.byType(HeroSeparator));
    final Rect buttons = tester.getRect(find.byType(HeroButtonGroup));
    expect(toggles.size, const Size(120, 40));
    expect(toolbar.size, const Size(120 + 8 + 1 + 8 + 80, 40));
    expect(separator.left, toggles.right + 8);
    expect(buttons.left, separator.right + 8);
    expect(separator.height, 20);
    expect(separator.center.dy, toolbar.center.dy);
  });

  testWidgets('vertical toolbars stack groups and flip separators', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _toolbar(orientation: Axis.vertical),
      surfaceSize: const Size(400, 400),
    );
    final Rect toolbar = tester.getRect(find.byType(HeroToolbar));
    final Rect toggles = tester.getRect(find.byType(HeroToggleButtonGroup));
    final Rect separator = tester.getRect(find.byType(HeroSeparator));
    final Rect buttons = tester.getRect(find.byType(HeroButtonGroup));
    // Both groups take the toolbar's orientation.
    expect(toggles.size, const Size(40, 120));
    expect(buttons.size, const Size(40, 80));
    expect(separator.size, const Size(20, 1));
    expect(separator.center.dx, toolbar.center.dx);
    expect(separator.top, toggles.bottom + 8);
    expect(buttons.top, separator.bottom + 8);
    expect(toolbar.size, const Size(40, 120 + 8 + 1 + 8 + 80));
  });

  testWidgets('an explicit group orientation wins', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroToolbar(
        orientation: Axis.vertical,
        children: <Widget>[_textStyle(orientation: Axis.horizontal)],
      ),
      surfaceSize: const Size(400, 300),
    );
    expect(
      tester.getSize(find.byType(HeroToggleButtonGroup)),
      const Size(120, 40),
    );
  });

  testWidgets('attached toolbars sit on a padded surface pill', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _toolbar(isAttached: true),
      surfaceSize: const Size(400, 300),
    );
    final Rect toolbar = tester.getRect(find.byType(HeroToolbar));
    final Rect toggles = tester.getRect(find.byType(HeroToggleButtonGroup));
    expect(toggles.topLeft - toolbar.topLeft, const Offset(4, 4));
    expect(toolbar.size, const Size(217 + 8, 48));
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(HeroToolbar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final ShapeDecoration decoration = box.decoration as ShapeDecoration;
    final HeroThemeData theme = HeroThemeData.light();
    expect(decoration.color, theme.colors.surface);
    expect(decoration.shadows, theme.shadows.overlay.boxShadows);
  });

  testWidgets('is one Tab stop with arrow key navigation', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _between(_toolbar()),
      surfaceSize: const Size(400, 400),
    );
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focused(), 'Before');
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focused(), 'Bold');
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Italic');
    await _press(tester, LogicalKeyboardKey.arrowRight);
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Copy');
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Cut');
    // No wrapping at the ends.
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Cut');
    await _press(tester, LogicalKeyboardKey.arrowLeft);
    expect(_focused(), 'Copy');
    await _press(tester, LogicalKeyboardKey.home);
    expect(_focused(), 'Bold');
    await _press(tester, LogicalKeyboardKey.end);
    expect(_focused(), 'Cut');

    // Tab leaves the toolbar; Shift+Tab returns to the control focused last.
    await _press(tester, LogicalKeyboardKey.arrowLeft);
    expect(_focused(), 'Copy');
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focused(), 'After');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focused(), 'Copy');
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focused(), 'Before');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
  });

  testWidgets('toggles still toggle from the keyboard', (
    WidgetTester tester,
  ) async {
    Set<Object>? selection;
    await pumpHero(
      tester,
      HeroToolbar(
        children: <Widget>[
          HeroToggleButtonGroup(
            selectionMode: HeroSelectionMode.multiple,
            onSelectionChanged: (Set<Object> keys) => selection = keys,
            children: const <Widget>[
              HeroToggleButton(
                id: 'bold',
                isIconOnly: true,
                semanticLabel: 'Bold',
                child: HeroIcon(HeroIcons.bold),
              ),
              HeroToggleButton(
                id: 'italic',
                isIconOnly: true,
                semanticLabel: 'Italic',
                child: HeroIcon(HeroIcons.italic),
              ),
            ],
          ),
        ],
      ),
    );
    await _press(tester, LogicalKeyboardKey.tab);
    await _press(tester, LogicalKeyboardKey.arrowRight);
    await _press(tester, LogicalKeyboardKey.space);
    expect(selection, <Object>{'italic'});
  });

  testWidgets('skips disabled controls', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _toolbar(cutDisabled: true),
      surfaceSize: const Size(400, 300),
    );
    await _press(tester, LogicalKeyboardKey.tab);
    await _press(tester, LogicalKeyboardKey.end);
    expect(_focused(), 'Copy');
  });

  testWidgets('arrows follow the screen in right-to-left layouts', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _toolbar(),
      textDirection: TextDirection.rtl,
      surfaceSize: const Size(400, 300),
    );
    final Rect bold = tester.getRect(find.byType(HeroToggleButton).first);
    final Rect copy = tester.getRect(find.byType(HeroButton).first);
    expect(bold.left, greaterThan(copy.left));
    await _press(tester, LogicalKeyboardKey.tab);
    expect(_focused(), 'Bold');
    await _press(tester, LogicalKeyboardKey.arrowLeft);
    expect(_focused(), 'Italic');
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Bold');
    await _press(tester, LogicalKeyboardKey.end);
    expect(_focused(), 'Cut');
    await _press(tester, LogicalKeyboardKey.home);
    expect(_focused(), 'Bold');
  });

  testWidgets('vertical toolbars use Up and Down', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _toolbar(orientation: Axis.vertical),
      surfaceSize: const Size(400, 400),
    );
    await _press(tester, LogicalKeyboardKey.tab);
    await _press(tester, LogicalKeyboardKey.arrowDown);
    expect(_focused(), 'Italic');
    await _press(tester, LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Italic');
    await _press(tester, LogicalKeyboardKey.arrowUp);
    expect(_focused(), 'Bold');
  });

  testWidgets('builder receives the orientation', (WidgetTester tester) async {
    Axis? seen;
    await pumpHero(
      tester,
      HeroToolbar(
        orientation: Axis.vertical,
        builder: (BuildContext context, Axis orientation) {
          seen = orientation;
          return <Widget>[_clipboard()];
        },
      ),
    );
    expect(seen, Axis.vertical);
    expect(find.byType(HeroButton), findsNWidgets(2));
  });

  testWidgets('custom gap, padding and decoration', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroToolbar(
        gap: 4,
        padding: const EdgeInsets.all(6),
        decoration: const ShapeDecoration(
          color: Color(0xFFEEEEEE),
          shape: RoundedRectangleBorder(),
        ),
        children: <Widget>[_clipboard(), _clipboard()],
      ),
    );
    final Rect toolbar = tester.getRect(find.byType(HeroToolbar));
    final Rect first = tester.getRect(find.byType(HeroButtonGroup).first);
    final Rect second = tester.getRect(find.byType(HeroButtonGroup).last);
    expect(first.topLeft - toolbar.topLeft, const Offset(6, 6));
    expect(second.left, first.right + 4);
  });

  testWidgets('toggle groups accept a custom gap', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroToolbar(
        children: <Widget>[
          HeroToggleButtonGroup(
            gap: 2,
            children: <Widget>[
              HeroToggleButton(id: 'a', child: Text('A')),
              HeroToggleButton(id: 'b', child: Text('B')),
            ],
          ),
        ],
      ),
    );
    final Rect a = tester.getRect(find.byType(HeroToggleButton).first);
    final Rect b = tester.getRect(find.byType(HeroToggleButton).last);
    expect(b.left, a.right + 2);
  });

  testWidgets('is labelled for assistive technologies', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, _toolbar(), surfaceSize: const Size(400, 300));
    expect(find.bySemanticsLabel('Text formatting'), findsOneWidget);
    expect(find.bySemanticsLabel('Bold'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('keeps its layout at 2x text', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroToolbar(
        children: <Widget>[
          HeroButtonGroup(
            variant: HeroButtonVariant.tertiary,
            children: <Widget>[
              HeroButton(onPressed: () {}, child: const Text('Undo')),
              HeroButton(onPressed: () {}, child: const Text('Redo')),
            ],
          ),
          const HeroSeparator(),
          _clipboard(),
        ],
      ),
      textScale: 2,
      surfaceSize: const Size(500, 300),
    );
    expect(tester.takeException(), isNull);
  });
}
