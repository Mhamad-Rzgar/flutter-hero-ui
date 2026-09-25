import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const Size _surface = Size(600, 500);

HeroPopoverContent _content({
  HeroPlacement placement = HeroPlacement.bottom,
  bool arrow = false,
  bool isNonModal = false,
  double? offset,
  List<Widget> extra = const <Widget>[],
}) => HeroPopoverContent(
  placement: placement,
  isNonModal: isNonModal,
  offset: offset,
  child: HeroPopoverDialog(
    children: <Widget>[
      if (arrow) const HeroPopoverArrow(),
      const HeroPopoverHeading(child: Text('Popover Title')),
      const Text('This is the popover content.'),
      ...extra,
    ],
  ),
);

Rect _panel(WidgetTester tester) => tester.getRect(
  find.ancestor(
    of: find.text('Popover Title'),
    matching: find.byType(HeroOverlaySurface),
  ),
);

void main() {
  testWidgets('pressing the trigger opens it 8 px below; outside press '
      'closes it without reaching the page', (WidgetTester tester) async {
    int pagePresses = 0;
    final List<bool> changes = <bool>[];
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroPopover(
            onOpenChanged: changes.add,
            content: _content(),
            child: const HeroButton(child: Text('Click me')),
          ),
          const SizedBox(height: 200),
          HeroButton(
            onPressed: () => pagePresses++,
            child: const Text('Page button'),
          ),
        ],
      ),
      surfaceSize: _surface,
    );
    expect(find.text('Popover Title'), findsNothing);
    await tester.tap(find.text('Click me'));
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsOneWidget);
    expect(changes, <bool>[true]);

    final Rect trigger = tester.getRect(find.byType(HeroButton).first);
    final Rect panel = _panel(tester);
    expect(panel.top, moreOrLessEquals(trigger.bottom + 8));
    expect(panel.center.dx, moreOrLessEquals(trigger.center.dx));

    await tester.tap(find.text('Page button'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsNothing);
    expect(pagePresses, 0);
    expect(changes, <bool>[true, false]);
  });

  testWidgets('Escape closes it and focus moves in and back', (
    WidgetTester tester,
  ) async {
    final FocusNode trigger = FocusNode();
    addTearDown(trigger.dispose);
    await pumpHero(
      tester,
      HeroPopover(
        content: _content(),
        child: HeroButton(focusNode: trigger, child: const Text('Click me')),
      ),
      surfaceSize: _surface,
    );
    trigger.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsOneWidget);
    expect(trigger.hasFocus, isFalse);
    final FocusNode? focused = FocusManager.instance.primaryFocus;
    expect(focused?.debugLabel, 'HeroPopoverContent');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsNothing);
    expect(trigger.hasFocus, isTrue);
  });

  testWidgets('a descendant that autofocuses keeps focus; Tab stays inside '
      'a modal popover', (WidgetTester tester) async {
    await pumpHero(
      tester,
      HeroPopover(
        content: _content(
          extra: <Widget>[
            const HeroButton(autofocus: true, child: Text('First')),
            const HeroButton(child: Text('Second')),
          ],
        ),
        child: const HeroButton(child: Text('Click me')),
      ),
      surfaceSize: _surface,
    );
    await tester.tap(find.text('Click me'));
    await tester.pumpAndSettle();
    Finder button(String label) =>
        find.ancestor(of: find.text(label), matching: find.byType(HeroButton));
    bool focused(String label) => Focus.of(
      tester.element(
        find.descendant(of: button(label), matching: find.byType(Text)),
      ),
    ).hasPrimaryFocus;
    expect(focused('First'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focused('Second'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(focused('First'), isTrue);
  });

  testWidgets('close slot buttons and the dialog builder close it', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroPopover(
            content: _content(
              extra: <Widget>[
                const HeroButton(
                  slot: HeroButtonSlot.close,
                  child: Text('Done'),
                ),
              ],
            ),
            child: const HeroButton(child: Text('Slot')),
          ),
          HeroPopover(
            content: HeroPopoverContent(
              child: HeroPopoverDialog(
                builder: (BuildContext context, VoidCallback close) =>
                    HeroButton(onPressed: close, child: const Text('Close')),
              ),
            ),
            child: const HeroButton(child: Text('Builder')),
          ),
        ],
      ),
      surfaceSize: _surface,
    );
    await tester.tap(find.text('Slot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsNothing);

    await tester.tap(find.text('Builder'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsNothing);
  });

  testWidgets('controlled with isOpen and with a controller', (
    WidgetTester tester,
  ) async {
    final HeroOverlayController controller = HeroOverlayController();
    addTearDown(controller.dispose);
    bool open = false;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroPopover(
              isOpen: open,
              onOpenChanged: (bool value) => setState(() => open = value),
              content: const HeroPopoverDialog(
                children: <Widget>[Text('Controlled')],
              ),
              child: const HeroButton(child: Text('A')),
            ),
            HeroPopover(
              controller: controller,
              content: const HeroPopoverDialog(
                children: <Widget>[Text('From controller')],
              ),
              child: const HeroButton(child: Text('B')),
            ),
          ],
        ),
      ),
      surfaceSize: _surface,
    );
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(open, isTrue);
    expect(find.text('Controlled'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(open, isFalse);
    expect(find.text('Controlled'), findsNothing);

    controller.open();
    await tester.pumpAndSettle();
    expect(find.text('From controller'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(controller.isOpen, isFalse);
    expect(find.text('From controller'), findsNothing);
  });

  testWidgets('non-modal: the page stays interactive and the trigger '
      'toggles it closed', (WidgetTester tester) async {
    int pagePresses = 0;
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroPopover(
            content: _content(isNonModal: true),
            child: const HeroButton(child: Text('Click me')),
          ),
          const SizedBox(height: 200),
          HeroButton(
            onPressed: () => pagePresses++,
            child: const Text('Page button'),
          ),
        ],
      ),
      surfaceSize: _surface,
    );
    await tester.tap(find.text('Click me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Click me'));
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsNothing);

    await tester.tap(find.text('Click me'));
    await tester.pumpAndSettle();
    // Pressing content inside does not close it.
    await tester.tap(find.text('This is the popover content.'));
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsOneWidget);
    await tester.tap(find.text('Page button'));
    await tester.pumpAndSettle();
    expect(pagePresses, 1);
    expect(find.text('Popover Title'), findsNothing);
  });

  testWidgets('HeroPopoverArrow draws an arrow on the edge facing the '
      'trigger', (WidgetTester tester) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HeroPopover(
            defaultOpen: true,
            content: _content(arrow: true, placement: HeroPlacement.top),
            child: const HeroButton(child: Text('Top')),
          ),
        ],
      ),
      surfaceSize: _surface,
    );
    await tester.pumpAndSettle();
    final Rect trigger = tester.getRect(find.byType(HeroButton));
    final Rect panel = _panel(tester);
    expect(panel.bottom, moreOrLessEquals(trigger.top - 8));
    final HeroOverlayArrow arrow = tester.widget(find.byType(HeroOverlayArrow));
    expect(arrow.side, HeroOverlaySide.top);
    expect(arrow.strokeColor, isNull);
    final Rect arrowRect = tester.getRect(find.byType(HeroOverlayArrow));
    expect(arrowRect.top, moreOrLessEquals(panel.bottom));
    expect(arrowRect.center.dx, moreOrLessEquals(trigger.center.dx));
  });

  testWidgets('placements follow the reading direction and flip', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      const Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HeroPopover(
              defaultOpen: true,
              content: HeroPopoverContent(
                isNonModal: true,
                child: HeroPopoverDialog(children: <Widget>[Text('Flipped')]),
              ),
              child: HeroButton(child: Text('Bottom')),
            ),
            HeroPopover(
              defaultOpen: true,
              content: HeroPopoverContent(
                isNonModal: true,
                placement: HeroPlacement.end,
                child: HeroPopoverDialog(children: <Widget>[Text('End')]),
              ),
              child: HeroButton(child: Text('Side')),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
      surfaceSize: _surface,
    );
    await tester.pumpAndSettle();
    Rect panelOf(String text) => tester.getRect(
      find.ancestor(
        of: find.text(text),
        matching: find.byType(HeroOverlaySurface),
      ),
    );
    final Rect bottom = tester.getRect(
      find.ancestor(of: find.text('Bottom'), matching: find.byType(HeroButton)),
    );
    expect(panelOf('Flipped').bottom, moreOrLessEquals(bottom.top - 8));
    final Rect side = tester.getRect(
      find.ancestor(of: find.text('Side'), matching: find.byType(HeroButton)),
    );
    // `end` is the left side in RTL.
    expect(panelOf('End').right, moreOrLessEquals(side.left - 8));
  });

  testWidgets('style: overlay fill, 24 px radius, 14 px text, 16 px dialog '
      'padding, medium heading', (WidgetTester tester) async {
    final HeroThemeData theme = HeroThemeData.light();
    await pumpHero(
      tester,
      HeroPopover(
        defaultOpen: true,
        content: _content(),
        child: const HeroButton(child: Text('Click me')),
      ),
      theme: theme,
      surfaceSize: _surface,
    );
    await tester.pumpAndSettle();
    final HeroOverlaySurface surface = tester.widget(
      find.byType(HeroOverlaySurface),
    );
    expect(surface.color, theme.colors.overlay);
    expect(surface.shape, theme.shapeAll(24));
    final Rect panel = _panel(tester);
    final Rect title = tester.getRect(find.text('Popover Title'));
    expect(title.left - panel.left, 16);
    expect(title.top - panel.top, 16);
    final RenderParagraph heading = tester.renderObject(
      find.text('Popover Title'),
    );
    expect(heading.text.style?.fontWeight, FontWeight.w500);
    expect(heading.text.style?.fontSize, 14);
    final RenderParagraph body = tester.renderObject(
      find.text('This is the popover content.'),
    );
    expect(body.text.style?.color, theme.colors.overlayForeground);
  });

  testWidgets('semantics: expanded trigger, dialog named by its heading', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      HeroPopover(
        content: _content(),
        child: const HeroButton(child: Text('Click me')),
      ),
      surfaceSize: _surface,
    );
    expect(
      tester.getSemantics(find.byType(HeroButton)),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
    );
    await tester.tap(find.text('Click me'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(HeroButton)),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: true),
    );
    final SemanticsNode dialog = tester.getSemantics(
      find.byType(HeroPopoverDialog),
    );
    expect(dialog.role, SemanticsRole.dialog);
    expect(dialog.flagsCollection.scopesRoute, isTrue);
    expect(
      tester.getSemantics(find.text('Popover Title')),
      isSemantics(isHeader: true, namesRoute: true, label: 'Popover Title'),
    );
    handle.dispose();
  });

  testWidgets('HeroPopoverTrigger opens it and shows the focus ring', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroPopover(
        content: _content(),
        child: const HeroPopoverTrigger(
          semanticsLabel: 'User profile',
          child: Text('Sarah Johnson'),
        ),
      ),
      surfaceSize: _surface,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsNothing);
  });

  testWidgets('a disabled HeroPopoverTrigger does not open it', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      HeroPopover(
        content: _content(),
        child: const HeroPopoverTrigger(
          isDisabled: true,
          child: Text('Sarah Johnson'),
        ),
      ),
      surfaceSize: _surface,
    );
    await tester.tap(find.text('Sarah Johnson'));
    await tester.pumpAndSettle();
    expect(find.text('Popover Title'), findsNothing);
    expect(
      tester
          .widget<HeroDisabledOpacity>(find.byType(HeroDisabledOpacity))
          .disabled,
      isTrue,
    );
  });

  testWidgets('builder, constraints and custom styles', (
    WidgetTester tester,
  ) async {
    final HeroThemeData theme = HeroThemeData.light();
    final List<HeroOverlaySide> placements = <HeroOverlaySide>[];
    await pumpHero(
      tester,
      HeroPopover(
        defaultOpen: true,
        content: HeroPopoverContent(
          placement: HeroPlacement.right,
          constraints: const BoxConstraints(maxWidth: 224),
          backgroundColor: theme.colors.surface,
          side: BorderSide(color: theme.colors.border),
          borderRadius: theme.radii.xl,
          clipBehavior: Clip.antiAlias,
          builder: (BuildContext context, HeroPopoverRenderState state, p) {
            placements.add(state.placement);
            return KeyedSubtree(key: const Key('custom'), child: p);
          },
          child: const HeroPopoverDialog(
            children: <Widget>[
              HeroPopoverHeading(child: Text('Popover Title')),
              Text(
                'A long description that wraps because the panel is at '
                'most 224 pixels wide.',
              ),
            ],
          ),
        ),
        child: const HeroButton(child: Text('Details')),
      ),
      theme: theme,
      surfaceSize: _surface,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('custom')), findsOneWidget);
    expect(placements.last, HeroOverlaySide.right);
    expect(_panel(tester).width, lessThanOrEqualTo(224));
    final HeroOverlaySurface surface = tester.widget(
      find.byType(HeroOverlaySurface),
    );
    expect(surface.color, theme.colors.surface);
    expect(surface.clipBehavior, Clip.antiAlias);
    expect(surface.shape, theme.shapeAll(theme.radii.xl));
  });

  testWidgets('text scale 2 does not overflow', (WidgetTester tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpHero(
      tester,
      const HeroPopover(
        defaultOpen: true,
        content: HeroPopoverContent(
          constraints: BoxConstraints(maxWidth: 256),
          child: HeroPopoverDialog(
            children: <Widget>[
              HeroPopoverArrow(),
              HeroPopoverHeading(child: Text('Popover Title')),
              Text('This is the popover content. You can put any content.'),
            ],
          ),
        ),
        child: HeroButton(child: Text('Click me')),
      ),
      textScale: 2,
      surfaceSize: _surface,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Popover Title'), findsOneWidget);
  });
}
