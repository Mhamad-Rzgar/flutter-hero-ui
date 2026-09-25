import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const Size _phone = Size(390, 700);
const Size _tablet = Size(700, 700);

Finder get _panel => find.byType(HeroDrawerDialog);

Widget _drawer({
  HeroDrawerPlacement placement = HeroDrawerPlacement.bottom,
  bool isDismissable = true,
  bool isKeyboardDismissDisabled = false,
  int paragraphs = 1,
  bool? isOpen,
  ValueChanged<bool>? onOpenChanged,
}) {
  return HeroDrawer(
    isOpen: isOpen,
    onOpenChanged: onOpenChanged,
    trigger: const HeroButton(child: Text('Open')),
    child: HeroDrawerBackdrop(
      isDismissable: isDismissable,
      isKeyboardDismissDisabled: isKeyboardDismissDisabled,
      child: HeroDrawerContent(
        placement: placement,
        child: HeroDrawerDialog(
          children: <Widget>[
            const HeroDrawerHandle(),
            const HeroDrawerCloseTrigger(),
            const HeroDrawerHeader(
              children: <Widget>[HeroDrawerHeading(child: Text('Title'))],
            ),
            HeroDrawerBody(
              children: <Widget>[
                for (int i = 0; i < paragraphs; i++) Text('Paragraph $i'),
              ],
            ),
            const HeroDrawerFooter(
              children: <Widget>[
                HeroButton(slot: HeroButtonSlot.close, child: Text('Done')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('bottom drawer: full width, rounded top corners, 85% max', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _drawer(), surfaceSize: _phone);
    expect(_panel, findsNothing);
    await _open(tester);
    final Rect rect = tester.getRect(_panel);
    expect(rect.left, 0);
    expect(rect.width, _phone.width);
    expect(rect.bottom, _phone.height);
    final ShapeDecoration surface =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(HeroOverlaySurface),
                        matching: find.byType(DecoratedBox),
                      )
                      .at(1),
                )
                .decoration
            as ShapeDecoration;
    expect(
      (surface.shape as RoundedSuperellipseBorder).borderRadius,
      const BorderRadius.vertical(top: Radius.circular(16)),
    );
    // The handle bar.
    expect(
      tester.getSize(
        find.descendant(
          of: find.byType(HeroDrawerHandle),
          matching: find.byType(SizedBox),
        ),
      ),
      const Size(36, 4),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await pumpHero(tester, _drawer(paragraphs: 60), surfaceSize: _phone);
    await _open(tester);
    expect(tester.getSize(_panel).height, closeTo(_phone.height * 0.85, 0.5));
    expect(find.text('Done').hitTestable(), findsOneWidget);
  });

  testWidgets('side drawers are full height, 320 wide, 384 from 640 px', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _drawer(placement: HeroDrawerPlacement.right),
      surfaceSize: _phone,
    );
    await _open(tester);
    Rect rect = tester.getRect(_panel);
    expect(rect.width, 320);
    expect(rect.height, _phone.height);
    expect(rect.right, _phone.width);
    // The footer sits at the bottom (the body grows).
    expect(tester.getBottomLeft(find.text('Done')).dy, greaterThan(600));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await pumpHero(
      tester,
      _drawer(placement: HeroDrawerPlacement.left),
      surfaceSize: _tablet,
    );
    await _open(tester);
    rect = tester.getRect(_panel);
    expect(rect.width, 384);
    expect(rect.left, 0);
  });

  testWidgets('left and right follow the reading direction', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _drawer(placement: HeroDrawerPlacement.left),
      surfaceSize: _phone,
      textDirection: TextDirection.rtl,
    );
    await _open(tester);
    expect(tester.getRect(_panel).right, _phone.width);
    // The close trigger sits at the end (left in RTL).
    expect(
      tester.getTopLeft(find.byType(HeroCloseButton)).dx,
      tester.getTopLeft(_panel).dx + 16,
    );
  });

  testWidgets('top drawer rounds its bottom corners', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _drawer(placement: HeroDrawerPlacement.top),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(tester.getRect(_panel).top, 0);
  });

  testWidgets('slides in from its edge and out again', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _drawer(), surfaceSize: _phone);
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    final double midway = tester.getRect(_panel).top;
    await tester.pumpAndSettle();
    final double open = tester.getRect(_panel).top;
    expect(midway, greaterThan(open));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getRect(_panel).top, greaterThan(open));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_panel, findsNothing);
  });

  testWidgets('dragging past 30% dismisses; a short drag springs back', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _drawer(), surfaceSize: _phone);
    await _open(tester);
    final Rect rect = tester.getRect(_panel);
    double title() => tester.getTopLeft(find.text('Title')).dy;
    final double rest = title();
    final Offset handle = tester.getCenter(find.byType(HeroDrawerHandle));

    // Short, slow drag: springs back.
    final TestGesture short = await tester.startGesture(handle);
    for (int i = 0; i < 5; i++) {
      await short.moveBy(const Offset(0, 4));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(title(), greaterThan(rest + 10));
    await tester.pump(const Duration(milliseconds: 200));
    await short.up();
    await tester.pumpAndSettle();
    expect(title(), rest);
    expect(_panel, findsOneWidget);

    // Upwards drags are clamped.
    final TestGesture up = await tester.startGesture(handle);
    await up.moveBy(const Offset(0, -40));
    await tester.pump();
    expect(title(), rest);
    await up.up();
    await tester.pumpAndSettle();

    // Past 30% of the height: dismissed.
    final TestGesture long = await tester.startGesture(handle);
    for (int i = 0; i < 10; i++) {
      await long.moveBy(Offset(0, rect.height * 0.04));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 200));
    await long.up();
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);
  });

  testWidgets('a fast flick dismisses', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _drawer(placement: HeroDrawerPlacement.right),
      surfaceSize: _phone,
    );
    await _open(tester);
    await tester.flingFrom(
      tester.getCenter(find.text('Title')),
      const Offset(60, 0),
      1500,
    );
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);
  });

  testWidgets('drags inside the body scroll instead of dismissing', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _drawer(paragraphs: 60), surfaceSize: _phone);
    await _open(tester);
    final double top = tester.getTopLeft(find.text('Title')).dy;
    await tester.drag(find.text('Paragraph 5'), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(_panel, findsOneWidget);
    expect(tester.getTopLeft(find.text('Title')).dy, top);
  });

  testWidgets('non-dismissable drawers ignore drags, outside presses', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _drawer(isDismissable: false), surfaceSize: _phone);
    await _open(tester);
    final double top = tester.getTopLeft(find.text('Title')).dy;
    await tester.drag(find.byType(HeroDrawerHandle), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Title')).dy, top);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_panel, findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);
  });

  testWidgets('outside press, Escape and close buttons close it', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _drawer(), surfaceSize: _phone);
    await _open(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);
    await _open(tester);
    await tester.tap(find.byType(HeroCloseButton));
    await tester.pumpAndSettle();
    expect(_panel, findsNothing);

    await pumpHero(
      tester,
      _drawer(isKeyboardDismissDisabled: true),
      surfaceSize: _phone,
    );
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_panel, findsOneWidget);
  });

  testWidgets('controlled drawers snap back when the owner keeps them open', (
    WidgetTester tester,
  ) async {
    final List<bool> changes = <bool>[];
    await pumpHero(
      tester,
      _drawer(isOpen: true, onOpenChanged: changes.add),
      surfaceSize: _phone,
    );
    await tester.pumpAndSettle();
    final double top = tester.getTopLeft(find.text('Title')).dy;
    final TestGesture drag = await tester.startGesture(
      tester.getCenter(find.byType(HeroDrawerHandle)),
    );
    for (int i = 0; i < 10; i++) {
      await drag.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 200));
    await drag.up();
    await tester.pumpAndSettle();
    expect(changes, <bool>[false]);
    expect(tester.getTopLeft(find.text('Title')).dy, top);
  });

  testWidgets('HeroDrawer.show completes with the close result', (
    WidgetTester tester,
  ) async {
    late BuildContext page;
    await pumpHero(
      tester,
      Builder(
        builder: (BuildContext context) {
          page = context;
          return const SizedBox();
        },
      ),
      surfaceSize: _phone,
    );
    final Future<int?> result = HeroDrawer.show<int>(
      page,
      placement: HeroDrawerPlacement.left,
      builder: (BuildContext context, VoidCallback close) => HeroDrawerDialog(
        children: <Widget>[
          HeroDrawerFooter(
            children: <Widget>[
              Builder(
                builder: (BuildContext context) => HeroButton(
                  onPressed: () => HeroModal.close(context, 7),
                  child: const Text('Pick'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(_panel).left, 0);
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    expect(await result, 7);
  });

  testWidgets('announces a dialog and hides the handle', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, _drawer(), surfaceSize: _phone);
    await _open(tester);
    final SemanticsNode node = tester.getSemantics(
      find.descendant(of: _panel, matching: find.byType(Semantics)).first,
    );
    expect(node.role, SemanticsRole.dialog);
    expect(node.flagsCollection.scopesRoute, isTrue);
    expect(
      find.descendant(
        of: find.byType(HeroDrawerHandle),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('keyboard inset lifts bottom drawers; text scale 2', (
    WidgetTester tester,
  ) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpHero(tester, _drawer(), surfaceSize: _phone);
    await _open(tester);
    expect(tester.takeException(), isNull);
    expect(tester.getRect(_panel).bottom, _phone.height - 300);
  });
}
