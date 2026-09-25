import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _alert({
  HeroColor status = HeroColor.danger,
  HeroAlertDialogSize size = HeroAlertDialogSize.md,
  HeroModalPlacement placement = HeroModalPlacement.auto,
  double? maxWidth = 400,
  Widget? icon,
}) {
  return HeroAlertDialog(
    defaultOpen: true,
    trigger: const HeroButton(
      variant: HeroButtonVariant.danger,
      child: Text('Delete Project'),
    ),
    child: HeroAlertDialogBackdrop(
      child: HeroAlertDialogContainer(
        size: size,
        placement: placement,
        child: HeroAlertDialogDialog(
          maxWidth: maxWidth,
          children: <Widget>[
            const HeroAlertDialogCloseTrigger(),
            HeroAlertDialogHeader(
              children: <Widget>[
                HeroAlertDialogIcon(status: status, child: icon),
                const HeroAlertDialogHeading(
                  child: Text('Delete project permanently?'),
                ),
              ],
            ),
            const HeroAlertDialogBody(
              child: Text.rich(
                TextSpan(
                  text: 'This will permanently delete ',
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'My Awesome Project',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text:
                          ' and all of its data. This action cannot be '
                          'undone.',
                    ),
                  ],
                ),
              ),
            ),
            const HeroAlertDialogFooter(
              children: <Widget>[
                HeroButton(
                  slot: HeroButtonSlot.close,
                  variant: HeroButtonVariant.tertiary,
                  child: Text('Cancel'),
                ),
                HeroButton(
                  slot: HeroButtonSlot.close,
                  variant: HeroButtonVariant.danger,
                  child: Text('Delete Project'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  heroGoldenTest(
    'alert dialog default (bottom below 640 px)',
    name: 'alert_dialog_default',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) => _alert(),
  );

  heroGoldenTest(
    'alert dialog centered from the sm breakpoint, cover size',
    name: 'alert_dialog_cover',
    size: const Size(520, 400),
    builder: (HeroThemeData theme) => HeroTheme(
      data: theme.copyWith(density: HeroDensity.desktop),
      child: _alert(
        status: HeroColor.warning,
        size: HeroAlertDialogSize.cover,
        maxWidth: null,
      ),
    ),
  );

  heroGoldenTest(
    'alert dialog status icons',
    name: 'alert_dialog_statuses',
    size: const Size(400, 80),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroColor status in HeroColor.values)
          HeroAlertDialogIcon(status: status),
        const HeroAlertDialogIcon(
          status: HeroColor.warning,
          child: HeroIcon(HeroIcons.lockOpen),
        ),
      ],
    ),
  );
}
