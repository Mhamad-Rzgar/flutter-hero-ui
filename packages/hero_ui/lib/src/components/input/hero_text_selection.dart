import 'dart:math' as math;

import 'package:flutter/cupertino.dart'
    show
        CupertinoTextSelectionControls,
        CupertinoTheme,
        CupertinoThemeData,
        cupertinoDesktopTextSelectionHandleControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';

/// iOS-style text selection handles (a bar with a ball) painted in the
/// theme's `--focus` color.
///
/// The toolbar is not managed here; hero_ui text fields show
/// [HeroTextSelectionToolbar] through `EditableText.contextMenuBuilder`.
class HeroTextSelectionControls extends CupertinoTextSelectionControls
    with TextSelectionHandleControls {
  /// Creates selection controls with an optional fixed [handleColor].
  HeroTextSelectionControls({this.handleColor});

  /// Handle color; defaults to the `focus` token of the ambient theme.
  final Color? handleColor;

  static final HeroTextSelectionControls _shared = HeroTextSelectionControls();

  /// The controls hero_ui uses on the current platform: iOS-style handles on
  /// touch platforms and no handles on desktop platforms.
  static TextSelectionControls adaptive() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS ||
      TargetPlatform.android ||
      TargetPlatform.fuchsia => _shared,
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.windows => cupertinoDesktopTextSelectionHandleControls,
    };
  }

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    final Color color = handleColor ?? HeroTheme.of(context).colors.focus;
    return CupertinoTheme(
      data: CupertinoThemeData(selectionHandleColor: color),
      child: Builder(
        builder: (BuildContext context) =>
            super.buildHandle(context, type, textLineHeight, onTap),
      ),
    );
  }
}

/// The copy / paste context menu of hero_ui text fields, drawn with HeroUI's
/// popover and menu tokens.
///
/// On touch platforms it is a horizontal bar above (or below) the selection,
/// like the iOS edit menu; on desktop platforms it is a vertical menu at the
/// pointer, like a HeroUI dropdown.
class HeroTextSelectionToolbar extends StatelessWidget {
  /// Creates a toolbar for [buttonItems] positioned at [anchors].
  const HeroTextSelectionToolbar({
    super.key,
    required this.anchors,
    required this.buttonItems,
  });

  /// Creates the toolbar for an [EditableTextState] with its default items.
  HeroTextSelectionToolbar.editableText({
    super.key,
    required EditableTextState editableTextState,
  }) : anchors = editableTextState.contextMenuAnchors,
       buttonItems = editableTextState.contextMenuButtonItems;

  /// Where the toolbar points.
  final TextSelectionToolbarAnchors anchors;

  /// The actions shown in the toolbar.
  final List<ContextMenuButtonItem> buttonItems;

