import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/hero_field.dart';
import '../input/hero_text_constraints.dart';

// Shared primitives of HeroUI's toggle fields: Checkbox, CheckboxGroup,
// Radio / RadioGroup and Switch.

/// Builds the parts of a toggle field's pressable content from its
/// interaction state (React Aria's `CheckboxButtonRenderProps`,
/// `RadioButtonRenderProps` and `SwitchButtonRenderProps`).
typedef HeroToggleContentBuilder =
    List<Widget> Function(BuildContext context, HeroInteractionState state);

/// Shares the interaction state of a toggle field's pressable content
/// (`Checkbox.Content`, `Radio.Content`, `Switch.Content`) with the control
/// inside it.
///
/// It stands in for the `[data-slot="…-content"][data-hovered="true"]`,
/// `[data-pressed]` and `[data-focus-visible]` ancestor selectors of the
/// control's CSS.
class HeroToggleInteractionScope extends InheritedWidget {
  /// Publishes [state] to [child].
  const HeroToggleInteractionScope({
    super.key,
    required this.state,
    required super.child,
  });

  /// The content's interaction state, with `isSelected` set to the field's
  /// selection.
  final HeroInteractionState state;

  /// The closest content state, or [HeroInteractionState.idle] outside a
  /// toggle field's content.
  static HeroInteractionState of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<HeroToggleInteractionScope>()
          ?.state ??
      HeroInteractionState.idle;

  @override
  bool updateShouldNotify(HeroToggleInteractionScope oldWidget) =>
      state != oldWidget.state;
}

/// The pressable row of a toggle field (`.checkbox__content`,
/// `.radio__content`, `.switch__content`): the control and its label in an
/// inline row with a 12 px gap, `text-sm font-medium` in `--foreground`.
///
/// It is the counterpart of React Aria's `CheckboxButton`, `RadioButton` and
/// `SwitchButton`: a single focusable, pressable node that activates on tap
/// and Space (not Enter, like a native checkbox) and shares its interaction
/// state with the control through [HeroToggleInteractionScope]. The field
/// roots (`HeroCheckboxContent`, `HeroRadioContent`, `HeroSwitchContent`)
/// configure it; it is not used directly.
class HeroToggleFieldContent extends StatelessWidget {
  /// Creates the pressable content of a toggle field.
  const HeroToggleFieldContent({
    super.key,
    required this.isSelected,
    this.onPressed,
    this.children,
    this.builder,
    this.isDisabled = false,
    this.focusNode,
    this.autofocus = false,
    this.canRequestFocus = true,
    this.onFocusChanged,
    this.shortcuts,
    this.semanticLabel,
    this.semanticHint,
    this.semanticsBuilder,
    this.spacing,
    this.padding,
    this.decoration,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.fullWidth = false,
  });

  /// Whether the field is selected (reported to [builder] and the control).
  final bool isSelected;

  /// Called when the content is pressed; null ignores presses (read-only).
  final VoidCallback? onPressed;

  /// The parts: the control and the label, in reading order.
  final List<Widget>? children;

  /// Builds the parts from the interaction state; wins over [children].
  final HeroToggleContentBuilder? builder;

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Focus node of the content.
  final FocusNode? focusNode;

  /// Whether to focus the content when first built.
  final bool autofocus;

  /// Whether the content takes part in focus traversal.
  final bool canRequestFocus;

  /// Called when the content gains or loses focus.
  final ValueChanged<bool>? onFocusChanged;

  /// Extra keyboard shortcuts active while the content has focus.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Accessibility label; defaults to the text inside the content.
  final String? semanticLabel;

  /// Accessibility hint (the field's description and error).
  final String? semanticHint;

  /// Wraps the content in the field's semantics flags (checked, toggled,
  /// ...), merged into the content's node.
  final Widget Function(Widget child)? semanticsBuilder;

  /// Gap between the parts; defaults to 12 (`gap-3`).
  final double? spacing;

  /// Padding around the parts (card-style contents).
  final EdgeInsetsGeometry? padding;

  /// Decoration behind the parts, resolved with the content's
  /// [WidgetState]s (`hovered`, `pressed`, `focused`, `selected`,
  /// `disabled`).
  final WidgetStateProperty<Decoration?>? decoration;

