import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../button/button.dart';
import '../close_button/close_button.dart';
import 'dialog_layout.dart';
import 'modal_route.dart';
import 'overlay_surface.dart';

/// Where a modal sits on screen (`Modal.Container` `placement`).
enum HeroModalPlacement {
  /// A bottom sheet below 640 px, centered from 640 px up (the default).
  auto,

  /// Vertically centered.
  center,

  /// At the top.
  top,

  /// At the bottom.
  bottom,
}

/// What scrolls when a modal's content is taller than the screen
/// (`Modal.Container` `scroll`).
enum HeroModalScroll {
  /// The dialog stays within the screen and its body scrolls (the default).
  inside,

  /// The dialog keeps its natural height and the backdrop scrolls.
  outside,
}

/// The width of a modal dialog (`Modal.Container` `size`).
enum HeroModalSize {
  /// At most 320 wide (`max-w-xs`).
  xs,

  /// At most 384 wide (`max-w-sm`).
  sm,

  /// At most 448 wide (`max-w-md`), the default.
  md,

  /// At most 512 wide (`max-w-lg`).
  lg,

  /// Fills the screen inside the container padding (16, or 40 from 640 px),
  /// keeping corners and shadow.
  cover,

  /// Fills the whole screen without corners or shadow.
  full;

  /// The maximum dialog width, or null when the dialog fills the container.
  double? maxWidth(HeroThemeData theme) => switch (this) {
    xs => theme.spacing(80),
    sm => theme.spacing(96),
    md => theme.spacing(112),
    lg => theme.spacing(128),
    cover || full => null,
  };

  /// Whether the dialog takes the full container height.
  bool get fillsHeight => this == cover || this == full;
}

/// Builds a custom container transition from the container's [progress]
/// (0 hidden, 1 shown) and whether it is [isExiting].
typedef HeroModalTransitionBuilder =
    Widget Function(
      BuildContext context,
      double progress,
      bool isExiting,
      Widget child,
    );

/// Builds the parts of a dialog with access to its [close] function
/// (HeroUI's `Dialog` render-prop children).
typedef HeroDialogPartsBuilder =
    List<Widget> Function(BuildContext context, VoidCallback close);

/// Layout settings a [HeroModalContainer] shares with its dialog.
class HeroModalContainerScope extends InheritedWidget {
  /// Creates the scope.
  const HeroModalContainerScope({
    super.key,
    required this.placement,
    required this.scroll,
    required this.size,
    required super.child,
  });

  /// The requested placement.
  final HeroModalPlacement placement;

  /// The scroll behaviour.
  final HeroModalScroll scroll;

  /// The dialog size.
  final HeroModalSize size;

  /// The nearest scope, or null.
  static HeroModalContainerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroModalContainerScope>();

  @override
  bool updateShouldNotify(HeroModalContainerScope oldWidget) =>
      placement != oldWidget.placement ||
      scroll != oldWidget.scroll ||
      size != oldWidget.size;
}

