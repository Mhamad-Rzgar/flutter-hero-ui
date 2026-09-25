/// HeroUI's ColorSwatchPicker: a list of color swatches to pick a color
/// from a predefined palette.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../color_swatch/color_swatch.dart';

export '../color/color.dart';
export '../color_swatch/color_swatch.dart'
    show HeroColorSwatchShape, HeroColorSwatchSize;

/// How the items of a [HeroColorSwatchPicker] are laid out (HeroUI's
/// `layout` prop).
enum HeroColorSwatchPickerLayout {
  /// A wrapping row, the default.
  grid,

  /// A single column.
  stack,
}

/// The render props of a [HeroColorSwatchPickerItem].
@immutable
class HeroColorSwatchPickerItemState {
  /// Creates an item state.
  const HeroColorSwatchPickerItemState({
    required this.color,
    this.isSelected = false,
    this.isDisabled = false,
    this.isHovered = false,
    this.isPressed = false,
    this.isFocused = false,
    this.isFocusVisible = false,
  });

  /// The color of the item.
  final Color color;

  /// Whether the item is the selected color.
  final bool isSelected;

  /// Whether the item is disabled.
  final bool isDisabled;

  /// Whether a pointer hovers the item.
  final bool isHovered;

  /// Whether the item is pressed.
  final bool isPressed;

  /// Whether the item has focus.
  final bool isFocused;

  /// Whether the item has keyboard focus (focus ring shown).
  final bool isFocusVisible;

  /// Whether the check mark should be black: the color is light
  /// (`(0.2126 R + 0.7152 G + 0.0722 B) / 255 > 0.5`).
  bool get isLightColor =>
      0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b > 0.5;

  @override
  bool operator ==(Object other) =>
      other is HeroColorSwatchPickerItemState &&
      other.color == color &&
      other.isSelected == isSelected &&
      other.isDisabled == isDisabled &&
      other.isHovered == isHovered &&
      other.isPressed == isPressed &&
      other.isFocused == isFocused &&
      other.isFocusVisible == isFocusVisible;

  @override
  int get hashCode => Object.hash(
    color,
    isSelected,
    isDisabled,
    isHovered,
    isPressed,
    isFocused,
    isFocusVisible,
  );
}

/// Builds the content of a [HeroColorSwatchPickerItem] or
/// [HeroColorSwatchPickerIndicator] from the item state.
typedef HeroColorSwatchPickerItemBuilder =
    Widget Function(BuildContext context, HeroColorSwatchPickerItemState state);

/// A list of color swatches that lets the user pick one color (HeroUI
/// `ColorSwatchPicker`).
///
/// ```dart
/// HeroColorSwatchPicker(
///   semanticLabel: 'Accent color',
///   colors: const <Color>[Color(0xFFF43F5E), Color(0xFF8B5CF6)],
///   onChanged: (Color color) => debugPrint('$color'),
/// )
/// ```
///
/// Pass [colors] for the default items (swatch + check mark), or
/// [children] of [HeroColorSwatchPickerItem]s to compose items yourself.
///
/// * [size]: xs (16), sm (24), md (32, default), lg (36) or xl (40).
/// * [variant]: circle (default) or square.
/// * [layout]: a wrapping row (grid, default) or a column (stack).
///
/// The selected item gets a border in its own color and the field shadow,
/// its swatch shrinks to reveal a gap and the check mark scales in. Swatches
/// grow on hover. The selection cannot be emptied.
///
/// The picker is controlled with [value] + [onChanged] or uncontrolled with
/// [defaultValue]; without a value inside a `HeroColorPicker` it selects the
/// picker's color. Items match the value by 8-bit RGBA equality.
///
/// Keyboard: Tab reaches the selected (or first) item, arrow keys move
/// between items (left/right in reading order, up/down to the item above or
/// below in a grid), Home/End jump to the first/last item, Enter or Space
/// selects. Disabled items are skipped.
class HeroColorSwatchPicker extends StatefulWidget {
  /// Creates a swatch picker.
  const HeroColorSwatchPicker({
    super.key,
    this.colors,
    this.children,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.size = HeroColorSwatchSize.md,
    this.variant = HeroColorSwatchShape.circle,
    this.layout = HeroColorSwatchPickerLayout.grid,
    this.alignment = WrapAlignment.start,
    this.semanticLabel,
  }) : assert(
         colors != null || children != null,
         'Provide colors or children.',
       );

