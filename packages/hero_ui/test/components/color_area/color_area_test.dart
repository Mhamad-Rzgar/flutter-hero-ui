import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Finder areaBox() => find
      .descendant(
        of: find.byType(HeroColorArea),
        matching: find.byType(CustomPaint),
      )
      .first;
  Finder thumb() => find.byType(HeroColorAreaThumb);

  HeroColorValue hsb(Color color) =>
      HeroColorValue.fromColor(color, space: HeroColorSpace.hsb);

  void useKeyboardHighlight() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
  }

  test('axes default to hsb saturation × brightness and are corrected', () {
    expect(HeroColorArea.resolveAxes(), (
      HeroColorSpace.hsb,
      HeroColorChannel.saturation,
      HeroColorChannel.brightness,
    ));
    expect(HeroColorArea.resolveAxes(colorSpace: HeroColorSpace.rgb), (
      HeroColorSpace.rgb,
      HeroColorChannel.red,
      HeroColorChannel.green,
    ));
    expect(
      HeroColorArea.resolveAxes(
        colorSpace: HeroColorSpace.rgb,
        xChannel: HeroColorChannel.blue,
      ),
      (HeroColorSpace.rgb, HeroColorChannel.blue, HeroColorChannel.red),
    );
    expect(
      HeroColorArea.resolveAxes(
        colorSpace: HeroColorSpace.hsl,
        yChannel: HeroColorChannel.brightness,
      ),
      (HeroColorSpace.hsb, HeroColorChannel.hue, HeroColorChannel.brightness),
    );
    expect(
      HeroColorArea.resolveAxes(
        colorSpace: HeroColorSpace.rgb,
        xChannel: HeroColorChannel.hue,
        yChannel: HeroColorChannel.hue,
      ),
      (HeroColorSpace.hsl, HeroColorChannel.hue, HeroColorChannel.saturation),
    );
  });

  testWidgets('sizes: 224 by default, fills narrower widths, fixed size', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const HeroColorArea());
    expect(tester.getSize(areaBox()), const Size.square(224));
    await pumpHero(tester, const SizedBox(width: 180, child: HeroColorArea()));
    expect(tester.getSize(areaBox()), const Size.square(180));
    await pumpHero(
      tester,
      const SizedBox(
        width: 260,
        child: HeroColorArea(maxSize: double.infinity),
      ),
    );
    expect(tester.getSize(areaBox()), const Size.square(260));
    await pumpHero(tester, const HeroColorArea(size: 176));
    expect(tester.getSize(areaBox()), const Size.square(176));
    expect(tester.getSize(thumb()), const Size.square(16));
  });

  testWidgets('the thumb sits at x from the start and y from the bottom', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroColorArea(
        size: 200,
        defaultValue: heroParseColor('hsb(219, 25%, 75%)'),
      ),
    );
    final Rect box = tester.getRect(areaBox());
    expect(tester.getCenter(thumb()), Offset(box.left + 50, box.top + 50));
    await pumpHero(
      tester,
      HeroColorArea(
        size: 200,
        defaultValue: heroParseColor('hsb(219, 25%, 75%)'),
      ),
      textDirection: TextDirection.rtl,
    );
    final Rect rtlBox = tester.getRect(areaBox());
    expect(
      tester.getCenter(thumb()),
      Offset(rtlBox.right - 50, rtlBox.top + 50),
    );
  });

  testWidgets('pressing and dragging set both channels', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    final List<Color> ends = <Color>[];
    await pumpHero(
      tester,
      HeroColorArea(
        size: 200,
        defaultValue: heroParseColor('hsb(120, 50%, 50%)'),
        onChanged: changes.add,
        onChangeEnd: ends.add,
      ),
    );
    final Rect box = tester.getRect(areaBox());
    final TestGesture gesture = await tester.startGesture(
      box.topLeft + const Offset(150, 20),
    );
    await tester.pump();
    HeroColorValue value = hsb(changes.last);
    expect(value.channelValue(HeroColorChannel.saturation), closeTo(75, 0.6));
    expect(value.channelValue(HeroColorChannel.brightness), closeTo(90, 0.6));
    expect(value.channelValue(HeroColorChannel.hue), closeTo(120, 0.6));
    // The thumb grows while dragged.
    await tester.pumpAndSettle();
    expect(tester.getSize(thumb()), const Size.square(20));

    await gesture.moveTo(box.topLeft + const Offset(40, 160));
    await tester.pump();
    value = hsb(changes.last);
    expect(value.channelValue(HeroColorChannel.saturation), closeTo(20, 0.6));
    expect(value.channelValue(HeroColorChannel.brightness), closeTo(20, 0.6));
    expect(ends, isEmpty);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(ends, hasLength(1));
    expect(tester.getSize(thumb()), const Size.square(16));
  });

  testWidgets('inside a scroll view presses set the value, drags do not '
      'scroll', (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      SizedBox(
        height: 400,
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: <Widget>[
              HeroColorArea(
                size: 200,
                defaultValue: heroParseColor('hsb(0, 50%, 50%)'),
                onChanged: changes.add,
              ),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      ),
    );
    final Rect box = tester.getRect(areaBox());
    await tester.tapAt(box.topLeft + const Offset(150, 150));
    await tester.pumpAndSettle();
    expect(changes, hasLength(1));
    await tester.dragFrom(
      box.topLeft + const Offset(100, 100),
      const Offset(0, -80),
    );
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
    expect(
      hsb(changes.last).channelValue(HeroColorChannel.brightness),
      closeTo(90, 0.6),
    );
  });

  testWidgets('keyboard moves each axis by steps and pages', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    Color? last;
    await pumpHero(
      tester,
      HeroColorArea(
        defaultValue: heroParseColor('hsb(200, 50%, 50%)'),
        onChanged: (Color color) => last = color,
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    Future<(double, double)> press(LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump();
      final HeroColorValue v = hsb(last!);
      return (
        v.channelValue(HeroColorChannel.saturation).roundToDouble(),
        v.channelValue(HeroColorChannel.brightness).roundToDouble(),
      );
    }

    expect(await press(LogicalKeyboardKey.arrowRight), (51.0, 50.0));
    expect(await press(LogicalKeyboardKey.arrowUp), (51.0, 51.0));
    expect(await press(LogicalKeyboardKey.arrowDown), (51.0, 50.0));
    expect(await press(LogicalKeyboardKey.arrowLeft), (50.0, 50.0));
    expect(await press(LogicalKeyboardKey.pageUp), (50.0, 60.0));
    expect(await press(LogicalKeyboardKey.pageDown), (50.0, 50.0));
    expect(await press(LogicalKeyboardKey.end), (60.0, 50.0));
    expect(await press(LogicalKeyboardKey.home), (50.0, 50.0));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    expect(await press(LogicalKeyboardKey.arrowRight), (60.0, 50.0));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  });

  testWidgets('right to left mirrors the horizontal keys', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    Color? last;
    await pumpHero(
      tester,
      HeroColorArea(
        defaultValue: heroParseColor('hsb(200, 50%, 50%)'),
        onChanged: (Color color) => last = color,
      ),
      textDirection: TextDirection.rtl,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(
      hsb(last!).channelValue(HeroColorChannel.saturation),
      closeTo(51, 0.01),
    );
  });

  testWidgets('keeps the hue when brightness reaches zero', (
    WidgetTester tester,
  ) async {
    Color color = heroParseColor('hsb(200, 80%, 60%)');
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => HeroColorArea(
          size: 200,
          value: color,
          onChanged: (Color next) => setState(() => color = next),
        ),
      ),
    );
    final Rect box = tester.getRect(areaBox());
    await tester.tapAt(box.bottomLeft + const Offset(100, -0.2));
    await tester.pumpAndSettle();
    expect(heroColorToString(color), '#000000');
    await tester.tapAt(box.topLeft + const Offset(100, 1));
    await tester.pumpAndSettle();
    expect(hsb(color).channelValue(HeroColorChannel.hue), closeTo(200, 0.5));
  });

  testWidgets('controlled value only changes through the parent', (
    WidgetTester tester,
  ) async {
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      HeroColorArea(
        size: 200,
        value: heroParseColor('hsb(0, 0%, 100%)'),
        onChanged: changes.add,
      ),
    );
    final Rect box = tester.getRect(areaBox());
    final Offset before = tester.getCenter(thumb());
    await tester.tapAt(box.center);
    await tester.pumpAndSettle();
    expect(changes, hasLength(1));
    expect(tester.getCenter(thumb()), before);
  });

  testWidgets('rgb axes edit the red and green channels', (
    WidgetTester tester,
  ) async {
    Color? last;
    await pumpHero(
      tester,
      HeroColorArea(
        size: 255,
        colorSpace: HeroColorSpace.rgb,
        xChannel: HeroColorChannel.red,
        yChannel: HeroColorChannel.green,
        defaultValue: heroParseColor('#9B80FF'),
        onChanged: (Color color) => last = color,
      ),
    );
    final Rect box = tester.getRect(areaBox());
    await tester.tapAt(box.topLeft + const Offset(10, 245));
    await tester.pumpAndSettle();
    expect(heroColorToString(last!), '#0A0AFF');
  });

  testWidgets('disabled areas ignore input and are not focusable', (
    WidgetTester tester,
  ) async {
    useKeyboardHighlight();
    final List<Color> changes = <Color>[];
    await pumpHero(
      tester,
      HeroColorArea(
        isDisabled: true,
        defaultValue: heroParseColor('hsl(200, 100%, 50%)'),
        onChanged: changes.add,
      ),
    );
    await tester.tapAt(tester.getCenter(areaBox()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    final Opacity opacity = tester.widget<Opacity>(
      find
          .descendant(
            of: find.byType(HeroColorArea),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('semantics: a group of two adjustable sliders', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    Color? last;
    await pumpHero(
      tester,
      HeroColorArea(
        defaultValue: heroParseColor('hsb(219, 58%, 93%)'),
        onChanged: (Color color) => last = color,
      ),
    );
    final SemanticsNode group = find.semantics
        .byLabel('Color picker')
        .evaluate()
        .single;
    expect(group.value, contains('blue'));
    final SemanticsNode x = find.semantics
        .byLabel('Saturation')
        .evaluate()
        .single;
    expect(x.flagsCollection.isSlider, isTrue);
    expect(x.value, '58%');
    expect(x.increasedValue, '59%');
    expect(x.decreasedValue, '57%');
    final SemanticsNode y = find.semantics
        .byLabel('Brightness')
        .evaluate()
        .single;
    expect(y.value, '93%');
    handle.dispose();
    expect(last, isNull);
  });

  testWidgets('semantic actions adjust each axis', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    Color? last;
    await pumpHero(
      tester,
      HeroColorArea(
        defaultValue: heroParseColor('hsb(219, 58%, 93%)'),
        onChanged: (Color color) => last = color,
      ),
    );
    tester.semantics.increase(find.semantics.byLabel('Saturation'));
    await tester.pump();
    expect(
      hsb(last!).channelValue(HeroColorChannel.saturation),
      closeTo(59, 0.01),
    );
    tester.semantics.decrease(find.semantics.byLabel('Brightness'));
    await tester.pump();
    expect(
      hsb(last!).channelValue(HeroColorChannel.brightness),
      closeTo(92, 0.01),
    );
    handle.dispose();
  });

  testWidgets('binds to the color picker scope', (WidgetTester tester) async {
    HeroColorValue value = const HeroColorValue.hsb(40, 50, 50);
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) =>
            HeroColorPickerScope(
              value: value,
              onChanged: (HeroColorValue next) => setState(() => value = next),
              child: const HeroColorArea(size: 200),
            ),
      ),
    );
    final Rect box = tester.getRect(areaBox());
    await tester.tapAt(box.topLeft + const Offset(20, 180));
    await tester.pumpAndSettle();
    expect(value.space, HeroColorSpace.hsb);
    expect(value.channelValue(HeroColorChannel.hue), 40);
    expect(value.channelValue(HeroColorChannel.saturation), 10);
    expect(value.channelValue(HeroColorChannel.brightness), 10);
  });

  testWidgets('custom thumb builder receives the state', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroColorArea(
        defaultValue: heroParseColor('#FF0000'),
        thumb: HeroColorAreaThumb(
          builder: (BuildContext context, HeroColorAreaState state) =>
              SizedBox.square(
                dimension: 10,
                child: Text(heroColorToString(state.color)),
              ),
        ),
      ),
      textScale: 2,
    );
    expect(find.text('#FF0000'), findsOneWidget);
  });
}
