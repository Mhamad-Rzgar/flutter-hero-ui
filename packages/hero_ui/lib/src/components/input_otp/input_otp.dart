/// HeroUI's `InputOTP`: a one-time password input made of single-character
/// slots.
library;

import 'dart:math' as math;
import 'dart:ui' show SemanticsValidationResult;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../form/form.dart';
import '../input/input.dart';

/// Transforms pasted (or autofilled) text before it is inserted into a
/// [HeroInputOTP], for example to remove dashes (`pasteTransformer`).
typedef HeroInputOTPPasteTransformer = String Function(String text);

/// A one-time password input (HeroUI `InputOTP`): [maxLength] slots, in
/// [HeroInputOTPGroup]s separated by [HeroInputOTPSeparator]s, showing one
/// character each.
///
/// ```dart
/// HeroInputOTP(
///   maxLength: 6,
///   onCompleted: (String code) => verify(code),
///   children: const <Widget>[
///     HeroInputOTPGroup(
///       children: <Widget>[
///         HeroInputOTPSlot(index: 0),
///         HeroInputOTPSlot(index: 1),
///         HeroInputOTPSlot(index: 2),
///       ],
///     ),
///     HeroInputOTPSeparator(),
///     HeroInputOTPGroup(
///       children: <Widget>[
///         HeroInputOTPSlot(index: 3),
///         HeroInputOTPSlot(index: 4),
///         HeroInputOTPSlot(index: 5),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// Without [children] the input builds its groups from [groupSizes]
/// (`HeroInputOTP(maxLength: 6, groupSizes: [3, 3])`), one group of
/// [maxLength] slots by default.
///
/// One hidden text input edits the code; the slots only show its state,
/// like the `input-otp` library HeroUI builds on:
///
/// * typing fills the active slot and moves to the next one; characters
///   that do not match [pattern] (for example [regexpOnlyDigits]) are
///   rejected, and the code never exceeds [maxLength];
/// * Backspace removes the previous character; ArrowLeft / ArrowRight move
///   the active slot, and a filled active slot is replaced by typing;
/// * pasted or autofilled text passes through [pasteTransformer] and fills
///   the slots from the caret;
/// * focusing (by tapping anywhere on the input) activates the first empty
///   slot, or the last slot when the code is complete;
/// * [onCompleted] is called whenever an edit leaves [maxLength] characters.
///
/// The active slot shows the focus ring and, while empty, a blinking caret;
/// characters appear with a short rise and scale animation. The input is
/// controlled with [value] + [onChanged], uncontrolled with [defaultValue]
/// or driven by a [controller], and registers a `FormField<String>` with
/// the nearest `Form` ([validator], [onSaved], [name]).
class HeroInputOTP extends StatefulWidget {
  /// Creates a one-time password input with [maxLength] slots.
  const HeroInputOTP({
    super.key,
    required this.maxLength,
    this.children,
    this.groupSizes,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    this.variant = HeroFieldVariant.primary,
    this.isDisabled = false,
    this.isInvalid = false,
    this.validationErrors,
    this.pattern,
    this.pasteTransformer,
    this.placeholder,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.autofocus = false,
    this.name,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.spacing,
    this.semanticLabel,
  }) : assert(maxLength > 0);

  /// Only digits (`REGEXP_ONLY_DIGITS`).
  static const String regexpOnlyDigits = r'^\d+$';

  /// Only letters (`REGEXP_ONLY_CHARS`).
  static const String regexpOnlyChars = r'^[a-zA-Z]+$';

  /// Only letters and digits (`REGEXP_ONLY_DIGITS_AND_CHARS`).
  static const String regexpOnlyDigitsAndChars = r'^[a-zA-Z0-9]+$';

  /// The number of characters (and slots).
  final int maxLength;

  /// The groups, separators and slots. When null the input builds them
  /// from [groupSizes].
  final List<Widget>? children;

  /// The number of slots of each built group, separated by separators;
  /// defaults to one group of [maxLength] slots.
  final List<int>? groupSizes;

  /// Controls the code; when null the input owns a controller.
  final TextEditingController? controller;

  /// Focus node of the hidden input; when null the input owns one.
  final FocusNode? focusNode;

  /// The current code (controlled).
  final String? value;

