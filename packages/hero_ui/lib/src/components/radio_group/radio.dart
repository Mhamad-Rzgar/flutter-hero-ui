import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../checkbox/toggle_field.dart';
import '../description/description.dart';
import '../input/hero_field.dart';
import '../text_field/hero_field_layout.dart';
import 'radio_group_scope.dart';

/// The render props of a [HeroRadio] (React Aria's `RadioFieldRenderProps`),
/// passed to [HeroRadio.builder] and [HeroRadioIndicator.builder].
@immutable
class HeroRadioState {
  /// Creates radio render props.
  const HeroRadioState({
    this.isSelected = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isInvalid = false,
    this.isRequired = false,
  });

  /// Whether the radio is the selected one of its group.
  final bool isSelected;

  /// Whether the radio is disabled.
  final bool isDisabled;

  /// Whether the group is read-only.
  final bool isReadOnly;

  /// Whether the group currently shows as invalid.
  final bool isInvalid;

  /// Whether the group requires a selection.
  final bool isRequired;

  @override
  bool operator ==(Object other) =>
      other is HeroRadioState &&
      other.isSelected == isSelected &&
      other.isDisabled == isDisabled &&
      other.isReadOnly == isReadOnly &&
      other.isInvalid == isInvalid &&
      other.isRequired == isRequired;

  @override
  int get hashCode =>
      Object.hash(isSelected, isDisabled, isReadOnly, isInvalid, isRequired);

  @override
  String toString() =>
      'HeroRadioState(${<String>[if (isSelected) 'selected', if (isDisabled) 'disabled', if (isReadOnly) 'read-only', if (isInvalid) 'invalid', if (isRequired) 'required'].join(', ')})';
}

/// Builds the parts of a [HeroRadio] from its state.
typedef HeroRadioBuilder =
    List<Widget> Function(BuildContext context, HeroRadioState state);

/// Builds the content of a [HeroRadioIndicator] from the radio state; null
/// shows nothing.
typedef HeroRadioIndicatorBuilder =
    Widget? Function(BuildContext context, HeroRadioState state);

/// One option of a `HeroRadioGroup` (HeroUI `Radio`): a [HeroRadioContent]
/// (the pressable row holding the [HeroRadioControl] and the label) with an
/// optional [HeroDescription] (indented under the label) and
/// `HeroFieldError`.
///
/// ```dart
/// const HeroRadio(
///   value: 'premium',
///   label: 'Premium Plan',
///   description: 'Includes 200 messages per month',
/// )
/// ```
///
/// Pressing the content (or Space) selects the radio; the arrow keys move
/// the selection within the group. The group's variant, read-only, required
/// and invalid states apply; [isDisabled] disables this radio only.
class HeroRadio extends StatefulWidget {
  /// Creates a radio for [value].
  const HeroRadio({
    super.key,
    required this.value,
    this.children,
    this.builder,
    this.label,
    this.description,
    this.isDisabled = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// The value the group takes when this radio is selected.
  final String value;

  /// The parts of the radio ([HeroRadioContent], [HeroDescription],
  /// `HeroFieldError`). When null (and [builder] is null) the radio builds
  /// them from [label] and [description].
  final List<Widget>? children;

  /// Builds the parts from the radio state; wins over [children].
  final HeroRadioBuilder? builder;

  /// Label text of the built radio.
  final String? label;

  /// Description text of the built radio.
  final String? description;

  /// Whether this radio is disabled (the group can disable all of them).
  final bool isDisabled;

  /// Focus node of the pressable content.
  final FocusNode? focusNode;

  /// Whether to focus the radio when first built.
  final bool autofocus;

  /// Accessibility label (`aria-label`), for a radio without a label.
  final String? semanticLabel;

  @override
  State<HeroRadio> createState() => _HeroRadioState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('value', value))
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroRadioState extends State<HeroRadio> {
  FocusNode? _ownFocusNode;
  HeroRadioGroupScope? _group;
  HeroRadioRegistration? _registration;

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroRadio'));

  bool get _enabled =>
      !widget.isDisabled && !(_group?.isDisabled ?? false) && mounted;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = HeroRadioGroupScope.maybeOf(context);
    assert(_group != null, 'A HeroRadio must be placed in a HeroRadioGroup.');
    _register();
  }

  @override
  void didUpdateWidget(HeroRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.focusNode != widget.focusNode) {
      _register();
    }
  }

