import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../demo.dart';

/// Gallery page of `HeroNumberField`, reproducing
/// heroui.com/docs/components/number-field.
final ComponentDemo numberFieldDemo = ComponentDemo(
  slug: 'number-field',
  playground: Playground(
    controls: const <PlaygroundControl>[
      OptionsControl('variant', <String>['primary', 'secondary']),
      OptionsControl('style', <String>[
        'decimal',
        'currency',
        'percent',
        'unit',
      ]),
      ToggleControl('fullWidth'),
      ToggleControl('isRequired'),
      ToggleControl('isDisabled'),
      ToggleControl('isReadOnly'),
      ToggleControl('isInvalid'),
      ToggleControl('showStepper', initial: true),
      TextControl('label', initial: 'Width'),
      TextControl('description', initial: 'Enter the width in pixels'),
    ],
    builder: (BuildContext context, PlaygroundValues values) => SizedBox(
      width: values.toggle('fullWidth') ? 400 : null,
      child: HeroNumberField(
        key: ValueKey<String>(values.option('style')),
        label: values.text('label'),
        description: values.text('description'),
        errorMessage: 'Please enter a valid number',
        defaultValue: _playgroundValue(values.option('style')),
        minValue: 0,
        inputWidth: 120,
        formatOptions: _playgroundFormat(values.option('style')),
        variant: values.pick('variant', HeroFieldVariant.values),
        fullWidth: values.toggle('fullWidth'),
        isRequired: values.toggle('isRequired'),
        isDisabled: values.toggle('isDisabled'),
        isReadOnly: values.toggle('isReadOnly'),
        isInvalid: values.toggle('isInvalid') ? true : null,
        showStepper: values.toggle('showStepper'),
      ),
    ),
    code: (PlaygroundValues values) {
      final StringBuffer out = StringBuffer('HeroNumberField(\n')
        ..writeln("  label: '${values.text('label')}',")
        ..writeln("  description: '${values.text('description')}',")
        ..writeln(
          '  defaultValue: ${_playgroundValue(values.option('style'))},',
        )
        ..writeln('  minValue: 0,')
        ..writeln('  inputWidth: 120,');
      final String? format = _playgroundFormatCode(values.option('style'));
      if (format != null) out.writeln('  formatOptions: $format,');
      if (values.option('variant') != 'primary') {
        out.writeln('  variant: HeroFieldVariant.${values.option('variant')},');
      }
      for (final String flag in <String>[
        'fullWidth',
        'isRequired',
        'isDisabled',
        'isReadOnly',
        'isInvalid',
      ]) {
        if (values.toggle(flag)) out.writeln('  $flag: true,');
      }
      if (!values.toggle('showStepper')) out.writeln('  showStepper: false,');
      out.write(')');
      return out.toString();
    },
  ),
  examples: <DemoExample>[
    DemoExample(
      title: 'Usage',
      builder: (BuildContext context) =>
          const SizedBox(width: 256, child: _BasicWidth()),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Variants',
      description:
          'primary (default) has the field shadow; secondary is the lower '
          'emphasis variant without shadow, suited to surfaces.',
      builder: (BuildContext context) => const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroNumberField(
            name: 'primary-width',
            label: 'Primary variant',
            defaultValue: 100,
            minValue: 0,
            inputWidth: 120,
          ),
          HeroNumberField(
            name: 'secondary-width',
            variant: HeroFieldVariant.secondary,
            label: 'Secondary variant',
            defaultValue: 100,
            minValue: 0,
            inputWidth: 120,
          ),
        ],
      ),
      code: '''
const HeroNumberField(
  name: 'secondary-width',
  variant: HeroFieldVariant.secondary, // or primary (default)
  label: 'Secondary variant',
  defaultValue: 100,
  minValue: 0,
  inputWidth: 120,
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
          width: 280,
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: EdgeInsets.all(theme.spacing(6)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: <Widget>[
              HeroNumberField(
                name: 'width',
                variant: HeroFieldVariant.secondary,
                fullWidth: true,
                label: 'Width',
                defaultValue: 1024,
                minValue: 0,
                description: 'Enter the width in pixels',
              ),
              HeroNumberField(
                name: 'percentage',
                variant: HeroFieldVariant.secondary,
                fullWidth: true,
                label: 'Percentage',
                defaultValue: 0.5,
                minValue: 0,
                maxValue: 1,
                step: 0.1,
                formatOptions: _percent,
                description: 'Value must be between 0 and 100',
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
HeroSurface(
  width: 280,
  borderRadius: BorderRadius.circular(theme.radii.xl3),
  padding: EdgeInsets.all(theme.spacing(6)),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: <Widget>[
      HeroNumberField(
        name: 'width',
        variant: HeroFieldVariant.secondary,
        fullWidth: true,
        label: 'Width',
        defaultValue: 1024,
        minValue: 0,
        description: 'Enter the width in pixels',
      ),
      HeroNumberField(
        name: 'percentage',
        variant: HeroFieldVariant.secondary,
        fullWidth: true,
        label: 'Percentage',
        defaultValue: 0.5,
        minValue: 0,
        maxValue: 1,
        step: 0.1,
        formatOptions: HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.percent,
        ),
        description: 'Value must be between 0 and 100',
      ),
    ],
  ),
)''',
    ),
    DemoExample(
      title: 'With Description',
      builder: (BuildContext context) => const _WidthAndPercent(),
      code: _widthAndPercentCode,
    ),
    DemoExample(
      title: 'Required Field',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            HeroNumberField(
              name: 'quantity',
              isRequired: true,
              label: 'Quantity',
              minValue: 0,
              inputWidth: 120,
            ),
            HeroNumberField(
              name: 'rating',
              isRequired: true,
              label: 'Rating',
              defaultValue: 1,
              minValue: 1,
              maxValue: 10,
              inputWidth: 120,
              description: 'Rate from 1 to 10',
            ),
          ],
        ),
      ),
      code: '''
const HeroNumberField(
  name: 'rating',
  isRequired: true,
  label: 'Rating',
  defaultValue: 1,
  minValue: 1,
  maxValue: 10,
  inputWidth: 120,
  description: 'Rate from 1 to 10',
)''',
    ),
    DemoExample(
      title: 'Disabled State',
      builder: (BuildContext context) =>
          const _WidthAndPercent(isDisabled: true),
      code: '''
const HeroNumberField(
  name: 'width',
  isDisabled: true,
  label: 'Width',
  defaultValue: 1024,
  minValue: 0,
  inputWidth: 120,
  description: 'Enter the width in pixels',
)''',
    ),
    DemoExample(
      title: 'Full Width',
      builder: (BuildContext context) => const SizedBox(
        width: 400,
        child: HeroNumberField(
          name: 'width',
          fullWidth: true,
          label: 'Width',
          defaultValue: 1024,
          minValue: 0,
        ),
      ),
      code: '''
const SizedBox(
  width: 400,
  child: HeroNumberField(
    name: 'width',
    fullWidth: true,
    label: 'Width',
    defaultValue: 1024,
    minValue: 0,
  ),
)''',
    ),
    DemoExample(
      title: 'Validation',
      description: 'isInvalid with a FieldError surfaces validation messages.',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            HeroNumberField(
              name: 'quantity',
              isInvalid: true,
              isRequired: true,
              label: 'Quantity',
              value: -5,
              minValue: 0,
              inputWidth: 120,
              errorMessage: 'Quantity must be greater than or equal to 0',
            ),
            HeroNumberField(
              name: 'percentage',
              isInvalid: true,
              label: 'Percentage',
              value: 1.5,
              minValue: 0,
              maxValue: 1,
              step: 0.1,
              formatOptions: _percent,
              inputWidth: 120,
              errorMessage: 'Percentage must be between 0 and 100',
            ),
          ],
        ),
      ),
      code: '''
const HeroNumberField(
  name: 'quantity',
  isInvalid: true,
  isRequired: true,
  value: -5,
  minValue: 0,
  children: <Widget>[
    HeroLabel.text('Quantity'),
    HeroNumberFieldGroup(
      children: <Widget>[
        HeroNumberFieldDecrementButton(),
        HeroNumberFieldInput(width: 120),
        HeroNumberFieldIncrementButton(),
      ],
    ),
    HeroFieldError.text('Quantity must be greater than or equal to 0'),
  ],
)''',
    ),
    DemoExample(
      title: 'Controlled',
      description:
          'Control the value to synchronize it with other widgets or format '
          'it.',
      builder: (BuildContext context) => const _ControlledWidth(),
      code: r'''
double value = 1024;

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    HeroNumberField(
      name: 'width',
      label: 'Width',
      value: value,
      minValue: 0,
      onChanged: (double? v) => setState(() => value = v ?? 0),
      inputWidth: 120,
      description: 'Current value: ${value.round()}',
    ),
    Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        HeroButton(
          variant: HeroButtonVariant.tertiary,
          onPressed: () => setState(() => value = 0),
          child: const Text('Reset to 0'),
        ),
        HeroButton(
          variant: HeroButtonVariant.tertiary,
          onPressed: () => setState(() => value = 2048),
          child: const Text('Set to 2048'),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'With Step',
      builder: (BuildContext context) => SizedBox(
        width: 256,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            for (final int step in <int>[1, 5, 10])
              HeroNumberField(
                name: 'step$step',
                label: 'Step: $step',
                defaultValue: 0,
                minValue: 0,
                maxValue: 100,
                step: step.toDouble(),
                inputWidth: 120,
                description: 'Increments by $step',
              ),
          ],
        ),
      ),
      code: '''
const HeroNumberField(
  name: 'step5',
  label: 'Step: 5',
  defaultValue: 0,
  minValue: 0,
  maxValue: 100,
  step: 5,
  inputWidth: 120,
  description: 'Increments by 5',
)''',
    ),
    DemoExample(
      title: 'With Format Options',
      description: 'Currency, percentage, decimal and unit formatting.',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            HeroNumberField(
              name: 'currency-eur',
              label: 'Currency (EUR - Accounting)',
              defaultValue: 99,
              minValue: 0,
              formatOptions: _eurAccounting,
              inputWidth: 120,
              description: 'Accounting format with EUR currency',
            ),
            HeroNumberField(
              name: 'currency-usd',
              label: 'Currency (USD)',
              defaultValue: 99.99,
              minValue: 0,
              formatOptions: HeroNumberFormatOptions(
                style: HeroNumberFormatStyle.currency,
                currency: 'USD',
              ),
              inputWidth: 120,
              description: 'Standard USD currency format',
            ),
            HeroNumberField(
              name: 'percentage',
              label: 'Percentage',
              defaultValue: 0.5,
              minValue: 0,
              maxValue: 1,
              step: 0.01,
              formatOptions: _percent,
              inputWidth: 120,
              description: 'Percentage format (0-1, where 0.5 = 50%)',
            ),
            HeroNumberField(
              name: 'decimal',
              label: 'Decimal (2 decimal places)',
              defaultValue: 1234.56,
              minValue: 0,
              formatOptions: HeroNumberFormatOptions(
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              ),
              inputWidth: 120,
              description: 'Decimal format with 2 decimal places',
            ),
            HeroNumberField(
              name: 'unit',
              label: 'Unit (Kilograms)',
              defaultValue: 1000,
              minValue: 0,
              formatOptions: HeroNumberFormatOptions(
                style: HeroNumberFormatStyle.unit,
                unit: 'kilogram',
              ),
              inputWidth: 120,
              description: 'Unit format with kilograms',
            ),
          ],
        ),
      ),
      code: '''
const HeroNumberField(
  name: 'currency-eur',
  label: 'Currency (EUR - Accounting)',
  defaultValue: 99,
  minValue: 0,
  formatOptions: HeroNumberFormatOptions(
    style: HeroNumberFormatStyle.currency,
    currency: 'EUR',
    currencySign: HeroCurrencySign.accounting,
  ),
  inputWidth: 120,
  description: 'Accounting format with EUR currency',
)

// Percentage: 0.5 shows as 50%.
formatOptions: HeroNumberFormatOptions(style: HeroNumberFormatStyle.percent)

// Decimal with 2 decimal places.
formatOptions: HeroNumberFormatOptions(
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
)

// Unit.
formatOptions: HeroNumberFormatOptions(
  style: HeroNumberFormatStyle.unit,
  unit: 'kilogram',
  unitDisplay: HeroUnitDisplay.short,
)''',
    ),
    DemoExample(
      title: 'Form Example',
      description: 'Form integration with validation and submission.',
      builder: (BuildContext context) => const _OrderForm(),
      code: r'''
const int stockAvailable = 3;
double? value;
bool isSubmitting = false;

final bool isOutOfStock = value != null && value! > stockAvailable;

HeroForm(
  onSubmit: (Map<String, Object?> data) async {
    setState(() => isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    setState(() {
      value = null;
      isSubmitting = false;
    });
  },
  child: SizedBox(
    width: 280,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        HeroNumberField(
          name: 'quantity',
          isRequired: true,
          isInvalid: isOutOfStock,
          label: 'Order quantity',
          value: value ?? double.nan,
          minValue: 1,
          maxValue: 5,
          onChanged: (double? v) => setState(() => value = v),
          inputWidth: 120,
          description: 'Only $stockAvailable items available',
          errorMessage: 'Only $stockAvailable items left in stock',
        ),
        HeroButton(
          type: HeroButtonType.submit,
          fullWidth: true,
          isDisabled: value == null || value! < 1 || isOutOfStock,
          isPending: isSubmitting,
          child: Text(isSubmitting ? 'Processing...' : 'Place Order'),
        ),
      ],
    ),
  ),
)''',
    ),
    DemoExample(
      title: 'With Validation',
      description: 'Custom validation logic with a controlled value.',
      builder: (BuildContext context) => const _LiveValidatedPercent(),
      code: r'''
