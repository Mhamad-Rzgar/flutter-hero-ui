import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _column(List<Widget> children) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: children,
);

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  heroGoldenTest(
    'basic, with a value and a description',
    name: 'basic',
    size: const Size(380, 300),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroSearchField(
        label: 'Search',
        placeholder: 'Search...',
        inputWidth: 280,
      ),
      HeroSearchField(
        label: 'Search products',
        defaultValue: 'Headphones',
        inputWidth: 280,
        description: 'Enter keywords to search for products',
      ),
      HeroSearchField(
        label: 'Search query',
        placeholder: 'Enter search query...',
        inputWidth: 280,
        isRequired: true,
        description: 'Minimum 3 characters required',
      ),
    ]),
  );

  heroGoldenTest(
    'variants on a surface',
    name: 'variants',
    size: const Size(420, 300),
    builder: (HeroThemeData theme) => HeroSurface(
      padding: EdgeInsets.all(theme.spacing(6)),
      borderRadius: BorderRadius.circular(theme.radii.xl3),
      child: _column(const <Widget>[
        HeroSearchField(
          label: 'Primary variant',
          placeholder: 'Search...',
          inputWidth: 280,
        ),
        HeroSearchField(
          label: 'Secondary variant',
          placeholder: 'Search...',
          defaultValue: 'Query',
          inputWidth: 280,
          variant: HeroFieldVariant.secondary,
        ),
      ]),
    ),
  );

  heroGoldenTest(
    'disabled, invalid and focused',
    name: 'states',
    size: const Size(380, 380),
    whilePerforming: (WidgetTester tester) async {
      await tester.tap(find.text('Focused...'));
    },
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroSearchField(
        label: 'Search',
        value: 'Disabled search',
        inputWidth: 280,
        description: 'This search field is disabled',
        isDisabled: true,
      ),
      HeroSearchField(
        label: 'Search',
        value: 'ab',
        inputWidth: 280,
        isRequired: true,
        isInvalid: true,
        errorMessage: 'Search query must be at least 3 characters',
      ),
      HeroSearchField(
        label: 'Search',
        placeholder: 'Focused...',
        inputWidth: 280,
      ),
    ]),
  );

  heroGoldenTest(
    'custom icons, full width and right to left',
    name: 'custom',
    size: const Size(440, 300),
    builder: (HeroThemeData theme) => SizedBox(
      width: 400,
      child: _column(<Widget>[
        const HeroSearchField(
          label: 'Search (Custom Icons)',
          defaultValue: 'Filters',
          searchIcon: HeroIcon(HeroIcons.funnel),
          clearIcon: HeroIcon(HeroIcons.circleXmarkFill),
          fullWidth: true,
        ),
        HeroSearchField(
          variant: HeroFieldVariant.secondary,
          children: <Widget>[
            const HeroLabel.text('Search docs'),
            HeroSearchFieldGroup(
              style: HeroFieldStyle(
                borderRadius: BorderRadius.circular(theme.radii.xl),
                backgroundColor: theme.colors.defaultColor,
              ),
              children: const <Widget>[
                HeroSearchFieldSearchIcon(),
                HeroSearchFieldInput(placeholder: 'Components, guides...'),
                HeroSearchFieldClearButton(),
              ],
            ),
          ],
        ),
        const Directionality(
          textDirection: TextDirection.rtl,
          child: HeroSearchField(
            label: 'Search',
            defaultValue: 'RTL',
            inputWidth: 280,
          ),
        ),
      ]),
    ),
  );
}
