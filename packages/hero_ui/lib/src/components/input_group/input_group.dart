/// HeroUI's `InputGroup`: a text input with prefix and suffix addons inside
/// one field box.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../input/input.dart';
import '../text_area/text_area.dart';

/// The render props of a [HeroInputGroup] (React Aria's `GroupRenderProps`),
/// passed to its [HeroInputGroup.builder].
@immutable
class HeroInputGroupState {
  /// Creates input group render props.
  const HeroInputGroupState({
    this.isHovered = false,
    this.isFocusWithin = false,
    this.isFocusVisible = false,
    this.isDisabled = false,
    this.isInvalid = false,
  });

  /// Whether a mouse hovers the group.
  final bool isHovered;

  /// Whether the input or another control inside the group has focus.
  final bool isFocusWithin;

  /// Whether the focus inside the group is visible (keyboard navigation).
  final bool isFocusVisible;

  /// Whether the group is disabled.
  final bool isDisabled;

  /// Whether the group is invalid.
  final bool isInvalid;

  @override
  bool operator ==(Object other) =>
      other is HeroInputGroupState &&
      other.isHovered == isHovered &&
      other.isFocusWithin == isFocusWithin &&
      other.isFocusVisible == isFocusVisible &&
      other.isDisabled == isDisabled &&
      other.isInvalid == isInvalid;

  @override
  int get hashCode => Object.hash(
    isHovered,
    isFocusWithin,
    isFocusVisible,
    isDisabled,
    isInvalid,
  );
}

/// Builds the parts of a [HeroInputGroup] from its state (HeroUI's
/// render-function children).
typedef HeroInputGroupBuilder =
    List<Widget> Function(BuildContext context, HeroInputGroupState state);

/// A text input with addons (HeroUI `InputGroup`): a [HeroInputGroupPrefix],
/// a [HeroInputGroupInput] (or [HeroInputGroupTextArea]) and a
/// [HeroInputGroupSuffix] inside a single field box.
///
/// The box looks like `HeroInput` (`rounded-field`, `--field-background`,
/// the field shadow, `min-h-9`) and shows the hover background, the focus
/// ring while its input is focused, the invalid outline and the disabled
/// opacity. The addons are transparent, `px-3`, in `--field-placeholder`
/// with 16 px icons; the input loses its padding on the side of an addon.
/// With a text area the addons align to the top.
///
/// It is normally a part of a `HeroTextField`, whose label, variant,
/// validation, disabled and required states it takes:
///
/// ```dart
/// HeroTextField(
///   name: 'email',
///   children: <Widget>[
///     const HeroLabel.text('Email address'),
///     HeroInputGroup(
///       children: const <Widget>[
///         HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
///         HeroInputGroupInput(placeholder: 'name@email.com'),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// [startContent], [endContent] and [child] build the same parts:
/// `HeroInputGroup(startContent: const Text('https://'))`.
///
/// Pressing the group outside its controls focuses the input. Outside a
/// field root the group shrink-wraps its parts (the input is 192 wide
/// unless it sets a width); inside one, or with [fullWidth], it fills the
/// available width.
class HeroInputGroup extends StatefulWidget {
  /// Creates an input group.
  const HeroInputGroup({
    super.key,
    this.children,
    this.builder,
    this.startContent,
    this.endContent,
    this.child,
    this.variant,
    this.fullWidth = false,
    this.isDisabled = false,
    this.isInvalid = false,
    this.direction = Axis.horizontal,
    this.spacing = 0,
    this.padding,
    this.style,
    this.semanticLabel,
  });

  /// The parts: [HeroInputGroupPrefix], [HeroInputGroupInput] or
  /// [HeroInputGroupTextArea], [HeroInputGroupSuffix] (or other widgets).
  /// When null (and [builder] is null) the group builds them from
  /// [startContent], [child] and [endContent].
  final List<Widget>? children;

  /// Builds the parts from the group state; takes precedence over
  /// [children].
  final HeroInputGroupBuilder? builder;

  /// Content of a [HeroInputGroupPrefix] built before [child].
  final Widget? startContent;

  /// Content of a [HeroInputGroupSuffix] built after [child].
  final Widget? endContent;

  /// The input of the built group; defaults to a [HeroInputGroupInput].
  final Widget? child;

  /// Visual variant; null inherits from the enclosing field, then primary.
  final HeroFieldVariant? variant;

  /// Whether the group takes the full available width.
  final bool fullWidth;

  /// Whether the group looks disabled and ignores the pointer; also
  /// inherited from the enclosing field.
  final bool isDisabled;