  /// The palette, one default item (swatch and check mark) per color.
  final List<Color>? colors;

  /// Custom items; used instead of [colors].
  final List<HeroColorSwatchPickerItem>? children;

  /// The selected color (controlled).
  final Color? value;

  /// The initially selected color (uncontrolled).
  final Color? defaultValue;

  /// Called with the color of the item the user selects.
  final ValueChanged<Color>? onChanged;

  /// The size of the items.
  final HeroColorSwatchSize size;

  /// The shape of the items.
  final HeroColorSwatchShape variant;

  /// The layout of the items.
  final HeroColorSwatchPickerLayout layout;

  /// Main-axis alignment of the items in the grid layout
  /// (`justify-center` is [WrapAlignment.center]).
  final WrapAlignment alignment;

  /// Accessibility label of the list (`aria-label`).
  final String? semanticLabel;

  @override
  State<HeroColorSwatchPicker> createState() => _HeroColorSwatchPickerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('value', value, defaultValue: null))
      ..add(
        EnumProperty<HeroColorSwatchSize>(
          'size',
          size,
          defaultValue: HeroColorSwatchSize.md,
        ),
      )
      ..add(
        EnumProperty<HeroColorSwatchShape>(
          'variant',
          variant,
          defaultValue: HeroColorSwatchShape.circle,
        ),
      )
      ..add(
        EnumProperty<HeroColorSwatchPickerLayout>(
          'layout',
          layout,
          defaultValue: HeroColorSwatchPickerLayout.grid,
        ),
      );
  }
}

class _HeroColorSwatchPickerState extends State<HeroColorSwatchPicker> {
  late Color? _value = widget.defaultValue;
  final List<FocusNode> _nodes = <FocusNode>[];
  int? _lastFocused;

  List<HeroColorSwatchPickerItem> get _items =>
      widget.children ??
      <HeroColorSwatchPickerItem>[
        for (final Color color in widget.colors!)
          HeroColorSwatchPickerItem(color: color),
      ];

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncNodes(int count) {
    while (_nodes.length < count) {
      _nodes.add(
        FocusNode(debugLabel: 'HeroColorSwatchPickerItem ${_nodes.length}'),
      );
    }
    while (_nodes.length > count) {
      _nodes.removeLast().dispose();
    }
  }

  Color? _selected(HeroColorPickerScope? scope) =>
      widget.value ?? scope?.value.toColor() ?? _value;

  void _select(Color color) {
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    final Color? selected = _selected(scope);
    if (selected != null && heroColorsEqual(selected, color)) return;
    if (widget.value == null) {
      if (scope != null) {
        scope.onChanged(
          heroResolveColorValue(
            color,
            scope.value.space,
            previous: scope.value,
          ),
        );
      } else {
        setState(() => _value = color);
      }
    }
    widget.onChanged?.call(color);
  }

