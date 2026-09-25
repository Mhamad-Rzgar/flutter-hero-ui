import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroThemeData _theme = HeroThemeData.light();

HeroFieldBox _box(WidgetTester tester) =>
    tester.widget<HeroFieldBox>(find.byType(HeroFieldBox));

EditableText _editable(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText));

EdgeInsets _textPadding(WidgetTester tester) {
  final Padding padding = tester.widget<Padding>(
    find
        .ancestor(of: find.byType(EditableText), matching: find.byType(Padding))
        .first,
  );
  return padding.padding.resolve(TextDirection.ltr);
}

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  group('HeroInputGroup layout', () {
    testWidgets('prefix, input and suffix share one field box', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 280,
          child: HeroInputGroup(
            children: <Widget>[
              HeroInputGroupPrefix(child: Text(r'$')),
              HeroInputGroupInput(placeholder: '0'),
              HeroInputGroupSuffix(child: Text('USD')),
            ],
          ),
        ),
        surfaceSize: const Size(390, 600),
      );
      expect(find.byType(HeroFieldBox), findsOneWidget);
      final Rect group = tester.getRect(find.byType(HeroInputGroup));
      final Rect prefix = tester.getRect(find.byType(HeroInputGroupPrefix));
      final Rect suffix = tester.getRect(find.byType(HeroInputGroupSuffix));
      final Rect input = tester.getRect(find.byType(HeroInputGroupInput));
      expect(group.width, 280);
      // Narrow viewport: text-base, 24 + py-2.
      expect(group.height, 40);
      // Full-height addons with px-3 around the text.
      expect(prefix.height, 40);
      expect(prefix.left, group.left);
      expect(tester.getRect(find.text(r'$')).left - prefix.left, 12);
      expect(suffix.right, group.right);
      expect(suffix.right - tester.getRect(find.text('USD')).right, 12);
      // The input fills the rest and drops its padding next to the addons.
      expect(input.left, prefix.right);
      expect(input.right, suffix.left);
      expect(_textPadding(tester), const EdgeInsets.symmetric(vertical: 8));
    });

    testWidgets('addon text is text-sm placeholder colored, icons 16 px', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInputGroup(
          startContent: Text('https://'),
          endContent: HeroIcon(HeroIcons.envelope),
        ),
      );
      final TextStyle style = tester
          .renderObject<RenderParagraph>(find.text('https://'))
          .text
          .style!;
      expect(style.fontSize, 14);
      expect(style.color, _theme.colors.fieldPlaceholder);
      expect(tester.getSize(find.byType(HeroIcon)), const Size(16, 16));
      // Input padding: none at the start (prefix), none at the end (suffix).
      expect(_textPadding(tester).horizontal, 0);
    });

    testWidgets('an input alone keeps px-3', (WidgetTester tester) async {
      await pumpHero(tester, const HeroInputGroup());
      expect(
        _textPadding(tester),
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });

    testWidgets('shrink-wraps its parts outside a sized parent', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroInputGroup(startContent: Text(r'$')));
      final double prefix = tester
          .getSize(find.byType(HeroInputGroupPrefix))
          .width;
      expect(
        tester.getSize(find.byType(HeroInputGroup)).width,
        prefix + HeroFieldMetrics.defaultWidth(_theme),
      );

      await pumpHero(
        tester,
        const HeroInputGroup(child: HeroInputGroupInput(width: 120)),
      );
      expect(tester.getSize(find.byType(HeroInputGroup)).width, 120);
    });

    testWidgets('fullWidth fills a bounded width', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 400,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: HeroInputGroup(fullWidth: true),
          ),
        ),
      );
      expect(tester.getSize(find.byType(HeroInputGroup)).width, 400);
    });

    testWidgets('stretches inside a text field', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 280,
          child: HeroTextField(
            children: <Widget>[
              HeroLabel.text('Email'),
              HeroInputGroup(startContent: HeroIcon(HeroIcons.envelope)),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(HeroInputGroup)).width, 280);
      expect(
        tester.getTopLeft(find.byType(HeroInputGroup)).dy -
            tester.getBottomLeft(find.byType(HeroLabel)).dy,
        4,
      );
    });

    testWidgets('min-h-9 around a small input and sm text on wide screens', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInputGroup(),
        surfaceSize: const Size(1024, 600),
      );
      expect(tester.getSize(find.byType(HeroInputGroup)).height, 36);
    });

    testWidgets('a text area top-aligns the addons', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 320,
          child: HeroInputGroup(
            children: <Widget>[
              HeroInputGroupPrefix(child: HeroIcon(HeroIcons.envelope)),
              HeroInputGroupTextArea(rows: 4),
            ],
          ),
        ),
        surfaceSize: const Size(390, 600),
      );
      final Rect group = tester.getRect(find.byType(HeroInputGroup));
      // 4 lines of 24 + py-2.
      expect(group.height, 4 * 24 + 16);
      expect(tester.getRect(find.byType(HeroIcon)).top - group.top, 8);
      expect(_editable(tester).maxLines, 4);
    });

    testWidgets('a vertical group stacks its parts', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 320,
          child: HeroInputGroup(
            direction: Axis.vertical,
            spacing: 8,
            padding: EdgeInsets.symmetric(vertical: 8),
            children: <Widget>[
              HeroInputGroupPrefix(child: Text('Top')),
              HeroInputGroupTextArea(rows: 2),
              HeroInputGroupSuffix(child: Text('Bottom')),
            ],
          ),
        ),
      );
      final Rect group = tester.getRect(find.byType(HeroInputGroup));
      final Rect top = tester.getRect(find.text('Top'));
      final Rect area = tester.getRect(find.byType(HeroInputGroupTextArea));
      final Rect bottom = tester.getRect(find.text('Bottom'));
      expect(area.width, 320);
      expect(area.top, greaterThan(top.bottom));
      expect(bottom.top, greaterThan(area.bottom));
      // Addons align to the start.
      expect(top.left - group.left, 12);
      expect(bottom.left - group.left, 12);
    });

    testWidgets('a resizable text area drags its height', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 320,
          child: HeroInputGroup(
            child: HeroInputGroupTextArea(resize: HeroTextAreaResize.vertical),
          ),
        ),
      );
      final double before = tester.getSize(find.byType(HeroInputGroup)).height;
      await tester.drag(
        find.byType(HeroTextAreaResizeGrip),
        const Offset(0, 40),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(HeroInputGroup)).height,
        greaterThan(before),
      );
    });

    testWidgets('RTL puts the prefix on the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 280,
          child: HeroInputGroup(startContent: Text('A'), endContent: Text('B')),
        ),
        textDirection: TextDirection.rtl,
      );
      final Rect group = tester.getRect(find.byType(HeroInputGroup));
      expect(
        tester.getRect(find.byType(HeroInputGroupPrefix)).right,
        group.right,
      );
      expect(
        tester.getRect(find.byType(HeroInputGroupSuffix)).left,
        group.left,
      );
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 320,
          child: HeroTextField(
            label: 'Price',
            children: <Widget>[
              HeroLabel.text('Price'),
              HeroInputGroup(
                startContent: Text(r'$'),
                endContent: Text('USD'),
                child: HeroInputGroupInput(placeholder: '0'),
              ),
            ],
          ),
        ),
        textScale: 2,
        surfaceSize: const Size(390, 600),
      );
      expect(tester.takeException(), isNull);
      // Two lines of text-base at 2x plus py-2.
      expect(tester.getSize(find.byType(HeroInputGroup)).height, 16 + 48);
    });
  });

  group('HeroInputGroup states', () {
    testWidgets('variant is inherited from the text field', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(
          variant: HeroFieldVariant.secondary,
          children: <Widget>[HeroInputGroup()],
        ),
      );
      expect(_box(tester).variant, HeroFieldVariant.secondary);

      await pumpHero(
        tester,
        const HeroTextField(
          variant: HeroFieldVariant.secondary,
          children: <Widget>[HeroInputGroup(variant: HeroFieldVariant.primary)],
        ),
      );
      expect(_box(tester).variant, HeroFieldVariant.primary);
    });

    testWidgets('focusing the input rings the group', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroInputGroup(startContent: Text('@')));
      expect(_box(tester).isFocused, isFalse);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(_box(tester).isFocused, isTrue);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      expect(_box(tester).isFocused, isFalse);
    });

    testWidgets('pressing an addon focuses the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroInputGroup(startContent: Text('@')));
      await tester.tap(find.text('@'));
      await tester.pump();
      expect(_editable(tester).focusNode.hasFocus, isTrue);
      expect(_box(tester).isFocused, isTrue);
    });

    testWidgets('a button in the suffix keeps its own press', (
      WidgetTester tester,
    ) async {
      int copies = 0;
      await pumpHero(
        tester,
        HeroInputGroup(
          endContent: HeroButton(
            isIconOnly: true,
            size: HeroSize.sm,
            variant: HeroButtonVariant.ghost,
            semanticLabel: 'Copy',
            onPressed: () => copies++,
            child: const HeroIcon(HeroIcons.copy),
          ),
        ),
      );
      await tester.tap(find.byType(HeroButton));
      await tester.pumpAndSettle();
      expect(copies, 1);
      expect(_box(tester).isFocused, isFalse);
    });

    testWidgets('inherits invalid and disabled from the text field', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(
          isInvalid: true,
          children: <Widget>[
            HeroInputGroup(),
            HeroFieldError.text('Please enter a valid email address'),
          ],
        ),
      );
      expect(_box(tester).isInvalid, isTrue);
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      await pumpHero(
        tester,
        const HeroTextField(
          isDisabled: true,
          defaultValue: '10',
          children: <Widget>[HeroInputGroup(startContent: Text(r'$'))],
        ),
      );
      expect(_box(tester).isDisabled, isTrue);
      await tester.tap(find.text(r'$'), warnIfMissed: false);
      await tester.pump();
      expect(_editable(tester).focusNode.hasFocus, isFalse);
    });

    testWidgets('own isInvalid and isDisabled', (WidgetTester tester) async {
      await pumpHero(tester, const HeroInputGroup(isInvalid: true));
      expect(_box(tester).isInvalid, isTrue);
      await pumpHero(tester, const HeroInputGroup(isDisabled: true));
      expect(_box(tester).isDisabled, isTrue);
    });

    testWidgets('builder receives the group state', (
      WidgetTester tester,
    ) async {
      final List<HeroInputGroupState> states = <HeroInputGroupState>[];
      await pumpHero(
        tester,
        HeroInputGroup(
          isInvalid: true,
          builder: (BuildContext context, HeroInputGroupState state) {
            states.add(state);
            return <Widget>[
              HeroInputGroupPrefix(
                child: Text(state.isFocusWithin ? 'focused' : 'idle'),
              ),
              const HeroInputGroupInput(),
            ];
          },
        ),
      );
      expect(states.last.isInvalid, isTrue);
      expect(find.text('idle'), findsOneWidget);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(find.text('focused'), findsOneWidget);
      expect(
        states.last,
        const HeroInputGroupState(isFocusWithin: true, isInvalid: true),
      );

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byType(HeroInputGroup)));
      await tester.pump();
      expect(states.last.isHovered, isTrue);
    });
  });

  group('HeroInputGroup value', () {
    testWidgets('edits the text of the enclosing field', (
      WidgetTester tester,
    ) async {
      String? changed;
      await pumpHero(
        tester,
        HeroTextField(
          defaultValue: 'heroui',
          onChanged: (String value) => changed = value,
          children: const <Widget>[
            HeroLabel.text('Website'),
            HeroInputGroup(endContent: Text('.com')),
          ],
        ),
      );
      expect(find.text('heroui'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'hero');
      expect(changed, 'hero');
    });

    testWidgets('pressing the label focuses the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroTextField(
          children: <Widget>[
            HeroLabel.text('Website'),
            HeroInputGroup(startContent: Text('https://')),
          ],
        ),
      );
      await tester.tap(find.byType(HeroLabel));
      await tester.pump();
      expect(_editable(tester).focusNode.hasFocus, isTrue);
      expect(_box(tester).isFocused, isTrue);
    });

    testWidgets('standalone: controlled, uncontrolled and caller nodes', (
      WidgetTester tester,
    ) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      String? changed;
      await pumpHero(
        tester,
        HeroInputGroup(
          child: HeroInputGroupInput(
            focusNode: node,
            defaultValue: 'a',
            onChanged: (String value) => changed = value,
          ),
        ),
      );
      expect(find.text('a'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'ab');
      expect(changed, 'ab');
      node.requestFocus();
      await tester.pump();
      expect(_box(tester).isFocused, isTrue);

      await pumpHero(
        tester,
        const HeroInputGroup(child: HeroInputGroupInput(value: 'fixed')),
      );
      expect(find.text('fixed'), findsOneWidget);
    });

    testWidgets('type and obscureText reach the input', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroInputGroup(
          child: HeroInputGroupInput(
            type: HeroInputType.password,
            defaultValue: 'secret',
          ),
        ),
      );
      expect(_editable(tester).obscureText, isTrue);
      await pumpHero(
        tester,
        const HeroInputGroup(
          child: HeroInputGroupInput(
            type: HeroInputType.password,
            obscureText: false,
            defaultValue: 'secret',
          ),
        ),
      );
      expect(_editable(tester).obscureText, isFalse);
    });

    testWidgets('submits with the enclosing form', (WidgetTester tester) async {
      Map<String, Object?>? submitted;
      await pumpHero(
        tester,
        HeroForm(
          onSubmit: (Map<String, Object?> data) => submitted = data,
          child: const HeroTextField(
            name: 'website',
            isRequired: true,
            children: <Widget>[
              HeroLabel.text('Website'),
              HeroInputGroup(startContent: Text('https://')),
              HeroFieldError(),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submitted, isNull);
      expect(_box(tester).isInvalid, isTrue);
      expect(find.text('Please fill out this field.'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'heroui.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submitted, <String, Object?>{'website': 'heroui.com'});
    });
  });

  group('HeroInputGroup semantics', () {
    testWidgets('a group around the labelled text field', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroTextField(
          children: <Widget>[
            HeroLabel.text('Email address'),
            HeroInputGroup(
              semanticLabel: 'Email group',
              startContent: HeroIcon(HeroIcons.envelope),
            ),
          ],
        ),
      );
      expect(
        tester.getSemantics(find.byType(HeroEditableText)).label,
        'Email address',
      );
      expect(find.bySemanticsLabel('Email group'), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets('debug properties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const HeroInputGroup(
      variant: HeroFieldVariant.secondary,
      fullWidth: true,
      isInvalid: true,
    ).debugFillProperties(builder);
    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();
    expect(description, contains('variant: secondary'));
    expect(description, contains('full width'));
    expect(description, contains('invalid'));
  });
}
