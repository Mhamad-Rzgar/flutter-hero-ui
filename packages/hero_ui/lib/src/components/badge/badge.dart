import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';
import '../../foundation/tokens/hero_typography.dart';
import '../../foundation/variants/hero_variants.dart';

/// The visual variants of a [HeroBadge].
enum HeroBadgeVariant {
  /// Solid role fill (the default); the neutral role uses `--default`.
  primary,

  /// `--default` fill with the role's soft foreground.
  secondary,

  /// The role's soft fill and soft foreground.
  soft;

  /// The shared variant this badge variant paints like.
  HeroVariant get heroVariant => switch (this) {
    primary => HeroVariant.primary,
    secondary => HeroVariant.secondary,
    soft => HeroVariant.soft,
  };
}

/// Which corner of a [HeroBadgeAnchor] a badge sits on. Placements are
/// physical, like HeroUI's: they do not flip in right-to-left layouts.
enum HeroBadgePlacement {
  /// Top-right corner (the default).
  topRight,

  /// Top-left corner.
  topLeft,

  /// Bottom-right corner.
  bottomRight,

  /// Bottom-left corner.
  bottomLeft,
}

/// A small count, label or status dot (HeroUI `Badge`), usually placed on
/// the corner of another widget with a [HeroBadgeAnchor]:
///
/// ```dart
/// HeroBadgeAnchor(
///   badge: const HeroBadge(label: '5', color: HeroColor.danger, size: HeroSize.sm),
///   child: HeroAvatar(src: url, name: 'Jane Doe'),
/// )
/// ```
///
/// Without [label] or [child] the badge is a dot. It has a 1 px outline in
/// the page `background` color so it stands out from what it overlaps.
class HeroBadge extends StatelessWidget {
  /// Creates a badge.
  const HeroBadge({
    super.key,
    this.label,
    this.child,
    this.color = HeroColor.standard,
    this.variant = HeroBadgeVariant.primary,
    this.size = HeroSize.md,
    this.placement = HeroBadgePlacement.topRight,
    this.semanticLabel,
    this.minWidth,
    this.style,
  });

  /// Text shown in a [HeroBadgeLabel].
  final String? label;

  /// Custom content, for example an icon or a [HeroBadgeLabel].
  final Widget? child;

  /// Color role.
  final HeroColor color;

  /// Visual variant.
  final HeroBadgeVariant variant;

  /// Size.
  final HeroSize size;

  /// Corner of the [HeroBadgeAnchor] the badge sits on.
  final HeroBadgePlacement placement;

  /// Accessibility label, for example "5 notifications". Dots without one
  /// are decorative.
  final String? semanticLabel;

  /// Overrides the minimum width of [size] (`min-w-*`).
  final double? minWidth;

  /// Extra text style merged on top of the size's style (for example
  /// tabular figures).
  final TextStyle? style;

  /// Returns the fill and foreground of [variant] in [color].
  static HeroVariantStyle styleOf(
    HeroThemeData theme,
    HeroBadgeVariant variant,
    HeroColor color,
  ) => HeroVariants.resolve(theme.colors, variant.heroVariant, color);

  /// The minimum side of a badge of [size] (`min-h-*`), outline included.
  static double minSizeOf(HeroThemeData theme, HeroSize size) => switch (size) {
    HeroSize.sm => theme.spacing(4),
    HeroSize.md => theme.spacing(7),
    HeroSize.lg => theme.spacing(8),
  };

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroVariantStyle colors = styleOf(theme, variant, color);
    final double minSize = minSizeOf(theme, size);
    final double radius = switch (size) {
      HeroSize.sm => theme.radii.xl,
      HeroSize.md => theme.radii.xl3,
      HeroSize.lg => theme.radii.xl2,
    };
    final HeroFontSize font = switch (size) {
      HeroSize.sm => HeroFontSize(theme.spacing(2.5), theme.spacing(2.5)),
      HeroSize.md => HeroFontSize.xs,
      HeroSize.lg => HeroFontSize.sm,
    };
    final double leading = size == HeroSize.lg ? 1.43 : 1.34;
    TextStyle text = theme.typography
        .style(
          font,
          weight: HeroTypography.medium,
          lineHeight: font.fontSize * leading,
        )
        .copyWith(color: colors.foreground);
    if (style != null) text = text.merge(style);
    final double border = theme.borderWidth;

    final Widget? content =
        child ?? (label != null ? HeroBadgeLabel(Text(label!)) : null);
    Widget result = DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.background,
        shape: theme.shapeAll(
          radius,
          side: BorderSide(color: theme.colors.background, width: border),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(border),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: (minWidth ?? minSize) - 2 * border,
            minHeight: minSize - 2 * border,
          ),
          child: content == null
              ? null
              : DefaultTextStyle(
                  style: text,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  child: IconTheme.merge(
                    data: IconThemeData(
                      color: colors.foreground,
                      size: theme.spacing(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: theme.spacing(0.5),
                      children: <Widget>[content],
                    ),
                  ),
                ),
        ),
      ),
    );
    if (semanticLabel != null) {
      result = Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: result,
      );
    } else if (content == null) {
      result = ExcludeSemantics(child: result);
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(EnumProperty<HeroColor>('color', color))
      ..add(EnumProperty<HeroBadgeVariant>('variant', variant))
      ..add(EnumProperty<HeroSize>('size', size))
      ..add(EnumProperty<HeroBadgePlacement>('placement', placement));
  }
}

/// The text of a [HeroBadge] (HeroUI `Badge.Label`), with 2 px horizontal
/// padding.
class HeroBadgeLabel extends StatelessWidget {
  /// Shows [child], usually a [Text].
  const HeroBadgeLabel(this.child, {super.key});

  /// The label content.
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: HeroTheme.of(context).spacing(0.5),
    ),
    child: child,
  );
}

/// Places a [badge] on a corner of [child] (HeroUI `Badge.Anchor`).
///
/// The badge's corner sits on the child's corner, pushed outwards by a
/// quarter of the badge's own size, as set by [HeroBadge.placement]. The
/// child and the badge are read together by assistive technologies.
class HeroBadgeAnchor extends StatelessWidget {
  /// Anchors [badge] to [child].
  const HeroBadgeAnchor({super.key, required this.child, required this.badge});

  /// The widget carrying the badge, for example a [HeroAvatar]-like widget.
  final Widget child;

  /// The badge, usually a [HeroBadge]; other widgets are placed top-right.
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final HeroBadgePlacement placement = badge is HeroBadge
        ? (badge as HeroBadge).placement
        : HeroBadgePlacement.topRight;
    final bool top =
        placement == HeroBadgePlacement.topRight ||
        placement == HeroBadgePlacement.topLeft;
    final bool right =
        placement == HeroBadgePlacement.topRight ||
        placement == HeroBadgePlacement.bottomRight;
    return MergeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          child,
          Positioned(
            top: top ? 0 : null,
            bottom: top ? null : 0,
            right: right ? 0 : null,
            left: right ? null : 0,
            child: FractionalTranslation(
              translation: Offset(right ? 0.25 : -0.25, top ? -0.25 : 0.25),
              child: badge,
            ),
          ),
        ],
      ),
    );
  }
}
