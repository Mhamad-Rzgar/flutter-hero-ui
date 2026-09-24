/// HeroUI's Spinner: a rotating loading indicator.
library;

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// The size of a [HeroSpinner] (HeroUI's `size` prop).
enum HeroSpinnerSize {
  /// 16 × 16 (`size-4`).
  sm,

  /// 24 × 24 (`size-6`), the default.
  md,

  /// 32 × 32 (`size-8`).
  lg,

  /// 40 × 40 (`size-10`).
  xl,
}

/// The color of a [HeroSpinner] (HeroUI's `color` prop).
enum HeroSpinnerColor {
  /// Inherits the ambient icon or text color (`currentColor`).
  current,

  /// `--accent`, the default.
  accent,

  /// `--success`.
  success,

  /// `--warning`.
  warning,

  /// `--danger`.
  danger,
}

/// A loading indicator that shows a pending state.
///
/// Reproduces HeroUI's spinner glyph: two arcs forming a ring that fade
/// from the spinner color to transparent, turning once every [period]
/// (`animate-spin-fast`, 750 ms linear). Under reduced motion the glyph
/// stays still (`motion-reduce:animate-none`).
///
/// ```dart
/// const HeroSpinner(size: HeroSpinnerSize.sm, color: HeroSpinnerColor.current)
/// ```
///
/// Screen readers announce it as a status with [semanticLabel] (`Loading`).
class HeroSpinner extends StatefulWidget {
  /// Creates a spinner.
  const HeroSpinner({
    super.key,
    this.size = HeroSpinnerSize.md,
    this.color = HeroSpinnerColor.accent,
    this.colorOverride,
    this.period = HeroMotion.spin,
    this.semanticLabel = 'Loading',
  });

  /// The spinner size. Defaults to [HeroSpinnerSize.md] (24).
  final HeroSpinnerSize size;

  /// The color role. Defaults to [HeroSpinnerColor.accent].
  final HeroSpinnerColor color;

  /// A custom color that replaces [color] (HeroUI's `text-*` class
  /// override).
  final Color? colorOverride;

  /// Duration of one full turn. Defaults to 750 ms; HeroUI's docs show
  /// 1.5 s (slow) and 0.4 s (fast) variations.
  final Duration period;

  /// Accessibility label announced for the status (`aria-label`).
  final String semanticLabel;

  /// Returns the side length of [size] in logical pixels for [theme].
  static double dimensionOf(HeroThemeData theme, HeroSpinnerSize size) {
    return switch (size) {
      HeroSpinnerSize.sm => theme.spacing(4),
      HeroSpinnerSize.md => theme.spacing(6),
      HeroSpinnerSize.lg => theme.spacing(8),
      HeroSpinnerSize.xl => theme.spacing(10),
    };
  }

  @override
  State<HeroSpinner> createState() => _HeroSpinnerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HeroSpinnerSize>('size', size))
      ..add(EnumProperty<HeroSpinnerColor>('color', color))
      ..add(ColorProperty('colorOverride', colorOverride, defaultValue: null))
      ..add(
        DiagnosticsProperty<Duration>(
          'period',
          period,
          defaultValue: HeroMotion.spin,
        ),
      );
  }
}

class _HeroSpinnerState extends State<HeroSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = HeroTheme.of(context).motion.shouldReduceMotion(context);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(HeroSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      if (_controller.isAnimating) {
        _controller
          ..stop()
          ..repeat();
      }
    }
  }

  void _syncAnimation() {
    if (_reduceMotion) {
      _controller
        ..stop()
        ..value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _resolveColor(HeroThemeData theme) {
    final Color? override = widget.colorOverride;
    if (override != null) return override;
    return switch (widget.color) {
      HeroSpinnerColor.current =>
        IconTheme.of(context).color ??
            DefaultTextStyle.of(context).style.color ??
            theme.colors.foreground,
      HeroSpinnerColor.accent => theme.colors.accent,
      HeroSpinnerColor.success => theme.colors.success,
      HeroSpinnerColor.warning => theme.colors.warning,
      HeroSpinnerColor.danger => theme.colors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final double dimension = HeroSpinner.dimensionOf(theme, widget.size);
    final Widget glyph = RepaintBoundary(
      child: CustomPaint(
        size: Size.square(dimension),
        painter: _HeroSpinnerPainter(color: _resolveColor(theme)),
      ),
    );
    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: dimension,
          child: _reduceMotion
              ? glyph
              : RotationTransition(turns: _controller, child: glyph),
        ),
      ),
    );
  }
}

/// Paints HeroUI's spinner glyph (a 24 × 24 view box).
class _HeroSpinnerPainter extends CustomPainter {
  const _HeroSpinnerPainter({required this.color});

  final Color color;

  static const double _viewBox = 24;

  /// Both arcs are translated by (1.5, 1.625) in the SVG.
  static const Offset _translate = Offset(1.5, 1.625);

  /// The leading arc, filled from full color at the top to 55%.
  static final Path _leading = parseSvgPathData(
    'M8.749.021a1.5 1.5 0 0 1 .497 2.958A7.5 7.5 0 0 0 3 10.375a7.5 7.5 0 0 0 '
    '7.5 7.5v3c-5.799 0-10.5-4.7-10.5-10.5C0 5.23 3.726.865 8.749.021',
  );

  /// The trailing arc, filled from transparent at the top to 55%.
  static final Path _trailing = parseSvgPathData(
    'M15.392 2.673a1.5 1.5 0 0 1 2.119-.115A10.48 10.48 0 0 1 21 10.375c0 '
    '5.8-4.701 10.5-10.5 10.5v-3a7.5 7.5 0 0 0 5.007-13.084a1.5 1.5 0 0 '
    '1-.115-2.118',
  );

  // Tight bounding boxes of the two arcs. SVG gradients use
  // `objectBoundingBox` units, so the gradient stops are placed relative to
  // these boxes (`y1="5.271%" y2="91.793%"` and `y1="15.24%" y2="87.15%"`).
  static const Rect _leadingBounds = Rect.fromLTRB(0, 0, 10.5, 20.875);
  static const Rect _trailingBounds = Rect.fromLTRB(10.5, 2.1742, 21, 20.875);

  static Offset _along(Rect bounds, double fraction) =>
      Offset(bounds.center.dx, bounds.top + bounds.height * fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final Color faded = color.withValues(alpha: color.a * 0.55);
    final Color clear = color.withValues(alpha: 0);
    canvas
      ..save()
      ..scale(size.width / _viewBox, size.height / _viewBox)
      ..translate(_translate.dx, _translate.dy);
    canvas.drawPath(
      _leading,
      Paint()
        ..isAntiAlias = true
        ..shader = ui.Gradient.linear(
          _along(_leadingBounds, 0.05271),
          _along(_leadingBounds, 0.91793),
          <Color>[color, faded],
        ),
    );
    canvas.drawPath(
      _trailing,
      Paint()
        ..isAntiAlias = true
        ..shader = ui.Gradient.linear(
          _along(_trailingBounds, 0.1524),
          _along(_trailingBounds, 0.8715),
          <Color>[clear, faded],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeroSpinnerPainter oldDelegate) =>
      oldDelegate.color != color;
}
