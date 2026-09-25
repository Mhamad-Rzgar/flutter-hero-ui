/// HeroUI's ColorPicker: a trigger and a popover that share one color
/// between the color components inside them.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../color_area/color_area.dart';
import '../color_slider/color_slider.dart';
import '../color_swatch/color_swatch.dart';
import '../label/label.dart';
import '../surface/surface.dart';

export '../color/color.dart';

/// A composable color picker (HeroUI `ColorPicker`): a [trigger] that opens
/// a [popover] of color components, all bound to one color.
///
/// ```dart
/// HeroColorPicker(
///   defaultValue: const Color(0xFF0485F7),
///   trigger: const HeroColorPickerTrigger(
///     children: <Widget>[
///       HeroColorSwatch(size: HeroColorSwatchSize.lg),
///       HeroLabel.text('Pick a color'),
///     ],
///   ),
///   popover: const HeroColorPickerPopover(
///     children: <Widget>[
///       HeroColorArea(maxSize: double.infinity),
///       HeroColorSlider(channel: HeroColorChannel.hue, colorSpace: HeroColorSpace.hsb),
///     ],
///   ),
/// )
/// ```
///
/// With only a [label] it builds HeroUI's basic anatomy: a large swatch and
/// the label as trigger, and a saturation × brightness area with a hue
/// slider in the popover.
///
/// Every `HeroColorSwatch`, `HeroColorArea`, `HeroColorSlider`,
/// `HeroColorField` and `HeroColorSwatchPicker` inside the trigger or the
/// popover that has no value of its own shows and edits the picker's color
/// (through a [HeroColorPickerScope]). The color keeps its hue and
/// saturation while the user drags brightness to zero or saturation to
/// gray.
///
/// The color is controlled with [value] + [onChanged] or uncontrolled with
/// [defaultValue]; the popover is controlled with [isOpen] +
/// [onOpenChanged] or uncontrolled with [defaultOpen].
///
/// A trigger tap, Enter or Space opens the popover (bottom start, 8 px from
/// the trigger, HeroUI's popover entrance) and moves focus to its first
/// control; Escape or a tap outside closes it and returns focus to the
/// trigger.
class HeroColorPicker extends StatefulWidget {
  /// Creates a color picker.
  const HeroColorPicker({
    super.key,
    this.trigger,
    this.popover,
    this.label,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.isOpen,
    this.defaultOpen = false,
    this.onOpenChanged,
    this.isDisabled = false,
  }) : assert(
         trigger != null || label != null,
         'Provide a trigger or a label.',
       );

  /// The trigger, usually a [HeroColorPickerTrigger]; built from [label]
  /// when null.
  final Widget? trigger;

  /// The popover, usually a [HeroColorPickerPopover]; an area and a hue
  /// slider when null.
  final Widget? popover;

  /// The label of the built trigger.
  final String? label;

  /// The current color (controlled).
  final Color? value;

  /// The initial color (uncontrolled); white when null.
  final Color? defaultValue;

  /// Called with the new color whenever a component inside edits it.
  final ValueChanged<Color>? onChanged;

  /// Whether the popover is open (controlled).
  final bool? isOpen;

  /// Whether the popover is initially open (uncontrolled).
  final bool defaultOpen;

  /// Called when the user opens or closes the popover.
  final ValueChanged<bool>? onOpenChanged;

  /// Whether the trigger is disabled.
  final bool isDisabled;