  /// Whether the group shows the invalid outline; also inherited from the
  /// enclosing field.
  final bool isInvalid;

  /// The direction of the parts: a row (default) or a column (for a prompt
  /// box with actions under a text area).
  final Axis direction;

  /// Gap between the parts (`gap-*`); none by default.
  final double spacing;

  /// Padding between the box and the parts; none by default.
  final EdgeInsetsGeometry? padding;

  /// Visual overrides of the box (the counterpart of `className`).
  final HeroFieldStyle? style;

  /// Accessibility label of the group (`aria-label`).
  final String? semanticLabel;

  @override
  State<HeroInputGroup> createState() => _HeroInputGroupState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<HeroFieldVariant>('variant', variant, defaultValue: null),
      )
      ..add(FlagProperty('fullWidth', value: fullWidth, ifTrue: 'full width'))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isInvalid', value: isInvalid, ifTrue: 'invalid'))
      ..add(
        EnumProperty<Axis>(
          'direction',
          direction,
          defaultValue: Axis.horizontal,
        ),
      );
  }
}

class _HeroInputGroupState extends State<HeroInputGroup> {
  FocusNode? _ownInputFocusNode;
  FocusNode? _inputFocusNode;
  bool _hovered = false;
  bool _focusWithin = false;

  /// The focus node of an input that has no node of its own (and no field
  /// providing one).
  FocusNode get defaultInputFocusNode =>
      _ownInputFocusNode ??= FocusNode(debugLabel: 'HeroInputGroupInput');

  @override
  void dispose() {
    _inputFocusNode?.removeListener(_handleInputFocusChanged);
    _ownInputFocusNode?.dispose();
    super.dispose();
  }

  /// Called by the input part with the focus node it edits with.
  void attachInput(FocusNode node) {
    if (identical(node, _inputFocusNode)) return;
    _inputFocusNode?.removeListener(_handleInputFocusChanged);
    _inputFocusNode = node;
    node.addListener(_handleInputFocusChanged);
    if (node.hasFocus) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  /// Called by the input part when it goes away.
  void detachInput(FocusNode node) {
    if (!identical(node, _inputFocusNode)) return;
    node.removeListener(_handleInputFocusChanged);
    _inputFocusNode = null;
  }

  void _handleInputFocusChanged() {
    if (mounted) setState(() {});
  }

  void _handleFocusWithin(bool value) {
    if (_focusWithin == value) return;
    setState(() => _focusWithin = value);
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    _hovered = value;
    // Only the builder shows the hover state; the box tracks its own.
    if (widget.builder != null) setState(() {});
  }

  void _focusInput() {
    final FocusNode? node = _inputFocusNode;
    if (node != null && node.canRequestFocus && !node.hasFocus) {
      node.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldScope? field = HeroFieldScope.maybeOf(context);
    final bool disabled =
        widget.isDisabled ||
        (field?.isDisabled ?? false) ||
        HeroDisabledScope.of(context);
    final bool invalid = widget.isInvalid || (field?.isInvalid ?? false);
    final HeroFieldVariant variant =
        widget.variant ?? field?.variant ?? HeroFieldVariant.primary;
    final bool fullWidth = widget.fullWidth || (field?.fullWidth ?? false);
    final bool inputFocused = !disabled && (_inputFocusNode?.hasFocus ?? false);

    final List<Widget> children =
        widget.builder?.call(
          context,
          HeroInputGroupState(
            isHovered: _hovered && !disabled,
            isFocusWithin: _focusWithin,
            isFocusVisible:
                _focusWithin &&
                FocusManager.instance.highlightMode ==
                    FocusHighlightMode.traditional,
            isDisabled: disabled,
            isInvalid: invalid,
          ),
        ) ??
        widget.children ??
        _defaultChildren();

    final bool hasPrefix = children.any(
      (Widget child) => child is HeroInputGroupPrefix,
    );
    final bool hasSuffix = children.any(
      (Widget child) => child is HeroInputGroupSuffix,
    );
    final bool hasTextArea = children.any(
      (Widget child) => child is HeroInputGroupTextArea,
    );
    final bool vertical = widget.direction == Axis.vertical;

    Widget content = vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: widget.spacing,
            children: children,
          )
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: widget.spacing,
              children: <Widget>[
                for (final Widget child in children)
                  if (child is HeroInputGroupInput ||
                      child is HeroInputGroupTextArea)
                    Expanded(child: child)
                  else
                    child,
              ],
            ),
          );
    final EdgeInsetsGeometry? padding = widget.padding;
    if (padding != null) content = Padding(padding: padding, child: content);

