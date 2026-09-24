/// Test utilities for apps and packages that render hero_ui widgets in
/// widget and golden tests.
library;

import 'dart:convert';

import 'package:flutter/services.dart';

/// Registers every font declared in the asset bundle's `FontManifest.json`
/// (including hero_ui's bundled Inter and JetBrains Mono) with the engine,
/// so golden tests render real glyphs instead of the test font.
///
/// Call it once from `flutter_test_config.dart`:
///
/// ```dart
/// Future<void> testExecutable(FutureOr<void> Function() testMain) async {
///   TestWidgetsFlutterBinding.ensureInitialized();
///   await loadHeroFonts();
///   await testMain();
/// }
/// ```
Future<void> loadHeroFonts() async {
  final String manifestJson = await rootBundle.loadString('FontManifest.json');
  final List<dynamic> manifest = json.decode(manifestJson) as List<dynamic>;
  for (final dynamic entry in manifest) {
    final Map<String, dynamic> family = entry as Map<String, dynamic>;
    final String name = family['family'] as String;
    final List<dynamic> fonts = family['fonts'] as List<dynamic>;
    final List<String> families = <String>[
      name,
      // When hero_ui itself is under test its fonts are registered without
      // the package prefix; register the prefixed name used by TextStyle too.
      if (!name.startsWith('packages/') &&
          (name == 'Inter' || name == 'JetBrainsMono'))
        'packages/hero_ui/$name',
    ];
    for (final String familyName in families) {
      final FontLoader loader = FontLoader(familyName);
      for (final dynamic font in fonts) {
        final String asset = (font as Map<String, dynamic>)['asset'] as String;
        loader.addFont(rootBundle.load(asset));
      }
      await loader.load();
    }
  }
}
