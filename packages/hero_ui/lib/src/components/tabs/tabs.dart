import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

part 'tabs_indicator.dart';
part 'tabs_layout.dart';

/// The look of [HeroTabs] (the `variant` prop).
enum HeroTabsVariant {
  /// A pill-shaped list with a raised indicator behind the selected tab.
  primary,

  /// A flat list with a 1 px rule and a 2 px accent line under (or beside)
  /// the selected tab.
  secondary,
}

/// Alignment of the content inside each [HeroTab] (the `align` prop).
enum HeroTabsAlign {
  /// Content starts at the leading edge.
  start,

  /// Content is centered (the default).
  center,

  /// Content ends at the trailing edge.
  end,
}

/// Whether arrow-key focus also selects tabs (React Aria's
/// `keyboardActivation`).
enum HeroTabsKeyboardActivation {
  /// Moving the focus selects the tab.
  automatic,

  /// Moving the focus does not select; Enter or Space does.
  manual,
}

/// The render state handed to [HeroTab.builder]: selected, hovered,
/// pressed, focused, focus-visible and disabled.
typedef HeroTabState = HeroInteractionState;

/// Builds the content of a [HeroTab] for its current state.
typedef HeroTabWidgetBuilder =
    Widget Function(BuildContext context, HeroTabState state);

/// Optional style overrides for a [HeroTab], the counterpart of customising
/// `.tabs__tab` with utilities. `null` values keep HeroUI's look; colors are
/// resolved with the tab's [WidgetState]s (`hovered`, `pressed`, `focused`,
/// `disabled`, `selected`).
@immutable
class HeroTabStyle {
  /// Creates a tab style override.
  const HeroTabStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.opacity,
    this.borderRadius,
  });

  /// Fill of the tab itself, painted below the indicator.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Text and icon color.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Opacity of an enabled tab (HeroUI fades hovered tabs to 0.7).
  final WidgetStateProperty<double?>? opacity;

  /// Corner radii of the tab (its focus ring and fill).
  final BorderRadiusGeometry? borderRadius;
}

/// HeroUI's Tabs: organizes content into sections and lets users switch
/// between them.
///
/// Compose it from a [HeroTabListContainer] holding a [HeroTabList] of
/// [HeroTab]s, followed by one [HeroTabPanel] per tab. Tabs and panels are
/// matched by `id`. Selection is controlled ([selectedKey] +
/// [onSelectionChanged]) or uncontrolled ([defaultSelectedKey], else the
/// first enabled tab).
///
/// ```dart
/// HeroTabs(
///   children: <Widget>[
///     HeroTabListContainer(
///       child: HeroTabList(
///         semanticLabel: 'Options',
///         children: const <Widget>[
///           HeroTab(id: 'overview', child: Text('Overview')),
///           HeroTab(id: 'analytics', child: Text('Analytics')),
///         ],
///       ),
///     ),
///     const HeroTabPanel(id: 'overview', child: Text('Overview panel')),
///     const HeroTabPanel(id: 'analytics', child: Text('Analytics panel')),
///   ],
/// )
/// ```
///
/// Keyboard: the tab list is one Tab stop (the selected tab). Arrow keys
/// (Left/Right when horizontal, flipped in right-to-left layouts; Up/Down
/// when vertical) move between tabs and wrap around, Home and End jump to
/// the first and last tab, and disabled tabs are skipped. With
/// [HeroTabsKeyboardActivation.automatic] the focused tab is selected.
class HeroTabs extends StatefulWidget {
  /// Creates tabs.
  const HeroTabs({
    super.key,
    required this.children,
    this.variant = HeroTabsVariant.primary,
    this.orientation = Axis.horizontal,
    this.align = HeroTabsAlign.center,
    this.selectedKey,
    this.defaultSelectedKey,
    this.onSelectionChanged,
    this.disabledKeys = const <Object>{},
    this.isDisabled = false,
    this.keyboardActivation = HeroTabsKeyboardActivation.automatic,
  });