  /// The initial code (uncontrolled).
  final String? defaultValue;

  /// Called on every user edit (`onChange`).
  final ValueChanged<String>? onChanged;

  /// Called when an edit leaves [maxLength] characters (`onComplete`).
  final ValueChanged<String>? onCompleted;

  /// Called when the user submits with the keyboard action or Enter; the
  /// enclosing `HeroForm` is submitted as well.
  final ValueChanged<String>? onSubmitted;

  /// Visual variant of the slots.
  final HeroFieldVariant variant;

  /// Whether the input is disabled: the slots fade and it cannot be
  /// focused.
  final bool isDisabled;

  /// Whether the slots show the invalid outline.
  final bool isInvalid;

  /// Messages shown by a `HeroFieldError` that reads the input's field
  /// scope.
  final List<String>? validationErrors;

  /// A regular expression the whole code must match (`pattern`), for
  /// example [regexpOnlyDigits]; input that does not match is rejected.
  final String? pattern;

  /// Transforms pasted or autofilled text before insertion.
  final HeroInputOTPPasteTransformer? pasteTransformer;

  /// Characters shown in the empty slots while the code is empty, one per
  /// slot.
  final String? placeholder;

  /// Alignment of the hidden input's text (`textAlign`); it has no visible
  /// effect.
  final TextAlign textAlign;

  /// The on-screen keyboard (`inputMode`); defaults to the number keyboard,
  /// or a text keyboard when [pattern] allows letters.
  final TextInputType? keyboardType;

  /// Whether to focus the input when first built (`autoFocus`).
  final bool autofocus;

  /// The name of the code in the data a [HeroForm] submits.
  final String? name;

  /// Validates the code when the form validates.
  final FormFieldValidator<String>? validator;

  /// Called with the code when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// When the form field validates automatically.
  final AutovalidateMode? autovalidateMode;

  /// Gap between groups, separators and slots; defaults to 8 (`gap-2`).
  final double? spacing;

  /// Accessibility label (the text of the label next to the input).
  final String? semanticLabel;

  @override
  State<HeroInputOTP> createState() => _HeroInputOTPState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IntProperty('maxLength', maxLength))
      ..add(StringProperty('value', value, defaultValue: null))
      ..add(StringProperty('pattern', pattern, defaultValue: null))
      ..add(
        EnumProperty<HeroFieldVariant>(
          'variant',
          variant,
          defaultValue: HeroFieldVariant.primary,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isInvalid', value: isInvalid, ifTrue: 'invalid'));
  }
}

