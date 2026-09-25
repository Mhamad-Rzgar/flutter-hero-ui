import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroColors colors = HeroThemeData.light().colors;

  TextStyle styleOf(WidgetTester tester, String text) =>
      tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

  testWidgets('shows "No results found" by default', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const HeroEmptyState());
    expect(find.text('No results found'), findsOneWidget);
    expect(HeroEmptyState.defaultText, 'No results found');
  });

  testWidgets('renders text-sm muted with 8 px padding', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const HeroEmptyState.text('Nothing here'));
    final TextStyle style = styleOf(tester, 'Nothing here');
    expect(style.fontSize, 14);
    expect(style.height! * style.fontSize!, closeTo(20, 0.001));
    expect(style.color, colors.muted);
    final Rect box = tester.getRect(find.byType(HeroEmptyState));
    final Rect text = tester.getRect(find.text('Nothing here'));
    expect(text.left - box.left, 8);
    expect(text.top - box.top, 8);
    expect(box.bottom - text.bottom, 8);
    expect(box.height, 36);
  });

  testWidgets('a widget child inherits the style; style and padding merge', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroEmptyState(
        style: TextStyle(fontWeight: FontWeight.w500),
        padding: EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[HeroIcon(HeroIcons.magnifier), Text('No match')],
        ),
      ),
    );
    final TextStyle style = styleOf(tester, 'No match');
    expect(style.fontSize, 14);
    expect(style.color, colors.muted);
    expect(style.fontWeight, FontWeight.w500);
    final BuildContext icon = tester.element(find.byType(HeroIcon));
    expect(IconTheme.of(icon).color, colors.muted);
    expect(
      tester.getTopLeft(find.byType(Row)) -
          tester.getTopLeft(find.byType(HeroEmptyState)),
      const Offset(2, 2),
    );
  });

  testWidgets('is announced as a live region', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, const HeroEmptyState());
    expect(
      tester.getSemantics(find.byType(HeroEmptyState)),
      matchesSemantics(label: 'No results found', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('RTL aligns the text to the right', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(width: 300, child: HeroEmptyState()),
      textDirection: TextDirection.rtl,
    );
    expect(
      tester.getTopRight(find.byType(HeroEmptyState)).dx -
          tester.getTopRight(find.text('No results found')).dx,
      8,
    );
  });

  testWidgets('wraps at text scale 2.0 without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(width: 120, child: HeroEmptyState()),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(HeroEmptyState)).height, greaterThan(56));
  });
}
