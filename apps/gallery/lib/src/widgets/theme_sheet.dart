import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../gallery_state.dart';
import 'gallery_widgets.dart';

/// Top-bar button that opens the theme switcher.
class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryIconButton(
      icon: HeroIcons.palette,
      label: 'Theme',
      onPressed: () => showGallerySheet<void>(
        context,
        title: 'Theme',
        builder: (BuildContext context) => const ThemeSheet(),
      ),
    );
  }
}

/// Theme switcher: brightness, preset and premium themes, text direction.
class ThemeSheet extends StatelessWidget {
  const ThemeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final GalleryState state = GalleryScope.of(context);
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle label = theme.typography
        .style(HeroFontSize.xs, weight: HeroTypography.medium)
        .copyWith(color: theme.colors.muted);

    Widget group(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: label),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 6, children: children),
        ],
      ),
    );

    final List<GalleryTheme> presets = state.themes
        .where((GalleryTheme t) => !t.isPremium)
        .toList();
    final List<GalleryTheme> premium = state.themes
        .where((GalleryTheme t) => t.isPremium)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          group('Mode', <Widget>[
            for (final HeroThemeMode mode in HeroThemeMode.values)
              GalleryPill(
                label: mode.name,
                selected: state.mode == mode,
                onPressed: () => state.mode = mode,
              ),
          ]),
          group('Theme', <Widget>[
            for (final GalleryTheme t in presets)
              GalleryPill(
                label: t.label,
                selected: state.theme == t,
                onPressed: () => state.theme = t,
              ),
          ]),
          if (premium.isNotEmpty)
            group('Premium design systems', <Widget>[
              for (final GalleryTheme t in premium)
                GalleryPill(
                  label: t.label,
                  selected: state.theme == t,
                  onPressed: () => state.theme = t,
                ),
            ]),
          group('Direction', <Widget>[
            for (final TextDirection d in TextDirection.values)
              GalleryPill(
                label: d.name.toUpperCase(),
                selected: state.direction == d,
                onPressed: () => state.direction = d,
              ),
          ]),
        ],
      ),
    );
  }
}
