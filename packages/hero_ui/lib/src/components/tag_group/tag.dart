part of 'tag_group.dart';

/// The render state of a [HeroTag]: the interaction state plus whether the
/// tag can be removed (HeroUI's `allowsRemoving` render prop).
@immutable
class HeroTagState extends HeroInteractionState {
  /// Creates a tag state.
  const HeroTagState({
    super.isHovered,
    super.isPressed,
    super.isFocused,
    super.isFocusVisible,
    super.isDisabled,
    super.isSelected,
    this.allowsRemoving = false,
  });

  /// Whether the tag group has an `onRemove` handler, so the tag should
  /// show a [HeroTagRemoveButton].
  final bool allowsRemoving;

  @override
  bool operator ==(Object other) =>
      other is HeroTagState &&
      super == other &&
      other.allowsRemoving == allowsRemoving;

  @override
  int get hashCode => Object.hash(super.hashCode, allowsRemoving);
}

/// Builds the content of a [HeroTag] for its current state (HeroUI's
/// render-prop children).
typedef HeroTagWidgetBuilder =
    Widget Function(BuildContext context, HeroTagState state);

/// Optional style overrides for a [HeroTag], the counterpart of customising
/// `.tag` with utilities. `null` values keep HeroUI's look; state-dependent
/// values are resolved with the tag's [WidgetState]s (`hovered`, `pressed`,
/// `focused`, `selected`, `disabled`).
@immutable
class HeroTagStyle {
  /// Creates tag style overrides.
  const HeroTagStyle({
    this.backgroundColor,
    this.foregroundColor,
    this.side,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.iconSize,
    this.iconColor,
    this.gap,
    this.shadows,
  });

  /// Fill of the tag.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Text and icon color.
  final WidgetStateProperty<Color?>? foregroundColor;

  /// Border drawn inside the tag.
  final WidgetStateProperty<BorderSide?>? side;

  /// Corner radii.
  final BorderRadiusGeometry? borderRadius;

  /// Inner padding.
  final EdgeInsetsGeometry? padding;

  /// Text style merged over the size's style.
  final TextStyle? textStyle;

  /// Size of icons in the tag (12 by default).
  final double? iconSize;

  /// Color of icons; defaults to the text color.
  final WidgetStateProperty<Color?>? iconColor;

  /// Gap between the parts of the tag (4 by default).
  final double? gap;

  /// Shadows painted behind the tag.
  final List<BoxShadow>? shadows;
}

/// HeroUI's `Tag`: one tag of a [HeroTagGroupList].
///
/// Content is a [startContent] (a 12 px icon or a small avatar) followed by
/// the [label] (or any [child]), or what [builder] returns. When the group
/// has an `onRemove` handler a remove button is appended, a
/// [HeroTagRemoveButton] by default or [removeButton].
///
/// Tags are `text-xs` medium (`text-sm` when large) with 12 px corners
/// (16 when large), filled with `--default` (or `--surface`), `--default-hover`
/// on hover and `--accent-soft` with `--accent-soft-foreground` text when
/// selected. Colors change over 100 ms.
class HeroTag extends StatefulWidget {
  /// Creates a tag.
  const HeroTag({
    super.key,
    required this.id,
    this.textValue,
    this.label,
    this.child,
    this.startContent,
    this.builder,
    this.removeButton,
    this.isDisabled = false,
    this.style,
    this.semanticLabel,
  });

  /// Identifies the tag in the group's selection, disabled keys and
  /// removal.
  final Object id;

  /// Text used for typeahead and as the accessibility label; defaults to
  /// [label] or the text of a [Text] [child].
  final String? textValue;

  /// The tag text.
  final String? label;

  /// The content; replaces [label].
  final Widget? child;

  /// Content before the label: an icon (12 px) or an avatar.
  final Widget? startContent;

  /// Builds the whole content from the tag state; replaces [startContent],
  /// [label], [child] and the automatic remove button (add a
  /// [HeroTagRemoveButton] when `state.allowsRemoving`).
  final HeroTagWidgetBuilder? builder;

  /// Replaces the automatic remove button, usually a [HeroTagRemoveButton]
  /// with a custom icon.
  final Widget? removeButton;

  /// Whether the tag cannot be focused, selected or removed.
  final bool isDisabled;

  /// Style overrides.
  final HeroTagStyle? style;

  /// Accessibility label; defaults to the text of the content.
  final String? semanticLabel;

  /// The text used for typeahead: [textValue], else [label], else the text
  /// of a [Text] [child], else an empty string.
  String get effectiveTextValue =>
      textValue ??
      label ??
      switch (child) {
        final Text text => text.data ?? text.textSpan?.toPlainText() ?? '',
        _ => '',
      };