double? value;
final bool isInvalid = value != null && (value! < 0 || value! > 100);

HeroNumberField(
  name: 'percentage',
  isRequired: true,
  isInvalid: isInvalid,
  label: 'Percentage',
  value: value ?? double.nan,
  minValue: 0,
  maxValue: 1,
  step: 0.1,
  formatOptions: const HeroNumberFormatOptions(
    style: HeroNumberFormatStyle.percent,
  ),
  onChanged: (double? v) => setState(() => value = v),
  inputWidth: 120,
  description: 'Enter a value between 0 and 100',
  errorMessage: 'Percentage must be between 0 and 100',
)''',
    ),
    DemoExample(
      title: 'Custom Icons',
      description: 'Replace the increment and decrement icons.',
      builder: (BuildContext context) => const SizedBox(
        width: 256,
        child: HeroNumberField(
          name: 'width',
          defaultValue: 1024,
          minValue: 0,
          children: <Widget>[
            HeroLabel.text('Width (Custom Icons)'),
            HeroNumberFieldGroup(
              children: <Widget>[
                HeroNumberFieldDecrementButton(
                  child: HeroIcon(HeroIcons.magnifierMinus),
                ),
                HeroNumberFieldInput(width: 120),
                HeroNumberFieldIncrementButton(
                  child: HeroIcon(HeroIcons.magnifierPlus),
                ),
              ],
            ),
            HeroDescription.text('Custom icon children'),
          ],
        ),
      ),
      code: '''
