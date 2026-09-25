import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/color/color_math.dart';
import '../../foundation/icons/hero_icon.dart';
import '../../foundation/icons/hero_icons.dart';
import '../../foundation/interaction/hero_focus_ring.dart';
import '../../foundation/interaction/hero_interactable.dart';
import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';
import '../../foundation/tokens/hero_motion.dart';
import '../../foundation/tokens/hero_typography.dart';

/// When a [HeroLink] underlines its text.
enum HeroLinkUnderline {
  /// While hovered or pressed (HeroUI's default).
  hover,

  /// Always (the `underline` utility).
  always,

  /// Never (the `no-underline` utility).
  none,
}

/// Where a [HeroLink] asks its [HeroLinkHandler] to open its `href`.
enum HeroLinkTarget {
  /// In the current context (`_self`).
  self,

  /// In a new window or tab (`_blank`).
  blank,
}

/// Opens the `href` of the [HeroLink]s below it, for example with a router
/// or a URL launcher. React Aria's `RouterProvider` counterpart.
class HeroLinkHandler extends InheritedWidget {
  /// Provides [onOpen] to descendant links.
  const HeroLinkHandler({
    super.key,
    required this.onOpen,
    required super.child,
  });

  /// Called with a link's `href` and `target` when the link is activated.
  final void Function(Uri href, HeroLinkTarget target) onOpen;

  /// Returns the nearest handler, or null.
  static HeroLinkHandler? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroLinkHandler>();

  @override
  bool updateShouldNotify(HeroLinkHandler oldWidget) =>
      onOpen != oldWidget.onOpen;
}

/// Signature of [HeroLink.builder].
typedef HeroLinkWidgetBuilder =
    Widget Function(BuildContext context, HeroInteractionState state);

/// A styled link for navigation with built-in icon support (HeroUI `Link`).
///
/// ```dart
/// HeroLink(
///   href: Uri.parse('https://heroui.com'),
///   children: const <Widget>[Text('Call to action'), HeroLinkIcon()],
/// )
/// ```
///
/// The link takes the font size of the surrounding text, uses the `link`
/// color in medium weight and underlines its text on hover and press
/// ([underline]). Activating it (tap, click or Enter) calls [onPressed] and
/// then hands [href] to the nearest [HeroLinkHandler].
class HeroLink extends StatefulWidget {
  /// Creates a link.
  const HeroLink({
    super.key,
    this.child,
    this.children = const <Widget>[],
    this.builder,
    this.href,
    this.target = HeroLinkTarget.self,
    this.onPressed,
    this.isDisabled = false,
    this.autofocus = false,
    this.focusNode,
    this.underline = HeroLinkUnderline.hover,
    this.underlineOffset = 4,
    this.decorationColor,
    this.color,
    this.gap = 0,
    this.semanticsLabel,
  });

  /// A single content widget, usually a [Text]. When [children] are given
  /// too, it comes first.
  final Widget? child;

  /// Content widgets laid out in a row, for example a [Text] and a
  /// [HeroLinkIcon].
  final List<Widget> children;

  /// Builds the content from the interaction state instead of [child] or
  /// [children] (HeroUI's render props).
  final HeroLinkWidgetBuilder? builder;

  /// Destination handed to the nearest [HeroLinkHandler] and exposed to
  /// assistive technologies.
  final Uri? href;

  /// Where the destination should open.
  final HeroLinkTarget target;

  /// Called when the link is activated.
  final VoidCallback? onPressed;

  /// Disables interaction and fades the link.
  final bool isDisabled;

  /// Whether the link requests focus when first built.
  final bool autofocus;

  /// Optional externally managed focus node.
  final FocusNode? focusNode;

  /// When the text is underlined.
  final HeroLinkUnderline underline;

  /// Distance from the text baseline to the underline
  /// (`underline-offset-4`).
  final double underlineOffset;

  /// Overrides the underline color. A [WidgetStateColor] resolves against
  /// the link's hovered, pressed, focused and disabled states.
  final Color? decorationColor;

  /// Overrides the text color (`link`). A [WidgetStateColor] resolves
  /// against the link's states.
  final Color? color;

  /// Space between the content widgets (`gap-1` is 4).
  final double gap;

  /// Accessibility label; defaults to the text of the link.
  final String? semanticsLabel;

  @override
  State<HeroLink> createState() => _HeroLinkState();
}

class _HeroLinkState extends State<HeroLink> {
  static const Map<ShortcutActivator, Intent> _shortcuts =
      <ShortcutActivator, Intent>{
        // Links activate with Enter only, like a native anchor.
        SingleActivator(LogicalKeyboardKey.space):
            DoNothingAndStopPropagationIntent(),
      };

