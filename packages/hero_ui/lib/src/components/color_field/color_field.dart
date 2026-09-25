/// HeroUI's ColorField: a hex or channel color input with a label, a
/// description and validation.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../color_swatch/color_swatch.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/input.dart';
import '../label/label.dart';
import '../text_field/text_field.dart';
import 'color_input_group.dart';

export '../color/color.dart';
export 'color_input_group.dart';

/// The render props of a [HeroColorField], passed to its
/// [HeroColorField.builder].
@immutable
class HeroColorFieldState {
  /// Creates color field render props.
  const HeroColorFieldState({
    this.value,
    this.isDisabled = false,
    this.isInvalid = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isFocusWithin = false,
    this.isFocusVisible = false,
    this.validation = HeroValidationResult.valid,
  });

  /// The committed color, or null when the field is empty.
  final Color? value;

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Whether the field currently shows as invalid.
  final bool isInvalid;

  /// Whether the field is read-only.
  final bool isReadOnly;

  /// Whether the field is required.
  final bool isRequired;

  /// Whether the input has focus.
  final bool isFocusWithin;

  /// Whether the focus is visible (keyboard navigation).
  final bool isFocusVisible;

  /// The displayed validation state.
  final HeroValidationResult validation;

  @override
  bool operator ==(Object other) =>
      other is HeroColorFieldState &&
      other.value == value &&
      other.isDisabled == isDisabled &&
      other.isInvalid == isInvalid &&
      other.isReadOnly == isReadOnly &&
      other.isRequired == isRequired &&
      other.isFocusWithin == isFocusWithin &&
      other.isFocusVisible == isFocusVisible &&
      other.validation == validation;

  @override
  int get hashCode => Object.hash(
    value,
    isDisabled,
    isInvalid,
    isReadOnly,
    isRequired,
    isFocusWithin,
    isFocusVisible,
    validation,
  );
}

/// Builds the parts of a [HeroColorField] from its state.
typedef HeroColorFieldBuilder =
    List<Widget> Function(BuildContext context, HeroColorFieldState state);

