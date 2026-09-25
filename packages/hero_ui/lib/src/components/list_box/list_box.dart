/// HeroUI's ListBox: a list of options that can be selected or activated,
/// with sections, headers, indicators and virtualization.
library;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../description/description.dart';
import '../input/hero_field.dart';
import '../label/label.dart';
import '../separator/separator.dart';
import '../spinner/spinner.dart';

part 'list_box_item.dart';
part 'list_box_section.dart';

/// The visual variant of a [HeroListBox] and its items (HeroUI's `variant`
/// prop).
enum HeroListBoxVariant {
  /// Regular items (HeroUI's `default`).
  standard,

  /// Destructive items: the label and the indicator use `--danger`.
  danger,
}

/// The render state of a [HeroListBoxItem]: `isSelected`, `isFocused`,
/// `isFocusVisible`, `isHovered`, `isPressed` and `isDisabled`.
typedef HeroListBoxItemState = HeroInteractionState;

/// Builds the content of a [HeroListBoxItem] for its current state (HeroUI's
/// render-prop children).
typedef HeroListBoxItemWidgetBuilder =
    Widget Function(BuildContext context, HeroListBoxItemState state);

/// Optional style overrides for [HeroListBoxItem]s, the counterpart of
/// customising `.list-box-item` with utilities.
///
/// `null` values keep HeroUI's look. [backgroundColor] is resolved with the
/// item's [WidgetState]s: `hovered`, `pressed`, `focused` (the item has list
/// focus, `data-focused`), `selected` and `disabled`.
@immutable
class HeroListBoxItemStyle with Diagnosticable {
  /// Creates item style overrides.
  const HeroListBoxItemStyle({
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.minHeight,
    this.pressedScale,
  });

  /// Fill of the item; by default `--default` while hovered, else none.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Corner radii (16, `rounded-2xl`, by default).
  final BorderRadiusGeometry? borderRadius;

  /// Inner padding (8 × 6, `px-2 py-1.5`, by default). An item with an
  /// indicator always reserves 28 at its end for it.
  final EdgeInsetsGeometry? padding;

  /// Minimum height (36, `min-h-9`, by default).
  final double? minHeight;

  /// Scale while pressed (0.98 by default).
  final double? pressedScale;

