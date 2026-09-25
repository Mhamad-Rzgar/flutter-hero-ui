import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroColors colors = HeroThemeData.light().colors;

  TextStyle styleOf(WidgetTester tester, String text) =>
      tester.renderObject<RenderParagraph>(find.text(text)).text.style!;

  testWidgets('renders text-xs danger without padding', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, const HeroErrorMessage.text('Something failed'));
    final TextStyle style = styleOf(tester, 'Something failed');
    expect(style.fontSize, 12);
    expect(style.height! * style.fontSize!, closeTo(16, 0.001));
    expect(style.color, colors.danger);
    expect(
      tester.getRect(find.byType(HeroErrorMessage)),
      tester.getRect(find.text('Something failed')),
    );
  });

  testWidgets('a widget child inherits the style; style merges', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroErrorMessage(
        style: TextStyle(fontWeight: FontWeight.w500),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[HeroIcon(HeroIcons.danger), Text('Broken')],
        ),
      ),
    );
    final TextStyle style = styleOf(tester, 'Broken');
    expect(style.color, colors.danger);
    expect(style.fontWeight, FontWeight.w500);
    expect(
      IconTheme.of(tester.element(find.byType(HeroIcon))).color,
      colors.danger,
    );
  });

  testWidgets('renders nothing without content', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[HeroErrorMessage(), HeroErrorMessage.text('')],
      ),
    );
    for (final Element element in find.byType(HeroErrorMessage).evaluate()) {
      expect((element.renderObject! as RenderBox).size, Size.zero);
    }
  });

  testWidgets('is announced as a live region', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, const HeroErrorMessage.text('Required'));
    expect(
      tester.getSemantics(find.text('Required')),
      isSemantics(label: 'Required', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('inside a tag group it gets 4 px padding', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroTagGroup(
        spacing: 6,
        errorMessage: 'Please select at least one category',
        children: <Widget>[
          HeroTagGroupList(
            children: <Widget>[HeroTag(id: 'a', label: 'A')],
          ),
          HeroErrorMessage.text('Second error'),
          HeroErrorMessage(),
        ],
      ),
    );
    final Rect tag = tester.getRect(find.byType(HeroTagGroupList));
    final Rect second = tester.getRect(find.text('Second error'));
    // 6 px group gap plus 4 px padding.
    expect(second.top - tag.bottom, 10);
    expect(second.left - tag.left, 4);
    expect(find.text('Please select at least one category'), findsOneWidget);
  });

  testWidgets('RTL aligns to the right', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(width: 300, child: HeroErrorMessage.text('Right')),
      textDirection: TextDirection.rtl,
    );
    expect(
      tester.getTopRight(find.text('Right')).dx,
      tester.getTopRight(find.byType(HeroErrorMessage)).dx,
    );
  });

  testWidgets('wraps at text scale 2.0 without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 100,
        child: HeroErrorMessage.text(
          'Averyveryverylongwordthatdoesnotfitonasingleline at all',
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
