import 'package:flutter/widgets.dart';

import '../../foundation/collections/hero_selection.dart';
import '../../foundation/variants/hero_variants.dart';

/// The state a `HeroToggleButtonGroup` shares with its toggle buttons.
///
/// This is the counterpart of HeroUI's `ToggleButtonGroupContext` plus React
/// Aria's toggle group state: the group owns the selection, propagates
/// `size` and `isDisabled`, and drives the roving keyboard focus.
abstract interface class HeroToggleButtonGroupController {
  /// Toggles the button with [id] and returns whether it is selected
  /// afterwards.
  bool toggle(Object id);

  /// Registers the focus node of the item at [index].
  void registerItem(int index, FocusNode node);

  /// Removes the focus node of the item at [index].
  void unregisterItem(int index, FocusNode node);

  /// Reports that the item at [index] received focus.
  void handleItemFocused(int index);
}

/// Provides the enclosing toggle button group to its buttons.
class HeroToggleButtonGroupScope extends InheritedWidget {
  /// Creates a group scope.
  const HeroToggleButtonGroupScope({
    super.key,
    required this.controller,
    required this.selectedKeys,
    required this.selectionMode,
    required this.size,
    required this.isDisabled,
    required this.orientation,
    required this.isDetached,
    required this.fullWidth,
    required this.rovingIndex,
    required super.child,
  });

  /// The group that owns the selection.
  final HeroToggleButtonGroupController controller;

  /// The ids of the selected buttons.
  final Set<Object> selectedKeys;

  /// Single (radio-like) or multiple selection.
  final HeroSelectionMode selectionMode;

  /// Size propagated to buttons that do not set their own.
  final HeroSize? size;

  /// Whether the whole group is disabled.
  final bool isDisabled;

  /// Layout direction of the group.
  final Axis orientation;

  /// Whether the buttons are separated by a gap instead of attached.
  final bool isDetached;

  /// Whether the buttons stretch to fill the group.
  final bool fullWidth;

  /// Index of the item that takes part in Tab traversal.
  final int rovingIndex;

  /// Whether a button with [id] is selected.
  bool isSelected(Object? id) => id != null && selectedKeys.contains(id);

  /// Returns the nearest group scope, if any.
  static HeroToggleButtonGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroToggleButtonGroupScope>();

  @override
  bool updateShouldNotify(HeroToggleButtonGroupScope oldWidget) =>
      !identical(controller, oldWidget.controller) ||
      !_setEquals(selectedKeys, oldWidget.selectedKeys) ||
      selectionMode != oldWidget.selectionMode ||
      size != oldWidget.size ||
      isDisabled != oldWidget.isDisabled ||
      orientation != oldWidget.orientation ||
      isDetached != oldWidget.isDetached ||
      fullWidth != oldWidget.fullWidth ||
      rovingIndex != oldWidget.rovingIndex;

  static bool _setEquals(Set<Object> a, Set<Object> b) =>
      a.length == b.length && a.containsAll(b);
}

/// Tells a toggle button where it sits inside its group.
class HeroToggleButtonGroupItemScope extends InheritedWidget {
  /// Creates an item scope.
  const HeroToggleButtonGroupItemScope({
    super.key,
    required this.index,
    required this.count,
    required super.child,
  });

  /// Position of the item among the group's children.
  final int index;

  /// Number of children in the group.
  final int count;

  /// Whether this is the first child.
  bool get isFirst => index == 0;

  /// Whether this is the last child.
  bool get isLast => index == count - 1;

  /// Returns the nearest item scope, if any.
  static HeroToggleButtonGroupItemScope? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<HeroToggleButtonGroupItemScope>();

  @override
  bool updateShouldNotify(HeroToggleButtonGroupItemScope oldWidget) =>
      index != oldWidget.index || count != oldWidget.count;
}