    Widget result = HeroFieldBox(
      variant: variant,
      isFocused: inputFocused,
      isInvalid: invalid,
      isDisabled: disabled,
      style: widget.style,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: theme.spacing(9)),
        child: _HeroInputGroupScope(
          state: this,
          variant: variant,
          hasPrefix: hasPrefix,
          hasSuffix: hasSuffix,
          hasTextArea: hasTextArea,
          direction: widget.direction,
          child: content,
        ),
      ),
    );

    result = MouseRegion(
      opaque: false,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: disabled ? null : _focusInput,
        child: result,
      ),
    );
    result = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: _handleFocusWithin,
      child: IgnorePointer(ignoring: disabled, child: result),
    );
    if (!fullWidth) result = IntrinsicWidth(child: result);

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: result,
    );
  }

  List<Widget> _defaultChildren() {
    final Widget? start = widget.startContent;
    final Widget? end = widget.endContent;
    return <Widget>[
      if (start != null) HeroInputGroupPrefix(child: start),
      widget.child ?? const HeroInputGroupInput(),
      if (end != null) HeroInputGroupSuffix(child: end),
    ];
  }
}

/// Shares the layout of a [HeroInputGroup] with its parts.
class _HeroInputGroupScope extends InheritedWidget {
  const _HeroInputGroupScope({
    required this.state,
    required this.variant,
    required this.hasPrefix,
    required this.hasSuffix,
    required this.hasTextArea,
    required this.direction,
    required super.child,
  });

  final _HeroInputGroupState state;
  final HeroFieldVariant variant;
  final bool hasPrefix;
  final bool hasSuffix;
  final bool hasTextArea;
  final Axis direction;

  static _HeroInputGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroInputGroupScope>();

  @override
  bool updateShouldNotify(_HeroInputGroupScope oldWidget) =>
      state != oldWidget.state ||
      variant != oldWidget.variant ||
      hasPrefix != oldWidget.hasPrefix ||
      hasSuffix != oldWidget.hasSuffix ||
      hasTextArea != oldWidget.hasTextArea ||
      direction != oldWidget.direction;
}

/// The content before the input of a [HeroInputGroup] (HeroUI
/// `InputGroup.Prefix`): an icon, a text such as `https://` or `$`, or a
/// control.
///
/// Transparent, full height, centred, `px-3`, text and icons in
/// `--field-placeholder` (icons 16 px). With a text area it aligns to the
/// top with 8 px of top padding. A themed field border width draws a
/// divider on its inner side.
class HeroInputGroupPrefix extends StatelessWidget {
  /// Creates a prefix showing [child].
  const HeroInputGroupPrefix({
    super.key,
    required this.child,
    this.padding,
    this.alignment,
    this.style,
  });

  /// The prefix content.
  final Widget child;

  /// Padding around [child]; defaults to 12 horizontally (`px-3`), plus 8
  /// at the top next to a text area.
  final EdgeInsetsGeometry? padding;

  /// Alignment of [child]; defaults to the centre (the top next to a text
  /// area, the start in a vertical group).
  final AlignmentGeometry? alignment;

  /// Text style merged over the addon style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => _HeroInputGroupAddon(
    isPrefix: true,
    padding: padding,
    alignment: alignment,
    style: style,
    child: child,
  );
}

/// The content after the input of a [HeroInputGroup] (HeroUI
/// `InputGroup.Suffix`): an icon, a text such as `.com` or `USD`, a
/// spinner, a keyboard shortcut, a chip or a button.
///
/// Styled like [HeroInputGroupPrefix]; set [padding] to tighten the end
/// padding around a button (`pe-0`) or a chip (`pe-2`).
class HeroInputGroupSuffix extends StatelessWidget {
  /// Creates a suffix showing [child].
  const HeroInputGroupSuffix({
    super.key,
    required this.child,
    this.padding,
    this.alignment,
    this.style,
  });

  /// The suffix content.
  final Widget child;

  /// Padding around [child]; defaults to 12 horizontally (`px-3`), plus 8
  /// at the top next to a text area.
  final EdgeInsetsGeometry? padding;

  /// Alignment of [child]; defaults to the centre (the top next to a text
  /// area, the start in a vertical group).
  final AlignmentGeometry? alignment;

  /// Text style merged over the addon style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => _HeroInputGroupAddon(
    isPrefix: false,
    padding: padding,
    alignment: alignment,
    style: style,
    child: child,
  );
}