  @override
  void dispose() {
    _unregister();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _register() {
    final HeroRadioGroupScope? group = _group;
    final HeroRadioRegistration? current = _registration;
    if (current != null &&
        identical(current.controller, group?.controller) &&
        current.value == widget.value &&
        identical(current.focusNode, _focusNode)) {
      return;
    }
    _unregister();
    if (group == null) return;
    final HeroRadioRegistration registration = HeroRadioRegistration(
      controller: group.controller,
      value: widget.value,
      focusNode: _focusNode,
      isEnabled: () => _enabled,
    );
    group.controller.registerRadio(registration);
    _registration = registration;
  }

  void _unregister() {
    final HeroRadioRegistration? registration = _registration;
    if (registration == null) return;
    registration.controller.unregisterRadio(registration);
    _registration = null;
  }

  void _select() => _group?.controller.select(widget.value);

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroRadioGroupScope group = _group!;
    final bool disabled = widget.isDisabled || group.isDisabled;
    final bool readOnly = group.isReadOnly;
    final HeroRadioState state = HeroRadioState(
      isSelected: group.value == widget.value,
      isDisabled: disabled,
      isReadOnly: readOnly,
      isInvalid: group.isInvalid,
      isRequired: group.isRequired,
    );
    // Roving focus: only one radio of the group is a Tab stop (the
    // selected one, or the first enabled one).
    final String? tabStop = group.tabStopValue;
    if (widget.focusNode == null) {
      _focusNode.skipTraversal = tabStop != null && tabStop != widget.value;
    }

    final List<Widget> parts =
        widget.builder?.call(context, state) ??
        widget.children ??
        _defaultParts();
    final HeroValidationResult validation = group.isInvalid
        ? HeroValidationResult.invalid(group.validationErrors)
        : HeroValidationResult.valid;
    final String? hint = heroToggleFieldHint(parts, validation);

    Widget result = HeroFieldLayout(
      spacing: theme.spacing(1),
      stretch: false,
      children: heroToggleFieldParts(
        parts,
        indent: theme.spacing(7),
        isDisabled: disabled,
      ),
    );
    result = HeroDisabledOpacity(disabled: disabled, child: result);
    if (group.orientation == Axis.vertical) {
      result = Padding(padding: group.itemMargin, child: result);
    }

    final VoidCallback? select = disabled || readOnly ? null : _select;
    return HeroRadioScope(
      state: state,
      variant: group.variant,
      onSelect: select,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onFocused: () => group.controller.handleRadioFocused(widget.value),
      semanticLabel: widget.semanticLabel,
      semanticHint: hint,
      child: HeroFieldScope(
        variant: group.variant,
        isDisabled: disabled,
        isInvalid: group.isInvalid,
        validationErrors: group.validationErrors,
        isRequired: group.isRequired,
        isReadOnly: readOnly,
        showRequiredIndicator: false,
        focusNode: _focusNode,
        onLabelPressed: select,
        semanticLabel: widget.semanticLabel,
        semanticHint: hint,
        child: result,
      ),
    );
  }

  List<Widget> _defaultParts() {
    final String? label = widget.label;
    final String? description = widget.description;
    return <Widget>[
      HeroRadioContent(
        children: <Widget>[
          const HeroRadioControl(),
          if (label != null) Text(label),
        ],
      ),
      if (description != null) HeroDescription.text(description),
    ];
  }
}

/// Shares the state of a [HeroRadio] with its parts ([HeroRadioContent],
/// [HeroRadioControl], [HeroRadioIndicator]).
class HeroRadioScope extends InheritedWidget {
  /// Publishes a radio's state to [child].
  const HeroRadioScope({
    super.key,
    required this.state,
    required this.variant,
    required super.child,
    this.onSelect,
    this.focusNode,
    this.autofocus = false,
    this.onFocused,
    this.semanticLabel,
    this.semanticHint,
  });

