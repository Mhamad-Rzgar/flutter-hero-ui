/// HeroUI's Card: a flexible container for grouping related content and
/// actions.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../link/link.dart';
import '../surface/surface.dart';

/// The prominence of a [HeroCard] (HeroUI `transparent | default |
/// secondary | tertiary`).
enum HeroCardVariant {
  /// No background, border or shadow; for nested cards and list rows.
  transparent,

  /// `--surface` with the surface shadow (HeroUI `default`).
  standard,

  /// `--surface-secondary` with the surface shadow.
  secondary,

  /// `--surface-tertiary` with the surface shadow.
  tertiary;

  /// The surface this variant publishes to its descendants, or null for
  /// [transparent] (which leaves the enclosing surface in place).
  HeroSurfaceVariant? get surfaceVariant => switch (this) {
    transparent => null,
    standard => HeroSurfaceVariant.standard,
    secondary => HeroSurfaceVariant.secondary,
    tertiary => HeroSurfaceVariant.tertiary,
  };

  /// The background of this variant, or null for [transparent].
  Color? background(HeroColors colors) => surfaceVariant?.background(colors);
}

/// Overrides for the container of a [HeroCard], the counterpart of the
/// Tailwind classes HeroUI's customization example puts on `Card`.
///
/// Every field is optional; `null` keeps HeroUI's value.
@immutable
class HeroCardStyle with Diagnosticable {
  /// Creates card style overrides.
  const HeroCardStyle({
    this.color,
    this.gradient,
    this.border,
    this.borderRadius,
    this.shadows,
  });

  /// Background color (`bg-*`); defaults to the variant background.
  final Color? color;

  /// Background gradient painted over [color] (`bg-linear-*`).
  final Gradient? gradient;

  /// Border drawn inside the card (`border-*`).
  final BorderSide? border;

  /// Corner radii (`rounded-*`); defaults to `min(32px, --radius-3xl)`.
  final BorderRadiusGeometry? borderRadius;

  /// Drop shadows (`shadow-*`); defaults to `--surface-shadow`, none for
  /// the transparent variant.
  final List<BoxShadow>? shadows;

  @override
  bool operator ==(Object other) =>
      other is HeroCardStyle &&
      other.color == color &&
      other.gradient == gradient &&
      other.border == border &&
      other.borderRadius == borderRadius &&
      listEquals(other.shadows, shadows);

  @override
  int get hashCode => Object.hash(
    color,
    gradient,
    border,
    borderRadius,
    shadows == null ? null : Object.hashAll(shadows!),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(
        DiagnosticsProperty<Gradient>('gradient', gradient, defaultValue: null),
      )
      ..add(
        DiagnosticsProperty<BorderSide>('border', border, defaultValue: null),
      )
      ..add(
        DiagnosticsProperty<BorderRadiusGeometry>(
          'borderRadius',
          borderRadius,
          defaultValue: null,
        ),
      );
  }
}

