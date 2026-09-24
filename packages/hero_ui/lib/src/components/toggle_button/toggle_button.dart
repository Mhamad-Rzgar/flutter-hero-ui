import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import 'toggle_button_group_scope.dart';

/// The visual style of a [HeroToggleButton] while it is not selected (the
/// `variant` prop). Selected buttons always use the accent soft fill.
enum HeroToggleButtonVariant {
  /// A `--default` fill (HeroUI's `default` variant).
  standard,

  /// A transparent fill that shows `--default` on hover.
  ghost,
}

/// The render state handed to [HeroToggleButton.builder]: hover, press,
/// focus, disabled and selected flags (React Aria's
/// `ToggleButtonRenderProps`).
typedef HeroToggleButtonState = HeroInteractionState;

/// Builds the content of a [HeroToggleButton] for its current state.
typedef HeroToggleButtonWidgetBuilder =
    Widget Function(BuildContext context, HeroToggleButtonState state);

/// Optional style overrides for a [HeroToggleButton], the counterpart of
/// customising HeroUI's `.toggle-button` classes with utilities.
///
/// Every property is optional; `null` keeps HeroUI's value. State-dependent
/// values are resolved with the button's [WidgetState]s (`hovered`,
/// `pressed`, `focused`, `disabled` and `selected`).
@immutable
class HeroToggleButtonStyle {
  /// Creates a style override.
  const HeroToggleButtonStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.iconColor,
    this.side,
    this.shadows,
    this.borderRadius,
    this.padding,
  });

  /// Fill color.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Text color (and icon color unless [iconColor] is set).
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Icon color.
  final WidgetStateProperty<Color?>? iconColor;

  /// Outline drawn inside the button's shape.
  final WidgetStateProperty<BorderSide?>? side;

  /// Outer shadows.
  final List<BoxShadow>? shadows;

  /// Corner radii; replaces the automatic radius, also inside groups.
  final BorderRadiusGeometry? borderRadius;

  /// Content padding; replaces the size's horizontal padding.
  final EdgeInsetsGeometry? padding;
}

/// HeroUI's ToggleButton: a button that switches between an on and an off
/// state.
///
/// The button toggles on press, Enter and Space. It can be controlled
/// ([isSelected] + [onChanged]) or uncontrolled ([defaultSelected]). Inside a
/// `HeroToggleButtonGroup` the group owns the selection: give every button an
/// [id], and the group's size and disabled state apply unless the button
/// sets its own.
///
/// ```dart
/// HeroToggleButton(
///   startContent: const HeroIcon(HeroIcons.heart),
///   onChanged: (bool selected) => debugPrint('$selected'),
///   child: const Text('Like'),
/// )
/// ```
class HeroToggleButton extends StatefulWidget {
  /// Creates a toggle button.
  const HeroToggleButton({
    super.key,
    this.id,
    this.child,
    this.builder,
    this.startContent,
    this.endContent,
    this.separator,
    this.variant = HeroToggleButtonVariant.standard,
    this.size,
    this.isIconOnly = false,
    this.isSelected,
    this.defaultSelected = false,
    this.isDisabled,
    this.onChanged,
    this.onPressed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.style,
  });

  /// Identifies the button inside a `HeroToggleButtonGroup` (React Aria's
  /// `id`). Required there; unused on standalone buttons.
  final Object? id;

  /// The label, usually a [Text], or the icon of an [isIconOnly] button.
  final Widget? child;

  /// Builds the label for the current state instead of [child] (HeroUI's
  /// render-prop children).
  final HeroToggleButtonWidgetBuilder? builder;

  /// Content before the label, usually a [HeroIcon].
  final Widget? startContent;

  /// Content after the label, usually a [HeroIcon].
  final Widget? endContent;

  /// A divider drawn on the leading edge of the button inside an attached
  /// group, usually `HeroToggleButtonGroupSeparator` (HeroUI places
  /// `ToggleButtonGroup.Separator` inside every button but the first).
  final Widget? separator;

  /// Unselected look.
  final HeroToggleButtonVariant variant;

  /// Size; `null` uses the group's size, then [HeroSize.md].
  final HeroSize? size;

  /// Makes the button a square that holds only an icon.
  final bool isIconOnly;

  /// Controlled selected state. Ignored inside a group.
  final bool? isSelected;

  /// Initial selected state when uncontrolled.
  final bool defaultSelected;

  /// Disables the button; `null` uses the group's disabled state.
  final bool? isDisabled;

  /// Called with the new selected state when the button toggles.
  final ValueChanged<bool>? onChanged;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Whether to focus the button when it is first built.
  final bool autofocus;

  /// Accessibility label, required for [isIconOnly] buttons (`aria-label`).
  final String? semanticLabel;

  /// Style overrides.
  final HeroToggleButtonStyle? style;