/// Positions the dialog of a modal (`Modal.Container`).
///
/// It covers the visual viewport (the screen above the keyboard) with 16 px
/// of padding (40 from 640 px; none for [HeroModalSize.full]), places the
/// dialog by [placement] and plays HeroUI's container motion: 250 ms
/// `ease-out-quad` in (fade, zoom from 105%, 4 px slide from the bottom
/// for auto/bottom placements below 640 px, from the top for top
/// placements) and 100 ms out (fade, zoom to 95%). Full-size modals only
/// fade.
class HeroModalContainer extends StatelessWidget
    implements HeroModalAnimatedLayer {
  /// Creates a container.
  const HeroModalContainer({
    super.key,
    required this.child,
    this.placement = HeroModalPlacement.auto,
    this.scroll = HeroModalScroll.inside,
    this.size = HeroModalSize.md,
    this.motion = const HeroModalMotion(),
    this.transitionBuilder,
  });

  /// The dialog.
  final Widget child;

  /// Where the dialog sits.
  final HeroModalPlacement placement;

  /// What scrolls when the content is too tall.
  final HeroModalScroll scroll;

  /// The dialog size.
  final HeroModalSize size;

  /// Overrides of the enter and exit motion.
  final HeroModalMotion motion;

  /// Replaces the fade/zoom/slide transition.
  final HeroModalTransitionBuilder? transitionBuilder;

  /// HeroUI's container timing.
  static const HeroModalMotion defaultMotion = HeroModalMotion(
    enterDuration: HeroMotion.slow,
    exitDuration: HeroMotion.fast,
    enterCurve: HeroMotion.easeOutQuad,
    exitCurve: HeroMotion.easeOutQuad,
  );

  @override
  Duration get enterDuration =>
      motion.enterDuration ?? defaultMotion.enterDuration!;

  @override
  Duration get exitDuration =>
      motion.exitDuration ?? defaultMotion.exitDuration!;

  /// The dialog alignment for [placement] ([sm]: 640 px and up).
  static Alignment alignmentFor(HeroModalPlacement placement, bool sm) =>
      switch (placement) {
        HeroModalPlacement.auto =>
          sm ? Alignment.center : Alignment.bottomCenter,
        HeroModalPlacement.center => Alignment.center,
        HeroModalPlacement.top => Alignment.topCenter,
        HeroModalPlacement.bottom => Alignment.bottomCenter,
      };

  HeroModalMotion _resolveMotion(HeroThemeData theme, bool sm) {
    final bool full = size == HeroModalSize.full;
    final double slide = full ? 0 : theme.spacing(1);
    final Offset enterOffset = switch (placement) {
      HeroModalPlacement.auto => sm ? Offset.zero : Offset(0, slide),
      HeroModalPlacement.center => Offset.zero,
      HeroModalPlacement.top => Offset(0, -slide),
      HeroModalPlacement.bottom => Offset(0, slide),
    };
    return motion.withDefaults(
      defaultMotion.withDefaults(
        HeroModalMotion(
          enterScale: full ? 1 : 1.05,
          exitScale: full ? 1 : 0.95,
          enterOffset: enterOffset,
          exitOffset: Offset.zero,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroModalRoute<Object?>? route = HeroModalRouteScope.maybeOf(context);
    final bool sm = heroIsSmallBreakpoint(context);
    final bool full = size == HeroModalSize.full;
    final EdgeInsets padding = full
        ? EdgeInsets.zero
        : heroSafePadding(context, EdgeInsets.all(theme.spacing(sm ? 10 : 4)));

    Widget content = HeroModalContainerScope(
      placement: placement,
      scroll: scroll,
      size: size,
      child: Align(alignment: alignmentFor(placement, sm), child: child),
    );
    if (scroll == HeroModalScroll.inside) {
      content = Padding(padding: padding, child: content);
    } else {
      final Widget positioned = content;
      content = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            primary: false,
            child: Stack(
              children: <Widget>[
                // The backdrop owns the scrolling, so it also takes the
                // outside presses.
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    excludeFromSemantics: true,
                    onTap: route?.handleOutsidePress,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(padding: padding, child: positioned),
                ),
              ],
            ),
          );
        },
      );
    }

    if (route != null) {
      final HeroModalMotion resolved = _resolveMotion(theme, sm);
      content = AnimatedBuilder(
        animation: route.animation!,
        child: content,
        builder: (BuildContext context, Widget? child) {
          final double t = resolved.progress(route);
          final bool exiting = route.isExiting;
          final HeroModalTransitionBuilder? builder = transitionBuilder;
          if (builder != null) return builder(context, t, exiting, child!);
          final double from = exiting
              ? resolved.exitScale!
              : resolved.enterScale!;
          final Offset offset =
              (exiting ? resolved.exitOffset! : resolved.enterOffset!) *
              (1 - t);
          return Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: offset,
              child: Transform.scale(
                scale: from + (1 - from) * t,
                child: child,
              ),
            ),
          );
        },
      );
    }
    // The visual viewport ends at the keyboard.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0,
      ),
      child: content,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HeroModalPlacement>('placement', placement))
      ..add(EnumProperty<HeroModalScroll>('scroll', scroll))
      ..add(EnumProperty<HeroModalSize>('size', size));
  }
}

