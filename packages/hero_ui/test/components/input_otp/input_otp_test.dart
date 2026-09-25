import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroThemeData _theme = HeroThemeData.light();

EditableText _editable(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText));

TextEditingValue _value(WidgetTester tester) =>
    _editable(tester).controller.value;

List<HeroFieldBox> _boxes(WidgetTester tester) =>
    tester.widgetList<HeroFieldBox>(find.byType(HeroFieldBox)).toList();

List<int> _activeSlots(WidgetTester tester) => <int>[
  for (final (int i, HeroFieldBox box) in _boxes(tester).indexed)
    if (box.isFocused) i,
];

Widget _sixDigits({
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onCompleted,
  String? value,
  String? defaultValue,
  String? pattern,
  HeroInputOTPPasteTransformer? pasteTransformer,
  bool isDisabled = false,
  bool isInvalid = false,
  HeroFieldVariant variant = HeroFieldVariant.primary,
}) {
  return SizedBox(
    width: 280,
    child: HeroInputOTP(
      maxLength: 6,
      value: value,
      defaultValue: defaultValue,
      onChanged: onChanged,
      onCompleted: onCompleted,
      pattern: pattern,
      pasteTransformer: pasteTransformer,
      isDisabled: isDisabled,
      isInvalid: isInvalid,
      variant: variant,
      semanticLabel: 'Verify account',
      children: const <Widget>[
        HeroInputOTPGroup(
          children: <Widget>[
            HeroInputOTPSlot(index: 0),
            HeroInputOTPSlot(index: 1),
            HeroInputOTPSlot(index: 2),
          ],
        ),
        HeroInputOTPSeparator(),
        HeroInputOTPGroup(
          children: <Widget>[
            HeroInputOTPSlot(index: 3),
            HeroInputOTPSlot(index: 4),
            HeroInputOTPSlot(index: 5),
          ],
        ),
      ],
    ),
  );
}

/// Types [text] one character at a time, like a keyboard.
Future<void> _type(WidgetTester tester, String text) async {
  for (final String char in text.split('')) {
    final TextEditingValue value = _value(tester);
    final TextSelection selection = value.selection;
    final String next = value.text.replaceRange(
      selection.start,
      selection.end,
      char,
    );
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: selection.start + 1),
      ),
    );
    await tester.pump();
  }
}

