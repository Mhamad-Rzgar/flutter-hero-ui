import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroCheckbox`, reproducing
/// heroui.com/docs/components/checkbox.
final ComponentDemo checkboxDemo = ComponentDemo(
  slug: 'checkbox',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      ToggleControl('defaultSelected'),
      ToggleControl('isIndeterminate'),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      ToggleControl('isInvalid'),
      ToggleControl('isRequired'),
      TextControl('label', initial: 'Accept terms and conditions'),
      TextControl('description', initial: 'You can change this later'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroCheckbox(
      // A new key restarts the uncontrolled state when the default changes.
      key: ValueKey<bool>(values.toggle('defaultSelected')),
      label: values.text('label'),
      description: values.text('description').isEmpty
          ? null
          : values.text('description'),
      errorMessage: 'You must accept the terms to continue',
      variant: values.pick('variant', HeroFieldVariant.values),
      defaultSelected: values.toggle('defaultSelected'),
      isIndeterminate: values.toggle('isIndeterminate'),
      isDisabled: values.toggle('isDisabled'),
      isReadOnly: values.toggle('isReadOnly'),
      isInvalid: values.toggle('isInvalid') ? true : null,
      isRequired: values.toggle('isRequired'),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroCheckbox(\n')
        ..writeln("  label: '${values.text('label')}',");
      if (values.text('description').isNotEmpty) {
        out.writeln("  description: '${values.text('description')}',");
      }
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      for (final String flag in <String>[
        'defaultSelected',
        'isIndeterminate',
        'isDisabled',
        'isReadOnly',
        'isInvalid',
        'isRequired',
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
      builder: (BuildContext context) => const _BasicCheckbox(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Variants',
      description:
          'primary (default) for most use cases; secondary is the lower '
          'emphasis variant for surfaces.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          _Caption(
            title: 'Primary variant',
            child: HeroCheckbox(
              name: 'primary',
              label: 'Primary checkbox',
              description: 'Standard styling with default background',
            ),
          ),
          _Caption(
            title: 'Secondary variant',
            child: HeroCheckbox(
              name: 'secondary',
              variant: HeroFieldVariant.secondary,
              label: 'Secondary checkbox',
              description: 'Lower emphasis variant for use in surfaces',
            ),
          ),
        ],
      ),
      code: '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text('Primary variant', style: captionStyle),
        const HeroCheckbox(
          name: 'primary',
          label: 'Primary checkbox',
          description: 'Standard styling with default background',
        ),
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text('Secondary variant', style: captionStyle),
        const HeroCheckbox(
          name: 'secondary',
          variant: HeroFieldVariant.secondary,
          label: 'Secondary checkbox',
          description: 'Lower emphasis variant for use in surfaces',
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Full Rounded',
      description:
          'Round controls of 12, 16, 20 and 24 px; the smallest and largest '
          'resize the checkmark.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: <Widget>[
                HeroLabel.text(
                  'Rounded checkboxes',
                  style: TextStyle(color: theme.colors.muted),
                ),
                _RoundedCheckbox(
                  name: 'small-rounded',
                  label: 'Small size',
                  size: theme.spacing(3),
                  checkmarkSize: theme.spacing(2),
                ),
              ],
            ),
            _RoundedCheckbox(
              name: 'default-rounded',
              label: 'Default size',
              size: theme.spacing(4),
            ),
            _RoundedCheckbox(
              name: 'large-rounded',
              label: 'Large size',
              size: theme.spacing(5),
            ),
            _RoundedCheckbox(
              name: 'xl-rounded',
              label: 'Extra large size',
              size: theme.spacing(6),
              checkmarkSize: theme.spacing(4),
            ),
          ],
        );
      },
      code: '''
HeroCheckbox(
  name: 'small-rounded',
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[
        HeroCheckboxControl(
          size: theme.spacing(3), // 12; 16, 20 and 24 for the others
          borderRadius: BorderRadius.circular(theme.radii.full),
          child: HeroCheckboxIndicator(size: theme.spacing(2)),
        ),
        const Text('Small size'),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => const HeroCheckbox(
        isDisabled: true,
        label: 'Premium Feature',
        description: 'This feature is coming soon',
      ),
      code: '''
const HeroCheckbox(
  isDisabled: true,
  label: 'Premium Feature',
  description: 'This feature is coming soon',
)''',
    ),
    DemoExample(
      title: 'External Label',
      description:
          'A checkbox without its own label; pressing the separate label '
          'toggles it.',
      builder: (BuildContext context) => const _ExternalLabel(),
      code: '''
Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: <Widget>[
    HeroCheckbox(
      isSelected: marketing,
      onChanged: (bool value) => setState(() => marketing = value),
      semanticLabel: 'Send me marketing emails',
      children: const <Widget>[
        HeroCheckboxContent(children: <Widget>[HeroCheckboxControl()]),
      ],
    ),
    HeroLabel.text(
      'Send me marketing emails',
      onPressed: () => setState(() => marketing = !marketing),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'With Description',
      builder: (BuildContext context) => const HeroCheckbox(
        name: 'description-notifications',
        label: 'Email notifications',
        description: 'Get notified when someone mentions you in a comment',
      ),
      code: '''
const HeroCheckbox(
  name: 'description-notifications',
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[HeroCheckboxControl(), Text('Email notifications')],
    ),
    HeroDescription.text(
      'Get notified when someone mentions you in a comment',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Default Selected',
      builder: (BuildContext context) => const HeroCheckbox(
        defaultSelected: true,
        label: 'Enable email notifications',
      ),
      code: '''
const HeroCheckbox(
  defaultSelected: true,
  label: 'Enable email notifications',
)''',
    ),
    DemoExample(
      title: 'Invalid',
      builder: (BuildContext context) => const HeroCheckbox(
        name: 'agreement',
        isInvalid: true,
        isRequired: true,
        children: <Widget>[
          HeroCheckboxContent(
            children: <Widget>[
              HeroCheckboxControl(),
              Text('I agree to the terms'),
            ],
          ),
          HeroFieldError.text('You must accept the terms to continue'),
        ],
      ),
      code: '''
const HeroCheckbox(
  name: 'agreement',
  isInvalid: true,
  isRequired: true,
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[HeroCheckboxControl(), Text('I agree to the terms')],
    ),
    HeroFieldError.text('You must accept the terms to continue'),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledCheckbox(),
      code: '''
bool isSelected = true;

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 12,
  children: <Widget>[
    HeroCheckbox(
      label: 'Email notifications',
      isSelected: isSelected,
      onChanged: (bool value) => setState(() => isSelected = value),
    ),
    Text.rich(
      TextSpan(
        text: 'Status: ',
        children: <InlineSpan>[
          TextSpan(
            text: isSelected ? 'Enabled' : 'Disabled',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      style: theme.typography.sm.copyWith(color: theme.colors.muted),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Indeterminate',
      builder: (BuildContext context) => const _IndeterminateCheckbox(),
      code: '''
bool isIndeterminate = true;
bool isSelected = false;

HeroCheckbox(
  isIndeterminate: isIndeterminate,
  isSelected: isSelected,
  onChanged: (bool selected) => setState(() {
    isSelected = selected;
    isIndeterminate = false;
  }),
  label: 'Select all',
  description: 'Shows indeterminate state (dash icon)',
)''',
    ),
    DemoExample(
      title: 'Form Integration',
      description:
          'A checked box submits its value under its name; unchecked boxes '
          'are left out.',
      builder: (BuildContext context) => const _CheckboxForm(),
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
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          HeroCheckbox(
            name: 'notifications',
            value: 'on',
            label: 'Enable notifications',
          ),
          HeroCheckbox(
            name: 'newsletter',
            value: 'on',
            defaultSelected: true,
            label: 'Subscribe to newsletter',
          ),
          HeroCheckbox(
            name: 'marketing',
            value: 'on',
            label: 'Receive marketing updates',
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: HeroButton(
          type: HeroButtonType.submit,
          size: HeroSize.sm,
          child: const Text('Submit'),
        ),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Render Props',
      description: 'The label and description follow the checked state.',
      builder: (BuildContext context) => HeroCheckbox(
        builder: (BuildContext context, HeroCheckboxState state) => <Widget>[
          HeroCheckboxContent(
            children: <Widget>[
              const HeroCheckboxControl(),
              Text(state.isSelected ? 'Terms accepted' : 'Accept terms'),
            ],
          ),
          HeroDescription.text(
            state.isSelected
                ? 'Thank you for accepting'
                : 'Please read and accept the terms',
          ),
        ],
      ),
      code: '''
HeroCheckbox(
  builder: (BuildContext context, HeroCheckboxState state) => <Widget>[
    HeroCheckboxContent(
      children: <Widget>[
        const HeroCheckboxControl(),
        Text(state.isSelected ? 'Terms accepted' : 'Accept terms'),
      ],
    ),
    HeroDescription.text(
      state.isSelected
          ? 'Thank you for accepting'
          : 'Please read and accept the terms',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'React renders the checkbox through a custom element. In Flutter '
          'the checkbox is composed like any other widget, so the output is '
          'identical to the basic example.',
      builder: (BuildContext context) => const _BasicCheckbox(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Custom Indicator',
      description:
          'The indicator builder draws a heart, a plus or a custom dash '
          'instead of the checkmark.',
      builder: (BuildContext context) => const Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          _CustomIndicatorCheckbox(
            name: 'heart',
            label: 'Heart',
            icon: _heartIcon,
            defaultSelected: true,
          ),
          _CustomIndicatorCheckbox(
            name: 'plus',
            label: 'Plus',
            icon: _plusIcon,
            defaultSelected: true,
          ),
          _CustomIndicatorCheckbox(
            name: 'indeterminate',
            label: 'Indeterminate',
            icon: _lineIcon,
            isIndeterminate: true,
          ),
        ],
      ),
      code: '''
HeroCheckbox(
  name: 'heart',
  defaultSelected: true,
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[
        HeroCheckboxControl(
          child: HeroCheckboxIndicator(
            builder: (BuildContext context, HeroCheckboxState state) =>
                state.isSelected ? const HeroIcon(heartIcon) : null,
          ),
        ),
        const Text('Heart'),
      ],
    ),
  ],
)

// With isIndeterminate: true, test state.isIndeterminate instead.''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A success-soft control with a success fill and a '
          'success-foreground checkmark.',
      builder: (BuildContext context) {
        final HeroColors colors = HeroTheme.of(context).colors;
        return HeroCheckbox(
          children: <Widget>[
            HeroCheckboxContent(
              children: <Widget>[
                HeroCheckboxControl(
                  color: colors.successSoft,
                  selectedColor: colors.success,
                  child: HeroCheckboxIndicator(color: colors.successForeground),
                ),
                const Text('Custom styled checkbox'),
              ],
            ),
          ],
        );
      },
      code: '''
HeroCheckbox(
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[
        HeroCheckboxControl(
          color: theme.colors.successSoft,
          selectedColor: theme.colors.success,
          child: HeroCheckboxIndicator(color: theme.colors.successForeground),
        ),
        const Text('Custom styled checkbox'),
      ],
    ),
  ],
)''',
    ),
  ],
);

const String _basicCode = '''
const HeroCheckbox(
  name: 'basic-terms',
  children: <Widget>[
    HeroCheckboxContent(
      children: <Widget>[
        HeroCheckboxControl(),
        Text('Accept terms and conditions'),
      ],
    ),
  ],
)''';

/// The heart of the custom indicator example (24 × 24 view box).
const HeroIconData _heartIcon = HeroIconData(
  <HeroIconPath>[
    HeroIconPath(
      'M12.62 20.81c-.34.12-.9.12-1.24 0C8.48 19.82 2 15.69 2 8.69 2 5.6 4.49 '
      '3.1 7.56 3.1c1.82 0 3.43.88 4.44 2.24a5.53 5.53 0 0 1 4.44-2.24C19.51 '
      '3.1 22 5.6 22 8.69c0 7-6.48 11.13-9.38 12.12Z',
    ),
  ],
  viewBoxWidth: 24,
  viewBoxHeight: 24,
);

/// Two 3-unit round-capped strokes (`M6 12H18`, `M12 18V6`).
const HeroIconData _plusIcon = HeroIconData(
  <HeroIconPath>[
    HeroIconPath('M6 10.5h12a1.5 1.5 0 0 1 0 3H6a1.5 1.5 0 0 1 0-3z'),
    HeroIconPath('M10.5 6a1.5 1.5 0 0 1 3 0v12a1.5 1.5 0 0 1-3 0z'),
  ],
  viewBoxWidth: 24,
  viewBoxHeight: 24,
);

/// A 3-unit stroke from 3 to 21 (`<line x1="21" x2="3" y1="12" y2="12">`).
const HeroIconData _lineIcon = HeroIconData(
  <HeroIconPath>[HeroIconPath('M3 10.5h18v3H3z')],
  viewBoxWidth: 24,
  viewBoxHeight: 24,
);

class _BasicCheckbox extends StatelessWidget {
  const _BasicCheckbox();

  @override
  Widget build(BuildContext context) {
    return const HeroCheckbox(
      name: 'basic-terms',
      children: <Widget>[
        HeroCheckboxContent(
          children: <Widget>[
            HeroCheckboxControl(),
            Text('Accept terms and conditions'),
          ],
        ),
      ],
    );
  }
}

/// A `text-sm font-medium text-muted` caption above [child].
class _Caption extends StatelessWidget {
  const _Caption({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        Text(
          title,
          style: theme.typography
              .style(HeroFontSize.sm, weight: HeroTypography.medium)
              .copyWith(color: theme.colors.muted),
        ),
        child,
      ],
    );
  }
}

class _RoundedCheckbox extends StatelessWidget {
  const _RoundedCheckbox({
    required this.name,
    required this.label,
    required this.size,
    this.checkmarkSize,
  });

  final String name;
  final String label;
  final double size;
  final double? checkmarkSize;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroCheckbox(
      name: name,
      children: <Widget>[
        HeroCheckboxContent(
          children: <Widget>[
            HeroCheckboxControl(
              size: size,
              borderRadius: BorderRadius.circular(theme.radii.full),
              child: HeroCheckboxIndicator(size: checkmarkSize),
            ),
            Text(label),
          ],
        ),
      ],
    );
  }
}

class _ExternalLabel extends StatefulWidget {
  const _ExternalLabel();

  @override
  State<_ExternalLabel> createState() => _ExternalLabelState();
}

class _ExternalLabelState extends State<_ExternalLabel> {
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: <Widget>[
        HeroCheckbox(
          isSelected: _marketing,
          onChanged: (bool value) => setState(() => _marketing = value),
          semanticLabel: 'Send me marketing emails',
          children: const <Widget>[
            HeroCheckboxContent(children: <Widget>[HeroCheckboxControl()]),
          ],
        ),
        HeroLabel.text(
          'Send me marketing emails',
          onPressed: () => setState(() => _marketing = !_marketing),
        ),
      ],
    );
  }
}

class _ControlledCheckbox extends StatefulWidget {
  const _ControlledCheckbox();

  @override
  State<_ControlledCheckbox> createState() => _ControlledCheckboxState();
}

class _ControlledCheckboxState extends State<_ControlledCheckbox> {
  bool _selected = true;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: <Widget>[
        HeroCheckbox(
          name: 'email-notifications',
          label: 'Email notifications',
          isSelected: _selected,
          onChanged: (bool value) => setState(() => _selected = value),
        ),
        Text.rich(
          TextSpan(
            text: 'Status: ',
            children: <InlineSpan>[
              TextSpan(
                text: _selected ? 'Enabled' : 'Disabled',
                style: const TextStyle(fontWeight: HeroTypography.medium),
              ),
            ],
          ),
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    );
  }
}

class _IndeterminateCheckbox extends StatefulWidget {
  const _IndeterminateCheckbox();

  @override
  State<_IndeterminateCheckbox> createState() => _IndeterminateCheckboxState();
}

class _IndeterminateCheckboxState extends State<_IndeterminateCheckbox> {
  bool _indeterminate = true;
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return HeroCheckbox(
      isIndeterminate: _indeterminate,
      isSelected: _selected,
      onChanged: (bool selected) => setState(() {
        _selected = selected;
        _indeterminate = false;
      }),
      label: 'Select all',
      description: 'Shows indeterminate state (dash icon)',
    );
  }
}

class _CheckboxForm extends StatefulWidget {
  const _CheckboxForm();

  @override
  State<_CheckboxForm> createState() => _CheckboxFormState();
}

class _CheckboxFormState extends State<_CheckboxForm> {
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
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: <Widget>[
              HeroCheckbox(
                name: 'notifications',
                value: 'on',
                label: 'Enable notifications',
              ),
              HeroCheckbox(
                name: 'newsletter',
                value: 'on',
                defaultSelected: true,
                label: 'Subscribe to newsletter',
              ),
              HeroCheckbox(
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

class _CustomIndicatorCheckbox extends StatelessWidget {
  const _CustomIndicatorCheckbox({
    required this.name,
    required this.label,
    required this.icon,
    this.defaultSelected = false,
    this.isIndeterminate = false,
  });

  final String name;
  final String label;
  final HeroIconData icon;
  final bool defaultSelected;
  final bool isIndeterminate;

  @override
  Widget build(BuildContext context) {
    return HeroCheckbox(
      name: name,
      defaultSelected: defaultSelected,
      isIndeterminate: isIndeterminate,
      children: <Widget>[
        HeroCheckboxContent(
          children: <Widget>[
            HeroCheckboxControl(
              child: HeroCheckboxIndicator(
                builder: (BuildContext context, HeroCheckboxState state) =>
                    (isIndeterminate ? state.isIndeterminate : state.isSelected)
                    ? HeroIcon(icon)
                    : null,
              ),
            ),
            Text(label),
          ],
        ),
      ],
    );
  }
}
