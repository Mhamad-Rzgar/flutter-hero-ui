import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroInputOTP`, reproducing
/// heroui.com/docs/components/input-otp.
final ComponentDemo inputOtpDemo = ComponentDemo(
  slug: 'input-otp',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      OptionsControl('maxLength', <String>['6', '4']),
      OptionsControl('pattern', <String>['any', 'digits', 'chars']),
      ToggleControl('isDisabled'),
      ToggleControl('isInvalid'),
      TextControl('label', initial: 'Verify account'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final int maxLength = int.parse(values.option('maxLength'));
      return SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            HeroLabel.text(
              values.text('label'),
              isDisabled: values.toggle('isDisabled'),
            ),
            HeroInputOTP(
              key: ValueKey<String>('$maxLength${values.option('pattern')}'),
              maxLength: maxLength,
              groupSizes: maxLength == 6 ? const <int>[3, 3] : null,
              pattern: _pattern(values.option('pattern')),
              variant: values.pick('variant', HeroFieldVariant.values),
              isDisabled: values.toggle('isDisabled'),
              isInvalid: values.toggle('isInvalid'),
              semanticLabel: values.text('label'),
            ),
          ],
        ),
      );
    },
    code: (PlaygroundValues values) {
      final int maxLength = int.parse(values.option('maxLength'));
      final StringBuffer out = StringBuffer('HeroInputOTP(\n')
        ..writeln('  maxLength: $maxLength,');
      if (maxLength == 6) out.writeln('  groupSizes: const <int>[3, 3],');
      final String pattern = values.option('pattern');
      if (pattern == 'digits') {
        out.writeln('  pattern: HeroInputOTP.regexpOnlyDigits,');
      } else if (pattern == 'chars') {
        out.writeln('  pattern: HeroInputOTP.regexpOnlyChars,');
      }
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      for (final String flag in <String>['isDisabled', 'isInvalid']) {
        if (values.toggle(flag)) out.writeln('  $flag: true,');
      }
      out
        ..writeln("  semanticLabel: '${values.text('label')}',")
        ..write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const _VerifyAccount(),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Variants',
      description:
          'primary (default) has the field shadow; secondary is the lower '
          'emphasis variant without shadow, suited to surfaces.',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: <Widget>[
            _LabelledOTP(label: 'Primary variant'),
            _LabelledOTP(
              label: 'Secondary variant',
              variant: HeroFieldVariant.secondary,
            ),
          ],
        ),
      ),
      code: '''
HeroInputOTP(
  maxLength: 6,
  variant: HeroFieldVariant.secondary, // or primary (default)
  semanticLabel: 'Secondary variant',
  children: const <Widget>[
    HeroInputOTPGroup(
      children: <Widget>[
        HeroInputOTPSlot(index: 0),
        HeroInputOTPSlot(index: 1),
        HeroInputOTPSlot(index: 2),
      ],
    ),
    HeroInputOTPSeparator(),
    HeroInputOTPGroup(
      children: <Widget>[
        HeroInputOTPSlot(index: 3),
        HeroInputOTPSlot(index: 4),
        HeroInputOTPSlot(index: 5),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'In Surface',
      description:
          'Inside a Surface, use the secondary variant for the lower '
          'emphasis look suited to surface backgrounds.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroSurface(
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: EdgeInsets.all(theme.spacing(6)),
          child: const _VerifyAccount(variant: HeroFieldVariant.secondary),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: <Widget>[
      // ... label and hint as in the basic example
      const HeroInputOTP(
        maxLength: 6,
        groupSizes: <int>[3, 3],
        variant: HeroFieldVariant.secondary,
      ),
      // ... resend row
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            HeroLabel.text('Verify account', isDisabled: true),
            HeroDescription.text('Code verification is currently disabled'),
            HeroInputOTP(
              maxLength: 6,
              groupSizes: <int>[3, 3],
              isDisabled: true,
              semanticLabel: 'Verify account',
            ),
          ],
        ),
      ),
      code: '''
const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: <Widget>[
    HeroLabel.text('Verify account', isDisabled: true),
    HeroDescription.text('Code verification is currently disabled'),
    HeroInputOTP(
      maxLength: 6,
      groupSizes: <int>[3, 3],
      isDisabled: true,
      semanticLabel: 'Verify account',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Four Digits',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            HeroLabel.text('Enter PIN'),
            HeroInputOTP(maxLength: 4, semanticLabel: 'Enter PIN'),
          ],
        ),
      ),
      code: '''
const HeroInputOTP(
  maxLength: 4,
  semanticLabel: 'Enter PIN',
  children: <Widget>[
    HeroInputOTPGroup(
      children: <Widget>[
        HeroInputOTPSlot(index: 0),
        HeroInputOTPSlot(index: 1),
        HeroInputOTPSlot(index: 2),
        HeroInputOTPSlot(index: 3),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      description:
          'Control the value to synchronize it with state, clear it or '
          'validate it.',
      builder: (BuildContext context) => const _ControlledOTP(),
      code: r'''
String value = '';

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: <Widget>[
    const HeroLabel.text('Verify account'),
    HeroInputOTP(
      maxLength: 6,
      groupSizes: const <int>[3, 3],
      value: value,
      onChanged: (String v) => setState(() => value = v),
    ),
    HeroDescription(
      child: value.isEmpty
          ? const Text('Enter a 6-digit code')
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Value: $value (${value.length}/6) • '),
                HeroLink(
                  underline: HeroLinkUnderline.always,
                  onPressed: () => setState(() => value = ''),
                  child: const Text('Clear'),
                ),
              ],
            ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'On Complete',
      description: 'onCompleted runs when every slot is filled.',
      builder: (BuildContext context) => const _OnCompleteForm(),
      code: r'''
String value = '';
bool isComplete = false;
bool isSubmitting = false;

HeroForm(
  onSubmit: (Map<String, Object?> data) async {
    setState(() => isSubmitting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    setState(() {
      isSubmitting = false;
      value = '';
      isComplete = false;
    });
  },
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: <Widget>[
      const HeroLabel.text('Verify account'),
      HeroInputOTP(
        maxLength: 6,
        groupSizes: const <int>[3, 3],
        value: value,
        onCompleted: (String code) => setState(() => isComplete = true),
        onChanged: (String v) => setState(() {
          value = v;
          isComplete = false;
        }),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: HeroButton(
          type: HeroButtonType.submit,
          fullWidth: true,
          isDisabled: !isComplete,
          isPending: isSubmitting,
          child: Text(isSubmitting ? 'Verifying...' : 'Verify Code'),
        ),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Form Example',
      description: 'A two-factor authentication form with validation.',
      builder: (BuildContext context) => const _TwoFactorForm(),
      code: r'''
String value = '';
String error = '';
bool isSubmitting = false;

Future<void> submit(Map<String, Object?> data) async {
  setState(() => error = '');
  if (value.length != 6) {
    setState(() => error = 'Please enter all 6 digits');
    return;
  }
  setState(() => isSubmitting = true);
  await Future<void>.delayed(const Duration(milliseconds: 1500));
  setState(() {
    if (value == '123456') {
      value = '';
    } else {
      error = 'Invalid code. Please try again.';
    }
    isSubmitting = false;
  });
}

HeroForm(
  onSubmit: submit,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          const HeroLabel.text('Two-factor authentication'),
          const HeroDescription.text(
            'Enter the 6-digit code from your authenticator app',
          ),
          HeroInputOTP(
            maxLength: 6,
            groupSizes: const <int>[3, 3],
            isInvalid: error.isNotEmpty,
            value: value,
            onChanged: (String v) => setState(() {
              value = v;
              error = '';
            }),
          ),
          HeroFieldError.text(error, isInvalid: error.isNotEmpty),
        ],
      ),
      HeroButton(
        type: HeroButtonType.submit,
        fullWidth: true,
        isDisabled: value.length != 6,
        isPending: isSubmitting,
        child: Text(isSubmitting ? 'Verifying...' : 'Verify'),
      ),
      // "Having trouble? Use backup code" row
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'With Pattern',
      description:
          'pattern restricts the characters; HeroInputOTP.regexpOnlyDigits, '
          'regexpOnlyChars and regexpOnlyDigitsAndChars are provided.',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            HeroLabel.text('Enter code (letters only)'),
            HeroDescription.text('Only alphabetic characters are allowed'),
            HeroInputOTP(
              maxLength: 6,
              groupSizes: <int>[3, 3],
              pattern: HeroInputOTP.regexpOnlyChars,
              semanticLabel: 'Enter code (letters only)',
            ),
          ],
        ),
      ),
      code: '''
const HeroInputOTP(
  maxLength: 6,
  groupSizes: <int>[3, 3],
  pattern: HeroInputOTP.regexpOnlyChars,
  semanticLabel: 'Enter code (letters only)',
)''',
    ),
    DemoExample(
      title: 'With Validation',
      description: 'isInvalid with a validation message surfaces errors.',
      builder: (BuildContext context) => const _ValidatedOTP(),
      code: r'''
String value = '';
bool isInvalid = false;

HeroForm(
  onSubmit: (Map<String, Object?> data) {
    if (data['code'] != '123456') {
      setState(() => isInvalid = true);
      return;
    }
    setState(() {
      isInvalid = false;
      value = '';
    });
  },
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: <Widget>[
      const HeroLabel.text('Verify account'),
      const HeroDescription.text('Hint: The code is 123456'),
      HeroInputOTP(
        maxLength: 6,
        groupSizes: const <int>[3, 3],
        name: 'code',
        isInvalid: isInvalid,
        value: value,
        onChanged: (String v) => setState(() {
          value = v;
          isInvalid = false;
        }),
      ),
      HeroFieldError.text(
        'Invalid code. Please try again.',
        isInvalid: isInvalid,
      ),
      HeroButton(
        type: HeroButtonType.submit,
        isDisabled: value.length != 6,
        child: const Text('Submit'),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'Slots with rounded-lg corners and the default background, an '
          'accent-soft active slot and a border-colored separator.',
      builder: (BuildContext context) => const _CustomOTP(),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final HeroFieldStyle slot = HeroFieldStyle(
  borderRadius: BorderRadius.circular(theme.radii.lg),
  backgroundColor: theme.colors.defaultColor,
  borderColor: theme.colors.border.withValues(alpha: 0.8),
  focusBorderColor: theme.colors.accent.withValues(alpha: 0.4),
  focusBackgroundColor: theme.colors.accentSoft,
);

HeroInputOTP(
  maxLength: 6,
  children: <Widget>[
    HeroInputOTPGroup(
      children: <Widget>[
        for (int i = 0; i < 3; i++) HeroInputOTPSlot(index: i, style: slot),
      ],
    ),
    HeroInputOTPSeparator(color: theme.colors.border),
    HeroInputOTPGroup(
      children: <Widget>[
        for (int i = 3; i < 6; i++) HeroInputOTPSlot(index: i, style: slot),
      ],
    ),
  ],
)''',
    ),
  ],
);

String? _pattern(String option) => switch (option) {
  'digits' => HeroInputOTP.regexpOnlyDigits,
  'chars' => HeroInputOTP.regexpOnlyChars,
  _ => null,
};

const String _basicCode = '''
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: <Widget>[
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: <Widget>[
        const HeroLabel.text('Verify account'),
        Text(
          "We've sent a code to a****@gmail.com",
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ],
    ),
    const HeroInputOTP(
      maxLength: 6,
      semanticLabel: 'Verify account',
      children: <Widget>[
        HeroInputOTPGroup(
          children: <Widget>[
            HeroInputOTPSlot(index: 0),
            HeroInputOTPSlot(index: 1),
            HeroInputOTPSlot(index: 2),
          ],
        ),
        HeroInputOTPSeparator(),
        HeroInputOTPGroup(
          children: <Widget>[
            HeroInputOTPSlot(index: 3),
            HeroInputOTPSlot(index: 4),
            HeroInputOTPSlot(index: 5),
          ],
        ),
      ],
    ),
    Padding(
      padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Row(
        spacing: 5,
        children: <Widget>[
          Text(
            "Didn't receive a code?",
            style: theme.typography.sm.copyWith(color: theme.colors.muted),
          ),
          HeroLink(
            underline: HeroLinkUnderline.always,
            color: theme.colors.foreground,
            onPressed: resend,
            child: const Text('Resend'),
          ),
        ],
      ),
    ),
  ],
)

// or build the groups from their sizes:
const HeroInputOTP(maxLength: 6, groupSizes: <int>[3, 3])''';

/// The six slots of the docs, in two groups of three.
const List<Widget> _sixSlots = <Widget>[
  HeroInputOTPGroup(
    children: <Widget>[
      HeroInputOTPSlot(index: 0),
      HeroInputOTPSlot(index: 1),
      HeroInputOTPSlot(index: 2),
    ],
  ),
  HeroInputOTPSeparator(),
  HeroInputOTPGroup(
    children: <Widget>[
      HeroInputOTPSlot(index: 3),
      HeroInputOTPSlot(index: 4),
      HeroInputOTPSlot(index: 5),
    ],
  ),
];

/// A label above a six-slot input.
class _LabelledOTP extends StatelessWidget {
  const _LabelledOTP({
    required this.label,
    this.variant = HeroFieldVariant.primary,
  });

  final String label;
  final HeroFieldVariant variant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        HeroLabel.text(label),
        HeroInputOTP(
          maxLength: 6,
          variant: variant,
          semanticLabel: label,
          children: _sixSlots,
        ),
      ],
    );
  }
}

/// The docs' basic example: label, hint, six slots and a resend row.
class _VerifyAccount extends StatelessWidget {
  const _VerifyAccount({this.variant = HeroFieldVariant.primary});

  final HeroFieldVariant variant;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: <Widget>[
              const HeroLabel.text('Verify account'),
              Text("We've sent a code to a****@gmail.com", style: muted),
            ],
          ),
          HeroInputOTP(
            maxLength: 6,
            variant: variant,
            semanticLabel: 'Verify account',
            children: _sixSlots,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing(1),
              theme.spacing(1),
              theme.spacing(1),
              0,
            ),
            child: Wrap(
              spacing: 5,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text("Didn't receive a code?", style: muted),
                DefaultTextStyle.merge(
                  style: theme.typography.sm,
                  child: HeroLink(
                    underline: HeroLinkUnderline.always,
                    color: theme.colors.foreground,
                    onPressed: () {},
                    child: const Text('Resend'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A controlled input with a live value summary and a clear link.
class _ControlledOTP extends StatefulWidget {
  const _ControlledOTP();

  @override
  State<_ControlledOTP> createState() => _ControlledOTPState();
}

class _ControlledOTPState extends State<_ControlledOTP> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          const HeroLabel.text('Verify account'),
          HeroInputOTP(
            maxLength: 6,
            value: _value,
            onChanged: (String value) => setState(() => _value = value),
            semanticLabel: 'Verify account',
            children: _sixSlots,
          ),
          HeroDescription(
            child: _value.isEmpty
                ? const Text('Enter a 6-digit code')
                : Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text('Value: $_value (${_value.length}/6) • '),
                      HeroLink(
                        underline: HeroLinkUnderline.always,
                        color: theme.colors.foreground,
                        onPressed: () => setState(() => _value = ''),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// A form whose verify button is enabled once the code is complete.
class _OnCompleteForm extends StatefulWidget {
  const _OnCompleteForm();

  @override
  State<_OnCompleteForm> createState() => _OnCompleteFormState();
}

class _OnCompleteFormState extends State<_OnCompleteForm> {
  String _value = '';
  bool _complete = false;
  bool _submitting = false;

  Future<void> _submit(Map<String, Object?> data) async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _value = '';
      _complete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroForm(
      onSubmit: _submit,
      child: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: <Widget>[
            const HeroLabel.text('Verify account'),
            HeroInputOTP(
              maxLength: 6,
              value: _value,
              onCompleted: (String code) => setState(() => _complete = true),
              onChanged: (String value) => setState(() {
                _value = value;
                _complete = false;
              }),
              semanticLabel: 'Verify account',
              children: _sixSlots,
            ),
            Padding(
              padding: EdgeInsets.only(top: theme.spacing(2)),
              child: HeroButton(
                type: HeroButtonType.submit,
                fullWidth: true,
                isDisabled: !_complete,
                isPending: _submitting,
                child: Text(_submitting ? 'Verifying...' : 'Verify Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The docs' two-factor authentication form.
class _TwoFactorForm extends StatefulWidget {
  const _TwoFactorForm();

  @override
  State<_TwoFactorForm> createState() => _TwoFactorFormState();
}

class _TwoFactorFormState extends State<_TwoFactorForm> {
  String _value = '';
  String _error = '';
  bool _submitting = false;

  Future<void> _submit(Map<String, Object?> data) async {
    setState(() => _error = '');
    if (_value.length != 6) {
      setState(() => _error = 'Please enter all 6 digits');
      return;
    }
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      if (_value == '123456') {
        _value = '';
      } else {
        _error = 'Invalid code. Please try again.';
      }
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle muted = theme.typography.sm.copyWith(
      color: theme.colors.muted,
    );
    return HeroForm(
      onSubmit: _submit,
      child: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: <Widget>[
                const HeroLabel.text('Two-factor authentication'),
                const HeroDescription.text(
                  'Enter the 6-digit code from your authenticator app',
                ),
                HeroInputOTP(
                  maxLength: 6,
                  isInvalid: _error.isNotEmpty,
                  value: _value,
                  onChanged: (String value) => setState(() {
                    _value = value;
                    _error = '';
                  }),
                  semanticLabel: 'Two-factor authentication',
                  children: _sixSlots,
                ),
                HeroFieldError.text(_error, isInvalid: _error.isNotEmpty),
              ],
            ),
            HeroButton(
              type: HeroButtonType.submit,
              fullWidth: true,
              isDisabled: _value.length != 6,
              isPending: _submitting,
              child: Text(_submitting ? 'Verifying...' : 'Verify'),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                Text('Having trouble?', style: muted),
                DefaultTextStyle.merge(
                  style: theme.typography.sm,
                  child: HeroLink(
                    underline: HeroLinkUnderline.always,
                    color: theme.colors.foreground,
                    onPressed: () {},
                    child: const Text('Use backup code'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A form that checks the code on submit.
class _ValidatedOTP extends StatefulWidget {
  const _ValidatedOTP();

  @override
  State<_ValidatedOTP> createState() => _ValidatedOTPState();
}

class _ValidatedOTPState extends State<_ValidatedOTP> {
  String _value = '';
  bool _invalid = false;
  bool _verified = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroForm(
      onSubmit: (Map<String, Object?> data) {
        if (data['code'] != '123456') {
          setState(() => _invalid = true);
          return;
        }
        setState(() {
          _invalid = false;
          _value = '';
          _verified = true;
        });
      },
      child: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: <Widget>[
            const HeroLabel.text('Verify account'),
            const HeroDescription.text('Hint: The code is 123456'),
            HeroInputOTP(
              maxLength: 6,
              name: 'code',
              isInvalid: _invalid,
              value: _value,
              onChanged: (String value) => setState(() {
                _value = value;
                _invalid = false;
                _verified = false;
              }),
              semanticLabel: 'Verify account',
              children: _sixSlots,
            ),
            HeroFieldError.text(
              'Invalid code. Please try again.',
              isInvalid: _invalid,
            ),
            HeroButton(
              type: HeroButtonType.submit,
              isDisabled: _value.length != 6,
              child: const Text('Submit'),
            ),
            if (_verified)
              Text(
                'Code verified successfully!',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The docs' customization example.
class _CustomOTP extends StatelessWidget {
  const _CustomOTP();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldStyle slot = HeroFieldStyle(
      borderRadius: BorderRadius.circular(theme.radii.lg),
      backgroundColor: theme.colors.defaultColor,
      borderColor: theme.colors.border.withValues(alpha: 0.8),
      focusBorderColor: theme.colors.accent.withValues(alpha: 0.4),
      focusBackgroundColor: theme.colors.accentSoft,
    );
    return SizedBox(
      width: 288,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: <Widget>[
          const HeroLabel.text('Verify account'),
          HeroInputOTP(
            maxLength: 6,
            semanticLabel: 'Verify account',
            children: <Widget>[
              HeroInputOTPGroup(
                children: <Widget>[
                  for (int i = 0; i < 3; i++)
                    HeroInputOTPSlot(index: i, style: slot),
                ],
              ),
              HeroInputOTPSeparator(color: theme.colors.border),
              HeroInputOTPGroup(
                children: <Widget>[
                  for (int i = 3; i < 6; i++)
                    HeroInputOTPSlot(index: i, style: slot),
                ],
              ),
            ],
          ),
          DefaultTextStyle.merge(
            style: theme.typography.sm,
            child: HeroLink(
              color: theme.colors.link,
              onPressed: () {},
              child: const Text('Resend code'),
            ),
          ),
        ],
      ),
    );
  }
}
