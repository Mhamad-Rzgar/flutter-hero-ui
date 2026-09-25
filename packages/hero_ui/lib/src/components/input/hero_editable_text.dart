import 'dart:ui' show SemanticsInputType, SemanticsValidationResult;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import 'hero_field.dart';
import 'hero_text_selection.dart';

/// The editable-text core of every hero_ui text input: an [EditableText]
/// with HeroUI's text tokens, a placeholder, iOS-style selection controls,
/// a token-styled context menu, pointer gestures and text-field semantics.
///
/// It paints no background: combine it with [HeroFieldBox] (as `HeroInput`
/// and `HeroTextArea` do) or place it inside a composite field such as an
/// input group. The [controller] and [focusNode] are owned by the caller.
class HeroEditableText extends StatefulWidget {
  /// Creates the editable text core.
  const HeroEditableText({
    super.key,
    required this.controller,
    required this.focusNode,
    this.placeholder,
    this.style,
    this.placeholderStyle,
    this.cursorColor,
    this.selectionColor,
    this.padding = EdgeInsets.zero,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.isReadOnly = false,
    this.isDisabled = false,
    this.isInvalid = false,
    this.isRequired = false,
    this.autofocus = false,
    this.inputFormatters,
    this.autofillHints,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.onTapOutside,
    this.scrollController,
    this.scrollPhysics,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.contextMenuBuilder = HeroTextSelectionToolbar.contextMenuBuilder,
    this.semanticLabel,
    this.semanticHint,
    this.semanticsInputType = SemanticsInputType.text,
  });

  /// The edited text.
  final TextEditingController controller;

  /// Focus of the text.
  final FocusNode focusNode;

  /// Text shown while [controller] is empty.
  final String? placeholder;

  /// Text style; defaults to [HeroFieldMetrics.textStyle].
  final TextStyle? style;

  /// Placeholder style; defaults to [style] in `--field-placeholder`.
  final TextStyle? placeholderStyle;

  /// Caret color; defaults to the text color (CSS `caret-color: auto`).
  final Color? cursorColor;

  /// Selection highlight; defaults to [HeroFieldMetrics.selectionColor].
  final Color? selectionColor;

  /// Padding around the text. Taps in the padding still place the caret.
  final EdgeInsetsGeometry padding;

  /// Horizontal text alignment.
  final TextAlign textAlign;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Automatic capitalization.
  final TextCapitalization textCapitalization;

  /// Whether the text is obscured (passwords).
  final bool obscureText;

  /// Character used to obscure the text.
  final String obscuringCharacter;

  /// Whether autocorrect is enabled.
  final bool autocorrect;

  /// Whether keyboard suggestions are enabled.
  final bool enableSuggestions;

  /// Maximum number of visible lines (null for unlimited).
  final int? maxLines;

  /// Minimum number of visible lines.
  final int? minLines;

  /// Whether the text fills the parent's height.
  final bool expands;

  /// Whether the text can be selected but not changed.
  final bool isReadOnly;

  /// Whether the text ignores input and cannot be focused.
  final bool isDisabled;

  /// Reports an invalid value to assistive technologies.
  final bool isInvalid;

  /// Reports a required value to assistive technologies.
  final bool isRequired;

  /// Whether to focus when first built.
  final bool autofocus;

  /// Formatters applied to user input.
  final List<TextInputFormatter>? inputFormatters;

  /// Autofill hints (`autoComplete`).
  final Iterable<String>? autofillHints;

  /// Called on every user edit.
  final ValueChanged<String>? onChanged;

  /// Called when the user completes editing.
  final VoidCallback? onEditingComplete;

  /// Called when the user submits (keyboard action button or Enter).
  final ValueChanged<String>? onSubmitted;

  /// Called on each tap that places the caret.
  final VoidCallback? onTap;

  /// Called on a tap outside the text while focused.
  final TapRegionCallback? onTapOutside;

  /// Scroll controller of multi-line text.
  final ScrollController? scrollController;