class _HeroInputOTPState extends State<HeroInputOTP> {
  final GlobalKey<EditableTextState> _editableKey =
      GlobalKey<EditableTextState>();
  final GlobalKey<_HeroOTPFormFieldState> _fieldKey =
      GlobalKey<_HeroOTPFormFieldState>();
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  TextEditingController? _listenedController;
  FocusNode? _listenedFocusNode;
  late String _initialText;
  TextSelection? _previousSelection;
  bool _normalizing = false;
  bool _scopeDisabled = false;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(text: _initialText));

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroInputOTP'));

  bool get _disabled => widget.isDisabled || _scopeDisabled;

  RegExp? get _pattern {
    final String? pattern = widget.pattern;
    return pattern == null ? null : RegExp(pattern);
  }

  @override
  void initState() {
    super.initState();
    _initialText = _clip(
      widget.value ?? widget.defaultValue ?? widget.controller?.text ?? '',
    );
    final String? value = widget.value;
    if (value != null && widget.controller != null) {
      widget.controller!.text = _clip(value);
    }
    _attach();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scopeDisabled = HeroDisabledScope.of(context);
    _focusNode.canRequestFocus = !_disabled;
  }

  @override
  void didUpdateWidget(HeroInputOTP oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach();
    _focusNode.canRequestFocus = !_disabled;
    final String? value = widget.value;
    if (value != null && _clip(value) != _controller.text) {
      final String text = _clip(value);
      _controller.value = TextEditingValue(
        text: text,
        selection: _focusSelection(text),
      );
      // A new controlled value is not a user edit: it must not notify the
      // form while widgets build.
      _fieldKey.currentState?.syncValue(text);
    }
  }

  @override
  void dispose() {
    _listenedController?.removeListener(_handleControllerChanged);
    _listenedFocusNode?.removeListener(_handleFocusChanged);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  String _clip(String text) => text.length > widget.maxLength
      ? text.substring(0, widget.maxLength)
      : text;

  void _attach() {
    final TextEditingController controller = _controller;
    if (!identical(controller, _listenedController)) {
      _listenedController?.removeListener(_handleControllerChanged);
      controller.addListener(_handleControllerChanged);
      _listenedController = controller;
    }
    final FocusNode node = _focusNode;
    if (!identical(node, _listenedFocusNode)) {
      _listenedFocusNode?.removeListener(_handleFocusChanged);
      node.addListener(_handleFocusChanged);
      _listenedFocusNode = node;
    }
  }

  /// The selection `input-otp` sets on focus: the first empty slot, or the
  /// last character when the code is complete.
  TextSelection _focusSelection(String text) => TextSelection(
    baseOffset: math.min(text.length, widget.maxLength - 1),
    extentOffset: text.length,
  );

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      _setSelection(_focusSelection(_controller.text));
    }
    if (mounted) setState(() {});
  }

  void _setSelection(TextSelection selection) {
    if (_controller.selection == selection) return;
    _normalizing = true;
    _controller.selection = selection;
    _normalizing = false;
    _previousSelection = selection;
  }

  /// Keeps a single-character selection unless the caret is at the end of
  /// an incomplete code, like `input-otp`'s selection listener: the
  /// selected character is the active slot and typing replaces it.
  void _handleControllerChanged() {
    if (_normalizing) return;
    final TextEditingValue value = _controller.value;
    final String text = value.text;
    final TextSelection selection = value.selection;
    final int max = widget.maxLength;
    if (!_focusNode.hasFocus || !selection.isValid || text.isEmpty) {
      _previousSelection = selection;
      if (mounted) setState(() {});
      return;
    }
    final int caret = selection.baseOffset;
    final bool insertMode = caret == text.length && text.length < max;
    TextSelection? next;
    if (selection.isCollapsed && !insertMode) {
      if (caret == 0) {
        next = const TextSelection(baseOffset: 0, extentOffset: 1);
      } else if (caret >= max) {
        next = TextSelection(baseOffset: max - 1, extentOffset: max);
      } else if (max > 1 && text.length > 1) {
        int offset = 0;
        final TextSelection? previous = _previousSelection;
        if (previous != null && previous.isValid) {
          final bool backward = caret < previous.end;
          final bool wasInserting =
              previous.isCollapsed && previous.start < max;
          if (backward && !wasInserting) offset = -1;
        }
        final int start = (caret + offset).clamp(0, text.length - 1);
        next = TextSelection(baseOffset: start, extentOffset: start + 1);
      }
    }
    if (next != null && next != selection) {
      _setSelection(next);
    } else {
      _previousSelection = selection;
    }
    if (mounted) setState(() {});
  }

  void _handleChanged(String text) {
    _fieldKey.currentState?.didChange(text);
    widget.onChanged?.call(text);
    if (text.length == widget.maxLength) widget.onCompleted?.call(text);
  }

  void _handleSubmitted(String text) {
    widget.onSubmitted?.call(text);
    if (!mounted) return;
    context.findAncestorStateOfType<HeroFormState>()?.submit();
  }

  void _handleTap() {
    if (_disabled) return;
    if (_focusNode.hasFocus) {
      _editableKey.currentState?.requestKeyboard();
    } else {
      _focusNode.requestFocus();
    }
  }

  void _handleLongPress() {
    if (_disabled) return;
    _focusNode.requestFocus();
    _editableKey.currentState?.showToolbar();
  }

  void _handleSaved(String? value) {
    widget.onSaved?.call(value);
    final String? name = widget.name;
    if (name == null || _disabled) return;
    context.findAncestorStateOfType<HeroFormState>()?.addValue(
      name,
      value ?? '',
    );
  }

  void _handleReset() {
    final String text = widget.value ?? _initialText;
    if (_controller.text == text) return;
    _controller.text = text;
    widget.onChanged?.call(text);
  }

  TextInputType get _keyboardType {
    final TextInputType? type = widget.keyboardType;
    if (type != null) return type;
    final String? pattern = widget.pattern;
    if (pattern == null || pattern == HeroInputOTP.regexpOnlyDigits) {
      return TextInputType.number;
    }
    return TextInputType.visiblePassword;
  }

  List<Widget> _defaultChildren() {
    final List<int> sizes = widget.groupSizes ?? <int>[widget.maxLength];
    final List<Widget> children = <Widget>[];
    int index = 0;
    for (int group = 0; group < sizes.length; group++) {
      if (group > 0) children.add(const HeroInputOTPSeparator());
      children.add(
        HeroInputOTPGroup(
          children: <Widget>[
            for (int i = 0; i < sizes[group]; i++)
              HeroInputOTPSlot(index: index + i),
          ],
        ),
      );
      index += sizes[group];
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return _HeroOTPFormField(
      key: _fieldKey,
      initialValue: _controller.text,
      validator: widget.validator,
      onSaved: _handleSaved,
      onReset: _handleReset,
      autovalidateMode: widget.autovalidateMode,
      enabled: !_disabled,
      builder: _buildField,
    );
  }

  Widget _buildField(FormFieldState<String> field) {
    final BuildContext context = field.context;
    final HeroThemeData theme = HeroTheme.of(context);
    final TextEditingValue value = _controller.value;
    final bool focused = _focusNode.hasFocus && !_disabled;
    final bool invalid = widget.isInvalid || field.hasError;
    final List<String> errors =
        widget.validationErrors ??
        <String>[if (field.errorText case final String error) error];
    final List<Widget> children = widget.children ?? _defaultChildren();
    final double gap = widget.spacing ?? theme.spacing(2);

    final Widget hidden = Positioned.fill(
      child: Opacity(
        opacity: 0,
        alwaysIncludeSemantics: true,
        child: EditableText(
          key: _editableKey,
          controller: _controller,
          focusNode: _focusNode,
          readOnly: _disabled,
          autofocus: widget.autofocus,
          style: theme.typography.sm.copyWith(
            color: theme.colors.fieldForeground.withValues(alpha: 0),
          ),
          textAlign: widget.textAlign,
          cursorColor: theme.colors.fieldForeground.withValues(alpha: 0),
          backgroundCursorColor: theme.colors.fieldForeground.withValues(
            alpha: 0,
          ),
          showCursor: false,
          selectionColor: theme.colors.focus.withValues(alpha: 0),
          maxLines: 1,
          keyboardType: _keyboardType,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          enableSuggestions: false,
          smartDashesType: SmartDashesType.disabled,
          smartQuotesType: SmartQuotesType.disabled,
          autofillHints: const <String>[AutofillHints.oneTimeCode],
          keyboardAppearance: theme.brightness,
          rendererIgnoresPointer: true,
          selectionControls: HeroTextSelectionControls.adaptive(),
          contextMenuBuilder: HeroTextSelectionToolbar.contextMenuBuilder,
          inputFormatters: <TextInputFormatter>[
            _HeroOTPFormatter(
              maxLength: widget.maxLength,
              pattern: _pattern,
              pasteTransformer: widget.pasteTransformer,
            ),
          ],
          onChanged: _handleChanged,
          onSubmitted: _handleSubmitted,
        ),
      ),
    );

    final Widget slots = ExcludeSemantics(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double slotWidth = _slotWidth(
            theme,
            children,
            gap,
            constraints.maxWidth,
          );
          return _HeroInputOTPScope(
            text: value.text,
            selection: focused ? value.selection : null,
            variant: widget.variant,
            isDisabled: _disabled,
            isInvalid: invalid,
            placeholder: widget.placeholder,
            slotWidth: slotWidth,
            spacing: gap,
            child: Row(
              mainAxisSize: constraints.hasBoundedWidth
                  ? MainAxisSize.max
                  : MainAxisSize.min,
              spacing: gap,
              children: children,
            ),
          );
        },
      ),
    );

    return HeroFieldScope(
      variant: widget.variant,
      isDisabled: _disabled,
      isInvalid: invalid,
      validationErrors: errors,
      focusNode: _focusNode,
      child: Semantics(
        container: true,
        label: widget.semanticLabel,
        enabled: !_disabled,
        maxValueLength: widget.maxLength,
        currentValueLength: value.text.length,
        validationResult: invalid
            ? SemanticsValidationResult.invalid
            : SemanticsValidationResult.none,
        child: MouseRegion(
          cursor: _disabled ? MouseCursor.defer : SystemMouseCursors.text,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            child: TextFieldTapRegion(
              child: Stack(children: <Widget>[hidden, slots]),
            ),
          ),
        ),
      ),
    );
  }

  /// The width of each slot: 38 (`w-9.5`), or less when the slots, gaps
  /// and separators do not fit (they shrink like `flex-1 min-w-0`).
  double _slotWidth(
    HeroThemeData theme,
    List<Widget> children,
    double gap,
    double maxWidth,
  ) {
    final double base = theme.spacing(9.5);
    if (!maxWidth.isFinite) return base;
    int slots = 0;
    double fixed = children.length > 1 ? (children.length - 1) * gap : 0;
    for (final Widget child in children) {
      if (child is HeroInputOTPSlot) {
        slots++;
      } else if (child is HeroInputOTPSeparator) {
        fixed += child.width ?? theme.spacing(1.5);
      } else if (child is HeroInputOTPGroup) {
        final int count = child.children.whereType<HeroInputOTPSlot>().length;
        slots += count;
        final double groupGap = child.spacing ?? gap;
        if (child.children.length > 1) {
          fixed += (child.children.length - 1) * groupGap;
        }
      }
    }
    if (slots == 0) return base;
    final double available = (maxWidth - fixed) / slots;
    return math.max(0, math.min(base, available));
  }
}

