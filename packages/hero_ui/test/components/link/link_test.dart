import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  final HeroThemeData theme = HeroThemeData.light();

  RenderHeroLinkUnderline underline(WidgetTester tester) =>
      tester.renderObject<RenderHeroLinkUnderline>(
        find.byWidgetPredicate(
          (Widget w) => w.runtimeType.toString() == '_LinkUnderline',
        ),
      );

  double iconOpacity(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(HeroLinkIcon),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;

  Future<TestGesture> hover(WidgetTester tester) async {
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(HeroLink)));
    await tester.pumpAndSettle();
    return mouse;
  }

  Widget link({
    VoidCallback? onPressed,
    Uri? href,
    bool isDisabled = false,
    HeroLinkUnderline underline = HeroLinkUnderline.hover,
    FocusNode? focusNode,
  }) => HeroLink(
    onPressed: onPressed,
    href: href,
    isDisabled: isDisabled,
    underline: underline,
    focusNode: focusNode,
    children: const <Widget>[Text('Call to action'), HeroLinkIcon()],
  );

  testWidgets('renders medium text in the link color', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, link(), theme: theme);
    final TextStyle style = DefaultTextStyle.of(
      tester.element(find.text('Call to action')),
    ).style;
    expect(style.color, theme.colors.link);
    expect(style.fontWeight, FontWeight.w500);
    expect(style.fontSize, 16);
    expect(underline(tester).visible, isFalse);
    expect(underline(tester).color, theme.colors.separatorTertiary);
    expect(iconOpacity(tester), 0.6);
  });

  testWidgets('press calls onPressed then opens href through the handler', (
    WidgetTester tester,
  ) async {
    final List<String> log = <String>[];
    await pumpHero(
      tester,
      HeroLinkHandler(
        onOpen: (Uri href, HeroLinkTarget target) =>
            log.add('open $href ${target.name}'),
        child: link(
          onPressed: () => log.add('pressed'),
          href: Uri.parse('https://heroui.com'),
        ),
      ),
    );
    await tester.tap(find.byType(HeroLink));
    await tester.pumpAndSettle();
    expect(log, <String>['pressed', 'open https://heroui.com self']);
  });

  testWidgets('hover underlines with muted/50 and shows the icon', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, link(onPressed: () {}), theme: theme);
    await hover(tester);
    expect(underline(tester).visible, isTrue);
    expect(
      underline(tester).color.a,
      closeTo(theme.colors.muted.a * 0.5, 0.01),
    );
    expect(iconOpacity(tester), 1);
    final List<Rect> rects = underline(tester).underlineRects();
    expect(rects, hasLength(1));
    final Rect text = tester.getRect(find.text('Call to action'));
    final Rect box = tester.getRect(find.byType(HeroLink));
    expect(rects.single.width, closeTo(text.width, 1));
    expect(rects.single.height, 1.5);
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: 'Call to action',
        style: DefaultTextStyle.of(
          tester.element(find.text('Call to action')),
        ).style,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final double baseline = painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    painter.dispose();
    expect(rects.single.top, closeTo(text.top - box.top + baseline + 4, 0.01));
  });

  testWidgets('pressed state uses the muted decoration', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, link(onPressed: () {}), theme: theme);
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(HeroLink)),
    );
    await tester.pump();
    expect(underline(tester).visible, isTrue);
    expect(underline(tester).color, theme.colors.muted);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('underline always and none', (WidgetTester tester) async {
    await pumpHero(
      tester,
      link(underline: HeroLinkUnderline.always),
      theme: theme,
    );
    expect(underline(tester).visible, isTrue);
    expect(underline(tester).color, theme.colors.separatorTertiary);

    await pumpHero(tester, link(underline: HeroLinkUnderline.none));
    await hover(tester);
    expect(underline(tester).visible, isFalse);
  });

  testWidgets('offset, decoration color and state colors', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroLink(
        underline: HeroLinkUnderline.always,
        underlineOffset: 1,
        decorationColor: theme.colors.accent,
        color: WidgetStateColor.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.hovered)
              ? theme.colors.danger
              : theme.colors.success,
        ),
        child: const Text('Styled'),
      ),
      theme: theme,
    );
    expect(underline(tester).offset, 1);
    expect(underline(tester).color, theme.colors.accent);
    expect(
      DefaultTextStyle.of(tester.element(find.text('Styled'))).style.color,
      theme.colors.success,
    );
    await hover(tester);
    expect(
      DefaultTextStyle.of(tester.element(find.text('Styled'))).style.color,
      theme.colors.danger,
    );
  });

  testWidgets('icon is skipped by the underline and sized 0.75em', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroLink(
        underline: HeroLinkUnderline.always,
        gap: 4,
        children: <Widget>[
          HeroLinkIcon(child: Text('X')),
          Text('Icon at start'),
        ],
      ),
    );
    expect(underline(tester).underlineRects(), hasLength(1));
    final Size icon = tester.getSize(find.byType(HeroLinkIcon));
    expect(icon, const Size(12, 12));
  });

  testWidgets('Enter activates, Space does not', (WidgetTester tester) async {
    int presses = 0;
    final FocusNode node = FocusNode();
    addTearDown(node.dispose);
    await pumpHero(tester, link(onPressed: () => presses++, focusNode: node));
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    node.requestFocus();
    await tester.pumpAndSettle();
    expect(find.byType(CustomPaint), findsWidgets);
    expect(iconOpacity(tester), 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(presses, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(presses, 1);
  });

  testWidgets('disabled links fade and ignore presses', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      link(onPressed: () => presses++, isDisabled: true),
      theme: theme,
    );
    await tester.tap(find.byType(HeroLink), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(presses, 0);
    final AnimatedOpacity fade = tester.widget<AnimatedOpacity>(
      find
          .ancestor(
            of: find.byType(HeroFocusRing),
            matching: find.byType(AnimatedOpacity),
          )
          .first,
    );
    expect(fade.opacity, theme.disabledOpacity);
  });

  testWidgets('exposes link semantics with the url', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      link(onPressed: () {}, href: Uri.parse('https://heroui.com')),
    );
    final SemanticsNode node = tester.getSemantics(find.byType(HeroLink));
    final SemanticsData data = node.getSemanticsData();
    expect(data.flagsCollection.isLink, isTrue);
    expect(data.flagsCollection.isButton, isFalse);
    expect(data.linkUrl, Uri.parse('https://heroui.com'));
    expect(data.label, 'Call to action');
    handle.dispose();
  });

  testWidgets('builder receives the interaction state', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroLink(
        onPressed: () {},
        builder: (BuildContext context, HeroInteractionState state) =>
            Text(state.isHovered ? 'Hovered' : 'Idle'),
      ),
    );
    expect(find.text('Idle'), findsOneWidget);
    await hover(tester);
    expect(find.text('Hovered'), findsOneWidget);
  });

  testWidgets('RTL mirrors the icon placement; 2x text scale fits', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      link(underline: HeroLinkUnderline.always),
      textDirection: TextDirection.rtl,
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getCenter(find.byType(HeroLinkIcon)).dx,
      lessThan(tester.getCenter(find.text('Call to action')).dx),
    );
    final Rect rect = underline(tester).underlineRects().single;
    expect(
      rect.width,
      closeTo(tester.getSize(find.text('Call to action')).width, 1),
    );
  });

  testWidgets('wrapped text is underlined on every line', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 120,
        child: HeroLink(
          underline: HeroLinkUnderline.always,
          child: Text('A link that wraps onto several lines'),
        ),
      ),
    );
    expect(underline(tester).underlineRects().length, greaterThan(1));
  });
}
