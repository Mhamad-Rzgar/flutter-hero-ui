/// HeroUI's TagGroup: a focusable list of tags with keyboard navigation,
/// selection and removal.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../button/button.dart';
import '../close_button/close_button.dart';
import '../description/description.dart';
import '../error_message/error_message.dart';
import '../label/label.dart';

part 'tag.dart';

/// The look of the tags of a [HeroTagGroup] (HeroUI's `variant` prop).
enum HeroTagVariant {
  /// `--default` fill with `--default-foreground` text (HeroUI's
  /// `default`).
  standard,

  /// `--surface` fill with `--surface-foreground` text, for tags on a
  /// background.
  surface,
}

/// HeroUI's TagGroup: a focusable list of [HeroTag]s with selection and
/// removal.
///
/// Compose it like HeroUI: an optional [label], a [HeroTagGroupList] of
/// tags, an optional [description] and an optional [errorMessage]. The
/// group owns the selection
/// ([selectedKeys] + [onSelectionChanged], or [defaultSelectedKeys]) and
/// passes [size], [variant] and [isDisabled] to its tags.
///
/// ```dart
/// HeroTagGroup(
///   label: 'Categories',
///   selectionMode: HeroSelectionMode.multiple,
///   onRemove: (Set<Object> keys) => setState(() => tags.removeAll(keys)),
///   children: <Widget>[
///     HeroTagGroupList(
///       children: <Widget>[
///         for (final String tag in tags) HeroTag(id: tag, label: tag),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// * Selection: [selectionMode] (none by default); pressing a tag, Enter or
///   Space toggles it. Single selection replaces the selection.
/// * Removal: with [onRemove] every tag shows a remove button (or its own
///   [HeroTagRemoveButton]); pressing it, or Delete / Backspace on the
///   focused tag, calls [onRemove] with that tag, or with the whole
///   selection when the focused tag is selected.
/// * Keyboard: the list is one Tab stop; the arrow keys (flipped in
///   right-to-left layouts), Home and End move between enabled tags,
///   typing focuses a tag by its text, Escape clears the selection and
///   Ctrl/Cmd+A selects all tags.
class HeroTagGroup extends StatefulWidget {
  /// Creates a tag group.
  const HeroTagGroup({
    super.key,
    required this.children,
    this.label,
    this.description,
    this.errorMessage,
    this.spacing,
    this.selectionMode = HeroSelectionMode.none,
    this.selectedKeys,
    this.defaultSelectedKeys,
    this.onSelectionChanged,
    this.disabledKeys = const <Object>{},
    this.disallowEmptySelection = false,
    this.isDisabled = false,
    this.onRemove,
    this.size = HeroSize.md,
    this.variant = HeroTagVariant.standard,
    this.semanticLabel,
  });

  /// The parts: a [HeroTagGroupList] and optionally a [HeroLabel],
  /// [HeroDescription]s, [HeroErrorMessage]s or other content, laid out in a
  /// column with a 4 px gap. Descriptions and error messages get 4 px of
  /// padding.
  final List<Widget> children;

  /// Label text shown above the parts, as a [HeroLabel]; it also labels the
  /// list for assistive technologies.
  final String? label;

  /// Description text shown below the parts, as a [HeroDescription].
  final String? description;

  /// Error text shown below the description, as a [HeroErrorMessage]; null
  /// or empty shows nothing.
  final String? errorMessage;

  /// Gap between the parts; 4 (`gap-1`) by default.
  final double? spacing;

  /// Whether tags can be selected, and how many.
  final HeroSelectionMode selectionMode;

  /// Controlled selection: the ids of the selected tags.
  final Set<Object>? selectedKeys;

  /// Initial selection when uncontrolled.
  final Set<Object>? defaultSelectedKeys;

  /// Called with the new selection when it changes.
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Ids of tags that cannot be focused, selected or removed.
  final Set<Object> disabledKeys;

  /// Keeps at least one tag selected.
  final bool disallowEmptySelection;

  /// Disables every tag.
  final bool isDisabled;

  /// Called with the ids of the tags to remove; also shows the remove
  /// buttons.
  final ValueChanged<Set<Object>>? onRemove;

  /// Size of the tags.
  final HeroSize size;

  /// Look of the tags.
  final HeroTagVariant variant;

  /// Accessibility label of the list; defaults to [label].
  final String? semanticLabel;