  /// The tab list (usually a [HeroTabListContainer]) and the
  /// [HeroTabPanel]s.
  final List<Widget> children;

  /// Primary (pill) or secondary (underline) look.
  final HeroTabsVariant variant;

  /// Tabs above the panels ([Axis.horizontal]) or beside them
  /// ([Axis.vertical]).
  final Axis orientation;

  /// Alignment of the content inside each tab.
  final HeroTabsAlign align;

  /// Controlled selection: the id of the selected tab.
  final Object? selectedKey;

  /// Initial selection when uncontrolled; defaults to the first enabled tab.
  final Object? defaultSelectedKey;

  /// Called with the id of the newly selected tab.
  final ValueChanged<Object>? onSelectionChanged;

  /// Ids of tabs that cannot be selected.
  final Set<Object> disabledKeys;

  /// Disables every tab.
  final bool isDisabled;

  /// Whether keyboard focus selects tabs.
  final HeroTabsKeyboardActivation keyboardActivation;

  @override
  State<HeroTabs> createState() => _HeroTabsState();
}

class _TabEntry {
  _TabEntry(this.id, this.node, this.isDisabled);

  final Object id;
  final FocusNode node;
  final bool isDisabled;
}

class _HeroTabsState extends State<HeroTabs> {
  Object? _selected;
  Object? _lastFocused;
  Object? _broadcast;
  int _version = 0;
  bool _reconcileScheduled = false;
  final SplayTreeMap<int, _TabEntry> _tabs = SplayTreeMap<int, _TabEntry>();

  @override
  void initState() {
    super.initState();
    _selected = widget.defaultSelectedKey;
  }

  _TabEntry? _entryFor(Object id) {
    for (final _TabEntry entry in _tabs.values) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  bool isKeyDisabled(Object id) =>
      widget.isDisabled ||
      widget.disabledKeys.contains(id) ||
      (_entryFor(id)?.isDisabled ?? false);

  Object? get _firstEnabledKey {
    for (final _TabEntry entry in _tabs.values) {
      if (!isKeyDisabled(entry.id)) return entry.id;
    }
    return null;
  }

  /// The selected tab, resolved live so tabs registering during the first
  /// build agree on the default selection.
  Object? get selectedKey =>
      widget.selectedKey ?? _selected ?? _firstEnabledKey;

  Object? keyAt(int index) => _tabs[index]?.id;

  void select(Object id) {
    if (isKeyDisabled(id) || id == selectedKey) return;
    if (widget.selectedKey == null) setState(() => _selected = id);
    widget.onSelectionChanged?.call(id);
  }

  bool isTabStop(Object id) {
    Object? stop =
        widget.keyboardActivation == HeroTabsKeyboardActivation.manual
        ? (_lastFocused ?? selectedKey)
        : selectedKey;
    if (stop == null || isKeyDisabled(stop)) stop = _firstEnabledKey;
    return stop == id;
  }

  void tabFocused(Object id) {
    _lastFocused = id;
    if (widget.keyboardActivation == HeroTabsKeyboardActivation.automatic) {
      select(id);
    }
  }

  void registerTab(int index, _TabEntry entry) {
    _tabs[index] = entry;
    _scheduleReconcile();
  }

  void unregisterTab(int index, _TabEntry entry) {
    if (identical(_tabs[index], entry)) _tabs.remove(index);
    _scheduleReconcile();
  }

  // Tabs register while the tree builds; once the frame is done, rebuild if
  // the resolved selection differs from what the scope announced.
  void _scheduleReconcile() {
    if (_reconcileScheduled) return;
    _reconcileScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _reconcileScheduled = false;
      if (mounted && selectedKey != _broadcast) setState(() {});
    }, debugLabel: 'HeroTabs.reconcile');
  }

  KeyEventResult handleListKey(BuildContext listContext, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final List<_TabEntry> entries = _tabs.values.toList();
    final int current = entries.indexWhere(
      (_TabEntry e) => e.node.hasPrimaryFocus,
    );
    if (current < 0) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    final bool rtl = Directionality.of(listContext) == TextDirection.rtl;
    bool enabled(int i) =>
        !isKeyDisabled(entries[i].id) && entries[i].node.canRequestFocus;

    int? target;
    if (key == LogicalKeyboardKey.home) {
      for (int i = 0; i < entries.length && target == null; i++) {
        if (enabled(i)) target = i;
      }
    } else if (key == LogicalKeyboardKey.end) {
      for (int i = entries.length - 1; i >= 0 && target == null; i--) {
        if (enabled(i)) target = i;
      }
    } else {
      final int? delta = switch (widget.orientation) {
        Axis.horizontal when key == LogicalKeyboardKey.arrowRight =>
          rtl ? -1 : 1,
        Axis.horizontal when key == LogicalKeyboardKey.arrowLeft =>
          rtl ? 1 : -1,
        Axis.vertical when key == LogicalKeyboardKey.arrowDown => 1,
        Axis.vertical when key == LogicalKeyboardKey.arrowUp => -1,
        _ => null,
      };
      if (delta == null) return KeyEventResult.ignored;
      // React Aria's tabs keyboard delegate wraps around.
      for (int step = 1; step <= entries.length && target == null; step++) {
        final int i = (current + delta * step) % entries.length;
        if (enabled(i)) target = i;
      }
    }
    if (target != null && target != current) {
      entries[target].node.requestFocus();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    _version++;
    _broadcast = selectedKey;
    final List<Widget> panels = <Widget>[];
    final List<Widget> others = <Widget>[];
    for (final Widget child in widget.children) {
      (child is HeroTabPanel ? panels : others).add(child);
    }
    final Widget content = widget.orientation == Axis.horizontal
        ? _TabsRootLayout(axis: Axis.horizontal, children: widget.children)
        : _TabsRootLayout(
            axis: Axis.vertical,
            children: <Widget>[
              if (others.length == 1)
                others.single
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: others,
                ),
              if (panels.isNotEmpty)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: panels,
                ),
            ],
          );
    return _HeroTabsScope(
      state: this,
      version: _version,
      variant: widget.variant,
      orientation: widget.orientation,
      align: widget.align,
      child: content,
    );
  }
}

