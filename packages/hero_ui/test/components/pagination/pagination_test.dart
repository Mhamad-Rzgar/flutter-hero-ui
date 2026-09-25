import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData light = HeroThemeData.light();

  /// The docs' basic pagination: Previous, pages and Next, with state.
  Widget basic({
    HeroSize size = HeroSize.md,
    int total = 3,
    Widget? summary,
    ValueChanged<int>? onPage,
    int initialPage = 1,
    bool ellipsis = false,
  }) {
    int page = initialPage;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        void go(int p) {
          setState(() => page = p);
          onPage?.call(p);
        }

        final List<int?> pages = ellipsis
            ? heroPaginationRange(page: page, total: total)
            : <int?>[for (int i = 1; i <= total; i++) i];
        return HeroPagination(
          size: size,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ?summary,
            HeroPaginationContent(
              children: <Widget>[
                HeroPaginationItem(
                  child: HeroPaginationPrevious(
                    isDisabled: page == 1,
                    onPressed: () => go(page - 1),
                    children: const <Widget>[
                      HeroPaginationPreviousIcon(),
                      Text('Previous'),
                    ],
                  ),
                ),
                for (final int? p in pages)
                  HeroPaginationItem(
                    child: p == null
                        ? const HeroPaginationEllipsis()
                        : HeroPaginationLink(
                            isActive: p == page,
                            onPressed: () => go(p),
                            child: Text('$p'),
                          ),
                  ),
                HeroPaginationItem(
                  child: HeroPaginationNext(
                    isDisabled: page == total,
                    onPressed: () => go(page + 1),
                    children: const <Widget>[
                      Text('Next'),
                      HeroPaginationNextIcon(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Finder link(String label) => find.ancestor(
    of: find.text(label),
    matching: find.byType(HeroInteractable),
  );

  ShapeDecoration decorationOf(WidgetTester tester, String label) =>
      tester
              .widget<AnimatedContainer>(
                find.descendant(
                  of: link(label),
                  matching: find.byType(AnimatedContainer),
                ),
              )
              .decoration!
          as ShapeDecoration;

  test('heroPaginationRange follows the docs ellipsis logic', () {
    expect(heroPaginationRange(page: 1, total: 12), <int?>[1, 2, null, 12]);
    expect(heroPaginationRange(page: 3, total: 12), <int?>[
      1,
      2,
      3,
      4,
      null,
      12,
    ]);
    expect(heroPaginationRange(page: 6, total: 12), <int?>[
      1,
      null,
      5,
      6,
      7,
      null,
      12,
    ]);
    expect(heroPaginationRange(page: 12, total: 12), <int?>[1, null, 11, 12]);
    expect(heroPaginationRange(page: 1, total: 1), <int?>[1]);
    expect(heroPaginationRange(page: 1, total: 0), isEmpty);
  });

  testWidgets('pressing pages, previous and next changes the page', (
    WidgetTester tester,
  ) async {
    final List<int> pages = <int>[];
    await pumpHero(tester, basic(onPage: pages.add));
    expect(decorationOf(tester, '1').color, light.colors.defaultColor);
    expect(decorationOf(tester, '2').color!.a, 0);
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(pages, <int>[2, 3]);
    expect(decorationOf(tester, '3').color, light.colors.defaultColor);
    // Next is disabled on the last page.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(pages, <int>[2, 3]);
    await tester.tap(find.text('Previous'));
    await tester.pumpAndSettle();
    expect(pages, <int>[2, 3, 2]);
  });

  testWidgets('disabled buttons fade and ignore presses', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      HeroPagination(
        children: <Widget>[
          HeroPaginationContent(
            children: <Widget>[
              HeroPaginationItem(
                child: HeroPaginationPrevious(
                  isDisabled: true,
                  onPressed: () => presses++,
                  children: const <Widget>[Text('Previous')],
                ),
              ),
              HeroPaginationItem(
                child: HeroPaginationLink(
                  isDisabled: true,
                  onPressed: () => presses++,
                  child: const Text('1'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    await tester.tap(find.text('Previous'));
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(presses, 0);
    expect(
      tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((Opacity o) => o.opacity),
      everyElement(light.disabledOpacity),
    );
  });

  testWidgets('hover and press use the ghost fills and scale', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, basic());
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('2')));
    await tester.pumpAndSettle();
    expect(decorationOf(tester, '2').color, light.colors.defaultHover);
    final TestGesture press = await tester.startGesture(
      tester.getCenter(find.text('3')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final AnimatedScale scale = tester.widget<AnimatedScale>(
      find.descendant(of: link('3'), matching: find.byType(AnimatedScale)),
    );
    expect(scale.scale, 0.97);
    await press.up();
    await tester.pumpAndSettle();
  });

  testWidgets('sizes follow HeroUI below and above the md breakpoint', (
    WidgetTester tester,
  ) async {
    Future<void> check(Size surface, Map<HeroSize, double> sizes) async {
      for (final MapEntry<HeroSize, double> entry in sizes.entries) {
        await pumpHero(tester, basic(size: entry.key), surfaceSize: surface);
        expect(tester.getSize(link('1')), Size.square(entry.value));
        expect(tester.getSize(link('Next')).height, entry.value);
        final double fontSize = DefaultTextStyle.of(
          tester.element(find.text('1')),
        ).style.fontSize!;
        expect(fontSize, switch (entry.key) {
          HeroSize.sm => 12,
          HeroSize.md => 14,
          HeroSize.lg => 16,
        });
      }
    }

    await check(const Size(700, 400), <HeroSize, double>{
      HeroSize.sm: 32,
      HeroSize.md: 36,
      HeroSize.lg: 40,
    });
    await check(const Size(1024, 400), <HeroSize, double>{
      HeroSize.sm: 28,
      HeroSize.md: 32,
      HeroSize.lg: 36,
    });
  });

  testWidgets('previous and next have a 6 px gap and 10 px padding', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, basic(), surfaceSize: const Size(700, 400));
    final Rect button = tester.getRect(
      find.descendant(
        of: link('Next'),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final Rect label = tester.getRect(find.text('Next'));
    final Rect icon = tester.getRect(find.byType(HeroIcon).last);
    expect(label.left - button.left, 10);
    expect(icon.left - label.right, 6);
    expect(button.right - icon.right, 10);
    expect(icon.size, const Size.square(16));
  });

  testWidgets('summary sits above the content on narrow screens', (
    WidgetTester tester,
  ) async {
    const Widget summary = HeroPaginationSummary(
      child: Text('Showing 1-10 of 120 results'),
    );
    await pumpHero(
      tester,
      SizedBox(
        width: 380,
        child: basic(summary: summary, total: 12, ellipsis: true),
      ),
      surfaceSize: const Size(400, 400),
    );
    final Rect text = tester.getRect(find.text('Showing 1-10 of 120 results'));
    final Rect previous = tester.getRect(link('Previous'));
    expect(previous.top, greaterThan(text.bottom));
    expect(text.left, previous.left);
    final DefaultTextStyle style = DefaultTextStyle.of(
      tester.element(find.text('Showing 1-10 of 120 results')),
    );
    expect(style.style.color, light.colors.muted);
    expect(style.style.fontSize, 14);

    await pumpHero(
      tester,
      SizedBox(
        width: 680,
        child: basic(summary: summary, total: 12, ellipsis: true),
      ),
      surfaceSize: const Size(700, 400),
    );
    final Rect wideText = tester.getRect(
      find.text('Showing 1-10 of 120 results'),
    );
    expect(
      tester.getCenter(link('Previous')).dy,
      closeTo(wideText.center.dy, 1),
    );
  });

  testWidgets('ellipsis renders a muted, hidden placeholder', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, basic(total: 12, ellipsis: true, initialPage: 6));
    expect(find.text('…'), findsNWidgets(2));
    expect(find.bySemanticsLabel('…'), findsNothing);
    final DefaultTextStyle style = DefaultTextStyle.of(
      tester.element(find.text('…').first),
    );
    expect(
      tester.widget<Text>(find.text('…').first).style!.color,
      light.colors.muted,
    );
    expect(style, isNotNull);
    handle.dispose();
  });

  testWidgets('semantics: navigation landmark and the current page', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, basic());
    expect(
      tester.getSemantics(link('1')),
      matchesSemantics(
        label: '1',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    final SemanticsNode navigation = tester.getSemantics(
      find.byType(HeroPagination),
    );
    expect(navigation.role, SemanticsRole.navigation);
    expect(navigation.label, 'pagination');
    handle.dispose();
  });

  testWidgets('Tab moves through the buttons and Enter presses', (
    WidgetTester tester,
  ) async {
    final List<int> pages = <int>[];
    await pumpHero(tester, basic(onPage: pages.add, initialPage: 2));
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(Focus.of(tester.element(find.text('1'))).hasPrimaryFocus, isTrue);
    expect(
      find.descendant(
        of: link('1'),
        matching: find.byWidgetPredicate(
          (Widget w) =>
              w is CustomPaint && w.foregroundPainter is HeroFocusRingPainter,
        ),
      ),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(pages, <int>[1]);
  });

  testWidgets('lays out right to left with mirrored chevrons', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, basic(), textDirection: TextDirection.rtl);
    expect(
      tester.getCenter(find.text('Previous')).dx,
      greaterThan(tester.getCenter(find.text('Next')).dx),
    );
  });

  testWidgets('style overrides link colors and the content decoration', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroPagination(
        children: <Widget>[
          HeroPaginationContent(
            padding: const EdgeInsets.all(4),
            decoration: ShapeDecoration(
              color: light.colors.defaultColor,
              shape: light.shapeAll(12),
            ),
            children: <Widget>[
              HeroPaginationItem(
                child: HeroPaginationLink(
                  isActive: true,
                  style: HeroPaginationLinkStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      light.colors.accent,
                    ),
                    foregroundColor: WidgetStatePropertyAll<Color>(
                      light.colors.accentForeground,
                    ),
                  ),
                  child: const Text('1'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    expect(decorationOf(tester, '1').color, light.colors.accent);
    expect(
      DefaultTextStyle.of(tester.element(find.text('1'))).style.color,
      light.colors.accentForeground,
    );
    // 32 px links (800 px wide test view) plus 4 px padding on both sides.
    expect(tester.getSize(find.byType(HeroPaginationContent)).height, 32 + 8);
  });

  testWidgets('text scale 2.0 lays out without overflow', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 600,
        child: basic(
          summary: const HeroPaginationSummary(child: Text('Page 1 of 3')),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(link('1')).height, greaterThan(36));
  });
}
