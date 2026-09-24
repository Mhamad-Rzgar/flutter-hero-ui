import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

String hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

void main() {
  group('HeroColors.light', () {
    final HeroColors c = HeroColors.light;

    test('source tokens match the HeroUI default theme', () {
      expect(hex(c.accent), '#0485f7');
      expect(hex(c.background), '#f5f5f5');
      expect(hex(c.foreground), '#18181b');
      expect(hex(c.danger), '#ff383c');
      expect(hex(c.success), '#17c964');
      expect(hex(c.warning), '#f5a524');
      expect(c.surface, c.white);
      expect(c.focus, c.accent);
      expect(c.fieldBorder.a, 0);
    });

    test('calculated tokens follow variables.css', () {
      expect(c.accentSoft.a, closeTo(0.15, 0.001));
      expect(c.accentSoftHover.a, closeTo(0.20, 0.001));
      expect(c.defaultSoft.a, closeTo(0.5, 0.001));
      expect(c.fieldHover.a, closeTo(0.92, 0.001));
      expect(c.backgroundInverse, c.foreground);
      expect(c.fieldFocus, c.fieldBackground);
      expect(c.chart3, c.accent);
      // Hover mixes 10% of the foreground into the fill.
      expect(
        OkLab.fromColor(c.accentHover).l,
        greaterThan(OkLab.fromColor(c.accent).l),
      );
    });
  });

  group('HeroColors.dark', () {
    final HeroColors c = HeroColors.dark;

    test('uses the dark sources', () {
      expect(hex(c.background), '#060607');
      expect(c.foreground, c.snow);
      expect(c.accent, HeroColors.light.accent);
      expect(c.accentSoft.a, closeTo(0.12, 0.001));
      expect(c.accentSoftHover.a, closeTo(0.16, 0.001));
      expect(c.dangerSoft.a, closeTo(0.15, 0.001));
    });
  });

  test('vibrant palette changes soft foregrounds only', () {
    final HeroColors vibrant = HeroColors.derive(
      HeroColorSource.light,
      brightness: Brightness.light,
      vibrantPalette: true,
    );
    expect(
      vibrant.accentSoftForeground,
      isNot(HeroColors.light.accentSoftForeground),
    );
    expect(vibrant.accent, HeroColors.light.accent);
  });

  test('lerp interpolates every token', () {
    final HeroColors mid = HeroColors.lerp(
      HeroColors.light,
      HeroColors.dark,
      0.5,
    );
    expect(
      mid.background,
      Color.lerp(HeroColors.light.background, HeroColors.dark.background, 0.5),
    );
    expect(
      HeroColors.lerp(HeroColors.light, HeroColors.dark, 0),
      HeroColors.light,
    );
  });

  test('toMap exposes CSS variable names', () {
    final Map<String, Color> map = HeroColors.light.toMap();
    expect(
      map['accent-soft-foreground'],
      HeroColors.light.accentSoftForeground,
    );
    expect(map['default'], HeroColors.light.defaultColor);
    expect(map.length, 74);
  });

  group('presets', () {
    for (final HeroThemePreset preset in HeroThemePreset.values) {
      test('${preset.label} builds light and dark themes', () {
        final HeroThemeData light = HeroThemeData.light(preset: preset);
        final HeroThemeData dark = HeroThemeData.dark(preset: preset);
        expect(light.brightness, Brightness.light);
        expect(dark.brightness, Brightness.dark);
        expect(light.colors.accent.a, 1);
        expect(
          relativeLuminance(light.colors.background),
          greaterThan(relativeLuminance(dark.colors.background)),
        );
      });
    }

    test('radius overrides come from the preset CSS', () {
      expect(
        HeroThemeData.light(preset: HeroThemePreset.netflix).radii.radius,
        2,
      );
      expect(
        HeroThemeData.light(preset: HeroThemePreset.netflix).radii.field,
        2,
      );
      expect(
        HeroThemeData.light(preset: HeroThemePreset.spotify).radii.radius,
        8,
      );
      expect(
        HeroThemeData.light(preset: HeroThemePreset.spotify).radii.field,
        2,
      );
      expect(
        HeroThemeData.light(preset: HeroThemePreset.rabbit).radii.field,
        16,
      );
      expect(
        HeroThemeData.light(preset: HeroThemePreset.discord).radii.radius,
        4,
      );
      expect(
        HeroThemeData.light(preset: HeroThemePreset.discord).radii.field,
        12,
      );
    });

    test('sky accent differs from default accent', () {
      expect(
        HeroThemeData.light(preset: HeroThemePreset.sky).colors.accent,
        isNot(HeroThemeData.light().colors.accent),
      );
    });
  });

  group('radii', () {
    test('scale follows theme.css', () {
      const HeroRadii r = HeroRadii();
      expect(
        <double>[r.xs, r.sm, r.md, r.lg, r.xl, r.xl2, r.xl3, r.xl4],
        <double>[2, 4, 6, 8, 12, 16, 24, 32],
      );
      expect(r.field, 12);
    });
  });

  test('spacing unit is 4', () {
    const HeroSpacing s = HeroSpacing();
    expect(s(2.5), 10);
    expect(s.s4, 16);
  });

  test('typography matches the Tailwind scale', () {
    const HeroTypography t = HeroTypography();
    expect(t.sm.fontSize, 14);
    expect(t.sm.height! * 14, closeTo(20, 0.001));
    expect(t.h1.fontSize, 36);
    expect(t.h1.fontWeight, FontWeight.w600);
    expect(t.h1.letterSpacing, closeTo(-0.9, 0.001));
    expect(t.body.height! * 16, closeTo(28, 0.001));
    expect(t.base.fontFamily, 'packages/hero_ui/Inter');
  });
}
