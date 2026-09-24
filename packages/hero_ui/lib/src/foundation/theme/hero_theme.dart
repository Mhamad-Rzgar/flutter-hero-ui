import 'package:flutter/material.dart' show Theme;
import 'package:flutter/widgets.dart';

import 'hero_theme_data.dart';

/// Provides a [HeroThemeData] to its descendants.
///
/// `HeroTheme.of(context)` is the single access point every hero_ui
/// component uses to read design tokens. It resolves, in order:
///
/// 1. the nearest [HeroTheme] ancestor,
/// 2. a [HeroThemeData] registered in a Material `ThemeData.extensions`
///    list (for apps built on `MaterialApp`),
/// 3. HeroUI's default light theme.
///
/// Nest a [HeroTheme] to re-theme a subtree, just like HeroUI's
/// `data-theme` attribute.
class HeroTheme extends InheritedTheme {
  /// Provides [data] to [child].
  const HeroTheme({super.key, required this.data, required super.child});

  /// The tokens provided to the subtree.
  final HeroThemeData data;

  static final HeroThemeData _fallback = HeroThemeData.light();

  /// Returns the closest theme data, falling back to the default light theme.
  static HeroThemeData of(BuildContext context) =>
      maybeOf(context) ?? _fallback;

  /// Returns the closest theme data, or null when neither a [HeroTheme] nor
  /// a Material theme extension is present.
  static HeroThemeData? maybeOf(BuildContext context) {
    final HeroTheme? inherited = context
        .dependOnInheritedWidgetOfExactType<HeroTheme>();
    if (inherited != null) return inherited.data;
    return Theme.of(context).extension<HeroThemeData>();
  }

  @override
  Widget wrap(BuildContext context, Widget child) =>
      HeroTheme(data: data, child: child);

  @override
  bool updateShouldNotify(HeroTheme oldWidget) => data != oldWidget.data;
}

/// A [HeroTheme] that animates token changes (for example switching between
/// light and dark) over [duration].
class AnimatedHeroTheme extends ImplicitlyAnimatedWidget {
  /// Animates to [data] whenever it changes.
  const AnimatedHeroTheme({
    super.key,
    required this.data,
    required this.child,
    super.curve = Curves.linear,
    super.duration = const Duration(milliseconds: 200),
    super.onEnd,
  });

  /// The target theme data.
  final HeroThemeData data;

  /// The subtree that receives the theme.
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedHeroTheme> createState() =>
      _AnimatedHeroThemeState();
}

class _AnimatedHeroThemeState
    extends AnimatedWidgetBaseState<AnimatedHeroTheme> {
  _HeroThemeDataTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data =
        visitor(
              _data,
              widget.data,
              (dynamic value) =>
                  _HeroThemeDataTween(begin: value as HeroThemeData),
            )
            as _HeroThemeDataTween?;
  }

  @override
  Widget build(BuildContext context) =>
      HeroTheme(data: _data!.evaluate(animation), child: widget.child);
}

class _HeroThemeDataTween extends Tween<HeroThemeData> {
  _HeroThemeDataTween({super.begin});

  @override
  HeroThemeData lerp(double t) => begin!.lerp(end, t);
}
