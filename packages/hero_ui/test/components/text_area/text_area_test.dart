import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

EditableText _editable(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText));

HeroFieldBox _box(WidgetTester tester) =>
    tester.widget<HeroFieldBox>(find.byType(HeroFieldBox));

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  group('HeroTextArea layout', () {
    testWidgets('two rows by default (rows × line height + padding)', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextArea(placeholder: 'Note'),
        surfaceSize: const Size(400, 400),
      );
      expect(tester.getSize(find.byType(HeroTextArea)).height, 2 * 24 + 16);
      expect(_editable(tester).maxLines, 2);
      expect(_editable(tester).keyboardType, TextInputType.multiline);
    });

    testWidgets('rows and sm text size', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroTextArea(rows: 6),
        surfaceSize: const Size(800, 400),
      );
      expect(tester.getSize(find.byType(HeroTextArea)).height, 6 * 20 + 16);
    });

    testWidgets('keeps the 38 px minimum height', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroTextArea(rows: 1),
        surfaceSize: const Size(800, 400),
      );
      expect(tester.getSize(find.byType(HeroTextArea)).height, 38);
    });

    testWidgets('explicit width and height', (WidgetTester tester) async {
      await pumpHero(tester, const HeroTextArea(width: 384, height: 128));
      expect(tester.getSize(find.byType(HeroTextArea)), const Size(384, 128));
      expect(_editable(tester).expands, isTrue);
    });

    testWidgets('fullWidth and cols', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 300,
          child: Column(
            children: <Widget>[
              HeroTextArea(key: Key('full'), fullWidth: true),
              HeroTextArea(key: Key('cols'), cols: 10),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('full'))).width, 300);
      final double cols = tester.getSize(find.byKey(const Key('cols'))).width;
      expect(cols, greaterThan(24 + 10 * 5));
      expect(cols, lessThan(24 + 10 * 16));
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroTextArea(defaultValue: 'Scaled text\nSecond line'),
        textScale: 2,
        surfaceSize: const Size(400, 400),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(HeroTextArea)).height, 2 * 48 + 16);
    });
  });

  group('HeroTextArea value', () {
    testWidgets('uncontrolled, multi-line text and onChanged', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await pumpHero(tester, HeroTextArea(onChanged: changes.add));
      await tester.enterText(find.byType(EditableText), 'line 1\nline 2');
      expect(changes.single, 'line 1\nline 2');
    });

    testWidgets('controlled value', (WidgetTester tester) async {
      String value = '';
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroTextArea(
                value: value,
                onChanged: (String v) => setState(() => value = v),
              ),
              Text('Characters: ${value.length} / 280'),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'Hello');
      await tester.pump();
      expect(find.text('Characters: 5 / 280'), findsOneWidget);
    });

    testWidgets('controller', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(
        text: 'from controller',
      );
      addTearDown(controller.dispose);
      await pumpHero(tester, HeroTextArea(controller: controller));
      expect(find.text('from controller'), findsOneWidget);
    });

    testWidgets('form validation with minLength', (WidgetTester tester) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await pumpHero(
        tester,
        Form(
          key: form,
          child: const HeroTextArea(isRequired: true, minLength: 20),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(_box(tester).isInvalid, isTrue);
      await tester.enterText(find.byType(EditableText), 'short');
      expect(form.currentState!.validate(), isFalse);
      await tester.enterText(
        find.byType(EditableText),
        'This bio is long enough to pass.',
      );
      expect(form.currentState!.validate(), isTrue);
    });
  });

  group('HeroTextArea states', () {
    testWidgets('focus, disabled and invalid', (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await pumpHero(tester, HeroTextArea(focusNode: node, isInvalid: true));
      await tester.tap(find.byType(HeroTextArea));
      await tester.pump();
      expect(node.hasFocus, isTrue);
      expect(_box(tester).isFocused, isTrue);
      expect(_box(tester).isInvalid, isTrue);

      await pumpHero(tester, HeroTextArea(focusNode: node, isDisabled: true));
      expect(node.hasFocus, isFalse);
      expect(_box(tester).isDisabled, isTrue);
    });

    testWidgets('inherits the variant from a field scope', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroFieldScope(
          variant: HeroFieldVariant.secondary,
          child: HeroTextArea(),
        ),
      );
      expect(_box(tester).variant, HeroFieldVariant.secondary);
    });
  });

  group('HeroTextArea resize', () {
    testWidgets('dragging the grip changes the height', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextArea(rows: 3, resize: HeroTextAreaResize.vertical),
        surfaceSize: const Size(400, 400),
      );
      final double before = tester.getSize(find.byType(HeroTextArea)).height;
      final Finder grip = find.descendant(
        of: find.byType(PositionedDirectional),
        matching: find.byType(GestureDetector),
      );
      await tester.drag(grip, const Offset(0, 60));
      await tester.pump();
      final double after = tester.getSize(find.byType(HeroTextArea)).height;
      expect(after, greaterThan(before + 30));

      await tester.drag(grip, const Offset(0, -400));
      await tester.pump();
      expect(tester.getSize(find.byType(HeroTextArea)).height, 38);
    });

    testWidgets('grip sits at the bottom-start corner in RTL', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextArea(resize: HeroTextAreaResize.vertical),
        textDirection: TextDirection.rtl,
      );
      final Rect area = tester.getRect(find.byType(HeroTextArea));
      final Rect grip = tester.getRect(
        find.descendant(
          of: find.byType(HeroTextArea),
          matching: find.byType(PositionedDirectional),
        ),
      );
      expect(grip.left, area.left);
      expect(grip.bottom, area.bottom);
    });

    testWidgets('no grip by default or when disabled', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroTextArea(),
            HeroTextArea(resize: HeroTextAreaResize.vertical, isDisabled: true),
          ],
        ),
      );
      expect(
        find.descendant(
          of: find.byType(HeroTextArea),
          matching: find.byType(PositionedDirectional),
        ),
        findsNothing,
      );
    });
  });

  testWidgets('semantics: multi-line text field', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const HeroTextArea(semanticLabel: 'Notes', placeholder: 'Add a note...'),
    );
    expect(
      tester.getSemantics(find.byType(HeroEditableText)),
      isSemantics(
        label: 'Notes',
        hint: 'Add a note...',
        isTextField: true,
        isMultiline: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('Enter inserts a new line on hardware keyboards', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const HeroTextArea(defaultValue: 'a'));
    await tester.tap(find.byType(HeroTextArea));
    await tester.pump();
    final EditableTextState state = tester.state(find.byType(EditableText));
    state.updateEditingValue(
      const TextEditingValue(
        text: 'a\nb',
        selection: TextSelection.collapsed(offset: 3),
      ),
    );
    await tester.pump();
    expect(_editable(tester).controller.text, 'a\nb');
    expect(_editable(tester).textInputAction, isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  });
}
