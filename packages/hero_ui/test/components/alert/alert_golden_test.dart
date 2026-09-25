import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// Spinners turn forever; goldens render them still.
Widget _still(HeroThemeData theme, Widget child) => HeroTheme(
  data: theme.copyWith(motion: const HeroMotion(reduceMotion: true)),
  child: child,
);

Widget _stack(HeroThemeData theme, List<Widget> children) => SizedBox(
  width: 460,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    spacing: theme.spacing(4),
    children: children,
  ),
);

void main() {
  heroGoldenTest(
    'alert statuses',
    name: 'alert_statuses',
    size: const Size(492, 470),
    builder: (HeroThemeData theme) => _stack(theme, <Widget>[
      for (final HeroColor status in HeroColor.values)
        HeroAlert(
          status: status,
          title: Text(
            '${status.name[0].toUpperCase()}${status.name.substring(1)} alert',
          ),
          description: const Text('Check out our latest updates.'),
        ),
    ]),
  );

  heroGoldenTest(
    'alert parts',
    name: 'alert_parts',
    size: const Size(492, 360),
    builder: (HeroThemeData theme) => _still(
      theme,
      _stack(theme, <Widget>[
        // Below the `sm` breakpoint the action sits under the text.
        HeroAlert(
          status: HeroColor.accent,
          children: <Widget>[
            const HeroAlertIndicator(),
            HeroAlertContent(
              children: <Widget>[
                const HeroAlertTitle.text('Update available'),
                const HeroAlertDescription.text(
                  'A new version of the application is available.',
                ),
                Padding(
                  padding: EdgeInsets.only(top: theme.spacing(2)),
                  child: HeroButton(
                    size: HeroSize.sm,
                    onPressed: () {},
                    child: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ],
        ),
        const HeroAlert(
          status: HeroColor.success,
          title: Text('Profile updated successfully'),
          endContent: HeroCloseButton(),
        ),
        const HeroAlert(
          status: HeroColor.accent,
          indicator: HeroSpinner(size: HeroSpinnerSize.sm),
          title: Text('Processing your request'),
          description: Text('Please wait while we sync your data.'),
        ),
      ]),
    ),
  );

  heroGoldenTest(
    'alert customization',
    name: 'alert_custom',
    size: const Size(492, 190),
    builder: (HeroThemeData theme) {
      final HeroColors colors = theme.colors;
      final bool dark = theme.isDark;
      Color warning(double alpha) =>
          colors.warning.withValues(alpha: colors.warning.a * alpha);
      return SizedBox(
        width: 460,
        child: HeroAlert(
          status: HeroColor.warning,
          style: HeroAlertStyle(
            borderRadius: BorderRadius.all(Radius.circular(theme.radii.xl)),
            border: BorderSide(color: warning(dark ? 0.3 : 0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                warning(dark ? 0.15 : 0.1),
                colors.surface,
                if (dark) warning(0.05) else colors.surfaceSecondary,
              ],
            ),
            shadows: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: -1,
              ),
            ],
          ),
          background: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                top: -theme.spacing(8),
                right: -theme.spacing(8),
                width: theme.spacing(28),
                height: theme.spacing(28),
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    shadows: <BoxShadow>[
                      BoxShadow(
                        color: warning(dark ? 0.25 : 0.15),
                        blurRadius: 68,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          children: <Widget>[
            HeroAlertIndicator(color: colors.warning),
            HeroAlertContent(
              children: <Widget>[
                const HeroAlertTitle.text('Payment method expires soon'),
                const HeroAlertDescription.text(
                  'Your Visa ending in 4242 expires on March 28. Update '
                  'billing to avoid interrupting your Pro subscription.',
                ),
                Padding(
                  padding: EdgeInsets.only(top: theme.spacing(3)),
                  child: HeroButton(
                    size: HeroSize.sm,
                    variant: HeroButtonVariant.tertiary,
                    onPressed: () {},
                    child: const Text('Update billing'),
                  ),
                ),
              ],
            ),
            const HeroCloseButton(),
          ],
        ),
      );
    },
  );
}
