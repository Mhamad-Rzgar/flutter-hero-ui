import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../input/input.dart';

/// Connects the parts of a color input group to the `HeroColorField` they
/// are in: the text, the focus node and the keyboard handling.
class HeroColorFieldInputScope extends InheritedWidget {
  /// Publishes the field's editing state to [child].
  const HeroColorFieldInputScope({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isChannel,
    required this.onKey,
    required this.onSubmitted,
    required super.child,
    this.onIncrease,
    this.onDecrease,
  });

  /// The text of the field.
  final TextEditingController controller;

  /// The focus node of the input.
  final FocusNode focusNode;

  /// Whether the field edits a single channel (a number) instead of hex.
  final bool isChannel;

  /// Handles the stepping keys (arrows, Page Up/Down, Home, End).
  final FocusOnKeyEventCallback onKey;

  /// Commits the text (Enter).
  final ValueChanged<String> onSubmitted;

  /// Increments the value (semantic action), or null when not adjustable.
  final VoidCallback? onIncrease;

  /// Decrements the value (semantic action), or null when not adjustable.
  final VoidCallback? onDecrease;

  /// The closest field input scope, or null.
  static HeroColorFieldInputScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroColorFieldInputScope>();

  @override
  bool updateShouldNotify(HeroColorFieldInputScope oldWidget) =>
      controller != oldWidget.controller ||
      focusNode != oldWidget.focusNode ||
      isChannel != oldWidget.isChannel ||
      onKey != oldWidget.onKey ||
      onSubmitted != oldWidget.onSubmitted ||
      onIncrease != oldWidget.onIncrease ||
      onDecrease != oldWidget.onDecrease;
}

class _HeroColorInputGroupSlots extends InheritedWidget {
  const _HeroColorInputGroupSlots({
    required this.hasPrefix,
    required this.hasSuffix,
    required super.child,
  });

  final bool hasPrefix;
  final bool hasSuffix;

  static _HeroColorInputGroupSlots? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroColorInputGroupSlots>();

  @override
  bool updateShouldNotify(_HeroColorInputGroupSlots oldWidget) =>
      hasPrefix != oldWidget.hasPrefix || hasSuffix != oldWidget.hasSuffix;
}

/// The input box of a color field (`ColorField.Group`, HeroUI's
/// `ColorInputGroup`): a [HeroColorInputPrefix], a [HeroColorInput] and a
/// [HeroColorInputSuffix] in a field box.
///
/// It is 36 tall (`h-9`, growing with the text scale) with the field radius,
/// background, border and shadow, HeroUI's hover background, the 2 px focus
/// ring while the input has focus, the danger outline while invalid and the
/// disabled opacity. [HeroFieldVariant.secondary] is the lower-emphasis
/// variant for surfaces (`--default` background, no shadow).
///
/// Without [variant] it inherits the variant of its field.
class HeroColorInputGroup extends StatelessWidget {
  /// Creates a color input group.
  const HeroColorInputGroup({
    super.key,
    this.children = const <Widget>[HeroColorInput()],
    this.variant,
    this.fullWidth,
    this.style,
  });

  /// The parts: an optional [HeroColorInputPrefix], a [HeroColorInput] and
  /// an optional [HeroColorInputSuffix].
  final List<Widget> children;

  /// The visual variant; null inherits the field's, then primary.
  final HeroFieldVariant? variant;

  /// Whether the group takes the full available width; null inherits the
  /// field's.
  final bool? fullWidth;

  /// Visual overrides (the counterpart of `className`).
  final HeroFieldStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldScope? field = HeroFieldScope.maybeOf(context);
    final HeroColorFieldInputScope? input = HeroColorFieldInputScope.maybeOf(
      context,
    );
    final bool hasPrefix = children.any(
      (Widget w) => w is HeroColorInputPrefix,
    );
    final bool hasSuffix = children.any(
      (Widget w) => w is HeroColorInputSuffix,
    );
    final bool disabled = field?.isDisabled ?? false;