/// The `FormField<String>` a [HeroInputOTP] registers with the nearest
/// `Form`.
class _HeroOTPFormField extends FormField<String> {
  const _HeroOTPFormField({
    super.key,
    required super.builder,
    super.initialValue,
    super.validator,
    super.onSaved,
    super.onReset,
    super.autovalidateMode,
    super.enabled,
  });

  @override
  FormFieldState<String> createState() => _HeroOTPFormFieldState();
}

class _HeroOTPFormFieldState extends FormFieldState<String> {
  /// Updates the value without notifying the form.
  void syncValue(String value) => setValue(value);
}

/// Filters edits of a [HeroInputOTP]: pasted text passes through the
/// paste transformer and is inserted at the selection, the code is capped
/// at the maximum length and must match the pattern.
class _HeroOTPFormatter extends TextInputFormatter {
  _HeroOTPFormatter({
    required this.maxLength,
    required this.pattern,
    required this.pasteTransformer,
  });

  final int maxLength;
  final RegExp? pattern;
  final HeroInputOTPPasteTransformer? pasteTransformer;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == newValue.text) return newValue;
    String text = newValue.text;
    int caret = newValue.selection.isValid
        ? newValue.selection.extentOffset
        : text.length;

    // The inserted text: what replaced the old selection.
    final TextSelection old = oldValue.selection.isValid
        ? oldValue.selection
        : TextSelection.collapsed(offset: oldValue.text.length);
    final String before = oldValue.text.substring(0, old.start);
    final String after = oldValue.text.substring(old.end);
    final bool replacesSelection =
        text.startsWith(before) &&
        text.endsWith(after) &&
        text.length >= before.length + after.length;
    if (replacesSelection) {
      String inserted = text.substring(
        before.length,
        text.length - after.length,
      );
      // Several characters at once: a paste or an autofilled code.
      final HeroInputOTPPasteTransformer? transform = pasteTransformer;
      if (inserted.length > 1 && transform != null) {
        inserted = transform(inserted);
      }
      text = '$before$inserted$after';
      caret = before.length + inserted.length;
    }
    if (text.length > maxLength) {
      // A single typed character past the end is rejected, like the
      // native `maxLength`; longer insertions are cut.
      if (text.length - oldValue.text.length == 1 &&
          oldValue.text.length >= maxLength) {
        return oldValue;
      }
      text = text.substring(0, maxLength);
    }
    final RegExp? pattern = this.pattern;
    if (text.isNotEmpty && pattern != null && !pattern.hasMatch(text)) {
      return oldValue;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: math.min(caret, text.length)),
    );
  }
}

