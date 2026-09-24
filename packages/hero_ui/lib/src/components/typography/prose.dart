import 'package:flutter/widgets.dart';

import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';
import '../../foundation/tokens/hero_typography.dart';
import '../separator/separator.dart';

/// Inline text styles of authored prose (`.typography-prose strong`, `em`
/// and `a`), resolved for a theme. Obtain them with [HeroProse.stylesOf].
@immutable
class HeroProseStyles {
  /// Creates prose inline styles.
  const HeroProseStyles({
    required this.strong,
    required this.em,
    required this.link,
  });

  /// Resolves the styles for [theme].
  factory HeroProseStyles.of(HeroThemeData theme) => HeroProseStyles(
    strong: TextStyle(
      fontWeight: HeroTypography.semibold,
      color: theme.colors.foreground,
    ),
    em: const TextStyle(fontStyle: FontStyle.italic),
    link: TextStyle(
      fontWeight: HeroTypography.medium,
      color: theme.colors.link,
      decoration: TextDecoration.underline,
      decorationColor: theme.colors.link,
    ),
  );

  /// `strong`: `font-semibold text-foreground`.
  final TextStyle strong;

  /// `em`: italic.
  final TextStyle em;

  /// `a`: `font-medium text-link underline`.
  final TextStyle link;
}

/// Styles authored content with HeroUI's prose rhythm (HeroUI
/// `Typography.Prose`).
///
/// React styles raw HTML children; in Flutter the prose elements are
/// widgets: [HeroHeading] (`h1`–`h6`), [HeroParagraph] (`p`),
/// [HeroCode.span] (`code`), [HeroProseBlockquote], [HeroProseList]
/// (`ul`/`ol`), [HeroProseDivider] (`hr`), [HeroProsePre] and
/// [HeroProseImage]. Inline `strong`, `em` and `a` styles come from
/// [HeroProse.stylesOf]. Plain [Text] children get the prose body style
/// (`text-base leading-7`, `--foreground`).
class HeroProse extends StatelessWidget {
  /// Lays out [children] vertically, [spacing] apart.
  const HeroProse({super.key, required this.children, this.spacing = 0});

  /// The prose elements.
  final List<Widget> children;

  /// Gap between elements (the docs demo uses `gap-3`, 12).
  final double spacing;

  /// Returns the inline prose styles for the theme of [context].
  static HeroProseStyles stylesOf(BuildContext context) =>
      HeroProseStyles.of(HeroTheme.of(context));

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return DefaultTextStyle(
      style: theme.typography.body.copyWith(color: theme.colors.foreground),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: spacing,
        children: children,
      ),
    );
  }
}

/// A prose block quote: `mt-4 border-s-4 border-border ps-4 text-muted
/// italic`.
class HeroProseBlockquote extends StatelessWidget {
  /// Quotes [child]; plain [Text] inside becomes muted and italic.
  const HeroProseBlockquote({super.key, required this.child});

  /// The quoted content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: theme.spacing(4)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(
            start: BorderSide(
              color: theme.colors.border,
              width: theme.spacing(1),
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: theme.spacing(1) + theme.spacing(4),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: theme.colors.muted,
              fontStyle: FontStyle.italic,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A prose list: `my-4 space-y-2 ps-6` with `list-disc` or
/// `list-decimal` markers; each item is `text-base leading-7`.
class HeroProseList extends StatelessWidget {
  /// Creates a list of [children] items.
  const HeroProseList({
    super.key,
    required this.children,
    this.ordered = false,
  });

  /// The list items; plain [Text] items get the prose body style.
  final List<Widget> children;

  /// Numbered (`ol`) instead of bulleted (`ul`).
  final bool ordered;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle item = theme.typography.body.copyWith(
      color: theme.colors.foreground,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing(4)),
      child: DefaultTextStyle.merge(
        style: item,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(2),
          children: <Widget>[
            for (final (int index, Widget child) in children.indexed)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  SizedBox(
                    width: theme.spacing(6),
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: theme.spacing(1.5),
                      ),
                      child: Text(
                        ordered ? '${index + 1}.' : '\u2022',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// A prose horizontal rule: a [HeroSeparator] with `my-8`.
class HeroProseDivider extends StatelessWidget {
  /// Creates a divider.
  const HeroProseDivider({super.key});

  @override
  Widget build(BuildContext context) => HeroSeparator(
    margin: EdgeInsets.symmetric(vertical: HeroTheme.of(context).spacing(8)),
  );
}

/// A prose code block (`pre`): `my-4 rounded-xl bg-default p-4 font-mono
/// text-sm leading-relaxed`, scrolling horizontally when too wide.
class HeroProsePre extends StatelessWidget {
  /// Shows [code] as a block.
  const HeroProsePre(this.code, {super.key});

  /// The preformatted code.
  final String code;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final OutlinedBorder shape = theme.shapeAll(theme.radii.xl);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing(4)),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: theme.colors.defaultColor,
          shape: shape,
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: shape,
            textDirection: Directionality.maybeOf(context),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(theme.spacing(4)),
            child: Text(
              code,
              softWrap: false,
              style: theme.typography
                  .style(
                    HeroFontSize.sm,
                    mono: true,
                    lineHeight: HeroFontSize.sm.fontSize * 1.625,
                  )
                  .copyWith(color: theme.colors.foreground),
            ),
          ),
        ),
      ),
    );
  }
}

/// A prose image: `my-4 rounded-xl`.
class HeroProseImage extends StatelessWidget {
  /// Clips [child] (usually an [Image]) to the prose image radius.
  const HeroProseImage({super.key, required this.child});

  /// The image.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing(4)),
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: theme.shapeAll(theme.radii.xl),
          textDirection: Directionality.maybeOf(context),
        ),
        child: child,
      ),
    );
  }
}
