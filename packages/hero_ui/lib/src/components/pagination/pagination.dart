import 'package:flutter/rendering.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// Returns the pages to show for [page] out of [total] pages, with `null`
/// standing for an ellipsis: the first page, an ellipsis when [page] is
/// past 3, the pages around [page], an ellipsis when [page] is more than two
/// pages from the end, and the last page (the logic of HeroUI's pagination
/// examples).
///
/// ```dart
/// heroPaginationRange(page: 6, total: 12); // [1, null, 5, 6, 7, null, 12]
/// ```
List<int?> heroPaginationRange({required int page, required int total}) {
  if (total <= 0) return const <int?>[];
  if (total == 1) return const <int?>[1];
  final int start = page - 1 < 2 ? 2 : page - 1;
  final int end = page + 1 > total - 1 ? total - 1 : page + 1;
  return <int?>[
    1,
    if (page > 3) null,
    for (int i = start; i <= end; i++) i,
    if (page < total - 2) null,
    total,
  ];
}

/// Optional style overrides for the buttons of a [HeroPagination]
/// ([HeroPaginationLink], [HeroPaginationPrevious], [HeroPaginationNext]).
///
/// Colors are resolved with the button's [WidgetState]s (`hovered`,
/// `pressed`, `focused`, `disabled`, and `selected` for the active page).
@immutable
class HeroPaginationLinkStyle {
  /// Creates a style override.
  const HeroPaginationLinkStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  /// Fill color.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Text and icon color.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Corner radii.
  final BorderRadiusGeometry? borderRadius;
}

class _HeroPaginationScope extends InheritedWidget {
  const _HeroPaginationScope({required this.size, required super.child});

  final HeroSize size;

  static HeroSize sizeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_HeroPaginationScope>()
          ?.size ??
      HeroSize.md;

  @override
  bool updateShouldNotify(_HeroPaginationScope oldWidget) =>
      size != oldWidget.size;
}

class _HeroPaginationContentScope extends InheritedWidget {
  const _HeroPaginationContentScope({required super.child});

  static bool isInside(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_HeroPaginationContentScope>() !=
      null;

  @override
  bool updateShouldNotify(_HeroPaginationContentScope oldWidget) => false;
}

// HeroUI's `sm:` utilities apply from 640 up unless the density is pinned.
bool _isSmUp(BuildContext context, HeroThemeData theme) =>
    switch (theme.density) {
      HeroDensity.touch => false,
      HeroDensity.desktop => true,
      HeroDensity.adaptive =>
        (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= HeroBreakpoints.sm,
    };

HeroFontSize _fontSize(HeroSize size) => switch (size) {
  HeroSize.sm => HeroFontSize.xs,
  HeroSize.md => HeroFontSize.sm,
  HeroSize.lg => HeroFontSize.base,
};

// `size-9 md:size-8` (md), `size-8 md:size-7` (sm), `size-10 md:size-9` (lg).
double _itemSize(BuildContext context, HeroThemeData theme, HeroSize size) {
  final bool desktop = theme.isDesktop(context);
  return theme.spacing(switch (size) {
    HeroSize.sm => desktop ? 7 : 8,
    HeroSize.md => desktop ? 8 : 9,
    HeroSize.lg => desktop ? 9 : 10,
  });
}

/// HeroUI's Pagination: page navigation built from composable parts.
///
/// A [HeroPaginationSummary] (optional) and a [HeroPaginationContent] of
/// [HeroPaginationItem]s holding [HeroPaginationLink]s,
/// [HeroPaginationPrevious], [HeroPaginationNext] and
/// [HeroPaginationEllipsis]. The widget is stateless: keep the current page
/// in your state and mark its link `isActive`.
///
/// Below 640 px the summary sits above the content, both aligned to the
/// start; from 640 px they share a row, spread apart by [mainAxisAlignment].
///
/// ```dart
/// HeroPagination(
///   mainAxisAlignment: MainAxisAlignment.center,
///   children: <Widget>[
///     HeroPaginationContent(
///       children: <Widget>[
///         HeroPaginationItem(
///           child: HeroPaginationLink(
///             isActive: page == 1,
///             onPressed: () => setState(() => page = 1),
///             child: const Text('1'),
///           ),
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
class HeroPagination extends StatelessWidget {
  /// Creates a pagination.
  const HeroPagination({
    super.key,
    required this.children,
    this.size = HeroSize.md,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.semanticLabel = 'pagination',
  });

  /// The summary and the content.
  final List<Widget> children;

  /// Size of the links, the ellipsis and the summary text.
  final HeroSize size;

  /// Distribution of the parts from 640 px up (`justify-between` by
  /// default; the docs examples use `justify-center`).
  final MainAxisAlignment mainAxisAlignment;

  /// Accessibility label of the navigation landmark.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double gap = theme.spacing(4);
    final Widget layout = _isSmUp(context, theme)
        ? Row(
            mainAxisAlignment: mainAxisAlignment,
            spacing: gap,
            children: children,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: gap,
            children: children,
          );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.navigation,
      label: semanticLabel,
      child: _HeroPaginationScope(size: size, child: layout),
    );
  }
}