  @override
  State<HeroTagGroup> createState() => _HeroTagGroupState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(EnumProperty<HeroSelectionMode>('selectionMode', selectionMode))
      ..add(
        IterableProperty<Object>(
          'selectedKeys',
          selectedKeys,
          defaultValue: null,
        ),
      )
      ..add(EnumProperty<HeroSize>('size', size, defaultValue: HeroSize.md))
      ..add(
        EnumProperty<HeroTagVariant>(
          'variant',
          variant,
          defaultValue: HeroTagVariant.standard,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroTagGroupState extends State<HeroTagGroup> {
  late Set<Object> _selected = <Object>{...?widget.defaultSelectedKeys};

  Set<Object> get _effectiveSelected => widget.selectedKeys ?? _selected;

  HeroSelectionManager _manager(Set<Object> disabled) => HeroSelectionManager(
    selectionMode: widget.selectionMode,
    selectedKeys: _effectiveSelected,
    disabledKeys: disabled,
    disallowEmptySelection: widget.disallowEmptySelection,
  );

  void _apply(Set<Object> next) {
    if (identical(next, _effectiveSelected)) return;
    if (widget.selectedKeys == null) setState(() => _selected = next);
    widget.onSelectionChanged?.call(next);
  }

  void toggle(Object id, Set<Object> disabled) =>
      _apply(_manager(disabled).toggle(id));

  void selectAll(List<Object> order, Set<Object> disabled) =>
      _apply(_manager(disabled).selectAll(order));

  /// Returns whether the selection changed.
  bool clear(Set<Object> disabled) {
    final Set<Object> cleared = _manager(disabled).clear();
    if (identical(cleared, _effectiveSelected)) return false;
    _apply(cleared);
    return true;
  }

  void remove(Set<Object> keys) {
    if (keys.isEmpty) return;
    widget.onRemove?.call(keys);
  }

  /// Delete or Backspace on [id]: removes the selection when [id] is part
  /// of it, else [id] alone.
  void removeFromKeyboard(Object id) => remove(
    _effectiveSelected.contains(id)
        ? <Object>{..._effectiveSelected}
        : <Object>{id},
  );

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final String? label = widget.label;
    final String? description = widget.description;
    final String? errorMessage = widget.errorMessage;
    return _HeroTagGroupScope(
      state: this,
      selectedKeys: _effectiveSelected,
      disabledKeys: widget.disabledKeys,
      selectionMode: widget.selectionMode,
      isDisabled: widget.isDisabled,
      allowsRemoving: widget.onRemove != null,
      size: widget.size,
      variant: widget.variant,
      semanticLabel: widget.semanticLabel ?? label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: widget.spacing ?? theme.spacing(1),
        children: <Widget>[
          if (label != null) HeroLabel.text(label),
          for (final Widget child in widget.children) _padSlot(theme, child),
          if (description != null)
            _padSlot(theme, HeroDescription.text(description)),
          if (errorMessage != null && errorMessage.isNotEmpty)
            _padSlot(theme, HeroErrorMessage.text(errorMessage)),
        ],
      ),
    );
  }

  // `.tag-group [data-slot="description"]` and
  // `[data-slot="error-message"]` have `p-1`.
  static Widget _padSlot(HeroThemeData theme, Widget child) =>
      child is HeroDescription ||
          (child is HeroErrorMessage &&
              (child.child != null || (child.data?.isNotEmpty ?? false)))
      ? Padding(padding: EdgeInsets.all(theme.spacing(1)), child: child)
      : child;
}

class _HeroTagGroupScope extends InheritedWidget {
  const _HeroTagGroupScope({
    required this.state,
    required this.selectedKeys,
    required this.disabledKeys,
    required this.selectionMode,
    required this.isDisabled,
    required this.allowsRemoving,
    required this.size,
    required this.variant,
    required this.semanticLabel,
    required super.child,
  });

  final _HeroTagGroupState state;
  final Set<Object> selectedKeys;
  final Set<Object> disabledKeys;
  final HeroSelectionMode selectionMode;
  final bool isDisabled;
  final bool allowsRemoving;
  final HeroSize size;
  final HeroTagVariant variant;
  final String? semanticLabel;

  static _HeroTagGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroTagGroupScope>();

  @override
  bool updateShouldNotify(_HeroTagGroupScope oldWidget) =>
      !setEquals(selectedKeys, oldWidget.selectedKeys) ||
      !setEquals(disabledKeys, oldWidget.disabledKeys) ||
      selectionMode != oldWidget.selectionMode ||
      isDisabled != oldWidget.isDisabled ||
      allowsRemoving != oldWidget.allowsRemoving ||
      size != oldWidget.size ||
      variant != oldWidget.variant ||
      semanticLabel != oldWidget.semanticLabel;
}

/// HeroUI's `TagGroup.List`: the tags of a [HeroTagGroup], wrapping onto
/// new lines with a 6 px gap.
///
/// Children are [HeroTag]s and [HeroCollection]s of data-built tags. When
/// there are none, [emptyStateBuilder] (usually a [HeroEmptyState]) is shown
/// instead.
class HeroTagGroupList extends StatefulWidget {
  /// Creates a tag list.
  const HeroTagGroupList({
    super.key,
    this.children = const <Widget>[],
    this.emptyStateBuilder,
    this.spacing,
    this.focusNode,
    this.autofocus = false,
  });

