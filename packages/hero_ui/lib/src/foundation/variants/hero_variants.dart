import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../color/color_math.dart';
import '../interaction/hero_interactable.dart';
import '../tokens/hero_colors.dart';

/// HeroUI's semantic color roles (the `color` prop).
///
/// HeroUI's `default` role is spelled [standard] because `default` is a
/// reserved word in Dart.
enum HeroColor {
  /// The brand accent (`--accent`).
  accent,

  /// The neutral gray role (`--default`).
  standard,

  /// Success status (`--success`).
  success,

  /// Warning status (`--warning`).
  warning,

  /// Danger status (`--danger`).
  danger,
}

/// HeroUI's shared size scale (the `size` prop).
enum HeroSize {
  /// Small.
  sm,

  /// Medium (the default almost everywhere).
  md,

  /// Large.
  lg,
}

/// HeroUI's shared visual variants (the `variant` prop).
///
/// Components expose their own variant enums that map onto these fills.
enum HeroVariant {
  /// Solid fill in the role color (`--accent` + `--accent-foreground`).
  primary,

  /// Neutral fill with a tinted foreground (`--default` +
  /// `--accent-soft-foreground`).
  secondary,

  /// Transparent fill with a tinted foreground.
  tertiary,

  /// Tinted translucent fill (`--accent-soft` + `--accent-soft-foreground`).
  soft,

  /// Transparent fill with a `--border` outline.
  outline,

  /// Transparent fill that shows `--default` on hover.
  ghost,
}

/// The six tokens that make up a color role: fill, text on fill, hovered
/// fill, and the soft (tinted) counterparts.
@immutable
class HeroColorRole {
  /// Creates a color role.
  const HeroColorRole({
    required this.base,
    required this.foreground,
    required this.hover,
    required this.soft,
    required this.softForeground,
    required this.softHover,
  });

  /// Solid fill (`--accent`).
  final Color base;

  /// Text on [base] (`--accent-foreground`).
  final Color foreground;

  /// Hovered [base] (`--accent-hover`).
  final Color hover;

  /// Tinted fill (`--accent-soft`).
  final Color soft;

  /// Text on [soft] and tinted text on neutral fills
  /// (`--accent-soft-foreground`).
  final Color softForeground;

  /// Hovered [soft] (`--accent-soft-hover`).
  final Color softHover;
}

/// Role lookup on [HeroColors].
extension HeroColorRoles on HeroColors {
  /// Returns the tokens of [color].
  HeroColorRole role(HeroColor color) => switch (color) {
    HeroColor.accent => HeroColorRole(
      base: accent,
      foreground: accentForeground,
      hover: accentHover,
      soft: accentSoft,
      softForeground: accentSoftForeground,
      softHover: accentSoftHover,
    ),
    HeroColor.standard => HeroColorRole(
      base: defaultColor,
      foreground: defaultForeground,
      hover: defaultHover,
      soft: defaultSoft,
      softForeground: defaultSoftForeground,
      softHover: defaultSoftHover,
    ),
    HeroColor.success => HeroColorRole(
      base: success,
      foreground: successForeground,
      hover: successHover,
      soft: successSoft,
      softForeground: successSoftForeground,
      softHover: successSoftHover,
    ),
    HeroColor.warning => HeroColorRole(
      base: warning,
      foreground: warningForeground,
      hover: warningHover,
      soft: warningSoft,
      softForeground: warningSoftForeground,
      softHover: warningSoftHover,
    ),
    HeroColor.danger => HeroColorRole(
      base: danger,
      foreground: dangerForeground,
      hover: dangerHover,
      soft: dangerSoft,
      softForeground: dangerSoftForeground,
      softHover: dangerSoftHover,
    ),
  };
}

/// The resolved paint of a variant × color combination.
///
/// Mirrors the per-component CSS custom properties HeroUI sets for each
/// variant (`--button-bg`, `--button-bg-hover`, `--button-bg-pressed`,
/// `--button-fg`, `--chip-bg`, ...).
@immutable
class HeroVariantStyle {
  /// Creates a variant style.
  const HeroVariantStyle({
    required this.background,
    required this.foreground,
    Color? backgroundHover,
    Color? backgroundPressed,
    this.borderColor,
  }) : backgroundHover = backgroundHover ?? background,
       backgroundPressed = backgroundPressed ?? backgroundHover ?? background;