/// A flexible container for grouping related content and actions (HeroUI
/// `Card`).
///
/// ```dart
/// HeroCard(
///   width: 400,
///   children: <Widget>[
///     HeroIcon(HeroIcons.circleDollar, size: 24, color: theme.colors.accent),
///     const HeroCardHeader(
///       children: <Widget>[
///         HeroCardTitle.text('Become an Acme Creator!'),
///         HeroCardDescription.text('Visit the Acme Creator Hub to sign up.'),
///       ],
///     ),
///     HeroCardFooter(
///       children: <Widget>[
///         HeroLink(
///           href: Uri.parse('https://heroui.com'),
///           children: const <Widget>[Text('Creator Hub'), HeroLinkIcon()],
///         ),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// The card is a column with a 12 px gap and 16 px padding, a
/// `min(32px, --radius-3xl)` radius (24 with the default radius) and the
/// surface shadow (none in dark mode).
///
/// * [variant]: `standard` (`--surface`, HeroUI's `default`), `secondary`
///   (`--surface-secondary`), `tertiary` (`--surface-tertiary`) or
///   `transparent` (no background, border or shadow). Non-transparent
///   cards publish a [HeroSurfaceScope] so descendants know which surface
///   they sit on, like HeroUI's `SurfaceContext`.
/// * [title], [description], [content] and [footer] build the usual
///   header / content / footer layout; pass [children] instead to compose
///   [HeroCardHeader], [HeroCardContent], [HeroCardFooter] and any other
///   widget yourself.
/// * Like a block element the card fills the width it is given; where the
///   width is unbounded (in a [Row]) it takes the width of its content.
///   Header, content and footer parts fill the card's width.
/// * [direction] lays the children out in a row (`flex-row`); a stretched
///   [crossAxisAlignment] then gives every child the height of the tallest
///   one, like CSS `items-stretch`.
/// * [background] fills the card behind its content and is clipped to its
///   shape (an absolutely positioned image in HeroUI's examples);
///   [overlays] are stacked over the content, usually as
///   [PositionedDirectional] widgets such as a close button at the top
///   end.
/// * [onPressed] or [href] make the whole card interactive (HeroUI's
///   "interactive cards" pattern): it gets link semantics when it has an
///   [href] and button semantics otherwise, shows the focus ring for
///   keyboard focus and scales to 0.97 while pressed.
class HeroCard extends StatelessWidget {
  /// Creates a card.
  const HeroCard({
    super.key,
    this.children,
    this.title,
    this.description,
    this.content,
    this.footer,
    this.variant = HeroCardVariant.standard,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.gap,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.background,
    this.overlays = const <Widget>[],
    this.clipBehavior = Clip.none,
    this.style,
    this.onPressed,
    this.href,
    this.target = HeroLinkTarget.self,
    this.isDisabled = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// The card's content: usually a [HeroCardHeader], a [HeroCardContent]
  /// and a [HeroCardFooter], plus images or icons. Replaces [title],
  /// [description], [content] and [footer].
  final List<Widget>? children;

  /// The title of the default layout (a [HeroCardTitle]'s content).
  final Widget? title;

  /// The description of the default layout (a [HeroCardDescription]'s
  /// content).
  final Widget? description;

  /// The main content of the default layout, placed in a
  /// [HeroCardContent].
  final Widget? content;

  /// The footer content of the default layout, placed in a
  /// [HeroCardFooter].
  final Widget? footer;

  /// The prominence of the card.
  final HeroCardVariant variant;

  /// Whether the children are laid out in a column (default) or a row
  /// (`flex-row`).
  final Axis direction;

  /// How the children are placed along [direction] (`justify-*`); with a
  /// minimum height, [MainAxisAlignment.spaceBetween] pushes the last child
  /// to the bottom like `mt-auto`.
  final MainAxisAlignment mainAxisAlignment;

  /// How the children are placed across [direction] (`items-*`).
  final CrossAxisAlignment crossAxisAlignment;

  /// Space between the children; defaults to 12 (`gap-3`).
  final double? gap;

  /// Inner padding; defaults to 16 (`p-4`).
  final EdgeInsetsGeometry? padding;

  /// Fixed width (`w-*`).
  final double? width;

  /// Fixed height (`h-*`).
  final double? height;

  /// Extra size constraints (`min-h-*`, `max-w-*`).
  final BoxConstraints? constraints;

  /// A layer filling the card behind its content, clipped to the card's
  /// shape (for example a cover image).
  final Widget? background;

  /// Widgets stacked over the content (children of a [Stack] the size of
  /// the card), usually [PositionedDirectional] widgets.
  final List<Widget> overlays;

  /// How to clip the content to the card's shape (`overflow-hidden`). The
  /// [background] is always clipped.
  final Clip clipBehavior;

  /// Container overrides.
  final HeroCardStyle? style;

  /// Makes the card interactive and is called when it is activated.
  final VoidCallback? onPressed;

  /// Makes the card a link to this destination, handed to the nearest
  /// [HeroLinkHandler] when activated.
  final Uri? href;

  /// Where [href] should open.
  final HeroLinkTarget target;

  /// Disables an interactive card and fades it.
  final bool isDisabled;

  /// An optional focus node for an interactive card.
  final FocusNode? focusNode;

  /// Whether an interactive card requests focus when first built.
  final bool autofocus;

  /// Accessibility label of the card (`aria-label`).
  final String? semanticLabel;

  /// Whether the card reacts to presses.
  bool get isInteractive => onPressed != null || href != null;

  /// Returns HeroUI's default corner radius of a card,
  /// `min(32px, --radius-3xl)`.
  static double radiusOf(HeroThemeData theme) =>
      math.min(theme.spacing(8), theme.radii.xl3);

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroCardStyle? style = this.style;
    final HeroSurfaceVariant? surface = variant.surfaceVariant;
    final List<Widget> parts =
        children ??
        <Widget>[
          if (title != null || description != null)
            HeroCardHeader(
              children: <Widget>[
                if (title case final Widget title) HeroCardTitle(child: title),
                if (description case final Widget description)
                  HeroCardDescription(child: description),
              ],
            ),
          if (content case final Widget content)
            HeroCardContent(children: <Widget>[content]),
          if (footer case final Widget footer)
            HeroCardFooter(children: <Widget>[footer]),
        ];

    Widget body = Flex(
      direction: direction,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: gap ?? theme.spacing(3),
      children: parts,
    );
    if (direction == Axis.horizontal &&
        crossAxisAlignment == CrossAxisAlignment.stretch) {
      // CSS stretches the items of a row to its tallest item.
      body = IntrinsicHeight(child: body);
    }
    body = Padding(
      padding: padding ?? EdgeInsets.all(theme.spacing(4)),
      child: body,
    );

    final OutlinedBorder shape = theme.shape(
      style?.borderRadius ?? BorderRadius.circular(radiusOf(theme)),
      side: style?.border ?? BorderSide.none,
    );
    final Widget? background = this.background;
    if (background != null || overlays.isNotEmpty) {
      body = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          if (background != null)
            Positioned.fill(
              child: ClipPath(
                clipper: ShapeBorderClipper(
                  shape: shape.copyWith(side: BorderSide.none),
                  textDirection: Directionality.maybeOf(context),
                ),
                child: background,
              ),
            ),
          body,
          ...overlays,
        ],
      );
    }
    if (surface != null) {
      final Color foreground = surface.foreground(theme.colors);
      body = DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: body,
        ),
      );
    }
    // Like a CSS border, the border takes room inside the card.
    if (shape.dimensions != EdgeInsets.zero) {
      body = Padding(padding: shape.dimensions, child: body);
    }
    if (clipBehavior != Clip.none) {
      // Clips the content but not the card's own shadow, like
      // `overflow: hidden`.
      body = ClipPath(
        clipper: ShapeBorderClipper(
          shape: shape,
          textDirection: Directionality.maybeOf(context),
        ),
        clipBehavior: clipBehavior,
        child: body,
      );
    }

    final List<BoxShadow>? shadows =
        style?.shadows ??
        (surface == null ? null : theme.shadows.surface.boxShadows);
    final Color? color = style?.color ?? variant.background(theme.colors);
    final Gradient? gradient = style?.gradient;
    body = DecoratedBox(
      decoration: ShapeDecoration(
        color: color,
        shape: gradient == null ? shape : shape.copyWith(side: BorderSide.none),
        shadows: shadows == null || shadows.isEmpty ? null : shadows,
      ),
      child: gradient == null
          ? body
          // Like CSS, the gradient (background-image) is painted over the
          // background color, and the border over both.
          : DecoratedBox(
              decoration: ShapeDecoration(gradient: gradient, shape: shape),
              child: body,
            ),
    );
    body = _HeroCardBlock(child: body);
    if (width != null || height != null || constraints != null) {
      body = ConstrainedBox(
        constraints: (constraints ?? const BoxConstraints()).tighten(
          width: width,
          height: height,
        ),
        child: body,
      );
    }
    if (surface != null) {
      body = HeroSurfaceScope(variant: surface, child: body);
    }

    if (!isInteractive) {
      return Semantics(
        container: true,
        explicitChildNodes: true,
        label: semanticLabel,
        child: body,
      );
    }
    return HeroInteractable(
      onPressed: _handlePressed(context),
      isDisabled: isDisabled,
      focusNode: focusNode,
      autofocus: autofocus,
      isLink: href != null,
      linkUrl: href,
      shortcuts: href != null ? _linkShortcuts : null,
      semanticsLabel: semanticLabel,
      child: body,
      builder:
          (BuildContext context, HeroInteractionState state, Widget? child) {
            return HeroPressScale(
              pressed: state.isPressed,
              child: HeroFocusRing(
                visible: state.isFocusVisible,
                shape: shape,
                child: HeroDisabledOpacity(disabled: isDisabled, child: child!),
              ),
            );
          },
    );
  }

  // Link cards activate with Enter only, like a native anchor.
  static const Map<ShortcutActivator, Intent> _linkShortcuts =
      <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space):
            DoNothingAndStopPropagationIntent(),
      };

  VoidCallback _handlePressed(BuildContext context) => () {
    onPressed?.call();
    final Uri? href = this.href;
    if (href != null && context.mounted) {
      HeroLinkHandler.maybeOf(context)?.onOpen(href, target);
    }
  };

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<HeroCardVariant>(
          'variant',
          variant,
          defaultValue: HeroCardVariant.standard,
        ),
      )
      ..add(
        EnumProperty<Axis>('direction', direction, defaultValue: Axis.vertical),
      )
      ..add(DoubleProperty('width', width, defaultValue: null))
      ..add(DoubleProperty('height', height, defaultValue: null))
      ..add(DiagnosticsProperty<Uri>('href', href, defaultValue: null))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
  }
}

