/// HeroUI's `Checkbox`: a control that marks one item as selected, with its
/// label, description and validation message.
library;

import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/hero_field.dart';
import '../input/hero_text_constraints.dart';
import '../text_field/hero_field_layout.dart';
import 'checkbox_group_scope.dart';
import 'toggle_field.dart';

export 'checkbox_group_scope.dart';
export 'toggle_field.dart'
    show
        HeroInlineFlexRow,
        HeroToggleContentBuilder,
        HeroToggleInteractionScope,
        RenderHeroInlineFlexRow;

/// The render props of a [HeroCheckbox] (React Aria's
/// `CheckboxFieldRenderProps`), passed to [HeroCheckbox.builder] and
/// [HeroCheckboxIndicator.builder].
@immutable
class HeroCheckboxState {
  /// Creates checkbox render props.
  const HeroCheckboxState({
    this.isSelected = false,
    this.isIndeterminate = false,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isInvalid = false,
    this.isRequired = false,
  });

  /// Whether the checkbox is checked.
  final bool isSelected;

  /// Whether the checkbox shows the indeterminate (mixed) state.
  final bool isIndeterminate;

  /// Whether the checkbox is disabled.
  final bool isDisabled;

  /// Whether the checkbox is read-only.
  final bool isReadOnly;

  /// Whether the checkbox currently shows as invalid.
  final bool isInvalid;

  /// Whether the checkbox must be checked.
  final bool isRequired;

  @override
  bool operator ==(Object other) =>
      other is HeroCheckboxState &&
      other.isSelected == isSelected &&
      other.isIndeterminate == isIndeterminate &&
      other.isDisabled == isDisabled &&
      other.isReadOnly == isReadOnly &&
      other.isInvalid == isInvalid &&
      other.isRequired == isRequired;

  @override
  int get hashCode => Object.hash(
    isSelected,
    isIndeterminate,
    isDisabled,
    isReadOnly,
    isInvalid,
    isRequired,
  );

  @override
  String toString() =>
      'HeroCheckboxState(${<String>[if (isSelected) 'selected', if (isIndeterminate) 'indeterminate', if (isDisabled) 'disabled', if (isReadOnly) 'read-only', if (isInvalid) 'invalid', if (isRequired) 'required'].join(', ')})';
}

/// Builds the parts of a [HeroCheckbox] from its state (HeroUI's
/// render-function children).
typedef HeroCheckboxBuilder =
    List<Widget> Function(BuildContext context, HeroCheckboxState state);

/// Builds the glyph of a [HeroCheckboxIndicator] from the checkbox state;
/// null shows nothing.
typedef HeroCheckboxIndicatorBuilder =
    Widget? Function(BuildContext context, HeroCheckboxState state);