const HeroNumberField(
  name: 'width',
  defaultValue: 1024,
  minValue: 0,
  children: <Widget>[
    HeroLabel.text('Width (Custom Icons)'),
    HeroNumberFieldGroup(
      children: <Widget>[
        HeroNumberFieldDecrementButton(
          child: HeroIcon(HeroIcons.magnifierMinus),
        ),
        HeroNumberFieldInput(width: 120),
        HeroNumberFieldIncrementButton(
          child: HeroIcon(HeroIcons.magnifierPlus),
        ),
      ],
    ),
    HeroDescription.text('Custom icon children'),
  ],
)''',
    ),
    DemoExample(
      title: 'With Chevrons',
      description:
          'The buttons stacked in a column at the end, with small chevrons.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        return SizedBox(
          width: 256,
          child: HeroNumberField(
            name: 'amount',
            defaultValue: 99,
            minValue: 0,
            formatOptions: _eurAccounting,
            children: <Widget>[
              const HeroLabel.text('Number field with chevrons'),
              HeroNumberFieldGroup(
                children: <Widget>[
                  const HeroNumberFieldInput(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: BorderDirectional(
                        start: BorderSide(
                          color: theme.colors.fieldPlaceholder.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: HeroNumberFieldIncrementButton(
                            width: theme.spacing(6),
                            showDivider: false,
                            padding: EdgeInsets.only(top: theme.spacing(0.5)),
                            child: const HeroIcon(
                              HeroIcons.chevronUp,
                              size: 11,
                            ),
                          ),
                        ),
                        Expanded(
                          child: HeroNumberFieldDecrementButton(
                            width: theme.spacing(6),
                            showDivider: false,
                            padding: EdgeInsets.only(
                              bottom: theme.spacing(0.5),
                            ),
                            child: const HeroIcon(
                              HeroIcons.chevronDown,
                              size: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      code: '''
