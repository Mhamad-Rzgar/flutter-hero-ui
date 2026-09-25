/// HeroUI's Toolbar: a container for interactive controls with arrow key
/// navigation.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../separator/separator.dart';
import 'toolbar_scope.dart';

export 'toolbar_scope.dart';

/// Builds the children of a [HeroToolbar] for its orientation (HeroUI's
/// render-prop children).
typedef HeroToolbarChildrenBuilder =
    List<Widget> Function(BuildContext context, Axis orientation);

/// A container for interactive controls with arrow key navigation (HeroUI
/// `Toolbar`).
///
/// ```dart
/// HeroToolbar(
///   semanticLabel: 'Text formatting',
///   children: <Widget>[
///     HeroToggleButtonGroup(
///       selectionMode: HeroSelectionMode.multiple,
///       children: const <Widget>[
///         HeroToggleButton(
///           id: 'bold',
///           isIconOnly: true,
///           semanticLabel: 'Bold',
///           child: HeroIcon(HeroIcons.bold),
///         ),
///         HeroToggleButton(
///           id: 'italic',
///           isIconOnly: true,
///           semanticLabel: 'Italic',
///           separator: HeroToggleButtonGroupSeparator(),
///           child: HeroIcon(HeroIcons.italic),
///         ),
///       ],
///     ),
///     const HeroSeparator(),
///     HeroButtonGroup(
///       variant: HeroButtonVariant.tertiary,
///       children: <Widget>[
///         HeroButton(isIconOnly: true, semanticLabel: 'Copy', child: const HeroIcon(HeroIcons.copy)),
///         const HeroButtonGroupSeparator(),
///         HeroButton(isIconOnly: true, semanticLabel: 'Cut', child: const HeroIcon(HeroIcons.scissors)),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// The toolbar sizes to its content (`w-fit`) and lays its children out in
/// a row (a column when [orientation] is vertical) with an 8 px gap,
/// centered across the row (at the start across a column). Toggle button
/// groups and button groups inside take its orientation, and
/// [HeroSeparator]s turn perpendicular to it and cover half of its
/// thickness, centered. [isAttached] puts the controls on a `--surface`
/// pill (radius 24, 4 px padding, the overlay shadow).
///
/// Keyboard: the toolbar is a single Tab stop that remembers the control
/// focused last. Left / Right (Up / Down when vertical) move the focus to
/// the previous or next control on screen, without wrapping; Home and End
/// move to the first and last control.
class HeroToolbar extends StatefulWidget {
  /// Creates a toolbar.
  const HeroToolbar({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.orientation = Axis.horizontal,
    this.isAttached = false,
    this.gap,
    this.padding,
    this.decoration,
    this.semanticLabel,
  });

  /// The controls, groups and separators.
  final List<Widget> children;

  /// Builds the children for the orientation; replaces [children].
  final HeroToolbarChildrenBuilder? builder;

  /// Whether the controls run horizontally or vertically.
  final Axis orientation;

  /// Whether the controls sit on a surface pill with the overlay shadow.
  final bool isAttached;

  /// Space between the children (`gap-*`); defaults to 8.
  final double? gap;

  /// Padding around the children (`p-*`); defaults to 4 when attached.
  final EdgeInsetsGeometry? padding;

  /// Replaces the background (the attached pill), for custom styles.
  final Decoration? decoration;

  /// Accessibility label (`aria-label`).
  final String? semanticLabel;

  @override
  State<HeroToolbar> createState() => _HeroToolbarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<Axis>(
          'orientation',
          orientation,
          defaultValue: Axis.horizontal,
        ),
      )
      ..add(FlagProperty('isAttached', value: isAttached, ifTrue: 'attached'))
      ..add(DoubleProperty('gap', gap, defaultValue: null))
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null));
  }
}

class _HeroToolbarState extends State<HeroToolbar> {
  final FocusNode _node = FocusNode(
    debugLabel: 'HeroToolbar',
    canRequestFocus: false,
    skipTraversal: true,
  );

  /// The control focused last: the toolbar's Tab stop.
  FocusNode? _lastFocused;