  /// Returns a copy with the non-null values of [other] applied.
  HeroListBoxItemStyle merge(HeroListBoxItemStyle? other) {
    if (other == null) return this;
    return HeroListBoxItemStyle(
      backgroundColor: other.backgroundColor ?? backgroundColor,
      borderRadius: other.borderRadius ?? borderRadius,
      padding: other.padding ?? padding,
      minHeight: other.minHeight ?? minHeight,
      pressedScale: other.pressedScale ?? pressedScale,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroListBoxItemStyle &&
      other.backgroundColor == backgroundColor &&
      other.borderRadius == borderRadius &&
      other.padding == padding &&
      other.minHeight == minHeight &&
      other.pressedScale == pressedScale;

  @override
  int get hashCode => Object.hash(
    backgroundColor,
    borderRadius,
    padding,
    minHeight,
    pressedScale,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<BorderRadiusGeometry>(
          'borderRadius',
          borderRadius,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<EdgeInsetsGeometry>(
          'padding',
          padding,
          defaultValue: null,
        ),
      )
      ..add(DoubleProperty('minHeight', minHeight, defaultValue: null))
      ..add(DoubleProperty('pressedScale', pressedScale, defaultValue: null));
  }
}

/// Drives the focused item of a [HeroListBox] from outside, for example
/// from the text field of a combo box that keeps the keyboard focus while
/// the list shows a virtually focused item
/// ([HeroListBox.shouldUseVirtualFocus]).
///
/// Listeners are notified when the focused item changes.
class HeroListBoxController extends ChangeNotifier {
  _HeroListBoxState? _state;

  /// The id of the focused item, or null.
  Object? get focusedKey => _state?._focusedKey;

  /// Focuses the item with [key] and scrolls it into view; null clears the
  /// focus.
  void focusKey(Object? key) => _state?._setFocusedKey(key, reveal: true);

  /// Focuses the first enabled item.
  void focusFirst() => _state?._setFocusedKey(_state?._firstKey, reveal: true);

  /// Focuses the last enabled item.
  void focusLast() => _state?._setFocusedKey(_state?._lastKey, reveal: true);

  /// Activates the focused item as if it was pressed.
  void activateFocused() {
    final Object? key = focusedKey;
    if (key != null) _state?._activate(key);
  }

  /// Handles a navigation or selection key as if the list had focus
  /// (arrows, Home/End, PageUp/PageDown, Enter, Space, Escape, Ctrl/Cmd+A and
  /// typeahead).
  KeyEventResult handleKeyEvent(KeyEvent event) =>
      _state?._handleKeyEvent(event) ?? KeyEventResult.ignored;

  void _attach(_HeroListBoxState state) => _state = state;

  void _detach(_HeroListBoxState state) {
    if (_state == state) _state = null;
  }

  void _changed() => notifyListeners();
}

/// HeroUI's ListBox: a list of options that can be selected or activated.
///
/// Children are [HeroListBoxItem]s, [HeroListBoxSection]s (a [HeroHeader]
/// and items), [HeroSeparator]s, [HeroCollection]s of data-built items and a
/// [HeroListBoxLoadMoreItem]. Use [HeroListBox.builder] for long lists.
///
/// ```dart
/// HeroListBox(
///   semanticLabel: 'Users',
///   selectionMode: HeroSelectionMode.single,
///   children: const <Widget>[
///     HeroListBoxItem(
///       id: 'bob',
///       label: 'Bob',
///       description: 'bob@heroui.com',
///       indicator: HeroListBoxItemIndicator(),
///     ),
///     HeroListBoxItem(
///       id: 'fred',
///       label: 'Fred',
///       description: 'fred@heroui.com',
///       indicator: HeroListBoxItemIndicator(),
///     ),
///   ],
/// )
/// ```
///
/// * Selection: [selectionMode] (none by default, like React Aria), with
///   [selectedKeys] + [onSelectionChanged] (controlled) or
///   [defaultSelectedKeys]; [disabledKeys] and item `isDisabled` exclude
///   items. Pressing an item toggles it (single selection replaces the
///   selection, and pressing the selected item clears it unless
///   [disallowEmptySelection]); Shift-press extends a multiple selection.
/// * Actions: [onAction] (and [HeroListBoxItem.onAction]) run when an item
///   is pressed, after its selection changed.
/// * Keyboard: the list is one Tab stop. Up/Down move the focus between
///   enabled items (without wrapping unless [shouldFocusWrap]), Home/End
///   and PageUp/PageDown jump, typing focuses the first item whose text
///   starts with the typed characters, Enter and Space press the focused
///   item, Shift with the arrows extends a multiple selection, Ctrl/Cmd+A
///   selects all and Escape clears the selection.
/// * Layout: the list fills the available width with 4 px padding and a
///   4 px gap between its children (none inside sections). It scrolls when
///   its height is limited. With [virtualized] it builds only the visible
///   rows, each [rowHeight] (items) or [headingHeight] (section headers)
///   tall; give it a bounded size.
/// * [emptyStateBuilder] (usually a [HeroEmptyState]) replaces the items
///   when there are none.
class HeroListBox extends StatefulWidget {
  /// Creates a list box from [children].
  const HeroListBox({
    super.key,
    this.children = const <Widget>[],
    this.selectionMode = HeroSelectionMode.none,
    this.selectedKeys,
    this.defaultSelectedKeys,
    this.onSelectionChanged,
    this.disabledKeys = const <Object>{},
    this.disallowEmptySelection = false,
    this.onAction,
    this.variant = HeroListBoxVariant.standard,
    this.emptyStateBuilder,
    this.semanticLabel,
    this.padding,
    this.itemStyle,
    this.animateIndicator = true,
    this.virtualized = false,
    this.rowHeight,
    this.headingHeight,
    this.loaderHeight,
    this.itemSpacing = 0,
    this.shouldFocusOnHover = false,
    this.shouldFocusWrap = false,
    this.shouldUseVirtualFocus = false,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.scrollController,
  }) : itemCount = null,
       itemBuilder = null;

  /// Creates a list box whose [itemCount] items are built by [itemBuilder]
  /// (React Aria's `items` with a render function). Usually combined with
  /// [virtualized] for long lists.
  const HeroListBox.builder({
    super.key,
    required int this.itemCount,
    required IndexedWidgetBuilder this.itemBuilder,
    this.selectionMode = HeroSelectionMode.none,
    this.selectedKeys,
    this.defaultSelectedKeys,
    this.onSelectionChanged,
    this.disabledKeys = const <Object>{},
    this.disallowEmptySelection = false,
    this.onAction,
    this.variant = HeroListBoxVariant.standard,
    this.emptyStateBuilder,
    this.semanticLabel,
    this.padding,
    this.itemStyle,
    this.animateIndicator = true,
    this.virtualized = false,
    this.rowHeight,
    this.headingHeight,
    this.loaderHeight,
    this.itemSpacing = 0,
    this.shouldFocusOnHover = false,
    this.shouldFocusWrap = false,
    this.shouldUseVirtualFocus = false,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.scrollController,
  }) : children = const <Widget>[];

  /// The items, sections, separators, collections and load-more sentinel.
  final List<Widget> children;

  /// Number of items built by [itemBuilder] ([HeroListBox.builder]).
  final int? itemCount;

  /// Builds the item at an index, usually a [HeroListBoxItem]
  /// ([HeroListBox.builder]).
  final IndexedWidgetBuilder? itemBuilder;

  /// Whether items can be selected, and how many.
  final HeroSelectionMode selectionMode;

  /// Controlled selection: the ids of the selected items.
  final Set<Object>? selectedKeys;

  /// Initial selection when uncontrolled.
  final Set<Object>? defaultSelectedKeys;

  /// Called with the new selection when it changes.
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Ids of items that cannot be focused, selected or pressed.
  final Set<Object> disabledKeys;

  /// Keeps at least one item selected.
  final bool disallowEmptySelection;

  /// Called with the id of a pressed item (`onAction`).
  final ValueChanged<Object>? onAction;

  /// Default variant of the items. HeroUI's root variant has no styles of
  /// its own; items that do not set a variant use this one.
  final HeroListBoxVariant variant;

  /// Builds the content shown when the list has no items
  /// (`renderEmptyState`), usually a [HeroEmptyState].
  final WidgetBuilder? emptyStateBuilder;

  /// Accessibility label of the list (`aria-label`).
  final String? semanticLabel;

  /// Padding around the items; 4 (`p-1`) by default.
  final EdgeInsetsGeometry? padding;

  /// Style overrides applied to every item (merged with the item's own).
  final HeroListBoxItemStyle? itemStyle;

  /// Whether the default checkmark indicator draws itself in when selected.
  /// Pickers turn it off for single selection, where the popover closes
  /// before the animation would be seen.
  final bool animateIndicator;

  /// Builds only the rows in view (React Aria's `Virtualizer` with a
  /// `ListLayout`). Rows have fixed heights, so the list needs a bounded
  /// size.
  final bool virtualized;

  /// Height of an item row when [virtualized]; 48 by default. Scales with
  /// the text scale factor.
  final double? rowHeight;

  /// Height of a section header row when [virtualized]; 48 by default.
  final double? headingHeight;

  /// Height of a loading [HeroListBoxLoadMoreItem] when [virtualized]; 48 by
  /// default.
  final double? loaderHeight;

  /// Gap between rows when [virtualized] (`ListLayout` `gap`).
  final double itemSpacing;

  /// Whether hovering an item focuses it (menus and pickers).
  final bool shouldFocusOnHover;

  /// Whether Up on the first item and Down on the last one wrap around.
  final bool shouldFocusWrap;

  /// Whether the list leaves the keyboard focus elsewhere (for example in a
  /// combo box input) and only shows a virtually focused item, driven by a
  /// [controller].
  final bool shouldUseVirtualFocus;

  /// Controls the focused item from outside.
  final HeroListBoxController? controller;

  /// Focus node of the list.
  final FocusNode? focusNode;

  /// Whether to focus the list when it is first built.
  final bool autofocus;

  /// Controller of the list's scroll view.
  final ScrollController? scrollController;

  @override
  State<HeroListBox> createState() => _HeroListBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HeroSelectionMode>('selectionMode', selectionMode))
      ..add(
        IterableProperty<Object>(
          'selectedKeys',
          selectedKeys,
          defaultValue: null,
        ),
      )
      ..add(IterableProperty<Object>('disabledKeys', disabledKeys))
      ..add(
        EnumProperty<HeroListBoxVariant>(
          'variant',
          variant,
          defaultValue: HeroListBoxVariant.standard,
        ),
      )
      ..add(
        FlagProperty('virtualized', value: virtualized, ifTrue: 'virtualized'),
      )
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null));
  }
}