  @override
  State<HeroToggleButton> createState() => _HeroToggleButtonState();
}

class _HeroToggleButtonState extends State<HeroToggleButton> {
  late bool _selected = widget.defaultSelected;
  FocusNode? _internalNode;
  HeroToggleButtonGroupScope? _group;
  HeroToggleButtonGroupItemScope? _item;
  HeroToggleButtonGroupController? _registeredController;
  int? _registeredIndex;
  FocusNode? _registeredNode;

  FocusNode get _node =>
      widget.focusNode ??
      (_internalNode ??= FocusNode(debugLabel: 'HeroToggleButton'));

  bool get _inGroup => _group != null && widget.id != null;

  bool get _effectiveSelected => _inGroup
      ? _group!.isSelected(widget.id)
      : (widget.isSelected ?? _selected);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _group = HeroToggleButtonGroupScope.maybeOf(context);
    _item = _group == null
        ? null
        : HeroToggleButtonGroupItemScope.maybeOf(context);
    assert(
      _group == null || widget.id != null,
      'A HeroToggleButton inside a HeroToggleButtonGroup needs an id.',
    );
    _syncGroup();
  }

  @override
  void didUpdateWidget(HeroToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) _syncGroup();
  }

  @override
  void dispose() {
    _unregister();
    _internalNode?.dispose();
    super.dispose();
  }

  void _unregister() {
    if (_registeredController != null) {
      _registeredController!.unregisterItem(
        _registeredIndex!,
        _registeredNode!,
      );
    }
    _registeredController = null;
    _registeredIndex = null;
    _registeredNode = null;
  }

  void _syncGroup() {
    final HeroToggleButtonGroupController? controller = _group?.controller;
    final int? index = _item?.index;
    final FocusNode node = _node;
    if (controller != _registeredController ||
        index != _registeredIndex ||
        node != _registeredNode) {
      _unregister();
      if (controller != null && index != null) {
        controller.registerItem(index, node);
        _registeredController = controller;
        _registeredIndex = index;
        _registeredNode = node;
      }
    }
    // Roving focus: only one button of a group takes part in Tab traversal;
    // the arrow keys move between the others.
    if (controller != null && index != null) {
      node.skipTraversal = _group!.rovingIndex != index;
    } else if (widget.focusNode == null) {
      node.skipTraversal = false;
    }
  }

  void _handlePressed() {
    final bool previous = _effectiveSelected;
    final bool next;
    if (_inGroup) {
      next = _group!.controller.toggle(widget.id!);
    } else {
      next = !previous;
      if (widget.isSelected == null) setState(() => _selected = next);
    }
    if (next != previous) widget.onChanged?.call(next);
    widget.onPressed?.call();
  }

  void _handleFocusChanged(bool focused) {
    if (focused && _registeredController != null) {
      _registeredController!.handleItemFocused(_registeredIndex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HeroToggleButtonGroupScope? group = _group;
    final bool selected = _effectiveSelected;
    final bool disabled = widget.isDisabled ?? group?.isDisabled ?? false;
    final bool radio =
        _inGroup && group!.selectionMode == HeroSelectionMode.single;

    return HeroInteractable(
      onPressed: _handlePressed,
      isDisabled: disabled,
      isSelected: !radio && selected,
      isToggle: !radio,
      isButton: !radio,
      focusNode: _node,
      autofocus: widget.autofocus,
      semanticsLabel: widget.semanticLabel,
      onFocusChanged: _handleFocusChanged,
      builder: (BuildContext context, HeroInteractionState state, _) {
        Widget result = _HeroToggleButtonBody(
          button: widget,
          state: state.copyWith(isSelected: selected),
          group: group,
          item: _item,
        );
        if (radio) {
          // In single-selection groups React Aria renders `role="radio"`.
          result = Semantics(
            checked: selected,
            inMutuallyExclusiveGroup: true,
            child: result,
          );
        }
        return result;
      },
    );
  }
}

class _HeroToggleButtonBody extends StatelessWidget {
  const _HeroToggleButtonBody({
    required this.button,
    required this.state,
    required this.group,
    required this.item,
  });

  final HeroToggleButton button;
  final HeroInteractionState state;
  final HeroToggleButtonGroupScope? group;
  final HeroToggleButtonGroupItemScope? item;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroToggleButtonStyle? style = button.style;
    final HeroSize size = button.size ?? group?.size ?? HeroSize.md;
    final bool desktop = theme.isDesktop(context);
    final bool smUp = _isSmUp(context, theme);
    final bool inGroup = group != null;
    final bool attached = inGroup && !group!.isDetached;

    // Geometry (`h-10 md:h-9`, `px-4`, `size-5 sm:size-4` ...).
    final double height = theme.spacing(switch (size) {
      HeroSize.sm => desktop ? 8 : 9,
      HeroSize.md => desktop ? 9 : 10,
      HeroSize.lg => desktop ? 10 : 11,
    });
    final double paddingX = theme.spacing(size == HeroSize.sm ? 3 : 4);
    final double iconSize = theme.spacing(size == HeroSize.sm || smUp ? 4 : 5);
    final double pressedScale = switch (size) {
      HeroSize.sm => 0.98,
      HeroSize.md => 0.97,
      HeroSize.lg => 0.96,
    };
    final TextStyle textStyle = theme.typography.style(
      size == HeroSize.lg ? HeroFontSize.base : HeroFontSize.sm,
      weight: HeroTypography.medium,
    );

    // Colors (`--toggle-button-bg`, `-bg-hover`, `-bg-pressed`, `-fg`).
    final bool selected = state.isSelected;
    final HeroVariantStyle palette = selected
        ? HeroVariantStyle(
            background: colors.accentSoft,
            backgroundHover: colors.accentSoftHover,
            foreground: colors.accentSoftForeground,
          )
        : switch (button.variant) {
            HeroToggleButtonVariant.standard => HeroVariantStyle(
              background: colors.defaultColor,
              backgroundHover: colors.defaultHover,
              foreground: colors.foreground,
            ),
            HeroToggleButtonVariant.ghost => HeroVariantStyle(
              background: colors.defaultColor.withValues(alpha: 0),
              backgroundHover: colors.defaultColor,
              foreground: colors.defaultForeground,
            ),
          };
    final Set<WidgetState> states = state.widgetStates;
    final Color background =
        style?.backgroundColor?.resolve(states) ?? palette.backgroundFor(state);
    final Color foreground =
        style?.foregroundColor?.resolve(states) ?? palette.foreground;
    final Color iconColor = style?.iconColor?.resolve(states) ?? foreground;
    final BorderSide side = style?.side?.resolve(states) ?? BorderSide.none;

    // Radius: `rounded-3xl`, or only the outer corners in an attached group.
    final Radius r = Radius.circular(theme.radii.xl3);
    final BorderRadiusGeometry radius =
        style?.borderRadius ??
        (attached && item != null
            ? _groupRadius(group!.orientation, item!, r)
            : BorderRadius.all(r));
    final OutlinedBorder shape = theme.shape(radius, side: side);

    final Widget? label = button.builder != null
        ? button.builder!(context, state)
        : button.child;
    final bool hasSlots =
        button.startContent != null || button.endContent != null;
    Widget content = label ?? const SizedBox.shrink();
    if (hasSlots) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: theme.spacing(2),
        children: <Widget>[
          if (button.startContent != null)
            _HeroIconBleed(
              bleed: theme.spacing(0.5),
              child: button.startContent,
            ),
          if (label != null) Flexible(child: label),
          if (button.endContent != null)
            _HeroIconBleed(bleed: theme.spacing(0.5), child: button.endContent),
        ],
      );
    }
    content = IconTheme.merge(
      data: IconThemeData(color: iconColor, size: iconSize),
      child: DefaultTextStyle(
        style: textStyle.copyWith(color: foreground),
        softWrap: false,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        child: content,
      ),
    );

    Widget result = AnimatedContainer(
      duration: theme.motion.resolve(context, HeroMotion.fast),
      curve: HeroMotion.easeOut,
      constraints: BoxConstraints(
        minHeight: height,
        minWidth: button.isIconOnly ? height : 0,
      ),
      padding:
          style?.padding ??
          EdgeInsetsDirectional.symmetric(
            horizontal: button.isIconOnly ? 0 : paddingX,
          ),
      decoration: ShapeDecoration(
        color: background,
        shape: shape,
        shadows: style?.shadows,
      ),
      child: Center(widthFactor: 1, heightFactor: 1, child: content),
    );

    if (button.separator != null && attached) {
      result = Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: <Widget>[
          result,
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: IconTheme.merge(
                  data: IconThemeData(color: foreground),
                  child: button.separator!,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (attached) {
      // `ring-inset` with no offset keeps the ring inside the button.
      result = _HeroInsetFocusRing(
        visible: state.isFocusVisible,
        shape: shape,
        child: result,
      );
    } else {
      result = HeroFocusRing(
        visible: state.isFocusVisible,
        shape: shape,
        child: result,
      );
    }

    result = HeroPressScale(
      // Pressed scaling is turned off for buttons inside groups.
      pressed: state.isPressed && !inGroup,
      scale: pressedScale,
      child: result,
    );

    return HeroDisabledOpacity(disabled: state.isDisabled, child: result);
  }

  static BorderRadiusGeometry _groupRadius(
    Axis orientation,
    HeroToggleButtonGroupItemScope item,
    Radius r,
  ) {
    if (item.isFirst && item.isLast) return BorderRadius.all(r);
    if (orientation == Axis.horizontal) {
      if (item.isFirst) return BorderRadiusDirectional.horizontal(start: r);
      if (item.isLast) return BorderRadiusDirectional.horizontal(end: r);
    } else {
      if (item.isFirst) return BorderRadius.vertical(top: r);
      if (item.isLast) return BorderRadius.vertical(bottom: r);
    }
    return BorderRadius.zero;
  }
}

// Whether HeroUI's `sm:` utilities apply in [context]: from the `sm`
// breakpoint (640) up, unless the theme density pins touch (never) or
// desktop (always) sizes.
bool _isSmUp(BuildContext context, HeroThemeData theme) =>
    switch (theme.density) {
      HeroDensity.touch => false,
      HeroDensity.desktop => true,
      HeroDensity.adaptive =>
        (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= HeroBreakpoints.sm,
    };

/// Reproduces the `-mx-0.5` negative margin HeroUI puts on button icons: the
/// child takes [bleed] less room on each side than it paints.
class _HeroIconBleed extends SingleChildRenderObjectWidget {
  const _HeroIconBleed({required this.bleed, super.child});

  final double bleed;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeroIconBleed(bleed);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderHeroIconBleed renderObject,
  ) {
    renderObject.bleed = bleed;
  }
}

class _RenderHeroIconBleed extends RenderShiftedBox {
  _RenderHeroIconBleed(this._bleed) : super(null);

  double _bleed;
  set bleed(double value) {
    if (value == _bleed) return;
    _bleed = value;
    markNeedsLayout();
  }

  BoxConstraints _childConstraints(BoxConstraints constraints) =>
      constraints.loosen().copyWith(
        maxWidth: constraints.maxWidth.isFinite
            ? constraints.maxWidth + 2 * _bleed
            : double.infinity,
      );

  Size _sizeFor(BoxConstraints constraints, Size childSize) =>
      constraints.constrain(
        Size(math.max(0, childSize.width - 2 * _bleed), childSize.height),
      );

  @override
  double computeMinIntrinsicWidth(double height) =>
      math.max(0, (child?.getMinIntrinsicWidth(height) ?? 0) - 2 * _bleed);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      math.max(0, (child?.getMaxIntrinsicWidth(height) ?? 0) - 2 * _bleed);

  @override
  double computeMinIntrinsicHeight(double width) =>
      child?.getMinIntrinsicHeight(width + 2 * _bleed) ?? 0;

  @override
  double computeMaxIntrinsicHeight(double width) =>
      child?.getMaxIntrinsicHeight(width + 2 * _bleed) ?? 0;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final RenderBox? child = this.child;
    if (child == null) return constraints.smallest;
    return _sizeFor(
      constraints,
      child.getDryLayout(_childConstraints(constraints)),
    );
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_childConstraints(constraints), parentUsesSize: true);
    size = _sizeFor(constraints, child.size);
    (child.parentData! as BoxParentData).offset = Offset(
      (size.width - child.size.width) / 2,
      (size.height - child.size.height) / 2,
    );
  }
}

