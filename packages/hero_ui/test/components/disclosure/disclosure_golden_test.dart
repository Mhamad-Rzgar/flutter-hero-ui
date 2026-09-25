import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

Widget _preview(HeroThemeData theme, {bool expanded = true}) => HeroDisclosure(
  defaultExpanded: expanded,
  children: <Widget>[
    HeroDisclosureHeading(
      child: Center(
        child: HeroDisclosureTrigger.builder(
          builder: (BuildContext context, HeroDisclosureState state) =>
              HeroButton(
                variant: HeroButtonVariant.secondary,
                onPressed: state.toggle,
                startContent: const HeroIcon(HeroIcons.qrCode),
                endContent: const HeroDisclosureIndicator(),
                child: const Text('Preview HeroUI Native'),
              ),
        ),
      ),
    ),
    HeroDisclosureContent(
      child: HeroDisclosureBody(
        child: HeroSurface(
          borderRadius: BorderRadius.circular(theme.radii.xl3),
          padding: EdgeInsets.all(theme.spacing(4)),
          child: Text(
            'Scan this QR code with your camera app to preview the HeroUI '
            'native components.',
            textAlign: TextAlign.center,
            style: theme.typography.sm.copyWith(color: theme.colors.muted),
          ),
        ),
      ),
    ),
  ],
);

void main() {
  heroGoldenTest(
    'button trigger, expanded and collapsed',
    name: 'disclosure',
    size: const Size(420, 260),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[_preview(theme), _preview(theme, expanded: false)],
      ),
    ),
  );

  heroGoldenTest(
    'plain trigger with keyboard focus, disabled and RTL',
    name: 'states',
    size: const Size(420, 320),
    builder: (HeroThemeData theme) => SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: <Widget>[
          const HeroDisclosure(
            children: <Widget>[
              HeroDisclosureHeading(
                child: HeroDisclosureTrigger(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: <Widget>[
                      Text('Shipping details'),
                      HeroDisclosureIndicator(),
                    ],
                  ),
                ),
              ),
              HeroDisclosureContent(
                child: HeroDisclosureBody(child: Text('Orders ship fast.')),
              ),
            ],
          ),
          const HeroDisclosure(
            isDisabled: true,
            children: <Widget>[
              HeroDisclosureHeading(
                child: HeroDisclosureTrigger(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: <Widget>[
                      Text('Disabled disclosure'),
                      HeroDisclosureIndicator(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(width: 360, child: _preview(theme)),
          ),
        ],
      ),
    ),
    whilePerforming: (WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    },
  );
}
