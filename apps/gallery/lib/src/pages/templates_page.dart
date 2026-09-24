import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../templates.dart';
import '../widgets/gallery_widgets.dart';
import '../widgets/theme_sheet.dart';

/// Lists the Pro templates; each opens as a full screen.
class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key, this.showBack = true});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GalleryTopBar(
          title: 'Templates',
          leading: showBack
              ? GalleryIconButton(
                  icon: HeroIcons.chevronLeft,
                  label: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,
          actions: const <Widget>[ThemeButton()],
        ),
        Expanded(
          child: templateRegistry.isEmpty
              ? Center(
                  child: Text(
                    'Templates arrive with the Pro tier.',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.muted,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    for (final TemplateEntry template in templateRegistry)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TemplateTile(template: template),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template});

  final TemplateEntry template;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroInteractable(
      onPressed: () => Navigator.of(context, rootNavigator: true).push(
        HeroPageRoute<void>(
          fullscreenDialog: true,
          builder: (BuildContext context) =>
              _TemplateScreen(template: template),
        ),
      ),
      builder: (BuildContext context, HeroInteractionState state, _) {
        final OutlinedBorder shape = theme.shapeAll(
          theme.radii.xl3,
          side: BorderSide(color: theme.colors.border),
        );
        return HeroFocusRing(
          visible: state.isFocusVisible,
          shape: shape,
          child: HeroPressScale(
            pressed: state.isPressed,
            scale: 0.98,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: state.isHovered
                    ? theme.colors.surfaceHover
                    : theme.colors.surface,
                shape: shape,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    template.name,
                    style: theme.typography.h5.copyWith(
                      color: theme.colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TemplateScreen extends StatelessWidget {
  const _TemplateScreen({required this.template});

  final TemplateEntry template;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GalleryTopBar(
          title: template.name,
          leading: GalleryIconButton(
            icon: HeroIcons.close,
            label: 'Close',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: const <Widget>[ThemeButton()],
        ),
        Expanded(child: Builder(builder: template.builder)),
      ],
    );
  }
}
