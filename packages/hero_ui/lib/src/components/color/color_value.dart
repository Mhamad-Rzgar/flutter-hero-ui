import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A color space a color value keeps its channels in (React Aria's
/// `ColorSpace`).
enum HeroColorSpace {
  /// Red, green and blue (0–255 each).
  rgb,

  /// Hue (0–360), saturation and lightness (0–100).
  hsl,

  /// Hue (0–360), saturation and brightness (0–100), also known as HSV.
  hsb;

  /// The three color channels of this space, in order (alpha excluded).
  List<HeroColorChannel> get channels => switch (this) {
    rgb => const <HeroColorChannel>[
      HeroColorChannel.red,
      HeroColorChannel.green,
      HeroColorChannel.blue,
    ],
    hsl => const <HeroColorChannel>[
      HeroColorChannel.hue,
      HeroColorChannel.saturation,
      HeroColorChannel.lightness,
    ],
    hsb => const <HeroColorChannel>[
      HeroColorChannel.hue,
      HeroColorChannel.saturation,
      HeroColorChannel.brightness,
    ],
  };
}

/// A channel of a color value (React Aria's `ColorChannel`).
enum HeroColorChannel {
  /// Hue in degrees (hsl, hsb).
  hue,

  /// Saturation in percent (hsl, hsb).
  saturation,

  /// Brightness in percent (hsb).
  brightness,

  /// Lightness in percent (hsl).
  lightness,

  /// Red, 0–255 (rgb).
  red,

  /// Green, 0–255 (rgb).
  green,

  /// Blue, 0–255 (rgb).
  blue,

  /// Opacity, 0–1 (every space).
  alpha;

  /// The value range, step and page size of this channel.
  HeroChannelRange get range => switch (this) {
    hue => const HeroChannelRange(min: 0, max: 360, step: 1, pageSize: 15),
    saturation || brightness || lightness => const HeroChannelRange(
      min: 0,
      max: 100,
      step: 1,
      pageSize: 10,
    ),
    red ||
    green ||
    blue => const HeroChannelRange(min: 0, max: 255, step: 1, pageSize: 17),
    alpha => const HeroChannelRange(min: 0, max: 1, step: 0.01, pageSize: 0.1),
  };

  /// The English name of the channel ("Hue", "Saturation", ...), used as
  /// the default accessibility label.
  String get label => switch (this) {
    hue => 'Hue',
    saturation => 'Saturation',
    brightness => 'Brightness',
    lightness => 'Lightness',
    red => 'Red',
    green => 'Green',
    blue => 'Blue',
    alpha => 'Alpha',
  };

  /// The color space a channel requires, or null for channels shared by
  /// several spaces (hue, saturation and alpha).
  HeroColorSpace? get requiredSpace => switch (this) {
    red || green || blue => HeroColorSpace.rgb,
    lightness => HeroColorSpace.hsl,
    brightness => HeroColorSpace.hsb,
    hue || saturation || alpha => null,
  };

  /// Whether this channel exists in [space].
  bool isIn(HeroColorSpace space) =>
      this == alpha || space.channels.contains(this);

  /// The space a slider or field editing this channel works in: [space]
  /// when the channel exists there, else the channel's own space (hue and
  /// saturation fall back to hsl), like HeroUI's ColorSlider auto-correction.
  HeroColorSpace resolveSpace(HeroColorSpace? space) {
    final HeroColorSpace? required = requiredSpace;
    if (required != null) return required;
    if (space == null) return HeroColorSpace.hsl;
    if (this == alpha || space != HeroColorSpace.rgb) return space;
    return HeroColorSpace.hsl;
  }
}

/// A textual color format (React Aria's `ColorFormat`).
enum HeroColorFormat {
  /// `#RRGGBB`.
  hex,

  /// `#RRGGBBAA`.
  hexa,

  /// `rgb(r, g, b)`.
  rgb,

  /// `rgba(r, g, b, a)`.
  rgba,

  /// `hsl(h, s%, l%)`.
  hsl,

  /// `hsla(h, s%, l%, a)`.
  hsla,

  /// `hsb(h, s%, b%)`.
  hsb,

  /// `hsba(h, s%, b%, a)`.
  hsba,

  /// A CSS color: `rgba(...)` for rgb and hsb values, `hsla(...)` for hsl.
  css,
}

/// The range, keyboard step and page size of a color channel.
@immutable
class HeroChannelRange {
  /// Creates a channel range.
  const HeroChannelRange({
    required this.min,
    required this.max,
    required this.step,
    required this.pageSize,
  });

  /// The minimum value.
  final double min;

  /// The maximum value.
  final double max;

  /// The arrow-key step.
  final double step;

  /// The Page Up / Page Down (and Shift + arrow) step.
  final double pageSize;

  /// Clamps [value] into the range.
  double clamp(double value) => value.clamp(min, max);

  /// The position of [value] in the range, from 0 to 1.
  double fraction(double value) =>
      max == min ? 0 : ((value - min) / (max - min)).clamp(0.0, 1.0);

  /// The value at [fraction] (0–1) of the range.
  double lerp(double fraction) => min + (max - min) * fraction.clamp(0.0, 1.0);

  /// Rounds [value] to the nearest [step] from [min].
  double snap(double value) {
    final double snapped = min + ((value - min) / step).round() * step;
    // Remove floating point noise such as 0.30000000000000004.
    return clamp(double.parse(snapped.toStringAsFixed(6)));
  }

  @override
  bool operator ==(Object other) =>
      other is HeroChannelRange &&
      other.min == min &&
      other.max == max &&
      other.step == step &&
      other.pageSize == pageSize;

  @override
  int get hashCode => Object.hash(min, max, step, pageSize);

  @override
  String toString() =>
      'HeroChannelRange($min–$max, step $step, page $pageSize)';
}

/// A color value that keeps its channels in a [HeroColorSpace], the
/// counterpart of React Aria's `Color` object.
///
/// Flutter's [Color] only stores red, green and blue, so a gray loses its
/// hue and black loses hue and saturation. The color components keep a
/// [HeroColorValue] internally so thumbs stay where the user left them, and
/// report plain [Color]s to their callers.
///
/// Channels use React Aria's units: hue in degrees (0–360), saturation,
/// lightness and brightness in percent (0–100), red, green and blue from 0
/// to 255 and alpha from 0 to 1.
///
/// ```dart
/// final HeroColorValue color = HeroColorValue.parse('hsl(200, 100%, 50%)');
/// color.channelValue(HeroColorChannel.hue); // 200
/// color.withChannelValue(HeroColorChannel.lightness, 25).toColor();
/// color.toFormat(HeroColorFormat.hex); // '#00AAFF'
/// ```
@immutable
class HeroColorValue {
  const HeroColorValue._(this.space, this._c1, this._c2, this._c3, this.alpha);

  /// An rgb color with channels from 0 to 255 and [alpha] from 0 to 1.
  const HeroColorValue.rgb(
    double red,
    double green,
    double blue, [
    double alpha = 1,
  ]) : this._(HeroColorSpace.rgb, red, green, blue, alpha);

  /// An hsl color: [hue] in degrees, [saturation] and [lightness] in
  /// percent, [alpha] from 0 to 1.
  const HeroColorValue.hsl(
    double hue,
    double saturation,
    double lightness, [
    double alpha = 1,
  ]) : this._(HeroColorSpace.hsl, hue, saturation, lightness, alpha);

  /// An hsb color: [hue] in degrees, [saturation] and [brightness] in
  /// percent, [alpha] from 0 to 1.
  const HeroColorValue.hsb(
    double hue,
    double saturation,
    double brightness, [
    double alpha = 1,
  ]) : this._(HeroColorSpace.hsb, hue, saturation, brightness, alpha);

  /// Converts a Flutter [Color] into [space].
  factory HeroColorValue.fromColor(
    Color color, {
    HeroColorSpace space = HeroColorSpace.rgb,
  }) {
    final HeroColorValue rgb = HeroColorValue.rgb(
      color.r * 255,
      color.g * 255,
      color.b * 255,
      color.a,
    );
    return rgb.toSpace(space);
  }

  /// Converts a Flutter [HSVColor] (hsb with fractions) into a value.
  factory HeroColorValue.fromHSVColor(HSVColor color) => HeroColorValue.hsb(
    color.hue,
    color.saturation * 100,
    color.value * 100,
    color.alpha,
  );

  /// Converts a Flutter [HSLColor] into a value.
  factory HeroColorValue.fromHSLColor(HSLColor color) => HeroColorValue.hsl(
    color.hue,
    color.saturation * 100,
    color.lightness * 100,
    color.alpha,
  );

  /// Parses a CSS-like color string: `#RGB`, `#RGBA`, `#RRGGBB`,
  /// `#RRGGBBAA`, `rgb()`, `rgba()`, `hsl()`, `hsla()`, `hsb()` and
  /// `hsba()` (React Aria's `parseColor`). The value keeps the space of the
  /// notation (hex is rgb).
  ///
  /// Throws a [FormatException] when [value] is not a color.
  static HeroColorValue parse(String value) {
    final HeroColorValue? color = tryParse(value);
    if (color == null) {
      throw FormatException('Invalid color value', value);
    }
    return color;
  }

  /// Like [parse], but returns null for an invalid color.
  static HeroColorValue? tryParse(String value) {
    final String text = value.trim().toLowerCase();
    if (text.startsWith('#')) return _parseHex(text.substring(1));
    final RegExpMatch? match = _functional.firstMatch(text);
    if (match == null) return null;
    final String name = match.group(1)!;
    final List<String> parts = match
        .group(2)!
        .split(RegExp(r'\s*[,/]\s*|\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    final bool withAlpha = name.endsWith('a');
    if (parts.length != (withAlpha ? 4 : 3) && parts.length != 4) return null;
    final List<double?> numbers = <double?>[
      for (final String part in parts) _number(part),
    ];
    if (numbers.contains(null)) return null;
    final double alpha = parts.length == 4
        ? (parts[3].endsWith('%') ? numbers[3]! / 100 : numbers[3]!)
        : 1;
    if (alpha < 0 || alpha > 1) return null;
    final double a = numbers[0]!;
    final double b = numbers[1]!;
    final double c = numbers[2]!;
    switch (name) {
      case 'rgb' || 'rgba':
        if (<double>[a, b, c].any((double v) => v < 0 || v > 255)) {
          return null;
        }
        return HeroColorValue.rgb(a, b, c, alpha);
      case 'hsl' || 'hsla' || 'hsb' || 'hsba':
        if (b < 0 || b > 100 || c < 0 || c > 100) return null;
        final double hue = _normalizeHue(a);
        return name.startsWith('hsl')
            ? HeroColorValue.hsl(hue, b, c, alpha)
            : HeroColorValue.hsb(hue, b, c, alpha);
    }
    return null;
  }

  static final RegExp _functional = RegExp(
    r'^(rgba?|hsla?|hsba?)\(\s*([^)]*)\s*\)$',
  );

  static double? _number(String part) {
    final String digits = part.endsWith('%') || part.endsWith('°')
        ? part.substring(0, part.length - 1)
        : part.endsWith('deg')
        ? part.substring(0, part.length - 3)
        : part;
    return double.tryParse(digits);
  }

  static HeroColorValue? _parseHex(String hex) {
    if (!RegExp(r'^[0-9a-f]+$').hasMatch(hex)) return null;
    final List<int> channels;
    switch (hex.length) {
      case 3 || 4:
        channels = <int>[
          for (final String digit in hex.split(''))
            int.parse('$digit$digit', radix: 16),
        ];
      case 6 || 8:
        channels = <int>[
          for (int i = 0; i < hex.length; i += 2)
            int.parse(hex.substring(i, i + 2), radix: 16),
        ];
      default:
        return null;
    }
    return HeroColorValue.rgb(
      channels[0].toDouble(),
      channels[1].toDouble(),
      channels[2].toDouble(),
      channels.length == 4 ? channels[3] / 255 : 1,
    );
  }

  /// The color space the channels are kept in.
  final HeroColorSpace space;

  final double _c1;
  final double _c2;
  final double _c3;

  /// The opacity, from 0 to 1.
  final double alpha;

  /// The three channels of [space] followed by alpha.
  List<HeroColorChannel> get channels => <HeroColorChannel>[
    ...space.channels,
    HeroColorChannel.alpha,
  ];

  /// The value of [channel]. Channels outside [space] are read from a
  /// converted copy (hue and saturation from hsb or hsl, lightness from hsl,
  /// brightness from hsb, red, green and blue from rgb).
  double channelValue(HeroColorChannel channel) {
    if (channel == HeroColorChannel.alpha) return alpha;
    final int index = space.channels.indexOf(channel);
    if (index < 0) return toSpace(_spaceFor(channel)).channelValue(channel);
    return switch (index) {
      0 => _c1,
      1 => _c2,
      _ => _c3,
    };
  }

  /// Returns a copy with [channel] set to [value] (clamped to the channel
  /// range). A channel outside [space] is set on a converted copy that is
  /// converted back.
  HeroColorValue withChannelValue(HeroColorChannel channel, double value) {
    final double v = channel.range.clamp(value);
    if (channel == HeroColorChannel.alpha) {
      return HeroColorValue._(space, _c1, _c2, _c3, v);
    }
    final int index = space.channels.indexOf(channel);
    if (index < 0) {
      return toSpace(
        _spaceFor(channel),
      ).withChannelValue(channel, v).toSpace(space);
    }
    return HeroColorValue._(
      space,
      index == 0 ? v : _c1,
      index == 1 ? v : _c2,
      index == 2 ? v : _c3,
      alpha,
    );
  }

  /// Returns a copy with the given [alpha].
  HeroColorValue withAlpha(double alpha) =>
      withChannelValue(HeroColorChannel.alpha, alpha);

  HeroColorSpace _spaceFor(HeroColorChannel channel) =>
      channel.requiredSpace ??
      (space == HeroColorSpace.rgb ? HeroColorSpace.hsb : space);

  /// Converts to [target], keeping the hue between hsl and hsb.
  HeroColorValue toSpace(HeroColorSpace target) {
    if (target == space) return this;
    switch ((space, target)) {
      case (HeroColorSpace.hsb, HeroColorSpace.hsl):
        final double s = _c2 / 100;
        final double v = _c3 / 100;
        final double l = v * (1 - s / 2);
        final double sl = l <= 0 || l >= 1 ? 0 : (v - l) / math.min(l, 1 - l);
        return HeroColorValue.hsl(_c1, sl * 100, l * 100, alpha);
      case (HeroColorSpace.hsl, HeroColorSpace.hsb):
        final double s = _c2 / 100;
        final double l = _c3 / 100;
        final double v = l + s * math.min(l, 1 - l);
        final double sv = v <= 0 ? 0 : 2 * (1 - l / v);
        return HeroColorValue.hsb(_c1, sv * 100, v * 100, alpha);
      case (_, HeroColorSpace.rgb):
        return _toRgb();
      case (HeroColorSpace.rgb, _):
        return _rgbTo(target);
      default:
        return _toRgb().toSpace(target);
    }
  }

  HeroColorValue _toRgb() {
    final double h = _c1 % 360;
    final double s = _c2 / 100;
    final double third = _c3 / 100;
    double channel(int n) {
      final double k = (n + h / 30) % 12;
      if (space == HeroColorSpace.hsl) {
        final double a = s * math.min(third, 1 - third);
        return third - a * math.max(-1, math.min(k - 3, math.min(9 - k, 1)));
      }
      final double kv = (n + h / 60) % 6;
      return third - third * s * math.max(0, math.min(kv, math.min(4 - kv, 1)));
    }

    if (space == HeroColorSpace.hsl) {
      return HeroColorValue.rgb(
        channel(0) * 255,
        channel(8) * 255,
        channel(4) * 255,
        alpha,
      );
    }
    return HeroColorValue.rgb(
      channel(5) * 255,
      channel(3) * 255,
      channel(1) * 255,
      alpha,
    );
  }

  HeroColorValue _rgbTo(HeroColorSpace target) {
    final double r = _c1 / 255;
    final double g = _c2 / 255;
    final double b = _c3 / 255;
    final double max = math.max(r, math.max(g, b));
    final double min = math.min(r, math.min(g, b));
    final double delta = max - min;
    double hue = 0;
    if (delta > 1e-12) {
      if (max == r) {
        hue = 60 * (((g - b) / delta) % 6);
      } else if (max == g) {
        hue = 60 * ((b - r) / delta + 2);
      } else {
        hue = 60 * ((r - g) / delta + 4);
      }
    }
    hue = _normalizeHue(hue);
    if (target == HeroColorSpace.hsb) {
      final double s = max <= 0 ? 0 : delta / max;
      return HeroColorValue.hsb(hue, s * 100, max * 100, alpha);
    }
    final double l = (max + min) / 2;
    final double s = delta <= 1e-12 ? 0 : delta / (1 - (2 * l - 1).abs());
    return HeroColorValue.hsl(hue, s * 100, l * 100, alpha);
  }

  static double _normalizeHue(double hue) {
    final double h = hue % 360;
    return h < 0 ? h + 360 : h;
  }

  /// The Flutter [Color] of this value (sRGB, full float precision).
  Color toColor() {
    final HeroColorValue rgb = toSpace(HeroColorSpace.rgb);
    return Color.from(
      alpha: alpha.clamp(0.0, 1.0),
      red: (rgb._c1 / 255).clamp(0.0, 1.0),
      green: (rgb._c2 / 255).clamp(0.0, 1.0),
      blue: (rgb._c3 / 255).clamp(0.0, 1.0),
    );
  }

  /// Converts to a Flutter [HSVColor], keeping the hue.
  HSVColor toHSVColor() {
    final HeroColorValue hsb = toSpace(HeroColorSpace.hsb);
    return HSVColor.fromAHSV(
      alpha.clamp(0.0, 1.0),
      hsb._c1.clamp(0.0, 360.0),
      (hsb._c2 / 100).clamp(0.0, 1.0),
      (hsb._c3 / 100).clamp(0.0, 1.0),
    );
  }

  /// Converts to a Flutter [HSLColor], keeping the hue.
  HSLColor toHSLColor() {
    final HeroColorValue hsl = toSpace(HeroColorSpace.hsl);
    return HSLColor.fromAHSL(
      alpha.clamp(0.0, 1.0),
      hsl._c1.clamp(0.0, 360.0),
      (hsl._c2 / 100).clamp(0.0, 1.0),
      (hsl._c3 / 100).clamp(0.0, 1.0),
    );
  }

  /// The 24-bit `0xRRGGBB` integer of this color (alpha ignored).
  int toHexInt() {
    final HeroColorValue rgb = toSpace(HeroColorSpace.rgb);
    int byte(double v) => v.round().clamp(0, 255);
    return byte(rgb._c1) << 16 | byte(rgb._c2) << 8 | byte(rgb._c3);
  }

  /// Formats this value (React Aria's `Color.toString(format)`).
  ///
  /// Hex is uppercase; rgb channels are rounded to integers; hue,
  /// saturation, lightness and brightness keep up to two decimals; alpha
  /// keeps up to two decimals.
  String toFormat(HeroColorFormat format) {
    String hexByte(int v) => v.toRadixString(16).padLeft(2, '0');
    switch (format) {
      case HeroColorFormat.hex:
        return '#${toHexInt().toRadixString(16).padLeft(6, '0')}'.toUpperCase();
      case HeroColorFormat.hexa:
        return '#${toHexInt().toRadixString(16).padLeft(6, '0')}'
                '${hexByte((alpha * 255).round().clamp(0, 255))}'
            .toUpperCase();
      case HeroColorFormat.rgb || HeroColorFormat.rgba:
        final HeroColorValue rgb = toSpace(HeroColorSpace.rgb);
        final String channels =
            '${rgb._c1.round()}, ${rgb._c2.round()}, ${rgb._c3.round()}';
        return format == HeroColorFormat.rgb
            ? 'rgb($channels)'
            : 'rgba($channels, ${_trim(alpha, 2)})';
      case HeroColorFormat.hsl || HeroColorFormat.hsla:
        final HeroColorValue hsl = toSpace(HeroColorSpace.hsl);
        final String channels =
            '${_trim(hsl._c1, 2)}, ${_trim(hsl._c2, 2)}%, '
            '${_trim(hsl._c3, 2)}%';
        return format == HeroColorFormat.hsl
            ? 'hsl($channels)'
            : 'hsla($channels, ${_trim(alpha, 2)})';
      case HeroColorFormat.hsb || HeroColorFormat.hsba:
        final HeroColorValue hsb = toSpace(HeroColorSpace.hsb);
        final String channels =
            '${_trim(hsb._c1, 2)}, ${_trim(hsb._c2, 2)}%, '
            '${_trim(hsb._c3, 2)}%';
        return format == HeroColorFormat.hsb
            ? 'hsb($channels)'
            : 'hsba($channels, ${_trim(alpha, 2)})';
      case HeroColorFormat.css:
        return toFormat(
          space == HeroColorSpace.hsl
              ? HeroColorFormat.hsla
              : HeroColorFormat.rgba,
        );
    }
  }

  /// Formats [space] notation without alpha (`hsl(...)`, `hsb(...)` or
  /// `rgb(...)`), like `toString(colorSpace)` in the docs examples.
  String toSpaceString() => toFormat(switch (space) {
    HeroColorSpace.rgb => HeroColorFormat.rgb,
    HeroColorSpace.hsl => HeroColorFormat.hsl,
    HeroColorSpace.hsb => HeroColorFormat.hsb,
  });

  /// Formats the value of [channel] for display: hue as degrees (`"200°"`),
  /// saturation, lightness, brightness and alpha as percentages (`"50%"`)
  /// and red, green and blue as numbers (`"255"`) (React Aria's
  /// `formatChannelValue`). Hue and rgb keep up to two decimals, the
  /// precision React Aria converts colors with (`"208.15°"`).
  String formatChannelValue(HeroColorChannel channel) {
    final double value = channelValue(channel);
    return switch (channel) {
      HeroColorChannel.hue => '${_trim(value, 2)}°',
      HeroColorChannel.saturation ||
      HeroColorChannel.lightness ||
      HeroColorChannel.brightness => '${value.round()}%',
      HeroColorChannel.alpha => '${(value * 100).round()}%',
      HeroColorChannel.red ||
      HeroColorChannel.green ||
      HeroColorChannel.blue => _trim(value, 2),
    };
  }

  static String _trim(double value, int decimals) {
    final String fixed = value.toStringAsFixed(decimals);
    if (!fixed.contains('.')) return fixed;
    final String trimmed = fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
    return trimmed == '-0' ? '0' : trimmed;
  }

  /// Whether this value paints the same 8-bit RGBA color as [other],
  /// whatever the space (React Aria's `isEqual`).
  bool isEquivalent(HeroColorValue other) =>
      heroColorsEqual(toColor(), other.toColor());

  @override
  bool operator ==(Object other) =>
      other is HeroColorValue &&
      other.space == space &&
      other._c1 == _c1 &&
      other._c2 == _c2 &&
      other._c3 == _c3 &&
      other.alpha == alpha;

  @override
  int get hashCode => Object.hash(space, _c1, _c2, _c3, alpha);

  @override
  String toString() => toFormat(switch (space) {
    HeroColorSpace.rgb => HeroColorFormat.rgba,
    HeroColorSpace.hsl => HeroColorFormat.hsla,
    HeroColorSpace.hsb => HeroColorFormat.hsba,
  });
}

/// Parses a color string into a [Color] (see [HeroColorValue.parse]).
///
/// Throws a [FormatException] for invalid input.
Color heroParseColor(String value) => HeroColorValue.parse(value).toColor();

/// Formats [color] in [format] (see [HeroColorValue.toFormat]).
String heroColorToString(
  Color color, [
  HeroColorFormat format = HeroColorFormat.hex,
]) => HeroColorValue.fromColor(color).toFormat(format);

/// Whether two colors are the same 8-bit RGBA color (color equality that
/// ignores the notation and sub-8-bit precision).
bool heroColorsEqual(Color a, Color b) => a.toARGB32() == b.toARGB32();

/// Converts [color] into a [HeroColorValue] in [space] for a color
/// component whose [previous] value is known.
///
/// A [Color] cannot store the hue of a gray or the saturation of black and
/// white, so the widgets keep their own value and use this to accept a new
/// color from their parent:
///
/// * when [previous] paints [color] (the parent handed back what the widget
///   reported), [previous] is kept, converted to [space];
/// * otherwise [color] is converted, and where it leaves hue (no
///   saturation) or saturation (black or white) undefined, the values of
///   [previous] are kept, so thumbs do not jump.
HeroColorValue heroResolveColorValue(
  Color color,
  HeroColorSpace space, {
  HeroColorValue? previous,
}) {
  if (previous != null && previous.toColor() == color) {
    return previous.toSpace(space);
  }
  final HeroColorValue fresh = HeroColorValue.fromColor(color, space: space);
  if (previous == null || space == HeroColorSpace.rgb) return fresh;
  const double epsilon = 1e-6;
  final HeroColorValue prior = previous.toSpace(space);
  final double third = fresh.channelValue(space.channels[2]);
  final bool noSaturation =
      fresh.channelValue(HeroColorChannel.saturation) < epsilon;
  final bool extreme = space == HeroColorSpace.hsb
      ? third < epsilon
      : third < epsilon || third > 100 - epsilon;
  HeroColorValue result = fresh;
  if (noSaturation || extreme) {
    result = result.withChannelValue(
      HeroColorChannel.hue,
      prior.channelValue(HeroColorChannel.hue),
    );
  }
  if (extreme) {
    result = result.withChannelValue(
      HeroColorChannel.saturation,
      prior.channelValue(HeroColorChannel.saturation),
    );
  }
  return result;
}
