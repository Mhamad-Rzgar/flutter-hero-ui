import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeExtension;
import 'package:flutter/widgets.dart';

import '../tokens/hero_colors.dart';
import '../tokens/hero_motion.dart';
import '../tokens/hero_radii.dart';
import '../tokens/hero_shadows.dart';
import '../tokens/hero_spacing.dart';
import '../tokens/hero_typography.dart';
import 'hero_breakpoints.dart';
import 'hero_theme_presets.dart';

/// How rounded corners are drawn.
enum HeroCornerStyle {
  /// iOS-style continuous corners (rounded superellipse). This is the
  /// default: HeroUI's design language is modelled on iOS, and continuous
  /// corners are the native rendering of that look.
  continuous,

  /// Circular-arc corners, identical to CSS `border-radius` in a browser.
  circular,
}

/// The skeleton loading animation (`--skeleton-animation`).
enum HeroSkeletonAnimation {
  /// A light sweep moving across the placeholder.
  shimmer,

  /// The placeholder fades in and out.
  pulse,

  /// No animation.
  none,
}

/// The complete HeroUI design-token set for one theme and brightness.
///
/// [HeroThemeData] is a [ThemeExtension], so it can live inside a Material
/// `ThemeData.extensions` list, and it can also be provided directly with
/// the [HeroTheme] widget. Components read it exclusively through
/// `HeroTheme.of(context)`.
@immutable
class HeroThemeData extends ThemeExtension<HeroThemeData> with Diagnosticable {
  /// Creates a theme from explicit token sets.
  const HeroThemeData({
    required this.brightness,
    required this.colors,
    this.preset,
    this.radii = const HeroRadii(),
    this.spacing = const HeroSpacing(),
    this.typography = const HeroTypography(),
    HeroShadows? shadows,
    this.motion = const HeroMotion(),
    this.cornerStyle = HeroCornerStyle.continuous,
    this.borderWidth = 1,
    this.fieldBorderWidth = 0,
    this.disabledOpacity = 0.5,
    this.focusRingWidth = 2,
    this.focusRingOffset = 2,
    this.skeletonAnimation = HeroSkeletonAnimation.shimmer,
    this.tooltipDelay = const Duration(milliseconds: 1500),
    this.tooltipCloseDelay = const Duration(milliseconds: 500),
    this.density = HeroDensity.adaptive,
    this.vibrantPalette = false,
  }) : shadows =
           shadows ??
           (brightness == Brightness.dark
               ? HeroShadows.dark
               : HeroShadows.light);

  /// Creates a theme from a named [preset] (defaults to HeroUI's default
  /// theme) for the given [brightness].
  factory HeroThemeData.fromPreset(
    HeroThemePreset preset, {
    Brightness brightness = Brightness.light,
    bool vibrantPalette = false,
    HeroTypography typography = const HeroTypography(),
    HeroCornerStyle cornerStyle = HeroCornerStyle.continuous,
    HeroDensity density = HeroDensity.adaptive,
    HeroMotion motion = const HeroMotion(),
  }) {
    final HeroColors colors = _colorCache.putIfAbsent(
      (preset, brightness, vibrantPalette),
      () => HeroColors.derive(
        brightness == Brightness.dark ? preset.darkSource : preset.lightSource,
        brightness: brightness,
        vibrantPalette: vibrantPalette,
      ),
    );
    return HeroThemeData(
      brightness: brightness,
      colors: colors,
      preset: preset,
      radii: HeroRadii(
        radius: preset.radius ?? 8,
        field: preset.fieldRadius ?? 12,
      ),
      typography: typography,
      cornerStyle: cornerStyle,
      density: density,
      motion: motion,
      vibrantPalette: vibrantPalette,
    );
  }

  /// HeroUI's light theme, optionally for another [preset].
  factory HeroThemeData.light({
    HeroThemePreset preset = HeroThemePreset.standard,
    bool vibrantPalette = false,
  }) => HeroThemeData.fromPreset(
    preset,
    brightness: Brightness.light,
    vibrantPalette: vibrantPalette,
  );