  /// The radio's render props.
  final HeroRadioState state;

  /// The group's variant.
  final HeroFieldVariant variant;

  /// Selects the radio; null while disabled or read-only.
  final VoidCallback? onSelect;

  /// Focus node of the content.
  final FocusNode? focusNode;

  /// Whether the content takes focus when first built.
  final bool autofocus;

  /// Called when the content receives focus.
  final VoidCallback? onFocused;

  /// Accessibility label of the radio.
  final String? semanticLabel;

  /// Accessibility hint of the radio (description and error).
  final String? semanticHint;

  /// The closest radio scope, or null outside a [HeroRadio].
  static HeroRadioScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroRadioScope>();

  /// The closest radio scope.
  static HeroRadioScope of(BuildContext context) {
    final HeroRadioScope? scope = maybeOf(context);
    assert(
      scope != null,
      'Radio parts (HeroRadioContent, HeroRadioControl, HeroRadioIndicator) '
      'must be placed inside a HeroRadio.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(HeroRadioScope oldWidget) =>
      state != oldWidget.state ||
      variant != oldWidget.variant ||
      onSelect != oldWidget.onSelect ||
      focusNode != oldWidget.focusNode ||
      autofocus != oldWidget.autofocus ||
      semanticLabel != oldWidget.semanticLabel ||
      semanticHint != oldWidget.semanticHint;
}

/// The pressable row of a [HeroRadio] (HeroUI `Radio.Content`): the
/// [HeroRadioControl] and the label text in an inline row with a 12 px gap,
/// `text-sm font-medium`.
///
/// Pressing it (or Space while it has focus) selects the radio. It is the
/// radio's accessibility node. [padding], [decoration],
/// [crossAxisAlignment] and [fullWidth] style card-like radios; the
/// [builder] receives the hover, press, focus and selection state.
class HeroRadioContent extends StatelessWidget {
  /// Creates the content of a radio.
  const HeroRadioContent({
    super.key,
    this.children,
    this.builder,
    this.spacing,
    this.padding,
    this.decoration,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.fullWidth = false,
  });

  /// The parts: usually a [HeroRadioControl] and a [Text].
  final List<Widget>? children;

  /// Builds the parts from the interaction state; wins over [children].
  final HeroToggleContentBuilder? builder;

  /// Gap between the parts; defaults to 12 (`gap-3`).
  final double? spacing;

  /// Padding around the parts.
  final EdgeInsetsGeometry? padding;

  /// Decoration behind the parts, resolved with the content's states
  /// (`selected`, `hovered`, `pressed`, `focused`, `disabled`).
  final WidgetStateProperty<Decoration?>? decoration;

  /// Vertical alignment of the parts; centred by default.
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the content fills the available width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final HeroRadioScope scope = HeroRadioScope.of(context);
    final HeroRadioState state = scope.state;
    return HeroToggleFieldContent(
      isSelected: state.isSelected,
      onPressed: scope.onSelect,
      isDisabled: state.isDisabled,
      focusNode: scope.focusNode,
      autofocus: scope.autofocus,
      onFocusChanged: (bool focused) {
        if (focused) scope.onFocused?.call();
      },
      semanticLabel: scope.semanticLabel,
      semanticHint: scope.semanticHint,
      spacing: spacing,
      padding: padding,
      decoration: decoration,
      crossAxisAlignment: crossAxisAlignment,
      fullWidth: fullWidth,
      builder: builder,
      semanticsBuilder: (Widget child) => Semantics(
        checked: state.isSelected,
        inMutuallyExclusiveGroup: true,
        readOnly: state.isReadOnly ? true : null,
        isRequired: state.isRequired ? true : null,
        validationResult: state.isInvalid
            ? SemanticsValidationResult.invalid
            : SemanticsValidationResult.none,
        child: child,
      ),
      children: children,
    );
  }
}

/// The circle of a [HeroRadio] (HeroUI `Radio.Control`): 16 px with
/// `rounded-lg` corners (a circle), `--field-background` and the field
/// shadow (`--default` without shadow for the secondary variant).
///
/// Selecting it fills it `--accent` (`--accent-hover` while pressed) and
/// shrinks the [HeroRadioIndicator] to a dot; pressing scales it to 95%.
/// Hovering shows `--field-border-hover`; an invalid group shows a 1 px
/// `--danger` outline; keyboard focus shows the focus ring. Colors change
/// over 200 ms and the press scale over 100 ms (ease-out).
///
/// [size], [borderRadius], [color] (unselected), [selectedColor],
/// [pressedColor] (selected and pressed) and [side] restyle it.
class HeroRadioControl extends StatelessWidget {
  /// Creates the circle of a radio, showing [child] (the default
  /// [HeroRadioIndicator] when null).
  const HeroRadioControl({
    super.key,
    this.child,
    this.size,
    this.borderRadius,
    this.color,
    this.selectedColor,
    this.pressedColor,
    this.side,
  });

