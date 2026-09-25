/// HeroUI's `RadioGroup` and `Radio`: a labelled set of options of which
/// exactly one can be selected.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../checkbox/toggle_field.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/hero_field.dart';
import '../input/hero_text_constraints.dart';
import '../label/label.dart';
import '../text_field/hero_field_layout.dart';
import 'radio.dart';
import 'radio_group_scope.dart';

export 'radio.dart';
export 'radio_group_scope.dart';

/// The render props of a [HeroRadioGroup] (React Aria's
/// `RadioGroupRenderProps`), passed to [HeroRadioGroup.builder].
@immutable
class HeroRadioGroupState {
  /// Creates radio group render props.
  const HeroRadioGroupState({
    this.value,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isInvalid = false,
    this.isRequired = false,
  });

  /// The selected value, or null.
  final String? value;

  /// Whether the group is disabled.
  final bool isDisabled;

  /// Whether the group is read-only.
  final bool isReadOnly;

  /// Whether the group currently shows as invalid.
  final bool isInvalid;

  /// Whether a selection is required.
  final bool isRequired;

  @override
  bool operator ==(Object other) =>
      other is HeroRadioGroupState &&
      other.value == value &&
      other.isDisabled == isDisabled &&
      other.isReadOnly == isReadOnly &&
      other.isInvalid == isInvalid &&
      other.isRequired == isRequired;

  @override
  int get hashCode =>
      Object.hash(value, isDisabled, isReadOnly, isInvalid, isRequired);
}

/// Builds the parts of a [HeroRadioGroup] from its state (HeroUI's
/// render-function children).
typedef HeroRadioGroupBuilder =
    List<Widget> Function(BuildContext context, HeroRadioGroupState state);

/// A radio group (HeroUI `RadioGroup`): a [HeroLabel], an optional
/// [HeroDescription], [HeroRadio]s and an optional [HeroFieldError].
///
/// ```dart
/// const HeroRadioGroup(
///   name: 'plan',
///   defaultValue: 'premium',
///   label: 'Plan selection',
///   description: 'Choose the plan that suits you best',
///   children: <Widget>[
///     HeroRadio(value: 'basic', label: 'Basic Plan'),
///     HeroRadio(value: 'premium', label: 'Premium Plan'),
///     HeroRadio(value: 'business', label: 'Business Plan'),
///   ],
/// )
/// ```
///
/// [label], [description] and [errorMessage] are placed before and after
/// [children]; the parts can also be composed directly. Vertically every
/// radio gets a 16 px top margin ([itemMargin]); horizontally the parts
/// wrap in a row with a 16 px gap ([spacing]).
///
/// The group owns the selection: controlled with [value] + [onChanged] or
/// uncontrolled with [defaultValue]. It is a single Tab stop (the selected
/// radio, or the first one); the arrow keys move the focus and the
/// selection to the previous or next enabled radio, wrapping around
/// (Left and Right are flipped in right-to-left horizontal groups), and
/// Space selects the focused radio. [isReadOnly] keeps the selection.
///
/// It is a `FormField<String>` of the nearest `Form` (a [HeroForm]):
/// [isRequired] asks for a selection (and puts the asterisk on the label),
/// [validator], [validationErrors] and [isInvalid] work as on the other
/// fields, and the selected value is submitted under [name]. While invalid
/// the label turns `--danger` and every radio shows the invalid outline.
class HeroRadioGroup extends StatefulWidget {
  /// Creates a radio group.
  const HeroRadioGroup({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.label,
    this.description,
    this.errorMessage,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.variant = HeroFieldVariant.primary,
    this.orientation = Axis.vertical,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid,
    this.name,
    this.validator,
    this.validationBehavior,
    this.validationErrors,
    this.validationMessages = const HeroValidationMessages(),
    this.onSaved,
    this.autovalidateMode,
    this.spacing,
    this.itemMargin,
    this.fullWidth = false,
    this.semanticLabel,
  });

  /// The parts of the group: radios, and optionally a label, a description
  /// and an error.
  final List<Widget> children;

  /// Builds the parts from the group state; replaces [children].
  final HeroRadioGroupBuilder? builder;

  /// Label text shown before the parts.
  final String? label;

  /// Description text shown after the label.
  final String? description;

  /// Error text shown after the parts while the group is invalid.
  final String? errorMessage;

  /// The selected value (controlled); null leaves the selection to the
  /// group.
  final String? value;

  /// The initially selected value (uncontrolled).
  final String? defaultValue;

