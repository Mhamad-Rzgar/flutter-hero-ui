import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroColors _colors = HeroThemeData.light().colors;

const List<Widget> _items = <Widget>[
  HeroCheckbox(value: 'coding', label: 'Coding'),
  HeroCheckbox(value: 'design', label: 'Design'),
  HeroCheckbox(value: 'writing', label: 'Writing'),
];

/// The checkbox node labelled [label].
SemanticsNode _checkbox(WidgetTester tester, String label) =>
    tester.getSemantics(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(HeroInteractable),
      ),
    );

/// The required asterisk of a label.
final Finder _asterisk = find.byWidgetPredicate(
  (Widget w) =>
      w is RichText &&
      w.text.toPlainText(includeSemanticsLabels: false).contains('*'),
);

CheckedState _checked(WidgetTester tester, String label) =>
    _checkbox(tester, label).flagsCollection.isChecked;

void main() {
  group('HeroCheckboxGroup layout', () {
    testWidgets('label and description touch, items get a 16 px margin', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroCheckboxGroup(
          label: 'Select your interests',
          description: 'Choose all that apply',
          children: _items,
        ),
      );
      final Finder label = find.byType(HeroLabel);
      final Finder description = find.byType(HeroDescription);
      expect(tester.getTopLeft(description).dy, tester.getBottomLeft(label).dy);
      final Finder checkboxes = find.byType(HeroCheckboxContent);
      expect(
        tester.getTopLeft(checkboxes.first).dy -
            tester.getBottomLeft(description).dy,
        16,
      );
      expect(
        tester.getTopLeft(checkboxes.at(1)).dy -
            tester.getBottomLeft(checkboxes.first).dy,
        16,
      );
    });

    testWidgets('spacing and itemMargin replace the defaults', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroCheckboxGroup(
          label: 'Channels',
          spacing: 12,
          itemMargin: EdgeInsets.zero,
          children: _items,
        ),
      );
      final Finder checkboxes = find.byType(HeroCheckboxContent);
      expect(
        tester.getTopLeft(checkboxes.first).dy -
            tester.getBottomLeft(find.byType(HeroLabel)).dy,
        12,
      );
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 200,
          child: HeroCheckboxGroup(
            label: 'Select your interests',
            description: 'Choose all that apply to your profile',
            isRequired: true,
            children: <Widget>[
              HeroCheckbox(
                value: 'coding',
                label: 'Coding and other long activities',
                description: 'Love building software',
              ),
            ],
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL aligns the parts to the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 300,
          child: HeroCheckboxGroup(label: 'Skills', children: _items),
        ),
        textDirection: TextDirection.rtl,
      );
      final double right = tester
          .getTopRight(find.byType(HeroCheckboxGroup))
          .dx;
      expect(
        tester.getTopRight(find.byType(HeroCheckboxControl).first).dx,
        right,
      );
    });
  });

  group('HeroCheckboxGroup selection', () {
    testWidgets('uncontrolled toggles membership', (WidgetTester tester) async {
      final List<Set<String>> changes = <Set<String>>[];
      final List<bool> itemChanges = <bool>[];
      await pumpHero(
        tester,
        HeroCheckboxGroup(
          defaultValue: const <String>{'coding'},
          onChanged: changes.add,
          children: <Widget>[
            const HeroCheckbox(value: 'coding', label: 'Coding'),
            HeroCheckbox(
              value: 'design',
              label: 'Design',
              onChanged: itemChanges.add,
            ),
          ],
        ),
      );
      expect(_checked(tester, 'Coding'), CheckedState.isTrue);
      expect(_checked(tester, 'Design'), CheckedState.isFalse);
      await tester.tap(find.text('Design'));
      await tester.pumpAndSettle();
      expect(changes.last, <String>{'coding', 'design'});
      expect(itemChanges, <bool>[true]);
      expect(_checked(tester, 'Design'), CheckedState.isTrue);
      await tester.tap(find.text('Coding'));
      await tester.pumpAndSettle();
      expect(changes.last, <String>{'design'});
    });

    testWidgets('controlled follows value', (WidgetTester tester) async {
      Set<String> selected = <String>{'coding', 'design'};
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroCheckboxGroup(
                value: selected,
                onChanged: (Set<String> value) =>
                    setState(() => selected = value),
                children: _items,
              ),
              Text('Selected: ${selected.join(', ')}'),
            ],
          ),
        ),
      );
      expect(find.text('Selected: coding, design'), findsOneWidget);
      await tester.tap(find.text('Writing'));
      await tester.pumpAndSettle();
      expect(find.text('Selected: coding, design, writing'), findsOneWidget);
      expect(_checked(tester, 'Writing'), CheckedState.isTrue);
    });

    testWidgets('Tab visits every checkbox and Space toggles', (
      WidgetTester tester,
    ) async {
      final List<Set<String>> changes = <Set<String>>[];
      await pumpHero(
        tester,
        HeroCheckboxGroup(onChanged: changes.add, children: _items),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        _checkbox(tester, 'Design').flagsCollection.isFocused,
        Tristate.isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(changes.single, <String>{'design'});
    });

    testWidgets('disabled and read-only apply to every checkbox', (
      WidgetTester tester,
    ) async {
      final List<Set<String>> changes = <Set<String>>[];
      await pumpHero(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroCheckboxGroup(
              label: 'Features',
              isDisabled: true,
              onChanged: changes.add,
              children: const <Widget>[
                HeroCheckbox(value: 'a', label: 'Feature A'),
              ],
            ),
            HeroCheckboxGroup(
              isReadOnly: true,
              onChanged: changes.add,
              children: const <Widget>[
                HeroCheckbox(value: 'b', label: 'Feature B'),
              ],
            ),
          ],
        ),
      );
      await tester.tap(find.text('Feature A'));
      await tester.tap(find.text('Feature B'));
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      expect(
        _checkbox(tester, 'Feature A').flagsCollection.isEnabled,
        Tristate.isFalse,
      );
      expect(_checkbox(tester, 'Feature B').flagsCollection.isReadOnly, isTrue);
      // The group label is dimmed; the group itself is not.
      final Opacity labelOpacity = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.byType(RichText).first,
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(labelOpacity.opacity, 0.5);
    });

    testWidgets('variant reaches the checkboxes unless they set one', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroCheckboxGroup(
          variant: HeroFieldVariant.secondary,
          children: <Widget>[
            HeroCheckbox(value: 'a', label: 'A'),
            HeroCheckbox(
              value: 'b',
              label: 'B',
              variant: HeroFieldVariant.primary,
            ),
          ],
        ),
      );
      List<HeroFieldVariant> variants = <HeroFieldVariant>[
        for (final Element e in find.byType(HeroCheckboxControl).evaluate())
          HeroCheckboxScope.maybeOf(e)!.variant,
      ];
      expect(variants, <HeroFieldVariant>[
        HeroFieldVariant.secondary,
        HeroFieldVariant.primary,
      ]);
      variants = const <HeroFieldVariant>[];
    });

    testWidgets('builder receives the group state', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroCheckboxGroup(
          builder: (BuildContext context, HeroCheckboxGroupState state) =>
              <Widget>[..._items, Text('${state.value.length} selected')],
        ),
      );
      expect(find.text('0 selected'), findsOneWidget);
      await tester.tap(find.text('Coding'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('the group is labelled and described', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroCheckboxGroup(
          label: 'Select your interests',
          description: 'Choose all that apply',
          children: _items,
        ),
      );
      // The label and description are announced once, by the group.
      expect(find.bySemanticsLabel('Select your interests'), findsOneWidget);
      expect(find.bySemanticsLabel('Choose all that apply'), findsNothing);
      final SemanticsNode group = tester.getSemantics(
        find.bySemanticsLabel('Select your interests'),
      );
      expect(group.hint, 'Choose all that apply');
      handle.dispose();
    });
  });

  group('HeroCheckboxGroup validation', () {
    testWidgets('required blocks submission until one is checked', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      final List<Map<String, Object?>> submitted = <Map<String, Object?>>[];
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          onSubmit: submitted.add,
          child: const HeroCheckboxGroup(
            name: 'preferences',
            isRequired: true,
            label: 'Preferences',
            children: <Widget>[
              HeroCheckbox(value: 'email', label: 'Email notifications'),
              HeroCheckbox(value: 'sms', label: 'SMS notifications'),
              HeroFieldError.text(
                'Please select at least one notification method.',
              ),
            ],
          ),
        ),
      );
      const String error = 'Please select at least one notification method.';
      expect(find.text(error), findsNothing);
      // The label shows the required asterisk.
      expect(_asterisk, findsOneWidget);
      form.currentState!.submit();
      await tester.pumpAndSettle();
      expect(submitted, isEmpty);
      expect(find.text(error), findsOneWidget);
      // The group error keeps the danger color; the label turns danger.
      expect(
        tester
            .renderObject<RenderParagraph>(find.text(error))
            .text
            .style!
            .color,
        _colors.danger,
      );
      expect(
        _checkbox(tester, 'Email notifications').validationResult,
        SemanticsValidationResult.invalid,
      );

      await tester.tap(find.text('SMS notifications'));
      await tester.tap(find.text('Email notifications'));
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);
      form.currentState!.submit();
      expect(submitted.single, <String, Object?>{
        'preferences': <String>['sms', 'email'],
      });
    });

    testWidgets('reset restores the default selection', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          child: const HeroCheckboxGroup(
            name: 'skills',
            defaultValue: <String>{'coding'},
            children: _items,
          ),
        ),
      );
      await tester.tap(find.text('Coding'));
      await tester.tap(find.text('Writing'));
      await tester.pumpAndSettle();
      expect(form.currentState!.save(), <String, Object?>{
        'skills': <String>['writing'],
      });
      form.currentState!.reset();
      await tester.pumpAndSettle();
      expect(_checked(tester, 'Coding'), CheckedState.isTrue);
      expect(_checked(tester, 'Writing'), CheckedState.isFalse);
    });

    testWidgets('validator, server errors and isInvalid', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroCheckboxGroup(
          validationErrors: const <String>['Choose again'],
          validator: (Set<String>? value) =>
              (value?.length ?? 0) > 1 ? 'Pick one at most' : null,
          children: const <Widget>[..._items, HeroFieldError()],
        ),
      );
      expect(find.text('Choose again'), findsOneWidget);
      await tester.tap(find.text('Coding'));
      await tester.pumpAndSettle();
      expect(find.text('Choose again'), findsNothing);
      await tester.tap(find.text('Design'));
      await tester.pumpAndSettle();
      expect(find.text('Pick one at most'), findsOneWidget);

      await pumpHero(
        tester,
        const HeroCheckboxGroup(
          isInvalid: true,
          children: <Widget>[HeroCheckbox(value: 'a', label: 'Forced')],
        ),
      );
      expect(
        _checkbox(tester, 'Forced').validationResult,
        SemanticsValidationResult.invalid,
      );
    });
  });
}