HeroNumberField(
  name: 'amount',
  defaultValue: 99,
  minValue: 0,
  formatOptions: const HeroNumberFormatOptions(
    style: HeroNumberFormatStyle.currency,
    currency: 'EUR',
    currencySign: HeroCurrencySign.accounting,
  ),
  children: <Widget>[
    const HeroLabel.text('Number field with chevrons'),
    HeroNumberFieldGroup(
      children: <Widget>[
        const HeroNumberFieldInput(),
        DecoratedBox(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(
                color: theme.colors.fieldPlaceholder.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: HeroNumberFieldIncrementButton(
                  width: theme.spacing(6),
                  showDivider: false,
                  padding: EdgeInsets.only(top: theme.spacing(0.5)),
                  child: const HeroIcon(HeroIcons.chevronUp, size: 11),
                ),
              ),
              Expanded(
                child: HeroNumberFieldDecrementButton(
                  width: theme.spacing(6),
                  showDivider: false,
                  padding: EdgeInsets.only(bottom: theme.spacing(0.5)),
                  child: const HeroIcon(HeroIcons.chevronDown, size: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ],
)''',
    ),
    DemoExample(
      title: 'Render Function',
      description:
          'React renders the field through a custom element. In Flutter the '
          'output is identical to the basic example.',
      builder: (BuildContext context) =>
          const SizedBox(width: 256, child: _BasicWidth()),
      code: _basicCode,
    ),
    DemoExample(
      title: 'Customization',
      description:
          'A secondary guests field: rounded-xl default group, muted buttons '
          'that turn to the foreground color on hover, centred tabular text.',
      builder: (BuildContext context) {
        final HeroThemeData theme = HeroTheme.of(context);
        final HeroButtonStyle buttons = HeroButtonStyle(
          foregroundColor: WidgetStateProperty<Color?>.fromMap(
            <WidgetStatesConstraint, Color?>{
              WidgetState.hovered: theme.colors.foreground,
              WidgetState.any: theme.colors.muted,
            },
          ),
        );
        return SizedBox(
          width: 192,
          child: HeroNumberField(
            name: 'guests',
            defaultValue: 2,
            minValue: 1,
            variant: HeroFieldVariant.secondary,
            fullWidth: true,
            children: <Widget>[
              HeroLabel.text(
                'Guests',
                style: TextStyle(color: theme.colors.foreground),
              ),
              HeroNumberFieldGroup(
                style: HeroFieldStyle(
                  borderRadius: BorderRadius.circular(theme.radii.xl),
                  backgroundColor: theme.colors.defaultColor,
                ),
                children: <Widget>[
                  HeroNumberFieldDecrementButton(style: buttons),
                  const HeroNumberFieldInput(textAlign: TextAlign.center),
                  HeroNumberFieldIncrementButton(style: buttons),
                ],
              ),
            ],
          ),
        );
      },
      code: '''
final HeroThemeData theme = HeroTheme.of(context);
final HeroButtonStyle buttons = HeroButtonStyle(
  foregroundColor: WidgetStateProperty<Color?>.fromMap(
    <WidgetStatesConstraint, Color?>{
      WidgetState.hovered: theme.colors.foreground,
      WidgetState.any: theme.colors.muted,
    },
  ),
);

SizedBox(
  width: 192,
  child: HeroNumberField(
    name: 'guests',
    defaultValue: 2,
    minValue: 1,
    variant: HeroFieldVariant.secondary,
    fullWidth: true,
    children: <Widget>[
      HeroLabel.text(
        'Guests',
        style: TextStyle(color: theme.colors.foreground),
      ),
      HeroNumberFieldGroup(
        style: HeroFieldStyle(
          borderRadius: BorderRadius.circular(theme.radii.xl),
          backgroundColor: theme.colors.defaultColor,
        ),
        children: <Widget>[
          HeroNumberFieldDecrementButton(style: buttons),
          const HeroNumberFieldInput(textAlign: TextAlign.center),
          HeroNumberFieldIncrementButton(style: buttons),
        ],
      ),
    ],
  ),
)''',
    ),
  ],
);

const HeroNumberFormatOptions _percent = HeroNumberFormatOptions(
  style: HeroNumberFormatStyle.percent,
);

const HeroNumberFormatOptions _eurAccounting = HeroNumberFormatOptions(
  style: HeroNumberFormatStyle.currency,
  currency: 'EUR',
  currencySign: HeroCurrencySign.accounting,
);

double _playgroundValue(String style) => switch (style) {
  'currency' => 99,
  'percent' => 0.5,
  'unit' => 1000,
  _ => 1024,
};

HeroNumberFormatOptions? _playgroundFormat(String style) => switch (style) {
  'currency' => _eurAccounting,
  'percent' => _percent,
  'unit' => const HeroNumberFormatOptions(
    style: HeroNumberFormatStyle.unit,
    unit: 'kilogram',
  ),
  _ => null,
};

String? _playgroundFormatCode(String style) => switch (style) {
  'currency' =>
    'const HeroNumberFormatOptions(\n'
        '    style: HeroNumberFormatStyle.currency,\n'
        "    currency: 'EUR',\n"
        '    currencySign: HeroCurrencySign.accounting,\n'
        '  )',
  'percent' =>
    'const HeroNumberFormatOptions(style: HeroNumberFormatStyle.percent)',
  'unit' =>
    'const HeroNumberFormatOptions(\n'
        '    style: HeroNumberFormatStyle.unit,\n'
        "    unit: 'kilogram',\n"
        '  )',
  _ => null,
};

const String _basicCode = '''
const HeroNumberField(
  name: 'width',
  defaultValue: 1024,
  minValue: 0,
  children: <Widget>[
    HeroLabel.text('Width'),
    HeroNumberFieldGroup(
      children: <Widget>[
        HeroNumberFieldDecrementButton(),
        HeroNumberFieldInput(width: 120),
        HeroNumberFieldIncrementButton(),
      ],
    ),
  ],
)

// or, with the convenience parameters:
const HeroNumberField(
  name: 'width',
  label: 'Width',
  defaultValue: 1024,
  minValue: 0,
  inputWidth: 120,
)''';

const String _widthAndPercentCode = '''
const HeroNumberField(
  name: 'percentage',
  label: 'Percentage',
  defaultValue: 0.5,
  minValue: 0,
  maxValue: 1,
  step: 0.1,
  formatOptions: HeroNumberFormatOptions(
    style: HeroNumberFormatStyle.percent,
  ),
  inputWidth: 120,
  description: 'Value must be between 0 and 100',
)''';

/// The docs' basic width field.
class _BasicWidth extends StatelessWidget {
  const _BasicWidth();

  @override
  Widget build(BuildContext context) {
    return const HeroNumberField(
      name: 'width',
      defaultValue: 1024,
      minValue: 0,
      children: <Widget>[
        HeroLabel.text('Width'),
        HeroNumberFieldGroup(
          children: <Widget>[
            HeroNumberFieldDecrementButton(),
            HeroNumberFieldInput(width: 120),
            HeroNumberFieldIncrementButton(),
          ],
        ),
      ],
    );
  }
}

/// A width field and a percentage field with descriptions.
class _WidthAndPercent extends StatelessWidget {
  const _WidthAndPercent({this.isDisabled = false});

  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroNumberField(
            name: 'width',
            isDisabled: isDisabled,
            label: 'Width',
            defaultValue: 1024,
            minValue: 0,
            inputWidth: 120,
            description: 'Enter the width in pixels',
          ),
          HeroNumberField(
            name: 'percentage',
            isDisabled: isDisabled,
            label: 'Percentage',
            defaultValue: 0.5,
            minValue: 0,
            maxValue: 1,
            step: 0.1,
            formatOptions: _percent,
            inputWidth: 120,
            description: 'Value must be between 0 and 100',
          ),
        ],
      ),
    );
  }
}

/// A controlled width field with buttons that set the value.
class _ControlledWidth extends StatefulWidget {
  const _ControlledWidth();

  @override
  State<_ControlledWidth> createState() => _ControlledWidthState();
}

class _ControlledWidthState extends State<_ControlledWidth> {
  double _value = 1024;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        HeroNumberField(
          name: 'width',
          label: 'Width',
          value: _value,
          minValue: 0,
          onChanged: (double? value) => setState(() => _value = value ?? 0),
          inputWidth: 120,
          description: 'Current value: ${_value.round()}',
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: <Widget>[
            HeroButton(
              variant: HeroButtonVariant.tertiary,
              onPressed: () => setState(() => _value = 0),
              child: const Text('Reset to 0'),
            ),
            HeroButton(
              variant: HeroButtonVariant.tertiary,
              onPressed: () => setState(() => _value = 2048),
              child: const Text('Set to 2048'),
            ),
          ],
        ),
      ],
    );
  }
}

/// The docs' order form: a quantity limited by the stock and a pending
/// submit button.
class _OrderForm extends StatefulWidget {
  const _OrderForm();

  @override
  State<_OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<_OrderForm> {
  static const int _stockAvailable = 3;
  double? _value;
  bool _submitting = false;

  Future<void> _submit(Map<String, Object?> data) async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _value = null;
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double? value = _value;
    final bool outOfStock = value != null && value > _stockAvailable;
    return HeroForm(
      onSubmit: _submit,
      child: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            HeroNumberField(
              name: 'quantity',
              isRequired: true,
              isInvalid: outOfStock,
              label: 'Order quantity',
              value: value ?? double.nan,
              minValue: 1,
              maxValue: 5,
              onChanged: (double? v) => setState(() => _value = v),
              inputWidth: 120,
              description: 'Only $_stockAvailable items available',
              errorMessage: 'Only $_stockAvailable items left in stock',
            ),
            HeroButton(
              type: HeroButtonType.submit,
              fullWidth: true,
              isDisabled: value == null || value < 1 || outOfStock,
              isPending: _submitting,
              child: Text(_submitting ? 'Processing...' : 'Place Order'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A percentage field validated while its value changes.
class _LiveValidatedPercent extends StatefulWidget {
  const _LiveValidatedPercent();

  @override
  State<_LiveValidatedPercent> createState() => _LiveValidatedPercentState();
}

class _LiveValidatedPercentState extends State<_LiveValidatedPercent> {
  double? _value;

  @override
  Widget build(BuildContext context) {
    final double? value = _value;
    // As in the docs, the check compares the fraction with 0..100.
    final bool invalid = value != null && (value < 0 || value > 100);
    return SizedBox(
      width: 256,
      child: HeroNumberField(
        name: 'percentage',
        isRequired: true,
        isInvalid: invalid,
        label: 'Percentage',
        value: value ?? double.nan,
        minValue: 0,
        maxValue: 1,
        step: 0.1,
        formatOptions: _percent,
        onChanged: (double? v) => setState(() => _value = v),
        inputWidth: 120,
        description: 'Enter a value between 0 and 100',
        errorMessage: 'Percentage must be between 0 and 100',
      ),
    );
  }
}
