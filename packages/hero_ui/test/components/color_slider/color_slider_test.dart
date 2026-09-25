import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Finder track([int index = 0]) => find.byType(HeroColorSliderTrack).at(index);
  Finder thumb([int index = 0]) => find.byType(HeroColorSliderThumb).at(index);

  double hueOf(Color color) => HeroColorValue.fromColor(
    color,
    space: HeroColorSpace.hsl,
  ).channelValue(HeroColorChannel.hue);

  void useKeyboardHighlight() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
  }

  Widget hueSlider({
    Color? value,
    Color? defaultValue,
    ValueChanged<Color>? onChanged,
    ValueChanged<Color>? onChangeEnd,
    bool isDisabled = false,
  }) => SizedBox(
    width: 320,
    child: HeroColorSlider(
      channel: HeroColorChannel.hue,
      label: 'Hue',
      value: value,
      defaultValue: defaultValue,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      isDisabled: isDisabled,
    ),
  );

  testWidgets('label, output and track geometry', (WidgetTester tester) async {
    await pumpHero(
      tester,
      hueSlider(defaultValue: heroParseColor('hsl(180, 100%, 50%)')),
    );
    expect(find.text('Hue'), findsOneWidget);
    expect(find.text('180°'), findsOneWidget);
    final Rect trackRect = tester.getRect(track());
    expect(trackRect.size, const Size(320, 20));
    // The output sits at the end of the label row, 4 above the track.
    expect(tester.getRect(find.text('180°')).right, trackRect.right);
    expect(trackRect.top - tester.getRect(find.text('Hue')).bottom, 4);
    // Thumb: 16 px, centred at the value between the 10 px caps.
    final Rect thumbRect = tester.getRect(thumb());
    expect(thumbRect.size, const Size.square(16));
    expect(thumbRect.center.dx, trackRect.left + 10 + 300 * 0.5);
    expect(thumbRect.center.dy, trackRect.center.dy);
  });

  testWidgets('tapping the track jumps there; dragging adjusts', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    final List<Color> ends = <Color>[];
    await pumpHero(
      tester,
      hueSlider(
        defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
        onChanged: changes.add,
        onChangeEnd: ends.add,
      ),
    );
    final Rect rect = tester.getRect(track());
    await tester.tapAt(Offset(rect.left + 10 + 300 * 0.25, rect.center.dy));
    await tester.pumpAndSettle();
    expect(hueOf(changes.last), closeTo(90, 0.01));
    expect(ends, hasLength(1));
    expect(find.text('90°'), findsOneWidget);

    // Grabbing the thumb does not make it jump, then it follows the drag.
    final Offset start = tester.getCenter(thumb()) + const Offset(3, 0);
    final TestGesture gesture = await tester.startGesture(start);
    await tester.pump();
    expect(find.text('90°'), findsOneWidget);
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(35, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('180°'), findsOneWidget);
    expect(ends, hasLength(2));
    expect(hueOf(ends.last), closeTo(180, 0.01));
  });

  testWidgets('keyboard: arrows, shift, page keys, home and end', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    final List<Color> ends = <Color>[];
    await pumpHero(
      tester,
      hueSlider(
        defaultValue: heroParseColor('hsl(100, 100%, 50%)'),
        onChangeEnd: ends.add,
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('101°'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(find.text('99°'), findsOneWidget);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(find.text('114°'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pump();
    expect(find.text('99°'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(find.text('360°'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(find.text('0°'), findsOneWidget);
    expect(ends, hasLength(7));
  });

  testWidgets('right to left: the minimum is on the right', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    await pumpHero(
      tester,
      hueSlider(defaultValue: heroParseColor('hsl(90, 100%, 50%)')),
      textDirection: TextDirection.rtl,
    );
    final Rect rect = tester.getRect(track());
    expect(
      tester.getCenter(thumb()).dx,
      closeTo(rect.right - 10 - 300 * 0.25, 0.01),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(find.text('89°'), findsOneWidget);
    await tester.tapAt(Offset(rect.right - 10, rect.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('0°'), findsOneWidget);
  });

  testWidgets('controlled value only changes through the parent', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      hueSlider(
        value: heroParseColor('hsl(30, 100%, 50%)'),
        onChanged: changes.add,
      ),
    );
    final Rect rect = tester.getRect(track());
    await tester.tapAt(Offset(rect.left + 10 + 150, rect.center.dy));
    await tester.pumpAndSettle();
    expect(changes, hasLength(1));
    expect(find.text('30°'), findsOneWidget);
  });

  testWidgets('sliders sharing a color keep the hue at zero saturation', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    Color color = heroParseColor('hsl(200, 50%, 50%)');
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final HeroColorChannel channel in <HeroColorChannel>[
                HeroColorChannel.hue,
                HeroColorChannel.saturation,
              ])
                HeroColorSlider(
                  channel: channel,
                  label: channel.label,
                  value: color,
                  onChanged: (Color next) => setState(() => color = next),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('200°'), findsOneWidget);
    expect(heroColorToString(color), '#808080');
    await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
    await tester.pumpAndSettle();
    expect(find.text('200°'), findsOneWidget);
    expect(hueOf(color), closeTo(200, 0.01));
  });

  testWidgets('vertical sliders run from the bottom up', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      SizedBox(
        height: 192,
        child: HeroColorSlider(
          channel: HeroColorChannel.lightness,
          orientation: Axis.vertical,
          defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
          onChanged: changes.add,
        ),
      ),
    );
    final Rect rect = tester.getRect(track());
    expect(rect.size, const Size(20, 192));
    expect(tester.getCenter(thumb()).dy, closeTo(rect.center.dy, 0.01));
    await tester.tapAt(Offset(rect.center.dx, rect.top + 10));
    await tester.pumpAndSettle();
    expect(
      HeroColorValue.fromColor(
        changes.last,
        space: HeroColorSpace.hsl,
      ).channelValue(HeroColorChannel.lightness),
      closeTo(100, 0.01),
    );
  });

  testWidgets('disabled sliders ignore input and are not focusable', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      hueSlider(
        defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
        onChanged: changes.add,
        isDisabled: true,
      ),
    );
    final Rect rect = tester.getRect(track());
    await tester.tapAt(rect.centerLeft + const Offset(20, 0));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find.descendant(of: thumb(), matching: find.byType(DecoratedBox)),
    );
    expect(
      (box.decoration as ShapeDecoration).color,
      HeroThemeData.light().colors.defaultColor,
    );
  });

  testWidgets('semantics: an adjustable slider with the value text', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      hueSlider(
        defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
        onChanged: changes.add,
      ),
    );
    final SemanticsNode node = tester.getSemantics(thumb());
    expect(node.label, 'Hue');
    expect(node.value, startsWith('0°'));
    expect(node.increasedValue, startsWith('1°'));
    expect(node.flagsCollection.isSlider, isTrue);
    tester.semantics.increase(find.semantics.byLabel('Hue'));
    await tester.pumpAndSettle();
    expect(find.text('1°'), findsOneWidget);
    expect(changes, hasLength(1));
    handle.dispose();
  });

  testWidgets('channels pick their color space', (WidgetTester tester) async {
    HeroColorSliderState? state;
    await pumpHero(
      tester,
      SizedBox(
        width: 200,
        child: HeroColorSlider(
          channel: HeroColorChannel.red,
          colorSpace: HeroColorSpace.hsl,
          defaultValue: heroParseColor('rgb(255, 100, 50)'),
          builder: (BuildContext context, HeroColorSliderState s) {
            state = s;
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                HeroColorSliderOutput(),
                HeroColorSliderTrack(),
              ],
            );
          },
        ),
      ),
    );
    expect(state!.colorSpace, HeroColorSpace.rgb);
    expect(find.text('255'), findsOneWidget);
  });

  testWidgets('alpha output and custom children', (WidgetTester tester) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 240,
        child: HeroColorSlider(
          channel: HeroColorChannel.alpha,
          defaultValue: heroParseColor('hsla(0, 100%, 50%, 0.5)'),
          children: const <Widget>[
            HeroLabel.text('Alpha'),
            HeroColorSliderOutput(),
            HeroColorSliderTrack(
              thickness: 16,
              thumb: HeroColorSliderThumb(size: 12),
            ),
          ],
        ),
      ),
    );
    expect(find.text('50%'), findsOneWidget);
    expect(tester.getSize(track()).height, 16);
    expect(tester.getSize(thumb()), const Size.square(12));
  });

  testWidgets('binds to the color picker scope', (WidgetTester tester) async {
    HeroColorValue value = const HeroColorValue.hsb(120, 0, 0);
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) =>
            HeroColorPickerScope(
              value: value,
              onChanged: (HeroColorValue next) => setState(() => value = next),
              child: const SizedBox(
                width: 320,
                child: HeroColorSlider(
                  channel: HeroColorChannel.hue,
                  colorSpace: HeroColorSpace.hsb,
                  label: 'Hue',
                ),
              ),
            ),
      ),
    );
    // Black keeps its hue in the shared value.
    expect(find.text('120°'), findsOneWidget);
    final Rect rect = tester.getRect(track());
    await tester.tapAt(Offset(rect.left + 10 + 150, rect.center.dy));
    await tester.pumpAndSettle();
    expect(value.channelValue(HeroColorChannel.hue), 180);
    expect(value.space, HeroColorSpace.hsb);
  });

  testWidgets('pressing the label focuses the thumb; 2x text fits', (
    WidgetTester tester,
  ) async {
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpHero(
      tester,
      SizedBox(
        width: 320,
        child: HeroColorSlider(
          channel: HeroColorChannel.saturation,
          label: 'Saturation',
          focusNode: node,
          defaultValue: heroParseColor('hsl(0, 100%, 50%)'),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Saturation'));
    await tester.pump();
    expect(node.hasFocus, isTrue);
  });
}
