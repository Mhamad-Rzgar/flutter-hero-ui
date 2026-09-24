import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The visual variant shared by HeroUI's form fields (`primary | secondary`).
///
/// Used by `HeroInput`, `HeroTextArea` and every field built on them.
enum HeroFieldVariant {
  /// The default field: `--field-background` with the field shadow.
  primary,

  /// A lower-emphasis field for use on surfaces: `--default` background and
  /// no shadow.
  secondary,
}

/// Shares the state of a field root (TextField, SearchField, Checkbox, ...)
/// with the parts rendered inside it (`HeroLabel`, `HeroDescription`,
/// `HeroInput`, ...).
///
/// This is the counterpart of HeroUI's `data-*` ancestor selectors
/// (`[data-disabled] .label`, `[data-invalid] .label`,
/// `[data-required] > .label`) and of the React contexts that let an `Input`
/// inherit the variant of its `TextField`.
class HeroFieldScope extends InheritedWidget {
  /// Publishes field state to [child].
  const HeroFieldScope({
    super.key,
    required super.child,
    this.variant,
    this.isDisabled = false,
    this.isInvalid = false,
    this.isRequired = false,
    this.isReadOnly = false,
    this.showRequiredIndicator,
    this.hideDescriptionWhenInvalid = false,
    this.fullWidth = false,
    this.focusNode,
    this.controller,
    this.onLabelPressed,
    this.semanticLabel,
    this.semanticHint,
  });

  /// Variant inherited by inputs that do not set their own.
  final HeroFieldVariant? variant;

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Whether the field is invalid.
  final bool isInvalid;

  /// Whether the field is required.
  final bool isRequired;

  /// Whether the field is read-only.
  final bool isReadOnly;

  /// Whether labels inside the field show the required asterisk; defaults to
  /// [isRequired]. Item roots such as a single checkbox set this to false,
  /// like HeroUI's `[data-required]:not([data-slot="checkbox"]) > .label`.
  final bool? showRequiredIndicator;

  /// Whether descriptions are hidden while the field is invalid (TextField,
  /// SearchField and NumberField hide them in favour of the error).
  final bool hideDescriptionWhenInvalid;

  /// Whether inputs inside the field take the full available width.
  final bool fullWidth;

  /// The focus node of the field's control. A label inside the field focuses
  /// it when pressed; an input inside the field uses it.
  final FocusNode? focusNode;

  /// The text controller owned by the field root. When set, inputs inside
  /// the field edit this controller and the root owns the form state
  /// (the inputs then do not register their own `FormField`).
  final TextEditingController? controller;

  /// Called when a label inside the field is pressed (for example to toggle
  /// a checkbox). Takes precedence over focusing [focusNode].
  final VoidCallback? onLabelPressed;

  /// Accessibility label for the field's control (usually the label text).
  final String? semanticLabel;

  /// Accessibility hint for the field's control (usually the description or
  /// error text).
  final String? semanticHint;

  /// Whether labels show the required asterisk.
  bool get requiredIndicatorVisible => showRequiredIndicator ?? isRequired;

  /// The closest field scope, or null outside a field.
  static HeroFieldScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroFieldScope>();

  @override
  bool updateShouldNotify(HeroFieldScope oldWidget) =>
      variant != oldWidget.variant ||
      isDisabled != oldWidget.isDisabled ||
      isInvalid != oldWidget.isInvalid ||
      isRequired != oldWidget.isRequired ||
      isReadOnly != oldWidget.isReadOnly ||
      showRequiredIndicator != oldWidget.showRequiredIndicator ||
      hideDescriptionWhenInvalid != oldWidget.hideDescriptionWhenInvalid ||
      fullWidth != oldWidget.fullWidth ||
      focusNode != oldWidget.focusNode ||
      controller != oldWidget.controller ||
      onLabelPressed != oldWidget.onLabelPressed ||
      semanticLabel != oldWidget.semanticLabel ||
      semanticHint != oldWidget.semanticHint;
}