  @override
  State<HeroColorPicker> createState() => _HeroColorPickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('value', value, defaultValue: null))
      ..add(DiagnosticsProperty<bool>('isOpen', isOpen, defaultValue: null))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroColorPickerState extends State<HeroColorPicker> {
  late HeroColorValue _value = HeroColorValue.fromColor(
    widget.value ?? widget.defaultValue ?? const Color(0xFFFFFFFF),
    space: HeroColorSpace.hsb,
  );
  late bool _open = widget.defaultOpen;

  // The last value reported to a controlling parent; kept when the parent
  // hands its color back, so the hue survives the round trip through Color.
  HeroColorValue? _reported;

  bool get _isOpen => (widget.isOpen ?? _open) && !widget.isDisabled;

  @override
  void didUpdateWidget(HeroColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Color? value = widget.value;
    if (value != null) {
      final HeroColorValue previous = _reported ?? _value;
      _value = heroResolveColorValue(value, previous.space, previous: previous);
      _reported = null;
    }
  }

  void _handleChanged(HeroColorValue next) {
    if (next == _value) return;
    if (widget.value == null) {
      setState(() => _value = next);
    } else {
      _reported = next;
    }
    widget.onChanged?.call(next.toColor());
  }

  void _setOpen(bool open) {
    if (open == _isOpen) return;
    if (widget.isOpen == null) setState(() => _open = open);
    widget.onOpenChanged?.call(open);
  }

  Widget _defaultTrigger() => HeroColorPickerTrigger(
    children: <Widget>[
      const HeroColorSwatch(size: HeroColorSwatchSize.lg),
      HeroLabel.text(widget.label!),
    ],
  );

  Widget _defaultPopover(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroColorPickerPopover(
      children: <Widget>[
        const HeroColorArea(
          semanticLabel: 'Color area',
          maxSize: double.infinity,
          colorSpace: HeroColorSpace.hsb,
          xChannel: HeroColorChannel.saturation,
          yChannel: HeroColorChannel.brightness,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: theme.spacing(1)),
          child: HeroColorSlider(
            channel: HeroColorChannel.hue,
            colorSpace: HeroColorSpace.hsb,
            children: <Widget>[
              const HeroLabel.text('Hue'),
              HeroColorSliderOutput(
                style: TextStyle(color: theme.colors.muted),
              ),
              const HeroColorSliderTrack(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget popover = widget.popover ?? _defaultPopover(context);
    final HeroPlacement placement = popover is HeroColorPickerPopover
        ? popover.placement
        : HeroPlacement.bottomStart;
    final bool open = _isOpen;
    return HeroColorPickerScope(
      value: _value,
      onChanged: _handleChanged,
      child: _HeroColorPickerControl(
        isOpen: open,
        isDisabled: widget.isDisabled,
        onToggle: () => _setOpen(!open),
        child: HeroAnchoredOverlay(
          isOpen: open,
          onDismiss: () => _setOpen(false),
          placement: placement,
          offset: HeroTheme.of(context).spacing(2),
          autofocus: true,
          transitionBuilder:
              (
                BuildContext context,
                Animation<double> animation,
                HeroOverlayGeometry geometry,
                Widget child,
              ) => HeroOverlayTransition(
                animation: animation,
                geometry: geometry,
                enterScale: 0.95,
                child: child,
              ),
          overlayBuilder: (BuildContext context, HeroOverlayGeometry _) =>
              popover,
          child: widget.trigger ?? _defaultTrigger(),
        ),
      ),
    );
  }
}

class _HeroColorPickerControl extends InheritedWidget {
  const _HeroColorPickerControl({
    required this.isOpen,
    required this.isDisabled,
    required this.onToggle,
    required super.child,
  });

  final bool isOpen;
  final bool isDisabled;
  final VoidCallback onToggle;

  static _HeroColorPickerControl? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroColorPickerControl>();

  @override
  bool updateShouldNotify(_HeroColorPickerControl oldWidget) =>
      isOpen != oldWidget.isOpen ||
      isDisabled != oldWidget.isDisabled ||
      onToggle != oldWidget.onToggle;
}

/// The render props of a [HeroColorPickerTrigger].
@immutable
class HeroColorPickerTriggerState {
  /// Creates trigger render props.
  const HeroColorPickerTriggerState({
    required this.color,
    required this.interaction,
    this.isOpen = false,
  });

  /// The picker's color.
  final Color color;

  /// Hover, press, focus and disabled state of the trigger.
  final HeroInteractionState interaction;

  /// Whether the popover is open.
  final bool isOpen;
}

/// Builds the content of a [HeroColorPickerTrigger] from its state.
typedef HeroColorPickerTriggerBuilder =
    Widget Function(BuildContext context, HeroColorPickerTriggerState state);

/// The button that opens the popover of a [HeroColorPicker]
/// (`ColorPicker.Trigger`): its [children] (usually a `HeroColorSwatch` and
/// a `HeroLabel`) in a row with a 12 px gap, `rounded-sm`, `text-sm`.
///
/// It shows HeroUI's focus ring for keyboard focus and the disabled opacity,
/// and is announced as a button with its expanded state. [padding],
/// [backgroundColor] and [borderRadius] stand in for `className`
/// (`rounded-xl bg-default-soft px-3 py-2` in the custom-styles example).
class HeroColorPickerTrigger extends StatelessWidget {
  /// Creates a trigger.
  const HeroColorPickerTrigger({
    super.key,
    this.children = const <Widget>[],
    this.builder,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.focusNode,
    this.semanticLabel,
  });

  /// The trigger content, laid out in a row.
  final List<Widget> children;

  /// Builds the content from the trigger state; replaces [children].
  final HeroColorPickerTriggerBuilder? builder;

  /// Inner padding (none by default).
  final EdgeInsetsGeometry? padding;

  /// Background color (transparent by default).
  final Color? backgroundColor;

  /// Corner radius (`rounded-sm`).
  final BorderRadiusGeometry? borderRadius;

  /// Focus node of the trigger.
  final FocusNode? focusNode;

  /// Accessibility label; defaults to the text of the content.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroColorPickerControl? control = _HeroColorPickerControl.maybeOf(
      context,
    );
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    final bool disabled = control?.isDisabled ?? false;
    final bool open = control?.isOpen ?? false;
    final OutlinedBorder shape = theme.shape(
      borderRadius ?? BorderRadius.circular(theme.radii.sm),
    );
    final Color background =
        backgroundColor ?? theme.colors.defaultColor.withValues(alpha: 0);

    return HeroInteractable(
      onPressed: control?.onToggle,
      isDisabled: disabled,
      focusNode: focusNode,
      semanticsLabel: semanticLabel,
      builder: (BuildContext context, HeroInteractionState state, _) {
        final Widget content = builder != null
            ? builder!(
                context,
                HeroColorPickerTriggerState(
                  color: scope?.value.toColor() ?? HeroColorSwatch.transparent,
                  interaction: state,
                  isOpen: open,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                spacing: theme.spacing(3),
                children: children,
              );
        return Semantics(
          expanded: open,
          child: HeroFocusRing(
            visible: state.isFocusVisible,
            shape: shape,
            child: HeroDisabledOpacity(
              disabled: disabled,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: background),
                duration: theme.motion.resolve(context, HeroMotion.normal),
                curve: HeroMotion.smooth,
                builder: (BuildContext context, Color? fill, Widget? child) =>
                    DecoratedBox(
                      decoration: ShapeDecoration(color: fill, shape: shape),
                      child: child,
                    ),
                child: Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: DefaultTextStyle.merge(
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.foreground,
                    ),
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The popover of a [HeroColorPicker] (`ColorPicker.Popover`).
///
/// A 248 wide (`min-w-62`) panel in `--overlay` with the overlay shadow,
/// `min(32, radius × 2.5)` corners and 8 / 8 / 12 padding, stacking its
/// [children] with a 12 px gap and scrolling vertically when it does not
/// fit. The children sit on the standard surface. It is announced as a
/// dialog.
class HeroColorPickerPopover extends StatelessWidget {
  /// Creates a popover.
  const HeroColorPickerPopover({
    super.key,
    required this.children,
    this.placement = HeroPlacement.bottomStart,
    this.width,
    this.spacing,
    this.padding,
    this.backgroundColor,
    this.semanticLabel,
  });

  /// The popover content, usually color components.
  final List<Widget> children;

  /// Where the popover opens relative to the trigger (`bottom left`).
  final HeroPlacement placement;

  /// The popover width; defaults to 248 (`min-w-62`).
  final double? width;

  /// The gap between the children; defaults to 12 (`gap-3`).
  final double? spacing;

  /// The inner padding; defaults to `px-2 pt-2 pb-3`.
  final EdgeInsetsGeometry? padding;

  /// The background; defaults to `--overlay`.
  final Color? backgroundColor;

  /// Accessibility label of the dialog; defaults to "Color picker".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroShadow shadow = theme.shadows.overlay;
    final Color? inset = shadow.insetColor;
    final OutlinedBorder shape = theme.shapeAll(
      math.min(theme.spacing(8), theme.radii.radius * 2.5),
      side: inset == null
          ? BorderSide.none
          : BorderSide(
              color: inset.withValues(alpha: inset.a * 0.5),
              width: theme.spacing(0.25),
            ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: semanticLabel ?? 'Color picker',
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: backgroundColor ?? theme.colors.overlay,
          shape: shape,
          shadows: shadow.boxShadows,
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: shape,
            textDirection: Directionality.maybeOf(context),
          ),
          child: SizedBox(
            width: width ?? theme.spacing(62),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      padding ??
                      EdgeInsets.fromLTRB(
                        theme.spacing(2),
                        theme.spacing(2),
                        theme.spacing(2),
                        theme.spacing(3),
                      ),
                  child: HeroSurfaceScope(
                    variant: HeroSurfaceVariant.standard,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: spacing ?? theme.spacing(3),
                      children: children,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
