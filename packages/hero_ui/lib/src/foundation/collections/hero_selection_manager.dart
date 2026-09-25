import 'package:flutter/foundation.dart';

import 'hero_selection.dart';

/// The selection rules of React Aria's `SelectionManager`, shared by the
/// collection components (list boxes, menus, tag groups, tables).
///
/// A manager is an immutable snapshot of a selection: [selectionMode], the
/// [selectedKeys] and the keys that cannot be selected ([disabledKeys]).
/// Every operation returns the next selection without changing the
/// snapshot, so widgets can apply it to their controlled or uncontrolled
/// state and report it through `onSelectionChanged`. An operation that is
/// not allowed returns [selectedKeys] itself (`identical`), which callers
/// use to skip redundant change notifications.
///
/// ```dart
/// final HeroSelectionManager manager = HeroSelectionManager(
///   selectionMode: HeroSelectionMode.multiple,
///   selectedKeys: const <Object>{'a'},
/// );
/// manager.toggle('b'); // {'a', 'b'}
/// ```
@immutable
class HeroSelectionManager {
  /// Creates a selection snapshot.
  const HeroSelectionManager({
    required this.selectionMode,
    this.selectedKeys = const <Object>{},
    this.disabledKeys = const <Object>{},
    this.disallowEmptySelection = false,
  });

  /// How many keys can be selected.
  final HeroSelectionMode selectionMode;

  /// The selected keys.
  final Set<Object> selectedKeys;

  /// Keys that cannot be selected or deselected.
  final Set<Object> disabledKeys;

  /// Whether operations that would leave nothing selected are ignored.
  final bool disallowEmptySelection;

  /// Whether nothing is selected.
  bool get isEmpty => selectedKeys.isEmpty;

  /// Whether [key] is selected.
  bool isSelected(Object key) => selectedKeys.contains(key);

  /// Whether [key] can take part in the selection.
  bool canSelect(Object key) =>
      selectionMode != HeroSelectionMode.none && !disabledKeys.contains(key);

  /// Toggles [key] (a press or Space on an item).
  ///
  /// In single selection an unselected key replaces the selection and the
  /// selected key is deselected, unless [disallowEmptySelection].
  Set<Object> toggle(Object key) {
    if (!canSelect(key)) return selectedKeys;
    if (selectionMode == HeroSelectionMode.single && !isSelected(key)) {
      return replace(key);
    }
    final Set<Object> next = <Object>{...selectedKeys};
    if (!next.remove(key)) next.add(key);
    if (disallowEmptySelection && next.isEmpty) return selectedKeys;
    return next;
  }

  /// Replaces the selection with [key].
  Set<Object> replace(Object key) {
    if (!canSelect(key)) return selectedKeys;
    if (selectedKeys.length == 1 && isSelected(key)) return selectedKeys;
    return <Object>{key};
  }

  /// Extends the selection from [anchor] to [to] (Shift with arrow keys or
  /// a Shift-click), following [order].
  ///
  /// The range from [anchor] to [current] (the previous end of the range)
  /// is removed first, so moving the end back shrinks the range. Without an
  /// [anchor] the range starts at [to]. Single selection replaces the
  /// selection with [to].
  Set<Object> extend({
    required Object to,
    required List<Object> order,
    Object? anchor,
    Object? current,
  }) {
    if (selectionMode == HeroSelectionMode.none) return selectedKeys;
    if (selectionMode == HeroSelectionMode.single) return replace(to);
    final Object start = anchor ?? to;
    final Set<Object> next = <Object>{...selectedKeys};
    for (final Object key in _range(start, current ?? to, order)) {
      if (canSelect(key)) next.remove(key);
    }
    for (final Object key in _range(to, start, order)) {
      if (canSelect(key)) next.add(key);
    }
    if (disallowEmptySelection && next.isEmpty) return selectedKeys;
    return setEquals(next, selectedKeys) ? selectedKeys : next;
  }

  /// Selects every selectable key of [keys] (Ctrl or Cmd + A); only in
  /// multiple selection.
  Set<Object> selectAll(Iterable<Object> keys) {
    if (selectionMode != HeroSelectionMode.multiple) return selectedKeys;
    final Set<Object> next = <Object>{
      ...selectedKeys,
      for (final Object key in keys)
        if (canSelect(key)) key,
    };
    return setEquals(next, selectedKeys) ? selectedKeys : next;
  }

  /// Deselects everything (Escape), unless [disallowEmptySelection].
  Set<Object> clear() {
    if (isEmpty || disallowEmptySelection) return selectedKeys;
    return <Object>{};
  }

  static Iterable<Object> _range(Object from, Object to, List<Object> order) {
    final int a = order.indexOf(from);
    final int b = order.indexOf(to);
    if (a < 0 || b < 0) return <Object>[if (a >= 0) from, if (b >= 0) to];
    return a <= b ? order.sublist(a, b + 1) : order.sublist(b, a + 1);
  }

  @override
  bool operator ==(Object other) =>
      other is HeroSelectionManager &&
      other.selectionMode == selectionMode &&
      setEquals(other.selectedKeys, selectedKeys) &&
      setEquals(other.disabledKeys, disabledKeys) &&
      other.disallowEmptySelection == disallowEmptySelection;

  @override
  int get hashCode => Object.hash(
    selectionMode,
    Object.hashAllUnordered(selectedKeys),
    Object.hashAllUnordered(disabledKeys),
    disallowEmptySelection,
  );
}
