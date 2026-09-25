import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroColors colors = HeroThemeData.light().colors;

  testWidgets('renders text-xs muted', (WidgetTester tester) async {
    await pumpHero(tester, const HeroDescription.text('Helpful text'));
    final TextStyle style = tester
        .renderObject<RenderParagraph>(find.text('Helpful text'))
        .text
        .style!;
    expect(style.fontSize, 12);
    expect(style.height! * style.fontSize!, closeTo(16, 0.001));
    expect(style.color, colors.muted);
  });

  testWidgets('widget child inherits the style and style overrides merge', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroDescription(
        style: TextStyle(letterSpacing: 0.3),
        child: Text('Child'),
      ),
    );
    final TextStyle style = tester
        .renderObject<RenderParagraph>(find.text('Child'))
        .text
        .style!;
    expect(style.fontSize, 12);
    expect(style.color, colors.muted);
    expect(style.letterSpacing, 0.3);
  });

  testWidgets('wraps long text', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 120,
        child: HeroDescription.text(
          "We'll never share your email with anyone else.",
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(HeroDescription)).height,
      greaterThan(16),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('hidden while an invalid field hides descriptions', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroFieldScope(
        isInvalid: true,
        hideDescriptionWhenInvalid: true,
        child: HeroDescription.text('Hidden'),
      ),
    );
    expect(find.text('Hidden'), findsNothing);
  });

  testWidgets('shown while valid or when the field keeps descriptions', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroFieldScope(
            hideDescriptionWhenInvalid: true,
            child: HeroDescription.text('Valid'),
          ),
          HeroFieldScope(isInvalid: true, child: HeroDescription.text('Kept')),
        ],
      ),
    );
    expect(find.text('Valid'), findsOneWidget);
    expect(find.text('Kept'), findsOneWidget);
  });

  testWidgets('semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroDescription.text('Standalone'),
          HeroFieldScope(
            semanticHint: 'Described by the field',
            child: HeroDescription.text('Inside a field'),
          ),
        ],
      ),
    );
    expect(find.bySemanticsLabel('Standalone'), findsOneWidget);
    expect(find.bySemanticsLabel('Inside a field'), findsNothing);
    handle.dispose();
  });

  testWidgets('RTL aligns to the right', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(width: 300, child: HeroDescription.text('Right')),
      textDirection: TextDirection.rtl,
    );
    expect(
      tester.getTopRight(find.text('Right')).dx,
      tester.getTopRight(find.byType(HeroDescription)).dx,
    );
  });

  testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 100,
        child: HeroDescription.text('Scaled supplementary text'),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
