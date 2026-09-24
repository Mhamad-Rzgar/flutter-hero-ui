import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../color/color_math.dart';

/// The source color tokens of a HeroUI theme.
///
/// These are the values a HeroUI theme declares directly (`--background`,
/// `--accent`, `--field-background`, ...). Every other token, such as hover
/// states, soft tints and secondary borders, is computed from these by
/// [HeroColors.derive] using the formulas from HeroUI's `variables.css`.
@immutable
class HeroColorSource {
  /// Creates a source token set. Every value maps 1:1 to a HeroUI CSS
  /// variable; see [HeroColors] for the meaning of each token.
  const HeroColorSource({
    required this.white,
    required this.black,
    required this.snow,
    required this.eclipse,
    required this.background,
    required this.foreground,
    required this.surface,
    required this.surfaceForeground,
    required this.surfaceSecondary,
    required this.surfaceSecondaryForeground,
    required this.surfaceTertiary,
    required this.surfaceTertiaryForeground,
    required this.overlay,
    required this.overlayForeground,
    required this.muted,
    required this.scrollbar,
    required this.defaultColor,
    required this.defaultForeground,
    required this.fieldBackground,
    required this.fieldForeground,
    required this.fieldPlaceholder,
    required this.fieldBorder,
    required this.accent,
    required this.accentForeground,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.danger,
    required this.dangerForeground,
    required this.segment,
    required this.segmentForeground,
    required this.border,
    required this.separator,
    required this.focus,
    required this.link,
    required this.backdrop,
  });

  /// Source value for [HeroColors.white].
  final Color white;

  /// Source value for [HeroColors.black].
  final Color black;

  /// Source value for [HeroColors.snow].
  final Color snow;

  /// Source value for [HeroColors.eclipse].
  final Color eclipse;

  /// Source value for [HeroColors.background].
  final Color background;

  /// Source value for [HeroColors.foreground].
  final Color foreground;

  /// Source value for [HeroColors.surface].
  final Color surface;

  /// Source value for [HeroColors.surfaceForeground].
  final Color surfaceForeground;

  /// Source value for [HeroColors.surfaceSecondary].
  final Color surfaceSecondary;

  /// Source value for [HeroColors.surfaceSecondaryForeground].
  final Color surfaceSecondaryForeground;

  /// Source value for [HeroColors.surfaceTertiary].
  final Color surfaceTertiary;

  /// Source value for [HeroColors.surfaceTertiaryForeground].
  final Color surfaceTertiaryForeground;

  /// Source value for [HeroColors.overlay].
  final Color overlay;

  /// Source value for [HeroColors.overlayForeground].
  final Color overlayForeground;

  /// Source value for [HeroColors.muted].
  final Color muted;

  /// Source value for [HeroColors.scrollbar].
  final Color scrollbar;

  /// Source value for [HeroColors.defaultColor].
  final Color defaultColor;

  /// Source value for [HeroColors.defaultForeground].
  final Color defaultForeground;

  /// Source value for [HeroColors.fieldBackground].
  final Color fieldBackground;

  /// Source value for [HeroColors.fieldForeground].
  final Color fieldForeground;

  /// Source value for [HeroColors.fieldPlaceholder].
  final Color fieldPlaceholder;

  /// Source value for [HeroColors.fieldBorder].
  final Color fieldBorder;

  /// Source value for [HeroColors.accent].
  final Color accent;

  /// Source value for [HeroColors.accentForeground].
  final Color accentForeground;

  /// Source value for [HeroColors.success].
  final Color success;

  /// Source value for [HeroColors.successForeground].
  final Color successForeground;

  /// Source value for [HeroColors.warning].
  final Color warning;

  /// Source value for [HeroColors.warningForeground].
  final Color warningForeground;

  /// Source value for [HeroColors.danger].
  final Color danger;

  /// Source value for [HeroColors.dangerForeground].
  final Color dangerForeground;

  /// Source value for [HeroColors.segment].
  final Color segment;

  /// Source value for [HeroColors.segmentForeground].
  final Color segmentForeground;

  /// Source value for [HeroColors.border].
  final Color border;

  /// Source value for [HeroColors.separator].
  final Color separator;

  /// Source value for [HeroColors.focus].
  final Color focus;

  /// Source value for [HeroColors.link].
  final Color link;

  /// Source value for [HeroColors.backdrop].
  final Color backdrop;

