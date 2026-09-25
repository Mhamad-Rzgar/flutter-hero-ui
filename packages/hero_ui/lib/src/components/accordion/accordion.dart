/// HeroUI's Accordion: collapsible panels for organizing content in a
/// compact space.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../surface/surface.dart';

/// The look of a [HeroAccordion] (HeroUI's `variant` prop).
enum HeroAccordionVariant {
  /// Transparent, items divided by full-width separators (HeroUI's
  /// `default`).
  standard,

  /// A rounded `--surface` card with inset separators.
  surface,
}

/// The render state of a [HeroAccordionTrigger]: the interaction state plus
/// whether its item is expanded.
@immutable
class HeroAccordionTriggerState extends HeroInteractionState {
  /// Creates a trigger state.
  const HeroAccordionTriggerState({
    super.isHovered,
    super.isPressed,
    super.isFocused,
    super.isFocusVisible,
    super.isDisabled,
    this.isExpanded = false,
  });

  /// Whether the item's panel is expanded.
  final bool isExpanded;

  @override
  bool operator ==(Object other) =>
      other is HeroAccordionTriggerState &&
      super == other &&
      other.isExpanded == isExpanded;

  @override
  int get hashCode => Object.hash(super.hashCode, isExpanded);
}

/// Builds the content of a [HeroAccordionTrigger] from its state (HeroUI's
/// render-prop children).
typedef HeroAccordionTriggerBuilder =
    Widget Function(BuildContext context, HeroAccordionTriggerState state);

/// HeroUI's Accordion: a vertically stacked set of [HeroAccordionItem]s,
/// each revealing a panel of content.
///
/// ```dart
/// HeroAccordion(
///   children: const <Widget>[
///     HeroAccordionItem(
///       title: Text('How do I place an order?'),
///       startContent: HeroIcon(HeroIcons.shoppingBag),
///       child: Text('Browse our products, add items to your cart, ...'),
///     ),
///     HeroAccordionItem(
///       title: Text('Can I modify or cancel my order?'),
///       child: Text('Yes, you can modify or cancel your order ...'),
///     ),
///   ],
/// )
/// ```
///
/// Items are compact rows (a [HeroAccordionHeading] holding a
/// [HeroAccordionTrigger]) that expand a [HeroAccordionPanel]; the
/// convenience parameters of [HeroAccordionItem] build these parts.
///
/// * Expansion: one item at a time, or several with
///   [allowsMultipleExpanded]. Controlled with [expandedKeys] +
///   [onExpandedChanged], or uncontrolled with [defaultExpandedKeys]. Items
///   are identified by their `id`, else by their index.
/// * [variant]: transparent with full-width separators, or a rounded
///   `--surface` card. [hideSeparator] removes the separators.
/// * [isDisabled] disables every item.
///
/// Panels open and close with HeroUI's height and opacity transition
/// (200 ms) while the indicator turns over (250 ms).
class HeroAccordion extends StatefulWidget {
  /// Creates an accordion.
  const HeroAccordion({
    super.key,
    required this.children,
    this.variant = HeroAccordionVariant.standard,
    this.hideSeparator = false,
    this.allowsMultipleExpanded = false,
    this.expandedKeys,
    this.defaultExpandedKeys,
    this.onExpandedChanged,
    this.isDisabled = false,
    this.borderRadius,
  });

  /// The [HeroAccordionItem]s.
  final List<Widget> children;

  /// Transparent or surface look.
  final HeroAccordionVariant variant;

  /// Hides the separators between items.
  final bool hideSeparator;

  /// Whether several items can be expanded at once.
  final bool allowsMultipleExpanded;

  /// Controlled expansion: the ids of the expanded items.
  final Set<Object>? expandedKeys;

  /// Initial expansion when uncontrolled.
  final Set<Object>? defaultExpandedKeys;

  /// Called with the ids of the expanded items when they change.
  final ValueChanged<Set<Object>>? onExpandedChanged;

  /// Disables every item.
  final bool isDisabled;

  /// Corner radius of the surface variant, also used by the first and last
  /// triggers; 24 (`min(32px, --radius-3xl)`) by default.
  final double? borderRadius;

