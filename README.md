# hero_ui

A Flutter port of [HeroUI v3](https://heroui.com): the same design language, component set
and variant system, with a familiar API, for iOS, Android and the web.

- **`hero_ui`** — design tokens, themes (light, dark and every HeroUI preset) and the
  open-source component set.
- **`hero_ui_pro`** — Pro components, full-screen templates (Dashboard, Mail, Chat, Finances,
  CRM) and premium design systems (Brutalism, Glass, Mouve).
- **`apps/gallery`** — a gallery app that runs every example from the HeroUI docs with a
  variant playground, code viewer and theme switcher.

The look follows HeroUI first and iOS second: continuous corners, scale-and-color press
feedback, iOS sheets and bouncing scroll on every platform, and no Material styling.

## Installation

The packages are not on pub.dev yet; depend on them from Git:

```yaml
dependencies:
  hero_ui:
    git:
      url: https://github.com/Mhamad-Rzgar/flutter-hero-ui
      path: packages/hero_ui
```

Requirements: Flutter 3.35 or newer (Dart 3.9).

## Quick start

```dart
import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

void main() => runApp(
  HeroApp(
    theme: HeroThemeData.light(),
    darkTheme: HeroThemeData.dark(),
    home: const HomePage(),
  ),
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Center(
      child: Text(
        'Hello HeroUI',
        style: theme.typography.h3.copyWith(color: theme.colors.foreground),
      ),
    );
  }
}
```

Every token is read through `HeroTheme.of(context)`. Switch presets with
`HeroThemeData.light(preset: HeroThemePreset.lavender)`. Apps built on `MaterialApp` can add a
`HeroThemeData` to `ThemeData.extensions` or wrap a subtree in a `HeroTheme`.

## Component coverage

Status of every slice lives in [PROGRESS.md](PROGRESS.md); the plan and the full
HeroUI → Flutter API mapping are in [PLAN.md](PLAN.md). Component docs are in
[docs/components](docs/components).

<!-- coverage:start -->
**53 of 164 slices done**, 0 in progress.

| Area | Done | Total |
| --- | --- | --- |
| Foundations | 8 | 8 |
| Buttons & typography | 13 | 13 |
| Data display | 12 | 15 |
| Forms | 5 | 14 |
| Overlays | 1 | 6 |
| Collections & navigation | 8 | 13 |
| Date & time | 0 | 6 |
| Color | 6 | 6 |
| Pro foundations | 0 | 1 |
| Pro charts | 0 | 8 |
| Pro data display | 0 | 20 |
| Pro feedback | 0 | 3 |
| Pro forms | 0 | 9 |
| Pro navigation | 0 | 9 |
| Pro overlays | 0 | 2 |
| Pro mobile | 0 | 10 |
| Pro AI | 0 | 11 |
| Pro composites | 0 | 1 |
| Pro templates | 0 | 5 |
| Premium themes | 0 | 3 |
| Polish | 0 | 1 |
<!-- coverage:end -->

## Development

```sh
flutter pub get          # resolves the whole workspace
flutter analyze          # all packages
cd packages/hero_ui && flutter test
dart run melos run test  # every package
```

Golden images are generated on Linux: `flutter test --update-goldens`.

Design and behaviour decisions are recorded in [DECISIONS.md](DECISIONS.md); changes in
[CHANGELOG.md](CHANGELOG.md).

## License

Apache License 2.0. hero_ui ports HeroUI (Apache-2.0) and bundles Gravity UI icons (MIT), Inter
and JetBrains Mono (OFL); see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