class _HeroTabsScope extends InheritedWidget {
  const _HeroTabsScope({
    required this.state,
    required this.version,
    required this.variant,
    required this.orientation,
    required this.align,
    required super.child,
  });

  final _HeroTabsState state;
  final int version;
  final HeroTabsVariant variant;
  final Axis orientation;
  final HeroTabsAlign align;

  bool get isSecondary => variant == HeroTabsVariant.secondary;

  static _HeroTabsScope of(BuildContext context) {
    final _HeroTabsScope? scope = context
        .dependOnInheritedWidgetOfExactType<_HeroTabsScope>();
    assert(scope != null, 'Tabs parts must be placed inside HeroTabs.');
    return scope!;
  }

  @override
  bool updateShouldNotify(_HeroTabsScope oldWidget) =>
      version != oldWidget.version ||
      variant != oldWidget.variant ||
      orientation != oldWidget.orientation ||
      align != oldWidget.align;
}

/// HeroUI's `Tabs.ListContainer`: the rounded `--default` track behind the
/// tab list, which also makes the list scroll with fading edges and
/// chevrons when the tabs overflow.
///
/// In the secondary variant it is transparent with a 1 px `--border` rule
/// below the list (beside it when vertical).
class HeroTabListContainer extends StatelessWidget {
  /// Creates a list container around a [HeroTabList].
  const HeroTabListContainer({super.key, required this.child, this.decoration});

  /// The [HeroTabList].
  final Widget child;

