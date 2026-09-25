import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

List<Widget> _items({int count = 3}) => <Widget>[
  for (int i = 0; i < count; i++)
    HeroAccordionItem(title: Text('Title $i'), child: Text('Body $i')),
];

bool _visible(WidgetTester tester, String text) =>
    tester.getSize(find.text(text, skipOffstage: false)).height > 0 &&
    find.text(text).evaluate().isNotEmpty;

void main() {
  final HeroColors colors = HeroThemeData.light().colors;

  testWidgets('renders triggers with HeroUI geometry and text', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(width: 400, child: HeroAccordion(children: _items())),
    );
    final Rect trigger = tester.getRect(
      find.byType(HeroAccordionTrigger).first,
    );
    expect(trigger.width, 400);
    // 16 px padding around a 20 px line.
    expect(trigger.height, 52);
    expect(tester.getTopLeft(find.text('Title 0')).dx - trigger.left, 16);
    final TextStyle style = tester
        .renderObject<RenderParagraph>(find.text('Title 0'))
        .text
        .style!;
    expect(style.fontSize, 14);
    expect(style.fontWeight, FontWeight.w500);
    expect(style.color, colors.foreground);
    final Rect indicator = tester.getRect(
      find.byType(HeroAccordionIndicator).first,
    );
    expect(indicator.size, const Size(16, 16));
    expect(trigger.right - indicator.right, 16);
    expect(
      IconTheme.of(tester.element(find.byType(HeroIcon).first)).color,
      colors.muted,
    );
  });

  testWidgets('single expansion toggles and collapses the others', (
    WidgetTester tester,
  ) async {
    final List<Set<Object>> changes = <Set<Object>>[];
    await pumpHero(
      tester,
      SizedBox(
        width: 400,
        child: HeroAccordion(
          onExpandedChanged: changes.add,
          children: _items(),
        ),
      ),
    );
    expect(find.text('Body 0'), findsNothing);
    await tester.tap(find.text('Title 0'));
    await tester.pumpAndSettle();
    expect(_visible(tester, 'Body 0'), isTrue);
    await tester.tap(find.text('Title 1'));
    await tester.pumpAndSettle();
    expect(find.text('Body 0'), findsNothing);
    expect(_visible(tester, 'Body 1'), isTrue);
    await tester.tap(find.text('Title 1'));
    await tester.pumpAndSettle();
    expect(find.text('Body 1'), findsNothing);
    expect(changes, <Set<Object>>[
      <Object>{0},
      <Object>{1},
      <Object>{},
    ]);
  });

  testWidgets('allowsMultipleExpanded keeps several items open', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 400,
        child: HeroAccordion(allowsMultipleExpanded: true, children: _items()),
      ),
    );
    await tester.tap(find.text('Title 0'));
    await tester.tap(find.text('Title 2'));
    await tester.pumpAndSettle();
    expect(_visible(tester, 'Body 0'), isTrue);
    expect(_visible(tester, 'Body 2'), isTrue);
  });

  testWidgets('controlled expandedKeys with ids', (WidgetTester tester) async {
    Set<Object> expanded = <Object>{'b'};
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Expanded: ${expanded.join(', ')}'),
            SizedBox(
              width: 400,
              child: HeroAccordion(
                expandedKeys: expanded,
                onExpandedChanged: (Set<Object> keys) =>
                    setState(() => expanded = keys),
                children: const <Widget>[
                  HeroAccordionItem(
                    id: 'a',
                    title: Text('A'),
                    child: Text('Body A'),
                  ),
                  HeroAccordionItem(
                    id: 'b',
                    title: Text('B'),
                    child: Text('Body B'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    expect(_visible(tester, 'Body B'), isTrue);
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(find.text('Expanded: a'), findsOneWidget);
    expect(find.text('Body B'), findsNothing);
  });

  testWidgets('defaultExpanded items and item callbacks', (
    WidgetTester tester,
  ) async {
    final List<bool> changes = <bool>[];
    await pumpHero(
      tester,
      SizedBox(
        width: 400,
        child: HeroAccordion(
          children: <Widget>[
            HeroAccordionItem(
              defaultExpanded: true,
              onExpandedChanged: changes.add,
              title: const Text('Open'),
              child: const Text('Open body'),
            ),
          ],
        ),
      ),
    );
    expect(_visible(tester, 'Open body'), isTrue);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(changes, <bool>[false]);
    expect(find.text('Open body'), findsNothing);
  });

  testWidgets('disabled group and items do not toggle', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 400,
            child: HeroAccordion(isDisabled: true, children: _items(count: 1)),
          ),
          const SizedBox(
            width: 400,
            child: HeroAccordion(
              children: <Widget>[
                HeroAccordionItem(
                  isDisabled: true,
                  title: Text('Locked'),
                  child: Text('Locked body'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    await tester.tap(find.text('Title 0'));
    await tester.tap(find.text('Locked'));
    await tester.pumpAndSettle();
    expect(find.text('Body 0'), findsNothing);
    expect(find.text('Locked body'), findsNothing);
    final AnimatedOpacity opacity = tester.widget<AnimatedOpacity>(
      find
          .ancestor(
            of: find.text('Locked'),
            matching: find.byType(AnimatedOpacity),
          )
          .first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('panel animates height and opacity over 200 ms', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(width: 400, child: HeroAccordion(children: _items(count: 1))),
    );
    final double collapsed = tester.getSize(find.byType(HeroAccordion)).height;
    await tester.tap(find.text('Title 0'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final double midway = tester.getSize(find.byType(HeroAccordion)).height;
    final Opacity fade = tester.widget<Opacity>(
      find
          .ancestor(of: find.text('Body 0'), matching: find.byType(Opacity))
          .first,
    );
    expect(fade.opacity, greaterThan(0));
    expect(fade.opacity, lessThan(1));
    await tester.pump(const Duration(milliseconds: 120));
    final double expanded = tester.getSize(find.byType(HeroAccordion)).height;
    expect(midway, greaterThan(collapsed));
    expect(midway, lessThan(expanded));
    // 20 px of text plus 16 px of bottom padding.
    expect(expanded - collapsed, 36);
    final AnimatedRotation rotation = tester.widget<AnimatedRotation>(
      find.byType(AnimatedRotation),
    );
    expect(rotation.turns, -0.5);
    expect(rotation.duration, const Duration(milliseconds: 250));
  });

  testWidgets('reduced motion expands instantly', (WidgetTester tester) async {
    await pumpHero(
      tester,
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: SizedBox(
          width: 400,
          child: HeroAccordion(children: _items(count: 1)),
        ),
      ),
    );
    await tester.tap(find.text('Title 0'));
    await tester.pump();
    await tester.pump();
    expect(_visible(tester, 'Body 0'), isTrue);
    expect(
      tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.text('Body 0'),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity,
      1,
    );
  });

  testWidgets('separators: full width, none on the last item or hidden', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 400, child: HeroAccordion(children: _items())),
          SizedBox(
            width: 400,
            child: HeroAccordion(hideSeparator: true, children: _items()),
          ),
        ],
      ),
    );
    final Iterable<DecoratedBox> lines = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where(
          (DecoratedBox box) =>
              box.decoration is ShapeDecoration &&
              (box.decoration as ShapeDecoration).color == colors.separator,
        );
    expect(lines, hasLength(2));
  });

  testWidgets('surface variant: card, rounded outer triggers, inset lines', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 400,
        child: HeroAccordion(
          variant: HeroAccordionVariant.surface,
          children: _items(),
        ),
      ),
    );
    final HeroSurface surface = tester.widget<HeroSurface>(
      find.byType(HeroSurface),
    );
    expect(surface.borderRadius, BorderRadius.circular(24));
    final Rect line = tester.getRect(
      find
          .descendant(
            of: find.byWidgetPredicate(
              (Widget w) => w is FractionallySizedBox && w.widthFactor == 0.94,
            ),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(line.width, closeTo(400 * 0.94, 0.01));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(find.text('Title 0')));
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    final ShapeDecoration hovered =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(HeroAccordionTrigger).first,
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as ShapeDecoration;
    expect(hovered.color, colors.defaultColor);
    final RoundedSuperellipseBorder shape =
        hovered.shape as RoundedSuperellipseBorder;
    expect(
      shape.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(24)),
    );
  });

  testWidgets('hover tints collapsed triggers only', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 400,
        child: HeroAccordion(
          defaultExpandedKeys: const <Object>{0},
          children: _items(count: 2),
        ),
      ),
    );
    Color? fill(int index) =>
        (tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(HeroAccordionTrigger).at(index),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as ShapeDecoration)
            .color;
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: tester.getCenter(find.text('Title 0')));
    addTearDown(mouse.removePointer);
    await tester.pumpAndSettle();
    expect(fill(0), isNull);
    await mouse.moveTo(tester.getCenter(find.text('Title 1')));
    await tester.pumpAndSettle();
    expect(
      fill(1),
      colors.foreground.withValues(alpha: colors.foreground.a * 0.03),
    );
  });

  testWidgets('keyboard: Tab between triggers, Enter and Space toggle', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(width: 400, child: HeroAccordion(children: _items(count: 2))),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      tester.widget<HeroFocusRing>(find.byType(HeroFocusRing).first).visible,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_visible(tester, 'Body 0'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    // The collapsed panel is skipped: focus moves to the next trigger.
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(_visible(tester, 'Body 1'), isTrue);
    expect(find.text('Body 0'), findsNothing);
  });

  testWidgets('compound parts and trigger builder', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      SizedBox(
        width: 400,
        child: HeroAccordion(
          children: <Widget>[
            HeroAccordionItem(
              children: <Widget>[
                HeroAccordionHeading(
                  child: HeroAccordionTrigger(
                    onPressed: () => presses++,
                    indicator: const HeroAccordionIndicator(
                      child: HeroIcon(HeroIcons.plus),
                    ),
                    builder:
                        (
                          BuildContext context,
                          HeroAccordionTriggerState state,
                        ) => Text(state.isExpanded ? 'Open' : 'Closed'),
                  ),
                ),
                const HeroAccordionPanel(
                  child: HeroAccordionBody(child: Text('Compound body')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    expect(find.text('Closed'), findsOneWidget);
    await tester.tap(find.text('Closed'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(presses, 1);
    final Rect body = tester.getRect(find.text('Compound body'));
    final Rect item = tester.getRect(find.byType(HeroAccordionItem));
    expect(body.left - item.left, 16);
    expect(item.bottom - body.bottom, 16);
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('Compound body'))
          .text
          .style!
          .color,
      colors.muted,
    );
  });

  testWidgets('semantics: heading, expanded button, hidden panel', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      SizedBox(width: 400, child: HeroAccordion(children: _items(count: 1))),
    );
    expect(
      tester.getSemantics(find.text('Title 0')),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
    );
    expect(find.bySemanticsLabel('Body 0'), findsNothing);
    await tester.tap(find.text('Title 0'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Title 0')),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: true),
    );
    expect(find.bySemanticsLabel('Body 0'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('RTL puts the indicator on the left', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(width: 400, child: HeroAccordion(children: _items(count: 1))),
      textDirection: TextDirection.rtl,
    );
    final Rect trigger = tester.getRect(find.byType(HeroAccordionTrigger));
    expect(
      tester.getRect(find.byType(HeroAccordionIndicator)).left - trigger.left,
      16,
    );
    expect(trigger.right - tester.getTopRight(find.text('Title 0')).dx, 16);
  });

  testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 240,
        child: HeroAccordion(
          defaultExpandedKeys: const <Object>{0},
          children: _items(),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
