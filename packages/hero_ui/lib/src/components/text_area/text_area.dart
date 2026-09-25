/// HeroUI's `TextArea`: the primitive multi-line text input.
library;

import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../input/input.dart';

/// Whether and how the user can resize a [HeroTextArea] (CSS `resize`).
enum HeroTextAreaResize {
  /// Fixed size.
  none,

  /// A grip at the bottom-end corner drags the height.
  vertical,
}

/// A primitive multi-line text input (HeroUI `TextArea`).
///
/// It looks and behaves like `HeroInput` (field background and shadow,
/// hover, focus ring, invalid outline, disabled opacity, `text-base` below
/// the `sm` breakpoint and `text-sm` from it) and adds `min-height: 38px`.
/// Its height is [rows] lines plus the padding, or an explicit [height];
/// longer text scrolls. Enter inserts a new line.
///
/// Controlled with [value] + [onChanged], uncontrolled with [defaultValue],
/// or driven by a [controller]. It registers a `FormField<String>` with the
/// nearest `Form` unless an enclosing field root owns the form state.
///
/// ```dart
/// HeroTextArea(
///   semanticLabel: 'Quick project update',
///   width: 384,
///   height: 128,
///   placeholder: 'Share a quick project update...',
/// )
/// ```
class HeroTextArea extends StatefulWidget {
  /// Creates a text area.
  const HeroTextArea({
    super.key,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onTap,
    this.placeholder,
    this.rows = 2,
    this.cols,
    this.variant,
    this.fullWidth = false,
    this.width,
    this.height,
    this.resize = HeroTextAreaResize.none,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid = false,
    this.name,
    this.autofillHints,
    this.maxLength,
    this.minLength,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.validationMessages = const HeroValidationMessages(),
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.autocorrect,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.semanticLabel,
    this.style,
    this.scrollController,
  }) : assert(rows > 0);

  /// Controls the text. When null the text area manages its own controller
  /// (or uses the one of an enclosing [HeroFieldScope]).
  final TextEditingController? controller;

  /// Focus node of the text area.
  final FocusNode? focusNode;

  /// The current value (controlled). Changes are applied to the text.
  final String? value;

  /// The initial value (uncontrolled).
  final String? defaultValue;

  /// Called on every user edit (`onChange`).
  final ValueChanged<String>? onChanged;

  /// Called on each tap on the text area.
  final VoidCallback? onTap;

  /// Text shown while the text area is empty.
  final String? placeholder;

  /// Number of visible lines (`rows`; the browser default is 2).
  final int rows;

  /// Visible width in average characters (`cols`); ignored when [width] or
  /// [fullWidth] is set.
  final int? cols;

  /// Visual variant; null inherits from the enclosing field, then primary.
  final HeroFieldVariant? variant;

  /// Whether the text area takes the full available width.
  final bool fullWidth;

  /// Explicit width; defaults to [HeroFieldMetrics.defaultWidth].
  final double? width;

  /// Explicit height; the text fills it instead of [rows].
  final double? height;

  /// Whether the user can drag the height (`resize`).
  final HeroTextAreaResize resize;

  /// Whether the text area is disabled (`disabled`).
  final bool isDisabled;

  /// Whether the text can be selected but not edited (`readOnly`).
  final bool isReadOnly;

  /// Whether a value is required (`required`).
  final bool isRequired;

  /// Forces the invalid look (`aria-invalid`).
  final bool isInvalid;

  /// The name of the value when a form collects its fields (`name`).
  final String? name;

  /// Autofill hints (`autoComplete`).
  final Iterable<String>? autofillHints;

  /// Maximum number of characters; longer input is truncated (`maxLength`).
  final int? maxLength;

  /// Minimum number of characters (`minLength`, validation).
  final int? minLength;

  /// Additional validation, run after the native constraints.
  final FormFieldValidator<String>? validator;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// When to validate automatically.
  final AutovalidateMode? autovalidateMode;

  /// Messages of the native constraint validation.
  final HeroValidationMessages validationMessages;

  /// Whether to focus the text area when first built.
  final bool autofocus;

  /// Automatic capitalization.
  final TextCapitalization textCapitalization;

  /// Whether autocorrect and suggestions are enabled.
  final bool? autocorrect;

  /// Extra input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Horizontal text alignment.
  final TextAlign textAlign;

  /// Accessibility label (`aria-label`).
  final String? semanticLabel;

