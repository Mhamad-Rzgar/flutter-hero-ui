import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

EditableText _editable(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText));

String _text(WidgetTester tester) => _editable(tester).controller.text;

HeroFieldBox _box(WidgetTester tester) =>
    tester.widget<HeroFieldBox>(find.byType(HeroFieldBox));

Finder get _increment => find.byType(HeroNumberFieldIncrementButton);

Finder get _decrement => find.byType(HeroNumberFieldDecrementButton);

double _opacity(WidgetTester tester, Finder button) => tester
    .widget<Opacity>(
      find.descendant(of: button, matching: find.byType(Opacity)).first,
    )
    .opacity;

Future<void> _blur(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  group('HeroNumberFormatter', () {
    test('formats the docs formats', () {
      final HeroNumberFormatter eur = HeroNumberFormatter(
        const HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.currency,
          currency: 'EUR',
          currencySign: HeroCurrencySign.accounting,
        ),
        locale: 'en_US',
      );
      expect(eur.format(99), '€99.00');
      expect(eur.format(-99), '(€99.00)');
      final HeroNumberFormatter usd = HeroNumberFormatter(
        const HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.currency,
          currency: 'USD',
        ),
        locale: 'en_US',
      );
      expect(usd.format(99.99), r'$99.99');
      expect(usd.format(-5), r'-$5.00');
      final HeroNumberFormatter percent = HeroNumberFormatter(
        const HeroNumberFormatOptions(style: HeroNumberFormatStyle.percent),
        locale: 'en_US',
      );
      expect(percent.format(0.5), '50%');
      expect(percent.isPercent, isTrue);
      final HeroNumberFormatter decimal = HeroNumberFormatter(
        const HeroNumberFormatOptions(
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        ),
        locale: 'en_US',
      );
      expect(decimal.format(1234.56), '1,234.56');
      expect(decimal.format(2), '2.00');
      final HeroNumberFormatter plain = HeroNumberFormatter(
        const HeroNumberFormatOptions(),
        locale: 'en_US',
      );
      expect(plain.format(1024), '1,024');
      expect(plain.format(1.23456), '1.235');
      expect(plain.format(double.nan), '');
      expect(
        HeroNumberFormatter(
          const HeroNumberFormatOptions(useGrouping: false),
        ).format(1024),
        '1024',
      );
    });

    test('formats units', () {
      String unit(String name, HeroUnitDisplay display, double value) =>
          HeroNumberFormatter(
            HeroNumberFormatOptions(
              style: HeroNumberFormatStyle.unit,
              unit: name,
              unitDisplay: display,
            ),
            locale: 'en_US',
          ).format(value);
      expect(unit('kilogram', HeroUnitDisplay.short, 1000), '1,000 kg');
      expect(unit('kilogram', HeroUnitDisplay.narrow, 1000), '1,000kg');
      expect(unit('kilogram', HeroUnitDisplay.long, 1000), '1,000 kilograms');
      expect(unit('kilogram', HeroUnitDisplay.long, 1), '1 kilogram');
      expect(unit('celsius', HeroUnitDisplay.short, 21), '21°C');
      expect(unit('parsec', HeroUnitDisplay.short, 3), '3 parsec');
    });

    test('parses leniently', () {
      final HeroNumberFormatter eur = HeroNumberFormatter(
        const HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.currency,
          currency: 'EUR',
          currencySign: HeroCurrencySign.accounting,
        ),
        locale: 'en_US',
      );
      expect(eur.parse('€99.00'), 99);
      expect(eur.parse('(€99.00)'), -99);
      expect(eur.parse('12'), 12);
      expect(eur.parse('-1,234.5'), -1234.5);
      expect(eur.parse('abc'), isNaN);
      expect(eur.parse(''), isNaN);
      final HeroNumberFormatter percent = HeroNumberFormatter(
        const HeroNumberFormatOptions(style: HeroNumberFormatStyle.percent),
        locale: 'en_US',
      );
      expect(percent.parse('50%'), 0.5);
      expect(percent.parse('21'), 0.21);
      final HeroNumberFormatter kg = HeroNumberFormatter(
        const HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.unit,
          unit: 'kilogram',
        ),
      );
      expect(kg.parse('1,000 kg'), 1000);
      final HeroNumberFormatter german = HeroNumberFormatter(
        const HeroNumberFormatOptions(),
        locale: 'de',
      );
      expect(german.format(1234.5), '1.234,5');
      expect(german.parse('1.234,5'), 1234.5);
    });

    test('validates partial input', () {
      final HeroNumberFormatter plain = HeroNumberFormatter(
        const HeroNumberFormatOptions(),
        locale: 'en_US',
      );
      expect(plain.isValidPartial(''), isTrue);
      expect(plain.isValidPartial('-'), isTrue);
      expect(plain.isValidPartial('12.'), isTrue);
      expect(plain.isValidPartial('1,024'), isTrue);
      expect(plain.isValidPartial('1a'), isFalse);
      expect(plain.isValidPartial('1.2.3'), isFalse);
      expect(plain.isValidPartial(',1'), isFalse);
      expect(plain.isValidPartial('-1', minValue: 0), isFalse);
      final HeroNumberFormatter percent = HeroNumberFormatter(
        const HeroNumberFormatOptions(style: HeroNumberFormatStyle.percent),
      );
      expect(percent.isValidPartial('50%'), isTrue);
      expect(percent.isValidPartial('50.5'), isFalse);
      final HeroNumberFormatter eur = HeroNumberFormatter(
        const HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.currency,
          currency: 'EUR',
        ),
      );
      expect(eur.isValidPartial('€9'), isTrue);
    });

    test('wraps an intl NumberFormat', () {
      final HeroNumberFormatter formatter =
          HeroNumberFormatter.fromNumberFormat(
            NumberFormat.percentPattern('en_US'),
          );
      expect(formatter.isPercent, isTrue);
      expect(formatter.format(0.25), '25%');
      expect(formatter.parse('25%'), 0.25);
    });

    test('snaps to the step like React Aria', () {
      expect(heroSnapValueToStep(7, 0, 100, 5), 5);
      expect(heroSnapValueToStep(8, 0, 100, 5), 10);
      expect(heroSnapValueToStep(103, 0, 100, 5), 100);
      expect(heroSnapValueToStep(-3, 0, 100, 5), 0);
      expect(heroSnapValueToStep(0.30000000000000004, null, null, 0.1), 0.3);
      expect(heroSnapValueToStep(12, 1, 10, 4), 9);
      expect(heroDecimalOperation(true, 0.1, 0.2), 0.3);
      expect(heroDecimalOperation(false, 1, 0.01), 0.99);
    });
  });

  group('HeroNumberField layout', () {
    testWidgets('a 36 px group with 40 px buttons and dividers', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroNumberField(label: 'Width', defaultValue: 1024),
        surfaceSize: const Size(390, 600),
      );
      final Rect group = tester.getRect(find.byType(HeroNumberFieldGroup));
      expect(group.height, 36);
      expect(tester.getSize(_decrement), const Size(40, 36));
      expect(tester.getSize(_increment), const Size(40, 36));
      expect(tester.getRect(_decrement).left, group.left);
      expect(tester.getRect(_increment).right, group.right);
      // 40 + the default input width + 40.
      expect(group.width, 40 + 192 + 40.0);
      expect(
        tester.getSize(
          find.descendant(of: _increment, matching: find.byType(HeroIcon)),
        ),
        const Size(16, 16),
      );
      final EditableText editable = _editable(tester);
      expect(editable.style.fontSize, 16);
      expect(
        editable.style.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(_text(tester), '1,024');
      // px-3 from the decrement button.
      expect(
        tester.getRect(find.byType(EditableText)).left -
            tester.getRect(_decrement).right,
        12,
      );
    });

    testWidgets('fullWidth and RTL', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 400,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: HeroNumberField(label: 'Width', fullWidth: true),
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      final Rect group = tester.getRect(find.byType(HeroNumberFieldGroup));
      expect(group.width, 400);
      // The decrement button sits at the start (right in RTL).
      expect(tester.getRect(_decrement).right, group.right);
      expect(tester.getRect(_increment).left, group.left);
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroNumberField(
          label: 'Width',
          defaultValue: 1024,
          description: 'Enter the width in pixels',
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(HeroNumberFieldGroup)).height,
        greaterThan(36),
      );
    });

    testWidgets('showStepper false builds only the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroNumberField(label: 'Width', showStepper: false),
      );
      expect(_increment, findsNothing);
      expect(_decrement, findsNothing);
    });
  });

  group('HeroNumberField typing and commit', () {
    testWidgets('filters typing and commits on blur', (
      WidgetTester tester,
    ) async {
      final List<double?> changes = <double?>[];
      await pumpHero(
        tester,
        HeroNumberField(
          label: 'Width',
          defaultValue: 10,
          minValue: 0,
          maxValue: 100,
          onChanged: changes.add,
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '12a');
      expect(_text(tester), '10', reason: 'invalid text is rejected');
      await tester.enterText(find.byType(EditableText), '250');
      await tester.pump();
      expect(changes, isEmpty, reason: 'no onChanged while typing');
      await _blur(tester);
      expect(changes, <double?>[100]);
      expect(_text(tester), '100');

      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '');
      await _blur(tester);
      expect(changes.last, isNull);
      expect(_text(tester), '');
    });

    testWidgets('negative input is rejected when the minimum is 0', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroNumberField(label: 'W', minValue: 0));
      await tester.enterText(find.byType(EditableText), '-');
      expect(_text(tester), '');
    });

    testWidgets('Enter commits and snaps to an explicit step', (
      WidgetTester tester,
    ) async {
      double? committed;
      await pumpHero(
        tester,
        HeroNumberField(
          label: 'Step',
          defaultValue: 0,
          minValue: 0,
          maxValue: 100,
          step: 5,
          onChanged: (double? value) => committed = value,
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '12');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(committed, 10);
      expect(_text(tester), '10');
    });

    testWidgets('an unparsable value reverts', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroNumberField(label: 'W', defaultValue: 7),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '.');
      await _blur(tester);
      expect(_text(tester), '7');
    });

    testWidgets('percent values are fractions', (WidgetTester tester) async {
      double? committed;
      await pumpHero(
        tester,
        HeroNumberField(
          label: 'Percentage',
          defaultValue: 0.5,
          formatOptions: const HeroNumberFormatOptions(
            style: HeroNumberFormatStyle.percent,
          ),
          onChanged: (double? value) => committed = value,
        ),
      );
      expect(_text(tester), '50%');
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '75');
      await _blur(tester);
      expect(committed, 0.75);
      expect(_text(tester), '75%');
      // The default step of a percentage is 0.01.
      await tester.tap(_increment);
      await tester.pumpAndSettle();
      expect(committed, 0.76);
      expect(_text(tester), '76%');
    });
  });

  group('HeroNumberField stepping', () {
    testWidgets('buttons step and disable at the limits', (
      WidgetTester tester,
    ) async {
      final List<double?> changes = <double?>[];
      await pumpHero(
        tester,
        HeroNumberField(
          label: 'Rating',
          defaultValue: 9,
          minValue: 1,
          maxValue: 10,
          onChanged: changes.add,
        ),
      );
      await tester.tap(_increment);
      await tester.pumpAndSettle();
      expect(changes, <double?>[10]);
      expect(_text(tester), '10');
      expect(_opacity(tester, _increment), 0.5);
      await tester.tap(_increment, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(changes, <double?>[10]);
      await tester.tap(_decrement);
      await tester.pumpAndSettle();
      expect(changes, <double?>[10, 9]);
      expect(_opacity(tester, _increment), 1);
    });

    testWidgets('holding a button repeats the step', (
      WidgetTester tester,
    ) async {
      double? value;
      await pumpHero(
        tester,
        HeroNumberField(
          label: 'Count',
          defaultValue: 0,
          onChanged: (double? v) => value = v,
        ),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(_increment),
      );
      await tester.pump();
      expect(value, 1);
      await tester.pump(const Duration(milliseconds: 399));
      expect(value, 1);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 60));
      expect(value, 2);
      await tester.pump(const Duration(milliseconds: 60));
      expect(value, 3);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 200));
      expect(value, 3);
      await tester.pumpAndSettle();
    });

    testWidgets('incrementing an empty field starts at the minimum', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroNumberField(label: 'Q', minValue: 1, maxValue: 5),
      );
      await tester.tap(_increment);
      await tester.pumpAndSettle();
      expect(_text(tester), '1');

      await pumpHero(
        tester,
        const HeroNumberField(
          key: ValueKey<int>(2),
          label: 'Q',
          minValue: 1,
          maxValue: 5,
        ),
      );
      await tester.tap(_decrement);
      await tester.pumpAndSettle();
      expect(_text(tester), '5');
    });

    testWidgets('keyboard steps, pages, Home and End', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroNumberField(
          label: 'Volume',
          defaultValue: 50,
          minValue: 0,
          maxValue: 100,
          step: 10,
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(_text(tester), '60');
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();
      expect(_text(tester), '50');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(_text(tester), '40');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(_text(tester), '100');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(_text(tester), '0');
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();
      expect(_text(tester), '10');
    });

    testWidgets('the wheel steps only while focused', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroNumberField(label: 'W', defaultValue: 5),
      );
      final Offset center = tester.getCenter(find.byType(EditableText));
      final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(center));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 20)));
      await tester.pump();
      expect(_text(tester), '5');
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 20)));
      await tester.pump();
      expect(_text(tester), '6');
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -20)));
      await tester.pump();
      expect(_text(tester), '5');
    });

    testWidgets('isWheelDisabled, read-only and disabled do not step', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroNumberField(label: 'W', defaultValue: 5, isReadOnly: true),
      );
      expect(_opacity(tester, _increment), 0.5);
      await tester.tap(find.byType(EditableText));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(_text(tester), '5');

      await pumpHero(
        tester,
        const HeroNumberField(
          key: ValueKey<int>(2),
          label: 'W',
          defaultValue: 5,
          isDisabled: true,
        ),
      );
      expect(_box(tester).isDisabled, isTrue);
      await tester.tap(_increment, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(_text(tester), '5');
      expect(_editable(tester).focusNode.canRequestFocus, isFalse);

      await pumpHero(
        tester,
        const HeroNumberField(
          key: ValueKey<int>(3),
          label: 'W',
          defaultValue: 5,
          isWheelDisabled: true,
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      final TestPointer pointer = TestPointer(2, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        pointer.hover(tester.getCenter(find.byType(EditableText))),
      );
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, 20)));
      await tester.pump();
      expect(_text(tester), '5');
    });

    testWidgets('the buttons are not in the focus order', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroNumberField(label: 'W', defaultValue: 1),
            HeroButton(child: Text('Next')),
          ],
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<HeroButton>(),
        isNotNull,
      );
    });
  });

  group('HeroNumberField value', () {
    testWidgets('controlled value follows the parent', (
      WidgetTester tester,
    ) async {
      double value = 1024;
      late StateSetter update;
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            update = setState;
            return HeroNumberField(
              label: 'Width',
              value: value,
              minValue: 0,
              onChanged: (double? v) => setState(() => value = v ?? 0),
              description: 'Current value: $value',
            );
          },
        ),
      );
      expect(_text(tester), '1,024');
      update(() => value = 2048);
      await tester.pump();
      expect(_text(tester), '2,048');
      await tester.tap(_increment);
      await tester.pumpAndSettle();
      expect(value, 2049);
      expect(_text(tester), '2,049');
    });

    testWidgets('a controlled value outside the range is shown as is', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroNumberField(label: 'Quantity', value: -5, minValue: 0),
      );
      expect(_text(tester), '-5');
      expect(_opacity(tester, _decrement), 0.5);
    });

    testWidgets('the locale formats the value', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroNumberField(
          label: 'Betrag',
          defaultValue: 1234.5,
          locale: Locale('de'),
        ),
      );
      expect(_text(tester), '1.234,5');
    });

    testWidgets('an intl number format', (WidgetTester tester) async {
      await pumpHero(
        tester,
        HeroNumberField(
          label: 'Price',
          defaultValue: 3,
          numberFormat: NumberFormat.simpleCurrency(
            locale: 'en_US',
            name: 'USD',
          ),
        ),
      );
      expect(_text(tester), r'$3.00');
    });

    testWidgets('builder receives the value and limits', (
      WidgetTester tester,
    ) async {
      HeroNumberFieldState? last;
      await pumpHero(
        tester,
        HeroNumberField(
          defaultValue: 3,
          minValue: 1,
          maxValue: 5,
          step: 2,
          builder: (BuildContext context, HeroNumberFieldState state) {
            last = state;
            return const <Widget>[
              HeroNumberFieldGroup(children: <Widget>[HeroNumberFieldInput()]),
            ];
          },
        ),
      );
      expect(last!.value, 3);
      expect(last!.minValue, 1);
      expect(last!.maxValue, 5);
      expect(last!.step, 2);
    });
  });

  group('HeroNumberField forms', () {
    testWidgets('submits the number, validates it and resets', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      Map<String, Object?>? submitted;
      double? saved;
      final List<double?> changes = <double?>[];
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          onSubmit: (Map<String, Object?> data) => submitted = data,
          child: HeroNumberField(
            name: 'quantity',
            label: 'Order quantity',
            defaultValue: 2,
            minValue: 1,
            maxValue: 5,
            onChanged: changes.add,
            onSaved: (double? value) => saved = value,
            validator: (double? value) =>
                value != null && value > 3 ? 'Only 3 items left' : null,
          ),
        ),
      );
      expect(form.currentState!.submit(), isTrue);
      expect(submitted, <String, Object?>{'quantity': 2.0});
      expect(saved, 2);

      await tester.tap(_increment);
      await tester.tap(_increment);
      await tester.pumpAndSettle();
      expect(_text(tester), '4');
      // A step commits the validation right away.
      expect(find.text('Only 3 items left'), findsOneWidget);
      expect(form.currentState!.submit(), isFalse);

      form.currentState!.reset();
      await tester.pumpAndSettle();
      expect(_text(tester), '2');
      expect(changes.last, 2);
      expect(find.text('Only 3 items left'), findsNothing);
    });

    testWidgets('required fails while empty', (WidgetTester tester) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          child: const HeroNumberField(
            name: 'quantity',
            label: 'Quantity',
            isRequired: true,
          ),
        ),
      );
      expect(form.currentState!.submit(), isFalse);
      await tester.pump();
      expect(find.text('Please fill out this field.'), findsOneWidget);
      expect(_box(tester).isInvalid, isTrue);
    });

    testWidgets('isInvalid hides the description and shows the error', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroNumberField(
          label: 'Percentage',
          value: 1.5,
          maxValue: 1,
          isInvalid: true,
          description: 'Enter a value between 0 and 100',
          errorMessage: 'Percentage must be between 0 and 100',
          formatOptions: HeroNumberFormatOptions(
            style: HeroNumberFormatStyle.percent,
          ),
        ),
      );
      expect(_text(tester), '150%');
      expect(find.text('Enter a value between 0 and 100'), findsNothing);
      expect(find.text('Percentage must be between 0 and 100'), findsOneWidget);
    });

    testWidgets('server errors by name', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroForm(
          validationErrors: <String, List<String>>{
            'quantity': <String>['Out of stock'],
          },
          child: HeroNumberField(name: 'quantity', label: 'Quantity'),
        ),
      );
      expect(find.text('Out of stock'), findsOneWidget);
    });
  });

  group('HeroNumberField semantics', () {
    testWidgets('an adjustable labelled text field and labelled buttons', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroNumberField(
          label: 'Width',
          defaultValue: 10,
          minValue: 0,
          maxValue: 20,
        ),
      );
      final SemanticsNode node = tester.getSemantics(
        find.byType(HeroEditableText),
      );
      final SemanticsData data = node.getSemanticsData();
      expect(node.label, 'Width');
      expect(data.value, '10');
      expect(data.increasedValue, '11');
      expect(data.decreasedValue, '9');
      expect(data.hasAction(SemanticsAction.increase), isTrue);
      expect(data.hasAction(SemanticsAction.decrease), isTrue);
      expect(find.bySemanticsLabel('Increase'), findsOneWidget);
      expect(find.bySemanticsLabel('Decrease'), findsOneWidget);

      tester.semantics.performAction(
        find.semantics.byLabel('Width'),
        SemanticsAction.increase,
      );
      await tester.pump();
      expect(_text(tester), '11');
      handle.dispose();
    });
  });

  testWidgets('debug properties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const HeroNumberField(
      label: 'Width',
      minValue: 0,
      step: 5,
      isDisabled: true,
    ).debugFillProperties(builder);
    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();
    expect(description, contains('label: "Width"'));
    expect(description, contains('minValue: 0.0'));
    expect(description, contains('step: 5.0'));
    expect(description, contains('disabled'));
  });
}
