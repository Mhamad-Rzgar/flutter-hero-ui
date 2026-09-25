/// HeroUI's `Switch` and `SwitchGroup`: a toggle for a boolean setting.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../checkbox/toggle_field.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/hero_field.dart';
import '../input/hero_text_constraints.dart';
import '../text_field/hero_field_layout.dart';

/// Where the label of a [HeroSwitch] built from `label` sits.
enum HeroSwitchLabelPosition {
  /// Before the control ("Label before").
  start,

  /// After the control, the default.
  end,
}

/// The render props of a [HeroSwitch] (React Aria's `SwitchRenderProps`),
/// passed to [HeroSwitch.builder].
@immutable
class HeroSwitchState {
  /// Creates switch render props.
  const HeroSwitchState({
    this.isSelected = false,
    this.isHovered = false,
    this.isPressed = false,
    this.isFocused = false,
    this.isFocusVisible = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isInvalid = false,
    this.isRequired = false,
  });

  /// Whether the switch is on.
  final bool isSelected;

  /// Whether a mouse hovers the switch.
  final bool isHovered;

  /// Whether the switch is being pressed.
  final bool isPressed;

  /// Whether the switch has focus.
  final bool isFocused;

  /// Whether the focus was reached with the keyboard.
  final bool isFocusVisible;

  /// Whether the switch is disabled.
  final bool isDisabled;

  /// Whether the switch is read-only.
  final bool isReadOnly;

  /// Whether the switch currently shows as invalid.
  final bool isInvalid;

  /// Whether the switch must be on.
  final bool isRequired;

  @override
  bool operator ==(Object other) =>
      other is HeroSwitchState &&
      other.isSelected == isSelected &&
      other.isHovered == isHovered &&
      other.isPressed == isPressed &&
      other.isFocused == isFocused &&
      other.isFocusVisible == isFocusVisible &&
      other.isDisabled == isDisabled &&
      other.isReadOnly == isReadOnly &&
      other.isInvalid == isInvalid &&
      other.isRequired == isRequired;

  @override
  int get hashCode => Object.hash(
    isSelected,
    isHovered,
    isPressed,
    isFocused,
    isFocusVisible,
    isDisabled,
    isReadOnly,
    isInvalid,
    isRequired,
  );
}

/// Builds the parts of a [HeroSwitch] from its state (HeroUI's
/// render-prop children).
typedef HeroSwitchBuilder =
    List<Widget> Function(BuildContext context, HeroSwitchState state);

/// The geometry of a [HeroSwitch] size, from `switch.css`.
@immutable
class HeroSwitchMetrics {
  const HeroSwitchMetrics._({
    required this.trackWidth,
    required this.trackHeight,
    required this.trackRadius,
    required this.thumbWidth,
    required this.thumbHeight,
    required this.thumbRadius,
    required this.inset,
  });

  /// The metrics of [size] in [theme].
  factory HeroSwitchMetrics.of(HeroThemeData theme, HeroSize size) {
    final HeroRadii radii = theme.radii;
    return switch (size) {
      // `h-4 w-8 rounded-lg`, thumb `1.03125rem × 0.75rem rounded-md`.
      HeroSize.sm => HeroSwitchMetrics._(
        trackWidth: theme.spacing(8),
        trackHeight: theme.spacing(4),
        trackRadius: radii.lg,
        thumbWidth: theme.spacing(4.125),
        thumbHeight: theme.spacing(3),
        thumbRadius: radii.md,
        inset: theme.spacing(0.5),
      ),
      // `h-5 w-10 rounded-xl`, thumb `1.375rem × 1rem rounded-lg`.
      HeroSize.md => HeroSwitchMetrics._(
        trackWidth: theme.spacing(10),
        trackHeight: theme.spacing(5),
        trackRadius: radii.xl,
        thumbWidth: theme.spacing(5.5),
        thumbHeight: theme.spacing(4),
        thumbRadius: radii.lg,
        inset: theme.spacing(0.5),
      ),
      // `h-6 w-12 rounded-xl`, thumb `1.71875rem × 1.25rem rounded-xl`.
      HeroSize.lg => HeroSwitchMetrics._(
        trackWidth: theme.spacing(12),
        trackHeight: theme.spacing(6),
        trackRadius: radii.xl,
        thumbWidth: theme.spacing(6.875),
        thumbHeight: theme.spacing(5),
        thumbRadius: radii.xl,
        inset: theme.spacing(0.5),
      ),
    };
  }

