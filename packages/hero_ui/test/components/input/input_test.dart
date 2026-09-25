import 'dart:ui' show SemanticsInputType;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

HeroFieldBox _box(WidgetTester tester) =>
    tester.widget<HeroFieldBox>(find.byType(HeroFieldBox));

EditableText _editable(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText));

/// Matches a render object that fills a path with [color] at some point.
PaintPattern _paintsPath(Color color) =>
    paints..something((Symbol method, List<dynamic> arguments) {
      return method == #drawPath &&
          (arguments[1] as Paint).color.toARGB32() == color.toARGB32();
    });

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  group('HeroInput layout', () {
    testWidgets('is 40 high with 16 px text below sm', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInput(placeholder: 'Enter your name'),
        surfaceSize: const Size(400, 400),
      );
      expect(find.text('Enter your name'), findsOneWidget);
      final Size size = tester.getSize(find.byType(HeroInput));
      expect(size.height, 40);
      expect(size.width, HeroFieldMetrics.defaultWidth(HeroThemeData.light()));
      expect(_editable(tester).style.fontSize, 16);
    });

    testWidgets('is 36 high with 14 px text from sm', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInput(placeholder: 'Wide'),
        surfaceSize: const Size(800, 400),
      );
      expect(tester.getSize(find.byType(HeroInput)).height, 36);
      expect(_editable(tester).style.fontSize, 14);
    });

    testWidgets('density pins the text size', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroInput(),
        theme: HeroThemeData.light().copyWith(density: HeroDensity.touch),
        surfaceSize: const Size(800, 400),
      );
      expect(_editable(tester).style.fontSize, 16);
    });

    testWidgets('fullWidth and width', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 300,
          child: Column(
            children: <Widget>[
              HeroInput(key: Key('full'), fullWidth: true),
              HeroInput(key: Key('fixed'), width: 120),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byKey(const Key('full'))).width, 300);
      expect(tester.getSize(find.byKey(const Key('fixed'))).width, 120);
    });

    testWidgets('text scale 2.0 grows without overflow', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInput(placeholder: 'Scaled', defaultValue: 'Scaled text'),
        textScale: 2,
        surfaceSize: const Size(400, 400),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(HeroInput)).height, 64);
    });

    testWidgets('right-to-left aligns text to the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInput(defaultValue: 'abc', fullWidth: true),
        textDirection: TextDirection.rtl,
      );
      final RenderEditable editable = tester
          .state<EditableTextState>(find.byType(EditableText))
          .renderEditable;
      expect(editable.textDirection, TextDirection.rtl);
      final Rect caret = editable.getLocalRectForCaret(
        const TextPosition(offset: 0),
      );
      expect(caret.left, greaterThan(editable.size.width / 2));
    });
  });

  group('HeroInput value', () {
    testWidgets('uncontrolled: defaultValue and onChanged', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await pumpHero(
        tester,
        HeroInput(defaultValue: 'Jane', onChanged: changes.add),
      );
      expect(find.text('Jane'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'Janet');
      expect(changes, <String>['Janet']);
      expect(find.text('Janet'), findsOneWidget);
    });

    testWidgets('controlled: value follows the parent', (
      WidgetTester tester,
    ) async {
      String value = 'heroui.com';
      late StateSetter setOuter;
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setOuter = setState;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                HeroInput(
                  value: value,
                  onChanged: (String v) => setState(() => value = v),
                ),
                Text('https://$value'),
              ],
            );
          },
        ),
      );
      expect(find.text('https://heroui.com'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'flutter.dev');
      await tester.pump();
      expect(find.text('https://flutter.dev'), findsOneWidget);
      setOuter(() => value = 'dart.dev');
      await tester.pump();
      expect(_editable(tester).controller.text, 'dart.dev');
    });

    testWidgets('external controller', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(
        text: 'abc',
      );
      addTearDown(controller.dispose);
      await pumpHero(tester, HeroInput(controller: controller));
      expect(find.text('abc'), findsOneWidget);
      controller.text = 'xyz';
      await tester.pump();
      expect(find.text('xyz'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'typed');
      expect(controller.text, 'typed');
    });

    testWidgets('placeholder hides while there is text', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroInput(placeholder: 'Type here'));
      expect(find.text('Type here'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'x');
      await tester.pump();
      expect(find.text('Type here'), findsNothing);
    });

    testWidgets('onSubmitted', (WidgetTester tester) async {
      String? submitted;
      await pumpHero(
        tester,
        HeroInput(onSubmitted: (String v) => submitted = v),
      );
      await tester.enterText(find.byType(EditableText), 'done');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 'done');
    });

    testWidgets('maxLength truncates input', (WidgetTester tester) async {
      await pumpHero(tester, const HeroInput(maxLength: 3));
      await tester.enterText(find.byType(EditableText), 'abcdef');
      expect(_editable(tester).controller.text, 'abc');
    });

    testWidgets('number type accepts only numeric characters', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroInput(type: HeroInputType.number));
      await tester.enterText(find.byType(EditableText), '12a3');
      expect(_editable(tester).controller.text, '123');
      expect(
        _editable(tester).keyboardType,
        const TextInputType.numberWithOptions(signed: true, decimal: true),
      );
    });

    testWidgets('password type obscures the text', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroInput(type: HeroInputType.password, defaultValue: 'secret'),
      );
      expect(_editable(tester).obscureText, isTrue);
      expect(_editable(tester).autocorrect, isFalse);
    });

    testWidgets('email type picks the email keyboard', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroInput(type: HeroInputType.email));
      expect(_editable(tester).keyboardType, TextInputType.emailAddress);
    });
  });

  group('HeroInput states', () {
    testWidgets('tap focuses and shows the focus state', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroInput());
      expect(_box(tester).isFocused, isFalse);
      await tester.tap(find.byType(HeroInput));
      await tester.pumpAndSettle();
      expect(_box(tester).isFocused, isTrue);
      // The 2 px focus ring (offset 0) is painted in the focus color.
      expect(
        find.byType(HeroFieldBox),
        _paintsPath(HeroThemeData.light().colors.focus),
      );
    });

    testWidgets('keyboard Tab moves focus into the input', (
      WidgetTester tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpHero(tester, HeroInput(focusNode: focusNode));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets('hover changes the background', (WidgetTester tester) async {
      await pumpHero(tester, const HeroInput());
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      final HeroColors colors = HeroThemeData.light().colors;
      expect(find.byType(HeroFieldBox), _paintsPath(colors.fieldBackground));
      await mouse.moveTo(tester.getCenter(find.byType(HeroInput)));
      await tester.pumpAndSettle();
      expect(find.byType(HeroFieldBox), _paintsPath(colors.fieldHover));
    });

    testWidgets('disabled cannot be focused or edited', (
      WidgetTester tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpHero(
        tester,
        HeroInput(focusNode: focusNode, isDisabled: true, defaultValue: 'x'),
      );
      await tester.tap(find.byType(HeroInput));
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);
      expect(_editable(tester).readOnly, isTrue);
      expect(_box(tester).isDisabled, isTrue);
      expect(
        find.descendant(
          of: find.byType(HeroInput),
          matching: find.byType(Opacity),
        ),
        findsOneWidget,
      );
    });

    testWidgets('read-only is focusable but not editable', (
      WidgetTester tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpHero(
        tester,
        HeroInput(focusNode: focusNode, isReadOnly: true, defaultValue: 'x'),
      );
      await tester.tap(find.byType(HeroInput));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      expect(_editable(tester).readOnly, isTrue);
    });

    testWidgets('invalid marks the field', (WidgetTester tester) async {
      await pumpHero(tester, const HeroInput(isInvalid: true));
      expect(_box(tester).isInvalid, isTrue);
      expect(
        find.byType(HeroFieldBox),
        _paintsPath(HeroThemeData.light().colors.danger),
      );
    });
  });

  group('HeroInput semantics', () {
    testWidgets('text field with label, hint and states', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroInput(
          semanticLabel: 'Email',
          placeholder: 'jane@example.com',
          type: HeroInputType.email,
          isRequired: true,
          isInvalid: true,
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.byType(HeroEditableText),
      );
      expect(
        node,
        isSemantics(
          label: 'Email',
          hint: 'jane@example.com',
          isTextField: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      final SemanticsData data = node.getSemanticsData();
      expect(data.inputType, SemanticsInputType.email);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      handle.dispose();
    });

    testWidgets('disabled is reported', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroInput(semanticLabel: 'Name', isDisabled: true),
      );
      expect(
        tester.getSemantics(find.byType(HeroEditableText)),
        isSemantics(
          label: 'Name',
          isTextField: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      handle.dispose();
    });
  });

  group('HeroInput forms', () {
    testWidgets('validates, saves and resets with a Form', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      String? saved;
      await pumpHero(
        tester,
        Form(
          key: form,
          child: HeroInput(
            defaultValue: 'ab',
            validator: (String? v) => (v ?? '').length < 3 ? 'Too short' : null,
            onSaved: (String? v) => saved = v,
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(_box(tester).isInvalid, isTrue);

      await tester.enterText(find.byType(EditableText), 'abcd');
      expect(form.currentState!.validate(), isTrue);
      await tester.pump();
      expect(_box(tester).isInvalid, isFalse);
      form.currentState!.save();
      expect(saved, 'abcd');

      form.currentState!.reset();
      await tester.pump();
      expect(_editable(tester).controller.text, 'ab');
    });

    testWidgets('native constraints', (WidgetTester tester) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await pumpHero(
        tester,
        Form(
          key: form,
          child: const HeroInput(isRequired: true, type: HeroInputType.email),
        ),
      );
      final FormFieldState<String> field = tester.state(
        find.byWidgetPredicate((Widget w) => w is FormField<String>),
      );
      expect(form.currentState!.validate(), isFalse);
      expect(field.errorText, 'Please fill out this field.');
      await tester.enterText(find.byType(EditableText), 'jane');
      expect(form.currentState!.validate(), isFalse);
      expect(field.errorText, 'Please enter an email address.');
      await tester.enterText(find.byType(EditableText), 'jane@example.com');
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('autovalidate on user interaction', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroInput(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? v) => v == 'bad' ? 'Bad value' : null,
        ),
      );
      expect(_box(tester).isInvalid, isFalse);
      await tester.enterText(find.byType(EditableText), 'bad');
      await tester.pump();
      expect(_box(tester).isInvalid, isTrue);
    });
  });

  group('HeroInput scope', () {
    testWidgets('inherits variant and states from a field scope', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController(
        text: 'from scope',
      );
      addTearDown(controller.dispose);
      await pumpHero(
        tester,
        HeroFieldScope(
          variant: HeroFieldVariant.secondary,
          isInvalid: true,
          controller: controller,
          semanticLabel: 'Scoped',
          child: const HeroInput(),
        ),
      );
      expect(_box(tester).variant, HeroFieldVariant.secondary);
      expect(_box(tester).isInvalid, isTrue);
      expect(find.text('from scope'), findsOneWidget);
      // The field root owns the form state.
      expect(
        find.byWidgetPredicate((Widget w) => w is FormField<String>),
        findsNothing,
      );
    });

    testWidgets('takes the scope type and reports its constraints', (
      WidgetTester tester,
    ) async {
      final TextEditingController controller = TextEditingController();
      addTearDown(controller.dispose);
      final List<HeroTextConstraints?> reported = <HeroTextConstraints?>[];
      Widget build({required bool withInput}) => HeroFieldScope(
        controller: controller,
        inputType: HeroInputType.password,
        isRequired: true,
        onInputConstraintsChanged: reported.add,
        child: withInput
            ? const HeroInput(minLength: 4)
            : const SizedBox.shrink(),
      );
      await pumpHero(tester, build(withInput: true));
      expect(_editable(tester).obscureText, isTrue);
      expect(
        reported.last,
        const HeroTextConstraints(
          isRequired: true,
          type: HeroInputType.password,
          minLength: 4,
        ),
      );
      await tester.pumpWidget(heroTestApp(build(withInput: false)));
      expect(reported.last, isNull);
    });

    testWidgets('an explicit type wins over the scope type', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroFieldScope(
          inputType: HeroInputType.password,
          child: HeroInput(type: HeroInputType.email),
        ),
      );
      expect(_editable(tester).obscureText, isFalse);
      expect(_editable(tester).keyboardType, TextInputType.emailAddress);
    });

    testWidgets('own variant wins over the scope', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroFieldScope(
          variant: HeroFieldVariant.secondary,
          child: HeroInput(variant: HeroFieldVariant.primary),
        ),
      );
      expect(_box(tester).variant, HeroFieldVariant.primary);
    });
  });

  group('HeroInput selection', () {
    testWidgets('uses hero selection controls and context menu', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroInput(defaultValue: 'hello world'));
      expect(
        _editable(tester).selectionControls,
        isA<HeroTextSelectionControls>(),
      );
      await tester.longPressAt(
        tester.getTopLeft(find.byType(EditableText)) + const Offset(12, 10),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HeroTextSelectionToolbar), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();
      final TextSelection selection = _editable(tester).controller.selection;
      expect(selection.start, 0);
      expect(selection.end, 'hello world'.length);
    });

    testWidgets('desktop shows a vertical menu without handles', (
      WidgetTester tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pumpHero(tester, const HeroInput(defaultValue: 'hello'));
        expect(
          _editable(tester).selectionControls,
          isNot(isA<HeroTextSelectionControls>()),
        );
        final TestGesture gesture = await tester.startGesture(
          tester.getCenter(find.byType(EditableText)),
          kind: PointerDeviceKind.mouse,
          buttons: kSecondaryMouseButton,
        );
        await gesture.up();
        await tester.pumpAndSettle();
        expect(find.byType(HeroTextSelectionToolbar), findsOneWidget);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
