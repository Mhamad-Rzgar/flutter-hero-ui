import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _w64(Widget child) => SizedBox(width: 256, child: child);

Finder _fill() => find.descendant(
  of: find.byType(HeroMeterFill),
  matching: find.byType(DecoratedBox),
);

void main() {
  testWidgets('builds the standard layout from a label', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _w64(const HeroMeter(value: 60, label: Text('Storage'))),
    );
    expect(find.text('Storage'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.byType(HeroLabel), findsOneWidget);
    expect(tester.getSize(find.byType(HeroMeter)).width, 256);

    // Label at the start, output at the end, track below both.
    final Rect label = tester.getRect(find.text('Storage'));
    final Rect output = tester.getRect(find.text('60%'));
    final Rect track = tester.getRect(find.byType(HeroMeterTrack));
    final Rect meter = tester.getRect(find.byType(HeroMeter));
    expect(label.left, meter.left);
    expect(output.right, meter.right);
    expect(track.top, label.bottom + 4);
    expect(track.width, 256);
    expect(track.height, 8);
    expect(tester.getSize(_fill()).width, closeTo(153.6, 0.01));
  });

  testWidgets('composes its parts in the grid areas', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _w64(
        const HeroMeter(
          value: 25,
          children: <Widget>[
            HeroMeterTrack(child: HeroMeterFill()),
            HeroMeterOutput(),
            HeroLabel.text('Storage'),
          ],
        ),
      ),
    );
    final Rect label = tester.getRect(find.text('Storage'));
    final Rect output = tester.getRect(find.text('25%'));
    final Rect track = tester.getRect(find.byType(HeroMeterTrack));
    expect(label.top, output.top);
    expect(track.top, greaterThan(label.bottom));
    expect(tester.getSize(_fill()).width, 64);
  });

  testWidgets('without a label it is only a track', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _w64(const HeroMeter(value: 45, semanticLabel: 'Storage usage')),
    );
    expect(find.byType(HeroMeterOutput), findsNothing);
    expect(find.byType(HeroLabel), findsNothing);
    expect(tester.getSize(find.byType(HeroMeter)), const Size(256, 8));
  });

  testWidgets('track heights and radii follow the size', (
    WidgetTester tester,
  ) async {
    const Map<HeroSize, double> heights = <HeroSize, double>{
      HeroSize.sm: 4,
      HeroSize.md: 8,
      HeroSize.lg: 12,
    };
    for (final MapEntry<HeroSize, double> entry in heights.entries) {
      await pumpHero(tester, _w64(HeroMeter(size: entry.key, value: 40)));
      expect(tester.getSize(find.byType(HeroMeterTrack)).height, entry.value);
    }
    final HeroThemeData theme = HeroThemeData.light();
    expect(HeroMeter.radiusOf(theme, HeroSize.sm), 2);
    expect(HeroMeter.radiusOf(theme, HeroSize.md), 4);
    expect(HeroMeter.radiusOf(theme, HeroSize.lg), 6);
  });

  test('fill colors follow the CSS color variants', () {
    final HeroColors colors = HeroThemeData.dark().colors;
    expect(
      HeroMeter.fillColorOf(colors, HeroColor.standard),
      colors.defaultForeground,
    );
    expect(HeroMeter.fillColorOf(colors, HeroColor.accent), colors.accent);
    expect(HeroMeter.fillColorOf(colors, HeroColor.success), colors.success);
    expect(HeroMeter.fillColorOf(colors, HeroColor.warning), colors.warning);
    expect(HeroMeter.fillColorOf(colors, HeroColor.danger), colors.danger);
  });

  testWidgets('formats the value with a number format', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _w64(
        HeroMeter(
          value: 750,
          maxValue: 1000,
          numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
          label: const Text('Revenue'),
        ),
      ),
    );
    expect(find.text(r'$750.00'), findsOneWidget);
    expect(tester.getSize(_fill()).width, 192);

    await pumpHero(
      tester,
      _w64(
        const HeroMeter(
          value: 3,
          maxValue: 4,
          valueLabel: '3 of 4',
          label: Text('Steps'),
        ),
      ),
    );
    expect(find.text('3 of 4'), findsOneWidget);
  });

  testWidgets('builder receives the state', (WidgetTester tester) async {
    HeroMeterState? state;
    await pumpHero(
      tester,
      _w64(
        HeroMeter(
          value: 150,
          minValue: 100,
          maxValue: 200,
          builder: (BuildContext context, HeroMeterState s) {
            state = s;
            return <Widget>[
              HeroMeterOutput(child: Text('${s.percentage.round()} percent')),
              const HeroMeterTrack(),
            ];
          },
        ),
      ),
    );
    expect(state, const HeroMeterState(percentage: 50, valueText: '50%'));
    expect(find.text('50 percent'), findsOneWidget);
  });

  testWidgets('animates the fill width over 300 ms', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _w64(const HeroMeter(value: 20)));
    expect(tester.getSize(_fill()).width, closeTo(51.2, 0.01));
    await tester.pumpWidget(heroTestApp(_w64(const HeroMeter(value: 80))));
    await tester.pump(const Duration(milliseconds: 150));
    final double middle = tester.getSize(_fill()).width;
    expect(middle, greaterThan(51.2));
    expect(middle, lessThan(204.8));
    await tester.pumpAndSettle();
    expect(tester.getSize(_fill()).width, closeTo(204.8, 0.01));
  });

  testWidgets('the fill grows from the right in right-to-left layouts', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _w64(const HeroMeter(value: 25, label: Text('Storage'))),
      textDirection: TextDirection.rtl,
    );
    final Rect track = tester.getRect(find.byType(HeroMeterTrack));
    final Rect fill = tester.getRect(_fill());
    expect(fill.right, track.right);
    expect(fill.width, 64);
    // The label sits at the right, the output at the left.
    expect(
      tester.getRect(find.text('Storage')).right,
      tester.getRect(find.byType(HeroMeter)).right,
    );
    expect(
      tester.getRect(find.text('25%')).left,
      tester.getRect(find.byType(HeroMeter)).left,
    );
  });

  testWidgets('announces a meter with its label and value', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      _w64(const HeroMeter(value: 60, label: Text('Storage'))),
    );
    expect(
      tester.getSemantics(find.byType(HeroMeter)),
      matchesSemantics(
        label: 'Storage',
        value: '60%',
        role: SemanticsRole.progressBar,
        minValue: '0',
        maxValue: '100',
      ),
    );

    await pumpHero(
      tester,
      _w64(
        const HeroMeter(
          value: 60,
          semanticLabel: 'Disk',
          label: Text('Storage'),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(HeroMeter)),
      matchesSemantics(
        label: 'Disk',
        value: '60%',
        role: SemanticsRole.progressBar,
        minValue: '0',
        maxValue: '100',
      ),
    );
    handle.dispose();
  });

  testWidgets('disabled meters fade as a whole', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _w64(
        const HeroMeter(value: 40, isDisabled: true, label: Text('Storage')),
      ),
    );
    final Iterable<Opacity> opacities = tester.widgetList<Opacity>(
      find.descendant(
        of: find.byType(HeroMeter),
        matching: find.byType(Opacity),
      ),
    );
    // One 50% layer for the root; the label is not dimmed a second time.
    expect(
      opacities.map((Opacity o) => o.opacity).where((double o) => o < 1),
      <double>[0.5],
    );
  });

  testWidgets('is 256 wide where the width is unbounded', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[HeroMeter(value: 30)],
      ),
    );
    expect(tester.getSize(find.byType(HeroMeter)).width, 256);
  });

  testWidgets('custom track and fill styles', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _w64(
        const HeroMeter(
          value: 68,
          children: <Widget>[
            HeroLabel.text('Storage used'),
            HeroMeterOutput(style: TextStyle(color: Color(0xFF777777))),
            HeroMeterTrack(
              borderRadius: BorderRadius.all(Radius.circular(9999)),
              child: HeroMeterFill(
                color: Color(0xFFFF9900),
                borderRadius: BorderRadius.all(Radius.circular(9999)),
              ),
            ),
          ],
        ),
      ),
    );
    final Text output = tester.widget<Text>(find.text('68%'));
    expect(output.data, '68%');
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      find.text('68%'),
    );
    expect(paragraph.text.style?.color, const Color(0xFF777777));
    expect(tester.takeException(), isNull);
  });

  testWidgets('wraps the label at 2x text without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _w64(
        const HeroMeter(
          value: 60,
          size: HeroSize.lg,
          label: Text('Storage used by photos and videos'),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.text('Storage used by photos and videos')).height,
      greaterThan(40),
    );
  });
}
