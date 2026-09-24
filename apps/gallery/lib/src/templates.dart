import 'package:flutter/widgets.dart';

/// A full-screen template shown in the Templates section.
class TemplateEntry {
  const TemplateEntry({
    required this.name,
    required this.description,
    required this.builder,
  });

  final String name;
  final String description;
  final WidgetBuilder builder;
}

/// Templates rendered by the gallery. Filled in as the Pro templates land.
final List<TemplateEntry> templateRegistry = <TemplateEntry>[];
