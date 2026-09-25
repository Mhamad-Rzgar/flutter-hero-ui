/// HeroUI's `SearchField`: a search input with a search icon, a clear
/// button, a label, a description and an error message.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../button/button.dart';
import '../close_button/close_button.dart';
import '../description/description.dart';
import '../field_error/field_error.dart';
import '../form/form.dart';
import '../input/input.dart';
import '../label/label.dart';
import '../text_field/text_field.dart';

/// The render props of a [HeroSearchField], passed to its
/// [HeroSearchField.builder].
@immutable
class HeroSearchFieldState {
  /// Creates search field render props.
  const HeroSearchFieldState({
    this.isDisabled = false,
    this.isInvalid = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isFocusWithin = false,
    this.isFocusVisible = false,
    this.validation = HeroValidationResult.valid,
    this.value = '',
  });

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

  /// The current search text.
  final String value;

  /// Whether the search text is empty (the clear button is hidden).
  bool get isEmpty => value.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is HeroSearchFieldState &&
      other.isDisabled == isDisabled &&
      other.isInvalid == isInvalid &&
      other.isReadOnly == isReadOnly &&
      other.isRequired == isRequired &&
      other.isFocusWithin == isFocusWithin &&
      other.isFocusVisible == isFocusVisible &&
      other.validation == validation &&
      other.value == value;

  @override
  int get hashCode => Object.hash(
    isDisabled,
    isInvalid,
    isReadOnly,
    isRequired,
    isFocusWithin,
    isFocusVisible,
    validation,
    value,
  );
}

/// Builds the parts of a [HeroSearchField] from its state (HeroUI's
/// render-function children).
typedef HeroSearchFieldBuilder =
    List<Widget> Function(BuildContext context, HeroSearchFieldState state);

/// A search field (HeroUI `SearchField`): a [HeroLabel], a
/// [HeroSearchFieldGroup] with a [HeroSearchFieldSearchIcon], a
/// [HeroSearchFieldInput] and a [HeroSearchFieldClearButton], a
/// [HeroDescription] and a [HeroFieldError], in a column with a 4 px gap.
///
/// ```dart
/// HeroSearchField(
///   name: 'search',
///   children: const <Widget>[
///     HeroLabel.text('Search'),
///     HeroSearchFieldGroup(
///       children: <Widget>[
///         HeroSearchFieldSearchIcon(),
///         HeroSearchFieldInput(placeholder: 'Search...', width: 280),
///         HeroSearchFieldClearButton(),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// Without [children] (or [builder]) the field builds this layout from
/// [label], [placeholder], [description], [errorMessage], [searchIcon],
/// [clearIcon] and [showClearButton].
///
/// * Enter (or the keyboard's search action) calls [onSubmitted] and
///   submits the enclosing `HeroForm`.
/// * Escape clears a non-empty value, calling [onChanged] with `''` and
///   [onClear]; with an empty value it is left to the ancestors.
/// * The clear button does the same and keeps the focus in the input. It
///   is hidden while the value is empty, is not in the focus order and is
///   disabled when the field is disabled or read-only.
///
/// Value, validation and form behaviour are those of `HeroTextField`: the
/// field is controlled with [value] + [onChanged], uncontrolled with
/// [defaultValue] or driven by a [controller], and registers a
/// `FormField<String>` with [validator], [isRequired], [validationBehavior],
/// [validationErrors] and [isInvalid]. While invalid the description is
/// hidden and the error shows.
class HeroSearchField extends StatefulWidget {
  /// Creates a search field.
  const HeroSearchField({
    super.key,
    this.children,
    this.builder,
    this.label,
    this.placeholder,
    this.description,
    this.errorMessage,
    this.searchIcon,
    this.clearIcon,
    this.showSearchIcon = true,
    this.showClearButton = true,
    this.inputWidth,
    this.controller,
    this.focusNode,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.variant = HeroFieldVariant.primary,
    this.fullWidth = false,
    this.spacing,
    this.isDisabled = false,
    this.isReadOnly = false,
    this.isRequired = false,
    this.isInvalid,
    this.name,
    this.validator,
    this.validationBehavior,
    this.validationErrors,
    this.onSaved,
    this.autovalidateMode,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.validationMessages = const HeroValidationMessages(),
    this.autofocus = false,
    this.semanticLabel,
  });

