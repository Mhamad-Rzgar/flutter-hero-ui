import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Finder _input(String label) => find.byWidgetPredicate(
  (Widget w) => w is HeroInput && w.semanticLabel == label,
);

Finder _editable(String label) =>
    find.descendant(of: _input(label), matching: find.byType(EditableText));

bool _invalid(WidgetTester tester, String label) => tester
    .widget<HeroFieldBox>(
      find.descendant(of: _input(label), matching: find.byType(HeroFieldBox)),
    )
    .isInvalid;

/// A sign-up form with a required email, a password and submit/reset
/// buttons.
Widget _signUp({
  GlobalKey<HeroFormState>? key,
  ValueChanged<Map<String, Object?>>? onSubmit,
  VoidCallback? onInvalid,
  VoidCallback? onReset,
  VoidCallback? onChanged,
  VoidCallback? onSubmitPressed,
  HeroValidationBehavior behavior = HeroValidationBehavior.native,
  bool focusInvalidField = true,
  FocusNode? emailFocus,
  FocusNode? passwordFocus,
}) {
  return HeroForm(
    key: key,
    onSubmit: onSubmit,
    onInvalid: onInvalid,
    onReset: onReset,
    onChanged: onChanged,
    validationBehavior: behavior,
    focusInvalidField: focusInvalidField,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        HeroInput(
          name: 'email',
          semanticLabel: 'Email',
          type: HeroInputType.email,
          isRequired: true,
          focusNode: emailFocus,
        ),
        HeroInput(
          name: 'password',
          semanticLabel: 'Password',
          type: HeroInputType.password,
          defaultValue: 'secret',
          minLength: 4,
          focusNode: passwordFocus,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            HeroButton(
              type: HeroButtonType.submit,
              onPressed: onSubmitPressed,
              child: const Text('Submit'),
            ),
            const HeroButton(
              type: HeroButtonType.reset,
              variant: HeroButtonVariant.secondary,
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    ),
  );
}

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  group('HeroForm native validation', () {
    testWidgets('submits the named values when every field is valid', (
      WidgetTester tester,
    ) async {
      Map<String, Object?>? submitted;
      bool invalidCalled = false;
      await pumpHero(
        tester,
        _signUp(
          onSubmit: (Map<String, Object?> data) => submitted = data,
          onInvalid: () => invalidCalled = true,
        ),
      );
      await tester.enterText(_editable('Email'), 'jane@example.com');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(submitted, <String, Object?>{
        'email': 'jane@example.com',
        'password': 'secret',
      });
      expect(invalidCalled, isFalse);
    });

    testWidgets('blocks submission, shows errors and focuses the first '
        'invalid field', (WidgetTester tester) async {
      final FocusNode emailFocus = FocusNode();
      addTearDown(emailFocus.dispose);
      Map<String, Object?>? submitted;
      int invalidCalls = 0;
      await pumpHero(
        tester,
        _signUp(
          emailFocus: emailFocus,
          onSubmit: (Map<String, Object?> data) => submitted = data,
          onInvalid: () => invalidCalls++,
        ),
      );
      expect(_invalid(tester, 'Email'), isFalse);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(submitted, isNull);
      expect(invalidCalls, 1);
      expect(_invalid(tester, 'Email'), isTrue);
      expect(_invalid(tester, 'Password'), isFalse);
      expect(emailFocus.hasFocus, isTrue);
    });

    testWidgets('focuses the first invalid field in focus order', (
      WidgetTester tester,
    ) async {
      final FocusNode emailFocus = FocusNode();
      final FocusNode passwordFocus = FocusNode();
      addTearDown(emailFocus.dispose);
      addTearDown(passwordFocus.dispose);
      await pumpHero(
        tester,
        _signUp(emailFocus: emailFocus, passwordFocus: passwordFocus),
      );
      await tester.enterText(_editable('Email'), 'jane@example.com');
      await tester.enterText(_editable('Password'), 'ab');
      emailFocus.unfocus();
      await tester.pump();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(passwordFocus.hasFocus, isTrue);
      expect(_invalid(tester, 'Password'), isTrue);
    });

    testWidgets('focusInvalidField: false leaves focus alone', (
      WidgetTester tester,
    ) async {
      final FocusNode emailFocus = FocusNode();
      addTearDown(emailFocus.dispose);
      await pumpHero(
        tester,
        _signUp(emailFocus: emailFocus, focusInvalidField: false),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(emailFocus.hasFocus, isFalse);
      expect(_invalid(tester, 'Email'), isTrue);
    });

    testWidgets('submit() and validate() on the state', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> key = GlobalKey<HeroFormState>();
      Map<String, Object?>? submitted;
      await pumpHero(
        tester,
        _signUp(
          key: key,
          onSubmit: (Map<String, Object?> data) => submitted = data,
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      expect(key.currentState!.submit(), isFalse);
      await tester.enterText(_editable('Email'), 'jane@example.com');
      expect(key.currentState!.validate(), isTrue);
      expect(key.currentState!.submit(), isTrue);
      expect(submitted!['email'], 'jane@example.com');
      expect(key.currentState!.form, isA<FormState>());
    });
  });

  group('HeroForm aria validation', () {
    testWidgets('never blocks submission nor validates on submit', (
      WidgetTester tester,
    ) async {
      Map<String, Object?>? submitted;
      bool invalidCalled = false;
      await pumpHero(
        tester,
        _signUp(
          behavior: HeroValidationBehavior.aria,
          onSubmit: (Map<String, Object?> data) => submitted = data,
          onInvalid: () => invalidCalled = true,
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(submitted, <String, Object?>{'email': '', 'password': 'secret'});
      expect(invalidCalled, isFalse);
      expect(_invalid(tester, 'Email'), isFalse);
    });

    testWidgets('fields read the behaviour and server errors', (
      WidgetTester tester,
    ) async {
      late HeroFormState state;
      Widget build(Map<String, List<String>>? errors) => HeroForm(
        validationBehavior: HeroValidationBehavior.aria,
        validationErrors: errors,
        child: Builder(
          builder: (BuildContext context) {
            state = HeroForm.of(context);
            return Text(state.validationErrorsFor('username').join());
          },
        ),
      );
      await pumpHero(tester, build(null));
      expect(state.validationBehavior, HeroValidationBehavior.aria);
      expect(state.validationErrorsFor('username'), isEmpty);
      expect(state.validationErrorsFor(null), isEmpty);
      await tester.pumpWidget(
        heroTestApp(
          build(const <String, List<String>>{
            'username': <String>['Username is taken'],
          }),
        ),
      );
      expect(find.text('Username is taken'), findsOneWidget);
    });
  });

  group('HeroForm reset and values', () {
    testWidgets('reset restores the initial values and clears errors', (
      WidgetTester tester,
    ) async {
      bool reset = false;
      await pumpHero(tester, _signUp(onReset: () => reset = true));
      await tester.enterText(_editable('Password'), 'ab');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(_invalid(tester, 'Email'), isTrue);
      expect(_invalid(tester, 'Password'), isTrue);

      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(reset, isTrue);
      expect(_invalid(tester, 'Email'), isFalse);
      expect(_invalid(tester, 'Password'), isFalse);
      expect(
        tester.widget<EditableText>(_editable('Password')).controller.text,
        'secret',
      );
    });

    testWidgets('collects fields sharing a name in a list and skips '
        'disabled fields', (WidgetTester tester) async {
      final GlobalKey<HeroFormState> key = GlobalKey<HeroFormState>();
      final List<String?> saved = <String?>[];
      await pumpHero(
        tester,
        HeroForm(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroInput(name: 'tag', defaultValue: 'a', onSaved: saved.add),
              const HeroInput(name: 'tag', defaultValue: 'b'),
              const HeroInput(name: 'tag', defaultValue: 'c'),
              const HeroInput(
                name: 'locked',
                defaultValue: 'x',
                isDisabled: true,
              ),
              const HeroInput(defaultValue: 'unnamed'),
            ],
          ),
        ),
      );
      expect(key.currentState!.save(), <String, Object?>{
        'tag': <Object?>['a', 'b', 'c'],
      });
      expect(saved, <String?>['a']);
      // Values are only collected while saving.
      key.currentState!.addValue('late', 'ignored');
      expect(key.currentState!.save().containsKey('late'), isFalse);
    });

    testWidgets('onChanged reports edits', (WidgetTester tester) async {
      int changes = 0;
      await pumpHero(tester, _signUp(onChanged: () => changes++));
      await tester.enterText(_editable('Email'), 'j');
      expect(changes, greaterThan(0));
    });
  });

  group('HeroForm buttons and keyboard', () {
    testWidgets('submit button runs onPressed first', (
      WidgetTester tester,
    ) async {
      final List<String> calls = <String>[];
      await pumpHero(
        tester,
        _signUp(
          onSubmitPressed: () => calls.add('pressed'),
          onInvalid: () => calls.add('invalid'),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(calls, <String>['pressed', 'invalid']);
    });

    testWidgets('form buttons outside a form only run onPressed', (
      WidgetTester tester,
    ) async {
      int pressed = 0;
      await pumpHero(
        tester,
        HeroButton(
          type: HeroButtonType.submit,
          onPressed: () => pressed++,
          child: const Text('Submit'),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(pressed, 1);
    });

    testWidgets('Enter on a focused submit button submits', (
      WidgetTester tester,
    ) async {
      int invalid = 0;
      await pumpHero(tester, _signUp(onInvalid: () => invalid++));
      // Email → Password → Submit.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(invalid, 1);
    });

    testWidgets('the done action in a single-line input submits', (
      WidgetTester tester,
    ) async {
      Map<String, Object?>? submitted;
      await pumpHero(
        tester,
        _signUp(onSubmit: (Map<String, Object?> data) => submitted = data),
      );
      await tester.enterText(_editable('Email'), 'jane@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(submitted?['email'], 'jane@example.com');
    });

    testWidgets('the next action and multi-line inputs do not submit', (
      WidgetTester tester,
    ) async {
      int submits = 0;
      await pumpHero(
        tester,
        HeroForm(
          onSubmit: (_) => submits++,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroInput(
                semanticLabel: 'First',
                textInputAction: TextInputAction.next,
              ),
              HeroTextArea(semanticLabel: 'Notes'),
            ],
          ),
        ),
      );
      await tester.enterText(_editable('First'), 'a');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).last, 'b');
      await tester.testTextInput.receiveAction(TextInputAction.newline);
      await tester.pumpAndSettle();
      expect(submits, 0);
    });

    testWidgets('reset button resets', (WidgetTester tester) async {
      final GlobalKey<HeroFormState> key = GlobalKey<HeroFormState>();
      await pumpHero(tester, _signUp(key: key));
      await tester.enterText(_editable('Password'), 'changed');
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(key.currentState!.save()['password'], 'secret');
    });
  });

  group('HeroForm integration', () {
    testWidgets('passes autovalidateMode to the Flutter form', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroForm(
          autovalidateMode: AutovalidateMode.always,
          child: HeroInput(semanticLabel: 'Email', isRequired: true),
        ),
      );
      expect(
        tester.widget<Form>(find.byType(Form)).autovalidateMode,
        AutovalidateMode.always,
      );
      await tester.pump();
      expect(_invalid(tester, 'Email'), isTrue);
    });

    testWidgets('HeroForm.of throws outside a form, maybeOf returns null', (
      WidgetTester tester,
    ) async {
      late BuildContext context;
      await pumpHero(
        tester,
        Builder(
          builder: (BuildContext c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      expect(HeroForm.maybeOf(context), isNull);
      expect(() => HeroForm.of(context), throwsAssertionError);
    });

    testWidgets('semantics: a labelled form', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroForm(
          semanticLabel: 'Sign up',
          child: HeroInput(semanticLabel: 'Email'),
        ),
      );
      final SemanticsNode form = tester.getSemantics(find.byType(Form));
      expect(form.getSemanticsData().role, SemanticsRole.form);
      expect(form.parent!.label, 'Sign up');
      handle.dispose();
    });

    testWidgets('lays out its child in RTL and at text scale 2.0', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        SizedBox(width: 360, child: _signUp()),
        textDirection: TextDirection.rtl,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('debug properties', (WidgetTester tester) async {
      final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
      const HeroForm(
        validationBehavior: HeroValidationBehavior.aria,
        child: SizedBox(),
      ).debugFillProperties(builder);
      expect(
        builder.properties.map((DiagnosticsNode p) => p.toString()),
        contains('validationBehavior: aria'),
      );
    });
  });
}