enum _RowKind { item, header, loader, separator, other }

class _Row {
  const _Row(this.kind, this.widget, [this.item]);

  final _RowKind kind;
  final Widget widget;
  final HeroListBoxItem? item;
}

/// The flattened collection of a list box.
class _Collection {
  _Collection(this.topLevel, this.rows, this.items)
    : indexOf = <Object, int>{
        for (int i = 0; i < items.length; i++) items[i].id: i,
      };

  /// Children laid out by a non-virtualized list (top-level collections
  /// expanded).
  final List<Widget> topLevel;

  /// Every row in order, sections flattened (virtualized lists).
  final List<_Row> rows;

  /// Every item in order.
  final List<HeroListBoxItem> items;

  /// Index of each item id in [items].
  final Map<Object, int> indexOf;

  static _Collection build(BuildContext context, HeroListBox widget) {
    final List<Widget> topLevel = <Widget>[];
    final List<_Row> rows = <_Row>[];
    final List<HeroListBoxItem> items = <HeroListBoxItem>[];

    void add(Widget child, {required bool inSection, List<Widget>? out}) {
      if (child is HeroCollection) {
        for (final Widget built in child.buildItems(context)) {
          add(built, inSection: inSection, out: out);
        }
        return;
      }
      out?.add(child);
      switch (child) {
        case HeroListBoxItem():
          items.add(child);
          rows.add(_Row(_RowKind.item, child, child));
        case HeroListBoxSection() when !inSection:
          if (child.header != null) {
            rows.add(_Row(_RowKind.header, child.header!));
          }
          for (final Widget sectionChild in child.children) {
            add(sectionChild, inSection: true);
          }
        case HeroHeader():
          rows.add(_Row(_RowKind.header, child));
        case HeroListBoxLoadMoreItem():
          rows.add(_Row(_RowKind.loader, child));
        case HeroSeparator():
          rows.add(_Row(_RowKind.separator, child));
        default:
          rows.add(_Row(_RowKind.other, child));
      }
    }

    final IndexedWidgetBuilder? builder = widget.itemBuilder;
    if (builder != null) {
      for (int i = 0; i < widget.itemCount!; i++) {
        add(builder(context, i), inSection: false, out: topLevel);
      }
    } else {
      for (final Widget child in widget.children) {
        add(child, inSection: false, out: topLevel);
      }
    }
    return _Collection(topLevel, rows, items);
  }
}