/// Per-instance visual overrides of a field (the Flutter counterpart of the
/// Tailwind classes HeroUI's "custom styles" examples pass in `className`).
///
/// Every value is optional; null keeps the theme default. Like a Tailwind
/// utility, a [backgroundColor] or [borderColor] without a state-specific
/// value applies to every state.
@immutable
class HeroFieldStyle with Diagnosticable {
  /// Creates field style overrides.
  const HeroFieldStyle({
    this.backgroundColor,
    this.hoverBackgroundColor,
    this.focusBackgroundColor,
    this.borderColor,
    this.hoverBorderColor,
    this.focusBorderColor,
    this.borderWidth,
    this.borderRadius,
    this.shadow,
    this.focusRingColor,
    this.focusRingWidth,
    this.padding,
    this.textStyle,
    this.placeholderStyle,
    this.cursorColor,
    this.selectionColor,
  });

  /// Resting background (`bg-field`, or `bg-default` for secondary).
  final Color? backgroundColor;

  /// Background while hovered (`bg-field-hover`).
  final Color? hoverBackgroundColor;

  /// Background while focused (`--field-focus`).
  final Color? focusBackgroundColor;

  /// Resting border color (`--field-border`).
  final Color? borderColor;

  /// Border color while hovered (`--field-border-hover`).
  final Color? hoverBorderColor;

  /// Border color while focused (`--field-border-focus`).
  final Color? focusBorderColor;

  /// Border width (`--field-border-width`, 0 by default).
  final double? borderWidth;

  /// Corner radius (`rounded-field`, 12 by default).
  final BorderRadiusGeometry? borderRadius;

  /// Resting shadow (`shadow-field` for primary fields, none for secondary).
  /// A Tailwind `ring-1` can be expressed as a shadow with a spread of 1.
  final HeroShadow? shadow;

  /// Focus ring color (`--focus`).
  final Color? focusRingColor;

  /// Focus ring width (`ring-2`).
  final double? focusRingWidth;

  /// Inner padding (`px-3 py-2`).
  final EdgeInsetsGeometry? padding;

  /// Text style merged over the field text style.
  final TextStyle? textStyle;

  /// Placeholder style merged over the placeholder style.
  final TextStyle? placeholderStyle;

  /// Caret color (the text color by default, like CSS `caret-color: auto`).
  final Color? cursorColor;

  /// Selection highlight color.
  final Color? selectionColor;

  /// Returns a copy where the non-null values of [other] win.
  HeroFieldStyle merge(HeroFieldStyle? other) {
    if (other == null) return this;
    return HeroFieldStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      hoverBackgroundColor: other.hoverBackgroundColor ?? hoverBackgroundColor,
      focusBackgroundColor: other.focusBackgroundColor ?? focusBackgroundColor,
      borderColor: other.borderColor ?? borderColor,
      hoverBorderColor: other.hoverBorderColor ?? hoverBorderColor,
      focusBorderColor: other.focusBorderColor ?? focusBorderColor,
      borderWidth: other.borderWidth ?? borderWidth,
      borderRadius: other.borderRadius ?? borderRadius,
      shadow: other.shadow ?? shadow,
      focusRingColor: other.focusRingColor ?? focusRingColor,
      focusRingWidth: other.focusRingWidth ?? focusRingWidth,
      padding: other.padding ?? padding,
      textStyle: textStyle?.merge(other.textStyle) ?? other.textStyle,
      placeholderStyle:
          placeholderStyle?.merge(other.placeholderStyle) ??
          other.placeholderStyle,
      cursorColor: other.cursorColor ?? cursorColor,
      selectionColor: other.selectionColor ?? selectionColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroFieldStyle &&
      other.backgroundColor == backgroundColor &&
      other.hoverBackgroundColor == hoverBackgroundColor &&
      other.focusBackgroundColor == focusBackgroundColor &&
      other.borderColor == borderColor &&
      other.hoverBorderColor == hoverBorderColor &&
      other.focusBorderColor == focusBorderColor &&
      other.borderWidth == borderWidth &&
      other.borderRadius == borderRadius &&
      other.shadow == shadow &&
      other.focusRingColor == focusRingColor &&
      other.focusRingWidth == focusRingWidth &&
      other.padding == padding &&
      other.textStyle == textStyle &&
      other.placeholderStyle == placeholderStyle &&
      other.cursorColor == cursorColor &&
      other.selectionColor == selectionColor;

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    hoverBackgroundColor,
    focusBackgroundColor,
    borderColor,
    hoverBorderColor,
    focusBorderColor,
    borderWidth,
    borderRadius,
    shadow,
    focusRingColor,
    focusRingWidth,
    padding,
    textStyle,
    placeholderStyle,
    cursorColor,
    selectionColor,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ColorProperty('backgroundColor', backgroundColor, defaultValue: null),
      )
      ..add(ColorProperty('borderColor', borderColor, defaultValue: null))
      ..add(DoubleProperty('borderWidth', borderWidth, defaultValue: null));
  }
}

