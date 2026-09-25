import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _column(List<Widget> children, {double spacing = 16}) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: spacing,
  children: children,
);

void main() {
  heroGoldenTest(
    'sizes off and on',
    name: 'sizes',
    size: const Size(420, 200),
    builder: (HeroThemeData theme) => _column(<Widget>[
      for (final bool on in <bool>[false, true])
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: <Widget>[
            for (final (HeroSize size, String label) in <(HeroSize, String)>[
              (HeroSize.sm, 'Small'),
              (HeroSize.md, 'Medium'),
              (HeroSize.lg, 'Large'),
            ])
              HeroSwitch(size: size, isSelected: on, label: label),
          ],
        ),
    ]),
  );

  heroGoldenTest(
    'description, label position, disabled and invalid',
    name: 'states',
    size: const Size(360, 380),
    builder: (HeroThemeData theme) => _column(<Widget>[
      const HeroSwitch(
        label: 'Public profile',
        description: 'Allow others to see your profile information',
      ),
      const HeroSwitch(
        label: 'Label before',
        labelPosition: HeroSwitchLabelPosition.start,
        defaultSelected: true,
      ),
      const HeroSwitch(label: 'Disabled off', isDisabled: true),
      const HeroSwitch(
        label: 'Disabled on',
        isDisabled: true,
        defaultSelected: true,
        description: 'Coming soon',
      ),
      const HeroSwitch(
        label: 'Accept updates',
        isInvalid: true,
        errorMessage: 'This setting is required',
      ),
    ]),
  );

  heroGoldenTest(
    'thumb icons and custom track colors',
    name: 'custom',
    size: const Size(360, 160),
    builder: (HeroThemeData theme) => _column(<Widget>[
      Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: <Widget>[
          for (final (HeroIconData on, HeroIconData off, Color? tint)
              in <(HeroIconData, HeroIconData, Color?)>[
                (
                  HeroIcons.check,
                  HeroIcons.power,
                  oklch(0.723, 0.219, 149.579).withValues(alpha: 0.8),
                ),
                (HeroIcons.sun, HeroIcons.moon, null),
              ])
            for (final bool selected in <bool>[true, false])
              HeroSwitch(
                size: HeroSize.lg,
                isSelected: selected,
                semanticLabel: 'icon',
                builder: (BuildContext context, HeroSwitchState state) =>
                    <Widget>[
                      HeroSwitchContent(
                        children: <Widget>[
                          HeroSwitchControl(
                            selectedColor: tint,
                            selectedHoverColor: tint,
                            child: HeroSwitchThumb(
                              child: HeroSwitchIcon(
                                child: state.isSelected
                                    ? HeroIcon(on)
                                    : Opacity(
                                        opacity: 0.7,
                                        child: HeroIcon(off),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
              ),
        ],
      ),
      HeroSwitch(
        defaultSelected: true,
        children: <Widget>[
          HeroSwitchContent(
            children: <Widget>[
              HeroSwitchControl(
                selectedColor: theme.colors.success,
                selectedHoverColor: theme.colors.success,
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: <Widget>[
                  HeroLabel.text('Auto-save drafts'),
                  HeroDescription.text('Changes are saved as you type.'),
                ],
              ),
            ],
          ),
        ],
      ),
    ]),
  );

  heroGoldenTest(
    'hover, press and keyboard focus',
    name: 'interaction',
    size: const Size(320, 180),
    builder: (HeroThemeData theme) => _column(<Widget>[
      const HeroSwitch(label: 'Hovered off'),
      const HeroSwitch(label: 'Pressed on', defaultSelected: true),
      const HeroSwitch(label: 'Focused'),
    ]),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      addTearDown(mouse.removePointer);
      await mouse.addPointer(
        location: tester.getCenter(find.text('Hovered off')),
      );
      final TestGesture finger = await tester.startGesture(
        tester.getCenter(find.text('Pressed on')),
        pointer: 7,
      );
      addTearDown(finger.up);
      await tester.pump(const Duration(milliseconds: 300));
      Focus.of(tester.element(find.text('Focused'))).requestFocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.shift);
      await tester.pump(const Duration(milliseconds: 300));
    },
  );
}
