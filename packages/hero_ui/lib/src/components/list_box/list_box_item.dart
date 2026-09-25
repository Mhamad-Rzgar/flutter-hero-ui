part of 'list_box.dart';

/// Builds the content of a [HeroListBoxItemIndicator] for the selection
/// state of its item; null shows nothing.
typedef HeroListBoxIndicatorBuilder =
    Widget? Function(BuildContext context, bool isSelected);

/// HeroUI's `ListBox.Item`: one option of a [HeroListBox].
///
/// The item lays its content out in a row with a 12 px gap:
/// [startContent] (an icon or avatar), the main content ([builder], [child],
/// or a [label] over a [description]) and [endContent] (for example a
/// keyboard shortcut, [HeroKbd]) pushed to the end. An [indicator] (usually
/// a [HeroListBoxItemIndicator]) sits 8 px from the end edge and shows the
/// selection.
///
/// ```dart
/// HeroListBoxItem(
///   id: 'new-file',
///   startContent: const HeroIcon(HeroIcons.squarePlus),
///   label: 'New file',
///   description: 'Create a new file',
///   endContent: const HeroKbd(
///     variant: HeroKbdVariant.light,
///     keys: <HeroKbdKey>[HeroKbdKey.command],
///     text: 'N',
///   ),
/// )
/// ```
///
/// It is at least 36 px tall with 8 × 6 padding and 16 px corners, fills
/// with `--default` on hover, scales to 0.98 while pressed, shows the focus
/// ring for keyboard focus and fades when disabled. Selected items have no
/// fill; the indicator marks them. The [HeroListBoxVariant.danger] variant
/// colors the label and the indicator `--danger`.
class HeroListBoxItem extends StatefulWidget {
  /// Creates a list box item.
  const HeroListBoxItem({
    super.key,
    required this.id,
    this.textValue,
    this.label,
    this.description,
    this.startContent,
    this.endContent,
    this.child,
    this.builder,
    this.indicator,
    this.isDisabled = false,
    this.variant,
    this.onAction,
    this.style,
    this.semanticLabel,
  });

  /// Identifies the item in the list's selection, disabled keys and
  /// actions.
  final Object id;

  /// Text used for typeahead; defaults to [label] or the text of a [Text]
  /// [child].
  final String? textValue;

  /// Label text, shown as a [HeroLabel] (`text-sm font-medium`).
  final String? label;

  /// Supplementary text below [label], shown as a [HeroDescription]
  /// (`text-xs`, muted).
  final String? description;

  /// Content before the main content (an icon or an avatar).
  final Widget? startContent;

  /// Content after the main content, at the end of the row (a keyboard
  /// shortcut or a trailing icon).
  final Widget? endContent;

  /// The main content; replaces [label] and [description].
  final Widget? child;

  /// Builds the main content from the item state; replaces [child]
  /// (HeroUI's render-prop children).
  final HeroListBoxItemWidgetBuilder? builder;

  /// The selection indicator, usually a [HeroListBoxItemIndicator], placed
  /// 8 px from the end edge. The item reserves 28 px of end padding for it.
  final Widget? indicator;

  /// Whether the item cannot be focused, selected or pressed.
  final bool isDisabled;

  /// The variant; defaults to the list's variant.
  final HeroListBoxVariant? variant;

  /// Called when the item is pressed (after the list's selection changed).
  final VoidCallback? onAction;

  /// Style overrides, merged over the list's [HeroListBox.itemStyle].
  final HeroListBoxItemStyle? style;

  /// Accessibility label; defaults to the text of the content.
  final String? semanticLabel;

  /// The text used for typeahead: [textValue], else [label], else the text
  /// of a [Text] or [HeroLabel] [child], else an empty string.
  String get effectiveTextValue =>
      textValue ??
      label ??
      switch (child) {
        final Text text => text.data ?? text.textSpan?.toPlainText() ?? '',
        final HeroLabel label => label.data ?? '',
        _ => '',
      };

  @override
  State<HeroListBoxItem> createState() => _HeroListBoxItemState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Object>('id', id))
      ..add(StringProperty('textValue', textValue, defaultValue: null))
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'))
      ..add(
        EnumProperty<HeroListBoxVariant>(
          'variant',
          variant,
          defaultValue: null,
        ),
      );
  }
}

class _HeroListBoxItemState extends State<HeroListBoxItem> {
  _HeroListBoxState? _list;
  Object? _registered;

  void _register(_HeroListBoxState? list) {
    if (identical(list, _list) && _registered == widget.id) return;
    final Object? old = _registered;
    if (old != null) _list?._unregisterItem(old, context);
    _list = list;
    _registered = list == null ? null : widget.id;
    list?._registerItem(widget.id, context);
  }

