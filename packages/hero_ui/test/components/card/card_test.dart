import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// The card's own decoration (the outermost shape decoration below it).
ShapeDecoration _decoration(WidgetTester tester, [Finder? card]) =>
    tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: card ?? find.byType(HeroCard),
                matching: find.byType(DecoratedBox),
              ),
            )
            .first
            .decoration
        as ShapeDecoration;

TextStyle? _textStyle(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style;

Widget _sized(Widget child, {double width = 360}) =>
    SizedBox(width: width, child: child);

void main() {
  testWidgets('lays out children in a padded column with a 12 px gap', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _sized(
        const HeroCard(
          children: <Widget>[
            SizedBox(key: Key('a'), width: 40, height: 20),
            SizedBox(key: Key('b'), width: 40, height: 30),
          ],
        ),
      ),
    );
    final Rect card = tester.getRect(find.byType(HeroCard));
    final Rect a = tester.getRect(find.byKey(const Key('a')));
    final Rect b = tester.getRect(find.byKey(const Key('b')));
    expect(card.width, 360);
    expect(a.topLeft, card.topLeft + const Offset(16, 16));
    expect(b.top, a.bottom + 12);
    expect(card.bottom, b.bottom + 16);
    // Children keep their own width (they are not stretched).
    expect(a.width, 40);
  });

  testWidgets('each variant paints its surface, shadow and radius', (
    WidgetTester tester,
  ) async {
    final HeroThemeData theme = HeroThemeData.light();
    final Map<HeroCardVariant, Color?> backgrounds = <HeroCardVariant, Color?>{
      HeroCardVariant.transparent: null,
      HeroCardVariant.standard: theme.colors.surface,
      HeroCardVariant.secondary: theme.colors.surfaceSecondary,
      HeroCardVariant.tertiary: theme.colors.surfaceTertiary,
    };
    for (final MapEntry<HeroCardVariant, Color?> entry in backgrounds.entries) {
      await pumpHero(
        tester,
        _sized(HeroCard(variant: entry.key, title: const Text('Title'))),
      );
      final ShapeDecoration decoration = _decoration(tester);
      expect(decoration.color, entry.value, reason: '${entry.key}');
      expect(
        decoration.shadows,
        entry.key == HeroCardVariant.transparent
            ? isNull
            : theme.shadows.surface.boxShadows,
      );
      expect(
        (decoration.shape as RoundedSuperellipseBorder).borderRadius,
        BorderRadius.circular(24),
      );
      expect(entry.key.background(theme.colors), entry.value);
    }
  });

  testWidgets('has no shadow in dark mode', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _sized(const HeroCard(title: Text('Title'))),
      theme: HeroThemeData.dark(),
    );
    expect(_decoration(tester).shadows, isNull);
    expect(_decoration(tester).color, HeroThemeData.dark().colors.surface);
  });

  testWidgets('the radius is min(32, --radius-3xl)', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _sized(const HeroCard(title: Text('Title'))),
      theme: HeroThemeData.light().copyWith(radii: const HeroRadii(radius: 16)),
    );
    expect(
      (_decoration(tester).shape as RoundedSuperellipseBorder).borderRadius,
      BorderRadius.circular(32),
    );
  });

  testWidgets('builds header, content and footer from the shorthand', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _sized(
        const HeroCard(
          title: Text('Login'),
          description: Text('Enter your credentials'),
          content: Text('Body'),
          footer: Text('Footer'),
        ),
      ),
    );
    final HeroThemeData theme = HeroThemeData.light();
    expect(find.byType(HeroCardHeader), findsOneWidget);
    expect(find.byType(HeroCardTitle), findsOneWidget);
    expect(find.byType(HeroCardDescription), findsOneWidget);
    expect(find.byType(HeroCardContent), findsOneWidget);
    expect(find.byType(HeroCardFooter), findsOneWidget);

    final Rect card = tester.getRect(find.byType(HeroCard));
    final Rect title = tester.getRect(find.text('Login'));
    final Rect description = tester.getRect(
      find.text('Enter your credentials'),
    );
    final Rect header = tester.getRect(find.byType(HeroCardHeader));
    final Rect content = tester.getRect(find.byType(HeroCardContent));
    final Rect footer = tester.getRect(find.byType(HeroCardFooter));
    expect(title.height, 24);
    expect(description.top, title.bottom);
    expect(description.height, 20);
    expect(content.top, header.bottom + 12);
    expect(footer.top, content.bottom + 12);
    // The parts fill the card width.
    for (final Rect part in <Rect>[header, content, footer]) {
      expect(part.left, card.left + 16);
      expect(part.width, 360 - 32);
    }

    final TextStyle titleStyle = _textStyle(tester, 'Login')!;
    expect(titleStyle.fontSize, 14);
    expect(titleStyle.fontWeight, HeroTypography.medium);
    expect(titleStyle.color, theme.colors.foreground);
    final TextStyle descriptionStyle = _textStyle(
      tester,
      'Enter your credentials',
    )!;
    expect(descriptionStyle.fontSize, 14);
    expect(descriptionStyle.color, theme.colors.muted);
    // Content inherits the surface foreground.
    expect(_textStyle(tester, 'Body')!.color, theme.colors.surfaceForeground);
  });

  testWidgets('content has a 4 px gap; footer is a centered row', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _sized(
        const HeroCard(
          children: <Widget>[
            HeroCardContent(
              children: <Widget>[
                SizedBox(key: Key('c1'), height: 10),
                SizedBox(key: Key('c2'), height: 10),
              ],
            ),
            HeroCardFooter(
              children: <Widget>[
                SizedBox(key: Key('f1'), width: 20, height: 40),
                SizedBox(key: Key('f2'), width: 20, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
    expect(
      tester.getRect(find.byKey(const Key('c2'))).top,
      tester.getRect(find.byKey(const Key('c1'))).bottom + 4,
    );
    final Rect f1 = tester.getRect(find.byKey(const Key('f1')));
    final Rect f2 = tester.getRect(find.byKey(const Key('f2')));
    expect(f2.left, f1.right);
    expect(f2.center.dy, f1.center.dy);
  });

  testWidgets('vertical footer centers its children', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _sized(
        HeroCard(
          children: <Widget>[
            HeroCardFooter(
              direction: Axis.vertical,
              gap: 8,
              children: <Widget>[
                HeroButton(
                  fullWidth: true,
                  onPressed: () {},
                  child: const Text('Sign In'),
                ),
                const Text('Forgot password?'),
              ],
            ),
          ],
        ),
      ),
    );
    final Rect footer = tester.getRect(find.byType(HeroCardFooter));
    final Rect button = tester.getRect(find.byType(HeroButton));
    final Rect link = tester.getRect(find.text('Forgot password?'));
    expect(button.width, footer.width);
    expect(link.top, button.bottom + 8);
    expect(link.center.dx, closeTo(footer.center.dx, 0.01));
  });

  testWidgets('title is a level-3 heading', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      _sized(
        const HeroCard(
          semanticLabel: 'Pricing',
          children: <Widget>[
            HeroCardHeader(
              children: <Widget>[
                HeroCardTitle.text('Pro plan'),
                HeroCardDescription.text('For teams'),
              ],
            ),
          ],
        ),
      ),
    );
    final SemanticsData title = tester
        .getSemantics(find.text('Pro plan'))
        .getSemanticsData();
    expect(title.flagsCollection.isHeader, isTrue);
    expect(title.headingLevel, 3);
    expect(find.bySemanticsLabel('Pricing'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('publishes its surface, except when transparent', (
    WidgetTester tester,
  ) async {
    HeroSurfaceVariant? surfaceOf(String text) =>
        HeroSurfaceScope.variantOf(tester.element(find.text(text)));
    await pumpHero(
      tester,
      _sized(
        const Column(
          children: <Widget>[
            HeroCard(content: Text('standard')),
            HeroCard(
              variant: HeroCardVariant.secondary,
              content: Text('secondary'),
            ),
            HeroCard(
              variant: HeroCardVariant.tertiary,
              content: Text('tertiary'),
            ),
            HeroCard(
              variant: HeroCardVariant.transparent,
              content: Text('transparent'),
            ),
            HeroSurface(
              variant: HeroSurfaceVariant.secondary,
              child: HeroCard(
                variant: HeroCardVariant.transparent,
                content: Text('nested'),
              ),
            ),
          ],
        ),
      ),
    );
    expect(surfaceOf('standard'), HeroSurfaceVariant.standard);
    expect(surfaceOf('secondary'), HeroSurfaceVariant.secondary);
    expect(surfaceOf('tertiary'), HeroSurfaceVariant.tertiary);
    expect(surfaceOf('transparent'), isNull);
    expect(surfaceOf('nested'), HeroSurfaceVariant.secondary);
  });

  testWidgets('takes its content width where the width is unbounded', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroCard(
            children: <Widget>[
              SizedBox(width: 100, height: 10),
              HeroCardFooter(children: <Widget>[SizedBox(width: 50)]),
            ],
          ),
        ],
      ),
    );
    expect(tester.getSize(find.byType(HeroCard)).width, 132);
    expect(tester.getSize(find.byType(HeroCardFooter)).width, 100);
  });

  testWidgets('width, height, constraints, padding and gap', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const HeroCard(
        width: 200,
        height: 120,
        padding: EdgeInsetsDirectional.only(start: 4, top: 8),
        gap: 2,
        children: <Widget>[
          SizedBox(key: Key('a'), width: 10, height: 10),
          SizedBox(key: Key('b'), width: 10, height: 10),
        ],
      ),
    );
    final Rect card = tester.getRect(find.byType(HeroCard));
    expect(card.size, const Size(200, 120));
    expect(
      tester.getTopLeft(find.byKey(const Key('a'))),
      card.topLeft + const Offset(4, 8),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('b'))).dy,
      card.top + 8 + 10 + 2,
    );

    await pumpHero(
      tester,
      const HeroCard(
        constraints: BoxConstraints(maxWidth: 240, minHeight: 200),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(key: Key('top'), height: 10),
          SizedBox(key: Key('bottom'), height: 10),
        ],
      ),
    );
    final Rect sized = tester.getRect(find.byType(HeroCard));
    expect(sized.size, const Size(240, 200));
    // Like `mt-auto`, the last child sits at the bottom.
    expect(
      tester.getRect(find.byKey(const Key('bottom'))).bottom,
      sized.bottom - 16,
    );
  });

  testWidgets('horizontal stretched cards give children equal heights', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _sized(
        const HeroCard(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(key: Key('image'), width: 120, height: 120),
            Expanded(
              child: HeroCardHeader(
                children: <Widget>[HeroCardTitle.text('Title')],
              ),
            ),
          ],
        ),
      ),
    );
    final Rect image = tester.getRect(find.byKey(const Key('image')));
    final Rect header = tester.getRect(find.byType(HeroCardHeader));
    expect(header.left, image.right + 12);
    expect(header.height, 120);
    expect(tester.getSize(find.byType(HeroCard)), const Size(360, 152));
  });

  testWidgets('background is clipped behind the content; overlays on top', (
    WidgetTester tester,
  ) async {
    const Color border = Color(0xFFFFAA00);
    await pumpHero(
      tester,
      _sized(
        const HeroCard(
          style: HeroCardStyle(border: BorderSide(color: border)),
          background: SizedBox.expand(key: Key('background')),
          overlays: <Widget>[
            PositionedDirectional(
              top: 12,
              end: 12,
              child: SizedBox(key: Key('close'), width: 20, height: 20),
            ),
          ],
          title: Text('NEO'),
        ),
      ),
    );
    final Rect card = tester.getRect(find.byType(HeroCard));
    // Like an absolutely positioned element, the layer covers the padding
    // box, inside the 1 px border.
    expect(
      tester.getRect(find.byKey(const Key('background'))),
      card.deflate(1),
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('background')),
        matching: find.byType(ClipPath),
      ),
      findsOneWidget,
    );
    expect(
      tester.getRect(find.byKey(const Key('close'))).topRight,
      card.topRight + const Offset(-13, 13),
    );
    // The border takes room inside the card.
    expect(
      tester.getTopLeft(find.text('NEO')),
      card.topLeft + const Offset(17, 17),
    );
  });

  testWidgets('style overrides and content clipping', (
    WidgetTester tester,
  ) async {
    const Color fill = Color(0xFF112233);
    const LinearGradient gradient = LinearGradient(
      colors: <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
    );
    await pumpHero(
      tester,
      _sized(
        const HeroCard(
          clipBehavior: Clip.antiAlias,
          style: HeroCardStyle(
            color: fill,
            gradient: gradient,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            shadows: <BoxShadow>[BoxShadow(blurRadius: 4)],
          ),
          title: Text('Title'),
        ),
      ),
    );
    final List<DecoratedBox> boxes = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(HeroCard),
            matching: find.byType(DecoratedBox),
          ),
        )
        .toList();
    final ShapeDecoration base = boxes[0].decoration as ShapeDecoration;
    final ShapeDecoration overlay = boxes[1].decoration as ShapeDecoration;
    expect(base.color, fill);
    expect(base.shadows, const <BoxShadow>[BoxShadow(blurRadius: 4)]);
    expect(overlay.gradient, gradient);
    expect(
      (base.shape as RoundedSuperellipseBorder).borderRadius,
      const BorderRadius.all(Radius.circular(12)),
    );
    // The content is clipped inside the decoration, so the shadow is not.
    expect(
      find.descendant(
        of: find.byWidget(boxes[0]),
        matching: find.byType(ClipPath),
      ),
      findsOneWidget,
    );
    expect(const HeroCardStyle(color: fill), const HeroCardStyle(color: fill));
    expect(
      const HeroCardStyle(color: fill).hashCode,
      const HeroCardStyle(color: fill).hashCode,
    );
  });

  group('interactive', () {
    testWidgets('a pressable card is a button activated by tap and keys', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int presses = 0;
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpHero(
        tester,
        _sized(
          HeroCard(
            onPressed: () => presses++,
            focusNode: focusNode,
            semanticLabel: 'Open plan',
            title: const Text('Pro plan'),
          ),
        ),
      );
      await tester.tap(find.byType(HeroCard));
      await tester.pumpAndSettle();
      expect(presses, 1);

      focusNode.requestFocus();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(presses, 3);

      final SemanticsData data = tester
          .getSemantics(find.byType(HeroCard))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.label, contains('Open plan'));
      handle.dispose();
    });

    testWidgets('a link card opens its href with Enter, not Space', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final List<(Uri, HeroLinkTarget)> opened = <(Uri, HeroLinkTarget)>[];
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final Uri href = Uri.parse('https://heroui.com/details');
      await pumpHero(
        tester,
        HeroLinkHandler(
          onOpen: (Uri uri, HeroLinkTarget target) => opened.add((uri, target)),
          child: _sized(
            HeroCard(
              href: href,
              target: HeroLinkTarget.blank,
              focusNode: focusNode,
              semanticLabel: 'View product details',
              title: const Text('Product Name'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(HeroCard));
      await tester.pumpAndSettle();
      expect(opened, <(Uri, HeroLinkTarget)>[(href, HeroLinkTarget.blank)]);

      focusNode.requestFocus();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(opened, hasLength(1));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(opened, hasLength(2));

      final SemanticsData data = tester
          .getSemantics(find.byType(HeroCard))
          .getSemanticsData();
      expect(data.flagsCollection.isLink, isTrue);
      expect(data.linkUrl, href);
      handle.dispose();
    });

    testWidgets('shows the focus ring for keyboard focus and scales when '
        'pressed', (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpHero(
        tester,
        _sized(
          HeroCard(
            onPressed: () {},
            focusNode: focusNode,
            title: const Text('Card'),
          ),
        ),
      );
      expect(
        tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
        isFalse,
      );
      focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(
        tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
        isTrue,
      );

      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(HeroCard)),
      );
      await tester.pump();
      expect(
        tester.widget<HeroPressScale>(find.byType(HeroPressScale)).pressed,
        isTrue,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        tester.widget<HeroPressScale>(find.byType(HeroPressScale)).pressed,
        isFalse,
      );
    });

    testWidgets('a disabled card ignores presses and fades', (
      WidgetTester tester,
    ) async {
      int presses = 0;
      final HeroThemeData theme = HeroThemeData.light();
      await pumpHero(
        tester,
        _sized(
          HeroCard(
            onPressed: () => presses++,
            isDisabled: true,
            title: const Text('Card'),
          ),
        ),
      );
      await tester.tap(find.byType(HeroCard), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(presses, 0);
      expect(
        tester
            .widget<Opacity>(
              find.descendant(
                of: find.byType(HeroDisabledOpacity),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        theme.disabledOpacity,
      );
      expect(
        Focus.of(tester.element(find.text('Card'))).canRequestFocus,
        isFalse,
      );
    });

    testWidgets('a static card is not focusable or a button', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(tester, _sized(const HeroCard(title: Text('Static'))));
      expect(find.byType(HeroInteractable), findsNothing);
      expect(const HeroCard().isInteractive, isFalse);
      final SemanticsData data = tester
          .getSemantics(find.text('Static'))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isFalse);
      handle.dispose();
    });
  });

  testWidgets('mirrors in right-to-left layouts', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _sized(
        const HeroCard(
          direction: Axis.horizontal,
          overlays: <Widget>[
            PositionedDirectional(
              top: 12,
              end: 12,
              child: SizedBox(key: Key('close'), width: 20, height: 20),
            ),
          ],
          children: <Widget>[
            SizedBox(key: Key('image'), width: 40, height: 40),
            HeroCardHeader(children: <Widget>[HeroCardTitle.text('Title')]),
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    final Rect card = tester.getRect(find.byType(HeroCard));
    final Rect image = tester.getRect(find.byKey(const Key('image')));
    expect(image.right, card.right - 16);
    expect(tester.getRect(find.text('Title')).right, image.left - 12);
    expect(tester.getRect(find.byKey(const Key('close'))).left, card.left + 12);
  });

  testWidgets('wraps at 2x text without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _sized(
        HeroCard(
          children: <Widget>[
            const HeroCardHeader(
              children: <Widget>[
                HeroCardTitle.text('Become an Acme Creator!'),
                HeroCardDescription.text(
                  'Visit the Acme Creator Hub to sign up today and start '
                  'earning credits from your fans and followers.',
                ),
              ],
            ),
            const HeroCardContent(
              children: <Widget>[Text('Use for primary or featured content')],
            ),
            HeroCardFooter(
              children: <Widget>[
                HeroLink(
                  onPressed: () {},
                  children: const <Widget>[Text('Creator Hub'), HeroLinkIcon()],
                ),
              ],
            ),
          ],
        ),
        width: 280,
      ),
      textScale: 2,
      surfaceSize: const Size(400, 1400),
    );
    expect(tester.takeException(), isNull);
  });

  test('variants map onto surfaces', () {
    expect(HeroCardVariant.transparent.surfaceVariant, isNull);
    expect(
      HeroCardVariant.standard.surfaceVariant,
      HeroSurfaceVariant.standard,
    );
    expect(
      HeroCardVariant.secondary.surfaceVariant,
      HeroSurfaceVariant.secondary,
    );
    expect(
      HeroCardVariant.tertiary.surfaceVariant,
      HeroSurfaceVariant.tertiary,
    );
    expect(HeroCard.radiusOf(HeroThemeData.light()), 24);
  });
}