  /// Returns a copy with the given source tokens replaced.
  HeroColorSource copyWith({
    Color? white,
    Color? black,
    Color? snow,
    Color? eclipse,
    Color? background,
    Color? foreground,
    Color? surface,
    Color? surfaceForeground,
    Color? surfaceSecondary,
    Color? surfaceSecondaryForeground,
    Color? surfaceTertiary,
    Color? surfaceTertiaryForeground,
    Color? overlay,
    Color? overlayForeground,
    Color? muted,
    Color? scrollbar,
    Color? defaultColor,
    Color? defaultForeground,
    Color? fieldBackground,
    Color? fieldForeground,
    Color? fieldPlaceholder,
    Color? fieldBorder,
    Color? accent,
    Color? accentForeground,
    Color? success,
    Color? successForeground,
    Color? warning,
    Color? warningForeground,
    Color? danger,
    Color? dangerForeground,
    Color? segment,
    Color? segmentForeground,
    Color? border,
    Color? separator,
    Color? focus,
    Color? link,
    Color? backdrop,
  }) {
    return HeroColorSource(
      white: white ?? this.white,
      black: black ?? this.black,
      snow: snow ?? this.snow,
      eclipse: eclipse ?? this.eclipse,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      surface: surface ?? this.surface,
      surfaceForeground: surfaceForeground ?? this.surfaceForeground,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceSecondaryForeground:
          surfaceSecondaryForeground ?? this.surfaceSecondaryForeground,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      surfaceTertiaryForeground:
          surfaceTertiaryForeground ?? this.surfaceTertiaryForeground,
      overlay: overlay ?? this.overlay,
      overlayForeground: overlayForeground ?? this.overlayForeground,
      muted: muted ?? this.muted,
      scrollbar: scrollbar ?? this.scrollbar,
      defaultColor: defaultColor ?? this.defaultColor,
      defaultForeground: defaultForeground ?? this.defaultForeground,
      fieldBackground: fieldBackground ?? this.fieldBackground,
      fieldForeground: fieldForeground ?? this.fieldForeground,
      fieldPlaceholder: fieldPlaceholder ?? this.fieldPlaceholder,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      success: success ?? this.success,
      successForeground: successForeground ?? this.successForeground,
      warning: warning ?? this.warning,
      warningForeground: warningForeground ?? this.warningForeground,
      danger: danger ?? this.danger,
      dangerForeground: dangerForeground ?? this.dangerForeground,
      segment: segment ?? this.segment,
      segmentForeground: segmentForeground ?? this.segmentForeground,
      border: border ?? this.border,
      separator: separator ?? this.separator,
      focus: focus ?? this.focus,
      link: link ?? this.link,
      backdrop: backdrop ?? this.backdrop,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeroColorSource &&
        other.white == white &&
        other.black == black &&
        other.snow == snow &&
        other.eclipse == eclipse &&
        other.background == background &&
        other.foreground == foreground &&
        other.surface == surface &&
        other.surfaceForeground == surfaceForeground &&
        other.surfaceSecondary == surfaceSecondary &&
        other.surfaceSecondaryForeground == surfaceSecondaryForeground &&
        other.surfaceTertiary == surfaceTertiary &&
        other.surfaceTertiaryForeground == surfaceTertiaryForeground &&
        other.overlay == overlay &&
        other.overlayForeground == overlayForeground &&
        other.muted == muted &&
        other.scrollbar == scrollbar &&
        other.defaultColor == defaultColor &&
        other.defaultForeground == defaultForeground &&
        other.fieldBackground == fieldBackground &&
        other.fieldForeground == fieldForeground &&
        other.fieldPlaceholder == fieldPlaceholder &&
        other.fieldBorder == fieldBorder &&
        other.accent == accent &&
        other.accentForeground == accentForeground &&
        other.success == success &&
        other.successForeground == successForeground &&
        other.warning == warning &&
        other.warningForeground == warningForeground &&
        other.danger == danger &&
        other.dangerForeground == dangerForeground &&
        other.segment == segment &&
        other.segmentForeground == segmentForeground &&
        other.border == border &&
        other.separator == separator &&
        other.focus == focus &&
        other.link == link &&
        other.backdrop == backdrop;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
    white,
    black,
    snow,
    eclipse,
    background,
    foreground,
    surface,
    surfaceForeground,
    surfaceSecondary,
    surfaceSecondaryForeground,
    surfaceTertiary,
    surfaceTertiaryForeground,
    overlay,
    overlayForeground,
    muted,
    scrollbar,
    defaultColor,
    defaultForeground,
    fieldBackground,
    fieldForeground,
    fieldPlaceholder,
    fieldBorder,
    accent,
    accentForeground,
    success,
    successForeground,
    warning,
    warningForeground,
    danger,
    dangerForeground,
    segment,
    segmentForeground,
    border,
    separator,
    focus,
    link,
    backdrop,
  ]);

  /// The HeroUI default light theme (`:root`, `.light`).
  static final HeroColorSource light = () {
    final Color white = oklch(1, 0, 0);
    final Color snow = oklch(0.9911, 0, 0);
    final Color eclipse = oklch(0.2103, 0.0059, 285.89);
    final Color accent = oklch(0.6204, 0.195, 253.83);
    final Color muted = oklch(0.5517, 0.0138, 285.94);
    return HeroColorSource(
      white: white,
      black: oklch(0, 0, 0),
      snow: snow,
      eclipse: eclipse,
      background: oklch(0.9702, 0, 0),
      foreground: eclipse,
      surface: white,
      surfaceForeground: eclipse,
      surfaceSecondary: oklch(0.9524, 0.0013, 286.37),
      surfaceSecondaryForeground: eclipse,
      surfaceTertiary: oklch(0.9373, 0.0013, 286.37),
      surfaceTertiaryForeground: eclipse,
      overlay: white,
      overlayForeground: eclipse,
      muted: muted,
      scrollbar: colorMix(
        eclipse,
        const Color(0x00000000),
        p1: 0.15,
        space: ColorMixSpace.oklch,
      ),
      defaultColor: oklch(0.94, 0.001, 286.375),
      defaultForeground: eclipse,
      fieldBackground: white,
      fieldForeground: oklch(0.2103, 0.0059, 285.89),
      fieldPlaceholder: muted,
      fieldBorder: const Color(0x00000000),
      accent: accent,
      accentForeground: snow,
      success: oklch(0.7329, 0.1935, 150.81),
      successForeground: eclipse,
      warning: oklch(0.7819, 0.1585, 72.33),
      warningForeground: eclipse,
      danger: oklch(0.6532, 0.2328, 25.74),
      dangerForeground: snow,
      segment: white,
      segmentForeground: eclipse,
      border: oklch(0.90, 0.004, 286.32),
      separator: oklch(0.92, 0.004, 286.32),
      focus: accent,
      link: eclipse,
      backdrop: const Color.fromRGBO(0, 0, 0, 0.5),
    );
  }();

  /// The HeroUI default dark theme (`.dark`, `[data-theme="dark"]`).
  static final HeroColorSource dark = () {
    final Color snow = oklch(0.9911, 0, 0);
    final Color eclipse = oklch(0.2103, 0.0059, 285.89);
    final Color accent = oklch(0.6204, 0.195, 253.83);
    final Color muted = oklch(0.705, 0.015, 286.067);
    final Color surface = oklch(0.2103, 0.0059, 285.89);
    return HeroColorSource(
      white: oklch(1, 0, 0),
      black: oklch(0, 0, 0),
      snow: snow,
      eclipse: eclipse,
      background: oklch(0.12, 0.005, 285.823),
      foreground: snow,
      surface: surface,
      surfaceForeground: snow,
      surfaceSecondary: oklch(0.257, 0.0037, 286.14),
      surfaceSecondaryForeground: snow,
      surfaceTertiary: oklch(0.2721, 0.0024, 247.91),
      surfaceTertiaryForeground: snow,
      overlay: surface,
      overlayForeground: snow,
      muted: muted,
      scrollbar: colorMix(
        snow,
        const Color(0x00000000),
        p1: 0.15,
        space: ColorMixSpace.oklch,
      ),
      defaultColor: oklch(0.274, 0.006, 286.033),
      defaultForeground: snow,
      fieldBackground: surface,
      fieldForeground: snow,
      fieldPlaceholder: muted,
      fieldBorder: const Color(0x00000000),
      accent: accent,
      accentForeground: snow,
      success: oklch(0.7329, 0.1935, 150.81),
      successForeground: eclipse,
      warning: oklch(0.8203, 0.1388, 76.34),
      warningForeground: eclipse,
      danger: oklch(0.594, 0.1967, 24.63),
      dangerForeground: snow,
      segment: oklch(0.3964, 0.01, 285.93),
      segmentForeground: snow,
      border: oklch(0.28, 0.006, 286.033),
      separator: oklch(0.25, 0.006, 286.033),
      focus: accent,
      link: snow,
      backdrop: const Color.fromRGBO(0, 0, 0, 0.6),
    );
  }();
}