/// Shares the state of a [HeroInputOTP] with its slots.
class _HeroInputOTPScope extends InheritedWidget {
  const _HeroInputOTPScope({
    required this.text,
    required this.selection,
    required this.variant,
    required this.isDisabled,
    required this.isInvalid,
    required this.placeholder,
    required this.slotWidth,
    required this.spacing,
    required super.child,
  });

  final String text;

  /// The selection while focused, else null.
  final TextSelection? selection;
  final HeroFieldVariant variant;
  final bool isDisabled;
  final bool isInvalid;
  final String? placeholder;
  final double slotWidth;
  final double spacing;

  static _HeroInputOTPScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroInputOTPScope>();

  /// Whether the slot at [index] is active (holds the caret or the
  /// selected character).
  bool isActive(int index) {
    final TextSelection? selection = this.selection;
    if (selection == null || !selection.isValid) return false;
    if (selection.isCollapsed) return index == selection.baseOffset;
    return index >= selection.start && index < selection.end;
  }

  @override
  bool updateShouldNotify(_HeroInputOTPScope oldWidget) =>
      text != oldWidget.text ||
      selection != oldWidget.selection ||
      variant != oldWidget.variant ||
      isDisabled != oldWidget.isDisabled ||
      isInvalid != oldWidget.isInvalid ||
      placeholder != oldWidget.placeholder ||
      slotWidth != oldWidget.slotWidth ||
      spacing != oldWidget.spacing;
}