class _HeroListBoxState extends State<HeroListBox> {
  late Set<Object> _selected = <Object>{...?widget.defaultSelectedKeys};
  _Collection _collection = _Collection(
    const <Widget>[],
    const <_Row>[],
    const <HeroListBoxItem>[],
  );
  final Map<Object, BuildContext> _itemContexts = <Object, BuildContext>{};
  final HeroTypeahead _typeahead = HeroTypeahead();
  FocusNode? _internalNode;
  ScrollController? _internalScroll;
  Object? _focusedKey;
  Object? _anchorKey;
  Object? _currentKey;
  Object? _pressedKey;
  LogicalKeyboardKey? _pressedBy;
  DateTime? _pressedAt;
  Timer? _releaseTimer;
  bool _hasFocus = false;
  List<double> _rowOffsets = const <double>[];
  List<double> _rowExtents = const <double>[];

  FocusNode get _node =>
      widget.focusNode ??
      (_internalNode ??= FocusNode(debugLabel: 'HeroListBox'));

  ScrollController get _scroll =>
      widget.scrollController ?? (_internalScroll ??= ScrollController());

  Set<Object> get _effectiveSelected => widget.selectedKeys ?? _selected;

  bool get _isFocused => widget.shouldUseVirtualFocus || _hasFocus;