/// HeroUI's `Pagination.Summary`: muted text describing the current range,
/// such as "Showing 1-10 of 120 results".
class HeroPaginationSummary extends StatelessWidget {
  /// Creates a summary.
  const HeroPaginationSummary({super.key, required this.child});

  /// The summary content, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroSize size = _HeroPaginationScope.sizeOf(context);
    return DefaultTextStyle(
      style: theme.typography
          .style(_fontSize(size))
          .copyWith(color: theme.colors.muted),
      child: IconTheme.merge(
        data: IconThemeData(color: theme.colors.muted),
        child: child,
      ),
    );
  }
}

/// HeroUI's `Pagination.Content`: the row of pagination items, with a
/// 4 px gap.
class HeroPaginationContent extends StatelessWidget {
  /// Creates the content row.
  const HeroPaginationContent({
    super.key,
    required this.children,
    this.decoration,
    this.padding,
  });

  /// The [HeroPaginationItem]s.
  final List<Widget> children;

  /// Optional decoration behind the items (for custom looks).
  final Decoration? decoration;

  /// Optional padding inside [decoration].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    Widget result = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(1),
      children: children,
    );
    if (padding != null) result = Padding(padding: padding!, child: result);
    if (decoration != null) {
      result = DecoratedBox(decoration: decoration!, child: result);
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.list,
      child: _HeroPaginationContentScope(child: result),
    );
  }
}

/// HeroUI's `Pagination.Item`: one entry of the content row (a list item).
class HeroPaginationItem extends StatelessWidget {
  /// Creates an item.
  const HeroPaginationItem({super.key, required this.child});

  /// A link, previous/next button or ellipsis.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!_HeroPaginationContentScope.isInside(context)) return child;
    return Semantics(
      container: true,
      role: SemanticsRole.listItem,
      child: child,
    );
  }
}

/// The shared button of pagination links and previous/next buttons: HeroUI's
/// `.pagination__link`, a ghost button.
class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    required this.isActive,
    required this.isDisabled,
    required this.onPressed,
    required this.isNav,
    required this.style,
    required this.semanticLabel,
    required this.child,
  });

  final bool isActive;
  final bool isDisabled;
  final VoidCallback? onPressed;
  final bool isNav;
  final HeroPaginationLinkStyle? style;
  final String? semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroSize size = _HeroPaginationScope.sizeOf(context);
    final double extent = _itemSize(context, theme, size);
    final double paddingX = isNav
        ? theme.spacing(switch (size) {
            HeroSize.sm => 2,
            HeroSize.md => 2.5,
            HeroSize.lg => 3,
          })
        : 0;
    final double pressedScale = switch (size) {
      HeroSize.sm => 0.98,
      HeroSize.md => 0.97,
      HeroSize.lg => 0.96,
    };
    final HeroVariantStyle palette = HeroVariantStyle(
      background: isActive
          ? colors.defaultColor
          : colors.defaultColor.withValues(alpha: 0),
      backgroundHover: colors.defaultHover,
      foreground: colors.defaultForeground,
    );

    return HeroInteractable(
      onPressed: onPressed,
      isDisabled: isDisabled,
      isSelected: isActive,
      semanticsLabel: semanticLabel,
      builder: (BuildContext context, HeroInteractionState state, _) {
        final Set<WidgetState> states = state.widgetStates;
        final Color background =
            style?.backgroundColor?.resolve(states) ??
            palette.backgroundFor(state);
        final Color foreground =
            style?.foregroundColor?.resolve(states) ?? palette.foreground;
        final OutlinedBorder shape = theme.shape(
          style?.borderRadius ??
              BorderRadius.all(Radius.circular(theme.radii.xl3)),
        );
        Widget content = DefaultTextStyle(
          style: theme.typography
              .style(_fontSize(size), weight: HeroTypography.medium)
              .copyWith(color: foreground),
          softWrap: false,
          maxLines: 1,
          child: IconTheme.merge(
            data: IconThemeData(color: foreground, size: theme.spacing(4)),
            child: child,
          ),
        );
        content = AnimatedContainer(
          duration: theme.motion.resolve(context, HeroMotion.fast),
          curve: HeroMotion.easeOut,
          constraints: BoxConstraints(minWidth: extent, minHeight: extent),
          padding: EdgeInsetsDirectional.symmetric(horizontal: paddingX),
          decoration: ShapeDecoration(color: background, shape: shape),
          child: Center(widthFactor: 1, heightFactor: 1, child: content),
        );
        content = HeroFocusRing(
          visible: state.isFocusVisible,
          shape: shape,
          child: content,
        );
        content = HeroPressScale(
          pressed: state.isPressed,
          scale: pressedScale,
          child: content,
        );
        return HeroDisabledOpacity(disabled: state.isDisabled, child: content);
      },
    );
  }
}

