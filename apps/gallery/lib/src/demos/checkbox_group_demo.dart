import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroCheckboxGroup`, reproducing
/// heroui.com/docs/components/checkbox-group.
final ComponentDemo checkboxGroupDemo = ComponentDemo(
  slug: 'checkbox-group',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      ToggleControl('isInvalid'),
      ToggleControl('isRequired'),
      TextControl('label', initial: 'Select your interests'),
      TextControl('description', initial: 'Choose all that apply'),
    ],
    builder: (BuildContext context, PlaygroundValues values) =>
        HeroCheckboxGroup(
          name: 'interests',
          label: values.text('label'),
          description: values.text('description').isEmpty
              ? null
              : values.text('description'),
          errorMessage: 'Please select at least one interest.',
          variant: values.pick('variant', HeroFieldVariant.values),
          isDisabled: values.toggle('isDisabled'),
          isReadOnly: values.toggle('isReadOnly'),
          isInvalid: values.toggle('isInvalid') ? true : null,
          isRequired: values.toggle('isRequired'),
          children: _interests,
        ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroCheckboxGroup(\n')
        ..writeln("  name: 'interests',")
        ..writeln("  label: '${values.text('label')}',");
      if (values.text('description').isNotEmpty) {
        out.writeln("  description: '${values.text('description')}',");
      }
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      for (final String flag in <String>[
        'isDisabled',
        'isReadOnly',
        'isInvalid',
        'isRequired',
      ]) {
        if (values.toggle(flag)) out.writeln('  $flag: true,');
      }
      out
        ..writeln('  children: const <Widget>[')
        ..writeln("    HeroCheckbox(value: 'coding', label: 'Coding'),")
        ..writeln("    HeroCheckbox(value: 'design', label: 'Design'),")
        ..writeln("    HeroCheckbox(value: 'writing', label: 'Writing'),")
        ..writeln('  ],')
        ..write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _BasicGroup(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'In Surface',
      description:
          'Inside a Surface, the secondary variant suits the surface '
          'background.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroSurface(
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: EdgeInsets.all(theme.spacing(6)),
          child: const SizedBox(
            width: double.infinity,
            child: _BasicGroup(variant: HeroFieldVariant.secondary),
          ),
        );
      },
      code: '''
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const HeroCheckboxGroup(
    name: 'interests',
    variant: HeroFieldVariant.secondary,
    label: 'Select your interests',
    description: 'Choose all that apply',
    children: <Widget>[
      HeroCheckbox(
        value: 'coding',
        label: 'Coding',
        description: 'Love building software',
      ),
      // ...
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => const HeroCheckboxGroup(
        name: 'disabled-features',
        isDisabled: true,
        label: 'Features',
        description: 'Feature selection is temporarily disabled',
        children: <Widget>[
          HeroCheckbox(
            value: 'feature1',
            label: 'Feature 1',
            description: 'This feature is coming soon',
          ),
          HeroCheckbox(
            value: 'feature2',
            label: 'Feature 2',
            description: 'This feature is coming soon',
          ),
        ],
      ),
      code: '''
const HeroCheckboxGroup(
  name: 'disabled-features',
  isDisabled: true,
  label: 'Features',
  description: 'Feature selection is temporarily disabled',
  children: <Widget>[
    HeroCheckbox(
      value: 'feature1',
      label: 'Feature 1',
      description: 'This feature is coming soon',
    ),
    HeroCheckbox(
      value: 'feature2',
      label: 'Feature 2',
      description: 'This feature is coming soon',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Indeterminate',
      description:
          'A "Select all" checkbox shows the indeterminate state while only '
          'some of the group is checked.',
      builder: (BuildContext context) => const _IndeterminateGroup(),
      code: '''
const List<String> allOptions = <String>['coding', 'design', 'writing'];
Set<String> selected = <String>{'coding'};

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: <Widget>[
    HeroCheckbox(
      name: 'select-all',
      label: 'Select all',
      isIndeterminate:
          selected.isNotEmpty && selected.length < allOptions.length,
      isSelected: selected.length == allOptions.length,
      onChanged: (bool isSelected) => setState(
        () => selected = isSelected ? allOptions.toSet() : <String>{},
      ),
    ),
    Padding(
      padding: EdgeInsetsDirectional.only(start: theme.spacing(6)),
      child: HeroCheckboxGroup(
        value: selected,
        onChanged: (Set<String> value) => setState(() => selected = value),
        children: const <Widget>[
          HeroCheckbox(value: 'coding', label: 'Coding'),
          HeroCheckbox(value: 'design', label: 'Design'),
          HeroCheckbox(value: 'writing', label: 'Writing'),
        ],
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledGroup(),
      code: '''
Set<String> selected = <String>{'coding', 'design'};

SizedBox(
  width: 320,
  child: HeroCheckboxGroup(
    name: 'skills',
    value: selected,
    onChanged: (Set<String> value) => setState(() => selected = value),
    children: <Widget>[
      const HeroLabel.text('Your skills'),
      const HeroCheckbox(value: 'coding', label: 'Coding'),
      const HeroCheckbox(value: 'design', label: 'Design'),
      const HeroCheckbox(value: 'writing', label: 'Writing'),
      Padding(
        padding: EdgeInsets.symmetric(vertical: theme.spacing(4)),
        child: Text(
          'Selected: \${selected.isEmpty ? 'None' : selected.join(', ')}',
          style: theme.typography
              .style(HeroFontSize.sm, weight: HeroTypography.medium)
              .copyWith(color: theme.colors.muted),
        ),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Validation',
      description:
          'A required group blocks submission until one option is checked.',
      builder: (BuildContext context) => const _ValidationGroup(),
      code: '''
HeroForm(
  onSubmit: (Map<String, Object?> data) => setState(
    () => result = 'Selected preferences: '
        '\${(data['preferences']! as List<String>).join(', ')}',
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: const <Widget>[
      HeroCheckboxGroup(
        name: 'preferences',
        isRequired: true,
        children: <Widget>[
          HeroLabel.text('Preferences'),
          HeroCheckbox(value: 'email', label: 'Email notifications'),
          HeroCheckbox(value: 'sms', label: 'SMS notifications'),
          HeroCheckbox(value: 'push', label: 'Push notifications'),
          HeroFieldError.text(
            'Please select at least one notification method.',
          ),
        ],
      ),
      HeroButton(type: HeroButtonType.submit, child: Text('Submit')),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Features and Add-ons Example',
      description:
          'Card checkboxes: a surface card (radius 24) turning accent/10 '
          'when checked, with an icon, a title, a description and a round '
          'control in the top-end corner.',
      builder: (BuildContext context) => const _FeaturesAndAddOns(),
      code: '''
HeroCheckboxGroup(
  name: 'notification-preferences',
  label: 'Notification preferences',
  description: 'Choose how you want to receive updates',
  children: <Widget>[
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: <Widget>[
        for (final AddOn addon in addOns)
          HeroCheckbox(
            value: addon.value,
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
                                addon.icon,
                                size: theme.spacing(5),
                                color: theme.colors.accentSoftForeground,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: theme.spacing(1),
                                children: <Widget>[
                                  Text(addon.title),
                                  HeroDescription.text(addon.description),
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
                            borderRadius:
                                BorderRadius.circular(theme.radii.full),
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
)''',
    ),
    DemoExample(
      title: 'With Custom Indicator',
      description: 'An × glyph replaces the checkmark.',
      builder: (BuildContext context) => const HeroCheckboxGroup(
        name: 'features',
        label: 'Features',
        description: 'Select the features you want',
        children: <Widget>[
          _CrossCheckbox(
            value: 'notifications',
            label: 'Email notifications',
            description: 'Receive updates via email',
          ),
          _CrossCheckbox(
            value: 'newsletter',
            label: 'Newsletter',
            description: 'Get weekly newsletters',
          ),
        ],
      ),
      code: '''
HeroCheckboxGroup(
  name: 'features',
  label: 'Features',
  description: 'Select the features you want',
  children: <Widget>[
    HeroCheckbox(
      value: 'notifications',
      children: <Widget>[
        HeroCheckboxContent(
          children: <Widget>[
            HeroCheckboxControl(
              child: HeroCheckboxIndicator(
                builder: (BuildContext context, HeroCheckboxState state) =>
                    state.isSelected ? const HeroIcon(crossIcon) : null,
              ),
            ),
            const Text('Email notifications'),
          ],
        ),
        const HeroDescription.text('Receive updates via email'),
      ],
    ),
    // ...
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'React renders the group through a custom element. In Flutter the '
          'group is composed like any other widget, so the output is '
          'identical to the basic example.',
      builder: (BuildContext context) => const _BasicGroup(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A 12 px gap instead of the checkbox margins and success-colored '
          'controls.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroCheckboxGroup(
          name: 'notification-channels',
          defaultValue: const <String>{'email'},
          spacing: theme.spacing(3),
          itemMargin: EdgeInsets.zero,
          label: 'Notification channels',
          description: 'Choose how we should reach you for account updates.',
          children: <Widget>[
            for (final (String label, String value) in _channels)
              HeroCheckbox(
                value: value,
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
                      Text(label),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
      code: '''
HeroCheckboxGroup(
  name: 'notification-channels',
  defaultValue: const <String>{'email'},
  spacing: theme.spacing(3),
  itemMargin: EdgeInsets.zero,
  label: 'Notification channels',
  description: 'Choose how we should reach you for account updates.',
  children: <Widget>[
    for (final (String label, String value) in <(String, String)>[
      ('Email', 'email'),
      ('SMS', 'sms'),
      ('Push', 'push'),
    ])
      HeroCheckbox(
        value: value,
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
              Text(label),
            ],
          ),
        ],
      ),
  ],
)''',
    ),
  ],
);

const String _basicCode = '''
const HeroCheckboxGroup(
  name: 'interests',
  label: 'Select your interests',
  description: 'Choose all that apply',
  children: <Widget>[
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
  ],
)''';

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

const List<(String, String)> _channels = <(String, String)>[
  ('Email', 'email'),
  ('SMS', 'sms'),
  ('Push', 'push'),
];

const List<String> _allOptions = <String>['coding', 'design', 'writing'];

/// Two 2-unit round-capped strokes (`M6 18L18 6M6 6l12 12`) in a 24 × 24
/// view box.
const HeroIconData _crossIcon = HeroIconData(
  <HeroIconPath>[
    HeroIconPath(
      'M5.293 17.293L17.293 5.293a1 1 0 0 1 1.414 1.414L6.707 18.707a1 1 0 0 '
      '1-1.414-1.414z',
    ),
    HeroIconPath(
      'M6.707 5.293L18.707 17.293a1 1 0 0 1-1.414 1.414L5.293 6.707a1 1 0 0 '
      '1 1.414-1.414z',
    ),
  ],
  viewBoxWidth: 24,
  viewBoxHeight: 24,
);

class _BasicGroup extends StatelessWidget {
  const _BasicGroup({this.variant = HeroFieldVariant.primary});

  final HeroFieldVariant variant;

  @override
  Widget build(BuildContext context) {
    return HeroCheckboxGroup(
      name: 'interests',
      variant: variant,
      label: 'Select your interests',
      description: 'Choose all that apply',
      children: _interests,
    );
  }
}

class _IndeterminateGroup extends StatefulWidget {
  const _IndeterminateGroup();

  @override
  State<_IndeterminateGroup> createState() => _IndeterminateGroupState();
}

class _IndeterminateGroupState extends State<_IndeterminateGroup> {
  Set<String> _selected = <String>{'coding'};

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HeroCheckbox(
          name: 'select-all',
          label: 'Select all',
          isIndeterminate:
              _selected.isNotEmpty && _selected.length < _allOptions.length,
          isSelected: _selected.length == _allOptions.length,
          onChanged: (bool isSelected) => setState(
            () => _selected = isSelected ? _allOptions.toSet() : <String>{},
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.only(start: theme.spacing(6)),
          child: HeroCheckboxGroup(
            value: _selected,
            onChanged: (Set<String> value) => setState(() => _selected = value),
            children: const <Widget>[
              HeroCheckbox(value: 'coding', label: 'Coding'),
              HeroCheckbox(value: 'design', label: 'Design'),
              HeroCheckbox(value: 'writing', label: 'Writing'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlledGroup extends StatefulWidget {
  const _ControlledGroup();

  @override
  State<_ControlledGroup> createState() => _ControlledGroupState();
}

class _ControlledGroupState extends State<_ControlledGroup> {
  Set<String> _selected = <String>{'coding', 'design'};

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 320,
      child: HeroCheckboxGroup(
        name: 'skills',
        value: _selected,
        onChanged: (Set<String> value) => setState(() => _selected = value),
        children: <Widget>[
          const HeroLabel.text('Your skills'),
          const HeroCheckbox(value: 'coding', label: 'Coding'),
          const HeroCheckbox(value: 'design', label: 'Design'),
          const HeroCheckbox(value: 'writing', label: 'Writing'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: theme.spacing(4)),
            child: Text(
              'Selected: ${_selected.isEmpty ? 'None' : _selected.join(', ')}',
              style: theme.typography
                  .style(HeroFontSize.sm, weight: HeroTypography.medium)
                  .copyWith(color: theme.colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationGroup extends StatefulWidget {
  const _ValidationGroup();

  @override
  State<_ValidationGroup> createState() => _ValidationGroupState();
}

class _ValidationGroupState extends State<_ValidationGroup> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final String? result = _result;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: theme.spacing(4)),
      child: HeroForm(
        onSubmit: (Map<String, Object?> data) => setState(
          () => _result =
              'Selected preferences: ${(data['preferences']! as List<String>).join(', ')}',
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            const HeroCheckboxGroup(
              name: 'preferences',
              isRequired: true,
              children: <Widget>[
                HeroLabel.text('Preferences'),
                HeroCheckbox(value: 'email', label: 'Email notifications'),
                HeroCheckbox(value: 'sms', label: 'SMS notifications'),
                HeroCheckbox(value: 'push', label: 'Push notifications'),
                HeroFieldError.text(
                  'Please select at least one notification method.',
                ),
              ],
            ),
            const HeroButton(
              type: HeroButtonType.submit,
              child: Text('Submit'),
            ),
            if (result != null)
              Text(
                result,
                style: theme.typography.sm.copyWith(color: theme.colors.muted),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeaturesAndAddOns extends StatelessWidget {
  const _FeaturesAndAddOns();

  static const List<(HeroIconData, String, String, String)> _addOns =
      <(HeroIconData, String, String, String)>[
        (
          HeroIcons.envelope,
          'Email Notifications',
          'Receive updates via email',
          'email',
        ),
        (
          HeroIcons.comment,
          'SMS Alerts',
          'Get instant SMS notifications',
          'sms',
        ),
        (
          HeroIcons.bell,
          'Push Notifications',
          'Browser and mobile push alerts',
          'push',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing(4),
        vertical: theme.spacing(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320),
        child: HeroCheckboxGroup(
          name: 'notification-preferences',
          label: 'Notification preferences',
          description: 'Choose how you want to receive updates',
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.spacing(2),
              children: <Widget>[
                for (final (
                      HeroIconData icon,
                      String title,
                      String description,
                      String value,
                    )
                    in _addOns)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: theme.spacing(4),
                                    children: <Widget>[
                                      HeroIcon(
                                        icon,
                                        size: theme.spacing(5),
                                        color:
                                            theme.colors.accentSoftForeground,
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: theme.spacing(1),
                                          children: <Widget>[
                                            Text(title),
                                            HeroDescription.text(description),
                                          ],
                                        ),
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
      ),
    );
  }
}

class _CrossCheckbox extends StatelessWidget {
  const _CrossCheckbox({
    required this.value,
    required this.label,
    required this.description,
  });

  final String value;
  final String label;
  final String description;

  @override
  Widget build(BuildContext context) {
    return HeroCheckbox(
      value: value,
      children: <Widget>[
        HeroCheckboxContent(
          children: <Widget>[
            HeroCheckboxControl(
              child: HeroCheckboxIndicator(
                builder: (BuildContext context, HeroCheckboxState state) =>
                    state.isSelected ? const HeroIcon(_crossIcon) : null,
              ),
            ),
            Text(label),
          ],
        ),
        HeroDescription.text(description),
      ],
    );
  }
}
