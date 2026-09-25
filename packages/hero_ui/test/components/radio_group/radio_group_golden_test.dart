import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<Widget> _plans = <Widget>[
  HeroRadio(
    value: 'basic',
    label: 'Basic Plan',
    description: 'Includes 100 messages per month',
  ),
  HeroRadio(
    value: 'premium',
    label: 'Premium Plan',
    description: 'Includes 200 messages per month',
  ),
  HeroRadio(
    value: 'business',
    label: 'Business Plan',
    description: 'Unlimited messages',
  ),
];

void main() {
  heroGoldenTest(
    'label, description and described radios',
    name: 'basic',
    size: const Size(360, 320),
    builder: (HeroThemeData theme) => const HeroRadioGroup(
      name: 'plan',
      defaultValue: 'premium',
      label: 'Plan selection',
      description: 'Choose the plan that suits you best',
      children: _plans,
    ),
  );

  heroGoldenTest(
    'horizontal and secondary on a surface',
    name: 'layouts',
    size: const Size(420, 440),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: <Widget>[
        const HeroRadioGroup(
          name: 'plan-orientation',
          defaultValue: 'pro',
          orientation: Axis.horizontal,
          children: <Widget>[
            HeroRadio(
              value: 'starter',
              label: 'Starter',
              description: 'For side projects',
            ),
            HeroRadio(
              value: 'pro',
              label: 'Pro',
              description: 'Advanced reporting',
            ),
            HeroRadio(
              value: 'teams',
              label: 'Teams',
              description: 'Up to 10 teammates',
            ),
          ],
        ),
        HeroSurface(
          padding: EdgeInsets.all(theme.spacing(6)),
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          child: const HeroRadioGroup(
            name: 'plan-on-surface',
            defaultValue: 'premium',
            variant: HeroFieldVariant.secondary,
            label: 'Plan selection',
            children: _plans,
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'disabled and invalid',
    name: 'states',
    size: const Size(360, 400),
    builder: (HeroThemeData theme) => const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: <Widget>[
        HeroRadioGroup(
          isDisabled: true,
          defaultValue: 'pro',
          label: 'Subscription plan',
          children: <Widget>[
            HeroRadio(
              value: 'starter',
              label: 'Starter',
              description: 'For side projects and small teams',
            ),
            HeroRadio(value: 'pro', label: 'Pro'),
          ],
        ),
        HeroRadioGroup(
          isRequired: true,
          isInvalid: true,
          defaultValue: 'pro',
          label: 'Subscription plan',
          errorMessage: 'Choose a subscription before continuing.',
          children: <Widget>[
            HeroRadio(value: 'starter', label: 'Starter'),
            HeroRadio(value: 'pro', label: 'Pro'),
          ],
        ),
      ],
    ),
  );

  heroGoldenTest(
    'custom indicator and success cards',
    name: 'custom',
    size: const Size(400, 360),
    builder: (HeroThemeData theme) {
      final HeroColors colors = theme.colors;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 24,
        children: <Widget>[
          HeroRadioGroup(
            defaultValue: 'premium',
            children: <Widget>[
              for (final String plan in <String>['basic', 'premium'])
                HeroRadio(
                  value: plan,
                  children: <Widget>[
                    HeroRadioContent(
                      children: <Widget>[
                        HeroRadioControl(
                          child: HeroRadioIndicator(
                            builder:
                                (BuildContext context, HeroRadioState state) =>
                                    state.isSelected
                                    ? Text(
                                        '✓',
                                        style: theme.typography.xs.copyWith(
                                          height: 1,
                                          color: colors.background,
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                        Text(plan == 'basic' ? 'Basic Plan' : 'Premium Plan'),
                      ],
                    ),
                  ],
                ),
            ],
          ),
          HeroRadioGroup(
            defaultValue: 'yearly',
            variant: HeroFieldVariant.secondary,
            spacing: theme.spacing(3),
            itemMargin: EdgeInsets.zero,
            children: <Widget>[
              for (final (String value, String label) in <(String, String)>[
                ('monthly', 'Monthly'),
                ('yearly', 'Yearly'),
              ])
                HeroRadio(
                  value: value,
                  children: <Widget>[
                    HeroRadioContent(
                      fullWidth: true,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing(4),
                        vertical: theme.spacing(3),
                      ),
                      decoration: WidgetStateProperty.resolveWith(
                        (Set<WidgetState> states) => ShapeDecoration(
                          color: states.contains(WidgetState.selected)
                              ? colors.successSoft
                              : colors.successSoft.withValues(
                                  alpha: colors.successSoft.a * 0.3,
                                ),
                          shape: theme.shapeAll(
                            theme.radii.xl,
                            side: BorderSide(
                              color: colors.success.withValues(
                                alpha: states.contains(WidgetState.selected)
                                    ? 0.3
                                    : 0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: theme.spacing(0.5)),
                          child: HeroRadioControl(
                            size: theme.spacing(5),
                            borderRadius: BorderRadius.circular(
                              theme.radii.full,
                            ),
                            selectedColor: colors.success,
                            pressedColor: colors.successHover,
                            side: BorderSide(color: colors.border),
                            child: HeroRadioIndicator(
                              selectedColor: colors.successForeground,
                              selectedScale: 0.5,
                              pressedScale: 0.57,
                            ),
                          ),
                        ),
                        Text(label),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      );
    },
  );

  heroGoldenTest(
    'hover, press and keyboard focus',
    name: 'interaction',
    size: const Size(320, 180),
    builder: (HeroThemeData theme) => const HeroRadioGroup(
      defaultValue: 'pressed',
      children: <Widget>[
        HeroRadio(value: 'hovered', label: 'Hovered'),
        HeroRadio(value: 'pressed', label: 'Pressed'),
        HeroRadio(value: 'focused', label: 'Focused', isDisabled: false),
      ],
    ),
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
      await mouse.addPointer(location: tester.getCenter(find.text('Hovered')));
      final TestGesture finger = await tester.startGesture(
        tester.getCenter(find.text('Pressed')),
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