/// A color input field (HeroUI `ColorField`): a [HeroLabel], a
/// [HeroColorInputGroup], a [HeroDescription] and a [HeroFieldError] in a
/// column with a 4 px gap.
///
/// ```dart
/// HeroColorField(
///   label: 'Color',
///   showSwatch: true,
///   value: color,
///   onChanged: (Color? next) => setState(() => color = next),
/// )
/// ```
///
/// or composed like HeroUI:
///
/// ```dart
/// HeroColorField(
///   defaultValue: const Color(0xFF3B82F6),
///   children: const <Widget>[
///     HeroLabel.text('Primary Color'),
///     HeroColorInputGroup(
///       children: <Widget>[
///         HeroColorInputPrefix(child: HeroColorSwatch(size: HeroColorSwatchSize.xs)),
///         HeroColorInput(),
///       ],
///     ),
///     HeroDescription.text("Enter your brand's primary color"),
///   ],
/// )
/// ```
///
/// **Hex mode** (no [channel]): the text is free while typing (hex digits
/// and an optional `#`). When the input loses focus or on Enter it is
/// parsed (`#RGB` or `#RRGGBB`, with or without `#`), committed and shown
/// as `#RRGGBB`; empty text clears the value and invalid text reverts to
/// the last value. Up / Page Up and Down / Page Down add or subtract one
/// from the hex number, Home and End jump to `#000000` and `#FFFFFF`, and
/// the mouse wheel steps while the input has focus (unless
/// [isWheelDisabled]).
///
/// **Channel mode** ([channel] and [colorSpace]): the field edits one
/// channel as a plain number (range and step of the channel; add a unit in
/// a [HeroColorInputSuffix]), with the same keys stepping by the channel
/// step and page size.
///
/// The value is a [Color] or null (empty): controlled with [value] +
/// [onChanged] (a controlled field that receives null is cleared),
/// uncontrolled with [defaultValue], or, without either inside a
/// `HeroColorPicker`, the picker's color. [onChanged] fires when a value is
/// committed. A [HeroColorSwatch] without a color inside the field shows the
/// field's color.
///
/// It is a `FormField<Color?>` of the nearest `Form` ([HeroForm]):
/// [isRequired], [validator], server-side [validationErrors] and
/// [isInvalid] decide the invalid state, shown after a commit or a form
/// validation (native behaviour) or right away (aria behaviour). While
/// invalid the label turns `--danger`, the group shows the invalid outline,
/// the description is hidden and the [HeroFieldError] shows the message. A
/// [HeroForm] receives the hex string (or the channel number) under [name].
class HeroColorField extends StatefulWidget {
  /// Creates a color field.
  const HeroColorField({
    super.key,
    this.children,
    this.builder,
    this.label,
    this.description,
    this.errorMessage,
    this.placeholder,
    this.showSwatch = false,
    this.startContent,
    this.endContent,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.colorSpace,
    this.channel,
    this.variant = HeroFieldVariant.primary,
    this.fullWidth = false,
    this.spacing,
    this.groupStyle,
    this.inputStyle,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid,
    this.isWheelDisabled = false,
    this.name,
    this.validator,
    this.validationBehavior,
    this.validationErrors,
    this.onSaved,
    this.autovalidateMode,
    this.validationMessages = const HeroValidationMessages(),
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// The parts of the field ([HeroLabel], [HeroColorInputGroup],
  /// [HeroDescription], [HeroFieldError], ...). When null (and [builder] is
  /// null) the field builds them from the convenience parameters.
  final List<Widget>? children;

  /// Builds the parts from the field state; takes precedence over
  /// [children].
  final HeroColorFieldBuilder? builder;

  /// Label text of the built field.
  final String? label;

  /// Description text of the built field, hidden while invalid.
  final String? description;

  /// Error text of the built field, shown while invalid; defaults to the
  /// validation messages.
  final String? errorMessage;

  /// Placeholder of the built input.
  final String? placeholder;

  /// Whether the built group starts with an extra-small swatch of the value.
  final bool showSwatch;

  /// Content of the built group's prefix (after the swatch).
  final Widget? startContent;

  /// Content of the built group's suffix.
  final Widget? endContent;

  /// The current color (controlled); null clears a controlled field.
  final Color? value;

  /// The initial color (uncontrolled).
  final Color? defaultValue;

  /// Called with the committed color, or null when the field is cleared.
  final ValueChanged<Color?>? onChanged;

  /// The color space of [channel].
  final HeroColorSpace? colorSpace;

  /// The channel to edit; null edits the hex value.
  final HeroColorChannel? channel;

  /// The variant of the groups inside the field.
  final HeroFieldVariant variant;

  /// Whether the field and its group take the full available width.
  final bool fullWidth;

  /// Gap between the parts; defaults to 4 (`gap-1`).
  final double? spacing;

  /// Visual overrides of the built group.
  final HeroFieldStyle? groupStyle;

  /// Text style merged over the built input's style.
  final TextStyle? inputStyle;

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Whether the value can be selected but not changed.
  final bool isReadOnly;

  /// Whether a value is required.
  final bool isRequired;

  /// Overrides the displayed validation: true shows the field as invalid,
  /// false as valid; null lets the validation decide.
  final bool? isInvalid;

  /// Whether the mouse wheel does not step the value.
  final bool isWheelDisabled;

  /// The name of the value in the data a [HeroForm] submits.
  final String? name;

  /// Custom validation (`validate`): returns an error message or null.
  final String? Function(Color? value)? validator;

  /// When errors show; null inherits the [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors, cleared once the user commits a new value.
  final List<String>? validationErrors;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<Color?>? onSaved;

  /// When the native behaviour shows errors without a commit.
  final AutovalidateMode? autovalidateMode;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Focus node of the input; when null the field owns one.
  final FocusNode? focusNode;

  /// Whether to focus the input when first built.
  final bool autofocus;

  /// Accessibility label of the input (`aria-label`); defaults to the label
  /// text.
  final String? semanticLabel;

  @override
  State<HeroColorField> createState() => _HeroColorFieldState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(ColorProperty('value', value, defaultValue: null))
      ..add(
        EnumProperty<HeroColorChannel>('channel', channel, defaultValue: null),
      )
      ..add(
        EnumProperty<HeroColorSpace>(
          'colorSpace',
          colorSpace,
          defaultValue: null,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isReadOnly', value: isReadOnly, ifTrue: 'read-only'))
      ..add(FlagProperty('isRequired', value: isRequired, ifTrue: 'required'))
      ..add(
        DiagnosticsProperty<bool>('isInvalid', isInvalid, defaultValue: null),
      );
  }
}

class _HeroColorFieldState extends State<HeroColorField> {
  final GlobalKey<_HeroColorFormFieldState> _fieldKey =
      GlobalKey<_HeroColorFormFieldState>();
  late final TextEditingController _controller = TextEditingController();
  FocusNode? _ownFocusNode;
  FocusNode? _listenedFocusNode;

  HeroColorValue? _value;
  late HeroColorValue? _initialValue;
  String _syncedText = '';
  bool _dirty = false;
  bool _syncing = false;
  bool _autofocused = false;

  HeroValidationResult _committed = HeroValidationResult.valid;
  HeroValidationBehavior _behavior = HeroValidationBehavior.native;
  List<String> _serverErrors = const <String>[];
  Object? _serverSource;
  bool _serverErrorsCleared = false;

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroColorField'));

  HeroColorChannel? get _channel => widget.channel;

  HeroColorSpace _spaceFor(HeroColorValue? previous) {
    final HeroColorChannel? channel = _channel;
    if (channel != null) return channel.resolveSpace(widget.colorSpace);
    return previous?.space ?? widget.colorSpace ?? HeroColorSpace.rgb;
  }

  List<String> get _activeServerErrors =>
      _serverErrorsCleared ? const <String>[] : _serverErrors;

  @override
  void initState() {
    super.initState();
    final Color? initial = widget.value ?? widget.defaultValue;
    _value = initial == null
        ? null
        : HeroColorValue.fromColor(initial, space: _spaceFor(null));
    _initialValue = _value;
    _controller.addListener(_handleTextChanged);
    _attachFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autofocus && !_autofocused) {
      _autofocused = true;
      FocusScope.of(context).autofocus(_focusNode);
    }
  }

  @override
  void didUpdateWidget(HeroColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attachFocus();
    // A controlled field whose value becomes null is cleared.
    if (oldWidget.value != null && widget.value == null) {
      _value = null;
      _fieldKey.currentState?.syncValue(null);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    _listenedFocusNode?.removeListener(_handleFocusChanged);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _attachFocus() {
    final FocusNode node = _focusNode;
    if (identical(node, _listenedFocusNode)) return;
    _listenedFocusNode?.removeListener(_handleFocusChanged);
    node.addListener(_handleFocusChanged);
    _listenedFocusNode = node;
  }

  void _handleTextChanged() {
    if (_syncing || _controller.text == _syncedText) return;
    _dirty = true;
  }

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) _commitText();
    setState(() {});
  }

  // The value shown by the field: the controlled value, the picker's color
  // or the uncontrolled value, keeping the cached hue.
  HeroColorValue? _resolve(HeroColorPickerScope? scope) {
    final Color? controlled = widget.value;
    if (controlled != null) {
      _value = heroResolveColorValue(
        controlled,
        _spaceFor(_value),
        previous: _value,
      );
    } else if (scope != null) {
      _value = scope.value.toSpace(_spaceFor(scope.value));
    } else if (_value != null) {
      _value = _value!.toSpace(_spaceFor(_value));
    }
    return _value;
  }

  String _format(HeroColorValue? value) {
    if (value == null) return '';
    final HeroColorChannel? channel = _channel;
    if (channel == null) return value.toFormat(HeroColorFormat.hex);
    final double v = value.channelValue(channel);
    final double step = channel.range.step;
    if (step >= 1) return v.round().toString();
    final String fixed = v.toStringAsFixed(2);
    return fixed.contains('.')
        ? fixed
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '')
        : fixed;
  }

  // Shows [text] without marking the field as edited.
  void _syncText(String text) {
    _syncedText = text;
    _dirty = false;
    if (_controller.text == text) return;
    _syncing = true;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _syncing = false;
  }

  /// Parses the text: `(true, value)` when it is a valid (or empty) value.
  (bool, HeroColorValue?) _parse(String raw) {
    final String text = raw.trim();
    final HeroColorValue? current = _value;
    final HeroColorChannel? channel = _channel;
    if (channel == null) {
      if (text.isEmpty) return (true, null);
      final String hex = text.startsWith('#') ? text : '#$text';
      final bool valid = RegExp(
        r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$',
      ).hasMatch(hex);
      final HeroColorValue? parsed = valid
          ? HeroColorValue.tryParse(hex)
          : null;
      if (parsed == null) return (false, null);
      final HeroColorValue withAlpha = parsed.withAlpha(current?.alpha ?? 1);
      return (
        true,
        heroResolveColorValue(
          withAlpha.toColor(),
          _spaceFor(current),
          previous: current,
        ),
      );
    }
    final double? number = double.tryParse(text);
    if (number == null || !number.isFinite) return (false, null);
    final HeroColorValue base =
        current ??
        HeroColorValue.fromColor(
          const Color(0x00000000),
          space: _spaceFor(null),
        );
    return (true, base.withChannelValue(channel, channel.range.snap(number)));
  }

  void _commitText() {
    if (widget.isReadOnly || widget.isDisabled) {
      _syncText(_format(_value));
      return;
    }
    if (!_dirty) return;
    final (bool valid, HeroColorValue? parsed) = _parse(_controller.text);
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    if (!valid || (parsed == null && (_channel != null || scope != null))) {
      _syncText(_format(_value));
      return;
    }
    _setValue(parsed);
    _fieldKey.currentState?.validate();
  }

  void _setValue(HeroColorValue? next) {
    final HeroColorValue? current = _value;
    _syncText(_format(next));
    if (next == current ||
        (next != null &&
            current != null &&
            next.isEquivalent(current) &&
            next.space == current.space)) {
      if (next != current) setState(() => _value = next);
      return;
    }
    setState(() {
      _value = next;
      _serverErrorsCleared = true;
    });
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    if (widget.value == null && scope != null && next != null) {
      scope.onChanged(next);
    }
    final Color? color = next?.toColor();
    _fieldKey.currentState?.didChange(color);
    widget.onChanged?.call(color);
  }

  // Steps the value by [delta] (the hex number or the channel), or jumps to
  // the minimum / maximum.
  void _step({double delta = 0, bool? toMax}) {
    if (widget.isReadOnly || widget.isDisabled) return;
    final (bool valid, HeroColorValue? parsed) = _parse(_controller.text);
    final HeroColorValue? current = valid ? parsed : _value;
    final HeroColorChannel? channel = _channel;
    if (channel == null) {
      final int hex = current?.toHexInt() ?? 0;
      final int next = toMax == null
          ? (hex + delta.round()).clamp(0, 0xFFFFFF)
          : (toMax ? 0xFFFFFF : 0);
      final HeroColorValue value = HeroColorValue.rgb(
        ((next >> 16) & 0xFF).toDouble(),
        ((next >> 8) & 0xFF).toDouble(),
        (next & 0xFF).toDouble(),
        current?.alpha ?? 1,
      );
      _setValue(
        heroResolveColorValue(
          value.toColor(),
          _spaceFor(current),
          previous: current,
        ),
      );
    } else {
      final HeroColorValue base =
          current ??
          HeroColorValue.fromColor(
            const Color(0x00000000),
            space: _spaceFor(null),
          );
      final HeroChannelRange range = channel.range;
      final double v = toMax == null
          ? range.snap(base.channelValue(channel) + delta)
          : (toMax ? range.max : range.min);
      _setValue(base.withChannelValue(channel, v));
    }
    _fieldKey.currentState?.validate();
  }

  double get _stepSize => _channel?.range.step ?? 1;

  double get _pageSize => _channel?.range.pageSize ?? 1;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _step(delta: _stepSize);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _step(delta: -_stepSize);
    } else if (key == LogicalKeyboardKey.pageUp) {
      _step(delta: _pageSize);
    } else if (key == LogicalKeyboardKey.pageDown) {
      _step(delta: -_pageSize);
    } else if (key == LogicalKeyboardKey.home) {
      _step(toMax: false);
    } else if (key == LogicalKeyboardKey.end) {
      _step(toMax: true);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent ||
        widget.isWheelDisabled ||
        !_focusNode.hasFocus) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, (
      PointerSignalEvent event,
    ) {
      final double dy = (event as PointerScrollEvent).scrollDelta.dy;
      if (dy == 0) return;
      _step(delta: dy < 0 ? _stepSize : -_stepSize);
    });
  }

  HeroValidationResult _clientValidation(HeroColorValue? value) {
    final String? error = widget.validator?.call(value?.toColor());
    if (error != null) return HeroValidationResult.invalid(<String>[error]);
    if (_behavior == HeroValidationBehavior.native &&
        widget.isRequired &&
        value == null) {
      return HeroValidationResult.invalid(<String>[
        widget.validationMessages.valueMissing,
      ]);
    }
    return HeroValidationResult.valid;
  }

  String? _validate(Color? _) {
    if (widget.isDisabled) return null;
    if (widget.isInvalid ?? false) {
      return widget.errorMessage ?? widget.validationMessages.invalidValue;
    }
    final List<String> server = _activeServerErrors;
    if (server.isNotEmpty) return server.join(' ');
    final HeroValidationResult client = _clientValidation(_value);
    return client.isInvalid ? client.validationErrors.join(' ') : null;
  }

  void _commitValidation() {
    _committed = _clientValidation(_value);
  }

  void _handleSaved(Color? value) {
    widget.onSaved?.call(_value?.toColor());
    final String? name = widget.name;
    if (name == null || widget.isDisabled) return;
    context.findAncestorStateOfType<HeroFormState>()?.addValue(
      name,
      _format(_value),
    );
  }

  void _handleReset() {
    _committed = HeroValidationResult.valid;
    _serverErrorsCleared = true;
    final HeroColorValue? initial = _initialValue;
    if (_value == initial) return;
    setState(() => _value = initial);
    _syncText(_format(initial));
    widget.onChanged?.call(initial?.toColor());
  }

  bool _autovalidates(FormFieldState<Color?> field) {
    return switch (widget.autovalidateMode ?? AutovalidateMode.disabled) {
      AutovalidateMode.always => true,
      AutovalidateMode.onUserInteraction => field.hasInteractedByUser,
      AutovalidateMode.onUserInteractionIfError =>
        field.hasInteractedByUser && _committed.isInvalid,
      AutovalidateMode.onUnfocus || AutovalidateMode.disabled => false,
    };
  }

  HeroValidationResult _displayValidation(FormFieldState<Color?> field) {
    final bool? controlled = widget.isInvalid;
    if (controlled != null) {
      return controlled
          ? const HeroValidationResult.invalid()
          : HeroValidationResult.valid;
    }
    final List<String> server = _activeServerErrors;
    if (server.isNotEmpty) return HeroValidationResult.invalid(server);
    if (_behavior == HeroValidationBehavior.aria || _autovalidates(field)) {
      return _clientValidation(_value);
    }
    return _committed;
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
    final HeroColorValue? value = _resolve(
      HeroColorPickerScope.maybeOf(context),
    );
    final String text = _format(value);
    // External changes of the value replace the text.
    if (text != _syncedText && !(_dirty && _focusNode.hasFocus)) {
      _syncText(text);
    }
    return _HeroColorFormField(
      key: _fieldKey,
      initialValue: _initialValue?.toColor(),
      validator: _validate,
      onSaved: _handleSaved,
      onReset: _handleReset,
      onValidate: _commitValidation,
      autovalidateMode: _behavior == HeroValidationBehavior.aria
          ? AutovalidateMode.always
          : widget.autovalidateMode,
      enabled: !widget.isDisabled,
      builder: _buildField,
    );
  }

  Widget _buildField(FormFieldState<Color?> field) {
    final BuildContext context = field.context;
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroValidationResult validation = _displayValidation(field);
    final bool invalid = validation.isInvalid;
    final HeroColorValue? value = _value;

    final List<Widget> children;
    final HeroColorFieldBuilder? builder = widget.builder;
    if (builder != null) {
      final bool focused = _focusNode.hasFocus;
      children = builder(
        context,
        HeroColorFieldState(
          value: value?.toColor(),
          isDisabled: widget.isDisabled,
          isInvalid: invalid,
          isReadOnly: widget.isReadOnly,
          isRequired: widget.isRequired,
          isFocusWithin: focused,
          isFocusVisible:
              focused &&
              FocusManager.instance.highlightMode ==
                  FocusHighlightMode.traditional,
          validation: validation,
        ),
      );
    } else {
      children = widget.children ?? _defaultChildren();
    }

    final bool adjustable = _channel != null;
    Widget content = HeroFieldLayout(
      spacing: widget.spacing ?? theme.spacing(1),
      fullWidth: widget.fullWidth,
      children: children,
    );
    if (value != null) {
      // Swatches without a color inside the field show the field's color.
      content = HeroColorPickerScope(
        value: value,
        onChanged: _setValue,
        child: content,
      );
    }
    content = HeroColorFieldInputScope(
      controller: _controller,
      focusNode: _focusNode,
      isChannel: adjustable,
      onKey: _handleKey,
      onSubmitted: (_) => _commitText(),
      onIncrease: adjustable ? () => _step(delta: _stepSize) : null,
      onDecrease: adjustable ? () => _step(delta: -_stepSize) : null,
      child: content,
    );
    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: HeroFieldScope(
        variant: widget.variant,
        isDisabled: widget.isDisabled,
        isInvalid: invalid,
        validationErrors: validation.validationErrors,
        isRequired: widget.isRequired,
        isReadOnly: widget.isReadOnly,
        hideDescriptionWhenInvalid: true,
        fullWidth: widget.fullWidth,
        focusNode: _focusNode,
        semanticLabel: widget.semanticLabel ?? _labelText(children),
        semanticHint: _hintText(children, validation),
        child: content,
      ),
    );
  }

  List<Widget> _defaultChildren() {
    final String? label = widget.label;
    final String? description = widget.description;
    final String? errorMessage = widget.errorMessage;
    final Widget? start = widget.startContent;
    final Widget? end = widget.endContent;
    return <Widget>[
      if (label != null) HeroLabel.text(label),
      HeroColorInputGroup(
        style: widget.groupStyle,
        children: <Widget>[
          if (widget.showSwatch || start != null)
            HeroColorInputPrefix(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: HeroTheme.of(context).spacing(2),
                children: <Widget>[
                  if (widget.showSwatch)
                    HeroColorSwatch(
                      size: HeroColorSwatchSize.xs,
                      color: _value == null
                          ? HeroColorSwatch.transparent
                          : null,
                    ),
                  ?start,
                ],
              ),
            ),
          HeroColorInput(
            placeholder: widget.placeholder,
            style: widget.inputStyle,
          ),
          if (end != null) HeroColorInputSuffix(child: end),
        ],
      ),
      if (description != null) HeroDescription.text(description),
      if (errorMessage != null)
        HeroFieldError.text(errorMessage)
      else
        const HeroFieldError(),
    ];
  }

  String? _labelText(List<Widget> children) {
    if (widget.label case final String label) return label;
    for (final Widget child in children) {
      if (child is HeroLabel) return child.data;
    }
    return null;
  }

  String? _hintText(List<Widget> children, HeroValidationResult validation) {
    if (validation.isInvalid) {
      String? error = widget.errorMessage;
      if (error == null) {
        for (final Widget child in children) {
          if (child is HeroFieldError) error ??= child.data;
        }
      }
      error ??= validation.validationErrors.join(' ');
      return error.isEmpty ? null : error;
    }
    if (widget.description case final String description) return description;
    for (final Widget child in children) {
      if (child is HeroDescription) return child.data;
    }
    return null;
  }
}

class _HeroColorFormField extends FormField<Color?> {
  const _HeroColorFormField({
    super.key,
    required super.builder,
    required this.onValidate,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.onReset,
    super.autovalidateMode,
    super.enabled,
  });

  final VoidCallback onValidate;

  @override
  FormFieldState<Color?> createState() => _HeroColorFormFieldState();
}

class _HeroColorFormFieldState extends FormFieldState<Color?> {
  @override
  _HeroColorFormField get widget => super.widget as _HeroColorFormField;

  @override
  bool validate() {
    widget.onValidate();
    return super.validate();
  }

  void syncValue(Color? value) => setValue(value);
}