  /// Scroll physics of multi-line text.
  final ScrollPhysics? scrollPhysics;

  /// Whether the user can select text.
  final bool enableInteractiveSelection;

  /// Selection handles; defaults to [HeroTextSelectionControls.adaptive].
  final TextSelectionControls? selectionControls;

  /// Builds the context menu; defaults to [HeroTextSelectionToolbar].
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Accessibility label of the text field.
  final String? semanticLabel;

  /// Extra accessibility hint (for example a field description). The
  /// placeholder is always part of the hint.
  final String? semanticHint;

  /// Input type reported to assistive technologies.
  final SemanticsInputType semanticsInputType;

  @override
  State<HeroEditableText> createState() => HeroEditableTextState();
}

/// State of a [HeroEditableText]; exposes the underlying [EditableText].
class HeroEditableTextState extends State<HeroEditableText>
    implements TextSelectionGestureDetectorBuilderDelegate {
  late final _HeroSelectionGestureBuilder _gestureBuilder =
      _HeroSelectionGestureBuilder(state: this);

  bool _showSelectionHandles = false;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => true;

  @override
  bool get selectionEnabled =>
      widget.enableInteractiveSelection && !widget.isDisabled;

  /// The state of the wrapped [EditableText], once built.
  EditableTextState? get editableText => editableTextKey.currentState;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(HeroEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleFocusChanged() {
    // The selection highlight is only shown while focused.
    setState(() {});
  }

  void _requestKeyboard() => editableText?.requestKeyboard();

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    if (!_gestureBuilder.shouldShowSelectionToolbar ||
        !_gestureBuilder.shouldShowSelectionHandles) {
      return false;
    }
    if (cause == SelectionChangedCause.keyboard) return false;
    if (widget.isDisabled) return false;
    // Like iOS, no handles for a collapsed selection.
    if (widget.controller.selection.isCollapsed) return false;
    if (cause == SelectionChangedCause.longPress ||
        cause == SelectionChangedCause.stylusHandwriting) {
      return true;
    }
    return widget.controller.text.isNotEmpty;
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    final bool show = _shouldShowSelectionHandles(cause);
    if (show != _showSelectionHandles) {
      setState(() => _showSelectionHandles = show);
    }
    if (cause == SelectionChangedCause.longPress) {
      editableText?.bringIntoView(selection.extent);
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        if (cause == SelectionChangedCause.drag) editableText?.hideToolbar();
      case TargetPlatform.iOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        break;
    }
  }

  void _handleSemanticsTap() {
    final TextEditingController controller = widget.controller;
    if (!controller.selection.isValid) {
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
    }
    _requestKeyboard();
  }

  void _handleSemanticsFocus() {
    if (widget.focusNode.canRequestFocus && !widget.focusNode.hasFocus) {
      widget.focusNode.requestFocus();
    } else if (!widget.isReadOnly) {
      _requestKeyboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool enabled = !widget.isDisabled;
    final TextStyle style = HeroFieldMetrics.textStyle(
      context,
    ).merge(widget.style?.copyWith(inherit: true));
    final TextStyle placeholderStyle = style
        .copyWith(color: theme.colors.fieldPlaceholder)
        .merge(widget.placeholderStyle?.copyWith(inherit: true));
    final Color cursorColor =
        widget.cursorColor ?? style.color ?? theme.colors.fieldForeground;
    final Color selectionColor =
        widget.selectionColor ?? HeroFieldMetrics.selectionColor(theme);
    final bool cupertinoCaret = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };

    final Widget editable = EditableText(
      key: editableTextKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: widget.isReadOnly || !enabled,
      showSelectionHandles: _showSelectionHandles,
      style: style,
      textAlign: widget.textAlign,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText,
      obscuringCharacter: widget.obscuringCharacter,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onTapOutside: widget.onTapOutside,
      onSelectionChanged: _handleSelectionChanged,
      rendererIgnoresPointer: true,
      cursorColor: cursorColor,
      backgroundCursorColor: theme.colors.muted,
      cursorWidth: theme.spacing(0.5),
      cursorHeight: _caretHeight(style, MediaQuery.textScalerOf(context)),
      cursorRadius: Radius.circular(theme.spacing(0.5)),
      cursorOpacityAnimates: cupertinoCaret,
      paintCursorAboveText: cupertinoCaret,
      selectionColor: widget.focusNode.hasFocus ? selectionColor : null,
      autocorrectionTextRectColor: selectionColor,
      selectionControls: selectionEnabled
          ? (widget.selectionControls ?? HeroTextSelectionControls.adaptive())
          : null,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      contextMenuBuilder: widget.contextMenuBuilder,
      keyboardAppearance: theme.brightness,
      scrollController: widget.scrollController,
      scrollPhysics: widget.scrollPhysics,
      dragStartBehavior: DragStartBehavior.down,
    );

    final String? placeholder = widget.placeholder;
    final Widget content = placeholder == null
        ? editable
        : Stack(
            children: <Widget>[
              Positioned.fill(
                child: ExcludeSemantics(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.controller,
                    builder: (BuildContext context, TextEditingValue value, _) {
                      if (value.text.isNotEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        placeholder,
                        style: placeholderStyle,
                        textAlign: widget.textAlign,
                        maxLines: widget.maxLines == 1 ? 1 : null,
                        softWrap: widget.maxLines != 1,
                        overflow: TextOverflow.clip,
                      );
                    },
                  ),
                ),
              ),
              editable,
            ],
          );

    final String? hint = <String>[
      ?placeholder,
      ?widget.semanticHint,
    ].where((String s) => s.isNotEmpty).join('\n').nullIfEmpty;

    // The text-field flags, value and multi-line state come from the
    // EditableText and merge into this node; setting them here as well would
    // split the field into two nodes.
    return Semantics(
      container: true,
      enabled: enabled,
      label: widget.semanticLabel,
      hint: hint,
      isRequired: widget.isRequired ? true : null,
      inputType: widget.semanticsInputType,
      validationResult: widget.isInvalid
          ? SemanticsValidationResult.invalid
          : SemanticsValidationResult.none,
      onTap: enabled && !widget.isReadOnly ? _handleSemanticsTap : null,
      onFocus: enabled ? _handleSemanticsFocus : null,
      child: TextFieldTapRegion(
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.text : MouseCursor.defer,
          child: IgnorePointer(
            ignoring: !enabled,
            child: _gestureBuilder.buildGestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Padding(padding: widget.padding, child: content),
            ),
          ),
        ),
      ),
    );
  }
}