  /// Vertical alignment of the parts (`items-center` by default).
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the content fills the available width (`w-full`).
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return HeroInteractable(
      onPressed: onPressed,
      isDisabled: isDisabled,
      focusNode: focusNode,
      autofocus: autofocus,
      canRequestFocus: canRequestFocus,
      onFocusChanged: onFocusChanged,
      isButton: false,
      semanticsLabel: semanticLabel,
      semanticsHint: semanticHint,
      // A checkbox, radio or switch activates with Space only.
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.enter):
            const DoNothingAndStopPropagationIntent(),
        const SingleActivator(LogicalKeyboardKey.numpadEnter):
            const DoNothingAndStopPropagationIntent(),
        ...?shortcuts,
      },
      builder: _buildContent,
    );
  }

  Widget _buildContent(
    BuildContext context,
    HeroInteractionState interaction,
    Widget? _,
  ) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroInteractionState state = interaction.copyWith(
      isSelected: isSelected,
    );
    final List<Widget> parts =
        builder?.call(context, state) ?? children ?? const <Widget>[];

    Widget result = HeroInlineFlexRow(
      spacing: spacing ?? theme.spacing(3),
      crossAxisAlignment: crossAxisAlignment,
      fullWidth: fullWidth,
      children: parts,
    );
    result = DefaultTextStyle(
      style: theme.typography
          .style(HeroFontSize.sm, weight: HeroTypography.medium)
          .copyWith(color: theme.colors.foreground),
      child: result,
    );

    final WidgetStateProperty<Decoration?>? decoration = this.decoration;
    if (padding != null || decoration != null) {
      // `transition-all` with Tailwind's default 150 ms curve.
      result = AnimatedContainer(
        duration: theme.motion.resolve(context, HeroMotion.normal),
        curve: HeroMotion.easeInOut,
        padding: padding,
        decoration: decoration?.resolve(state.widgetStates),
        child: result,
      );
    }

    result = HeroToggleInteractionScope(state: state, child: result);
    return semanticsBuilder?.call(result) ?? result;
  }
}

/// A row laid out like a CSS `inline-flex` container: the children keep
/// their natural width while it fits and shrink together (never below their
/// minimum intrinsic width) when it does not, so a long label wraps next to
/// a fixed-size control instead of overflowing.
///
/// Children wrapped in [Flexible] or [Expanded] grow into the free space of
/// a bounded row (`flex-1`). With [fullWidth] the row fills a bounded width
/// (`w-full`).
class HeroInlineFlexRow extends MultiChildRenderObjectWidget {
  /// Lays [children] out in a row.
  const HeroInlineFlexRow({
    super.key,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.fullWidth = false,
    super.children,
  });

  /// Gap between the children.
  final double spacing;

  /// Vertical alignment of the children (start, center or end).
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the row fills a bounded width.
  final bool fullWidth;

  @override
  RenderHeroInlineFlexRow createRenderObject(BuildContext context) =>
      RenderHeroInlineFlexRow(
        spacing: spacing,
        crossAxisAlignment: crossAxisAlignment,
        fullWidth: fullWidth,
        textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHeroInlineFlexRow renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..crossAxisAlignment = crossAxisAlignment
      ..fullWidth = fullWidth
      ..textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
  }
}

/// The render object of a [HeroInlineFlexRow].
class RenderHeroInlineFlexRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {
  /// Creates an inline flex row.
  RenderHeroInlineFlexRow({
    double spacing = 0,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    bool fullWidth = false,
    TextDirection textDirection = TextDirection.ltr,
  }) : _spacing = spacing,
       _crossAxisAlignment = crossAxisAlignment,
       _fullWidth = fullWidth,
       _textDirection = textDirection;

  /// Gap between the children.
  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  /// Vertical alignment of the children.
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  set crossAxisAlignment(CrossAxisAlignment value) {
    if (value == _crossAxisAlignment) return;
    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  /// Whether the row fills a bounded width.
  bool get fullWidth => _fullWidth;
  bool _fullWidth;
  set fullWidth(bool value) {
    if (value == _fullWidth) return;
    _fullWidth = value;
    markNeedsLayout();
  }

  /// The direction that decides where the row starts.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  List<RenderBox> get _children {
    final List<RenderBox> result = <RenderBox>[];
    RenderBox? child = firstChild;
    while (child != null) {
      result.add(child);
      child = childAfter(child);
    }
    return result;
  }