/// Shared metrics of HeroUI's text fields.
abstract final class HeroFieldMetrics {
  /// Whether HeroUI's `sm:` utilities apply: the viewport is at least
  /// [HeroBreakpoints.sm] wide, unless the theme density pins a value
  /// ([HeroDensity.touch] never, [HeroDensity.desktop] always).
  static bool isSmUp(BuildContext context) {
    return switch (HeroTheme.of(context).density) {
      HeroDensity.touch => false,
      HeroDensity.desktop => true,
      HeroDensity.adaptive =>
        (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= HeroBreakpoints.sm,
    };
  }

  /// The font size of text inputs: `text-base` below `sm`, `sm:text-sm`
  /// from it (16/24 → 14/20).
  static HeroFontSize fontSize(BuildContext context) =>
      isSmUp(context) ? HeroFontSize.sm : HeroFontSize.base;

  /// The text style of text inputs in `--field-foreground`.
  static TextStyle textStyle(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return theme.typography
        .style(fontSize(context))
        .copyWith(color: theme.colors.fieldForeground);
  }

  /// The placeholder style (`placeholder:text-field-placeholder`).
  static TextStyle placeholderStyle(BuildContext context) => textStyle(
    context,
  ).copyWith(color: HeroTheme.of(context).colors.fieldPlaceholder);

  /// The inner padding of inputs and text areas (`px-3 py-2`).
  static EdgeInsetsGeometry padding(HeroThemeData theme) =>
      EdgeInsetsDirectional.symmetric(
        horizontal: theme.spacing(3),
        vertical: theme.spacing(2),
      );

  /// The width of an input without an explicit width, like a native
  /// `<input>` with its default `size="20"`.
  static double defaultWidth(HeroThemeData theme) => theme.spacing(48);

  /// The default selection highlight: the focus color at 20% like iOS.
  static Color selectionColor(HeroThemeData theme) =>
      theme.colors.focus.withValues(alpha: theme.colors.focus.a * 0.2);
}

/// The painted container of a HeroUI field: background, border, field
/// shadow, focus ring (offset 0) and invalid outline, with HeroUI's state
/// transitions.
///
/// This is the styled part of `.input`, `.textarea` and `.input-group`
/// without any editable text, so every field-like component (inputs, input
/// groups, select and combo box triggers, date inputs, ...) shares one
/// implementation:
///
/// * hover (mouse only): `bg-field-hover`, `--field-border-hover`;
/// * focus: `--field-focus`, `--field-border-focus` and a 2 px `--focus`
///   ring with no offset (`status-focused-field`);
/// * invalid: a 1 px `--danger` outline, or a 2 px `--danger` ring while
///   focused (`status-invalid-field`);
/// * disabled: `--disabled-opacity`;
/// * [HeroFieldVariant.secondary]: `--default` backgrounds and no shadow.
///
/// Colors and borders animate over 150 ms `ease`, the ring and shadow over
/// 150 ms `ease-out`, and nothing animates under reduced motion.
class HeroFieldBox extends StatefulWidget {
  /// Paints a field container around [child].
  const HeroFieldBox({
    super.key,
    required this.child,
    this.variant = HeroFieldVariant.primary,
    this.isHovered = false,
    this.isFocused = false,
    this.isInvalid = false,
    this.isDisabled = false,
    this.style,
    this.padding = EdgeInsets.zero,
    this.mouseCursor = MouseCursor.defer,
  });