class _HeroInputGroupAddon extends StatelessWidget {
  const _HeroInputGroupAddon({
    required this.isPrefix,
    required this.child,
    this.padding,
    this.alignment,
    this.style,
  });

  final bool isPrefix;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final _HeroInputGroupScope? group = _HeroInputGroupScope.maybeOf(context);
    final bool textArea = group?.hasTextArea ?? false;
    final bool vertical = group?.direction == Axis.vertical;

    Widget result = Padding(
      padding:
          padding ??
          EdgeInsetsDirectional.only(
            start: theme.spacing(3),
            end: theme.spacing(3),
            top: textArea ? theme.spacing(2) : 0,
          ),
      child: IconTheme.merge(
        data: IconThemeData(
          size: theme.spacing(4),
          color: colors.fieldPlaceholder,
        ),
        child: DefaultTextStyle.merge(
          style: theme.typography.sm
              .copyWith(color: colors.fieldPlaceholder)
              .merge(style),
          child: child,
        ),
      ),
    );
    result = Align(
      alignment:
          alignment ??
          (vertical
              ? AlignmentDirectional.centerStart
              : textArea
              ? AlignmentDirectional.topCenter
              : AlignmentDirectional.center),
      widthFactor: vertical ? null : 1,
      heightFactor: 1,
      child: result,
    );

    // The divider on the inner side (`border-inline-end` of the prefix,
    // `border-inline-start` of the suffix), invisible at the default field
    // border width of 0.
    final double borderWidth = theme.fieldBorderWidth;
    if (borderWidth > 0 && !vertical) {
      final BorderSide side = BorderSide(
        color: colors.fieldBorder,
        width: borderWidth,
      );
      result = DecoratedBox(
        decoration: BoxDecoration(
          border: BorderDirectional(
            end: isPrefix ? side : BorderSide.none,
            start: isPrefix ? BorderSide.none : side,
          ),
        ),
        child: result,
      );
    }
    return result;
  }
}

/// The single-line input of a [HeroInputGroup] (HeroUI
/// `InputGroup.Input`): transparent, no radius or border, `px-3 py-2`
/// without the padding on the side of an addon, `text-base` (`text-sm`
/// from the `sm` breakpoint).
///
/// Inside a `HeroTextField` it edits the field's text, uses its focus node
/// and inherits its type and states; the field owns the form state.
/// Standalone it manages its own text and registers a `FormField<String>`
/// like `HeroInput`.
class HeroInputGroupInput extends StatelessWidget {
  /// Creates the input of an input group.
  const HeroInputGroupInput({
    super.key,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.placeholder,
    this.type = HeroInputType.text,
    this.width,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid = false,
    this.name,
    this.autofillHints,
    this.maxLength,
    this.minLength,
    this.pattern,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.semanticLabel,
    this.style,
  });

  /// Controls the text; defaults to the field's controller, then its own.
  final TextEditingController? controller;

  /// Focus node; defaults to the field's, then one owned by the group.
  final FocusNode? focusNode;

  /// The current value (controlled).
  final String? value;

  /// The initial value (uncontrolled).
  final String? defaultValue;

  /// Called on every user edit.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits with the keyboard action or Enter.
  final ValueChanged<String>? onSubmitted;

  /// Called on each tap on the input.
  final VoidCallback? onTap;

  /// Text shown while the input is empty.
  final String? placeholder;

  /// The input type; inside a field the default takes the field's type.
  final HeroInputType type;

  /// Width of the input when the group shrink-wraps; defaults to the
  /// browser's default input width (192). Inside a sized group the input
  /// fills the space the addons leave (`flex-1`).
  final double? width;

  /// Whether the input is disabled.
  final bool isDisabled;

  /// Whether the text can be selected but not edited.
  final bool isReadOnly;

  /// Whether a value is required.
  final bool isRequired;

  /// Reports an invalid value (the group shows the outline).
  final bool isInvalid;

  /// The name of the value in the data a `HeroForm` submits.
  final String? name;

  /// Autofill hints.
  final Iterable<String>? autofillHints;

  /// Maximum number of characters.
  final int? maxLength;

  /// Minimum number of characters (validation).
  final int? minLength;

  /// Pattern the whole value must match (validation).
  final RegExp? pattern;

  /// Additional validation of a standalone input.
  final FormFieldValidator<String>? validator;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// When a standalone input validates automatically.
  final AutovalidateMode? autovalidateMode;