  @override
  State<HeroAccordion> createState() => _HeroAccordionState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<HeroAccordionVariant>(
          'variant',
          variant,
          defaultValue: HeroAccordionVariant.standard,
        ),
      )
      ..add(
        FlagProperty(
          'hideSeparator',
          value: hideSeparator,
          ifTrue: 'hide separator',
        ),
      )
      ..add(
        FlagProperty(
          'allowsMultipleExpanded',
          value: allowsMultipleExpanded,
          ifTrue: 'multiple',
        ),
      )
      ..add(
        IterableProperty<Object>(
          'expandedKeys',
          expandedKeys,
          defaultValue: null,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroAccordionState extends State<HeroAccordion> {
  late Set<Object> _expanded = <Object>{
    ...?widget.defaultExpandedKeys,
    for (int i = 0; i < widget.children.length; i++)
      if (widget.children[i] case final HeroAccordionItem item
          when item.defaultExpanded)
        item.id ?? i,
  };

  Set<Object> get _effectiveExpanded => widget.expandedKeys ?? _expanded;

  void toggle(Object id) {
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
    final HeroThemeData theme = HeroTheme.of(context);
    final bool surface = widget.variant == HeroAccordionVariant.surface;
    final double radius =
        widget.borderRadius ?? (theme.radii.xl3 < 32 ? theme.radii.xl3 : 32);
    final int count = widget.children.length;
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          _HeroAccordionItemIndex(
            index: i,
            isFirst: i == 0,
            isLast: i == count - 1,
            child: widget.children[i],
          ),
      ],
    );
    if (surface) {
      content = HeroSurface(
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }
    return _HeroAccordionScope(
      state: this,
      expandedKeys: _effectiveExpanded,
      variant: widget.variant,
      hideSeparator: widget.hideSeparator,
      isDisabled: widget.isDisabled,
      radius: radius,
      child: content,
    );
  }
}

class _HeroAccordionScope extends InheritedWidget {
  const _HeroAccordionScope({
    required this.state,
    required this.expandedKeys,
    required this.variant,
    required this.hideSeparator,
    required this.isDisabled,
    required this.radius,
    required super.child,
  });

  final _HeroAccordionState state;
  final Set<Object> expandedKeys;
  final HeroAccordionVariant variant;
  final bool hideSeparator;
  final bool isDisabled;
  final double radius;

  bool get isSurface => variant == HeroAccordionVariant.surface;

  static _HeroAccordionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroAccordionScope>();

  @override
  bool updateShouldNotify(_HeroAccordionScope oldWidget) =>
      !setEquals(expandedKeys, oldWidget.expandedKeys) ||
      variant != oldWidget.variant ||
      hideSeparator != oldWidget.hideSeparator ||
      isDisabled != oldWidget.isDisabled ||
      radius != oldWidget.radius;
}

class _HeroAccordionItemIndex extends InheritedWidget {
  const _HeroAccordionItemIndex({
    required this.index,
    required this.isFirst,
    required this.isLast,
    required super.child,
  });

  final int index;
  final bool isFirst;
  final bool isLast;

  static _HeroAccordionItemIndex? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroAccordionItemIndex>();

  @override
  bool updateShouldNotify(_HeroAccordionItemIndex oldWidget) =>
      index != oldWidget.index ||
      isFirst != oldWidget.isFirst ||
      isLast != oldWidget.isLast;
}

class _HeroAccordionItemScope extends InheritedWidget {
  const _HeroAccordionItemScope({
    required this.isExpanded,
    required this.isDisabled,
    required this.isFirst,
    required this.isLast,
    required this.onToggle,
    required super.child,
  });

  final bool isExpanded;
  final bool isDisabled;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onToggle;

  static _HeroAccordionItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroAccordionItemScope>();

  @override
  bool updateShouldNotify(_HeroAccordionItemScope oldWidget) =>
      isExpanded != oldWidget.isExpanded ||
      isDisabled != oldWidget.isDisabled ||
      isFirst != oldWidget.isFirst ||
      isLast != oldWidget.isLast ||
      onToggle != oldWidget.onToggle;
}

/// HeroUI's `Accordion.Item`: one collapsible section of a [HeroAccordion].
///
/// Compose it from a [HeroAccordionHeading] (holding a
/// [HeroAccordionTrigger]) and a [HeroAccordionPanel] in [children], or use
/// the convenience parameters: [title] (with [startContent] and
/// [indicator]) builds the heading and trigger, and [child] becomes the
/// panel's [HeroAccordionBody].
///
/// A 1 px `--separator` line divides it from the next item (inset and
/// fainter in the surface variant).
class HeroAccordionItem extends StatefulWidget {
  /// Creates an accordion item.
  const HeroAccordionItem({
    super.key,
    this.id,
    this.children,
    this.title,
    this.startContent,
    this.indicator = const HeroAccordionIndicator(),
    this.child,
    this.isDisabled = false,
    this.isExpanded,
    this.defaultExpanded = false,
    this.onExpandedChanged,
  });

  /// Identifies the item in the accordion's expanded keys; defaults to its
  /// index.
  final Object? id;

  /// The parts: a [HeroAccordionHeading] and a [HeroAccordionPanel].
  /// Replaces [title], [startContent], [indicator] and [child].
  final List<Widget>? children;

  /// The trigger label, usually a [Text].
  final Widget? title;

  /// Content before the title (an icon), 12 px from it.
  final Widget? startContent;

  /// The indicator at the end of the trigger; null shows none.
  final Widget? indicator;

  /// The panel content, shown in a [HeroAccordionBody].
  final Widget? child;

  /// Whether the item cannot be expanded or collapsed.
  final bool isDisabled;

  /// Controls this item's expansion directly, overriding the accordion's
  /// expanded keys.
  final bool? isExpanded;

  /// Whether the item starts expanded (adds it to the accordion's initial
  /// expanded keys).
  final bool defaultExpanded;

  /// Called with the new expansion state when the trigger is pressed.
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<HeroAccordionItem> createState() => _HeroAccordionItemState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Object>('id', id, defaultValue: null))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(
        FlagProperty(
          'isExpanded',
          value: isExpanded,
          ifTrue: 'expanded',
          ifFalse: 'collapsed',
        ),
      );
  }
}