  late final _HeroToolbarTraversalPolicy _policy = _HeroToolbarTraversalPolicy(
    this,
  );

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_handleFocusChange);
    _node.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary.ancestors.contains(_node)) {
      _lastFocused = primary;
    }
  }

  /// The focusable controls in on-screen order along the toolbar.
  List<FocusNode> _items() {
    final bool horizontal = widget.orientation == Axis.horizontal;
    final List<FocusNode> items = <FocusNode>[
      for (final FocusNode node in _node.descendants)
        if (node.canRequestFocus && (node.context?.mounted ?? false)) node,
    ];
    double along(FocusNode node) =>
        horizontal ? node.rect.center.dx : node.rect.center.dy;
    mergeSort<FocusNode>(
      items,
      compare: (FocusNode a, FocusNode b) => along(a).compareTo(along(b)),
    );
    return items;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    final bool horizontal = widget.orientation == Axis.horizontal;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final LogicalKeyboardKey next = horizontal
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowDown;
    final LogicalKeyboardKey previous = horizontal
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowUp;
    if (key != next &&
        key != previous &&
        key != LogicalKeyboardKey.home &&
        key != LogicalKeyboardKey.end) {
      return KeyEventResult.ignored;
    }
    final List<FocusNode> items = _items();
    final int index = items.indexOf(FocusManager.instance.primaryFocus!);
    if (index < 0) return KeyEventResult.ignored;
    // Home and End follow the reading order: the first control of a
    // right-to-left row is its rightmost one.
    final bool mirrored = horizontal && rtl;
    final FocusNode? target = switch (key) {
      LogicalKeyboardKey.home => mirrored ? items.last : items.first,
      LogicalKeyboardKey.end => mirrored ? items.first : items.last,
      _ when key == next => index + 1 < items.length ? items[index + 1] : null,
      _ => index > 0 ? items[index - 1] : null,
    };
    target?.requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Axis orientation = widget.orientation;
    final bool horizontal = orientation == Axis.horizontal;
    final List<Widget> children =
        widget.builder?.call(context, orientation) ?? widget.children;
    final double gap = widget.gap ?? theme.spacing(2);

    // Rows are as tall as their tallest control (and columns as wide as
    // their widest) so separators can cover half of it, like the grid row
    // of HeroUI's toolbar.
    Widget result = horizontal
        ? IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: gap,
              children: children,
            ),
          )
        : IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: gap,
              children: <Widget>[
                for (final Widget child in children)
                  // `justify-self-center` for separators.
                  if (child is HeroSeparator) Align(child: child) else child,
              ],
            ),
          );

    result = HeroSeparatorScope(
      orientation: horizontal ? Axis.vertical : Axis.horizontal,
      lengthFactor: 0.5,
      child: HeroToolbarScope(orientation: orientation, child: result),
    );

    result = FocusTraversalGroup(
      policy: _policy,
      child: Focus(
        focusNode: _node,
        includeSemantics: false,
        onKeyEvent: _handleKey,
        child: result,
      ),
    );

    final EdgeInsetsGeometry? padding =
        widget.padding ??
        (widget.isAttached ? EdgeInsets.all(theme.spacing(1)) : null);
    if (padding != null) result = Padding(padding: padding, child: result);

    final Decoration? decoration =
        widget.decoration ?? (widget.isAttached ? _attached(theme) : null);
    if (decoration != null) {
      result = DecoratedBox(decoration: decoration, child: result);
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: result,
    );
  }

  /// `rounded-3xl bg-surface shadow-overlay`; the dark overlay shadow is an
  /// inset hairline.
  static Decoration _attached(HeroThemeData theme) {
    final HeroShadow shadow = theme.shadows.overlay;
    final Color? inset = shadow.insetColor;
    return ShapeDecoration(
      color: theme.colors.surface,
      shape: theme.shapeAll(
        theme.radii.xl3,
        side: inset == null
            ? BorderSide.none
            : BorderSide(
                color: inset.withValues(alpha: inset.a * 0.5),
                width: theme.spacing(0.25),
              ),
      ),
      shadows: shadow.boxShadows,
    );
  }
}

/// Makes a toolbar a single Tab stop: only the focused control (or the one
/// focused last, or the first) takes part in Tab traversal; the arrow keys
/// reach the others.
class _HeroToolbarTraversalPolicy extends ReadingOrderTraversalPolicy {
  _HeroToolbarTraversalPolicy(this._toolbar);

  final _HeroToolbarState _toolbar;

  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) {
    final List<FocusNode> sorted = super
        .sortDescendants(descendants, currentNode)
        .toList();
    if (sorted.isEmpty || sorted.contains(currentNode)) {
      return sorted.isEmpty ? sorted : <FocusNode>[currentNode];
    }
    final FocusNode? last = _toolbar._lastFocused;
    if (last != null && sorted.contains(last)) return <FocusNode>[last];
    return <FocusNode>[sorted.first];
  }
}
