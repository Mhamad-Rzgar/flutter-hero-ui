import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const List<Widget> _threeThree = <Widget>[
  HeroInputOTPGroup(
    children: <Widget>[
      HeroInputOTPSlot(index: 0),
      HeroInputOTPSlot(index: 1),
      HeroInputOTPSlot(index: 2),
    ],
  ),
  HeroInputOTPSeparator(),
  HeroInputOTPGroup(
    children: <Widget>[
      HeroInputOTPSlot(index: 3),
      HeroInputOTPSlot(index: 4),
      HeroInputOTPSlot(index: 5),
    ],
  ),
];

Widget _labelled(String label, Widget otp) => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: <Widget>[HeroLabel.text(label), otp],
);

/// Reduced motion: no caret blink or value animation in the goldens.
Widget _still(HeroThemeData theme, Widget child) => HeroTheme(
  data: theme.copyWith(motion: const HeroMotion(reduceMotion: true)),
  child: child,
);

void main() {
  heroGoldenTest(
    'empty, partly filled with the caret, complete',
    name: 'basic',
    size: const Size(320, 300),
    whilePerforming: (WidgetTester tester) async {
      await tester.tap(find.byType(HeroInputOTP).at(1));
    },
    builder: (HeroThemeData theme) => _still(
      theme,
      SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: <Widget>[
            _labelled(
              'Verify account',
              const HeroInputOTP(maxLength: 6, children: _threeThree),
            ),
            _labelled(
              'Focused',
              const HeroInputOTP(
                maxLength: 6,
                defaultValue: '12',
                children: _threeThree,
              ),
            ),
            _labelled(
              'Complete',
              const HeroInputOTP(
                maxLength: 6,
                defaultValue: '482913',
                children: _threeThree,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  heroGoldenTest(
    'secondary on a surface, disabled, invalid',
    name: 'states',
    size: const Size(360, 360),
    builder: (HeroThemeData theme) => _still(
      theme,
      HeroSurface(
        padding: EdgeInsets.all(theme.spacing(6)),
        borderRadius: BorderRadius.circular(theme.radii.xl3),
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: <Widget>[
              _labelled(
                'Secondary variant',
                const HeroInputOTP(
                  maxLength: 6,
                  defaultValue: '123',
                  variant: HeroFieldVariant.secondary,
                  children: _threeThree,
                ),
              ),
              _labelled(
                'Disabled',
                const HeroInputOTP(
                  maxLength: 6,
                  defaultValue: '12',
                  isDisabled: true,
                  children: _threeThree,
                ),
              ),
              _labelled(
                'Invalid',
                const HeroInputOTP(
                  maxLength: 6,
                  defaultValue: '123457',
                  isInvalid: true,
                  children: _threeThree,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  heroGoldenTest(
    'four digits, placeholder, custom slots and RTL',
    name: 'custom',
    size: const Size(320, 380),
    whilePerforming: (WidgetTester tester) async {
      await tester.tap(find.byType(HeroInputOTP).at(2));
    },
    builder: (HeroThemeData theme) {
      final HeroFieldStyle slot = HeroFieldStyle(
        borderRadius: BorderRadius.circular(theme.radii.lg),
        backgroundColor: theme.colors.defaultColor,
        focusBackgroundColor: theme.colors.accentSoft,
      );
      return _still(
        theme,
        SizedBox(
          width: 288,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: <Widget>[
              _labelled(
                'Enter PIN',
                const HeroInputOTP(maxLength: 4, defaultValue: '73'),
              ),
              _labelled(
                'Placeholder',
                const HeroInputOTP(
                  maxLength: 6,
                  placeholder: '000000',
                  groupSizes: <int>[3, 3],
                ),
              ),
              _labelled(
                'Custom',
                HeroInputOTP(
                  maxLength: 6,
                  defaultValue: '12',
                  children: <Widget>[
                    HeroInputOTPGroup(
                      children: <Widget>[
                        for (int i = 0; i < 3; i++)
                          HeroInputOTPSlot(index: i, style: slot),
                      ],
                    ),
                    HeroInputOTPSeparator(color: theme.colors.border),
                    HeroInputOTPGroup(
                      children: <Widget>[
                        for (int i = 3; i < 6; i++)
                          HeroInputOTPSlot(index: i, style: slot),
                      ],
                    ),
                  ],
                ),
              ),
              const Directionality(
                textDirection: TextDirection.rtl,
                child: HeroInputOTP(
                  maxLength: 4,
                  defaultValue: '12',
                  groupSizes: <int>[2, 2],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
