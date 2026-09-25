import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _open(String trigger, HeroTooltipContent content) => HeroTooltip(
  isOpen: true,
  content: content,
  child: HeroButton(
    variant: HeroButtonVariant.tertiary,
    onPressed: () {},
    child: Text(trigger),
  ),
);

void main() {
  heroGoldenTest(
    'tooltip placements with arrows',
    name: 'tooltip_placements',
    size: const Size(480, 300),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _open(
          'Top',
          const HeroTooltipContent(showArrow: true, child: Text('Top')),
        ),
        SizedBox(height: theme.spacing(4)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _open(
              'Left',
              const HeroTooltipContent(
                showArrow: true,
                placement: HeroPlacement.left,
                child: Text('Left'),
              ),
            ),
            SizedBox(width: theme.spacing(24)),
            _open(
              'Right',
              const HeroTooltipContent(
                showArrow: true,
                placement: HeroPlacement.right,
                child: Text('Right'),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.spacing(4)),
        _open(
          'Bottom',
          const HeroTooltipContent(
            showArrow: true,
            placement: HeroPlacement.bottom,
            child: Text('Bottom'),
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'tooltip content: plain, rich, custom styles',
    name: 'tooltip_content',
    size: const Size(480, 260),
    builder: (HeroThemeData theme) => Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _open(
          'Hover me',
          const HeroTooltipContent(child: Text('This is a tooltip')),
        ),
        SizedBox(width: theme.spacing(10)),
        HeroTooltip(
          isOpen: true,
          content: HeroTooltipContent(
            showArrow: true,
            placement: HeroPlacement.bottom,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: theme.spacing(1)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Jane Doe',
                    style: TextStyle(fontWeight: HeroTypography.semibold),
                  ),
                  Text(
                    'jane@example.com',
                    style: TextStyle(color: theme.colors.muted),
                  ),
                ],
              ),
            ),
          ),
          child: const HeroTooltipTrigger(
            child: HeroAvatar(size: HeroSize.sm, name: 'Jane Doe'),
          ),
        ),
        SizedBox(width: theme.spacing(10)),
        _open(
          'Share link',
          HeroTooltipContent(
            backgroundColor: theme.colors.surface,
            foregroundColor: theme.colors.foreground,
            side: BorderSide(
              color: theme.colors.border.withValues(alpha: 0.8),
              width: theme.borderWidth,
            ),
            borderRadius: theme.radii.lg,
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing(2.5),
              vertical: theme.spacing(1),
            ),
            child: const Text('Copied to clipboard'),
          ),
        ),
      ],
    ),
  );
}