  /// The field content.
  final Widget child;

  /// The field variant.
  final HeroFieldVariant variant;

  /// Forces the hover look (the box also tracks mouse hover itself).
  final bool isHovered;

  /// Whether the field (or a control inside it) has focus.
  final bool isFocused;

  /// Whether the field is invalid.
  final bool isInvalid;

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Visual overrides.
  final HeroFieldStyle? style;

  /// Padding between the box and [child].
  final EdgeInsetsGeometry padding;

  /// Cursor shown while a mouse hovers the box.
  final MouseCursor mouseCursor;

  @override
  State<HeroFieldBox> createState() => _HeroFieldBoxState();
}

@immutable
class _FieldVisual {
  const _FieldVisual({
    required this.background,
    required this.borderColor,
    required this.ringColor,
    required this.ringWidth,
    required this.shadows,
  });

  final Color background;
  final Color borderColor;
  final Color ringColor;
  final double ringWidth;
  final List<BoxShadow> shadows;

  static _FieldVisual lerp(
    _FieldVisual a,
    _FieldVisual b,
    double colorT,
    double ringT,
  ) {
    return _FieldVisual(
      background: Color.lerp(a.background, b.background, colorT)!,
      borderColor: Color.lerp(a.borderColor, b.borderColor, colorT)!,
      ringColor: Color.lerp(a.ringColor, b.ringColor, ringT)!,
      ringWidth: a.ringWidth + (b.ringWidth - a.ringWidth) * ringT,
      shadows: BoxShadow.lerpList(a.shadows, b.shadows, ringT) ?? const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _FieldVisual &&
      other.background == background &&
      other.borderColor == borderColor &&
      other.ringColor == ringColor &&
      other.ringWidth == ringWidth &&
      listEquals(other.shadows, shadows);

  @override
  int get hashCode => Object.hash(
    background,
    borderColor,
    ringColor,
    ringWidth,
    Object.hashAll(shadows),
  );
}

class _HeroFieldBoxState extends State<HeroFieldBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: HeroMotion.normal,
    value: 1,
  );
  _FieldVisual? _from;
  _FieldVisual? _to;
  bool _hovered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _FieldVisual get _current {
    final _FieldVisual? from = _from;
    if (from == null || _controller.value >= 1) return _to!;
    final double v = _controller.value;
    return _FieldVisual.lerp(
      from,
      _to!,
      HeroMotion.smooth.transform(v),
      HeroMotion.easeOut.transform(v),
    );
  }

