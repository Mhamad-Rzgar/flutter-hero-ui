import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroInput`, reproducing heroui.com/docs/components/input.
final ComponentDemo inputDemo = ComponentDemo(
  slug: 'input',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      OptionsControl('type', <String>[
        'text',
        'email',
        'password',
        'number',
        'url',
        'tel',
        'search',
      ]),
      ToggleControl('fullWidth'),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      ToggleControl('isInvalid'),
      TextControl('placeholder', initial: 'Enter your name'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: 320,
      child: Center(
        child: HeroInput(
          semanticLabel: 'Playground input',
          placeholder: values.text('placeholder'),
          variant: values.pick('variant', HeroFieldVariant.values),
          type: values.pick('type', HeroInputType.values),
          fullWidth: values.toggle('fullWidth'),
          isDisabled: values.toggle('isDisabled'),
          isReadOnly: values.toggle('isReadOnly'),
          isInvalid: values.toggle('isInvalid'),
        ),
      ),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroInput(\n')
        ..writeln("  placeholder: '${values.text('placeholder')}',");
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      if (values.option('type') != 'text') {
        out.writeln('  type: HeroInputType.${values.option('type')},');
      }
      for (final String flag in <String>[
        'fullWidth',
        'isDisabled',
        'isReadOnly',
        'isInvalid',
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
      builder: (BuildContext context) => const HeroInput(
        semanticLabel: 'Name',
        width: 256,
        placeholder: 'Enter your name',
      ),
      code: '''
HeroInput(
  semanticLabel: 'Name',
  width: 256,
  placeholder: 'Enter your name',
)''',
    ),
    DemoExample(
      title: 'Variants',
      description:
          'primary (default) has the field shadow; secondary is the lower '
          'emphasis variant for surfaces.',
      builder: (BuildContext context) => const SizedBox(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: <Widget>[
            HeroInput(
              fullWidth: true,
              placeholder: 'Primary input',
              variant: HeroFieldVariant.primary,
            ),
            HeroInput(
              fullWidth: true,
              placeholder: 'Secondary input',
              variant: HeroFieldVariant.secondary,
            ),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 240,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: <Widget>[
      HeroInput(
        fullWidth: true,
        placeholder: 'Primary input',
        variant: HeroFieldVariant.primary,
      ),
      HeroInput(
        fullWidth: true,
        placeholder: 'Secondary input',
        variant: HeroFieldVariant.secondary,
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Full Width',
      builder: (BuildContext context) => const SizedBox(
        width: 400,
        child: HeroInput(fullWidth: true, placeholder: 'Full width input'),
      ),
      code: '''
SizedBox(
  width: 400,
  child: HeroInput(fullWidth: true, placeholder: 'Full width input'),
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) => const _ControlledInput(),
      code: '''
class ControlledInput extends StatefulWidget {
  const ControlledInput({super.key});

  @override
  State<ControlledInput> createState() => _ControlledInputState();
}

class _ControlledInputState extends State<ControlledInput> {
  String value = 'heroui.com';

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          HeroInput(
            semanticLabel: 'Domain',
            placeholder: 'domain',
            value: value,
            onChanged: (String next) => setState(() => value = next),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'https://\${value.isEmpty ? 'your-domain' : value}',
              style: theme.typography.sm.copyWith(color: theme.colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'Per-instance overrides with HeroFieldStyle (rounded-xl, a border '
          'and the default background).',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroInput(
          semanticLabel: 'Search projects',
          width: 256,
          placeholder: 'Search projects...',
          style: HeroFieldStyle(
            borderRadius: BorderRadius.circular(theme.radii.xl),
            borderWidth: theme.borderWidth,
            borderColor: theme.colors.border.withValues(alpha: 0.8),
            backgroundColor: theme.colors.defaultColor,
            textStyle: TextStyle(color: theme.colors.foreground),
            placeholderStyle: TextStyle(color: theme.colors.muted),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroInput(
  semanticLabel: 'Search projects',
  width: 256,
  placeholder: 'Search projects...',
  style: HeroFieldStyle(
    borderRadius: BorderRadius.circular(theme.radii.xl),
    borderWidth: theme.borderWidth,
    borderColor: theme.colors.border.withValues(alpha: 0.8),
    backgroundColor: theme.colors.defaultColor,
    textStyle: TextStyle(color: theme.colors.foreground),
    placeholderStyle: TextStyle(color: theme.colors.muted),
  ),
)''',
    ),
  ],
);

class _ControlledInput extends StatefulWidget {
  const _ControlledInput();

  @override
  State<_ControlledInput> createState() => _ControlledInputState();
}

class _ControlledInputState extends State<_ControlledInput> {
  String _value = 'heroui.com';

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: <Widget>[
          HeroInput(
            semanticLabel: 'Domain',
            placeholder: 'domain',
            value: _value,
            onChanged: (String next) => setState(() => _value = next),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'https://${_value.isEmpty ? 'your-domain' : _value}',
              style: theme.typography.sm.copyWith(color: theme.colors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