/// The panel of a modal (`Modal.Dialog`).
///
/// `overlay` surface with the overlay shadow, 24 px corners (none for
/// [HeroModalSize.full]) and 24 px padding, as wide as the container allows
/// up to the size's maximum. Its [children] are the parts
/// ([HeroModalCloseTrigger], [HeroModalHeader], [HeroModalBody],
/// [HeroModalFooter]); [builder] builds them with a `close` function
/// instead (HeroUI's render-prop children).
///
/// Announced as a dialog ([role]) named by its [HeroModalHeading] or
/// [semanticLabel].
class HeroModalDialog extends StatelessWidget {
  /// Creates a dialog.
  const HeroModalDialog({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.role = SemanticsRole.dialog,
    this.semanticLabel,
    this.maxWidth,
    this.padding,
    this.backgroundColor,
    this.side = BorderSide.none,
    this.shadows,
    this.backdropBlur = 0,
  });

  /// The parts of the dialog.
  final List<Widget> children;

  /// Builds the parts with a `close` function; replaces [children].
  final HeroDialogPartsBuilder? builder;

  /// The semantics role (`role`, "dialog").
  final SemanticsRole role;

  /// Accessibility label (`aria-label`); defaults to the heading.
  final String? semanticLabel;

  /// Overrides the maximum width of the size (e.g. `sm:max-w-[360px]`).
  final double? maxWidth;

  /// Overrides the 24 px padding.
  final EdgeInsets? padding;

  /// Overrides the `overlay` fill.
  final Color? backgroundColor;

  /// A border inside the panel.
  final BorderSide side;

  /// Replaces the overlay shadow (`shadow-*`).
  final List<BoxShadow>? shadows;

  /// Blurs what is behind a translucent panel (`backdrop-blur-*`).
  final double backdropBlur;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroModalContainerScope? container = HeroModalContainerScope.maybeOf(
      context,
    );
    final HeroModalSize size = container?.size ?? HeroModalSize.md;
    final HeroModalScroll scroll = container?.scroll ?? HeroModalScroll.inside;
    final bool full = size == HeroModalSize.full;
    final double radius = full
        ? 0
        : math.min(theme.spacing(8), theme.radii.xl3);
    final double? limit = maxWidth ?? size.maxWidth(theme);
    EdgeInsets padding = this.padding ?? EdgeInsets.all(theme.spacing(6));
    if (full) {
      padding += MediaQuery.maybePaddingOf(context) ?? EdgeInsets.zero;
    }
    final List<Widget> parts =
        builder?.call(
          context,
          () => HeroDialogScope.maybeOf(context)?.close(),
        ) ??
        children;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool bounded = constraints.hasBoundedHeight;
        final bool scrollable = scroll == HeroModalScroll.inside && bounded;
        final bool fill = size.fillsHeight && scrollable;
        double width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : (limit ?? theme.spacing(112));
        if (limit != null) width = math.min(width, limit);

        Widget panel = HeroDialogLayout(
          padding: padding,
          scrollableBody: scrollable,
          fillHeight: fill,
          children: parts,
        );
        panel = DefaultTextStyle(
          style: theme.typography.base.copyWith(color: theme.colors.foreground),
          child: IconTheme(
            data: IconThemeData(color: theme.colors.foreground),
            child: panel,
          ),
        );
        panel = HeroOverlaySurface(
          shape: theme.shapeAll(radius),
          color: backgroundColor,
          shadow: full ? HeroShadow.none : null,
          shadows: shadows,
          side: side,
          backdropBlur: backdropBlur,
          child: panel,
        );
        panel = Semantics(
          role: role,
          scopesRoute: true,
          explicitChildNodes: true,
          namesRoute: semanticLabel != null ? true : null,
          label: semanticLabel,
          child: panel,
        );
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: width,
            maxWidth: width,
            minHeight: fill ? constraints.maxHeight : 0,
            maxHeight: scrollable ? constraints.maxHeight : double.infinity,
          ),
          // Presses on the panel never reach the backdrop.
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            child: panel,
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null))
      ..add(DoubleProperty('maxWidth', maxWidth, defaultValue: null));
  }
}

