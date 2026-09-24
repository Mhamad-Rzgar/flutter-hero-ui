import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'svg_path.dart';

/// One filled path of a [HeroIconData].
@immutable
class HeroIconPath {
  /// Creates an icon path from SVG path data.
  const HeroIconPath(this.data, {this.evenOdd = false});

  /// SVG path data (`d` attribute).
  final String data;

  /// Whether the path uses the `evenodd` fill rule.
  final bool evenOdd;
}

/// Vector data for a [HeroIcon]: one or more filled SVG paths in a
/// [viewBox]-sized coordinate space.
///
/// hero_ui ships HeroUI's built-in icons and a set of Gravity UI icons (the
/// icon family used throughout HeroUI's documentation) in `HeroIcons`.
/// Custom icons can be declared with SVG path data:
///
/// ```dart
/// const HeroIconData myIcon = HeroIconData(<HeroIconPath>[
///   HeroIconPath('M2 2h12v12H2z'),
/// ]);
/// ```
@immutable
class HeroIconData {
  /// Creates icon data.
  const HeroIconData(
    this.paths, {
    this.viewBoxWidth = 16,
    this.viewBoxHeight = 16,
    this.matchTextDirection = false,
  });

  /// Filled paths, painted in order.
  final List<HeroIconPath> paths;

  /// Width of the SVG view box.
  final double viewBoxWidth;

  /// Height of the SVG view box.
  final double viewBoxHeight;

  /// Whether the icon mirrors in right-to-left text (arrows, chevrons).
  final bool matchTextDirection;

  /// Returns a copy that mirrors in right-to-left text.
  HeroIconData directional() => HeroIconData(
    paths,
    viewBoxWidth: viewBoxWidth,
    viewBoxHeight: viewBoxHeight,
    matchTextDirection: true,
  );

  static final Expando<List<Path>> _partsCache = Expando<List<Path>>(
    'HeroIconData.parts',
  );

  /// Individual parsed paths, each with its own fill rule.
  List<Path> get parsedPaths {
    final List<Path>? cached = _partsCache[this];
    if (cached != null) return cached;
    final List<Path> parts = <Path>[
      for (final HeroIconPath p in paths)
        parseSvgPathData(
          p.data,
          fillType: p.evenOdd ? PathFillType.evenOdd : PathFillType.nonZero,
        ),
    ];
    _partsCache[this] = parts;
    return parts;
  }
}

/// Paints a [HeroIconData] vector icon.
///
/// Like an SVG with `fill="currentColor"`, the icon takes its color from
/// [color], then the ambient [IconTheme], then the ambient
/// [DefaultTextStyle]. The size defaults to the ambient [IconTheme] size or
/// 16 (Tailwind `size-4`).
class HeroIcon extends StatelessWidget {
  /// Creates an icon.
  const HeroIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// The icon to paint.
  final HeroIconData icon;

  /// Square size in logical pixels.
  final double? size;

  /// Fill color.
  final Color? color;

  /// Accessibility label. Icons without one are excluded from semantics
  /// (`aria-hidden`).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double resolvedSize = size ?? iconTheme.size ?? 16;
    final Color resolvedColor =
        color ??
        iconTheme.color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFF000000);
    final double opacity = iconTheme.opacity ?? 1;
    final TextDirection? direction = Directionality.maybeOf(context);
    final bool mirror =
        icon.matchTextDirection && direction == TextDirection.rtl;

    Widget result = CustomPaint(
      size: Size.square(resolvedSize),
      painter: _HeroIconPainter(
        icon: icon,
        color: resolvedColor.withValues(alpha: resolvedColor.a * opacity),
        mirror: mirror,
      ),
    );
    result = SizedBox.square(dimension: resolvedSize, child: result);

    if (semanticLabel == null) {
      return ExcludeSemantics(child: result);
    }
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: result),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('size', size, defaultValue: null))
      ..add(ColorProperty('color', color, defaultValue: null));
  }
}

class _HeroIconPainter extends CustomPainter {
  const _HeroIconPainter({
    required this.icon,
    required this.color,
    required this.mirror,
  });

  final HeroIconData icon;
  final Color color;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / icon.viewBoxWidth;
    final double scaleY = size.height / icon.viewBoxHeight;
    canvas.save();
    if (mirror) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.scale(scale, scaleY);
    final Paint paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    for (final Path p in icon.parsedPaths) {
      canvas.drawPath(p, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeroIconPainter oldDelegate) =>
      oldDelegate.icon != icon ||
      oldDelegate.color != color ||
      oldDelegate.mirror != mirror;
}
