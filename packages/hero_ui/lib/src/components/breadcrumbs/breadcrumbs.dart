import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The state handed to [HeroBreadcrumbsItem.builder] (React Aria's
/// `BreadcrumbRenderProps` plus the link's interaction state).
@immutable
class HeroBreadcrumbState {
  /// Creates a breadcrumb state.
  const HeroBreadcrumbState({
    this.isCurrent = false,
    this.isDisabled = false,
    this.isHovered = false,
    this.isPressed = false,
    this.isFocusVisible = false,
  });

  /// Whether this is the last item, the current page.
  final bool isCurrent;

  /// Whether the breadcrumbs are disabled.
  final bool isDisabled;

  /// Whether a pointer hovers the link.
  final bool isHovered;

  /// Whether the link is pressed.
  final bool isPressed;

  /// Whether the link has keyboard focus.
  final bool isFocusVisible;

  @override
  bool operator ==(Object other) =>
      other is HeroBreadcrumbState &&
      other.isCurrent == isCurrent &&
      other.isDisabled == isDisabled &&
      other.isHovered == isHovered &&
      other.isPressed == isPressed &&
      other.isFocusVisible == isFocusVisible;

  @override
  int get hashCode =>
      Object.hash(isCurrent, isDisabled, isHovered, isPressed, isFocusVisible);
}

/// Builds the content of a [HeroBreadcrumbsItem] for its state.
typedef HeroBreadcrumbWidgetBuilder =
    Widget Function(BuildContext context, HeroBreadcrumbState state);

/// Optional style overrides for a [HeroBreadcrumbsItem].
@immutable
class HeroBreadcrumbsItemStyle {
  /// Creates a style override.
  const HeroBreadcrumbsItemStyle({this.foregroundColor, this.textStyle});

  /// Link color, resolved with the link's [WidgetState]s (`hovered`,
  /// `pressed`, `focused`, `disabled`, and `selected` for the current page).
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Merged into the link's text style.
  final TextStyle? textStyle;
}

class _HeroBreadcrumbsScope extends InheritedWidget {
  const _HeroBreadcrumbsScope({
    required this.separator,
    required this.isDisabled,
    required super.child,
  });

  final Widget? separator;
  final bool isDisabled;

  static _HeroBreadcrumbsScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroBreadcrumbsScope>();

  @override
  bool updateShouldNotify(_HeroBreadcrumbsScope oldWidget) =>
      separator != oldWidget.separator || isDisabled != oldWidget.isDisabled;
}

class _HeroBreadcrumbsItemScope extends InheritedWidget {
  const _HeroBreadcrumbsItemScope({
    required this.isCurrent,
    required super.child,
  });

  final bool isCurrent;

  static bool isCurrentOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_HeroBreadcrumbsItemScope>()
          ?.isCurrent ??
      false;

  @override
  bool updateShouldNotify(_HeroBreadcrumbsItemScope oldWidget) =>
      isCurrent != oldWidget.isCurrent;
}

/// HeroUI's Breadcrumbs: shows where the current page sits in a hierarchy.
///
/// Every child is a [HeroBreadcrumbsItem]; the last one is the current page
/// (React Aria marks the last breadcrumb current). Items are links separated
/// by a 12 px chevron (or [separator]) with 6 px spacing, and wrap onto a
/// new line when they do not fit.
///
/// ```dart
/// HeroBreadcrumbs(
///   children: <Widget>[
///     HeroBreadcrumbsItem(href: '/', onPressed: goHome, child: Text('Home')),
///     const HeroBreadcrumbsItem(child: Text('Laptop')),
///   ],
/// )
/// ```
class HeroBreadcrumbs extends StatelessWidget {
  /// Creates breadcrumbs.
  const HeroBreadcrumbs({
    super.key,
    required this.children,
    this.separator,
    this.isDisabled = false,
    this.semanticLabel = 'Breadcrumbs',
  });

  /// The [HeroBreadcrumbsItem]s.
  final List<Widget> children;

  /// Replaces the chevron between items; it is sized 12 px and colored
  /// `--muted` through the [IconTheme]. Use a directional icon so it mirrors
  /// in right-to-left layouts.
  final Widget? separator;

  /// Disables every link except the current page.
  final bool isDisabled;

  /// Accessibility label of the navigation landmark.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final int count = children.length;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.navigation,
      label: semanticLabel,
      child: _HeroBreadcrumbsScope(
        separator: separator,
        isDisabled: isDisabled,
        child: Wrap(
          spacing: theme.spacing(1.5),
          runSpacing: theme.spacing(1),
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (int i = 0; i < count; i++)
              _HeroBreadcrumbsItemScope(
                isCurrent: i == count - 1,
                child: children[i],
              ),
          ],
        ),
      ),
    );
  }
}

/// HeroUI's `Breadcrumbs.Item`: a link to one level of the hierarchy,
/// followed by the separator unless it is the current page.
///
/// Links are 14 px medium `--muted` text that underlines on hover; the
/// current page uses `--link` (the foreground) and is not interactive.
/// Navigation happens in [onPressed]; [href] is announced to assistive
/// technologies.
class HeroBreadcrumbsItem extends StatelessWidget {
  /// Creates a breadcrumb.
  const HeroBreadcrumbsItem({
    super.key,
    this.child,
    this.builder,
    this.href,
    this.onPressed,
    this.style,
    this.semanticLabel,
  });

  /// The label, usually a [Text].
  final Widget? child;

  /// Builds the label from the breadcrumb state instead of [child].
  final HeroBreadcrumbWidgetBuilder? builder;

  /// The link target, exposed as the semantics link URL.
  final String? href;

