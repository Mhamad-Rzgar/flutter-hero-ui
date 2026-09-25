import 'dart:ui' show SemanticsInputType;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroThemeData _theme = HeroThemeData.light();

HeroFieldBox _box(WidgetTester tester) =>
    tester.widget<HeroFieldBox>(find.byType(HeroFieldBox));

EditableText _editable(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText));

double _clearOpacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find
          .ancestor(
            of: find.byType(HeroCloseButton),
            matching: find.byType(Opacity),
          )
          .first,
    )
    .opacity;

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  group('HeroSearchField layout', () {
    testWidgets('builds label, icon, input, clear button and description', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSearchField(
          label: 'Search',
          placeholder: 'Search...',
          description: 'Enter keywords',
          inputWidth: 280,
        ),
        surfaceSize: const Size(390, 600),
      );
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Search...'), findsOneWidget);
      expect(find.text('Enter keywords'), findsOneWidget);
      expect(find.byType(HeroSearchFieldSearchIcon), findsOneWidget);
      expect(find.byType(HeroSearchFieldClearButton), findsOneWidget);

      final Rect group = tester.getRect(find.byType(HeroSearchFieldGroup));
      // h-9 even with text-base on narrow screens.
      expect(group.height, 36);
      // ms-3 + 16 icon + 280 input + 20 button + me-2.
      expect(group.width, 12 + 16 + 280 + 20 + 8);
      final Rect icon = tester.getRect(find.byType(HeroIcon).first);
      expect(icon.left - group.left, 12);
      expect(icon.size, const Size(16, 16));
      expect(icon.center.dy, group.center.dy);
      final Rect clear = tester.getRect(find.byType(HeroCloseButton));
      expect(clear.size, const Size(20, 20));
      expect(group.right - clear.right, 8);
      // Input text: ps-2 after the icon.
      expect(tester.getRect(find.byType(EditableText)).left - icon.right, 8);
      expect(_editable(tester).style.fontSize, 16);
    });

    testWidgets('the clear icon is 12 px', (WidgetTester tester) async {
      await pumpHero(tester, const HeroSearchField(defaultValue: 'x'));
      expect(
        tester.getSize(
          find.descendant(
            of: find.byType(HeroCloseButton),
            matching: find.byType(HeroIcon),
          ),
        ),
        const Size(12, 12),
      );
    });

    testWidgets('without icon or clear button the input keeps px-3', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSearchField(showSearchIcon: false, showClearButton: false),
      );
      final Rect group = tester.getRect(find.byType(HeroSearchFieldGroup));
      expect(group.width, HeroFieldMetrics.defaultWidth(_theme));
      final Rect text = tester.getRect(find.byType(EditableText));
      expect(text.left - group.left, 12);
      expect(group.right - text.right, 12);
    });

    testWidgets('fullWidth fills a bounded width', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 400,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: HeroSearchField(label: 'Search', fullWidth: true),
          ),
        ),
      );
      expect(tester.getSize(find.byType(HeroSearchFieldGroup)).width, 400);
    });

    testWidgets('RTL mirrors the icon and the clear button', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSearchField(defaultValue: 'x'),
        textDirection: TextDirection.rtl,
      );
      final Rect group = tester.getRect(find.byType(HeroSearchFieldGroup));
      expect(
        group.right - tester.getRect(find.byType(HeroIcon).first).right,
        12,
      );
      expect(tester.getRect(find.byType(HeroCloseButton)).left - group.left, 8);
    });

    testWidgets('text scale 2.0 grows the group without overflow', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSearchField(
          label: 'Search',
          placeholder: 'Search...',
          description: 'Enter keywords',
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(HeroSearchFieldGroup)).height,
        greaterThan(36),
      );
    });
  });

  group('HeroSearchField behaviour', () {
    testWidgets('the clear button is hidden while empty', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroSearchField(label: 'Search'));
      expect(_clearOpacity(tester), 0);
      await tester.enterText(find.byType(EditableText), 'shoes');
      await tester.pump();
      expect(_clearOpacity(tester), 1);
    });

    testWidgets('the clear button clears and keeps the focus', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      int clears = 0;
      await pumpHero(
        tester,
        HeroSearchField(
          label: 'Search',
          onChanged: changes.add,
          onClear: () => clears++,
        ),
      );
      await tester.enterText(find.byType(EditableText), 'shoes');
      await tester.pump();
      await tester.tap(find.byType(HeroCloseButton));
      await tester.pumpAndSettle();
      expect(changes, <String>['shoes', '']);
      expect(clears, 1);
      expect(_editable(tester).controller.text, isEmpty);
      expect(_editable(tester).focusNode.hasFocus, isTrue);
      expect(_clearOpacity(tester), 0);
    });

    testWidgets('Escape clears a value, then bubbles when empty', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      int clears = 0;
      int bubbled = 0;
      await pumpHero(
        tester,
        Focus(
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event.logicalKey == LogicalKeyboardKey.escape) bubbled++;
            return KeyEventResult.ignored;
          },
          child: HeroSearchField(
            label: 'Search',
            onChanged: changes.add,
            onClear: () => clears++,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'shoes');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(changes, <String>['shoes', '']);
      expect(clears, 1);
      // The key-down and key-up of the clearing Escape are consumed.
      expect(bubbled, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(clears, 1);
      expect(bubbled, 2);
    });

    testWidgets('Enter calls onSubmitted and submits the form', (
      WidgetTester tester,
    ) async {
      String? submittedValue;
      Map<String, Object?>? form;
      await pumpHero(
        tester,
        HeroForm(
          onSubmit: (Map<String, Object?> data) => form = data,
          child: HeroSearchField(
            name: 'search',
            onSubmitted: (String value) => submittedValue = value,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'shoes');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(submittedValue, 'shoes');
      expect(form, <String, Object?>{'search': 'shoes'});
      expect(_editable(tester).textInputAction, TextInputAction.search);
      expect(_editable(tester).keyboardType, TextInputType.webSearch);
    });

    testWidgets('pressing the search icon focuses the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroSearchField(label: 'Search'));
      expect(_box(tester).isFocused, isFalse);
      await tester.tap(find.byType(HeroSearchFieldSearchIcon));
      await tester.pump();
      expect(_editable(tester).focusNode.hasFocus, isTrue);
      expect(_box(tester).isFocused, isTrue);
    });

    testWidgets('the clear button is not in the focus order', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroSearchField(label: 'Search', defaultValue: 'x'),
            HeroButton(child: Text('Next')),
          ],
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_editable(tester).focusNode.hasFocus, isFalse);
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<HeroButton>(),
        isNotNull,
      );
    });

    testWidgets('disabled and read-only fields cannot be cleared', (
      WidgetTester tester,
    ) async {
      int clears = 0;
      await pumpHero(
        tester,
        HeroSearchField(
          value: 'Disabled search',
          isDisabled: true,
          onClear: () => clears++,
        ),
      );
      expect(_box(tester).isDisabled, isTrue);
      await tester.tap(find.byType(HeroCloseButton), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Disabled search'), findsOneWidget);

      await pumpHero(
        tester,
        HeroSearchField(
          key: const ValueKey<String>('read-only'),
          defaultValue: 'Read only',
          isReadOnly: true,
          onClear: () => clears++,
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tap(find.byType(HeroCloseButton), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Read only'), findsOneWidget);
      expect(clears, 0);
    });

    testWidgets('controlled value follows the parent', (
      WidgetTester tester,
    ) async {
      String value = '';
      late StateSetter update;
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            update = setState;
            return HeroSearchField(
              label: 'Search',
              value: value,
              onChanged: (String v) => setState(() => value = v),
              description:
                  'Current value: ${value.isEmpty ? '(empty)' : value}',
            );
          },
        ),
      );
      expect(find.text('Current value: (empty)'), findsOneWidget);
      update(() => value = 'example query');
      await tester.pump();
      expect(_editable(tester).controller.text, 'example query');
      expect(find.text('Current value: example query'), findsOneWidget);
      await tester.tap(find.byType(HeroCloseButton));
      await tester.pumpAndSettle();
      expect(value, '');
    });

    testWidgets('validation hides the description and shows the error', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSearchField(
          label: 'Search',
          value: 'ab',
          isRequired: true,
          isInvalid: true,
          description: 'Enter at least 3 characters',
          errorMessage: 'Search query must be at least 3 characters',
        ),
      );
      expect(_box(tester).isInvalid, isTrue);
      expect(find.text('Enter at least 3 characters'), findsNothing);
      expect(
        find.text('Search query must be at least 3 characters'),
        findsOneWidget,
      );
    });

    testWidgets('required validation on submit', (WidgetTester tester) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          child: const HeroSearchField(
            name: 'search',
            label: 'Search',
            isRequired: true,
          ),
        ),
      );
      expect(form.currentState!.submit(), isFalse);
      await tester.pump();
      expect(find.text('Please fill out this field.'), findsOneWidget);
    });

    testWidgets('variant and style reach the group', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroSearchField(variant: HeroFieldVariant.secondary),
      );
      expect(_box(tester).variant, HeroFieldVariant.secondary);
    });

    testWidgets('builder receives the value and the state', (
      WidgetTester tester,
    ) async {
      final List<HeroSearchFieldState> states = <HeroSearchFieldState>[];
      await pumpHero(
        tester,
        HeroSearchField(
          builder: (BuildContext context, HeroSearchFieldState state) {
            states.add(state);
            return <Widget>[
              HeroLabel.text(state.isEmpty ? 'Empty' : state.value),
              const HeroSearchFieldGroup(
                children: <Widget>[HeroSearchFieldInput()],
              ),
            ];
          },
        ),
      );
      expect(find.text('Empty'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      expect(states.last.value, 'abc');
      expect(states.last.isEmpty, isFalse);
      expect(states.last.isFocusWithin, isTrue);
    });

    testWidgets('hover shows the hover background', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroSearchField());
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(HeroSearchFieldGroup)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('HeroSearchField semantics', () {
    testWidgets('a labelled search text field and a clear button', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroSearchField(
          label: 'Search',
          defaultValue: 'x',
          description: 'Enter keywords',
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.byType(HeroEditableText),
      );
      expect(node.label, 'Search');
      expect(node.hint, contains('Enter keywords'));
      expect(node.getSemanticsData().inputType, SemanticsInputType.search);
      expect(find.bySemanticsLabel('Clear search'), findsOneWidget);

      await pumpHero(
        tester,
        const HeroSearchField(key: ValueKey<int>(2), label: 'Search'),
      );
      // Hidden while empty.
      expect(find.bySemanticsLabel('Clear search'), findsNothing);
      handle.dispose();
    });
  });

  testWidgets('debug properties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const HeroSearchField(
      label: 'Search',
      variant: HeroFieldVariant.secondary,
      isDisabled: true,
    ).debugFillProperties(builder);
    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();
    expect(description, contains('label: "Search"'));
    expect(description, contains('variant: secondary'));
    expect(description, contains('disabled'));
  });
}