  /// HeroUI's dark theme, optionally for another [preset].
  factory HeroThemeData.dark({
    HeroThemePreset preset = HeroThemePreset.standard,
    bool vibrantPalette = false,
  }) => HeroThemeData.fromPreset(
    preset,
    brightness: Brightness.dark,
    vibrantPalette: vibrantPalette,
  );

  static final Map<(HeroThemePreset, Brightness, bool), HeroColors>
  _colorCache = <(HeroThemePreset, Brightness, bool), HeroColors>{};

  /// Whether this is a light or dark theme.
  final Brightness brightness;

  /// The preset this theme was built from, if any.
  final HeroThemePreset? preset;

  /// Color tokens.
  final HeroColors colors;

  /// Radius tokens.
  final HeroRadii radii;

  /// Spacing tokens.
  final HeroSpacing spacing;

  /// Typography tokens.
  final HeroTypography typography;

  /// Shadow tokens.
  final HeroShadows shadows;

  /// Motion tokens.
  final HeroMotion motion;

  /// Corner rendering style used by every rounded component.
  final HeroCornerStyle cornerStyle;

  /// `--border-width`.
  final double borderWidth;

  /// `--field-border-width` (0 by default: fields have no visible border).
  final double fieldBorderWidth;

  /// `--disabled-opacity`.
  final double disabledOpacity;

  /// Width of the focus ring (`ring-2`).
  final double focusRingWidth;

  /// Gap between a component and its focus ring (`--ring-offset-width`).
  final double focusRingOffset;

  /// `--skeleton-animation`.
  final HeroSkeletonAnimation skeletonAnimation;

  /// `--tooltip-delay`.
  final Duration tooltipDelay;

  /// `--tooltip-close-delay`.
  final Duration tooltipCloseDelay;

  /// Sizing density; see [HeroDensity].
  final HeroDensity density;

  /// Whether soft foregrounds use HeroUI's vibrant palette.
  final bool vibrantPalette;

  /// Whether this is a dark theme.
  bool get isDark => brightness == Brightness.dark;

  /// Resolves [density] for [context]: `adaptive` becomes `desktop` at the
  /// `md` breakpoint (768) and above, mirroring HeroUI's `md:` utilities.
  HeroDensity resolveDensity(BuildContext context) {
    if (density != HeroDensity.adaptive) return density;
    final double width = MediaQuery.maybeSizeOf(context)?.width ?? 0;
    return width >= HeroBreakpoints.md
        ? HeroDensity.desktop
        : HeroDensity.touch;
  }

  /// Whether [context] resolves to the compact desktop density.
  bool isDesktop(BuildContext context) =>
      resolveDensity(context) == HeroDensity.desktop;

  /// Returns the rounded shape for [radius] in the theme's [cornerStyle].
  OutlinedBorder shape(
    BorderRadiusGeometry radius, {
    BorderSide side = BorderSide.none,
  }) {
    return switch (cornerStyle) {
      HeroCornerStyle.continuous => RoundedSuperellipseBorder(
        borderRadius: radius,
        side: side,
      ),
      HeroCornerStyle.circular => RoundedRectangleBorder(
        borderRadius: radius,
        side: side,
      ),
    };
  }

  /// Shorthand for [shape] with a uniform circular radius.
  OutlinedBorder shapeAll(double radius, {BorderSide side = BorderSide.none}) =>
      shape(BorderRadius.all(Radius.circular(radius)), side: side);

