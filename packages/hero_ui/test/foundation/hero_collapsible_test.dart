import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../helpers/hero_test_app.dart';

Widget _collapsible(bool expanded, {FocusNode? node}) => Column(
  mainAxisSize: MainAxisSize.min,
  children: <Widget>[
    SizedBox(
      width: 200,
      child: HeroCollapsible(
        isExpanded: expanded,
        child: SizedBox(
          height: 100,
          child: Focus(focusNode: node, child: const Text('Content')),
        ),
      ),
    ),
  ],
);

void main() {
  testWidgets('animates the height over 200 ms with ease-out-quad', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _collapsible(false));
    expect(tester.getSize(find.byType(HeroCollapsible)).height, 0);
    await pumpHero(tester, _collapsible(true));
    // pumpHero settles; replay the transition step by step.
    await pumpHero(tester, _collapsible(false));
    await tester.pumpWidget(heroTestApp(_collapsible(true)));
    await tester.pump(const Duration(milliseconds: 100));
    final double half = tester.getSize(find.byType(HeroCollapsible)).height;
    expect(half, closeTo(100 * HeroMotion.easeOutQuad.transform(0.5), 0.5));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(HeroCollapsible)).height, 100);
    // Collapsing eases forward in time too: quick at first.
    await tester.pumpWidget(heroTestApp(_collapsible(false)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.getSize(find.byType(HeroCollapsible)).height,
      closeTo(100 * (1 - HeroMotion.easeOutQuad.transform(0.5)), 0.5),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(HeroCollapsible)).height, 0);
  });

  testWidgets('collapsed content leaves focus traversal and semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpHero(tester, _collapsible(false, node: node));
    node.requestFocus();
    await tester.pump();
    expect(node.hasFocus, isFalse);
    expect(find.bySemanticsLabel('Content'), findsNothing);
    await pumpHero(tester, _collapsible(true, node: node));
    expect(find.bySemanticsLabel('Content'), findsOneWidget);
    node.requestFocus();
    await tester.pump();
    expect(node.hasFocus, isTrue);
    handle.dispose();
  });

  testWidgets('reduced motion switches instantly', (WidgetTester tester) async {
    Widget reduced(bool expanded) => MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: _collapsible(expanded),
    );
    await pumpHero(tester, reduced(false));
    await tester.pumpWidget(heroTestApp(reduced(true)));
    await tester.pump();
    expect(tester.getSize(find.byType(HeroCollapsible)).height, 100);
  });
}
