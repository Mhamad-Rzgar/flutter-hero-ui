/// HeroUI's Disclosure: a collapsible section with a heading, a trigger and
/// a panel of content.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../disclosure_group/disclosure_group.dart';

/// The state of a [HeroDisclosure], handed to builders and returned by
/// [HeroDisclosure.of] (HeroUI's `isExpanded` / `isDisabled` render props
/// plus the actions of React Aria's disclosure state).
@immutable
class HeroDisclosureState {
  /// Creates a disclosure state.
  const HeroDisclosureState({
    required this.isExpanded,
    required this.isDisabled,
    required VoidCallback onToggle,
    required ValueChanged<bool> onSetExpanded,
  }) : _onToggle = onToggle,
       _onSetExpanded = onSetExpanded;

  /// Whether the content is shown.
  final bool isExpanded;

  /// Whether the disclosure ignores toggles.
  final bool isDisabled;

  final VoidCallback _onToggle;
  final ValueChanged<bool> _onSetExpanded;

  /// Expands a collapsed disclosure and collapses an expanded one.
  void toggle() => _onToggle();

  /// Shows the content.
  void expand() => _onSetExpanded(true);

  /// Hides the content.
  void collapse() => _onSetExpanded(false);

  @override
  bool operator ==(Object other) =>
      other is HeroDisclosureState &&
      other.isExpanded == isExpanded &&
      other.isDisabled == isDisabled;

  @override
  int get hashCode => Object.hash(isExpanded, isDisabled);
}

/// Builds a widget from the state of a [HeroDisclosure].
typedef HeroDisclosureWidgetBuilder =
    Widget Function(BuildContext context, HeroDisclosureState state);

/// HeroUI's Disclosure: a heading with a trigger that shows and hides a
/// panel of content.
///
/// Compose it from a [HeroDisclosureHeading] holding the trigger and a
/// [HeroDisclosureContent] (usually with a [HeroDisclosureBody]). The trigger
/// is a [HeroDisclosureTrigger], or any control built with
/// [HeroDisclosureTrigger.builder], like HeroUI's `slot="trigger"` buttons:
///
/// ```dart
/// HeroDisclosure(
///   children: <Widget>[
///     HeroDisclosureHeading(
///       child: HeroDisclosureTrigger.builder(
///         builder: (BuildContext context, HeroDisclosureState state) =>
///             HeroButton(
///               variant: HeroButtonVariant.secondary,
///               onPressed: state.toggle,
///               endContent: const HeroDisclosureIndicator(),
///               child: const Text('Preview HeroUI Native'),
///             ),
///       ),
///     ),
///     const HeroDisclosureContent(
///       child: HeroDisclosureBody(child: Text('Scan this QR code ...')),
///     ),
///   ],
/// )
/// ```
///
/// Expansion is controlled ([isExpanded] + [onExpandedChanged]) or
/// uncontrolled ([defaultExpanded]); inside a [HeroDisclosureGroup] the
/// group decides, by [id]. The content opens and closes with
/// HeroUI's height and opacity transition (200 ms) and the indicator turns
/// over (250 ms). Collapsed content is removed from focus traversal and
/// semantics.
class HeroDisclosure extends StatefulWidget {
  /// Creates a disclosure from [children].
  const HeroDisclosure({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.id,
    this.isExpanded,
    this.defaultExpanded = false,
    this.onExpandedChanged,
    this.isDisabled = false,
  });

  /// The parts: a [HeroDisclosureHeading] and a [HeroDisclosureContent],
  /// laid out in a column.
  final List<Widget> children;

  /// Builds the content from the disclosure state; replaces [children]
  /// (HeroUI's render-function children).
  final HeroDisclosureWidgetBuilder? builder;

  /// Identifies the disclosure inside a [HeroDisclosureGroup] (required
  /// there).
  final Object? id;

  /// Controlled expansion; ignored inside a [HeroDisclosureGroup].
  final bool? isExpanded;

  /// Initial expansion when uncontrolled.
  final bool defaultExpanded;

