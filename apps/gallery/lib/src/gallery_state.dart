import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

/// A theme the gallery can switch to: an open-source preset or a premium
/// design system contributed by hero_ui_pro.
class GalleryTheme {
  const GalleryTheme({
    required this.id,
    required this.label,
    required this.light,
    required this.dark,
    this.isPremium = false,
  });

  final String id;
  final String label;
  final HeroThemeData Function() light;
  final HeroThemeData Function() dark;
  final bool isPremium;
}

/// Themes built from the HeroUI theme-builder presets.
final List<GalleryTheme> presetThemes = <GalleryTheme>[
  for (final HeroThemePreset preset in HeroThemePreset.values)
    GalleryTheme(
      id: preset.name,
      label: preset.label,
      light: () => HeroThemeData.light(preset: preset),
      dark: () => HeroThemeData.dark(preset: preset),
    ),
];

/// App-wide gallery settings: theme, brightness and layout direction.
class GalleryState extends ChangeNotifier {
  GalleryState({List<GalleryTheme>? themes})
    : themes = themes ?? presetThemes,
      _theme = (themes ?? presetThemes).first;

  final List<GalleryTheme> themes;

  GalleryTheme _theme;
  GalleryTheme get theme => _theme;
  set theme(GalleryTheme value) {
    if (_theme == value) return;
    _theme = value;
    notifyListeners();
  }

  HeroThemeMode _mode = HeroThemeMode.system;
  HeroThemeMode get mode => _mode;
  set mode(HeroThemeMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  TextDirection _direction = TextDirection.ltr;
  TextDirection get direction => _direction;
  set direction(TextDirection value) {
    if (_direction == value) return;
    _direction = value;
    notifyListeners();
  }
}

/// Provides [GalleryState] to the widget tree.
class GalleryScope extends InheritedNotifier<GalleryState> {
  const GalleryScope({
    super.key,
    required GalleryState state,
    required super.child,
  }) : super(notifier: state);

  static GalleryState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GalleryScope>()!.notifier!;
}