/// A checkbox (HeroUI `Checkbox`): a [HeroCheckboxContent] (the pressable
/// row holding the [HeroCheckboxControl] and the label) with an optional
/// [HeroDescription] and [HeroFieldError] below it.
///
/// Build it from convenience parameters:
///
/// ```dart
/// HeroCheckbox(
///   label: 'Email notifications',
///   description: 'Get notified when someone mentions you in a comment',
///   onChanged: (bool selected) => debugPrint('$selected'),
/// )
/// ```
///
/// or compose the parts, like HeroUI:
///
/// ```dart
/// const HeroCheckbox(
///   name: 'terms',
///   children: <Widget>[
///     HeroCheckboxContent(
///       children: <Widget>[
///         HeroCheckboxControl(),
///         Text('Accept terms and conditions'),
///       ],
///     ),
///     HeroDescription.text('Read them first'),
///     HeroFieldError(),
///   ],
/// )
/// ```
///
/// The checkbox is controlled with [isSelected] + [onChanged] or
/// uncontrolled with [defaultSelected]. Pressing the content (or a
/// [HeroLabel] inside the checkbox) and Space toggle it; [isReadOnly]
/// ignores input and [isIndeterminate] shows a dash until the owner clears
/// it.
///
/// It is a `FormField<bool>` of the nearest `Form` (a [HeroForm]): a checked
/// box submits [value] (`'on'` by default) under [name], [isRequired] fails
/// validation while unchecked, and [validator], [validationErrors] and
/// [isInvalid] work as on the other fields. With the default native
/// [validationBehavior] errors show once the box is toggled or the form is
/// submitted. While invalid an unchecked control shows a `--danger` outline
/// and a checked one turns `--danger`; the [HeroFieldError] shows the
/// message in `--muted`, as in HeroUI.
///
/// Inside a `HeroCheckboxGroup` the group owns the selection: give every
/// checkbox a [value]; the group's variant, disabled, read-only and invalid
/// states apply and the group is the form field.
class HeroCheckbox extends StatefulWidget {
  /// Creates a checkbox.
  const HeroCheckbox({
    super.key,
    this.children,
    this.builder,
    this.label,
    this.description,
    this.errorMessage,
    this.isSelected,
    this.defaultSelected = false,
    this.onChanged,
    this.isIndeterminate = false,
    this.variant,
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

  /// The parts of the checkbox ([HeroCheckboxContent], [HeroDescription],
  /// [HeroFieldError]). When null (and [builder] is null) the checkbox
  /// builds them from [label], [description] and [errorMessage].
  final List<Widget>? children;

  /// Builds the parts from the checkbox state; wins over [children].
  final HeroCheckboxBuilder? builder;

  /// Label text of the built checkbox.
  final String? label;

  /// Description text of the built checkbox.
  final String? description;

  /// Error text of the built checkbox, shown while invalid; defaults to the
  /// validation messages.
  final String? errorMessage;

  /// Whether the checkbox is checked (controlled).
  final bool? isSelected;

  /// Whether the checkbox starts checked (uncontrolled).
  final bool defaultSelected;

  /// Called with the new state when the user toggles the checkbox
  /// (`onChange`).
  final ValueChanged<bool>? onChanged;

  /// Whether the checkbox shows the indeterminate (mixed) state. It is
  /// presentational: toggling calls [onChanged] and the owner clears it.
  final bool isIndeterminate;

  /// Visual variant; null inherits the group's, then
  /// [HeroFieldVariant.primary]. Use [HeroFieldVariant.secondary] on
  /// surfaces.
  final HeroFieldVariant? variant;

  /// Whether the checkbox is disabled.
  final bool isDisabled;

  /// Whether the checkbox can be focused but not toggled.
  final bool isReadOnly;

  /// Whether the checkbox must be checked (validated with the native
  /// behaviour).
  final bool isRequired;

  /// Overrides the displayed validation: true shows the checkbox as
  /// invalid, false as valid; null lets the validation decide.
  final bool? isInvalid;

  /// The name of the value in the data a [HeroForm] submits.
  final String? name;

  /// The value submitted while checked (`'on'` when null), and the
  /// checkbox's identity inside a `HeroCheckboxGroup`.
  final String? value;

  /// Custom validation (`validate`): an error message or null.
  final FormFieldValidator<bool>? validator;

  /// When errors show; null inherits the [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors, shown until the user toggles the checkbox.
  final List<String>? validationErrors;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Called with the state when the enclosing form is saved.
  final FormFieldSetter<bool>? onSaved;

  /// When the native behaviour shows errors before any change.
  final AutovalidateMode? autovalidateMode;

  /// Focus node of the pressable content.
  final FocusNode? focusNode;

  /// Whether to focus the checkbox when first built.
  final bool autofocus;

  /// Accessibility label (`aria-label`), for a checkbox without a label.
  final String? semanticLabel;

  @override
  State<HeroCheckbox> createState() => _HeroCheckboxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(
        DiagnosticsProperty<bool>('isSelected', isSelected, defaultValue: null),
      )
      ..add(
        FlagProperty(
          'isIndeterminate',
          value: isIndeterminate,
          ifTrue: 'indeterminate',
        ),
      )
      ..add(
        EnumProperty<HeroFieldVariant>('variant', variant, defaultValue: null),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isReadOnly', value: isReadOnly, ifTrue: 'read-only'))
      ..add(FlagProperty('isRequired', value: isRequired, ifTrue: 'required'))
      ..add(
        DiagnosticsProperty<bool>('isInvalid', isInvalid, defaultValue: null),
      )
      ..add(StringProperty('name', name, defaultValue: null))
      ..add(StringProperty('value', value, defaultValue: null));
  }
}

class _HeroCheckboxState extends State<HeroCheckbox> {
  final GlobalKey<HeroValidatedFieldState<bool>> _fieldKey =
      GlobalKey<HeroValidatedFieldState<bool>>();
  late bool _selected = widget.defaultSelected;
  late final bool _initialSelected =
      widget.isSelected ?? widget.defaultSelected;
  FocusNode? _ownFocusNode;
  bool _hovered = false;
  HeroCheckboxGroupScope? _group;

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroCheckbox'));

  /// The group that owns this checkbox's selection, if any.
  HeroCheckboxGroupScope? get _owningGroup =>
      widget.value == null ? null : _group;

  bool get _effectiveSelected {
    final HeroCheckboxGroupScope? group = _owningGroup;
    if (group != null) return group.isSelected(widget.value!);
    return widget.isSelected ?? _selected;
  }

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _toggle() {
    final HeroCheckboxGroupScope? group = _owningGroup;
    final bool next;
    if (group != null) {
      next = group.toggle(widget.value!);
    } else {
      next = !_effectiveSelected;
      if (widget.isSelected == null) setState(() => _selected = next);
      _fieldKey.currentState?.didChange(next);
    }
    widget.onChanged?.call(next);
  }

  void _handleReset() {
    if (_effectiveSelected == _initialSelected) return;
    if (widget.isSelected == null) {
      setState(() => _selected = _initialSelected);
    }
    widget.onChanged?.call(_initialSelected);
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    _group = HeroCheckboxGroupScope.maybeOf(context);
    final HeroCheckboxGroupScope? group = _owningGroup;
    assert(
      _group == null || widget.value != null,
      'A HeroCheckbox inside a HeroCheckboxGroup needs a value.',
    );
    final bool selected = _effectiveSelected;
    if (group != null) {
      // The group is the form field; its validation applies to every item.
      final bool invalid = widget.isInvalid ?? group.isInvalid;
      return Padding(
        padding: group.itemMargin,
        child: _buildField(
          context,
          selected,
          invalid
              ? HeroValidationResult.invalid(group.validationErrors)
              : HeroValidationResult.valid,
          group,
        ),
      );
    }
    return HeroValidatedField<bool>(
      key: _fieldKey,
      value: selected,
      name: widget.name,
      formValue: (bool checked) => checked ? (widget.value ?? 'on') : null,
      onReset: _handleReset,
      isDisabled: widget.isDisabled,
      isRequired: widget.isRequired,
      isValueMissing: (bool checked) => !checked,
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
          _buildField(context, selected, validation, null),
    );
  }

  Widget _buildField(
    BuildContext context,
    bool selected,
    HeroValidationResult validation,
    HeroCheckboxGroupScope? group,
  ) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool disabled = widget.isDisabled || (group?.isDisabled ?? false);
    final bool readOnly = widget.isReadOnly || (group?.isReadOnly ?? false);
    final bool required = widget.isRequired || (group?.isRequired ?? false);
    final HeroFieldVariant variant =
        widget.variant ?? group?.variant ?? HeroFieldVariant.primary;
    final HeroCheckboxState state = HeroCheckboxState(
      isSelected: selected,
      isIndeterminate: widget.isIndeterminate,
      isDisabled: disabled,
      isReadOnly: readOnly,
      isInvalid: validation.isInvalid,
      isRequired: required,
    );
    final List<Widget> parts =
        widget.builder?.call(context, state) ??
        widget.children ??
        _defaultParts();
    final VoidCallback? toggle = disabled || readOnly ? null : _toggle;

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
    // `.checkbox:hover .checkbox__control`: hovering anywhere over the
    // field (the description too) highlights the control.
    result = MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: result,
    );

    final String? hint = heroToggleFieldHint(
      parts,
      validation,
      description: widget.children == null && widget.builder == null
          ? widget.description
          : null,
    );
    return HeroCheckboxScope(
      state: state,
      variant: variant,
      isHovered: _hovered && !disabled,
      onToggle: toggle,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      semanticHint: hint,
      child: HeroFieldScope(
        variant: variant,
        isDisabled: disabled,
        isInvalid: validation.isInvalid,
        validationErrors: validation.validationErrors,
        isRequired: required,
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
    return <Widget>[
      HeroCheckboxContent(
        children: <Widget>[
          const HeroCheckboxControl(),
          if (label != null) Text(label),
        ],
      ),
      if (description != null) HeroDescription.text(description),
      if (errorMessage != null)
        HeroFieldError.text(errorMessage)
      // Inside a group the group shows the validation messages.
      else if (_owningGroup == null)
        const HeroFieldError(),
    ];
  }
}

/// Shares the state of a [HeroCheckbox] with its parts
/// ([HeroCheckboxContent], [HeroCheckboxControl], [HeroCheckboxIndicator]).
class HeroCheckboxScope extends InheritedWidget {
  /// Publishes a checkbox's state to [child].
  const HeroCheckboxScope({
    super.key,
    required this.state,
    required this.variant,
    required super.child,
    this.isHovered = false,
    this.onToggle,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.semanticHint,
  });

  /// The checkbox's render props.
  final HeroCheckboxState state;

  /// The resolved variant.
  final HeroFieldVariant variant;

  /// Whether a mouse hovers the checkbox (anywhere over the field).
  final bool isHovered;

  /// Toggles the checkbox; null while disabled or read-only.
  final VoidCallback? onToggle;

  /// Focus node of the content.
  final FocusNode? focusNode;

  /// Whether the content takes focus when first built.
  final bool autofocus;

  /// Accessibility label of the checkbox.
  final String? semanticLabel;

  /// Accessibility hint of the checkbox (description and error).
  final String? semanticHint;

  /// The closest checkbox scope, or null outside a [HeroCheckbox].
  static HeroCheckboxScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroCheckboxScope>();

  /// The closest checkbox scope.
  static HeroCheckboxScope of(BuildContext context) {
    final HeroCheckboxScope? scope = maybeOf(context);
    assert(
      scope != null,
      'Checkbox parts (HeroCheckboxContent, HeroCheckboxControl, '
      'HeroCheckboxIndicator) must be placed inside a HeroCheckbox.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(HeroCheckboxScope oldWidget) =>
      state != oldWidget.state ||
      variant != oldWidget.variant ||
      isHovered != oldWidget.isHovered ||
      onToggle != oldWidget.onToggle ||
      focusNode != oldWidget.focusNode ||
      autofocus != oldWidget.autofocus ||
      semanticLabel != oldWidget.semanticLabel ||
      semanticHint != oldWidget.semanticHint;
}

/// The pressable row of a [HeroCheckbox] (HeroUI `Checkbox.Content`): the
/// [HeroCheckboxControl] and the label text in an inline row with a 12 px
/// gap, `text-sm font-medium`.
///
/// Pressing it (or Space while it has focus) toggles the checkbox. It is
/// the checkbox's accessibility node: a checkbox labelled by its text.
/// Long labels wrap next to the control. [padding], [decoration],
/// [crossAxisAlignment] and [fullWidth] style card-like contents; the
/// [builder] receives the hover, press, focus and selection state.
class HeroCheckboxContent extends StatelessWidget {
  /// Creates the content of a checkbox.
  const HeroCheckboxContent({
    super.key,
    this.children,
    this.builder,
    this.spacing,
    this.padding,
    this.decoration,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.fullWidth = false,
  });

  /// The parts: usually a [HeroCheckboxControl] and a [Text].
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
    final HeroCheckboxScope scope = HeroCheckboxScope.of(context);
    final HeroCheckboxState state = scope.state;
    return HeroToggleFieldContent(
      isSelected: state.isSelected,
      onPressed: scope.onToggle,
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
        checked: !state.isIndeterminate && state.isSelected,
        mixed: state.isIndeterminate ? true : null,
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

/// The box of a [HeroCheckbox] (HeroUI `Checkbox.Control`): a 16 px square
/// with `rounded-md` corners, `--field-background` and the field shadow
/// (`--default` without shadow for [HeroFieldVariant.secondary]).
///
/// Checking it grows an accent fill from 70% to full size while it fades
/// in (100 ms / 200 ms, linear) and draws the checkmark of the
/// [HeroCheckboxIndicator]. Hovering tints the fill `--accent-hover`; an
/// indeterminate box is filled `--accent` (`--accent-hover` while pressed).
/// While invalid, an unchecked box shows a 1 px `--danger` outline and a
/// checked or indeterminate one turns `--danger`. Keyboard focus shows the
/// focus ring with its 2 px offset.
///
/// [size] and [borderRadius] resize and reshape it (a full radius makes a
/// round checkbox); [color] replaces the unchecked background and
/// [selectedColor] the fill.
class HeroCheckboxControl extends StatelessWidget {
  /// Creates the box of a checkbox, showing [child] (the default
  /// [HeroCheckboxIndicator] when null).
  const HeroCheckboxControl({
    super.key,
    this.child,
    this.size,
    this.borderRadius,
    this.color,
    this.selectedColor,
  });

  /// The glyph inside the box; defaults to a [HeroCheckboxIndicator].
  final Widget? child;

  /// Side length; defaults to 16 (`size-4`).
  final double? size;

  /// Corner radii; defaults to `rounded-md` (6).
  final BorderRadiusGeometry? borderRadius;

  /// Background while unchecked (`bg-field`, or `bg-default` for the
  /// secondary variant).
  final Color? color;

  /// Fill color while checked (`--accent`, `--accent-hover` on hover).
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroCheckboxScope scope = HeroCheckboxScope.of(context);
    final HeroCheckboxState state = scope.state;
    final HeroInteractionState interaction = HeroToggleInteractionScope.of(
      context,
    );
    final bool secondary = scope.variant == HeroFieldVariant.secondary;
    final bool selected = state.isSelected;
    final bool indeterminate = state.isIndeterminate;
    final bool invalid = state.isInvalid;
    final bool hovered = interaction.isHovered || scope.isHovered;

    final Color background;
    if (indeterminate) {
      background = invalid
          ? colors.danger
          : interaction.isPressed
          ? colors.accentHover
          : colors.accent;
    } else if (invalid && selected) {
      background = colors.danger;
    } else {
      background =
          color ?? (secondary ? colors.defaultColor : colors.fieldBackground);
    }
    final Color borderColor = invalid && selected
        ? colors.fieldBorder.withValues(alpha: 0)
        : hovered
        ? colors.fieldBorderHover
        : selected
        ? colors.fieldBorder.withValues(alpha: 0)
        : colors.fieldBorder;
    final Color fillColor = invalid
        ? colors.danger
        : selectedColor ?? (hovered ? colors.accentHover : colors.accent);

    final double dimension = size ?? theme.spacing(4);
    final double borderWidth = theme.fieldBorderWidth;
    final BorderRadiusGeometry radius =
        borderRadius ?? BorderRadius.all(Radius.circular(theme.radii.md));
    final OutlinedBorder shape = theme.shape(radius);
    final Duration colorDuration = theme.motion.resolve(
      context,
      HeroMotion.medium,
    );

    Widget result = AnimatedContainer(
      duration: colorDuration,
      curve: HeroMotion.easeOut,
      width: dimension,
      height: dimension,
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
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(borderWidth),
            child: _HeroControlFill(
              visible: selected,
              color: fillColor,
              shape: shape,
            ),
          ),
          Center(child: child ?? const HeroCheckboxIndicator()),
        ],
      ),
    );

    result = HeroFocusRing(
      visible: interaction.isFocusVisible,
      shape: shape,
      child: result,
    );
    // `status-invalid-field`: a 1 px outline, painted above the focus ring
    // like a CSS outline above a box-shadow.
    if (invalid && !selected && !indeterminate) {
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
    return ExcludeSemantics(child: result);
  }
}

/// The checked fill of a checkbox (`.checkbox__control::before`): scales
/// from 70% (100 ms linear), fades (200 ms linear) and changes color
/// (200 ms ease-out).
class _HeroControlFill extends StatelessWidget {
  const _HeroControlFill({
    required this.visible,
    required this.color,
    required this.shape,
  });

  final bool visible;
  final Color color;
  final ShapeBorder shape;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return AnimatedScale(
      scale: visible ? 1 : 0.7,
      duration: theme.motion.resolve(context, HeroMotion.fast),
      curve: HeroMotion.linear,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: theme.motion.resolve(context, HeroMotion.medium),
        curve: HeroMotion.linear,
        child: AnimatedContainer(
          duration: theme.motion.resolve(context, HeroMotion.medium),
          curve: HeroMotion.easeOut,
          decoration: ShapeDecoration(color: color, shape: shape),
        ),
      ),
    );
  }
}

/// The glyph of a [HeroCheckbox] (HeroUI `Checkbox.Indicator`), centred in
/// the [HeroCheckboxControl].
///
/// By default it draws HeroUI's checkmark — a 10 px polyline stroked from
/// its start while the box is checked (150 ms linear after 15 ms) and
/// erased when unchecked (200 ms) — or a 12 px dash while indeterminate, in
/// `--accent-foreground` (`--danger-foreground` while invalid).
///
/// [child] or [builder] replace the glyph; they are drawn in a 12 px box
/// and an ambient [IconTheme] sizes and colors [HeroIcon]s. [size] sets the
/// default glyph's size and [color] its color.
class HeroCheckboxIndicator extends StatelessWidget {
  /// Creates the glyph of a checkbox.
  const HeroCheckboxIndicator({
    super.key,
    this.child,
    this.builder,
    this.size,
    this.color,
  });