  /// Resting fill.
  final Color background;

  /// Fill while hovered.
  final Color backgroundHover;

  /// Fill while pressed.
  final Color backgroundPressed;

  /// Text and icon color.
  final Color foreground;

  /// Outline color, if the variant has a border.
  final Color? borderColor;

  /// Returns the fill for an interaction [state]. Pressed wins over hovered,
  /// exactly like the CSS cascade.
  Color backgroundFor(HeroInteractionState state) {
    if (state.isPressed) return backgroundPressed;
    if (state.isHovered) return backgroundHover;
    return background;
  }

  /// Returns a copy with the given fields replaced.
  HeroVariantStyle copyWith({
    Color? background,
    Color? backgroundHover,
    Color? backgroundPressed,
    Color? foreground,
    Color? borderColor,
  }) {
    return HeroVariantStyle(
      background: background ?? this.background,
      backgroundHover: backgroundHover ?? this.backgroundHover,
      backgroundPressed: backgroundPressed ?? this.backgroundPressed,
      foreground: foreground ?? this.foreground,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroVariantStyle &&
      other.background == background &&
      other.backgroundHover == backgroundHover &&
      other.backgroundPressed == backgroundPressed &&
      other.foreground == foreground &&
      other.borderColor == borderColor;

  @override
  int get hashCode => Object.hash(
    background,
    backgroundHover,
    backgroundPressed,
    foreground,
    borderColor,
  );
}

/// Resolves the HeroUI variant × color matrix once for every component.
abstract final class HeroVariants {
  static const Color _transparent = Color(0x00000000);

  /// Returns the style of [variant] in [color] for the token set [colors].
  ///
  /// The matrix follows HeroUI's chip, badge and button CSS:
  ///
  /// * `primary`: solid role fill; the neutral role uses `--default`.
  /// * `secondary`: `--default` fill with the role's soft foreground.
  /// * `tertiary`: transparent fill with the role's soft foreground.
  /// * `soft`: the role's soft fill and soft foreground.
  /// * `outline`: transparent with a `--border` outline, `--default` at 60%
  ///   on hover.
  /// * `ghost`: transparent, `--default` on hover.
  static HeroVariantStyle resolve(
    HeroColors colors,
    HeroVariant variant,
    HeroColor color,
  ) {
    final HeroColorRole role = colors.role(color);
    final bool neutral = color == HeroColor.standard;
    final Color tinted = neutral
        ? colors.defaultForeground
        : role.softForeground;
    return switch (variant) {
      HeroVariant.primary => HeroVariantStyle(
        background: role.base,
        backgroundHover: role.hover,
        foreground: role.foreground,
      ),
      HeroVariant.secondary => HeroVariantStyle(
        background: colors.defaultColor,
        backgroundHover: colors.defaultHover,
        foreground: tinted,
      ),
      HeroVariant.tertiary => HeroVariantStyle(
        background: _transparent,
        backgroundHover: colors.defaultColor,
        foreground: tinted,
      ),
      HeroVariant.soft => HeroVariantStyle(
        background: role.soft,
        backgroundHover: role.softHover,
        foreground: role.softForeground,
      ),
      HeroVariant.outline => HeroVariantStyle(
        background: _transparent,
        backgroundHover: colorMix(
          colors.defaultColor,
          _transparent,
          p1: 0.6,
          space: ColorMixSpace.srgb,
        ),
        foreground: neutral ? colors.defaultForeground : role.softForeground,
        borderColor: colors.border,
      ),
      HeroVariant.ghost => HeroVariantStyle(
        background: _transparent,
        backgroundHover: colors.defaultColor,
        foreground: neutral ? colors.defaultForeground : role.softForeground,
      ),
    };
  }
}

/// A value per [HeroSize], used by components to declare their size matrix
/// once (`HeroSizeValues(sm: 32, md: 36, lg: 40)`).
@immutable
class HeroSizeValues<T> {
  /// Creates a size table.
  const HeroSizeValues({required this.sm, required this.md, required this.lg});

  /// Value for [HeroSize.sm].
  final T sm;

  /// Value for [HeroSize.md].
  final T md;

  /// Value for [HeroSize.lg].
  final T lg;

  /// Returns the value for [size].
  T of(HeroSize size) => switch (size) {
    HeroSize.sm => sm,
    HeroSize.md => md,
    HeroSize.lg => lg,
  };
}
