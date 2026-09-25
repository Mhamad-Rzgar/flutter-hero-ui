import 'package:flutter/widgets.dart';

import '../theme/hero_theme.dart';
import '../tokens/hero_motion.dart';

/// Expands and collapses [child] like HeroUI's disclosure panels
/// (`.disclosure__content`, `.accordion__panel`).
///
/// The height animates between zero and the child's height over 200 ms with
/// `--ease-out-quad` while the opacity fades over 200 ms with Tailwind's
/// `ease-out`; the content is clipped. Collapsing plays the same curves in
/// reverse time, like a CSS transition back to the start value. A collapsed
/// (or collapsing) child is removed from focus traversal and semantics but
/// keeps its state. Under reduced motion the change is instant.
///
/// ```dart
/// HeroCollapsible(
///   isExpanded: expanded,
///   child: const Padding(
///     padding: EdgeInsets.all(8),
///     child: Text('Panel content'),
///   ),
/// )
/// ```
class HeroCollapsible extends StatefulWidget {
  /// Creates a collapsible region.
  const HeroCollapsible({
    super.key,
    required this.isExpanded,
    required this.child,
    this.duration = HeroMotion.medium,
    this.sizeCurve = HeroMotion.easeOutQuad,
    this.opacityCurve = HeroMotion.easeOut,
  });

  /// Whether the child is shown.
  final bool isExpanded;

  /// The content.
  final Widget child;

  /// Length of the height and opacity transitions.
  final Duration duration;

  /// Easing of the height transition.
  final Curve sizeCurve;

  /// Easing of the opacity transition.
  final Curve opacityCurve;

  @override
  State<HeroCollapsible> createState() => _HeroCollapsibleState();
}

class _HeroCollapsibleState extends State<HeroCollapsible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.isExpanded ? 1 : 0,
  );
  late CurvedAnimation _size = _curve(widget.sizeCurve);
  late CurvedAnimation _opacity = _curve(widget.opacityCurve);

  CurvedAnimation _curve(Curve curve) => CurvedAnimation(
    parent: _controller,
    curve: curve,
    // A CSS transition back to zero eases forward in time as well.
    reverseCurve: curve.flipped,
  );

  @override
  void didUpdateWidget(HeroCollapsible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sizeCurve != widget.sizeCurve) {
      _size.dispose();
      _size = _curve(widget.sizeCurve);
    }
    if (oldWidget.opacityCurve != widget.opacityCurve) {
      _opacity.dispose();
      _opacity = _curve(widget.opacityCurve);
    }
    if (oldWidget.isExpanded != widget.isExpanded) {
      final Duration duration = HeroTheme.of(
        context,
      ).motion.resolve(context, widget.duration);
      if (duration == Duration.zero) {
        _controller.value = widget.isExpanded ? 1 : 0;
      } else {
        _controller.duration = duration;
        if (widget.isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _opacity.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool expanded = widget.isExpanded;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final bool hidden = _controller.value == 0 && !expanded;
        return ExcludeFocus(
          excluding: !expanded,
          child: ExcludeSemantics(
            excluding: !expanded,
            child: Visibility(
              visible: !hidden,
              maintainState: true,
              child: ClipRect(
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  heightFactor: _size.value.clamp(0.0, 1.0),
                  child: Opacity(
                    opacity: _opacity.value.clamp(0.0, 1.0),
                    child: child,
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