/// A group of slots of a [HeroInputOTP] (HeroUI `InputOTP.Group`): a row
/// with 8 px between the slots.
class HeroInputOTPGroup extends StatelessWidget {
  /// Groups [children], usually [HeroInputOTPSlot]s.
  const HeroInputOTPGroup({super.key, required this.children, this.spacing});

  /// The slots.
  final List<Widget> children;

  /// Gap between the slots; defaults to the input's spacing (8).
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final _HeroInputOTPScope? scope = _HeroInputOTPScope.maybeOf(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: spacing ?? scope?.spacing ?? HeroTheme.of(context).spacing(2),
      children: children,
    );
  }
}

/// One character of a [HeroInputOTP] (HeroUI `InputOTP.Slot`): a 38 × 40
/// field box (`rounded-field`, `--field-background`, field shadow) showing
/// the character at [index] in `text-lg` semibold.
///
/// The active slot shows the 2 px focus ring and, while empty, a blinking
/// 2 × 16 caret; a filled slot uses `--field-focus`; an invalid input
/// outlines every slot in `--danger`; a disabled one fades them. A new
/// character rises 8 px and scales from 0.8 over 250 ms.
class HeroInputOTPSlot extends StatelessWidget {
  /// Creates the slot of the character at [index].
  const HeroInputOTPSlot({super.key, required this.index, this.style});

  /// The zero-based position of the character.
  final int index;

  /// Visual overrides (the counterpart of `className`):
  /// [HeroFieldStyle.focusBackgroundColor] is the active background.
  final HeroFieldStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final _HeroInputOTPScope? scope = _HeroInputOTPScope.maybeOf(context);
    final String text = scope?.text ?? '';
    final String? char = index < text.length ? text[index] : null;
    final bool active = scope?.isActive(index) ?? false;
    final bool secondary = scope?.variant == HeroFieldVariant.secondary;
    final String? placeholder = scope?.placeholder;
    final String? placeholderChar =
        text.isEmpty && placeholder != null && index < placeholder.length
        ? placeholder[index]
        : null;

    // `[data-filled]` uses the focus background, also while hovered.
    final Color filledBackground = secondary
        ? colors.defaultColor
        : colors.fieldFocus;
    final HeroFieldStyle? slotStyle = char != null
        ? HeroFieldStyle(
            backgroundColor: filledBackground,
            hoverBackgroundColor: filledBackground,
          ).merge(style)
        : style;

    final TextStyle valueStyle = theme.typography
        .style(
          HeroFontSize.lg,
          weight: HeroTypography.semibold,
          lineHeight: theme.spacing(6),
        )
        .copyWith(color: colors.fieldForeground, letterSpacing: -0.27)
        .merge(style?.textStyle);
    final double height = math.max(
      theme.spacing(10),
      MediaQuery.textScalerOf(context).scale(theme.spacing(6)) +
          theme.spacing(4),
    );

