import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<Widget> _interests = <Widget>[
  HeroCheckbox(
    value: 'coding',
    label: 'Coding',
    description: 'Love building software',
  ),
  HeroCheckbox(
    value: 'design',
    label: 'Design',
    description: 'Enjoy creating beautiful interfaces',
  ),
  HeroCheckbox(
    value: 'writing',
    label: 'Writing',
    description: 'Passionate about content creation',
  ),
];

void main() {
  heroGoldenTest(
    'label, description and described checkboxes',
    name: 'basic',
    size: const Size(360, 320),
    builder: (HeroThemeData theme) => const HeroCheckboxGroup(
      name: 'interests',
      label: 'Select your interests',
      description: 'Choose all that apply',
      defaultValue: <String>{'design'},
      children: _interests,
    ),
  );

  heroGoldenTest(
    'secondary on a surface',
    name: 'on_surface',
    size: const Size(400, 360),
    builder: (HeroThemeData theme) => HeroSurface(
      padding: EdgeInsets.all(theme.spacing(6)),
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      child: const HeroCheckboxGroup(
        name: 'interests',
        variant: HeroFieldVariant.secondary,
        label: 'Select your interests',
        description: 'Choose all that apply',
        defaultValue: <String>{'coding'},
        children: _interests,
      ),
    ),
  );

  heroGoldenTest(
    'disabled and invalid',
    name: 'states',
    size: const Size(360, 420),
    builder: (HeroThemeData theme) => const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 24,
      children: <Widget>[
        HeroCheckboxGroup(
          isDisabled: true,
          label: 'Features',
          description: 'Feature selection is temporarily disabled',
          defaultValue: <String>{'feature1'},
          children: <Widget>[
            HeroCheckbox(
              value: 'feature1',
              label: 'Feature 1',
              description: 'This feature is coming soon',
            ),
            HeroCheckbox(value: 'feature2', label: 'Feature 2'),
          ],
        ),
        HeroCheckboxGroup(
          isRequired: true,
          isInvalid: true,
          label: 'Preferences',
          errorMessage: 'Please select at least one notification method.',
          defaultValue: <String>{'sms'},
          children: <Widget>[
            HeroCheckbox(value: 'email', label: 'Email notifications'),
            HeroCheckbox(value: 'sms', label: 'SMS notifications'),
          ],
        ),
      ],
    ),
  );

  heroGoldenTest(
    'custom spacing, colors and card checkboxes',
    name: 'custom',
    size: const Size(400, 420),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: <Widget>[
        HeroCheckboxGroup(
          spacing: theme.spacing(3),
          itemMargin: EdgeInsets.zero,
          defaultValue: const <String>{'email'},
          label: 'Notification channels',
          children: <Widget>[
            for (final String channel in <String>['Email', 'SMS'])
              HeroCheckbox(
                value: channel.toLowerCase(),
                children: <Widget>[
                  HeroCheckboxContent(
                    children: <Widget>[
                      HeroCheckboxControl(
                        color: theme.colors.successSoft,
                        selectedColor: theme.colors.success,
                        child: HeroCheckboxIndicator(
                          color: theme.colors.successForeground,
                        ),
                      ),
                      Text(channel),
                    ],
                  ),
                ],
              ),
          ],
        ),
        HeroCheckboxGroup(
          defaultValue: const <String>{'email'},
          label: 'Notification preferences',
          children: <Widget>[
            for (final (String value, String title) in <(String, String)>[
              ('email', 'Email Notifications'),
              ('sms', 'SMS Alerts'),
            ])
              HeroCheckbox(
                value: value,
                variant: HeroFieldVariant.secondary,
                children: <Widget>[
                  HeroCheckboxContent(
                    fullWidth: true,
                    decoration: WidgetStateProperty.resolveWith(
                      (Set<WidgetState> states) => ShapeDecoration(
                        color: states.contains(WidgetState.selected)
                            ? theme.colors.accent.withValues(alpha: 0.1)
                            : theme.colors.surface,
                        shape: theme.shapeAll(theme.radii.xl3),
                      ),
                    ),
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: theme.spacing(5),
                                vertical: theme.spacing(4),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: theme.spacing(4),
                                children: <Widget>[
                                  HeroIcon(
                                    HeroIcons.envelope,
                                    size: theme.spacing(5),
                                    color: theme.colors.accentSoftForeground,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: theme.spacing(1),
                                    children: <Widget>[
                                      Text(title),
                                      const HeroDescription.text(
                                        'Receive updates',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PositionedDirectional(
                              top: theme.spacing(3),
                              end: theme.spacing(4),
                              child: HeroCheckboxControl(
                                size: theme.spacing(5),
                                borderRadius: BorderRadius.circular(
                                  theme.radii.full,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    ),
  );
}
