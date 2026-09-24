import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A Tailwind CSS v4 font-size step: a font size and its default line height,
/// both in logical pixels.
@immutable
class HeroFontSize {
  /// Creates a font-size step.
  const HeroFontSize(this.fontSize, this.lineHeight);

  /// Font size in logical pixels.
  final double fontSize;

  /// Line height in logical pixels.
  final double lineHeight;

  /// `text-xs`: 12 / 16.
  static const HeroFontSize xs = HeroFontSize(12, 16);

  /// `text-sm`: 14 / 20.
  static const HeroFontSize sm = HeroFontSize(14, 20);

  /// `text-base`: 16 / 24.
  static const HeroFontSize base = HeroFontSize(16, 24);

  /// `text-lg`: 18 / 28.
  static const HeroFontSize lg = HeroFontSize(18, 28);

  /// `text-xl`: 20 / 28.
  static const HeroFontSize xl = HeroFontSize(20, 28);

  /// `text-2xl`: 24 / 32.
  static const HeroFontSize xl2 = HeroFontSize(24, 32);

  /// `text-3xl`: 30 / 36.
  static const HeroFontSize xl3 = HeroFontSize(30, 36);

  /// `text-4xl`: 36 / 40.
  static const HeroFontSize xl4 = HeroFontSize(36, 40);

  /// `text-5xl`: 48 / 48.
  static const HeroFontSize xl5 = HeroFontSize(48, 48);

  /// `text-6xl`: 60 / 60.
  static const HeroFontSize xl6 = HeroFontSize(60, 60);

  @override
  bool operator ==(Object other) =>
      other is HeroFontSize &&
      other.fontSize == fontSize &&
      other.lineHeight == lineHeight;

  @override
  int get hashCode => Object.hash(fontSize, lineHeight);
}

/// The HeroUI typography tokens.
///
/// HeroUI renders text in Inter (bundled with this package) on top of
/// Tailwind CSS v4's type scale. Every getter returns a complete [TextStyle]
/// with CSS-like half-leading so text is vertically centred exactly as in the
/// browser. Colors are not set; components apply color tokens themselves.
@immutable
class HeroTypography with Diagnosticable {
  /// Creates typography tokens.
  const HeroTypography({
    this.fontFamily = 'Inter',
    this.fontPackage = 'hero_ui',
    this.fontFamilyFallback = defaultFallback,
    this.monoFontFamily = 'JetBrainsMono',
    this.monoFontPackage = 'hero_ui',
    this.monoFontFamilyFallback = defaultMonoFallback,
  });

  /// Sans-serif fallbacks, following Tailwind's `font-sans` stack.
  static const List<String> defaultFallback = <String>[
    '.AppleSystemUIFont',
    'SF Pro Text',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'Noto Sans',
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Noto Color Emoji',
  ];

  /// Monospace fallbacks, following Tailwind's `font-mono` stack.
  static const List<String> defaultMonoFallback = <String>[
    'SF Mono',
    'Menlo',
    'Monaco',
    'Consolas',
    'Liberation Mono',
    'Courier New',
    'monospace',
  ];

  /// `font-normal` (400).
  static const FontWeight normal = FontWeight.w400;

  /// `font-medium` (500).
  static const FontWeight medium = FontWeight.w500;

  /// `font-semibold` (600).
  static const FontWeight semibold = FontWeight.w600;

  /// `font-bold` (700).
  static const FontWeight bold = FontWeight.w700;

  /// `tracking-tight` in em.
  static const double trackingTight = -0.025;

  /// Primary font family.
  final String fontFamily;

  /// Package that bundles [fontFamily], or null for an app or system font.
  final String? fontPackage;

  /// Fallback font families.
  final List<String> fontFamilyFallback;

  /// Monospace font family used by code and keyboard keys.
  final String monoFontFamily;

  /// Package that bundles [monoFontFamily], or null.
  final String? monoFontPackage;

  /// Monospace fallback font families.
  final List<String> monoFontFamilyFallback;

  /// Returns a text style for the given [size] and [weight].
  ///
  /// [lineHeight] overrides the size's default line height (Tailwind
  /// `leading-*`), and [tracking] sets letter spacing in em.
  TextStyle style(
    HeroFontSize size, {
    FontWeight weight = normal,
    double? lineHeight,
    double tracking = 0,
    bool mono = false,
  }) {
    final double lh = lineHeight ?? size.lineHeight;
    return TextStyle(
      inherit: false,
      fontFamily: mono ? monoFontFamily : fontFamily,
      package: mono ? monoFontPackage : fontPackage,
      fontFamilyFallback: mono ? monoFontFamilyFallback : fontFamilyFallback,
      fontSize: size.fontSize,
      height: lh / size.fontSize,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: weight,
      letterSpacing: tracking == 0 ? null : tracking * size.fontSize,
      textBaseline: TextBaseline.alphabetic,
      decoration: TextDecoration.none,
    );
  }