  /// The parts of the field. When null (and [builder] is null) the field
  /// builds them from the convenience parameters.
  final List<Widget>? children;

  /// Builds the parts from the field state; takes precedence over
  /// [children].
  final HeroSearchFieldBuilder? builder;

  /// Label text of the built field.
  final String? label;

  /// Placeholder of the built input.
  final String? placeholder;

  /// Description text of the built field, hidden while invalid.
  final String? description;

  /// Error text of the built field, shown while invalid; defaults to the
  /// validation messages.
  final String? errorMessage;

  /// Icon of the built search icon; defaults to HeroUI's magnifier.
  final Widget? searchIcon;

  /// Icon of the built clear button; defaults to HeroUI's close icon.
  final Widget? clearIcon;

  /// Whether the built group shows the search icon.
  final bool showSearchIcon;

  /// Whether the built group shows the clear button.
  final bool showClearButton;

  /// Width of the built input (the group adds its icon and button).
  final double? inputWidth;

  /// Controls the text; when null the field owns a controller.
  final TextEditingController? controller;

  /// Focus node of the input; when null the field owns one.
  final FocusNode? focusNode;

  /// The current value (controlled).
  final String? value;

  /// The initial value (uncontrolled).
  final String? defaultValue;

  /// Called when the user edits or clears the value (`onChange`).
  final ValueChanged<String>? onChanged;

  /// Called with the value when the user presses Enter (`onSubmit`).
  final ValueChanged<String>? onSubmitted;

  /// Called when the value is cleared with Escape or the clear button.
  final VoidCallback? onClear;

  /// Visual variant.
  final HeroFieldVariant variant;

  /// Whether the field and its group take the full available width.
  final bool fullWidth;

  /// Gap between the parts; defaults to 4 (`gap-1`).
  final double? spacing;

  /// Whether the field is disabled.
  final bool isDisabled;

  /// Whether the text can be selected but not edited or cleared.
  final bool isReadOnly;

  /// Whether a value is required.
  final bool isRequired;

  /// Overrides the displayed validation: true invalid, false valid, null
  /// lets the validation decide.
  final bool? isInvalid;

  /// The name of the value in the data a [HeroForm] submits.
  final String? name;

  /// Custom validation (`validate`).
  final FormFieldValidator<String>? validator;

  /// When errors show and whether they block submission; null inherits the
  /// [HeroForm]'s, then native.
  final HeroValidationBehavior? validationBehavior;

  /// Server-side errors, shown until the user edits the field.
  final List<String>? validationErrors;

  /// Called with the value when the enclosing form is saved.
  final FormFieldSetter<String>? onSaved;

  /// When the native behaviour shows errors without a commit.
  final AutovalidateMode? autovalidateMode;

  /// Minimum number of characters (validation).
  final int? minLength;

  /// Maximum number of characters (truncates input).
  final int? maxLength;

  /// Pattern the whole value must match (validation).
  final RegExp? pattern;

  /// Messages of the built-in validation.
  final HeroValidationMessages validationMessages;

  /// Whether to focus the input when first built.
  final bool autofocus;

  /// Accessibility label of the input; defaults to the label text.
  final String? semanticLabel;

  @override
  State<HeroSearchField> createState() => _HeroSearchFieldState();

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
      ..add(FlagProperty('fullWidth', value: fullWidth, ifTrue: 'full width'))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isReadOnly', value: isReadOnly, ifTrue: 'read-only'))
      ..add(FlagProperty('isRequired', value: isRequired, ifTrue: 'required'))
      ..add(
        DiagnosticsProperty<bool>('isInvalid', isInvalid, defaultValue: null),
      );
  }
}

