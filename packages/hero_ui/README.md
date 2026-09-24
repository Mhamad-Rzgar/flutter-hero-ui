# hero_ui

A Flutter port of the [HeroUI v3](https://heroui.com) design system: OKLCH design tokens,
light and dark themes with every HeroUI preset, and accessible components for iOS, Android
and the web.

```dart
import 'package:hero_ui/hero_ui.dart';

HeroApp(
  theme: HeroThemeData.light(),
  darkTheme: HeroThemeData.dark(),
  home: const MyHomePage(),
);
```

Read tokens anywhere with `HeroTheme.of(context)`. See the
[repository README](https://github.com/Mhamad-Rzgar/flutter-hero-ui) for the component list,
documentation and gallery.
