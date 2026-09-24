import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// Finds the rich text whose visible characters (ignoring the placeholder of
/// the asterisk gap) are [text].
Finder _rich(String text) => find.byWidgetPredicate(
  (Widget w) =>
      w is RichText &&
      w.text
              .toPlainText(includeSemanticsLabels: false)
              .replaceAll('\uFFFC', '') ==
          text,
);

TextStyle _styleOf(WidgetTester tester, String text) {
  final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
    _rich(text),
  );
  return paragraph.text.style!;
}

void main() {
  final HeroColors colors = HeroThemeData.light().colors;

  testWidgets('renders text-sm medium foreground', (WidgetTester tester) async {
    await pumpHero(tester, const HeroLabel.text('Name'));
    final TextStyle style = _styleOf(tester, 'Name');
    expect(style.fontSize, 14);
    expect(style.fontWeight, FontWeight.w500);
    expect(style.color, colors.foreground);
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('required shows a danger asterisk', (WidgetTester tester) async {
    await pumpHero(tester, const HeroLabel.text('Email', isRequired: true));
    final RenderParagraph paragraph = tester.renderObject<RenderParagraph>(
      _rich('Email*'),
    );
    final List<TextSpan> spans = <TextSpan>[];
    paragraph.text.visitChildren((InlineSpan span) {
      if (span is TextSpan && span.text != null) spans.add(span);
      return true;
    });
    expect(spans.last.text, '*');
    expect(spans.last.style!.color, colors.danger);
  });

  testWidgets('widget child with required asterisk', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroLabel(isRequired: true, child: Text('Child')),
    );
    expect(find.text('Child'), findsOneWidget);
    expect(_rich('*'), findsOneWidget);
    // The child inherits the label style.
    final DefaultTextStyle inherited = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.text('Child'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(inherited.style.fontWeight, FontWeight.w500);
  });

  testWidgets('disabled fades and invalid turns danger', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroLabel.text('Disabled', isDisabled: true),
          HeroLabel.text('Invalid', isInvalid: true),
        ],
      ),
    );
    final Opacity opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Disabled'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 0.5);
    expect(_styleOf(tester, 'Invalid').color, colors.danger);
  });

  testWidgets('inherits required, disabled and invalid from a field', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroFieldScope(
        isRequired: true,
        isInvalid: true,
        isDisabled: true,
        child: HeroLabel.text('Scoped'),
      ),
    );
    expect(_rich('Scoped*'), findsOneWidget);
    expect(_styleOf(tester, 'Scoped*').color, colors.danger);
    expect(find.byType(Opacity), findsOneWidget);
  });

  testWidgets('item fields hide the asterisk', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroFieldScope(
        isRequired: true,
        showRequiredIndicator: false,
        child: HeroLabel.text('Option'),
      ),
    );
    expect(_rich('Option'), findsOneWidget);
    expect(_rich('Option*'), findsNothing);
  });

  testWidgets('own values win over the field', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroFieldScope(
        isInvalid: true,
        child: HeroLabel.text('Own', isInvalid: false),
      ),
    );
    expect(_styleOf(tester, 'Own').color, colors.foreground);
  });

  testWidgets('pressing focuses the associated control', (
    WidgetTester tester,
  ) async {
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroLabel.text('Name', focusNode: node),
          HeroInput(focusNode: node),
        ],
      ),
    );
    await tester.tap(find.text('Name'));
    await tester.pump();
    expect(node.hasFocus, isTrue);
  });

  testWidgets('field focus node and onPressed', (WidgetTester tester) async {
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    int presses = 0;
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroFieldScope(
            focusNode: node,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const HeroLabel.text('Scoped'),
                HeroInput(focusNode: node),
              ],
            ),
          ),
          HeroLabel.text('Action', onPressed: () => presses++),
          HeroLabel.text(
            'Disabled',
            isDisabled: true,
            onPressed: () => presses++,
          ),
        ],
      ),
    );
    await tester.tap(find.text('Scoped'));
    await tester.pump();
    expect(node.hasFocus, isTrue);
    await tester.tap(find.text('Action'));
    await tester.tap(find.text('Disabled'));
    expect(presses, 1);
  });

  testWidgets('semantics read the text without the asterisk', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, const HeroLabel.text('Email', isRequired: true));
    expect(find.bySemanticsLabel('Email'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('RTL puts the asterisk on the left', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const HeroLabel(isRequired: true, child: Text('Label')),
      textDirection: TextDirection.rtl,
    );
    final double text = tester.getCenter(find.text('Label')).dx;
    final double star = tester.getCenter(_rich('*')).dx;
    expect(star, lessThan(text));
  });

  testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 120,
        child: HeroLabel.text('A long label that wraps', isRequired: true),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
