/// HeroUI's Button: a clickable button with variants, sizes and states.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../spinner/spinner.dart';
import 'button_content.dart';
import 'button_metrics.dart';
import 'button_style.dart';

export 'button_content.dart';
export 'button_metrics.dart';
export 'button_style.dart';

/// The visual style of a [HeroButton] (HeroUI's `variant` prop).
enum HeroButtonVariant {
  /// Solid accent fill (`--accent`), the default.
  primary,

  /// Neutral fill with accent text (`--default` + `--accent-soft-foreground`).
  secondary,

  /// Neutral fill with the surrounding text color (`--default` +
  /// `currentColor`).
  tertiary,

  /// Transparent with a `--border` outline.
  outline,

  /// Transparent; `--default` on hover.
  ghost,

  /// Solid danger fill (`--danger`).
  danger,

  /// Tinted danger fill (`--danger-soft`), HeroUI's `danger-soft`.
  dangerSoft;

  /// Resolves the fill, hover and pressed fills, foreground and border of
  /// this variant from `button.css`. [currentColor] is the inherited text
  /// color used by [tertiary].
  HeroVariantStyle resolve(HeroColors colors, {required Color currentColor}) {
    return switch (this) {
      primary => HeroVariants.resolve(
        colors,
        HeroVariant.primary,
        HeroColor.accent,
      ),
      secondary => HeroVariants.resolve(
        colors,
        HeroVariant.secondary,
        HeroColor.accent,
      ),
      tertiary => HeroVariants.resolve(
        colors,
        HeroVariant.secondary,
        HeroColor.standard,
      ).copyWith(foreground: currentColor),
      // The hover fill is `--default` at 60%, the pressed fill `--default`.
      outline => HeroVariants.resolve(
        colors,
        HeroVariant.outline,
        HeroColor.standard,
      ).copyWith(backgroundPressed: colors.defaultColor),
      ghost => HeroVariants.resolve(
        colors,
        HeroVariant.ghost,
        HeroColor.standard,
      ),
      danger => HeroVariants.resolve(
        colors,
        HeroVariant.primary,
        HeroColor.danger,
      ),
      dangerSoft => HeroVariants.resolve(
        colors,
        HeroVariant.soft,
        HeroColor.danger,
      ),
    };
  }
}

/// The render props of a [HeroButton]: `isHovered`, `isPressed`,
/// `isFocused`, `isFocusVisible`, `isDisabled` and `isPending`.
typedef HeroButtonState = HeroInteractionState;

/// Builds the content of a [HeroButton] for its current [state] (HeroUI's
/// render-prop children).
typedef HeroButtonWidgetBuilder =
    Widget Function(BuildContext context, HeroButtonState state);

/// A clickable button with HeroUI's variants, sizes and states.
///
/// ```dart
/// HeroButton(
///   onPressed: () => debugPrint('Button pressed'),
///   child: const Text('Click me'),
/// )
/// ```
///
/// * [variant]: primary (default), secondary, tertiary, outline, ghost,
///   danger or dangerSoft.
/// * [size]: sm, md (default) or lg; heights shrink by 4 from the `md`
///   breakpoint (768) like HeroUI's `md:` utilities.
/// * [startContent] / [endContent]: icons around the label. A [HeroIcon] in
///   a slot takes the button's icon size and color.
/// * [isIconOnly]: a square button whose [child] is an icon; give it a
///   [semanticLabel].
/// * [isPending]: ignores presses without dimming, stays focusable and
///   shows a small spinner in the start slot (in place of the icon of an
///   icon-only button). Use [builder] to render the pending state yourself.
/// * [isDisabled]: 50% opacity, not focusable, no presses.
///
/// The button reacts to hover (mouse), press (scales to 0.97 and switches
/// to the pressed fill), keyboard focus (focus ring) and activates on tap,
/// Enter and Space.
class HeroButton extends StatelessWidget {
  /// Creates a button.
  const HeroButton({
    super.key,
    this.child,
    this.builder,
    this.startContent,
    this.endContent,
    this.onPressed,
    this.onPressStart,
    this.onPressEnd,
    this.onHoverChanged,
    this.onFocusChanged,
    this.variant,
    this.size,
    this.fullWidth,
    this.isDisabled,
    this.isPending = false,
    this.isIconOnly = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.style,
  });

  /// The label, usually a [Text] (or a [HeroIcon] when [isIconOnly]).
  final Widget? child;

