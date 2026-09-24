import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Widget column(List<Widget> rows) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: <Widget>[
      for (final Widget row in rows)
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[row],
        ),
    ],
  );

  Widget row(List<Widget> children) =>
      Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: children);

  heroGoldenTest(
    'variants unselected and selected',
    name: 'toggle_button_variants',
    size: const Size(440, 200),
    builder: (HeroThemeData theme) => column(<Widget>[
      row(const <Widget>[
        HeroToggleButton(
          startContent: HeroIcon(HeroIcons.heart),
          child: Text('Default'),
        ),
        HeroToggleButton(
          variant: HeroToggleButtonVariant.ghost,
          startContent: HeroIcon(HeroIcons.heart),
          child: Text('Ghost'),
        ),
      ]),
      row(const <Widget>[
        HeroToggleButton(
          defaultSelected: true,
          startContent: HeroIcon(HeroIcons.heartFill),
          child: Text('Default'),
        ),
        HeroToggleButton(
          defaultSelected: true,
          variant: HeroToggleButtonVariant.ghost,
          startContent: HeroIcon(HeroIcons.heartFill),
          child: Text('Ghost'),
        ),
      ]),
      row(const <Widget>[
        HeroToggleButton(
          isIconOnly: true,
          semanticLabel: 'Like',
          child: HeroIcon(HeroIcons.heart),
        ),
        HeroToggleButton(
          isIconOnly: true,
          variant: HeroToggleButtonVariant.ghost,
          semanticLabel: 'Bookmark',
          child: HeroIcon(HeroIcons.bookmark),
        ),
        HeroToggleButton(
          isIconOnly: true,
          defaultSelected: true,
          semanticLabel: 'Like',
          child: HeroIcon(HeroIcons.heartFill),
        ),
      ]),
    ]),
  );

  heroGoldenTest(
    'sizes',
    name: 'toggle_button_sizes',
    size: const Size(440, 160),
    builder: (HeroThemeData theme) => column(<Widget>[
      row(<Widget>[
        for (final (HeroSize size, String label) in <(HeroSize, String)>[
          (HeroSize.sm, 'Small'),
          (HeroSize.md, 'Medium'),
          (HeroSize.lg, 'Large'),
        ])
          HeroToggleButton(
            size: size,
            startContent: const HeroIcon(HeroIcons.heart),
            child: Text(label),
          ),
      ]),
      row(<Widget>[
        for (final HeroSize size in HeroSize.values)
          HeroToggleButton(
            size: size,
            isIconOnly: true,
            semanticLabel: 'Like',
            child: const HeroIcon(HeroIcons.heart),
          ),
      ]),
    ]),
  );

  heroGoldenTest(
    'disabled and focused',
    name: 'toggle_button_states',
    size: const Size(440, 140),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      Focus.of(tester.element(find.text('Focused'))).requestFocus();
    },
    builder: (HeroThemeData theme) => column(<Widget>[
      row(const <Widget>[
        HeroToggleButton(
          isDisabled: true,
          startContent: HeroIcon(HeroIcons.heart),
          child: Text('Like'),
        ),
        HeroToggleButton(
          isDisabled: true,
          defaultSelected: true,
          startContent: HeroIcon(HeroIcons.heartFill),
          child: Text('Like'),
        ),
      ]),
      row(const <Widget>[
        HeroToggleButton(
          startContent: HeroIcon(HeroIcons.heart),
          child: Text('Focused'),
        ),
      ]),
    ]),
  );

  heroGoldenTest(
    'hovered unselected and selected',
    name: 'toggle_button_hover',
    size: const Size(440, 100),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Hovered')));
    },
    builder: (HeroThemeData theme) => row(const <Widget>[
      HeroToggleButton(
        startContent: HeroIcon(HeroIcons.heart),
        child: Text('Hovered'),
      ),
      HeroToggleButton(
        defaultSelected: true,
        startContent: HeroIcon(HeroIcons.heartFill),
        child: Text('Selected'),
      ),
    ]),
  );
}
