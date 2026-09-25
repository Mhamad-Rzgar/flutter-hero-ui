import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const Size _phone = Size(390, 700);
const Size _desktop = Size(1000, 700);

Finder get _dialog => find.byType(HeroModalDialog);

Widget _dialogContent({String heading = 'Welcome', List<Widget>? footer}) =>
    HeroModalDialog(
      children: <Widget>[
        const HeroModalCloseTrigger(),
        HeroModalHeader(
          children: <Widget>[HeroModalHeading(child: Text(heading))],
        ),
        const HeroModalBody(child: Text('Body text')),
        HeroModalFooter(
          children:
              footer ??
              const <Widget>[
                HeroButton(
                  slot: HeroButtonSlot.close,
                  variant: HeroButtonVariant.secondary,
                  child: Text('Cancel'),
                ),
                HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
              ],
        ),
      ],
    );

Widget _modal({
  HeroModalPlacement placement = HeroModalPlacement.auto,
  HeroModalScroll scroll = HeroModalScroll.inside,
  HeroModalSize size = HeroModalSize.md,
  HeroBackdropVariant variant = HeroBackdropVariant.opaque,
  bool isDismissable = true,
  bool isKeyboardDismissDisabled = false,
  bool? isOpen,
  ValueChanged<bool>? onOpenChanged,
  HeroOverlayController? controller,
  Widget? dialog,
}) {
  return HeroModal(
    isOpen: isOpen,
    onOpenChanged: onOpenChanged,
    controller: controller,
    trigger: const HeroButton(child: Text('Open')),
    child: HeroModalBackdrop(
      variant: variant,
      isDismissable: isDismissable,
      isKeyboardDismissDisabled: isKeyboardDismissDisabled,
      child: HeroModalContainer(
        placement: placement,
        scroll: scroll,
        size: size,
        child: dialog ?? _dialogContent(),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pressing the trigger opens the dialog with its parts', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    expect(_dialog, findsNothing);
    await _open(tester);
    expect(_dialog, findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Body text'), findsOneWidget);
    expect(find.byType(HeroCloseButton), findsOneWidget);
    // md: min(390 - 2 * 16, 448).
    expect(tester.getSize(_dialog).width, 358);
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
    final HeroThemeData theme = HeroThemeData.light();
    expect(surface.color, theme.colors.overlay);
    expect(
      (surface.shape as RoundedSuperellipseBorder).borderRadius,
      BorderRadius.circular(24),
    );
  });

  testWidgets('auto placement is a bottom sheet below 640 and centered above', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    await _open(tester);
    expect(tester.getBottomLeft(_dialog).dy, _phone.height - 16);
    expect(tester.getTopLeft(_dialog).dx, 16);

    await pumpHero(tester, _modal(), surfaceSize: _desktop);
    await _open(tester);
    final Rect rect = tester.getRect(_dialog);
    expect(rect.center.dy, closeTo(_desktop.height / 2, 0.5));
    expect(rect.width, 448);
    expect(rect.center.dx, _desktop.width / 2);
  });

  testWidgets('top, center and bottom placements', (WidgetTester tester) async {
    for (final HeroModalPlacement placement in <HeroModalPlacement>[
      HeroModalPlacement.top,
      HeroModalPlacement.center,
      HeroModalPlacement.bottom,
    ]) {
      await pumpHero(tester, _modal(placement: placement), surfaceSize: _phone);
      await _open(tester);
      final Rect rect = tester.getRect(_dialog);
      switch (placement) {
        case HeroModalPlacement.top:
          expect(rect.top, 16);
        case HeroModalPlacement.center:
          expect(rect.center.dy, closeTo(_phone.height / 2, 0.5));
        case HeroModalPlacement.bottom:
        case HeroModalPlacement.auto:
          expect(rect.bottom, _phone.height - 16);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('sizes cap the width; cover and full fill the container', (
    WidgetTester tester,
  ) async {
    const Map<HeroModalSize, double> widths = <HeroModalSize, double>{
      HeroModalSize.xs: 320,
      HeroModalSize.sm: 384,
      HeroModalSize.md: 448,
      HeroModalSize.lg: 512,
      HeroModalSize.cover: 1000 - 80,
      HeroModalSize.full: 1000,
    };
    for (final MapEntry<HeroModalSize, double> entry in widths.entries) {
      await pumpHero(tester, _modal(size: entry.key), surfaceSize: _desktop);
      await _open(tester);
      final Size size = tester.getSize(_dialog);
      expect(size.width, entry.value, reason: '${entry.key}');
      if (entry.key == HeroModalSize.cover) expect(size.height, 700 - 80);
      if (entry.key == HeroModalSize.full) expect(size.height, 700);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Escape closes unless keyboard dismissal is disabled', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);

    await pumpHero(
      tester,
      _modal(isKeyboardDismissDisabled: true),
      surfaceSize: _phone,
    );
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);
  });

  testWidgets('pressing the backdrop closes unless not dismissable', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    await _open(tester);
    // Pressing the dialog itself keeps it open.
    await tester.tapAt(tester.getCenter(find.text('Body text')));
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);

    await pumpHero(tester, _modal(isDismissable: false), surfaceSize: _phone);
    await _open(tester);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);
    // The system back action follows the keyboard setting.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
  });

  testWidgets('close trigger, slot=close buttons and builder close', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      _modal(
        dialog: _dialogContent(
          footer: <Widget>[
            HeroButton(
              slot: HeroButtonSlot.close,
              onPressed: () => presses++,
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
      surfaceSize: _phone,
    );
    await _open(tester);
    await tester.tap(find.byType(HeroCloseButton));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);

    await _open(tester);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(presses, 1);
    expect(_dialog, findsNothing);

    await pumpHero(
      tester,
      _modal(
        dialog: HeroModalDialog(
          builder: (BuildContext context, VoidCallback close) => <Widget>[
            HeroModalFooter(
              children: <Widget>[
                HeroButton(onPressed: close, child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
      surfaceSize: _phone,
    );
    await _open(tester);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
  });

  testWidgets('controlled: dismissal asks the owner, isOpen closes', (
    WidgetTester tester,
  ) async {
    bool open = false;
    final List<bool> changes = <bool>[];
    late StateSetter setOuter;
    bool obey = true;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          setOuter = setState;
          return _modal(
            isOpen: open,
            onOpenChanged: (bool value) {
              changes.add(value);
              if (obey) setState(() => open = value);
            },
          );
        },
      ),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(changes, <bool>[true]);
    expect(_dialog, findsOneWidget);

    obey = false;
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(changes, <bool>[true, false]);
    // The owner did not accept the change: still open.
    expect(_dialog, findsOneWidget);

    setOuter(() => open = false);
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);

    setOuter(() => open = true);
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);
  });

  testWidgets('HeroOverlayController opens, toggles and closes', (
    WidgetTester tester,
  ) async {
    final List<bool> changes = <bool>[];
    final HeroOverlayController controller = HeroOverlayController(
      onOpenChanged: changes.add,
    );
    addTearDown(controller.dispose);
    await pumpHero(tester, _modal(controller: controller), surfaceSize: _phone);
    controller.open();
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);
    controller.toggle();
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
    await _open(tester);
    expect(controller.isOpen, isTrue);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    expect(_dialog, findsNothing);
    expect(changes, <bool>[true, false, true, false]);
  });

  testWidgets('a backdrop placed in the page acts as a controlled root', (
    WidgetTester tester,
  ) async {
    bool open = false;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroButton(
              onPressed: () => setState(() => open = true),
              child: const Text('Open'),
            ),
            Text(open ? 'open' : 'closed'),
            HeroModalBackdrop(
              isOpen: open,
              onOpenChanged: (bool value) => setState(() => open = value),
              child: HeroModalContainer(child: _dialogContent()),
            ),
          ],
        ),
      ),
      surfaceSize: _phone,
    );
    expect(find.text('closed'), findsOneWidget);
    await _open(tester);
    expect(find.text('open'), findsOneWidget);
    expect(_dialog, findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('closed'), findsOneWidget);
    expect(_dialog, findsNothing);
  });

  testWidgets('HeroModal.show completes with the close result', (
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
    final Future<String?> result = HeroModal.show<String>(
      page,
      size: HeroModalSize.xs,
      builder: (BuildContext context, VoidCallback close) => HeroModalDialog(
        children: <Widget>[
          HeroModalFooter(
            children: <Widget>[
              Builder(
                builder: (BuildContext context) => HeroButton(
                  onPressed: () => HeroModal.close(context, 'saved'),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(_dialog).width, 320);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(await result, 'saved');

    final Future<String?> dismissed = HeroModal.show<String>(
      page,
      builder: (BuildContext context, VoidCallback close) =>
          const HeroModalDialog(children: <Widget>[HeroModalCloseTrigger()]),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(await dismissed, isNull);
  });

  testWidgets('focus is trapped in the dialog and restored to the trigger', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final FocusNode trigger = FocusManager.instance.primaryFocus!;
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);

    final Set<FocusNode> visited = <FocusNode>{};
    for (int i = 0; i < 6; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final FocusNode focused = FocusManager.instance.primaryFocus!;
      expect(
        find.descendant(
          of: _dialog,
          matching: find.byWidget(focused.context!.widget),
        ),
        findsOneWidget,
      );
      visited.add(focused);
    }
    // Close trigger, Cancel and Confirm, cycling.
    expect(visited, hasLength(3));

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, trigger);
  });

  testWidgets('announces a dialog named by its heading', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    expect(
      tester.getSemantics(find.byType(HeroButton)),
      matchesSemantics(
        label: 'Open',
        isButton: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasExpandedState: true,
      ),
    );
    await _open(tester);
    final SemanticsNode dialog = tester.getSemantics(
      find.descendant(of: _dialog, matching: find.byType(Semantics)).first,
    );
    expect(dialog.role, SemanticsRole.dialog);
    expect(dialog.flagsCollection.scopesRoute, isTrue);
    final SemanticsNode heading = tester.getSemantics(find.text('Welcome'));
    expect(heading.flagsCollection.namesRoute, isTrue);
    expect(heading.flagsCollection.isHeader, isTrue);
    handle.dispose();
  });

  testWidgets('RTL puts the close trigger at the top left', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _modal(),
      surfaceSize: _phone,
      textDirection: TextDirection.rtl,
    );
    await _open(tester);
    final Rect dialog = tester.getRect(_dialog);
    final Rect close = tester.getRect(find.byType(HeroCloseButton));
    expect(close.left - dialog.left, 16);
    expect(close.top - dialog.top, 16);
    // Footer actions are end-aligned: on the left in RTL.
    expect(
      tester.getTopLeft(find.text('Confirm')).dx,
      lessThan(tester.getTopLeft(find.text('Cancel')).dx),
    );
  });

  testWidgets('scroll inside keeps the dialog on screen and scrolls the body', (
    WidgetTester tester,
  ) async {
    final Widget long = HeroModalDialog(
      children: <Widget>[
        const HeroModalHeader(
          children: <Widget>[HeroModalHeading(child: Text('Long'))],
        ),
        HeroModalBody(
          children: <Widget>[for (int i = 0; i < 30; i++) Text('Paragraph $i')],
        ),
        const HeroModalFooter(
          children: <Widget>[
            HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
          ],
        ),
      ],
    );
    await pumpHero(tester, _modal(dialog: long), surfaceSize: _phone);
    await _open(tester);
    final Rect rect = tester.getRect(_dialog);
    expect(rect.top, 16);
    expect(rect.bottom, _phone.height - 16);
    expect(find.text('Confirm').hitTestable(), findsOneWidget);
    await tester.drag(find.text('Paragraph 3'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Long')).dy, rect.top + 24);

    await pumpHero(
      tester,
      _modal(dialog: long, scroll: HeroModalScroll.outside),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(tester.getSize(_dialog).height, greaterThan(_phone.height));
    await tester.drag(find.text('Paragraph 3'), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(find.text('Confirm').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
  });

  testWidgets('the visual viewport ends at the keyboard', (
    WidgetTester tester,
  ) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    await _open(tester);
    expect(tester.getRect(_dialog).bottom, _phone.height - 300 - 16);
  });

  testWidgets('backdrop variants paint the backdrop token and blur', (
    WidgetTester tester,
  ) async {
    final HeroThemeData theme = HeroThemeData.light();
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    await _open(tester);
    BoxDecoration fill() =>
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(HeroModalBackdropLayer),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(fill().color, theme.colors.backdrop);
    expect(find.byType(BackdropFilter), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await pumpHero(
      tester,
      _modal(variant: HeroBackdropVariant.blur),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(fill().color, theme.colors.backdrop);
    expect(
      find.descendant(
        of: find.byType(HeroModalBackdropLayer),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    await pumpHero(
      tester,
      _modal(variant: HeroBackdropVariant.transparent),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(
      find.descendant(
        of: find.byType(HeroModalBackdropLayer),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
    // Still blocks and dismisses.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
  });

  testWidgets('enter and exit motion follow the CSS timings', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _modal(), surfaceSize: _phone);
    await tester.tap(find.text('Open'));
    await tester.pump();
    double backdrop() => tester
        .widget<Opacity>(
          find
              .descendant(
                of: find.byType(HeroModalBackdropLayer),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;
    double container() => tester
        .widget<Opacity>(
          find.ancestor(of: _dialog, matching: find.byType(Opacity)).first,
        )
        .opacity;
    await tester.pump(const Duration(milliseconds: 150));
    // The backdrop is in after 150 ms, the container after 250 ms.
    expect(backdrop(), 1);
    expect(container(), lessThan(1));
    final double scale = tester
        .widget<Transform>(
          find.ancestor(of: _dialog, matching: find.byType(Transform)).first,
        )
        .transform
        .getMaxScaleOnAxis();
    expect(scale, greaterThan(1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(container(), 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(container(), inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 60));
    expect(_dialog, findsNothing);
  });

  testWidgets('reduced motion opens and closes without animating', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _modal(),
      ),
      surfaceSize: _phone,
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump();
    expect(_dialog, findsOneWidget);
  });

  testWidgets('renders inside a HeroOverlayHost', (WidgetTester tester) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        height: 380,
        child: HeroOverlayHost(
          child: Center(
            child: HeroModal(
              useRootNavigator: false,
              trigger: const HeroButton(child: Text('Open')),
              child: HeroModalBackdrop(
                child: HeroModalContainer(child: _dialogContent()),
              ),
            ),
          ),
        ),
      ),
      surfaceSize: _phone,
    );
    await _open(tester);
    final Rect host = tester.getRect(find.byType(HeroOverlayHost));
    final Rect dialog = tester.getRect(_dialog);
    expect(dialog.width, 300 - 32);
    expect(dialog.bottom, host.bottom - 16);
  });

  testWidgets('text scale 2 does not overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _modal(),
      ),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Confirm').hitTestable(), findsOneWidget);
  });

  testWidgets('HeroModalTrigger opens the modal and shows press feedback', (
    WidgetTester tester,
  ) async {
    int presses = 0;
    await pumpHero(
      tester,
      HeroModal(
        trigger: HeroModalTrigger(
          onPressed: () => presses++,
          child: const Text('Settings'),
        ),
        child: HeroModalBackdrop(
          child: HeroModalContainer(child: _dialogContent()),
        ),
      ),
      surfaceSize: _phone,
    );
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.text('Settings')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byType(HeroModalTrigger),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale,
      0.97,
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(presses, 1);
    expect(_dialog, findsOneWidget);
  });

  testWidgets('dark overlays paint the inner highlight', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _modal(),
      surfaceSize: _phone,
      theme: HeroThemeData.dark(),
    );
    await _open(tester);
    expect(
      find.descendant(
        of: find.byType(HeroOverlaySurface),
        matching: find.byType(CustomPaint),
      ),
      findsWidgets,
    );
  });
}