/// The title area of a modal (`Modal.Header`): a column with 12 px gaps,
/// usually a [HeroModalIcon] and a [HeroModalHeading].
class HeroModalHeader extends HeroDialogPart {
  /// Creates a header.
  const HeroModalHeader({
    super.key,
    this.children = const <Widget>[],
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// The content.
  final List<Widget> children;

  /// Horizontal alignment of the content (`items-*`).
  final CrossAxisAlignment crossAxisAlignment;

  @override
  HeroDialogPartKind get kind => HeroDialogPartKind.header;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      spacing: theme.spacing(3),
      children: children,
    );
  }
}

/// The title of a modal (`Modal.Heading`): 16 px, medium weight,
/// `foreground`. It names the dialog for assistive technologies.
class HeroModalHeading extends StatelessWidget {
  /// Creates a heading.
  const HeroModalHeading({super.key, required this.child, this.textAlign});

  /// The title, usually a [Text].
  final Widget child;

  /// Alignment of the title text.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Semantics(
      header: true,
      namesRoute: true,
      child: DefaultTextStyle(
        style: theme.typography
            .style(HeroFontSize.base, weight: HeroTypography.medium)
            .copyWith(color: theme.colors.foreground),
        textAlign: textAlign,
        child: child,
      ),
    );
  }
}

