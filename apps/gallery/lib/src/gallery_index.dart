import 'catalog.dart';
import 'demo.dart';
import 'demos/registry.dart';

/// Pro components, derived from the registered Pro demos.
List<CatalogEntry> get proCatalog {
  final List<CatalogEntry> entries = <CatalogEntry>[
    for (final ComponentDemo demo in demoRegistry.values)
      if (demo.pro != null)
        CatalogEntry(
          slug: demo.slug,
          name: demo.pro!.name,
          category: ComponentCategory.pro,
          description: demo.pro!.description,
          group: demo.pro!.category,
        ),
  ];
  entries.sort((CatalogEntry a, CatalogEntry b) {
    final int byGroup = a.group!.compareTo(b.group!);
    return byGroup != 0 ? byGroup : a.name.compareTo(b.name);
  });
  return entries;
}

/// Every entry of the gallery index: the open-source catalog followed by the
/// Pro components.
List<CatalogEntry> get galleryIndex => <CatalogEntry>[
  ...catalog,
  ...proCatalog,
];
