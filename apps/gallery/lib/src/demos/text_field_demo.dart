import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroTextField`, reproducing
/// heroui.com/docs/components/text-field.
final ComponentDemo textFieldDemo = ComponentDemo(
  slug: 'text-field',
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
      ]),
      ToggleControl('isRequired'),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      ToggleControl('isInvalid'),
      ToggleControl('isMultiline'),
      TextControl('label', initial: 'Email'),
      TextControl('placeholder', initial: 'Enter your email'),
      TextControl('description', initial: "We'll never share your email"),
      TextControl('errorMessage', initial: 'Please enter a valid value'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: 256,
      child: HeroTextField(
        label: values.text('label'),
        placeholder: values.text('placeholder'),
        description: values.text('description'),
        errorMessage: values.text('errorMessage'),
        variant: values.pick('variant', HeroFieldVariant.values),
        type: values.pick('type', HeroInputType.values),
        isRequired: values.toggle('isRequired'),
        isDisabled: values.toggle('isDisabled'),
        isReadOnly: values.toggle('isReadOnly'),
        isInvalid: values.toggle('isInvalid') ? true : null,
        isMultiline: values.toggle('isMultiline'),
      ),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroTextField(\n')
        ..writeln("  label: '${values.text('label')}',")
        ..writeln("  placeholder: '${values.text('placeholder')}',")
        ..writeln('  description: "${values.text('description')}",')
        ..writeln("  errorMessage: '${values.text('errorMessage')}',");
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      if (values.option('type') != 'text') {
        out.writeln('  type: HeroInputType.${values.option('type')},');
      }
      for (final String flag in <String>[
        'isRequired',
        'isDisabled',
        'isReadOnly',
        'isInvalid',
        'isMultiline',
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
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: HeroTextField(
          name: 'email',
          type: HeroInputType.email,
          children: <Widget>[
            HeroLabel.text('Email'),
            HeroInput(placeholder: 'Enter your email'),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'email',
    type: HeroInputType.email,
    children: const <Widget>[
      HeroLabel.text('Email'),
      HeroInput(placeholder: 'Enter your email'),
    ],
  ),
)

// or, with the convenience parameters:
const HeroTextField(
  name: 'email',
  type: HeroInputType.email,
  label: 'Email',
  placeholder: 'Enter your email',
)''',
    ),
    DemoExample(
      title: 'In Surface',
      description:
          'Inside a Surface, use the secondary variant for the lower emphasis '
          'fields suited to surface backgrounds.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroSurface(
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: EdgeInsets.all(theme.spacing(6)),
          child: const SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: <Widget>[
                HeroTextField(
                  name: 'name',
                  variant: HeroFieldVariant.secondary,
                  children: <Widget>[
                    HeroLabel.text('Your name'),
                    HeroInput(placeholder: 'John'),
                    HeroDescription.text(
                      "We'll never share this with anyone else",
                    ),
                  ],
                ),
                HeroTextField(
                  name: 'email',
                  type: HeroInputType.email,
                  variant: HeroFieldVariant.secondary,
                  children: <Widget>[
                    HeroLabel.text('Email'),
                    HeroInput(placeholder: 'john@example.com'),
                  ],
                ),
                HeroTextField(
                  name: 'bio',
                  variant: HeroFieldVariant.secondary,
                  children: <Widget>[
                    HeroLabel.text('Bio'),
                    HeroTextArea(
                      placeholder: 'Tell us about yourself...',
                      rows: 4,
                    ),
                    HeroDescription.text('Minimum 4 rows'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const SizedBox(
    width: 340,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        HeroTextField(
          name: 'name',
          variant: HeroFieldVariant.secondary,
          children: <Widget>[
            HeroLabel.text('Your name'),
            HeroInput(placeholder: 'John'),
            HeroDescription.text("We'll never share this with anyone else"),
          ],
        ),
        HeroTextField(
          name: 'email',
          type: HeroInputType.email,
          variant: HeroFieldVariant.secondary,
          children: <Widget>[
            HeroLabel.text('Email'),
            HeroInput(placeholder: 'john@example.com'),
          ],
        ),
        HeroTextField(
          name: 'bio',
          variant: HeroFieldVariant.secondary,
          children: <Widget>[
            HeroLabel.text('Bio'),
            HeroTextArea(placeholder: 'Tell us about yourself...', rows: 4),
            HeroDescription.text('Minimum 4 rows'),
          ],
        ),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'With Description',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: HeroTextField(
          name: 'username',
          children: <Widget>[
            HeroLabel.text('Username'),
            HeroInput(placeholder: 'Enter username'),
            HeroDescription.text('Choose a unique username for your account'),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'username',
    children: const <Widget>[
      HeroLabel.text('Username'),
      HeroInput(placeholder: 'Enter username'),
      HeroDescription.text('Choose a unique username for your account'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Required Field',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: HeroTextField(
          name: 'fullName',
          isRequired: true,
          children: <Widget>[
            HeroLabel.text('Full Name'),
            HeroInput(placeholder: 'John Doe'),
            HeroDescription.text('This field is required'),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'fullName',
    isRequired: true,
    children: const <Widget>[
      HeroLabel.text('Full Name'),
      HeroInput(placeholder: 'John Doe'),
      HeroDescription.text('This field is required'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: HeroTextField(
          name: 'accountId',
          value: 'USR-12345',
          isDisabled: true,
          children: <Widget>[
            HeroLabel.text('Account ID'),
            HeroInput(placeholder: 'Auto-generated'),
            HeroDescription.text('This field cannot be edited'),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'accountId',
    value: 'USR-12345',
    isDisabled: true,
    children: const <Widget>[
      HeroLabel.text('Account ID'),
      HeroInput(placeholder: 'Auto-generated'),
      HeroDescription.text('This field cannot be edited'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Full Width',
      builder: (BuildContext context) => const SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            HeroTextField(
              name: 'name',
              fullWidth: true,
              children: <Widget>[
                HeroLabel.text('Your name'),
                HeroInput(placeholder: 'John'),
              ],
            ),
            HeroTextField(
              name: 'password',
              type: HeroInputType.password,
              fullWidth: true,
              isInvalid: true,
              isRequired: true,
              children: <Widget>[
                HeroLabel.text('Password'),
                HeroInput(),
                HeroFieldError.text(
                  'Password must be longer than 8 characters',
                ),
              ],
            ),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 400,
  child: Column(
    spacing: 16,
    children: <Widget>[
      HeroTextField(
        name: 'name',
        fullWidth: true,
        children: const <Widget>[
          HeroLabel.text('Your name'),
          HeroInput(placeholder: 'John'),
        ],
      ),
      HeroTextField(
        name: 'password',
        type: HeroInputType.password,
        fullWidth: true,
        isInvalid: true,
        isRequired: true,
        children: const <Widget>[
          HeroLabel.text('Password'),
          HeroInput(),
          HeroFieldError.text('Password must be longer than 8 characters'),
        ],
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Validation',
      description:
          'Use isInvalid together with HeroFieldError to surface validation '
          'messages.',
      builder: (BuildContext context) => const _Validation(),
      code: r'''
String username = '';
String bio = '';

final bool isUsernameInvalid = username.isNotEmpty && username.length < 3;
final bool isBioInvalid = bio.isNotEmpty && bio.length < 20;

SizedBox(
  width: 256,
  child: Column(
    spacing: 16,
    children: <Widget>[
      HeroTextField(
        name: 'username',
        isRequired: true,
        isInvalid: isUsernameInvalid,
        value: username,
        onChanged: (String value) => setState(() => username = value),
        children: <Widget>[
          const HeroLabel.text('Username'),
          const HeroInput(placeholder: 'jane_doe'),
          if (isUsernameInvalid)
            const HeroFieldError.text(
              'Username must be at least 3 characters.',
            )
          else
            const HeroDescription.text(
              'Choose a unique username for your profile.',
            ),
        ],
      ),
      HeroTextField(
        name: 'bio',
        isRequired: true,
        isInvalid: isBioInvalid,
        value: bio,
        onChanged: (String value) => setState(() => bio = value),
        children: <Widget>[
          const HeroLabel.text('Bio'),
          const HeroTextArea(placeholder: 'Tell us about yourself...'),
          if (isBioInvalid)
            const HeroFieldError.text(
              'Bio must contain at least 20 characters.',
            )
          else
            HeroDescription.text(
              'Minimum 20 characters (${bio.length}/20).',
            ),
        ],
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Controlled',
      description:
          'Control the value to synchronize counters, previews, or '
          'formatting.',
      builder: (BuildContext context) => const _Controlled(),
      code: r'''
String name = '';
String bio = '';

SizedBox(
  width: 256,
  child: Column(
    spacing: 16,
    children: <Widget>[
      HeroTextField(
        name: 'name',
        value: name,
        onChanged: (String value) => setState(() => name = value),
        children: <Widget>[
          const HeroLabel.text('Display name'),
          const HeroInput(placeholder: 'Jane'),
          HeroDescription.text('Characters: ${name.length}'),
        ],
      ),
      HeroTextField(
        name: 'bio',
        value: bio,
        onChanged: (String value) => setState(() => bio = value),
        children: <Widget>[
          const HeroLabel.text('Bio'),
          const HeroTextArea(placeholder: 'Tell us about yourself...'),
          HeroDescription.text('Characters: ${bio.length} / 200'),
        ],
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Error Message',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: HeroTextField(
          name: 'email',
          type: HeroInputType.email,
          isInvalid: true,
          children: <Widget>[
            HeroLabel.text('Email'),
            HeroInput(placeholder: 'user@example.com'),
            HeroFieldError.text('Please enter a valid email address'),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'email',
    type: HeroInputType.email,
    isInvalid: true,
    children: const <Widget>[
      HeroLabel.text('Email'),
      HeroInput(placeholder: 'user@example.com'),
      HeroFieldError.text('Please enter a valid email address'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'TextArea',
      description:
          'Use HeroTextArea instead of HeroInput for multiline content.',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: HeroTextField(
          name: 'message',
          children: <Widget>[
            HeroLabel.text('Message'),
            HeroTextArea(placeholder: 'Write your message here...', rows: 4),
            HeroDescription.text('Maximum 500 characters'),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'message',
    children: const <Widget>[
      HeroLabel.text('Message'),
      HeroTextArea(placeholder: 'Write your message here...', rows: 4),
      HeroDescription.text('Maximum 500 characters'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Input Types',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            HeroTextField(
              name: 'password',
              type: HeroInputType.password,
              children: <Widget>[
                HeroLabel.text('Password'),
                HeroInput(placeholder: '••••••••'),
              ],
            ),
            HeroTextField(
              name: 'age',
              type: HeroInputType.number,
              children: <Widget>[
                HeroLabel.text('Age'),
                HeroInput(min: 0, max: 150, placeholder: '21'),
              ],
            ),
            HeroTextField(
              name: 'email',
              type: HeroInputType.email,
              children: <Widget>[
                HeroLabel.text('Email'),
                HeroInput(placeholder: 'user@example.com'),
              ],
            ),
            HeroTextField(
              name: 'website',
              type: HeroInputType.url,
              children: <Widget>[
                HeroLabel.text('Website'),
                HeroInput(placeholder: 'https://example.com'),
              ],
            ),
            HeroTextField(
              name: 'phone',
              type: HeroInputType.tel,
              children: <Widget>[
                HeroLabel.text('Phone'),
                HeroInput(placeholder: '+1 (555) 000-0000'),
              ],
            ),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      HeroTextField(
        name: 'password',
        type: HeroInputType.password,
        children: const <Widget>[
          HeroLabel.text('Password'),
          HeroInput(placeholder: '••••••••'),
        ],
      ),
      HeroTextField(
        name: 'age',
        type: HeroInputType.number,
        children: const <Widget>[
          HeroLabel.text('Age'),
          HeroInput(min: 0, max: 150, placeholder: '21'),
        ],
      ),
      HeroTextField(
        name: 'email',
        type: HeroInputType.email,
        children: const <Widget>[
          HeroLabel.text('Email'),
          HeroInput(placeholder: 'user@example.com'),
        ],
      ),
      HeroTextField(
        name: 'website',
        type: HeroInputType.url,
        children: const <Widget>[
          HeroLabel.text('Website'),
          HeroInput(placeholder: 'https://example.com'),
        ],
      ),
      HeroTextField(
        name: 'phone',
        type: HeroInputType.tel,
        children: const <Widget>[
          HeroLabel.text('Phone'),
          HeroInput(placeholder: '+1 (555) 000-0000'),
        ],
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'builder receives the field state (isFocusWithin, isInvalid, '
          'isRequired, ...) and returns the parts.',
      builder: (BuildContext context) => SizedBox(
        width: 256,
        child: HeroTextField(
          name: 'email',
          type: HeroInputType.email,
          builder: (BuildContext context, HeroTextFieldState state) => <Widget>[
            HeroLabel.text(state.isFocusWithin ? 'Email (editing)' : 'Email'),
            const HeroInput(placeholder: 'Enter your email'),
          ],
        ),
      ),
      code: '''
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'email',
    type: HeroInputType.email,
    builder: (BuildContext context, HeroTextFieldState state) => <Widget>[
      HeroLabel.text(state.isFocusWithin ? 'Email (editing)' : 'Email'),
      const HeroInput(placeholder: 'Enter your email'),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A 6 px gap and an input restyled with HeroFieldStyle: rounded-xl, '
          'a border, the surface background, a hairline ring and a soft '
          'focus ring.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return SizedBox(
          width: 256,
          child: HeroTextField(
            name: 'email',
            type: HeroInputType.email,
            spacing: theme.spacing(1.5),
            children: <Widget>[
              const HeroLabel.text('Email'),
              HeroInput(
                placeholder: 'you@email.com',
                style: _customInputStyle(theme),
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
SizedBox(
  width: 256,
  child: HeroTextField(
    name: 'email',
    type: HeroInputType.email,
    spacing: theme.spacing(1.5), // gap-1.5
    children: <Widget>[
      const HeroLabel.text('Email'),
      HeroInput(
        placeholder: 'you@email.com',
        style: HeroFieldStyle(
          borderRadius: BorderRadius.circular(theme.radii.xl),
          borderWidth: theme.borderWidth,
          borderColor: theme.colors.border.withValues(alpha: 0.8),
          backgroundColor: theme.colors.surface,
          // shadow-sm plus a ring-1 (black/5, white/10 in dark mode)
          shadow: HeroShadow(
            boxShadows: <BoxShadow>[
              BoxShadow(
                color: theme.isDark
                    ? theme.colors.white.withValues(alpha: 0.1)
                    : theme.colors.black.withValues(alpha: 0.05),
                spreadRadius: 1,
              ),
              ...theme.shadows.surface.boxShadows,
            ],
          ),
          focusRingColor: theme.colors.muted.withValues(alpha: 0.3),
          textStyle: theme.typography.sm.copyWith(
            color: theme.colors.foreground,
          ),
          placeholderStyle: TextStyle(color: theme.colors.muted),
        ),
      ),
    ],
  ),
)''',
    ),
  ],
);

HeroFieldStyle _customInputStyle(HeroThemeData theme) => HeroFieldStyle(
  borderRadius: BorderRadius.circular(theme.radii.xl),
  borderWidth: theme.borderWidth,
  borderColor: theme.colors.border.withValues(alpha: 0.8),
  backgroundColor: theme.colors.surface,
  shadow: HeroShadow(
    boxShadows: <BoxShadow>[
      BoxShadow(
        color: theme.isDark
            ? theme.colors.white.withValues(alpha: 0.1)
            : theme.colors.black.withValues(alpha: 0.05),
        spreadRadius: 1,
      ),
      ...theme.shadows.surface.boxShadows,
    ],
  ),
  focusRingColor: theme.colors.muted.withValues(alpha: 0.3),
  textStyle: theme.typography.sm.copyWith(color: theme.colors.foreground),
  placeholderStyle: TextStyle(color: theme.colors.muted),
);

class _Validation extends StatefulWidget {
  const _Validation();

  @override
  State<_Validation> createState() => _ValidationState();
}

class _ValidationState extends State<_Validation> {
  String _username = '';
  String _bio = '';

  @override
  Widget build(BuildContext context) {
    final bool isUsernameInvalid = _username.isNotEmpty && _username.length < 3;
    final bool isBioInvalid = _bio.isNotEmpty && _bio.length < 20;
    return SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          HeroTextField(
            name: 'username',
            isRequired: true,
            isInvalid: isUsernameInvalid,
            value: _username,
            onChanged: (String value) => setState(() => _username = value),
            children: <Widget>[
              const HeroLabel.text('Username'),
              const HeroInput(placeholder: 'jane_doe'),
              if (isUsernameInvalid)
                const HeroFieldError.text(
                  'Username must be at least 3 characters.',
                )
              else
                const HeroDescription.text(
                  'Choose a unique username for your profile.',
                ),
            ],
          ),
          HeroTextField(
            name: 'bio',
            isRequired: true,
            isInvalid: isBioInvalid,
            value: _bio,
            onChanged: (String value) => setState(() => _bio = value),
            children: <Widget>[
              const HeroLabel.text('Bio'),
              const HeroTextArea(placeholder: 'Tell us about yourself...'),
              if (isBioInvalid)
                const HeroFieldError.text(
                  'Bio must contain at least 20 characters.',
                )
              else
                HeroDescription.text(
                  'Minimum 20 characters (${_bio.length}/20).',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Controlled extends StatefulWidget {
  const _Controlled();

  @override
  State<_Controlled> createState() => _ControlledState();
}

class _ControlledState extends State<_Controlled> {
  String _name = '';
  String _bio = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          HeroTextField(
            name: 'name',
            value: _name,
            onChanged: (String value) => setState(() => _name = value),
            children: <Widget>[
              const HeroLabel.text('Display name'),
              const HeroInput(placeholder: 'Jane'),
              HeroDescription.text('Characters: ${_name.length}'),
            ],
          ),
          HeroTextField(
            name: 'bio',
            value: _bio,
            onChanged: (String value) => setState(() => _bio = value),
            children: <Widget>[
              const HeroLabel.text('Bio'),
              const HeroTextArea(placeholder: 'Tell us about yourself...'),
              HeroDescription.text('Characters: ${_bio.length} / 200'),
            ],
          ),
        ],
      ),
    );
  }
}