  /// Called with the new value when the user selects a radio.
  final ValueChanged<String>? onChanged;

  /// Visual variant of the radios.
  final HeroFieldVariant variant;

  /// Whether the radios are stacked ([Axis.vertical]) or in a wrapping row.
  final Axis orientation;

  /// Whether every radio is disabled.
  final bool isDisabled;

  /// Whether the radios can be focused but the selection not changed.
  final bool isReadOnly;

  /// Whether a radio must be selected.
  final bool isRequired;

  /// Overrides the displayed validation: true invalid, false valid.
  final bool? isInvalid;

  /// The name of the selected value in the data a [HeroForm] submits.
  final String? name;

  /// Custom validation (`validate`): an error message or null.
  final FormFieldValidator<String>? validator;

  /// When errors show; null inherits the [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors, shown until the user changes the selection.
  final List<String>? validationErrors;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// When the native behaviour shows errors before any change.
  final AutovalidateMode? autovalidateMode;

  /// Gap between the parts: 0 when vertical, 16 when horizontal.
  final double? spacing;

  /// Space around every radio of a vertical group; defaults to a 16 px top
  /// margin (`mt-4`).
  final EdgeInsetsGeometry? itemMargin;

  /// Whether the group fills the available width (`w-full`); otherwise it
  /// is as wide as its widest part.
  final bool fullWidth;

  /// Accessibility label of the group; defaults to the label text.
  final String? semanticLabel;

  @override
  State<HeroRadioGroup> createState() => _HeroRadioGroupState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(StringProperty('value', value, defaultValue: null))
      ..add(
        EnumProperty<HeroFieldVariant>(
          'variant',
          variant,
          defaultValue: HeroFieldVariant.primary,
        ),
      )
      ..add(
        EnumProperty<Axis>(
          'orientation',
          orientation,
          defaultValue: Axis.vertical,
        ),
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

class _HeroRadioGroupState extends State<HeroRadioGroup>
    implements HeroRadioGroupController {
  final GlobalKey<HeroValidatedFieldState<String>> _fieldKey =
      GlobalKey<HeroValidatedFieldState<String>>();
  late String? _value = widget.defaultValue;
  late final String? _initialValue = widget.value ?? widget.defaultValue;
  final Map<String, HeroRadioRegistration> _radios =
      <String, HeroRadioRegistration>{};

  /// The registered values in tree order, refreshed after each frame in
  /// which radios were added or removed.
  List<String> _order = const <String>[];
  bool _orderScheduled = false;
  String? _lastFocused;

  String? get _effectiveValue => widget.value ?? _value;

  bool _isEnabled(String value) => _radios[value]?.isEnabled() ?? false;

  @override
  void registerRadio(HeroRadioRegistration radio) {
    _radios[radio.value] = radio;
    _scheduleOrder();
  }

  @override
  void unregisterRadio(HeroRadioRegistration radio) {
    if (identical(_radios[radio.value], radio)) _radios.remove(radio.value);
    _scheduleOrder();
  }

  void _scheduleOrder() {
    if (_orderScheduled) return;
    _orderScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _orderScheduled = false;
      if (!mounted) return;
      final List<String> order = _collectOrder();
      if (!listEquals(order, _order)) setState(() => _order = order);
    });
  }

