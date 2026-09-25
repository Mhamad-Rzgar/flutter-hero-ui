import 'package:flutter/widgets.dart';

/// The gallery page of one component: a variant playground and every example
/// from the component's HeroUI documentation page.
class ComponentDemo {
  const ComponentDemo({
    required this.slug,
    required this.examples,
    this.playground,
    this.pro,
  });

  /// Catalog slug this demo belongs to (e.g. `button`, or `pro-kpi` for a Pro
  /// component).
  final String slug;

  /// Index metadata for Pro components, which are not part of the open-source
  /// catalog. Null for open-source components.
  final ProComponentInfo? pro;

  /// Interactive playground with variant / color / size / state toggles.
  final Playground? playground;

  /// Examples in the order of the HeroUI docs page.
  final List<DemoExample> examples;
}

/// How a Pro component appears in the gallery index.
class ProComponentInfo {
  const ProComponentInfo({
    required this.name,
    required this.category,
    required this.description,
  });

  /// HeroUI Pro component name without the `HeroPro` prefix (e.g. `KPI`).
  final String name;

  /// Pro index group (e.g. `Charts`, `Data Display`).
  final String category;

  /// One-line description shown in the index.
  final String description;
}

/// One example from a docs page.
class DemoExample {
  const DemoExample({
    required this.title,
    required this.builder,
    required this.code,
    this.description,
  });

  final String title;
  final String? description;

  /// Builds the live example.
  final WidgetBuilder builder;

  /// The Dart snippet shown in the "View code" sheet.
  final String code;
}

/// A control in a [Playground].
sealed class PlaygroundControl {
  const PlaygroundControl(this.name);

  /// Prop name shown as the control label.
  final String name;

  Object get initialValue;
}

/// Pick one of several named options (variant, color, size, ...).
class OptionsControl extends PlaygroundControl {
  const OptionsControl(super.name, this.options, {String? initial})
    : _initial = initial;

  final List<String> options;
  final String? _initial;

  @override
  String get initialValue => _initial ?? options.first;
}

/// A boolean prop (isDisabled, isPending, ...).
class ToggleControl extends PlaygroundControl {
  const ToggleControl(super.name, {this.initial = false});

  final bool initial;

  @override
  bool get initialValue => initial;
}

/// A free-text prop (label, placeholder, ...).
class TextControl extends PlaygroundControl {
  const TextControl(super.name, {this.initial = ''});

  final String initial;

  @override
  String get initialValue => initial;
}

/// Current values of a playground's controls.
class PlaygroundValues {
  const PlaygroundValues(this._values);

  final Map<String, Object> _values;

  String option(String name) => _values[name]! as String;
  bool toggle(String name) => _values[name]! as bool;
  String text(String name) => _values[name]! as String;

  /// Looks up the enum value whose `name` matches the option [name].
  T pick<T extends Enum>(String name, List<T> values) =>
      values.byName(option(name));
}

/// An interactive variant playground.
class Playground {
  const Playground({
    required this.controls,
    required this.builder,
    required this.code,
  });

  final List<PlaygroundControl> controls;
  final Widget Function(BuildContext context, PlaygroundValues values) builder;
  final String Function(PlaygroundValues values) code;
}