  /// Called with the new expansion state when the trigger toggles it.
  final ValueChanged<bool>? onExpandedChanged;

  /// Whether the trigger ignores presses (also when the enclosing
  /// [HeroDisclosureGroup] is disabled).
  final bool isDisabled;

  /// The state of the nearest enclosing [HeroDisclosure].
  ///
  /// Use it to toggle the disclosure from any widget inside it.
  static HeroDisclosureState of(BuildContext context) {
    final _HeroDisclosureScope? scope = context
        .dependOnInheritedWidgetOfExactType<_HeroDisclosureScope>();
    assert(scope != null, 'No HeroDisclosure found in context.');
    return scope!.state;
  }

  /// The state of the nearest enclosing [HeroDisclosure], or null.
  static HeroDisclosureState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroDisclosureScope>()?.state;

  @override
  State<HeroDisclosure> createState() => _HeroDisclosureWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Object>('id', id, defaultValue: null))
      ..add(
        FlagProperty(
          'isExpanded',
          value: isExpanded,
          ifTrue: 'expanded',
          ifFalse: 'collapsed',
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroDisclosureWidgetState extends State<HeroDisclosure> {
  late bool _expanded = widget.defaultExpanded;
  HeroDisclosureGroupScope? _group;

  // Inside a group the disclosure is identified by its id (React Aria
  // generates one when missing; here the state object stands in for it).
  Object get _id => widget.id ?? this;

  bool get _effectiveExpanded {
    final HeroDisclosureGroupScope? group = _group;
    if (group != null) return group.expandedKeys.contains(_id);
    return widget.isExpanded ?? _expanded;
  }

  bool get _disabled => widget.isDisabled || (_group?.isDisabled ?? false);

  void _set(bool expanded) {
    if (_disabled || expanded == _effectiveExpanded) return;
    final HeroDisclosureGroupScope? group = _group;
    if (group != null) {
      group.onToggle(_id);
    } else if (widget.isExpanded == null) {
      setState(() => _expanded = expanded);
    }
    widget.onExpandedChanged?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    _group = HeroDisclosureGroupScope.maybeOf(context);
    assert(
      _group == null || widget.id != null,
      'A HeroDisclosure inside a HeroDisclosureGroup needs an id.',
    );
    final HeroDisclosureState state = HeroDisclosureState(
      isExpanded: _effectiveExpanded,
      isDisabled: _disabled,
      onToggle: () => _set(!_effectiveExpanded),
      onSetExpanded: _set,
    );
    final HeroDisclosureWidgetBuilder? builder = widget.builder;
    return _HeroDisclosureScope(
      state: state,
      child: builder != null
          ? Builder(builder: (BuildContext context) => builder(context, state))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children,
            ),
    );
  }
}

class _HeroDisclosureScope extends InheritedWidget {
  const _HeroDisclosureScope({required this.state, required super.child});

  final HeroDisclosureState state;

  @override
  bool updateShouldNotify(_HeroDisclosureScope oldWidget) =>
      state != oldWidget.state;
}

/// HeroUI's `Disclosure.Heading`: the heading that holds the trigger,
/// announced as a heading.
///
/// It spans the width of the disclosure and places the trigger at its
/// start at its natural width, like the inline trigger in HeroUI's block
/// heading; wrap the trigger in a [Center] to center it.
class HeroDisclosureHeading extends StatelessWidget {
  /// Creates a disclosure heading.
  const HeroDisclosureHeading({super.key, required this.child});

  /// The trigger.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      header: true,
      child: Align(alignment: AlignmentDirectional.centerStart, child: child),
    );
  }
}

/// HeroUI's `Disclosure.Trigger`: the control that expands and collapses a
/// [HeroDisclosure].
///
/// The default constructor makes [child] pressable (Enter and Space
/// included) with a focus ring for keyboard focus and 50% opacity when
/// disabled, without any fill of its own. [HeroDisclosureTrigger.builder]
/// makes another control the trigger instead, usually a [HeroButton] whose
/// `onPressed` is the state's [HeroDisclosureState.toggle] and whose
/// `isDisabled` is [HeroDisclosureState.isDisabled] (HeroUI's
/// `<Button slot="trigger">`). Either way the trigger is announced as a
/// button with an expanded state.
class HeroDisclosureTrigger extends StatelessWidget {
  /// Creates a trigger around [child].
  const HeroDisclosureTrigger({
    super.key,
    required Widget this.child,
    this.semanticLabel,
  }) : builder = null;