/// Height of the caret: the natural height of the font (ascent + descent),
/// like a browser caret, instead of the full CSS line height.
double _caretHeight(TextStyle style, TextScaler scaler) {
  final (TextStyle, TextScaler) key = (style, scaler);
  final double? cached = _caretHeights[key];
  if (cached != null) return cached;
  if (_caretHeights.length >= 64) _caretHeights.clear();
  final TextPainter painter = TextPainter(
    text: TextSpan(
      text: ' ',
      style: TextStyle(
        fontFamily: style.fontFamily,
        fontFamilyFallback: style.fontFamilyFallback,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        fontStyle: style.fontStyle,
      ),
    ),
    textDirection: TextDirection.ltr,
    textScaler: scaler,
  )..layout();
  final double height = painter.preferredLineHeight;
  painter.dispose();
  return _caretHeights[key] = height;
}

final Map<(TextStyle, TextScaler), double> _caretHeights =
    <(TextStyle, TextScaler), double>{};

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

class _HeroSelectionGestureBuilder extends TextSelectionGestureDetectorBuilder {
  _HeroSelectionGestureBuilder({required HeroEditableTextState state})
    : _state = state,
      super(delegate: state);

  final HeroEditableTextState _state;

  @override
  void onUserTap() => _state.widget.onTap?.call();

  @override
  void onDragSelectionEnd(TapDragEndDetails details) {
    _state._requestKeyboard();
    super.onDragSelectionEnd(details);
  }
}