  void _handlePressed() {
    widget.onPressed?.call();
    final Uri? href = widget.href;
    if (href != null) {
      HeroLinkHandler.maybeOf(context)?.onOpen(href, widget.target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroInteractable(
      onPressed: _handlePressed,
      isDisabled: widget.isDisabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      isLink: true,
      linkUrl: widget.href,
      shortcuts: _shortcuts,
      semanticsLabel: widget.semanticsLabel,
      builder: (BuildContext context, HeroInteractionState state, _) {
        final Set<WidgetState> states = state.widgetStates;
        final Color textColor =
            WidgetStateProperty.resolveAs<Color?>(widget.color, states) ??
            theme.colors.link;
        final bool active =
            state.isHovered || state.isPressed || state.isFocusVisible;
        final bool underlined = switch (widget.underline) {
          HeroLinkUnderline.always => true,
          HeroLinkUnderline.none => false,
          HeroLinkUnderline.hover => state.isHovered || state.isPressed,
        };
        final Color decorationColor =
            WidgetStateProperty.resolveAs<Color?>(
              widget.decorationColor,
              states,
            ) ??
            (state.isPressed
                ? theme.colors.muted
                : state.isHovered
                ? colorMix(
                    theme.colors.muted,
                    const Color(0x00000000),
                    p1: 0.5,
                    space: ColorMixSpace.srgb,
                  )
                : theme.colors.separatorTertiary);

        Widget content = widget.builder != null
            ? widget.builder!(context, state)
            : widget.children.isEmpty && widget.child != null
            ? widget.child!
            : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: widget.gap,
                children: <Widget>[
                  // Text may wrap when space runs out, like the flex items
                  // of an inline-flex link; icons keep their size.
                  for (final Widget child in <Widget>[
                    ?widget.child,
                    ...widget.children,
                  ])
                    if (child is HeroLinkIcon)
                      child
                    else
                      Flexible(child: child),
                ],
              );
        content = _HeroLinkScope(active: active, child: content);
        content = IconTheme.merge(
          data: IconThemeData(color: textColor),
          child: content,
        );
        content = AnimatedDefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(
            color: textColor,
            fontWeight: HeroTypography.medium,
            decoration: TextDecoration.none,
          ),
          duration: theme.motion.resolve(context, HeroMotion.fast),
          curve: HeroMotion.smooth,
          child: content,
        );
        content = _LinkUnderline(
          visible: underlined,
          color: decorationColor,
          thickness: theme.spacing(0.375),
          offset: widget.underlineOffset,
          child: content,
        );
        content = HeroFocusRing(
          visible: state.isFocusVisible,
          shape: theme.shapeAll(theme.radii.xl),
          child: content,
        );
        return AnimatedOpacity(
          opacity: state.isDisabled ? theme.disabledOpacity : 1,
          duration: theme.motion.resolve(context, HeroMotion.fast),
          curve: HeroMotion.easeOut,
          child: content,
        );
      },
    );
  }
}

class _HeroLinkScope extends InheritedWidget {
  const _HeroLinkScope({required this.active, required super.child});

  final bool active;

  @override
  bool updateShouldNotify(_HeroLinkScope oldWidget) =>
      active != oldWidget.active;
}

/// The icon of a [HeroLink] (HeroUI `Link.Icon`).
///
/// Without a [child] it shows HeroUI's external-link arrow, raised slightly
/// and 4 px after the text. The icon box is 0.75 em square, takes the link
/// color, and is 60% opaque until the link is hovered, pressed or focused.
class HeroLinkIcon extends StatelessWidget {
  /// Creates a link icon.
  const HeroLinkIcon({super.key, this.child, this.size, this.margin});

  /// A custom icon, for example a [HeroIcon]; it receives [size] through
  /// the ambient [IconTheme].
  final Widget? child;

  /// Size of the icon box; defaults to 0.75 × the link's font size.
  final double? size;

