import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  heroGoldenTest(
    'basic, description and required',
    name: 'basic',
    size: const Size(320, 320),
    builder: (HeroThemeData theme) => const SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          HeroTextField(
            name: 'email',
            type: HeroInputType.email,
            children: <Widget>[
              HeroLabel.text('Email'),
              HeroInput(placeholder: 'Enter your email'),
            ],
          ),
          HeroTextField(
            label: 'Username',
            placeholder: 'Enter username',
            description: 'Choose a unique username for your account',
          ),
          HeroTextField(
            label: 'Full Name',
            placeholder: 'John Doe',
            description: 'This field is required',
            isRequired: true,
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'disabled, invalid and text area',
    name: 'states',
    size: const Size(320, 400),
    builder: (HeroThemeData theme) => const SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: <Widget>[
          HeroTextField(
            label: 'Account ID',
            value: 'USR-12345',
            placeholder: 'Auto-generated',
            description: 'This field cannot be edited',
            isDisabled: true,
          ),
          HeroTextField(
            label: 'Email',
            placeholder: 'user@example.com',
            description: 'Hidden while invalid',
            errorMessage: 'Please enter a valid email address',
            type: HeroInputType.email,
            isInvalid: true,
          ),
          HeroTextField(
            label: 'Message',
            placeholder: 'Write your message here...',
            description: 'Maximum 500 characters',
            isMultiline: true,
            rows: 4,
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'secondary on a surface',
    name: 'on_surface',
    size: const Size(420, 420),
    builder: (HeroThemeData theme) => HeroSurface(
      padding: EdgeInsets.all(theme.spacing(6)),
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      child: const SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            HeroTextField(
              label: 'Your name',
              placeholder: 'John',
              description: "We'll never share this with anyone else",
              variant: HeroFieldVariant.secondary,
            ),
            HeroTextField(
              label: 'Email',
              placeholder: 'john@example.com',
              type: HeroInputType.email,
              variant: HeroFieldVariant.secondary,
            ),
            HeroTextField(
              label: 'Bio',
              placeholder: 'Tell us about yourself...',
              description: 'Minimum 4 rows',
              isMultiline: true,
              rows: 4,
              variant: HeroFieldVariant.secondary,
            ),
          ],
        ),
      ),
    ),
  );

  heroGoldenTest(
    'full width, focused and RTL',
    name: 'full_width',
    size: const Size(440, 320),
    whilePerforming: (WidgetTester tester) async {
      await tester.tap(find.text('John'));
    },
    builder: (HeroThemeData theme) => const SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          HeroTextField(
            label: 'Your name',
            placeholder: 'John',
            fullWidth: true,
          ),
          HeroTextField(
            label: 'Password',
            type: HeroInputType.password,
            defaultValue: 'secret',
            errorMessage: 'Password must be longer than 8 characters',
            fullWidth: true,
            isInvalid: true,
            isRequired: true,
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 400,
              child: HeroTextField(
                label: 'Name',
                placeholder: 'Right to left',
                isRequired: true,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