class _HeroSearchFieldState extends State<HeroSearchField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(
        text: widget.value ?? widget.defaultValue ?? '',
      ));

  FocusNode get _focusNode =>
      widget.focusNode ??
      (_ownFocusNode ??= FocusNode(debugLabel: 'HeroSearchField'));

  @override
  void dispose() {
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  /// Clears a non-empty value (Escape, clear button); returns whether the
  /// value was cleared.
  bool _clear() {
    final bool disabled = widget.isDisabled || HeroDisabledScope.of(context);
    if (_controller.text.isEmpty || disabled || widget.isReadOnly) {
      return false;
    }
    _controller.clear();
    widget.onClear?.call();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final HeroSearchFieldBuilder? builder = widget.builder;
    return _HeroSearchFieldScope(
      clear: _clear,
      onSubmitted: widget.onSubmitted,
      child: HeroTextField(
        controller: _controller,
        focusNode: _focusNode,
        value: widget.value,
        defaultValue: widget.defaultValue,
        onChanged: widget.onChanged,
        type: HeroInputType.search,
        variant: widget.variant,
        fullWidth: widget.fullWidth,
        spacing: widget.spacing,
        isDisabled: widget.isDisabled,
        isReadOnly: widget.isReadOnly,
        isRequired: widget.isRequired,
        isInvalid: widget.isInvalid,
        name: widget.name,
        validator: widget.validator,
        validationBehavior: widget.validationBehavior,
        validationErrors: widget.validationErrors,
        onSaved: widget.onSaved,
        autovalidateMode: widget.autovalidateMode,
        minLength: widget.minLength,
        pattern: widget.pattern,
        validationMessages: widget.validationMessages,
        autofocus: widget.autofocus,
        errorMessage: widget.errorMessage,
        description: widget.description,
        label: widget.label,
        semanticLabel: widget.semanticLabel,
        builder: builder == null
            ? null
            : (BuildContext context, HeroTextFieldState state) => builder(
                context,
                HeroSearchFieldState(
                  isDisabled: state.isDisabled,
                  isInvalid: state.isInvalid,
                  isReadOnly: state.isReadOnly,
                  isRequired: state.isRequired,
                  isFocusWithin: state.isFocusWithin,
                  isFocusVisible: state.isFocusVisible,
                  validation: state.validation,
                  value: _controller.text,
                ),
              ),
        children: builder == null
            ? (widget.children ?? _defaultChildren())
            : null,
      ),
    );
  }

  List<Widget> _defaultChildren() {
    final String? label = widget.label;
    final String? description = widget.description;
    final String? errorMessage = widget.errorMessage;
    return <Widget>[
      if (label != null) HeroLabel.text(label),
      HeroSearchFieldGroup(
        children: <Widget>[
          if (widget.showSearchIcon)
            HeroSearchFieldSearchIcon(child: widget.searchIcon),
          HeroSearchFieldInput(
            placeholder: widget.placeholder,
            width: widget.inputWidth,
            maxLength: widget.maxLength,
          ),
          if (widget.showClearButton)
            HeroSearchFieldClearButton(child: widget.clearIcon),
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

/// Shares the search behaviour of a [HeroSearchField] with its parts.
class _HeroSearchFieldScope extends InheritedWidget {
  const _HeroSearchFieldScope({
    required this.clear,
    required this.onSubmitted,
    required super.child,
  });

  /// Clears a non-empty value; returns whether it did.
  final bool Function() clear;

  final ValueChanged<String>? onSubmitted;

  static _HeroSearchFieldScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroSearchFieldScope>();

  @override
  bool updateShouldNotify(_HeroSearchFieldScope oldWidget) =>
      clear != oldWidget.clear || onSubmitted != oldWidget.onSubmitted;
}

/// Shares the layout of a [HeroSearchFieldGroup] with its parts.
class _HeroSearchFieldGroupScope extends InheritedWidget {
  const _HeroSearchFieldGroupScope({
    required this.hasSearchIcon,
    required this.hasClearButton,
    required super.child,
  });

  final bool hasSearchIcon;
  final bool hasClearButton;

  static _HeroSearchFieldGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroSearchFieldGroupScope>();

  @override
  bool updateShouldNotify(_HeroSearchFieldGroupScope oldWidget) =>
      hasSearchIcon != oldWidget.hasSearchIcon ||
      hasClearButton != oldWidget.hasClearButton;
}

/// The box of a [HeroSearchField] (HeroUI `SearchField.Group`): the search
/// icon, the input and the clear button in a 36 px field box
/// (`rounded-field`, `--field-background`, field shadow).
///
/// It shows the hover background (mouse, while not focused), the focus
/// ring while the input has focus, the invalid outline and the disabled
/// opacity, and takes the field's variant ([HeroFieldVariant.secondary]:
/// `--default`, no shadow). Pressing it outside the input focuses the
/// input. It grows with the text only when the text scale needs more than
/// 36 px.
class HeroSearchFieldGroup extends StatefulWidget {
  /// Creates the group of a search field.
  const HeroSearchFieldGroup({super.key, required this.children, this.style});

  /// The parts: [HeroSearchFieldSearchIcon], [HeroSearchFieldInput],
  /// [HeroSearchFieldClearButton].
  final List<Widget> children;

  /// Visual overrides of the box (the counterpart of `className`).
  final HeroFieldStyle? style;

  @override
  State<HeroSearchFieldGroup> createState() => _HeroSearchFieldGroupState();
}

class _HeroSearchFieldGroupState extends State<HeroSearchFieldGroup> {
  bool _focusWithin = false;

  void _handleFocusWithin(bool value) {
    if (_focusWithin == value) return;
    setState(() => _focusWithin = value);
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldScope? field = HeroFieldScope.maybeOf(context);
    final bool disabled =
        (field?.isDisabled ?? false) || HeroDisabledScope.of(context);
    final bool invalid = field?.isInvalid ?? false;
    final FocusNode? input = field?.focusNode;
    final List<Widget> children = widget.children;

    final Widget row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: theme.spacing(9)),
      child: Row(
        children: <Widget>[
          for (final Widget child in children)
            if (child is HeroSearchFieldInput)
              Expanded(child: child)
            else
              child,
        ],
      ),
    );

    Widget result = HeroFieldBox(
      variant: field?.variant ?? HeroFieldVariant.primary,
      isFocused: _focusWithin && !disabled,
      isInvalid: invalid,
      isDisabled: disabled,
      style: widget.style,
      child: _HeroSearchFieldGroupScope(
        hasSearchIcon: children.any(
          (Widget child) => child is HeroSearchFieldSearchIcon,
        ),
        hasClearButton: children.any(
          (Widget child) => child is HeroSearchFieldClearButton,
        ),
        child: row,
      ),
    );
    result = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: disabled || input == null ? null : input.requestFocus,
      child: result,
    );
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: _handleFocusWithin,
      child: IgnorePointer(ignoring: disabled, child: result),
    );
  }
}

/// The search icon of a [HeroSearchField] (HeroUI
/// `SearchField.SearchIcon`): 16 px, `--field-placeholder`, 12 px from the
/// start (`ms-3`). Pressing it focuses the input.
class HeroSearchFieldSearchIcon extends StatelessWidget {
  /// Creates the search icon; [child] replaces HeroUI's magnifier.
  const HeroSearchFieldSearchIcon({super.key, this.child, this.color});

  /// A custom icon; defaults to [HeroIcons.search].
  final Widget? child;

  /// Icon color; defaults to `--field-placeholder`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(start: theme.spacing(3)),
      child: ExcludeSemantics(
        child: IconTheme.merge(
          data: IconThemeData(
            size: theme.spacing(4),
            color: color ?? theme.colors.fieldPlaceholder,
          ),
          child: SizedBox.square(
            dimension: theme.spacing(4),
            child: child ?? const HeroIcon(HeroIcons.search),
          ),
        ),
      ),
    );
  }
}