  @override
  void dispose() {
    final Object? old = _registered;
    if (old != null) _list?._unregisterItem(old, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Object id = widget.id;
    final _HeroListBoxScope? scope = _HeroListBoxScope.maybeOf(context, id);
    final _HeroListBoxState? list = scope?.state;
    _register(list);
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroListBoxVariant variant =
        widget.variant ?? scope?.variant ?? HeroListBoxVariant.standard;
    final bool selected = scope?.isSelected(id) ?? false;
    final bool disabled =
        widget.isDisabled || (scope?.disabledKeys.contains(id) ?? false);
    final bool focused = scope?.isItemFocused(id) ?? false;
    final bool focusVisible = focused && scope!.isFocusVisible;
    final bool keyboardPressed = scope?.pressedKey == id;
    final HeroListBoxItemStyle style =
        (scope?.itemStyle ?? const HeroListBoxItemStyle()).merge(widget.style);
    final OutlinedBorder shape = theme.shape(
      style.borderRadius ?? BorderRadius.circular(theme.radii.xl2),
    );

    return HeroInteractable(
      canRequestFocus: false,
      isDisabled: disabled,
      isSelected: selected,
      semanticsLabel: widget.semanticLabel,
      onPressed: list == null ? widget.onAction : () => list._press(id),
      onPressStart: list == null ? null : () => list._focusFromPointer(id),
      onHoverChanged: list == null
          ? null
          : (bool hovered) {
              if (hovered) list._focusFromHover(id);
            },
      builder: (BuildContext context, HeroInteractionState interaction, _) {
        final HeroListBoxItemState state = interaction.copyWith(
          isPressed: interaction.isPressed || (keyboardPressed && !disabled),
          isFocused: focused,
          isFocusVisible: focusVisible,
          isSelected: selected,
        );
        final bool focusable = list != null && !disabled;
        return Semantics(
          focusable: focusable,
          // A null `focused` marks the node as not focusable.
          focused: focusable ? focused : null,
          child: _HeroListBoxItemScope(
            isSelected: selected,
            variant: variant,
            animate: scope?.animateIndicator ?? true,
            child: _HeroListBoxItemBody(
              item: widget,
              state: state,
              style: style,
              shape: shape,
              variant: variant,
            ),
          ),
        );
      },
    );
  }
}

class _HeroListBoxItemBody extends StatelessWidget {
  const _HeroListBoxItemBody({
    required this.item,
    required this.state,
    required this.style,
    required this.shape,
    required this.variant,
  });

  final HeroListBoxItem item;
  final HeroListBoxItemState state;
  final HeroListBoxItemStyle style;
  final OutlinedBorder shape;
  final HeroListBoxVariant variant;

  Widget? _labels() {
    final String? label = item.label;
    final String? description = item.description;
    if (label == null && description == null) return null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label != null) HeroLabel.text(label),
        if (description != null) HeroDescription.text(description),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColors colors = theme.colors;
    final TextDirection direction = Directionality.of(context);
    final Color? background =
        style.backgroundColor?.resolve(state.widgetStates) ??
        (state.isHovered ? colors.defaultColor : null);

    EdgeInsets padding =
        (style.padding ??
                EdgeInsetsDirectional.symmetric(
                  horizontal: theme.spacing(2),
                  vertical: theme.spacing(1.5),
                ))
            .resolve(direction);
    final Widget? indicator = item.indicator;
    if (indicator != null) {
      // `pe-7` leaves room for the absolutely positioned indicator.
      final double end = theme.spacing(7);
      padding = direction == TextDirection.ltr
          ? padding.copyWith(right: end)
          : padding.copyWith(left: end);
    }

    final Widget? main =
        item.builder?.call(context, state) ?? item.child ?? _labels();
    final Widget? start = item.startContent;
    final Widget? end = item.endContent;
    Widget content = Row(
      spacing: theme.spacing(3),
      children: <Widget>[
        ?start,
        if (main != null)
          Expanded(child: main)
        else if (end != null)
          const Spacer(),
        ?end,
      ],
    );
    content = DefaultTextStyle(
      style: theme.typography.sm.copyWith(
        color: DefaultTextStyle.of(context).style.color ?? colors.foreground,
      ),
      child: IconTheme.merge(
        data: IconThemeData(size: theme.spacing(4)),
        child: content,
      ),
    );
    // The item's labels and descriptions are plain parts of the option, not
    // of an enclosing form field; the danger variant colors labels
    // (`.list-box-item--danger [data-slot="label"]`).
    content = HeroFieldScope(
      isInvalid: variant == HeroListBoxVariant.danger,
      child: HeroSeparatorScope(child: content),
    );
    content = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: style.minHeight ?? theme.spacing(9),
      ),
      child: Padding(padding: padding, child: content),
    );
    if (indicator != null) {
      content = Stack(
        children: <Widget>[
          content,
          PositionedDirectional(
            end: theme.spacing(2),
            top: 0,
            bottom: 0,
            child: Center(child: indicator),
          ),
        ],
      );
    }
    content = DecoratedBox(
      decoration: ShapeDecoration(color: background, shape: shape),
      child: content,
    );
    return HeroPressScale(
      pressed: state.isPressed,
      scale: style.pressedScale ?? 0.98,
      curve: HeroMotion.easeOutQuart,
      child: HeroFocusRing(
        visible: state.isFocusVisible,
        shape: shape,
        child: HeroDisabledOpacity(disabled: state.isDisabled, child: content),
      ),
    );
  }
}

