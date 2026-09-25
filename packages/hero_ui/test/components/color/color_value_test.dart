import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  group('parsing', () {
    test('hex in every length', () {
      expect(heroParseColor('#0485F7'), isSameColorAs(const Color(0xFF0485F7)));
      expect(heroParseColor('#f00'), isSameColorAs(const Color(0xFFFF0000)));
      expect(heroParseColor('#f008'), isSameColorAs(const Color(0x88FF0000)));
      expect(
        heroParseColor('#0485F780'),
        isSameColorAs(const Color(0x800485F7)),
      );
      expect(HeroColorValue.tryParse('#12'), isNull);
      expect(HeroColorValue.tryParse('#GGGGGG'), isNull);
    });

    test('functional notations keep their space', () {
      final HeroColorValue rgb = HeroColorValue.parse('rgb(116, 52, 255)');
      expect(rgb.space, HeroColorSpace.rgb);
      expect(rgb.channelValue(HeroColorChannel.green), 52);

      final HeroColorValue rgba = HeroColorValue.parse(
        'rgba(4, 133, 247, 0.25)',
      );
      expect(rgba.alpha, 0.25);

      final HeroColorValue hsl = HeroColorValue.parse('hsl(200, 100%, 50%)');
      expect(hsl.space, HeroColorSpace.hsl);
      expect(hsl.channelValue(HeroColorChannel.hue), 200);
      expect(hsl.toFormat(HeroColorFormat.hex), '#00AAFF');

      final HeroColorValue hsla = HeroColorValue.parse(
        'hsla(0, 100%, 50%, 0.5)',
      );
      expect(hsla.alpha, 0.5);

      final HeroColorValue hsb = HeroColorValue.parse('hsb(219, 58%, 93%)');
      expect(hsb.space, HeroColorSpace.hsb);
      expect(hsb.channelValue(HeroColorChannel.brightness), 93);
    });

    test('invalid strings fail', () {
      expect(HeroColorValue.tryParse('not-a-color'), isNull);
      expect(HeroColorValue.tryParse('rgb(300, 0, 0)'), isNull);
      expect(HeroColorValue.tryParse('hsl(0, 120%, 50%)'), isNull);
      expect(HeroColorValue.tryParse('rgba(0, 0, 0)'), isNull);
      expect(() => heroParseColor('nope'), throwsFormatException);
    });
  });

  group('conversion', () {
    test('rgb to hsb and hsl', () {
      final HeroColorValue color = HeroColorValue.fromColor(
        const Color(0xFFFF0000),
        space: HeroColorSpace.hsb,
      );
      expect(color.channelValue(HeroColorChannel.hue), 0);
      expect(color.channelValue(HeroColorChannel.saturation), 100);
      expect(color.channelValue(HeroColorChannel.brightness), 100);
      final HeroColorValue hsl = color.toSpace(HeroColorSpace.hsl);
      expect(hsl.channelValue(HeroColorChannel.lightness), closeTo(50, 1e-9));
      expect(hsl.channelValue(HeroColorChannel.saturation), closeTo(100, 1e-9));
    });

    test('round trips through every space', () {
      const Color color = Color(0xFF7434FF);
      for (final HeroColorSpace space in HeroColorSpace.values) {
        final HeroColorValue value = HeroColorValue.fromColor(
          color,
          space: space,
        );
        expect(heroColorsEqual(value.toColor(), color), isTrue);
        for (final HeroColorSpace other in HeroColorSpace.values) {
          expect(
            heroColorsEqual(value.toSpace(other).toColor(), color),
            isTrue,
          );
        }
      }
    });

    test('hsl and hsb conversion keeps the hue of grays', () {
      const HeroColorValue gray = HeroColorValue.hsb(210, 0, 50);
      expect(
        gray.toSpace(HeroColorSpace.hsl).channelValue(HeroColorChannel.hue),
        210,
      );
      expect(gray.channelValue(HeroColorChannel.lightness), 50);
    });

    test('Flutter HSVColor and HSLColor interop', () {
      final HeroColorValue value = HeroColorValue.fromHSVColor(
        const HSVColor.fromAHSV(1, 120, 0.5, 0.8),
      );
      expect(value.channelValue(HeroColorChannel.saturation), 50);
      expect(value.toHSVColor().value, closeTo(0.8, 1e-9));
      expect(
        HeroColorValue.fromHSLColor(
          value.toHSLColor(),
        ).channelValue(HeroColorChannel.hue),
        120,
      );
    });
  });

  group('channels', () {
    test('ranges follow React Aria', () {
      expect(HeroColorChannel.hue.range.max, 360);
      expect(HeroColorChannel.hue.range.pageSize, 15);
      expect(HeroColorChannel.saturation.range.pageSize, 10);
      expect(HeroColorChannel.red.range.pageSize, 17);
      expect(HeroColorChannel.alpha.range.step, 0.01);
      expect(HeroColorChannel.alpha.range.snap(0.304), 0.3);
    });

    test('withChannelValue clamps and converts', () {
      const HeroColorValue red = HeroColorValue.rgb(255, 0, 0);
      expect(
        red
            .withChannelValue(HeroColorChannel.green, 400)
            .channelValue(HeroColorChannel.green),
        255,
      );
      final HeroColorValue lighter = red.withChannelValue(
        HeroColorChannel.lightness,
        75,
      );
      expect(lighter.space, HeroColorSpace.rgb);
      expect(lighter.toFormat(HeroColorFormat.hex), '#FF8080');
      expect(red.withAlpha(0.5).alpha, 0.5);
    });

    test('channel spaces resolve like the ColorSlider auto-correction', () {
      expect(
        HeroColorChannel.red.resolveSpace(HeroColorSpace.hsl),
        HeroColorSpace.rgb,
      );
      expect(
        HeroColorChannel.brightness.resolveSpace(null),
        HeroColorSpace.hsb,
      );
      expect(
        HeroColorChannel.hue.resolveSpace(HeroColorSpace.rgb),
        HeroColorSpace.hsl,
      );
      expect(
        HeroColorChannel.hue.resolveSpace(HeroColorSpace.hsb),
        HeroColorSpace.hsb,
      );
      expect(
        HeroColorChannel.alpha.resolveSpace(HeroColorSpace.rgb),
        HeroColorSpace.rgb,
      );
    });

    test('formats channel values', () {
      const HeroColorValue color = HeroColorValue.hsl(200, 50, 25, 0.5);
      expect(color.formatChannelValue(HeroColorChannel.hue), '200°');
      expect(color.formatChannelValue(HeroColorChannel.saturation), '50%');
      expect(color.formatChannelValue(HeroColorChannel.alpha), '50%');
      expect(
        HeroColorValue.fromColor(
          const Color(0xFF0485F7),
          space: HeroColorSpace.hsb,
        ).formatChannelValue(HeroColorChannel.hue),
        '208.15°',
      );
      expect(
        const HeroColorValue.rgb(
          255,
          100,
          50,
        ).formatChannelValue(HeroColorChannel.red),
        '255',
      );
    });
  });

  test('formats', () {
    const HeroColorValue color = HeroColorValue.rgb(4, 133, 247, 0.5);
    expect(color.toFormat(HeroColorFormat.hex), '#0485F7');
    expect(color.toFormat(HeroColorFormat.hexa), '#0485F780');
    expect(color.toFormat(HeroColorFormat.rgb), 'rgb(4, 133, 247)');
    expect(color.toFormat(HeroColorFormat.rgba), 'rgba(4, 133, 247, 0.5)');
    expect(color.toFormat(HeroColorFormat.css), 'rgba(4, 133, 247, 0.5)');
    expect(
      const HeroColorValue.hsl(200, 100, 50).toFormat(HeroColorFormat.hsl),
      'hsl(200, 100%, 50%)',
    );
    expect(
      const HeroColorValue.hsl(200, 100, 50).toFormat(HeroColorFormat.css),
      'hsla(200, 100%, 50%, 1)',
    );
    expect(
      const HeroColorValue.hsb(219, 58, 93).toSpaceString(),
      'hsb(219, 58%, 93%)',
    );
    expect(heroColorToString(const Color(0xFF10B981)), '#10B981');
    expect(const HeroColorValue.rgb(1, 2, 3).toHexInt(), 0x010203);
  });

  group('heroResolveColorValue', () {
    test('keeps the previous value for the color it reported', () {
      const HeroColorValue previous = HeroColorValue.hsb(200, 0, 40);
      final HeroColorValue resolved = heroResolveColorValue(
        previous.toColor(),
        HeroColorSpace.hsb,
        previous: previous,
      );
      expect(resolved, previous);
    });

    test('keeps hue of grays and saturation of black', () {
      const HeroColorValue previous = HeroColorValue.hsb(200, 80, 60);
      final HeroColorValue gray = heroResolveColorValue(
        const Color(0xFF808080),
        HeroColorSpace.hsb,
        previous: previous,
      );
      expect(gray.channelValue(HeroColorChannel.hue), 200);
      expect(gray.channelValue(HeroColorChannel.saturation), 0);

      final HeroColorValue black = heroResolveColorValue(
        const Color(0xFF000000),
        HeroColorSpace.hsb,
        previous: previous,
      );
      expect(black.channelValue(HeroColorChannel.hue), 200);
      expect(black.channelValue(HeroColorChannel.saturation), 80);
      expect(black.channelValue(HeroColorChannel.brightness), 0);

      final HeroColorValue white = heroResolveColorValue(
        const Color(0xFFFFFFFF),
        HeroColorSpace.hsl,
        previous: previous,
      );
      expect(white.channelValue(HeroColorChannel.hue), 200);
    });

    test('takes new colors as they are', () {
      final HeroColorValue resolved = heroResolveColorValue(
        const Color(0xFFFF0000),
        HeroColorSpace.hsl,
        previous: const HeroColorValue.hsl(200, 50, 50),
      );
      expect(resolved.channelValue(HeroColorChannel.hue), 0);
    });
  });

  group('heroColorName', () {
    test('names common colors', () {
      expect(heroColorName(const Color(0xFFFFFFFF)), 'white');
      expect(heroColorName(const Color(0xFF000000)), 'black');
      expect(heroColorName(const Color(0x00000000)), 'transparent');
      expect(heroColorName(const Color(0xFFEF4444)), 'vibrant red');
      expect(heroColorName(const Color(0xFF808080)), 'gray');
      expect(heroColorName(const Color(0xFF22C55E)), contains('green'));
      expect(heroColorName(const Color(0xFF0485F7)), contains('blue'));
      expect(heroColorName(const Color(0xFF7C2D12)), contains('brown'));
      expect(heroColorName(const Color(0xFFD9D9D9)), 'very light gray');
    });

    test('mentions transparency', () {
      expect(
        heroColorName(const Color(0x800485F7)),
        endsWith(', 50% transparent'),
      );
    });
  });
}
