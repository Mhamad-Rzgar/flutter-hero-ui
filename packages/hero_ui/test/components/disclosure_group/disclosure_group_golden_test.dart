import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _item(
  HeroThemeData theme,
  String id,
  HeroIconData icon,
  String title,
  String body,
) => HeroDisclosure(
  id: id,
  children: <Widget>[
    HeroDisclosureHeading(
      child: HeroDisclosureTrigger.builder(
        builder: (BuildContext context, HeroDisclosureState state) =>
            HeroButton(
              variant: state.isExpanded
                  ? HeroButtonVariant.secondary
                  : HeroButtonVariant.tertiary,
              fullWidth: true,
              onPressed: state.toggle,
              isDisabled: state.isDisabled,
              style: state.isExpanded
                  ? null
                  : HeroButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (Set<WidgetState> states) =>
                            states.contains(WidgetState.hovered)
                            ? null
                            : theme.colors.defaultColor.withValues(alpha: 0),
                      ),
                    ),
              child: Row(
                spacing: theme.spacing(2),
                children: <Widget>[
                  HeroIcon(icon),
                  Expanded(child: Text(title)),
                  HeroDisclosureIndicator(color: theme.colors.muted),
                ],
              ),
            ),
      ),
    ),
    HeroDisclosureContent(
      child: HeroDisclosureBody(
        child: Text(
          body,
          textAlign: TextAlign.center,
          style: theme.typography.sm.copyWith(color: theme.colors.muted),
        ),
      ),
    ),
  ],
);

void main() {
  heroGoldenTest(
    'group with button triggers and a separator',
    name: 'disclosure_group',
    size: const Size(420, 260),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: HeroDisclosureGroup(
        defaultExpandedKeys: const <Object>{'preview'},
        children: <Widget>[
          _item(
            theme,
            'preview',
            HeroIcons.qrCode,
            'Preview HeroUI Native',
            'Scan this QR code with your camera app to preview the HeroUI '
                'native components.',
          ),
          HeroSeparator(
            margin: EdgeInsets.symmetric(vertical: theme.spacing(2)),
          ),
          _item(
            theme,
            'download',
            HeroIcons.smartphone,
            'Download App',
            'Download the HeroUI native app to explore our mobile components.',
          ),
        ],
      ),
    ),
  );

  heroGoldenTest(
    'disabled group on a soft container',
    name: 'disabled',
    size: const Size(420, 200),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: HeroSurface(
        color: theme.colors.defaultSoft,
        borderRadius: BorderRadius.circular(theme.radii.xl),
        padding: EdgeInsets.all(theme.spacing(2)),
        child: HeroDisclosureGroup(
          isDisabled: true,
          children: <Widget>[
            _item(
              theme,
              'billing',
              HeroIcons.creditCard,
              'Billing',
              'Invoices',
            ),
            HeroSeparator(
              margin: EdgeInsets.symmetric(vertical: theme.spacing(1)),
            ),
            _item(
              theme,
              'support',
              HeroIcons.circleQuestion,
              'Support',
              'Help',
            ),
          ],
        ),
      ),
    ),
  );
}
