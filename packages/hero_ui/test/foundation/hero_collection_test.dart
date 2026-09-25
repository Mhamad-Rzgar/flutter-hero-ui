import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  group('HeroSelectionManager', () {
    const List<Object> order = <Object>['a', 'b', 'c', 'd'];

    HeroSelectionManager manager(
      HeroSelectionMode mode, [
      Set<Object> selected = const <Object>{},
      Set<Object> disabled = const <Object>{},
      bool disallowEmpty = false,
    ]) => HeroSelectionManager(
      selectionMode: mode,
      selectedKeys: selected,
      disabledKeys: disabled,
      disallowEmptySelection: disallowEmpty,
    );

    test('none selects nothing', () {
      final HeroSelectionManager m = manager(HeroSelectionMode.none);
      expect(identical(m.toggle('a'), m.selectedKeys), isTrue);
      expect(m.canSelect('a'), isFalse);
      expect(
        identical(m.extend(to: 'b', order: order), m.selectedKeys),
        isTrue,
      );
    });

    test('single toggles, replaces and honours disallowEmptySelection', () {
      expect(manager(HeroSelectionMode.single).toggle('a'), <Object>{'a'});
      expect(
        manager(HeroSelectionMode.single, <Object>{'a'}).toggle('b'),
        <Object>{'b'},
      );
      expect(
        manager(HeroSelectionMode.single, <Object>{'a'}).toggle('a'),
        isEmpty,
      );
      final HeroSelectionManager locked = manager(
        HeroSelectionMode.single,
        <Object>{'a'},
        const <Object>{},
        true,
      );
      expect(identical(locked.toggle('a'), locked.selectedKeys), isTrue);
      expect(identical(locked.clear(), locked.selectedKeys), isTrue);
      expect(
        manager(HeroSelectionMode.single, <Object>{
          'a',
        }).extend(to: 'c', order: order),
        <Object>{'c'},
      );
    });

    test('multiple toggles and skips disabled keys', () {
      final HeroSelectionManager m = manager(
        HeroSelectionMode.multiple,
        <Object>{'a'},
        <Object>{'c'},
      );
      expect(m.toggle('b'), <Object>{'a', 'b'});
      expect(m.toggle('a'), isEmpty);
      expect(identical(m.toggle('c'), m.selectedKeys), isTrue);
      expect(m.selectAll(order), <Object>{'a', 'b', 'd'});
      expect(m.clear(), isEmpty);
      expect(m.isSelected('a'), isTrue);
    });

    test('extend selects the range from the anchor', () {
      final HeroSelectionManager m = manager(
        HeroSelectionMode.multiple,
        <Object>{'a'},
      );
      final Set<Object> grown = m.extend(
        to: 'c',
        order: order,
        anchor: 'a',
        current: 'a',
      );
      expect(grown, <Object>{'a', 'b', 'c'});
      final Set<Object> shrunk = manager(
        HeroSelectionMode.multiple,
        grown,
      ).extend(to: 'b', order: order, anchor: 'a', current: 'c');
      expect(shrunk, <Object>{'a', 'b'});
      final Set<Object> backwards = manager(
        HeroSelectionMode.multiple,
        grown,
      ).extend(to: 'a', order: order, anchor: 'c', current: 'c');
      expect(backwards, <Object>{'a', 'b', 'c'});
      expect(
        manager(HeroSelectionMode.multiple).extend(to: 'b', order: order),
        <Object>{'b'},
      );
    });

    test('equality compares the snapshot', () {
      expect(
        manager(HeroSelectionMode.multiple, <Object>{'a', 'b'}),
        manager(HeroSelectionMode.multiple, <Object>{'b', 'a'}),
      );
      expect(
        manager(HeroSelectionMode.multiple, <Object>{'a'}).hashCode,
        manager(HeroSelectionMode.multiple, <Object>{'a'}).hashCode,
      );
    });
  });

  group('HeroTypeahead', () {
    const List<HeroTypeaheadEntry> entries = <HeroTypeaheadEntry>[
      (key: 1, text: 'Apple', isDisabled: false),
      (key: 2, text: 'Banana', isDisabled: false),
      (key: 3, text: 'blueberry', isDisabled: false),
      (key: 4, text: 'Cherry', isDisabled: true),
      (key: 5, text: 'Avocado', isDisabled: false),
    ];

    test('matches prefixes ignoring case and accumulates', () {
      final HeroTypeahead typeahead = HeroTypeahead();
      addTearDown(typeahead.dispose);
      expect(typeahead.search('b', entries), 2);
      expect(typeahead.search('L', entries, from: 2), 3);
      expect(typeahead.buffer, 'bL');
      expect(typeahead.isActive, isTrue);
      typeahead.reset();
      expect(typeahead.isActive, isFalse);
    });

    test('searches from the focused entry and wraps around', () {
      final HeroTypeahead typeahead = HeroTypeahead();
      addTearDown(typeahead.dispose);
      expect(typeahead.search('a', entries, from: 3), 5);
      typeahead.reset();
      expect(typeahead.search('a', entries, from: 5), 5);
      typeahead.reset();
      expect(typeahead.search('b', entries, from: 5), 2);
    });

    test('skips disabled entries and misses', () {
      final HeroTypeahead typeahead = HeroTypeahead();
      addTearDown(typeahead.dispose);
      expect(typeahead.search('c', entries), isNull);
      typeahead.reset();
      expect(typeahead.search('z', entries), isNull);
    });

    testWidgets('resets after the timeout', (WidgetTester tester) async {
      final HeroTypeahead typeahead = HeroTypeahead();
      addTearDown(typeahead.dispose);
      typeahead.search('b', entries);
      await tester.pump(const Duration(milliseconds: 999));
      expect(typeahead.buffer, 'b');
      await tester.pump(const Duration(milliseconds: 2));
      expect(typeahead.buffer, isEmpty);
    });
  });

  group('HeroCollection', () {
    testWidgets('builds one widget per item and lays them out alone', (
      WidgetTester tester,
    ) async {
      const HeroCollection<int> collection = HeroCollection<int>(
        items: <int>[1, 2, 3],
        itemBuilder: _build,
      );
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: collection),
        ),
      );
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      expect(
        collection.buildItems(tester.element(find.byType(Center))),
        hasLength(3),
      );
    });
  });
}

Widget _build(BuildContext context, int item) => Text('Item $item');