  /// Visual overrides (the counterpart of `className`).
  final HeroFieldStyle? style;

  /// Scroll controller of the text.
  final ScrollController? scrollController;

  @override
  State<HeroTextArea> createState() => _HeroTextAreaState();
}

class _HeroTextAreaState extends State<HeroTextArea> {
  /// Height set by dragging the resize grip.
  double? _draggedHeight;

  double _colsWidth(BuildContext context, HeroThemeData theme, int cols) {
    final TextStyle style = HeroFieldMetrics.textStyle(
      context,
    ).merge(widget.style?.textStyle?.copyWith(inherit: true));
    final TextPainter painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final double charWidth = painter.width;
    painter.dispose();
    final EdgeInsets padding =
        (widget.style?.padding ?? HeroFieldMetrics.padding(theme)).resolve(
          Directionality.of(context),
        );
    return cols * charWidth + padding.horizontal;
  }

  void _handleDrag(DragUpdateDetails details) {
    final double current = _draggedHeight ?? context.size!.height;
    final HeroThemeData theme = HeroTheme.of(context);
    setState(() {
      _draggedHeight = math.max(theme.spacing(9.5), current + details.delta.dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final int? cols = widget.cols;
    final double? width =
        widget.width ??
        (cols != null && !widget.fullWidth
            ? _colsWidth(context, theme, cols)
            : null);
    final double? height = _draggedHeight ?? widget.height;
    final bool disabled =
        widget.isDisabled ||
        (HeroFieldScope.maybeOf(context)?.isDisabled ?? false) ||
        HeroDisabledScope.of(context);

    final Widget field = HeroTextInputCore(
      controller: widget.controller,
      focusNode: widget.focusNode,
      value: widget.value,
      defaultValue: widget.defaultValue,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      placeholder: widget.placeholder,
      variant: widget.variant,
      fullWidth: widget.fullWidth,
      width: width,
      height: height,
      minHeight: theme.spacing(9.5),
      maxLines: widget.rows,
      minLines: widget.rows,
      isDisabled: widget.isDisabled,
      isReadOnly: widget.isReadOnly,
      isRequired: widget.isRequired,
      isInvalid: widget.isInvalid,
      name: widget.name,
      autofillHints: widget.autofillHints,
      maxLength: widget.maxLength,
      minLength: widget.minLength,
      validator: widget.validator,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      validationMessages: widget.validationMessages,
      autofocus: widget.autofocus,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      inputFormatters: widget.inputFormatters,
      textAlign: widget.textAlign,
      semanticLabel: widget.semanticLabel,
      style: widget.style,
      scrollController: widget.scrollController,
      debugLabel: 'HeroTextArea',
    );

    if (widget.resize == HeroTextAreaResize.none || disabled) return field;
    return Stack(
      children: <Widget>[
        field,
        PositionedDirectional(
          end: 0,
          bottom: 0,
          child: _HeroResizeGrip(onDrag: _handleDrag),
        ),
      ],
    );
  }
}

/// The resize handle of a vertically resizable text area.
class _HeroResizeGrip extends StatelessWidget {
  const _HeroResizeGrip({required this.onDrag});

  final GestureDragUpdateCallback onDrag;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: onDrag,
        child: SizedBox.square(
          dimension: theme.spacing(4),
          child: CustomPaint(
            painter: _HeroResizeGripPainter(
              color: theme.colors.muted,
              strokeWidth: theme.spacing(0.25),
              inset: theme.spacing(1),
              textDirection: Directionality.of(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroResizeGripPainter extends CustomPainter {
  const _HeroResizeGripPainter({
    required this.color,
    required this.strokeWidth,
    required this.inset,
    required this.textDirection,
  });

  final Color color;
  final double strokeWidth;
  final double inset;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final double corner = size.width - inset;
    final double long = corner - inset;
    final double short = long / 2;
    final bool rtl = textDirection == TextDirection.rtl;
    double x(double value) => rtl ? size.width - value : value;
    // Two diagonal strokes pointing at the bottom-end corner.
    canvas
      ..drawLine(
        Offset(x(corner - long), corner),
        Offset(x(corner), corner - long),
        paint,
      )
      ..drawLine(
        Offset(x(corner - short), corner),
        Offset(x(corner), corner - short),
        paint,
      );
  }

  @override
  bool shouldRepaint(_HeroResizeGripPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.inset != inset ||
      oldDelegate.textDirection != textDirection;
}
