/// HeroUI's CloseButton: the small round dismiss button.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../button/button.dart';

/// The visual style of a [HeroCloseButton] (HeroUI's `variant` prop, whose
/// only value is `default`).
enum HeroCloseButtonVariant {
  /// `--default` fill with a `--muted` icon.
  standard,
}

/// A button for closing dialogs, modals or dismissing content.
///
/// A 24 × 24 circle (`rounded-xl`) on the `default` fill showing HeroUI's
/// close icon in `muted`. It darkens on hover (mouse), scales to 0.93 while
/// pressed, shows the focus ring for keyboard focus and is announced as a
/// button labelled "Close".
///
/// ```dart
/// HeroCloseButton(onPressed: () => Navigator.of(context).pop())
/// ```
///
/// Pass a [child] (usually a [HeroIcon]) to replace the icon, and a
/// [style] to change size, shape, colors or the press scale.
class HeroCloseButton extends StatelessWidget {
  /// Creates a close button.
  const HeroCloseButton({
    super.key,
    this.child,
    this.builder,
    this.onPressed,
    this.variant = HeroCloseButtonVariant.standard,
    this.isDisabled = false,
    this.isPending = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel = 'Close',
    this.style,
  });

  /// The content; defaults to HeroUI's close icon ([HeroIcons.close]).
  final Widget? child;

  /// Builds the content from the button state; replaces [child].
  final HeroButtonWidgetBuilder? builder;

  /// Called when the button is activated (`onPress`).
  final VoidCallback? onPressed;

  /// The visual style.
  final HeroCloseButtonVariant variant;

  /// Whether the button is disabled.
  final bool isDisabled;

  /// Whether the button ignores presses while staying focusable.
  final bool isPending;

  /// An optional focus node.
  final FocusNode? focusNode;

  /// Whether to focus the button when it is first built.
  final bool autofocus;

  /// Accessibility label (`aria-label`, "Close" by default).
  final String semanticLabel;

  /// Overrides for size ([HeroButtonStyle.height]), shape, colors, icon
  /// size and press scale. Padding and text style do not apply.
  final HeroButtonStyle? style;

  static const Widget _icon = HeroIcon(HeroIcons.close);

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroButtonStyle? style = this.style;
    final double dimension = style?.height ?? theme.spacing(6);
    final BorderRadius radius =
        (style?.borderRadius ?? BorderRadius.circular(theme.radii.xl)).resolve(
          Directionality.of(context),
        );
    final OutlinedBorder shape = theme.shape(radius);
    final BorderSide side = style?.side ?? BorderSide.none;

    return HeroInteractable(
      onPressed: onPressed,
      isDisabled: isDisabled,
      isPending: isPending,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticsLabel: semanticLabel,
      builder: (BuildContext context, HeroInteractionState state, _) {
        final Set<WidgetState> states = state.widgetStates;
        final Color background =
            style?.backgroundColor?.resolve(states) ??
            switch (variant) {
              // The pressed state keeps the hover fill of a mouse press.
              HeroCloseButtonVariant.standard =>
                state.isHovered
                    ? theme.colors.defaultHover
                    : theme.colors.defaultColor,
            };
        final Color foreground =
            style?.foregroundColor?.resolve(states) ?? theme.colors.muted;
        final Widget content = builder?.call(context, state) ?? child ?? _icon;
        return HeroPressScale(
          pressed: state.isPressed,
          scale: style?.pressedScale ?? 0.93,
          curve: HeroMotion.easeOutQuart,
          child: HeroFocusRing(
            visible: state.isFocusVisible,
            shape: shape,
            child: HeroDisabledOpacity(
              disabled: isDisabled,
              child: HeroButtonSurface(
                color: background,
                shape: shape,
                borderRadius: radius,
                side: side,
                borderWidths: side.style == BorderStyle.none
                    ? EdgeInsets.zero
                    : EdgeInsets.all(side.width),
                shadows: style?.shadows,
                child: SizedBox.square(
                  dimension: dimension,
                  child: Center(
                    // `transition: color 150ms ease-out`.
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: foreground),
                      duration: theme.motion.resolve(
                        context,
                        HeroMotion.normal,
                      ),
                      curve: HeroMotion.easeOut,
                      child: content,
                      builder:
                          (BuildContext context, Color? color, Widget? child) =>
                              IconTheme(
                                data: IconThemeData(
                                  color: color,
                                  size: style?.iconSize ?? theme.spacing(4),
                                ),
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(color: color),
                                  child: child!,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<HeroCloseButtonVariant>(
          'variant',
          variant,
          defaultValue: HeroCloseButtonVariant.standard,
        ),
      )
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(FlagProperty('isPending', value: isPending, ifTrue: 'pending'))
      ..add(StringProperty('semanticLabel', semanticLabel))
      ..add(
        ObjectFlagProperty<VoidCallback>(
          'onPressed',
          onPressed,
          ifNull: 'no handler',
        ),
      );
  }
}