  void _handleFocus(int index) {
    if (_lastFocused == index) return;
    setState(() => _lastFocused = index);
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final List<HeroColorSwatchPickerItem> items = _items;
    final int current = _nodes.indexWhere((FocusNode n) => n.hasPrimaryFocus);
    if (current < 0) return KeyEventResult.ignored;
    bool enabled(int i) => !items[i].isDisabled;
    final LogicalKeyboardKey key = event.logicalKey;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final bool grid = widget.layout == HeroColorSwatchPickerLayout.grid;

    int? target;
    if (key == LogicalKeyboardKey.home) {
      target = _firstWhere(items.length, enabled);
    } else if (key == LogicalKeyboardKey.end) {
      target = _lastWhere(items.length, enabled);
    } else {
      final int? delta = switch (key) {
        LogicalKeyboardKey.arrowRight when grid => rtl ? -1 : 1,
        LogicalKeyboardKey.arrowLeft when grid => rtl ? 1 : -1,
        LogicalKeyboardKey.arrowDown when !grid => 1,
        LogicalKeyboardKey.arrowUp when !grid => -1,
        _ => null,
      };
      if (delta != null) {
        for (
          int i = current + delta;
          i >= 0 && i < items.length && target == null;
          i += delta
        ) {
          if (enabled(i)) target = i;
        }
      } else if (grid &&
          (key == LogicalKeyboardKey.arrowDown ||
              key == LogicalKeyboardKey.arrowUp)) {
        target = _verticalNeighbour(
          current,
          down: key == LogicalKeyboardKey.arrowDown,
          enabled: enabled,
        );
      } else {
        return KeyEventResult.ignored;
      }
    }
    if (target != null && target != current) _nodes[target].requestFocus();
    return KeyEventResult.handled;
  }

  static int? _firstWhere(int count, bool Function(int) test) {
    for (int i = 0; i < count; i++) {
      if (test(i)) return i;
    }
    return null;
  }

  static int? _lastWhere(int count, bool Function(int) test) {
    for (int i = count - 1; i >= 0; i--) {
      if (test(i)) return i;
    }
    return null;
  }

  // The closest enabled item in the nearest wrapped row above or below.
  int? _verticalNeighbour(
    int current, {
    required bool down,
    required bool Function(int) enabled,
  }) {
    final Rect from = _nodes[current].rect;
    int? best;
    double bestRow = double.infinity;
    double bestColumn = double.infinity;
    for (int i = 0; i < _nodes.length; i++) {
      if (i == current || !enabled(i)) continue;
      final Rect rect = _nodes[i].rect;
      final double rowDistance = down
          ? rect.top - from.bottom
          : from.top - rect.bottom;
      if (rowDistance < -0.5) continue;
      final double columnDistance = (rect.center.dx - from.center.dx).abs();
      if (rowDistance < bestRow - 0.5 ||
          (rowDistance - bestRow).abs() <= 0.5 && columnDistance < bestColumn) {
        best = i;
        bestRow = rowDistance;
        bestColumn = columnDistance;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColorPickerScope? scope = HeroColorPickerScope.maybeOf(context);
    final List<HeroColorSwatchPickerItem> items = _items;
    _syncNodes(items.length);
    final Color? selected = _selected(scope);

    int? selectedIndex;
    for (int i = 0; i < items.length && selectedIndex == null; i++) {
      if (selected != null &&
          !items[i].isDisabled &&
          heroColorsEqual(items[i].color, selected)) {
        selectedIndex = i;
      }
    }
    final int? lastFocused =
        _lastFocused != null &&
            _lastFocused! < items.length &&
            !items[_lastFocused!].isDisabled
        ? _lastFocused
        : null;
    final int? tabStop =
        selectedIndex ??
        lastFocused ??
        _firstWhere(items.length, (int i) => !items[i].isDisabled);

    final List<Widget> children = <Widget>[
      for (int i = 0; i < items.length; i++)
        _HeroColorSwatchPickerItemSlot(
          index: i,
          focusNode: _nodes[i],
          isTabStop: i == tabStop,
          isSelected:
              selected != null && heroColorsEqual(items[i].color, selected),
          child: items[i],
        ),
    ];
    final double gap = theme.spacing(2);
    final Widget list = widget.layout == HeroColorSwatchPickerLayout.grid
        ? Wrap(
            spacing: gap,
            runSpacing: gap,
            alignment: widget.alignment,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            spacing: gap,
            children: children,
          );

    return _HeroColorSwatchPickerScope(
      size: widget.size,
      variant: widget.variant,
      onSelect: _select,
      onFocus: _handleFocus,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: widget.semanticLabel,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          includeSemantics: false,
          onKeyEvent: _handleKey,
          child: list,
        ),
      ),
    );
  }
}

