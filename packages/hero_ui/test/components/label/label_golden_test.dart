import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _field(Widget label, Widget input) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 4,
  children: <Widget>[label, input],
);

void main() {
  heroGoldenTest(
    'states',
    name: 'states',
    size: const Size(320, 200),
    builder: (HeroThemeData theme) => const Wrap(
      direction: Axis.vertical,
      spacing: 12,
      children: <Widget>[
        HeroLabel.text('Name'),
        HeroLabel.text('Email Address', isRequired: true),
        HeroLabel.text('Username', isDisabled: true),
        HeroLabel.text('Password', isInvalid: true),
        HeroLabel(isRequired: true, child: Text('Widget child')),
      ],
    ),
  );

  heroGoldenTest(
    'with inputs',
    name: 'with_inputs',
    size: const Size(320, 260),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: <Widget>[
        _field(
          const HeroLabel.text('Email Address', isRequired: true),
          const HeroInput(type: HeroInputType.email, width: 256),
        ),
        _field(
          const HeroLabel.text('Username', isDisabled: true),
          const HeroInput(isDisabled: true, width: 256),
        ),
        const HeroFieldScope(
          isInvalid: true,
          isRequired: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: <Widget>[
              HeroLabel.text('Password (from scope)'),
              HeroInput(width: 256),
            ],
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'custom style and RTL',
    name: 'custom',
    size: const Size(320, 160),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        HeroLabel.text(
          'REPOSITORY',
          style: theme.typography
              .style(
                HeroFontSize.xs,
                weight: HeroTypography.semibold,
                tracking: 0.025,
              )
              .copyWith(color: theme.colors.accent),
        ),
        const Directionality(
          textDirection: TextDirection.rtl,
          child: HeroLabel.text('Right to left', isRequired: true),
        ),
      ],
    ),
  );
}
