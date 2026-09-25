import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _drawer(
  HeroDrawerPlacement placement, {
  bool handle = false,
  bool closeTrigger = true,
  int paragraphs = 1,
  HeroBackdropVariant variant = HeroBackdropVariant.opaque,
}) {
  final String name =
      placement.name[0].toUpperCase() + placement.name.substring(1);
  return HeroDrawer(
    defaultOpen: true,
    trigger: const HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text('Open Drawer'),
    ),
    child: HeroDrawerBackdrop(
      variant: variant,
      child: HeroDrawerContent(
        placement: placement,
        child: HeroDrawerDialog(
          children: <Widget>[
            if (closeTrigger) const HeroDrawerCloseTrigger(),
            if (handle && placement != HeroDrawerPlacement.top)
              const HeroDrawerHandle(),
            HeroDrawerHeader(
              children: <Widget>[
                HeroDrawerHeading(child: Text('$name Drawer')),
              ],
            ),
            HeroDrawerBody(
              children: <Widget>[
                for (int i = 0; i < paragraphs; i++)
                  Text(
                    'This drawer slides in from the ${placement.name} edge '
                    'of the screen.',
                  ),
              ],
            ),
            const HeroDrawerFooter(
              children: <Widget>[
                HeroButton(
                  slot: HeroButtonSlot.close,
                  variant: HeroButtonVariant.secondary,
                  child: Text('Cancel'),
                ),
                HeroButton(slot: HeroButtonSlot.close, child: Text('Done')),
              ],
            ),
            if (handle && placement == HeroDrawerPlacement.top)
              const HeroDrawerHandle(),
          ],
        ),
      ),
    ),
  );
}

void main() {
  heroGoldenTest(
    'drawer bottom with handle',
    name: 'drawer_bottom',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) =>
        _drawer(HeroDrawerPlacement.bottom, handle: true),
  );

  heroGoldenTest(
    'drawer top with handle at the end',
    name: 'drawer_top',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) =>
        _drawer(HeroDrawerPlacement.top, handle: true),
  );

  heroGoldenTest(
    'drawer right',
    name: 'drawer_right',
    size: const Size(480, 480),
    builder: (HeroThemeData theme) => _drawer(HeroDrawerPlacement.right),
  );

  heroGoldenTest(
    'drawer left with a blurred backdrop',
    name: 'drawer_left_blur',
    size: const Size(480, 480),
    builder: (HeroThemeData theme) => Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text(
          'Page content',
          style: theme.typography.xl2.copyWith(color: theme.colors.accent),
        ),
        _drawer(HeroDrawerPlacement.left, variant: HeroBackdropVariant.blur),
      ],
    ),
  );

  heroGoldenTest(
    'drawer bottom scrollable content',
    name: 'drawer_scrollable',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) =>
        _drawer(HeroDrawerPlacement.bottom, handle: true, paragraphs: 20),
  );
}
