import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<String> _names = <String>['Bob', 'Fred', 'Martha'];

List<Widget> _items({
  Set<String> disabled = const <String>{},
  bool indicator = true,
}) => <Widget>[
  for (final String name in _names)
    HeroListBoxItem(
      id: name.toLowerCase(),
      label: name,
      description: '${name.toLowerCase()}@heroui.com',
      isDisabled: disabled.contains(name.toLowerCase()),
      indicator: indicator ? const HeroListBoxItemIndicator() : null,
    ),
];

Future<void> _tabInto(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();
}

void main() {
  final HeroColors colors = HeroThemeData.light().colors;

  testWidgets('renders items with HeroUI geometry', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(semanticLabel: 'Users', children: _items()),
      ),
    );
    final Rect list = tester.getRect(find.byType(HeroListBox));
    final Rect first = tester.getRect(find.byType(HeroListBoxItem).first);
    final Rect second = tester.getRect(find.byType(HeroListBoxItem).at(1));
    expect(list.width, 220);
    // `p-1` around the items and `mt-1` between them.
    expect(first.left - list.left, 4);
    expect(first.top - list.top, 4);
    expect(first.width, 212);
    expect(second.top - first.bottom, 4);
    // Label (20) + description (16) + `py-1.5`.
    expect(first.height, 48);
    // `px-2`, and `pe-7` for the indicator.
    expect(tester.getTopLeft(find.text('Bob')).dx - first.left, 8);
    final Rect indicator = tester.getRect(
      find.byType(HeroListBoxItemIndicator).first,
    );
    expect(indicator.size, const Size(16, 16));
    expect(first.right - indicator.right, 8);
    expect(indicator.center.dy, first.center.dy);
    final TextStyle label = tester
        .renderObject<RenderParagraph>(find.text('Bob'))
        .text
        .style!;
    expect(label.fontSize, 14);
    expect(label.fontWeight, FontWeight.w500);
    expect(label.color, colors.foreground);
  });

  testWidgets('a plain item is at least 36 tall with text-sm content', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        child: HeroListBox(
          children: <Widget>[HeroListBoxItem(id: 'a', child: Text('Apple'))],
        ),
      ),
    );
    expect(tester.getSize(find.byType(HeroListBoxItem)).height, 36);
    final TextStyle style = tester
        .renderObject<RenderParagraph>(find.text('Apple'))
        .text
        .style!;
    expect(style.fontSize, 14);
  });

  testWidgets('fills the width it is given and sizes to content otherwise', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroListBox(
            children: <Widget>[HeroListBoxItem(id: 'a', child: Text('Apple'))],
          ),
        ],
      ),
    );
    final double width = tester.getSize(find.byType(HeroListBox)).width;
    expect(width, lessThan(120));
    expect(width, greaterThan(40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('single selection: press selects, replaces and deselects', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    final List<Object> actions = <Object>[];
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          onSelectionChanged: changes.add,
          onAction: actions.add,
          children: _items(),
        ),
      ),
    );
    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fred'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fred'));
    await tester.pumpAndSettle();
    expect(changes, <Set<Object>>[
      <Object>{'bob'},
      <Object>{'fred'},
      <Object>{},
    ]);
    expect(actions, <Object>['bob', 'fred', 'fred']);
  });

  testWidgets('disallowEmptySelection keeps the selected item', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          defaultSelectedKeys: const <Object>{'bob'},
          disallowEmptySelection: true,
          onSelectionChanged: changes.add,
          children: _items(),
        ),
      ),
    );
    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });

  testWidgets('multiple selection toggles and Shift-press extends', (
    WidgetTester tester,
  ) async {
    Set<Object> selection = <Object>{};
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.multiple,
          onSelectionChanged: (Set<Object> keys) => selection = keys,
          children: _items(),
        ),
      ),
    );
    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Martha'));
    await tester.pumpAndSettle();
    expect(selection, <Object>{'bob', 'martha'});
    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();
    expect(selection, <Object>{'martha'});

    await tester.tap(find.text('Bob'));
    await tester.pumpAndSettle();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.tap(find.text('Fred'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'bob', 'fred', 'martha'});
  });

  testWidgets('controlled selection follows selectedKeys', (
    WidgetTester tester,
  ) async {
    Set<Object> selected = <Object>{'bob'};
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 220,
              child: HeroListBox(
                selectionMode: HeroSelectionMode.multiple,
                selectedKeys: selected,
                onSelectionChanged: (Set<Object> keys) =>
                    setState(() => selected = keys),
                children: _items(),
              ),
            ),
            Text('Selected: ${selected.join(', ')}'),
          ],
        ),
      ),
    );
    expect(find.text('Selected: bob'), findsOneWidget);
    await tester.tap(find.text('Fred'));
    await tester.pumpAndSettle();
    expect(find.text('Selected: bob, fred'), findsOneWidget);
  });

  testWidgets('a controlled list ignores presses without an update', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          selectedKeys: const <Object>{'bob'},
          children: _items(),
        ),
      ),
    );
    await tester.tap(find.text('Fred'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(HeroListBoxItem).first),
      isSemantics(isSelected: true),
    );
    expect(
      tester.getSemantics(find.byType(HeroListBoxItem).at(1)),
      isNot(isSemantics(isSelected: true)),
    );
    handle.dispose();
  });

  testWidgets('selectionMode none runs actions only', (
    WidgetTester tester,
  ) async {
    final List<Object> actions = <Object>[];
    int itemActions = 0;
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          onAction: actions.add,
          onSelectionChanged: (_) => fail('no selection in none mode'),
          children: <Widget>[
            HeroListBoxItem(
              id: 'new',
              label: 'New file',
              onAction: () => itemActions++,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('New file'));
    await tester.pumpAndSettle();
    expect(actions, <Object>['new']);
    expect(itemActions, 1);
  });

  testWidgets('disabled items and disabledKeys ignore presses', (
    WidgetTester tester,
  ) async {
    final List<Object> actions = <Object>[];
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          disabledKeys: const <Object>{'fred'},
          onAction: actions.add,
          children: _items(disabled: <String>{'martha'}),
        ),
      ),
    );
    await tester.tap(find.text('Fred'));
    await tester.tap(find.text('Martha'));
    await tester.pumpAndSettle();
    expect(actions, isEmpty);
    Finder faded(String name) => find.ancestor(
      of: find.text(name),
      matching: find.byWidgetPredicate(
        (Widget w) => w is HeroDisabledOpacity && w.disabled,
      ),
    );
    expect(faded('Fred'), findsOneWidget);
    expect(faded('Martha'), findsOneWidget);
    expect(faded('Bob'), findsNothing);
  });

  testWidgets('hover fills the item with --default', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(children: _items(indicator: false)),
      ),
    );
    ShapeDecoration fill() =>
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(HeroListBoxItem).first,
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as ShapeDecoration;
    expect(fill().color, isNull);
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(find.text('Bob')));
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    expect(fill().color, colors.defaultColor);
  });

  testWidgets('pressing scales the item to 0.98', (WidgetTester tester) async {
    await pumpHero(
      tester,
      SizedBox(width: 220, child: HeroListBox(children: _items())),
    );
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.text('Bob')),
    );
    await tester.pumpAndSettle();
    final AnimatedScale scale = tester.widget<AnimatedScale>(
      find
          .descendant(
            of: find.byType(HeroListBoxItem).first,
            matching: find.byType(AnimatedScale),
          )
          .first,
    );
    expect(scale.scale, 0.98);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('keyboard: Tab focuses the selected item, arrows move, '
      'Enter and Space select', (WidgetTester tester) async {
    Set<Object> selection = <Object>{'fred'};
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.multiple,
          defaultSelectedKeys: selection,
          onSelectionChanged: (Set<Object> keys) => selection = keys,
          children: _items(),
        ),
      ),
    );
    await _tabInto(tester);
    HeroFocusRing ring(String name) => tester.widget<HeroFocusRing>(
      find
          .ancestor(of: find.text(name), matching: find.byType(HeroFocusRing))
          .first,
    );
    expect(ring('Fred').visible, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(ring('Fred').visible, isFalse);
    expect(ring('Martha').visible, isTrue);
    // No wrapping at the end.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(ring('Martha').visible, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'fred', 'martha'});
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(ring('Bob').visible, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'fred', 'martha', 'bob'});
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(ring('Martha').visible, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(selection, isEmpty);
  });

  testWidgets('keyboard skips disabled items and wraps when asked', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          shouldFocusWrap: true,
          children: _items(disabled: <String>{'fred'}),
        ),
      ),
    );
    await _tabInto(tester);
    bool focused(String name) => tester
        .widget<HeroFocusRing>(
          find
              .ancestor(
                of: find.text(name),
                matching: find.byType(HeroFocusRing),
              )
              .first,
        )
        .visible;
    expect(focused('Bob'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(focused('Martha'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(focused('Bob'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(focused('Martha'), isTrue);
  });

  testWidgets('Shift+arrows extend and Ctrl+A selects all', (
    WidgetTester tester,
  ) async {
    Set<Object> selection = <Object>{};
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.multiple,
          onSelectionChanged: (Set<Object> keys) => selection = keys,
          children: _items(),
        ),
      ),
    );
    await _tabInto(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'bob', 'fred', 'martha'});
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'bob', 'fred'});
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'bob', 'fred', 'martha'});
  });

  testWidgets('typeahead focuses the matching item', (
    WidgetTester tester,
  ) async {
    Set<Object> selection = <Object>{};
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          onSelectionChanged: (Set<Object> keys) => selection = keys,
          children: const <Widget>[
            HeroListBoxItem(id: 'apple', child: Text('Apple')),
            HeroListBoxItem(id: 'banana', child: Text('Banana')),
            HeroListBoxItem(id: 'blueberry', textValue: 'Blueberry'),
          ],
        ),
      ),
    );
    await _tabInto(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'blueberry'});
    // The search starts over after a second without typing.
    await tester.pump(const Duration(seconds: 2));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    // Space during a search is part of the search, not a selection key.
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'blueberry'});
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selection, <Object>{'apple'});
  });

  testWidgets('keyboard focus in a scrolling list reveals the item', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        height: 120,
        child: HeroListBox(
          children: <Widget>[
            for (int i = 0; i < 20; i++)
              HeroListBoxItem(id: i, child: Text('Item $i')),
          ],
        ),
      ),
    );
    await _tabInto(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    final Rect list = tester.getRect(find.byType(HeroListBox));
    final Rect last = tester.getRect(find.text('Item 19'));
    expect(last.bottom, lessThanOrEqualTo(list.bottom));
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Item 19')).top, greaterThan(list.top));
  });

  testWidgets('sections: header, items without gap, separator at 94%', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        child: HeroListBox(
          children: <Widget>[
            HeroListBoxSection(
              header: HeroHeader.text('Actions'),
              children: <Widget>[
                HeroListBoxItem(id: 'new', child: Text('New')),
                HeroListBoxItem(id: 'edit', child: Text('Edit')),
              ],
            ),
            HeroSeparator(),
            HeroListBoxSection(
              children: <Widget>[
                HeroHeader.text('Danger zone'),
                HeroListBoxItem(id: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
    final Rect header = tester.getRect(find.byType(HeroHeader).first);
    final Rect first = tester.getRect(find.byType(HeroListBoxItem).first);
    final Rect second = tester.getRect(find.byType(HeroListBoxItem).at(1));
    expect(header.height, 26);
    expect(first.top, header.bottom);
    expect(second.top, first.bottom);
    final TextStyle style = tester
        .renderObject<RenderParagraph>(find.text('Actions'))
        .text
        .style!;
    expect(style.fontSize, 12);
    expect(style.fontWeight, FontWeight.w500);
    expect(style.color, colors.muted);
    expect(tester.getTopLeft(find.text('Actions')).dx - header.left, 8);
    expect(
      tester.getSemantics(find.text('Actions')),
      isSemantics(isHeader: true),
    );
    final RenderHeroSeparator line = tester.renderObject(
      find.byType(HeroSeparator),
    );
    expect(line.lengthFactor, 0.94);
    handle.dispose();
  });

  testWidgets('danger variant colors the label and the indicator', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          defaultSelectedKeys: <Object>{'delete'},
          children: <Widget>[
            HeroListBoxItem(
              id: 'delete',
              variant: HeroListBoxVariant.danger,
              label: 'Delete',
              description: 'Move to trash',
              indicator: HeroListBoxItemIndicator(),
            ),
          ],
        ),
      ),
    );
    TextStyle styleOf(String text) =>
        tester.renderObject<RenderParagraph>(find.text(text)).text.style!;
    expect(styleOf('Delete').color, colors.danger);
    expect(styleOf('Move to trash').color, colors.muted);
    final BuildContext indicator = tester.element(
      find.descendant(
        of: find.byType(HeroListBoxItemIndicator),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(IconTheme.of(indicator).color, colors.danger);
  });

  testWidgets('the root variant is the default of its items', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        child: HeroListBox(
          variant: HeroListBoxVariant.danger,
          children: <Widget>[HeroListBoxItem(id: 'a', label: 'Remove')],
        ),
      ),
    );
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('Remove'))
          .text
          .style!
          .color,
      colors.danger,
    );
  });

  testWidgets('checkmark strokes in when selected and out when deselected', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          children: _items(),
        ),
      ),
    );
    double progress() => tester
        .widget<TweenAnimationBuilder<double>>(
          find
              .descendant(
                of: find.byType(HeroListBoxItemIndicator).first,
                matching: find.byType(TweenAnimationBuilder<double>),
              )
              .first,
        )
        .tween
        .end!;
    expect(progress(), 0);
    await tester.tap(find.text('Bob'));
    await tester.pump();
    expect(progress(), 1);
    final TweenAnimationBuilder<double> builder = tester
        .widget<TweenAnimationBuilder<double>>(
          find
              .descendant(
                of: find.byType(HeroListBoxItemIndicator).first,
                matching: find.byType(TweenAnimationBuilder<double>),
              )
              .first,
        );
    expect(builder.duration, const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  });

  testWidgets('animateIndicator: false switches the checkmark instantly', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          animateIndicator: false,
          children: _items(),
        ),
      ),
    );
    final TweenAnimationBuilder<double> builder = tester
        .widget<TweenAnimationBuilder<double>>(
          find
              .descendant(
                of: find.byType(HeroListBoxItemIndicator).first,
                matching: find.byType(TweenAnimationBuilder<double>),
              )
              .first,
        );
    expect(builder.duration, Duration.zero);
  });

  testWidgets('custom indicator and item builder receive the state', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.multiple,
          defaultSelectedKeys: const <Object>{'a'},
          children: <Widget>[
            for (final String id in <String>['a', 'b'])
              HeroListBoxItem(
                id: id,
                builder: (BuildContext context, HeroListBoxItemState state) =>
                    Text('$id ${state.isSelected ? 'on' : 'off'}'),
                indicator: HeroListBoxItemIndicator(
                  builder: (BuildContext context, bool isSelected) =>
                      isSelected ? const Text('✓') : null,
                ),
              ),
          ],
        ),
      ),
    );
    expect(find.text('a on'), findsOneWidget);
    expect(find.text('b off'), findsOneWidget);
    expect(find.text('✓'), findsOneWidget);
    await tester.tap(find.text('b off'));
    await tester.pumpAndSettle();
    expect(find.text('b on'), findsOneWidget);
    expect(find.text('✓'), findsNWidgets(2));
  });

  testWidgets('item style overrides background per state', (
    WidgetTester tester,
  ) async {
    const Color selectedColor = Color(0xFF00FF00);
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          defaultSelectedKeys: const <Object>{'bob'},
          itemStyle: HeroListBoxItemStyle(
            borderRadius: BorderRadius.circular(8),
            backgroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) =>
                  states.contains(WidgetState.selected) ? selectedColor : null,
            ),
          ),
          children: _items(),
        ),
      ),
    );
    final ShapeDecoration decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(HeroListBoxItem).first,
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as ShapeDecoration;
    expect(decoration.color, selectedColor);
  });

  testWidgets('empty state replaces the items', (WidgetTester tester) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          emptyStateBuilder: (BuildContext context) => const HeroEmptyState(),
        ),
      ),
    );
    expect(find.text('No results found'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(HeroEmptyState)) -
          tester.getTopLeft(find.byType(HeroListBox)),
      const Offset(4, 4),
    );
  });

  testWidgets('HeroCollection and builder build items from data', (
    WidgetTester tester,
  ) async {
    final List<Object> actions = <Object>[];
    await pumpHero(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: HeroListBox(
              onAction: actions.add,
              children: <Widget>[
                const HeroListBoxItem(id: 'first', child: Text('First')),
                HeroCollection<String>(
                  items: const <String>['x', 'y'],
                  itemBuilder: (BuildContext context, String item) =>
                      HeroListBoxItem(id: item, child: Text('Item $item')),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: HeroListBox.builder(
              onAction: actions.add,
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) =>
                  HeroListBoxItem(id: index, child: Text('Row $index')),
            ),
          ),
        ],
      ),
    );
    expect(
      tester.getTopLeft(find.text('Item y')).dy -
          tester.getTopLeft(find.text('Item x')).dy,
      40,
    );
    await tester.tap(find.text('Item y'));
    await tester.tap(find.text('Row 1'));
    await tester.pumpAndSettle();
    expect(actions, <Object>['y', 1]);
  });

  testWidgets('virtualized lists build only visible rows', (
    WidgetTester tester,
  ) async {
    Set<Object> selection = <Object>{};
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 400,
        child: HeroListBox.builder(
          semanticLabel: 'Users',
          virtualized: true,
          rowHeight: 50,
          selectionMode: HeroSelectionMode.single,
          onSelectionChanged: (Set<Object> keys) => selection = keys,
          itemCount: 1000,
          itemBuilder: (BuildContext context, int index) => HeroListBoxItem(
            id: index,
            label: 'User $index',
            description: 'user$index@acme.com',
          ),
        ),
      ),
    );
    expect(find.byType(HeroListBoxItem).evaluate().length, lessThan(20));
    expect(
      tester.getTopLeft(find.text('User 1')).dy -
          tester.getTopLeft(find.text('User 0')).dy,
      50,
    );
    await _tabInto(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(find.text('User 999'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selection, <Object>{999});
    final Rect list = tester.getRect(find.byType(HeroListBox));
    expect(
      tester.getRect(find.text('User 999')).bottom,
      lessThanOrEqualTo(list.bottom),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('User 0'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    expect(find.text('User 7'), findsOneWidget);
  });

  testWidgets('load more fires near the end and shows a spinner', (
    WidgetTester tester,
  ) async {
    int count = 10;
    bool loading = false;
    int loads = 0;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SizedBox(
          width: 220,
          height: 200,
          child: HeroListBox(
            children: <Widget>[
              for (int i = 0; i < count; i++)
                HeroListBoxItem(id: i, child: Text('Item $i')),
              HeroListBoxLoadMoreItem(
                isLoading: loading,
                onLoadMore: () {
                  loads++;
                  setState(() => loading = true);
                },
              ),
            ],
          ),
        ),
      ),
    );
    // 10 rows of 40 do not fit twice in 200: the sentinel is not near yet.
    expect(loads, 0);
    await tester.drag(find.byType(HeroListBox), const Offset(0, -300));
    await tester.pump();
    await tester.pump();
    expect(loads, 1);
    expect(find.byType(HeroSpinner), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    count = 20;
  });

  testWidgets('controller drives a virtual focus', (WidgetTester tester) async {
    final HeroListBoxController controller = HeroListBoxController();
    addTearDown(controller.dispose);
    Set<Object> selection = <Object>{};
    int notifications = 0;
    controller.addListener(() => notifications++);
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          selectionMode: HeroSelectionMode.single,
          shouldUseVirtualFocus: true,
          controller: controller,
          onSelectionChanged: (Set<Object> keys) => selection = keys,
          children: _items(),
        ),
      ),
    );
    controller.focusFirst();
    await tester.pump();
    expect(controller.focusedKey, 'bob');
    expect(
      controller.handleKeyEvent(
        const KeyDownEvent(
          physicalKey: PhysicalKeyboardKey.arrowDown,
          logicalKey: LogicalKeyboardKey.arrowDown,
          timeStamp: Duration.zero,
        ),
      ),
      KeyEventResult.handled,
    );
    await tester.pump();
    expect(controller.focusedKey, 'fred');
    controller.activateFocused();
    await tester.pump();
    expect(selection, <Object>{'fred'});
    controller.focusLast();
    await tester.pump();
    expect(controller.focusedKey, 'martha');
    expect(notifications, 3);
  });

  testWidgets('shouldFocusOnHover focuses the hovered item', (
    WidgetTester tester,
  ) async {
    final HeroListBoxController controller = HeroListBoxController();
    addTearDown(controller.dispose);
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          shouldFocusOnHover: true,
          controller: controller,
          children: _items(),
        ),
      ),
    );
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(find.text('Martha')));
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    expect(controller.focusedKey, 'martha');
  });

  testWidgets('semantics: list, labelled selectable items', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      SizedBox(
        width: 220,
        child: HeroListBox(
          semanticLabel: 'Users',
          selectionMode: HeroSelectionMode.single,
          defaultSelectedKeys: const <Object>{'bob'},
          disabledKeys: const <Object>{'martha'},
          children: _items(),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Users'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(HeroListBoxItem).first),
      matchesSemantics(
        label: 'Bob\nbob@heroui.com',
        isButton: true,
        isSelected: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        hasTapAction: true,
        hasSelectedState: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(HeroListBoxItem).last),
      isSemantics(isEnabled: false, isFocusable: false),
    );
    handle.dispose();
  });

  testWidgets('RTL mirrors padding and the indicator', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(width: 220, child: HeroListBox(children: _items())),
      textDirection: TextDirection.rtl,
    );
    final Rect item = tester.getRect(find.byType(HeroListBoxItem).first);
    final Rect indicator = tester.getRect(
      find.byType(HeroListBoxItemIndicator).first,
    );
    expect(indicator.left - item.left, 8);
    expect(item.right - tester.getTopRight(find.text('Bob')).dx, 8);
  });

  testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 220,
            child: HeroListBox(
              children: <Widget>[
                ..._items(),
                const HeroListBoxItem(
                  id: 'kbd',
                  label: 'New file',
                  endContent: HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command]),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 220,
            height: 200,
            child: HeroListBox.builder(
              virtualized: true,
              itemCount: 30,
              itemBuilder: (BuildContext context, int index) => HeroListBoxItem(
                id: index,
                label: 'User $index',
                description: 'Description',
              ),
            ),
          ),
        ],
      ),
      textScale: 2,
      surfaceSize: const Size(800, 1200),
    );
    expect(tester.takeException(), isNull);
  });
}
