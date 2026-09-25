import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<(String, String, HeroIconData)> _faq =
    <(String, String, HeroIconData)>[
      (
        'How do I place an order?',
        'Browse our products, add items to your cart, and proceed to checkout.',
        HeroIcons.shoppingBag,
      ),
      (
        'Can I modify or cancel my order?',
        "Yes, you can modify or cancel your order before it's shipped.",
        HeroIcons.receipt,
      ),
      (
        'What payment methods do you accept?',
        'We accept all major credit cards.',
        HeroIcons.creditCard,
      ),
    ];

List<Widget> _items(HeroThemeData theme, {bool icons = true}) => <Widget>[
  for (final (String title, String body, HeroIconData icon) in _faq)
    HeroAccordionItem(
      startContent: icons ? HeroIcon(icon, color: theme.colors.muted) : null,
      title: Text(title),
      child: Text(body),
    ),
];

void main() {
  heroGoldenTest(
    'standard with an expanded item and hover',
    name: 'standard',
    size: const Size(460, 300),
    builder: (HeroThemeData theme) => SizedBox(
      width: 420,
      child: HeroAccordion(
        defaultExpandedKeys: const <Object>{0},
        children: _items(theme),
      ),
    ),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(
        location: tester.getCenter(
          find.text('What payment methods do you accept?'),
        ),
      );
      addTearDown(mouse.removePointer);
    },
  );

  heroGoldenTest(
    'surface with hover and keyboard focus',
    name: 'surface',
    size: const Size(460, 300),
    builder: (HeroThemeData theme) => SizedBox(
      width: 420,
      child: HeroAccordion(
        variant: HeroAccordionVariant.surface,
        defaultExpandedKeys: const <Object>{2},
        children: _items(theme),
      ),
    ),
    whilePerforming: (WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    },
  );

  heroGoldenTest(
    'without separator, disabled items and custom indicators',
    name: 'states',
    size: const Size(460, 420),
    builder: (HeroThemeData theme) => SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          HeroAccordion(hideSeparator: true, children: _items(theme)),
          const HeroAccordion(
            children: <Widget>[
              HeroAccordionItem(
                title: Text('Active Item'),
                child: Text('This item is active.'),
              ),
              HeroAccordionItem(
                isDisabled: true,
                title: Text('Disabled Item'),
                child: Text('This content cannot be accessed.'),
              ),
              HeroAccordionItem(
                defaultExpanded: true,
                title: Text('Using Plus/Minus Icon'),
                indicator: HeroAccordionIndicator(
                  child: HeroIcon(HeroIcons.circleChevronDown),
                ),
                child: Text('Any icon turns over when the item expands.'),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'right to left',
    name: 'rtl',
    size: const Size(460, 220),
    builder: (HeroThemeData theme) => Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: 420,
        child: HeroAccordion(
          variant: HeroAccordionVariant.surface,
          defaultExpandedKeys: const <Object>{1},
          children: _items(theme).take(2).toList(),
        ),
      ),
    ),
  );
}
