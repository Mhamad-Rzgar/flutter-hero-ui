import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  const Widget basic = HeroLink(
    children: <Widget>[Text('Call to action'), HeroLinkIcon()],
  );

  heroGoldenTest(
    'link content',
    name: 'link_content',
    size: const Size(300, 220),
    builder: (HeroThemeData theme) => const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        basic,
        HeroLink(
          gap: 4,
          children: <Widget>[HeroLinkIcon(), Text('Icon at start')],
        ),
        HeroLink(
          children: <Widget>[
            Text('External link'),
            HeroLinkIcon(
              size: 12,
              margin: EdgeInsetsDirectional.only(start: 6),
              child: HeroIcon(HeroIcons.arrowRightFromSquare),
            ),
          ],
        ),
        HeroLink(
          gap: 4,
          children: <Widget>[
            Text('Go to page'),
            HeroLinkIcon(size: 12, child: HeroIcon(HeroIcons.link)),
          ],
        ),
        HeroLink(
          isDisabled: true,
          children: <Widget>[Text('Disabled link'), HeroLinkIcon()],
        ),
      ],
    ),
  );

  heroGoldenTest(
    'link underline options',
    name: 'link_underline',
    size: const Size(300, 260),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        const HeroLink(
          underline: HeroLinkUnderline.always,
          children: <Widget>[Text('Underline always visible'), HeroLinkIcon()],
        ),
        const HeroLink(
          underline: HeroLinkUnderline.none,
          children: <Widget>[Text('Link without underline'), HeroLinkIcon()],
        ),
        for (final double offset in <double>[1, 2, 3, 4])
          HeroLink(
            underline: HeroLinkUnderline.always,
            underlineOffset: offset,
            children: <Widget>[
              Text('Offset ${offset.toInt()}'),
              const HeroLinkIcon(),
            ],
          ),
      ],
    ),
  );

  heroGoldenTest(
    'link hovered',
    name: 'link_hovered',
    size: const Size(240, 80),
    builder: (HeroThemeData theme) => basic,
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(HeroLink)));
    },
  );

  heroGoldenTest(
    'link pressed',
    name: 'link_pressed',
    size: const Size(240, 80),
    builder: (HeroThemeData theme) => HeroLink(
      onPressed: () {},
      children: const <Widget>[Text('Call to action'), HeroLinkIcon()],
    ),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(HeroLink)),
      );
      addTearDown(gesture.up);
      await tester.pump();
    },
  );

  heroGoldenTest(
    'link focused',
    name: 'link_focused',
    size: const Size(240, 80),
    builder: (HeroThemeData theme) => const HeroLink(
      autofocus: true,
      children: <Widget>[Text('Call to action'), HeroLinkIcon()],
    ),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
    },
  );
}
