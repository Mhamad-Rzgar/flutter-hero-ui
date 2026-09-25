import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui_testing.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadHeroFonts();
  await testMain();
}