/// The input of a [HeroSearchField] (HeroUI `SearchField.Input`): the
/// field's text in `text-base` (`text-sm` from the `sm` breakpoint), `px-3`,
/// `ps-2` after the search icon and `pe-2` before the clear button, with the
/// search keyboard.
///
/// Escape clears a non-empty value; Enter calls the field's `onSubmitted`.
class HeroSearchFieldInput extends StatefulWidget {
  /// Creates the input of a search field.
  const HeroSearchFieldInput({
    super.key,
    this.placeholder,
    this.width,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.style,
  });

  /// Text shown while the input is empty.
  final String? placeholder;

  /// Width of the input when the field shrink-wraps; defaults to the
  /// browser's default input width (192).
  final double? width;

  /// Maximum number of characters.
  final int? maxLength;

  /// Horizontal text alignment.
  final TextAlign textAlign;

  /// Text, placeholder, caret and padding overrides.
  final HeroFieldStyle? style;

  @override
  State<HeroSearchFieldInput> createState() => _HeroSearchFieldInputState();
}

class _HeroSearchFieldInputState extends State<HeroSearchFieldInput> {
  /// Whether the last Escape key-down cleared the value, so its key-up is
  /// consumed as well.
  bool _escapeHandled = false;

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      _escapeHandled = _HeroSearchFieldScope.maybeOf(context)?.clear() ?? false;
      return _escapeHandled ? KeyEventResult.handled : KeyEventResult.ignored;
    }
    if (_escapeHandled) {
      if (event is KeyUpEvent) _escapeHandled = false;
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroSearchFieldGroupScope? group =
        _HeroSearchFieldGroupScope.maybeOf(context);
    final double side = theme.spacing(3);
    final double inner = theme.spacing(2);
    final HeroFieldStyle style = HeroFieldStyle(
      // The group is 36 px tall and centres the text (the input's py-2 box
      // is taller than the group at `text-base` and is clipped by it).
      padding: EdgeInsetsDirectional.only(
        start: (group?.hasSearchIcon ?? false) ? inner : side,
        end: (group?.hasClearButton ?? false) ? inner : side,
      ),
    ).merge(widget.style);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: _handleKey,
      child: HeroTextInputCore(
        placeholder: widget.placeholder,
        type: HeroInputType.search,
        width: widget.width ?? HeroFieldMetrics.defaultWidth(theme),
        decorated: false,
        maxLength: widget.maxLength,
        textAlign: widget.textAlign,
        onSubmitted: _HeroSearchFieldScope.maybeOf(context)?.onSubmitted,
        style: style,
        debugLabel: 'HeroSearchFieldInput',
      ),
    );
  }
}