/// The header of a [HeroCard] (HeroUI `Card.Header`): a column, usually a
/// [HeroCardTitle] above a [HeroCardDescription].
///
/// It fills the width of the card (in a row it takes the width of its
/// content).
class HeroCardHeader extends StatelessWidget {
  /// Creates a card header.
  const HeroCardHeader({
    super.key,
    required this.children,
    this.gap = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// The header content, top to bottom.
  final List<Widget> children;

  /// Space between the children (none by default; `gap-1` is 4).
  final double gap;

  /// How the children are aligned horizontally.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return _HeroCardBlock(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        spacing: gap,
        children: children,
      ),
    );
  }
}

/// The title of a [HeroCard] (HeroUI `Card.Title`): `text-sm leading-6
/// font-medium` in `--foreground`, announced as a level-3 heading.
class HeroCardTitle extends StatelessWidget {
  /// Creates a title for [child].
  const HeroCardTitle({super.key, required Widget this.child, this.style})
    : data = null;

  /// Creates a title showing [data].
  const HeroCardTitle.text(String this.data, {super.key, this.style})
    : child = null;

  /// The title content (text widgets inherit the title style).
  final Widget? child;

  /// The title text, for [HeroCardTitle.text].
  final String? data;

  /// Style merged over the title style.
  final TextStyle? style;