  @override
  State<HeroTag> createState() => _HeroTagState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Object>('id', id))
      ..add(StringProperty('label', label, defaultValue: null))
      ..add(FlagProperty('isDisabled', value: isDisabled, ifTrue: 'disabled'));
  }
}

class _HeroTagState extends State<HeroTag> {
  BuildContext? _removeContext;
  Offset? _lastDown;

  void _registerRemove(BuildContext? context) => _removeContext = context;

  // HeroUI widens the 12 px remove button to a 24 px touch target
  // (`touch-target`); presses on the tag that land in that area remove it.
  bool _hitsRemoveTarget(Offset? global) {
    final RenderObject? object = _removeContext?.findRenderObject();
    if (global == null || object is! RenderBox || !object.attached) {
      return false;
    }
    final Offset center = object.localToGlobal(object.size.center(Offset.zero));
    final double half = HeroTheme.of(context).spacing(3);
    return Rect.fromCenter(
      center: center,
      width: half * 2,
      height: half * 2,
    ).contains(global);
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroTagGroupScope? group = _HeroTagGroupScope.maybeOf(context);
    final _HeroTagListScope? list = _HeroTagListScope.maybeOf(context);
    final Object id = widget.id;
    final bool selected = group?.selectedKeys.contains(id) ?? false;
    final bool disabled =
        widget.isDisabled ||
        (group?.isDisabled ?? false) ||
        (group?.disabledKeys.contains(id) ?? false);
    final bool focused = list?.focusedKey == id;
    final bool allowsRemoving = group?.allowsRemoving ?? false;
    final _HeroTagGroupListState? listState = list?.state;

    void remove() => listState?._remove(id);

    return Listener(
      onPointerDown: (PointerDownEvent event) => _lastDown = event.position,
      child: HeroInteractable(
        canRequestFocus: false,
        isDisabled: disabled,
        isSelected: selected,
        semanticsLabel: widget.semanticLabel ?? widget.textValue,
        onPressStart: listState == null
            ? null
            : () => listState._focusFromPointer(id),
        onPressed: listState == null
            ? null
            : () {
                if (allowsRemoving && _hitsRemoveTarget(_lastDown)) {
                  remove();
                } else {
                  listState._press(id);
                }
              },
        builder: (BuildContext context, HeroInteractionState interaction, _) {
          final HeroTagState state = HeroTagState(
            isHovered: interaction.isHovered,
            isPressed: interaction.isPressed,
            isFocused: focused,
            isFocusVisible: focused && list!.isFocusVisible,
            isDisabled: disabled,
            isSelected: selected,
            allowsRemoving: allowsRemoving,
          );
          final bool focusable = listState != null && !disabled;
          return Semantics(
            focusable: focusable,
            focused: focusable ? focused : null,
            child: _HeroTagScope(
              allowsRemoving: allowsRemoving,
              isDisabled: disabled,
              onRemove: remove,
              register: _registerRemove,
              child: _HeroTagBody(
                tag: widget,
                state: state,
                size: group?.size ?? HeroSize.md,
                variant: group?.variant ?? HeroTagVariant.standard,
                theme: theme,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroTagBody extends StatelessWidget {
  const _HeroTagBody({
    required this.tag,
    required this.state,
    required this.size,
    required this.variant,
    required this.theme,
  });

  final HeroTag tag;
  final HeroTagState state;
  final HeroSize size;
  final HeroTagVariant variant;
  final HeroThemeData theme;

  @override
  Widget build(BuildContext context) {
    final HeroColors colors = theme.colors;
    final HeroTagStyle? style = tag.style;
    final Set<WidgetState> states = state.widgetStates;
    final bool hovered = state.isHovered && !state.isDisabled;

    final Color background =
        style?.backgroundColor?.resolve(states) ??
        (state.isSelected
            ? (hovered ? colors.accentSoftHover : colors.accentSoft)
            : switch (variant) {
                HeroTagVariant.standard =>
                  hovered ? colors.defaultHover : colors.defaultColor,
                HeroTagVariant.surface =>
                  hovered ? colors.surfaceHover : colors.surface,
              });
    final Color foreground =
        style?.foregroundColor?.resolve(states) ??
        (state.isSelected
            ? colors.accentSoftForeground
            : switch (variant) {
                HeroTagVariant.standard => colors.defaultForeground,
                HeroTagVariant.surface => colors.surfaceForeground,
              });
    final BorderSide side = style?.side?.resolve(states) ?? BorderSide.none;
    final OutlinedBorder shape = theme.shape(
      style?.borderRadius ??
          BorderRadius.circular(
            size == HeroSize.lg ? theme.radii.xl2 : theme.radii.xl,
          ),
      side: side,
    );
    final EdgeInsetsGeometry padding =
        style?.padding ??
        switch (size) {
          HeroSize.sm => EdgeInsets.symmetric(
            horizontal: theme.spacing(2),
            vertical: theme.spacing(0.5),
          ),
          HeroSize.md => EdgeInsets.symmetric(
            horizontal: theme.spacing(2),
            vertical: theme.spacing(1),
          ),
          HeroSize.lg => EdgeInsets.symmetric(
            horizontal: theme.spacing(2.5),
            vertical: theme.spacing(1.5),
          ),
        };
    final TextStyle textStyle = theme.typography
        .style(
          size == HeroSize.lg ? HeroFontSize.sm : HeroFontSize.xs,
          weight: HeroTypography.medium,
        )
        .merge(style?.textStyle?.copyWith(inherit: true));
    final Duration duration = theme.motion.resolve(context, HeroMotion.fast);

    Widget content;
    final HeroTagWidgetBuilder? builder = tag.builder;
    if (builder != null) {
      content = builder(context, state);
    } else {
      final String? label = tag.label;
      final Widget? main = tag.child ?? (label == null ? null : Text(label));
      final Widget? start = tag.startContent;
      content = Row(
        mainAxisSize: MainAxisSize.min,
        spacing: style?.gap ?? theme.spacing(1),
        children: <Widget>[
          ?start,
          if (main != null) Flexible(child: main),
          if (state.allowsRemoving)
            tag.removeButton ?? const HeroTagRemoveButton(),
        ],
      );
    }

    content = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: foreground),
      duration: duration,
      curve: HeroMotion.smooth,
      child: content,
      builder: (BuildContext context, Color? color, Widget? child) =>
          DefaultTextStyle(
            style: textStyle.copyWith(color: color),
            child: IconTheme(
              data: IconThemeData(
                color: style?.iconColor?.resolve(states) ?? color,
                size: style?.iconSize ?? theme.spacing(3),
              ),
              child: child!,
            ),
          ),
    );
    content = AnimatedContainer(
      duration: duration,
      curve: HeroMotion.smooth,
      decoration: ShapeDecoration(
        color: background,
        shape: shape,
        shadows: style?.shadows,
      ),
      padding: padding.add(shape.dimensions),
      child: content,
    );
    return HeroFocusRing(
      visible: state.isFocusVisible,
      shape: shape,
      child: HeroDisabledOpacity(disabled: state.isDisabled, child: content),
    );
  }
}

class _HeroTagScope extends InheritedWidget {
  const _HeroTagScope({
    required this.allowsRemoving,
    required this.isDisabled,
    required this.onRemove,
    required this.register,
    required super.child,
  });

  final bool allowsRemoving;
  final bool isDisabled;
  final VoidCallback onRemove;
  final ValueChanged<BuildContext?> register;

  static _HeroTagScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroTagScope>();

  @override
  bool updateShouldNotify(_HeroTagScope oldWidget) =>
      allowsRemoving != oldWidget.allowsRemoving ||
      isDisabled != oldWidget.isDisabled;
}

/// HeroUI's `Tag.RemoveButton`: the button that removes its [HeroTag].
///
/// A 12 px close button in the tag's text color with a 24 px touch target.
/// It is not a Tab stop: keyboard users remove the focused tag with Delete
/// or Backspace. Tags show one automatically when their group has an
/// `onRemove` handler; add one yourself to change its [child] icon, as the
/// tag's `removeButton` or inside its `builder`.
class HeroTagRemoveButton extends StatefulWidget {
  /// Creates a remove button.
  const HeroTagRemoveButton({
    super.key,
    this.child,
    this.semanticLabel = 'Remove tag',
  });

  /// The icon; defaults to HeroUI's close icon.
  final Widget? child;

  /// Accessibility label.
  final String semanticLabel;

  @override
  State<HeroTagRemoveButton> createState() => _HeroTagRemoveButtonState();
}

class _HeroTagRemoveButtonState extends State<HeroTagRemoveButton> {
  _HeroTagScope? _tag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _HeroTagScope? tag = _HeroTagScope.maybeOf(context);
    if (tag != _tag) {
      _tag?.register(null);
      _tag = tag;
      tag?.register(context);
    }
  }

  @override
  void dispose() {
    _tag?.register(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final _HeroTagScope? tag = _HeroTagScope.maybeOf(context);
    final Color color =
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color ??
        theme.colors.foreground;
    final double size = theme.spacing(3);
    return ExcludeFocus(
      child: HeroCloseButton(
        onPressed: tag?.onRemove,
        isDisabled: tag?.isDisabled ?? false,
        semanticLabel: widget.semanticLabel,
        style: HeroButtonStyle(
          height: size,
          iconSize: size,
          foregroundColor: WidgetStatePropertyAll<Color?>(color),
        ),
        child: widget.child,
      ),
    );
  }
}