/// The clear button of a [HeroSearchField] (HeroUI
/// `SearchField.ClearButton`): a 20 px `HeroCloseButton` with a 12 px icon,
/// 8 px from the end (`me-2`).
///
/// It clears the value and keeps the focus in the input. It is invisible
/// and inert while the value is empty (it keeps its space), is not in the
/// focus order, and is disabled while the field is disabled or read-only.
/// It is announced as "Clear search".
class HeroSearchFieldClearButton extends StatelessWidget {
  /// Creates the clear button; [child] replaces the close icon.
  const HeroSearchFieldClearButton({
    super.key,
    this.child,
    this.style,
    this.semanticLabel = 'Clear search',
  });

  /// A custom icon; defaults to HeroUI's close icon.
  final Widget? child;

  /// Overrides of the close button (colors, size, icon size).
  final HeroButtonStyle? style;

  /// Accessibility label (`aria-label`).
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldScope? field = HeroFieldScope.maybeOf(context);
    final _HeroSearchFieldScope? search = _HeroSearchFieldScope.maybeOf(
      context,
    );
    final TextEditingController? controller = field?.controller;
    final bool disabled =
        (field?.isDisabled ?? false) ||
        (field?.isReadOnly ?? false) ||
        HeroDisabledScope.of(context);
    final HeroButtonStyle buttonStyle = HeroButtonStyle(
      height: theme.spacing(5),
      iconSize: theme.spacing(3),
    ).merge(style);

    Widget button(bool empty) {
      final Widget closeButton = ExcludeFocus(
        child: HeroCloseButton(
          isDisabled: disabled,
          semanticLabel: semanticLabel,
          style: buttonStyle,
          onPressed: () {
            search?.clear();
            field?.focusNode?.requestFocus();
          },
          child: child,
        ),
      );
      return Padding(
        padding: EdgeInsetsDirectional.only(end: theme.spacing(2)),
        // `[data-empty] .clear-button { opacity-0 pointer-events-none }`:
        // hidden but still taking its space.
        child: Opacity(
          opacity: empty ? 0 : 1,
          child: IgnorePointer(
            ignoring: empty,
            child: ExcludeSemantics(excluding: empty, child: closeButton),
          ),
        ),
      );
    }

    if (controller == null) return button(false);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) =>
          button(value.text.isEmpty),
    );
  }
}
