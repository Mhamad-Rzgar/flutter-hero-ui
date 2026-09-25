import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData light = HeroThemeData.light();

  TextStyle styleOf(WidgetTester tester, String text) =>
      tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

  group('HeroFieldError visibility', () {
    testWidgets('renders nothing outside an invalid field', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroFieldError.text('Standalone'),
            HeroFieldScope(child: HeroFieldError.text('Valid field')),
          ],
        ),
      );
      expect(find.text('Standalone'), findsNothing);
      expect(find.text('Valid field'), findsNothing);
    });

    testWidgets('renders inside an invalid field', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroFieldScope(
          isInvalid: true,
          child: HeroFieldError.text('Username must be at least 3 characters'),
        ),
      );
      expect(
        find.text('Username must be at least 3 characters'),
        findsOneWidget,
      );
    });

    testWidgets('isInvalid overrides the field', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroFieldError.text('Forced', isInvalid: true),
            HeroFieldScope(
              isInvalid: true,
              child: HeroFieldError.text('Hidden', isInvalid: false),
            ),
          ],
        ),
      );
      expect(find.text('Forced'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('follows the field as it becomes valid and invalid', (
      WidgetTester tester,
    ) async {
      Widget build(bool invalid) => HeroFieldScope(
        isInvalid: invalid,
        child: const HeroFieldError.text('Error'),
      );
      await pumpHero(tester, build(false));
      expect(find.text('Error'), findsNothing);
      await tester.pumpWidget(heroTestApp(build(true)));
      expect(find.text('Error'), findsOneWidget);
      await tester.pumpWidget(heroTestApp(build(false)));
      expect(find.text('Error'), findsNothing);
    });
  });

  group('HeroFieldError content', () {
    testWidgets('defaults to the validation messages joined by spaces', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroFieldScope(
          isInvalid: true,
          validationErrors: <String>['Too short.', 'Needs a number.'],
          child: HeroFieldError(),
        ),
      );
      expect(find.text('Too short. Needs a number.'), findsOneWidget);
    });

    testWidgets('renders nothing when invalid without messages or content', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroFieldScope(isInvalid: true, child: HeroFieldError()),
      );
      expect(find.byType(Text), findsNothing);
      expect(tester.getSize(find.byType(HeroFieldError)), Size.zero);
    });

    testWidgets('text wins over the validation messages', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroFieldScope(
          isInvalid: true,
          validationErrors: <String>['From the validator'],
          child: HeroFieldError.text('Custom message'),
        ),
      );
      expect(find.text('Custom message'), findsOneWidget);
      expect(find.text('From the validator'), findsNothing);
    });

    testWidgets('builder receives the validation result', (
      WidgetTester tester,
    ) async {
      HeroValidationResult? received;
      await pumpHero(
        tester,
        HeroFieldScope(
          isInvalid: true,
          validationErrors: const <String>['One', 'Two'],
          child: HeroFieldError(
            builder: (BuildContext context, HeroValidationResult validation) {
              received = validation;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final String error in validation.validationErrors)
                    Text(error),
                ],
              );
            },
          ),
        ),
      );
      expect(
        received,
        const HeroValidationResult.invalid(<String>['One', 'Two']),
      );
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      // Each message is on its own line with the error style.
      expect(
        tester.getTopLeft(find.text('Two')).dy,
        greaterThan(tester.getTopLeft(find.text('One')).dy),
      );
      expect(styleOf(tester, 'Two').color, light.colors.danger);
    });

    testWidgets('child inherits the error style', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroFieldError(isInvalid: true, child: Text('Child')),
      );
      final TextStyle style = styleOf(tester, 'Child');
      expect(style.fontSize, 12);
      expect(style.color, light.colors.danger);
    });
  });

  group('HeroFieldError style', () {
    testWidgets('text-xs danger with 4 px horizontal padding', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroFieldError.text('Error', isInvalid: true),
      );
      final TextStyle style = styleOf(tester, 'Error');
      expect(style.fontSize, 12);
      expect(style.height! * style.fontSize!, closeTo(16, 0.001));
      expect(style.color, light.colors.danger);
      expect(
        tester.getTopLeft(find.text('Error')).dx -
            tester.getTopLeft(find.byType(HeroFieldError)).dx,
        4,
      );
      expect(
        tester.getSize(find.byType(HeroFieldError)).width,
        tester.getSize(find.text('Error')).width + 8,
      );
    });

    testWidgets('dark theme uses the dark danger color', (
      WidgetTester tester,
    ) async {
      final HeroThemeData dark = HeroThemeData.dark();
      await pumpHero(
        tester,
        const HeroFieldError.text('Error', isInvalid: true),
        theme: dark,
      );
      expect(styleOf(tester, 'Error').color, dark.colors.danger);
    });

    testWidgets('style overrides merge', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroFieldError.text(
          'Medium',
          isInvalid: true,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      );
      final TextStyle style = styleOf(tester, 'Medium');
      expect(style.fontWeight, FontWeight.w500);
      expect(style.fontSize, 12);
      expect(style.color, light.colors.danger);
    });

    testWidgets('wraps long messages', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 120,
          child: HeroFieldError.text(
            'Password must be longer than 8 characters',
            isInvalid: true,
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(HeroFieldError)).height,
        greaterThan(16),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL pads the start edge on the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 300,
          child: HeroFieldError.text('Right', isInvalid: true),
        ),
        textDirection: TextDirection.rtl,
      );
      expect(
        tester.getTopRight(find.byType(HeroFieldError)).dx -
            tester.getTopRight(find.text('Right')).dx,
        4,
      );
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 120,
          child: HeroFieldError.text(
            'Scaled validation message',
            isInvalid: true,
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(styleOf(tester, 'Scaled validation message').fontSize, 12);
    });
  });

  group('HeroFieldError semantics', () {
    testWidgets('is a live region with the message', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroFieldError.text(
          'Please enter a valid email',
          isInvalid: true,
        ),
      );
      expect(
        tester.getSemantics(find.byType(HeroFieldError)),
        isSemantics(label: 'Please enter a valid email', isLiveRegion: true),
      );
      handle.dispose();
    });
  });

  group('HeroValidationResult', () {
    test('equality and constructors', () {
      expect(HeroValidationResult.valid.isInvalid, isFalse);
      expect(HeroValidationResult.valid.validationErrors, isEmpty);
      expect(
        const HeroValidationResult.invalid(<String>['a']),
        const HeroValidationResult(
          isInvalid: true,
          validationErrors: <String>['a'],
        ),
      );
      expect(
        const HeroValidationResult.invalid(<String>['a']).hashCode,
        HeroValidationResult(
          isInvalid: true,
          validationErrors: <String>['a'].toList(),
        ).hashCode,
      );
      expect(
        const HeroValidationResult.invalid(),
        isNot(HeroValidationResult.valid),
      );
      expect(
        const HeroValidationResult.invalid(<String>['a']).toString(),
        contains('invalid'),
      );
    });

    testWidgets('field scope exposes its validation', (
      WidgetTester tester,
    ) async {
      late HeroValidationResult validation;
      await pumpHero(
        tester,
        HeroFieldScope(
          isInvalid: true,
          validationErrors: const <String>['Required'],
          child: Builder(
            builder: (BuildContext context) {
              validation = HeroFieldScope.maybeOf(context)!.validation;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        validation,
        const HeroValidationResult.invalid(<String>['Required']),
      );
    });
  });

  testWidgets('a help text scope mutes and indents it', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 300,
        child: HeroFieldHelpTextScope(
          indent: 28,
          child: HeroFieldError.text('Muted', isInvalid: true),
        ),
      ),
    );
    expect(styleOf(tester, 'Muted').color, light.colors.muted);
    final Rect error = tester.getRect(find.byType(HeroFieldError));
    expect(tester.getTopLeft(find.text('Muted')).dx - error.left, 28);
    // No end padding: the text may use the whole remaining width.
    expect(tester.getSize(find.text('Muted')).width, lessThanOrEqualTo(272));
  });
}
