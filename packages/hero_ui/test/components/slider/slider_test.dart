import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// `max-w-xs`: a 320 wide slider whose track has 296 usable pixels.
Widget _xs(Widget child) => SizedBox(width: 320, child: child);

Finder _thumb([int index = 0]) => find.byWidgetPredicate(
  (Widget w) => w is HeroSliderThumb && w.index == index,
);

Finder _track() => find.byType(HeroSliderTrack);

/// The x position of [fraction] on a horizontal track of the default
/// geometry (12 px caps).
double _xAt(WidgetTester tester, double fraction) {
  final Rect track = tester.getRect(_track());
  return track.left + 12 + fraction * (track.width - 24);
}

void main() {
  testWidgets('builds the standard layout from a label', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xs(const HeroSlider(defaultValue: 30, label: Text('Volume'))),
    );
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    final Rect slider = tester.getRect(find.byType(HeroSlider));
    final Rect track = tester.getRect(_track());
    expect(slider.width, 320);
    expect(track.width, 320);
    expect(track.height, 20);
    expect(track.top, tester.getRect(find.text('Volume')).bottom + 4);
    expect(tester.getRect(find.text('30')).right, slider.right);

    final Rect thumb = tester.getRect(_thumb());
    expect(thumb.size, const Size(28, 20));
    expect(thumb.center.dx, closeTo(_xAt(tester, 0.3), 0.01));
    final Rect fill = tester.getRect(find.byType(HeroSliderFill));
    expect(fill.left, track.left + 12);
    expect(fill.right, closeTo(thumb.center.dx, 0.01));
  });

  testWidgets('without a label it is only a track', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xs(const HeroSlider(defaultValue: 30, semanticLabel: 'Volume')),
    );
    expect(find.byType(HeroSliderOutput), findsNothing);
    expect(tester.getSize(find.byType(HeroSlider)), const Size(320, 20));
  });

  testWidgets('dragging a thumb moves it by the pointer travel', (
    WidgetTester tester,
  ) async {
    final List<double> changes = <double>[];
    final List<double> ends = <double>[];
    await pumpHero(
      tester,
      _xs(
        HeroSlider(
          defaultValue: 30,
          label: const Text('Volume'),
          onChanged: changes.add,
          onChangeEnd: ends.add,
        ),
      ),
    );
    // Grab the thumb off-center: it does not jump to the pointer.
    final Offset start = tester.getCenter(_thumb()) + const Offset(6, 0);
    final TestGesture gesture = await tester.startGesture(start);
    await tester.pump();
    await gesture.moveBy(const Offset(29.6, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(29.6, 0));
    await tester.pump();
    expect(find.text('50'), findsOneWidget);
    expect(ends, isEmpty);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes.last, 50);
    expect(ends, <double>[50]);
    expect(tester.getCenter(_thumb()).dx, closeTo(_xAt(tester, 0.5), 0.01));
  });

  testWidgets('pressing the track moves the closest thumb there', (
    WidgetTester tester,
  ) async {
    final List<double> ends = <double>[];
    await pumpHero(
      tester,
      _xs(
        HeroSlider(
          defaultValue: 30,
          label: const Text('Volume'),
          onChangeEnd: ends.add,
        ),
      ),
    );
    final Rect track = tester.getRect(_track());
    await tester.tapAt(Offset(_xAt(tester, 0.8), track.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('80'), findsOneWidget);
    expect(ends, <double>[80]);

    // Pressing and dragging from the track keeps moving the thumb.
    final TestGesture gesture = await tester.startGesture(
      Offset(_xAt(tester, 0.1), track.center.dy),
    );
    await gesture.moveBy(const Offset(29.6, 0));
    await gesture.moveBy(const Offset(29.6, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('30'), findsOneWidget);
    expect(ends.last, 30);
  });

  testWidgets('a controlled slider reports changes and shows its value', (
    WidgetTester tester,
  ) async {
    double value = 25;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => _xs(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroSlider(
                value: value,
                label: const Text('Volume'),
                onChanged: (double v) => setState(() => value = v),
              ),
              Text('Current value: ${value.round()}'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Current value: 25'), findsOneWidget);
    await tester.tapAt(
      Offset(_xAt(tester, 0.6), tester.getCenter(_track()).dy),
    );
    await tester.pumpAndSettle();
    expect(value, 60);
    expect(find.text('Current value: 60'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);

    // Without a parent update the thumb stays where the value says.
    await pumpHero(
      tester,
      _xs(const HeroSlider(value: 40, label: Text('Volume'))),
    );
    await tester.tapAt(
      Offset(_xAt(tester, 0.9), tester.getCenter(_track()).dy),
    );
    await tester.pumpAndSettle();
    expect(find.text('40'), findsOneWidget);
  });

  testWidgets('range sliders keep their thumbs in order', (
    WidgetTester tester,
  ) async {
    final List<List<double>> changes = <List<double>>[];
    final List<List<double>> ends = <List<double>>[];
    await pumpHero(
      tester,
      _xs(
        HeroSlider.range(
          defaultValues: const <double>[100, 500],
          maxValue: 1000,
          step: 50,
          numberFormat: NumberFormat.simpleCurrency(
            name: 'USD',
            decimalDigits: 0,
          ),
          label: const Text('Price Range'),
          onChanged: changes.add,
          onChangeEnd: ends.add,
        ),
      ),
    );
    expect(find.text(r'$100 – $500'), findsOneWidget);
    expect(_thumb(1), findsOneWidget);
    final Rect track = tester.getRect(_track());
    final Rect fill = tester.getRect(find.byType(HeroSliderFill));
    expect(fill.left, closeTo(_xAt(tester, 0.1), 0.01));
    expect(fill.right, closeTo(_xAt(tester, 0.5), 0.01));

    // Pressing near the second thumb moves it, snapped to the step.
    await tester.tapAt(Offset(_xAt(tester, 0.72), track.center.dy));
    await tester.pumpAndSettle();
    expect(ends.last, <double>[100, 700]);

    // Dragging the first thumb past the second stops at it.
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(_thumb()),
    );
    await gesture.moveBy(const Offset(150, 0));
    await gesture.moveBy(const Offset(150, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(changes.last, <double>[700, 700]);
    expect(find.text(r'$700 – $700'), findsOneWidget);
  });

  testWidgets('keyboard moves the focused thumb', (WidgetTester tester) async {
    final List<double> ends = <double>[];
    await pumpHero(
      tester,
      _xs(
        HeroSlider(
          defaultValue: 30,
          label: const Text('Volume'),
          onChangeEnd: ends.add,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    Future<void> press(LogicalKeyboardKey key, String expected) async {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
      expect(find.text(expected), findsOneWidget, reason: '$key');
    }

    await press(LogicalKeyboardKey.arrowRight, '31');
    await press(LogicalKeyboardKey.arrowUp, '32');
    await press(LogicalKeyboardKey.arrowLeft, '31');
    await press(LogicalKeyboardKey.arrowDown, '30');
    await press(LogicalKeyboardKey.pageUp, '40');
    await press(LogicalKeyboardKey.pageDown, '30');
    await press(LogicalKeyboardKey.end, '100');
    await press(LogicalKeyboardKey.arrowRight, '100');
    await press(LogicalKeyboardKey.home, '0');
    expect(ends, <double>[31, 32, 31, 30, 40, 30, 100, 100, 0]);
  });

  testWidgets('arrow keys follow the reading direction', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xs(const HeroSlider(defaultValue: 30, label: Text('Volume'))),
      textDirection: TextDirection.rtl,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('31'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('29'), findsOneWidget);
  });

  testWidgets('right-to-left sliders start at the right', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xs(const HeroSlider(defaultValue: 25, label: Text('Volume'))),
      textDirection: TextDirection.rtl,
    );
    final Rect track = tester.getRect(_track());
    final Rect fill = tester.getRect(find.byType(HeroSliderFill));
    expect(fill.right, track.right - 12);
    expect(fill.width, closeTo(74, 0.01));
    expect(tester.getCenter(_thumb()).dx, closeTo(track.right - 12 - 74, 0.01));
    // Dragging left increases the value.
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(_thumb()),
    );
    await gesture.moveBy(const Offset(-29.6, 0));
    await gesture.moveBy(const Offset(-29.6, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('45'), findsOneWidget);
  });

  testWidgets('range keys stop at the neighbouring thumb', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xs(
        const HeroSlider.range(
          defaultValues: <double>[25, 75],
          label: Text('Range'),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('25 – 25'), findsOneWidget);
  });

  testWidgets('vertical sliders put the minimum at the bottom', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        height: 256,
        child: HeroSlider(
          defaultValue: 30,
          orientation: Axis.vertical,
          label: const Text('Volume'),
          onChanged: (_) {},
        ),
      ),
    );
    final Rect slider = tester.getRect(find.byType(HeroSlider));
    final Rect track = tester.getRect(_track());
    final Rect output = tester.getRect(find.text('30'));
    final Rect label = tester.getRect(find.text('Volume'));
    expect(slider.height, 256);
    expect(track.width, 20);
    expect(output.bottom + 8, track.top);
    expect(track.bottom + 8, label.top);
    expect(track.center.dx, closeTo(slider.center.dx, 0.5));
    final Rect thumb = tester.getRect(_thumb());
    expect(thumb.size, const Size(20, 28));
    final double length = track.height - 24;
    expect(thumb.center.dy, closeTo(track.bottom - 12 - 0.3 * length, 0.01));
    final Rect fill = tester.getRect(find.byType(HeroSliderFill));
    expect(fill.bottom, track.bottom - 12);

    // Dragging up increases the value.
    final TestGesture gesture = await tester.startGesture(thumb.center);
    await gesture.moveBy(Offset(0, -length / 10));
    await gesture.moveBy(Offset(0, -length / 10));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('50'), findsOneWidget);
  });

  testWidgets('announces each thumb as a slider', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      _xs(const HeroSlider(defaultValue: 30, label: Text('Volume'))),
    );
    expect(
      tester.getSemantics(_thumb()),
      matchesSemantics(
        isSlider: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        label: 'Volume',
        value: '30',
        increasedValue: '31',
        decreasedValue: '29',
        hasIncreaseAction: true,
        hasDecreaseAction: true,
        textDirection: TextDirection.ltr,
      ),
    );
    // The visible label and output are not announced twice.
    expect(find.bySemanticsLabel('Volume'), findsOneWidget);

    tester.semantics.increase(find.semantics.byValue('30'));
    await tester.pumpAndSettle();
    expect(find.text('31'), findsOneWidget);
    tester.semantics.decrease(find.semantics.byValue('31'));
    await tester.pumpAndSettle();
    tester.semantics.decrease(find.semantics.byValue('30'));
    await tester.pumpAndSettle();
    expect(find.text('29'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('disabled sliders ignore input and fade once', (
    WidgetTester tester,
  ) async {
    final List<double> changes = <double>[];
    await pumpHero(
      tester,
      _xs(
        HeroSlider(
          defaultValue: 30,
          isDisabled: true,
          label: const Text('Volume'),
          onChanged: changes.add,
        ),
      ),
    );
    await tester.tapAt(
      Offset(_xAt(tester, 0.8), tester.getCenter(_track()).dy),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(find.text('30'), findsOneWidget);
    final Iterable<double> dimmed = tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(HeroSlider),
            matching: find.byType(Opacity),
          ),
        )
        .map((Opacity o) => o.opacity)
        .where((double o) => o < 1);
    expect(dimmed, <double>[0.5]);
  });

  testWidgets('a disabled thumb stays put', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _xs(
        HeroSlider.range(
          defaultValues: const <double>[20, 80],
          label: const Text('Range'),
          children: <Widget>[
            const HeroLabel.text('Range'),
            const HeroSliderOutput(),
            HeroSliderTrack(
              builder: (BuildContext context, HeroSliderState state) =>
                  const <Widget>[
                    HeroSliderFill(),
                    HeroSliderThumb(index: 0, isDisabled: true),
                    HeroSliderThumb(index: 1),
                  ],
            ),
          ],
        ),
      ),
    );
    await tester.tapAt(
      Offset(_xAt(tester, 0.1), tester.getCenter(_track()).dy),
    );
    await tester.pumpAndSettle();
    expect(find.text('20 – 80'), findsOneWidget);
    await tester.tapAt(
      Offset(_xAt(tester, 0.9), tester.getCenter(_track()).dy),
    );
    await tester.pumpAndSettle();
    expect(find.text('20 – 90'), findsOneWidget);
  });

  testWidgets('keyboard focus shows the ring and dragging shrinks the knob', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xs(const HeroSlider(defaultValue: 30, label: Text('Volume'))),
    );
    HeroFocusRing ring() => tester.widget<HeroFocusRing>(
      find.descendant(of: _thumb(), matching: find.byType(HeroFocusRing)),
    );
    AnimatedScale knob() => tester.widget<AnimatedScale>(
      find.descendant(of: _thumb(), matching: find.byType(AnimatedScale)),
    );
    expect(ring().visible, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(ring().visible, isTrue);

    expect(knob().scale, 1);
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(_thumb()),
    );
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(knob().scale, 0.9);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(knob().scale, 1);
  });

  testWidgets('pressing the label focuses the first thumb', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _xs(const HeroSlider(defaultValue: 30, label: Text('Volume'))),
    );
    await tester.tap(find.text('Volume'));
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'HeroSliderThumb#0');
  });

  testWidgets('custom output and track builders', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _xs(
        HeroSlider.range(
          defaultValues: const <double>[25, 75],
          builder: (BuildContext context, HeroSliderState state) => <Widget>[
            const HeroLabel.text('Range'),
            HeroSliderOutput(
              builder: (BuildContext context, HeroSliderState state) => Text(
                <String>[
                  for (int i = 0; i < state.values.length; i++)
                    state.getThumbValueLabel(i),
                ].join(' to '),
              ),
            ),
            HeroSliderTrack(
              builder: (BuildContext context, HeroSliderState state) =>
                  <Widget>[
                    const HeroSliderFill(),
                    for (int i = 0; i < state.values.length; i++)
                      HeroSliderThumb(index: i),
                  ],
            ),
          ],
        ),
      ),
    );
    expect(find.text('25 to 75'), findsOneWidget);
    expect(find.byType(HeroSliderThumb), findsNWidgets(2));
  });

  testWidgets('integrates with Form', (WidgetTester tester) async {
    final GlobalKey<FormState> form = GlobalKey<FormState>();
    List<double>? saved;
    await pumpHero(
      tester,
      Form(
        key: form,
        child: _xs(
          HeroSlider(
            defaultValue: 30,
            label: const Text('Volume'),
            validator: (List<double>? values) =>
                values!.first < 50 ? 'Too quiet' : null,
            onSaved: (List<double>? values) => saved = values,
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), isFalse);
    await tester.tapAt(
      Offset(_xAt(tester, 0.7), tester.getCenter(_track()).dy),
    );
    await tester.pumpAndSettle();
    expect(form.currentState!.validate(), isTrue);
    form.currentState!.save();
    expect(saved, <double>[70]);

    form.currentState!.reset();
    await tester.pumpAndSettle();
    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('named thumbs submit their values with HeroForm', (
    WidgetTester tester,
  ) async {
    final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
    Map<String, Object?>? submitted;
    await pumpHero(
      tester,
      HeroForm(
        key: form,
        onSubmit: (Map<String, Object?> values) => submitted = values,
        child: _xs(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroSlider(
                defaultValue: 30,
                name: 'volume',
                label: Text('Volume'),
              ),
              HeroSlider.range(
                defaultValues: <double>[100, 500],
                maxValue: 1000,
                name: 'price',
                label: Text('Price'),
              ),
              HeroSlider.range(
                defaultValues: <double>[10, 90],
                children: <Widget>[
                  HeroLabel.text('Bounds'),
                  HeroSliderTrack(
                    children: <Widget>[
                      HeroSliderFill(),
                      HeroSliderThumb(index: 0, name: 'low'),
                      HeroSliderThumb(index: 1, name: 'high'),
                    ],
                  ),
                ],
              ),
              HeroSlider(
                defaultValue: 5,
                name: 'ignored',
                isDisabled: true,
                label: Text('Disabled'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(form.currentState!.submit(), isTrue);
    expect(submitted, <String, Object?>{
      'volume': 30.0,
      'price': <Object?>[100.0, 500.0],
      'low': 10.0,
      'high': 90.0,
    });
  });

  testWidgets('snaps to decimal steps', (WidgetTester tester) async {
    double? value;
    await pumpHero(
      tester,
      _xs(
        HeroSlider(
          defaultValue: 0.5,
          maxValue: 1,
          step: 0.1,
          label: const Text('Opacity'),
          onChanged: (double v) => value = v,
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(value, 0.6);
    expect(find.text('0.6'), findsOneWidget);
  });

  testWidgets('wraps at 2x text without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _xs(
        const HeroSlider(
          defaultValue: 30,
          label: Text('Notification volume for calls'),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(_track()).height, 20);
  });

  testWidgets('custom styles recolor the parts', (WidgetTester tester) async {
    const Color red = Color(0xFFFF0000);
    await pumpHero(
      tester,
      _xs(
        const HeroSlider(
          defaultValue: 40,
          label: Text('Brightness'),
          style: HeroSliderStyle(
            fillColor: red,
            outputStyle: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
    final ColoredBox fill = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(HeroSliderFill),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(fill.color, red);
    final RenderParagraph output = tester.renderObject<RenderParagraph>(
      find.text('40'),
    );
    expect(output.text.style!.fontSize, 12);
  });
}