  /// A custom glyph shown in every state.
  final Widget? child;

  /// Builds a custom glyph from the checkbox state; wins over [child].
  final HeroCheckboxIndicatorBuilder? builder;

  /// Size of the default checkmark (10) or dash (12).
  final double? size;

  /// Color of the glyph.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroCheckboxState state = HeroCheckboxScope.of(context).state;
    final Color glyphColor =
        color ??
        (state.isInvalid && (state.isSelected || state.isIndeterminate)
            ? theme.colors.dangerForeground
            : theme.colors.accentForeground);
    final double box = theme.spacing(3);

    Widget? glyph;
    final HeroCheckboxIndicatorBuilder? builder = this.builder;
    if (builder != null) {
      glyph = builder(context, state);
    } else if (child != null) {
      glyph = child;
    } else if (state.isIndeterminate) {
      final double side = size ?? theme.spacing(3);
      glyph = CustomPaint(
        size: Size.square(side),
        painter: _HeroDashPainter(color: glyphColor),
      );
    } else {
      glyph = _HeroCheckmark(
        isDrawn: state.isSelected,
        size: size ?? theme.spacing(2.5),
        color: glyphColor,
      );
    }

    final double side = math.max(box, size ?? 0);
    return ExcludeSemantics(
      child: IconTheme.merge(
        data: IconThemeData(color: glyphColor, size: box),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: glyphColor),
          child: SizedBox.square(
            dimension: side,
            child: Center(child: glyph),
          ),
        ),
      ),
    );
  }
}

