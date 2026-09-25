import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData light = HeroThemeData.light();
  const List<String> basic = <String>['Overview', 'Analytics', 'Reports'];

  Widget tabs({
    List<String> labels = basic,
    HeroTabsVariant variant = HeroTabsVariant.primary,
    Axis orientation = Axis.horizontal,
    Object? selectedKey,
    Object? defaultSelectedKey,
    ValueChanged<Object>? onSelectionChanged,
    Set<Object> disabledKeys = const <Object>{},
    Set<String> disabledTabs = const <String>{},
    HeroTabsKeyboardActivation activation =
        HeroTabsKeyboardActivation.automatic,
    bool separators = false,
    bool container = true,
    HeroTabsAlign align = HeroTabsAlign.center,
  }) {
    final Widget list = HeroTabList(
      semanticLabel: 'Options',
      children: <Widget>[
        for (int i = 0; i < labels.length; i++)
          HeroTab(
            id: labels[i],
            isDisabled: disabledTabs.contains(labels[i]),
            separator: separators && i > 0 ? const HeroTabSeparator() : null,
            child: Text(labels[i]),
          ),
      ],
    );
    return HeroTabs(
      variant: variant,
      orientation: orientation,
      align: align,
      selectedKey: selectedKey,
      defaultSelectedKey: defaultSelectedKey,
      onSelectionChanged: onSelectionChanged,
      disabledKeys: disabledKeys,
      keyboardActivation: activation,
      children: <Widget>[
        if (container) HeroTabListContainer(child: list) else list,
        for (final String label in labels)
          HeroTabPanel(id: label, child: Text('$label panel')),
      ],
    );
  }

  Widget sized(Widget child, {double width = 400}) =>
      SizedBox(width: width, child: child);

  Finder tab(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(HeroTab));

  FocusNode focusOf(WidgetTester tester, String label) =>
      Focus.of(tester.element(find.text(label)));

  void useKeyboardHighlight() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
  }

  Color labelColor(WidgetTester tester, String label) =>
      DefaultTextStyle.of(tester.element(find.text(label))).style.color!;

  testWidgets('selects the first tab and shows only its panel', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs()));
    expect(find.text('Overview panel'), findsOneWidget);
    expect(find.text('Analytics panel'), findsNothing);
    expect(labelColor(tester, 'Overview'), light.colors.segmentForeground);
    expect(labelColor(tester, 'Analytics'), light.colors.muted);
  });

  testWidgets('tapping selects a tab and reports the key', (
    WidgetTester tester,
  ) async {
    final List<Object> changes = <Object>[];
    await pumpHero(tester, sized(tabs(onSelectionChanged: changes.add)));
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(changes, <Object>['Reports']);
    expect(find.text('Reports panel'), findsOneWidget);
    expect(find.text('Overview panel'), findsNothing);
    // Tapping the selected tab again does not report a change.
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(changes, <Object>['Reports']);
  });

  testWidgets('defaultSelectedKey and controlled selection', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs(defaultSelectedKey: 'Analytics')));
    expect(find.text('Analytics panel'), findsOneWidget);

    final List<Object> changes = <Object>[];
    await pumpHero(
      tester,
      sized(tabs(selectedKey: 'Analytics', onSelectionChanged: changes.add)),
    );
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(changes, <Object>['Reports']);
    expect(find.text('Analytics panel'), findsOneWidget);

    Object selected = 'Overview';
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => sized(
          tabs(
            selectedKey: selected,
            onSelectionChanged: (Object key) => setState(() => selected = key),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(selected, 'Analytics');
    expect(find.text('Analytics panel'), findsOneWidget);
  });

  testWidgets('disabled tabs cannot be selected and are skipped', (
    WidgetTester tester,
  ) async {
    final List<Object> changes = <Object>[];
    await pumpHero(
      tester,
      sized(
        tabs(
          disabledTabs: const <String>{'Overview'},
          disabledKeys: const <Object>{'Reports'},
          onSelectionChanged: changes.add,
        ),
      ),
    );
    // The first enabled tab is selected by default.
    expect(find.text('Analytics panel'), findsOneWidget);
    await tester.tap(find.text('Overview'));
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    final AnimatedOpacity opacity = tester.widget<AnimatedOpacity>(
      find
          .descendant(
            of: tab('Overview'),
            matching: find.byType(AnimatedOpacity),
          )
          .first,
    );
    expect(opacity.opacity, light.disabledOpacity);
    expect(focusOf(tester, 'Overview').canRequestFocus, isFalse);
  });

  testWidgets('hovering an unselected tab fades it to 70%', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs()));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Analytics')));
    await tester.pumpAndSettle();
    AnimatedOpacity opacityOf(String label) => tester.widget<AnimatedOpacity>(
      find
          .descendant(of: tab(label), matching: find.byType(AnimatedOpacity))
          .first,
    );
    expect(opacityOf('Analytics').opacity, 0.7);
    await mouse.moveTo(tester.getCenter(find.text('Overview')));
    await tester.pumpAndSettle();
    expect(opacityOf('Overview').opacity, 1);
  });

  testWidgets('arrow keys move focus and select, wrapping around', (
    WidgetTester tester,
  ) async {
    final FocusNode before = FocusNode(debugLabel: 'before');
    addTearDown(before.dispose);
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Focus(
            focusNode: before,
            child: const SizedBox(width: 10, height: 10),
          ),
          sized(
            tabs(
              defaultSelectedKey: 'Analytics',
              labels: const <String>[
                'Overview',
                'Analytics',
                'Reports',
                'Logs',
              ],
              disabledTabs: const <String>{'Reports'},
            ),
          ),
        ],
      ),
    );
    useKeyboardHighlight();
    before.requestFocus();
    await tester.pumpAndSettle();
    // Tab enters the list on the selected tab.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 'Analytics').hasPrimaryFocus, isTrue);

    // Disabled tabs are skipped.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 'Logs').hasPrimaryFocus, isTrue);
    expect(find.text('Logs panel'), findsOneWidget);

    // Wraps around to the first tab.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 'Overview').hasPrimaryFocus, isTrue);
    expect(find.text('Overview panel'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 'Logs').hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 'Overview').hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 'Logs').hasPrimaryFocus, isTrue);

    // The focused tab shows the focus ring.
    expect(
      find.descendant(
        of: tab('Logs'),
        matching: find.byWidgetPredicate(
          (Widget w) =>
              w is CustomPaint && w.foregroundPainter is HeroFocusRingPainter,
        ),
      ),
      findsOneWidget,
    );

    // Shift+Tab leaves the list.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(before.hasPrimaryFocus, isTrue);
  });

  testWidgets('arrow keys follow right-to-left and vertical layouts', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs()), textDirection: TextDirection.rtl);
    useKeyboardHighlight();
    // Overview is on the right in right-to-left layouts.
    expect(
      tester.getCenter(find.text('Overview')).dx,
      greaterThan(tester.getCenter(find.text('Reports')).dx),
    );
    focusOf(tester, 'Overview').requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Analytics panel'), findsOneWidget);

    await pumpHero(tester, sized(tabs(orientation: Axis.vertical)));
    focusOf(tester, 'Overview').requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.text('Analytics panel'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(find.text('Overview panel'), findsOneWidget);
    // Left and Right do nothing in vertical lists.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Overview panel'), findsOneWidget);
  });

  testWidgets('manual activation selects with Enter only', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      sized(tabs(activation: HeroTabsKeyboardActivation.manual)),
    );
    useKeyboardHighlight();
    focusOf(tester, 'Overview').requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(focusOf(tester, 'Analytics').hasPrimaryFocus, isTrue);
    expect(find.text('Overview panel'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Analytics panel'), findsOneWidget);
  });

  testWidgets('the indicator slides to the new tab', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs()));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.tap(find.text('Reports'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.hasRunningAnimations, isFalse);

    // Nothing animates under reduced motion.
    await pumpHero(
      tester,
      sized(tabs()),
      theme: light.copyWith(motion: const HeroMotion(reduceMotion: true)),
    );
    await tester.tap(find.text('Analytics'));
    await tester.pump();
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('horizontal tabs share the list width', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs()));
    // 400 wide list with 4 px padding: three tabs of (400 - 8) / 3.
    final double width = tester.getSize(tab('Overview')).width;
    expect(width, closeTo(392 / 3, 0.01));
    expect(tester.getSize(tab('Overview')).height, 32);
    final Rect list = tester.getRect(find.byType(HeroTabListContainer));
    expect(list.height, 40);
    expect(
      tester.getTopLeft(tab('Overview')) - list.topLeft,
      const Offset(4, 4),
    );
  });

  testWidgets('vertical tabs are as wide as the widest tab', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs(orientation: Axis.vertical), width: 500));
    final double overview = tester.getSize(tab('Overview')).width;
    expect(tester.getSize(tab('Reports')).width, overview);
    expect(overview, greaterThanOrEqualTo(80));
    // 4 px gap between vertical tabs.
    expect(
      tester.getTopLeft(tab('Analytics')).dy -
          tester.getBottomLeft(tab('Overview')).dy,
      4,
    );
    // The panel starts 8 (gap) + 16 (margin) + 8 (padding) after the list.
    final Rect container = tester.getRect(find.byType(HeroTabListContainer));
    expect(
      tester.getTopLeft(find.text('Overview panel')).dx - container.right,
      32,
    );
  });

  testWidgets('overflowing lists scroll with chevrons', (
    WidgetTester tester,
  ) async {
    const List<String> many = <String>[
      'Overview',
      'Analytics',
      'Reports',
      'Performance',
      'Engagement',
      'Audience',
      'Acquisition',
    ];
    await pumpHero(tester, sized(tabs(labels: many), width: 300));
    expect(find.bySemanticsLabel('Scroll tabs left'), findsNothing);
    expect(find.bySemanticsLabel('Scroll tabs right'), findsOneWidget);
    final ScrollPosition position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(position.maxScrollExtent, greaterThan(0));
    await tester.tap(find.bySemanticsLabel('Scroll tabs right'));
    await tester.pumpAndSettle();
    expect(position.pixels, closeTo(300 * 0.8, 0.5));
    expect(find.bySemanticsLabel('Scroll tabs left'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Scroll tabs left'));
    await tester.pumpAndSettle();
    expect(position.pixels, 0);

    // Keyboard focus scrolls the focused tab into view.
    useKeyboardHighlight();
    focusOf(tester, 'Overview').requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(tab('Acquisition')).right,
      lessThanOrEqualTo(
        tester.getRect(find.byType(HeroTabListContainer)).right,
      ),
    );
    expect(position.pixels, greaterThan(position.maxScrollExtent - 5));
    expect(find.text('Acquisition panel'), findsOneWidget);
  });

  testWidgets('separators hide next to the selected tab', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      sized(
        tabs(
          labels: const <String>['Overview', 'Analytics', 'Reports', 'Logs'],
          separators: true,
          defaultSelectedKey: 'Analytics',
        ),
      ),
    );
    double separatorOpacity(String label) => tester
        .widget<AnimatedOpacity>(
          find.descendant(
            of: find.descendant(
              of: tab(label),
              matching: find.byType(HeroTabSeparator),
            ),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(separatorOpacity('Analytics'), 0);
    expect(separatorOpacity('Reports'), 0);
    expect(separatorOpacity('Logs'), 1);
  });

  testWidgets('secondary variant draws a rule and foreground text', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs(variant: HeroTabsVariant.secondary)));
    expect(labelColor(tester, 'Overview'), light.colors.foreground);
    final DecoratedBox box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(HeroTabListContainer),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final Border border = (box.decoration as ShapeDecoration).shape as Border;
    expect(border.bottom.color, light.colors.border);
    // No list padding in the secondary container.
    expect(
      tester.getTopLeft(tab('Overview')),
      tester.getTopLeft(find.byType(HeroTabListContainer)),
    );
  });

  testWidgets('alignment moves the tab content', (WidgetTester tester) async {
    await pumpHero(tester, sized(tabs(align: HeroTabsAlign.start)));
    expect(
      tester.getTopLeft(find.text('Analytics')).dx -
          tester.getTopLeft(tab('Analytics')).dx,
      16,
    );
    await pumpHero(tester, sized(tabs(align: HeroTabsAlign.end)));
    expect(
      tester.getTopRight(tab('Analytics')).dx -
          tester.getTopRight(find.text('Analytics')).dx,
      16,
    );
  });

  testWidgets('works without a list container', (WidgetTester tester) async {
    await pumpHero(tester, sized(tabs(container: false)));
    expect(find.byType(Scrollable), findsNothing);
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Reports panel'), findsOneWidget);
  });

  testWidgets('exposes tab bar, tab and tab panel semantics', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, sized(tabs()));
    final SemanticsNode overview = tester.getSemantics(tab('Overview'));
    expect(overview.role, SemanticsRole.tab);
    expect(overview.flagsCollection.isSelected, Tristate.isTrue);
    expect(overview.label, 'Overview');
    final SemanticsNode analytics = tester.getSemantics(tab('Analytics'));
    expect(analytics.flagsCollection.isSelected, Tristate.isFalse);
    expect(analytics.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    final SemanticsNode bar = overview.parent!;
    expect(bar.role, SemanticsRole.tabBar);
    expect(bar.label, 'Options');
    expect(
      tester.getSemantics(find.text('Overview panel')).role,
      SemanticsRole.tabPanel,
    );
    handle.dispose();
  });

  testWidgets('style overrides colors, opacity and the indicator', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      sized(
        HeroTabs(
          children: <Widget>[
            HeroTabListContainer(
              decoration: ShapeDecoration(
                color: light.colors.accentSoft,
                shape: light.shapeAll(12),
              ),
              child: HeroTabList(
                children: <Widget>[
                  for (final String label in basic)
                    HeroTab(
                      id: label,
                      indicator: HeroTabIndicator(
                        color: light.colors.accent,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        shadows: const <BoxShadow>[],
                      ),
                      style: HeroTabStyle(
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (Set<WidgetState> states) =>
                              states.contains(WidgetState.selected)
                              ? light.colors.accentForeground
                              : light.colors.muted,
                        ),
                        opacity: const WidgetStatePropertyAll<double>(1),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child: Text(label),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    expect(labelColor(tester, 'Overview'), light.colors.accentForeground);
    expect(labelColor(tester, 'Analytics'), light.colors.muted);
  });

  testWidgets('text scale 2.0 lays out without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, sized(tabs()), textScale: 2);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(tab('Overview')).height, greaterThan(32));
    await pumpHero(
      tester,
      sized(tabs(orientation: Axis.vertical)),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tight height makes a vertical list scroll', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 400,
        height: 100,
        child: tabs(
          orientation: Axis.vertical,
          labels: const <String>['One', 'Two', 'Three', 'Four', 'Five'],
        ),
      ),
    );
    expect(tester.getSize(find.byType(HeroTabListContainer)).height, 100);
    expect(find.bySemanticsLabel('Scroll tabs down'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Scroll tabs down'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Scroll tabs up'), findsOneWidget);
  });
}