  @override
  HeroThemeData copyWith({
    Brightness? brightness,
    HeroThemePreset? preset,
    HeroColors? colors,
    HeroRadii? radii,
    HeroSpacing? spacing,
    HeroTypography? typography,
    HeroShadows? shadows,
    HeroMotion? motion,
    HeroCornerStyle? cornerStyle,
    double? borderWidth,
    double? fieldBorderWidth,
    double? disabledOpacity,
    double? focusRingWidth,
    double? focusRingOffset,
    HeroSkeletonAnimation? skeletonAnimation,
    Duration? tooltipDelay,
    Duration? tooltipCloseDelay,
    HeroDensity? density,
    bool? vibrantPalette,
  }) {
    return HeroThemeData(
      brightness: brightness ?? this.brightness,
      preset: preset ?? this.preset,
      colors: colors ?? this.colors,
      radii: radii ?? this.radii,
      spacing: spacing ?? this.spacing,
      typography: typography ?? this.typography,
      shadows: shadows ?? this.shadows,
      motion: motion ?? this.motion,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      borderWidth: borderWidth ?? this.borderWidth,
      fieldBorderWidth: fieldBorderWidth ?? this.fieldBorderWidth,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingOffset: focusRingOffset ?? this.focusRingOffset,
      skeletonAnimation: skeletonAnimation ?? this.skeletonAnimation,
      tooltipDelay: tooltipDelay ?? this.tooltipDelay,
      tooltipCloseDelay: tooltipCloseDelay ?? this.tooltipCloseDelay,
      density: density ?? this.density,
      vibrantPalette: vibrantPalette ?? this.vibrantPalette,
    );
  }

  @override
  HeroThemeData lerp(covariant HeroThemeData? other, double t) {
    if (other == null || identical(this, other)) return this;
    final bool first = t < 0.5;
    return HeroThemeData(
      brightness: first ? brightness : other.brightness,
      preset: first ? preset : other.preset,
      colors: HeroColors.lerp(colors, other.colors, t),
      radii: HeroRadii.lerp(radii, other.radii, t),
      spacing: HeroSpacing.lerp(spacing, other.spacing, t),
      typography: first ? typography : other.typography,
      shadows: HeroShadows.lerp(shadows, other.shadows, t),
      motion: first ? motion : other.motion,
      cornerStyle: first ? cornerStyle : other.cornerStyle,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      fieldBorderWidth: lerpDouble(
        fieldBorderWidth,
        other.fieldBorderWidth,
        t,
      )!,
      disabledOpacity: lerpDouble(disabledOpacity, other.disabledOpacity, t)!,
      focusRingWidth: lerpDouble(focusRingWidth, other.focusRingWidth, t)!,
      focusRingOffset: lerpDouble(focusRingOffset, other.focusRingOffset, t)!,
      skeletonAnimation: first ? skeletonAnimation : other.skeletonAnimation,
      tooltipDelay: first ? tooltipDelay : other.tooltipDelay,
      tooltipCloseDelay: first ? tooltipCloseDelay : other.tooltipCloseDelay,
      density: first ? density : other.density,
      vibrantPalette: first ? vibrantPalette : other.vibrantPalette,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeroThemeData &&
        other.brightness == brightness &&
        other.preset == preset &&
        other.colors == colors &&
        other.radii == radii &&
        other.spacing == spacing &&
        other.typography == typography &&
        other.shadows == shadows &&
        other.motion == motion &&
        other.cornerStyle == cornerStyle &&
        other.borderWidth == borderWidth &&
        other.fieldBorderWidth == fieldBorderWidth &&
        other.disabledOpacity == disabledOpacity &&
        other.focusRingWidth == focusRingWidth &&
        other.focusRingOffset == focusRingOffset &&
        other.skeletonAnimation == skeletonAnimation &&
        other.tooltipDelay == tooltipDelay &&
        other.tooltipCloseDelay == tooltipCloseDelay &&
        other.density == density &&
        other.vibrantPalette == vibrantPalette;
  }

  @override
  int get hashCode => Object.hash(
    brightness,
    preset,
    colors,
    radii,
    spacing,
    typography,
    shadows,
    motion,
    cornerStyle,
    borderWidth,
    fieldBorderWidth,
    disabledOpacity,
    focusRingWidth,
    focusRingOffset,
    skeletonAnimation,
    tooltipDelay,
    tooltipCloseDelay,
    density,
    vibrantPalette,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<Brightness>('brightness', brightness))
      ..add(EnumProperty<HeroThemePreset>('preset', preset))
      ..add(DiagnosticsProperty<HeroColors>('colors', colors))
      ..add(DiagnosticsProperty<HeroRadii>('radii', radii))
      ..add(EnumProperty<HeroCornerStyle>('cornerStyle', cornerStyle))
      ..add(EnumProperty<HeroDensity>('density', density));
  }
}