  /// Replaces the container's decoration (for custom looks).
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroTabsScope tabs = _HeroTabsScope.of(context);
    final bool horizontal = tabs.orientation == Axis.horizontal;
    Decoration? resolved = decoration;
    EdgeInsetsGeometry padding = EdgeInsets.zero;
    if (resolved == null) {
      if (tabs.isSecondary) {
        final BorderSide rule = BorderSide(
          color: theme.colors.border,
          width: theme.borderWidth,
        );
        resolved = ShapeDecoration(
          shape: horizontal
              ? Border(bottom: rule)
              : BorderDirectional(start: rule),
        );
        padding = horizontal
            ? EdgeInsets.only(bottom: theme.borderWidth)
            : EdgeInsetsDirectional.only(start: theme.borderWidth);
      } else {
        resolved = ShapeDecoration(
          color: theme.colors.defaultColor,
          // `calc(var(--radius) * 2.5)`.
          shape: theme.shapeAll(theme.radii.radius * 2.5),
        );
      }
    }
    return _HeroTabListContainerScope(
      child: DecoratedBox(
        decoration: resolved,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _HeroTabListContainerScope extends InheritedWidget {
  const _HeroTabListContainerScope({required super.child});

  static bool isContained(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_HeroTabListContainerScope>() !=
      null;

  @override
  bool updateShouldNotify(_HeroTabListContainerScope oldWidget) => false;
}

/// HeroUI's `Tabs.List`: the row (or column) of [HeroTab]s.
///
/// Horizontal lists are at least as wide as their container and share the
/// width between the tabs; inside a [HeroTabListContainer] they scroll when
/// the tabs do not fit. Vertical lists are as wide as their widest tab
/// (at least 80 px per tab) with a 4 px gap.
class HeroTabList extends StatefulWidget {
  /// Creates a tab list.
  const HeroTabList({super.key, required this.children, this.semanticLabel});

  /// The [HeroTab]s.
  final List<Widget> children;

  /// Accessibility label of the tab bar (`aria-label`).
  final String? semanticLabel;

  @override
  State<HeroTabList> createState() => _HeroTabListState();
}

class _HeroTabListState extends State<HeroTabList> {
  final _IndicatorCoordinator _coordinator = _IndicatorCoordinator();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroTabsScope tabs = _HeroTabsScope.of(context);
    final bool contained = _HeroTabListContainerScope.isContained(context);
    final bool horizontal = tabs.orientation == Axis.horizontal;
    final int count = widget.children.length;
    final List<Widget> items = <Widget>[
      for (int i = 0; i < count; i++)
        _HeroTabItemScope(index: i, child: widget.children[i]),
    ];

    Widget list = horizontal
        ? _TabRow(children: items)
        : IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: theme.spacing(1),
              children: <Widget>[
                for (final Widget item in items)
                  ConstrainedBox(
                    constraints: BoxConstraints(minWidth: theme.spacing(20)),
                    child: item,
                  ),
              ],
            ),
          );
    list = _IndicatorOrigin(coordinator: _coordinator, child: list);
    list = Padding(
      padding: EdgeInsets.all(
        contained && tabs.isSecondary ? 0 : theme.spacing(1),
      ),
      child: list,
    );
    list = Semantics(
      container: true,
      explicitChildNodes: true,
      role: SemanticsRole.tabBar,
      label: widget.semanticLabel,
      child: list,
    );
    list = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: (FocusNode node, KeyEvent event) =>
          tabs.state.handleListKey(context, event),
      child: list,
    );

    if (horizontal) {
      // `min-w-full`: the list is at least as wide as its container.
      final Widget content = list;
      list = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget minWidth = ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.hasBoundedWidth ? constraints.maxWidth : 0,
            ),
            child: content,
          );
          if (!contained) return minWidth;
          return _TabListScroller(
            controller: _scrollController,
            axis: Axis.horizontal,
            child: minWidth,
          );
        },
      );
    } else if (contained) {
      list = _TabListScroller(
        controller: _scrollController,
        axis: Axis.vertical,
        child: list,
      );
    }

    return _HeroTabListScope(
      coordinator: _coordinator,
      scrollController: contained ? _scrollController : null,
      child: list,
    );
  }
}

class _HeroTabListScope extends InheritedWidget {
  const _HeroTabListScope({
    required this.coordinator,
    required this.scrollController,
    required super.child,
  });

