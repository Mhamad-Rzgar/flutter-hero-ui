/// HeroUI's `Surface`: a container with surface-level styling that tells its
/// children which surface they sit on.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The variant of a [HeroSurface] (HeroUI `transparent | default |
/// secondary | tertiary`).
enum HeroSurfaceVariant {
  /// No background; text in `--foreground`.
  transparent,

  /// `--surface` with `--surface-foreground` text (HeroUI `default`).
  standard,

  /// `--surface-secondary` with `--surface-secondary-foreground` text.
  secondary,

  /// `--surface-tertiary` with `--surface-tertiary-foreground` text.
  tertiary;

  /// The background of this variant, or null for [transparent].
  Color? background(HeroColors colors) => switch (this) {
    HeroSurfaceVariant.transparent => null,
    HeroSurfaceVariant.standard => colors.surface,
    HeroSurfaceVariant.secondary => colors.surfaceSecondary,
    HeroSurfaceVariant.tertiary => colors.surfaceTertiary,
  };

  /// The text color of this variant.
  Color foreground(HeroColors colors) => switch (this) {
    HeroSurfaceVariant.transparent => colors.foreground,
    HeroSurfaceVariant.standard => colors.surfaceForeground,
    HeroSurfaceVariant.secondary => colors.surfaceSecondaryForeground,
    HeroSurfaceVariant.tertiary => colors.surfaceTertiaryForeground,
  };
}

/// Tells descendants which surface they are drawn on (HeroUI's
/// `SurfaceContext`), so they can pick "on-surface" colors.
///
/// Provided by [HeroSurface] and by other surface-like containers (cards,
/// alerts, popovers, modals, drawers, ...).
class HeroSurfaceScope extends InheritedWidget {
  /// Publishes [variant] to [child].
  const HeroSurfaceScope({
    super.key,
    required this.variant,
    required super.child,
  });

  /// The surface variant the descendants sit on.
  final HeroSurfaceVariant variant;

  /// The closest surface scope, or null when not on a surface.
  static HeroSurfaceScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroSurfaceScope>();

  /// The variant of the closest surface, or null when not on a surface.
  static HeroSurfaceVariant? variantOf(BuildContext context) =>
      maybeOf(context)?.variant;

  @override
  bool updateShouldNotify(HeroSurfaceScope oldWidget) =>
      variant != oldWidget.variant;
}

/// A container with surface-level styling (HeroUI `Surface`).
///
/// It paints the background of its [variant], sets the default text and icon
/// color to the surface foreground, and publishes a [HeroSurfaceScope] so
/// descendants know which surface they sit on. Like HeroUI it has no radius,
/// padding or shadow by default; pass them as parameters (the counterpart of
/// `className`).
///
/// Use the secondary variant of form fields on surfaces:
///
/// ```dart
/// HeroSurface(
///   borderRadius: BorderRadius.circular(theme.radii.xl3),
///   padding: EdgeInsets.all(theme.spacing(6)),
///   child: const HeroInput(variant: HeroFieldVariant.secondary),
/// )
/// ```
class HeroSurface extends StatelessWidget {
  /// Creates a surface around [child].
  const HeroSurface({
    super.key,
    required this.child,
    this.variant = HeroSurfaceVariant.standard,
    this.padding,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
    this.constraints,
    this.color,
    this.gradient,
    this.shadow,
    this.alignment,
    this.clipBehavior = Clip.none,
  });

  /// The surface content.
  final Widget child;

  /// The surface variant.
  final HeroSurfaceVariant variant;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Corner radius (drawn with the theme's corner style).
  final BorderRadiusGeometry? borderRadius;

  /// Border drawn inside the surface, like a CSS border.
  final BorderSide? border;

  /// Fixed width.
  final double? width;

  /// Fixed height.
  final double? height;

  /// Extra size constraints (for example a minimum width).
  final BoxConstraints? constraints;

  /// Background override; defaults to the variant background.
  final Color? color;

  /// Background gradient, painted over the background color.
  final Gradient? gradient;

  /// Shadow of the surface.
  final HeroShadow? shadow;

  /// Aligns [child] within the surface.
  final AlignmentGeometry? alignment;

  /// How to clip [child] to the surface shape.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Color foreground = variant.foreground(theme.colors);
    final OutlinedBorder shape = theme.shape(
      borderRadius ?? BorderRadius.zero,
      side: border ?? BorderSide.none,
    );
    final HeroShadow? shadow = this.shadow;

    Widget result = DefaultTextStyle.merge(
      style: TextStyle(color: foreground),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: child,
      ),
    );
    if (alignment != null) {
      result = Align(alignment: alignment!, child: result);
    }
    // Like a CSS border, the border takes room inside the surface.
    final EdgeInsetsGeometry inset = (padding ?? EdgeInsets.zero).add(
      shape.dimensions,
    );
    if (inset != EdgeInsets.zero) {
      result = Padding(padding: inset, child: result);
    }
    final Color? background = color ?? variant.background(theme.colors);
    final Gradient? gradient = this.gradient;
    if (gradient == null) {
      result = DecoratedBox(
        decoration: ShapeDecoration(
          color: background,
          shape: shape,
          shadows: shadow?.boxShadows,
        ),
        child: result,
      );
    } else {
      // Like CSS, the gradient (background-image) is painted over the
      // variant background (background-color), and the border over both.
      result = DecoratedBox(
        decoration: ShapeDecoration(
          color: background,
          shape: shape.copyWith(side: BorderSide.none),
          shadows: shadow?.boxShadows,
        ),
        child: DecoratedBox(
          decoration: ShapeDecoration(gradient: gradient, shape: shape),
          child: result,
        ),
      );
    }
    if (clipBehavior != Clip.none) {
      result = ClipPath(
        clipper: ShapeBorderClipper(
          shape: shape,
          textDirection: Directionality.maybeOf(context),
        ),
        clipBehavior: clipBehavior,
        child: result,
      );
    }
    if (width != null || height != null || constraints != null) {
      result = ConstrainedBox(
        constraints: (constraints ?? const BoxConstraints()).tighten(
          width: width,
          height: height,
        ),
        child: result,
      );
    }
    return HeroSurfaceScope(variant: variant, child: result);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HeroSurfaceVariant>('variant', variant));
  }
}
