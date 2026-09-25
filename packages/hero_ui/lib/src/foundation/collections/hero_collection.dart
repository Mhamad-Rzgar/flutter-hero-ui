import 'package:flutter/widgets.dart';

/// Builds the item widget for one element of a [HeroCollection].
typedef HeroCollectionItemBuilder<T> =
    Widget Function(BuildContext context, T item);

/// A run of items built from data inside the static children of a
/// collection component (React Aria's `Collection`).
///
/// List boxes, sections, menus and tag groups expand it in place, so
/// dynamic items can be mixed with static items, sections and load-more
/// sentinels:
///
/// ```dart
/// HeroListBox(
///   semanticLabel: 'Pokemon',
///   children: <Widget>[
///     HeroCollection<Pokemon>(
///       items: pokemon,
///       itemBuilder: (BuildContext context, Pokemon item) =>
///           HeroListBoxItem(id: item.name, label: item.name),
///     ),
///     HeroListBoxLoadMoreItem(isLoading: loading, onLoadMore: loadMore),
///   ],
/// )
/// ```
///
/// Outside a collection it lays its items out in a column.
class HeroCollection<T> extends StatelessWidget {
  /// Creates a collection of [items] built by [itemBuilder].
  const HeroCollection({
    super.key,
    required this.items,
    required this.itemBuilder,
  });

  /// The data.
  final Iterable<T> items;

  /// Builds the widget of one element.
  final HeroCollectionItemBuilder<T> itemBuilder;

  /// Builds the widget of every element, in order.
  List<Widget> buildItems(BuildContext context) => <Widget>[
    for (final T item in items) itemBuilder(context, item),
  ];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: buildItems(context),
  );
}