  final _IndicatorCoordinator coordinator;
  final ScrollController? scrollController;

  static _HeroTabListScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_HeroTabListScope>();

  @override
  bool updateShouldNotify(_HeroTabListScope oldWidget) =>
      coordinator != oldWidget.coordinator ||
      scrollController != oldWidget.scrollController;
}

class _HeroTabItemScope extends InheritedWidget {
  const _HeroTabItemScope({required this.index, required super.child});

  final int index;

  static _HeroTabItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroTabItemScope>();

  @override
  bool updateShouldNotify(_HeroTabItemScope oldWidget) =>
      index != oldWidget.index;
}

class _HeroTabScope extends InheritedWidget {
  const _HeroTabScope({
    required this.isSelected,
    required this.hideSeparator,
    required super.child,
  });

  final bool isSelected;
  final bool hideSeparator;

  static _HeroTabScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroTabScope>();

  @override
  bool updateShouldNotify(_HeroTabScope oldWidget) =>
      isSelected != oldWidget.isSelected ||
      hideSeparator != oldWidget.hideSeparator;
}

/// HeroUI's `Tabs.Tab`: one selectable tab.
///
/// The [indicator] (a [HeroTabIndicator] by default) marks the selected tab
/// and slides to the next selected tab. Add a [HeroTabSeparator] as
/// [separator] to every tab but the first for divider lines.
class HeroTab extends StatefulWidget {
  /// Creates a tab.
  const HeroTab({
    super.key,
    required this.id,
    this.child,
    this.builder,
    this.isDisabled = false,
    this.indicator = const HeroTabIndicator(),
    this.separator,
    this.style,
    this.focusNode,
    this.semanticLabel,
  });

  /// Identifies the tab and its [HeroTabPanel].
  final Object id;

  /// The label.
  final Widget? child;

  /// Builds the label for the current state instead of [child] (HeroUI's
  /// render function).
  final HeroTabWidgetBuilder? builder;

  /// Whether the tab cannot be selected.
  final bool isDisabled;

  /// The selection indicator shown while the tab is selected; `null` shows
  /// none.
  final Widget? indicator;

  /// A divider drawn on the leading edge (top edge when vertical), usually
  /// [HeroTabSeparator]. Hidden next to the selected tab.
  final Widget? separator;

  /// Style overrides.
  final HeroTabStyle? style;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Accessibility label; defaults to the label text.
  final String? semanticLabel;

  @override
  State<HeroTab> createState() => _HeroTabState();
}

class _HeroTabState extends State<HeroTab> {
  FocusNode? _internalNode;
  _HeroTabsScope? _tabs;
  _TabEntry? _entry;
  int? _index;

