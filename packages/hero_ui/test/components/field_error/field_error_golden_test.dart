import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  heroGoldenTest(
    'in an invalid field',
    name: 'field',
    size: const Size(320, 176),
    builder: (HeroThemeData theme) => const SizedBox(
      width: 256,
      child: HeroFieldScope(
        isInvalid: true,
        hideDescriptionWhenInvalid: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: <Widget>[
            HeroLabel.text('Username'),
            HeroInput(defaultValue: 'jr', fullWidth: true),
            HeroDescription.text('Hidden while invalid'),
            HeroFieldError.text('Username must be at least 3 characters'),
          ],
        ),
      ),
    ),
  );

  heroGoldenTest(
    'messages, builder, style, wrapping and RTL',
    name: 'content',
    size: const Size(320, 256),
    builder: (HeroThemeData theme) => SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          const HeroFieldScope(
            isInvalid: true,
            validationErrors: <String>[
              'Password must be at least 8 characters.',
              'Password must contain at least one number.',
            ],
            child: HeroFieldError(),
          ),
          HeroFieldScope(
            isInvalid: true,
            validationErrors: const <String>[
              'Must include an uppercase letter',
              'Must include a symbol',
            ],
            child: HeroFieldError(
              builder: (BuildContext context, HeroValidationResult v) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final String error in v.validationErrors) Text(error),
                ],
              ),
            ),
          ),
          const HeroFieldError.text(
            'Handle must be at least 3 characters',
            isInvalid: true,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const Directionality(
            textDirection: TextDirection.rtl,
            child: HeroFieldError.text('Right to left error', isInvalid: true),
          ),
        ],
      ),
    ),
  );
}