/// HeroUI's checkmark: `<polyline points="1 9 7 14 15 4">` in a 17 × 18 view
/// box, `stroke-width: 2.5px`, round caps and joins, drawn with a 22-unit
/// stroke dash whose offset animates from 66 (hidden) to 44 (drawn).
class _HeroCheckmark extends StatefulWidget {
  const _HeroCheckmark({
    required this.isDrawn,
    required this.size,
    required this.color,
  });

  final bool isDrawn;
  final double size;
  final Color color;

  @override
  State<_HeroCheckmark> createState() => _HeroCheckmarkState();
}

class _HeroCheckmarkState extends State<_HeroCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: widget.isDrawn ? 1 : 0,
  );

  @override
  void didUpdateWidget(_HeroCheckmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDrawn == oldWidget.isDrawn) return;
    final HeroMotion motion = HeroTheme.of(context).motion;
    if (motion.shouldReduceMotion(context)) {
      _controller.value = widget.isDrawn ? 1 : 0;
      return;
    }
    if (widget.isDrawn) {
      // `transition: stroke-dashoffset 150ms linear 15ms`.
      const Duration draw = HeroMotion.normal;
      final Duration delay = draw * 0.1;
      final Duration total = draw + delay;
      _controller.animateTo(
        1,
        duration: total,
        curve: Interval(
          delay.inMicroseconds / total.inMicroseconds,
          1,
          curve: HeroMotion.linear,
        ),
      );
    } else {
      // `transition-all duration-200` with Tailwind's default curve.
      _controller.animateBack(
        0,
        duration: HeroMotion.medium,
        curve: HeroMotion.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(widget.size),
      painter: _HeroCheckmarkPainter(
        progress: _controller,
        color: widget.color,
      ),
    );
  }
}