  /// The indicator; defaults to a [HeroRadioIndicator].
  final Widget? child;

  /// Side length; defaults to 16 (`size-4`).
  final double? size;

  /// Corner radii; defaults to `rounded-lg` (8, a circle at 16 px).
  final BorderRadiusGeometry? borderRadius;

  /// Background while unselected.
  final Color? color;

  /// Background while selected (`--accent`).
  final Color? selectedColor;

  /// Background while selected and pressed (`--accent-hover`).
  final Color? pressedColor;

  /// Border; defaults to the field border (0 px wide unless themed).
  final BorderSide? side;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroRadioScope scope = HeroRadioScope.of(context);
    final HeroRadioState state = scope.state;
    final HeroInteractionState interaction = HeroToggleInteractionScope.of(
      context,
    );
    final bool secondary = scope.variant == HeroFieldVariant.secondary;
    final bool selected = state.isSelected;
    final bool pressed = interaction.isPressed;

    final Color background = selected
        ? (pressed
              ? pressedColor ?? selectedColor ?? colors.accentHover
              : selectedColor ?? colors.accent)
        : color ?? (secondary ? colors.defaultColor : colors.fieldBackground);
    final BorderSide? side = this.side;
    final double borderWidth = side?.width ?? theme.fieldBorderWidth;
    // The hover border wins over the selected (transparent) one, as in the
    // CSS specificity; a custom border (a utility class in HeroUI) wins over
    // the hover color.
    final Color borderColor = side != null
        ? (selected ? side.color.withValues(alpha: 0) : side.color)
        : interaction.isHovered
        ? colors.fieldBorderHover
        : selected
        ? colors.fieldBorder.withValues(alpha: 0)
        : colors.fieldBorder;

    final double dimension = size ?? theme.spacing(4);
    final BorderRadiusGeometry radius =
        borderRadius ?? BorderRadius.all(Radius.circular(theme.radii.lg));
    final OutlinedBorder shape = theme.shape(radius);

    Widget result = AnimatedContainer(
      duration: theme.motion.resolve(context, HeroMotion.medium),
      curve: HeroMotion.easeOut,
      width: dimension,
      height: dimension,
      // The indicator fills the box inside the border (`absolute inset-0`).
      padding: EdgeInsets.all(borderWidth),
      decoration: ShapeDecoration(
        color: background,
        shape: shape.copyWith(
          side: borderWidth > 0
              ? BorderSide(color: borderColor, width: borderWidth)
              : BorderSide.none,
        ),
        shadows: secondary
            ? const <BoxShadow>[]
            : theme.shadows.field.boxShadows,
      ),
      child: HeroRadioIndicatorScope(
        shape: shape,
        child: child ?? const HeroRadioIndicator(),
      ),
    );

    result = HeroFocusRing(
      visible: interaction.isFocusVisible,
      shape: shape,
      child: result,
    );
    if (state.isInvalid) {
      result = CustomPaint(
        foregroundPainter: HeroFocusRingPainter(
          shape: shape,
          color: colors.danger,
          width: theme.spacing(0.25),
          offset: 0,
          offsetColor: colors.danger.withValues(alpha: 0),
          textDirection: Directionality.maybeOf(context),
        ),
        child: result,
      );
    }
    result = AnimatedScale(
      scale: pressed ? 0.95 : 1,
      duration: theme.motion.resolve(context, HeroMotion.fast),
      curve: HeroMotion.easeOut,
      child: result,
    );
    return ExcludeSemantics(child: result);
  }
}

