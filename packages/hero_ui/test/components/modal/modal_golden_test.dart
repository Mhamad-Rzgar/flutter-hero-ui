import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hero_ui/hero_ui.dart';

import '../../helpers/hero_test_app.dart';

const String _text =
    'A beautiful, fast, and modern React UI library for building accessible '
    'and customizable web applications with ease.';

Widget _modal(
  HeroThemeData theme, {
  HeroBackdropVariant variant = HeroBackdropVariant.opaque,
  HeroModalPlacement placement = HeroModalPlacement.auto,
  HeroModalScroll scroll = HeroModalScroll.inside,
  HeroModalSize size = HeroModalSize.md,
  double? maxWidth = 360,
  int paragraphs = 1,
  List<Widget>? footer,
}) {
  return HeroModal(
    defaultOpen: true,
    trigger: const HeroButton(
      variant: HeroButtonVariant.secondary,
      child: Text('Open Modal'),
    ),
    child: HeroModalBackdrop(
      variant: variant,
      child: HeroModalContainer(
        placement: placement,
        scroll: scroll,
        size: size,
        child: HeroModalDialog(
          maxWidth: maxWidth,
          children: <Widget>[
            const HeroModalCloseTrigger(),
            HeroModalHeader(
              children: <Widget>[
                HeroModalIcon(
                  backgroundColor: theme.colors.defaultColor,
                  child: const HeroIcon(HeroIcons.rocket),
                ),
                const HeroModalHeading(child: Text('Welcome to HeroUI')),
              ],
            ),
            HeroModalBody(
              children: <Widget>[
                for (int i = 0; i < paragraphs; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: paragraphs > 1 ? theme.spacing(3) : 0,
                    ),
                    child: Text(
                      paragraphs > 1 ? 'Paragraph ${i + 1}: $_text' : _text,
                    ),
                  ),
              ],
            ),
            HeroModalFooter(
              children:
                  footer ??
                  const <Widget>[
                    HeroButton(
                      slot: HeroButtonSlot.close,
                      fullWidth: true,
                      child: Text('Continue'),
                    ),
                  ],
            ),
          ],
        ),
      ),
    ),
  );
}

const List<Widget> _cancelConfirm = <Widget>[
  HeroButton(
    slot: HeroButtonSlot.close,
    variant: HeroButtonVariant.secondary,
    child: Text('Cancel'),
  ),
  HeroButton(slot: HeroButtonSlot.close, child: Text('Confirm')),
];

void main() {
  heroGoldenTest(
    'modal default (bottom sheet below 640 px)',
    name: 'modal_default',
    size: const Size(400, 520),
    builder: _modal,
  );

  heroGoldenTest(
    'modal centered from the sm breakpoint',
    name: 'modal_desktop',
    size: const Size(520, 480),
    builder: (HeroThemeData theme) => HeroTheme(
      data: theme.copyWith(density: HeroDensity.desktop),
      child: _modal(theme, maxWidth: null, footer: _cancelConfirm),
    ),
  );

  heroGoldenTest(
    'modal top placement with a blurred backdrop',
    name: 'modal_top_blur',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) => Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text(
          'Page content behind the backdrop',
          style: theme.typography.xl2.copyWith(color: theme.colors.accent),
        ),
        _modal(
          theme,
          placement: HeroModalPlacement.top,
          variant: HeroBackdropVariant.blur,
        ),
      ],
    ),
  );

  heroGoldenTest(
    'modal transparent backdrop, xs size',
    name: 'modal_transparent_xs',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) => _modal(
      theme,
      placement: HeroModalPlacement.center,
      variant: HeroBackdropVariant.transparent,
      size: HeroModalSize.xs,
      maxWidth: null,
    ),
  );

  heroGoldenTest(
    'modal cover size',
    name: 'modal_cover',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) => _modal(
      theme,
      size: HeroModalSize.cover,
      maxWidth: null,
      footer: _cancelConfirm,
    ),
  );

  heroGoldenTest(
    'modal full size',
    name: 'modal_full',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) => _modal(
      theme,
      size: HeroModalSize.full,
      maxWidth: null,
      footer: _cancelConfirm,
    ),
  );

  heroGoldenTest(
    'modal scroll inside',
    name: 'modal_scroll_inside',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) =>
        _modal(theme, paragraphs: 8, footer: _cancelConfirm),
  );

  heroGoldenTest(
    'modal scroll outside',
    name: 'modal_scroll_outside',
    size: const Size(400, 480),
    builder: (HeroThemeData theme) => _modal(
      theme,
      paragraphs: 8,
      scroll: HeroModalScroll.outside,
      footer: _cancelConfirm,
    ),
  );

  heroGoldenTest(
    'modal close trigger keyboard focus',
    name: 'modal_focus',
    size: const Size(400, 400),
    builder: (HeroThemeData theme) => _modal(theme, footer: _cancelConfirm),
    whilePerforming: (WidgetTester tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 300));
    },
  );

  heroGoldenTest(
    'modal custom trigger states',
    name: 'modal_trigger',
    size: const Size(360, 120),
    builder: (HeroThemeData theme) => HeroModal(
      trigger: HeroModalTrigger(
        borderRadius: BorderRadius.circular(theme.radii.xl2),
        builder: (BuildContext context, HeroInteractionState state) =>
            DecoratedBox(
              decoration: ShapeDecoration(
                color: state.isHovered
                    ? theme.colors.surfaceSecondary
                    : theme.colors.surface,
                shape: theme.shapeAll(theme.radii.xl2),
                shadows: theme.shadows.surface.boxShadows,
              ),
              child: Padding(
                padding: EdgeInsets.all(theme.spacing(4)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: theme.spacing(3),
                  children: <Widget>[
                    HeroModalIcon(
                      backgroundColor: theme.colors.accentSoft,
                      foregroundColor: theme.colors.accentSoftForeground,
                      child: const HeroIcon(HeroIcons.gear),
                    ),
                    const Text('Settings'),
                  ],
                ),
              ),
            ),
      ),
      child: const SizedBox.shrink(),
    ),
    whilePerforming: (WidgetTester tester) async {
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(
        location: tester.getCenter(find.byType(HeroModalTrigger)),
      );
      addTearDown(mouse.removePointer);
    },
  );
}
