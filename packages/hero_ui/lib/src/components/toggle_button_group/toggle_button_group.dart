import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../toggle_button/toggle_button.dart';
import '../toggle_button/toggle_button_group_scope.dart';

/// HeroUI's ToggleButtonGroup: groups [HeroToggleButton]s into one control
/// with single (radio-like) or multiple selection.
///
/// Every button needs an `id`; the group owns the selection
/// ([selectedKeys] + [onSelectionChanged], or [defaultSelectedKeys]) and
/// passes [size] and [isDisabled] to buttons that do not set their own.
/// Buttons are attached by default (only the outer corners are rounded and a
/// [HeroToggleButtonGroupSeparator] divides them); [isDetached] separates
/// them with a 4 px gap.
///
/// The group is a single Tab stop. Arrow keys move the focus between its
/// buttons (Left/Right when horizontal, flipped in right-to-left layouts;
/// Up/Down when vertical), and Enter or Space toggle the focused button.
///
/// ```dart
/// HeroToggleButtonGroup(
///   selectionMode: HeroSelectionMode.multiple,
///   children: const <Widget>[
///     HeroToggleButton(
///       id: 'bold',
///       isIconOnly: true,
///       semanticLabel: 'Bold',
///       child: HeroIcon(HeroIcons.bold),
///     ),
///     HeroToggleButton(
///       id: 'italic',
///       isIconOnly: true,
///       semanticLabel: 'Italic',
///       separator: HeroToggleButtonGroupSeparator(),
///       child: HeroIcon(HeroIcons.italic),
///     ),
///   ],
/// )
/// ```
class HeroToggleButtonGroup extends StatefulWidget {
  /// Creates a toggle button group.
  const HeroToggleButtonGroup({
    super.key,
    required this.children,
    this.selectionMode = HeroSelectionMode.single,
    this.selectedKeys,
    this.defaultSelectedKeys,
    this.onSelectionChanged,
    this.disallowEmptySelection = false,
    this.orientation = Axis.horizontal,
    this.size = HeroSize.md,
    this.isDetached = false,
    this.fullWidth = false,
    this.isDisabled = false,
    this.semanticLabel,
  }) : assert(
         selectionMode != HeroSelectionMode.none,
         'A toggle button group selects single or multiple buttons.',
       );

  /// The buttons, usually [HeroToggleButton]s with an `id`.
  final List<Widget> children;

  /// Whether one ([HeroSelectionMode.single]) or several buttons can be
  /// selected.
  final HeroSelectionMode selectionMode;

  /// Controlled selection: the ids of the selected buttons.
  final Set<Object>? selectedKeys;

  /// Initial selection when uncontrolled.
  final Set<Object>? defaultSelectedKeys;

  /// Called with the new selection when a button toggles.
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Prevents deselecting the last selected button.
  final bool disallowEmptySelection;

  /// Lays the buttons out in a row or a column.
  final Axis orientation;

  /// Size of buttons that do not set their own.
  final HeroSize size;

  /// Separates the buttons with a gap and rounds all their corners.
  final bool isDetached;

  /// Stretches the group to the available width and the buttons to fill it.
  final bool fullWidth;

  /// Disables every button that does not set `isDisabled` itself.
  final bool isDisabled;

  /// Accessibility label of the group (`aria-label`).
  final String? semanticLabel;

  @override
  State<HeroToggleButtonGroup> createState() => _HeroToggleButtonGroupState();
}