class _HeroCheckmarkPainter extends CustomPainter {
  _HeroCheckmarkPainter({required this.progress, required this.color})
    : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  static const double _viewBoxWidth = 17;
  static const double _viewBoxHeight = 18;
  static const double _strokeWidth = 2.5;
  static const double _dash = 22;
  static const List<Offset> _points = <Offset>[
    Offset(1, 9),
    Offset(7, 14),
    Offset(15, 4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double t = progress.value;
    if (t <= 0) return;
    // `preserveAspectRatio="xMidYMid meet"`.
    final double scale = math.min(
      size.width / _viewBoxWidth,
      size.height / _viewBoxHeight,
    );
    final Offset origin = Offset(
      (size.width - _viewBoxWidth * scale) / 2,
      (size.height - _viewBoxHeight * scale) / 2,
    );
    final Path path = Path();
    for (int i = 0; i < _points.length; i++) {
      final Offset p = origin + _points[i] * scale;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final PathMetric metric = path.computeMetrics().first;
    final double length = math.min(metric.length, _dash * scale * t);
    canvas.drawPath(
      metric.extractPath(0, length),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_HeroCheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// HeroUI's indeterminate glyph: `<line x1="21" x2="3" y1="12" y2="12">` in a
/// 24 × 24 view box, stroke 3 with round caps.
class _HeroDashPainter extends CustomPainter {
  const _HeroDashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = math.min(size.width, size.height) / 24;
    final Offset origin = Offset(
      (size.width - 24 * scale) / 2,
      (size.height - 24 * scale) / 2,
    );
    canvas.drawLine(
      origin + const Offset(3, 12) * scale,
      origin + const Offset(21, 12) * scale,
      Paint()
        ..color = color
        ..strokeWidth = 3 * scale
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_HeroDashPainter oldDelegate) =>
      oldDelegate.color != color;
}
