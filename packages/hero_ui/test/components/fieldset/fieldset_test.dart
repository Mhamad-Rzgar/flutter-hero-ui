import 'dart:ui' show Tristate;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

final HeroThemeData _theme = HeroThemeData.light();

/// Finds the rich text whose visible characters (ignoring the placeholder of
/// the asterisk gap) are [text].
Finder _rich(String text) => find.byWidgetPredicate(
  (Widget w) =>
      w is RichText &&
      w.text.toPlainText(includeSemanticsLabels: false).replaceAll('￼', '') ==
          text,
);

double _opacityAbove(WidgetTester tester, Finder finder) => tester
    .widgetList<Opacity>(
      find.ancestor(of: finder, matching: find.byType(Opacity)),
    )
    .fold(1, (double value, Opacity o) => value * o.opacity);

Widget _profile({
  bool isDisabled = false,
  VoidCallback? onSave,
  ValueChanged<Map<String, Object?>>? onSubmit,
}) {
  return HeroForm(
    onSubmit: onSubmit,
    child: SizedBox(
      width: 384,
      child: HeroFieldset(
        isDisabled: isDisabled,
        children: <Widget>[
          const HeroFieldsetLegend.text('Profile Settings'),
          const HeroDescription.text('Update your profile information.'),
          const HeroFieldsetGroup(
            children: <Widget>[
              HeroTextField(
                name: 'name',
                isRequired: true,
                children: <Widget>[
                  HeroLabel.text('Name'),
                  HeroInput(placeholder: 'John Doe'),
                  HeroFieldError(),
                ],
              ),
              HeroTextField(
                name: 'email',
                type: HeroInputType.email,
                children: <Widget>[
                  HeroLabel.text('Email'),
                  HeroInput(placeholder: 'john@example.com'),
                ],
              ),
            ],
          ),
          HeroFieldsetActions(
            children: <Widget>[
              HeroButton(
                onPressed: onSave,
                type: HeroButtonType.submit,
                child: const Text('Save changes'),
              ),
              const HeroButton(
                type: HeroButtonType.reset,
                variant: HeroButtonVariant.secondary,
                child: Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  group('HeroFieldset layout', () {
    testWidgets('stacks legend, description, fields and actions', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, _profile(), surfaceSize: const Size(480, 640));
      final Rect legend = tester.getRect(find.text('Profile Settings'));
      final Rect description = tester.getRect(
        find.text('Update your profile information.'),
      );
      final Rect group = tester.getRect(find.byType(HeroFieldsetGroup));
      final Rect actions = tester.getRect(find.byType(HeroFieldsetActions));

      // The legend is outside the content box: no gap after it.
      expect(legend.height, 24);
      expect(description.top, legend.bottom);
      // gap-6 between the other parts.
      expect(group.top - description.bottom, 24);
      expect(actions.top - group.bottom, 24);
      // space-y-4 between the fields.
      final Rect name = tester.getRect(find.byType(HeroTextField).first);
      final Rect email = tester.getRect(find.byType(HeroTextField).last);
      expect(email.top - name.bottom, 16);
      // Fields and the group fill the fieldset.
      expect(group.width, 384);
      expect(name.width, 384);
      expect(tester.getSize(find.byType(HeroInput).first).width, 384);
      // pt-1 above the buttons, gap-2 between them.
      final Rect save = tester.getRect(find.byType(HeroButton).first);
      final Rect cancel = tester.getRect(find.byType(HeroButton).last);
      expect(save.top - actions.top, 4);
      expect(cancel.left - save.right, 8);
      expect(save.left, actions.left);
    });

    testWidgets('legend style is text-base medium foreground', (
      WidgetTester tester,
    ) async {
      await pumpHero(tester, const HeroFieldsetLegend.text('Legend'));
      final TextStyle style = tester
          .renderObject<RenderParagraph>(find.text('Legend'))
          .text
          .style!;
      expect(style.fontSize, 16);
      expect(style.fontWeight, FontWeight.w500);
      expect(style.color, _theme.colors.foreground);

      await pumpHero(
        tester,
        const HeroFieldsetLegend(
          style: TextStyle(fontWeight: FontWeight.w600),
          child: Text('Custom'),
        ),
      );
      final TextStyle custom = tester
          .renderObject<RenderParagraph>(find.text('Custom'))
          .text
          .style!;
      expect(custom.fontSize, 16);
      expect(custom.fontWeight, FontWeight.w600);
    });

    testWidgets('convenience parameters build the parts', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 300,
          child: HeroFieldset(
            legend: 'Shipping',
            description: 'Where should we send it?',
            actions: <Widget>[HeroButton(child: Text('Continue'))],
            children: <Widget>[
              HeroFieldGroup(
                children: <Widget>[HeroTextField(label: 'Street')],
              ),
            ],
          ),
        ),
      );
      expect(find.byType(HeroFieldsetLegend), findsOneWidget);
      expect(find.byType(HeroDescription), findsOneWidget);
      expect(find.byType(HeroFieldsetActions), findsOneWidget);
      final double legendBottom = tester.getRect(find.text('Shipping')).bottom;
      expect(
        tester.getTopLeft(find.text('Where should we send it?')).dy,
        legendBottom,
      );
      expect(
        tester.getTopLeft(find.byType(HeroFieldsetGroup)).dy -
            tester.getBottomLeft(find.byType(HeroDescription)).dy,
        24,
      );
      expect(
        tester.getTopLeft(find.byType(HeroFieldsetActions)).dy,
        greaterThan(tester.getBottomLeft(find.byType(HeroFieldsetGroup)).dy),
      );
    });

    testWidgets('the legend goes on top wherever it is declared', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 300,
          child: HeroFieldset(
            children: <Widget>[
              HeroDescription.text('Description first'),
              HeroFieldsetLegend.text('Legend'),
            ],
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Description first')).dy,
        tester.getBottomLeft(find.text('Legend')).dy,
      );
    });

    testWidgets('spacing, padding and decoration', (WidgetTester tester) async {
      final HeroThemeData theme = _theme;
      await pumpHero(
        tester,
        SizedBox(
          width: 300,
          child: HeroFieldset(
            spacing: 12,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: theme.colors.surface,
              shape: theme.shapeAll(theme.radii.xl),
            ),
            children: const <Widget>[
              HeroFieldsetLegend.text('Legend'),
              HeroDescription.text('One'),
              HeroDescription.text('Two'),
            ],
          ),
        ),
      );
      final Rect fieldset = tester.getRect(find.byType(HeroFieldset));
      expect(
        tester.getTopLeft(find.text('Legend')),
        fieldset.topLeft + const Offset(16, 16),
      );
      expect(
        tester.getTopLeft(find.text('Two')).dy -
            tester.getBottomLeft(find.text('One')).dy,
        12,
      );
      expect(find.byType(DecoratedBox), findsWidgets);
      expect(fieldset.width, 300);
    });

    testWidgets('shrink-wraps its widest part when unbounded', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const UnconstrainedBox(
          child: HeroFieldset(
            legend: 'Legend',
            children: <Widget>[
              HeroFieldGroup(children: <Widget>[HeroTextField(label: 'Name')]),
            ],
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(HeroFieldset)).width,
        HeroFieldMetrics.defaultWidth(_theme),
      );
    });

    testWidgets('actions wrap and align', (WidgetTester tester) async {
      await pumpHero(
        tester,
        const SizedBox(
          width: 200,
          child: HeroFieldsetActions(
            alignment: WrapAlignment.end,
            children: <Widget>[
              HeroButton(child: Text('Save changes')),
              HeroButton(child: Text('Cancel')),
            ],
          ),
        ),
      );
      final Rect save = tester.getRect(find.byType(HeroButton).first);
      final Rect cancel = tester.getRect(find.byType(HeroButton).last);
      expect(cancel.top - save.bottom, 8);
      expect(
        cancel.right,
        tester.getRect(find.byType(HeroFieldsetActions)).right,
      );
    });

    testWidgets('RTL aligns the parts to the right', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        _profile(),
        textDirection: TextDirection.rtl,
        surfaceSize: const Size(480, 640),
      );
      final Rect fieldset = tester.getRect(find.byType(HeroFieldset));
      expect(
        tester.getRect(find.text('Profile Settings')).right,
        fieldset.right,
      );
      expect(
        tester.getRect(find.byType(HeroButton).first).right,
        fieldset.right,
      );
    });

    testWidgets('text scale 2.0 without overflow', (WidgetTester tester) async {
      await pumpHero(
        tester,
        _profile(),
        textScale: 2,
        surfaceSize: const Size(480, 1000),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Profile Settings'), findsOneWidget);
    });
  });

  group('HeroFieldset disabled', () {
    testWidgets('disables fields, buttons and dims labels', (
      WidgetTester tester,
    ) async {
      int saves = 0;
      await pumpHero(
        tester,
        _profile(isDisabled: true, onSave: () => saves++),
        surfaceSize: const Size(480, 640),
      );
      // Labels and inputs fade; the legend and description do not.
      expect(_opacityAbove(tester, _rich('Name*')), 0.5);
      expect(
        tester.widget<HeroFieldBox>(find.byType(HeroFieldBox).first).isDisabled,
        isTrue,
      );
      expect(_opacityAbove(tester, find.text('Profile Settings')), 1);
      expect(
        _opacityAbove(tester, find.text('Update your profile information.')),
        1,
      );
      expect(_opacityAbove(tester, find.text('Save changes')), 0.5);

      await tester.tap(find.byType(HeroInput).first, warnIfMissed: false);
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText).first)
            .focusNode
            .hasFocus,
        isFalse,
      );
      await tester.tap(find.text('Save changes'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(saves, 0);
    });

    testWidgets('re-enables when isDisabled turns false', (
      WidgetTester tester,
    ) async {
      int saves = 0;
      Map<String, Object?>? submitted;
      await pumpHero(
        tester,
        _profile(isDisabled: true, onSave: () => saves++),
        surfaceSize: const Size(480, 640),
      );
      await tester.pumpWidget(
        heroTestApp(
          _profile(
            onSave: () => saves++,
            onSubmit: (Map<String, Object?> data) => submitted = data,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_opacityAbove(tester, _rich('Name*')), 1);
      await tester.enterText(find.byType(EditableText).first, 'Jane');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(saves, 1);
      expect(submitted, <String, Object?>{'name': 'Jane', 'email': ''});
    });

    testWidgets('disabled fields are neither validated nor submitted', (
      WidgetTester tester,
    ) async {
      final GlobalKey<HeroFormState> form = GlobalKey<HeroFormState>();
      Map<String, Object?>? submitted;
      await pumpHero(
        tester,
        HeroForm(
          key: form,
          onSubmit: (Map<String, Object?> data) => submitted = data,
          child: const HeroFieldset(
            isDisabled: true,
            children: <Widget>[
              HeroTextField(name: 'name', label: 'Name', isRequired: true),
            ],
          ),
        ),
      );
      expect(form.currentState!.submit(), isTrue);
      expect(submitted, isEmpty);
    });

    testWidgets('an enabled scope cannot re-enable a disabled fieldset', (
      WidgetTester tester,
    ) async {
      await pumpHero(
        tester,
        const HeroFieldset(
          isDisabled: true,
          children: <Widget>[
            HeroDisabledScope(
              isDisabled: false,
              child: HeroButton(child: Text('Still disabled')),
            ),
          ],
        ),
      );
      expect(_opacityAbove(tester, find.text('Still disabled')), 0.5);
    });
  });

  group('HeroFieldset semantics', () {
    testWidgets('a group named by its legend', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(tester, _profile(), surfaceSize: const Size(480, 640));
      expect(
        tester.getSemantics(find.byType(HeroFieldset)),
        isSemantics(label: 'Profile Settings'),
      );
      // The legend is announced once, as the group name.
      expect(find.bySemanticsLabel('Profile Settings'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('semanticLabel overrides the legend', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroFieldset(
          legend: 'Profile',
          semanticLabel: 'Profile settings',
          children: <Widget>[HeroDescription.text('Text')],
        ),
      );
      expect(
        tester.getSemantics(find.byType(HeroFieldset)),
        isSemantics(label: 'Profile settings'),
      );
      handle.dispose();
    });

    testWidgets('disabled controls are announced as disabled', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await pumpHero(
        tester,
        const HeroFieldset(
          isDisabled: true,
          children: <Widget>[HeroButton(child: Text('Save'))],
        ),
      );
      final SemanticsData data = tester
          .getSemantics(find.byType(HeroButton))
          .getSemanticsData();
      expect(data.flagsCollection.isEnabled, Tristate.isFalse);
      handle.dispose();
    });
  });

  testWidgets('debug properties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const HeroFieldset(
      legend: 'Legend',
      isDisabled: true,
    ).debugFillProperties(builder);
    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();
    expect(description, contains('legend: "Legend"'));
    expect(description, contains('disabled'));
  });
}