/// The complete set of HeroUI color tokens for one theme and brightness.
///
/// Field names mirror HeroUI's CSS variables in camelCase (`--accent-soft`
/// becomes [accentSoft]). The `--default` token is exposed as [defaultColor]
/// because `default` is a reserved word in Dart.
@immutable
class HeroColors with Diagnosticable {
  /// Creates a complete color token set. Prefer [HeroColors.derive], which
  /// computes every calculated token from the source tokens exactly like
  /// HeroUI's theme CSS.
  const HeroColors({
    required this.white,
    required this.black,
    required this.snow,
    required this.eclipse,
    required this.background,
    required this.foreground,
    required this.surface,
    required this.surfaceForeground,
    required this.surfaceSecondary,
    required this.surfaceSecondaryForeground,
    required this.surfaceTertiary,
    required this.surfaceTertiaryForeground,
    required this.overlay,
    required this.overlayForeground,
    required this.muted,
    required this.scrollbar,
    required this.defaultColor,
    required this.defaultForeground,
    required this.fieldBackground,
    required this.fieldForeground,
    required this.fieldPlaceholder,
    required this.fieldBorder,
    required this.accent,
    required this.accentForeground,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.danger,
    required this.dangerForeground,
    required this.segment,
    required this.segmentForeground,
    required this.border,
    required this.separator,
    required this.focus,
    required this.link,
    required this.backdrop,
    required this.surfaceHover,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundInverse,
    required this.defaultHover,
    required this.accentHover,
    required this.successHover,
    required this.warningHover,
    required this.dangerHover,
    required this.fieldHover,
    required this.fieldFocus,
    required this.fieldBorderHover,
    required this.fieldBorderFocus,
    required this.defaultSoft,
    required this.defaultSoftForeground,
    required this.defaultSoftHover,
    required this.accentSoft,
    required this.accentSoftForeground,
    required this.accentSoftHover,
    required this.dangerSoft,
    required this.dangerSoftForeground,
    required this.dangerSoftHover,
    required this.warningSoft,
    required this.warningSoftForeground,
    required this.warningSoftHover,
    required this.successSoft,
    required this.successSoftForeground,
    required this.successSoftHover,
    required this.separatorSecondary,
    required this.separatorTertiary,
    required this.borderSecondary,
    required this.borderTertiary,
    required this.chart1,
    required this.chart2,
    required this.chart3,
    required this.chart4,
    required this.chart5,
  });

  /// Pure white primitive. CSS: `--white`.
  final Color white;

  /// Pure black primitive. CSS: `--black`.
  final Color black;

  /// Near-white primitive used for light foregrounds. CSS: `--snow`.
  final Color snow;

  /// Near-black primitive used for dark foregrounds. CSS: `--eclipse`.
  final Color eclipse;

  /// App background. CSS: `--background`.
  final Color background;

  /// Default text color on [background]. CSS: `--foreground`.
  final Color foreground;

  /// Non-overlay container background (cards, accordions, disclosure groups). CSS: `--surface`.
  final Color surface;

  /// Text color on [surface]. CSS: `--surface-foreground`.
  final Color surfaceForeground;

  /// Secondary surface level. CSS: `--surface-secondary`.
  final Color surfaceSecondary;

  /// Text color on [surfaceSecondary]. CSS: `--surface-secondary-foreground`.
  final Color surfaceSecondaryForeground;

  /// Tertiary surface level. CSS: `--surface-tertiary`.
  final Color surfaceTertiary;

  /// Text color on [surfaceTertiary]. CSS: `--surface-tertiary-foreground`.
  final Color surfaceTertiaryForeground;

  /// Floating container background (tooltips, popovers, modals, menus). CSS: `--overlay`.
  final Color overlay;

  /// Text color on [overlay]. CSS: `--overlay-foreground`.
  final Color overlayForeground;

  /// Muted text (descriptions, placeholders, secondary labels). CSS: `--muted`.
  final Color muted;

  /// Scrollbar thumb color. CSS: `--scrollbar`.
  final Color scrollbar;

  /// Neutral fill used by the `default` color role. CSS: `--default`.
  final Color defaultColor;

  /// Text color on [defaultColor]. CSS: `--default-foreground`.
  final Color defaultForeground;

  /// Form field background. CSS: `--field-background`.
  final Color fieldBackground;

  /// Form field text color. CSS: `--field-foreground`.
  final Color fieldForeground;

  /// Form field placeholder color. CSS: `--field-placeholder`.
  final Color fieldPlaceholder;

  /// Form field border color. CSS: `--field-border`.
  final Color fieldBorder;

  /// Brand accent color. CSS: `--accent`.
  final Color accent;

  /// Text color on [accent]. CSS: `--accent-foreground`.
  final Color accentForeground;

  /// Success status color. CSS: `--success`.
  final Color success;

  /// Text color on [success]. CSS: `--success-foreground`.
  final Color successForeground;

  /// Warning status color. CSS: `--warning`.
  final Color warning;

  /// Text color on [warning]. CSS: `--warning-foreground`.
  final Color warningForeground;

  /// Danger status color. CSS: `--danger`.
  final Color danger;

  /// Text color on [danger]. CSS: `--danger-foreground`.
  final Color dangerForeground;

  /// Selected segment background (tabs, toggle groups). CSS: `--segment`.
  final Color segment;

  /// Text color on [segment]. CSS: `--segment-foreground`.
  final Color segmentForeground;

  /// Default border color. CSS: `--border`.
  final Color border;

  /// Separator line color. CSS: `--separator`.
  final Color separator;

  /// Focus ring color. CSS: `--focus`.
  final Color focus;

  /// Link text color. CSS: `--link`.
  final Color link;

  /// Modal backdrop color. CSS: `--backdrop`.
  final Color backdrop;

  /// Hovered [surface]. CSS: `--surface-hover`.
  final Color surfaceHover;

  /// Secondary background level. CSS: `--background-secondary`.
  final Color backgroundSecondary;

  /// Tertiary background level. CSS: `--background-tertiary`.
  final Color backgroundTertiary;

  /// Inverted background (equals [foreground]). CSS: `--background-inverse`.
  final Color backgroundInverse;

  /// Hovered [defaultColor]. CSS: `--default-hover`.
  final Color defaultHover;

  /// Hovered [accent]. CSS: `--accent-hover`.
  final Color accentHover;

  /// Hovered [success]. CSS: `--success-hover`.
  final Color successHover;

  /// Hovered [warning]. CSS: `--warning-hover`.
  final Color warningHover;

  /// Hovered [danger]. CSS: `--danger-hover`.
  final Color dangerHover;

  /// Hovered form field background. CSS: `--field-hover`.
  final Color fieldHover;

  /// Focused form field background. CSS: `--field-focus`.
  final Color fieldFocus;

  /// Hovered form field border. CSS: `--field-border-hover`.
  final Color fieldBorderHover;