  /// Builds the label from the button state; replaces [child]
  /// (`children` as a render function).
  final HeroButtonWidgetBuilder? builder;

  /// Content before the label, usually a [HeroIcon].
  final Widget? startContent;

  /// Content after the label, usually a [HeroIcon].
  final Widget? endContent;

  /// Called when the button is activated (`onPress`).
  final VoidCallback? onPressed;

  /// Called when a press starts (`onPressStart`).
  final VoidCallback? onPressStart;

  /// Called when a press ends, activated or not (`onPressEnd`).
  final VoidCallback? onPressEnd;

  /// Called when a mouse starts or stops hovering (`onHoverChange`).
  final ValueChanged<bool>? onHoverChanged;

  /// Called when the button gains or loses focus (`onFocusChange`).
  final ValueChanged<bool>? onFocusChanged;

  /// The visual style; defaults to [HeroButtonVariant.primary].
  final HeroButtonVariant? variant;

  /// The size; defaults to [HeroSize.md].
  final HeroSize? size;

  /// Whether the button fills a bounded width (`w-full`); defaults to
  /// false.
  final bool? fullWidth;

  /// Whether the button is disabled; defaults to false.
  final bool? isDisabled;

  /// Whether the button is in a loading state.
  final bool isPending;

  /// Whether the button only contains an icon (square, no padding).
  final bool isIconOnly;

  /// An optional focus node.
  final FocusNode? focusNode;

  /// Whether to focus the button when it is first built.
  final bool autofocus;

  /// Accessibility label (`aria-label`); required for icon-only buttons.
  final String? semanticLabel;

  /// Overrides for colors, shape, geometry and text.
  final HeroButtonStyle? style;

  static const Widget _pendingSpinner = HeroSpinner(
    size: HeroSpinnerSize.sm,
    color: HeroSpinnerColor.current,
  );

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroButtonStyle? style = this.style;
    final HeroButtonVariant variant = this.variant ?? HeroButtonVariant.primary;
    final bool disabled = isDisabled ?? false;
    final HeroButtonMetrics metrics = HeroButtonMetrics.of(
      context,
      size ?? HeroSize.md,
    );
    final HeroVariantStyle colors = variant.resolve(
      theme.colors,
      currentColor:
          DefaultTextStyle.of(context).style.color ?? theme.colors.foreground,
    );
    final TextDirection direction = Directionality.of(context);

    final BorderRadius radius =
        (style?.borderRadius ?? BorderRadius.circular(metrics.radius)).resolve(
          direction,
        );
    final BorderSide side =
        style?.side ??
        (colors.borderColor == null
            ? BorderSide.none
            : BorderSide(color: colors.borderColor!, width: theme.borderWidth));
    final EdgeInsets borderWidths = side.style == BorderStyle.none
        ? EdgeInsets.zero
        : EdgeInsets.all(side.width);
    final EdgeInsetsGeometry padding =
        style?.padding ??
        (isIconOnly
            ? EdgeInsets.zero
            : EdgeInsetsDirectional.symmetric(
                horizontal: metrics.horizontalPadding,
              ));
    final double height = style?.height ?? metrics.height;
    final OutlinedBorder shape = theme.shape(radius);
    final TextStyle textStyle = metrics.textStyle.merge(style?.textStyle);