  /// Whether to focus the input when first built.
  final bool autofocus;

  /// Keyboard type; defaults to the one of [type].
  final TextInputType? keyboardType;

  /// Keyboard action button; defaults to the one of [type].
  final TextInputAction? textInputAction;

  /// Automatic capitalization.
  final TextCapitalization textCapitalization;

  /// Whether to obscure the text; defaults to true for passwords.
  final bool? obscureText;

  /// Extra input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Horizontal text alignment.
  final TextAlign textAlign;

  /// Accessibility label (`aria-label`).
  final String? semanticLabel;

  /// Text, placeholder, caret and padding overrides.
  final HeroFieldStyle? style;

  @override
  Widget build(BuildContext context) {
    return _HeroInputGroupEditable(
      controller: controller,
      focusNode: focusNode,
      value: value,
      defaultValue: defaultValue,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      placeholder: placeholder,
      type: type,
      width: width,
      isDisabled: isDisabled,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isInvalid: isInvalid,
      name: name,
      autofillHints: autofillHints,
      maxLength: maxLength,
      minLength: minLength,
      pattern: pattern,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      semanticLabel: semanticLabel,
      style: style,
      debugLabel: 'HeroInputGroupInput',
    );
  }
}

/// The multi-line input of a [HeroInputGroup] (HeroUI
/// `InputGroup.TextArea`): like [HeroInputGroupInput] with [rows] visible
/// lines and `min-height: 38px`. The group then aligns its addons to the
/// top and grows with the text area.
class HeroInputGroupTextArea extends StatelessWidget {
  /// Creates the text area of an input group.
  const HeroInputGroupTextArea({
    super.key,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onTap,
    this.placeholder,
    this.rows = 2,
    this.width,
    this.height,
    this.resize = HeroTextAreaResize.none,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid = false,
    this.name,
    this.maxLength,
    this.minLength,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.semanticLabel,
    this.style,
  }) : assert(rows > 0);

  /// Controls the text; defaults to the field's controller, then its own.
  final TextEditingController? controller;

  /// Focus node; defaults to the field's, then one owned by the group.
  final FocusNode? focusNode;

  /// The current value (controlled).
  final String? value;

  /// The initial value (uncontrolled).
  final String? defaultValue;

  /// Called on every user edit.
  final ValueChanged<String>? onChanged;

  /// Called on each tap on the text area.
  final VoidCallback? onTap;

  /// Text shown while the text area is empty.
  final String? placeholder;

  /// Number of visible lines (`rows`); longer text scrolls.
  final int rows;

  /// Width of the text area when the group shrink-wraps.
  final double? width;

  /// Explicit height; defaults to [rows] lines plus the padding.
  final double? height;

  /// Whether the user can drag the height (`resize`).
  final HeroTextAreaResize resize;

  /// Whether the text area is disabled.
  final bool isDisabled;

  /// Whether the text can be selected but not edited.
  final bool isReadOnly;

  /// Whether a value is required.
  final bool isRequired;

  /// Reports an invalid value.
  final bool isInvalid;

  /// The name of the value in the data a `HeroForm` submits.
  final String? name;

  /// Maximum number of characters.
  final int? maxLength;

  /// Minimum number of characters (validation).
  final int? minLength;

  /// Additional validation of a standalone text area.
  final FormFieldValidator<String>? validator;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// When a standalone text area validates automatically.
  final AutovalidateMode? autovalidateMode;

  /// Whether to focus the text area when first built.
  final bool autofocus;

  /// Automatic capitalization.
  final TextCapitalization textCapitalization;

  /// Extra input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Accessibility label (`aria-label`).
  final String? semanticLabel;

  /// Text, placeholder, caret and padding overrides.
  final HeroFieldStyle? style;

  @override
  Widget build(BuildContext context) {
    return _HeroInputGroupEditable(
      controller: controller,
      focusNode: focusNode,
      value: value,
      defaultValue: defaultValue,
      onChanged: onChanged,
      onTap: onTap,
      placeholder: placeholder,
      rows: rows,
      width: width,
      height: height,
      resize: resize,
      isDisabled: isDisabled,
      isReadOnly: isReadOnly,
      isRequired: isRequired,
      isInvalid: isInvalid,
      name: name,
      maxLength: maxLength,
      minLength: minLength,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      semanticLabel: semanticLabel,
      style: style,
      debugLabel: 'HeroInputGroupTextArea',
    );
  }
}

