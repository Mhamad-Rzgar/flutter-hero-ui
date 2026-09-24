import 'package:flutter/widgets.dart';

import '../theme/hero_theme.dart';
import '../tokens/hero_motion.dart';

/// Scales [child] down while [pressed], reproducing HeroUI's
/// `transform: scale(0.97)` press feedback with its
/// `transform 250ms ease` transition. This replaces Material ink ripples.
class HeroPressScale extends StatelessWidget {
  /// Scales [child] to [scale] while [pressed].
  const HeroPressScale({
    super.key,
    required this.pressed,
    required this.child,
    this.scale = 0.97,
    this.duration = HeroMotion.slow,
    this.curve = HeroMotion.smooth,
  });

  /// Whether the component is pressed.
  final bool pressed;

  /// Scale factor applied while pressed.
  final double scale;

  /// Transition duration.
  final Duration duration;

  /// Transition curve.
  final Curve curve;

  /// The scaled subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressed ? scale : 1,
      duration: HeroTheme.of(context).motion.resolve(context, duration),
      curve: curve,
      child: child,
    );
  }
}

/// Applies HeroUI's `status-disabled` look: [HeroThemeData.disabledOpacity]
/// when [disabled]. Pointer handling is left to the component.
class HeroDisabledOpacity extends StatelessWidget {
  /// Fades [child] when [disabled].
  const HeroDisabledOpacity({
    super.key,
    required this.disabled,
    required this.child,
  });

  /// Whether the subtree is disabled.
  final bool disabled;

  /// The faded subtree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Always wrap in Opacity so toggling [disabled] keeps the subtree (and
    // its state); an opacity of 1 paints the child directly.
    return Opacity(
      opacity: disabled ? HeroTheme.of(context).disabledOpacity : 1,
      child: child,
    );
  }
}
