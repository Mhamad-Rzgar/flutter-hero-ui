import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroThemeData _light = HeroThemeData.light();

Finder get _content => find.byType(HeroCheckboxContent);

Finder get _control => find.byType(HeroCheckboxControl);

/// The semantics node of the checkbox (the pressable content).
SemanticsNode _node(WidgetTester tester) =>
    tester.getSemantics(find.byType(HeroInteractable).first);

Color? _textColor(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style!.color;

double _opacityAbove(WidgetTester tester, Finder finder) {
  double opacity = 1;
  for (final Opacity widget in tester.widgetList<Opacity>(
    find.ancestor(of: finder, matching: find.byType(Opacity)),
  )) {
    opacity *= widget.opacity;
  }
  return opacity;
}

void main() {
  group('HeroCheckbox layout', () {
    testWidgets('builds the control, the label and the description', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroCheckbox(
          label: 'Email notifications',
          description: 'Get notified when someone mentions you',
        ),
      );
      expect(_control, findsOneWidget);
      expect(find.byType(HeroCheckboxIndicator), findsOneWidget);
      expect(tester.getSize(_control), const Size(16, 16));
      // `gap-3` between the control and the label.
      expect(
        tester.getTopLeft(find.text('Email notifications')).dx -
            tester.getTopRight(_control).dx,
        12,
      );
      // The description is indented under the label (`ps-7`) with `gap-1`.
      final Offset description = tester.getTopLeft(
        find.text('Get notified when someone mentions you'),
      );
      expect(description.dx - tester.getTopLeft(_control).dx, 28);
      expect(description.dy - tester.getBottomLeft(_content).dy, 4);
      // The hidden error takes no gap.
      expect(
        tester.getSize(find.byType(HeroCheckbox)).height,
        20 + 4 + 16, // content + gap + description
      );
    });

    testWidgets('the content keeps its own width (items-start)', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 300,
          child: HeroCheckbox(
            label: 'Short',
            description: 'A description that is wider than the label',
          ),
        ),
      );
      expect(tester.getSize(find.byType(HeroCheckbox)).width, 300);
      expect(
        tester.getSize(_content).width,
        16 + 12 + tester.getSize(find.text('Short')).width,
      );
    });

    testWidgets('a long label wraps next to the control', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 160,
          child: HeroCheckbox(
            label: 'Accept the terms and conditions of the service',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(_control), const Size(16, 16));
      expect(
        tester
            .getSize(
              find.text('Accept the terms and conditions of the service'),
            )
            .height,
        greaterThan(20),
      );
      expect(tester.getSize(_content).width, lessThanOrEqualTo(160));
    });

    testWidgets('RTL puts the control on the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 300,
          child: HeroCheckbox(label: 'Label', description: 'Description'),
        ),
        textDirection: TextDirection.rtl,
      );
      expect(tester.getTopRight(_control).dx, 300 + (800 - 300) / 2);
      expect(
        tester.getTopRight(_control).dx -
            tester.getTopRight(find.text('Description')).dx,
        28,
      );
      expect(
        tester.getTopLeft(_control).dx -
            tester.getTopRight(find.text('Label')).dx,
        12,
      );
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 200,
          child: HeroCheckbox(
            label: 'Enable email notifications',
            description: 'Get notified when someone mentions you in a comment',
            errorMessage: 'Required',
            isInvalid: true,
          ),
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Required'), findsOneWidget);
    });
  });

  group('HeroCheckbox selection', () {
    testWidgets('uncontrolled toggles on press', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];
      await pumpHero(
        tester,
        HeroCheckbox(label: 'Accept', onChanged: changes.add),
      );
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      expect(changes, <bool>[true]);
      expect(_node(tester).flagsCollection.isChecked, CheckedState.isTrue);
      await tester.tap(_control);
      await tester.pumpAndSettle();
      expect(changes, <bool>[true, false]);
      expect(_node(tester).flagsCollection.isChecked, CheckedState.isFalse);
    });

    testWidgets('defaultSelected starts checked', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const HeroCheckbox(label: 'On', defaultSelected: true),
      );
      expect(_node(tester).flagsCollection.isChecked, CheckedState.isTrue);
    });

    testWidgets('controlled follows isSelected', (WidgetTester tester) async {
      bool selected = false;
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroCheckbox(
                label: 'Email',
                isSelected: selected,
                onChanged: (bool value) => setState(() => selected = value),
              ),
              Text('Status: ${selected ? 'Enabled' : 'Disabled'}'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();
      expect(find.text('Status: Enabled'), findsOneWidget);

      // Without an update from the owner, the state does not change.
      await pumpHero(
        tester,
        const HeroCheckbox(label: 'Fixed', isSelected: true),
      );
      await tester.tap(find.text('Fixed'));
      await tester.pumpAndSettle();
      expect(_node(tester).flagsCollection.isChecked, CheckedState.isTrue);
    });

    testWidgets('Space toggles, Enter does not', (WidgetTester tester) async {
      final List<bool> changes = <bool>[];
      await pumpHero(
        tester,
        HeroCheckbox(label: 'Keys', onChanged: changes.add),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(_node(tester).flagsCollection.isFocused, Tristate.isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(changes, <bool>[true]);
    });

    testWidgets('keyboard focus shows the focus ring on the control', (
      WidgetTester tester,
    ) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await pumpHero(tester, const HeroCheckbox(label: 'Focus'));
      HeroFocusRing ring() => tester.widget<HeroFocusRing>(
        find.descendant(of: _control, matching: find.byType(HeroFocusRing)),
      );
      expect(ring().visible, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(ring().visible, isTrue);
    });

    testWidgets('pressing a label inside the checkbox toggles it once', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];
      await pumpHero(
        tester,
        HeroCheckbox(
          onChanged: changes.add,
          children: const <Widget>[
            HeroCheckboxContent(
              children: <Widget>[
                HeroCheckboxControl(),
                HeroLabel.text('Auto-save'),
              ],
            ),
          ],
        ),
      );
      await tester.tap(find.byType(HeroLabel));
      await tester.pumpAndSettle();
      expect(changes, <bool>[true]);
      // Labels inside a checkbox never show the required asterisk.
      expect(find.textContaining('*', findRichText: true), findsNothing);
    });

    testWidgets('disabled ignores input, dims and is not focusable', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];
      await pumpHero(
        tester,
        HeroCheckbox(
          label: 'Premium Feature',
          description: 'This feature is coming soon',
          isDisabled: true,
          onChanged: changes.add,
        ),
      );
      await tester.tap(find.text('Premium Feature'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      final SemanticsNode node = _node(tester);
      expect(node.flagsCollection.isEnabled, Tristate.isFalse);
      expect(node.flagsCollection.isFocused, Tristate.none);
      expect(_opacityAbove(tester, find.text('Premium Feature')), 0.5);
      // The description is dimmed once more (`status-disabled` compounds).
      expect(
        _opacityAbove(tester, find.text('This feature is coming soon')),
        0.25,
      );
    });

    testWidgets('read-only is focusable but does not toggle', (
      WidgetTester tester,
    ) async {
      final List<bool> changes = <bool>[];
      await pumpHero(
        tester,
        HeroCheckbox(label: 'Locked', isReadOnly: true, onChanged: changes.add),
      );
      await tester.tap(find.text('Locked'));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
      final SemanticsNode node = _node(tester);
      expect(node.flagsCollection.isReadOnly, isTrue);
      expect(node.flagsCollection.isFocused, Tristate.isTrue);
    });

    testWidgets('indeterminate is mixed until the owner clears it', (
      WidgetTester tester,
    ) async {
      bool indeterminate = true;
      bool selected = false;
      await pumpHero(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => HeroCheckbox(
            label: 'Select all',
            isIndeterminate: indeterminate,
            isSelected: selected,
            onChanged: (bool value) => setState(() {
              selected = value;
              indeterminate = false;
            }),
          ),
        ),
      );
      expect(_node(tester).flagsCollection.isChecked, CheckedState.mixed);
      expect(
        find.descendant(
          of: find.byType(HeroCheckboxIndicator),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Select all'));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      expect(_node(tester).flagsCollection.isChecked, CheckedState.isTrue);
    });

    testWidgets('builder receives the render props', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroCheckbox(
          builder: (BuildContext context, HeroCheckboxState state) => <Widget>[
            HeroCheckboxContent(
              children: <Widget>[
                const HeroCheckboxControl(),
                Text(state.isSelected ? 'Terms accepted' : 'Accept terms'),
              ],
            ),
          ],
        ),
      );
      expect(find.text('Accept terms'), findsOneWidget);
      await tester.tap(find.text('Accept terms'));
      await tester.pumpAndSettle();
      expect(find.text('Terms accepted'), findsOneWidget);
    });

    testWidgets('content builder receives hover and selection', (
      WidgetTester tester,
    ) async {
      final List<HeroInteractionState> states = <HeroInteractionState>[];
      await pumpHero(
        tester,
        HeroCheckbox(
          defaultSelected: true,
          children: <Widget>[
            HeroCheckboxContent(
              builder: (BuildContext context, HeroInteractionState state) {
                states.add(state);
                return const <Widget>[HeroCheckboxControl(), Text('State')];
              },
            ),
          ],
        ),
      );
      expect(states.last.isSelected, isTrue);
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: tester.getCenter(find.text('State')));
      await tester.pump();
      expect(states.last.isHovered, isTrue);
    });

    testWidgets('custom indicators use the indicator builder', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroCheckbox(
          defaultSelected: true,
          children: <Widget>[
            HeroCheckboxContent(
              children: <Widget>[
                HeroCheckboxControl(
                  child: HeroCheckboxIndicator(
                    builder: (BuildContext context, HeroCheckboxState state) =>
                        state.isSelected
                        ? const HeroIcon(HeroIcons.heartFill)
                        : null,
                  ),
                ),
                const Text('Heart'),
              ],
            ),
          ],
        ),
      );
      expect(find.byType(HeroIcon), findsOneWidget);
      // The icon takes the indicator's 12 px box and the glyph color.
      expect(tester.getSize(find.byType(HeroIcon)), const Size(12, 12));
      final IconThemeData icon = IconTheme.of(
        tester.element(find.byType(HeroIcon)),
      );
      expect(icon.color, _light.colors.accentForeground);
      await tester.tap(find.text('Heart'));
      await tester.pumpAndSettle();
      expect(find.byType(HeroIcon), findsNothing);
    });

    testWidgets('the checkmark draws after a short delay', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroCheckbox(label: 'Animate'));
      await tester.tap(find.text('Animate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      RenderObject glyph() => tester.renderObject(
        find.descendant(
          of: find.byType(HeroCheckboxIndicator),
          matching: find.byType(CustomPaint),
        ),
      );
      // `stroke-dashoffset 150ms linear 15ms`: nothing is drawn yet.
      expect(glyph(), paintsNothing);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pump(const Duration(milliseconds: 80));
      expect(glyph(), paints..path());
      await tester.pumpAndSettle();
      expect(glyph(), paints..path());
      // Unchecking erases it.
      await tester.tap(find.text('Animate'));
      await tester.pumpAndSettle();
      expect(glyph(), paintsNothing);
    });

    testWidgets('reduced motion draws the checkmark instantly', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroCheckbox(label: 'Instant'),
        theme: HeroThemeData.light().copyWith(
          motion: const HeroMotion(reduceMotion: true),
        ),
      );
      await tester.tap(find.text('Instant'));
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('HeroCheckbox validation', () {
    testWidgets('invalid shows the muted, indented error', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroCheckbox(
          label: 'I agree to the terms',
          isInvalid: true,
          isRequired: true,
          errorMessage: 'You must accept the terms to continue',
        ),
      );
      const String error = 'You must accept the terms to continue';
      expect(find.text(error), findsOneWidget);
      expect(_textColor(tester, error), _light.colors.muted);
      expect(
        tester.getTopLeft(find.text(error)).dx - tester.getTopLeft(_control).dx,
        28,
      );
      final SemanticsNode node = _node(tester);
      expect(node.validationResult, SemanticsValidationResult.invalid);
      expect(node.flagsCollection.isRequired, Tristate.isTrue);
      expect(node.hint, error);
    });

    testWidgets('the description is announced as the hint', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroCheckbox(
          label: 'Public profile',
          description: 'Allow others to see your profile',
        ),
      );
      final SemanticsNode node = _node(tester);
      expect(node.label, 'Public profile');
      expect(node.hint, 'Allow others to see your profile');
      expect(
        find.bySemanticsLabel('Allow others to see your profile'),
        findsNothing,
      );
      handle.dispose();
    });

    testWidgets('required blocks a HeroForm until checked', (
      WidgetTester tester,
    ) async {
      final List<Map<String, Object?>> submitted = <Map<String, Object?>>[];
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          onSubmit: submitted.add,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroCheckbox(name: 'terms', label: 'Terms', isRequired: true),
              HeroCheckbox(
                name: 'newsletter',
                label: 'Newsletter',
                value: 'weekly',
                defaultSelected: true,
              ),
              HeroCheckbox(name: 'marketing', label: 'Marketing'),
            ],
          ),
        ),
      );
      // Nothing shows before a submission (native behaviour).
      expect(
        find.text('Please check this box if you want to proceed.'),
        findsNothing,
      );
      form.currentState!.submit();
      await tester.pumpAndSettle();
      expect(submitted, isEmpty);
      expect(
        find.text('Please check this box if you want to proceed.'),
        findsOneWidget,
      );
      // The first invalid field is focused.
      expect(_node(tester).flagsCollection.isFocused, Tristate.isTrue);

      await tester.tap(find.text('Terms'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please check this box if you want to proceed.'),
        findsNothing,
      );
      form.currentState!.submit();
      expect(submitted.single, <String, Object?>{
        'terms': 'on',
        'newsletter': 'weekly',
      });
    });

    testWidgets('errors show after a change and reset clears them', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      final List<bool> changes = <bool>[];
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          child: HeroCheckbox(
            label: 'Agree',
            defaultSelected: true,
            isRequired: true,
            onChanged: changes.add,
          ),
        ),
      );
      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();
      expect(
        find.text('Please check this box if you want to proceed.'),
        findsOneWidget,
      );
      form.currentState!.reset();
      await tester.pumpAndSettle();
      expect(changes, <bool>[false, true]);
      expect(_node(tester).flagsCollection.isChecked, CheckedState.isTrue);
      expect(
        find.text('Please check this box if you want to proceed.'),
        findsNothing,
      );
    });

    testWidgets('validator, aria behaviour and server errors', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        HeroForm(
          validationBehavior: HeroValidationBehavior.aria,
          validationErrors: const <String, List<String>>{
            'beta': <String>['Beta is full'],
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroCheckbox(
                label: 'Updates',
                validator: (bool? value) =>
                    value ?? false ? null : 'Updates are recommended',
              ),
              const HeroCheckbox(name: 'beta', label: 'Beta'),
            ],
          ),
        ),
      );
      // Aria: realtime validator, server errors immediately.
      expect(find.text('Updates are recommended'), findsOneWidget);
      expect(find.text('Beta is full'), findsOneWidget);
      await tester.tap(find.text('Updates'));
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(find.text('Updates are recommended'), findsNothing);
      expect(find.text('Beta is full'), findsNothing);
    });

    testWidgets('onSaved receives the state and disabled boxes are skipped', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      bool? saved;
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroCheckbox(
                name: 'a',
                label: 'A',
                defaultSelected: true,
                onSaved: (bool? value) => saved = value,
              ),
              const HeroCheckbox(
                name: 'b',
                label: 'B',
                defaultSelected: true,
                isDisabled: true,
              ),
            ],
          ),
        ),
      );
      expect(form.currentState!.save(), <String, Object?>{'a': 'on'});
      expect(saved, isTrue);
    });
  });

  group('HeroFieldLayout', () {
    testWidgets('stretch false keeps widths and aligns to the start', (
      WidgetTester tester,
    ) async {
      Future<void> pumpLayout(TextDirection direction) => pumpHero(
        tester,
        const SizedBox(
          width: 200,
          child: HeroFieldLayout(
            spacing: 4,
            stretch: false,
            children: <Widget>[
              SizedBox(width: 50, height: 10),
              SizedBox.shrink(),
              SizedBox(width: 80, height: 10),
            ],
          ),
        ),
        textDirection: direction,
      );
      await pumpLayout(TextDirection.ltr);
      final Finder boxes = find.descendant(
        of: find.byType(HeroFieldLayout),
        matching: find.byType(SizedBox),
      );
      final Rect layout = tester.getRect(find.byType(HeroFieldLayout));
      expect(
        tester.getRect(boxes.first),
        Rect.fromLTWH(layout.left, layout.top, 50, 10),
      );
      // The empty part takes no gap.
      expect(tester.getTopLeft(boxes.last).dy, layout.top + 14);
      await pumpLayout(TextDirection.rtl);
      expect(tester.getTopRight(boxes.last).dx, layout.right);
    });
  });
}
