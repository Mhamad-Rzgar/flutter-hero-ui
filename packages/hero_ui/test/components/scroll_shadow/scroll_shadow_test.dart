import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// A column of 20 fixed-height rows: 1000 px of content.
Widget _rows({Axis axis = Axis.vertical}) {
  final List<Widget> rows = <Widget>[
    for (int i = 0; i < 20; i++)
      SizedBox(
        width: axis == Axis.vertical ? 200 : 50,
        height: axis == Axis.vertical ? 50 : 40,
        child: Text('Row $i'),
      ),
  ];
  return axis == Axis.vertical
      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows)
      : Row(children: rows);
}

/// The fade mask layers currently painted.
List<ShaderMaskLayer> _masks(WidgetTester tester) {
  final List<ShaderMaskLayer> masks = <ShaderMaskLayer>[];
  void visit(Layer layer) {
    if (layer is ShaderMaskLayer) masks.add(layer);
    if (layer is ContainerLayer) {
      Layer? child = layer.firstChild;
      while (child != null) {
        visit(child);
        child = child.nextSibling;
      }
    }
  }

  visit(tester.layers.first);
  return masks;
}

ScrollPosition _position(WidgetTester tester) => tester
    .state<ScrollableState>(
      find.descendant(
        of: find.byType(HeroScrollShadow),
        matching: find.byType(Scrollable),
      ),
    )
    .position;

