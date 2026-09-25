import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroSwitch`, reproducing
/// heroui.com/docs/components/switch.
final ComponentDemo switchDemo = ComponentDemo(
  slug: 'switch',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('size', <String>['sm', 'md', 'lg'], initial: 'md'),
      OptionsControl('labelPosition', <String>['end', 'start']),
      ToggleControl('defaultSelected'),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      TextControl('label', initial: 'Enable notifications'),
      TextControl('description'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroSwitch(
      // A new key restarts the uncontrolled state when the default changes.
      key: ValueKey<bool>(values.toggle('defaultSelected')),
      label: values.text('label'),
      description: values.text('description').isEmpty
          ? null
          : values.text('description'),
      size: values.pick('size', HeroSize.values),
      labelPosition: values.pick(
        'labelPosition',
        HeroSwitchLabelPosition.values,
      ),
      defaultSelected: values.toggle('defaultSelected'),
      isDisabled: values.toggle('isDisabled'),
      isReadOnly: values.toggle('isReadOnly'),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroSwitch(\n')
        ..writeln("  label: '${values.text('label')}',");
      if (values.text('description').isNotEmpty) {
        out.writeln("  description: '${values.text('description')}',");
      }
      if (values.option('size') != 'md') {
        out.writeln('  size: HeroSize.${values.option('size')},');
      }
      if (values.option('labelPosition') != 'end') {
        out.writeln('  labelPosition: HeroSwitchLabelPosition.start,');
      }
      for (final String flag in <String>[
        'defaultSelected',
        'isDisabled',
        'isReadOnly',
      ]) {
        if (values.toggle(flag)) out.writeln('  $flag: true,');
      }
      out.write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _BasicSwitch(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Sizes',
      builder: (BuildContext context) => const Wrap(
        spacing: 24,
        runSpacing: 16,
        children: <Widget>[
          HeroSwitch(size: HeroSize.sm, label: 'Small'),
          HeroSwitch(label: 'Medium'),
          HeroSwitch(size: HeroSize.lg, label: 'Large'),
        ],
      ),
      code: '''
const Row(
  spacing: 24,
  children: <Widget>[
    HeroSwitch(size: HeroSize.sm, label: 'Small'),
    HeroSwitch(size: HeroSize.md, label: 'Medium'),
    HeroSwitch(size: HeroSize.lg, label: 'Large'),
  ],
)''',
    ),
    DemoExample(
      title: 'With Icons',
      description:
          'Large label-less switches whose thumb icon changes with the state; '
          'four of them tint the track when on.',
      builder: (BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          for (final (
                String name,
                HeroIconData on,
                HeroIconData off,
                Color? tint,
              )
              in _iconSwitches)
            _IconSwitch(name: name, on: on, off: off, tint: tint),
        ],
      ),
      code: '''
HeroSwitch(
  size: HeroSize.lg,
  defaultSelected: true,
  semanticLabel: 'check',
  builder: (BuildContext context, HeroSwitchState state) => <Widget>[
    HeroSwitchContent(
      children: <Widget>[
        HeroSwitchControl(
          // bg-green-500/80 while on
          selectedColor: green,
          selectedHoverColor: green,
          child: HeroSwitchThumb(
            child: HeroSwitchIcon(
              child: state.isSelected
                  ? const HeroIcon(HeroIcons.check)
                  : const Opacity(
                      opacity: 0.7,
                      child: HeroIcon(HeroIcons.power),
                    ),
            ),
          ),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) =>
          const HeroSwitch(isDisabled: true, label: 'Enable notifications'),
      code: '''
const HeroSwitch(isDisabled: true, label: 'Enable notifications')''',
    ),
    DemoExample(
      title: 'Without Label',
      builder: (BuildContext context) => const HeroSwitch(
        semanticLabel: 'Enable notifications',
        children: <Widget>[
          HeroSwitchContent(children: <Widget>[HeroSwitchControl()]),
        ],
      ),
      code: '''
const HeroSwitch(
  semanticLabel: 'Enable notifications',
  children: <Widget>[
    HeroSwitchContent(children: <Widget>[HeroSwitchControl()]),
  ],
)''',
    ),
    DemoExample(
      title: 'With Description',
      builder: (BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: const HeroSwitch(
          label: 'Public profile',
          description: 'Allow others to see your profile information',
        ),
      ),
      code: '''
const HeroSwitch(
  label: 'Public profile',
  description: 'Allow others to see your profile information',
)''',
    ),
    DemoExample(
      title: 'Default Selected',
      builder: (BuildContext context) => const HeroSwitch(
        defaultSelected: true,
        label: 'Enable notifications',
      ),
      code: '''
const HeroSwitch(defaultSelected: true, label: 'Enable notifications')''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledSwitch(),
      code: '''
bool isSelected = false;

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroSwitch(
      label: 'Enable notifications',
      isSelected: isSelected,
      onChanged: (bool value) => setState(() => isSelected = value),
    ),
    Text(
      'Switch is \${isSelected ? 'on' : 'off'}',
      style: theme.typography.sm.copyWith(color: theme.colors.muted),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Label Position',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroSwitch(label: 'Label after'),
          HeroSwitch(
            label: 'Label before',
            labelPosition: HeroSwitchLabelPosition.start,
          ),
        ],
      ),
      code: '''
const HeroSwitch(label: 'Label after')

// Or compose the content with the text first:
const HeroSwitch(
  children: <Widget>[
    HeroSwitchContent(
      children: <Widget>[Text('Label before'), HeroSwitchControl()],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Group',
      builder: (BuildContext context) => const HeroSwitchGroup(
        children: <Widget>[
          HeroSwitch(name: 'notifications', label: 'Allow Notifications'),
          HeroSwitch(name: 'marketing', label: 'Marketing emails'),
          HeroSwitch(name: 'social', label: 'Social media updates'),
        ],
      ),
      code: '''
const HeroSwitchGroup(
  children: <Widget>[
    HeroSwitch(name: 'notifications', label: 'Allow Notifications'),
    HeroSwitch(name: 'marketing', label: 'Marketing emails'),
    HeroSwitch(name: 'social', label: 'Social media updates'),
  ],
)''',
    ),
    DemoExample(
      title: 'Group Horizontal',
      builder: (BuildContext context) => const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: HeroSwitchGroup(
          orientation: Axis.horizontal,
          children: <Widget>[
            HeroSwitch(name: 'notifications', label: 'Notifications'),
            HeroSwitch(name: 'marketing', label: 'Marketing'),
            HeroSwitch(name: 'social', label: 'Social'),
          ],
        ),
      ),
      code: '''
const SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: HeroSwitchGroup(
    orientation: Axis.horizontal,
    children: <Widget>[
      HeroSwitch(name: 'notifications', label: 'Notifications'),
      HeroSwitch(name: 'marketing', label: 'Marketing'),
      HeroSwitch(name: 'social', label: 'Social'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Form Integration',
      description:
          'A switch that is on submits its value under its name; switches '
          'that are off are left out.',
      builder: (BuildContext context) => const _SwitchForm(),
      code: '''
HeroForm(
  onSubmit: (Map<String, Object?> data) => setState(
    () => result = data.entries
        .map((MapEntry<String, Object?> e) => '\${e.key}: \${e.value}')
        .join('\\n'),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      const HeroSwitchGroup(
        children: <Widget>[
          HeroSwitch(
            name: 'notifications',
            value: 'on',
            label: 'Enable notifications',
          ),
          HeroSwitch(
            name: 'newsletter',
            value: 'on',
            defaultSelected: true,
            label: 'Subscribe to newsletter',
          ),
          HeroSwitch(
            name: 'marketing',
            value: 'on',
            label: 'Receive marketing updates',
          ),
        ],
      ),
      Padding(
        padding: EdgeInsets.only(top: theme.spacing(4)),
        child: const HeroButton(
          type: HeroButtonType.submit,
          size: HeroSize.sm,
          child: Text('Submit'),
        ),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Render Props',
      builder: (BuildContext context) => HeroSwitch(
        builder: (BuildContext context, HeroSwitchState state) => <Widget>[
          HeroSwitchContent(
            children: <Widget>[
              const HeroSwitchControl(),
              Text(state.isSelected ? 'Enabled' : 'Disabled'),
            ],
          ),
        ],
      ),
      code: '''
HeroSwitch(
  builder: (BuildContext context, HeroSwitchState state) => <Widget>[
    HeroSwitchContent(
      children: <Widget>[
        const HeroSwitchControl(),
        Text(state.isSelected ? 'Enabled' : 'Disabled'),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'React renders the switch through a custom element. In Flutter the '
          'switch is composed like any other widget, so the output is '
          'identical to the basic example.',
      builder: (BuildContext context) => const _BasicSwitch(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A success-colored track when on, with a label and a description '
          'inside the content.',
      builder: (BuildContext context) {
        final HeroColors colors = HeroTheme.of(context).colors;
        return HeroSwitch(
          children: <Widget>[
            HeroSwitchContent(
              children: <Widget>[
                HeroSwitchControl(
                  selectedColor: colors.success,
                  selectedHoverColor: colors.success,
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
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
        );
      },
      code: '''
HeroSwitch(
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
)''',
    ),
  ],
);

const String _basicCode = '''
const HeroSwitch(
  children: <Widget>[
    HeroSwitchContent(
      children: <Widget>[HeroSwitchControl(), Text('Enable notifications')],
    ),
  ],
)''';

/// Tailwind's `*-500` palette colors at 80%, used by the icons example.
final List<(String, HeroIconData, HeroIconData, Color?)> _iconSwitches =
    <(String, HeroIconData, HeroIconData, Color?)>[
      (
        'check',
        HeroIcons.check,
        HeroIcons.power,
        oklch(0.723, 0.219, 149.579).withValues(alpha: 0.8),
      ),
      ('darkMode', HeroIcons.sun, HeroIcons.moon, null),
      (
        'microphone',
        HeroIcons.microphoneSlash,
        HeroIcons.microphone,
        oklch(0.637, 0.237, 25.331).withValues(alpha: 0.8),
      ),
      (
        'notification',
        HeroIcons.bellFill,
        HeroIcons.bellSlash,
        oklch(0.627, 0.265, 303.9).withValues(alpha: 0.8),
      ),
      (
        'volume',
        HeroIcons.volumeSlashFill,
        HeroIcons.volumeFill,
        oklch(0.623, 0.214, 259.815).withValues(alpha: 0.8),
      ),
    ];

class _BasicSwitch extends StatelessWidget {
  const _BasicSwitch();

  @override
  Widget build(BuildContext context) {
    return const HeroSwitch(
      children: <Widget>[
        HeroSwitchContent(
          children: <Widget>[HeroSwitchControl(), Text('Enable notifications')],
        ),
      ],
    );
  }
}

class _IconSwitch extends StatelessWidget {
  const _IconSwitch({
    required this.name,
    required this.on,
    required this.off,
    required this.tint,
  });

  final String name;
  final HeroIconData on;
  final HeroIconData off;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return HeroSwitch(
      size: HeroSize.lg,
      defaultSelected: true,
      semanticLabel: name,
      builder: (BuildContext context, HeroSwitchState state) => <Widget>[
        HeroSwitchContent(
          children: <Widget>[
            HeroSwitchControl(
              selectedColor: tint,
              selectedHoverColor: tint,
              child: HeroSwitchThumb(
                child: HeroSwitchIcon(
                  child: state.isSelected
                      ? HeroIcon(on)
                      : Opacity(opacity: 0.7, child: HeroIcon(off)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ControlledSwitch extends StatefulWidget {
  const _ControlledSwitch();

  @override
  State<_ControlledSwitch> createState() => _ControlledSwitchState();
}

class _ControlledSwitchState extends State<_ControlledSwitch> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroSwitch(
          label: 'Enable notifications',
          isSelected: _selected,
          onChanged: (bool value) => setState(() => _selected = value),
        ),
        Text(
          'Switch is ${_selected ? 'on' : 'off'}',
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    );
  }
}

class _SwitchForm extends StatefulWidget {
  const _SwitchForm();

  @override
  State<_SwitchForm> createState() => _SwitchFormState();
}

class _SwitchFormState extends State<_SwitchForm> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final String? result = _result;
    return HeroForm(
      onSubmit: (Map<String, Object?> data) => setState(
        () => _result =
            'Form submitted with:\n${data.entries.map((MapEntry<String, Object?> e) => '${e.key}: ${e.value}').join('\n')}',
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          const HeroSwitchGroup(
            children: <Widget>[
              HeroSwitch(
                name: 'notifications',
                value: 'on',
                label: 'Enable notifications',
              ),
              HeroSwitch(
                name: 'newsletter',
                value: 'on',
                defaultSelected: true,
                label: 'Subscribe to newsletter',
              ),
              HeroSwitch(
                name: 'marketing',
                value: 'on',
                label: 'Receive marketing updates',
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: theme.spacing(4)),
            child: const HeroButton(
              type: HeroButtonType.submit,
              size: HeroSize.sm,
              child: Text('Submit'),
            ),
          ),
          if (result != null)
            Text(
              result,
              style: theme.typography.sm.copyWith(color: theme.colors.muted),
            ),
        ],
      ),
    );
  }
}