class _HeroAccordionItemState extends State<HeroAccordionItem> {
  late bool _expanded = widget.defaultExpanded;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroAccordionScope? accordion = _HeroAccordionScope.maybeOf(context);
    final _HeroAccordionItemIndex? index = _HeroAccordionItemIndex.maybeOf(
      context,
    );
    final Object id = widget.id ?? index?.index ?? 0;
    final bool expanded =
        widget.isExpanded ??
        (accordion != null ? accordion.expandedKeys.contains(id) : _expanded);
    final bool disabled = widget.isDisabled || (accordion?.isDisabled ?? false);
    final bool isFirst = index?.isFirst ?? true;
    final bool isLast = index?.isLast ?? true;

    void toggle() {
      if (disabled) return;
      if (widget.isExpanded == null) {
        if (accordion != null) {
          accordion.state.toggle(id);
        } else {
          setState(() => _expanded = !_expanded);
        }
      }
      widget.onExpandedChanged?.call(!expanded);
    }

    final List<Widget> parts =
        widget.children ??
        <Widget>[
          HeroAccordionHeading(
            child: HeroAccordionTrigger(
              startContent: widget.startContent,
              indicator: widget.indicator,
              child: widget.title,
            ),
          ),
          HeroAccordionPanel(child: HeroAccordionBody(child: widget.child)),
        ];

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: parts,
    );
    final bool showSeparator =
        accordion != null && !accordion.hideSeparator && !isLast;
    if (showSeparator) {
      final bool surface = accordion.isSurface;
      final Color base = surface
          ? theme.colors.surfaceForeground
          : theme.colors.separator;
      final Widget line = DecoratedBox(
        decoration: ShapeDecoration(
          color: surface ? base.withValues(alpha: base.a * 0.06) : base,
          shape: theme.shapeAll(theme.radii.xs),
        ),
      );
      content = Stack(
        children: <Widget>[
          content,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: theme.spacing(0.25),
            child: surface
                ? FractionallySizedBox(widthFactor: 0.94, child: line)
                : line,
          ),
        ],
      );
    }
    return _HeroAccordionItemScope(
      isExpanded: expanded,
      isDisabled: disabled,
      isFirst: isFirst,
      isLast: isLast,
      onToggle: toggle,
      child: content,
    );
  }
}

/// HeroUI's `Accordion.Heading`: the heading that holds an item's
/// [HeroAccordionTrigger], announced as a heading.
class HeroAccordionHeading extends StatelessWidget {
  /// Creates an accordion heading.
  const HeroAccordionHeading({super.key, required this.child});

  /// The trigger.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      header: true,
      child: Row(children: <Widget>[Expanded(child: child)]),
    );
  }
}

