import 'package:flutter/rendering.dart';

import '../../foundation/foundation.dart';

/// HeroUI's transparency checkerboard, painted behind colors that may be
/// translucent (swatches, the color slider track and its start cap).
///
/// It reproduces `repeating-conic-gradient(#efefef 0% 25%, #f7f7f7 0% 50%)
/// 50% / 16px 16px`: 16 px tiles of four 8 px squares, [dark] top-right and
/// bottom-left, [light] top-left and bottom-right, with a tile centred on
/// the painted box. The colors are fixed in HeroUI's CSS (not theme tokens)
/// so transparency reads the same in light and dark themes.
abstract final class HeroCheckerboard {
  /// The lighter squares (`#f7f7f7`).
  static const Color light = Color(0xFFF7F7F7);

  /// The darker squares (`#efefef`).
  static const Color dark = Color(0xFFEFEFEF);

  /// Paints the checkerboard into [rect] with tiles of [tileSize] (two
  /// squares per side) centred on [rect]. Clip the canvas to the shape of
  /// the component first.
  static void paint(Canvas canvas, Rect rect, {required double tileSize}) {
    canvas.drawRect(rect, Paint()..color = light);
    final double square = tileSize / 2;
    if (square <= 0) return;
    final Offset center = rect.center;
    final int firstColumn = ((rect.left - center.dx) / square).floor();
    final int lastColumn = ((rect.right - center.dx) / square).ceil();
    final int firstRow = ((rect.top - center.dy) / square).floor();
    final int lastRow = ((rect.bottom - center.dy) / square).ceil();
    final Path squares = Path();
    for (int row = firstRow; row < lastRow; row++) {
      for (int column = firstColumn; column < lastColumn; column++) {
        if ((row + column).isEven) continue;
        squares.addRect(
          Rect.fromLTWH(
            center.dx + column * square,
            center.dy + row * square,
            square,
            square,
          ).intersect(rect),
        );
      }
    }
    canvas.drawPath(squares, Paint()..color = dark);
  }
}

/// The color of the 1 px inset ring HeroUI draws inside color swatches, the
/// color area and the color slider track so light colors stay visible on
/// light backgrounds (`box-shadow: inset 0 0 0 1px rgba(0,0,0,.1)`): the
/// `black` token at 10%.
Color heroColorInsetRing(HeroColors colors) =>
    colors.black.withValues(alpha: colors.black.a * 0.1);
