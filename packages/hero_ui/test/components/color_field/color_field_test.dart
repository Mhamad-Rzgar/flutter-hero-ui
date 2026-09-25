import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Finder input([int index = 0]) => find.byType(EditableText).at(index);

  String textOf(WidgetTester tester, [int index = 0]) =>
      tester.widget<EditableText>(input(index)).controller.text;

  Future<void> commit(WidgetTester tester, String text, [int index = 0]) async {
    await tester.enterText(input(index), text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> focus(WidgetTester tester, [int index = 0]) async {
    await tester.tap(input(index));
    await tester.pumpAndSettle();
  }

  testWidgets('hex: commits on Enter and formats as #RRGGBB', (
    WidgetTester tester,
  ) async {
    final List<Color?> changes = <Color?>[];
    await pumpHero(
      tester,
      HeroColorField(
        label: 'Color',
        defaultValue: const Color(0xFF0485F7),
        onChanged: changes.add,
      ),
    );
    expect(find.text('Color'), findsOneWidget);
    expect(textOf(tester), '#0485F7');
    await commit(tester, 'ff0000');
    expect(textOf(tester), '#FF0000');
    expect(changes, hasLength(1));
    expect(heroColorToString(changes.single!), '#FF0000');
    await commit(tester, '#0f0');
    expect(textOf(tester), '#00FF00');
    // Typing alone does not change the value.
    await tester.enterText(input(), '#123');
    await tester.pump();
    expect(changes, hasLength(2));
  });

  testWidgets('hex: invalid text reverts, empty text clears on blur', (
    WidgetTester tester,
  ) async {
    final List<Color?> changes = <Color?>[];
    final FocusNode other = FocusNode();
    addTearDown(other.dispose);
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroColorField(
            semanticLabel: 'Color',
            defaultValue: const Color(0xFF0485F7),
            onChanged: changes.add,
          ),
          Focus(focusNode: other, child: const SizedBox(width: 10, height: 10)),
        ],
      ),
    );
    await focus(tester);
    await tester.enterText(input(), '12');
    other.requestFocus();
    await tester.pumpAndSettle();
    expect(textOf(tester), '#0485F7');
    expect(changes, isEmpty);

    await focus(tester);
    await tester.enterText(input(), '');
    other.requestFocus();
    await tester.pumpAndSettle();
    expect(textOf(tester), '');
    expect(changes, <Color?>[null]);
  });

  testWidgets('hex: non-hex characters are rejected while typing', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const HeroColorField(semanticLabel: 'Color'));
    await focus(tester);
    await tester.enterText(input(), 'not-a-color');
    await tester.pump();
    expect(textOf(tester), '');
    await tester.enterText(input(), '#abc');
    await tester.pump();
    expect(textOf(tester), '#abc');
  });

  testWidgets('hex: arrow, page, home and end keys step the value', (
    WidgetTester tester,
  ) async {
    final List<Color?> changes = <Color?>[];
    await pumpHero(
      tester,
      HeroColorField(
        semanticLabel: 'Color',
        defaultValue: const Color(0xFF0485F7),
        onChanged: changes.add,
      ),
    );
    await focus(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(textOf(tester), '#0485F8');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    expect(textOf(tester), '#0485F6');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(textOf(tester), '#FFFFFF');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(textOf(tester), '#000000');
    expect(changes, hasLength(5));
  });

  testWidgets('the mouse wheel steps while focused unless disabled', (
    WidgetTester tester,
  ) async {
    Future<void> scroll() async {
      final TestPointer pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(tester.getCenter(input())));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -20)));
      await tester.pump();
    }

    await pumpHero(
      tester,
      const HeroColorField(
        semanticLabel: 'Color',
        defaultValue: Color(0xFF000010),
      ),
    );
    await scroll();
    expect(textOf(tester), '#000010');
    await focus(tester);
    await scroll();
    expect(textOf(tester), '#000011');

    await pumpHero(
      tester,
      const HeroColorField(
        key: ValueKey<String>('wheel-disabled'),
        semanticLabel: 'Color',
        isWheelDisabled: true,
        defaultValue: Color(0xFF000010),
      ),
    );
    await focus(tester);
    await scroll();
    expect(textOf(tester), '#000010');
  });

  testWidgets('channel mode edits one channel as a number', (
    WidgetTester tester,
  ) async {
    Color color = const Color(0xFF7F007F);
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final HeroColorChannel channel in <HeroColorChannel>[
              HeroColorChannel.hue,
              HeroColorChannel.saturation,
            ])
              SizedBox(
                width: 100,
                child: HeroColorField(
                  channel: channel,
                  colorSpace: HeroColorSpace.hsl,
                  label: channel.label,
                  value: color,
                  onChanged: (Color? next) => setState(() => color = next!),
                ),
              ),
          ],
        ),
      ),
    );
    expect(textOf(tester), '300');
    expect(textOf(tester, 1), '100');
    await focus(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(textOf(tester), '301');
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pump();
    expect(textOf(tester), '316');
    await commit(tester, '400');
    expect(textOf(tester), '360');
    await commit(tester, '120', 0);
    expect(heroColorToString(color), '#007F00');
    // Saturation zero keeps the hue in the shared color.
    await commit(tester, '0', 1);
    expect(textOf(tester), '120');
    expect(heroColorToString(color), '#404040');
    // Invalid numbers revert.
    await commit(tester, '-', 1);
    expect(textOf(tester, 1), '0');
  });

  testWidgets('controlled: new values replace the text; null clears it', (
    WidgetTester tester,
  ) async {
    Color? value = const Color(0xFF0485F7);
    late StateSetter update;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          update = setState;
          return HeroColorField(
            label: 'Color',
            showSwatch: true,
            value: value,
            onChanged: (Color? next) => setState(() => value = next),
          );
        },
      ),
    );
    update(() => value = const Color(0xFFEF4444));
    await tester.pump();
    expect(textOf(tester), '#EF4444');
    final HeroColorSwatchPainter swatch =
        tester
                .widget<CustomPaint>(
                  find
                      .descendant(
                        of: find.byType(HeroColorSwatch),
                        matching: find.byType(CustomPaint),
                      )
                      .first,
                )
                .painter!
            as HeroColorSwatchPainter;
    expect(heroColorToString(swatch.color), '#EF4444');
    update(() => value = null);
    await tester.pump();
    expect(textOf(tester), '');
    await commit(tester, '10B981');
    expect(heroColorToString(value!), '#10B981');
  });

  testWidgets('required fields block form submission with an error', (
    WidgetTester tester,
  ) async {
    final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
    Map<String, Object?>? submitted;
    await pumpHero(
      tester,
      SizedBox(
        width: 280,
        child: HeroForm(
          key: form,
          onSubmit: (Map<String, Object?> data) => submitted = data,
          child: const HeroColorField(
            name: 'brand-color',
            label: 'Brand Color',
            isRequired: true,
            placeholder: '#000000',
            description: "Choose your brand's primary color",
          ),
        ),
      ),
    );
    expect(find.text("Choose your brand's primary color"), findsOneWidget);
    form.currentState!.submit();
    await tester.pumpAndSettle();
    expect(submitted, isNull);
    expect(find.text('Please fill out this field.'), findsOneWidget);
    expect(find.text("Choose your brand's primary color"), findsNothing);

    await commit(tester, '#3B82F6');
    expect(find.text('Please fill out this field.'), findsNothing);
    form.currentState!.submit();
    await tester.pumpAndSettle();
    expect(submitted, <String, Object?>{'brand-color': '#3B82F6'});
  });

  testWidgets('isInvalid shows the field error and the invalid outline', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 280,
        child: HeroColorField(
          isInvalid: true,
          children: <Widget>[
            HeroLabel.text('Color'),
            HeroColorInputGroup(
              children: <Widget>[HeroColorInput(placeholder: '#000000')],
            ),
            HeroFieldError.text('Please enter a valid hex color'),
          ],
        ),
      ),
    );
    expect(find.text('Please enter a valid hex color'), findsOneWidget);
    final HeroFieldBox box = tester.widget<HeroFieldBox>(
      find.byType(HeroFieldBox),
    );
    expect(box.isInvalid, isTrue);
  });

  testWidgets('disabled and read-only fields do not change', (
    WidgetTester tester,
  ) async {
    final List<Color?> changes = <Color?>[];
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroColorField(
            semanticLabel: 'Disabled',
            isDisabled: true,
            defaultValue: const Color(0xFF0485F7),
            onChanged: changes.add,
          ),
          HeroColorField(
            semanticLabel: 'Read only',
            isReadOnly: true,
            defaultValue: const Color(0xFF0485F7),
            onChanged: changes.add,
          ),
        ],
      ),
    );
    await tester.tap(input(0));
    await tester.pump();
    expect(tester.widget<EditableText>(input(0)).focusNode.hasFocus, isFalse);
    await focus(tester, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(textOf(tester, 1), '#0485F7');
    expect(changes, isEmpty);
  });

  testWidgets('binds to the color picker scope', (WidgetTester tester) async {
    HeroColorValue value = const HeroColorValue.hsl(220, 90, 50);
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) =>
            HeroColorPickerScope(
              value: value,
              onChanged: (HeroColorValue next) => setState(() => value = next),
              child: const SizedBox(
                width: 100,
                child: HeroColorField(
                  semanticLabel: 'Hue',
                  channel: HeroColorChannel.hue,
                  colorSpace: HeroColorSpace.hsl,
                ),
              ),
            ),
      ),
    );
    expect(textOf(tester), '220');
    await commit(tester, '10');
    expect(value.channelValue(HeroColorChannel.hue), 10);
    expect(value.space, HeroColorSpace.hsl);
  });

  testWidgets('semantics: a text field labelled by the label', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const HeroColorField(
        label: 'Color',
        description: 'Pick a color',
        defaultValue: Color(0xFF0485F7),
      ),
    );
    expect(
      find.semantics.byPredicate(
        (SemanticsNode node) =>
            node.label == 'Color' && node.flagsCollection.isTextField,
      ),
      findsOne,
    );
    handle.dispose();
  });

  testWidgets('right to left and 2x text', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 280,
        child: HeroColorField(
          label: 'Color',
          showSwatch: true,
          defaultValue: Color(0xFF0485F7),
        ),
      ),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getCenter(find.byType(HeroColorSwatch)).dx,
      greaterThan(tester.getCenter(input()).dx),
    );
    expect(
      tester.getSize(find.byType(HeroColorInputGroup)).height,
      greaterThan(36),
    );
  });

  testWidgets('an unsized field is as wide as a native input', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroColorField(
        semanticLabel: 'Color',
        defaultValue: Color(0xFF0485F7),
      ),
    );
    expect(
      tester.getSize(find.byType(HeroColorInputGroup)),
      const Size(192, 36),
    );
  });
}