/// Style overrides for a [HeroAccordionTrigger], the counterpart of
/// customising `.accordion__trigger` with utilities.
@immutable
class HeroAccordionTriggerStyle {
  /// Creates trigger style overrides.
  const HeroAccordionTriggerStyle({
    this.backgroundColor,
    this.padding,
    this.textStyle,
  });

  /// Fill per state (`hovered`, `pressed`, `focused`, `disabled`, and
  /// `selected` while expanded); by default `--foreground` at 3% (or
  /// `--default` on a surface) while hovered and collapsed.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Inner padding (16 all round by default).
  final EdgeInsetsGeometry? padding;

  /// Text style merged over `text-sm font-medium`.
  final TextStyle? textStyle;
}

/// HeroUI's `Accordion.Trigger`: the full-width button that expands and
/// collapses its item.
///
/// It lays out [startContent], the label ([builder] or [child]) and the
/// [indicator] pushed to the end, with 16 px padding in `text-sm` medium.
/// Hovering a collapsed trigger tints it (`--foreground` at 3%, `--default`
/// in the surface variant); keyboard focus shows the focus ring.
class HeroAccordionTrigger extends StatelessWidget {
  /// Creates an accordion trigger.
  const HeroAccordionTrigger({
    super.key,
    this.child,
    this.builder,
    this.startContent,
    this.indicator = const HeroAccordionIndicator(),
    this.onPressed,
    this.isDisabled,
    this.style,
    this.semanticLabel,
  });

  /// The label.
  final Widget? child;

  /// Builds the label from the trigger state; replaces [child].
  final HeroAccordionTriggerBuilder? builder;

  /// Content before the label (an icon), 12 px from it.
  final Widget? startContent;

  /// The indicator at the end; null shows none.
  final Widget? indicator;

  /// Called after the item toggles (`onPress`).
  final VoidCallback? onPressed;

  /// Disables the trigger; defaults to the item's state.
  final bool? isDisabled;

  /// Style overrides.
  final HeroAccordionTriggerStyle? style;

  /// Accessibility label; defaults to the label text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroAccordionScope? accordion = _HeroAccordionScope.maybeOf(context);
    final _HeroAccordionItemScope? item = _HeroAccordionItemScope.maybeOf(
      context,
    );
    final bool expanded = item?.isExpanded ?? false;
    final bool disabled = isDisabled ?? item?.isDisabled ?? false;
    final bool surface = accordion?.isSurface ?? false;
    final double radius = accordion?.radius ?? 0;
    final Radius corner = Radius.circular(radius);
    final BorderRadiusGeometry borderRadius = surface
        ? BorderRadius.vertical(
            top: (item?.isFirst ?? false) ? corner : Radius.zero,
            bottom: (item?.isLast ?? false) && !expanded ? corner : Radius.zero,
          )
        : BorderRadius.zero;
    final OutlinedBorder shape = theme.shape(borderRadius);
    final Color foreground =
        DefaultTextStyle.of(context).style.color ?? theme.colors.foreground;

    return HeroInteractable(
      isDisabled: disabled,
      semanticsLabel: semanticLabel,
      onPressed: () {
        item?.onToggle();
        onPressed?.call();
      },
      builder: (BuildContext context, HeroInteractionState interaction, _) {
        final HeroAccordionTriggerState state = HeroAccordionTriggerState(
          isHovered: interaction.isHovered,
          isPressed: interaction.isPressed,
          isFocused: interaction.isFocused,
          isFocusVisible: interaction.isFocusVisible,
          isDisabled: disabled,
          isExpanded: expanded,
        );
        final Set<WidgetState> states = <WidgetState>{
          ...interaction.widgetStates,
          if (expanded) WidgetState.selected,
        };
        final Color? background =
            style?.backgroundColor?.resolve(states) ??
            (state.isHovered && !expanded
                ? (surface
                      ? theme.colors.defaultColor
                      : theme.colors.foreground.withValues(
                          alpha: theme.colors.foreground.a * 0.03,
                        ))
                : null);
        final Widget? label = builder?.call(context, state) ?? child;
        final Widget? start = startContent;
        final Widget? end = indicator;
        Widget content = Row(
          children: <Widget>[
            if (start != null)
              Padding(
                padding: EdgeInsetsDirectional.only(end: theme.spacing(3)),
                child: start,
              ),
            Expanded(child: label ?? const SizedBox.shrink()),
            ?end,
          ],
        );
        content = DefaultTextStyle(
          style: theme.typography
              .style(HeroFontSize.sm, weight: HeroTypography.medium)
              .copyWith(color: foreground)
              .merge(style?.textStyle?.copyWith(inherit: true)),
          textAlign: TextAlign.start,
          child: IconTheme.merge(
            data: IconThemeData(size: theme.spacing(4)),
            child: content,
          ),
        );
        content = DecoratedBox(
          decoration: ShapeDecoration(color: background, shape: shape),
          child: Padding(
            padding: style?.padding ?? EdgeInsets.all(theme.spacing(4)),
            child: content,
          ),
        );
        return Semantics(
          expanded: expanded,
          child: HeroFocusRing(
            visible: state.isFocusVisible,
            shape: shape,
            child: _FadeOpacity(
              opacity: disabled ? theme.disabledOpacity : 1,
              child: content,
            ),
          ),
        );
      },
    );
  }
}