  FocusNode get _node =>
      widget.focusNode ?? (_internalNode ??= FocusNode(debugLabel: 'HeroTab'));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabs = _HeroTabsScope.of(context);
    _register(_HeroTabItemScope.maybeOf(context)?.index ?? 0);
  }

  @override
  void didUpdateWidget(HeroTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _register(_index ?? 0);
  }

  @override
  void dispose() {
    if (_entry != null) _tabs?.state.unregisterTab(_index!, _entry!);
    _internalNode?.dispose();
    super.dispose();
  }

  void _register(int index) {
    final _TabEntry? old = _entry;
    if (old != null &&
        _index == index &&
        old.id == widget.id &&
        old.node == _node &&
        old.isDisabled == widget.isDisabled) {
      return;
    }
    if (old != null) _tabs!.state.unregisterTab(_index!, old);
    _index = index;
    _entry = _TabEntry(widget.id, _node, widget.isDisabled);
    _tabs!.state.registerTab(index, _entry!);
  }

  void _handleFocusChanged(bool focused) {
    if (!focused) return;
    _tabs?.state.tabFocused(widget.id);
    _reveal();
  }

  // Scrolls an overflowing list so the focused tab is fully visible, like a
  // browser does when an element receives focus.
  void _reveal() {
    final ScrollController? controller = _HeroTabListScope.maybeOf(
      context,
    )?.scrollController;
    final RenderObject? object = context.findRenderObject();
    if (controller == null || !controller.hasClients || object == null) return;
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
      object,
    );
    if (viewport == null) return;
    final ScrollPosition position = controller.position;
    final double toStart = viewport.getOffsetToReveal(object, 0).offset;
    final double toEnd = viewport.getOffsetToReveal(object, 1).offset;
    double target = position.pixels;
    if (target > toStart) {
      target = toStart;
    } else if (target < toEnd) {
      target = toEnd;
    }
    target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    if (target == position.pixels) return;
    final Duration duration = HeroTheme.of(
      context,
    ).motion.resolve(context, HeroMotion.slow);
    if (duration == Duration.zero) {
      position.jumpTo(target);
    } else {
      position.animateTo(
        target,
        duration: duration,
        curve: HeroMotion.easeOutFluid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _HeroTabsScope tabs = _HeroTabsScope.of(context);
    final _HeroTabsState state = tabs.state;
    final Object? selectedKey = state.selectedKey;
    final bool selected = selectedKey == widget.id;
    final bool disabled = state.isKeyDisabled(widget.id);
    final int index = _index ?? 0;
    final bool previousSelected =
        index > 0 &&
        selectedKey != null &&
        state.keyAt(index - 1) == selectedKey;
    // Roving focus: only the selected tab takes part in Tab traversal.
    _node.skipTraversal = !state.isTabStop(widget.id);

    return _HeroTabScope(
      isSelected: selected,
      hideSeparator: selected || previousSelected,
      child: HeroInteractable(
        onPressed: () => state.select(widget.id),
        isDisabled: disabled,
        isButton: false,
        focusNode: _node,
        semanticsLabel: widget.semanticLabel,
        onFocusChanged: _handleFocusChanged,
        builder: (BuildContext context, HeroInteractionState interaction, _) {
          return Semantics(
            role: SemanticsRole.tab,
            selected: selected,
            child: _HeroTabBody(
              tab: widget,
              tabs: tabs,
              state: interaction.copyWith(isSelected: selected),
            ),
          );
        },
      ),
    );
  }
}

class _HeroTabBody extends StatelessWidget {
  const _HeroTabBody({
    required this.tab,
    required this.tabs,
    required this.state,
  });

  final HeroTab tab;
  final _HeroTabsScope tabs;
  final HeroInteractionState state;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final HeroTabStyle? style = tab.style;
    final Set<WidgetState> states = state.widgetStates;
    final bool secondary = tabs.isSecondary;
    final Duration duration = theme.motion.resolve(context, HeroMotion.normal);

    final Color foreground =
        style?.foregroundColor?.resolve(states) ??
        (state.isSelected
            ? (secondary ? colors.foreground : colors.segmentForeground)
            : colors.muted);
    final Color? background = style?.backgroundColor?.resolve(states);
    final double opacity = state.isDisabled
        ? theme.disabledOpacity
        : (style?.opacity?.resolve(states) ??
              (state.isHovered && !state.isSelected ? 0.7 : 1));
    final OutlinedBorder shape = theme.shape(
      style?.borderRadius ??
          (secondary
              ? BorderRadius.zero
              : BorderRadius.all(Radius.circular(theme.radii.xl3))),
    );
    final (
      AlignmentGeometry alignment,
      TextAlign textAlign,
    ) = switch (tabs.align) {
      HeroTabsAlign.start => (
        AlignmentDirectional.centerStart,
        TextAlign.start,
      ),
      HeroTabsAlign.center => (Alignment.center, TextAlign.center),
      HeroTabsAlign.end => (AlignmentDirectional.centerEnd, TextAlign.end),
    };