  /// An `EditableText.contextMenuBuilder` that shows this toolbar.
  static Widget contextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) => HeroTextSelectionToolbar.editableText(
    editableTextState: editableTextState,
  );

  /// The label of [item]: its own label or the localized default.
  static String labelFor(BuildContext context, ContextMenuButtonItem item) {
    if (item.label != null) return item.label!;
    final WidgetsLocalizations l10n = WidgetsLocalizations.of(context);
    return switch (item.type) {
      ContextMenuButtonType.cut => l10n.cutButtonLabel,
      ContextMenuButtonType.copy => l10n.copyButtonLabel,
      ContextMenuButtonType.paste => l10n.pasteButtonLabel,
      ContextMenuButtonType.selectAll => l10n.selectAllButtonLabel,
      ContextMenuButtonType.lookUp => l10n.lookUpButtonLabel,
      ContextMenuButtonType.searchWeb => l10n.searchWebButtonLabel,
      ContextMenuButtonType.share => l10n.shareButtonLabel,
      ContextMenuButtonType.delete ||
      ContextMenuButtonType.liveTextInput ||
      ContextMenuButtonType.custom => '',
    };
  }

  static bool get _isDesktop => switch (defaultTargetPlatform) {
    TargetPlatform.macOS ||
    TargetPlatform.linux ||
    TargetPlatform.windows => true,
    TargetPlatform.iOS ||
    TargetPlatform.android ||
    TargetPlatform.fuchsia => false,
  };

  @override
  Widget build(BuildContext context) {
    final List<ContextMenuButtonItem> items = <ContextMenuButtonItem>[
      for (final ContextMenuButtonItem item in buttonItems)
        if (labelFor(context, item).isNotEmpty) item,
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    final HeroThemeData theme = HeroTheme.of(context);
    final bool desktop = _isDesktop;
    final double screenPadding = theme.spacing(2);
    final double paddingAbove =
        MediaQuery.paddingOf(context).top + screenPadding;
    final Offset localAdjustment = Offset(screenPadding, paddingAbove);

    final List<Widget> buttons = <Widget>[
      for (final ContextMenuButtonItem item in items)
        _HeroToolbarButton(
          label: labelFor(context, item),
          onPressed: item.onPressed,
        ),
    ];
    final Widget panel = _HeroToolbarPanel(
      child: desktop
          ? ConstrainedBox(
              constraints: BoxConstraints(minWidth: theme.spacing(40)),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: theme.spacing(1),
                  children: buttons,
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: theme.spacing(1),
                children: buttons,
              ),
            ),
    );

    final SingleChildLayoutDelegate delegate;
    if (desktop) {
      delegate = DesktopTextSelectionToolbarLayoutDelegate(
        anchor: anchors.primaryAnchor - localAdjustment,
      );
    } else {
      final double distance = theme.spacing(2);
      final Offset anchorAbove = anchors.primaryAnchor - Offset(0, distance);
      final Offset anchorBelow =
          (anchors.secondaryAnchor ?? anchors.primaryAnchor) +
          Offset(0, theme.spacing(5));
      // The bar is one menu item (`min-h-9`) plus the panel padding.
      final double barHeight = theme.spacing(9) + theme.spacing(2);
      final bool fitsAbove =
          barHeight <= anchorAbove.dy - distance - paddingAbove;
      delegate = TextSelectionToolbarLayoutDelegate(
        anchorAbove: anchorAbove - localAdjustment,
        anchorBelow: anchorBelow - localAdjustment,
        fitsAbove: fitsAbove,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenPadding,
        paddingAbove,
        screenPadding,
        screenPadding,
      ),
      child: CustomSingleChildLayout(delegate: delegate, child: panel),
    );
  }
}

/// The popover surface of the toolbar (`.popover` + `.menu`).
class _HeroToolbarPanel extends StatelessWidget {
  const _HeroToolbarPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroShadow shadow = theme.shadows.overlay;
    final Color? inset = shadow.insetColor;
    final OutlinedBorder shape = theme.shapeAll(
      math.min(theme.spacing(8), theme.radii.xl3),
      side: inset == null
          ? BorderSide.none
          : BorderSide(
              color: inset.withValues(alpha: inset.a * 0.5),
              width: theme.spacing(0.25),
            ),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: theme.colors.overlay,
        shape: shape,
        shadows: shadow.boxShadows,
      ),
      child: Padding(padding: EdgeInsets.all(theme.spacing(1)), child: child),
    );
  }
}

/// One action of the toolbar (`.menu-item`).
class _HeroToolbarButton extends StatelessWidget {
  const _HeroToolbarButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    return HeroInteractable(
      onPressed: onPressed,
      isDisabled: onPressed == null,
      // Taking focus would blur the text field and close the toolbar.
      canRequestFocus: false,
      semanticsLabel: label,
      excludeSemantics: true,
      builder: (BuildContext context, HeroInteractionState state, _) {
        return HeroPressScale(
          pressed: state.isPressed,
          scale: 0.98,
          curve: HeroMotion.easeOutQuart,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: state.isHovered || state.isPressed
                  ? theme.colors.defaultColor
                  : theme.colors.defaultColor.withValues(alpha: 0),
              shape: theme.shapeAll(theme.radii.xl2),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: theme.spacing(9)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing(2),
                  vertical: theme.spacing(1.5),
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: theme.typography
                        .style(HeroFontSize.sm, weight: HeroTypography.medium)
                        .copyWith(color: theme.colors.overlayForeground),
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