  // Read live: the platform default changes when a mouse connects, without a
  // highlight mode notification.
  bool get _highlight =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  HeroSelectionManager get _manager => HeroSelectionManager(
    selectionMode: widget.selectionMode,
    selectedKeys: _effectiveSelected,
    disabledKeys: <Object>{
      ...widget.disabledKeys,
      for (final HeroListBoxItem item in _collection.items)
        if (item.isDisabled) item.id,
    },
    disallowEmptySelection: widget.disallowEmptySelection,
  );

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_handleHighlightMode);
    widget.controller?._attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _collection = _Collection.build(context, widget);
  }

  @override
  void didUpdateWidget(HeroListBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    _collection = _Collection.build(context, widget);
    final Object? focused = _focusedKey;
    if (focused != null && !_collection.indexOf.containsKey(focused)) {
      _focusedKey = null;
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_handleHighlightMode);
    widget.controller?._detach(this);
    _typeahead.dispose();
    _releaseTimer?.cancel();
    _internalNode?.dispose();
    _internalScroll?.dispose();
    super.dispose();
  }

  void _handleHighlightMode(FocusHighlightMode mode) {
    if (mounted && _isFocused) setState(() {});
  }

  // ---------------------------------------------------------------------
  // Items.

  void _registerItem(Object id, BuildContext context) =>
      _itemContexts[id] = context;

  void _unregisterItem(Object id, BuildContext context) {
    if (_itemContexts[id] == context) _itemContexts.remove(id);
  }

  bool _isEnabled(HeroListBoxItem item) =>
      !item.isDisabled && !widget.disabledKeys.contains(item.id);

  bool _isKeyDisabled(Object id) {
    if (widget.disabledKeys.contains(id)) return true;
    final int? index = _collection.indexOf[id];
    return index != null && _collection.items[index].isDisabled;
  }

  Object? get _firstKey => _scanFrom(0, 1);

  Object? get _lastKey => _scanFrom(_collection.items.length - 1, -1);

  Object? _scanFrom(int start, int delta) {
    final List<HeroListBoxItem> items = _collection.items;
    for (int i = start; i >= 0 && i < items.length; i += delta) {
      if (_isEnabled(items[i])) return items[i].id;
    }
    return null;
  }

  Object? _step(Object? from, int delta) {
    final List<HeroListBoxItem> items = _collection.items;
    if (items.isEmpty) return null;
    final int? index = from == null ? null : _collection.indexOf[from];
    if (index == null) return delta > 0 ? _firstKey : _lastKey;
    final Object? next = _scanFrom(index + delta, delta);
    if (next != null || !widget.shouldFocusWrap) return next ?? from;
    return delta > 0 ? _firstKey : _lastKey;
  }

  Object? _page(Object? from, int direction) {
    final int count = math.max(1, _itemsPerPage());
    Object? key = from;
    for (int i = 0; i < count; i++) {
      final int? index = key == null ? null : _collection.indexOf[key];
      if (index == null) return _step(from, direction);
      final Object? next = _scanFrom(index + direction, direction);
      if (next == null) break;
      key = next;
    }
    return key;
  }

  int _itemsPerPage() {
    if (!_scroll.hasClients) return _collection.items.length;
    final double viewport = _scroll.position.viewportDimension;
    double row;
    if (widget.virtualized) {
      row = _scaled(widget.rowHeight) + widget.itemSpacing;
    } else {
      final BuildContext? context = _focusedKey == null
          ? null
          : _itemContexts[_focusedKey];
      final Size? size = context?.size;
      row =
          (size?.height ?? HeroTheme.of(this.context).spacing(9)) +
          HeroTheme.of(this.context).spacing(1);
    }
    return row <= 0 ? 1 : (viewport / row).floor();
  }

  double _scaled(double? value) {
    final HeroThemeData theme = HeroTheme.of(context);
    return MediaQuery.textScalerOf(context).scale(value ?? theme.spacing(12));
  }

  // ---------------------------------------------------------------------
  // Focus.

  Object? get _tabStop {
    final Object? focused = _focusedKey;
    if (focused != null && _collection.indexOf.containsKey(focused)) {
      if (!_isKeyDisabled(focused)) return focused;
    }
    for (final HeroListBoxItem item in _collection.items) {
      if (_isEnabled(item) && _effectiveSelected.contains(item.id)) {
        return item.id;
      }
    }
    return _firstKey;
  }

  void _handleFocusChange(bool focused) {
    if (focused == _hasFocus) return;
    setState(() {
      _hasFocus = focused;
      if (focused && _focusedKey == null) _focusedKey = _tabStop;
    });
    if (focused && _focusedKey != null) _reveal(_focusedKey!);
    if (focused) widget.controller?._changed();
  }

  void _setFocusedKey(Object? key, {required bool reveal}) {
    if (key == _focusedKey) {
      if (key != null && reveal) _reveal(key);
      return;
    }
    setState(() => _focusedKey = key);
    widget.controller?._changed();
    if (key != null && reveal) _reveal(key);
  }

  void _focusFromPointer(Object id) {
    if (_isKeyDisabled(id)) return;
    _typeahead.reset();
    _setFocusedKey(id, reveal: false);
    if (!widget.shouldUseVirtualFocus && !_node.hasFocus) {
      _node.requestFocus();
    }
  }

  void _focusFromHover(Object id) {
    if (!widget.shouldFocusOnHover || _isKeyDisabled(id)) return;
    _setFocusedKey(id, reveal: false);
    if (!widget.shouldUseVirtualFocus && !_node.hasFocus) {
      _node.requestFocus();
    }
  }

  /// Scrolls the item with [key] into view, like a browser does when an
  /// option receives focus.
  void _reveal(Object key) {
    if (widget.virtualized) {
      final int row = _collection.rows.indexWhere(
        (_Row r) => r.item?.id == key,
      );
      if (row >= 0 && _scroll.hasClients && row < _rowOffsets.length) {
        final ScrollPosition position = _scroll.position;
        final double top = _rowOffsets[row];
        final double bottom = top + _rowExtents[row];
        final EdgeInsets padding = _resolvedPadding;
        double target = position.pixels;
        if (top - padding.top < target) {
          target = top - padding.top;
        } else if (bottom + padding.bottom >
            target + position.viewportDimension) {
          target = bottom + padding.bottom - position.viewportDimension;
        }
        target = target.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        if (target != position.pixels) position.jumpTo(target);
      }
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final RenderObject? object = _itemContexts[key]?.findRenderObject();
      if (object != null && object.attached) object.showOnScreen();
    }, debugLabel: 'HeroListBox.reveal');
  }

  EdgeInsets get _resolvedPadding {
    final HeroThemeData theme = HeroTheme.of(context);
    return (widget.padding ?? EdgeInsets.all(theme.spacing(1))).resolve(
      Directionality.of(context),
    );
  }

  // ---------------------------------------------------------------------
  // Selection and actions.

  void _applySelection(Set<Object> next) {
    if (identical(next, _effectiveSelected)) return;
    if (widget.selectedKeys == null) setState(() => _selected = next);
    widget.onSelectionChanged?.call(next);
  }

  void _press(Object id) {
    if (_isKeyDisabled(id)) return;
    final bool extend =
        widget.selectionMode == HeroSelectionMode.multiple &&
        HardwareKeyboard.instance.isShiftPressed;
    _activate(id, extend: extend);
  }

  void _activate(Object id, {bool extend = false}) {
    final int? index = _collection.indexOf[id];
    if (index == null || _isKeyDisabled(id)) return;
    if (widget.selectionMode != HeroSelectionMode.none) {
      final HeroSelectionManager manager = _manager;
      if (extend) {
        _applySelection(
          manager.extend(
            to: id,
            order: _order,
            anchor: _anchorKey,
            current: _currentKey,
          ),
        );
        _anchorKey ??= id;
        _currentKey = id;
      } else {
        _applySelection(manager.toggle(id));
        _anchorKey = id;
        _currentKey = id;
      }
    }
    _collection.items[index].onAction?.call();
    widget.onAction?.call(id);
  }

  List<Object> get _order => <Object>[
    for (final HeroListBoxItem item in _collection.items) item.id,
  ];

  void _extendTo(Object to) {
    _applySelection(
      _manager.extend(
        to: to,
        order: _order,
        anchor: _anchorKey,
        current: _currentKey,
      ),
    );
    _anchorKey ??= to;
    _currentKey = to;
  }

  // ---------------------------------------------------------------------
  // Keyboard.

  void _pressKey(Object id, LogicalKeyboardKey key) {
    _releaseTimer?.cancel();
    setState(() {
      _pressedKey = id;
      _pressedBy = key;
      _pressedAt = DateTime.now();
    });
    _activate(id);
  }

  void _releaseKey() {
    final DateTime? at = _pressedAt;
    _pressedBy = null;
    _pressedAt = null;
    if (_pressedKey == null) return;
    final Duration remaining = at == null
        ? Duration.zero
        : const Duration(milliseconds: 100) - DateTime.now().difference(at);
    void release() {
      if (mounted && _pressedKey != null) setState(() => _pressedKey = null);
    }

    if (remaining <= Duration.zero) {
      release();
    } else {
      _releaseTimer?.cancel();
      _releaseTimer = Timer(remaining, release);
    }
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      if (event.logicalKey == _pressedBy) {
        _releaseKey();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    final HardwareKeyboard keyboard = HardwareKeyboard.instance;
    final bool shift = keyboard.isShiftPressed;
    final bool command = keyboard.isControlPressed || keyboard.isMetaPressed;
    final bool multiple = widget.selectionMode == HeroSelectionMode.multiple;
    final Object? focused = _focusedKey;

    Object? target;
    if (key == LogicalKeyboardKey.arrowDown) {
      target = _step(focused, 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      target = _step(focused, -1);
    } else if (key == LogicalKeyboardKey.home) {
      target = _firstKey;
    } else if (key == LogicalKeyboardKey.end) {
      target = _lastKey;
    } else if (key == LogicalKeyboardKey.pageDown) {
      target = _page(focused, 1);
    } else if (key == LogicalKeyboardKey.pageUp) {
      target = _page(focused, -1);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        (key == LogicalKeyboardKey.space && !_typeahead.isActive)) {
      if (event is KeyRepeatEvent) return KeyEventResult.handled;
      if (focused == null || _isKeyDisabled(focused)) {
        return KeyEventResult.ignored;
      }
      _pressKey(focused, key);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.keyA && command && multiple) {
      _applySelection(_manager.selectAll(_order));
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.escape) {
      final Set<Object> cleared = _manager.clear();
      if (identical(cleared, _effectiveSelected)) {
        return KeyEventResult.ignored;
      }
      _applySelection(cleared);
      return KeyEventResult.handled;
    } else {
      final String? character = event.character;
      if (character == null ||
          character.isEmpty ||
          command ||
          keyboard.isAltPressed ||
          character.runes.any((int r) => r < 0x20 || r == 0x7f)) {
        return KeyEventResult.ignored;
      }
      final Object? match = _typeahead.search(character, <HeroTypeaheadEntry>[
        for (final HeroListBoxItem item in _collection.items)
          (
            key: item.id,
            text: item.effectiveTextValue,
            isDisabled: !_isEnabled(item),
          ),
      ], from: focused);
      if (match != null) _setFocusedKey(match, reveal: true);
      return KeyEventResult.handled;
    }

    if (target == null) return KeyEventResult.handled;
    _typeahead.reset();
    _setFocusedKey(target, reveal: true);
    if (shift && multiple) _extendTo(target);
    return KeyEventResult.handled;
  }

  // ---------------------------------------------------------------------
  // Build.

  Widget _buildRow(BuildContext context, int index) {
    final _Row row = _collection.rows[index];
    Widget child = row.widget;
    if (row.kind == _RowKind.separator) {
      child = Center(child: child);
    } else {
      // A row is as tall as its layout slot; the content keeps its natural
      // height at the top, like React Aria's absolutely positioned rows.
      child = ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: double.infinity,
          child: child,
        ),
      );
    }
    if (widget.itemSpacing > 0 && index < _collection.rows.length - 1) {
      child = Padding(
        padding: EdgeInsets.only(bottom: widget.itemSpacing),
        child: child,
      );
    }
    return child;
  }

  void _layoutRows() {
    final List<_Row> rows = _collection.rows;
    final List<double> extents = List<double>.filled(rows.length, 0);
    final List<double> offsets = List<double>.filled(rows.length, 0);
    final double item = _scaled(widget.rowHeight);
    final double heading = _scaled(widget.headingHeight);
    final double loader = _scaled(widget.loaderHeight);
    final TextDirection direction = Directionality.of(context);
    double offset = _resolvedPadding.top;
    for (int i = 0; i < rows.length; i++) {
      final _Row row = rows[i];
      extents[i] = switch (row.kind) {
        _RowKind.item || _RowKind.other => item,
        _RowKind.header => heading,
        _RowKind.loader =>
          (row.widget as HeroListBoxLoadMoreItem).isLoading ? loader : 0,
        _RowKind.separator => () {
          final HeroSeparator separator = row.widget as HeroSeparator;
          return separator.thickness +
              (separator.margin?.resolve(direction).vertical ?? 0);
        }(),
      };
      offsets[i] = offset;
      offset += extents[i] + widget.itemSpacing;
    }
    _rowExtents = extents;
    _rowOffsets = offsets;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final EdgeInsets padding = _resolvedPadding;
    final _Collection collection = _collection;
    final bool empty =
        collection.items.isEmpty && widget.emptyStateBuilder != null;

    Widget content;
    if (empty) {
      content = SingleChildScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(1),
          children: <Widget>[
            widget.emptyStateBuilder!(context),
            for (final _Row row in collection.rows)
              if (row.kind == _RowKind.loader) row.widget,
          ],
        ),
      );
    } else if (widget.virtualized) {
      _layoutRows();
      content = ListView.builder(
        controller: _scroll,
        padding: padding,
        itemCount: collection.rows.length,
        itemExtentBuilder: (int index, SliverLayoutDimensions dimensions) =>
            index < _rowExtents.length
            ? _rowExtents[index] +
                  (index < _rowExtents.length - 1 ? widget.itemSpacing : 0)
            : null,
        itemBuilder: _buildRow,
      );
    } else {
      content = SingleChildScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: theme.spacing(1),
          children: collection.topLevel,
        ),
      );
    }

    // Horizontal separators take 94% of the width, centered
    // (`ms-[3%] w-[94%]`).
    content = HeroSeparatorScope(
      orientation: Axis.horizontal,
      lengthFactor: 0.94,
      child: content,
    );
    content = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.list,
      label: widget.semanticLabel,
      child: content,
    );
    content = Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      canRequestFocus: !widget.shouldUseVirtualFocus,
      skipTraversal: widget.shouldUseVirtualFocus,
      includeSemantics: false,
      onFocusChange: _handleFocusChange,
      onKeyEvent: (FocusNode node, KeyEvent event) => _handleKeyEvent(event),
      child: content,
    );
    content = _HeroListBoxScope(
      state: this,
      selectedKeys: _effectiveSelected,
      disabledKeys: widget.disabledKeys,
      focusedKey: _focusedKey,
      isFocused: _isFocused,
      isFocusVisible: _highlight,
      pressedKey: _pressedKey,
      selectionMode: widget.selectionMode,
      variant: widget.variant,
      itemStyle: widget.itemStyle,
      animateIndicator: widget.animateIndicator,
      child: content,
    );
    // `overflow-clip`: the items' focus rings fit in the list padding.
    return _HeroListBoxWidth(child: ClipRect(child: content));
  }
}