void main() {
  group('HeroInputOTP layout', () {
    testWidgets('38 × 40 slots, 8 px gaps and a 6 × 2 separator', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _sixDigits());
      final List<Rect> slots = <Rect>[
        for (final Element e in find.byType(HeroInputOTPSlot).evaluate())
          tester.getRect(find.byWidget(e.widget)),
      ];
      expect(slots, hasLength(6));
      // 6 × 38 + 4 gaps + 2 × 8 around the separator + 6 = 282 > 280: the
      // slots shrink a little, like flex-1 min-w-0.
      expect(slots.first.height, 40);
      expect(slots.first.width, closeTo((280 - 4 * 8 - 16 - 6) / 6, 0.01));
      expect(slots[1].left - slots[0].right, 8);
      final Rect separator = tester.getRect(find.byType(HeroInputOTPSeparator));
      expect(separator.size, const Size(6, 2));
      expect(separator.left - slots[2].right, 8);
      expect(slots[3].left - separator.right, 8);
      expect(separator.center.dy, slots.first.center.dy);
    });

    testWidgets('slots are 38 wide when there is room, from the start', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(width: 400, child: HeroInputOTP(maxLength: 4)),
      );
      final Rect first = tester.getRect(find.byType(HeroInputOTPSlot).first);
      expect(first.width, 38);
      expect(first.left, tester.getRect(find.byType(HeroInputOTP)).left);
      expect(find.byType(HeroInputOTPGroup), findsOneWidget);
      expect(find.byType(HeroInputOTPSeparator), findsNothing);
    });

    testWidgets('groupSizes build groups and separators', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInputOTP(maxLength: 6, groupSizes: <int>[2, 2, 2]),
      );
      expect(find.byType(HeroInputOTPGroup), findsNWidgets(3));
      expect(find.byType(HeroInputOTPSeparator), findsNWidgets(2));
      expect(find.byType(HeroInputOTPSlot), findsNWidgets(6));
    });

    testWidgets('unbounded width keeps the natural size', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const UnconstrainedBox(child: HeroInputOTP(maxLength: 4)),
      );
      expect(tester.getSize(find.byType(HeroInputOTP)).width, 4 * 38 + 3 * 8);
    });

    testWidgets('values are text-lg semibold', (WidgetTester tester) async {
      await pumpHero(tester, _sixDigits(defaultValue: '12'));
      await tester.pumpAndSettle();
      final TextStyle style = tester
          .renderObject<RenderParagraph>(find.text('1'))
          .text
          .style!;
      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.w600);
      expect(style.letterSpacing, -0.27);
      expect(style.color, _theme.colors.fieldForeground);
    });

    testWidgets('RTL lays the slots out from the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        _sixDigits(defaultValue: '1'),
        textDirection: TextDirection.rtl,
      );
      await tester.pumpAndSettle();
      final Rect first = tester.getRect(find.byType(HeroInputOTPSlot).first);
      expect(first.right, tester.getRect(find.byType(HeroInputOTP)).right);
    });

    testWidgets('text scale 2.0 grows the slots without overflow', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _sixDigits(defaultValue: '888888'), textScale: 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(HeroInputOTPSlot).first).height,
        2 * 24 + 16,
      );
    });
  });

  group('HeroInputOTP typing', () {
    testWidgets('tapping focuses the first empty slot', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _sixDigits(defaultValue: '12'));
      expect(_activeSlots(tester), isEmpty);
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      expect(_editable(tester).focusNode.hasFocus, isTrue);
      expect(_activeSlots(tester), <int>[2]);
      // The active empty slot shows the caret.
      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets('a complete code activates the last slot', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _sixDigits(defaultValue: '123456'));
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      expect(_activeSlots(tester), <int>[5]);
      expect(
        _value(tester).selection,
        const TextSelection(baseOffset: 5, extentOffset: 6),
      );
    });

    testWidgets('typing advances and completes', (WidgetTester tester) async {
      final List<String> changes = <String>[];
      final List<String> completed = <String>[];
      await pumpHero(
        tester,
        _sixDigits(onChanged: changes.add, onCompleted: completed.add),
      );
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      await _type(tester, '1234');
      expect(changes.last, '1234');
      expect(_activeSlots(tester), <int>[4]);
      expect(completed, isEmpty);
      await _type(tester, '56');
      await tester.pumpAndSettle();
      expect(completed, <String>['123456']);
      expect(find.text('6'), findsOneWidget);
      // The last character stays selected; typing replaces it.
      expect(_activeSlots(tester), <int>[5]);
      await _type(tester, '9');
      expect(changes.last, '123459');
      expect(completed.last, '123459');
    });

    testWidgets('pattern rejects other characters', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await pumpHero(
        tester,
        _sixDigits(
          onChanged: changes.add,
          pattern: HeroInputOTP.regexpOnlyChars,
        ),
      );
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      await _type(tester, 'a1b');
      expect(_value(tester).text, 'ab');
      expect(changes, <String>['a', 'ab']);
      expect(_editable(tester).keyboardType, TextInputType.visiblePassword);

      // The blinking caret never settles; leave the input first.
      FocusManager.instance.primaryFocus?.unfocus();
      await pumpHero(
        tester,
        _sixDigits(pattern: HeroInputOTP.regexpOnlyDigits),
      );
      expect(_editable(tester).keyboardType, TextInputType.number);
    });

    testWidgets('never exceeds maxLength', (WidgetTester tester) async {
      await pumpHero(tester, _sixDigits());
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '12345678',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      await tester.pump();
      expect(_value(tester).text, '123456');
    });

    testWidgets('paste passes through the transformer', (
      WidgetTester tester,
    ) async {
      String? completed;
      await pumpHero(
        tester,
        _sixDigits(
          pattern: HeroInputOTP.regexpOnlyDigits,
          pasteTransformer: (String text) => text.replaceAll('-', ''),
          onCompleted: (String code) => completed = code,
        ),
      );
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '123-456',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );
      await tester.pump();
      expect(_value(tester).text, '123456');
      expect(completed, '123456');
    });

    testWidgets('keyboard paste inserts the clipboard', (
      WidgetTester tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.getData') {
            return <String, dynamic>{'text': '987 654'};
          }
          if (call.method == 'Clipboard.hasStrings') {
            return <String, dynamic>{'value': true};
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpHero(
        tester,
        _sixDigits(pasteTransformer: (String text) => text.replaceAll(' ', '')),
      );
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(_value(tester).text, '987654');
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('Backspace removes the previous character', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _sixDigits(defaultValue: '123'));
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(_value(tester).text, '12');
      expect(_activeSlots(tester), <int>[2]);
    });

    testWidgets('arrow keys move the active slot', (WidgetTester tester) async {
      await pumpHero(tester, _sixDigits(defaultValue: '123'));
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      expect(_activeSlots(tester), <int>[3]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_activeSlots(tester), <int>[2]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(_activeSlots(tester), <int>[1]);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_activeSlots(tester), <int>[2]);
      // Typing replaces the active character and moves on.
      await _type(tester, '9');
      expect(_value(tester).text, '129');
      expect(_activeSlots(tester), <int>[3]);
    });

    testWidgets('losing focus clears the active slot', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _sixDigits());
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      expect(_activeSlots(tester), <int>[0]);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(_activeSlots(tester), isEmpty);
    });

    testWidgets('autofocus and one-time-code autofill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        heroTestApp(const HeroInputOTP(maxLength: 4, autofocus: true)),
      );
      await tester.pump();
      expect(_editable(tester).focusNode.hasFocus, isTrue);
      expect(_editable(tester).autofillHints, <String>[
        AutofillHints.oneTimeCode,
      ]);
    });
  });

  group('HeroInputOTP value', () {
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
            return _sixDigits(
              value: value,
              onChanged: (String v) => setState(() => value = v),
            );
          },
        ),
      );
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      await _type(tester, '12');
      expect(value, '12');
      update(() => value = '');
      await tester.pump();
      expect(_value(tester).text, '');
      expect(find.text('1'), findsNothing);
    });

    testWidgets('an external controller', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(
        text: '42',
      );
      addTearDown(controller.dispose);
      await pumpHero(
        tester,
        HeroInputOTP(maxLength: 4, controller: controller),
      );
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);
      controller.text = '4242';
      await tester.pumpAndSettle();
      expect(find.text('2'), findsNWidgets(2));
    });

    testWidgets('placeholder characters show while empty', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInputOTP(maxLength: 4, placeholder: '0000'),
      );
      expect(find.text('0'), findsNWidgets(4));
      final TextStyle style = tester
          .renderObject<RenderParagraph>(find.text('0').first)
          .text
          .style!;
      expect(style.color, _theme.colors.fieldPlaceholder);
    });
  });

  group('HeroInputOTP states', () {
    testWidgets('variant, invalid and filled reach the slots', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        _sixDigits(
          defaultValue: '1',
          isInvalid: true,
          variant: HeroFieldVariant.secondary,
        ),
      );
      final List<HeroFieldBox> boxes = _boxes(tester);
      expect(
        boxes.every(
          (HeroFieldBox b) => b.variant == HeroFieldVariant.secondary,
        ),
        isTrue,
      );
      expect(boxes.every((HeroFieldBox b) => b.isInvalid), isTrue);
      expect(boxes[0].style?.backgroundColor, _theme.colors.defaultColor);
      expect(boxes[1].style?.backgroundColor, isNull);
    });

    testWidgets('disabled cannot be focused and fades the slots', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _sixDigits(isDisabled: true));
      expect(_boxes(tester).every((HeroFieldBox b) => b.isDisabled), isTrue);
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      expect(_editable(tester).focusNode.hasFocus, isFalse);
      expect(_editable(tester).readOnly, isTrue);
    });

    testWidgets('a disabled fieldset disables the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroFieldset(isDisabled: true, children: <Widget>[_sixDigits()]),
      );
      expect(_boxes(tester).every((HeroFieldBox b) => b.isDisabled), isTrue);
    });

    testWidgets('slot style overrides the active background', (
      WidgetTester tester,
    ) async {
      final HeroFieldStyle style = HeroFieldStyle(
        borderRadius: BorderRadius.circular(8),
        backgroundColor: _theme.colors.defaultColor,
        focusBackgroundColor: _theme.colors.accentSoft,
      );
      await pumpHero(
        tester,
        HeroInputOTP(
          maxLength: 2,
          children: <Widget>[
            HeroInputOTPGroup(
              children: <Widget>[
                HeroInputOTPSlot(index: 0, style: style),
                HeroInputOTPSlot(index: 1, style: style),
              ],
            ),
          ],
        ),
      );
      expect(
        _boxes(tester).first.style?.focusBackgroundColor,
        _theme.colors.accentSoft,
      );
    });

    testWidgets('the caret blinks and stays still under reduced motion', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _sixDigits());
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      double opacity() => tester
          .widget<FadeTransition>(
            find
                .descendant(
                  of: find.byType(HeroInputOTPSlot).first,
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value;
      expect(opacity(), 1);
      await tester.pump(const Duration(milliseconds: 360));
      expect(opacity(), 0);
      await tester.pump(const Duration(milliseconds: 840));
      expect(opacity(), closeTo(1, 0.01));

      await pumpHero(
        tester,
        HeroTheme(
          data: _theme.copyWith(motion: const HeroMotion(reduceMotion: true)),
          child: _sixDigits(),
        ),
      );
      await tester.tap(find.byType(HeroInputOTP));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 360));
      expect(opacity(), 1);
    });
  });

  group('HeroInputOTP forms', () {
    testWidgets('validates, saves under its name and resets', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      Map<String, Object?>? submitted;
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          onSubmit: (Map<String, Object?> data) => submitted = data,
          child: HeroInputOTP(
            maxLength: 4,
            name: 'code',
            defaultValue: '12',
            validator: (String? value) =>
                (value ?? '').length < 4 ? 'Please enter all 4 digits' : null,
            children: const <Widget>[
              HeroInputOTPGroup(
                children: <Widget>[
                  HeroInputOTPSlot(index: 0),
                  HeroInputOTPSlot(index: 1),
                  HeroInputOTPSlot(index: 2),
                  HeroInputOTPSlot(index: 3),
                ],
              ),
              HeroFieldError(),
            ],
          ),
        ),
      );
      expect(form.currentState!.submit(), isFalse);
      await tester.pump();
      expect(find.text('Please enter all 4 digits'), findsOneWidget);
      expect(_boxes(tester).first.isInvalid, isTrue);

      await tester.tap(find.byType(HeroInputOTPSlot).first);
      await tester.pump();
      await _type(tester, '34');
      // Enter submits the form.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submitted, <String, Object?>{'code': '1234'});

      form.currentState!.reset();
      await tester.pump();
      expect(_value(tester).text, '12');
    });
  });

  group('HeroInputOTP semantics', () {
    testWidgets('one labelled text field with the code', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(tester, _sixDigits(defaultValue: '12', isInvalid: true));
      final SemanticsNode node = tester.getSemantics(find.byType(EditableText));
      final SemanticsData data = node.getSemanticsData();
      expect(data.label, 'Verify account');
      expect(data.value, '12');
      expect(data.maxValueLength, 6);
      expect(data.currentValueLength, 2);
      expect(data.validationResult, SemanticsValidationResult.invalid);
      expect(data.flagsCollection.isTextField, isTrue);
      handle.dispose();
    });
  });

  testWidgets('debug properties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const HeroInputOTP(
      maxLength: 6,
      pattern: HeroInputOTP.regexpOnlyDigits,
      isDisabled: true,
    ).debugFillProperties(builder);
    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();
    expect(description, contains('maxLength: 6'));
    expect(description, contains(r'pattern: "^\d+$"'));
    expect(description, contains('disabled'));
  });
}
