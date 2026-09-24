import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  final HeroColors c = HeroColors.light;

  test('roles map to their tokens', () {
    final HeroColorRole accent = c.role(HeroColor.accent);
    expect(accent.base, c.accent);
    expect(accent.foreground, c.accentForeground);
    expect(accent.hover, c.accentHover);
    expect(accent.soft, c.accentSoft);
    expect(accent.softForeground, c.accentSoftForeground);
    expect(accent.softHover, c.accentSoftHover);
    expect(c.role(HeroColor.standard).base, c.defaultColor);
    expect(c.role(HeroColor.danger).soft, c.dangerSoft);
  });

  test('primary is the solid role fill', () {
    final HeroVariantStyle s = HeroVariants.resolve(
      c,
      HeroVariant.primary,
      HeroColor.success,
    );
    expect(s.background, c.success);
    expect(s.backgroundHover, c.successHover);
    expect(s.backgroundPressed, c.successHover);
    expect(s.foreground, c.successForeground);
    expect(s.borderColor, isNull);
  });

  test('secondary is neutral with a tinted foreground', () {
    final HeroVariantStyle s = HeroVariants.resolve(
      c,
      HeroVariant.secondary,
      HeroColor.accent,
    );
    expect(s.background, c.defaultColor);
    expect(s.foreground, c.accentSoftForeground);
    expect(
      HeroVariants.resolve(
        c,
        HeroVariant.secondary,
        HeroColor.standard,
      ).foreground,
      c.defaultForeground,
    );
  });

  test('soft uses the soft tokens', () {
    final HeroVariantStyle s = HeroVariants.resolve(
      c,
      HeroVariant.soft,
      HeroColor.warning,
    );
    expect(s.background, c.warningSoft);
    expect(s.backgroundHover, c.warningSoftHover);
    expect(s.foreground, c.warningSoftForeground);
  });

  test('outline and ghost are transparent at rest', () {
    final HeroVariantStyle outline = HeroVariants.resolve(
      c,
      HeroVariant.outline,
      HeroColor.standard,
    );
    expect(outline.background.a, 0);
    expect(outline.borderColor, c.border);
    expect(outline.backgroundHover.a, closeTo(c.defaultColor.a * 0.6, 0.001));
    final HeroVariantStyle ghost = HeroVariants.resolve(
      c,
      HeroVariant.ghost,
      HeroColor.standard,
    );
    expect(ghost.background.a, 0);
    expect(ghost.backgroundHover, c.defaultColor);
  });

  test('backgroundFor follows the CSS cascade', () {
    const HeroVariantStyle s = HeroVariantStyle(
      background: Color(0xFF000001),
      backgroundHover: Color(0xFF000002),
      backgroundPressed: Color(0xFF000003),
      foreground: Color(0xFFFFFFFF),
    );
    expect(s.backgroundFor(HeroInteractionState.idle), s.background);
    expect(
      s.backgroundFor(const HeroInteractionState(isHovered: true)),
      s.backgroundHover,
    );
    expect(
      s.backgroundFor(
        const HeroInteractionState(isHovered: true, isPressed: true),
      ),
      s.backgroundPressed,
    );
  });

  test('size tables', () {
    const HeroSizeValues<double> heights = HeroSizeValues<double>(
      sm: 32,
      md: 36,
      lg: 40,
    );
    expect(heights.of(HeroSize.sm), 32);
    expect(heights.of(HeroSize.lg), 40);
  });
}