  void _retarget(_FieldVisual target, Duration duration) {
    if (_to == null) {
      _to = target;
      return;
    }
    if (target == _to) return;
    if (duration == Duration.zero) {
      _from = null;
      _to = target;
      _controller.value = 1;
      return;
    }
    _from = _current;
    _to = target;
    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  _FieldVisual _resolve(HeroThemeData theme, bool hovered) {
    final HeroColors colors = theme.colors;
    final HeroFieldStyle? style = widget.style;
    final bool secondary = widget.variant == HeroFieldVariant.secondary;
    final bool focused = widget.isFocused;

    final Color restBg =
        style?.backgroundColor ??
        (secondary ? colors.defaultColor : colors.fieldBackground);
    final Color hoverBg =
        style?.hoverBackgroundColor ??
        style?.backgroundColor ??
        (secondary ? colors.defaultHover : colors.fieldHover);
    final Color focusBg =
        style?.focusBackgroundColor ??
        style?.backgroundColor ??
        (secondary ? colors.defaultColor : colors.fieldFocus);
    final Color restBorder = style?.borderColor ?? colors.fieldBorder;
    final Color hoverBorder =
        style?.hoverBorderColor ??
        style?.borderColor ??
        colors.fieldBorderHover;
    final Color focusBorder =
        style?.focusBorderColor ??
        style?.borderColor ??
        colors.fieldBorderFocus;

    final Color ringColor = widget.isInvalid
        ? colors.danger
        : (style?.focusRingColor ?? colors.focus);
    return _FieldVisual(
      background: focused
          ? focusBg
          : hovered
          ? hoverBg
          : widget.isInvalid
          ? focusBg
          : restBg,
      borderColor: focused
          ? focusBorder
          : hovered
          ? hoverBorder
          : restBorder,
      ringColor: focused ? ringColor : ringColor.withValues(alpha: 0),
      ringWidth: focused ? (style?.focusRingWidth ?? theme.focusRingWidth) : 0,
      shadows:
          style?.shadow?.boxShadows ??
          (secondary ? const <BoxShadow>[] : theme.shadows.field.boxShadows),
    );
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool hovered =
        (_hovered || widget.isHovered) &&
        !widget.isFocused &&
        !widget.isDisabled;
    _retarget(
      _resolve(theme, hovered),
      theme.motion.resolve(context, HeroMotion.normal),
    );
    final OutlinedBorder shape = theme.shape(
      widget.style?.borderRadius ??
          BorderRadius.all(Radius.circular(theme.radii.field)),
    );
    final double borderWidth =
        widget.style?.borderWidth ?? theme.fieldBorderWidth;
    final TextDirection? textDirection = Directionality.maybeOf(context);
    final bool showOutline = widget.isInvalid;
    final Color outlineColor = theme.colors.danger;
    final double outlineWidth = theme.spacing(0.25);

    return HeroDisabledOpacity(
      disabled: widget.isDisabled,
      child: MouseRegion(
        cursor: widget.mouseCursor,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              painter: _HeroFieldPainter(
                visual: _current,
                shape: shape,
                borderWidth: borderWidth,
                outlineColor: showOutline ? outlineColor : null,
                outlineWidth: outlineWidth,
                textDirection: textDirection,
              ),
              child: child,
            );
          },
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}

class _HeroFieldPainter extends CustomPainter {
  const _HeroFieldPainter({
    required this.visual,
    required this.shape,
    required this.borderWidth,
    required this.outlineColor,
    required this.outlineWidth,
    required this.textDirection,
  });

  final _FieldVisual visual;
  final OutlinedBorder shape;
  final double borderWidth;
  final Color? outlineColor;
  final double outlineWidth;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path inner = shape.getOuterPath(rect, textDirection: textDirection);

    // Outer box shadows are clipped to the outside of the box, like CSS, so
    // a translucent background (`--field-hover` is 92% opaque) never shows
    // the shadow through.
    if (visual.shadows.isNotEmpty) {
      double extent = 0;
      for (final BoxShadow shadow in visual.shadows) {
        extent = math.max(
          extent,
          shadow.offset.distance + shadow.spreadRadius + shadow.blurRadius * 2,
        );
      }
      canvas
        ..save()
        ..clipPath(
          Path.combine(
            PathOperation.difference,
            Path()..addRect(rect.inflate(extent)),
            inner,
          ),
        );
      for (final BoxShadow shadow in visual.shadows) {
        canvas.drawPath(
          heroInflatedShapePath(
            shape,
            rect.shift(shadow.offset),
            shadow.spreadRadius,
            textDirection,
          ),
          shadow.toPaint(),
        );
      }
      canvas.restore();
    }

    if (visual.ringWidth > 0 && visual.ringColor.a > 0) {
      _paintBand(canvas, rect, inner, visual.ringWidth, visual.ringColor);
    }

    canvas.drawPath(inner, Paint()..color = visual.background);

    if (borderWidth > 0 && visual.borderColor.a > 0) {
      shape
          .copyWith(
            side: BorderSide(color: visual.borderColor, width: borderWidth),
          )
          .paint(canvas, rect, textDirection: textDirection);
    }

    final Color? outline = outlineColor;
    if (outline != null && outlineWidth > 0) {
      _paintBand(canvas, rect, inner, outlineWidth, outline);
    }
  }

  void _paintBand(
    Canvas canvas,
    Rect rect,
    Path inner,
    double width,
    Color color,
  ) {
    final Path outer = heroInflatedShapePath(shape, rect, width, textDirection);
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, inner),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_HeroFieldPainter oldDelegate) =>
      oldDelegate.visual != visual ||
      oldDelegate.shape != shape ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.outlineColor != outlineColor ||
      oldDelegate.outlineWidth != outlineWidth ||
      oldDelegate.textDirection != textDirection;
}
