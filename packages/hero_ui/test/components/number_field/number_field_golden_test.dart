import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _column(List<Widget> children, {double width = 256}) => SizedBox(
  width: width,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: children,
  ),
);

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  heroGoldenTest(
    'basic, description and required',
    name: 'basic',
    size: const Size(300, 320),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroNumberField(label: 'Width', defaultValue: 1024, minValue: 0),
      HeroNumberField(
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
      HeroNumberField(label: 'Quantity', minValue: 0, isRequired: true),
    ]),
  );

  heroGoldenTest(
    'formats',
    name: 'formats',
    size: const Size(300, 420),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroNumberField(
        label: 'Currency (EUR - Accounting)',
        defaultValue: -99,
        formatOptions: HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.currency,
          currency: 'EUR',
          currencySign: HeroCurrencySign.accounting,
        ),
      ),
      HeroNumberField(
        label: 'Currency (USD)',
        defaultValue: 99.99,
        minValue: 0,
        formatOptions: HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.currency,
          currency: 'USD',
        ),
      ),
      HeroNumberField(
        label: 'Decimal (2 decimal places)',
        defaultValue: 1234.56,
        minValue: 0,
        formatOptions: HeroNumberFormatOptions(
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        ),
      ),
      HeroNumberField(
        label: 'Unit (Kilograms)',
        defaultValue: 1000,
        minValue: 0,
        formatOptions: HeroNumberFormatOptions(
          style: HeroNumberFormatStyle.unit,
          unit: 'kilogram',
        ),
      ),
    ]),
  );

  heroGoldenTest(
    'disabled, invalid, focused and limits',
    name: 'states',
    size: const Size(300, 380),
    whilePerforming: (WidgetTester tester) async {
      await tester.tap(find.text('7'));
    },
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroNumberField(
        label: 'Width',
        defaultValue: 1024,
        minValue: 0,
        isDisabled: true,
        description: 'Enter the width in pixels',
      ),
      HeroNumberField(
        label: 'Quantity',
        value: -5,
        minValue: 0,
        isRequired: true,
        isInvalid: true,
        errorMessage: 'Quantity must be greater than or equal to 0',
      ),
      HeroNumberField(label: 'Rating', defaultValue: 7, maxValue: 7),
    ]),
  );

  heroGoldenTest(
    'secondary on a surface',
    name: 'on_surface',
    size: const Size(340, 280),
    builder: (HeroThemeData theme) => HeroSurface(
      padding: EdgeInsets.all(theme.spacing(6)),
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      child: _column(width: 232, const <Widget>[
        HeroNumberField(
          label: 'Width',
          defaultValue: 1024,
          minValue: 0,
          variant: HeroFieldVariant.secondary,
          description: 'Enter the width in pixels',
        ),
        HeroNumberField(
          label: 'Guests',
          defaultValue: 1,
          minValue: 1,
          variant: HeroFieldVariant.secondary,
        ),
      ]),
    ),
  );

  heroGoldenTest(
    'custom icons, chevrons, custom styles and RTL',
    name: 'custom',
    size: const Size(300, 380),
    builder: (HeroThemeData theme) => _column(<Widget>[
      const HeroNumberField(
        defaultValue: 1024,
        minValue: 0,
        children: <Widget>[
          HeroLabel.text('Width (Custom Icons)'),
          HeroNumberFieldGroup(
            children: <Widget>[
              HeroNumberFieldDecrementButton(
                child: HeroIcon(HeroIcons.magnifierMinus),
              ),
              HeroNumberFieldInput(),
              HeroNumberFieldIncrementButton(
                child: HeroIcon(HeroIcons.magnifierPlus),
              ),
            ],
          ),
        ],
      ),
      HeroNumberField(
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
                      color: theme.colors.fieldPlaceholder.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                ),
                child: const Column(
                  children: <Widget>[
                    Expanded(
                      child: HeroNumberFieldIncrementButton(
                        width: 24,
                        showDivider: false,
                        child: HeroIcon(HeroIcons.chevronUp, size: 11),
                      ),
                    ),
                    Expanded(
                      child: HeroNumberFieldDecrementButton(
                        width: 24,
                        showDivider: false,
                        child: HeroIcon(HeroIcons.chevronDown, size: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      HeroNumberField(
        defaultValue: 2,
        minValue: 1,
        variant: HeroFieldVariant.secondary,
        children: <Widget>[
          const HeroLabel.text('Guests'),
          HeroNumberFieldGroup(
            style: HeroFieldStyle(
              borderRadius: BorderRadius.circular(theme.radii.xl),
              backgroundColor: theme.colors.defaultColor,
            ),
            children: <Widget>[
              HeroNumberFieldDecrementButton(
                style: HeroButtonStyle(
                  foregroundColor: WidgetStatePropertyAll<Color?>(
                    theme.colors.muted,
                  ),
                ),
              ),
              const HeroNumberFieldInput(textAlign: TextAlign.center),
              HeroNumberFieldIncrementButton(
                style: HeroButtonStyle(
                  foregroundColor: WidgetStatePropertyAll<Color?>(
                    theme.colors.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const Directionality(
        textDirection: TextDirection.rtl,
        child: HeroNumberField(label: 'RTL', defaultValue: 42),
      ),
    ]),
  );
}