    final List<Widget> parts = <Widget>[
      for (final Widget child in children)
        child is HeroColorInput ? Expanded(child: child) : child,
    ];
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: theme.spacing(9)),
      child: Row(children: parts),
    );
    content = _HeroColorInputGroupSlots(
      hasPrefix: hasPrefix,
      hasSuffix: hasSuffix,
      child: content,
    );

    final FocusNode? focusNode = input?.focusNode ?? field?.focusNode;
    final Widget box = focusNode == null
        ? _box(field, disabled, false, content)
        : ListenableBuilder(
            listenable: focusNode,
            builder: (BuildContext context, Widget? child) =>
                _box(field, disabled, focusNode.hasFocus && !disabled, child!),
            child: content,
          );
    return _GroupWidth(
      fullWidth: fullWidth ?? field?.fullWidth ?? false,
      child: box,
    );
  }

  Widget _box(
    HeroFieldScope? field,
    bool disabled,
    bool focused,
    Widget child,
  ) {
    return HeroFieldBox(
      variant: variant ?? field?.variant ?? HeroFieldVariant.primary,
      isFocused: focused,
      isInvalid: field?.isInvalid ?? false,
      isDisabled: disabled,
      style: style,
      mouseCursor: disabled ? MouseCursor.defer : SystemMouseCursors.text,
      child: child,
    );
  }
}

/// Content before the input of a [HeroColorInputGroup]
/// (`ColorField.Prefix`), usually an extra-small [HeroColorSwatch] bound to
/// the field's color: 12 px from the start edge, in the placeholder color.
class HeroColorInputPrefix extends StatelessWidget {
  /// Creates a prefix.
  const HeroColorInputPrefix({super.key, required this.child});

  /// The prefix content.
  final Widget child;

  @override
  Widget build(BuildContext context) => _affix(
    context,
    EdgeInsetsDirectional.only(start: _margin(context)),
    child,
  );
}

/// Content after the input of a [HeroColorInputGroup]
/// (`ColorField.Suffix`): 12 px from the end edge, in the placeholder color.
class HeroColorInputSuffix extends StatelessWidget {
  /// Creates a suffix.
  const HeroColorInputSuffix({super.key, required this.child});

  /// The suffix content.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _affix(context, EdgeInsetsDirectional.only(end: _margin(context)), child);
}

double _margin(BuildContext context) => HeroTheme.of(context).spacing(3);

Widget _affix(BuildContext context, EdgeInsetsGeometry padding, Widget child) {
  final HeroThemeData theme = HeroTheme.of(context);
  final Color color = theme.colors.fieldPlaceholder;
  return Padding(
    padding: padding,
    child: IconTheme.merge(
      data: IconThemeData(color: color, size: theme.spacing(4)),
      child: DefaultTextStyle.merge(
        style: theme.typography.sm.copyWith(color: color),
        child: child,
      ),
    ),
  );
}

/// The text input of a [HeroColorInputGroup] (`ColorField.Input`): the hex
/// value or the channel number of its field, `px-3` (8 next to a prefix or
/// suffix), `text-base` below the `sm` breakpoint and `text-sm` from it.
class HeroColorInput extends StatelessWidget {
  /// Creates the input part.
  const HeroColorInput({
    super.key,
    this.placeholder,
    this.style,
    this.placeholderStyle,
  });

  /// Text shown while the field is empty.
  final String? placeholder;

  /// Style merged over the input text style.
  final TextStyle? style;

  /// Style merged over the placeholder style.
  final TextStyle? placeholderStyle;

  static final RegExp _hexCharacters = RegExp(r'^#?[0-9a-fA-F]{0,6}$');

