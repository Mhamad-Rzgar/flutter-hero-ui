import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/input_group_demo.dart';

void main() {
  testWidgets('input group demo examples build', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ComponentDemo demo = inputGroupDemo;
    await tester.pumpWidget(
      HeroApp(
        // Reduced motion keeps the loading spinner still.
        theme: HeroThemeData.light().copyWith(
          motion: const HeroMotion(reduceMotion: true),
        ),
        // A Column builds every example (a ListView would skip those
        // outside the viewport).
        home: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Builder(
                builder: (BuildContext context) => demo.playground!.builder(
                  context,
                  PlaygroundValues(<String, Object>{
                    for (final PlaygroundControl c in demo.playground!.controls)
                      c.name: c.initialValue,
                  }),
                ),
              ),
              for (final DemoExample example in demo.examples)
                Center(child: Builder(builder: example.builder)),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(HeroInputGroup), findsWidgets);
    expect(demo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Variants',
      'In Surface',
      'Loading State',
      'Required Field',
      'Disabled State',
      'Full Width',
      'Text Prefix',
      'Text Suffix',
      'Icon Prefix and Text Suffix',
      'Copy Button Suffix',
      'Icon Prefix and Copy Button',
      'Password Toggle',
      'Keyboard Shortcut',
      'Badge Suffix',
      'Validation',
      'With Prefix Icon',
      'With Suffix Icon',
      'With Prefix and Suffix',
      'With TextArea',
      'Usage Example',
      'TextArea Usage Example',
      'Customization',
    ]);
  });
}
