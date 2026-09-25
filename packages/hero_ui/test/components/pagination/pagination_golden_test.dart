import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

void main() {
  Widget pagination({
    HeroSize size = HeroSize.md,
    int page = 1,
    int total = 3,
    bool ellipsis = false,
    bool disabledNav = false,
    Widget? summary,
    MainAxisAlignment alignment = MainAxisAlignment.center,
  }) {
    final List<int?> pages = ellipsis
        ? heroPaginationRange(page: page, total: total)
        : <int?>[for (int i = 1; i <= total; i++) i];
    return HeroPagination(
      size: size,
      mainAxisAlignment: alignment,
      children: <Widget>[
        ?summary,
        HeroPaginationContent(
          children: <Widget>[
            HeroPaginationItem(
              child: HeroPaginationPrevious(
                isDisabled: disabledNav || page == 1,
                onPressed: () {},
                children: const <Widget>[
                  HeroPaginationPreviousIcon(),
                  Text('Previous'),
                ],
              ),
            ),
            for (final int? p in pages)
              HeroPaginationItem(
                child: p == null
                    ? const HeroPaginationEllipsis()
                    : HeroPaginationLink(
                        isActive: p == page,
                        onPressed: () {},
                        child: Text('$p'),
                      ),
              ),
            HeroPaginationItem(
              child: HeroPaginationNext(
                isDisabled: disabledNav || page == total,
                onPressed: () {},
                children: const <Widget>[
                  Text('Next'),
                  HeroPaginationNextIcon(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  heroGoldenTest(
    'sizes',
    name: 'pagination_sizes',
    size: const Size(440, 200),
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        for (final HeroSize size in HeroSize.values)
          pagination(size: size, page: 2),
      ],
    ),
  );

  heroGoldenTest(
    'ellipsis, disabled and hovered',
    name: 'pagination_states',
    size: const Size(520, 200),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('7').first));
    },
    builder: (HeroThemeData theme) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: <Widget>[
        pagination(page: 6, total: 12, ellipsis: true),
        pagination(disabledNav: true),
      ],
    ),
  );

  heroGoldenTest(
    'summary on a narrow screen',
    name: 'pagination_summary',
    size: const Size(420, 160),
    builder: (HeroThemeData theme) => pagination(
      total: 12,
      ellipsis: true,
      alignment: MainAxisAlignment.spaceBetween,
      summary: const HeroPaginationSummary(
        child: Text('Showing 1-10 of 120 results'),
      ),
    ),
  );

  heroGoldenTest(
    'keyboard focus',
    name: 'pagination_focus',
    size: const Size(420, 90),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      Focus.of(tester.element(find.text('2'))).requestFocus();
    },
    builder: (HeroThemeData theme) => pagination(),
  );
}