  /// The values of the registered radios in tree (reading) order.
  List<String> _collectOrder() {
    final List<String> order = <String>[];
    void visit(Element element) {
      final Widget widget = element.widget;
      if (widget is HeroRadio &&
          _radios.containsKey(widget.value) &&
          !order.contains(widget.value)) {
        order.add(widget.value);
      }
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
    return order;
  }

  /// The radio that takes part in Tab traversal: the selected one, then the
  /// last focused one, then the first enabled one.
  String? get _tabStopValue {
    final String? selected = _effectiveValue;
    if (selected != null && _isEnabled(selected)) return selected;
    final String? focused = _lastFocused;
    if (focused != null && _isEnabled(focused)) return focused;
    for (final String value in _order) {
      if (_isEnabled(value)) return value;
    }
    return null;
  }

  @override
  bool select(String value) {
    if (widget.isDisabled || widget.isReadOnly) {
      return _effectiveValue == value;
    }
    if (_effectiveValue != value) {
      if (widget.value == null) setState(() => _value = value);
      _fieldKey.currentState?.didChange(value);
      widget.onChanged?.call(value);
    }
    return true;
  }

  @override
  void handleRadioFocused(String value) {
    if (_lastFocused == value) return;
    setState(() => _lastFocused = value);
  }

  void _handleReset() {
    if (_effectiveValue == _initialValue) return;
    if (widget.value == null) setState(() => _value = _initialValue);
    final String? initial = _initialValue;
    if (initial != null) widget.onChanged?.call(initial);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final bool flip =
        Directionality.of(context) == TextDirection.rtl &&
        widget.orientation == Axis.horizontal;
    final int? delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowDown => 1,
      LogicalKeyboardKey.arrowUp => -1,
      LogicalKeyboardKey.arrowRight => flip ? -1 : 1,
      LogicalKeyboardKey.arrowLeft => flip ? 1 : -1,
      _ => null,
    };
    if (delta == null) return KeyEventResult.ignored;
    final List<String> enabled = _collectOrder()
        .where(_isEnabled)
        .toList(growable: false);
    final int current = enabled.indexWhere(
      (String value) => _radios[value]!.focusNode.hasPrimaryFocus,
    );
    if (current < 0) return KeyEventResult.ignored;
    // Like React Aria, the focus wraps around and the selection follows it.
    final String next = enabled[(current + delta) % enabled.length];
    _radios[next]!.focusNode.requestFocus();
    select(next);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final String? value = _effectiveValue;
    return HeroValidatedField<String>(
      key: _fieldKey,
      value: value,
      name: widget.name,
      onReset: _handleReset,
      isDisabled: widget.isDisabled,
      isRequired: widget.isRequired,
      isValueMissing: (String? v) => v == null,
      valueMissingMessage: widget.validationMessages.radioValueMissing,
      isInvalid: widget.isInvalid,
      errorMessage: widget.errorMessage,
      validator: widget.validator,
      validationBehavior: widget.validationBehavior,
      validationErrors: widget.validationErrors,
      validationMessages: widget.validationMessages,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      builder: (BuildContext context, HeroValidationResult validation) =>
          _buildGroup(context, value, validation),
    );
  }

  Widget _buildGroup(
    BuildContext context,
    String? value,
    HeroValidationResult validation,
  ) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroRadioGroupState state = HeroRadioGroupState(
      value: value,
      isDisabled: widget.isDisabled,
      isReadOnly: widget.isReadOnly,
      isInvalid: validation.isInvalid,
      isRequired: widget.isRequired,
    );
    final String? label = widget.label;
    final String? description = widget.description;
    final String? errorMessage = widget.errorMessage;
    final List<Widget> parts = <Widget>[
      if (label != null) HeroLabel.text(label),
      if (description != null) HeroDescription.text(description),
      ...widget.builder?.call(context, state) ?? widget.children,
      if (errorMessage != null) HeroFieldError.text(errorMessage),
    ];

    final bool horizontal = widget.orientation == Axis.horizontal;
    Widget layout = horizontal
        ? Wrap(
            spacing: widget.spacing ?? theme.spacing(4),
            runSpacing: widget.spacing ?? theme.spacing(4),
            children: parts,
          )
        : HeroFieldLayout(
            spacing: widget.spacing ?? 0,
            fullWidth: widget.fullWidth,
            children: parts,
          );
    if (horizontal && widget.fullWidth) {
      layout = SizedBox(width: double.infinity, child: layout);
    }

    final String? semanticLabel = widget.semanticLabel ?? _labelText(parts);
    final String? hint = heroToggleFieldHint(parts, validation);
    return HeroFieldScope(
      variant: widget.variant,
      isDisabled: widget.isDisabled,
      isInvalid: validation.isInvalid,
      validationErrors: validation.validationErrors,
      isRequired: widget.isRequired,
      isReadOnly: widget.isReadOnly,
      semanticLabel: semanticLabel,
      semanticHint: hint,
      child: HeroRadioGroupScope(
        controller: this,
        value: value,
        tabStopValue: _tabStopValue,
        variant: widget.variant,
        orientation: widget.orientation,
        isDisabled: widget.isDisabled,
        isReadOnly: widget.isReadOnly,
        isRequired: widget.isRequired,
        isInvalid: validation.isInvalid,
        validationErrors: validation.validationErrors,
        itemMargin:
            widget.itemMargin ??
            EdgeInsetsDirectional.only(top: theme.spacing(4)),
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _handleKey,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            role: SemanticsRole.radioGroup,
            label: semanticLabel,
            hint: hint,
            child: layout,
          ),
        ),
      ),
    );
  }

  /// The text of the group's label, announced for the group.
  static String? _labelText(List<Widget> parts) {
    for (final Widget part in parts) {
      if (part is HeroLabel) return part.data;
    }
    return null;
  }
}
