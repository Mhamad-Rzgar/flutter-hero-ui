import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  heroGoldenTest(
    'after a blocked submission',
    name: 'invalid_submit',
    size: const Size(360, 280),
    whilePerforming: (WidgetTester tester) async {
      await tester.tap(find.text('Submit'));
    },
    builder: (HeroThemeData theme) => const SizedBox(
      width: 288,
      child: HeroForm(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: <Widget>[
                HeroLabel.text('Email', isRequired: true),
                HeroInput(
                  name: 'email',
                  semanticLabel: 'Email',
                  type: HeroInputType.email,
                  isRequired: true,
                  fullWidth: true,
                  placeholder: 'john@example.com',
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: <Widget>[
                HeroLabel.text('Password'),
                HeroInput(
                  name: 'password',
                  semanticLabel: 'Password',
                  type: HeroInputType.password,
                  defaultValue: 'secret',
                  fullWidth: true,
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: <Widget>[
                HeroButton(
                  type: HeroButtonType.submit,
                  startContent: HeroIcon(HeroIcons.check),
                  child: Text('Submit'),
                ),
                HeroButton(
                  type: HeroButtonType.reset,
                  variant: HeroButtonVariant.secondary,
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
