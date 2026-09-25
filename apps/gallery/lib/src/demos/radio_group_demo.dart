import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroRadioGroup`, reproducing
/// heroui.com/docs/components/radio-group.
final ComponentDemo radioGroupDemo = ComponentDemo(
  slug: 'radio-group',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      OptionsControl('orientation', <String>['vertical', 'horizontal']),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      ToggleControl('isInvalid'),
      ToggleControl('isRequired'),
      TextControl('label', initial: 'Plan selection'),
      TextControl(
        'description',
        initial: 'Choose the plan that suits you best',
      ),
    ],
    builder: (BuildContext context, PlaygroundValues values) => HeroRadioGroup(
      name: 'plan',
      defaultValue: 'premium',
      label: values.text('label'),
      description: values.text('description').isEmpty
          ? null
          : values.text('description'),
      errorMessage: 'Choose a plan before continuing.',
      variant: values.pick('variant', HeroFieldVariant.values),
      orientation: values.pick('orientation', Axis.values),
      isDisabled: values.toggle('isDisabled'),
      isReadOnly: values.toggle('isReadOnly'),
      isInvalid: values.toggle('isInvalid') ? true : null,
      isRequired: values.toggle('isRequired'),
      children: _plans,
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroRadioGroup(\n')
        ..writeln("  name: 'plan',")
        ..writeln("  defaultValue: 'premium',")
        ..writeln("  label: '${values.text('label')}',");
      if (values.text('description').isNotEmpty) {
        out.writeln("  description: '${values.text('description')}',");
      }
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      if (values.option('orientation') != 'vertical') {
        out.writeln('  orientation: Axis.${values.option('orientation')},');
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
        ..writeln("    HeroRadio(value: 'basic', label: 'Basic Plan'),")
        ..writeln("    HeroRadio(value: 'premium', label: 'Premium Plan'),")
        ..writeln("    HeroRadio(value: 'business', label: 'Business Plan'),")
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
      title: 'Horizontal Orientation',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroLabel.text('Subscription plan'),
          HeroRadioGroup(
            name: 'plan-orientation',
            defaultValue: 'pro',
            orientation: Axis.horizontal,
            children: <Widget>[
              HeroRadio(
                value: 'starter',
                label: 'Starter',
                description: 'For side projects',
              ),
              HeroRadio(
                value: 'pro',
                label: 'Pro',
                description: 'Advanced reporting',
              ),
              HeroRadio(
                value: 'teams',
                label: 'Teams',
                description: 'Up to 10 teammates',
              ),
            ],
          ),
        ],
      ),
      code: '''
const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroLabel.text('Subscription plan'),
    HeroRadioGroup(
      name: 'plan-orientation',
      defaultValue: 'pro',
      orientation: Axis.horizontal,
      children: <Widget>[
        HeroRadio(
          value: 'starter',
          label: 'Starter',
          description: 'For side projects',
        ),
        HeroRadio(value: 'pro', label: 'Pro', description: 'Advanced reporting'),
        HeroRadio(
          value: 'teams',
          label: 'Teams',
          description: 'Up to 10 teammates',
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Variants',
      description:
          'primary (default) for most use cases; secondary is the lower '
          'emphasis variant for surfaces.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 32,
        children: <Widget>[
          _Caption(
            title: 'Primary variant',
            child: HeroRadioGroup(
              name: 'primary-plan',
              defaultValue: 'option1',
              children: <Widget>[
                HeroRadio(
                  value: 'option1',
                  label: 'Option 1',
                  description: 'Standard styling with default background',
                ),
                HeroRadio(
                  value: 'option2',
                  label: 'Option 2',
                  description: 'Another option with primary styling',
                ),
              ],
            ),
          ),
          _Caption(
            title: 'Secondary variant',
            child: HeroRadioGroup(
              name: 'secondary-plan',
              defaultValue: 'option1',
              variant: HeroFieldVariant.secondary,
              children: <Widget>[
                HeroRadio(
                  value: 'option1',
                  label: 'Option 1',
                  description: 'Lower emphasis variant for use in surfaces',
                ),
                HeroRadio(
                  value: 'option2',
                  label: 'Option 2',
                  description: 'Another option with secondary styling',
                ),
              ],
            ),
          ),
        ],
      ),
      code: '''
const HeroRadioGroup(
  name: 'secondary-plan',
  defaultValue: 'option1',
  variant: HeroFieldVariant.secondary, // or primary (the default)
  children: <Widget>[
    HeroRadio(
      value: 'option1',
      label: 'Option 1',
      description: 'Lower emphasis variant for use in surfaces',
    ),
    HeroRadio(
      value: 'option2',
      label: 'Option 2',
      description: 'Another option with secondary styling',
    ),
  ],
)''',
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
            child: _BasicGroup(
              name: 'plan-on-surface',
              variant: HeroFieldVariant.secondary,
            ),
          ),
        );
      },
      code: '''
HeroSurface(
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const HeroRadioGroup(
    name: 'plan-on-surface',
    defaultValue: 'premium',
    variant: HeroFieldVariant.secondary,
    label: 'Plan selection',
    description: 'Choose the plan that suits you best',
    children: <Widget>[
      HeroRadio(
        value: 'basic',
        label: 'Basic Plan',
        description: 'Includes 100 messages per month',
      ),
      // ...
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Disabled',
      builder: (BuildContext context) => const HeroRadioGroup(
        name: 'plan-disabled',
        isDisabled: true,
        defaultValue: 'pro',
        label: 'Subscription plan',
        description:
            'Plan changes are temporarily paused while we roll out updates.',
        children: _subscriptionPlans,
      ),
      code: '''
const HeroRadioGroup(
  name: 'plan-disabled',
  isDisabled: true,
  defaultValue: 'pro',
  label: 'Subscription plan',
  description: 'Plan changes are temporarily paused while we roll out updates.',
  children: <Widget>[
    HeroRadio(
      value: 'starter',
      label: 'Starter',
      description: 'For side projects and small teams',
    ),
    HeroRadio(
      value: 'pro',
      label: 'Pro',
      description: 'Advanced reporting and analytics',
    ),
    HeroRadio(
      value: 'teams',
      label: 'Teams',
      description: 'Share access with up to 10 teammates',
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      builder: (BuildContext context) =>
          const _CaptionedGroup(controlled: true),
      code: '''
String value = 'pro';

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroRadioGroup(
      name: 'plan-controlled',
      value: value,
      onChanged: (String next) => setState(() => value = next),
      label: 'Subscription plan',
      children: plans,
    ),
    Text.rich(
      TextSpan(
        text: 'Selected plan: ',
        children: <InlineSpan>[
          TextSpan(
            text: value,
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
      title: 'Uncontrolled',
      description:
          'Combine defaultValue with onChanged when you only need to react '
          'to updates.',
      builder: (BuildContext context) =>
          const _CaptionedGroup(controlled: false),
      code: '''
String selection = 'pro';

HeroRadioGroup(
  name: 'plan-uncontrolled',
  defaultValue: 'pro',
  onChanged: (String next) => setState(() => selection = next),
  label: 'Subscription plan',
  children: plans,
)
// Caption: Text('Last chosen plan: \$selection')''',
    ),
    DemoExample(
      title: 'Validation',
      builder: (BuildContext context) => const _ValidationGroup(),
      code: '''
HeroForm(
  onSubmit: (Map<String, Object?> data) => setState(
    () => message = 'Your chosen plan is: \${data['plan-validation']}',
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 16,
    children: <Widget>[
      const HeroRadioGroup(
        name: 'plan-validation',
        isRequired: true,
        children: <Widget>[
          HeroLabel.text('Subscription plan'),
          HeroRadio(value: 'starter', label: 'Starter'),
          HeroRadio(value: 'pro', label: 'Pro'),
          HeroRadio(value: 'teams', label: 'Teams'),
          HeroFieldError.text('Choose a subscription before continuing.'),
        ],
      ),
      Padding(
        padding: EdgeInsets.only(top: theme.spacing(2)),
        child: const HeroButton(
          type: HeroButtonType.submit,
          child: Text('Submit'),
        ),
      ),
      if (message != null) Text(message!),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'Delivery & Payment',
      description:
          'Card radios under a theme override (accent #006FEE, 2 px field '
          'borders): the selected card gets an accent border and an accent/10 '
          'fill. Brand logos are replaced by neutral icons.',
      builder: (BuildContext context) => const _DeliveryAndPayment(),
      code: '''
HeroTheme(
  data: theme.copyWith(
    colors: theme.colors.copyWith(
      accent: const Color(0xFF006FEE),
      accentForeground: const Color(0xFFFFFFFF),
      accentHover: const Color(0xFF006FEE),
      focus: const Color(0xFF006FEE),
    ),
    borderWidth: 2,
    fieldBorderWidth: 2,
  ),
  child: HeroRadioGroup(
    name: 'delivery',
    defaultValue: 'express',
    variant: HeroFieldVariant.secondary,
    children: <Widget>[
      const HeroLabel.text('Delivery method'),
      for (final DeliveryOption option in deliveryOptions)
        HeroRadio(
          value: option.value,
          children: <Widget>[
            HeroRadioContent(
              fullWidth: true,
              decoration: WidgetStateProperty.resolveWith(
                (Set<WidgetState> states) {
                  final bool active = states.contains(WidgetState.selected) ||
                      states.contains(WidgetState.focused);
                  return ShapeDecoration(
                    color: active
                        ? theme.colors.accent.withValues(alpha: 0.1)
                        : theme.colors.surface,
                    shape: theme.shapeAll(
                      theme.radii.xl,
                      side: BorderSide(
                        width: 2,
                        color: active
                            ? theme.colors.accent
                            : const Color(0x00000000),
                      ),
                    ),
                  );
                },
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
                        child: Column(/* title, description, price */),
                      ),
                      PositionedDirectional(
                        top: theme.spacing(3),
                        end: theme.spacing(4),
                        child: HeroRadioControl(size: theme.spacing(5)),
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
)''',
    ),
    DemoExample(
      title: 'Custom Indicator',
      description: 'A check mark replaces the dot of the selected radio.',
      builder: (BuildContext context) => HeroRadioGroup(
        name: 'plan-custom-indicator',
        defaultValue: 'premium',
        label: 'Plan selection',
        description: 'Choose the plan that suits you best',
        children: <Widget>[
          for (final (String value, String label, String description)
              in _planOptions)
            HeroRadio(
              value: value,
              children: <Widget>[
                HeroRadioContent(
                  children: <Widget>[
                    const HeroRadioControl(
                      child: HeroRadioIndicator(builder: _checkIndicator),
                    ),
                    Text(label),
                  ],
                ),
                HeroDescription.text(description),
              ],
            ),
        ],
      ),
      code: '''
HeroRadio(
  value: 'basic',
  children: <Widget>[
    HeroRadioContent(
      children: <Widget>[
        HeroRadioControl(
          child: HeroRadioIndicator(
            builder: (BuildContext context, HeroRadioState state) =>
                state.isSelected
                ? Text(
                    '✓',
                    style: theme.typography.xs.copyWith(
                      height: 1,
                      color: theme.colors.background,
                    ),
                  )
                : null,
          ),
        ),
        const Text('Basic Plan'),
      ],
    ),
    const HeroDescription.text('Includes 100 messages per month'),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'React renders the group through a custom element. In Flutter the '
          'group is composed like any other widget, so the output is '
          'identical to the basic example.',
      builder: (BuildContext context) =>
          const _BasicGroup(name: 'plan-custom-render'),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Customization',
      description:
          'Success-tinted cards with 20 px controls whose dot grows to 50% '
          '(57% while pressed).',
      builder: (BuildContext context) => const _BillingCycle(),
      code: '''
HeroRadioGroup(
  name: 'billing',
  defaultValue: 'yearly',
  variant: HeroFieldVariant.secondary,
  spacing: theme.spacing(3),
  itemMargin: EdgeInsets.zero,
  children: <Widget>[
    HeroLabel.text(
      'Billing cycle',
      style: TextStyle(color: theme.colors.foreground),
    ),
    const HeroDescription.text('Choose how often you are charged.'),
    for (final (String value, String label, String description) in options)
      HeroRadio(
        value: value,
        children: <Widget>[
          HeroRadioContent(
            fullWidth: true,
            crossAxisAlignment: CrossAxisAlignment.start,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing(4),
              vertical: theme.spacing(3),
            ),
            decoration: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) => ShapeDecoration(
                color: states.contains(WidgetState.hovered)
                    ? colors.successSoftHover
                    : states.contains(WidgetState.selected)
                    ? colors.successSoft
                    : colors.successSoft.withValues(alpha: 0.3),
                shape: theme.shapeAll(
                  theme.radii.xl,
                  side: BorderSide(
                    color: colors.success.withValues(
                      alpha: states.contains(WidgetState.selected) ? 0.3 : 0.1,
                    ),
                  ),
                ),
              ),
            ),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: theme.spacing(0.5)),
                child: HeroRadioControl(
                  size: theme.spacing(5),
                  borderRadius: BorderRadius.circular(theme.radii.full),
                  selectedColor: colors.success,
                  pressedColor: colors.successHover,
                  side: BorderSide(color: colors.border),
                  child: HeroRadioIndicator(
                    selectedColor: colors.successForeground,
                    selectedScale: 0.5,
                    pressedScale: 0.57,
                  ),
                ),
              ),
              Column(/* label and description */),
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
const HeroRadioGroup(
  name: 'plan',
  defaultValue: 'premium',
  label: 'Plan selection',
  description: 'Choose the plan that suits you best',
  children: <Widget>[
    HeroRadio(
      value: 'basic',
      label: 'Basic Plan',
      description: 'Includes 100 messages per month',
    ),
    HeroRadio(
      value: 'premium',
      label: 'Premium Plan',
      description: 'Includes 200 messages per month',
    ),
    HeroRadio(
      value: 'business',
      label: 'Business Plan',
      description: 'Unlimited messages',
    ),
  ],
)''';

const List<(String, String, String)> _planOptions = <(String, String, String)>[
  ('basic', 'Basic Plan', 'Includes 100 messages per month'),
  ('premium', 'Premium Plan', 'Includes 200 messages per month'),
  ('business', 'Business Plan', 'Unlimited messages'),
];

const List<Widget> _plans = <Widget>[
  HeroRadio(
    value: 'basic',
    label: 'Basic Plan',
    description: 'Includes 100 messages per month',
  ),
  HeroRadio(
    value: 'premium',
    label: 'Premium Plan',
    description: 'Includes 200 messages per month',
  ),
  HeroRadio(
    value: 'business',
    label: 'Business Plan',
    description: 'Unlimited messages',
  ),
];

const List<Widget> _subscriptionPlans = <Widget>[
  HeroRadio(
    value: 'starter',
    label: 'Starter',
    description: 'For side projects and small teams',
  ),
  HeroRadio(
    value: 'pro',
    label: 'Pro',
    description: 'Advanced reporting and analytics',
  ),
  HeroRadio(
    value: 'teams',
    label: 'Teams',
    description: 'Share access with up to 10 teammates',
  ),
];

Widget? _checkIndicator(BuildContext context, HeroRadioState state) {
  if (!state.isSelected) return null;
  final HeroThemeData theme = HeroTheme.of(context);
  return Text(
    '✓',
    style: theme.typography.xs.copyWith(
      height: 1,
      color: theme.colors.background,
    ),
  );
}

class _BasicGroup extends StatelessWidget {
  const _BasicGroup({
    this.name = 'plan',
    this.variant = HeroFieldVariant.primary,
  });

  final String name;
  final HeroFieldVariant variant;

  @override
  Widget build(BuildContext context) {
    return HeroRadioGroup(
      name: name,
      defaultValue: 'premium',
      variant: variant,
      label: 'Plan selection',
      description: 'Choose the plan that suits you best',
      children: _plans,
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

/// The controlled and uncontrolled examples: a group and a caption.
class _CaptionedGroup extends StatefulWidget {
  const _CaptionedGroup({required this.controlled});

  final bool controlled;

  @override
  State<_CaptionedGroup> createState() => _CaptionedGroupState();
}

class _CaptionedGroupState extends State<_CaptionedGroup> {
  String _value = 'pro';

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool controlled = widget.controlled;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroRadioGroup(
          name: controlled ? 'plan-controlled' : 'plan-uncontrolled',
          value: controlled ? _value : null,
          defaultValue: controlled ? null : 'pro',
          onChanged: (String next) => setState(() => _value = next),
          label: 'Subscription plan',
          children: _subscriptionPlans,
        ),
        Text.rich(
          TextSpan(
            text: controlled ? 'Selected plan: ' : 'Last chosen plan: ',
            children: <InlineSpan>[
              TextSpan(
                text: _value,
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

class _ValidationGroup extends StatefulWidget {
  const _ValidationGroup();

  @override
  State<_ValidationGroup> createState() => _ValidationGroupState();
}

class _ValidationGroupState extends State<_ValidationGroup> {
  String? _message;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final String? message = _message;
    return HeroForm(
      onSubmit: (Map<String, Object?> data) => setState(
        () => _message = 'Your chosen plan is: ${data['plan-validation']}',
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          const HeroRadioGroup(
            name: 'plan-validation',
            isRequired: true,
            children: <Widget>[
              HeroLabel.text('Subscription plan'),
              ..._subscriptionPlans,
              HeroFieldError.text('Choose a subscription before continuing.'),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: theme.spacing(2)),
            child: const HeroButton(
              type: HeroButtonType.submit,
              child: Text('Submit'),
            ),
          ),
          if (message != null)
            Text(
              message,
              style: theme.typography.sm.copyWith(color: theme.colors.muted),
            ),
        ],
      ),
    );
  }
}

class _DeliveryAndPayment extends StatelessWidget {
  const _DeliveryAndPayment();

  static const List<(String, String, String, String)> _delivery =
      <(String, String, String, String)>[
        ('standard', 'Standard', '4-10 business days', r'$5.00'),
        ('express', 'Express', '2-5 business days', r'$16.00'),
        ('super-fast', 'Super Fast', '1 business day', r'$25.00'),
      ];

  static const List<(String, String, String, HeroIconData)> _payment =
      <(String, String, String, HeroIconData)>[
        ('mastercard', '**** 8304', 'Exp. on 01/2026', HeroIcons.creditCard),
        ('visa', '**** 0123', 'Exp. on 01/2026', HeroIcons.creditCard),
        ('paypal', 'PayPal', 'Pay with PayPal', HeroIcons.wallet),
      ];

  @override
  Widget build(BuildContext context) {
    final HeroThemeData base = HeroTheme.of(context);
    // The example overrides HeroUI's variables on its container.
    const Color accent = Color(0xFF006FEE);
    final HeroThemeData theme = base.copyWith(
      colors: base.colors.copyWith(
        accent: accent,
        accentForeground: const Color(0xFFFFFFFF),
        accentHover: accent,
        focus: accent,
      ),
      borderWidth: 2,
      fieldBorderWidth: 2,
    );
    final bool desktop = theme.isDesktop(context);
    return HeroTheme(
      data: theme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 40,
        children: <Widget>[
          ConstrainedBox(
            // `w-full max-w-lg`
            constraints: const BoxConstraints(maxWidth: 512),
            child: HeroRadioGroup(
              fullWidth: true,
              name: 'delivery',
              defaultValue: 'express',
              variant: HeroFieldVariant.secondary,
              children: <Widget>[
                const HeroLabel.text('Delivery method'),
                _Grid(
                  columns: desktop ? 3 : 1,
                  children: <Widget>[
                    for (final (
                          String value,
                          String title,
                          String description,
                          String price,
                        )
                        in _delivery)
                      _CardRadio(
                        value: value,
                        vertical: true,
                        children: <Widget>[
                          _Texts(title: title, description: description),
                          Text(
                            price,
                            style: theme.typography
                                .style(
                                  HeroFontSize.sm,
                                  weight: HeroTypography.semibold,
                                )
                                .copyWith(color: theme.colors.foreground),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          ConstrainedBox(
            // `w-full max-w-lg`
            constraints: const BoxConstraints(maxWidth: 512),
            child: HeroRadioGroup(
              fullWidth: true,
              name: 'payment',
              defaultValue: 'visa',
              variant: HeroFieldVariant.secondary,
              children: <Widget>[
                const HeroLabel.text('Payment method'),
                _Grid(
                  columns: desktop ? 2 : 1,
                  children: <Widget>[
                    for (final (
                          String value,
                          String title,
                          String description,
                          HeroIconData icon,
                        )
                        in _payment)
                      _CardRadio(
                        value: value,
                        vertical: false,
                        children: <Widget>[
                          HeroIcon(icon, size: theme.spacing(6)),
                          _Texts(title: title, description: description),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A CSS grid with [columns] equal columns and a 16 px column gap.
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children});

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final double gap = HeroTheme.of(context).spacing(4);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int row = 0; row < children.length; row += columns)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: gap,
              children: <Widget>[
                for (int i = row; i < row + columns; i++)
                  Expanded(
                    child: i < children.length
                        ? children[i]
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Texts extends StatelessWidget {
  const _Texts({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: HeroTheme.of(context).spacing(1),
      children: <Widget>[Text(title), HeroDescription.text(description)],
    );
  }
}

/// A radio drawn as a card: surface background, radius 12, a 2 px border
/// and an accent/10 fill when selected, with the control in the top-end
/// corner.
class _CardRadio extends StatelessWidget {
  const _CardRadio({
    required this.value,
    required this.vertical,
    required this.children,
  });

  final String value;
  final bool vertical;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    return HeroRadio(
      value: value,
      children: <Widget>[
        HeroRadioContent(
          fullWidth: true,
          decoration: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            final bool active =
                states.contains(WidgetState.selected) ||
                states.contains(WidgetState.focused);
            return ShapeDecoration(
              color: active
                  ? colors.accent.withValues(alpha: 0.1)
                  : colors.surface,
              shape: theme.shapeAll(
                theme.radii.xl,
                side: BorderSide(
                  width: theme.borderWidth,
                  color: active
                      ? colors.accent
                      : colors.accent.withValues(alpha: 0),
                ),
              ),
            );
          }),
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing(5),
                      vertical: theme.spacing(4),
                    ),
                    child: vertical
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: theme.spacing(6),
                            children: children,
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: theme.spacing(4),
                            children: <Widget>[
                              children.first,
                              Flexible(child: children.last),
                            ],
                          ),
                  ),
                  PositionedDirectional(
                    top: theme.spacing(3),
                    end: theme.spacing(4),
                    child: HeroRadioControl(size: theme.spacing(5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BillingCycle extends StatelessWidget {
  const _BillingCycle();

  static const List<(String, String, String)> _options =
      <(String, String, String)>[
        ('monthly', 'Monthly', r'$12 billed every month'),
        ('yearly', 'Yearly', r'$120 billed once a year'),
      ];

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    return ConstrainedBox(
      // `w-full max-w-sm`
      constraints: const BoxConstraints(maxWidth: 384),
      child: HeroRadioGroup(
        fullWidth: true,
        name: 'billing',
        defaultValue: 'yearly',
        variant: HeroFieldVariant.secondary,
        spacing: theme.spacing(3),
        itemMargin: EdgeInsets.zero,
        children: <Widget>[
          HeroLabel.text(
            'Billing cycle',
            style: TextStyle(color: colors.foreground),
          ),
          const HeroDescription.text('Choose how often you are charged.'),
          for (final (String value, String label, String description)
              in _options)
            HeroRadio(
              value: value,
              builder: (BuildContext context, HeroRadioState state) => <Widget>[
                HeroRadioContent(
                  fullWidth: true,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing(4),
                    vertical: theme.spacing(3),
                  ),
                  decoration: WidgetStateProperty.resolveWith(
                    (Set<WidgetState> states) => ShapeDecoration(
                      color: states.contains(WidgetState.hovered)
                          ? colors.successSoftHover
                          : states.contains(WidgetState.selected)
                          ? colors.successSoft
                          : colors.successSoft.withValues(
                              alpha: colors.successSoft.a * 0.3,
                            ),
                      shape: theme.shapeAll(
                        theme.radii.xl,
                        side: BorderSide(
                          color: colors.success.withValues(
                            alpha: states.contains(WidgetState.selected)
                                ? 0.3
                                : 0.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: theme.spacing(0.5)),
                      child: HeroRadioControl(
                        size: theme.spacing(5),
                        borderRadius: BorderRadius.circular(theme.radii.full),
                        selectedColor: colors.success,
                        pressedColor: colors.successHover,
                        side: BorderSide(color: colors.border),
                        child: HeroRadioIndicator(
                          selectedColor: colors.successForeground,
                          selectedScale: 0.5,
                          pressedScale: 0.57,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: theme.spacing(0.5),
                      children: <Widget>[
                        Text(
                          label,
                          style: TextStyle(
                            color: state.isSelected
                                ? colors.successSoftForeground
                                : colors.foreground,
                          ),
                        ),
                        HeroDescription.text(
                          description,
                          style: state.isSelected
                              ? TextStyle(
                                  color: colors.successSoftForeground
                                      .withValues(alpha: 0.8),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
