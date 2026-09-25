/// HeroUI's DisclosureGroup: coordinates the expanded state of several
/// disclosures.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../disclosure/disclosure.dart';

/// Builds the content of a [HeroDisclosureGroup] from its state (HeroUI's
/// render-function children).
typedef HeroDisclosureGroupWidgetBuilder =
    Widget Function(
      BuildContext context,
      Set<Object> expandedKeys,
      bool isDisabled,
    );

/// HeroUI's DisclosureGroup: a container that manages several
/// [HeroDisclosure]s with coordinated expanded states.
///
/// Give every disclosure an `id`; the group expands them by id. Expanding
/// one collapses the others unless [allowsMultipleExpanded]. Expansion is
/// controlled ([expandedKeys] + [onExpandedChanged]) or uncontrolled
/// ([defaultExpandedKeys]), and [isDisabled] disables every disclosure.
///
/// ```dart
/// HeroDisclosureGroup(
///   defaultExpandedKeys: const <Object>{'preview'},
///   children: <Widget>[
///     HeroDisclosure(id: 'preview', children: previewParts),
///     const HeroSeparator(margin: EdgeInsets.symmetric(vertical: 8)),
///     HeroDisclosure(id: 'download', children: downloadParts),
///   ],
/// )
/// ```
///
/// The group fills the available width and lays its children out in a
/// column; it has no look of its own.
class HeroDisclosureGroup extends StatefulWidget {
  /// Creates a disclosure group.
  const HeroDisclosureGroup({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.expandedKeys,
    this.defaultExpandedKeys,
    this.onExpandedChanged,
    this.allowsMultipleExpanded = false,
    this.isDisabled = false,
  });

  /// The disclosures, and anything between them (separators).
  final List<Widget> children;

  /// Builds the content from the expanded ids and the disabled state;
  /// replaces [children].
  final HeroDisclosureGroupWidgetBuilder? builder;

  /// Controlled expansion: the ids of the expanded disclosures.
  final Set<Object>? expandedKeys;

  /// Initial expansion when uncontrolled.
  final Set<Object>? defaultExpandedKeys;

  /// Called with the ids of the expanded disclosures when they change.
  final ValueChanged<Set<Object>>? onExpandedChanged;

  /// Whether several disclosures can be expanded at once.
  final bool allowsMultipleExpanded;

  /// Disables every disclosure.
  final bool isDisabled;

  @override
  State<HeroDisclosureGroup> createState() => _HeroDisclosureGroupState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        IterableProperty<Object>(
          'expandedKeys',
          expandedKeys,
          defaultValue: null,
        ),
      )
      ..add(
        FlagProperty(
          'allowsMultipleExpanded',
          value: allowsMultipleExpanded,
          ifTrue: 'multiple',
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroDisclosureGroupState extends State<HeroDisclosureGroup> {
  late Set<Object> _expanded = <Object>{...?widget.defaultExpandedKeys};

  Set<Object> get _effectiveExpanded => widget.expandedKeys ?? _expanded;

  void _toggle(Object id) {
    if (widget.isDisabled) return;
    final Set<Object> current = _effectiveExpanded;
    final Set<Object> next;
    if (current.contains(id)) {
      next = <Object>{...current}..remove(id);
    } else if (widget.allowsMultipleExpanded) {
      next = <Object>{...current, id};
    } else {
      next = <Object>{id};
    }
    if (widget.expandedKeys == null) setState(() => _expanded = next);
    widget.onExpandedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final Set<Object> expanded = _effectiveExpanded;
    final HeroDisclosureGroupWidgetBuilder? builder = widget.builder;
    return HeroDisclosureGroupScope(
      expandedKeys: expanded,
      isDisabled: widget.isDisabled,
      onToggle: _toggle,
      child: builder != null
          ? Builder(
              builder: (BuildContext context) =>
                  builder(context, expanded, widget.isDisabled),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children,
            ),
    );
  }
}

/// Shares the state of a [HeroDisclosureGroup] with its [HeroDisclosure]s
/// (React Aria's `DisclosureGroupStateContext`).
///
/// Disclosures read it to know whether their id is expanded and report
/// toggles through [onToggle]; custom disclosure-like widgets can do the
/// same.
class HeroDisclosureGroupScope extends InheritedWidget {
  /// Publishes a group state to [child].
  const HeroDisclosureGroupScope({
    super.key,
    required this.expandedKeys,
    required this.isDisabled,
    required this.onToggle,
    required super.child,
  });

  /// The ids of the expanded disclosures.
  final Set<Object> expandedKeys;

  /// Whether every disclosure of the group is disabled.
  final bool isDisabled;

  /// Expands or collapses the disclosure with the given id.
  final ValueChanged<Object> onToggle;

  /// The closest group scope, or null outside a group.
  static HeroDisclosureGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroDisclosureGroupScope>();

  @override
  bool updateShouldNotify(HeroDisclosureGroupScope oldWidget) =>
      !setEquals(expandedKeys, oldWidget.expandedKeys) ||
      isDisabled != oldWidget.isDisabled ||
      onToggle != oldWidget.onToggle;
}

/// Previous / next navigation through the items of a disclosure group or
/// accordion (HeroUI's `useDisclosureGroupNavigation`).
///
/// The current item is the first expanded one in [itemIds] order, else the
/// first item. [previous] and [next] expand the neighbouring item (adding it
/// when [allowsMultipleExpanded], replacing the expansion otherwise) through
/// [onExpandedChanged].
///
/// ```dart
/// final HeroDisclosureGroupNavigation navigation =
///     HeroDisclosureGroupNavigation(
///       expandedKeys: expandedKeys,
///       itemIds: const <Object>['preview', 'download'],
///       onExpandedChanged: (Set<Object> keys) =>
///           setState(() => expandedKeys = keys),
///     );
///
/// HeroButton(
///   isDisabled: navigation.isNextDisabled,
///   onPressed: navigation.next,
///   child: const Text('Next'),
/// )
/// ```
@immutable
class HeroDisclosureGroupNavigation {
  /// Creates a navigation helper.
  const HeroDisclosureGroupNavigation({
    required this.expandedKeys,
    required this.itemIds,
    required this.onExpandedChanged,
    this.allowsMultipleExpanded = false,
  });

  /// The currently expanded ids.
  final Set<Object> expandedKeys;

  /// The ids of the items, in order.
  final List<Object> itemIds;

  /// Called with the new expanded ids.
  final ValueChanged<Set<Object>> onExpandedChanged;

  /// Whether navigating adds to the expansion instead of replacing it.
  final bool allowsMultipleExpanded;

  /// Index of the current item in [itemIds], or -1 without items.
  int get currentIndex {
    if (itemIds.isEmpty) return -1;
    final int expanded = itemIds.indexWhere(expandedKeys.contains);
    return expanded < 0 ? 0 : expanded;
  }

  /// Whether there is no previous item.
  bool get isPrevDisabled => currentIndex <= 0;

  /// Whether there is no next item.
  bool get isNextDisabled => currentIndex >= itemIds.length - 1;

  /// Expands the previous item.
  void previous() => _go(currentIndex - 1);

  /// Expands the next item.
  void next() => _go(currentIndex + 1);

  void _go(int index) {
    if (index < 0 || index >= itemIds.length || currentIndex < 0) return;
    final Object id = itemIds[index];
    onExpandedChanged(
      allowsMultipleExpanded ? <Object>{...expandedKeys, id} : <Object>{id},
    );
  }
}