  @override
  Widget build(BuildContext context) {
    final HeroColorFieldInputScope? input = HeroColorFieldInputScope.maybeOf(
      context,
    );
    if (input == null) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroFieldScope? field = HeroFieldScope.maybeOf(context);
    final _HeroColorInputGroupSlots? slots = _HeroColorInputGroupSlots.maybeOf(
      context,
    );
    final double outer = theme.spacing(3);
    final double inner = theme.spacing(2);
    final bool disabled = field?.isDisabled ?? false;
    final bool readOnly = field?.isReadOnly ?? false;

    Widget editable = HeroEditableText(
      controller: input.controller,
      focusNode: input.focusNode,
      placeholder: placeholder,
      style: style,
      placeholderStyle: placeholderStyle,
      padding: EdgeInsetsDirectional.only(
        start: (slots?.hasPrefix ?? false) ? inner : outer,
        end: (slots?.hasSuffix ?? false) ? inner : outer,
      ),
      keyboardType: input.isChannel
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : TextInputType.text,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      maxLines: 1,
      isReadOnly: readOnly,
      isDisabled: disabled,
      isInvalid: field?.isInvalid ?? false,
      isRequired: field?.isRequired ?? false,
      inputFormatters: <TextInputFormatter>[
        if (input.isChannel)
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))
        else
          TextInputFormatter.withFunction(
            (TextEditingValue oldValue, TextEditingValue newValue) =>
                _hexCharacters.hasMatch(newValue.text) ? newValue : oldValue,
          ),
      ],
      onSubmitted: input.onSubmitted,
      semanticLabel: field?.semanticLabel,
      semanticHint: field?.semanticHint,
    );
    editable = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: input.onKey,
      child: _IntrinsicWidth(
        width: HeroFieldMetrics.defaultWidth(theme),
        child: editable,
      ),
    );
    if (input.onIncrease != null || input.onDecrease != null) {
      editable = Semantics(
        container: true,
        onIncrease: disabled || readOnly ? null : input.onIncrease,
        onDecrease: disabled || readOnly ? null : input.onDecrease,
        child: editable,
      );
    }
    return editable;
  }
}

// Reports a fixed intrinsic width (the default input width) so a group
// that sizes to its content is as wide as a native input.
class _IntrinsicWidth extends SingleChildRenderObjectWidget {
  const _IntrinsicWidth({required this.width, super.child});

  final double width;

  @override
  _RenderIntrinsicWidth createRenderObject(BuildContext context) =>
      _RenderIntrinsicWidth(width);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderIntrinsicWidth renderObject,
  ) {
    renderObject.width = width;
  }
}

class _RenderIntrinsicWidth extends RenderProxyBox {
  _RenderIntrinsicWidth(this._width);

  double _width;
  set width(double value) {
    if (value == _width) return;
    _width = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) => _width;

  @override
  double computeMaxIntrinsicWidth(double height) => _width;
}

// Fills a tight (or, with [fullWidth], a bounded) width; otherwise sizes the
// group to its content, like an `inline-flex` box.
class _GroupWidth extends SingleChildRenderObjectWidget {
  const _GroupWidth({required this.fullWidth, super.child});

  final bool fullWidth;

  @override
  _RenderGroupWidth createRenderObject(BuildContext context) =>
      _RenderGroupWidth(fullWidth);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGroupWidth renderObject,
  ) {
    renderObject.fullWidth = fullWidth;
  }
}

class _RenderGroupWidth extends RenderProxyBox {
  _RenderGroupWidth(this._fullWidth);

  bool _fullWidth;
  set fullWidth(bool value) {
    if (value == _fullWidth) return;
    _fullWidth = value;
    markNeedsLayout();
  }

  BoxConstraints _childConstraints(BoxConstraints constraints) {
    if (constraints.hasTightWidth ||
        (_fullWidth && constraints.hasBoundedWidth)) {
      return constraints.tighten(width: constraints.maxWidth);
    }
    final double width = constraints.constrainWidth(
      child!.getMaxIntrinsicWidth(double.infinity),
    );
    return constraints.tighten(width: width);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) return constraints.smallest;
    return child.getDryLayout(_childConstraints(constraints));
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(constraints), parentUsesSize: true);
    size = child.size;
  }
}
