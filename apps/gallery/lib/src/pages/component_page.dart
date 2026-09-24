import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../catalog.dart';
import '../demo.dart';
import '../demos/registry.dart';
import '../widgets/gallery_widgets.dart';
import '../widgets/theme_sheet.dart';

/// The page of one component: playground plus every docs example.
class ComponentPage extends StatelessWidget {
  const ComponentPage({super.key, required this.entry, this.showBack = true});

  final CatalogEntry entry;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final ComponentDemo? demo = demoRegistry[entry.slug];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GalleryTopBar(
          title: entry.name,
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            children: <Widget>[
              Text(
                entry.name,
                style: theme.typography.h2.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.description,
                style: theme.typography.body.copyWith(
                  color: theme.colors.muted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.category.label} · Hero${entry.name}',
                style: theme.typography.sm.copyWith(color: theme.colors.muted),
              ),
              const SizedBox(height: 32),
              if (demo == null)
                const _ComingSoon()
              else ...<Widget>[
                if (demo.playground != null)
                  GallerySection(
                    title: 'Playground',
                    child: PlaygroundView(playground: demo.playground!),
                  ),
                for (final DemoExample example in demo.examples)
                  GallerySection(
                    title: example.title,
                    description: example.description,
                    child: DemoCard(
                      code: example.code,
                      child: Builder(builder: example.builder),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: ShapeDecoration(
        color: theme.colors.surface,
        shape: theme.shapeAll(
          theme.radii.xl3,
          side: BorderSide(color: theme.colors.border),
        ),
      ),
      child: Column(
        children: <Widget>[
          HeroIcon(HeroIcons.clock, size: 24, color: theme.colors.muted),
          const SizedBox(height: 12),
          Text(
            'This component has not landed yet.',
            textAlign: TextAlign.center,
            style: theme.typography.sm.copyWith(color: theme.colors.muted),
          ),
        ],
      ),
    );
  }
}

/// Renders a [Playground] with its controls, preview and code.
class PlaygroundView extends StatefulWidget {
  const PlaygroundView({super.key, required this.playground});

  final Playground playground;

  @override
  State<PlaygroundView> createState() => _PlaygroundViewState();
}

class _PlaygroundViewState extends State<PlaygroundView> {
  late final Map<String, Object> _values = <String, Object>{
    for (final PlaygroundControl c in widget.playground.controls)
      c.name: c.initialValue,
  };

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final PlaygroundValues values = PlaygroundValues(
      Map<String, Object>.of(_values),
    );
    final TextStyle label = theme.typography
        .style(HeroFontSize.xs, weight: HeroTypography.medium)
        .copyWith(color: theme.colors.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DemoCard(
          code: widget.playground.code(values),
          child: widget.playground.builder(context, values),
        ),
        const SizedBox(height: 16),
        for (final PlaygroundControl control in widget.playground.controls)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(control.name, style: label),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: switch (control) {
                    OptionsControl(:final List<String> options) => <Widget>[
                      for (final String option in options)
                        GalleryPill(
                          label: option,
                          selected: _values[control.name] == option,
                          onPressed: () =>
                              setState(() => _values[control.name] = option),
                        ),
                    ],
                    ToggleControl() => <Widget>[
                      for (final bool option in <bool>[false, true])
                        GalleryPill(
                          label: '$option',
                          selected: _values[control.name] == option,
                          onPressed: () =>
                              setState(() => _values[control.name] = option),
                        ),
                    ],
                    TextControl() => <Widget>[
                      Text('${_values[control.name]}', style: label),
                    ],
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
