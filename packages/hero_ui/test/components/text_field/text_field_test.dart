import 'dart:ui' show SemanticsInputType, Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroColors _colors = HeroThemeData.light().colors;

Finder get _editable => find.byType(EditableText);

EditableText _editableWidget(WidgetTester tester) =>
    tester.widget<EditableText>(_editable);

HeroFieldBox _box(WidgetTester tester) =>
    tester.widget<HeroFieldBox>(find.byType(HeroFieldBox));

/// Finds the rich text whose visible characters (ignoring the placeholder of
/// the asterisk gap) are [text].
Finder _rich(String text) => find.byWidgetPredicate(
  (Widget w) =>
      w is RichText &&
      w.text.toPlainText(includeSemanticsLabels: false).replaceAll('￼', '') ==
          text,
);

Color? _labelColor(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(_rich(text)).text.style!.color;

/// Moves focus away from the text field (a blur).
Future<void> _blur(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  group('HeroTextField layout', () {
    testWidgets('builds label, input, description and a hidden error', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(
          label: 'Username',
          placeholder: 'Enter username',
          description: 'Choose a unique username',
          errorMessage: 'Too short',
        ),
      );
      expect(_rich('Username'), findsOneWidget);
      expect(find.text('Enter username'), findsOneWidget);
      expect(find.text('Choose a unique username'), findsOneWidget);
      expect(find.byType(HeroInput), findsOneWidget);
      expect(find.text('Too short'), findsNothing);
      // 20 (label) + 4 + 36 (input) + 4 + 16 (description); the empty error
      // takes no gap.
      expect(tester.getSize(find.byType(HeroTextField)).height, 80);
      expect(
        tester.getTopLeft(find.byType(HeroInput)).dy -
            tester.getBottomLeft(_rich('Username')).dy,
        4,
      );
    });

    testWidgets('shrink-wraps its widest part and stretches the others', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroTextField(label: 'Email'));
      final double inputWidth = HeroFieldMetrics.defaultWidth(
        HeroThemeData.light(),
      );
      expect(tester.getSize(find.byType(HeroTextField)).width, inputWidth);
      expect(tester.getSize(find.byType(HeroInput)).width, inputWidth);
      expect(tester.getSize(find.byType(HeroLabel)).width, inputWidth);

      await tester.pumpWidget(
        heroTestApp(
          const HeroTextField(
            label: 'Email',
            description:
                'A description that is much wider than the default input',
          ),
        ),
      );
      final double wide = tester.getSize(find.byType(HeroDescription)).width;
      expect(wide, greaterThan(inputWidth));
      expect(tester.getSize(find.byType(HeroInput)).width, wide);
    });

    testWidgets('fills a tight width', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(width: 256, child: HeroTextField(label: 'Email')),
      );
      expect(tester.getSize(find.byType(HeroInput)).width, 256);
    });

    testWidgets('fullWidth fills a bounded width', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const Center(
          child: SizedBox(
            width: 400,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: HeroTextField(label: 'Your name', fullWidth: true),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(HeroTextField)).width, 400);
      expect(tester.getSize(find.byType(HeroInput)).width, 400);
    });

    testWidgets('hidden parts take no gap and spacing is configurable', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(
          label: 'Username',
          description: 'Hidden while invalid',
          errorMessage: 'Username must be at least 3 characters',
          isInvalid: true,
          spacing: 6,
        ),
      );
      expect(find.text('Hidden while invalid'), findsNothing);
      expect(
        tester.getTopLeft(find.byType(HeroFieldError)).dy -
            tester.getBottomLeft(find.byType(HeroInput)).dy,
        6,
      );
    });

    testWidgets('multiline builds a text area with rows', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(
          label: 'Message',
          isMultiline: true,
          rows: 4,
          placeholder: 'Write your message here...',
        ),
      );
      expect(find.byType(HeroTextArea), findsOneWidget);
      expect(tester.widget<HeroTextArea>(find.byType(HeroTextArea)).rows, 4);
      // 4 lines of 20 + 16 padding.
      expect(tester.getSize(find.byType(HeroTextArea)).height, 96);
    });

    testWidgets('RTL aligns the label to the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(width: 300, child: HeroTextField(label: 'Name')),
        textDirection: TextDirection.rtl,
      );
      expect(
        tester.getTopRight(_rich('Name')).dx,
        tester.getTopRight(find.byType(HeroTextField)).dx,
      );
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 240,
          child: HeroTextField(
            label: 'Email address',
            placeholder: 'you@example.com',
            description: "We'll never share your email with anyone else.",
            isRequired: true,
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(HeroInput)).height, greaterThan(40));
    });

    testWidgets('intrinsic sizes follow the parts', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const IntrinsicHeight(
          child: HeroTextField(label: 'Email', description: 'Helpful text'),
        ),
      );
      expect(tester.getSize(find.byType(HeroTextField)).height, 80);
      final RenderBox box = tester.renderObject(find.byType(HeroFieldLayout));
      expect(box.getMinIntrinsicWidth(double.infinity), greaterThan(0));
      expect(box.getMaxIntrinsicHeight(192), 80);
      expect(box.getMinIntrinsicHeight(192), 80);
      expect(box.getDryLayout(const BoxConstraints(maxWidth: 300)).height, 80);
    });
  });

  group('HeroTextField states', () {
    testWidgets('variant reaches the input', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroTextField(label: 'Name', variant: HeroFieldVariant.secondary),
      );
      expect(_box(tester).variant, HeroFieldVariant.secondary);
    });

    testWidgets('required shows the label asterisk', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(label: 'Full Name', isRequired: true),
      );
      expect(_rich('Full Name*'), findsOneWidget);
    });

    testWidgets('disabled fades the label and disables the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(
          label: 'Account ID',
          value: 'USR-12345',
          description: 'This field cannot be edited',
          isDisabled: true,
        ),
      );
      expect(_box(tester).isDisabled, isTrue);
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(
                of: _rich('Account ID'),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        0.5,
      );
      // The description keeps its look.
      expect(
        find.ancestor(
          of: find.text('This field cannot be edited'),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
      await tester.tap(find.byType(HeroInput), warnIfMissed: false);
      await tester.pump();
      expect(_editableWidget(tester).focusNode.hasFocus, isFalse);
    });

    testWidgets('read-only keeps the input focusable but not editable', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(label: 'Code', value: 'ABC', isReadOnly: true),
      );
      await tester.tap(find.byType(HeroInput));
      await tester.pump();
      expect(_editableWidget(tester).focusNode.hasFocus, isTrue);
      expect(_editableWidget(tester).readOnly, isTrue);
    });

    testWidgets('type reaches a composed input', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroTextField(
          type: HeroInputType.password,
          children: <Widget>[HeroLabel.text('Password'), HeroInput()],
        ),
      );
      expect(_editableWidget(tester).obscureText, isTrue);
    });

    testWidgets('pressing the label focuses the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroTextField(label: 'Email'));
      await tester.tap(_rich('Email'));
      await tester.pump();
      expect(_editableWidget(tester).focusNode.hasFocus, isTrue);
      expect(_box(tester).isFocused, isTrue);
    });

    testWidgets('autofocus and a caller focus node', (
      WidgetTester tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpHero(
        tester,
        HeroTextField(label: 'Email', focusNode: focusNode, autofocus: true),
      );
      expect(focusNode.hasFocus, isTrue);
      expect(_editableWidget(tester).focusNode, focusNode);
    });

    testWidgets('keyboard Tab moves focus into the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroTextField(label: 'Email'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_editableWidget(tester).focusNode.hasFocus, isTrue);
    });

    testWidgets('builder receives the field state', (
      WidgetTester tester,
    ) async {
      final List<HeroTextFieldState> states = <HeroTextFieldState>[];
      await pumpHero(
        tester,
        HeroTextField(
          isRequired: true,
          builder: (BuildContext context, HeroTextFieldState state) {
            states.add(state);
            return <Widget>[
              HeroLabel.text(state.isFocusWithin ? 'Focused' : 'Email'),
              const HeroInput(),
            ];
          },
        ),
      );
      expect(states.last.isRequired, isTrue);
      expect(states.last.isFocusWithin, isFalse);
      await tester.tap(find.byType(HeroInput));
      await tester.pump();
      expect(states.last.isFocusWithin, isTrue);
      expect(_rich('Focused*'), findsOneWidget);
      expect(
        states.last,
        const HeroTextFieldState(isRequired: true, isFocusWithin: true),
      );
      expect(states.last.hashCode, isNot(states.first.hashCode));
    });
  });

  group('HeroTextField value', () {
    testWidgets('uncontrolled: defaultValue and onChanged', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await pumpHero(
        tester,
        HeroTextField(
          label: 'Name',
          defaultValue: 'Jane',
          onChanged: changes.add,
        ),
      );
      expect(find.text('Jane'), findsOneWidget);
      await tester.enterText(_editable, 'Janet');
      expect(changes, <String>['Janet']);
    });

    testWidgets('controlled: value follows the parent without onChanged', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      String value = '';
      late StateSetter setOuter;
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setOuter = setState;
            return HeroTextField(
              label: 'Display name',
              value: value,
              onChanged: (String v) {
                changes.add(v);
                setState(() => value = v.toUpperCase());
              },
            );
          },
        ),
      );
      await tester.enterText(_editable, 'jane');
      await tester.pump();
      expect(_editableWidget(tester).controller.text, 'JANE');
      expect(changes, <String>['jane']);
      setOuter(() => value = 'Reset');
      await tester.pump();
      expect(_editableWidget(tester).controller.text, 'Reset');
      expect(changes, <String>['jane']);
    });

    testWidgets('external controller', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController(
        text: 'from controller',
      );
      addTearDown(controller.dispose);
      await pumpHero(
        tester,
        HeroTextField(label: 'Name', controller: controller),
      );
      expect(find.text('from controller'), findsOneWidget);
      await tester.enterText(_editable, 'typed');
      expect(controller.text, 'typed');
    });

    testWidgets('onSubmitted and maxLength of the built input', (
      WidgetTester tester,
    ) async {
      String? submitted;
      await pumpHero(
        tester,
        HeroTextField(
          label: 'Code',
          maxLength: 3,
          onSubmitted: (String v) => submitted = v,
        ),
      );
      await tester.enterText(_editable, 'abcdef');
      expect(_editableWidget(tester).controller.text, 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, 'abc');
    });
  });

  group('HeroTextField native validation', () {
    testWidgets('shows validator errors after a blur that follows an edit', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroTextField(
          label: 'Username',
          description: 'Choose a unique username',
          validator: (String? v) =>
              (v ?? '').length < 3 ? 'At least 3 characters' : null,
        ),
      );
      // Focus and blur without an edit: nothing is committed.
      await tester.tap(find.byType(HeroInput));
      await _blur(tester);
      expect(find.text('At least 3 characters'), findsNothing);

      await tester.enterText(_editable, 'jr');
      await tester.pump();
      expect(find.text('At least 3 characters'), findsNothing);
      await _blur(tester);
      expect(find.text('At least 3 characters'), findsOneWidget);
      expect(find.text('Choose a unique username'), findsNothing);
      expect(_box(tester).isInvalid, isTrue);
      expect(_labelColor(tester, 'Username'), _colors.danger);

      // The error stays while editing until the next commit.
      await tester.enterText(_editable, 'jane');
      await tester.pump();
      expect(find.text('At least 3 characters'), findsOneWidget);
      await _blur(tester);
      expect(find.text('At least 3 characters'), findsNothing);
      expect(find.text('Choose a unique username'), findsOneWidget);
    });

    testWidgets('form validation shows built-in constraint errors', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await pumpHero(
        tester,
        Form(
          key: form,
          child: const HeroTextField(
            label: 'Email',
            type: HeroInputType.email,
            isRequired: true,
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Please fill out this field.'), findsOneWidget);
      await tester.enterText(_editable, 'jane');
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Please enter an email address.'), findsOneWidget);
      await tester.enterText(_editable, 'jane@example.com');
      expect(form.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.byType(Text), findsNWidgets(1));
    });

    testWidgets('the validator runs before the built-in constraints', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await pumpHero(
        tester,
        Form(
          key: form,
          child: HeroTextField(
            label: 'Email',
            isRequired: true,
            validator: (String? v) =>
                (v ?? '').contains('@') ? null : 'Email must include @',
          ),
        ),
      );
      form.currentState!.validate();
      await tester.pump();
      expect(find.text('Email must include @'), findsOneWidget);
    });

    testWidgets('constraints set on a composed input are validated', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await pumpHero(
        tester,
        Form(
          key: form,
          child: const HeroTextField(
            type: HeroInputType.number,
            children: <Widget>[
              HeroLabel.text('Age'),
              HeroInput(min: 0, max: 150, placeholder: '21'),
              HeroFieldError(),
            ],
          ),
        ),
      );
      await tester.enterText(_editable, '200');
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(
        find.text('Value must be less than or equal to 150.'),
        findsOneWidget,
      );
      await tester.enterText(_editable, '42');
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('autovalidateMode onUserInteraction validates while typing', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroTextField(
          label: 'Username',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? v) => v == 'bad' ? 'Bad value' : null,
        ),
      );
      expect(find.text('Bad value'), findsNothing);
      await tester.enterText(_editable, 'bad');
      await tester.pump();
      expect(find.text('Bad value'), findsOneWidget);
    });

    testWidgets('disabled fields are neither validated nor submitted', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          child: const HeroTextField(
            label: 'Account ID',
            name: 'id',
            isRequired: true,
            isDisabled: true,
          ),
        ),
      );
      expect(form.currentState!.validate(), isTrue);
      expect(form.currentState!.save(), isEmpty);
    });
  });

  group('HeroTextField controlled invalid', () {
    testWidgets('isInvalid shows the error and marks the parts', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(
          type: HeroInputType.email,
          isInvalid: true,
          children: <Widget>[
            HeroLabel.text('Email'),
            HeroInput(placeholder: 'user@example.com'),
            HeroFieldError.text('Please enter a valid email address'),
          ],
        ),
      );
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(_box(tester).isInvalid, isTrue);
      expect(_labelColor(tester, 'Email'), _colors.danger);
    });

    testWidgets('isInvalid without a message and an empty FieldError', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await pumpHero(
        tester,
        Form(
          key: form,
          child: const HeroTextField(label: 'Name', isInvalid: true),
        ),
      );
      expect(find.byType(HeroFieldError), findsOneWidget);
      expect(tester.getSize(find.byType(HeroFieldError)).height, 0);
      // A field marked invalid blocks the form.
      expect(form.currentState!.validate(), isFalse);
    });

    testWidgets('isInvalid false overrides a failing validator', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await pumpHero(
        tester,
        Form(
          key: form,
          child: HeroTextField(
            label: 'Name',
            isInvalid: false,
            validator: (String? v) => 'Always wrong',
          ),
        ),
      );
      form.currentState!.validate();
      await tester.pump();
      expect(find.text('Always wrong'), findsNothing);
      expect(_box(tester).isInvalid, isFalse);
    });
  });

  group('HeroTextField aria validation', () {
    testWidgets('shows validator errors in realtime and ignores required', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await pumpHero(
        tester,
        Form(
          key: form,
          child: HeroTextField(
            label: 'Username',
            isRequired: true,
            validationBehavior: HeroValidationBehavior.aria,
            validator: (String? v) => (v ?? '').isNotEmpty && v!.length < 3
                ? 'At least 3 characters'
                : null,
          ),
        ),
      );
      expect(find.text('At least 3 characters'), findsNothing);
      await tester.enterText(_editable, 'jr');
      await tester.pump();
      expect(find.text('At least 3 characters'), findsOneWidget);
      await tester.enterText(_editable, 'jane');
      await tester.pump();
      expect(find.text('At least 3 characters'), findsNothing);
      await tester.enterText(_editable, '');
      expect(form.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Please fill out this field.'), findsNothing);
    });

    testWidgets('inherits the behaviour of a HeroForm', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroForm(
          validationBehavior: HeroValidationBehavior.aria,
          child: HeroTextField(
            label: 'Code',
            validator: (String? v) => v == 'x' ? 'Not x' : null,
          ),
        ),
      );
      await tester.enterText(_editable, 'x');
      await tester.pump();
      expect(find.text('Not x'), findsOneWidget);
    });

    testWidgets('a field can override the form behaviour', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroForm(
          validationBehavior: HeroValidationBehavior.aria,
          child: HeroTextField(
            label: 'Code',
            validationBehavior: HeroValidationBehavior.native,
            validator: (String? v) => v == 'x' ? 'Not x' : null,
          ),
        ),
      );
      await tester.enterText(_editable, 'x');
      await tester.pump();
      expect(find.text('Not x'), findsNothing);
    });
  });

  group('HeroTextField server errors', () {
    testWidgets('field errors show immediately and clear on edit', (
      WidgetTester tester,
    ) async {
      Widget build(List<String> errors) => HeroTextField(
        label: 'Username',
        description: 'Pick a name',
        validationErrors: errors,
      );
      final List<String> errors = <String>['Username is taken'];
      await pumpHero(tester, build(errors));
      expect(find.text('Username is taken'), findsOneWidget);
      expect(find.text('Pick a name'), findsNothing);

      await tester.enterText(_editable, 'jane');
      await tester.pump();
      expect(find.text('Username is taken'), findsNothing);
      expect(find.text('Pick a name'), findsOneWidget);

      // The same errors stay cleared; a new list shows them again.
      await tester.pumpWidget(heroTestApp(build(errors)));
      expect(find.text('Username is taken'), findsNothing);
      await tester.pumpWidget(heroTestApp(build(<String>['Still taken'])));
      expect(find.text('Still taken'), findsOneWidget);
    });

    testWidgets('form errors by name block submission until edited', (
      WidgetTester tester,
    ) async {
      Map<String, Object?>? submitted;
      await pumpHero(
        tester,
        HeroForm(
          validationErrors: const <String, List<String>>{
            'username': <String>['Username is taken', 'Try another'],
          },
          onSubmit: (Map<String, Object?> data) => submitted = data,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroTextField(
                label: 'Username',
                name: 'username',
                defaultValue: 'jane',
              ),
              HeroTextField(label: 'Bio', name: 'bio'),
              HeroButton(type: HeroButtonType.submit, child: Text('Submit')),
            ],
          ),
        ),
      );
      expect(find.text('Username is taken Try another'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(submitted, isNull);

      await tester.enterText(_editable.first, 'janet');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(submitted, <String, Object?>{'username': 'janet', 'bio': ''});
    });
  });

  group('HeroTextField forms', () {
    testWidgets('submits its named value and focuses itself when invalid', (
      WidgetTester tester,
    ) async {
      Map<String, Object?>? submitted;
      await pumpHero(
        tester,
        HeroForm(
          onSubmit: (Map<String, Object?> data) => submitted = data,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroTextField(
                label: 'Email',
                name: 'email',
                type: HeroInputType.email,
                isRequired: true,
              ),
              HeroButton(type: HeroButtonType.submit, child: Text('Submit')),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(submitted, isNull);
      expect(find.text('Please fill out this field.'), findsOneWidget);
      expect(_editableWidget(tester).focusNode.hasFocus, isTrue);

      await tester.enterText(_editable, 'jane@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(submitted, <String, Object?>{'email': 'jane@example.com'});
    });

    testWidgets('onSaved and reset', (WidgetTester tester) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      final List<String> changes = <String>[];
      String? saved;
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          child: HeroTextField(
            label: 'Name',
            defaultValue: 'Jane',
            isRequired: true,
            onChanged: changes.add,
            onSaved: (String? v) => saved = v,
          ),
        ),
      );
      await tester.enterText(_editable, '');
      expect(form.currentState!.submit(), isFalse);
      await tester.pump();
      expect(find.text('Please fill out this field.'), findsOneWidget);

      form.currentState!.reset();
      await tester.pump();
      expect(_editableWidget(tester).controller.text, 'Jane');
      expect(find.text('Please fill out this field.'), findsNothing);
      expect(changes, <String>['', 'Jane']);

      form.currentState!.save();
      expect(saved, 'Jane');
    });
  });

  group('HeroTextField semantics', () {
    testWidgets('one labelled text field described by the description', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroTextField(
          type: HeroInputType.email,
          isRequired: true,
          children: <Widget>[
            HeroLabel.text('Email'),
            HeroInput(placeholder: 'Enter your email'),
            HeroDescription.text("We'll never share your email"),
          ],
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.byType(HeroEditableText),
      );
      expect(node.label, 'Email');
      expect(node.hint, contains("We'll never share your email"));
      expect(node.getSemanticsData().inputType, SemanticsInputType.email);
      expect(
        node.getSemanticsData().flagsCollection.isRequired,
        Tristate.isTrue,
      );
      // The label and description are announced with the input.
      expect(find.bySemanticsLabel(RegExp(r'^Email\*?$')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the error describes an invalid field', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroTextField(
          label: 'Email',
          description: 'Hidden',
          errorMessage: 'Please enter a valid email address',
          isInvalid: true,
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.byType(HeroEditableText),
      );
      expect(node.hint, contains('Please enter a valid email address'));
      expect(
        node.getSemanticsData().validationResult,
        SemanticsValidationResult.invalid,
      );
      expect(
        tester.getSemantics(find.byType(HeroFieldError)),
        isSemantics(isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('semanticLabel overrides the label text', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroTextField(placeholder: 'Search', semanticLabel: 'Search'),
      );
      expect(
        tester.getSemantics(find.byType(HeroEditableText)).label,
        'Search',
      );
      handle.dispose();
    });
  });

  testWidgets('debug properties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const HeroTextField(
      label: 'Email',
      type: HeroInputType.email,
      isRequired: true,
    ).debugFillProperties(builder);
    final List<String> properties = builder.properties
        .map((DiagnosticsNode p) => p.toString())
        .toList();
    expect(properties, contains('label: "Email"'));
    expect(properties, contains('type: email'));
    expect(properties, contains('required'));
  });
}
