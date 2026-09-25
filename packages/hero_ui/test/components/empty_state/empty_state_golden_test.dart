import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  heroGoldenTest(
    'default, custom text, custom content and RTL',
    name: 'empty_state',
    size: const Size(320, 260),
    builder: (HeroThemeData theme) => SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: <Widget>[
          HeroSurface(
            borderRadius: BorderRadius.circular(theme.radii.xl3),
            padding: EdgeInsets.all(theme.spacing(1)),
            shadow: theme.shadows.surface,
            child: const HeroEmptyState(),
          ),
          const HeroEmptyState.text('No tags selected'),
          HeroEmptyState(
            child: Row(
              spacing: theme.spacing(2),
              children: const <Widget>[
                HeroIcon(HeroIcons.magnifier, size: 16),
                Expanded(child: Text('Try another search term')),
              ],
            ),
          ),
          const Directionality(
            textDirection: TextDirection.rtl,
            child: HeroEmptyState(),
          ),
        ],
      ),
    ),
  );
}
