import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const Size _phone = Size(390, 700);
const Size _desktop = Size(1000, 700);

Finder get _dialog => find.byType(HeroAlertDialogDialog);

Widget _parts({HeroColor status = HeroColor.danger}) => HeroAlertDialogDialog(
  children: <Widget>[
    const HeroAlertDialogCloseTrigger(),
    HeroAlertDialogHeader(
      children: <Widget>[
        HeroAlertDialogIcon(status: status),
        const HeroAlertDialogHeading(child: Text('Delete project?')),
      ],
    ),
    const HeroAlertDialogBody(child: Text('This cannot be undone.')),
    const HeroAlertDialogFooter(
      children: <Widget>[
        HeroButton(
          slot: HeroButtonSlot.close,
          variant: HeroButtonVariant.tertiary,
          child: Text('Cancel'),
        ),
        HeroButton(
          slot: HeroButtonSlot.close,
          variant: HeroButtonVariant.danger,
          child: Text('Delete'),
        ),
      ],
    ),
  ],
);

Widget _alert({
  bool? isDismissable,
  bool? isKeyboardDismissDisabled,
  HeroAlertDialogSize size = HeroAlertDialogSize.md,
  HeroModalPlacement placement = HeroModalPlacement.auto,
  Widget? dialog,
}) {
  return HeroAlertDialog(
    trigger: const HeroButton(child: Text('Open')),
    child: isDismissable == null && isKeyboardDismissDisabled == null
        ? HeroAlertDialogBackdrop(
            child: HeroAlertDialogContainer(
              size: size,
              placement: placement,
              child: dialog ?? _parts(),
            ),
          )
        : HeroAlertDialogBackdrop(
            isDismissable: isDismissable ?? false,
            isKeyboardDismissDisabled: isKeyboardDismissDisabled ?? true,
            child: HeroAlertDialogContainer(
              size: size,
              placement: placement,
              child: dialog ?? _parts(),
            ),
          ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('requires an explicit action by default', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _alert(), surfaceSize: _phone);
    await _open(tester);
    expect(_dialog, findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
  });

  testWidgets('backdrop and Escape dismissal can be enabled', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _alert(isDismissable: true, isKeyboardDismissDisabled: false),
      surfaceSize: _phone,
    );
    await _open(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
    await _open(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
  });

  testWidgets('the close trigger closes the dialog', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _alert(), surfaceSize: _phone);
    await _open(tester);
    await tester.tap(find.byType(HeroCloseButton));
    await tester.pumpAndSettle();
    expect(_dialog, findsNothing);
  });

  testWidgets('status icons pick colors and glyphs', (
    WidgetTester tester,
  ) async {
    final HeroColors colors = HeroThemeData.light().colors;
    final Map<HeroColor, (Color, Color, HeroIconData)> expected =
        <HeroColor, (Color, Color, HeroIconData)>{
          HeroColor.standard: (
            colors.defaultColor,
            colors.foreground,
            HeroIcons.info,
          ),
          HeroColor.accent: (
            colors.accentSoft,
            colors.accentSoftForeground,
            HeroIcons.info,
          ),
          HeroColor.success: (
            colors.successSoft,
            colors.successSoftForeground,
            HeroIcons.success,
          ),
          HeroColor.warning: (
            colors.warningSoft,
            colors.warningSoftForeground,
            HeroIcons.warning,
          ),
          HeroColor.danger: (
            colors.dangerSoft,
            colors.dangerSoftForeground,
            HeroIcons.danger,
          ),
        };
    for (final MapEntry<HeroColor, (Color, Color, HeroIconData)> entry
        in expected.entries) {
      await pumpHero(tester, HeroAlertDialogIcon(status: entry.key));
      final ShapeDecoration fill =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byType(HeroAlertDialogIcon),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as ShapeDecoration;
      expect(fill.color, entry.value.$1, reason: '${entry.key}');
      final HeroIcon icon = tester.widget(find.byType(HeroIcon));
      expect(icon.icon, entry.value.$3);
      expect(
        IconTheme.of(tester.element(find.byType(HeroIcon))).color,
        entry.value.$2,
      );
      expect(tester.getSize(find.byType(HeroIcon)), const Size.square(20));
      expect(
        tester.getSize(find.byType(HeroAlertDialogIcon)),
        const Size.square(40),
      );
    }
    expect(const HeroAlertDialogIcon().status, HeroColor.danger);

    await pumpHero(
      tester,
      const HeroAlertDialogIcon(
        status: HeroColor.warning,
        child: HeroIcon(HeroIcons.lockOpen),
      ),
    );
    expect(
      tester.widget<HeroIcon>(find.byType(HeroIcon)).icon,
      HeroIcons.lockOpen,
    );
  });

  testWidgets('announces an alert dialog', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(tester, _alert(), surfaceSize: _phone);
    await _open(tester);
    final SemanticsNode node = tester.getSemantics(
      find.descendant(of: _dialog, matching: find.byType(Semantics)).first,
    );
    expect(node.role, SemanticsRole.alertDialog);
    expect(node.flagsCollection.scopesRoute, isTrue);
    expect(
      tester
          .getSemantics(find.text('Delete project?'))
          .flagsCollection
          .namesRoute,
      isTrue,
    );
    handle.dispose();
  });

  testWidgets('sizes and placements follow the modal', (
    WidgetTester tester,
  ) async {
    const Map<HeroAlertDialogSize, double> widths =
        <HeroAlertDialogSize, double>{
          HeroAlertDialogSize.xs: 320,
          HeroAlertDialogSize.sm: 384,
          HeroAlertDialogSize.md: 448,
          HeroAlertDialogSize.lg: 512,
          HeroAlertDialogSize.cover: 1000 - 80,
        };
    for (final MapEntry<HeroAlertDialogSize, double> entry in widths.entries) {
      await pumpHero(tester, _alert(size: entry.key), surfaceSize: _desktop);
      await _open(tester);
      expect(tester.getSize(_dialog).width, entry.value);
      if (entry.key == HeroAlertDialogSize.cover) {
        expect(tester.getSize(_dialog).height, 700 - 80);
      } else {
        expect(tester.getCenter(_dialog).dy, closeTo(350, 0.5));
      }
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }

    await pumpHero(tester, _alert(), surfaceSize: _phone);
    await _open(tester);
    expect(tester.getRect(_dialog).bottom, _phone.height - 16);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await pumpHero(
      tester,
      _alert(placement: HeroModalPlacement.top),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(tester.getRect(_dialog).top, 16);
  });

  testWidgets('the body scrolls when the message is too long', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      _alert(
        dialog: HeroAlertDialogDialog(
          children: <Widget>[
            const HeroAlertDialogHeader(
              children: <Widget>[HeroAlertDialogHeading(child: Text('Terms'))],
            ),
            HeroAlertDialogBody(
              children: <Widget>[for (int i = 0; i < 40; i++) Text('Line $i')],
            ),
            const HeroAlertDialogFooter(
              children: <Widget>[
                HeroButton(slot: HeroButtonSlot.close, child: Text('Accept')),
              ],
            ),
          ],
        ),
      ),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(tester.getRect(_dialog).top, 16);
    expect(find.text('Accept').hitTestable(), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(HeroAlertDialogBody),
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );
  });

  testWidgets('controlled backdrop and HeroAlertDialog.show', (
    WidgetTester tester,
  ) async {
    bool open = false;
    late BuildContext page;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          page = context;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              HeroButton(
                onPressed: () => setState(() => open = true),
                child: const Text('Open'),
              ),
              HeroAlertDialogBackdrop(
                isOpen: open,
                onOpenChanged: (bool value) => setState(() => open = value),
                child: HeroAlertDialogContainer(child: _parts()),
              ),
            ],
          );
        },
      ),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(open, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(open, isTrue);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(open, isFalse);
    expect(_dialog, findsNothing);

    final Future<bool?> result = HeroAlertDialog.show<bool>(
      page,
      builder: (BuildContext context, VoidCallback close) =>
          HeroAlertDialogDialog(
            children: <Widget>[
              HeroAlertDialogFooter(
                children: <Widget>[
                  Builder(
                    builder: (BuildContext context) => HeroButton(
                      onPressed: () => HeroModal.close(context, true),
                      child: const Text('Yes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Yes'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('HeroAlertDialogTrigger opens the dialog', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroAlertDialog(
        trigger: const HeroAlertDialogTrigger(child: Text('Delete Item')),
        child: HeroAlertDialogBackdrop(
          child: HeroAlertDialogContainer(child: _parts()),
        ),
      ),
      surfaceSize: _phone,
    );
    await tester.tap(find.text('Delete Item'));
    await tester.pumpAndSettle();
    expect(_dialog, findsOneWidget);
  });

  testWidgets('RTL and text scale 2', (WidgetTester tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpHero(
      tester,
      _alert(),
      surfaceSize: _phone,
      textDirection: TextDirection.rtl,
    );
    await _open(tester);
    expect(tester.takeException(), isNull);
    final Rect dialog = tester.getRect(_dialog);
    expect(
      tester.getTopLeft(find.byType(HeroCloseButton)).dx,
      dialog.left + 16,
    );
    expect(
      tester.getTopRight(find.byType(HeroAlertDialogIcon)).dx,
      dialog.right - 24,
    );
  });

  testWidgets('actions stack when they do not fit on one line', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpHero(
      tester,
      _alert(
        dialog: const HeroAlertDialogDialog(
          children: <Widget>[
            HeroAlertDialogFooter(
              children: <Widget>[
                HeroButton(
                  slot: HeroButtonSlot.close,
                  variant: HeroButtonVariant.tertiary,
                  child: Text('Stay Signed In'),
                ),
                HeroButton(
                  slot: HeroButtonSlot.close,
                  child: Text('Sign Out Everywhere'),
                ),
              ],
            ),
          ],
        ),
      ),
      surfaceSize: _phone,
    );
    await _open(tester);
    expect(tester.takeException(), isNull);
    final Rect first = tester.getRect(find.byType(HeroButton).at(1));
    final Rect second = tester.getRect(find.byType(HeroButton).at(2));
    expect(second.top, greaterThanOrEqualTo(first.bottom + 8));
    expect(second.right, closeTo(first.right, 0.5));
  });
}