  /// Space around the icon; the default icon has a 4 px start margin.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroLinkScope? scope = context
        .dependOnInheritedWidgetOfExactType<_HeroLinkScope>();
    final double fontSize =
        DefaultTextStyle.of(context).style.fontSize ??
        HeroFontSize.base.fontSize;
    final double box = size ?? fontSize * 0.75;
    final Widget icon;
    if (child == null) {
      // `ms-1 pb-1.5` around the 9 px arrow: the bottom padding raises the
      // arrow by half of it inside the box.
      icon = Transform.translate(
        offset: Offset(0, -theme.spacing(1.5) / 2),
        child: const HeroIcon(HeroIcons.externalLink, size: 9),
      );
    } else {
      icon = IconTheme.merge(
        data: IconThemeData(size: box),
        child: child!,
      );
    }
    final EdgeInsetsGeometry resolvedMargin =
        margin ??
        (child == null
            ? EdgeInsetsDirectional.only(start: theme.spacing(1))
            : EdgeInsets.zero);
    return Padding(
      padding: resolvedMargin,
      child: _NoUnderline(
        child: AnimatedOpacity(
          opacity: scope?.active ?? false ? 1 : 0.6,
          duration: theme.motion.resolve(context, HeroMotion.normal),
          curve: HeroMotion.easeOut,
          child: SizedBox.square(
            dimension: box,
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkUnderline extends SingleChildRenderObjectWidget {
  const _LinkUnderline({
    required this.visible,
    required this.color,
    required this.thickness,
    required this.offset,
    required super.child,
  });

  final bool visible;
  final Color color;
  final double thickness;
  final double offset;

  @override
  RenderHeroLinkUnderline createRenderObject(BuildContext context) =>
      RenderHeroLinkUnderline(
        visible: visible,
        color: color,
        thickness: thickness,
        offset: offset,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHeroLinkUnderline renderObject,
  ) {
    renderObject
      ..visible = visible
      ..color = color
      ..thickness = thickness
      ..offset = offset;
  }
}

class _NoUnderline extends SingleChildRenderObjectWidget {
  const _NoUnderline({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderNoUnderline();
}

class _RenderNoUnderline extends RenderProxyBox {}

/// Paints a text underline below every [Text] inside a [HeroLink], [offset]
/// below the alphabetic baseline and [thickness] thick, like CSS
/// `text-underline-offset` and `text-decoration-thickness`. The icon of a
/// [HeroLinkIcon] is skipped.
class RenderHeroLinkUnderline extends RenderProxyBox {
  /// Creates the render object.
  RenderHeroLinkUnderline({
    required bool visible,
    required Color color,
    required double thickness,
    required double offset,
  }) : _visible = visible,
       _color = color,
       _thickness = thickness,
       _offset = offset;

  /// Whether the underline is painted.
  bool get visible => _visible;
  bool _visible;
  set visible(bool value) {
    if (value == _visible) return;
    _visible = value;
    markNeedsPaint();
  }

  /// Underline color.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    markNeedsPaint();
  }

  /// Underline thickness.
  double get thickness => _thickness;
  double _thickness;
  set thickness(double value) {
    if (value == _thickness) return;
    _thickness = value;
    markNeedsPaint();
  }

  /// Distance from the baseline to the top of the underline.
  double get offset => _offset;
  double _offset;
  set offset(double value) {
    if (value == _offset) return;
    _offset = value;
    markNeedsPaint();
  }

  void _collect(RenderObject node, List<RenderParagraph> out) {
    node.visitChildren((RenderObject child) {
      if (child is _RenderNoUnderline) return;
      if (child is RenderParagraph) {
        out.add(child);
        return;
      }
      _collect(child, out);
    });
  }

  /// The underline rectangles in this box's coordinate space.
  List<Rect> underlineRects() {
    final List<Rect> rects = <Rect>[];
    final List<RenderParagraph> paragraphs = <RenderParagraph>[];
    _collect(this, paragraphs);
    for (final RenderParagraph paragraph in paragraphs) {
      if (!paragraph.hasSize || !paragraph.attached) continue;
      final Offset origin = MatrixUtils.transformPoint(
        paragraph.getTransformTo(this),
        Offset.zero,
      );
      final TextPainter painter = TextPainter(
        text: paragraph.text,
        textAlign: paragraph.textAlign,
        textDirection: paragraph.textDirection,
        textScaler: paragraph.textScaler,
        maxLines: paragraph.maxLines,
        ellipsis: paragraph.overflow == TextOverflow.ellipsis ? '…' : null,
        locale: paragraph.locale,
        strutStyle: paragraph.strutStyle,
        textWidthBasis: paragraph.textWidthBasis,
        textHeightBehavior: paragraph.textHeightBehavior,
      );
      try {
        final bool hasPlaceholders = _hasPlaceholder(paragraph.text);
        if (hasPlaceholders) {
          final double? baseline = paragraph.getDistanceToActualBaseline(
            TextBaseline.alphabetic,
          );
          if (baseline != null) {
            rects.add(
              Rect.fromLTWH(
                origin.dx,
                origin.dy + baseline + _offset,
                paragraph.size.width,
                _thickness,
              ),
            );
          }
          continue;
        }
        painter.layout(
          minWidth: paragraph.size.width,
          maxWidth: paragraph.size.width,
        );
        for (final LineMetrics line in painter.computeLineMetrics()) {
          if (line.width <= 0) continue;
          rects.add(
            Rect.fromLTWH(
              origin.dx + line.left,
              origin.dy + line.baseline + _offset,
              line.width,
              _thickness,
            ),
          );
        }
      } finally {
        painter.dispose();
      }
    }
    return rects;
  }

  static bool _hasPlaceholder(InlineSpan span) {
    bool found = false;
    span.visitChildren((InlineSpan child) {
      if (child is PlaceholderSpan) found = true;
      return !found;
    });
    return found;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (!_visible || _color.a == 0) return;
    final Paint paint = Paint()..color = _color;
    for (final Rect rect in underlineRects()) {
      context.canvas.drawRect(rect.shift(offset), paint);
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('visible', value: _visible, ifTrue: 'underlined'))
      ..add(ColorProperty('color', _color));
  }
}
