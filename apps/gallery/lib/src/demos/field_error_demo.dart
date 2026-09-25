import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroFieldError`, reproducing
/// heroui.com/docs/components/field-error.
final ComponentDemo fieldErrorDemo = ComponentDemo(
  slug: 'field-error',
  playground: Playground(
    controls: const <PlaygroundControl>[
      ToggleControl('isInvalid', initial: true),
      TextControl('text', initial: 'Username must be at least 3 characters'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: 256,
      child: HeroTextField(
        isInvalid: values.toggle('isInvalid'),
        defaultValue: 'jr',
        children: <Widget>[
          const HeroLabel.text('Username'),
          const HeroInput(placeholder: 'Enter username'),
          HeroFieldError.text(values.text('text')),
        ],
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroTextField(
  isInvalid: ${values.toggle('isInvalid')},
  children: const <Widget>[
    HeroLabel.text('Username'),
    HeroInput(placeholder: 'Enter username'),
    HeroFieldError.text('${values.text('text')}'),
  ],
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      description:
          'The error appears while its field is invalid, here while the '
          'username has 1 or 2 characters.',
      builder: (BuildContext context) => const _UsernameField(initial: 'jr'),
      code: _usernameCode,
    ),
    DemoExample(
      title: 'Basic Validation',
      builder: (BuildContext context) => const _UsernameField(initial: ''),
      code: _usernameCode,
    ),
    DemoExample(
      title: 'With Dynamic Messages',
      description:
          'A builder receives the validation result and renders the current '
          'messages.',
      builder: (BuildContext context) => SizedBox(
        width: 256,
        child: HeroTextField(
          type: HeroInputType.password,
          validationBehavior: HeroValidationBehavior.aria,
          validator: _passwordRule,
          children: <Widget>[
            const HeroLabel.text('Password'),
            const HeroInput(),
            HeroFieldError(
              builder: (BuildContext context, HeroValidationResult v) =>
                  Text(v.validationErrors.join(', ')),
            ),
          ],
        ),
      ),
      code: '''
HeroTextField(
  type: HeroInputType.password,
  validationBehavior: HeroValidationBehavior.aria,
  validator: (String? value) {
    final String password = value ?? '';
    if (password.isEmpty) return null;
    if (password.length < 8) return 'At least 8 characters';
    if (!password.contains(RegExp('[A-Z]'))) return 'One uppercase letter';
    if (!password.contains(RegExp('[0-9]'))) return 'One number';
    return null;
  },
  children: <Widget>[
    const HeroLabel.text('Password'),
    const HeroInput(),
    HeroFieldError(
      builder: (BuildContext context, HeroValidationResult validation) =>
          Text(validation.validationErrors.join(', ')),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Custom Validation Logic',
      builder: (BuildContext context) => const _EmailField(),
      code: r'''
String email = '';

final bool isInvalid = email.isNotEmpty && !email.contains('@');

HeroTextField(
  type: HeroInputType.email,
  isInvalid: isInvalid,
  value: email,
  onChanged: (String value) => setState(() => email = value),
  children: const <Widget>[
    HeroLabel.text('Email'),
    HeroInput(),
    HeroFieldError.text('Email must include @ symbol'),
  ],
)''',
    ),
    DemoExample(
      title: 'Multiple Error Messages',
      description: 'Each message on its own line.',
      builder: (BuildContext context) => const _MultipleErrors(),
      code: r'''
final List<String> errors = <String>[
  if (username.length < 3) 'At least 3 characters',
  if (username.contains(' ')) 'No spaces',
  if (username != username.toLowerCase()) 'Lowercase letters only',
];

HeroTextField(
  isInvalid: username.isNotEmpty && errors.isNotEmpty,
  value: username,
  onChanged: (String value) => setState(() => username = value),
  children: <Widget>[
    const HeroLabel.text('Username'),
    const HeroInput(),
    HeroFieldError(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[for (final String error in errors) Text(error)],
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description: 'A monospace field-background input and a medium error.',
      builder: (BuildContext context) => const _HandleField(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
SizedBox(
  width: 256,
  child: HeroTextField(
    isInvalid: handle.isNotEmpty && handle.length < 3,
    value: handle,
    onChanged: (String value) => setState(() => handle = value),
    children: <Widget>[
      const HeroLabel.text('Handle'),
      HeroInput(
        placeholder: 'min. 3 characters',
        // bg-field font-mono
        style: HeroFieldStyle(
          backgroundColor: theme.colors.fieldBackground,
          textStyle: theme.typography.style(
            HeroFieldMetrics.fontSize(context),
            mono: true,
          ),
        ),
      ),
      const HeroFieldError.text(
        'Handle must be at least 3 characters',
        // font-medium
        style: TextStyle(fontWeight: HeroTypography.medium),
      ),
    ],
  ),
)''',
    ),
  ],
);

const String _usernameCode = r'''
String value = 'jr';

final bool isInvalid = value.isNotEmpty && value.length < 3;

SizedBox(
  width: 256,
  child: HeroTextField(
    isInvalid: isInvalid,
    value: value,
    onChanged: (String v) => setState(() => value = v),
    children: const <Widget>[
      HeroLabel.text('Username'),
      HeroInput(placeholder: 'Enter username'),
      HeroFieldError.text('Username must be at least 3 characters'),
    ],
  ),
)''';

String? _passwordRule(String? value) {
  final String password = value ?? '';
  if (password.isEmpty) return null;
  if (password.length < 8) return 'At least 8 characters';
  if (!password.contains(RegExp('[A-Z]'))) return 'One uppercase letter';
  if (!password.contains(RegExp('[0-9]'))) return 'One number';
  return null;
}

class _UsernameField extends StatefulWidget {
  const _UsernameField({required this.initial});

  final String initial;

  @override
  State<_UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<_UsernameField> {
  late String _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: HeroTextField(
        isInvalid: _value.isNotEmpty && _value.length < 3,
        value: _value,
        onChanged: (String value) => setState(() => _value = value),
        children: const <Widget>[
          HeroLabel.text('Username'),
          HeroInput(placeholder: 'Enter username'),
          HeroFieldError.text('Username must be at least 3 characters'),
        ],
      ),
    );
  }
}

class _EmailField extends StatefulWidget {
  const _EmailField();

  @override
  State<_EmailField> createState() => _EmailFieldState();
}

class _EmailFieldState extends State<_EmailField> {
  String _email = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: HeroTextField(
        type: HeroInputType.email,
        isInvalid: _email.isNotEmpty && !_email.contains('@'),
        value: _email,
        onChanged: (String value) => setState(() => _email = value),
        children: const <Widget>[
          HeroLabel.text('Email'),
          HeroInput(),
          HeroFieldError.text('Email must include @ symbol'),
        ],
      ),
    );
  }
}

class _MultipleErrors extends StatefulWidget {
  const _MultipleErrors();

  @override
  State<_MultipleErrors> createState() => _MultipleErrorsState();
}

class _MultipleErrorsState extends State<_MultipleErrors> {
  String _username = 'J D';

  @override
  Widget build(BuildContext context) {
    final List<String> errors = <String>[
      if (_username.length < 3) 'At least 3 characters',
      if (_username.contains(' ')) 'No spaces',
      if (_username != _username.toLowerCase()) 'Lowercase letters only',
    ];
    return SizedBox(
      width: 256,
      child: HeroTextField(
        isInvalid: _username.isNotEmpty && errors.isNotEmpty,
        value: _username,
        onChanged: (String value) => setState(() => _username = value),
        children: <Widget>[
          const HeroLabel.text('Username'),
          const HeroInput(),
          HeroFieldError(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                for (final String error in errors) Text(error),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HandleField extends StatefulWidget {
  const _HandleField();

  @override
  State<_HandleField> createState() => _HandleFieldState();
}

class _HandleFieldState extends State<_HandleField> {
  String _handle = 'jr';

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 256,
      child: HeroTextField(
        isInvalid: _handle.isNotEmpty && _handle.length < 3,
        value: _handle,
        onChanged: (String value) => setState(() => _handle = value),
        children: <Widget>[
          const HeroLabel.text('Handle'),
          HeroInput(
            placeholder: 'min. 3 characters',
            style: HeroFieldStyle(
              backgroundColor: theme.colors.fieldBackground,
              textStyle: theme.typography.style(
                HeroFieldMetrics.fontSize(context),
                mono: true,
              ),
            ),
          ),
          const HeroFieldError.text(
            'Handle must be at least 3 characters',
            style: TextStyle(fontWeight: HeroTypography.medium),
          ),
        ],
      ),
    );
  }
}
