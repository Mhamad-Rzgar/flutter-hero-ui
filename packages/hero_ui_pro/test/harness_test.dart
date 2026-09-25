import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import 'helpers/hero_test_app.dart';

void main() {
  testWidgets('Pro widgets render inside the hero_ui theme', (
    WidgetTester tester,
  ) async {
    late HeroThemeData theme;
    await pumpHero(
      tester,
      Builder(
        builder: (BuildContext context) {
          theme = HeroTheme.of(context);
          return const Text('Pro');
        },
      ),
      theme: HeroThemeData.dark(),
    );
    expect(find.text('Pro'), findsOneWidget);
    expect(theme.isDark, isTrue);
  });
}