void main() {
  group('fade math', () {
    ScrollMetrics metrics(double pixels, {double max = 800}) =>
        FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: max,
          pixels: pixels,
          viewportDimension: 200,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1,
        );

    test('fades grow and shrink over the first and last size pixels', () {
      expect(HeroScrollShadow.fadesOf(metrics(0), size: 40), (
        start: 0.0,
        end: 40.0,
      ));
      expect(HeroScrollShadow.fadesOf(metrics(10), size: 40), (
        start: 10.0,
        end: 40.0,
      ));
      expect(HeroScrollShadow.fadesOf(metrics(400), size: 40), (
        start: 40.0,
        end: 40.0,
      ));
      expect(HeroScrollShadow.fadesOf(metrics(785), size: 40), (
        start: 40.0,
        end: 15.0,
      ));
      expect(HeroScrollShadow.fadesOf(metrics(800), size: 40), (
        start: 40.0,
        end: 0.0,
      ));
      // Overscroll clamps.
      expect(HeroScrollShadow.fadesOf(metrics(-30), size: 40), (
        start: 0.0,
        end: 40.0,
      ));
    });

    test('the offset delays both fades', () {
      expect(HeroScrollShadow.fadesOf(metrics(30), size: 40, offset: 20), (
        start: 10.0,
        end: 40.0,
      ));
      expect(HeroScrollShadow.fadesOf(metrics(770), size: 40, offset: 20), (
        start: 40.0,
        end: 10.0,
      ));
    });

    test('content that fits has no fade', () {
      expect(HeroScrollShadow.fadesOf(metrics(0, max: 0), size: 40), (
        start: 0.0,
        end: 0.0,
      ));
    });

    test('visibility follows HeroUI thresholds', () {
      expect(
        HeroScrollShadow.visibilityOf(metrics(0)),
        HeroScrollShadowVisibility.bottom,
      );
      expect(
        HeroScrollShadow.visibilityOf(metrics(1)),
        HeroScrollShadowVisibility.both,
      );
      expect(
        HeroScrollShadow.visibilityOf(metrics(799.5)),
        HeroScrollShadowVisibility.top,
      );
      expect(
        HeroScrollShadow.visibilityOf(metrics(0, max: 0)),
        HeroScrollShadowVisibility.none,
      );
      expect(
        HeroScrollShadow.visibilityOf(metrics(10), offset: 10),
        HeroScrollShadowVisibility.bottom,
      );
      final ScrollMetrics horizontal = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 100,
        pixels: 100,
        viewportDimension: 200,
        axisDirection: AxisDirection.right,
        devicePixelRatio: 1,
      );
      expect(
        HeroScrollShadow.visibilityOf(horizontal),
        HeroScrollShadowVisibility.left,
      );
    });
  });

  testWidgets('scrolls its child inside the constraints with padding', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        child: HeroScrollShadow(
          constraints: const BoxConstraints(maxHeight: 240),
          padding: const EdgeInsets.all(16),
          child: _rows(),
        ),
      ),
    );
    final Rect box = tester.getRect(find.byType(HeroScrollShadow));
    expect(box.height, 240);
    expect(
      tester.getTopLeft(find.text('Row 0')),
      box.topLeft + const Offset(16, 16),
    );
    final SingleChildScrollView view = tester.widget(
      find.byType(SingleChildScrollView),
    );
    expect(view.physics, isA<BouncingScrollPhysics>());
    expect(_position(tester).maxScrollExtent, 1000 + 32 - 240);
  });

  testWidgets('masks all but the scrollbar gutter while content overflows', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(child: _rows()),
      ),
    );
    final Rect box = tester.getRect(find.byType(HeroScrollShadow));
    List<ShaderMaskLayer> masks = _masks(tester);
    expect(masks, hasLength(1));
    expect(masks.single.blendMode, BlendMode.dstIn);
    expect(
      masks.single.maskRect,
      Rect.fromLTWH(box.left, box.top, 300 - 10, 200),
    );

    // Hiding the scrollbar drops the gutter.
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(hideScrollBar: true, child: _rows()),
      ),
    );
    masks = _masks(tester);
    expect(masks.single.maskRect!.width, 300);

    // A custom gutter.
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(scrollbarGutter: 16, child: _rows()),
      ),
    );
    expect(_masks(tester).single.maskRect!.width, 300 - 16);
  });

  testWidgets('the gutter follows the scrollbar in right-to-left layouts', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(child: _rows()),
      ),
      textDirection: TextDirection.rtl,
    );
    final Rect box = tester.getRect(find.byType(HeroScrollShadow));
    expect(
      _masks(tester).single.maskRect,
      Rect.fromLTWH(box.left + 10, box.top, 290, 200),
    );
  });

  testWidgets('horizontal scroll shadows keep a bottom gutter', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        child: HeroScrollShadow(
          orientation: Axis.horizontal,
          child: _rows(axis: Axis.horizontal),
        ),
      ),
    );
    final Rect box = tester.getRect(find.byType(HeroScrollShadow));
    expect(box.size, const Size(300, 40));
    expect(
      _masks(tester).single.maskRect,
      Rect.fromLTWH(box.left, box.top, 300, 30),
    );
  });

  testWidgets('content that fits is not masked', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 300,
        child: HeroScrollShadow(
          constraints: BoxConstraints(maxHeight: 240),
          child: Text('Short'),
        ),
      ),
    );
    expect(_masks(tester), isEmpty);
    expect(tester.getSize(find.byType(HeroScrollShadow)).height, 24);
  });

  testWidgets('controlled visibility shows fixed fades without overflow', (
    WidgetTester tester,
  ) async {
    Future<void> pump(HeroScrollShadowVisibility visibility, {Axis? axis}) =>
        pumpHero(
          tester,
          SizedBox(
            width: 300,
            height: 200,
            child: HeroScrollShadow(
              visibility: visibility,
              orientation: axis ?? Axis.vertical,
              child: const Text('Short'),
            ),
          ),
        );
    for (final HeroScrollShadowVisibility visibility
        in <HeroScrollShadowVisibility>[
          HeroScrollShadowVisibility.both,
          HeroScrollShadowVisibility.top,
          HeroScrollShadowVisibility.bottom,
        ]) {
      await pump(visibility);
      expect(_masks(tester), hasLength(1), reason: '$visibility');
    }
    await pump(HeroScrollShadowVisibility.none);
    expect(_masks(tester), isEmpty);
    // Left and right only apply to horizontal scroll shadows.
    await pump(HeroScrollShadowVisibility.left);
    expect(_masks(tester), isEmpty);
    await pump(HeroScrollShadowVisibility.left, axis: Axis.horizontal);
    expect(_masks(tester), hasLength(1));
    await pump(HeroScrollShadowVisibility.top, axis: Axis.horizontal);
    expect(_masks(tester), isEmpty);
  });

  testWidgets('a disabled scroll shadow does not fade', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(isEnabled: false, child: _rows()),
      ),
    );
    expect(_masks(tester), isEmpty);
  });

  testWidgets('reports visibility changes while scrolling', (
    WidgetTester tester,
  ) async {
    final List<HeroScrollShadowVisibility> reports =
        <HeroScrollShadowVisibility>[];
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(
          controller: controller,
          onVisibilityChanged: reports.add,
          child: _rows(),
        ),
      ),
    );
    expect(reports, <HeroScrollShadowVisibility>[
      HeroScrollShadowVisibility.bottom,
    ]);
    controller.jumpTo(100);
    await tester.pump();
    controller.jumpTo(200);
    await tester.pump();
    expect(reports, <HeroScrollShadowVisibility>[
      HeroScrollShadowVisibility.bottom,
      HeroScrollShadowVisibility.both,
    ]);
    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(reports.last, HeroScrollShadowVisibility.top);
    expect(reports, hasLength(3));

    // Dragging scrolls with the bouncing physics.
    await tester.drag(find.byType(HeroScrollShadow), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(controller.offset, lessThan(800));
    expect(reports.last, HeroScrollShadowVisibility.both);
  });

  testWidgets('reports left and right for horizontal scroll shadows', (
    WidgetTester tester,
  ) async {
    final List<HeroScrollShadowVisibility> reports =
        <HeroScrollShadowVisibility>[];
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        child: HeroScrollShadow(
          orientation: Axis.horizontal,
          onVisibilityChanged: reports.add,
          child: _rows(axis: Axis.horizontal),
        ),
      ),
    );
    _position(tester).jumpTo(_position(tester).maxScrollExtent);
    await tester.pump();
    expect(reports, <HeroScrollShadowVisibility>[
      HeroScrollShadowVisibility.right,
      HeroScrollShadowVisibility.left,
    ]);
  });

  testWidgets('does not report in controlled or disabled mode', (
    WidgetTester tester,
  ) async {
    final List<HeroScrollShadowVisibility> reports =
        <HeroScrollShadowVisibility>[];
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(
          visibility: HeroScrollShadowVisibility.both,
          onVisibilityChanged: reports.add,
          child: _rows(),
        ),
      ),
    );
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(
          isEnabled: false,
          onVisibilityChanged: reports.add,
          child: _rows(),
        ),
      ),
    );
    expect(reports, isEmpty);
  });

  testWidgets('reports when the content grows without scrolling', (
    WidgetTester tester,
  ) async {
    final List<HeroScrollShadowVisibility> reports =
        <HeroScrollShadowVisibility>[];
    Widget build(double height) => SizedBox(
      width: 300,
      height: 200,
      child: HeroScrollShadow(
        onVisibilityChanged: reports.add,
        child: SizedBox(height: height),
      ),
    );
    await pumpHero(tester, build(100));
    expect(_masks(tester), isEmpty);
    await pumpHero(tester, build(600));
    expect(reports, <HeroScrollShadowVisibility>[
      HeroScrollShadowVisibility.none,
      HeroScrollShadowVisibility.bottom,
    ]);
    expect(_masks(tester), hasLength(1));
  });

  testWidgets('builder fades a list view built with its controller', (
    WidgetTester tester,
  ) async {
    final List<HeroScrollShadowVisibility> reports =
        <HeroScrollShadowVisibility>[];
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow.builder(
          onVisibilityChanged: reports.add,
          builder: (BuildContext context, ScrollController controller) =>
              ListView.builder(
                controller: controller,
                itemCount: 50,
                itemExtent: 40,
                itemBuilder: (BuildContext context, int index) =>
                    Text('Item $index'),
              ),
        ),
      ),
    );
    expect(reports, <HeroScrollShadowVisibility>[
      HeroScrollShadowVisibility.bottom,
    ]);
    expect(_masks(tester), hasLength(1));
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(reports.last, HeroScrollShadowVisibility.both);
  });

  testWidgets('can be focused to scroll with the keyboard', (
    WidgetTester tester,
  ) async {
    final FocusNode focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(focusNode: focusNode, child: _rows()),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);
    expect(
      tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();
    expect(_position(tester).pixels, greaterThan(0));
  });

  testWidgets('is not a tab stop when its content is focusable or fits', (
    WidgetTester tester,
  ) async {
    final FocusNode focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(
          focusNode: focusNode,
          child: Column(
            children: <Widget>[
              HeroButton(onPressed: () {}, child: const Text('Action')),
              const SizedBox(height: 800),
            ],
          ),
        ),
      ),
    );
    expect(focusNode.canRequestFocus, isFalse);

    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(
          focusNode: focusNode,
          child: const Text('Short'),
        ),
      ),
    );
    expect(focusNode.canRequestFocus, isFalse);
  });

  testWidgets('paints and clips to a decoration', (WidgetTester tester) async {
    final HeroThemeData theme = HeroThemeData.light();
    final ShapeDecoration decoration = ShapeDecoration(
      color: theme.colors.surface,
      shape: theme.shapeAll(
        12,
        side: BorderSide(color: theme.colors.border, width: 2),
      ),
    );
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 200,
        child: HeroScrollShadow(
          decoration: decoration,
          padding: const EdgeInsets.all(16),
          child: _rows(),
        ),
      ),
    );
    final Rect box = tester.getRect(find.byType(HeroScrollShadow));
    // The border takes room inside.
    expect(
      tester.getTopLeft(find.text('Row 0')),
      box.topLeft + const Offset(18, 18),
    );
    expect(
      find.descendant(
        of: find.byType(HeroScrollShadow),
        matching: find.byType(ClipPath),
      ),
      findsOneWidget,
    );
    // The decoration is painted inside the mask, so it fades with the
    // content.
    expect(
      find.descendant(
        of: find.byType(HeroScrollShadow),
        matching: find.byWidgetPredicate(
          (Widget w) => w is DecoratedBox && w.decoration == decoration,
        ),
      ),
      findsOneWidget,
    );
    expect(_masks(tester), hasLength(1));
  });

  testWidgets('wraps at 2x text without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      const SizedBox(
        width: 240,
        child: HeroScrollShadow(
          constraints: BoxConstraints(maxHeight: 240),
          padding: EdgeInsets.all(16),
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
            'Nullam pulvinar risus non risus hendrerit venenatis.',
          ),
        ),
      ),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(HeroScrollShadow)).height, 240);
  });

  testWidgets('updates when the controller is replaced', (
    WidgetTester tester,
  ) async {
    final ScrollController first = ScrollController();
    final ScrollController second = ScrollController();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    Widget build(ScrollController? controller) => SizedBox(
      width: 300,
      height: 200,
      child: HeroScrollShadow(controller: controller, child: _rows()),
    );
    await pumpHero(tester, build(first));
    expect(first.hasClients, isTrue);
    await pumpHero(tester, build(second));
    expect(first.hasClients, isFalse);
    expect(second.hasClients, isTrue);
    await pumpHero(tester, build(null));
    expect(second.hasClients, isFalse);
    expect(_masks(tester), hasLength(1));
  });
}
