import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroFieldset`, reproducing
/// heroui.com/docs/components/fieldset.
final ComponentDemo fieldsetDemo = ComponentDemo(
  slug: 'fieldset',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      ToggleControl('isDisabled'),
      TextControl('legend', initial: 'Profile Settings'),
      TextControl('description', initial: 'Update your profile information.'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: 384,
      child: HeroFieldset(
        legend: values.text('legend'),
        description: values.text('description'),
        isDisabled: values.toggle('isDisabled'),
        actions: <Widget>[
          HeroButton(onPressed: () {}, child: const Text('Save changes')),
          const HeroButton(
            variant: HeroButtonVariant.secondary,
            child: Text('Cancel'),
          ),
        ],
        children: <Widget>[
          HeroFieldsetGroup(
            children: <Widget>[
              HeroTextField(
                label: 'Name',
                placeholder: 'John Doe',
                variant: values.pick('variant', HeroFieldVariant.values),
              ),
              HeroTextField(
                label: 'Email',
                placeholder: 'john@example.com',
                type: HeroInputType.email,
                variant: values.pick('variant', HeroFieldVariant.values),
              ),
            ],
          ),
        ],
      ),
    ),
    code: (PlaygroundValues values) {
      final String variant = values.option('variant') == 'primary'
          ? ''
          : '\n          variant: HeroFieldVariant.${values.option('variant')},';
      return '''
HeroFieldset(
  legend: '${values.text('legend')}',
  description: '${values.text('description')}',${values.toggle('isDisabled') ? '\n  isDisabled: true,' : ''}
  actions: <Widget>[
    HeroButton(onPressed: save, child: const Text('Save changes')),
    const HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text('Cancel'),
    ),
  ],
  children: <Widget>[
    HeroFieldsetGroup(
      children: <Widget>[
        HeroTextField(
          label: 'Name',
          placeholder: 'John Doe',$variant
        ),
        HeroTextField(
          label: 'Email',
          placeholder: 'john@example.com',
          type: HeroInputType.email,$variant
        ),
      ],
    ),
  ],
)''';
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) =>
          const SizedBox(width: 384, child: _ProfileForm()),
      code: _profileCode,
    ),
    DemoExample(
      title: 'In Surface',
      description:
          'Inside a Surface, use the secondary variant on the form controls '
          'for the lower emphasis look suited to surface backgrounds.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return HeroSurface(
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: EdgeInsets.all(theme.spacing(6)),
          child: const SizedBox(
            width: 380,
            child: _ProfileForm(
              variant: HeroFieldVariant.secondary,
              cancelVariant: HeroButtonVariant.tertiary,
            ),
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: SizedBox(
    width: 380,
    child: HeroForm(
      onSubmit: (Map<String, Object?> data) => showSuccess(),
      child: HeroFieldset(
        children: <Widget>[
          const HeroFieldsetLegend.text('Profile Settings'),
          const HeroDescription.text('Update your profile information.'),
          HeroFieldsetGroup(
            children: <Widget>[
              HeroTextField(
                name: 'name',
                isRequired: true,
                validator: validateName,
                children: const <Widget>[
                  HeroLabel.text('Name'),
                  HeroInput(
                    placeholder: 'John Doe',
                    variant: HeroFieldVariant.secondary,
                  ),
                  HeroFieldError(),
                ],
              ),
              // ... Email and Bio with variant: HeroFieldVariant.secondary
            ],
          ),
          const HeroFieldsetActions(
            children: <Widget>[
              HeroButton(
                type: HeroButtonType.submit,
                startContent: HeroIcon(HeroIcons.floppyDisk),
                child: Text('Save changes'),
              ),
              HeroButton(
                type: HeroButtonType.reset,
                variant: HeroButtonVariant.tertiary,
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A shell with rounded-xl corners, a border, a vertical gradient, '
          'padding and a hairline ring; muted legend and description colors '
          'and restyled inputs.',
      builder: (BuildContext context) =>
          const SizedBox(width: 384, child: _ProfileForm(custom: true)),
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final bool dark = theme.isDark;
final HeroFieldStyle field = HeroFieldStyle(
  borderRadius: BorderRadius.circular(theme.radii.xl),
  borderWidth: theme.borderWidth,
  borderColor: theme.colors.border.withValues(alpha: 0.8),
  backgroundColor: theme.colors.surface,
  shadow: HeroShadow(
    boxShadows: <BoxShadow>[
      BoxShadow(
        color: dark ? const Color(0x1AFFFFFF) : const Color(0x0D000000),
        spreadRadius: 1,
      ),
      ...theme.shadows.surface.boxShadows,
    ],
  ),
  focusRingColor: dark ? const Color(0x4D737373) : const Color(0x40A1A1A1),
);

HeroForm(
  onSubmit: (Map<String, Object?> data) => showSuccess(),
  child: HeroFieldset(
    padding: EdgeInsets.all(theme.spacing(4)),
    decoration: ShapeDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? const <Color>[Color(0xCC171717), Color(0xFF171717)]
            : const <Color>[Color(0xE6FAFAFA), Color(0xFFFFFFFF)],
      ),
      shape: theme.shapeAll(
        theme.radii.xl,
        side: BorderSide(color: theme.colors.border.withValues(alpha: 0.7)),
      ),
      shadows: <BoxShadow>[
        BoxShadow(
          color: dark ? const Color(0x1AFFFFFF) : const Color(0x0D000000),
          spreadRadius: 1,
        ),
      ],
    ),
    children: <Widget>[
      HeroFieldsetLegend.text(
        'Profile Settings',
        style: TextStyle(
          color: dark ? const Color(0xFFF5F5F5) : const Color(0xFF262626),
        ),
      ),
      HeroDescription.text(
        'Update your profile information.',
        style: TextStyle(
          color: dark ? const Color(0xFFA1A1A1) : const Color(0xFF525252),
        ),
      ),
      HeroFieldsetGroup(
        children: <Widget>[
          HeroTextField(
            name: 'name',
            isRequired: true,
            validator: validateName,
            children: <Widget>[
              const HeroLabel.text('Name'),
              HeroInput(placeholder: 'John Doe', style: field),
              const HeroFieldError(),
            ],
          ),
          // ... Email (HeroInput) and Bio (HeroTextArea) with style: field
        ],
      ),
      const HeroFieldsetActions(
        children: <Widget>[
          HeroButton(
            type: HeroButtonType.submit,
            startContent: HeroIcon(HeroIcons.floppyDisk),
            child: Text('Save changes'),
          ),
          HeroButton(
            type: HeroButtonType.reset,
            variant: HeroButtonVariant.secondary,
            child: Text('Cancel'),
          ),
        ],
      ),
    ],
  ),
)''',
    ),
  ],
);

const String _profileCode = r'''
HeroForm(
  onSubmit: (Map<String, Object?> data) => showSuccess(),
  child: SizedBox(
    width: 384,
    child: HeroFieldset(
      children: <Widget>[
        const HeroFieldsetLegend.text('Profile Settings'),
        const HeroDescription.text('Update your profile information.'),
        HeroFieldGroup(
          children: <Widget>[
            HeroTextField(
              name: 'name',
              isRequired: true,
              validator: (String? value) => (value ?? '').length < 3
                  ? 'Name must be at least 3 characters'
                  : null,
              children: const <Widget>[
                HeroLabel.text('Name'),
                HeroInput(placeholder: 'John Doe'),
                HeroFieldError(),
              ],
            ),
            const HeroTextField(
              name: 'email',
              type: HeroInputType.email,
              isRequired: true,
              children: <Widget>[
                HeroLabel.text('Email'),
                HeroInput(placeholder: 'john@example.com'),
                HeroFieldError(),
              ],
            ),
            HeroTextField(
              name: 'bio',
              isRequired: true,
              validator: (String? value) => (value ?? '').length < 10
                  ? 'Bio must be at least 10 characters'
                  : null,
              children: const <Widget>[
                HeroLabel.text('Bio'),
                HeroTextArea(placeholder: 'Tell us about yourself...'),
                HeroDescription.text('Minimum 10 characters'),
                HeroFieldError(),
              ],
            ),
          ],
        ),
        const HeroFieldsetActions(
          children: <Widget>[
            HeroButton(
              type: HeroButtonType.submit,
              startContent: HeroIcon(HeroIcons.floppyDisk),
              child: Text('Save changes'),
            ),
            HeroButton(
              type: HeroButtonType.reset,
              variant: HeroButtonVariant.secondary,
              child: Text('Cancel'),
            ),
          ],
        ),
      ],
    ),
  ),
)''';

String? _validateName(String? value) =>
    (value ?? '').length < 3 ? 'Name must be at least 3 characters' : null;

String? _validateBio(String? value) =>
    (value ?? '').length < 10 ? 'Bio must be at least 10 characters' : null;

/// The docs' profile form: a fieldset with a legend, a description, name,
/// email and bio fields and save / cancel actions.
class _ProfileForm extends StatefulWidget {
  const _ProfileForm({
    this.variant = HeroFieldVariant.primary,
    this.cancelVariant = HeroButtonVariant.secondary,
    this.custom = false,
  });

  final HeroFieldVariant variant;
  final HeroButtonVariant cancelVariant;
  final bool custom;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool dark = theme.isDark;
    final bool custom = widget.custom;
    final HeroFieldStyle? field = custom
        ? HeroFieldStyle(
            borderRadius: BorderRadius.circular(theme.radii.xl),
            borderWidth: theme.borderWidth,
            borderColor: theme.colors.border.withValues(alpha: 0.8),
            backgroundColor: theme.colors.surface,
            shadow: HeroShadow(
              boxShadows: <BoxShadow>[
                BoxShadow(
                  color: dark
                      ? const Color(0x1AFFFFFF)
                      : const Color(0x0D000000),
                  spreadRadius: 1,
                ),
                ...theme.shadows.surface.boxShadows,
              ],
            ),
            focusRingColor: dark
                ? const Color(0x4D737373)
                : const Color(0x40A1A1A1),
          )
        : null;

    return HeroForm(
      onSubmit: (Map<String, Object?> data) =>
          setState(() => _submitted = true),
      onReset: () => setState(() => _submitted = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          HeroFieldset(
            padding: custom ? EdgeInsets.all(theme.spacing(4)) : null,
            decoration: custom
                ? ShapeDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: dark
                          ? const <Color>[Color(0xCC171717), Color(0xFF171717)]
                          : const <Color>[Color(0xE6FAFAFA), Color(0xFFFFFFFF)],
                    ),
                    shape: theme.shapeAll(
                      theme.radii.xl,
                      side: BorderSide(
                        color: theme.colors.border.withValues(alpha: 0.7),
                      ),
                    ),
                    shadows: <BoxShadow>[
                      BoxShadow(
                        color: dark
                            ? const Color(0x1AFFFFFF)
                            : const Color(0x0D000000),
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : null,
            children: <Widget>[
              HeroFieldsetLegend.text(
                'Profile Settings',
                style: custom
                    ? TextStyle(
                        color: dark
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF262626),
                      )
                    : null,
              ),
              HeroDescription.text(
                'Update your profile information.',
                style: custom
                    ? TextStyle(
                        color: dark
                            ? const Color(0xFFA1A1A1)
                            : const Color(0xFF525252),
                      )
                    : null,
              ),
              HeroFieldGroup(
                children: <Widget>[
                  HeroTextField(
                    name: 'name',
                    isRequired: true,
                    validator: _validateName,
                    variant: widget.variant,
                    children: <Widget>[
                      const HeroLabel.text('Name'),
                      HeroInput(placeholder: 'John Doe', style: field),
                      const HeroFieldError(),
                    ],
                  ),
                  HeroTextField(
                    name: 'email',
                    type: HeroInputType.email,
                    isRequired: true,
                    variant: widget.variant,
                    children: <Widget>[
                      const HeroLabel.text('Email'),
                      HeroInput(placeholder: 'john@example.com', style: field),
                      const HeroFieldError(),
                    ],
                  ),
                  HeroTextField(
                    name: 'bio',
                    isRequired: true,
                    validator: _validateBio,
                    variant: widget.variant,
                    children: <Widget>[
                      const HeroLabel.text('Bio'),
                      HeroTextArea(
                        placeholder: 'Tell us about yourself...',
                        style: field,
                      ),
                      const HeroDescription.text('Minimum 10 characters'),
                      const HeroFieldError(),
                    ],
                  ),
                ],
              ),
              HeroFieldsetActions(
                children: <Widget>[
                  const HeroButton(
                    type: HeroButtonType.submit,
                    startContent: HeroIcon(HeroIcons.floppyDisk),
                    child: Text('Save changes'),
                  ),
                  HeroButton(
                    type: HeroButtonType.reset,
                    variant: widget.cancelVariant,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
          if (_submitted)
            Text(
              'Form submitted successfully!',
              style: theme.typography.sm.copyWith(color: theme.colors.success),
            ),
        ],
      ),
    );
  }
}