/// The icon badge of a modal (`Modal.Icon`): a 40 px circle centering a
/// 20 px icon. Colors come from the caller, e.g. `defaultColor` with
/// `foreground` or `accentSoft` with `accentSoftForeground`.
class HeroModalIcon extends StatelessWidget {
  /// Creates an icon badge.
  const HeroModalIcon({
    super.key,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The icon, usually a [HeroIcon].
  final Widget child;

  /// The circle fill; none by default.
  final Color? backgroundColor;

  /// The icon color; defaults to `foreground`.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double dimension = theme.spacing(10);
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: theme.shapeAll(math.min(theme.radii.xl3, dimension / 2)),
        ),
        child: SizedBox.square(
          dimension: dimension,
          child: Center(
            child: IconTheme(
              data: IconThemeData(
                color: foregroundColor ?? theme.colors.foreground,
                size: theme.spacing(5),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// The main content of a modal (`Modal.Body`): 14 px `muted` text with a
/// 1.43 line height. It scrolls inside the dialog when the modal uses
/// [HeroModalScroll.inside] and the content is too tall.
class HeroModalBody extends HeroDialogPart {
  /// Creates a body.
  const HeroModalBody({
    super.key,
    this.child,
    this.children = const <Widget>[],
    this.padding,
  });

  /// The content.
  final Widget? child;

  /// Content blocks stacked vertically, used when [child] is null.
  final List<Widget> children;

  /// Replaces the 3 px padding (e.g. `p-6`).
  final EdgeInsets? padding;

  @override
  HeroDialogPartKind get kind => HeroDialogPartKind.body;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool scrollable =
        HeroDialogLayoutScope.maybeOf(context)?.scrollableBody ?? false;
    Widget content =
        child ??
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
    content = DefaultTextStyle(
      style: theme.typography
          .style(HeroFontSize.sm, lineHeight: HeroFontSize.sm.fontSize * 1.43)
          .copyWith(color: theme.colors.muted),
      child: content,
    );
    final EdgeInsets inset = padding ?? EdgeInsets.all(theme.spacing(0.75));
    if (scrollable) {
      return SingleChildScrollView(
        primary: false,
        padding: inset,
        child: content,
      );
    }
    return Padding(padding: inset, child: content);
  }
}

/// The actions row of a modal (`Modal.Footer`): end-aligned with 8 px gaps.
///
/// Buttons with `fullWidth: true` share the row (`w-full`). When the
/// actions do not fit on one line (long labels, large text) they stack
/// vertically, end-aligned, like iOS alert actions. Pass [child] for a
/// custom layout, e.g. stacked buttons.
class HeroModalFooter extends HeroDialogPart {
  /// Creates a footer.
  const HeroModalFooter({
    super.key,
    this.children = const <Widget>[],
    this.child,
  });

  /// The actions.
  final List<Widget> children;

  /// A custom layout; replaces [children].
  final Widget? child;

  @override
  HeroDialogPartKind get kind => HeroDialogPartKind.footer;

  @override
  Widget build(BuildContext context) {
    final Widget? child = this.child;
    if (child != null) return child;
    final HeroThemeData theme = HeroTheme.of(context);
    final bool expands = children.any(
      (Widget action) => action is HeroButton && (action.fullWidth ?? false),
    );
    if (expands) {
      return Row(
        spacing: theme.spacing(2),
        children: <Widget>[
          for (final Widget action in children)
            if (action is HeroButton && (action.fullWidth ?? false))
              Expanded(child: action)
            else
              action,
        ],
      );
    }
    return OverflowBar(
      alignment: MainAxisAlignment.end,
      spacing: theme.spacing(2),
      overflowSpacing: theme.spacing(2),
      overflowAlignment: OverflowBarAlignment.end,
      children: children,
    );
  }
}

/// The close button of a modal (`Modal.CloseTrigger`): a
/// [HeroCloseButton] pinned 16 px from the top and end edges that closes
/// the dialog.
class HeroModalCloseTrigger extends HeroDialogPart {
  /// Creates a close trigger.
  const HeroModalCloseTrigger({
    super.key,
    this.child,
    this.onPressed,
    this.semanticLabel = 'Close',
  });

  /// Replaces the close icon.
  final Widget? child;

  /// Called before the dialog closes.
  final VoidCallback? onPressed;

  /// Accessibility label.
  final String semanticLabel;

  @override
  HeroDialogPartKind get kind => HeroDialogPartKind.closeTrigger;

  @override
  Widget build(BuildContext context) {
    return HeroCloseButton(
      semanticLabel: semanticLabel,
      onPressed: () {
        onPressed?.call();
        HeroDialogScope.maybeOf(context)?.close();
      },
      child: child,
    );
  }
}

/// A custom pressable that opens a modal (`Modal.Trigger`), for triggers
/// that are not buttons, such as cards.
///
/// It scales to 0.97 while pressed (250 ms `ease-out-quart`), shows the
/// focus ring around [borderRadius] for keyboard focus and is announced as
/// a button. Use [builder] to paint hover and pressed states.
class HeroModalTrigger extends StatelessWidget {
  /// Creates a trigger.
  const HeroModalTrigger({
    super.key,
    this.child,
    this.builder,
    this.onPressed,
    this.borderRadius = BorderRadius.zero,
    this.isDisabled = false,
    this.semanticLabel,
  });

  /// The content.
  final Widget? child;

  /// Builds the content for the interaction state; replaces [child].
  final HeroButtonWidgetBuilder? builder;

  /// Called when pressed, before the modal opens.
  final VoidCallback? onPressed;

  /// Corner radii of the content, used by the focus ring.
  final BorderRadiusGeometry borderRadius;

  /// Whether the trigger is disabled.
  final bool isDisabled;

  /// Accessibility label; defaults to the text of the content.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final OutlinedBorder shape = theme.shape(borderRadius);
    return HeroInteractable(
      onPressed: onPressed,
      isDisabled: isDisabled,
      semanticsLabel: semanticLabel,
      builder: (BuildContext context, HeroInteractionState state, _) {
        return HeroPressScale(
          pressed: state.isPressed,
          curve: HeroMotion.easeOutQuart,
          child: HeroFocusRing(
            visible: state.isFocusVisible,
            shape: shape,
            child: HeroDisabledOpacity(
              disabled: isDisabled,
              child:
                  builder?.call(context, state) ??
                  child ??
                  const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