    Widget? content;
    if (char != null) {
      content = _HeroOTPSlotValue(
        key: ValueKey<int>(index),
        char: char,
        style: valueStyle,
      );
    } else if (active) {
      content = const _HeroOTPCaret();
    } else if (placeholderChar != null) {
      content = Text(
        placeholderChar,
        style: valueStyle.copyWith(color: colors.fieldPlaceholder),
      );
    }

    return SizedBox(
      width: scope?.slotWidth ?? theme.spacing(9.5),
      height: height,
      child: HeroFieldBox(
        variant: scope?.variant ?? HeroFieldVariant.primary,
        isFocused: active,
        isInvalid: scope?.isInvalid ?? false,
        isDisabled: scope?.isDisabled ?? false,
        style: slotStyle,
        mouseCursor: (scope?.isDisabled ?? false)
            ? SystemMouseCursors.basic
            : SystemMouseCursors.text,
        child: SizedBox.expand(
          child: Center(child: content ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// The character of a slot, animated in when it appears
/// (`slot-value-in`: 250 ms ease, opacity 0 → 1, 8 px rise, scale
/// 0.8 → 1 from the bottom centre).
class _HeroOTPSlotValue extends StatefulWidget {
  const _HeroOTPSlotValue({super.key, required this.char, required this.style});

  final String char;
  final TextStyle style;

  @override
  State<_HeroOTPSlotValue> createState() => _HeroOTPSlotValueState();
}

class _HeroOTPSlotValueState extends State<_HeroOTPSlotValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: HeroMotion.slow,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final Duration duration = HeroTheme.of(
      context,
    ).motion.resolve(context, HeroMotion.slow);
    if (duration == Duration.zero) {
      _controller.value = 1;
    } else {
      _controller
        ..duration = duration
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double rise = HeroTheme.of(context).spacing(2);
    final Widget text = Text(widget.char, style: widget.style);
    return AnimatedBuilder(
      animation: _controller,
      child: text,
      builder: (BuildContext context, Widget? child) {
        final double t = HeroMotion.smooth.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, rise * (1 - t)),
            child: Transform.scale(
              scale: 0.8 + 0.2 * t,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// The fake caret of the active empty slot: 2 × 16, `--field-placeholder`,
/// blinking every 1.2 s (`caret-blink`: visible at 0%, 70% and 100%,
/// hidden from 20% to 50%, `ease-out`). It stays visible under reduced
/// motion.
class _HeroOTPCaret extends StatefulWidget {
  const _HeroOTPCaret();

  @override
  State<_HeroOTPCaret> createState() => _HeroOTPCaretState();
}

class _HeroOTPCaretState extends State<_HeroOTPCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  static final Animatable<double> _blink =
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 1,
            end: 0,
          ).chain(CurveTween(curve: HeroMotion.easeOut)),
          weight: 20,
        ),
        TweenSequenceItem<double>(tween: ConstantTween<double>(0), weight: 30),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: 0,
            end: 1,
          ).chain(CurveTween(curve: HeroMotion.easeOut)),
          weight: 20,
        ),
        TweenSequenceItem<double>(tween: ConstantTween<double>(1), weight: 30),
      ]);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool animate =
        HeroTheme.of(context).motion.resolve(context, HeroMotion.normal) !=
        Duration.zero;
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return FadeTransition(
      opacity: _controller.drive(_blink),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: theme.colors.fieldPlaceholder,
          shape: theme.shapeAll(theme.radii.sm),
        ),
        child: SizedBox(width: theme.spacing(0.5), height: theme.spacing(4)),
      ),
    );
  }
}

/// The separator between the groups of a [HeroInputOTP] (HeroUI
/// `InputOTP.Separator`): a 6 × 2 bar in `--separator` with rounded ends.
class HeroInputOTPSeparator extends StatelessWidget {
  /// Creates a separator.
  const HeroInputOTPSeparator({super.key, this.color, this.width});

  /// Bar color; defaults to `--separator`.
  final Color? color;

  /// Bar width; defaults to 6.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color ?? theme.colors.separator,
        shape: theme.shapeAll(theme.radii.sm),
      ),
      child: SizedBox(
        width: width ?? theme.spacing(1.5),
        height: theme.spacing(0.5),
      ),
    );
  }
}
