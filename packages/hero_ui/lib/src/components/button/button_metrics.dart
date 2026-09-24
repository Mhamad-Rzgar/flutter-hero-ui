import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The geometry of a HeroUI button of a given [HeroSize], resolved for the
/// current viewport (`button.css`).
///
/// | Size | Height (touch / `md:`) | Padding | Icon (`<sm` / `sm:`) | Text | Pressed |
/// | --- | --- | --- | --- | --- | --- |
/// | `sm` | 36 / 32 | 12 | 16 / 16 | `text-sm` | 0.98 |
/// | `md` | 40 / 36 | 16 | 20 / 16 | `text-sm` | 0.97 |
/// | `lg` | 44 / 40 | 16 | 20 / 16 | `text-base` | 0.96 |
///
/// Icon-only buttons are square ([height] wide). Components that share the
/// button geometry (toggle buttons, custom buttons) resolve it here.
@immutable
class HeroButtonMetrics {
  /// Creates button metrics.
  const HeroButtonMetrics({
    required this.height,
    required this.horizontalPadding,
    required this.gap,
    required this.iconSize,
    required this.iconInset,
    required this.radius,
    required this.textStyle,
    required this.pressedScale,
  });

  /// Resolves the metrics of [size] for [context].
  ///
  /// Heights follow [HeroThemeData.isDesktop] (`md:` utilities) and icon
  /// sizes the `sm` breakpoint (640), both pinned by
  /// [HeroThemeData.density] when it is not adaptive.
  factory HeroButtonMetrics.of(BuildContext context, HeroSize size) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool desktop = theme.isDesktop(context);
    final bool smUp = switch (theme.density) {
      HeroDensity.touch => false,
      HeroDensity.desktop => true,
      HeroDensity.adaptive =>
        (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= HeroBreakpoints.sm,
    };
    return HeroButtonMetrics(
      height: switch (size) {
        HeroSize.sm => theme.spacing(desktop ? 8 : 9),
        HeroSize.md => theme.spacing(desktop ? 9 : 10),
        HeroSize.lg => theme.spacing(desktop ? 10 : 11),
      },
      horizontalPadding: theme.spacing(size == HeroSize.sm ? 3 : 4),
      gap: theme.spacing(2),
      iconSize: theme.spacing(size == HeroSize.sm || smUp ? 4 : 5),
      iconInset: theme.spacing(0.5),
      radius: theme.radii.xl3,
      textStyle: theme.typography.style(
        size == HeroSize.lg ? HeroFontSize.base : HeroFontSize.sm,
        weight: HeroTypography.medium,
      ),
      pressedScale: switch (size) {
        HeroSize.sm => 0.98,
        HeroSize.md => 0.97,
        HeroSize.lg => 0.96,
      },
    );
  }

  /// Minimum height (`h-*`), also the width of icon-only buttons.
  final double height;

  /// Horizontal padding (`px-*`).
  final double horizontalPadding;

  /// Space between icon and label (`gap-2`).
  final double gap;

  /// Size of slot icons (`size-5` / `sm:size-4`).
  final double iconSize;

  /// Negative horizontal margin of slot icons (`-mx-0.5`).
  final double iconInset;

  /// Corner radius (`rounded-3xl`).
  final double radius;

  /// Label text style without color (`text-sm font-medium`).
  final TextStyle textStyle;

  /// Scale while pressed (`active:scale-*`).
  final double pressedScale;

  @override
  bool operator ==(Object other) =>
      other is HeroButtonMetrics &&
      other.height == height &&
      other.horizontalPadding == horizontalPadding &&
      other.gap == gap &&
      other.iconSize == iconSize &&
      other.iconInset == iconInset &&
      other.radius == radius &&
      other.textStyle == textStyle &&
      other.pressedScale == pressedScale;

  @override
  int get hashCode => Object.hash(
    height,
    horizontalPadding,
    gap,
    iconSize,
    iconInset,
    radius,
    textStyle,
    pressedScale,
  );
}