class _HeroColorSwatchPickerScope extends InheritedWidget {
  const _HeroColorSwatchPickerScope({
    required this.size,
    required this.variant,
    required this.onSelect,
    required this.onFocus,
    required super.child,
  });

  final HeroColorSwatchSize size;
  final HeroColorSwatchShape variant;
  final ValueChanged<Color> onSelect;
  final ValueChanged<int> onFocus;

  static _HeroColorSwatchPickerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroColorSwatchPickerScope>();

  @override
  bool updateShouldNotify(_HeroColorSwatchPickerScope oldWidget) =>
      size != oldWidget.size ||
      variant != oldWidget.variant ||
      onSelect != oldWidget.onSelect ||
      onFocus != oldWidget.onFocus;
}

class _HeroColorSwatchPickerItemSlot extends InheritedWidget {
  const _HeroColorSwatchPickerItemSlot({
    required this.index,
    required this.focusNode,
    required this.isTabStop,
    required this.isSelected,
    required super.child,
  });

  final int index;
  final FocusNode focusNode;
  final bool isTabStop;
  final bool isSelected;

  static _HeroColorSwatchPickerItemSlot? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_HeroColorSwatchPickerItemSlot>();

  @override
  bool updateShouldNotify(_HeroColorSwatchPickerItemSlot oldWidget) =>
      index != oldWidget.index ||
      focusNode != oldWidget.focusNode ||
      isTabStop != oldWidget.isTabStop ||
      isSelected != oldWidget.isSelected;
}

// Shares the item state and geometry with the swatch and indicator parts.
class _HeroColorSwatchPickerItemScope extends InheritedWidget {
  const _HeroColorSwatchPickerItemScope({
    required this.state,
    required this.size,
    required this.variant,
    required super.child,
  });

  final HeroColorSwatchPickerItemState state;
  final HeroColorSwatchSize size;
  final HeroColorSwatchShape variant;

  static _HeroColorSwatchPickerItemScope? maybeOf(
    BuildContext context,
  ) => context
      .dependOnInheritedWidgetOfExactType<_HeroColorSwatchPickerItemScope>();

  @override
  bool updateShouldNotify(_HeroColorSwatchPickerItemScope oldWidget) =>
      state != oldWidget.state ||
      size != oldWidget.size ||
      variant != oldWidget.variant;
}

/// The geometry of swatch picker items (HeroUI's size and shape classes).
abstract final class HeroColorSwatchPickerMetrics {
  /// The item border width: 1 (xs), 2 (sm, md) or 3 (lg, xl).
  static double borderWidth(HeroThemeData theme, HeroColorSwatchSize size) =>
      theme.spacing(switch (size) {
        HeroColorSwatchSize.xs => 0.25,
        HeroColorSwatchSize.sm || HeroColorSwatchSize.md => 0.5,
        HeroColorSwatchSize.lg || HeroColorSwatchSize.xl => 0.75,
      });

  /// The item corner radius.
  static double itemRadius(
    HeroThemeData theme,
    HeroColorSwatchSize size,
    HeroColorSwatchShape shape,
  ) {
    if (shape == HeroColorSwatchShape.circle) {
      return size.circleRadius(theme.radii);
    }
    return switch (size) {
      HeroColorSwatchSize.xs => theme.radii.md,
      HeroColorSwatchSize.sm => theme.radii.lg,
      _ => theme.radii.xl,
    };
  }

  /// The swatch corner radius: the item radius for circles; for squares
  /// `rounded-md` (xs, and sm while selected) or `rounded-lg`.
  static double swatchRadius(
    HeroThemeData theme,
    HeroColorSwatchSize size,
    HeroColorSwatchShape shape, {
    required bool isSelected,
  }) {
    if (shape == HeroColorSwatchShape.circle) {
      return itemRadius(theme, size, shape);
    }
    return switch (size) {
      HeroColorSwatchSize.xs => theme.radii.md,
      HeroColorSwatchSize.sm => isSelected ? theme.radii.md : theme.radii.lg,
      _ => theme.radii.lg,
    };
  }
}

