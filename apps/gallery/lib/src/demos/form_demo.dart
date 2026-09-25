import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroForm`, reproducing heroui.com/docs/components/form.
final ComponentDemo formDemo = ComponentDemo(
  slug: 'form',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('validationBehavior', <String>['native', 'aria']),
    ],
    builder: (BuildContext context, PlaygroundValues values) => _SignUpForm(
      behavior: values.pick(
        'validationBehavior',
        HeroValidationBehavior.values,
      ),
    ),
    code: (PlaygroundValues values) =>
        '''
HeroForm(
  validationBehavior: HeroValidationBehavior.${values.option('validationBehavior')},
  onSubmit: (Map<String, Object?> data) => debugPrint('\$data'),
  child: ...,
)''',
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _SignUpForm(),
      code: _signUpCode,
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'React renders the form through a custom element. In Flutter the '
          'form is composed like any other widget, so the output is '
          'identical to the basic example.',
      builder: (BuildContext context) => const _SignUpForm(),
      code: _signUpCode,
    ),
    DemoExample(
      title: 'Customization',
      description:
          'The form laid out as a card: rounded-xl, a border, the surface '
          'background, padding and a small shadow.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroForm(
          child: Container(
            width: 320,
            padding: EdgeInsets.all(theme.spacing(4)),
            decoration: ShapeDecoration(
              color: theme.colors.surface,
              shape: theme.shapeAll(
                theme.radii.xl,
                side: BorderSide(
                  color: theme.colors.border.withValues(alpha: 0.8),
                ),
              ),
              shadows: theme.shadows.surface.boxShadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.spacing(3),
              children: <Widget>[
                HeroTextField(
                  name: 'email',
                  type: HeroInputType.email,
                  isRequired: true,
                  children: <Widget>[
                    const HeroLabel.text('Work email'),
                    HeroInput(
                      placeholder: 'you@company.com',
                      style: HeroFieldStyle(
                        backgroundColor: theme.colors.fieldBackground,
                      ),
                    ),
                  ],
                ),
                const HeroButton(
                  type: HeroButtonType.submit,
                  fullWidth: true,
                  child: Text('Continue'),
                ),
              ],
            ),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroForm(
  onSubmit: (Map<String, Object?> data) {},
  child: Container(
    width: 320,
    padding: EdgeInsets.all(theme.spacing(4)),
    decoration: ShapeDecoration(
      color: theme.colors.surface,
      shape: theme.shapeAll(
        theme.radii.xl,
        side: BorderSide(color: theme.colors.border.withValues(alpha: 0.8)),
      ),
      shadows: theme.shadows.surface.boxShadows,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: theme.spacing(3),
      children: <Widget>[
        HeroTextField(
          name: 'email',
          type: HeroInputType.email,
          isRequired: true,
          children: <Widget>[
            const HeroLabel.text('Work email'),
            HeroInput(
              placeholder: 'you@company.com',
              style: HeroFieldStyle(
                backgroundColor: theme.colors.fieldBackground,
              ),
            ),
          ],
        ),
        const HeroButton(
          type: HeroButtonType.submit,
          fullWidth: true,
          child: Text('Continue'),
        ),
      ],
    ),
  ),
)''',
    ),
  ],
);

const String _signUpCode = r'''
HeroForm(
  onSubmit: (Map<String, Object?> data) {
    setState(() => result = 'Form submitted with: $data');
  },
  child: SizedBox(
    width: 384,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        HeroTextField(
          name: 'email',
          type: HeroInputType.email,
          isRequired: true,
          validator: (String? value) {
            final RegExp email = RegExp(
              r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
              caseSensitive: false,
            );
            if (!email.hasMatch(value ?? '')) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          children: const <Widget>[
            HeroLabel.text('Email'),
            HeroInput(placeholder: 'john@example.com'),
            HeroFieldError(),
          ],
        ),
        HeroTextField(
          name: 'password',
          type: HeroInputType.password,
          isRequired: true,
          minLength: 8,
          validator: (String? value) {
            final String password = value ?? '';
            if (password.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!password.contains(RegExp('[A-Z]'))) {
              return 'Password must contain at least one uppercase letter';
            }
            if (!password.contains(RegExp('[0-9]'))) {
              return 'Password must contain at least one number';
            }
            return null;
          },
          children: const <Widget>[
            HeroLabel.text('Password'),
            HeroInput(placeholder: 'Enter your password'),
            HeroDescription.text(
              'Must be at least 8 characters with 1 uppercase and 1 number',
            ),
            HeroFieldError(),
          ],
        ),
        const Row(
          spacing: 8,
          children: <Widget>[
            HeroButton(
              type: HeroButtonType.submit,
              startContent: HeroIcon(HeroIcons.check),
              child: Text('Submit'),
            ),
            HeroButton(
              type: HeroButtonType.reset,
              variant: HeroButtonVariant.secondary,
              child: Text('Reset'),
            ),
          ],
        ),
      ],
    ),
  ),
)''';

final RegExp _email = RegExp(
  r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
  caseSensitive: false,
);

String? _validateEmail(String? value) {
  if (!_email.hasMatch(value ?? '')) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? _validatePassword(String? value) {
  final String password = value ?? '';
  if (password.length < 8) return 'Password must be at least 8 characters';
  if (!password.contains(RegExp('[A-Z]'))) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!password.contains(RegExp('[0-9]'))) {
    return 'Password must contain at least one number';
  }
  return null;
}

/// The docs' sign-up form: a required email, a required password with rules
/// and submit / reset buttons; shows the data it submits.
class _SignUpForm extends StatefulWidget {
  const _SignUpForm({this.behavior = HeroValidationBehavior.native});

  final HeroValidationBehavior behavior;

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  String? _result;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroForm(
      validationBehavior: widget.behavior,
      onSubmit: (Map<String, Object?> data) =>
          setState(() => _result = 'Form submitted with: $data'),
      onReset: () => setState(() => _result = null),
      child: SizedBox(
        width: 384,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            const HeroTextField(
              name: 'email',
              type: HeroInputType.email,
              isRequired: true,
              validator: _validateEmail,
              children: <Widget>[
                HeroLabel.text('Email'),
                HeroInput(placeholder: 'john@example.com'),
                HeroFieldError(),
              ],
            ),
            const HeroTextField(
              name: 'password',
              type: HeroInputType.password,
              isRequired: true,
              minLength: 8,
              validator: _validatePassword,
              children: <Widget>[
                HeroLabel.text('Password'),
                HeroInput(placeholder: 'Enter your password'),
                HeroDescription.text(
                  'Must be at least 8 characters with 1 uppercase and 1 '
                  'number',
                ),
                HeroFieldError(),
              ],
            ),
            const Row(
              spacing: 8,
              children: <Widget>[
                HeroButton(
                  type: HeroButtonType.submit,
                  startContent: HeroIcon(HeroIcons.check),
                  child: Text('Submit'),
                ),
                HeroButton(
                  type: HeroButtonType.reset,
                  variant: HeroButtonVariant.secondary,
                  child: Text('Reset'),
                ),
              ],
            ),
            if (_result case final String result)
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