  /// Width of the track.
  final double trackWidth;

  /// Height of the track.
  final double trackHeight;

  /// Corner radius of the track.
  final double trackRadius;

  /// Width of the thumb.
  final double thumbWidth;

  /// Height of the thumb.
  final double thumbHeight;

  /// Corner radius of the thumb.
  final double thumbRadius;

  /// Start margin of the thumb while off (`ms-0.5`).
  final double inset;

  /// Distance the thumb travels between off and on.
  double get travel => trackWidth - thumbWidth - 2 * inset;
}

/// A switch (HeroUI `Switch`): a [HeroSwitchContent] (the pressable row
/// holding the [HeroSwitchControl] track and the label) with an optional
/// [HeroDescription] and [HeroFieldError] below it.
///
/// ```dart
/// HeroSwitch(
///   label: 'Enable notifications',
///   onChanged: (bool on) => debugPrint('$on'),
/// )
/// ```
///
/// The switch is controlled with [isSelected] + [onChanged] or uncontrolled
/// with [defaultSelected]. Pressing the content (or a [HeroLabel] inside it)
/// or Space toggles it, and the thumb can be dragged across the track like
/// an iOS switch. The thumb slides over 300 ms with HeroUI's
/// `ease-out-fluid` curve and the track color changes over 250 ms.
///
/// [size] (sm, md, lg) sets the track (32 × 16, 40 × 20, 48 × 24) and
/// thumb; [labelPosition] puts the built label before or after the control.
///
/// It is a `FormField<bool>` of the nearest `Form` (a [HeroForm]): an on
/// switch submits [value] (`'on'` by default) under [name], [isRequired]
/// fails validation while off, and [validator], [validationErrors] and
/// [isInvalid] work as on the other fields.
class HeroSwitch extends StatefulWidget {
  /// Creates a switch.
  const HeroSwitch({
    super.key,
    this.children,
    this.builder,
    this.label,
    this.description,
    this.errorMessage,
    this.labelPosition = HeroSwitchLabelPosition.end,
    this.size = HeroSize.md,
    this.isSelected,
    this.defaultSelected = false,
    this.onChanged,
    this.onPressed,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid,
    this.name,
    this.value,
    this.validator,
    this.validationBehavior,
    this.validationErrors,
    this.validationMessages = const HeroValidationMessages(),
    this.onSaved,
    this.autovalidateMode,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// The parts of the switch ([HeroSwitchContent], [HeroDescription],
  /// [HeroFieldError]). When null (and [builder] is null) the switch builds
  /// them from [label], [description] and [errorMessage].
  final List<Widget>? children;

  /// Builds the parts from the switch state; wins over [children].
  final HeroSwitchBuilder? builder;

  /// Label text of the built switch.
  final String? label;

  /// Description text of the built switch.
  final String? description;

  /// Error text of the built switch, shown while invalid; defaults to the
  /// validation messages.
  final String? errorMessage;

  /// Whether the built label sits after (default) or before the control.
  final HeroSwitchLabelPosition labelPosition;

  /// The size of the control.
  final HeroSize size;

  /// Whether the switch is on (controlled).
  final bool? isSelected;

  /// Whether the switch starts on (uncontrolled).
  final bool defaultSelected;

  /// Called with the new state when the user toggles the switch
  /// (`onChange`).
  final ValueChanged<bool>? onChanged;

  /// Called when the switch is pressed (`onPress`).
  final VoidCallback? onPressed;

  /// Whether the switch is disabled.
  final bool isDisabled;

  /// Whether the switch can be focused but not toggled.
  final bool isReadOnly;

  /// Whether the switch must be on (validated with the native behaviour).
  final bool isRequired;

  /// Overrides the displayed validation: true invalid, false valid.
  final bool? isInvalid;

  /// The name of the value in the data a [HeroForm] submits.
  final String? name;

  /// The value submitted while on (`'on'` when null).
  final String? value;

  /// Custom validation (`validate`): an error message or null.
  final FormFieldValidator<bool>? validator;

  /// When errors show; null inherits the [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors, shown until the user toggles the switch.
  final List<String>? validationErrors;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Called with the state when the enclosing form is saved.
  final FormFieldSetter<bool>? onSaved;

  /// When the native behaviour shows errors before any change.
  final AutovalidateMode? autovalidateMode;

  /// Focus node of the pressable content.
  final FocusNode? focusNode;

  /// Whether to focus the switch when first built.
  final bool autofocus;

  /// Accessibility label (`aria-label`), for a switch without a label.
  final String? semanticLabel;

  @override
  State<HeroSwitch> createState() => _HeroSwitchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(EnumProperty<HeroSize>('size', size, defaultValue: HeroSize.md))
      ..add(
        DiagnosticsProperty<bool>('isSelected', isSelected, defaultValue: null),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isReadOnly', value: isReadOnly, ifTrue: 'read-only'))
      ..add(FlagProperty('isRequired', value: isRequired, ifTrue: 'required'))
      ..add(
        DiagnosticsProperty<bool>('isInvalid', isInvalid, defaultValue: null),
      )
      ..add(StringProperty('name', name, defaultValue: null));
  }
}

class _HeroSwitchState extends State<HeroSwitch> {
  final GlobalKey<HeroValidatedFieldState<bool>> _fieldKey =
      GlobalKey<HeroValidatedFieldState<bool>>();
  late bool _selected = widget.defaultSelected;
  late final bool _initialSelected =
      widget.isSelected ?? widget.defaultSelected;
  FocusNode? _ownFocusNode;
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroSwitch'));

  bool get _effectiveSelected => widget.isSelected ?? _selected;

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _toggle() {
    final bool next = !_effectiveSelected;
    if (widget.isSelected == null) setState(() => _selected = next);
    _fieldKey.currentState?.didChange(next);
    widget.onChanged?.call(next);
  }

  void _press() {
    widget.onPressed?.call();
    if (!widget.isDisabled && !widget.isReadOnly) _toggle();
  }

  void _handleReset() {
    if (_effectiveSelected == _initialSelected) return;
    if (widget.isSelected == null) {
      setState(() => _selected = _initialSelected);
    }
    widget.onChanged?.call(_initialSelected);
  }

  void _set(VoidCallback update) {
    if (mounted) setState(update);
  }

  @override
  Widget build(BuildContext context) {
    final bool selected = _effectiveSelected;
    return HeroValidatedField<bool>(
      key: _fieldKey,
      value: selected,
      name: widget.name,
      formValue: (bool? on) => on ?? false ? (widget.value ?? 'on') : null,
      onReset: _handleReset,
      isDisabled: widget.isDisabled,
      isRequired: widget.isRequired,
      isValueMissing: (bool? on) => !(on ?? false),
      valueMissingMessage: widget.validationMessages.checkboxValueMissing,
      isInvalid: widget.isInvalid,
      errorMessage: widget.errorMessage,
      validator: widget.validator,
      validationBehavior: widget.validationBehavior,
      validationErrors: widget.validationErrors,
      validationMessages: widget.validationMessages,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      builder: (BuildContext context, HeroValidationResult validation) =>
          _buildField(context, selected, validation),
    );
  }

  Widget _buildField(
    BuildContext context,
    bool selected,
    HeroValidationResult validation,
  ) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool disabled = widget.isDisabled;
    final bool readOnly = widget.isReadOnly;
    final HeroSwitchState state = HeroSwitchState(
      isSelected: selected,
      isHovered: _hovered && !disabled,
      isPressed: _pressed && !disabled,
      isFocused: _focused,
      isFocusVisible:
          _focused &&
          FocusManager.instance.highlightMode == FocusHighlightMode.traditional,
      isDisabled: disabled,
      isReadOnly: readOnly,
      isInvalid: validation.isInvalid,
      isRequired: widget.isRequired,
    );
    final List<Widget> parts =
        widget.builder?.call(context, state) ??
        widget.children ??
        _defaultParts();
    final HeroSwitchMetrics metrics = HeroSwitchMetrics.of(theme, widget.size);

    Widget result = HeroFieldLayout(
      spacing: theme.spacing(1),
      stretch: false,
      children: heroToggleFieldParts(
        parts,
        // The track width plus the 12 px gap to the label.
        indent: metrics.trackWidth + theme.spacing(3),
        isDisabled: disabled,
      ),
    );
    result = HeroDisabledOpacity(disabled: disabled, child: result);
    // `.switch:hover .switch__control`: hovering anywhere over the field
    // tints the track.
    result = MouseRegion(
      onEnter: (_) => _set(() => _hovered = true),
      onExit: (_) => _set(() => _hovered = false),
      child: result,
    );

    final String? hint = heroToggleFieldHint(
      parts,
      validation,
      description: widget.children == null && widget.builder == null
          ? widget.description
          : null,
    );
    final VoidCallback? toggle = disabled || readOnly ? null : _toggle;
    return HeroSwitchScope(
      state: state,
      size: widget.size,
      onToggle: toggle,
      onPressed: disabled ? null : _press,
      onPressChanged: (bool pressed) => _set(() => _pressed = pressed),
      onFocusChanged: (bool focused) => _set(() => _focused = focused),
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      semanticHint: hint,
      child: HeroFieldScope(
        isDisabled: disabled,
        isInvalid: validation.isInvalid,
        validationErrors: validation.validationErrors,
        isRequired: widget.isRequired,
        isReadOnly: readOnly,
        showRequiredIndicator: false,
        focusNode: _focusNode,
        onLabelPressed: toggle,
        semanticLabel: widget.semanticLabel,
        semanticHint: hint,
        child: result,
      ),
    );
  }

  List<Widget> _defaultParts() {
    final String? label = widget.label;
    final String? description = widget.description;
    final String? errorMessage = widget.errorMessage;
    final bool before = widget.labelPosition == HeroSwitchLabelPosition.start;
    return <Widget>[
      HeroSwitchContent(
        children: <Widget>[
          if (label != null && before) Text(label),
          const HeroSwitchControl(),
          if (label != null && !before) Text(label),
        ],
      ),
      if (description != null) HeroDescription.text(description),
      if (errorMessage != null)
        HeroFieldError.text(errorMessage)
      else
        const HeroFieldError(),
    ];
  }
}

/// Shares the state of a [HeroSwitch] with its parts ([HeroSwitchContent],
/// [HeroSwitchControl], [HeroSwitchThumb], [HeroSwitchIcon]).
class HeroSwitchScope extends InheritedWidget {
  /// Publishes a switch's state to [child].
  const HeroSwitchScope({
    super.key,
    required this.state,
    required this.size,
    required super.child,
    this.onToggle,
    this.onPressed,
    this.onPressChanged,
    this.onFocusChanged,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.semanticHint,
  });

