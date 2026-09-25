import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroInputGroup`, reproducing
/// heroui.com/docs/components/input-group.
final ComponentDemo inputGroupDemo = ComponentDemo(
  slug: 'input-group',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      ToggleControl('fullWidth'),
      ToggleControl('isRequired'),
      ToggleControl('isDisabled'),
      ToggleControl('isInvalid'),
      TextControl('label', initial: 'Set a price'),
      TextControl('prefix', initial: r'$'),
      TextControl('suffix', initial: 'USD'),
      TextControl('placeholder', initial: '0'),
    ],
    builder: (BuildContext context, PlaygroundValues values) {
      final String prefix = values.text('prefix');
      final String suffix = values.text('suffix');
      return SizedBox(
        width: values.toggle('fullWidth') ? 400 : 280,
        child: HeroTextField(
          variant: values.pick('variant', HeroFieldVariant.values),
          fullWidth: values.toggle('fullWidth'),
          isRequired: values.toggle('isRequired'),
          isDisabled: values.toggle('isDisabled'),
          isInvalid: values.toggle('isInvalid') ? true : null,
          children: <Widget>[
            HeroLabel.text(values.text('label')),
            HeroInputGroup(
              startContent: prefix.isEmpty ? null : Text(prefix),
              endContent: suffix.isEmpty ? null : Text(suffix),
              child: HeroInputGroupInput(
                placeholder: values.text('placeholder'),
              ),
            ),
            const HeroFieldError.text('Please enter a valid value'),
          ],
        ),
      );
    },
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroTextField(\n');
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      for (final String flag in <String>[
        'fullWidth',
        'isRequired',
        'isDisabled',
        'isInvalid',
      ]) {
        if (values.toggle(flag)) out.writeln('  $flag: true,');
      }
      out
        ..writeln('  children: <Widget>[')
        ..writeln("    const HeroLabel.text('${values.text('label')}'),")
        ..writeln('    HeroInputGroup(');
      if (values.text('prefix').isNotEmpty) {
        out.writeln(
          "      startContent: const Text('${values.text('prefix')}'),",
        );
      }
      if (values.text('suffix').isNotEmpty) {
        out.writeln(
          "      endContent: const Text('${values.text('suffix')}'),",
        );
      }
      out
        ..writeln(
          "      child: const HeroInputGroupInput(placeholder: '${values.text('placeholder')}'),",
        )
        ..writeln('    ),')
        ..writeln(
          "    const HeroFieldError.text('Please enter a valid value'),",
        )
        ..writeln('  ],')
        ..write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: HeroTextField(
          name: 'email',
          children: <Widget>[
            HeroLabel.text('Email address'),
            HeroInputGroup(
              children: <Widget>[
                HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
                HeroInputGroupInput(placeholder: 'name@email.com'),
              ],
            ),
          ],
        ),
      ),
      code: '''
const SizedBox(
  width: 280,
  child: HeroTextField(
    name: 'email',
    children: <Widget>[
      HeroLabel.text('Email address'),
      HeroInputGroup(
        children: <Widget>[
          HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
          HeroInputGroupInput(placeholder: 'name@email.com'),
        ],
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Variants',
      description:
          'primary (default) has the field shadow; secondary is the lower '
          'emphasis variant without shadow, suited to surfaces.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'primary',
              children: <Widget>[
                HeroLabel.text('Primary variant'),
                HeroInputGroup(
                  variant: HeroFieldVariant.primary,
                  startContent: HeroIcon(HeroIcons.envelope),
                  child: HeroInputGroupInput(placeholder: 'name@email.com'),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'secondary',
              children: <Widget>[
                HeroLabel.text('Secondary variant'),
                HeroInputGroup(
                  variant: HeroFieldVariant.secondary,
                  startContent: HeroIcon(HeroIcons.envelope),
                  child: HeroInputGroupInput(placeholder: 'name@email.com'),
                ),
              ],
            ),
          ),
        ],
      ),
      code: '''
HeroInputGroup(
  variant: HeroFieldVariant.primary, // or HeroFieldVariant.secondary
  startContent: const HeroIcon(HeroIcons.envelope),
  child: const HeroInputGroupInput(placeholder: 'name@email.com'),
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
          borderRadius: BorderRadius.circular(theme.radii.xl2),
          padding: EdgeInsets.all(theme.spacing(6)),
          child: const SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'email',
              children: <Widget>[
                HeroLabel.text('Email address'),
                HeroInputGroup(
                  variant: HeroFieldVariant.secondary,
                  startContent: HeroIcon(HeroIcons.envelope),
                  child: HeroInputGroupInput(placeholder: 'name@email.com'),
                ),
                HeroDescription.text("We'll never share this with anyone else"),
              ],
            ),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl2),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const SizedBox(
    width: 280,
    child: HeroTextField(
      name: 'email',
      children: <Widget>[
        HeroLabel.text('Email address'),
        HeroInputGroup(
          variant: HeroFieldVariant.secondary,
          startContent: HeroIcon(HeroIcons.envelope),
          child: HeroInputGroupInput(placeholder: 'name@email.com'),
        ),
        HeroDescription.text("We'll never share this with anyone else"),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Loading State',
      description: 'A spinner in the suffix indicates processing.',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: HeroTextField(
          name: 'status',
          defaultValue: 'Sending...',
          semanticLabel: 'Status',
          children: <Widget>[
            HeroInputGroup(endContent: HeroSpinner(size: HeroSpinnerSize.sm)),
          ],
        ),
      ),
      code: '''
const SizedBox(
  width: 280,
  child: HeroTextField(
    name: 'status',
    defaultValue: 'Sending...',
    children: <Widget>[
      HeroInputGroup(endContent: HeroSpinner(size: HeroSpinnerSize.sm)),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Required Field',
      description: 'The group follows the required state of its TextField.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'email',
              isRequired: true,
              children: <Widget>[
                HeroLabel.text('Email address'),
                HeroInputGroup(
                  startContent: HeroIcon(HeroIcons.envelope),
                  child: HeroInputGroupInput(placeholder: 'name@email.com'),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'price',
              isRequired: true,
              type: HeroInputType.number,
              children: <Widget>[
                HeroLabel.text('Set a price'),
                HeroInputGroup(
                  startContent: Text(r'$'),
                  endContent: Text('USD'),
                  child: HeroInputGroupInput(placeholder: '0'),
                ),
                HeroDescription.text('What customers would pay'),
              ],
            ),
          ),
        ],
      ),
      code: r'''
const HeroTextField(
  name: 'price',
  isRequired: true,
  type: HeroInputType.number,
  children: <Widget>[
    HeroLabel.text('Set a price'),
    HeroInputGroup(
      startContent: Text(r'$'),
      endContent: Text('USD'),
      child: HeroInputGroupInput(placeholder: '0'),
    ),
    HeroDescription.text('What customers would pay'),
  ],
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      description: 'The group follows the disabled state of its TextField.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'email',
              isDisabled: true,
              defaultValue: 'name@email.com',
              children: <Widget>[
                HeroLabel.text('Email address'),
                HeroInputGroup(startContent: HeroIcon(HeroIcons.envelope)),
              ],
            ),
          ),
          SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'price',
              isDisabled: true,
              defaultValue: '10',
              type: HeroInputType.number,
              children: <Widget>[
                HeroLabel.text('Set a price'),
                HeroInputGroup(
                  startContent: Text(r'$'),
                  endContent: Text('USD'),
                ),
              ],
            ),
          ),
        ],
      ),
      code: r'''
const HeroTextField(
  name: 'price',
  isDisabled: true,
  defaultValue: '10',
  type: HeroInputType.number,
  children: <Widget>[
    HeroLabel.text('Set a price'),
    HeroInputGroup(startContent: Text(r'$'), endContent: Text('USD')),
  ],
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
              name: 'email',
              fullWidth: true,
              children: <Widget>[
                HeroLabel.text('Email address'),
                HeroInputGroup(
                  fullWidth: true,
                  startContent: HeroIcon(HeroIcons.envelope),
                  child: HeroInputGroupInput(placeholder: 'name@email.com'),
                ),
              ],
            ),
            HeroTextField(
              name: 'password',
              fullWidth: true,
              children: <Widget>[
                HeroLabel.text('Password'),
                HeroInputGroup(
                  fullWidth: true,
                  endContent: HeroIcon(HeroIcons.eye),
                  child: HeroInputGroupInput(
                    placeholder: 'Enter password',
                    type: HeroInputType.password,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      code: '''
const SizedBox(
  width: 400,
  child: HeroTextField(
    name: 'email',
    fullWidth: true,
    children: <Widget>[
      HeroLabel.text('Email address'),
      HeroInputGroup(
        fullWidth: true,
        startContent: HeroIcon(HeroIcons.envelope),
        child: HeroInputGroupInput(placeholder: 'name@email.com'),
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Text Prefix',
      description: 'A text prefix such as a currency symbol or a protocol.',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: HeroTextField(
          name: 'website',
          defaultValue: 'heroui.com',
          children: <Widget>[
            HeroLabel.text('Website'),
            HeroInputGroup(startContent: Text('https://')),
          ],
        ),
      ),
      code: '''
const HeroTextField(
  name: 'website',
  defaultValue: 'heroui.com',
  children: <Widget>[
    HeroLabel.text('Website'),
    HeroInputGroup(
      children: <Widget>[
        HeroInputGroupPrefix(child: Text('https://')),
        HeroInputGroupInput(),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Text Suffix',
      description: 'A text suffix such as a domain extension or a unit.',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: HeroTextField(
          name: 'website',
          defaultValue: 'heroui',
          children: <Widget>[
            HeroLabel.text('Website'),
            HeroInputGroup(endContent: Text('.com')),
          ],
        ),
      ),
      code: '''
const HeroTextField(
  name: 'website',
  defaultValue: 'heroui',
  children: <Widget>[
    HeroLabel.text('Website'),
    HeroInputGroup(endContent: Text('.com')),
  ],
)''',
    ),
    DemoExample(
      title: 'Icon Prefix and Text Suffix',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: HeroTextField(
          name: 'website',
          defaultValue: 'heroui',
          children: <Widget>[
            HeroLabel.text('Website'),
            HeroInputGroup(
              startContent: HeroIcon(HeroIcons.globe),
              endContent: Text('.com'),
            ),
          ],
        ),
      ),
      code: '''
const HeroTextField(
  name: 'website',
  defaultValue: 'heroui',
  children: <Widget>[
    HeroLabel.text('Website'),
    HeroInputGroup(
      startContent: HeroIcon(HeroIcons.globe),
      endContent: Text('.com'),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Copy Button Suffix',
      description: 'An interactive button in the suffix.',
      builder: (BuildContext context) =>
          const SizedBox(width: 280, child: _WebsiteWithCopy()),
      code: _copyCode,
    ),
    DemoExample(
      title: 'Icon Prefix and Copy Button',
      builder: (BuildContext context) =>
          const SizedBox(width: 280, child: _WebsiteWithCopy(withIcon: true)),
      code: '''
HeroTextField(
  name: 'website',
  defaultValue: 'heroui.com',
  children: <Widget>[
    const HeroLabel.text('Website'),
    HeroInputGroup(
      children: <Widget>[
        const HeroInputGroupPrefix(child: HeroIcon(HeroIcons.globe)),
        const HeroInputGroupInput(),
        HeroInputGroupSuffix(
          padding: EdgeInsetsDirectional.only(start: 12), // pe-0
          child: HeroButton(
            isIconOnly: true,
            size: HeroSize.sm,
            variant: HeroButtonVariant.ghost,
            semanticLabel: 'Copy',
            onPressed: copy,
            child: const HeroIcon(HeroIcons.copy),
          ),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Password Toggle',
      description: 'A suffix button toggles the password visibility.',
      builder: (BuildContext context) =>
          const SizedBox(width: 280, child: _PasswordToggle()),
      code: r'''
bool isVisible = false;

HeroTextField(
  name: 'password',
  value: isVisible ? '87$2h.3diua' : '••••••••',
  children: <Widget>[
    const HeroLabel.text('Password'),
    HeroInputGroup(
      children: <Widget>[
        HeroInputGroupInput(
          type: isVisible ? HeroInputType.text : HeroInputType.password,
        ),
        HeroInputGroupSuffix(
          padding: const EdgeInsetsDirectional.only(start: 12), // pe-0
          child: HeroButton(
            isIconOnly: true,
            size: HeroSize.sm,
            variant: HeroButtonVariant.ghost,
            semanticLabel: isVisible ? 'Hide password' : 'Show password',
            onPressed: () => setState(() => isVisible = !isVisible),
            child: HeroIcon(isVisible ? HeroIcons.eye : HeroIcons.eyeSlash),
          ),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Keyboard Shortcut',
      description: 'A keyboard shortcut shown with Kbd.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return SizedBox(
          width: 280,
          child: HeroTextField(
            name: 'command',
            semanticLabel: 'Command',
            children: <Widget>[
              HeroInputGroup(
                children: <Widget>[
                  const HeroInputGroupInput(placeholder: 'Command'),
                  HeroInputGroupSuffix(
                    padding: EdgeInsetsDirectional.only(
                      start: theme.spacing(3),
                      end: theme.spacing(2),
                    ),
                    child: const HeroKbd(
                      keys: <HeroKbdKey>[HeroKbdKey.command],
                      text: 'K',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      code: '''
HeroTextField(
  name: 'command',
  semanticLabel: 'Command',
  children: <Widget>[
    HeroInputGroup(
      children: <Widget>[
        const HeroInputGroupInput(placeholder: 'Command'),
        HeroInputGroupSuffix(
          // pe-2
          padding: EdgeInsetsDirectional.only(
            start: theme.spacing(3),
            end: theme.spacing(2),
          ),
          child: const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K'),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Badge Suffix',
      description: 'A chip in the suffix shows a status or a label.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return SizedBox(
          width: 280,
          child: HeroTextField(
            name: 'email',
            semanticLabel: 'Email address',
            children: <Widget>[
              HeroInputGroup(
                children: <Widget>[
                  const HeroInputGroupInput(placeholder: 'Email address'),
                  HeroInputGroupSuffix(
                    padding: EdgeInsetsDirectional.only(
                      start: theme.spacing(3),
                      end: theme.spacing(2),
                    ),
                    child: const HeroChip(
                      label: 'Pro',
                      color: HeroColor.accent,
                      variant: HeroChipVariant.soft,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      code: '''
HeroInputGroup(
  children: <Widget>[
    const HeroInputGroupInput(placeholder: 'Email address'),
    HeroInputGroupSuffix(
      // pe-2
      padding: EdgeInsetsDirectional.only(
        start: theme.spacing(3),
        end: theme.spacing(2),
      ),
      child: const HeroChip(
        label: 'Pro',
        color: HeroColor.accent,
        variant: HeroChipVariant.soft,
      ),
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Validation',
      description: 'The group reflects the invalid state of its TextField.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'email',
              isInvalid: true,
              isRequired: true,
              children: <Widget>[
                HeroLabel.text('Email address'),
                HeroInputGroup(
                  startContent: HeroIcon(HeroIcons.envelope),
                  child: HeroInputGroupInput(placeholder: 'name@email.com'),
                ),
                HeroFieldError.text('Please enter a valid email address'),
              ],
            ),
          ),
          SizedBox(
            width: 280,
            child: HeroTextField(
              name: 'price',
              isInvalid: true,
              isRequired: true,
              type: HeroInputType.number,
              children: <Widget>[
                HeroLabel.text('Set a price'),
                HeroInputGroup(
                  startContent: Text(r'$'),
                  endContent: Text('USD'),
                  child: HeroInputGroupInput(placeholder: '0'),
                ),
                HeroFieldError.text('Price must be greater than 0'),
              ],
            ),
          ),
        ],
      ),
      code: '''
const HeroTextField(
  name: 'email',
  isInvalid: true,
  isRequired: true,
  children: <Widget>[
    HeroLabel.text('Email address'),
    HeroInputGroup(
      startContent: HeroIcon(HeroIcons.envelope),
      child: HeroInputGroupInput(placeholder: 'name@email.com'),
    ),
    HeroFieldError.text('Please enter a valid email address'),
  ],
)''',
    ),
    DemoExample(
      title: 'With Prefix Icon',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: HeroTextField(
          name: 'email',
          children: <Widget>[
            HeroLabel.text('Email address'),
            HeroInputGroup(
              startContent: HeroIcon(HeroIcons.envelope),
              child: HeroInputGroupInput(placeholder: 'name@email.com'),
            ),
            HeroDescription.text("We'll never share this with anyone else"),
          ],
        ),
      ),
      code: '''
const HeroTextField(
  name: 'email',
  children: <Widget>[
    HeroLabel.text('Email address'),
    HeroInputGroup(
      startContent: HeroIcon(HeroIcons.envelope),
      child: HeroInputGroupInput(placeholder: 'name@email.com'),
    ),
    HeroDescription.text("We'll never share this with anyone else"),
  ],
)''',
    ),
    DemoExample(
      title: 'With Suffix Icon',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: HeroTextField(
          name: 'email',
          children: <Widget>[
            HeroLabel.text('Email address'),
            HeroInputGroup(
              endContent: HeroIcon(HeroIcons.envelope),
              child: HeroInputGroupInput(placeholder: 'name@email.com'),
            ),
            HeroDescription.text("We don't send spam"),
          ],
        ),
      ),
      code: '''
const HeroTextField(
  name: 'email',
  children: <Widget>[
    HeroLabel.text('Email address'),
    HeroInputGroup(
      endContent: HeroIcon(HeroIcons.envelope),
      child: HeroInputGroupInput(placeholder: 'name@email.com'),
    ),
    HeroDescription.text("We don't send spam"),
  ],
)''',
    ),
    DemoExample(
      title: 'With Prefix and Suffix',
      builder: (BuildContext context) => const SizedBox(
        width: 280,
        child: HeroTextField(
          name: 'price',
          defaultValue: '10',
          type: HeroInputType.number,
          children: <Widget>[
            HeroLabel.text('Set a price'),
            HeroInputGroup(startContent: Text(r'$'), endContent: Text('USD')),
            HeroDescription.text('What customers would pay'),
          ],
        ),
      ),
      code: r'''
const HeroTextField(
  name: 'price',
  defaultValue: '10',
  type: HeroInputType.number,
  children: <Widget>[
    HeroLabel.text('Set a price'),
    HeroInputGroup(
      children: <Widget>[
        HeroInputGroupPrefix(child: Text(r'$')),
        HeroInputGroupInput(),
        HeroInputGroupSuffix(child: Text('USD')),
      ],
    ),
    HeroDescription.text('What customers would pay'),
  ],
)''',
    ),
    DemoExample(
      title: 'With TextArea',
      description:
          'A prompt box: a vertical group with the text area between an '
          'action row on top and at the bottom; the addons align to the '
          'start.',
      builder: (BuildContext context) => const _PromptInput(),
      code: _promptCode,
    ),
    DemoExample(
      title: 'Usage Example',
      builder: (BuildContext context) => SizedBox(
        width: 280,
        child: HeroTextField(
          children: <Widget>[
            const HeroLabel.text('Email'),
            HeroInputGroup(
              children: <Widget>[
                const HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
                const HeroInputGroupInput(placeholder: 'name@email.com'),
                HeroInputGroupSuffix(
                  child: HeroButton(
                    isIconOnly: true,
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.ghost,
                    semanticLabel: 'Confirm',
                    onPressed: () {},
                    child: const HeroIcon(HeroIcons.check),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      code: '''
HeroTextField(
  children: <Widget>[
    const HeroLabel.text('Email'),
    HeroInputGroup(
      children: <Widget>[
        const HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
        const HeroInputGroupInput(placeholder: 'name@email.com'),
        HeroInputGroupSuffix(
          child: HeroButton(
            isIconOnly: true,
            size: HeroSize.sm,
            variant: HeroButtonVariant.ghost,
            semanticLabel: 'Confirm',
            onPressed: confirm,
            child: const HeroIcon(HeroIcons.check),
          ),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'TextArea Usage Example',
      builder: (BuildContext context) =>
          const SizedBox(width: 400, child: _FeedbackField()),
      code: r'''
String feedback = '';

HeroTextField(
  name: 'feedback',
  fullWidth: true,
  isInvalid: feedback.length > 500,
  onChanged: (String value) => setState(() => feedback = value),
  children: <Widget>[
    const HeroLabel.text('Your Feedback'),
    const HeroInputGroup(
      fullWidth: true,
      children: <Widget>[
        HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
        HeroInputGroupTextArea(
          placeholder: 'Share your thoughts, suggestions, or issues...',
          rows: 5,
        ),
      ],
    ),
    HeroDescription(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: <Widget>[
            const Expanded(child: Text('Maximum 500 characters.')),
            Text('${feedback.length}/500'),
          ],
        ),
      ),
    ),
    const HeroFieldError.text('Feedback must be less than 500 characters'),
  ],
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'The group restyled with HeroFieldStyle: rounded-xl, a border, the '
          'default background and a small shadow.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return SizedBox(
          width: 320,
          child: HeroTextField(
            name: 'email',
            children: <Widget>[
              const HeroLabel.text('Work email'),
              HeroInputGroup(
                style: HeroFieldStyle(
                  borderRadius: BorderRadius.circular(theme.radii.xl),
                  borderWidth: theme.borderWidth,
                  borderColor: theme.colors.border.withValues(alpha: 0.8),
                  backgroundColor: theme.colors.defaultColor,
                  shadow: theme.shadows.surface,
                ),
                startContent: const HeroIcon(HeroIcons.envelope),
                child: const HeroInputGroupInput(
                  placeholder: 'you@company.com',
                ),
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
SizedBox(
  width: 320,
  child: HeroTextField(
    name: 'email',
    children: <Widget>[
      const HeroLabel.text('Work email'),
      HeroInputGroup(
        style: HeroFieldStyle(
          borderRadius: BorderRadius.circular(theme.radii.xl),
          borderWidth: theme.borderWidth,
          borderColor: theme.colors.border.withValues(alpha: 0.8),
          backgroundColor: theme.colors.defaultColor,
          shadow: theme.shadows.surface, // shadow-sm
        ),
        startContent: const HeroIcon(HeroIcons.envelope),
        child: const HeroInputGroupInput(placeholder: 'you@company.com'),
      ),
    ],
  ),
)''',
    ),
  ],
);

const String _copyCode = '''
HeroTextField(
  name: 'website',
  defaultValue: 'heroui.com',
  children: <Widget>[
    const HeroLabel.text('Website'),
    HeroInputGroup(
      children: <Widget>[
        const HeroInputGroupInput(),
        HeroInputGroupSuffix(
          padding: const EdgeInsetsDirectional.only(start: 12), // pe-0
          child: HeroButton(
            isIconOnly: true,
            size: HeroSize.sm,
            variant: HeroButtonVariant.ghost,
            semanticLabel: 'Copy',
            onPressed: copy,
            child: const HeroIcon(HeroIcons.copy),
          ),
        ),
      ],
    ),
  ],
)''';

const String _promptCode = r'''
String value = '';
bool isSubmitting = false;

Future<void> submit() async {
  if (value.trim().isEmpty) return;
  setState(() => isSubmitting = true);
  await Future<void>.delayed(const Duration(seconds: 1));
  setState(() {
    isSubmitting = false;
    value = '';
  });
}

HeroTextField(
  name: 'prompt',
  fullWidth: true,
  semanticLabel: 'Prompt input',
  value: value,
  onChanged: (String v) => setState(() => value = v),
  children: <Widget>[
    HeroInputGroup(
      fullWidth: true,
      direction: Axis.vertical,
      spacing: theme.spacing(2),
      padding: EdgeInsets.symmetric(vertical: theme.spacing(2)),
      style: HeroFieldStyle(
        borderRadius: BorderRadius.circular(theme.radii.xl3),
      ),
      children: <Widget>[
        HeroInputGroupPrefix(
          padding: EdgeInsets.symmetric(horizontal: theme.spacing(3)),
          child: HeroButton(
            size: HeroSize.sm,
            variant: HeroButtonVariant.outline,
            semanticLabel: 'Add context',
            startContent: const HeroIcon(HeroIcons.at),
            onPressed: () {},
            child: const Text('Add Context'),
          ),
        ),
        HeroInputGroupTextArea(
          placeholder: 'Assign tasks or ask anything...',
          rows: 5,
          style: HeroFieldStyle(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing(3.5)),
          ),
        ),
        HeroInputGroupSuffix(
          padding: EdgeInsets.symmetric(horizontal: theme.spacing(3)),
          child: Row(
            spacing: theme.spacing(1.5),
            children: <Widget>[
              HeroButton(
                isIconOnly: true,
                size: HeroSize.sm,
                variant: HeroButtonVariant.tertiary,
                semanticLabel: 'Attach file',
                onPressed: () {},
                child: const HeroIcon(HeroIcons.plus),
              ),
              HeroButton(
                isIconOnly: true,
                size: HeroSize.sm,
                variant: HeroButtonVariant.tertiary,
                semanticLabel: 'Connect Apps',
                onPressed: () {},
                child: const HeroIcon(HeroIcons.plugConnection),
              ),
              const Spacer(),
              HeroButton(
                isIconOnly: true,
                size: HeroSize.sm,
                variant: HeroButtonVariant.ghost,
                semanticLabel: 'Voice input',
                onPressed: () {},
                child: const HeroIcon(HeroIcons.microphone),
              ),
              HeroButton(
                isIconOnly: true,
                size: HeroSize.sm,
                semanticLabel: 'Send prompt',
                isDisabled: value.trim().isEmpty,
                isPending: isSubmitting,
                onPressed: submit,
                builder: (BuildContext context, HeroButtonState state) =>
                    state.isPending
                    ? const HeroSpinner(
                        size: HeroSpinnerSize.sm,
                        color: HeroSpinnerColor.current,
                      )
                    : const HeroIcon(HeroIcons.arrowUp),
              ),
            ],
          ),
        ),
      ],
    ),
  ],
)''';

/// The docs' prompt box: a vertical input group with a context button, a
/// five-row text area and an action row with a send button.
class _PromptInput extends StatefulWidget {
  const _PromptInput();

  @override
  State<_PromptInput> createState() => _PromptInputState();
}

class _PromptInputState extends State<_PromptInput> {
  String _value = '';
  bool _submitting = false;

  Future<void> _submit() async {
    if (_value.trim().isEmpty) return;
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _value = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    // `w-sm sm:w-lg`: 384, 512 from the sm breakpoint.
    final double width = MediaQuery.sizeOf(context).width >= HeroBreakpoints.sm
        ? 512
        : 384;
    return SizedBox(
      width: width,
      child: HeroTextField(
        name: 'prompt',
        fullWidth: true,
        semanticLabel: 'Prompt input',
        value: _value,
        onChanged: (String value) => setState(() => _value = value),
        children: <Widget>[
          HeroInputGroup(
            fullWidth: true,
            direction: Axis.vertical,
            spacing: theme.spacing(2),
            padding: EdgeInsets.symmetric(vertical: theme.spacing(2)),
            style: HeroFieldStyle(
              borderRadius: BorderRadius.circular(theme.radii.xl3),
            ),
            children: <Widget>[
              HeroInputGroupPrefix(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing(3)),
                child: HeroButton(
                  size: HeroSize.sm,
                  variant: HeroButtonVariant.outline,
                  semanticLabel: 'Add context',
                  startContent: const HeroIcon(HeroIcons.at),
                  onPressed: () {},
                  child: const Text('Add Context'),
                ),
              ),
              HeroInputGroupTextArea(
                placeholder: 'Assign tasks or ask anything...',
                rows: 5,
                style: HeroFieldStyle(
                  padding: EdgeInsets.symmetric(horizontal: theme.spacing(3.5)),
                ),
              ),
              HeroInputGroupSuffix(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing(3)),
                child: Row(
                  spacing: theme.spacing(1.5),
                  children: <Widget>[
                    HeroButton(
                      isIconOnly: true,
                      size: HeroSize.sm,
                      variant: HeroButtonVariant.tertiary,
                      semanticLabel: 'Attach file',
                      onPressed: () {},
                      child: const HeroIcon(HeroIcons.plus),
                    ),
                    HeroButton(
                      isIconOnly: true,
                      size: HeroSize.sm,
                      variant: HeroButtonVariant.tertiary,
                      semanticLabel: 'Connect Apps',
                      onPressed: () {},
                      child: const HeroIcon(HeroIcons.plugConnection),
                    ),
                    const Spacer(),
                    HeroButton(
                      isIconOnly: true,
                      size: HeroSize.sm,
                      variant: HeroButtonVariant.ghost,
                      semanticLabel: 'Voice input',
                      onPressed: () {},
                      child: const HeroIcon(HeroIcons.microphone),
                    ),
                    HeroButton(
                      isIconOnly: true,
                      size: HeroSize.sm,
                      semanticLabel: 'Send prompt',
                      isDisabled: _value.trim().isEmpty,
                      isPending: _submitting,
                      onPressed: _submit,
                      builder: (BuildContext context, HeroButtonState state) =>
                          state.isPending
                          ? const HeroSpinner(
                              size: HeroSpinnerSize.sm,
                              color: HeroSpinnerColor.current,
                            )
                          : const HeroIcon(HeroIcons.arrowUp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A website field with a copy button in the suffix.
class _WebsiteWithCopy extends StatefulWidget {
  const _WebsiteWithCopy({this.withIcon = false});

  final bool withIcon;

  @override
  State<_WebsiteWithCopy> createState() => _WebsiteWithCopyState();
}

class _WebsiteWithCopyState extends State<_WebsiteWithCopy> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroTextField(
      name: 'website',
      defaultValue: 'heroui.com',
      children: <Widget>[
        const HeroLabel.text('Website'),
        HeroInputGroup(
          children: <Widget>[
            if (widget.withIcon)
              const HeroInputGroupPrefix(child: HeroIcon(HeroIcons.globe)),
            const HeroInputGroupInput(),
            HeroInputGroupSuffix(
              padding: EdgeInsetsDirectional.only(start: theme.spacing(3)),
              child: HeroButton(
                isIconOnly: true,
                size: HeroSize.sm,
                variant: HeroButtonVariant.ghost,
                semanticLabel: 'Copy',
                onPressed: () => setState(() => _copied = !_copied),
                child: HeroIcon(_copied ? HeroIcons.check : HeroIcons.copy),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A password field whose suffix button toggles the visibility.
class _PasswordToggle extends StatefulWidget {
  const _PasswordToggle();

  @override
  State<_PasswordToggle> createState() => _PasswordToggleState();
}

class _PasswordToggleState extends State<_PasswordToggle> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroTextField(
      name: 'password',
      value: _visible ? r'87$2h.3diua' : '••••••••',
      children: <Widget>[
        const HeroLabel.text('Password'),
        HeroInputGroup(
          children: <Widget>[
            HeroInputGroupInput(
              type: _visible ? HeroInputType.text : HeroInputType.password,
            ),
            HeroInputGroupSuffix(
              padding: EdgeInsetsDirectional.only(start: theme.spacing(3)),
              child: HeroButton(
                isIconOnly: true,
                size: HeroSize.sm,
                variant: HeroButtonVariant.ghost,
                semanticLabel: _visible ? 'Hide password' : 'Show password',
                onPressed: () => setState(() => _visible = !_visible),
                child: HeroIcon(_visible ? HeroIcons.eye : HeroIcons.eyeSlash),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The docs' feedback text area with a character counter.
class _FeedbackField extends StatefulWidget {
  const _FeedbackField();

  @override
  State<_FeedbackField> createState() => _FeedbackFieldState();
}

class _FeedbackFieldState extends State<_FeedbackField> {
  String _feedback = '';

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroTextField(
      name: 'feedback',
      fullWidth: true,
      isInvalid: _feedback.length > 500,
      onChanged: (String value) => setState(() => _feedback = value),
      children: <Widget>[
        const HeroLabel.text('Your Feedback'),
        const HeroInputGroup(
          fullWidth: true,
          children: <Widget>[
            HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
            HeroInputGroupTextArea(
              placeholder: 'Share your thoughts, suggestions, or issues...',
              rows: 5,
            ),
          ],
        ),
        HeroDescription(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
            child: Row(
              children: <Widget>[
                const Expanded(child: Text('Maximum 500 characters.')),
                Text('${_feedback.length}/500'),
              ],
            ),
          ),
        ),
        const HeroFieldError.text('Feedback must be less than 500 characters'),
      ],
    );
  }
}
