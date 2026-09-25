import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import '../catalog.dart';
import '../demos/registry.dart';
import '../gallery_index.dart';
import '../templates.dart';
import '../widgets/gallery_widgets.dart';
import '../widgets/theme_sheet.dart';
import 'component_page.dart';
import 'templates_page.dart';

/// Width from which the gallery shows index and detail side by side.
const double kSplitViewBreakpoint = HeroBreakpoints.lg;

/// The gallery home: a searchable, categorised component index. On wide
/// screens it becomes a sidebar next to the selected component.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';
  CatalogEntry? _selected;
  bool _templatesSelected = false;

  void _open(CatalogEntry entry, bool split) {
    if (split) {
      setState(() {
        _selected = entry;
        _templatesSelected = false;
      });
    } else {
      Navigator.of(context).push(
        HeroPageRoute<void>(
          builder: (BuildContext context) => ComponentPage(entry: entry),
        ),
      );
    }
  }

  void _openTemplates(bool split) {
    if (split) {
      setState(() {
        _templatesSelected = true;
        _selected = null;
      });
    } else {
      Navigator.of(context).push(
        HeroPageRoute<void>(
          builder: (BuildContext context) => const TemplatesPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final bool split = MediaQuery.sizeOf(context).width >= kSplitViewBreakpoint;
    final Widget index = _ComponentIndex(
      query: _query,
      selected: split ? _selected : null,
      templatesSelected: split && _templatesSelected,
      onQueryChanged: (String q) => setState(() => _query = q),
      onOpen: (CatalogEntry e) => _open(e, split),
      onOpenTemplates: () => _openTemplates(split),
    );
    if (!split) return index;

    final Widget detail;
    if (_templatesSelected) {
      detail = const TemplatesPage(showBack: false);
    } else if (_selected != null) {
      detail = ComponentPage(
        key: ValueKey<String>(_selected!.slug),
        entry: _selected!,
        showBack: false,
      );
    } else {
      detail = const _Welcome();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(width: 320, child: index),
        ColoredBox(
          color: theme.colors.separator,
          child: const SizedBox(width: 1),
        ),
        Expanded(child: detail),
      ],
    );
  }
}

class _ComponentIndex extends StatelessWidget {
  const _ComponentIndex({
    required this.query,
    required this.selected,
    required this.templatesSelected,
    required this.onQueryChanged,
    required this.onOpen,
    required this.onOpenTemplates,
  });

  final String query;
  final CatalogEntry? selected;
  final bool templatesSelected;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<CatalogEntry> onOpen;
  final VoidCallback onOpenTemplates;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final String q = query.trim().toLowerCase();
    final List<CatalogEntry> matches = galleryIndex
        .where(
          (CatalogEntry e) =>
              q.isEmpty ||
              e.name.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q) ||
              e.category.label.toLowerCase().contains(q) ||
              (e.group?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final int proCount = proCatalog.length;
    final int available = catalog
        .where((CatalogEntry e) => demoRegistry.containsKey(e.slug))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const GalleryTopBar(
          title: 'HeroUI for Flutter',
          actions: <Widget>[ThemeButton()],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: GallerySearchBox(onChanged: onQueryChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            '$available of ${catalog.length} components available'
            '${proCount > 0 ? ' · $proCount Pro' : ''}',
            style: theme.typography.xs.copyWith(color: theme.colors.muted),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: <Widget>[
              if (q.isEmpty)
                _IndexTile(
                  title: 'Templates',
                  subtitle: 'Dashboard, Mail, Chat, Finances and CRM screens',
                  icon: HeroIcons.layoutCellsLarge,
                  selected: templatesSelected,
                  enabled: true,
                  onPressed: onOpenTemplates,
                ),
              for (final (String heading, List<CatalogEntry> entries)
                  in _groups(matches)) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                  child: Text(
                    heading.toUpperCase(),
                    style: theme.typography
                        .style(HeroFontSize.xs, weight: HeroTypography.semibold)
                        .copyWith(
                          color: theme.colors.muted,
                          letterSpacing: 0.6,
                        ),
                  ),
                ),
                for (final CatalogEntry entry in entries)
                  _IndexTile(
                    title: entry.name,
                    subtitle: entry.description,
                    selected: selected == entry,
                    enabled: demoRegistry.containsKey(entry.slug),
                    onPressed: () => onOpen(entry),
                  ),
              ],
              if (matches.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No results found',
                    textAlign: TextAlign.center,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.muted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Groups index entries by category, and Pro entries by their Pro group.
List<(String, List<CatalogEntry>)> _groups(List<CatalogEntry> entries) {
  final List<(String, List<CatalogEntry>)> groups =
      <(String, List<CatalogEntry>)>[];
  for (final ComponentCategory category in ComponentCategory.values) {
    final List<CatalogEntry> inCategory = entries
        .where((CatalogEntry e) => e.category == category)
        .toList();
    if (inCategory.isEmpty) continue;
    if (category != ComponentCategory.pro) {
      groups.add((category.label, inCategory));
      continue;
    }
    for (final String group
        in inCategory.map((CatalogEntry e) => e.group!).toSet()) {
      groups.add((
        'Pro · $group',
        inCategory.where((CatalogEntry e) => e.group == group).toList(),
      ));
    }
  }
  return groups;
}

class _IndexTile extends StatelessWidget {
  const _IndexTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    this.icon,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;
  final HeroIconData? icon;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: HeroInteractable(
        onPressed: onPressed,
        isSelected: selected,
        builder: (BuildContext context, HeroInteractionState state, _) {
          final OutlinedBorder shape = theme.shapeAll(theme.radii.xl);
          final Color bg = selected
              ? theme.colors.defaultColor
              : state.isHovered || state.isPressed
              ? theme.colors.defaultSoftHover
              : const Color(0x00000000);
          return HeroFocusRing(
            visible: state.isFocusVisible,
            shape: shape,
            offset: 0,
            child: AnimatedContainer(
              duration: HeroMotion.fast,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: ShapeDecoration(color: bg, shape: shape),
              child: Row(
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    HeroIcon(icon!, size: 18, color: theme.colors.foreground),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: theme.typography
                              .style(
                                HeroFontSize.sm,
                                weight: HeroTypography.medium,
                              )
                              .copyWith(
                                color: enabled
                                    ? theme.colors.foreground
                                    : theme.colors.muted,
                              ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.xs.copyWith(
                            color: theme.colors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!enabled)
                    Text(
                      'Soon',
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.muted,
                      ),
                    )
                  else
                    HeroIcon(HeroIcons.chevronRight, color: theme.colors.muted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'HeroUI for Flutter',
              style: theme.typography.h2.copyWith(
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a component from the index to explore its variants.',
              textAlign: TextAlign.center,
              style: theme.typography.body.copyWith(color: theme.colors.muted),
            ),
            if (templateRegistry.isNotEmpty) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
