import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A HeroUI shadow token: a list of outer [boxShadows] plus an optional
/// inset hairline.
///
/// CSS `inset` box-shadows have no direct [BoxShadow] equivalent; HeroUI only
/// uses them for the dark overlay highlight (`0 0 1px 0 rgba(255,255,255,.3)
/// inset`). That highlight is exposed as [insetColor] and painted by
/// components as an inner hairline stroke.
@immutable
class HeroShadow {
  /// Creates a shadow token.
  const HeroShadow({this.boxShadows = const <BoxShadow>[], this.insetColor});

  /// A shadow that paints nothing.
  static const HeroShadow none = HeroShadow();

  /// Outer shadows, painted in order.
  final List<BoxShadow> boxShadows;

  /// Color of the inner highlight hairline, if any.
  final Color? insetColor;

  /// Whether this token paints anything.
  bool get isNone => boxShadows.isEmpty && insetColor == null;

  /// Linearly interpolates between two shadows.
  static HeroShadow lerp(HeroShadow a, HeroShadow b, double t) {
    if (identical(a, b)) return a;
    return HeroShadow(
      boxShadows: BoxShadow.lerpList(a.boxShadows, b.boxShadows, t) ?? const [],
      insetColor: Color.lerp(a.insetColor, b.insetColor, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroShadow &&
      listEquals(other.boxShadows, boxShadows) &&
      other.insetColor == insetColor;

  @override
  int get hashCode => Object.hash(Object.hashAll(boxShadows), insetColor);
}

/// The HeroUI elevation tokens: `--surface-shadow`, `--overlay-shadow` and
/// `--field-shadow`.
@immutable
class HeroShadows with Diagnosticable {
  /// Creates the shadow tokens.
  const HeroShadows({
    required this.surface,
    required this.overlay,
    required this.field,
  });

  /// Shadow of non-overlay containers such as cards (`shadow-surface`).
  final HeroShadow surface;

  /// Shadow of floating containers such as popovers (`shadow-overlay`).
  final HeroShadow overlay;

  /// Shadow of form fields (`shadow-field`).
  final HeroShadow field;

  /// Light-mode shadows from HeroUI's `variables.css`.
  static const HeroShadows light = HeroShadows(
    surface: HeroShadow(
      boxShadows: <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.04),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.06),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 1),
      ],
    ),
    overlay: HeroShadow(
      boxShadows: <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.06),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.03),
          offset: Offset(0, -6),
          blurRadius: 12,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 14),
          blurRadius: 28,
        ),
      ],
    ),
    field: HeroShadow(
      boxShadows: <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.04),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.06),
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 1),
      ],
    ),
  );

  /// Dark-mode shadows: no outer shadows, and a faint inner highlight on
  /// overlays.
  static const HeroShadows dark = HeroShadows(
    surface: HeroShadow.none,
    overlay: HeroShadow(insetColor: Color.fromRGBO(255, 255, 255, 0.3)),
    field: HeroShadow.none,
  );

  /// Returns a copy with the given values replaced.
  HeroShadows copyWith({
    HeroShadow? surface,
    HeroShadow? overlay,
    HeroShadow? field,
  }) => HeroShadows(
    surface: surface ?? this.surface,
    overlay: overlay ?? this.overlay,
    field: field ?? this.field,
  );

  /// Linearly interpolates between two shadow sets.
  static HeroShadows lerp(HeroShadows a, HeroShadows b, double t) {
    if (identical(a, b)) return a;
    return HeroShadows(
      surface: HeroShadow.lerp(a.surface, b.surface, t),
      overlay: HeroShadow.lerp(a.overlay, b.overlay, t),
      field: HeroShadow.lerp(a.field, b.field, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is HeroShadows &&
      other.surface == surface &&
      other.overlay == overlay &&
      other.field == field;

  @override
  int get hashCode => Object.hash(surface, overlay, field);
}