  /// The tags.
  final List<Widget> children;

  /// Builds the content shown when there are no tags (`renderEmptyState`).
  final WidgetBuilder? emptyStateBuilder;

  /// Gap between tags, horizontally and between lines; 6 (`gap-1.5`) by
  /// default.
  final double? spacing;

  /// Focus node of the list.
  final FocusNode? focusNode;

  /// Whether to focus the list when it is first built.
  final bool autofocus;

  @override
  State<HeroTagGroupList> createState() => _HeroTagGroupListState();
}

class _HeroTagGroupListState extends State<HeroTagGroupList> {
  List<Widget> _children = const <Widget>[];
  List<HeroTag> _tags = const <HeroTag>[];
  Map<Object, int> _indexOf = const <Object, int>{};
  final HeroTypeahead _typeahead = HeroTypeahead();
  FocusNode? _internalNode;
  Object? _focusedKey;
  int? _removedIndex;
  bool _hasFocus = false;

  FocusNode get _node =>
      widget.focusNode ??
      (_internalNode ??= FocusNode(debugLabel: 'HeroTagGroupList'));

  bool get _highlight =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  _HeroTagGroupScope? get _group =>
      context.getInheritedWidgetOfExactType<_HeroTagGroupScope>();

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_handleHighlightMode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _collect();
  }

