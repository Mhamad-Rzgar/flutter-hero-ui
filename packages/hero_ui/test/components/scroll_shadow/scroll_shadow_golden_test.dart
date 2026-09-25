import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const String _lorem =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam '
    'pulvinar risus non risus hendrerit venenatis. Pellentesque sit amet '
    'hendrerit risus, sed porttitor quam.';

Widget _paragraphs(HeroThemeData theme) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 16,
  children: <Widget>[
    for (int i = 0; i < 6; i++)
      Text(
        _lorem,
        style: theme.typography.sm.copyWith(color: theme.colors.foreground),
      ),
  ],
);

/// A scroll shadow scrolled to [scrolled] pixels, or to its end when
/// negative.
class _Scrolled extends StatefulWidget {
  const _Scrolled({required this.scrolled, required this.builder});

  final double scrolled;
  final Widget Function(ScrollController controller) builder;

  @override
  State<_Scrolled> createState() => _ScrolledState();
}

class _ScrolledState extends State<_Scrolled> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ScrollPosition position = _controller.position;
      _controller.jumpTo(
        widget.scrolled < 0 ? position.maxScrollExtent : widget.scrolled,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller);
}

Widget _tile(HeroThemeData theme, int index) => HeroCard(
  variant: HeroCardVariant.transparent,
  direction: Axis.horizontal,
  crossAxisAlignment: CrossAxisAlignment.center,
  padding: EdgeInsets.all(theme.spacing(1)),
  children: <Widget>[
    SizedBox.square(
      dimension: theme.spacing(12),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: <Color>[
            theme.colors.accent,
            theme.colors.success,
            theme.colors.warning,
          ][index % 3],
          shape: theme.shapeAll(theme.radii.xl),
        ),
      ),
    ),
    HeroCardTitle.text('Item $index'),
  ],
);

void main() {
  heroGoldenTest(
    'vertical fades grow with the scroll position',
    name: 'scroll_shadow_vertical',
    size: const Size(500, 260),
    builder: (HeroThemeData theme) => Row(
      spacing: 12,
      children: <Widget>[
        for (final double scrolled in <double>[0, 20, 200, -1])
          Expanded(
            child: HeroCard(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _Scrolled(
                  scrolled: scrolled,
                  builder: (ScrollController controller) => HeroScrollShadow(
                    controller: controller,
                    height: 200,
                    padding: EdgeInsets.all(theme.spacing(3)),
                    child: _paragraphs(theme),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  heroGoldenTest(
    'horizontal fades are logical',
    name: 'scroll_shadow_horizontal',
    size: const Size(420, 300),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final (double scrolled, TextDirection direction)
            in <(double, TextDirection)>[
              (0, TextDirection.ltr),
              (160, TextDirection.ltr),
              (160, TextDirection.rtl),
            ])
          Directionality(
            textDirection: direction,
            child: HeroCard(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _Scrolled(
                  scrolled: scrolled,
                  builder: (ScrollController controller) => HeroScrollShadow(
                    controller: controller,
                    orientation: Axis.horizontal,
                    padding: EdgeInsets.all(theme.spacing(2)),
                    child: Row(
                      spacing: 16,
                      children: <Widget>[
                        for (int i = 0; i < 8; i++) _tile(theme, i),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  heroGoldenTest(
    'size, offset and controlled visibility',
    name: 'scroll_shadow_options',
    size: const Size(500, 260),
    builder: (HeroThemeData theme) => Row(
      spacing: 12,
      children: <Widget>[
        Expanded(
          child: HeroScrollShadow(
            size: 80,
            height: 200,
            child: _paragraphs(theme),
          ),
        ),
        Expanded(
          child: _Scrolled(
            scrolled: 30,
            builder: (ScrollController controller) => HeroScrollShadow(
              controller: controller,
              offset: 20,
              hideScrollBar: true,
              height: 200,
              child: _paragraphs(theme),
            ),
          ),
        ),
        Expanded(
          child: HeroScrollShadow(
            visibility: HeroScrollShadowVisibility.both,
            height: 200,
            child: _paragraphs(theme),
          ),
        ),
        Expanded(
          child: HeroScrollShadow(
            visibility: HeroScrollShadowVisibility.top,
            height: 200,
            child: _paragraphs(theme),
          ),
        ),
      ],
    ),
  );

  heroGoldenTest(
    'custom decoration fades with the content',
    name: 'scroll_shadow_custom',
    size: const Size(400, 260),
    builder: (HeroThemeData theme) => HeroScrollShadow(
      hideScrollBar: true,
      size: 48,
      constraints: const BoxConstraints(maxHeight: 192),
      padding: EdgeInsets.all(theme.spacing(4)),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[theme.colors.surfaceSecondary, theme.colors.surface],
        ),
        shape: theme.shapeAll(
          theme.radii.xl,
          side: BorderSide(
            color: theme.colors.border.withValues(alpha: 0.8),
            width: theme.borderWidth,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: <Widget>[
          for (final String entry in <String>[
            'Reviewed quarterly goals with the design team.',
            'Shipped dark mode tokens to production.',
            'Merged accessibility fixes for form fields.',
            'Published updated component documentation.',
            'Scheduled performance audit for next sprint.',
            'Added scroll shadow demos to the docs site.',
          ])
            Text(
              entry,
              style: theme.typography.sm.copyWith(color: theme.colors.muted),
            ),
        ],
      ),
    ),
  );
}