/// An item of a [HeroColorSwatchPicker] (`ColorSwatchPicker.Item`).
///
/// By default it shows a [HeroColorSwatchPickerSwatch] and a
/// [HeroColorSwatchPickerIndicator]; pass [children] to change the parts
/// (for example only the swatch) or [builder] to draw the content from the
/// item state.
class HeroColorSwatchPickerItem extends StatelessWidget {
  /// Creates a picker item for [color].
  const HeroColorSwatchPickerItem({
    super.key,
    required this.color,
    this.isDisabled = false,
    this.children,
    this.builder,
    this.semanticLabel,
  });

  /// The color the item selects.
  final Color color;

  /// Whether the item cannot be selected or focused.
  final bool isDisabled;

  /// The stacked parts inside the item border; defaults to a swatch and an
  /// indicator.
  final List<Widget>? children;

  /// Builds the content from the item state; replaces [children].
  final HeroColorSwatchPickerItemBuilder? builder;

  /// Accessibility label; defaults to the color name.
  final String? semanticLabel;

  static const List<Widget> _defaultParts = <Widget>[
    HeroColorSwatchPickerSwatch(),
    HeroColorSwatchPickerIndicator(),
  ];

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroColorSwatchPickerScope? picker =
        _HeroColorSwatchPickerScope.maybeOf(context);
    final _HeroColorSwatchPickerItemSlot? slot =
        _HeroColorSwatchPickerItemSlot.maybeOf(context);
    final HeroColorSwatchSize size = picker?.size ?? HeroColorSwatchSize.md;
    final HeroColorSwatchShape variant =
        picker?.variant ?? HeroColorSwatchShape.circle;
    final bool selected = slot?.isSelected ?? false;
    final FocusNode? node = slot?.focusNode;
    if (node != null) node.skipTraversal = !(slot?.isTabStop ?? true);

    final double extent = size.extent(theme);
    final double border = HeroColorSwatchPickerMetrics.borderWidth(theme, size);
    final OutlinedBorder shape = theme.shapeAll(
      HeroColorSwatchPickerMetrics.itemRadius(theme, size, variant),
    );
    final Duration duration = theme.motion.resolve(context, HeroMotion.fast);