class _HeroListBoxScope extends InheritedModel<Object> {
  const _HeroListBoxScope({
    required this.state,
    required this.selectedKeys,
    required this.disabledKeys,
    required this.focusedKey,
    required this.isFocused,
    required this.isFocusVisible,
    required this.pressedKey,
    required this.selectionMode,
    required this.variant,
    required this.itemStyle,
    required this.animateIndicator,
    required super.child,
  });

  final _HeroListBoxState state;
  final Set<Object> selectedKeys;
  final Set<Object> disabledKeys;
  final Object? focusedKey;
  final bool isFocused;
  final bool isFocusVisible;
  final Object? pressedKey;
  final HeroSelectionMode selectionMode;
  final HeroListBoxVariant variant;
  final HeroListBoxItemStyle? itemStyle;
  final bool animateIndicator;

  bool isSelected(Object id) => selectedKeys.contains(id);

  bool isItemFocused(Object id) => isFocused && focusedKey == id;

  static _HeroListBoxScope? maybeOf(BuildContext context, Object id) =>
      InheritedModel.inheritFrom<_HeroListBoxScope>(context, aspect: id);

  bool _globalChanged(_HeroListBoxScope old) =>
      state != old.state ||
      selectionMode != old.selectionMode ||
      variant != old.variant ||
      itemStyle != old.itemStyle ||
      animateIndicator != old.animateIndicator;

