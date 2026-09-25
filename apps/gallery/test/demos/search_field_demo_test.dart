import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';
import 'package:hero_ui_gallery/src/demo.dart';
import 'package:hero_ui_gallery/src/demos/search_field_demo.dart';

void main() {
  testWidgets('search field demo examples build', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ComponentDemo demo = searchFieldDemo;
    await tester.pumpWidget(
      HeroApp(
        // Reduced motion keeps the pending spinner still.
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
    expect(find.byType(HeroSearchField), findsWidgets);
    expect(demo.examples.map((DemoExample e) => e.title), <String>[
      'Usage',
      'Variants',
      'In Surface',
      'With Description',
      'Required Field',
      'Disabled State',
      'Full Width',
      'Validation',
      'Controlled',
      'Form Example',
      'With Validation',
      'Custom Icons',
      'With Keyboard Shortcut',
      'Render Function',
      'Customization',
    ]);
  });

  testWidgets('Shift+S focuses the shortcut example and Escape leaves it', (
    WidgetTester tester,
  ) async {
    final DemoExample example = searchFieldDemo.examples.firstWhere(
      (DemoExample e) => e.title == 'With Keyboard Shortcut',
    );
    await tester.pumpWidget(
      HeroApp(
        home: Center(child: Builder(builder: example.builder)),
      ),
    );
    await tester.pumpAndSettle();
    EditableText editable() =>
        tester.widget<EditableText>(find.byType(EditableText));
    expect(editable().focusNode.hasFocus, isFalse);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS, character: 'S');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(editable().focusNode.hasFocus, isTrue);

    await tester.enterText(find.byType(EditableText), 'query');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    // The first Escape clears, the second leaves the field.
    expect(editable().controller.text, isEmpty);
    expect(editable().focusNode.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(editable().focusNode.hasFocus, isFalse);
  });
}
