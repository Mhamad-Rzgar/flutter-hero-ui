import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

void main() {
  test('HeroSelectionMode mirrors React Aria selection modes', () {
    expect(
      HeroSelectionMode.values.map((HeroSelectionMode m) => m.name),
      <String>['none', 'single', 'multiple'],
    );
  });
}