  /// Returns the title style of [theme].
  static TextStyle styleOf(HeroThemeData theme) => theme.typography
      .style(
        HeroFontSize.sm,
        weight: HeroTypography.medium,
        lineHeight: theme.spacing(6),
      )
      .copyWith(color: theme.colors.foreground);

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = styleOf(
      HeroTheme.of(context),
    ).merge(style?.copyWith(inherit: true));
    final String? data = this.data;
    return Semantics(
      header: true,
      headingLevel: 3,
      child: data != null
          ? Text(data, style: textStyle)
          : DefaultTextStyle.merge(style: textStyle, child: child!),
    );
  }
}

/// The description of a [HeroCard] (HeroUI `Card.Description`):
/// `text-sm leading-5` in `--muted`.
class HeroCardDescription extends StatelessWidget {
  /// Creates a description for [child].
  const HeroCardDescription({super.key, required Widget this.child, this.style})
    : data = null;

  /// Creates a description showing [data].
  const HeroCardDescription.text(String this.data, {super.key, this.style})
    : child = null;

  /// The description content (text widgets inherit the style).
  final Widget? child;

  /// The description text, for [HeroCardDescription.text].
  final String? data;

  /// Style merged over the description style.
  final TextStyle? style;

  /// Returns the description style of [theme].
  static TextStyle styleOf(HeroThemeData theme) =>
      theme.typography.sm.copyWith(color: theme.colors.muted);

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = styleOf(
      HeroTheme.of(context),
    ).merge(style?.copyWith(inherit: true));
    final String? data = this.data;
    return data != null
        ? Text(data, style: textStyle)
        : DefaultTextStyle.merge(style: textStyle, child: child!);
  }
}

