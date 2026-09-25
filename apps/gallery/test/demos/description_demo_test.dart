import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/description_demo.dart';

void main() {
  testWidgets('description demo examples build', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ComponentDemo demo = descriptionDemo;
    await tester.pumpWidget(
      HeroApp(
        home: ListView(
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
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(HeroDescription), findsWidgets);
  });
}