    return HeroInteractable(
      onPressed: () => picker?.onSelect(color),
      isDisabled: isDisabled,
      isSelected: selected,
      focusNode: node,
      semanticsLabel: semanticLabel ?? heroColorName(color),
      onFocusChanged: (bool focused) {
        if (focused && slot != null) picker?.onFocus(slot.index);
      },
      builder: (BuildContext context, HeroInteractionState interaction, _) {
        final HeroColorSwatchPickerItemState state =
            HeroColorSwatchPickerItemState(
              color: color,
              isSelected: selected,
              isDisabled: isDisabled,
              isHovered: interaction.isHovered,
              isPressed: interaction.isPressed,
              isFocused: interaction.isFocused,
              isFocusVisible: interaction.isFocusVisible,
            );
        final Widget content = builder != null
            ? builder!(context, state)
            : Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: children ?? _defaultParts,
              );
        return HeroFocusRing(
          visible: interaction.isFocusVisible,
          shape: shape,
          child: HeroDisabledOpacity(
            disabled: isDisabled,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: selected ? 1 : 0),
              duration: duration,
              curve: HeroMotion.easeOut,
              builder: (BuildContext context, double t, Widget? child) {
                final List<BoxShadow> shadows = theme.shadows.field.boxShadows;
                return DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: shape.copyWith(
                      side: BorderSide(
                        color: color.withValues(alpha: color.a * t),
                        width: border,
                      ),
                    ),
                    shadows: t == 0
                        ? null
                        : <BoxShadow>[
                            for (final BoxShadow shadow in shadows)
                              shadow.copyWith(
                                color: shadow.color.withValues(
                                  alpha: shadow.color.a * t,
                                ),
                              ),
                          ],
                  ),
                  child: child,
                );
              },
              child: SizedBox.square(
                dimension: extent,
                child: Padding(
                  padding: EdgeInsets.all(border),
                  child: _HeroColorSwatchPickerItemScope(
                    state: state,
                    size: size,
                    variant: variant,
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The color of a [HeroColorSwatchPickerItem]
/// (`ColorSwatchPicker.Swatch`).
///
/// It fills the item inside its border, paints the color over the
/// transparency checkerboard, grows to 110% on hover and shrinks to 77%
/// while selected (100 ms ease-out).
class HeroColorSwatchPickerSwatch extends StatelessWidget {
  /// Creates the swatch part.
  const HeroColorSwatchPickerSwatch({super.key});

  @override
  Widget build(BuildContext context) {
    final _HeroColorSwatchPickerItemScope? item =
        _HeroColorSwatchPickerItemScope.maybeOf(context);
    if (item == null) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColorSwatchPickerItemState state = item.state;
    final double scale = state.isSelected
        ? 0.77
        : state.isHovered
        ? 1.1
        : 1;
    return AnimatedScale(
      scale: scale,
      duration: theme.motion.resolve(context, HeroMotion.fast),
      curve: HeroMotion.easeOut,
      child: CustomPaint(
        painter: HeroColorSwatchPainter(
          color: state.color,
          shape: theme.shapeAll(
            HeroColorSwatchPickerMetrics.swatchRadius(
              theme,
              item.size,
              item.variant,
              isSelected: state.isSelected,
            ),
          ),
          tileSize: theme.spacing(4),
          textDirection: Directionality.maybeOf(context),
        ),
      ),
    );
  }
}

/// The selection mark of a [HeroColorSwatchPickerItem]
/// (`ColorSwatchPicker.Indicator`).
///
/// Centred on the item, a third of its size, `white` on dark colors and
/// `black` on light ones; it scales in when the item is selected (150 ms ease-out).
/// The default child is HeroUI's check mark; pass a [child] (such as a
/// [HeroIcon]) or a [builder] to replace it.
class HeroColorSwatchPickerIndicator extends StatelessWidget {
  /// Creates the indicator part.
  const HeroColorSwatchPickerIndicator({super.key, this.child, this.builder});

  /// Replaces the check mark; icons take the indicator color and size.
  final Widget? child;

  /// Builds the mark from the item state; replaces [child].
  final HeroColorSwatchPickerItemBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final _HeroColorSwatchPickerItemScope? item =
        _HeroColorSwatchPickerItemScope.maybeOf(context);
    if (item == null) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColorSwatchPickerItemState state = item.state;
    final Color color = state.isLightColor
        ? theme.colors.black
        : theme.colors.white;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double extent = constraints.biggest.shortestSide / 3;
            final Widget mark =
                builder?.call(context, state) ??
                child ??
                CustomPaint(painter: _CheckmarkPainter(color: color));
            return Center(
              child: AnimatedScale(
                scale: state.isSelected ? 1 : 0,
                duration: theme.motion.resolve(context, HeroMotion.normal),
                curve: HeroMotion.easeOut,
                child: SizedBox.square(
                  dimension: extent,
                  child: IconTheme(
                    data: IconThemeData(color: color, size: extent),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: color),
                      child: mark,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// HeroUI's check mark: a 12 × 12 view box polyline (2.5,6) (5,8.5) (9.5,3)
// stroked 1.5 wide with round caps and joins.
class _CheckmarkPainter extends CustomPainter {
  const _CheckmarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.shortestSide / 12;
    final Path path = Path()
      ..moveTo(2.5 * unit, 6 * unit)
      ..lineTo(5 * unit, 8.5 * unit)
      ..lineTo(9.5 * unit, 3 * unit);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
