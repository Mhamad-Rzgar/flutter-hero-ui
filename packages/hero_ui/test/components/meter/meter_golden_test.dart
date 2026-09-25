import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

/// `flex w-64 flex-col gap-6`.
Widget _stack(HeroThemeData theme, List<Widget> children) => SizedBox(
  width: theme.spacing(64),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    spacing: theme.spacing(6),
    children: children,
  ),
);

void main() {
  heroGoldenTest(
    'meter sizes',
    name: 'meter_sizes',
    size: const Size(300, 200),
    builder: (HeroThemeData theme) => _stack(theme, const <Widget>[
      HeroMeter(
        color: HeroColor.success,
        size: HeroSize.sm,
        value: 40,
        label: Text('Small'),
      ),
      HeroMeter(value: 60, label: Text('Medium')),
      HeroMeter(
        color: HeroColor.warning,
        size: HeroSize.lg,
        value: 80,
        label: Text('Large'),
      ),
    ]),
  );

  heroGoldenTest(
    'meter colors',
    name: 'meter_colors',
    size: const Size(300, 320),
    builder: (HeroThemeData theme) => _stack(theme, <Widget>[
      for (final HeroColor color in HeroColor.values)
        HeroMeter(color: color, value: 50, label: Text(color.name)),
    ]),
  );

  heroGoldenTest(
    'meter variations',
    name: 'meter_variations',
    size: const Size(300, 260),
    builder: (HeroThemeData theme) => _stack(theme, <Widget>[
      const HeroMeter(value: 45, semanticLabel: 'Storage usage'),
      HeroMeter(
        value: 750,
        maxValue: 1000,
        numberFormat: NumberFormat.simpleCurrency(name: 'USD'),
        label: const Text('Revenue'),
      ),
      const HeroMeter(value: 30, isDisabled: true, label: Text('Disabled')),
      HeroMeter(
        value: 68,
        children: <Widget>[
          const HeroLabel.text('Storage used'),
          HeroMeterOutput(style: TextStyle(color: theme.colors.muted)),
          HeroMeterTrack(
            borderRadius: BorderRadius.all(Radius.circular(theme.radii.full)),
            child: HeroMeterFill(
              color: theme.colors.warning,
              borderRadius: BorderRadius.all(Radius.circular(theme.radii.full)),
            ),
          ),
        ],
      ),
    ]),
  );

  heroGoldenTest(
    'meter right-to-left',
    name: 'meter_rtl',
    size: const Size(300, 90),
    builder: (HeroThemeData theme) => Directionality(
      textDirection: TextDirection.rtl,
      child: _stack(theme, const <Widget>[
        HeroMeter(value: 30, label: Text('Storage')),
      ]),
    ),
  );
}
