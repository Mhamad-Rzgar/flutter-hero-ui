import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData theme = HeroThemeData.light();

  TextStyle styleOf(WidgetTester tester, String text) {
    final RichText rich = tester.widget<RichText>(
      find.descendant(of: find.text(text), matching: find.byType(RichText)),
    );
    return rich.text.style!;
  }

  testWidgets('every type uses its typography token', (
    WidgetTester tester,
  ) async {
    final Map<HeroTextType, (double, double, FontWeight)> expected =
        <HeroTextType, (double, double, FontWeight)>{
          HeroTextType.h1: (36, 40, FontWeight.w600),
          HeroTextType.h2: (30, 36, FontWeight.w600),
          HeroTextType.h3: (24, 32, FontWeight.w600),
          HeroTextType.h4: (20, 28, FontWeight.w600),
          HeroTextType.h5: (18, 28, FontWeight.w600),
          HeroTextType.h6: (16, 24, FontWeight.w600),
          HeroTextType.body: (16, 28, FontWeight.w400),
          HeroTextType.bodySm: (14, 24, FontWeight.w400),
          HeroTextType.bodyXs: (12, 20, FontWeight.w400),
          HeroTextType.code: (14, 20, FontWeight.w400),
        };
    for (final MapEntry<HeroTextType, (double, double, FontWeight)> e
        in expected.entries) {
      await pumpHero(tester, HeroText('Sample', type: e.key), theme: theme);
      final TextStyle style = styleOf(tester, 'Sample');
      expect(style.fontSize, e.value.$1, reason: '${e.key}');
      expect(style.fontSize! * style.height!, closeTo(e.value.$2, 0.01));
      expect(style.fontWeight, e.value.$3, reason: '${e.key}');
      expect(style.color, theme.colors.foreground);
      if (e.key.headingLevel != null) {
        expect(style.letterSpacing, closeTo(-0.025 * e.value.$1, 0.001));
      }
    }
  });

  testWidgets('code type is monospace on a default fill with padding', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroText('pnpm add', type: HeroTextType.code),
      theme: theme,
    );
    expect(styleOf(tester, 'pnpm add').fontFamily, contains('JetBrainsMono'));
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text('pnpm add'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (box.decoration as ShapeDecoration).color,
      theme.colors.defaultColor,
    );
    final Size text = tester.getSize(find.text('pnpm add'));
    final Size outer = tester.getSize(find.byType(HeroText));
    expect(outer.width, text.width + 12);
    expect(outer.height, text.height + 4);
  });

  testWidgets('color, weight, align and style overrides', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroText(
        'Muted',
        color: HeroTextColor.muted,
        weight: HeroTypography.bold,
        align: TextAlign.center,
        style: TextStyle(letterSpacing: 2, color: theme.colors.accent),
      ),
      theme: theme,
    );
    final TextStyle style = styleOf(tester, 'Muted');
    expect(style.fontWeight, FontWeight.w700);
    expect(style.letterSpacing, 2);
    expect(style.color, theme.colors.accent);
    expect(tester.widget<Text>(find.text('Muted')).textAlign, TextAlign.center);

    await pumpHero(
      tester,
      const HeroText('Muted', color: HeroTextColor.muted),
      theme: theme,
    );
    expect(styleOf(tester, 'Muted').color, theme.colors.muted);
  });

  testWidgets('truncate keeps a single line with an ellipsis', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 120,
        child: HeroText(
          'A very long line of text that cannot fit in the box',
          truncate: true,
        ),
      ),
      theme: theme,
    );
    final Text text = tester.widget<Text>(find.byType(Text));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.getSize(find.byType(HeroText)).height, 28);
  });

  testWidgets('headings expose heading semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroText('Title', type: HeroTextType.h2),
          HeroText(
            'Styled h1, semantic h3',
            type: HeroTextType.h1,
            semanticHeadingLevel: 3,
          ),
          HeroText(
            'Not a heading',
            type: HeroTextType.h4,
            semanticHeadingLevel: 0,
          ),
          HeroText('Body'),
        ],
      ),
    );
    final SemanticsData title = tester
        .getSemantics(find.text('Title'))
        .getSemanticsData();
    expect(title.flagsCollection.isHeader, isTrue);
    expect(title.headingLevel, 2);
    final SemanticsData decoupled = tester
        .getSemantics(find.text('Styled h1, semantic h3'))
        .getSemanticsData();
    expect(decoupled.headingLevel, 3);
    expect(
      tester
          .getSemantics(find.text('Not a heading'))
          .getSemanticsData()
          .flagsCollection
          .isHeader,
      isFalse,
    );
    expect(
      tester
          .getSemantics(find.text('Body'))
          .getSemanticsData()
          .flagsCollection
          .isHeader,
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('primitives map to types', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroHeading('Dashboard', level: 3),
          HeroParagraph(
            'Small',
            size: HeroParagraphSize.sm,
            color: HeroTextColor.muted,
          ),
          HeroParagraph('Tiny', size: HeroParagraphSize.xs),
          HeroCode('Typography.Code'),
        ],
      ),
      theme: theme,
    );
    expect(styleOf(tester, 'Dashboard').fontSize, 24);
    expect(styleOf(tester, 'Small').fontSize, 14);
    expect(styleOf(tester, 'Small').color, theme.colors.muted);
    expect(styleOf(tester, 'Tiny').fontSize, 12);
    expect(
      tester
          .widget<HeroText>(
            find.ancestor(
              of: find.text('Typography.Code'),
              matching: find.byType(HeroText),
            ),
          )
          .type,
      HeroTextType.code,
    );
    expect(HeroTextType.heading(5), HeroTextType.h5);
  });

  testWidgets('rich text with inline code spans', (WidgetTester tester) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 320,
        child: HeroParagraph.rich(
          TextSpan(
            children: <InlineSpan>[
              const TextSpan(text: 'Inline code like '),
              HeroCode.span('render'),
              const TextSpan(text: ' gets the code look.'),
            ],
          ),
        ),
      ),
      theme: theme,
    );
    expect(find.byType(HeroCode), findsOneWidget);
    expect(find.textContaining('Inline code like'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prose lays out elements with body defaults', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 360,
        child: Builder(
          builder: (BuildContext context) {
            final HeroProseStyles styles = HeroProse.stylesOf(context);
            return HeroProse(
              spacing: 12,
              children: <Widget>[
                const HeroHeading('Prose title'),
                const Text('Plain prose text'),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: 'Bold', style: styles.strong),
                      TextSpan(text: 'Italic', style: styles.em),
                      TextSpan(text: 'Link', style: styles.link),
                    ],
                  ),
                ),
                const HeroProseBlockquote(child: Text('Quoted')),
                const HeroProseList(
                  children: <Widget>[Text('One'), Text('Two')],
                ),
                const HeroProseList(
                  ordered: true,
                  children: <Widget>[Text('First')],
                ),
                const HeroProseDivider(),
                const HeroProsePre('final int x = 1;'),
                HeroProseImage(
                  child: Container(height: 40, color: theme.colors.accent),
                ),
              ],
            );
          },
        ),
      ),
      theme: theme,
      surfaceSize: const Size(800, 1200),
    );
    expect(tester.takeException(), isNull);
    final DefaultTextStyle plain = DefaultTextStyle.of(
      tester.element(find.text('Plain prose text')),
    );
    expect(plain.style.fontSize, 16);
    expect(plain.style.color, theme.colors.foreground);
    final DefaultTextStyle quoted = DefaultTextStyle.of(
      tester.element(find.text('Quoted')),
    );
    expect(quoted.style.color, theme.colors.muted);
    expect(quoted.style.fontStyle, FontStyle.italic);
    expect(find.text('\u2022'), findsNWidgets(2));
    expect(find.text('1.'), findsOneWidget);
    expect(find.byType(HeroSeparator), findsOneWidget);
    final HeroProseStyles styles = HeroProseStyles.of(theme);
    expect(styles.link.color, theme.colors.link);
    expect(styles.link.decoration, TextDecoration.underline);
    expect(styles.strong.fontWeight, FontWeight.w600);
  });

  testWidgets('blockquote border follows the text direction', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 200,
        child: HeroProseBlockquote(child: Text('Quoted')),
      ),
      textDirection: TextDirection.rtl,
    );
    final Rect quote = tester.getRect(find.byType(HeroProseBlockquote));
    final Rect text = tester.getRect(find.text('Quoted'));
    expect(quote.right - text.right, 20);
  });

  testWidgets('RTL start alignment and 2x text scale do not overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroText('Heading', type: HeroTextType.h1),
            HeroText('Body copy that wraps onto several lines at large scale.'),
            HeroText('pnpm add @heroui/react', type: HeroTextType.code),
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    final Rect column = tester.getRect(find.byType(Column));
    final Rect heading = tester.getRect(find.text('Heading'));
    expect(heading.right, column.right);
  });
}
