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

  Widget breadcrumbs({
    List<String> labels = const <String>[
      'Home',
      'Products',
      'Electronics',
      'Laptop',
    ],
    ValueChanged<String>? onPressed,
    bool isDisabled = false,
    Widget? separator,
  }) => HeroBreadcrumbs(
    isDisabled: isDisabled,
    separator: separator,
    children: <Widget>[
      for (final String label in labels)
        HeroBreadcrumbsItem(
          href: '#',
          onPressed: onPressed == null ? null : () => onPressed(label),
          child: Text(label),
        ),
    ],
  );

  Color colorOf(WidgetTester tester, String label) =>
      DefaultTextStyle.of(tester.element(find.text(label))).style.color!;

  testWidgets('renders links, separators and the current page', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, breadcrumbs());
    // One separator between each pair of items.
    expect(find.byType(HeroIcon), findsNWidgets(3));
    expect(tester.getSize(find.byType(HeroIcon).first), const Size.square(12));
    expect(colorOf(tester, 'Home'), light.colors.muted);
    expect(colorOf(tester, 'Laptop'), light.colors.link);
    final TextStyle style = DefaultTextStyle.of(
      tester.element(find.text('Home')),
    ).style;
    expect(style.fontSize, 14);
    expect(style.fontWeight, FontWeight.w500);
    expect(tester.getSize(find.text('Home')).height, 20);
  });

  testWidgets('spacing follows the CSS gaps', (WidgetTester tester) async {
    await pumpHero(tester, breadcrumbs());
    final Rect home = tester.getRect(find.text('Home'));
    final Rect chevron = tester.getRect(find.byType(HeroIcon).first);
    final Rect products = tester.getRect(find.text('Products'));
    expect(chevron.left - home.right, 4);
    expect(products.left - chevron.right, 6);
  });

  testWidgets('pressing a link calls onPressed; the current page is inert', (
    WidgetTester tester,
  ) async {
    final List<String> pressed = <String>[];
    await pumpHero(tester, breadcrumbs(onPressed: pressed.add));
    await tester.tap(find.text('Products'));
    await tester.tap(find.text('Laptop'));
    await tester.pumpAndSettle();
    expect(pressed, <String>['Products']);
  });

  testWidgets('hover underlines the link', (WidgetTester tester) async {
    await pumpHero(tester, breadcrumbs(onPressed: (_) {}));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Home')));
    await tester.pumpAndSettle();
    final RenderBox text = tester.renderObject<RenderBox>(find.text('Home'));
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: 'Home',
        style: DefaultTextStyle.of(tester.element(find.text('Home'))).style,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    addTearDown(painter.dispose);
    final double baseline = painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    // Painting is recorded relative to the breadcrumbs.
    final Offset origin =
        text.localToGlobal(Offset.zero) -
        tester.getTopLeft(find.byType(HeroBreadcrumbs));
    // A 1.5 px line 4 px below the baseline, in --muted at 50%.
    final Color muted = light.colors.muted;
    expect(
      find.byType(HeroBreadcrumbs),
      paints..rect(
        rect: Rect.fromLTWH(
          origin.dx,
          origin.dy + baseline + 4,
          text.size.width,
          1.5,
        ),
        color: muted.withValues(alpha: muted.a * 0.5),
      ),
    );
    // The current page never underlines.
    await mouse.moveTo(tester.getCenter(find.text('Laptop')));
    await tester.pumpAndSettle();
    expect(find.byType(HeroBreadcrumbs), isNot(paints..rect(color: muted)));
  });

  testWidgets('disabled breadcrumbs fade every link but the current one', (
    WidgetTester tester,
  ) async {
    final List<String> pressed = <String>[];
    await pumpHero(
      tester,
      breadcrumbs(isDisabled: true, onPressed: pressed.add),
    );
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(pressed, isEmpty);
    double opacityOf(String label) => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;
    expect(opacityOf('Home'), light.disabledOpacity);
    expect(opacityOf('Laptop'), 1);
  });

  testWidgets('Tab moves through the links and Enter activates', (
    WidgetTester tester,
  ) async {
    final List<String> pressed = <String>[];
    await pumpHero(tester, breadcrumbs(onPressed: pressed.add));
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      Focus.of(tester.element(find.text('Products'))).hasPrimaryFocus,
      isTrue,
    );
    expect(
      find.byWidgetPredicate(
        (Widget w) =>
            w is CustomPaint && w.foregroundPainter is HeroFocusRingPainter,
      ),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(pressed, <String>['Products']);
    // The current page is not focusable.
    expect(
      Focus.of(tester.element(find.text('Laptop'))).canRequestFocus,
      isFalse,
    );
  });

  testWidgets('semantics: navigation landmark, links and current page', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, breadcrumbs(onPressed: (_) {}));
    final SemanticsNode nav = tester.getSemantics(find.byType(HeroBreadcrumbs));
    expect(nav.role, SemanticsRole.navigation);
    expect(nav.label, 'Breadcrumbs');
    expect(
      tester.getSemantics(find.text('Home')),
      matchesSemantics(
        label: 'Home',
        isLink: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasTapAction: true,
      ),
    );
    final SemanticsData current = tester
        .getSemantics(find.text('Laptop'))
        .getSemanticsData();
    expect(current.label, 'Laptop');
    expect(current.flagsCollection.isLink, isTrue);
    expect(current.flagsCollection.isSelected, Tristate.isTrue);
    expect(current.flagsCollection.isEnabled, Tristate.isFalse);
    expect(current.hasAction(SemanticsAction.tap), isFalse);
    expect(
      tester.getSemantics(find.text('Home')).getSemanticsData().linkUrl,
      Uri.parse('#'),
    );
    handle.dispose();
  });

  testWidgets('custom separator and right-to-left layout', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      breadcrumbs(separator: const Text('/')),
      textDirection: TextDirection.rtl,
    );
    expect(find.text('/'), findsNWidgets(3));
    expect(
      tester.getCenter(find.text('Home')).dx,
      greaterThan(tester.getCenter(find.text('Laptop')).dx),
    );
  });

  testWidgets('builder receives the breadcrumb state', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroBreadcrumbs(
        children: <Widget>[
          for (final String label in const <String>['Home', 'Laptop'])
            HeroBreadcrumbsItem(
              builder: (BuildContext context, HeroBreadcrumbState state) =>
                  Text(state.isCurrent ? '$label (current)' : label),
            ),
        ],
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Laptop (current)'), findsOneWidget);
  });

  testWidgets('style overrides the link color', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroBreadcrumbs(
        children: <Widget>[
          HeroBreadcrumbsItem(
            onPressed: () {},
            style: HeroBreadcrumbsItemStyle(
              foregroundColor: WidgetStatePropertyAll<Color>(
                light.colors.accent,
              ),
            ),
            child: const Text('Home'),
          ),
          const HeroBreadcrumbsItem(child: Text('Laptop')),
        ],
      ),
    );
    expect(colorOf(tester, 'Home'), light.colors.accent);
  });

  testWidgets('wraps instead of overflowing, also at text scale 2.0', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(width: 200, child: breadcrumbs()),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Laptop')).dy,
      greaterThan(tester.getTopLeft(find.text('Home')).dy),
    );
  });
}
