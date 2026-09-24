import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  heroGoldenTest(
    'typography types',
    name: 'typography_types',
    size: const Size(420, 520),
    builder: (HeroThemeData theme) => const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        HeroText('Heading one', type: HeroTextType.h1),
        HeroText('Heading two', type: HeroTextType.h2),
        HeroText('Heading three', type: HeroTextType.h3),
        HeroText('Heading four', type: HeroTextType.h4),
        HeroText('Heading five', type: HeroTextType.h5),
        HeroText('Heading six', type: HeroTextType.h6),
        HeroText('Body text for descriptions and copy.'),
        HeroText('Small body for table cells.', type: HeroTextType.bodySm),
        HeroText(
          'Extra small captions and fine print.',
          type: HeroTextType.bodyXs,
        ),
        HeroText('pnpm add @heroui/react', type: HeroTextType.code),
      ],
    ),
  );

  heroGoldenTest(
    'typography modifiers',
    name: 'typography_modifiers',
    size: const Size(360, 300),
    builder: (HeroThemeData theme) => const SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: <Widget>[
          HeroText('Muted body copy', color: HeroTextColor.muted),
          HeroText('Normal', weight: HeroTypography.normal),
          HeroText('Medium', weight: HeroTypography.medium),
          HeroText('Semibold', weight: HeroTypography.semibold),
          HeroText('Bold', weight: HeroTypography.bold),
          HeroText('Centered', align: TextAlign.center),
          HeroText('End aligned', align: TextAlign.end),
          HeroText(
            'Truncated text that is much too long to fit on a single line',
            truncate: true,
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'typography primitives and inline code',
    name: 'typography_primitives',
    size: const Size(400, 300),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          const HeroHeading('Dashboard'),
          HeroParagraph.rich(
            TextSpan(
              children: <InlineSpan>[
                const TextSpan(text: 'Inline code like '),
                HeroCode.span('render'),
                const TextSpan(text: ' receives the same code treatment.'),
              ],
            ),
          ),
          const HeroParagraph(
            'Paragraph supports base, sm, and xs sizes.',
            size: HeroParagraphSize.sm,
            color: HeroTextColor.muted,
          ),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: HeroCode('Typography.Code'),
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'typography prose',
    name: 'typography_prose',
    size: const Size(420, 520),
    builder: (HeroThemeData theme) => SizedBox(
      width: 380,
      child: Builder(
        builder: (BuildContext context) {
          final HeroProseStyles styles = HeroProse.stylesOf(context);
          return HeroProse(
            children: <Widget>[
              const HeroHeading('Prose title', level: 3),
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    const TextSpan(text: 'Authored content with '),
                    TextSpan(text: 'strong', style: styles.strong),
                    const TextSpan(text: ', '),
                    TextSpan(text: 'emphasis', style: styles.em),
                    const TextSpan(text: ', a '),
                    TextSpan(text: 'link', style: styles.link),
                    const TextSpan(text: ' and '),
                    HeroCode.span('code'),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const HeroProseBlockquote(child: Text('A quoted remark.')),
              const HeroProseList(
                children: <Widget>[Text('First item'), Text('Second item')],
              ),
              const HeroProseList(
                ordered: true,
                children: <Widget>[Text('Step one'), Text('Step two')],
              ),
              const HeroProsePre('final HeroText text = HeroText("Hello");'),
            ],
          );
        },
      ),
    ),
  );
}