/// The editable part shared by [HeroInputGroupInput] and
/// [HeroInputGroupTextArea]: a [HeroTextInputCore] without its own box,
/// connected to the group's focus handling.
class _HeroInputGroupEditable extends StatefulWidget {
  const _HeroInputGroupEditable({
    required this.debugLabel,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.placeholder,
    this.type = HeroInputType.text,
    this.rows,
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
    this.pattern,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.semanticLabel,
    this.style,
  });

  final String debugLabel;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? value;
  final String? defaultValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? placeholder;
  final HeroInputType type;

  /// Visible lines of a text area; null for a single-line input.
  final int? rows;
  final double? width;
  final double? height;
  final HeroTextAreaResize resize;
  final bool isDisabled;
  final bool isReadOnly;
  final bool isRequired;
  final bool isInvalid;
  final String? name;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final int? minLength;
  final RegExp? pattern;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final AutovalidateMode? autovalidateMode;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final String? semanticLabel;
  final HeroFieldStyle? style;

  @override
  State<_HeroInputGroupEditable> createState() =>
      _HeroInputGroupEditableState();
}

class _HeroInputGroupEditableState extends State<_HeroInputGroupEditable> {
  _HeroInputGroupScope? _group;
  HeroFieldScope? _field;
  FocusNode? _attached;
  double? _draggedHeight;

  FocusNode? get _focusNode =>
      widget.focusNode ??
      _field?.focusNode ??
      _group?.state.defaultInputFocusNode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = _HeroInputGroupScope.maybeOf(context);
    _field = HeroFieldScope.maybeOf(context);
    _attach();
  }

  @override
  void didUpdateWidget(_HeroInputGroupEditable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach();
  }

  @override
  void dispose() {
    final FocusNode? attached = _attached;
    if (attached != null) _group?.state.detachInput(attached);
    super.dispose();
  }

  void _attach() {
    final FocusNode? node = _focusNode;
    if (identical(node, _attached)) return;
    final FocusNode? previous = _attached;
    if (previous != null) _group?.state.detachInput(previous);
    _attached = node;
    if (node != null) _group?.state.attachInput(node);
  }

  void _handleDrag(DragUpdateDetails details) {
    final double current = _draggedHeight ?? context.size!.height;
    final HeroThemeData theme = HeroTheme.of(context);
    setState(() {
      _draggedHeight = current + details.delta.dy < theme.spacing(9.5)
          ? theme.spacing(9.5)
          : current + details.delta.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroInputGroupScope? group = _group;
    final int? rows = widget.rows;
    final bool multiline = rows != null;
    final EdgeInsetsDirectional padding = EdgeInsetsDirectional.fromSTEB(
      (group?.hasPrefix ?? false) ? 0 : theme.spacing(3),
      theme.spacing(2),
      (group?.hasSuffix ?? false) ? 0 : theme.spacing(3),
      theme.spacing(2),
    );
    final HeroFieldStyle style = HeroFieldStyle(
      padding: padding,
    ).merge(widget.style);

    final Widget field = HeroTextInputCore(
      controller: widget.controller,
      focusNode: _focusNode,
      value: widget.value,
      defaultValue: widget.defaultValue,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      placeholder: widget.placeholder,
      type: widget.type,
      variant: group?.variant,
      width: widget.width ?? HeroFieldMetrics.defaultWidth(theme),
      height: _draggedHeight ?? widget.height,
      minHeight: multiline ? theme.spacing(9.5) : null,
      maxLines: rows ?? 1,
      minLines: rows,
      decorated: false,
      isDisabled: widget.isDisabled,
      isReadOnly: widget.isReadOnly,
      isRequired: widget.isRequired,
      isInvalid: widget.isInvalid,
      name: widget.name,
      autofillHints: widget.autofillHints,
      maxLength: widget.maxLength,
      minLength: widget.minLength,
      pattern: widget.pattern,
      validator: widget.validator,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText,
      inputFormatters: widget.inputFormatters,
      textAlign: widget.textAlign,
      semanticLabel: widget.semanticLabel,
      style: style,
      debugLabel: widget.debugLabel,
    );

    final bool disabled =
        widget.isDisabled ||
        (_field?.isDisabled ?? false) ||
        HeroDisabledScope.of(context);
    if (!multiline || widget.resize == HeroTextAreaResize.none || disabled) {
      return field;
    }
    return Stack(
      children: <Widget>[
        field,
        PositionedDirectional(
          end: 0,
          bottom: 0,
          child: HeroTextAreaResizeGrip(onDrag: _handleDrag),
        ),
      ],
    );
  }
}
