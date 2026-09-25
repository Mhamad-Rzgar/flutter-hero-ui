import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Finder trigger() => find.byType(HeroColorPickerTrigger);
  Finder area() => find
      .descendant(
        of: find.byType(HeroColorArea),
        matching: find.byType(CustomPaint),
      )
      .first;

  Color triggerSwatch(WidgetTester tester) {
    final CustomPaint paint = tester.widget<CustomPaint>(
      find
          .descendant(
            of: find.descendant(
              of: trigger(),
              matching: find.byType(HeroColorSwatch),
            ),
            matching: find.byType(CustomPaint),
          )
          .first,
    );
    return (paint.painter! as HeroColorSwatchPainter).color;
  }

  Widget topStart(Widget child) => Align(
    alignment: AlignmentDirectional.topStart,
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  void useKeyboardHighlight() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
  }

  testWidgets('the trigger opens the popover below it; outside taps close', (
    WidgetTester tester,
  ) async {
    final List<bool> openChanges = <bool>[];
    await pumpHero(
      tester,
      topStart(
        HeroColorPicker(
          label: 'Pick a color',
          defaultValue: const Color(0xFF0485F7),
          onOpenChanged: openChanges.add,
        ),
      ),
    );
    expect(find.byType(HeroColorArea), findsNothing);
    expect(heroColorToString(triggerSwatch(tester)), '#0485F7');
    await tester.tap(find.text('Pick a color'));
    await tester.pumpAndSettle();
    expect(find.byType(HeroColorArea), findsOneWidget);
    expect(find.byType(HeroColorSlider), findsOneWidget);
    final Rect popover = tester.getRect(find.byType(HeroColorPickerPopover));
    expect(popover.width, 248);
    expect(popover.top - tester.getRect(trigger()).bottom, 8);
    expect(popover.left, tester.getRect(trigger()).left);
    // The area fills the popover content box.
    expect(tester.getSize(area()), const Size.square(232));

    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();
    expect(find.byType(HeroColorArea), findsNothing);
    expect(openChanges, <bool>[true, false]);
  });

  testWidgets('keyboard: Enter opens, focus moves in, Escape returns it', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    await pumpHero(
      tester,
      topStart(
        const HeroColorPicker(
          label: 'Pick a color',
          defaultValue: Color(0xFF0485F7),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final FocusNode triggerFocus = Focus.of(
      tester.element(find.text('Pick a color')),
    );
    expect(triggerFocus.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(HeroColorArea), findsOneWidget);
    // The area thumb has focus: arrow keys move it.
    expect(triggerFocus.hasFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    final HeroColorValue value = HeroColorValue.fromColor(
      triggerSwatch(tester),
      space: HeroColorSpace.hsb,
    );
    expect(value.channelValue(HeroColorChannel.saturation), closeTo(97, 0.6));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(HeroColorArea), findsNothing);
    expect(triggerFocus.hasFocus, isTrue);
  });

  testWidgets('components in the popover edit the picker color', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      topStart(
        HeroColorPicker(
          defaultValue: const Color(0xFF325578),
          defaultOpen: true,
          onChanged: changes.add,
          trigger: const HeroColorPickerTrigger(
            children: <Widget>[
              HeroColorSwatch(size: HeroColorSwatchSize.lg),
              HeroLabel.text('Pick a color'),
            ],
          ),
          popover: const HeroColorPickerPopover(
            children: <Widget>[
              HeroColorSwatchPicker(
                size: HeroColorSwatchSize.xs,
                colors: <Color>[Color(0xFFEF4444), Color(0xFF22C55E)],
              ),
              HeroColorArea(maxSize: double.infinity),
              HeroColorSlider(
                channel: HeroColorChannel.hue,
                colorSpace: HeroColorSpace.hsb,
                label: 'Hue',
              ),
              HeroColorField(semanticLabel: 'Color field'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '#325578',
    );

    await tester.tap(find.byType(HeroColorSwatchPickerItem).first);
    await tester.pumpAndSettle();
    expect(heroColorToString(changes.last), '#EF4444');
    expect(heroColorToString(triggerSwatch(tester)), '#EF4444');
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '#EF4444',
    );

    // Dragging brightness to zero keeps the hue on the slider.
    final Rect box = tester.getRect(area());
    await tester.tapAt(box.bottomLeft + Offset(box.width / 2, -0.2));
    await tester.pumpAndSettle();
    expect(heroColorToString(changes.last), '#000000');
    expect(find.text('0°'), findsOneWidget);
    await tester.tapAt(box.topLeft + Offset(box.width - 1, 1));
    await tester.pumpAndSettle();
    expect(heroColorToString(changes.last), startsWith('#F'));
    expect(find.text('0°'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '22C55E');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(heroColorToString(triggerSwatch(tester)), '#22C55E');
  });

  testWidgets('controlled value and open state', (WidgetTester tester) async {
    Color color = const Color(0xFF0485F7);
    bool open = false;
    late StateSetter update;
    await pumpHero(
      tester,
      topStart(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            update = setState;
            return HeroColorPicker(
              label: 'Pick a color',
              value: color,
              onChanged: (Color next) => setState(() => color = next),
              isOpen: open,
              onOpenChanged: (bool next) => setState(() => open = next),
            );
          },
        ),
      ),
    );
    update(() => color = const Color(0xFFF43F5E));
    await tester.pump();
    expect(heroColorToString(triggerSwatch(tester)), '#F43F5E');

    update(() => open = true);
    await tester.pumpAndSettle();
    expect(find.byType(HeroColorArea), findsOneWidget);
    await tester.tap(find.text('Pick a color'));
    await tester.pumpAndSettle();
    expect(open, isFalse);
    expect(find.byType(HeroColorArea), findsNothing);
  });

  testWidgets('a controlled picker ignores edits its parent rejects', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      topStart(
        HeroColorPicker(
          label: 'Pick a color',
          value: const Color(0xFF0485F7),
          onChanged: changes.add,
          defaultOpen: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getCenter(area()));
    await tester.pumpAndSettle();
    expect(changes, hasLength(1));
    expect(heroColorToString(triggerSwatch(tester)), '#0485F7');
  });

  testWidgets('disabled pickers do not open', (WidgetTester tester) async {
    useKeyboardHighlight();
    await pumpHero(
      tester,
      topStart(
        const HeroColorPicker(
          label: 'Pick a color',
          isDisabled: true,
          defaultOpen: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HeroColorArea), findsNothing);
    await tester.tap(find.text('Pick a color'));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.byType(HeroColorArea), findsNothing);
  });

  testWidgets('semantics: an expandable button and a dialog', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      topStart(
        const HeroColorPicker(
          label: 'Pick a color',
          defaultValue: Color(0xFF0485F7),
        ),
      ),
    );
    SemanticsNode button = tester.getSemantics(trigger());
    expect(button.flagsCollection.isButton, isTrue);
    expect(button.flagsCollection.isExpanded, Tristate.isFalse);
    await tester.tap(trigger());
    await tester.pumpAndSettle();
    button = tester.getSemantics(trigger());
    expect(button.flagsCollection.isExpanded, Tristate.isTrue);
    expect(find.semantics.byLabel('Color picker'), findsOne);
    handle.dispose();
  });

  testWidgets('right to left and 2x text', (WidgetTester tester) async {
    await pumpHero(
      tester,
      topStart(
        const HeroColorPicker(
          label: 'Pick a color',
          defaultValue: Color(0xFF0485F7),
          defaultOpen: true,
        ),
      ),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // The popover opens at the start (right) edge of the trigger.
    expect(
      tester.getRect(find.byType(HeroColorPickerPopover)).right,
      closeTo(tester.getRect(trigger()).right, 0.01),
    );
  });
}