  @override
  void didUpdateWidget(HeroTagGroupList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _collect();
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_handleHighlightMode);
    _typeahead.dispose();
    _internalNode?.dispose();
    super.dispose();
  }

  void _handleHighlightMode(FocusHighlightMode mode) {
    if (mounted && _hasFocus) setState(() {});
  }

  void _collect() {
    final List<Widget> children = <Widget>[];
    final List<HeroTag> tags = <HeroTag>[];
    void add(Widget child) {
      if (child is HeroCollection) {
        child.buildItems(context).forEach(add);
        return;
      }
      children.add(child);
      if (child is HeroTag) tags.add(child);
    }

    widget.children.forEach(add);
    _children = children;
    _tags = tags;
    _indexOf = <Object, int>{
      for (int i = 0; i < tags.length; i++) tags[i].id: i,
    };
    final Object? focused = _focusedKey;
    if (focused != null && !_indexOf.containsKey(focused)) {
      // After a removal the focus moves to the tag that took its place, or
      // the new last tag.
      final int? removed = _removedIndex;
      _focusedKey = null;
      if (removed != null && tags.isNotEmpty) {
        final int start = removed.clamp(0, tags.length - 1);
        _focusedKey = _scan(start, 1) ?? _scan(start, -1);
      }
    }
    _removedIndex = null;
  }

  Set<Object> get _disabled {
    final _HeroTagGroupScope? group = _group;
    return <Object>{
      ...?group?.disabledKeys,
      for (final HeroTag tag in _tags)
        if (tag.isDisabled || (group?.isDisabled ?? false)) tag.id,
    };
  }

  bool _isEnabled(HeroTag tag) {
    final _HeroTagGroupScope? group = _group;
    return !tag.isDisabled &&
        !(group?.isDisabled ?? false) &&
        !(group?.disabledKeys.contains(tag.id) ?? false);
  }

  Object? _scan(int start, int delta) {
    for (int i = start; i >= 0 && i < _tags.length; i += delta) {
      if (_isEnabled(_tags[i])) return _tags[i].id;
    }
    return null;
  }

  Object? get _tabStop {
    final Object? focused = _focusedKey;
    if (focused != null) {
      final int? index = _indexOf[focused];
      if (index != null && _isEnabled(_tags[index])) return focused;
    }
    final Set<Object> selected = _group?.selectedKeys ?? const <Object>{};
    for (final HeroTag tag in _tags) {
      if (_isEnabled(tag) && selected.contains(tag.id)) return tag.id;
    }
    return _scan(0, 1);
  }

  void _setFocusedKey(Object? key) {
    if (key == _focusedKey) return;
    setState(() => _focusedKey = key);
  }

  void _handleFocusChange(bool focused) {
    if (focused == _hasFocus) return;
    setState(() {
      _hasFocus = focused;
      if (focused) _focusedKey = _tabStop;
    });
  }

  void _focusFromPointer(Object id) {
    final int? index = _indexOf[id];
    if (index == null || !_isEnabled(_tags[index])) return;
    _typeahead.reset();
    _setFocusedKey(id);
    if (!_node.hasFocus) _node.requestFocus();
  }

  void _press(Object id) {
    final int? index = _indexOf[id];
    if (index == null || !_isEnabled(_tags[index])) return;
    _group?.state.toggle(id, _disabled);
  }

  void _remove(Object id) {
    final int? index = _indexOf[id];
    if (index == null || !_isEnabled(_tags[index])) return;
    _removedIndex = index;
    _group?.state.remove(<Object>{id});
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final _HeroTagGroupScope? group = _group;
    if (group == null) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    final HardwareKeyboard keyboard = HardwareKeyboard.instance;
    final bool command = keyboard.isControlPressed || keyboard.isMetaPressed;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final Object? focused = _focusedKey;
    final int? index = focused == null ? null : _indexOf[focused];

    int? delta;
    if (key == LogicalKeyboardKey.arrowRight) {
      delta = rtl ? -1 : 1;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      delta = rtl ? 1 : -1;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      delta = 1;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      delta = -1;
    }
    if (delta != null) {
      final Object? target = index == null
          ? _scan(delta > 0 ? 0 : _tags.length - 1, delta)
          : _scan(index + delta, delta);
      _typeahead.reset();
      if (target != null) _setFocusedKey(target);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home || key == LogicalKeyboardKey.end) {
      final Object? target = key == LogicalKeyboardKey.home
          ? _scan(0, 1)
          : _scan(_tags.length - 1, -1);
      if (target != null) _setFocusedKey(target);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        (key == LogicalKeyboardKey.space && !_typeahead.isActive)) {
      if (focused == null || event is KeyRepeatEvent) {
        return KeyEventResult.handled;
      }
      _press(focused);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      if (!group.allowsRemoving || focused == null || index == null) {
        return KeyEventResult.ignored;
      }
      if (!_isEnabled(_tags[index])) return KeyEventResult.handled;
      _removedIndex = index;
      group.state.removeFromKeyboard(focused);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyA &&
        command &&
        group.selectionMode == HeroSelectionMode.multiple) {
      group.state.selectAll(<Object>[
        for (final HeroTag tag in _tags) tag.id,
      ], _disabled);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      return group.state.clear(_disabled)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    final String? character = event.character;
    if (character == null ||
        character.isEmpty ||
        command ||
        keyboard.isAltPressed ||
        character.runes.any((int r) => r < 0x20 || r == 0x7f)) {
      return KeyEventResult.ignored;
    }
    final Object? match = _typeahead.search(character, <HeroTypeaheadEntry>[
      for (final HeroTag tag in _tags)
        (
          key: tag.id,
          text: tag.effectiveTextValue,
          isDisabled: !_isEnabled(tag),
        ),
    ], from: focused);
    if (match != null) _setFocusedKey(match);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroTagGroupScope? group = _HeroTagGroupScope.maybeOf(context);
    final double spacing = widget.spacing ?? theme.spacing(1.5);
    final bool disabled = group?.isDisabled ?? false;
    final WidgetBuilder? emptyStateBuilder = widget.emptyStateBuilder;

    Widget content = _tags.isEmpty && emptyStateBuilder != null
        ? emptyStateBuilder(context)
        : Wrap(
            spacing: spacing,
            runSpacing: spacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _children,
          );
    content = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.list,
      label: group?.semanticLabel,
      child: content,
    );
    content = Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      canRequestFocus: !disabled && _tags.isNotEmpty,
      skipTraversal: disabled || _tags.isEmpty,
      includeSemantics: false,
      onFocusChange: _handleFocusChange,
      onKeyEvent: _handleKey,
      child: content,
    );
    return _HeroTagListScope(
      state: this,
      focusedKey: _hasFocus ? _focusedKey : null,
      isFocusVisible: _highlight,
      child: content,
    );
  }
}

class _HeroTagListScope extends InheritedWidget {
  const _HeroTagListScope({
    required this.state,
    required this.focusedKey,
    required this.isFocusVisible,
    required super.child,
  });

  final _HeroTagGroupListState state;
  final Object? focusedKey;
  final bool isFocusVisible;

  static _HeroTagListScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroTagListScope>();

  @override
  bool updateShouldNotify(_HeroTagListScope oldWidget) =>
      focusedKey != oldWidget.focusedKey ||
      isFocusVisible != oldWidget.isFocusVisible;
}