  /// Focused form field border. CSS: `--field-border-focus`.
  final Color fieldBorderFocus;

  /// Soft (tinted) default background. CSS: `--default-soft`.
  final Color defaultSoft;

  /// Text color on [defaultSoft]. CSS: `--default-soft-foreground`.
  final Color defaultSoftForeground;

  /// Hovered [defaultSoft]. CSS: `--default-soft-hover`.
  final Color defaultSoftHover;

  /// Soft (tinted) accent background. CSS: `--accent-soft`.
  final Color accentSoft;

  /// Text color on [accentSoft]. CSS: `--accent-soft-foreground`.
  final Color accentSoftForeground;

  /// Hovered [accentSoft]. CSS: `--accent-soft-hover`.
  final Color accentSoftHover;

  /// Soft (tinted) danger background. CSS: `--danger-soft`.
  final Color dangerSoft;

  /// Text color on [dangerSoft]. CSS: `--danger-soft-foreground`.
  final Color dangerSoftForeground;

  /// Hovered [dangerSoft]. CSS: `--danger-soft-hover`.
  final Color dangerSoftHover;

  /// Soft (tinted) warning background. CSS: `--warning-soft`.
  final Color warningSoft;

  /// Text color on [warningSoft]. CSS: `--warning-soft-foreground`.
  final Color warningSoftForeground;

  /// Hovered [warningSoft]. CSS: `--warning-soft-hover`.
  final Color warningSoftHover;

  /// Soft (tinted) success background. CSS: `--success-soft`.
  final Color successSoft;

  /// Text color on [successSoft]. CSS: `--success-soft-foreground`.
  final Color successSoftForeground;

  /// Hovered [successSoft]. CSS: `--success-soft-hover`.
  final Color successSoftHover;

  /// Separator on secondary surfaces. CSS: `--separator-secondary`.
  final Color separatorSecondary;

  /// Separator on tertiary surfaces. CSS: `--separator-tertiary`.
  final Color separatorTertiary;

  /// Border on secondary surfaces. CSS: `--border-secondary`.
  final Color borderSecondary;

  /// Border on tertiary surfaces. CSS: `--border-tertiary`.
  final Color borderTertiary;

  /// Chart series 1 (accent, lightness -0.24). CSS: `--chart-1`.
  final Color chart1;

  /// Chart series 2 (accent, lightness -0.12). CSS: `--chart-2`.
  final Color chart2;

  /// Chart series 3 (accent). CSS: `--chart-3`.
  final Color chart3;

  /// Chart series 4 (accent, lightness +0.12). CSS: `--chart-4`.
  final Color chart4;

  /// Chart series 5 (accent, lightness +0.24). CSS: `--chart-5`.
  final Color chart5;

  /// Returns a copy with the given tokens replaced. Calculated tokens are
  /// not re-derived; use [HeroColors.derive] to rebuild a consistent set.
  HeroColors copyWith({
    Color? white,
    Color? black,
    Color? snow,
    Color? eclipse,
    Color? background,
    Color? foreground,
    Color? surface,
    Color? surfaceForeground,
    Color? surfaceSecondary,
    Color? surfaceSecondaryForeground,
    Color? surfaceTertiary,
    Color? surfaceTertiaryForeground,
    Color? overlay,
    Color? overlayForeground,
    Color? muted,
    Color? scrollbar,
    Color? defaultColor,
    Color? defaultForeground,
    Color? fieldBackground,
    Color? fieldForeground,
    Color? fieldPlaceholder,
    Color? fieldBorder,
    Color? accent,
    Color? accentForeground,
    Color? success,
    Color? successForeground,
    Color? warning,
    Color? warningForeground,
    Color? danger,
    Color? dangerForeground,
    Color? segment,
    Color? segmentForeground,
    Color? border,
    Color? separator,
    Color? focus,
    Color? link,
    Color? backdrop,
    Color? surfaceHover,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? backgroundInverse,
    Color? defaultHover,
    Color? accentHover,
    Color? successHover,
    Color? warningHover,
    Color? dangerHover,
    Color? fieldHover,
    Color? fieldFocus,
    Color? fieldBorderHover,
    Color? fieldBorderFocus,
    Color? defaultSoft,
    Color? defaultSoftForeground,
    Color? defaultSoftHover,
    Color? accentSoft,
    Color? accentSoftForeground,
    Color? accentSoftHover,
    Color? dangerSoft,
    Color? dangerSoftForeground,
    Color? dangerSoftHover,
    Color? warningSoft,
    Color? warningSoftForeground,
    Color? warningSoftHover,
    Color? successSoft,
    Color? successSoftForeground,
    Color? successSoftHover,
    Color? separatorSecondary,
    Color? separatorTertiary,
    Color? borderSecondary,
    Color? borderTertiary,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
  }) {
    return HeroColors(
      white: white ?? this.white,
      black: black ?? this.black,
      snow: snow ?? this.snow,
      eclipse: eclipse ?? this.eclipse,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      surface: surface ?? this.surface,
      surfaceForeground: surfaceForeground ?? this.surfaceForeground,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceSecondaryForeground:
          surfaceSecondaryForeground ?? this.surfaceSecondaryForeground,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      surfaceTertiaryForeground:
          surfaceTertiaryForeground ?? this.surfaceTertiaryForeground,
      overlay: overlay ?? this.overlay,
      overlayForeground: overlayForeground ?? this.overlayForeground,
      muted: muted ?? this.muted,
      scrollbar: scrollbar ?? this.scrollbar,
      defaultColor: defaultColor ?? this.defaultColor,
      defaultForeground: defaultForeground ?? this.defaultForeground,
      fieldBackground: fieldBackground ?? this.fieldBackground,
      fieldForeground: fieldForeground ?? this.fieldForeground,
      fieldPlaceholder: fieldPlaceholder ?? this.fieldPlaceholder,
      fieldBorder: fieldBorder ?? this.fieldBorder,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      success: success ?? this.success,
      successForeground: successForeground ?? this.successForeground,
      warning: warning ?? this.warning,
      warningForeground: warningForeground ?? this.warningForeground,
      danger: danger ?? this.danger,
      dangerForeground: dangerForeground ?? this.dangerForeground,
      segment: segment ?? this.segment,
      segmentForeground: segmentForeground ?? this.segmentForeground,
      border: border ?? this.border,
      separator: separator ?? this.separator,
      focus: focus ?? this.focus,
      link: link ?? this.link,
      backdrop: backdrop ?? this.backdrop,
      surfaceHover: surfaceHover ?? this.surfaceHover,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundInverse: backgroundInverse ?? this.backgroundInverse,
      defaultHover: defaultHover ?? this.defaultHover,
      accentHover: accentHover ?? this.accentHover,
      successHover: successHover ?? this.successHover,
      warningHover: warningHover ?? this.warningHover,
      dangerHover: dangerHover ?? this.dangerHover,
      fieldHover: fieldHover ?? this.fieldHover,
      fieldFocus: fieldFocus ?? this.fieldFocus,
      fieldBorderHover: fieldBorderHover ?? this.fieldBorderHover,
      fieldBorderFocus: fieldBorderFocus ?? this.fieldBorderFocus,
      defaultSoft: defaultSoft ?? this.defaultSoft,
      defaultSoftForeground:
          defaultSoftForeground ?? this.defaultSoftForeground,
      defaultSoftHover: defaultSoftHover ?? this.defaultSoftHover,
      accentSoft: accentSoft ?? this.accentSoft,
      accentSoftForeground: accentSoftForeground ?? this.accentSoftForeground,
      accentSoftHover: accentSoftHover ?? this.accentSoftHover,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      dangerSoftForeground: dangerSoftForeground ?? this.dangerSoftForeground,
      dangerSoftHover: dangerSoftHover ?? this.dangerSoftHover,
      warningSoft: warningSoft ?? this.warningSoft,
      warningSoftForeground:
          warningSoftForeground ?? this.warningSoftForeground,
      warningSoftHover: warningSoftHover ?? this.warningSoftHover,
      successSoft: successSoft ?? this.successSoft,
      successSoftForeground:
          successSoftForeground ?? this.successSoftForeground,
      successSoftHover: successSoftHover ?? this.successSoftHover,
      separatorSecondary: separatorSecondary ?? this.separatorSecondary,
      separatorTertiary: separatorTertiary ?? this.separatorTertiary,
      borderSecondary: borderSecondary ?? this.borderSecondary,
      borderTertiary: borderTertiary ?? this.borderTertiary,
      chart1: chart1 ?? this.chart1,
      chart2: chart2 ?? this.chart2,
      chart3: chart3 ?? this.chart3,
      chart4: chart4 ?? this.chart4,
      chart5: chart5 ?? this.chart5,
    );
  }

