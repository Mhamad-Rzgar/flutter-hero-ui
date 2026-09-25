import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _placed(String label, HeroPlacement placement) => HeroPopover(
  defaultOpen: true,
  content: HeroPopoverContent(
    isNonModal: true,
    placement: placement,
    child: HeroPopoverDialog(
      children: <Widget>[const HeroPopoverArrow(), Text('$label placement')],
    ),
  ),
  child: HeroButton(variant: HeroButtonVariant.tertiary, child: Text(label)),
);

void main() {
  heroGoldenTest(
    'popover dialog with heading',
    name: 'popover_basic',
    size: const Size(400, 240),
    builder: (HeroThemeData theme) => Align(
      alignment: Alignment.topCenter,
      child: HeroPopover(
        defaultOpen: true,
        content: HeroPopoverContent(
          constraints: BoxConstraints(maxWidth: theme.spacing(64)),
          child: HeroPopoverDialog(
            children: <Widget>[
              const HeroPopoverHeading(child: Text('Popover Title')),
              SizedBox(height: theme.spacing(2)),
              Text(
                'This is the popover content. You can put any content here.',
                style: TextStyle(color: theme.colors.muted),
              ),
            ],
          ),
        ),
        child: const HeroButton(child: Text('Click me')),
      ),
    ),
  );

  heroGoldenTest(
    'popover placements with arrows',
    name: 'popover_placements',
    size: const Size(480, 320),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _placed('Top', HeroPlacement.top),
        SizedBox(height: theme.spacing(6)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _placed('Left', HeroPlacement.left),
            SizedBox(width: theme.spacing(8)),
            _placed('Right', HeroPlacement.right),
          ],
        ),
        SizedBox(height: theme.spacing(6)),
        _placed('Bottom', HeroPlacement.bottom),
      ],
    ),
  );
}
