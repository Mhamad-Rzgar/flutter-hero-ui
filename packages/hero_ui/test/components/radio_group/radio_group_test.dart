import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<Widget> _plans = <Widget>[
  HeroRadio(value: 'starter', label: 'Starter'),
  HeroRadio(value: 'pro', label: 'Pro'),
  HeroRadio(value: 'teams', label: 'Teams'),
];

SemanticsNode _radio(WidgetTester tester, String label) => tester.getSemantics(
  find.ancestor(of: find.text(label), matching: find.byType(HeroInteractable)),
);

bool _selected(WidgetTester tester, String label) =>
    _radio(tester, label).flagsCollection.isChecked == CheckedState.isTrue;

bool _focused(WidgetTester tester, String label) =>
    _radio(tester, label).flagsCollection.isFocused == Tristate.isTrue;

void main() {
  group('HeroRadioGroup layout', () {
    testWidgets('vertical radios get a 16 px top margin', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroRadioGroup(
          label: 'Plan selection',
          description: 'Choose the plan that suits you best',
          children: <Widget>[
            HeroRadio(
              value: 'basic',
              label: 'Basic Plan',
              description: 'Includes 100 messages per month',
            ),
            HeroRadio(value: 'premium', label: 'Premium Plan'),
          ],
        ),
      );
      final Finder contents = find.byType(HeroRadioContent);
      expect(
        tester.getTopLeft(contents.first).dy -
            tester.getBottomLeft(find.byType(HeroDescription).first).dy,
        16,
      );
      expect(
        tester.getSize(find.byType(HeroRadioControl).first),
        const Size(16, 16),
      );
      // The radio's description is indented under its label.
      expect(
        tester.getTopLeft(find.text('Includes 100 messages per month')).dx -
            tester.getTopLeft(find.byType(HeroRadioControl).first).dx,
        28,
      );
    });

    testWidgets('horizontal radios wrap in a row with a 16 px gap', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroRadioGroup(orientation: Axis.horizontal, children: _plans),
      );
      final Finder radios = find.byType(HeroRadio);
      expect(
        tester.getTopLeft(radios.at(1)).dx -
            tester.getTopRight(radios.first).dx,
        16,
      );
      expect(
        tester.getTopLeft(radios.at(1)).dy,
        tester.getTopLeft(radios.first).dy,
      );
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 220,
          child: HeroRadioGroup(
            label: 'Subscription plan',
            isRequired: true,
            children: <Widget>[
              HeroRadio(
                value: 'starter',
                label: 'Starter plan for side projects',
                description: 'For side projects and small teams',
              ),
            ],
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('HeroRadioGroup selection', () {
    testWidgets('uncontrolled selects on press', (WidgetTester tester) async {
      final List<String> changes = <String>[];
      await pumpHero(
        tester,
        HeroRadioGroup(
          defaultValue: 'pro',
          onChanged: changes.add,
          children: _plans,
        ),
      );
      expect(_selected(tester, 'Pro'), isTrue);
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      expect(changes, <String>['teams']);
      expect(_selected(tester, 'Teams'), isTrue);
      expect(_selected(tester, 'Pro'), isFalse);
      // Pressing the selected radio changes nothing.
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      expect(changes, <String>['teams']);
    });

    testWidgets('controlled follows value', (WidgetTester tester) async {
      String value = 'pro';
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroRadioGroup(
                value: value,
                onChanged: (String next) => setState(() => value = next),
                children: _plans,
              ),
              Text('Selected plan: $value'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Starter'));
      await tester.pumpAndSettle();
      expect(find.text('Selected plan: starter'), findsOneWidget);
    });

    testWidgets('the group is one Tab stop and arrows move the selection', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await pumpHero(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroRadioGroup(
              defaultValue: 'pro',
              onChanged: changes.add,
              children: _plans,
            ),
            const HeroButton(child: Text('After')),
          ],
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focused(tester, 'Pro'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(_focused(tester, 'Teams'), isTrue);
      expect(changes, <String>['teams']);
      // Wraps around to the first radio.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(_selected(tester, 'Starter'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(_selected(tester, 'Teams'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(_selected(tester, 'Pro'), isTrue);
      // Tab leaves the group.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester.getSemantics(find.byType(HeroButton)).flagsCollection.isFocused,
        Tristate.isTrue,
      );
    });

    testWidgets('without a selection the first radio is the Tab stop', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroRadioGroup(children: _plans));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_focused(tester, 'Starter'), isTrue);
      expect(_selected(tester, 'Starter'), isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(_selected(tester, 'Starter'), isTrue);
    });

    testWidgets('arrows skip disabled radios and flip in RTL rows', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroRadioGroup(
          defaultValue: 'starter',
          orientation: Axis.horizontal,
          children: <Widget>[
            HeroRadio(value: 'starter', label: 'Starter'),
            HeroRadio(value: 'pro', label: 'Pro', isDisabled: true),
            HeroRadio(value: 'teams', label: 'Teams'),
          ],
        ),
        textDirection: TextDirection.rtl,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      // In RTL, Left moves to the next radio.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(_selected(tester, 'Teams'), isTrue);
      expect(_radio(tester, 'Pro').flagsCollection.isEnabled, Tristate.isFalse);
      // The radios run from right to left.
      expect(
        tester.getCenter(find.text('Starter')).dx,
        greaterThan(tester.getCenter(find.text('Teams')).dx),
      );
    });

    testWidgets('read-only moves the focus but keeps the selection', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await pumpHero(
        tester,
        HeroRadioGroup(
          defaultValue: 'starter',
          isReadOnly: true,
          onChanged: changes.add,
          children: _plans,
        ),
      );
      await tester.tap(find.text('Pro'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(_selected(tester, 'Starter'), isTrue);
      expect(_focused(tester, 'Pro'), isTrue);
      expect(_radio(tester, 'Pro').flagsCollection.isReadOnly, isTrue);
    });

    testWidgets('a disabled group ignores input and dims its radios', (
      WidgetTester tester,
    ) async {
      final List<String> changes = <String>[];
      await pumpHero(
        tester,
        HeroRadioGroup(
          isDisabled: true,
          defaultValue: 'pro',
          onChanged: changes.add,
          children: _plans,
        ),
      );
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(
        _radio(tester, 'Teams').flagsCollection.isEnabled,
        Tristate.isFalse,
      );
      final Opacity opacity = tester.widget<Opacity>(
        find
            .ancestor(of: find.text('Teams'), matching: find.byType(Opacity))
            .first,
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('radios are mutually exclusive in a labelled radio group', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroRadioGroup(
          label: 'Subscription plan',
          defaultValue: 'pro',
          children: _plans,
        ),
      );
      final SemanticsNode pro = _radio(tester, 'Pro');
      expect(pro.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(pro.label, 'Pro');
      final SemanticsNode group = tester.getSemantics(
        find.bySemanticsLabel('Subscription plan'),
      );
      expect(group.role, SemanticsRole.radioGroup);
      handle.dispose();
    });

    testWidgets('builder and indicator builder receive the state', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroRadioGroup(
          builder: (BuildContext context, HeroRadioGroupState state) =>
              <Widget>[
                HeroRadio(
                  value: 'a',
                  children: <Widget>[
                    HeroRadioContent(
                      children: <Widget>[
                        HeroRadioControl(
                          child: HeroRadioIndicator(
                            builder:
                                (BuildContext context, HeroRadioState radio) =>
                                    radio.isSelected ? const Text('✓') : null,
                          ),
                        ),
                        const Text('Option A'),
                      ],
                    ),
                  ],
                ),
                Text('Value: ${state.value}'),
              ],
        ),
      );
      expect(find.text('✓'), findsNothing);
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();
      expect(find.text('✓'), findsOneWidget);
      expect(find.text('Value: a'), findsOneWidget);
    });
  });

  group('HeroRadioGroup validation', () {
    testWidgets('required blocks submission until a radio is selected', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      final List<Map<String, Object?>> submitted = <Map<String, Object?>>[];
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          onSubmit: submitted.add,
          child: const HeroRadioGroup(
            name: 'plan',
            isRequired: true,
            children: <Widget>[
              HeroLabel.text('Subscription plan'),
              ..._plans,
              HeroFieldError(),
            ],
          ),
        ),
      );
      form.currentState!.submit();
      await tester.pumpAndSettle();
      expect(submitted, isEmpty);
      expect(find.text('Please select one of these options.'), findsOneWidget);
      expect(_focused(tester, 'Starter'), isTrue);
      expect(
        _radio(tester, 'Pro').validationResult,
        SemanticsValidationResult.invalid,
      );
      await tester.tap(find.text('Pro'));
      await tester.pumpAndSettle();
      expect(find.text('Please select one of these options.'), findsNothing);
      form.currentState!.submit();
      expect(submitted.single, <String, Object?>{'plan': 'pro'});
    });

    testWidgets('reset restores the default value', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      final List<String> changes = <String>[];
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          child: HeroRadioGroup(
            name: 'plan',
            defaultValue: 'pro',
            onChanged: changes.add,
            children: _plans,
          ),
        ),
      );
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      form.currentState!.reset();
      await tester.pumpAndSettle();
      expect(changes, <String>['teams', 'pro']);
      expect(_selected(tester, 'Pro'), isTrue);
    });

    testWidgets('validator and server errors', (WidgetTester tester) async {
      await pumpHero(
        tester,
        HeroRadioGroup(
          validationErrors: const <String>['Plan unavailable'],
          validator: (String? value) =>
              value == 'teams' ? 'Teams needs approval' : null,
          children: const <Widget>[..._plans, HeroFieldError()],
        ),
      );
      expect(find.text('Plan unavailable'), findsOneWidget);
      await tester.tap(find.text('Teams'));
      await tester.pumpAndSettle();
      expect(find.text('Plan unavailable'), findsNothing);
      expect(find.text('Teams needs approval'), findsOneWidget);
    });
  });
}