  /// Creates a trigger from the control that [builder] returns.
  const HeroDisclosureTrigger.builder({
    super.key,
    required HeroDisclosureWidgetBuilder this.builder,
  }) : child = null,
       semanticLabel = null;

  /// The trigger content.
  final Widget? child;

  /// Builds the control that acts as the trigger.
  final HeroDisclosureWidgetBuilder? builder;

  /// Accessibility label; defaults to the content text.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroDisclosureState? state = HeroDisclosure.maybeOf(context);
    final bool expanded = state?.isExpanded ?? false;
    final bool disabled = state?.isDisabled ?? false;
    final HeroDisclosureWidgetBuilder? builder = this.builder;
    if (builder != null && state != null) {
      return MergeSemantics(
        child: Semantics(expanded: expanded, child: builder(context, state)),
      );
    }
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroInteractable(
      isDisabled: disabled,
      semanticsLabel: semanticLabel,
      onPressed: state?.toggle,
      builder: (BuildContext context, HeroInteractionState interaction, _) {
        return Semantics(
          expanded: expanded,
          child: HeroFocusRing(
            visible: interaction.isFocusVisible,
            shape: theme.shapeAll(0),
            child: HeroDisabledOpacity(disabled: disabled, child: child!),
          ),
        );
      },
    );
  }
}

/// HeroUI's `Disclosure.Indicator`: a chevron that turns upside down while
/// its disclosure is expanded (250 ms).
///
/// 16 px in the surrounding icon color (the trigger's text color); a custom
/// [child] icon turns as well.
class HeroDisclosureIndicator extends StatelessWidget {
  /// Creates an indicator.
  const HeroDisclosureIndicator({super.key, this.child, this.color});

  /// The icon; defaults to a chevron pointing down.
  final Widget? child;

  /// Icon color; defaults to the surrounding icon color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool expanded = HeroDisclosure.maybeOf(context)?.isExpanded ?? false;
    return ExcludeSemantics(
      child: AnimatedRotation(
        turns: expanded ? -0.5 : 0,
        // `transition duration-250` with Tailwind's default easing.
        duration: theme.motion.resolve(context, HeroMotion.slow),
        curve: HeroMotion.easeInOut,
        child: IconTheme.merge(
          data: IconThemeData(color: color, size: theme.spacing(4)),
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

/// HeroUI's `Disclosure.Content`: the panel shown while the disclosure is
/// expanded, animating its height (200 ms, ease-out-quad) and opacity
/// (200 ms, ease-out).
class HeroDisclosureContent extends StatelessWidget {
  /// Creates the disclosure content.
  const HeroDisclosureContent({super.key, this.child, this.builder});

  /// The content, usually a [HeroDisclosureBody].
  final Widget? child;

  /// Builds the content from the disclosure state; replaces [child].
  final HeroDisclosureWidgetBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final HeroDisclosureState? state = HeroDisclosure.maybeOf(context);
    final HeroDisclosureWidgetBuilder? builder = this.builder;
    return HeroCollapsible(
      isExpanded: state?.isExpanded ?? false,
      child: Semantics(
        container: true,
        child: builder != null && state != null
            ? builder(context, state)
            : (child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// HeroUI's `Disclosure.Body`: the padded content of a
/// [HeroDisclosureContent] (8 px all round).
class HeroDisclosureBody extends StatelessWidget {
  /// Creates a disclosure body.
  const HeroDisclosureBody({super.key, this.child, this.padding});

  /// The content.
  final Widget? child;

  /// Replaces the 8 px padding (`p-2`).
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(HeroTheme.of(context).spacing(2)),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
