import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const Map<HeroButtonVariant, String> _labels = <HeroButtonVariant, String>{
  HeroButtonVariant.primary: 'Primary',
  HeroButtonVariant.secondary: 'Secondary',
  HeroButtonVariant.tertiary: 'Tertiary',
  HeroButtonVariant.outline: 'Outline',
  HeroButtonVariant.ghost: 'Ghost',
  HeroButtonVariant.danger: 'Danger',
  HeroButtonVariant.dangerSoft: 'Danger Soft',
};

/// Every variant, wrapped like the docs' variants example.
Widget _variants({bool isDisabled = false, bool isPending = false}) {
  return Wrap(
    spacing: 12,
    runSpacing: 12,
    children: <Widget>[
      for (final MapEntry<HeroButtonVariant, String> e in _labels.entries)
        HeroButton(
          variant: e.key,
          isDisabled: isDisabled,
          isPending: isPending,
          onPressed: () {},
          child: Text(e.value),
        ),
    ],
  );
}

/// Pending buttons contain spinners; render them still.
Widget _still(HeroThemeData theme, Widget child) => HeroTheme(
  data: theme.copyWith(motion: const HeroMotion(reduceMotion: true)),
  child: child,
);

Widget _caption(HeroThemeData theme, String text) =>
    Text(text, style: theme.typography.xs.copyWith(color: theme.colors.muted));