/// HeroUI's `Pagination.Link`: a page number button.
///
/// The active page has a `--default` fill; other pages are transparent and
/// show `--default-hover` on hover and press.
class HeroPaginationLink extends StatelessWidget {
  /// Creates a page link.
  const HeroPaginationLink({
    super.key,
    required this.child,
    this.isActive = false,
    this.isDisabled = false,
    this.onPressed,
    this.style,
    this.semanticLabel,
  });

  /// The page number, usually a [Text].
  final Widget child;

  /// Whether this is the current page (`aria-current="page"`).
  final bool isActive;

  /// Disables the link.
  final bool isDisabled;

  /// Called when the link is pressed.
  final VoidCallback? onPressed;

  /// Style overrides.
  final HeroPaginationLinkStyle? style;

  /// Accessibility label; defaults to the page number text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return _PaginationButton(
      isActive: isActive,
      isDisabled: isDisabled,
      onPressed: onPressed,
      isNav: false,
      style: style,
      semanticLabel: semanticLabel,
      child: child,
    );
  }
}

/// HeroUI's `Pagination.Previous`: the button that goes to the previous
/// page, usually a [HeroPaginationPreviousIcon] and a label.
class HeroPaginationPrevious extends StatelessWidget {
  /// Creates a previous button.
  const HeroPaginationPrevious({
    super.key,
    required this.children,
    this.isDisabled = false,
    this.onPressed,
    this.style,
    this.semanticLabel,
  });

  /// The content, laid out in a row with a 6 px gap.
  final List<Widget> children;

  /// Disables the button (on the first page).
  final bool isDisabled;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Style overrides.
  final HeroPaginationLinkStyle? style;

  /// Accessibility label; defaults to the label text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => _PaginationButton(
    isActive: false,
    isDisabled: isDisabled,
    onPressed: onPressed,
    isNav: true,
    style: style,
    semanticLabel: semanticLabel,
    child: _NavContent(children: children),
  );
}

/// HeroUI's `Pagination.Next`: the button that goes to the next page,
/// usually a label and a [HeroPaginationNextIcon].
class HeroPaginationNext extends StatelessWidget {
  /// Creates a next button.
  const HeroPaginationNext({
    super.key,
    required this.children,
    this.isDisabled = false,
    this.onPressed,
    this.style,
    this.semanticLabel,
  });

  /// The content, laid out in a row with a 6 px gap.
  final List<Widget> children;

  /// Disables the button (on the last page).
  final bool isDisabled;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Style overrides.
  final HeroPaginationLinkStyle? style;

  /// Accessibility label; defaults to the label text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => _PaginationButton(
    isActive: false,
    isDisabled: isDisabled,
    onPressed: onPressed,
    isNav: true,
    style: style,
    semanticLabel: semanticLabel,
    child: _NavContent(children: children),
  );
}

class _NavContent extends StatelessWidget {
  const _NavContent({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: HeroTheme.of(context).spacing(1.5),
    children: children,
  );
}

/// HeroUI's `Pagination.PreviousIcon`: a 16 px chevron pointing to the
/// previous page (mirrored in right-to-left layouts), or a custom [child].
class HeroPaginationPreviousIcon extends StatelessWidget {
  /// Creates the previous icon.
  const HeroPaginationPreviousIcon({super.key, this.child});

  /// Replaces the chevron; directional icons mirror in right-to-left
  /// layouts.
  final Widget? child;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: child ?? const HeroIcon(HeroIcons.chevronLeft));
}

/// HeroUI's `Pagination.NextIcon`: a 16 px chevron pointing to the next
/// page (mirrored in right-to-left layouts), or a custom [child].
class HeroPaginationNextIcon extends StatelessWidget {
  /// Creates the next icon.
  const HeroPaginationNextIcon({super.key, this.child});

  /// Replaces the chevron; directional icons mirror in right-to-left
  /// layouts.
  final Widget? child;

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: child ?? const HeroIcon(HeroIcons.chevronRight));
}

/// HeroUI's `Pagination.Ellipsis`: a muted "…" standing for skipped pages.
/// It is hidden from assistive technologies.
class HeroPaginationEllipsis extends StatelessWidget {
  /// Creates an ellipsis.
  const HeroPaginationEllipsis({super.key});

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroSize size = _HeroPaginationScope.sizeOf(context);
    final double extent = _itemSize(context, theme, size);
    return ExcludeSemantics(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: extent, minHeight: extent),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            '…',
            style: theme.typography
                .style(_fontSize(size))
                .copyWith(color: theme.colors.muted),
          ),
        ),
      ),
    );
  }
}
