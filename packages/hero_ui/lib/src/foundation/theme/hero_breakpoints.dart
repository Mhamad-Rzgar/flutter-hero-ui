/// Tailwind CSS v4 breakpoints used by HeroUI's responsive utilities, in
/// logical pixels.
abstract final class HeroBreakpoints {
  /// `sm`: 640.
  static const double sm = 640;

  /// `md`: 768. HeroUI switches controls to their compact desktop size here.
  static const double md = 768;

  /// `lg`: 1024.
  static const double lg = 1024;

  /// `xl`: 1280.
  static const double xl = 1280;

  /// `2xl`: 1536.
  static const double xl2 = 1536;
}

/// Sizing density of controls.
///
/// HeroUI sizes controls larger on narrow (touch) viewports and slightly
/// smaller from the `md` breakpoint up, e.g. a medium button is
/// `h-10 md:h-9`. [adaptive] reproduces that; the other values pin one
/// density.
enum HeroDensity {
  /// Follows the viewport width like HeroUI's `md:` utilities.
  adaptive,

  /// Always use the larger touch sizes (below `md`).
  touch,

  /// Always use the compact desktop sizes (`md` and up).
  desktop,
}