/// A focus ring drawn inside [shape] (Tailwind's `ring-inset` with a zero
/// offset), used by buttons of attached groups so the ring is not covered by
/// their neighbours.
class _HeroInsetFocusRing extends StatelessWidget {
  const _HeroInsetFocusRing({
    required this.visible,
    required this.shape,
    required this.child,
  });

  final bool visible;
  final ShapeBorder shape;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: visible ? 1 : 0),
      duration: theme.motion.resolve(context, HeroMotion.fast),
      curve: HeroMotion.easeOut,
      child: child,
      builder: (BuildContext context, double t, Widget? child) {
        if (t == 0) return child!;
        return CustomPaint(
          foregroundPainter: _InsetRingPainter(
            shape: shape,
            color: theme.colors.focus,
            width: theme.focusRingWidth,
            opacity: t,
            textDirection: Directionality.maybeOf(context),
          ),
          child: child,
        );
      },
    );
  }
}

class _InsetRingPainter extends CustomPainter {
  const _InsetRingPainter({
    required this.shape,
    required this.color,
    required this.width,
    required this.opacity,
    required this.textDirection,
  });

  final ShapeBorder shape;
  final Color color;
  final double width;
  final double opacity;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Path outer = heroInflatedShapePath(shape, rect, 0, textDirection);
    final Path inner = heroInflatedShapePath(
      shape,
      rect,
      -width,
      textDirection,
    );
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, inner),
      Paint()..color = color.withValues(alpha: color.a * opacity),
    );
  }

  @override
  bool shouldRepaint(_InsetRingPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.opacity != opacity ||
      oldDelegate.textDirection != textDirection;
}