void main() {
  heroGoldenTest(
    'button variants',
    name: 'button_variants',
    size: const Size(420, 170),
    builder: (HeroThemeData theme) => _variants(),
  );

  heroGoldenTest(
    'button variants hovered',
    name: 'button_hovered',
    size: const Size(420, 170),
    builder: (HeroThemeData theme) => _variants(),
    whilePerforming: (WidgetTester tester) async {
      // One mouse per button, so every variant shows its hover fill.
      int device = 1;
      for (final Element button in find.byType(HeroButton).evaluate()) {
        final TestGesture mouse = TestGesture(
          dispatcher: tester.sendEventToBinding,
          kind: PointerDeviceKind.mouse,
          pointer: 100 + device,
          device: device++,
        );
        await mouse.addPointer(
          location: tester.getCenter(find.byWidget(button.widget)),
        );
        addTearDown(mouse.removePointer);
      }
      await tester.pump();
    },
  );

  heroGoldenTest(
    'button variants pressed',
    name: 'button_pressed',
    size: const Size(420, 170),
    builder: (HeroThemeData theme) => _variants(),
    whilePerforming: (WidgetTester tester) async {
      // One finger per button; the fingers stay down while the golden is
      // captured.
      int pointer = 1;
      for (final Element button in find.byType(HeroButton).evaluate()) {
        final TestGesture finger = await tester.startGesture(
          tester.getCenter(find.byWidget(button.widget)),
          pointer: pointer++,
        );
        addTearDown(finger.up);
      }
      await tester.pump(const Duration(milliseconds: 300));
    },
  );

  heroGoldenTest(
    'button focus ring',
    name: 'button_focused',
    size: const Size(420, 120),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        HeroButton(onPressed: () {}, child: const Text('Primary')),
        HeroButton(
          variant: HeroButtonVariant.outline,
          onPressed: () {},
          child: const Text('Outline'),
        ),
        HeroButton(
          variant: HeroButtonVariant.tertiary,
          isIconOnly: true,
          semanticLabel: 'Settings',
          onPressed: () {},
          child: const HeroIcon(HeroIcons.gear),
        ),
      ],
    ),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 200));
    },
  );

  heroGoldenTest(
    'button variants disabled',
    name: 'button_disabled',
    size: const Size(420, 170),
    builder: (HeroThemeData theme) => _variants(isDisabled: true),
  );

  heroGoldenTest(
    'button variants pending',
    name: 'button_pending',
    size: const Size(480, 170),
    builder: (HeroThemeData theme) => _still(theme, _variants(isPending: true)),
  );

  heroGoldenTest(
    'button sizes',
    name: 'button_sizes',
    size: const Size(420, 220),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroSize size in HeroSize.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              HeroButton(
                size: size,
                onPressed: () {},
                child: Text(size.name.toUpperCase()),
              ),
              HeroButton(
                size: size,
                variant: HeroButtonVariant.secondary,
                startContent: const HeroIcon(HeroIcons.plus),
                onPressed: () {},
                child: const Text('Add'),
              ),
              HeroButton(
                size: size,
                variant: HeroButtonVariant.tertiary,
                isIconOnly: true,
                semanticLabel: 'More',
                onPressed: () {},
                child: const HeroIcon(HeroIcons.ellipsis),
              ),
            ],
          ),
      ],
    ),
  );

  heroGoldenTest(
    'button sizes at desktop density',
    name: 'button_sizes_desktop',
    size: const Size(420, 200),
    builder: (HeroThemeData theme) => HeroTheme(
      data: theme.copyWith(density: HeroDensity.desktop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          for (final HeroSize size in HeroSize.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: <Widget>[
                HeroButton(
                  size: size,
                  onPressed: () {},
                  child: Text(size.name.toUpperCase()),
                ),
                HeroButton(
                  size: size,
                  variant: HeroButtonVariant.secondary,
                  startContent: const HeroIcon(HeroIcons.plus),
                  onPressed: () {},
                  child: const Text('Add'),
                ),
                HeroButton(
                  size: size,
                  variant: HeroButtonVariant.tertiary,
                  isIconOnly: true,
                  semanticLabel: 'More',
                  onPressed: () {},
                  child: const HeroIcon(HeroIcons.ellipsis),
                ),
              ],
            ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'button icons, icon-only and right-to-left',
    name: 'button_icons',
    size: const Size(460, 290),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            HeroButton(
              startContent: const HeroIcon(HeroIcons.globe),
              onPressed: () {},
              child: const Text('Search'),
            ),
            HeroButton(
              variant: HeroButtonVariant.secondary,
              startContent: const HeroIcon(HeroIcons.plus),
              onPressed: () {},
              child: const Text('Add Member'),
            ),
            HeroButton(
              variant: HeroButtonVariant.tertiary,
              startContent: const HeroIcon(HeroIcons.envelope),
              onPressed: () {},
              child: const Text('Email'),
            ),
            HeroButton(
              variant: HeroButtonVariant.danger,
              startContent: const HeroIcon(HeroIcons.trashBin),
              onPressed: () {},
              child: const Text('Delete'),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: <Widget>[
            for (final (HeroButtonVariant, HeroIconData) b
                in <(HeroButtonVariant, HeroIconData)>[
                  (HeroButtonVariant.tertiary, HeroIcons.ellipsis),
                  (HeroButtonVariant.secondary, HeroIcons.gear),
                  (HeroButtonVariant.danger, HeroIcons.trashBin),
                  (HeroButtonVariant.outline, HeroIcons.pencil),
                  (HeroButtonVariant.ghost, HeroIcons.bell),
                ])
              HeroButton(
                variant: b.$1,
                isIconOnly: true,
                semanticLabel: 'Icon',
                onPressed: () {},
                child: HeroIcon(b.$2),
              ),
          ],
        ),
        _caption(theme, 'Right-to-left'),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: <Widget>[
              HeroButton(
                variant: HeroButtonVariant.secondary,
                startContent: const HeroIcon(HeroIcons.chevronLeft),
                onPressed: () {},
                child: const Text('Previous'),
              ),
              HeroButton(
                variant: HeroButtonVariant.secondary,
                endContent: const HeroIcon(HeroIcons.chevronRight),
                onPressed: () {},
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'button full width',
    name: 'button_full_width',
    size: const Size(440, 150),
    builder: (HeroThemeData theme) => SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          HeroButton(
            fullWidth: true,
            onPressed: () {},
            child: const Text('Primary Button'),
          ),
          HeroButton(
            fullWidth: true,
            startContent: const HeroIcon(HeroIcons.plus),
            onPressed: () {},
            child: const Text('With Icon'),
          ),
        ],
      ),
    ),
  );
}
