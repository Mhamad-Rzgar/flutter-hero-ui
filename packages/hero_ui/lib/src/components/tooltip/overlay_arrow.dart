import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The arrow of a tooltip or popover (`OverlayArrow`): HeroUI's 12 × 12
/// curved triangle (`M0 0C5.48 8 6.5 8 12 0Z`) pointing from the overlay
/// towards its trigger.
///
/// The shape points down for overlays above their trigger and is rotated
/// for the other [side]s. Use [HeroOverlayArrow.positioned] to place it on
/// the edge of an overlay at the trigger anchor point.
class HeroOverlayArrow extends StatelessWidget {
  /// Creates an arrow.
  const HeroOverlayArrow({
    super.key,
    required this.side,
    this.color,
    this.strokeColor,
    this.child,
  });

  /// The side of the trigger the overlay is on.
  final HeroOverlaySide side;

  /// Fill color; defaults to `overlay`.
  final Color? color;

  /// Outline color, if any.
  final Color? strokeColor;

  /// A custom arrow drawn pointing down; it is rotated like the default.
  final Widget? child;

  /// The quarter turns of an arrow for [side] (the shape points down).
  static int quarterTurnsFor(HeroOverlaySide side) => switch (side) {
    HeroOverlaySide.top => 0,
    HeroOverlaySide.bottom => 2,
    HeroOverlaySide.left => 3,
    HeroOverlaySide.right => 1,
  };

  /// Places [arrow] (a square of [extent]) just outside the edge of an
  /// overlay that faces its trigger, centered on the geometry's anchor
  /// point and kept within the overlay's edge.
  ///
  /// Use it as a child of a [Stack] (with `clipBehavior: Clip.none`) whose
  /// size is the overlay's.
  static Widget positioned({
    required HeroOverlayGeometry geometry,
    required double extent,
    required Widget arrow,
  }) {
    final Size size = geometry.rect.size;
    final Offset point = geometry.anchorPoint;
    double along(double center, double length) {
      final double start = center - extent / 2;
      if (length < extent) return start;
      return start.clamp(0.0, length - extent);
    }

    return switch (geometry.side) {
      HeroOverlaySide.top => Positioned(
        left: along(point.dx, size.width),
        bottom: -extent,
        width: extent,
        height: extent,
        child: arrow,
      ),
      HeroOverlaySide.bottom => Positioned(
        left: along(point.dx, size.width),
        top: -extent,
        width: extent,
        height: extent,
        child: arrow,
      ),
      HeroOverlaySide.left => Positioned(
        top: along(point.dy, size.height),
        right: -extent,
        width: extent,
        height: extent,
        child: arrow,
      ),
      HeroOverlaySide.right => Positioned(
        top: along(point.dy, size.height),
        left: -extent,
        width: extent,
        height: extent,
        child: arrow,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double extent = theme.spacing(3);
    return ExcludeSemantics(
      child: RotatedBox(
        quarterTurns: quarterTurnsFor(side),
        child: SizedBox.square(
          dimension: extent,
          child:
              child ??
              CustomPaint(
                painter: _HeroOverlayArrowPainter(
                  color: color ?? theme.colors.overlay,
                  strokeColor: strokeColor,
                  strokeWidth: theme.borderWidth,
                ),
              ),
        ),
      ),
    );
  }
}

class _HeroOverlayArrowPainter extends CustomPainter {
  const _HeroOverlayArrowPainter({
    required this.color,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final Color color;
  final Color? strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // The 12 × 12 view box of HeroUI's arrow.
    final double s = size.width / 12;
    final Path path = Path()
      ..moveTo(0, 0)
      ..cubicTo(5.48483 * s, 8 * s, 6.5 * s, 8 * s, 12 * s, 0)
      ..close();
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..drawPath(path, Paint()..color = color);
    final Color? stroke = strokeColor;
    if (stroke != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeroOverlayArrowPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
