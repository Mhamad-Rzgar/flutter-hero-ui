import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';
import '../../foundation/tokens/hero_typography.dart';

/// The visual variants of a [HeroKbd].
enum HeroKbdVariant {
  /// A `--default` fill (HeroUI's `default`).
  standard,

  /// No fill.
  light,
}

/// The keys [HeroKbdAbbr] can show, with HeroUI's symbols (`kbdKeysMap`)
/// and accessible names (`kbdKeysLabelMap`).
enum HeroKbdKey {
  /// ⌘ Command.
  command('⌘', 'Command'),

  /// ⇧ Shift.
  shift('⇧', 'Shift'),

  /// ⌃ Control.
  ctrl('⌃', 'Control'),

  /// ⌥ Option.
  option('⌥', 'Option'),

  /// ↵ Enter.
  enter('↵', 'Enter'),

  /// ⌫ Delete.
  delete('⌫', 'Delete'),

  /// ⎋ Escape.
  escape('⎋', 'Escape'),

  /// ⇥ Tab.
  tab('⇥', 'Tab'),

  /// ⇪ Caps Lock.
  capslock('⇪', 'Caps Lock'),

  /// ↑ Up.
  up('↑', 'Up'),

  /// → Right.
  right('→', 'Right'),

  /// ↓ Down.
  down('↓', 'Down'),

  /// ← Left.
  left('←', 'Left'),

  /// ⇞ Page Up.
  pageup('⇞', 'Page Up'),

  /// ⇟ Page Down.
  pagedown('⇟', 'Page Down'),

  /// ↖ Home.
  home('↖', 'Home'),

  /// ↘ End.
  end('↘', 'End'),

  /// ? Help.
  help('?', 'Help'),

  /// ␣ Space.
  space('␣', 'Space'),

  /// Fn.
  fn('Fn', 'Fn'),

  /// ⌘ Windows.
  win('⌘', 'Win'),

  /// ⌥ Alt.
  alt('⌥', 'Alt');

  const HeroKbdKey(this.symbol, this.label);

  /// The symbol shown for the key.
  final String symbol;

  /// The name of the key, used as its accessibility label.
  final String label;
}

/// Displays a keyboard shortcut or key combination (HeroUI `Kbd`).
///
/// Use the [keys] and [text] shorthand for the common modifier + key form,
/// or compose [HeroKbdAbbr] and [HeroKbdContent] parts in [children]:
///
/// ```dart
/// const HeroKbd(keys: <HeroKbdKey>[HeroKbdKey.command], text: 'K')
///
/// const HeroKbd(
///   children: <Widget>[
///     HeroKbdAbbr(HeroKbdKey.command),
///     HeroKbdContent(Text('K')),
///   ],
/// )
/// ```
///
/// Inside running text, wrap it in a [WidgetSpan] aligned to the baseline
/// (see [HeroKbd.span]). Assistive technologies read the whole key as one
/// label, for example "Command K".
class HeroKbd extends StatelessWidget {
  /// Creates a keyboard key.
  const HeroKbd({
    super.key,
    this.keys = const <HeroKbdKey>[],
    this.text,
    this.children = const <Widget>[],
    this.variant = HeroKbdVariant.standard,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
  });

  /// Modifier or special keys shown first, as [HeroKbdAbbr]s.
  final List<HeroKbdKey> keys;

  /// Text shown after [keys], as a [HeroKbdContent].
  final String? text;

  /// Parts shown after [keys] and [text].
  final List<Widget> children;

  /// Visual variant.
  final HeroKbdVariant variant;

  /// Overrides the fill (`bg-*` utilities).
  final Color? backgroundColor;

  /// Overrides the text color (`text-*` utilities).
  final Color? foregroundColor;

  /// Overrides the horizontal padding (`px-2`, 8).
  final EdgeInsetsGeometry? padding;

  /// Returns [kbd] as an inline span aligned to the text baseline.
  static InlineSpan span(HeroKbd kbd) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: kbd,
  );

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Color foreground = foregroundColor ?? theme.colors.muted;
    final Color background =
        backgroundColor ??
        switch (variant) {
          HeroKbdVariant.standard => theme.colors.defaultColor,
          HeroKbdVariant.light => const Color(0x00000000),
        };
    final List<Widget> parts = <Widget>[
      for (final HeroKbdKey key in keys) HeroKbdAbbr(key),
      if (text != null) HeroKbdContent(Text(text!)),
      ...children,
    ];
    return MergeSemantics(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: background,
          shape: theme.shapeAll(theme.radii.lg),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: theme.spacing(6)),
          child: Padding(
            padding:
                padding ?? EdgeInsets.symmetric(horizontal: theme.spacing(2)),
            child: DefaultTextStyle(
              style: theme.typography
                  .style(HeroFontSize.sm, weight: HeroTypography.medium)
                  .copyWith(color: foreground, wordSpacing: -theme.spacing(1)),
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              child: IconTheme.merge(
                data: IconThemeData(color: foreground),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: theme.spacing(0.5),
                  children: parts,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<HeroKbdKey>('keys', keys))
      ..add(StringProperty('text', text, defaultValue: null))
      ..add(
        EnumProperty<HeroKbdVariant>(
          'variant',
          variant,
          defaultValue: HeroKbdVariant.standard,
        ),
      );
  }
}

/// A modifier or special key symbol inside a [HeroKbd] (HeroUI
/// `Kbd.Abbr`). Its accessibility label is the key name.
class HeroKbdAbbr extends StatelessWidget {
  /// Shows the symbol of [keyValue].
  const HeroKbdAbbr(this.keyValue, {super.key});

  /// The key to show.
  final HeroKbdKey keyValue;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: keyValue.label,
      excludeSemantics: true,
      child: Text(keyValue.symbol),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HeroKbdKey>('keyValue', keyValue));
  }
}

/// The key text inside a [HeroKbd] (HeroUI `Kbd.Content`).
class HeroKbdContent extends StatelessWidget {
  /// Shows [child], usually a [Text].
  const HeroKbdContent(this.child, {super.key});

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
