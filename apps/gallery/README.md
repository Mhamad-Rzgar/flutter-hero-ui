# hero_ui gallery

The showcase app for hero_ui and hero_ui_pro. It runs on iOS, Android and the web.

- Searchable component index grouped like the HeroUI docs.
- One page per component with a variant playground and every docs example, each with a
  "view code" sheet.
- Theme switcher for light/dark, every HeroUI preset and the premium design systems.
- Templates section with the Pro screens.

```sh
flutter run -d chrome     # or an iOS/Android device
```

Demo pages live in `lib/src/demos/*_demo.dart`; after adding one, run
`dart run tool/generate_gallery_registry.dart` from the repository root.