  /// Linearly interpolates between two color sets.
  static HeroColors lerp(HeroColors a, HeroColors b, double t) {
    if (identical(a, b)) return a;
    return HeroColors(
      white: Color.lerp(a.white, b.white, t)!,
      black: Color.lerp(a.black, b.black, t)!,
      snow: Color.lerp(a.snow, b.snow, t)!,
      eclipse: Color.lerp(a.eclipse, b.eclipse, t)!,
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      surfaceForeground: Color.lerp(
        a.surfaceForeground,
        b.surfaceForeground,
        t,
      )!,
      surfaceSecondary: Color.lerp(a.surfaceSecondary, b.surfaceSecondary, t)!,
      surfaceSecondaryForeground: Color.lerp(
        a.surfaceSecondaryForeground,
        b.surfaceSecondaryForeground,
        t,
      )!,
      surfaceTertiary: Color.lerp(a.surfaceTertiary, b.surfaceTertiary, t)!,
      surfaceTertiaryForeground: Color.lerp(
        a.surfaceTertiaryForeground,
        b.surfaceTertiaryForeground,
        t,
      )!,
      overlay: Color.lerp(a.overlay, b.overlay, t)!,
      overlayForeground: Color.lerp(
        a.overlayForeground,
        b.overlayForeground,
        t,
      )!,
      muted: Color.lerp(a.muted, b.muted, t)!,
      scrollbar: Color.lerp(a.scrollbar, b.scrollbar, t)!,
      defaultColor: Color.lerp(a.defaultColor, b.defaultColor, t)!,
      defaultForeground: Color.lerp(
        a.defaultForeground,
        b.defaultForeground,
        t,
      )!,
      fieldBackground: Color.lerp(a.fieldBackground, b.fieldBackground, t)!,
      fieldForeground: Color.lerp(a.fieldForeground, b.fieldForeground, t)!,
      fieldPlaceholder: Color.lerp(a.fieldPlaceholder, b.fieldPlaceholder, t)!,
      fieldBorder: Color.lerp(a.fieldBorder, b.fieldBorder, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      accentForeground: Color.lerp(a.accentForeground, b.accentForeground, t)!,
      success: Color.lerp(a.success, b.success, t)!,
      successForeground: Color.lerp(
        a.successForeground,
        b.successForeground,
        t,
      )!,
      warning: Color.lerp(a.warning, b.warning, t)!,
      warningForeground: Color.lerp(
        a.warningForeground,
        b.warningForeground,
        t,
      )!,
      danger: Color.lerp(a.danger, b.danger, t)!,
      dangerForeground: Color.lerp(a.dangerForeground, b.dangerForeground, t)!,
      segment: Color.lerp(a.segment, b.segment, t)!,
      segmentForeground: Color.lerp(
        a.segmentForeground,
        b.segmentForeground,
        t,
      )!,
      border: Color.lerp(a.border, b.border, t)!,
      separator: Color.lerp(a.separator, b.separator, t)!,
      focus: Color.lerp(a.focus, b.focus, t)!,
      link: Color.lerp(a.link, b.link, t)!,
      backdrop: Color.lerp(a.backdrop, b.backdrop, t)!,
      surfaceHover: Color.lerp(a.surfaceHover, b.surfaceHover, t)!,
      backgroundSecondary: Color.lerp(
        a.backgroundSecondary,
        b.backgroundSecondary,
        t,
      )!,
      backgroundTertiary: Color.lerp(
        a.backgroundTertiary,
        b.backgroundTertiary,
        t,
      )!,
      backgroundInverse: Color.lerp(
        a.backgroundInverse,
        b.backgroundInverse,
        t,
      )!,
      defaultHover: Color.lerp(a.defaultHover, b.defaultHover, t)!,
      accentHover: Color.lerp(a.accentHover, b.accentHover, t)!,
      successHover: Color.lerp(a.successHover, b.successHover, t)!,
      warningHover: Color.lerp(a.warningHover, b.warningHover, t)!,
      dangerHover: Color.lerp(a.dangerHover, b.dangerHover, t)!,
      fieldHover: Color.lerp(a.fieldHover, b.fieldHover, t)!,
      fieldFocus: Color.lerp(a.fieldFocus, b.fieldFocus, t)!,
      fieldBorderHover: Color.lerp(a.fieldBorderHover, b.fieldBorderHover, t)!,
      fieldBorderFocus: Color.lerp(a.fieldBorderFocus, b.fieldBorderFocus, t)!,
      defaultSoft: Color.lerp(a.defaultSoft, b.defaultSoft, t)!,
      defaultSoftForeground: Color.lerp(
        a.defaultSoftForeground,
        b.defaultSoftForeground,
        t,
      )!,
      defaultSoftHover: Color.lerp(a.defaultSoftHover, b.defaultSoftHover, t)!,
      accentSoft: Color.lerp(a.accentSoft, b.accentSoft, t)!,
      accentSoftForeground: Color.lerp(
        a.accentSoftForeground,
        b.accentSoftForeground,
        t,
      )!,
      accentSoftHover: Color.lerp(a.accentSoftHover, b.accentSoftHover, t)!,
      dangerSoft: Color.lerp(a.dangerSoft, b.dangerSoft, t)!,
      dangerSoftForeground: Color.lerp(
        a.dangerSoftForeground,
        b.dangerSoftForeground,
        t,
      )!,
      dangerSoftHover: Color.lerp(a.dangerSoftHover, b.dangerSoftHover, t)!,
      warningSoft: Color.lerp(a.warningSoft, b.warningSoft, t)!,
      warningSoftForeground: Color.lerp(
        a.warningSoftForeground,
        b.warningSoftForeground,
        t,
      )!,
      warningSoftHover: Color.lerp(a.warningSoftHover, b.warningSoftHover, t)!,
      successSoft: Color.lerp(a.successSoft, b.successSoft, t)!,
      successSoftForeground: Color.lerp(
        a.successSoftForeground,
        b.successSoftForeground,
        t,
      )!,
      successSoftHover: Color.lerp(a.successSoftHover, b.successSoftHover, t)!,
      separatorSecondary: Color.lerp(
        a.separatorSecondary,
        b.separatorSecondary,
        t,
      )!,
      separatorTertiary: Color.lerp(
        a.separatorTertiary,
        b.separatorTertiary,
        t,
      )!,
      borderSecondary: Color.lerp(a.borderSecondary, b.borderSecondary, t)!,
      borderTertiary: Color.lerp(a.borderTertiary, b.borderTertiary, t)!,
      chart1: Color.lerp(a.chart1, b.chart1, t)!,
      chart2: Color.lerp(a.chart2, b.chart2, t)!,
      chart3: Color.lerp(a.chart3, b.chart3, t)!,
      chart4: Color.lerp(a.chart4, b.chart4, t)!,
      chart5: Color.lerp(a.chart5, b.chart5, t)!,
    );
  }

  /// Every token keyed by its CSS variable name (without the `--`).
  Map<String, Color> toMap() => <String, Color>{
    'white': white,
    'black': black,
    'snow': snow,
    'eclipse': eclipse,
    'background': background,
    'foreground': foreground,
    'surface': surface,
    'surface-foreground': surfaceForeground,
    'surface-secondary': surfaceSecondary,
    'surface-secondary-foreground': surfaceSecondaryForeground,
    'surface-tertiary': surfaceTertiary,
    'surface-tertiary-foreground': surfaceTertiaryForeground,
    'overlay': overlay,
    'overlay-foreground': overlayForeground,
    'muted': muted,
    'scrollbar': scrollbar,
    'default': defaultColor,
    'default-foreground': defaultForeground,
    'field-background': fieldBackground,
    'field-foreground': fieldForeground,
    'field-placeholder': fieldPlaceholder,
    'field-border': fieldBorder,
    'accent': accent,
    'accent-foreground': accentForeground,
    'success': success,
    'success-foreground': successForeground,
    'warning': warning,
    'warning-foreground': warningForeground,
    'danger': danger,
    'danger-foreground': dangerForeground,
    'segment': segment,
    'segment-foreground': segmentForeground,
    'border': border,
    'separator': separator,
    'focus': focus,
    'link': link,
    'backdrop': backdrop,
    'surface-hover': surfaceHover,
    'background-secondary': backgroundSecondary,
    'background-tertiary': backgroundTertiary,
    'background-inverse': backgroundInverse,
    'default-hover': defaultHover,
    'accent-hover': accentHover,
    'success-hover': successHover,
    'warning-hover': warningHover,
    'danger-hover': dangerHover,
    'field-hover': fieldHover,
    'field-focus': fieldFocus,
    'field-border-hover': fieldBorderHover,
    'field-border-focus': fieldBorderFocus,
    'default-soft': defaultSoft,
    'default-soft-foreground': defaultSoftForeground,
    'default-soft-hover': defaultSoftHover,
    'accent-soft': accentSoft,
    'accent-soft-foreground': accentSoftForeground,
    'accent-soft-hover': accentSoftHover,
    'danger-soft': dangerSoft,
    'danger-soft-foreground': dangerSoftForeground,
    'danger-soft-hover': dangerSoftHover,
    'warning-soft': warningSoft,
    'warning-soft-foreground': warningSoftForeground,
    'warning-soft-hover': warningSoftHover,
    'success-soft': successSoft,
    'success-soft-foreground': successSoftForeground,
    'success-soft-hover': successSoftHover,
    'separator-secondary': separatorSecondary,
    'separator-tertiary': separatorTertiary,
    'border-secondary': borderSecondary,
    'border-tertiary': borderTertiary,
    'chart-1': chart1,
    'chart-2': chart2,
    'chart-3': chart3,
    'chart-4': chart4,
    'chart-5': chart5,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeroColors &&
        other.white == white &&
        other.black == black &&
        other.snow == snow &&
        other.eclipse == eclipse &&
        other.background == background &&
        other.foreground == foreground &&
        other.surface == surface &&
        other.surfaceForeground == surfaceForeground &&
        other.surfaceSecondary == surfaceSecondary &&
        other.surfaceSecondaryForeground == surfaceSecondaryForeground &&
        other.surfaceTertiary == surfaceTertiary &&
        other.surfaceTertiaryForeground == surfaceTertiaryForeground &&
        other.overlay == overlay &&
        other.overlayForeground == overlayForeground &&
        other.muted == muted &&
        other.scrollbar == scrollbar &&
        other.defaultColor == defaultColor &&
        other.defaultForeground == defaultForeground &&
        other.fieldBackground == fieldBackground &&
        other.fieldForeground == fieldForeground &&
        other.fieldPlaceholder == fieldPlaceholder &&
        other.fieldBorder == fieldBorder &&
        other.accent == accent &&
        other.accentForeground == accentForeground &&
        other.success == success &&
        other.successForeground == successForeground &&
        other.warning == warning &&
        other.warningForeground == warningForeground &&
        other.danger == danger &&
        other.dangerForeground == dangerForeground &&
        other.segment == segment &&
        other.segmentForeground == segmentForeground &&
        other.border == border &&
        other.separator == separator &&
        other.focus == focus &&
        other.link == link &&
        other.backdrop == backdrop &&
        other.surfaceHover == surfaceHover &&
        other.backgroundSecondary == backgroundSecondary &&
        other.backgroundTertiary == backgroundTertiary &&
        other.backgroundInverse == backgroundInverse &&
        other.defaultHover == defaultHover &&
        other.accentHover == accentHover &&
        other.successHover == successHover &&
        other.warningHover == warningHover &&
        other.dangerHover == dangerHover &&
        other.fieldHover == fieldHover &&
        other.fieldFocus == fieldFocus &&
        other.fieldBorderHover == fieldBorderHover &&
        other.fieldBorderFocus == fieldBorderFocus &&
        other.defaultSoft == defaultSoft &&
        other.defaultSoftForeground == defaultSoftForeground &&
        other.defaultSoftHover == defaultSoftHover &&
        other.accentSoft == accentSoft &&
        other.accentSoftForeground == accentSoftForeground &&
        other.accentSoftHover == accentSoftHover &&
        other.dangerSoft == dangerSoft &&
        other.dangerSoftForeground == dangerSoftForeground &&
        other.dangerSoftHover == dangerSoftHover &&
        other.warningSoft == warningSoft &&
        other.warningSoftForeground == warningSoftForeground &&
        other.warningSoftHover == warningSoftHover &&
        other.successSoft == successSoft &&
        other.successSoftForeground == successSoftForeground &&
        other.successSoftHover == successSoftHover &&
        other.separatorSecondary == separatorSecondary &&
        other.separatorTertiary == separatorTertiary &&
        other.borderSecondary == borderSecondary &&
        other.borderTertiary == borderTertiary &&
        other.chart1 == chart1 &&
        other.chart2 == chart2 &&
        other.chart3 == chart3 &&
        other.chart4 == chart4 &&
        other.chart5 == chart5;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
    white,
    black,
    snow,
    eclipse,
    background,
    foreground,
    surface,
    surfaceForeground,
    surfaceSecondary,
    surfaceSecondaryForeground,
    surfaceTertiary,
    surfaceTertiaryForeground,
    overlay,
    overlayForeground,
    muted,
    scrollbar,
    defaultColor,
    defaultForeground,
    fieldBackground,
    fieldForeground,
    fieldPlaceholder,
    fieldBorder,
    accent,
    accentForeground,
    success,
    successForeground,
    warning,
    warningForeground,
    danger,
    dangerForeground,
    segment,
    segmentForeground,
    border,
    separator,
    focus,
    link,
    backdrop,
    surfaceHover,
    backgroundSecondary,
    backgroundTertiary,
    backgroundInverse,
    defaultHover,
    accentHover,
    successHover,
    warningHover,
    dangerHover,
    fieldHover,
    fieldFocus,
    fieldBorderHover,
    fieldBorderFocus,
    defaultSoft,
    defaultSoftForeground,
    defaultSoftHover,
    accentSoft,
    accentSoftForeground,
    accentSoftHover,
    dangerSoft,
    dangerSoftForeground,
    dangerSoftHover,
    warningSoft,
    warningSoftForeground,
    warningSoftHover,
    successSoft,
    successSoftForeground,
    successSoftHover,
    separatorSecondary,
    separatorTertiary,
    borderSecondary,
    borderTertiary,
    chart1,
    chart2,
    chart3,
    chart4,
    chart5,
  ]);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('white', white));
    properties.add(ColorProperty('black', black));
    properties.add(ColorProperty('snow', snow));
    properties.add(ColorProperty('eclipse', eclipse));
    properties.add(ColorProperty('background', background));
    properties.add(ColorProperty('foreground', foreground));
    properties.add(ColorProperty('surface', surface));
    properties.add(ColorProperty('surfaceForeground', surfaceForeground));
    properties.add(ColorProperty('surfaceSecondary', surfaceSecondary));
    properties.add(
      ColorProperty('surfaceSecondaryForeground', surfaceSecondaryForeground),
    );
    properties.add(ColorProperty('surfaceTertiary', surfaceTertiary));
    properties.add(
      ColorProperty('surfaceTertiaryForeground', surfaceTertiaryForeground),
    );
    properties.add(ColorProperty('overlay', overlay));
    properties.add(ColorProperty('overlayForeground', overlayForeground));
    properties.add(ColorProperty('muted', muted));
    properties.add(ColorProperty('scrollbar', scrollbar));
    properties.add(ColorProperty('defaultColor', defaultColor));
    properties.add(ColorProperty('defaultForeground', defaultForeground));
    properties.add(ColorProperty('fieldBackground', fieldBackground));
    properties.add(ColorProperty('fieldForeground', fieldForeground));
    properties.add(ColorProperty('fieldPlaceholder', fieldPlaceholder));
    properties.add(ColorProperty('fieldBorder', fieldBorder));
    properties.add(ColorProperty('accent', accent));
    properties.add(ColorProperty('accentForeground', accentForeground));
    properties.add(ColorProperty('success', success));
    properties.add(ColorProperty('successForeground', successForeground));
    properties.add(ColorProperty('warning', warning));
    properties.add(ColorProperty('warningForeground', warningForeground));
    properties.add(ColorProperty('danger', danger));
    properties.add(ColorProperty('dangerForeground', dangerForeground));
    properties.add(ColorProperty('segment', segment));
    properties.add(ColorProperty('segmentForeground', segmentForeground));
    properties.add(ColorProperty('border', border));
    properties.add(ColorProperty('separator', separator));
    properties.add(ColorProperty('focus', focus));
    properties.add(ColorProperty('link', link));
    properties.add(ColorProperty('backdrop', backdrop));
    properties.add(ColorProperty('surfaceHover', surfaceHover));
    properties.add(ColorProperty('backgroundSecondary', backgroundSecondary));
    properties.add(ColorProperty('backgroundTertiary', backgroundTertiary));
    properties.add(ColorProperty('backgroundInverse', backgroundInverse));
    properties.add(ColorProperty('defaultHover', defaultHover));
    properties.add(ColorProperty('accentHover', accentHover));
    properties.add(ColorProperty('successHover', successHover));
    properties.add(ColorProperty('warningHover', warningHover));
    properties.add(ColorProperty('dangerHover', dangerHover));
    properties.add(ColorProperty('fieldHover', fieldHover));
    properties.add(ColorProperty('fieldFocus', fieldFocus));
    properties.add(ColorProperty('fieldBorderHover', fieldBorderHover));
    properties.add(ColorProperty('fieldBorderFocus', fieldBorderFocus));
    properties.add(ColorProperty('defaultSoft', defaultSoft));
    properties.add(
      ColorProperty('defaultSoftForeground', defaultSoftForeground),
    );
    properties.add(ColorProperty('defaultSoftHover', defaultSoftHover));
    properties.add(ColorProperty('accentSoft', accentSoft));
    properties.add(ColorProperty('accentSoftForeground', accentSoftForeground));
    properties.add(ColorProperty('accentSoftHover', accentSoftHover));
    properties.add(ColorProperty('dangerSoft', dangerSoft));
    properties.add(ColorProperty('dangerSoftForeground', dangerSoftForeground));
    properties.add(ColorProperty('dangerSoftHover', dangerSoftHover));
    properties.add(ColorProperty('warningSoft', warningSoft));
    properties.add(
      ColorProperty('warningSoftForeground', warningSoftForeground),
    );
    properties.add(ColorProperty('warningSoftHover', warningSoftHover));
    properties.add(ColorProperty('successSoft', successSoft));
    properties.add(
      ColorProperty('successSoftForeground', successSoftForeground),
    );
    properties.add(ColorProperty('successSoftHover', successSoftHover));
    properties.add(ColorProperty('separatorSecondary', separatorSecondary));
    properties.add(ColorProperty('separatorTertiary', separatorTertiary));
    properties.add(ColorProperty('borderSecondary', borderSecondary));
    properties.add(ColorProperty('borderTertiary', borderTertiary));
    properties.add(ColorProperty('chart1', chart1));
    properties.add(ColorProperty('chart2', chart2));
    properties.add(ColorProperty('chart3', chart3));
    properties.add(ColorProperty('chart4', chart4));
    properties.add(ColorProperty('chart5', chart5));
  }

  /// Computes the full token set from [source], applying the calculated-color
  /// formulas of HeroUI's `variables.css` for the given [brightness].
  ///
  /// When [vibrantPalette] is true the soft foreground tokens use the more
  /// saturated `[data-vibrant-palette]` formulas.
  factory HeroColors.derive(
    HeroColorSource source, {
    required Brightness brightness,
    bool vibrantPalette = false,
  }) {
    const Color transparent = Color(0x00000000);
    Color mix(Color a, double p1, Color b, [double? p2]) =>
        colorMix(a, b, p1: p1, p2: p2 ?? 1 - p1);
    Color fade(Color a, double p) => colorMix(a, transparent, p1: p, p2: 1 - p);

    final HeroColorSource s = source;
    final bool dark = brightness == Brightness.dark;
    final Color fg = s.foreground;

    Color softForeground(
      Color base,
      double light1,
      double light2,
      double dark1,
      double dark2,
    ) {
      if (vibrantPalette) return mix(base, 0.92, fg, 0.08);
      return dark ? mix(base, dark1, fg, dark2) : mix(base, light1, fg, light2);
    }

    final double softA = dark ? 0.12 : 0.15;
    final double softAHover = dark ? 0.16 : 0.20;

    return HeroColors(
      white: s.white,
      black: s.black,
      snow: s.snow,
      eclipse: s.eclipse,
      background: s.background,
      foreground: fg,
      surface: s.surface,
      surfaceForeground: s.surfaceForeground,
      surfaceSecondary: s.surfaceSecondary,
      surfaceSecondaryForeground: s.surfaceSecondaryForeground,
      surfaceTertiary: s.surfaceTertiary,
      surfaceTertiaryForeground: s.surfaceTertiaryForeground,
      overlay: s.overlay,
      overlayForeground: s.overlayForeground,
      muted: s.muted,
      scrollbar: s.scrollbar,
      defaultColor: s.defaultColor,
      defaultForeground: s.defaultForeground,
      fieldBackground: s.fieldBackground,
      fieldForeground: s.fieldForeground,
      fieldPlaceholder: s.fieldPlaceholder,
      fieldBorder: s.fieldBorder,
      accent: s.accent,
      accentForeground: s.accentForeground,
      success: s.success,
      successForeground: s.successForeground,
      warning: s.warning,
      warningForeground: s.warningForeground,
      danger: s.danger,
      dangerForeground: s.dangerForeground,
      segment: s.segment,
      segmentForeground: s.segmentForeground,
      border: s.border,
      separator: s.separator,
      focus: s.focus,
      link: s.link,
      backdrop: s.backdrop,
      surfaceHover: mix(s.surface, 0.92, s.surfaceForeground, 0.08),
      backgroundSecondary: mix(s.background, 0.96, fg, 0.04),
      backgroundTertiary: mix(s.background, 0.92, fg, 0.08),
      backgroundInverse: fg,
      defaultHover: mix(s.defaultColor, 0.96, s.defaultForeground, 0.04),
      accentHover: mix(s.accent, 0.90, s.accentForeground, 0.10),
      successHover: mix(s.success, 0.90, s.successForeground, 0.10),
      warningHover: mix(s.warning, 0.90, s.warningForeground, 0.10),
      dangerHover: mix(s.danger, 0.90, s.dangerForeground, 0.10),
      fieldHover: mix(s.fieldBackground, 0.90, s.fieldForeground, 0.02),
      fieldFocus: s.fieldBackground,
      fieldBorderHover: mix(s.fieldBorder, 0.88, s.fieldForeground, 0.10),
      fieldBorderFocus: mix(s.fieldBorder, 0.74, s.fieldForeground, 0.22),
      defaultSoft: fade(s.defaultColor, 0.50),
      defaultSoftForeground: s.defaultForeground,
      defaultSoftHover: fade(s.defaultColor, 0.60),
      accentSoft: fade(s.accent, softA),
      accentSoftForeground: softForeground(s.accent, 0.70, 0.30, 0.80, 0.30),
      accentSoftHover: fade(s.accent, softAHover),
      dangerSoft: fade(s.danger, 0.15),
      dangerSoftForeground: softForeground(s.danger, 0.70, 0.40, 0.80, 0.30),
      dangerSoftHover: fade(s.danger, 0.20),
      warningSoft: fade(s.warning, softA),
      warningSoftForeground: softForeground(s.warning, 0.80, 0.70, 0.80, 0.30),
      warningSoftHover: fade(s.warning, softAHover),
      successSoft: fade(s.success, softA),
      successSoftForeground: softForeground(s.success, 0.80, 0.60, 0.80, 0.30),
      successSoftHover: fade(s.success, softAHover),
      separatorSecondary: mix(s.surface, 0.85, s.surfaceForeground, 0.15),
      separatorTertiary: mix(s.surface, 0.81, s.surfaceForeground, 0.19),
      borderSecondary: mix(s.surface, 0.78, s.surfaceForeground, 0.22),
      borderTertiary: mix(s.surface, 0.66, s.surfaceForeground, 0.34),
      chart1: shiftOkLchLightness(s.accent, -0.24),
      chart2: shiftOkLchLightness(s.accent, -0.12),
      chart3: s.accent,
      chart4: shiftOkLchLightness(s.accent, 0.12),
      chart5: shiftOkLchLightness(s.accent, 0.24),
    );
  }

  /// HeroUI default light colors.
  static final HeroColors light = HeroColors.derive(
    HeroColorSource.light,
    brightness: Brightness.light,
  );

  /// HeroUI default dark colors.
  static final HeroColors dark = HeroColors.derive(
    HeroColorSource.dark,
    brightness: Brightness.dark,
  );
}