  /// The switch's render props.
  final HeroSwitchState state;

  /// The size of the control.
  final HeroSize size;

  /// Toggles the switch; null while disabled or read-only.
  final VoidCallback? onToggle;

  /// Handles a press of the content (`onPress` and toggling); null while
  /// disabled.
  final VoidCallback? onPressed;

  /// Reports when a press of the content starts and ends.
  final ValueChanged<bool>? onPressChanged;

  /// Reports when the content gains or loses focus.
  final ValueChanged<bool>? onFocusChanged;

  /// Focus node of the content.
  final FocusNode? focusNode;

  /// Whether the content takes focus when first built.
  final bool autofocus;

  /// Accessibility label of the switch.
  final String? semanticLabel;

  /// Accessibility hint of the switch (description and error).
  final String? semanticHint;

  /// The closest switch scope, or null outside a [HeroSwitch].
  static HeroSwitchScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroSwitchScope>();

  /// The closest switch scope.
  static HeroSwitchScope of(BuildContext context) {
    final HeroSwitchScope? scope = maybeOf(context);
    assert(
      scope != null,
      'Switch parts (HeroSwitchContent, HeroSwitchControl, HeroSwitchThumb, '
      'HeroSwitchIcon) must be placed inside a HeroSwitch.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(HeroSwitchScope oldWidget) =>
      state != oldWidget.state ||
      size != oldWidget.size ||
      onToggle != oldWidget.onToggle ||
      onPressed != oldWidget.onPressed ||
      focusNode != oldWidget.focusNode ||
      autofocus != oldWidget.autofocus ||
      semanticLabel != oldWidget.semanticLabel ||
      semanticHint != oldWidget.semanticHint;
}

/// The pressable row of a [HeroSwitch] (HeroUI `Switch.Content`): the
/// [HeroSwitchControl] and the label in an inline row with a 12 px gap,
/// `text-sm font-medium`. Put the label before the control for a leading
/// label.
///
/// Pressing it (or Space while it has focus) toggles the switch. It is the
/// switch's accessibility node.
class HeroSwitchContent extends StatelessWidget {
  /// Creates the content of a switch.
  const HeroSwitchContent({
    super.key,
    this.children,
    this.builder,
    this.spacing,
    this.padding,
    this.decoration,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.fullWidth = false,
  });

  /// The parts: usually a [HeroSwitchControl] and a [Text].
  final List<Widget>? children;

  /// Builds the parts from the interaction state; wins over [children].
  final HeroToggleContentBuilder? builder;

  /// Gap between the parts; defaults to 12 (`gap-3`).
  final double? spacing;

  /// Padding around the parts.
  final EdgeInsetsGeometry? padding;

  /// Decoration behind the parts, resolved with the content's states.
  final WidgetStateProperty<Decoration?>? decoration;

  /// Vertical alignment of the parts; centred by default.
  final CrossAxisAlignment crossAxisAlignment;

  /// Whether the content fills the available width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final HeroSwitchScope scope = HeroSwitchScope.of(context);
    final HeroSwitchState state = scope.state;
    return HeroToggleFieldContent(
      isSelected: state.isSelected,
      onPressed: scope.onPressed,
      onPressStart: () => scope.onPressChanged?.call(true),
      onPressEnd: () => scope.onPressChanged?.call(false),
      onFocusChanged: scope.onFocusChanged,
      isDisabled: state.isDisabled,
      focusNode: scope.focusNode,
      autofocus: scope.autofocus,
      semanticLabel: scope.semanticLabel,
      semanticHint: scope.semanticHint,
      spacing: spacing,
      padding: padding,
      decoration: decoration,
      crossAxisAlignment: crossAxisAlignment,
      fullWidth: fullWidth,
      builder: builder,
      semanticsBuilder: (Widget child) => Semantics(
        toggled: state.isSelected,
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

/// Shares the thumb position of a [HeroSwitchControl] with its
/// [HeroSwitchThumb].
class HeroSwitchThumbScope extends InheritedWidget {
  /// Publishes the thumb [position] to [child].
  const HeroSwitchThumbScope({
    super.key,
    required this.position,
    required super.child,
  });

  /// The thumb position: 0 at the start (off), 1 at the end (on).
  final Animation<double> position;

  /// The closest thumb position, or null outside a [HeroSwitchControl].
  static Animation<double>? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<HeroSwitchThumbScope>()
      ?.position;

  @override
  bool updateShouldNotify(HeroSwitchThumbScope oldWidget) =>
      position != oldWidget.position;
}

/// The track of a [HeroSwitch] (HeroUI `Switch.Control`), holding the
/// [HeroSwitchThumb].
///
/// The track is `--default` when off and `--accent` when on; hovering or
/// pressing makes an off track 80% opaque and an on track
/// `--accent-hover`. Colors change over 250 ms (`ease`); keyboard focus
/// shows the focus ring with its 2 px offset.
///
/// The thumb slides between its off and on positions over 300 ms
/// (`ease-out-fluid`) and follows a horizontal drag like an iOS switch;
/// releasing past the middle (or flicking) toggles the switch.
///
/// [color], [hoverColor], [selectedColor] and [selectedHoverColor] replace
/// the track colors (HeroUI's `--switch-control-bg*` variables).
class HeroSwitchControl extends StatefulWidget {
  /// Creates the track of a switch, holding [child] (the default
  /// [HeroSwitchThumb] when null).
  const HeroSwitchControl({
    super.key,
    this.child,
    this.color,
    this.hoverColor,
    this.selectedColor,
    this.selectedHoverColor,
  });

  /// The thumb; defaults to a [HeroSwitchThumb].
  final Widget? child;

  /// Track color while off (`--switch-control-bg`, `--default`).
  final Color? color;

  /// Track color while off and hovered or pressed; defaults to [color]
  /// (or `--default`) at 80% opacity.
  final Color? hoverColor;

  /// Track color while on (`--switch-control-bg-checked`, `--accent`).
  final Color? selectedColor;

  /// Track color while on and hovered or pressed; defaults to
  /// [selectedColor], or `--accent-hover`.
  final Color? selectedHoverColor;

  @override
  State<HeroSwitchControl> createState() => _HeroSwitchControlState();
}

class _HeroSwitchControlState extends State<HeroSwitchControl>
    with SingleTickerProviderStateMixin {
  late final AnimationController _position = AnimationController(vsync: this);
  bool? _selected;
  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool selected = HeroSwitchScope.of(context).state.isSelected;
    final bool? previous = _selected;
    _selected = selected;
    if (previous == null) {
      _position.value = selected ? 1 : 0;
    } else if (previous != selected && !_dragging) {
      _settle();
    }
  }

  @override
  void dispose() {
    _position.dispose();
    super.dispose();
  }

  /// Moves the thumb to the current selection.
  void _settle() {
    final double target = (_selected ?? false) ? 1 : 0;
    final HeroMotion motion = HeroTheme.of(context).motion;
    if (motion.shouldReduceMotion(context)) {
      _position.value = target;
      return;
    }
    // `transition: margin 300ms var(--ease-out-fluid)`.
    _position.animateTo(
      target,
      duration: HeroMotion.slower,
      curve: HeroMotion.easeOutFluid,
    );
  }

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;

  void _handleDragStart(DragStartDetails details) {
    _dragging = true;
    _position.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details, double travel) {
    if (travel <= 0) return;
    final double delta = (details.primaryDelta ?? 0) / travel;
    _position.value = (_position.value + (_rtl ? -delta : delta)).clamp(
      0.0,
      1.0,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragging = false;
    final HeroSwitchScope scope = HeroSwitchScope.of(context);
    double velocity = details.primaryVelocity ?? 0;
    if (_rtl) velocity = -velocity;
    final bool target = velocity.abs() > kMinFlingVelocity
        ? velocity > 0
        : _position.value >= 0.5;
    if (target != scope.state.isSelected) scope.onToggle?.call();
    // Settle on the selection the owner kept (a controlled switch may not
    // change).
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _settle();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  void _handleDragCancel() {
    _dragging = false;
    _settle();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroSwitchScope scope = HeroSwitchScope.of(context);
    final HeroSwitchState state = scope.state;
    final HeroInteractionState interaction = HeroToggleInteractionScope.of(
      context,
    );
    final HeroSwitchMetrics metrics = HeroSwitchMetrics.of(theme, scope.size);
    final bool active =
        state.isHovered ||
        interaction.isHovered ||
        state.isPressed ||
        interaction.isPressed;

    final Color off = widget.color ?? colors.defaultColor;
    final Color on = widget.selectedColor ?? colors.accent;
    final Color background = state.isSelected
        ? (active
              ? widget.selectedHoverColor ??
                    widget.selectedColor ??
                    colors.accentHover
              : on)
        : (active
              ? widget.hoverColor ?? off.withValues(alpha: off.a * 0.8)
              : off);
    final OutlinedBorder shape = theme.shapeAll(metrics.trackRadius);

    Widget result = AnimatedContainer(
      // `background-color 250ms var(--ease-smooth)`.
      duration: theme.motion.resolve(context, HeroMotion.slow),
      curve: HeroMotion.smooth,
      width: metrics.trackWidth,
      height: metrics.trackHeight,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(color: background, shape: shape),
      child: HeroSwitchThumbScope(
        position: _position,
        child: widget.child ?? const HeroSwitchThumb(),
      ),
    );
    result = HeroFocusRing(
      visible: interaction.isFocusVisible,
      shape: shape,
      child: result,
    );
    if (scope.onToggle != null) {
      final double travel = metrics.travel;
      result = GestureDetector(
        excludeFromSemantics: true,
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: (DragUpdateDetails details) =>
            _handleDragUpdate(details, travel),
        onHorizontalDragEnd: _handleDragEnd,
        onHorizontalDragCancel: _handleDragCancel,
        child: result,
      );
    }
    return ExcludeSemantics(child: result);
  }
}

/// The thumb of a [HeroSwitch] (HeroUI `Switch.Thumb`): a white pill with
/// the field shadow that slides to the end of the track and turns
/// `--accent-foreground` (with a softer lifted shadow) when the switch is
/// on. Its [child], usually a [HeroSwitchIcon], is drawn in black while off
/// and `--accent` while on.
///
/// While disabled the thumb is `--default-foreground` at 20% when off and
/// 40% opaque when on.
class HeroSwitchThumb extends StatelessWidget {
  /// Creates the thumb of a switch.
  const HeroSwitchThumb({super.key, this.child});

  /// Content drawn on the thumb, usually a [HeroSwitchIcon].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroSwitchScope scope = HeroSwitchScope.of(context);
    final HeroSwitchState state = scope.state;
    final HeroSwitchMetrics metrics = HeroSwitchMetrics.of(theme, scope.size);
    final bool selected = state.isSelected;
    final bool disabled = state.isDisabled;

    final Color background = selected
        ? colors.accentForeground
        : disabled
        ? colors.defaultForeground.withValues(
            alpha: colors.defaultForeground.a * 0.2,
          )
        : colors.white;
    final Color glyph = selected ? colors.accent : colors.black;
    final Color shadow = colors.black;
    final List<BoxShadow> shadows = selected
        ? <BoxShadow>[
            BoxShadow(
              color: shadow.withValues(alpha: 0.02),
              blurRadius: theme.spacing(1.25),
            ),
            BoxShadow(
              color: shadow.withValues(alpha: 0.06),
              offset: Offset(0, theme.spacing(0.5)),
              blurRadius: theme.spacing(2.5),
            ),
            BoxShadow(
              color: shadow.withValues(alpha: 0.3),
              blurRadius: theme.spacing(0.25),
            ),
          ]
        : theme.shadows.field.boxShadows;

    Widget thumb = AnimatedContainer(
      // `background-color 200ms var(--ease-out)`.
      duration: theme.motion.resolve(context, HeroMotion.medium),
      curve: HeroMotion.easeOut,
      width: metrics.thumbWidth,
      height: metrics.thumbHeight,
      decoration: ShapeDecoration(
        color: background,
        shape: theme.shapeAll(metrics.thumbRadius),
        shadows: shadows,
      ),
      child: child == null
          ? null
          : IconTheme.merge(
              data: IconThemeData(color: glyph, size: theme.spacing(3)),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: glyph),
                child: child!,
              ),
            ),
    );
    if (disabled && selected) {
      thumb = Opacity(opacity: 0.4, child: thumb);
    }

    final Animation<double> position =
        HeroSwitchThumbScope.maybeOf(context) ??
        AlwaysStoppedAnimation<double>(selected ? 1 : 0);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AnimatedBuilder(
        animation: position,
        child: thumb,
        builder: (BuildContext context, Widget? child) => Padding(
          // Margin-based positioning: `ms-0.5` off,
          // `ms-[calc(100%-thumb-0.125rem)]` on.
          padding: EdgeInsetsDirectional.only(
            start: metrics.inset + metrics.travel * position.value,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// An icon on a [HeroSwitchThumb] (HeroUI `Switch.Icon`): centred on the
/// thumb, sized 12 px, in the thumb's glyph color (black while off,
/// `--accent` while on).
class HeroSwitchIcon extends StatelessWidget {
  /// Creates a thumb icon showing [child].
  const HeroSwitchIcon({super.key, required this.child});

  /// The icon, usually a [HeroIcon].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: Center(child: child));
  }
}

/// A group of switches (HeroUI `SwitchGroup`): the switches in a column
/// (default) or a row with a 16 px gap.
///
/// ```dart
/// const HeroSwitchGroup(
///   children: <Widget>[
///     HeroSwitch(name: 'notifications', label: 'Allow Notifications'),
///     HeroSwitch(name: 'marketing', label: 'Marketing emails'),
///   ],
/// )
/// ```
///
/// Wrap a horizontal group in a horizontally scrolling view when it may not
/// fit.
class HeroSwitchGroup extends StatelessWidget {
  /// Creates a switch group.
  const HeroSwitchGroup({
    super.key,
    required this.children,
    this.orientation = Axis.vertical,
    this.spacing,
  });

  /// The switches.
  final List<Widget> children;

  /// Whether the switches are stacked or in a row.
  final Axis orientation;

  /// Gap between the switches; defaults to 16 (`gap-4`).
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final double gap = spacing ?? HeroTheme.of(context).spacing(4);
    return orientation == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: gap,
            children: children,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: gap,
            children: children,
          );
  }
}