  /// Called when the link is pressed.
  final VoidCallback? onPressed;

  /// Style overrides.
  final HeroBreadcrumbsItemStyle? style;

  /// Accessibility label; defaults to the label text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroBreadcrumbsScope? scope = _HeroBreadcrumbsScope.maybeOf(context);
    final bool isCurrent = _HeroBreadcrumbsItemScope.isCurrentOf(context);
    final bool disabled = scope?.isDisabled ?? false;
    final Widget link = _BreadcrumbLink(
      item: this,
      isCurrent: isCurrent,
      isDisabled: disabled,
    );
    if (isCurrent) return link;
    // `size-3 text-muted`: icons are 12 px; text separators use the link
    // text size.
    final Widget separator = ExcludeSemantics(
      child: IconTheme.merge(
        data: IconThemeData(color: theme.colors.muted, size: theme.spacing(3)),
        child: DefaultTextStyle(
          style: theme.typography
              .style(HeroFontSize.sm, weight: HeroTypography.medium)
              .copyWith(color: theme.colors.muted),
          child: scope?.separator ?? const HeroIcon(HeroIcons.chevronRight),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: theme.spacing(1),
      children: <Widget>[link, separator],
    );
  }
}

class _BreadcrumbLink extends StatelessWidget {
  const _BreadcrumbLink({
    required this.item,
    required this.isCurrent,
    required this.isDisabled,
  });

  final HeroBreadcrumbsItem item;
  final bool isCurrent;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final Uri? url = item.href == null ? null : Uri.tryParse(item.href!);
    final OutlinedBorder shape = theme.shapeAll(theme.radii.xl);

    return HeroInteractable(
      onPressed: item.onPressed,
      // The current page is rendered as a disabled link (React Aria).
      isDisabled: isDisabled || isCurrent,
      isSelected: isCurrent,
      // Link semantics (with the URL) are added inside the builder.
      isButton: false,
      semanticsLabel: item.semanticLabel,
      builder: (BuildContext context, HeroInteractionState state, _) {
        final HeroBreadcrumbState breadcrumb = HeroBreadcrumbState(
          isCurrent: isCurrent,
          isDisabled: isDisabled,
          isHovered: state.isHovered,
          isPressed: state.isPressed,
          isFocusVisible: state.isFocusVisible,
        );
        final Set<WidgetState> states = <WidgetState>{
          ...state.widgetStates,
          if (isCurrent) WidgetState.selected,
          if (isCurrent) WidgetState.disabled,
        };
        final Color foreground =
            item.style?.foregroundColor?.resolve(states) ??
            (isCurrent ? colors.link : colors.muted);
        // Hover underlines in `--muted` at 50%, press in `--muted`.
        final Color? underline = isCurrent
            ? null
            : state.isPressed
            ? colors.muted
            : state.isHovered
            ? colors.muted.withValues(alpha: colors.muted.a * 0.5)
            : null;
        final Duration duration = theme.motion.resolve(
          context,
          HeroMotion.fast,
        );

        Widget label =
            item.builder?.call(context, breadcrumb) ??
            item.child ??
            const SizedBox.shrink();
        label = AnimatedDefaultTextStyle(
          duration: duration,
          curve: HeroMotion.smooth,
          style: theme.typography
              .style(
                HeroFontSize.sm,
                weight: HeroTypography.medium,
                lineHeight: theme.spacing(5),
              )
              .copyWith(color: foreground)
              .merge(item.style?.textStyle),
          softWrap: false,
          child: label,
        );
        label = _Underline(
          color: underline,
          thickness: theme.spacing(0.375),
          offset: theme.spacing(1),
          child: label,
        );
        label = HeroFocusRing(
          visible: state.isFocusVisible,
          shape: shape,
          child: label,
        );
        // Disabled links fade; the current page keeps full opacity.
        label = AnimatedOpacity(
          opacity: isDisabled && !isCurrent ? theme.disabledOpacity : 1,
          duration: duration,
          curve: HeroMotion.easeOut,
          child: label,
        );
        return Semantics(link: true, linkUrl: url, child: label);
      },
    );
  }
}

/// Draws a text underline [offset] below the child's alphabetic baseline
/// with the given [thickness] (CSS `text-underline-offset` and
/// `text-decoration-thickness`, which Flutter text styles cannot express).
class _Underline extends SingleChildRenderObjectWidget {
  const _Underline({
    required this.color,
    required this.thickness,
    required this.offset,
    super.child,
  });

  final Color? color;
  final double thickness;
  final double offset;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderUnderline(color: color, thickness: thickness, offset: offset);

  @override
  void updateRenderObject(BuildContext context, _RenderUnderline renderObject) {
    renderObject
      ..color = color
      ..thickness = thickness
      ..offset = offset;
  }
}

class _RenderUnderline extends RenderProxyBox {
  _RenderUnderline({
    required Color? color,
    required double thickness,
    required double offset,
  }) : _color = color,
       _thickness = thickness,
       _offset = offset;

  double? _baseline;

  Color? _color;
  set color(Color? value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  double _thickness;
  set thickness(double value) {
    if (value == _thickness) return;
    _thickness = value;
    markNeedsPaint();
  }

  double _offset;
  set offset(double value) {
    if (value == _offset) return;
    _offset = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    super.performLayout();
    _baseline = child?.getDistanceToBaseline(
      TextBaseline.alphabetic,
      onlyReal: true,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    final Color? color = _color;
    if (color == null || size.isEmpty) return;
    final double top = (_baseline ?? size.height - _offset) + _offset;
    context.canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy + top, size.width, _thickness),
      Paint()..color = color,
    );
  }
}