/// Passes the shape of a [HeroRadioControl] to its indicator, whose dot
/// uses the same corners.
class HeroRadioIndicatorScope extends InheritedWidget {
  /// Publishes the control [shape] to [child].
  const HeroRadioIndicatorScope({
    super.key,
    required this.shape,
    required super.child,
  });

  /// The shape of the control.
  final ShapeBorder shape;

  /// The closest control shape, or null.
  static ShapeBorder? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<HeroRadioIndicatorScope>()
      ?.shape;

  @override
  bool updateShouldNotify(HeroRadioIndicatorScope oldWidget) =>
      shape != oldWidget.shape;
}

/// The dot of a [HeroRadio] (HeroUI `Radio.Indicator`).
///
/// By default it covers the whole [HeroRadioControl] in the control's
/// unselected color (`--field-hover` while hovered) and shrinks to a
/// `--accent-foreground` dot of 43% (57% while pressed) when the radio is
/// selected, over 200 ms (ease-out).
///
/// [child] or [builder] replace the dot with custom content centred in the
/// control (HeroUI only draws the dot while the indicator is empty).
/// [color], [selectedColor], [selectedScale] and [pressedScale] restyle
/// the dot.
class HeroRadioIndicator extends StatelessWidget {
  /// Creates the indicator of a radio.
  const HeroRadioIndicator({
    super.key,
    this.child,
    this.builder,
    this.color,
    this.selectedColor,
    this.selectedScale,
    this.pressedScale,
  });

  /// Custom content shown instead of the dot.
  final Widget? child;

  /// Builds custom content from the radio state; wins over [child].
  final HeroRadioIndicatorBuilder? builder;

  /// Dot color while unselected (the control's background).
  final Color? color;

  /// Dot color while selected (`--accent-foreground`).
  final Color? selectedColor;

  /// Dot scale while selected (0.4286, a 6.9 px dot at 16 px).
  final double? selectedScale;

  /// Dot scale while selected and pressed (0.5714).
  final double? pressedScale;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroRadioScope scope = HeroRadioScope.of(context);
    final HeroRadioState state = scope.state;
    final HeroInteractionState interaction = HeroToggleInteractionScope.of(
      context,
    );

    final HeroRadioIndicatorBuilder? builder = this.builder;
    if (builder != null || child != null) {
      final Widget? content = builder != null ? builder(context, state) : child;
      return Center(
        child: IconTheme.merge(
          data: IconThemeData(
            color: colors.accentForeground,
            size: theme.spacing(3),
          ),
          child: content ?? const SizedBox.shrink(),
        ),
      );
    }

    final bool secondary = scope.variant == HeroFieldVariant.secondary;
    final bool selected = state.isSelected;
    final Color dotColor;
    if (selected) {
      dotColor = selectedColor ?? colors.accentForeground;
    } else if (interaction.isHovered && color == null) {
      dotColor = secondary ? colors.defaultHover : colors.fieldHover;
    } else {
      dotColor =
          color ?? (secondary ? colors.defaultColor : colors.fieldBackground);
    }
    final double scale = !selected
        ? 1
        : interaction.isPressed
        ? pressedScale ?? 0.5714
        : selectedScale ?? 0.4286;
    final ShapeBorder shape =
        HeroRadioIndicatorScope.maybeOf(context) ??
        theme.shapeAll(theme.radii.lg);
    final Duration duration = theme.motion.resolve(context, HeroMotion.medium);
    return AnimatedScale(
      scale: scale,
      duration: duration,
      curve: HeroMotion.easeOut,
      child: AnimatedContainer(
        duration: duration,
        curve: HeroMotion.easeOut,
        decoration: ShapeDecoration(color: dotColor, shape: shape),
      ),
    );
  }
}