/// The main content of a [HeroCard] (HeroUI `Card.Content`): a column with
/// a 4 px gap that fills the width of the card.
///
/// HeroUI's content grows into free height (`flex-1`); in a card with a
/// fixed height wrap it in an [Expanded] to do the same.
class HeroCardContent extends StatelessWidget {
  /// Creates the card content.
  const HeroCardContent({
    super.key,
    required this.children,
    this.gap,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// The content, top to bottom.
  final List<Widget> children;

  /// Space between the children; defaults to 4 (`gap-1`).
  final double? gap;

  /// How the children are aligned horizontally.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return _HeroCardBlock(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        spacing: gap ?? HeroTheme.of(context).spacing(1),
        children: children,
      ),
    );
  }
}

/// The footer of a [HeroCard] (HeroUI `Card.Footer`): a row of actions or
/// links, vertically centered, that fills the width of the card.
///
/// Set [direction] to [Axis.vertical] for stacked actions (`flex-col`);
/// children stay centered horizontally, as in HeroUI, unless
/// [crossAxisAlignment] says otherwise. Wrap text that may wrap in a
/// [Flexible].
class HeroCardFooter extends StatelessWidget {
  /// Creates a card footer.
  const HeroCardFooter({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.gap = 0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// The footer content.
  final List<Widget> children;

  /// Whether the children form a row (default) or a column.
  final Axis direction;

  /// Space between the children (none by default; `gap-2` is 8).
  final double gap;

  /// How the children are placed along [direction] (`justify-*`).
  final MainAxisAlignment mainAxisAlignment;

  /// How the children are placed across [direction] (`items-*`).
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return _HeroCardBlock(
      child: Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        spacing: gap,
        children: children,
      ),
    );
  }
}

/// Sizes [child] like a CSS block box: it takes the full width it is
/// offered, or the width of its content when that width is unbounded (for
/// example inside a [Row]).
///
/// [HeroCard] and its header, content and footer parts use it so they fill
/// the card without asking for stretched columns.
class _HeroCardBlock extends SingleChildRenderObjectWidget {
  const _HeroCardBlock({required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeroCardBlock();
}

class _RenderHeroCardBlock extends RenderProxyBox {
  BoxConstraints _childConstraints(RenderBox child, BoxConstraints c) {
    if (c.hasBoundedWidth) return c.tighten(width: c.maxWidth);
    return c.tighten(
      width: c.constrainWidth(child.getMaxIntrinsicWidth(c.maxHeight)),
    );
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) return constraints.smallest;
    return child.getDryLayout(_childConstraints(child, constraints));
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(child, constraints), parentUsesSize: true);
    size = child.size;
  }
}