class _HeroToggleButtonGroupState extends State<HeroToggleButtonGroup>
    implements HeroToggleButtonGroupController {
  late Set<Object> _selected = <Object>{...?widget.defaultSelectedKeys};
  final Map<int, FocusNode> _nodes = <int, FocusNode>{};
  int? _lastFocused;

  Set<Object> get _effectiveSelected => widget.selectedKeys ?? _selected;

  @override
  bool toggle(Object id) {
    final Set<Object> current = _effectiveSelected;
    final Set<Object> next;
    if (widget.selectionMode == HeroSelectionMode.single) {
      next = current.contains(id) ? <Object>{} : <Object>{id};
    } else {
      next = <Object>{...current};
      if (!next.remove(id)) next.add(id);
    }
    if (widget.disallowEmptySelection && next.isEmpty) {
      return current.contains(id);
    }
    if (widget.selectedKeys == null) setState(() => _selected = next);
    widget.onSelectionChanged?.call(next);
    return next.contains(id);
  }

  @override
  void registerItem(int index, FocusNode node) => _nodes[index] = node;

  @override
  void unregisterItem(int index, FocusNode node) {
    if (_nodes[index] == node) _nodes.remove(index);
  }

  @override
  void handleItemFocused(int index) {
    if (_lastFocused == index) return;
    setState(() => _lastFocused = index);
  }

  bool _isEnabled(int index) {
    final FocusNode? node = _nodes[index];
    if (node != null && node.context != null) return node.canRequestFocus;
    final Widget child = widget.children[index];
    if (child is HeroToggleButton) {
      return !(child.isDisabled ?? widget.isDisabled);
    }
    return !widget.isDisabled;
  }

  int get _rovingIndex {
    final int count = widget.children.length;
    final int? last = _lastFocused;
    if (last != null && last < count && _isEnabled(last)) return last;
    for (int i = 0; i < count; i++) {
      if (_isEnabled(i)) return i;
    }
    return 0;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final int? delta = switch (widget.orientation) {
      Axis.horizontal when key == LogicalKeyboardKey.arrowRight => rtl ? -1 : 1,
      Axis.horizontal when key == LogicalKeyboardKey.arrowLeft => rtl ? 1 : -1,
      Axis.vertical when key == LogicalKeyboardKey.arrowDown => 1,
      Axis.vertical when key == LogicalKeyboardKey.arrowUp => -1,
      _ => null,
    };
    if (delta == null) return KeyEventResult.ignored;
    int? current;
    for (final MapEntry<int, FocusNode> entry in _nodes.entries) {
      if (entry.value.hasPrimaryFocus) current = entry.key;
    }
    if (current == null) return KeyEventResult.ignored;
    // Like React Aria's toolbar, focus stops at the ends (no wrapping).
    for (
      int i = current + delta;
      i >= 0 && i < widget.children.length;
      i += delta
    ) {
      final FocusNode? target = _nodes[i];
      if (target != null && target.canRequestFocus) {
        target.requestFocus();
        break;
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final int count = widget.children.length;
    final bool horizontal = widget.orientation == Axis.horizontal;
    final List<Widget> items = <Widget>[
      for (int i = 0; i < count; i++)
        if (widget.fullWidth && horizontal)
          Expanded(
            child: HeroToggleButtonGroupItemScope(
              index: i,
              count: count,
              child: widget.children[i],
            ),
          )
        else
          HeroToggleButtonGroupItemScope(
            index: i,
            count: count,
            child: widget.children[i],
          ),
    ];
    final double gap = widget.isDetached ? theme.spacing(1) : 0;
    Widget result = horizontal
        ? Row(
            mainAxisSize: widget.fullWidth
                ? MainAxisSize.max
                : MainAxisSize.min,
            spacing: gap,
            children: items,
          )
        : Column(mainAxisSize: MainAxisSize.min, spacing: gap, children: items);
    if (widget.fullWidth && !horizontal) {
      result = SizedBox(width: double.infinity, child: result);
    }

    result = HeroToggleButtonGroupScope(
      controller: this,
      selectedKeys: _effectiveSelected,
      selectionMode: widget.selectionMode,
      size: widget.size,
      isDisabled: widget.isDisabled,
      orientation: widget.orientation,
      isDetached: widget.isDetached,
      fullWidth: widget.fullWidth,
      rovingIndex: _rovingIndex,
      child: result,
    );

    result = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _handleKey,
      child: result,
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      role: widget.selectionMode == HeroSelectionMode.single
          ? SemanticsRole.radioGroup
          : null,
      child: result,
    );
  }
}

/// A divider between the buttons of an attached [HeroToggleButtonGroup]
/// (HeroUI's `ToggleButtonGroup.Separator`).
///
/// Pass it as the `separator` of every button except the first. It is drawn
/// on the button's leading edge (its top edge in vertical groups) in the
/// button's foreground color at 15% opacity, and hidden in detached groups.
class HeroToggleButtonGroupSeparator extends StatelessWidget {
  /// Creates a separator.
  const HeroToggleButtonGroupSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final HeroToggleButtonGroupScope? group =
        HeroToggleButtonGroupScope.maybeOf(context);
    if (group == null || group.isDetached) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    final Color current =
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color ??
        theme.colors.foreground;
    final double hairline = theme.spacing(0.25);
    final Widget line = DecoratedBox(
      decoration: ShapeDecoration(
        color: current.withValues(alpha: current.a * 0.15),
        shape: theme.shapeAll(theme.radii.sm),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        if (group.orientation == Axis.horizontal)
          PositionedDirectional(
            start: -hairline,
            top: 0,
            bottom: 0,
            width: hairline,
            child: FractionallySizedBox(heightFactor: 0.5, child: line),
          )
        else
          Positioned(
            top: -hairline,
            left: 0,
            right: 0,
            height: hairline,
            child: FractionallySizedBox(widthFactor: 0.5, child: line),
          ),
      ],
    );
  }
}