/// `transition: opacity 150ms ease-out`.
class _FadeOpacity extends StatelessWidget {
  const _FadeOpacity({required this.opacity, required this.child});

  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: HeroTheme.of(
        context,
      ).motion.resolve(context, HeroMotion.normal),
      curve: HeroMotion.easeOut,
      child: child,
    );
  }
}

/// HeroUI's `Accordion.Indicator`: the chevron at the end of a trigger,
/// which turns upside down while its item is expanded.
///
/// 16 px in `--muted` by default; a custom [child] icon turns as well.
class HeroAccordionIndicator extends StatelessWidget {
  /// Creates an indicator.
  const HeroAccordionIndicator({super.key, this.child, this.color});

  /// The icon; defaults to a chevron pointing down.
  final Widget? child;

  /// Icon color; defaults to `--muted`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool expanded =
        _HeroAccordionItemScope.maybeOf(context)?.isExpanded ?? false;
    return ExcludeSemantics(
      child: AnimatedRotation(
        turns: expanded ? -0.5 : 0,
        // `transition duration-250` with Tailwind's default easing.
        duration: theme.motion.resolve(context, HeroMotion.slow),
        curve: HeroMotion.easeInOut,
        child: IconTheme.merge(
          data: IconThemeData(
            color: color ?? theme.colors.muted,
            size: theme.spacing(4),
          ),
          child: SizedBox.square(
            dimension: theme.spacing(4),
            child: Center(
              child: child ?? const HeroIcon(HeroIcons.chevronDown),
            ),
          ),
        ),
      ),
    );
  }
}

/// HeroUI's `Accordion.Panel`: the region that expands under an item's
/// heading, animating its height (200 ms, ease-out-quad) and opacity
/// (200 ms, ease-out).
///
/// Collapsed content is removed from focus traversal and semantics.
class HeroAccordionPanel extends StatelessWidget {
  /// Creates a panel.
  const HeroAccordionPanel({super.key, this.child, this.builder});

  /// The content, usually a [HeroAccordionBody].
  final Widget? child;

  /// Builds the content; replaces [child].
  final WidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final bool expanded =
        _HeroAccordionItemScope.maybeOf(context)?.isExpanded ?? false;
    return HeroCollapsible(
      isExpanded: expanded,
      child: Semantics(
        container: true,
        child: builder?.call(context) ?? child ?? const SizedBox.shrink(),
      ),
    );
  }
}

/// HeroUI's `Accordion.Body`: the padded content of a panel, `text-sm` in
/// `--muted` with 16 px of horizontal and bottom padding.
class HeroAccordionBody extends StatelessWidget {
  /// Creates a panel body.
  const HeroAccordionBody({super.key, this.child, this.padding, this.style});

  /// The content (text widgets inherit the body style).
  final Widget? child;

  /// Replaces the padding (16 start, end and bottom).
  final EdgeInsetsGeometry? padding;

  /// Style merged over the body style (the counterpart of `className`).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding:
          padding ??
          EdgeInsetsDirectional.only(
            start: theme.spacing(4),
            end: theme.spacing(4),
            bottom: theme.spacing(4),
          ),
      child: DefaultTextStyle.merge(
        style: theme.typography.sm
            .copyWith(color: theme.colors.muted)
            .merge(style?.copyWith(inherit: true)),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
