import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';
import '../../foundation/tokens/hero_typography.dart';
import '../../foundation/variants/hero_variants.dart';

/// The visual variants of a [HeroChip].
enum HeroChipVariant {
  /// Solid role fill (`--accent` + `--accent-foreground`); the neutral role
  /// uses `--default`.
  primary,

  /// `--default` fill with the role's soft foreground (the default).
  secondary,

  /// No fill, role soft foreground.
  tertiary,

  /// The role's soft fill and soft foreground.
  soft;

  /// The shared variant this chip variant paints like.
  HeroVariant get heroVariant => switch (this) {
    primary => HeroVariant.primary,
    secondary => HeroVariant.secondary,
    tertiary => HeroVariant.tertiary,
    soft => HeroVariant.soft,
  };
}

/// A small informational badge for labels, statuses and categories
/// (HeroUI `Chip`).
///
/// ```dart
/// const HeroChip(label: 'Active', color: HeroColor.success)
///
/// const HeroChip(
///   color: HeroColor.success,
///   startContent: HeroIcon(HeroIcons.check, size: 12),
///   label: 'Available',
/// )
/// ```
///
/// A [label] string is wrapped in a [HeroChipLabel]; [child] takes any
/// widget instead. Icons in [startContent] and [endContent] take the chip's
/// foreground color. Chips are static: use a tag group for interactive
/// tags.
class HeroChip extends StatelessWidget {
  /// Creates a chip.
  const HeroChip({
    super.key,
    this.label,
    this.child,
    this.startContent,
    this.endContent,
    this.color = HeroColor.standard,
    this.variant = HeroChipVariant.secondary,
    this.size = HeroSize.md,
    this.radius,
    this.padding,
  });

  /// The chip text, shown in a [HeroChipLabel].
  final String? label;

  /// Content shown after [label], for example a custom [HeroChipLabel].
  final Widget? child;

  /// Widget before the label, usually an icon.
  final Widget? startContent;

  /// Widget after the label, usually an icon.
  final Widget? endContent;

  /// Color role.
  final HeroColor color;

  /// Visual variant.
  final HeroChipVariant variant;

  /// Size.
  final HeroSize size;

  /// Overrides the corner radius (`rounded-2xl`, 16; `radii.full` makes a
  /// pill).
  final double? radius;

  /// Overrides the padding of [size].
  final EdgeInsetsGeometry? padding;

  /// Returns the fill and foreground of [variant] in [color].
  static HeroVariantStyle styleOf(
    HeroThemeData theme,
    HeroChipVariant variant,
    HeroColor color,
  ) => HeroVariants.resolve(theme.colors, variant.heroVariant, color);

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroVariantStyle style = styleOf(theme, variant, color);
    final EdgeInsetsGeometry resolvedPadding =
        padding ??
        switch (size) {
          HeroSize.sm => EdgeInsets.symmetric(horizontal: theme.spacing(1)),
          HeroSize.md => EdgeInsets.symmetric(
            horizontal: theme.spacing(2),
            vertical: theme.spacing(0.5),
          ),
          HeroSize.lg => EdgeInsets.symmetric(
            horizontal: theme.spacing(3),
            vertical: theme.spacing(1),
          ),
        };
    final TextStyle text = theme.typography
        .style(
          size == HeroSize.lg ? HeroFontSize.sm : HeroFontSize.xs,
          weight: HeroTypography.medium,
          lineHeight: theme.spacing(5),
        )
        .copyWith(color: style.foreground);
    final List<Widget> parts = <Widget>[
      ?startContent,
      if (label != null) Flexible(child: HeroChipLabel(Text(label!))),
      if (child != null) Flexible(child: child!),
      ?endContent,
    ];
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: style.background,
        shape: theme.shapeAll(radius ?? theme.radii.xl2),
      ),
      child: Padding(
        padding: resolvedPadding,
        child: DefaultTextStyle(
          style: text,
          child: IconTheme.merge(
            data: IconThemeData(
              color: style.foreground,
              size: theme.spacing(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: theme.spacing(0.5),
              children: parts,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(EnumProperty<HeroColor>('color', color))
      ..add(EnumProperty<HeroChipVariant>('variant', variant))
      ..add(EnumProperty<HeroSize>('size', size));
  }
}

/// The text of a [HeroChip] (HeroUI `Chip.Label`), with 2 px horizontal
/// padding.
class HeroChipLabel extends StatelessWidget {
  /// Shows [child], usually a [Text].
  const HeroChipLabel(this.child, {super.key});

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
