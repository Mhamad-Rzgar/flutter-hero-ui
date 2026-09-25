import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<String> _names = <String>['News', 'Travel', 'Gaming'];

List<Widget> _tags({Set<String> disabled = const <String>{}}) => <Widget>[
  for (final String name in _names)
    HeroTag(
      id: name.toLowerCase(),
      label: name,
      isDisabled: disabled.contains(name.toLowerCase()),
    ),
];

ShapeDecoration _decoration(WidgetTester tester, String label) =>
    tester
            .widget<AnimatedContainer>(
              find
                  .ancestor(
                    of: find.text(label),
                    matching: find.byType(AnimatedContainer),
                  )
                  .first,
            )
            .decoration!
        as ShapeDecoration;

bool _ringVisible(WidgetTester tester, String label) => tester
    .widget<HeroFocusRing>(
      find
          .ancestor(of: find.text(label), matching: find.byType(HeroFocusRing))
          .first,
    )
    .visible;

void main() {
  final HeroColors colors = HeroThemeData.light().colors;

  testWidgets('renders tags with HeroUI geometry per size', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final HeroSize size in HeroSize.values)
            HeroTagGroup(
              size: size,
              children: <Widget>[
                HeroTagGroupList(
                  children: <Widget>[
                    HeroTag(id: size.name, label: 'Tag ${size.name}'),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
    Size sizeOf(String name) => tester.getSize(
      find
          .ancestor(
            of: find.text('Tag $name'),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    expect(sizeOf('sm').height, 20);
    expect(sizeOf('md').height, 24);
    expect(sizeOf('lg').height, 32);
    final TextStyle md = tester
        .renderObject<RenderParagraph>(find.text('Tag md'))
        .text
        .style!;
    expect(md.fontSize, 12);
    expect(md.fontWeight, FontWeight.w500);
    expect(md.color, colors.defaultForeground);
    final TextStyle lg = tester
        .renderObject<RenderParagraph>(find.text('Tag lg'))
        .text
        .style!;
    expect(lg.fontSize, 14);
    expect(
      tester.getTopLeft(find.text('Tag md')).dx -
          tester
              .getTopLeft(
                find
                    .ancestor(
                      of: find.text('Tag md'),
                      matching: find.byType(AnimatedContainer),
                    )
                    .first,
              )
              .dx,
      8,
    );
    expect(_decoration(tester, 'Tag md').color, colors.defaultColor);
  });

  testWidgets('list wraps with a 6 px gap and the group has a label', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 140,
        child: HeroTagGroup(
          label: 'Categories',
          children: <Widget>[HeroTagGroupList(children: _tags())],
        ),
      ),
    );
    final Rect news = tester.getRect(
      find
          .ancestor(of: find.text('News'), matching: find.byType(HeroTag))
          .first,
    );
    final Rect travel = tester.getRect(
      find
          .ancestor(of: find.text('Travel'), matching: find.byType(HeroTag))
          .first,
    );
    final Rect gaming = tester.getRect(
      find
          .ancestor(of: find.text('Gaming'), matching: find.byType(HeroTag))
          .first,
    );
    expect(travel.left - news.right, 6);
    expect(gaming.top - news.bottom, 6);
    expect(news.top - tester.getRect(find.text('Categories')).bottom, 4);
  });

  testWidgets('single selection toggles and replaces', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    await pumpHero(
      tester,
      HeroTagGroup(
        selectionMode: HeroSelectionMode.single,
        onSelectionChanged: changes.add,
        children: <Widget>[HeroTagGroupList(children: _tags())],
      ),
    );
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(_decoration(tester, 'News').color, colors.accentSoft);
    final TextStyle style = tester
        .renderObject<RenderParagraph>(find.text('News'))
        .text
        .style!;
    expect(style.color, colors.accentSoftForeground);
    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();
    expect(changes, <Set<Object>>[
      <Object>{'news'},
      <Object>{'travel'},
      <Object>{},
    ]);
  });

  testWidgets('multiple selection, controlled', (WidgetTester tester) async {
    Set<Object> selected = <Object>{'news'};
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => HeroTagGroup(
          selectionMode: HeroSelectionMode.multiple,
          selectedKeys: selected,
          description: 'Selected: ${selected.join(', ')}',
          onSelectionChanged: (Set<Object> keys) =>
              setState(() => selected = keys),
          children: <Widget>[HeroTagGroupList(children: _tags())],
        ),
      ),
    );
    await tester.tap(find.text('Gaming'));
    await tester.pumpAndSettle();
    expect(find.text('Selected: news, gaming'), findsOneWidget);
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(find.text('Selected: gaming'), findsOneWidget);
  });

  testWidgets('selectionMode none ignores presses', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroTagGroup(
        onSelectionChanged: (_) => fail('no selection'),
        children: <Widget>[HeroTagGroupList(children: _tags())],
      ),
    );
    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();
    expect(_decoration(tester, 'News').color, colors.defaultColor);
  });

  testWidgets('disabled tags, disabledKeys and a disabled group', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroTagGroup(
            selectionMode: HeroSelectionMode.single,
            disabledKeys: const <Object>{'travel'},
            onSelectionChanged: changes.add,
            children: <Widget>[
              HeroTagGroupList(children: _tags(disabled: <String>{'news'})),
            ],
          ),
          HeroTagGroup(
            isDisabled: true,
            selectionMode: HeroSelectionMode.single,
            onSelectionChanged: changes.add,
            children: const <Widget>[
              HeroTagGroupList(
                children: <Widget>[HeroTag(id: 'x', label: 'Locked')],
              ),
            ],
          ),
        ],
      ),
    );
    await tester.tap(find.text('News'));
    await tester.tap(find.text('Travel'));
    await tester.tap(find.text('Locked'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    Finder faded(String name) => find.ancestor(
      of: find.text(name),
      matching: find.byWidgetPredicate(
        (Widget w) => w is HeroDisabledOpacity && w.disabled,
      ),
    );
    expect(faded('News'), findsOneWidget);
    expect(faded('Travel'), findsOneWidget);
    expect(faded('Locked'), findsOneWidget);
    expect(faded('Gaming'), findsNothing);
  });

  testWidgets('hover uses the hover fill of the variant', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroTagGroup(children: <Widget>[HeroTagGroupList(children: _tags())]),
          const HeroTagGroup(
            variant: HeroTagVariant.surface,
            children: <Widget>[
              HeroTagGroupList(
                children: <Widget>[HeroTag(id: 's', label: 'Surface')],
              ),
            ],
          ),
        ],
      ),
    );
    expect(_decoration(tester, 'Surface').color, colors.surface);
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(find.text('News')));
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    expect(_decoration(tester, 'News').color, colors.defaultHover);
    await mouse.moveTo(tester.getCenter(find.text('Surface')));
    await tester.pumpAndSettle();
    expect(_decoration(tester, 'Surface').color, colors.surfaceHover);
  });

  testWidgets('remove buttons remove their tag, with a 24 px target', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> removed = <Set<Object>>[];
    final List<Set<Object>> selections = <Set<Object>>[];
    await pumpHero(
      tester,
      HeroTagGroup(
        selectionMode: HeroSelectionMode.single,
        onRemove: removed.add,
        onSelectionChanged: selections.add,
        children: <Widget>[HeroTagGroupList(children: _tags())],
      ),
    );
    expect(find.byType(HeroTagRemoveButton), findsNWidgets(3));
    final Finder button = find.byType(HeroTagRemoveButton).first;
    expect(tester.getSize(button), const Size(12, 12));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(removed, <Set<Object>>[
      <Object>{'news'},
    ]);
    // 5 px outside the glyph is still within the 24 px target.
    final Offset center = tester.getCenter(
      find.byType(HeroTagRemoveButton).at(1),
    );
    await tester.tapAt(center + const Offset(0, 5));
    await tester.pumpAndSettle();
    expect(removed.last, <Object>{'travel'});
    expect(selections, isEmpty);
    // The label itself selects.
    await tester.tap(find.text('Gaming'));
    await tester.pumpAndSettle();
    expect(selections, <Set<Object>>[
      <Object>{'gaming'},
    ]);
  });

  testWidgets('custom remove button and render function', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> removed = <Set<Object>>[];
    await pumpHero(
      tester,
      HeroTagGroup(
        onRemove: removed.add,
        children: <Widget>[
          HeroTagGroupList(
            children: <Widget>[
              const HeroTag(
                id: 'react',
                label: 'React',
                removeButton: HeroTagRemoveButton(
                  child: HeroIcon(HeroIcons.circleXmarkFill),
                ),
              ),
              HeroTag(
                id: 'vue',
                builder: (BuildContext context, HeroTagState state) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Vue'),
                    if (state.allowsRemoving) const HeroTagRemoveButton(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
    expect(find.byType(HeroIcon), findsNWidgets(2));
    await tester.tap(find.byType(HeroTagRemoveButton).last);
    await tester.pumpAndSettle();
    expect(removed, <Set<Object>>[
      <Object>{'vue'},
    ]);
  });

  testWidgets('no remove buttons without onRemove', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroTagGroup(children: <Widget>[HeroTagGroupList(children: _tags())]),
    );
    expect(find.byType(HeroTagRemoveButton), findsNothing);
  });

  testWidgets('keyboard: arrows, Home/End, Space, Delete and Escape', (
    WidgetTester tester,
  ) async {
    List<String> names = <String>['News', 'Travel', 'Gaming', 'Shopping'];
    Set<Object> selected = <Object>{};
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => HeroTagGroup(
          selectionMode: HeroSelectionMode.multiple,
          selectedKeys: selected,
          onSelectionChanged: (Set<Object> keys) =>
              setState(() => selected = keys),
          onRemove: (Set<Object> keys) => setState(() {
            names = <String>[
              for (final String name in names)
                if (!keys.contains(name)) name,
            ];
            selected = selected.difference(keys);
          }),
          children: <Widget>[
            HeroTagGroupList(
              children: <Widget>[
                for (final String name in names) HeroTag(id: name, label: name),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(_ringVisible(tester, 'News'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_ringVisible(tester, 'Travel'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(selected, <Object>{'Travel'});
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(_ringVisible(tester, 'Shopping'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, <Object>{'Travel', 'Shopping'});
    // Delete on a selected tag removes the whole selection.
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(names, <String>['News', 'Gaming']);
    // The focus moves to the tag that took its place (the new last one).
    expect(_ringVisible(tester, 'Gaming'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(names, <String>['Gaming']);
    expect(_ringVisible(tester, 'Gaming'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(selected, <Object>{'Gaming'});
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(selected, isEmpty);
  });

  testWidgets('keyboard is mirrored in RTL and supports typeahead', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroTagGroup(children: <Widget>[HeroTagGroupList(children: _tags())]),
      textDirection: TextDirection.rtl,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_ringVisible(tester, 'Travel'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_ringVisible(tester, 'News'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await tester.pumpAndSettle();
    expect(_ringVisible(tester, 'Gaming'), isTrue);
    expect(
      tester.getTopRight(find.text('News')).dx,
      greaterThan(tester.getTopRight(find.text('Travel')).dx),
    );
  });

  testWidgets('Ctrl+A selects every enabled tag', (WidgetTester tester) async {
    Set<Object> selected = <Object>{};
    await pumpHero(
      tester,
      HeroTagGroup(
        selectionMode: HeroSelectionMode.multiple,
        onSelectionChanged: (Set<Object> keys) => selected = keys,
        children: <Widget>[
          HeroTagGroupList(children: _tags(disabled: <String>{'travel'})),
        ],
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(selected, <Object>{'news', 'gaming'});
  });

  testWidgets('empty state and collections', (WidgetTester tester) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroTagGroup(
            children: <Widget>[
              HeroTagGroupList(
                emptyStateBuilder: (BuildContext context) =>
                    const HeroEmptyState.text('No tags'),
              ),
            ],
          ),
          HeroTagGroup(
            children: <Widget>[
              HeroTagGroupList(
                children: <Widget>[
                  HeroCollection<String>(
                    items: const <String>['a', 'b'],
                    itemBuilder: (BuildContext context, String item) =>
                        HeroTag(id: item, label: 'Item $item'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    expect(find.text('No tags'), findsOneWidget);
    expect(find.text('Item a'), findsOneWidget);
    expect(find.text('Item b'), findsOneWidget);
  });

  testWidgets('description gets 4 px padding', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroTagGroup(
        children: <Widget>[
          HeroTagGroupList(children: _tags()),
          const HeroDescription.text('Pick some'),
        ],
      ),
    );
    final Rect description = tester.getRect(find.byType(HeroDescription));
    final Rect text = tester.getRect(find.text('Pick some'));
    expect(text.left - description.left, 0);
    expect(
      text.left -
          tester
              .getRect(
                find
                    .ancestor(
                      of: find.byType(HeroDescription),
                      matching: find.byType(Padding),
                    )
                    .first,
              )
              .left,
      4,
    );
  });

  testWidgets('semantics: labelled list, selected tags, remove buttons', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      HeroTagGroup(
        label: 'Categories',
        selectionMode: HeroSelectionMode.single,
        defaultSelectedKeys: const <Object>{'news'},
        onRemove: (_) {},
        children: <Widget>[HeroTagGroupList(children: _tags())],
      ),
    );
    expect(find.bySemanticsLabel('Categories'), findsNWidgets(2));
    expect(
      tester.getSemantics(find.text('News')),
      isSemantics(isSelected: true, isButton: true, isFocusable: true),
    );
    expect(find.bySemanticsLabel('Remove tag'), findsNWidgets(3));
    handle.dispose();
  });

  testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 200,
        child: HeroTagGroup(
          label: 'Categories',
          size: HeroSize.lg,
          onRemove: (_) {},
          children: <Widget>[HeroTagGroupList(children: _tags())],
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
