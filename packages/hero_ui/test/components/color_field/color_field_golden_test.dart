import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  heroGoldenTest(
    'variants, swatch prefix and suffix',
    name: 'color_field_variants',
    size: const Size(360, 400),
    builder: (HeroThemeData theme) => SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          const HeroColorField(
            label: 'Color',
            showSwatch: true,
            defaultValue: Color(0xFF0485F7),
          ),
          const HeroColorField(
            label: 'Secondary variant',
            variant: HeroFieldVariant.secondary,
            defaultValue: Color(0xFFF43F5E),
            description: 'Lower emphasis, for surfaces',
          ),
          const HeroColorField(
            label: 'Brand Color',
            isRequired: true,
            placeholder: '#000000',
          ),
          Row(
            spacing: 16,
            children: <Widget>[
              for (final HeroColorChannel channel in <HeroColorChannel>[
                HeroColorChannel.hue,
                HeroColorChannel.saturation,
                HeroColorChannel.lightness,
              ])
                Expanded(
                  child: HeroColorField(
                    channel: channel,
                    colorSpace: HeroColorSpace.hsl,
                    label: channel.label,
                    defaultValue: const Color(0xFF7F007F),
                    endContent: channel == HeroColorChannel.hue
                        ? null
                        : const Text('%'),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'disabled, invalid and focused',
    name: 'color_field_states',
    size: const Size(360, 320),
    whilePerforming: (WidgetTester tester) async {
      await tester.tap(find.byType(EditableText).last);
      await tester.pump(const Duration(milliseconds: 600));
    },
    builder: (HeroThemeData theme) => const SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          HeroColorField(
            label: 'Color',
            isDisabled: true,
            defaultValue: Color(0xFF0485F7),
            description: 'This color field is disabled',
          ),
          HeroColorField(
            label: 'Color',
            isInvalid: true,
            isRequired: true,
            placeholder: '#000000',
            errorMessage: 'Please enter a valid hex color',
          ),
          HeroColorField(
            label: 'Focused',
            showSwatch: true,
            defaultValue: Color(0xFF10B981),
          ),
        ],
      ),
    ),
  );
}
