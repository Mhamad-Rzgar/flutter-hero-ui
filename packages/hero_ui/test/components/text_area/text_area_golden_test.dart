import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _column(List<Widget> children, {double width = 280}) => SizedBox(
  width: width,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 12,
    children: children,
  ),
);

void main() {
  setUp(() => EditableText.debugDeterministicCursor = true);
  tearDown(() => EditableText.debugDeterministicCursor = false);

  heroGoldenTest(
    'variants',
    name: 'variants',
    size: const Size(320, 280),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroTextArea(fullWidth: true, placeholder: 'Primary textarea'),
      HeroTextArea(
        fullWidth: true,
        placeholder: 'Secondary textarea',
        variant: HeroFieldVariant.secondary,
      ),
      HeroTextArea(
        fullWidth: true,
        defaultValue:
            'A longer note that wraps onto more lines than the text area '
            'shows, so it scrolls.',
      ),
    ]),
  );

  heroGoldenTest(
    'rows and resize',
    name: 'rows',
    size: const Size(320, 360),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroTextArea(fullWidth: true, rows: 3, placeholder: 'Three rows'),
      HeroTextArea(
        fullWidth: true,
        rows: 6,
        resize: HeroTextAreaResize.vertical,
        placeholder: 'Six rows, vertical resize',
      ),
    ]),
  );

  heroGoldenTest(
    'states',
    name: 'states',
    size: const Size(320, 300),
    builder: (HeroThemeData theme) => _column(const <Widget>[
      HeroTextArea(fullWidth: true, placeholder: 'Focused', autofocus: true),
      HeroTextArea(fullWidth: true, placeholder: 'Invalid', isInvalid: true),
      HeroTextArea(fullWidth: true, defaultValue: 'Disabled', isDisabled: true),
    ]),
  );

  heroGoldenTest(
    'custom style, sm text and RTL',
    name: 'custom',
    size: const Size(360, 300),
    builder: (HeroThemeData theme) => _column(width: 320, <Widget>[
      HeroTextArea(
        fullWidth: true,
        height: 112,
        placeholder: 'Add a note...',
        style: HeroFieldStyle(
          borderRadius: BorderRadius.circular(theme.radii.xl),
          borderWidth: theme.borderWidth,
          borderColor: theme.colors.border.withValues(alpha: 0.8),
          backgroundColor: theme.colors.surface,
          shadow: HeroShadow(
            boxShadows: <BoxShadow>[
              BoxShadow(
                color: theme.isDark
                    ? theme.colors.white.withValues(alpha: 0.1)
                    : theme.colors.black.withValues(alpha: 0.05),
                spreadRadius: 1,
              ),
              ...theme.shadows.surface.boxShadows,
            ],
          ),
        ),
      ),
      HeroTheme(
        data: theme.copyWith(density: HeroDensity.desktop),
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: HeroTextArea(
            fullWidth: true,
            defaultValue: 'Right to left, text-sm',
            resize: HeroTextAreaResize.vertical,
          ),
        ),
      ),
    ]),
  );
}