    return HeroInteractable(
      onPressed: onPressed,
      onPressStart: onPressStart,
      onPressEnd: onPressEnd,
      onHoverChanged: onHoverChanged,
      onFocusChanged: onFocusChanged,
      isDisabled: disabled,
      isPending: isPending,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticsLabel: semanticLabel,
      builder: (BuildContext context, HeroInteractionState state, _) {
        final Set<WidgetState> states = state.widgetStates;
        final Color background =
            style?.backgroundColor?.resolve(states) ??
            colors.backgroundFor(state);
        final Color foreground =
            style?.foregroundColor?.resolve(states) ?? colors.foreground;

        Widget? start = startContent;
        Widget? label = builder?.call(context, state) ?? child;
        if (isPending && builder == null) {
          if (isIconOnly) {
            label = _pendingSpinner;
          } else {
            start = _pendingSpinner;
          }
        }

        Widget content = HeroButtonContent(
          startContent: start,
          label: label,
          endContent: endContent,
          gap: metrics.gap,
          iconInset: metrics.iconInset,
          expand: fullWidth ?? false,
        );
        content = IconTheme(
          data: IconThemeData(
            color: foreground,
            size: style?.iconSize ?? metrics.iconSize,
          ),
          child: DefaultTextStyle(
            style: textStyle.copyWith(color: foreground),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: content,
          ),
        );
        content = ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height,
            minWidth: isIconOnly ? height : 0,
          ),
          child: Padding(padding: padding.add(borderWidths), child: content),
        );
        content = HeroButtonSurface(
          color: background,
          shape: shape,
          borderRadius: radius,
          side: side,
          borderWidths: borderWidths,
          shadows: style?.shadows,
          child: content,
        );
        return HeroPressScale(
          pressed: state.isPressed,
          scale: style?.pressedScale ?? metrics.pressedScale,
          child: HeroFocusRing(
            visible: state.isFocusVisible,
            shape: shape,
            child: HeroDisabledOpacity(disabled: disabled, child: content),
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<HeroButtonVariant>('variant', variant, defaultValue: null),
      )
      ..add(EnumProperty<HeroSize>('size', size, defaultValue: null))
      ..add(FlagProperty('fullWidth', value: fullWidth, ifTrue: 'full width'))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isPending', value: isPending, ifTrue: 'pending'))
      ..add(FlagProperty('isIconOnly', value: isIconOnly, ifTrue: 'icon only'))
      ..add(
        ObjectFlagProperty<VoidCallback>(
          'onPressed',
          onPressed,
          ifNull: 'no handler',
        ),
      );
  }
}

/// The painted surface of a HeroUI button: its fill (animated over 100 ms
/// like `transition: background-color 100ms ease-out`), shadows and an
/// outline that may leave out sides.
///
/// [borderWidths] sets the outline width per side; a zero side is not
/// drawn, which button groups use to merge neighbouring outlines. Inner
/// corners are reduced by the adjacent widths like CSS borders.
class HeroButtonSurface extends StatelessWidget {
  /// Creates a button surface.
  const HeroButtonSurface({
    super.key,
    required this.color,
    required this.shape,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.side = BorderSide.none,
    this.borderWidths = EdgeInsets.zero,
    this.shadows,
  });

  /// The fill color.
  final Color color;

  /// The outline of the surface.
  final OutlinedBorder shape;

  /// The corner radii of [shape], used to derive the inner outline edge.
  final BorderRadius borderRadius;

  /// The outline color and style.
  final BorderSide side;

  /// The outline width per side.
  final EdgeInsets borderWidths;

  /// Shadows painted behind the surface.
  final List<BoxShadow>? shadows;

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool bordered =
        side.style != BorderStyle.none &&
        side.color.a > 0 &&
        borderWidths != EdgeInsets.zero;
    final CustomPainter? border = bordered
        ? _HeroButtonBorderPainter(
            outer: shape,
            inner: theme.shape(_innerRadius(borderRadius, borderWidths)),
            widths: borderWidths,
            color: side.color,
          )
        : null;
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: theme.motion.resolve(context, HeroMotion.fast),
      curve: HeroMotion.easeOut,
      child: child,
      builder: (BuildContext context, Color? fill, Widget? child) {
        return DecoratedBox(
          decoration: ShapeDecoration(
            color: fill,
            shape: shape,
            shadows: shadows,
          ),
          child: CustomPaint(foregroundPainter: border, child: child),
        );
      },
    );
  }

  static BorderRadius _innerRadius(BorderRadius outer, EdgeInsets widths) {
    Radius shrink(Radius r, double dx, double dy) =>
        Radius.elliptical(math.max(0, r.x - dx), math.max(0, r.y - dy));
    return BorderRadius.only(
      topLeft: shrink(outer.topLeft, widths.left, widths.top),
      topRight: shrink(outer.topRight, widths.right, widths.top),
      bottomLeft: shrink(outer.bottomLeft, widths.left, widths.bottom),
      bottomRight: shrink(outer.bottomRight, widths.right, widths.bottom),
    );
  }
}

/// Paints the band between the outer shape and the inner shape inset by
/// per-side widths.
class _HeroButtonBorderPainter extends CustomPainter {
  const _HeroButtonBorderPainter({
    required this.outer,
    required this.inner,
    required this.widths,
    required this.color,
  });

  final ShapeBorder outer;
  final ShapeBorder inner;
  final EdgeInsets widths;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        outer.getOuterPath(rect),
        inner.getOuterPath(widths.deflateRect(rect)),
      ),
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_HeroButtonBorderPainter oldDelegate) =>
      oldDelegate.outer != outer ||
      oldDelegate.inner != inner ||
      oldDelegate.widths != widths ||
      oldDelegate.color != color;
}
