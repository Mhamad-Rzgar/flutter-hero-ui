import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// First / Second / Third with separators, like most docs examples.
HeroButtonGroup _group({
  HeroButtonVariant? variant,
  HeroSize? size,
  bool isDisabled = false,
  bool fullWidth = false,
  bool separators = true,
  bool? thirdDisabled,
}) {
  return HeroButtonGroup(
    variant: variant,
    size: size,
    isDisabled: isDisabled,
    fullWidth: fullWidth,
    children: <Widget>[
      HeroButton(onPressed: () {}, child: const Text('First')),
      if (separators) const HeroButtonGroupSeparator(),
      HeroButton(onPressed: () {}, child: const Text('Second')),
      if (separators) const HeroButtonGroupSeparator(),
      HeroButton(
        isDisabled: thirdDisabled,
        onPressed: () {},
        child: const Text('Third'),
      ),
    ],
  );
}

HeroButtonGroup _alignment({
  Axis orientation = Axis.horizontal,
  bool fullWidth = false,
  HeroButtonVariant? variant = HeroButtonVariant.tertiary,
}) {
  const List<(String, HeroIconData)> icons = <(String, HeroIconData)>[
    ('Align left', HeroIcons.textAlignLeft),
    ('Align center', HeroIcons.textAlignCenter),
    ('Align right', HeroIcons.textAlignRight),
    ('Justify', HeroIcons.textAlignJustify),
  ];
  return HeroButtonGroup(
    orientation: orientation,
    fullWidth: fullWidth,
    variant: variant,
    children: <Widget>[
      for (int i = 0; i < icons.length; i++) ...<Widget>[
        if (i > 0) const HeroButtonGroupSeparator(),
        HeroButton(
          isIconOnly: true,
          semanticLabel: icons[i].$1,
          onPressed: () {},
          child: HeroIcon(icons[i].$2),
        ),
      ],
    ],
  );
}

void main() {
  heroGoldenTest(
    'button group variants',
    name: 'button_group_variants',
    size: const Size(300, 420),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroButtonVariant variant in HeroButtonVariant.values)
          _group(variant: variant),
      ],
    ),
  );

  heroGoldenTest(
    'button group sizes',
    name: 'button_group_sizes',
    size: const Size(320, 200),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroSize size in HeroSize.values)
          _group(size: size, variant: HeroButtonVariant.secondary),
      ],
    ),
  );

  heroGoldenTest(
    'button group orientation and right-to-left',
    name: 'button_group_orientation',
    size: const Size(420, 240),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            _alignment(),
            Directionality(
              textDirection: TextDirection.rtl,
              child: HeroButtonGroup(
                variant: HeroButtonVariant.outline,
                children: <Widget>[
                  HeroButton(
                    startContent: const HeroIcon(HeroIcons.chevronLeft),
                    onPressed: () {},
                    child: const Text('Previous'),
                  ),
                  const HeroButtonGroupSeparator(),
                  HeroButton(
                    endContent: const HeroIcon(HeroIcons.chevronRight),
                    onPressed: () {},
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
        _alignment(orientation: Axis.vertical),
        _alignment(
          orientation: Axis.vertical,
          variant: HeroButtonVariant.outline,
        ),
      ],
    ),
  );

  heroGoldenTest(
    'button group with icons',
    name: 'button_group_icons',
    size: const Size(360, 150),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        HeroButtonGroup(
          variant: HeroButtonVariant.secondary,
          children: <Widget>[
            HeroButton(
              startContent: const HeroIcon(HeroIcons.globe),
              onPressed: () {},
              child: const Text('Search'),
            ),
            const HeroButtonGroupSeparator(),
            HeroButton(
              startContent: const HeroIcon(HeroIcons.plus),
              onPressed: () {},
              child: const Text('Add'),
            ),
            const HeroButtonGroupSeparator(),
            HeroButton(
              startContent: const HeroIcon(HeroIcons.trashBin),
              onPressed: () {},
              child: const Text('Delete'),
            ),
          ],
        ),
        HeroButtonGroup(
          children: <Widget>[
            HeroButton(
              onPressed: () {},
              child: const Text('Merge pull request'),
            ),
            const HeroButtonGroupSeparator(),
            HeroButton(
              isIconOnly: true,
              semanticLabel: 'More options',
              onPressed: () {},
              child: const HeroIcon(HeroIcons.chevronDown),
            ),
          ],
        ),
      ],
    ),
  );

  heroGoldenTest(
    'button group full width',
    name: 'button_group_full_width',
    size: const Size(440, 310),
    builder: (HeroThemeData theme) => SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          _group(fullWidth: true),
          _alignment(fullWidth: true, variant: null),
          SizedBox(
            width: 200,
            child: _alignment(
              orientation: Axis.vertical,
              fullWidth: true,
              variant: HeroButtonVariant.outline,
            ),
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'button group disabled',
    name: 'button_group_disabled',
    size: const Size(320, 130),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        _group(isDisabled: true),
        _group(isDisabled: true, thirdDisabled: false),
      ],
    ),
  );

  heroGoldenTest(
    'button group hover, press and focus',
    name: 'button_group_states',
    size: const Size(320, 150),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: <Widget>[
        _group(variant: HeroButtonVariant.outline),
        _group(variant: HeroButtonVariant.secondary, separators: false),
      ],
    ),
    whilePerforming: (WidgetTester tester) async {
      final List<Element> buttons = find.byType(HeroButton).evaluate().toList();
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(
        location: tester.getCenter(find.byWidget(buttons[0].widget)),
      );
      addTearDown(mouse.removePointer);
      final TestGesture finger = await tester.startGesture(
        tester.getCenter(find.byWidget(buttons[2].widget)),
      );
      addTearDown(finger.up);
      // Keyboard focus on the middle button of the second group.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      for (int i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 300));
    },
  );
}
