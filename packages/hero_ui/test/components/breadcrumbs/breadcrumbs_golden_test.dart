import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Widget breadcrumbs(
    List<String> labels, {
    bool isDisabled = false,
    Widget? separator,
  }) => HeroBreadcrumbs(
    isDisabled: isDisabled,
    separator: separator,
    children: <Widget>[
      for (final String label in labels)
        HeroBreadcrumbsItem(href: '#', onPressed: () {}, child: Text(label)),
    ],
  );

  const List<String> basic = <String>[
    'Home',
    'Products',
    'Electronics',
    'Laptop',
  ];

  heroGoldenTest(
    'levels, disabled and custom separator',
    name: 'breadcrumbs_variants',
    size: const Size(400, 220),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: <Widget>[
        breadcrumbs(basic),
        breadcrumbs(const <String>['Home', 'Current Page']),
        breadcrumbs(const <String>['Home', 'Category', 'Current Page']),
        breadcrumbs(basic, isDisabled: true),
        breadcrumbs(basic, separator: const Text('/')),
      ],
    ),
  );

  heroGoldenTest(
    'hovered link',
    name: 'breadcrumbs_hover',
    size: const Size(400, 80),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Products')));
    },
    builder: (HeroThemeData theme) => breadcrumbs(basic),
  );

  heroGoldenTest(
    'keyboard focus',
    name: 'breadcrumbs_focus',
    size: const Size(400, 80),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      Focus.of(tester.element(find.text('Products'))).requestFocus();
    },
    builder: (HeroThemeData theme) => breadcrumbs(basic),
  );
}