  static int _flexOf(RenderBox child) =>
      (child.parentData! as FlexParentData).flex ?? 0;

  double get _gaps => childCount > 1 ? (childCount - 1) * _spacing : 0;

  /// The width of every child for an available [maxWidth], following the
  /// CSS flexbox algorithm with `flex-shrink: 1` and `flex-basis: auto`
  /// (growing children have `flex: 1 1 0`).
  List<double> _widths(List<RenderBox> children, double maxWidth) {
    final int count = children.length;
    final List<double> base = <double>[
      for (final RenderBox child in children)
        _flexOf(child) > 0 && maxWidth.isFinite
            ? 0
            : child.getMaxIntrinsicWidth(double.infinity),
    ];
    if (!maxWidth.isFinite) return base;
    final List<double> min = <double>[
      for (int i = 0; i < count; i++)
        base[i] == 0 ? 0 : children[i].getMinIntrinsicWidth(double.infinity),
    ];
    final double natural = base.fold<double>(_gaps, (double a, double b) {
      return a + b;
    });
    final List<double> widths = List<double>.of(base);
    if (natural <= maxWidth) {
      final int totalFlex = children.fold<int>(
        0,
        (int sum, RenderBox child) => sum + _flexOf(child),
      );
      if (totalFlex > 0) {
        final double free = maxWidth - natural;
        for (int i = 0; i < count; i++) {
          final int flex = _flexOf(children[i]);
          if (flex > 0) widths[i] = free * flex / totalFlex;
        }
      }
      return widths;
    }
    // Shrink proportionally to the base sizes, freezing children that reach
    // their minimum width, until the row fits.
    final List<bool> frozen = <bool>[
      for (int i = 0; i < count; i++) base[i] <= min[i],
    ];
    while (true) {
      double used = _gaps;
      double scaled = 0;
      for (int i = 0; i < count; i++) {
        if (frozen[i]) {
          used += widths[i];
        } else {
          used += base[i];
          scaled += base[i];
        }
      }
      final double overflow = used - maxWidth;
      if (overflow <= 0 || scaled <= 0) {
        for (int i = 0; i < count; i++) {
          if (!frozen[i]) widths[i] = base[i];
        }
        break;
      }
      bool clamped = false;
      for (int i = 0; i < count; i++) {
        if (frozen[i]) continue;
        final double target = base[i] - overflow * base[i] / scaled;
        if (target < min[i]) {
          widths[i] = min[i];
          frozen[i] = true;
          clamped = true;
        } else {
          widths[i] = target;
        }
      }
      if (!clamped) break;
    }
    return widths;
  }

  BoxConstraints _childConstraints(
    RenderBox child,
    double width,
    double maxHeight,
  ) {
    return _flexOf(child) > 0 && width.isFinite
        ? BoxConstraints(minWidth: width, maxWidth: width, maxHeight: maxHeight)
        : BoxConstraints(maxWidth: width, maxHeight: maxHeight);
  }

  bool _fills(List<RenderBox> children, BoxConstraints constraints) =>
      constraints.hasBoundedWidth &&
      (_fullWidth || children.any((RenderBox c) => _flexOf(c) > 0));

  @override
  double computeMinIntrinsicWidth(double height) {
    double total = _gaps;
    for (final RenderBox child in _children) {
      total += child.getMinIntrinsicWidth(height);
    }
    return total;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double total = _gaps;
    for (final RenderBox child in _children) {
      total += child.getMaxIntrinsicWidth(height);
    }
    return total;
  }

