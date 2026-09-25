import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _disclosure(String id, {bool isDisabled = false}) => HeroDisclosure(
  id: id,
  isDisabled: isDisabled,
  children: <Widget>[
    HeroDisclosureHeading(
      child: HeroDisclosureTrigger(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Title $id'),
            const HeroDisclosureIndicator(),
          ],
        ),
      ),
    ),
    HeroDisclosureContent(child: HeroDisclosureBody(child: Text('Body $id'))),
  ],
);

bool _shown(String id) => find.text('Body $id').evaluate().isNotEmpty;

Widget _group({
  Set<Object>? expandedKeys,
  Set<Object>? defaultExpandedKeys,
  ValueChanged<Set<Object>>? onExpandedChanged,
  bool allowsMultipleExpanded = false,
  bool isDisabled = false,
}) => SizedBox(
  width: 300,
  child: HeroDisclosureGroup(
    expandedKeys: expandedKeys,
    defaultExpandedKeys: defaultExpandedKeys,
    onExpandedChanged: onExpandedChanged,
    allowsMultipleExpanded: allowsMultipleExpanded,
    isDisabled: isDisabled,
    children: <Widget>[
      _disclosure('a'),
      const HeroSeparator(),
      _disclosure('b'),
      _disclosure('c', isDisabled: true),
    ],
  ),
);

void main() {
  testWidgets('expanding one collapses the others', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    await pumpHero(
      tester,
      _group(
        defaultExpandedKeys: const <Object>{'a'},
        onExpandedChanged: changes.add,
      ),
    );
    expect(_shown('a'), isTrue);
    await tester.tap(find.text('Title b'));
    await tester.pumpAndSettle();
    expect(_shown('a'), isFalse);
    expect(_shown('b'), isTrue);
    await tester.tap(find.text('Title b'));
    await tester.pumpAndSettle();
    expect(_shown('b'), isFalse);
    expect(changes, <Set<Object>>[
      <Object>{'b'},
      <Object>{},
    ]);
  });

  testWidgets('allowsMultipleExpanded keeps several open', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _group(allowsMultipleExpanded: true));
    await tester.tap(find.text('Title a'));
    await tester.tap(find.text('Title b'));
    await tester.pumpAndSettle();
    expect(_shown('a'), isTrue);
    expect(_shown('b'), isTrue);
  });

  testWidgets('controlled expandedKeys', (WidgetTester tester) async {
    Set<Object> expanded = <Object>{'b'};
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => _group(
          expandedKeys: expanded,
          onExpandedChanged: (Set<Object> keys) =>
              setState(() => expanded = keys),
        ),
      ),
    );
    expect(_shown('b'), isTrue);
    await tester.tap(find.text('Title a'));
    await tester.pumpAndSettle();
    expect(expanded, <Object>{'a'});
    expect(_shown('a'), isTrue);
    expect(_shown('b'), isFalse);
  });

  testWidgets('disabled group and disclosures do not toggle', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _group(),
          SizedBox(
            width: 300,
            child: HeroDisclosureGroup(
              isDisabled: true,
              children: <Widget>[_disclosure('d')],
            ),
          ),
        ],
      ),
    );
    await tester.tap(find.text('Title c'));
    await tester.tap(find.text('Title d'));
    await tester.pumpAndSettle();
    expect(_shown('c'), isFalse);
    expect(_shown('d'), isFalse);
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is HeroDisabledOpacity && w.disabled,
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('the builder receives the expanded keys', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        child: HeroDisclosureGroup(
          defaultExpandedKeys: const <Object>{'a'},
          builder:
              (BuildContext context, Set<Object> expandedKeys, bool disabled) =>
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Open: ${expandedKeys.join(', ')}'),
                      _disclosure('a'),
                      _disclosure('b'),
                    ],
                  ),
        ),
      ),
    );
    expect(find.text('Open: a'), findsOneWidget);
    await tester.tap(find.text('Title b'));
    await tester.pumpAndSettle();
    expect(find.text('Open: b'), findsOneWidget);
  });

  test('navigation moves through the items', () {
    Set<Object> expanded = <Object>{'a'};
    HeroDisclosureGroupNavigation navigation({bool multiple = false}) =>
        HeroDisclosureGroupNavigation(
          expandedKeys: expanded,
          itemIds: const <Object>['a', 'b', 'c'],
          allowsMultipleExpanded: multiple,
          onExpandedChanged: (Set<Object> keys) => expanded = keys,
        );
    expect(navigation().currentIndex, 0);
    expect(navigation().isPrevDisabled, isTrue);
    expect(navigation().isNextDisabled, isFalse);
    navigation().next();
    expect(expanded, <Object>{'b'});
    navigation().next();
    expect(expanded, <Object>{'c'});
    expect(navigation().isNextDisabled, isTrue);
    navigation().next();
    expect(expanded, <Object>{'c'});
    navigation(multiple: true).previous();
    expect(expanded, <Object>{'c', 'b'});
    expanded = <Object>{};
    expect(navigation().currentIndex, 0);
    expect(
      const HeroDisclosureGroupNavigation(
        expandedKeys: <Object>{},
        itemIds: <Object>[],
        onExpandedChanged: _ignore,
      ).currentIndex,
      -1,
    );
  });

  testWidgets('keyboard: Tab skips collapsed content, Enter toggles', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _group());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_shown('b'), isTrue);
  });

  testWidgets('semantics reflect the group state', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, _group(defaultExpandedKeys: const <Object>{'b'}));
    expect(
      tester.getSemantics(find.text('Title b')),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: true),
    );
    expect(
      tester.getSemantics(find.text('Title a')),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
    );
    handle.dispose();
  });

  testWidgets('RTL and text scale 2.0 without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _group(defaultExpandedKeys: const <Object>{'a'}),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopRight(find.byType(HeroDisclosureTrigger).first).dx,
      tester.getTopRight(find.byType(HeroDisclosureGroup)).dx,
    );
  });
}

void _ignore(Set<Object> keys) {}
