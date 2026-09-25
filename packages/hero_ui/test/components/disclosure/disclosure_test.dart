import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _disclosure({
  bool? isExpanded,
  bool defaultExpanded = false,
  ValueChanged<bool>? onExpandedChanged,
  bool isDisabled = false,
  bool button = false,
}) => SizedBox(
  width: 300,
  child: HeroDisclosure(
    isExpanded: isExpanded,
    defaultExpanded: defaultExpanded,
    onExpandedChanged: onExpandedChanged,
    isDisabled: isDisabled,
    children: <Widget>[
      HeroDisclosureHeading(
        child: button
            ? HeroDisclosureTrigger.builder(
                builder: (BuildContext context, HeroDisclosureState state) =>
                    HeroButton(
                      variant: HeroButtonVariant.secondary,
                      onPressed: state.toggle,
                      isDisabled: state.isDisabled,
                      endContent: const HeroDisclosureIndicator(),
                      child: const Text('Toggle'),
                    ),
              )
            : const HeroDisclosureTrigger(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[Text('Toggle'), HeroDisclosureIndicator()],
                ),
              ),
      ),
      const HeroDisclosureContent(
        child: HeroDisclosureBody(child: Text('Content')),
      ),
    ],
  ),
);

bool _shown(WidgetTester tester) => find.text('Content').evaluate().isNotEmpty;

void main() {
  testWidgets('uncontrolled: the trigger toggles the content', (
    WidgetTester tester,
  ) async {
    final List<bool> changes = <bool>[];
    await pumpHero(tester, _disclosure(onExpandedChanged: changes.add));
    expect(_shown(tester), isFalse);
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(_shown(tester), isTrue);
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(_shown(tester), isFalse);
    expect(changes, <bool>[true, false]);
  });

  testWidgets('defaultExpanded and a button trigger', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _disclosure(defaultExpanded: true, button: true));
    expect(_shown(tester), isTrue);
    await tester.tap(find.byType(HeroButton));
    await tester.pumpAndSettle();
    expect(_shown(tester), isFalse);
  });

  testWidgets('controlled isExpanded', (WidgetTester tester) async {
    bool expanded = true;
    await pumpHero(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => _disclosure(
          isExpanded: expanded,
          onExpandedChanged: (bool value) => setState(() => expanded = value),
          button: true,
        ),
      ),
    );
    expect(_shown(tester), isTrue);
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(expanded, isFalse);
    expect(_shown(tester), isFalse);
  });

  testWidgets('a controlled disclosure ignores toggles without an update', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _disclosure(isExpanded: false));
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(_shown(tester), isFalse);
  });

  testWidgets('disabled disclosures do not toggle', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _disclosure(isDisabled: true),
          _disclosure(isDisabled: true, button: true),
        ],
      ),
    );
    await tester.tap(find.text('Toggle').first);
    await tester.tap(find.text('Toggle').last);
    await tester.pumpAndSettle();
    expect(_shown(tester), isFalse);
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is HeroDisabledOpacity && w.disabled,
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('indicator turns over and inherits the icon color', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _disclosure(button: true));
    AnimatedRotation rotation() =>
        tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
    expect(rotation().turns, 0);
    expect(rotation().duration, const Duration(milliseconds: 250));
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(rotation().turns, -0.5);
    final HeroColors colors = HeroThemeData.light().colors;
    expect(
      IconTheme.of(tester.element(find.byType(HeroIcon))).color,
      colors.accentSoftForeground,
    );
    expect(
      tester.getSize(find.byType(HeroDisclosureIndicator)),
      const Size(16, 16),
    );
  });

  testWidgets('content animates over 200 ms and body pads 8 px', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _disclosure());
    final double collapsed = tester.getSize(find.byType(HeroDisclosure)).height;
    await tester.tap(find.text('Toggle'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final double midway = tester.getSize(find.byType(HeroDisclosure)).height;
    await tester.pumpAndSettle();
    final double expanded = tester.getSize(find.byType(HeroDisclosure)).height;
    expect(midway, greaterThan(collapsed));
    expect(midway, lessThan(expanded));
    // A 24 px line of body text plus 8 px of padding on each side.
    expect(expanded - collapsed, 40);
    expect(
      tester.getTopLeft(find.text('Content')) -
          tester.getTopLeft(find.byType(HeroDisclosureBody)),
      const Offset(8, 8),
    );
  });

  testWidgets('HeroDisclosure.of and the root builder', (
    WidgetTester tester,
  ) async {
    await pumpHero(
      tester,
      SizedBox(
        width: 300,
        child: HeroDisclosure(
          builder: (BuildContext context, HeroDisclosureState state) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(state.isExpanded ? 'Open' : 'Closed'),
              Builder(
                builder: (BuildContext context) => GestureDetector(
                  onTap: HeroDisclosure.of(context).expand,
                  child: const Text('Expand'),
                ),
              ),
              Builder(
                builder: (BuildContext context) => GestureDetector(
                  onTap: HeroDisclosure.of(context).collapse,
                  child: const Text('Collapse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Closed'), findsOneWidget);
    await tester.tap(find.text('Expand'));
    await tester.pump();
    expect(find.text('Open'), findsOneWidget);
    await tester.tap(find.text('Collapse'));
    await tester.pump();
    expect(find.text('Closed'), findsOneWidget);
  });

  testWidgets('keyboard: Enter and Space toggle the trigger', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _disclosure());
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      tester.widget<HeroFocusRing>(find.byType(HeroFocusRing)).visible,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_shown(tester), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(_shown(tester), isFalse);
  });

  testWidgets('semantics: heading, expanded button, hidden content', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHero(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[_disclosure(), _disclosure(button: true)],
      ),
    );
    expect(
      tester.getSemantics(find.text('Toggle').first),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: false),
    );
    expect(
      tester.getSemantics(find.text('Toggle').last),
      isSemantics(
        isButton: true,
        hasExpandedState: true,
        isExpanded: false,
        hasTapAction: true,
      ),
    );
    expect(find.bySemanticsLabel('Content'), findsNothing);
    await tester.tap(find.text('Toggle').last);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.text('Toggle').last),
      isSemantics(isButton: true, hasExpandedState: true, isExpanded: true),
    );
    expect(find.bySemanticsLabel('Content'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('RTL places the trigger at the start (right)', (
    WidgetTester tester,
  ) async {
    await pumpHero(tester, _disclosure(), textDirection: TextDirection.rtl);
    expect(
      tester.getTopRight(find.byType(HeroDisclosureTrigger)).dx,
      tester.getTopRight(find.byType(HeroDisclosure)).dx,
    );
  });

  testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
    await pumpHero(
      tester,
      _disclosure(defaultExpanded: true, button: true),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });
}