  double _intrinsicHeight(
    double width,
    double Function(RenderBox child, double width) height,
  ) {
    final List<RenderBox> children = _children;
    final List<double> widths = _widths(children, width);
    double result = 0;
    for (int i = 0; i < children.length; i++) {
      result = math.max(result, height(children[i], widths[i]));
    }
    return result;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(
    width,
    (RenderBox child, double w) => child.getMinIntrinsicHeight(w),
  );

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(
    width,
    (RenderBox child, double w) => child.getMaxIntrinsicHeight(w),
  );

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToHighestActualBaseline(baseline);

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final List<RenderBox> children = _children;
    if (children.isEmpty) return constraints.smallest;
    final List<double> widths = _widths(children, constraints.maxWidth);
    double x = 0;
    double height = 0;
    for (int i = 0; i < children.length; i++) {
      final Size size = children[i].getDryLayout(
        _childConstraints(children[i], widths[i], constraints.maxHeight),
      );
      x += math.max(size.width, widths[i]);
      height = math.max(height, size.height);
    }
    x += _gaps;
    final double width = _fills(children, constraints)
        ? constraints.maxWidth
        : x;
    return constraints.constrain(Size(width, height));
  }

  @override
  void performLayout() {
    final List<RenderBox> children = _children;
    if (children.isEmpty) {
      size = constraints.smallest;
      return;
    }
    final List<double> widths = _widths(children, constraints.maxWidth);
    final List<double> slots = <double>[];
    double contentWidth = _gaps;
    double height = 0;
    for (int i = 0; i < children.length; i++) {
      final RenderBox child = children[i];
      child.layout(
        _childConstraints(child, widths[i], constraints.maxHeight),
        parentUsesSize: true,
      );
      final double slot = math.max(child.size.width, widths[i]);
      slots.add(slot);
      contentWidth += slot;
      height = math.max(height, child.size.height);
    }
    final double width = _fills(children, constraints)
        ? constraints.maxWidth
        : contentWidth;
    size = constraints.constrain(Size(width, height));

    final bool rtl = _textDirection == TextDirection.rtl;
    double x = 0;
    for (int i = 0; i < children.length; i++) {
      final RenderBox child = children[i];
      final double y = switch (_crossAxisAlignment) {
        CrossAxisAlignment.start ||
        CrossAxisAlignment.stretch ||
        CrossAxisAlignment.baseline => 0,
        CrossAxisAlignment.center => (size.height - child.size.height) / 2,
        CrossAxisAlignment.end => size.height - child.size.height,
      };
      final double dx = rtl ? size.width - x - child.size.width : x;
      (child.parentData! as FlexParentData).offset = Offset(dx, y);
      x += slots[i] + _spacing;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Wraps the help text parts placed directly in a toggle field root
/// ([HeroDescription] and [HeroFieldError]) so they are indented by
/// [indent] under the label, and dimmed once more while the field
/// [isDisabled] (HeroUI applies `status-disabled` to both the field and its
/// help text).
List<Widget> heroToggleFieldParts(
  List<Widget> parts, {
  required double indent,
  required bool isDisabled,
}) {
  return <Widget>[
    for (final Widget part in parts)
      if (part is HeroDescription || part is HeroFieldError)
        HeroFieldHelpTextScope(
          indent: indent,
          child: HeroDisabledOpacity(disabled: isDisabled, child: part),
        )
      else
        part,
  ];
}

/// The accessibility hint of a toggle field (`aria-describedby`): the text
/// of the [HeroDescription] placed directly in the field, and while the
/// field is invalid the text of its [HeroFieldError] (or the validation
/// messages).
String? heroToggleFieldHint(
  List<Widget> parts,
  HeroValidationResult validation, {
  String? description,
  String? errorMessage,
}) {
  String? describedBy = description;
  String? error = errorMessage;
  bool hasError = false;
  for (final Widget part in parts) {
    if (part is HeroDescription) describedBy ??= part.data;
    if (part is HeroFieldError) {
      hasError = true;
      error ??= part.data;
    }
  }
  if (validation.isInvalid && (hasError || errorMessage != null)) {
    error ??= validation.validationErrors.join(' ');
  } else {
    error = null;
  }
  final String hint = <String?>[
    describedBy,
    error,
  ].whereType<String>().where((String s) => s.isNotEmpty).join('\n');
  return hint.isEmpty ? null : hint;
}

/// Builds a field from the validation it displays.
typedef HeroValidatedFieldBuilder =
    Widget Function(BuildContext context, HeroValidationResult validation);

/// The form integration of HeroUI's toggle fields (Checkbox, CheckboxGroup,
/// RadioGroup, Switch): a `FormField<T>` registered with the nearest `Form`
/// that decides which validation is displayed.
///
/// The field root owns the value and reports user changes with
/// [HeroValidatedFieldState.didChange]. The displayed validation follows
/// React Aria:
///
/// * [isInvalid] true or false overrides everything;
/// * server-side [validationErrors] (or the [HeroForm]'s errors for [name])
///   show immediately and clear once the user changes the value;
/// * with [HeroValidationBehavior.native] (the default) the [validator] and
///   the built-in [isRequired] rule show once the user changed the value or
///   the form was validated (every toggle commits the value), and they block
///   submission;
/// * with [HeroValidationBehavior.aria] the [validator] shows in realtime
///   and [isRequired] is only announced.
///
/// When the form is saved, the value (or [formValue] of it; null omits it)
/// is added to the [HeroForm] data under [name]. When the form is reset,
/// [onReset] lets the root restore its initial value.
class HeroValidatedField<T> extends StatefulWidget {
  /// Creates the form integration of a toggle field.
  const HeroValidatedField({
    super.key,
    required this.value,
    required this.builder,
    this.name,
    this.formValue,
    this.onReset,
    this.isDisabled = false,
    this.isRequired = false,
    this.isValueMissing,
    this.valueMissingMessage,
    this.isInvalid,
    this.errorMessage,
    this.validator,
    this.validationBehavior,
    this.validationErrors,
    this.validationMessages = const HeroValidationMessages(),
    this.onSaved,
    this.autovalidateMode,
  });

  /// The current value of the field.
  final T value;

  /// Builds the field from the displayed validation.
  final HeroValidatedFieldBuilder builder;

  /// The name of the value in the [HeroForm] data and of its server errors.
  final String? name;

  /// The value submitted for [value]; null leaves the field out of the
  /// data (an unchecked checkbox). Defaults to the value itself.
  final Object? Function(T value)? formValue;

  /// Called when the enclosing form is reset.
  final VoidCallback? onReset;

  /// Whether the field is disabled: it neither validates nor submits.
  final bool isDisabled;

  /// Whether a value is required.
  final bool isRequired;

  /// Whether [value] counts as missing for [isRequired].
  final bool Function(T value)? isValueMissing;

  /// The message of a missing required value; defaults to
  /// [HeroValidationMessages.valueMissing].
  final String? valueMissingMessage;

  /// Overrides the displayed validation: true invalid, false valid.
  final bool? isInvalid;

  /// The message that blocks submission while [isInvalid] is true.
  final String? errorMessage;

  /// Custom validation (`validate`): an error message or null.
  final FormFieldValidator<T>? validator;

  /// When errors show; null inherits the [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors; override the form's errors for [name].
  final List<String>? validationErrors;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<T>? onSaved;

  /// When the native behaviour shows errors before any change.
  final AutovalidateMode? autovalidateMode;

  @override
  State<HeroValidatedField<T>> createState() => HeroValidatedFieldState<T>();
}

/// The state of a [HeroValidatedField].
class HeroValidatedFieldState<T> extends State<HeroValidatedField<T>> {
  final GlobalKey<_HeroValidatedFormFieldState<T>> _fieldKey =
      GlobalKey<_HeroValidatedFormFieldState<T>>();
  late final T _initialValue = widget.value;

  /// Whether the native behaviour shows the validation (after a change or a
  /// form validation).
  bool _committed = false;

  HeroValidationBehavior _behavior = HeroValidationBehavior.native;
  List<String> _serverErrors = const <String>[];
  Object? _serverSource;
  bool _serverErrorsCleared = false;

  List<String> get _activeServerErrors =>
      _serverErrorsCleared ? const <String>[] : _serverErrors;

  /// Reports that the user changed the value to [value]: commits the
  /// validation, clears server errors and notifies the form.
  void didChange(T value) {
    _committed = true;
    _serverErrorsCleared = true;
    _fieldKey.currentState?.didChange(value);
  }

  @override
  void didUpdateWidget(HeroValidatedField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fieldKey.currentState?.syncValue(widget.value);
  }

  HeroValidationResult _clientValidation(T value) {
    final String? error = widget.validator?.call(value);
    if (error != null) return HeroValidationResult.invalid(<String>[error]);
    if (_behavior == HeroValidationBehavior.aria) {
      return HeroValidationResult.valid;
    }
    if (widget.isRequired && (widget.isValueMissing?.call(value) ?? false)) {
      return HeroValidationResult.invalid(<String>[
        widget.valueMissingMessage ?? widget.validationMessages.valueMissing,
      ]);
    }
    return HeroValidationResult.valid;
  }

  String? _validate(T? _) {
    if (widget.isDisabled) return null;
    if (widget.isInvalid ?? false) {
      return widget.errorMessage ?? widget.validationMessages.invalidValue;
    }
    final List<String> server = _activeServerErrors;
    if (server.isNotEmpty) return server.join(' ');
    final HeroValidationResult client = _clientValidation(widget.value);
    return client.isInvalid ? client.validationErrors.join(' ') : null;
  }

  void _handleSaved(T? _) {
    final T value = widget.value;
    widget.onSaved?.call(value);
    final String? name = widget.name;
    if (name == null || widget.isDisabled) return;
    final Object? data = widget.formValue == null
        ? value
        : widget.formValue!(value);
    if (data == null) return;
    context.findAncestorStateOfType<HeroFormState>()?.addValue(name, data);
  }

  void _handleReset() {
    _committed = false;
    _serverErrorsCleared = true;
    widget.onReset?.call();
  }

  bool _autovalidates(FormFieldState<T> field) {
    return switch (widget.autovalidateMode ?? AutovalidateMode.disabled) {
      AutovalidateMode.always => true,
      AutovalidateMode.onUserInteraction ||
      AutovalidateMode.onUserInteractionIfError => field.hasInteractedByUser,
      AutovalidateMode.onUnfocus || AutovalidateMode.disabled => false,
    };
  }

  HeroValidationResult _display(FormFieldState<T> field) {
    final bool? forced = widget.isInvalid;
    if (forced != null) {
      return forced
          ? const HeroValidationResult.invalid()
          : HeroValidationResult.valid;
    }
    if (widget.isDisabled) return HeroValidationResult.valid;
    final List<String> server = _activeServerErrors;
    if (server.isNotEmpty) return HeroValidationResult.invalid(server);
    if (_behavior == HeroValidationBehavior.aria ||
        _committed ||
        _autovalidates(field)) {
      return _clientValidation(widget.value);
    }
    return HeroValidationResult.valid;
  }

  void _resolveFormState(HeroFormState? form) {
    _behavior =
        widget.validationBehavior ??
        form?.validationBehavior ??
        HeroValidationBehavior.native;
    final Object? source =
        widget.validationErrors ?? form?.widget.validationErrors;
    if (!identical(source, _serverSource)) {
      _serverSource = source;
      _serverErrorsCleared = false;
    }
    _serverErrors =
        widget.validationErrors ??
        form?.validationErrorsFor(widget.name) ??
        const <String>[];
  }

  @override
  Widget build(BuildContext context) {
    _resolveFormState(HeroForm.maybeOf(context));
    return _HeroValidatedFormField<T>(
      key: _fieldKey,
      initialValue: _initialValue,
      validator: _validate,
      onSaved: _handleSaved,
      onReset: _handleReset,
      onValidate: () => _committed = true,
      enabled: !widget.isDisabled,
      builder: (FormFieldState<T> field) =>
          widget.builder(field.context, _display(field)),
    );
  }
}

class _HeroValidatedFormField<T> extends FormField<T> {
  const _HeroValidatedFormField({
    super.key,
    required super.builder,
    required this.onValidate,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.onReset,
    super.enabled,
  });

  /// Called before the field validates (form submission).
  final VoidCallback onValidate;

  @override
  FormFieldState<T> createState() => _HeroValidatedFormFieldState<T>();
}

class _HeroValidatedFormFieldState<T> extends FormFieldState<T> {
  @override
  _HeroValidatedFormField<T> get widget =>
      super.widget as _HeroValidatedFormField<T>;

  @override
  bool validate() {
    widget.onValidate();
    return super.validate();
  }

  /// Updates the value without notifying the form (a controlled update).
  void syncValue(T value) {
    if (this.value != value) setValue(value);
  }
}