  /// `text-xs` (12/16).
  TextStyle get xs => style(HeroFontSize.xs);

  /// `text-sm` (14/20).
  TextStyle get sm => style(HeroFontSize.sm);

  /// `text-base` (16/24).
  TextStyle get base => style(HeroFontSize.base);

  /// `text-lg` (18/28).
  TextStyle get lg => style(HeroFontSize.lg);

  /// `text-xl` (20/28).
  TextStyle get xl => style(HeroFontSize.xl);

  /// `text-2xl` (24/32).
  TextStyle get xl2 => style(HeroFontSize.xl2);

  /// `text-3xl` (30/36).
  TextStyle get xl3 => style(HeroFontSize.xl3);

  /// `text-4xl` (36/40).
  TextStyle get xl4 => style(HeroFontSize.xl4);

  /// Typography `h1`: `text-4xl font-semibold tracking-tight`.
  TextStyle get h1 =>
      style(HeroFontSize.xl4, weight: semibold, tracking: trackingTight);

  /// Typography `h2`: `text-3xl font-semibold tracking-tight`.
  TextStyle get h2 =>
      style(HeroFontSize.xl3, weight: semibold, tracking: trackingTight);

  /// Typography `h3`: `text-2xl font-semibold tracking-tight`.
  TextStyle get h3 =>
      style(HeroFontSize.xl2, weight: semibold, tracking: trackingTight);

  /// Typography `h4`: `text-xl font-semibold tracking-tight`.
  TextStyle get h4 =>
      style(HeroFontSize.xl, weight: semibold, tracking: trackingTight);

  /// Typography `h5`: `text-lg font-semibold tracking-tight`.
  TextStyle get h5 =>
      style(HeroFontSize.lg, weight: semibold, tracking: trackingTight);

  /// Typography `h6`: `text-base font-semibold tracking-tight`.
  TextStyle get h6 =>
      style(HeroFontSize.base, weight: semibold, tracking: trackingTight);

  /// Typography `body`: `text-base leading-7`.
  TextStyle get body => style(HeroFontSize.base, lineHeight: 28);

  /// Typography `body-sm`: `text-sm leading-6`.
  TextStyle get bodySm => style(HeroFontSize.sm, lineHeight: 24);

  /// Typography `body-xs`: `text-xs leading-5`.
  TextStyle get bodyXs => style(HeroFontSize.xs, lineHeight: 20);

  /// Typography `code`: `font-mono text-sm`.
  TextStyle get code => style(HeroFontSize.sm, mono: true);

  /// Returns a copy with the given values replaced.
  HeroTypography copyWith({
    String? fontFamily,
    ValueGetter<String?>? fontPackage,
    List<String>? fontFamilyFallback,
    String? monoFontFamily,
    ValueGetter<String?>? monoFontPackage,
    List<String>? monoFontFamilyFallback,
  }) {
    return HeroTypography(
      fontFamily: fontFamily ?? this.fontFamily,
      fontPackage: fontPackage != null ? fontPackage() : this.fontPackage,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      monoFontFamily: monoFontFamily ?? this.monoFontFamily,
      monoFontPackage: monoFontPackage != null
          ? monoFontPackage()
          : this.monoFontPackage,
      monoFontFamilyFallback:
          monoFontFamilyFallback ?? this.monoFontFamilyFallback,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroTypography &&
      other.fontFamily == fontFamily &&
      other.fontPackage == fontPackage &&
      listEquals(other.fontFamilyFallback, fontFamilyFallback) &&
      other.monoFontFamily == monoFontFamily &&
      other.monoFontPackage == monoFontPackage &&
      listEquals(other.monoFontFamilyFallback, monoFontFamilyFallback);

  @override
  int get hashCode => Object.hash(
    fontFamily,
    fontPackage,
    Object.hashAll(fontFamilyFallback),
    monoFontFamily,
    monoFontPackage,
    Object.hashAll(monoFontFamilyFallback),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('fontFamily', fontFamily))
      ..add(StringProperty('monoFontFamily', monoFontFamily));
  }
}