  @override
  bool updateShouldNotify(_HeroListBoxScope oldWidget) =>
      _globalChanged(oldWidget) ||
      !setEquals(selectedKeys, oldWidget.selectedKeys) ||
      !setEquals(disabledKeys, oldWidget.disabledKeys) ||
      focusedKey != oldWidget.focusedKey ||
      isFocused != oldWidget.isFocused ||
      isFocusVisible != oldWidget.isFocusVisible ||
      pressedKey != oldWidget.pressedKey;

  @override
  bool updateShouldNotifyDependent(
    _HeroListBoxScope oldWidget,
    Set<Object> dependencies,
  ) {
    if (_globalChanged(oldWidget)) return true;
    for (final Object id in dependencies) {
      final bool focused = isItemFocused(id);
      if (isSelected(id) != oldWidget.isSelected(id) ||
          focused != oldWidget.isItemFocused(id) ||
          (focused && isFocusVisible != oldWidget.isFocusVisible) ||
          (pressedKey == id) != (oldWidget.pressedKey == id) ||
          disabledKeys.contains(id) != oldWidget.disabledKeys.contains(id)) {
        return true;
      }
    }
    return false;
  }
}

/// Fills a bounded width (`w-full`); in an unbounded width it takes the
/// width of its widest child.
class _HeroListBoxWidth extends SingleChildRenderObjectWidget {
  const _HeroListBoxWidth({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeroListBoxWidth();
}

class _RenderHeroListBoxWidth extends RenderProxyBox {
  BoxConstraints _childConstraints(BoxConstraints constraints) {
    if (constraints.hasBoundedWidth) {
      return constraints.tighten(width: constraints.maxWidth);
    }
    final double width = child!.getMaxIntrinsicWidth(
      constraints.hasBoundedHeight ? constraints.maxHeight : double.infinity,
    );
    return constraints.tighten(width: constraints.constrainWidth(width));
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    if (child == null) return constraints.smallest;
    return child!.getDryLayout(_childConstraints(constraints));
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child!.layout(_childConstraints(constraints), parentUsesSize: true);
    size = child!.size;
  }
}