    final Widget label =
        tab.builder?.call(context, state) ??
        tab.child ??
        const SizedBox.shrink();
    Widget content = AnimatedDefaultTextStyle(
      duration: duration,
      curve: HeroMotion.smooth,
      style: theme.typography
          .style(HeroFontSize.sm, weight: HeroTypography.medium)
          .copyWith(color: foreground),
      textAlign: textAlign,
      child: IconTheme.merge(
        data: IconThemeData(color: foreground, size: theme.spacing(4)),
        child: label,
      ),
    );
    content = Container(
      constraints: BoxConstraints(minHeight: theme.spacing(8)),
      padding: EdgeInsetsDirectional.symmetric(horizontal: theme.spacing(4)),
      alignment: alignment,
      child: content,
    );

    Widget result = Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: <Widget>[
        // The indicator sits behind the label (`z-index: -1`).
        if (tab.indicator != null)
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(child: tab.indicator!),
            ),
          ),
        content,
        if (tab.separator != null && !secondary)
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(child: tab.separator!),
            ),
          ),
      ],
    );
    if (background != null || style?.backgroundColor != null) {
      result = AnimatedContainer(
        duration: duration,
        curve: HeroMotion.smooth,
        decoration: ShapeDecoration(
          color: background ?? colors.defaultColor.withValues(alpha: 0),
          shape: shape,
        ),
        child: result,
      );
    }
    result = HeroFocusRing(
      visible: state.isFocusVisible,
      shape: shape,
      child: result,
    );
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      curve: HeroMotion.smooth,
      child: result,
    );
  }
}

/// HeroUI's `Tabs.Separator`: a short divider on the leading edge of a tab.
///
/// Horizontal lists draw a 1 px line at half the tab's height; vertical
/// lists a 1 px line across 90% of its width at the top. The separator of
/// the selected tab and of the tab after it fade out, and the secondary
/// variant hides separators.
class HeroTabSeparator extends StatelessWidget {
  /// Creates a tab separator.
  const HeroTabSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroTabsScope tabs = _HeroTabsScope.of(context);
    if (tabs.isSecondary) return const SizedBox.shrink();
    final bool hidden = _HeroTabScope.maybeOf(context)?.hideSeparator ?? false;
    final Color muted = theme.colors.muted;
    final double hairline = theme.spacing(0.25);
    final Widget line = DecoratedBox(
      decoration: ShapeDecoration(
        color: muted.withValues(alpha: muted.a * 0.25),
        shape: theme.shapeAll(theme.radii.sm),
      ),
    );
    return AnimatedOpacity(
      opacity: hidden ? 0 : 1,
      duration: theme.motion.resolve(context, HeroMotion.normal),
      curve: HeroMotion.smooth,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          if (tabs.orientation == Axis.horizontal)
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              width: hairline,
              child: FractionallySizedBox(heightFactor: 0.5, child: line),
            )
          else
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: hairline,
              child: FractionallySizedBox(widthFactor: 0.9, child: line),
            ),
        ],
      ),
    );
  }
}

/// HeroUI's `Tabs.Panel`: the content shown while the tab with the same
/// [id] is selected.
///
/// Only the selected panel is built. It has 8 px padding and sits 16 px
/// (plus the tabs' 8 px gap) below the list, or beside it when vertical.
class HeroTabPanel extends StatelessWidget {
  /// Creates a tab panel.
  const HeroTabPanel({
    super.key,
    required this.id,
    this.child,
    this.builder,
    this.padding,
  });

  /// The id of the [HeroTab] this panel belongs to.
  final Object id;

  /// The content.
  final Widget? child;

  /// Builds the content instead of [child].
  final WidgetBuilder? builder;

  /// Replaces the default 8 px padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final _HeroTabsScope tabs = _HeroTabsScope.of(context);
    if (tabs.state.selectedKey != id) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    // `gap-2` of the tabs root plus the panel's `mt-4` / `ms-4`.
    final double offset = theme.spacing(2) + theme.spacing(4);
    return Padding(
      padding: tabs.orientation == Axis.horizontal
          ? EdgeInsets.only(top: offset)
          : EdgeInsetsDirectional.only(start: offset),
      child: Semantics(
        container: true,
        role: SemanticsRole.tabPanel,
        child: Padding(
          padding: padding ?? EdgeInsets.all(theme.spacing(2)),
          child: builder?.call(context) ?? child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
