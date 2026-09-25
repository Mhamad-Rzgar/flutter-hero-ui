import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/avatar_group_demo.dart';
import 'package:hero_ui_gallery/src/pages/component_page.dart';

void main() {
  Widget demoPage({required bool reduceMotion}) {
    final ComponentDemo demo = avatarGroupDemo;
    return HeroApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (BuildContext context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                PlaygroundView(playground: demo.playground!),
                for (final DemoExample example in demo.examples)
                  Builder(builder: example.builder),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('avatar group demo renders the playground and every example', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(demoPage(reduceMotion: true));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(HeroAvatarGroup), findsWidgets);
    for (final DemoExample example in avatarGroupDemo.examples) {
      expect(example.code, isNotEmpty);
    }
  });

  testWidgets('the overlap backdrop animates without errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(demoPage(reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(tester.takeException(), isNull);
  });
}