class _HeroListBoxItemScope extends InheritedWidget {
  const _HeroListBoxItemScope({
    required this.isSelected,
    required this.variant,
    required this.animate,
    required super.child,
  });

  final bool isSelected;
  final HeroListBoxVariant variant;
  final bool animate;

  static _HeroListBoxItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroListBoxItemScope>();

  @override
  bool updateShouldNotify(_HeroListBoxItemScope oldWidget) =>
      isSelected != oldWidget.isSelected ||
      variant != oldWidget.variant ||
      animate != oldWidget.animate;
}

/// HeroUI's `ListBox.ItemIndicator`: the selection mark of a
/// [HeroListBoxItem], passed as its `indicator`.
///
/// By default it draws HeroUI's checkmark, which strokes itself in over
/// 300 ms when the item is selected and out when it is deselected, in
/// `--default-foreground` (`--danger` for danger items). Pass a [child] to
/// replace it, or a [builder] to render something for the selection state
/// (return null to show nothing):
///
/// ```dart
/// HeroListBoxItemIndicator(
///   builder: (BuildContext context, bool isSelected) => isSelected
///       ? HeroIcon(HeroIcons.check, color: colors.accentSoftForeground)
///       : null,
/// )
/// ```
///
/// The indicator is 16 × 16 and hidden from assistive technologies; the
/// item announces its selected state.
class HeroListBoxItemIndicator extends StatelessWidget {
  /// Creates an item indicator.
  const HeroListBoxItemIndicator({super.key, this.child, this.builder});

  /// Replaces the checkmark.
  final Widget? child;

  /// Builds the indicator for the selection state; replaces [child].
  final HeroListBoxIndicatorBuilder? builder;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroListBoxItemScope? item = _HeroListBoxItemScope.maybeOf(context);
    final bool selected = item?.isSelected ?? false;
    final Color color = item?.variant == HeroListBoxVariant.danger
        ? theme.colors.danger
        : theme.colors.defaultForeground;
    final double size = theme.spacing(4);
    final HeroListBoxIndicatorBuilder? builder = this.builder;
    final Widget? content = builder != null
        ? builder(context, selected)
        : (child ??
              _HeroCheckmark(
                selected: selected,
                animate: item?.animate ?? true,
              ));
    return ExcludeSemantics(
      child: IconTheme.merge(
        data: IconThemeData(color: color, size: size),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: color),
          child: SizedBox.square(
            dimension: size,
            child: content == null ? null : Center(child: content),
          ),
        ),
      ),
    );
  }
}

/// HeroUI's checkmark: a polyline stroked in with a dash offset transition.
class _HeroCheckmark extends StatelessWidget {
  const _HeroCheckmark({required this.selected, required this.animate});

  final bool selected;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final Color color =
        IconTheme.of(context).color ?? theme.colors.defaultForeground;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: selected ? 1 : 0),
      // `transition-all duration-300` with Tailwind's default easing.
      duration: animate
          ? theme.motion.resolve(context, HeroMotion.slower)
          : Duration.zero,
      curve: HeroMotion.easeInOut,
      builder: (BuildContext context, double progress, Widget? child) =>
          CustomPaint(
            size: Size.square(theme.spacing(2.5)),
            painter: _HeroCheckmarkPainter(progress: progress, color: color),
          ),
    );
  }
}

class _HeroCheckmarkPainter extends CustomPainter {
  const _HeroCheckmarkPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    // `viewBox="0 0 17 18"`, scaled to fit and centered (`xMidYMid meet`).
    final double scale = math.min(size.width / 17, size.height / 18);
    final Offset origin = Offset(
      (size.width - 17 * scale) / 2,
      (size.height - 18 * scale) / 2,
    );
    Offset point(double x, double y) => origin + Offset(x * scale, y * scale);
    final Path path = Path()
      ..moveTo(point(1, 9).dx, point(1, 9).dy)
      ..lineTo(point(7, 14).dx, point(7, 14).dy)
      ..lineTo(point(15, 4).dx, point(15, 4).dy);
    // `stroke-dasharray: 22`: the offset moves from 66 (hidden) to 44
    // (drawn), revealing up to 22 units of the ~20.6 unit polyline.
    final PathMetric metric = path.computeMetrics().first;
    final double length = math.min(metric.length, 22 * scale * progress);
    if (length <= 0) return;
    canvas.drawPath(
      metric.extractPath(0, length),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_HeroCheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
