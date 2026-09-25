/// HeroUI's AlertDialog: a modal dialog for critical confirmations that
/// require an explicit decision.
library;

import 'dart:ui' show SemanticsRole;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../modal/modal.dart';

/// The width of an alert dialog (`AlertDialog.Container` `size`).
enum HeroAlertDialogSize {
  /// At most 320 wide.
  xs(HeroModalSize.xs),

  /// At most 384 wide.
  sm(HeroModalSize.sm),

  /// At most 448 wide, the default.
  md(HeroModalSize.md),

  /// At most 512 wide.
  lg(HeroModalSize.lg),

  /// Fills the screen inside the container padding (16, or 40 from 640 px).
  cover(HeroModalSize.cover);

  const HeroAlertDialogSize(this.modalSize);

  /// The equivalent modal size.
  final HeroModalSize modalSize;
}

/// A modal dialog for critical confirmations that require user attention
/// and an explicit decision.
///
/// ```dart
/// HeroAlertDialog(
///   trigger: const HeroButton(
///     variant: HeroButtonVariant.danger,
///     child: Text('Delete Project'),
///   ),
///   child: HeroAlertDialogBackdrop(
///     child: HeroAlertDialogContainer(
///       child: HeroAlertDialogDialog(
///         maxWidth: 400,
///         children: const <Widget>[
///           HeroAlertDialogCloseTrigger(),
///           HeroAlertDialogHeader(children: <Widget>[
///             HeroAlertDialogIcon(),
///             HeroAlertDialogHeading(
///               child: Text('Delete project permanently?'),
///             ),
///           ]),
///           HeroAlertDialogBody(child: Text('This cannot be undone.')),
///           HeroAlertDialogFooter(children: <Widget>[
///             HeroButton(
///               slot: HeroButtonSlot.close,
///               variant: HeroButtonVariant.tertiary,
///               child: Text('Cancel'),
///             ),
///             HeroButton(
///               slot: HeroButtonSlot.close,
///               variant: HeroButtonVariant.danger,
///               child: Text('Delete Project'),
///             ),
///           ]),
///         ],
///       ),
///     ),
///   ),
/// )
/// ```
///
/// It shares the modal's route, backdrop, placements and motion, but by
/// default requires an explicit action: pressing the backdrop and Escape do
/// not close it ([HeroAlertDialogBackdrop.isDismissable] is false and
/// [HeroAlertDialogBackdrop.isKeyboardDismissDisabled] is true), the dialog
/// is announced as an alert dialog, its body always scrolls inside, and
/// [HeroAlertDialogIcon] shows a status icon.
class HeroAlertDialog extends StatelessWidget {
  /// Creates an alert dialog.
  const HeroAlertDialog({
    super.key,
    required this.child,
    this.trigger,
    this.isOpen,
    this.defaultOpen = false,
    this.onOpenChanged,
    this.controller,
    this.useRootNavigator = true,
  });

  /// The overlay: a [HeroAlertDialogBackdrop] holding a
  /// [HeroAlertDialogContainer].
  final Widget child;

  /// The widget that opens the dialog when pressed.
  final Widget? trigger;

  /// Controlled open state; defaults to the backdrop's `isOpen`.
  final bool? isOpen;

  /// Initial open state when uncontrolled.
  final bool defaultOpen;

  /// Called when the open state should change.
  final ValueChanged<bool>? onOpenChanged;

  /// External open state.
  final HeroOverlayController? controller;

  /// Whether to open in the root navigator.
  final bool useRootNavigator;

  /// Opens an alert dialog and completes with the value it is closed with.
  ///
  /// [builder] returns the [HeroAlertDialogDialog]; its `close` argument
  /// closes the dialog.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext context, VoidCallback close) builder,
    HeroBackdropVariant backdropVariant = HeroBackdropVariant.opaque,
    HeroModalPlacement placement = HeroModalPlacement.auto,
    HeroAlertDialogSize size = HeroAlertDialogSize.md,
    bool isDismissable = false,
    bool isKeyboardDismissDisabled = true,
    bool useRootNavigator = true,
    RouteSettings? settings,
  }) {
    return showHeroModalRoute<T>(
      context,
      useRootNavigator: useRootNavigator,
      settings: settings,
      content: HeroAlertDialogBackdrop(
        variant: backdropVariant,
        isDismissable: isDismissable,
        isKeyboardDismissDisabled: isKeyboardDismissDisabled,
        child: HeroAlertDialogContainer(
          placement: placement,
          size: size,
          child: Builder(
            builder: (BuildContext context) => builder(
              context,
              () => HeroDialogScope.maybeOf(context)?.close(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HeroModal(
      trigger: trigger,
      isOpen: isOpen,
      defaultOpen: defaultOpen,
      onOpenChanged: onOpenChanged,
      controller: controller,
      useRootNavigator: useRootNavigator,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('isOpen', value: isOpen, ifTrue: 'open'))
      ..add(FlagProperty('defaultOpen', value: defaultOpen));
  }
}

/// A custom pressable that opens an alert dialog (`AlertDialog.Trigger`);
/// see [HeroModalTrigger].
class HeroAlertDialogTrigger extends HeroModalTrigger {
  /// Creates a trigger.
  const HeroAlertDialogTrigger({
    super.key,
    super.child,
    super.builder,
    super.onPressed,
    super.borderRadius,
    super.isDisabled,
    super.semanticLabel,
  });
}

/// The backdrop of an alert dialog (`AlertDialog.Backdrop`).
///
/// Like [HeroModalBackdrop], except that pressing it ([isDismissable]) and
/// Escape ([isKeyboardDismissDisabled]) do not close the dialog by default.
class HeroAlertDialogBackdrop extends HeroModalBackdrop {
  /// Creates a backdrop.
  const HeroAlertDialogBackdrop({
    super.key,
    required super.child,
    super.variant,
    super.isDismissable = false,
    super.isKeyboardDismissDisabled = true,
    super.isOpen,
    super.onOpenChanged,
    super.color,
    super.decoration,
    super.motion,
    super.useRootNavigator,
  });
}

/// Positions an alert dialog (`AlertDialog.Container`): the modal
/// container with the body always scrolling inside the dialog.
class HeroAlertDialogContainer extends StatelessWidget
    implements HeroModalAnimatedLayer {
  /// Creates a container.
  const HeroAlertDialogContainer({
    super.key,
    required this.child,
    this.placement = HeroModalPlacement.auto,
    this.size = HeroAlertDialogSize.md,
    this.motion = const HeroModalMotion(),
    this.transitionBuilder,
  });

  /// The dialog.
  final Widget child;

  /// Where the dialog sits.
  final HeroModalPlacement placement;

  /// The dialog size.
  final HeroAlertDialogSize size;

  /// Overrides of the enter and exit motion.
  final HeroModalMotion motion;

  /// Replaces the fade/zoom/slide transition.
  final HeroModalTransitionBuilder? transitionBuilder;

  @override
  Duration get enterDuration => _container.enterDuration;

  @override
  Duration get exitDuration => _container.exitDuration;

  HeroModalContainer get _container => HeroModalContainer(
    placement: placement,
    size: size.modalSize,
    motion: motion,
    transitionBuilder: transitionBuilder,
    child: child,
  );

  @override
  Widget build(BuildContext context) => _container;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<HeroModalPlacement>('placement', placement))
      ..add(EnumProperty<HeroAlertDialogSize>('size', size));
  }
}

/// The panel of an alert dialog (`AlertDialog.Dialog`), announced with the
/// alert dialog role; see [HeroModalDialog].
class HeroAlertDialogDialog extends HeroModalDialog {
  /// Creates a dialog.
  const HeroAlertDialogDialog({
    super.key,
    super.children,
    super.builder,
    super.role = SemanticsRole.alertDialog,
    super.semanticLabel,
    super.maxWidth,
    super.padding,
    super.backgroundColor,
    super.side,
    super.shadows,
    super.backdropBlur,
  });
}

/// The title area of an alert dialog (`AlertDialog.Header`); see
/// [HeroModalHeader].
class HeroAlertDialogHeader extends HeroModalHeader {
  /// Creates a header.
  const HeroAlertDialogHeader({
    super.key,
    super.children,
    super.crossAxisAlignment,
  });
}

/// The title of an alert dialog (`AlertDialog.Heading`); see
/// [HeroModalHeading].
class HeroAlertDialogHeading extends HeroModalHeading {
  /// Creates a heading.
  const HeroAlertDialogHeading({
    super.key,
    required super.child,
    super.textAlign,
  });
}

/// The message of an alert dialog (`AlertDialog.Body`), scrolling when it
/// is too tall; see [HeroModalBody].
class HeroAlertDialogBody extends HeroModalBody {
  /// Creates a body.
  const HeroAlertDialogBody({
    super.key,
    super.child,
    super.children,
    super.padding,
  });
}

/// The actions of an alert dialog (`AlertDialog.Footer`); see
/// [HeroModalFooter].
class HeroAlertDialogFooter extends HeroModalFooter {
  /// Creates a footer.
  const HeroAlertDialogFooter({super.key, super.children, super.child});
}

/// The close button of an alert dialog (`AlertDialog.CloseTrigger`); see
/// [HeroModalCloseTrigger].
class HeroAlertDialogCloseTrigger extends HeroModalCloseTrigger {
  /// Creates a close trigger.
  const HeroAlertDialogCloseTrigger({
    super.key,
    super.child,
    super.onPressed,
    super.semanticLabel,
  });
}

/// The status icon of an alert dialog (`AlertDialog.Icon`): a 40 px
/// circle in the soft color of [status] with HeroUI's status glyph.
///
/// | Status | Fill | Glyph |
/// | --- | --- | --- |
/// | `standard` | `defaultColor` / `foreground` | info |
/// | `accent` | `accentSoft` / `accentSoftForeground` | info |
/// | `success` | `successSoft` / `successSoftForeground` | check circle |
/// | `warning` | `warningSoft` / `warningSoftForeground` | warning triangle |
/// | `danger` (default) | `dangerSoft` / `dangerSoftForeground` | exclamation circle |
///
/// A [child] replaces the glyph and keeps the colors.
class HeroAlertDialogIcon extends StatelessWidget {
  /// Creates a status icon.
  const HeroAlertDialogIcon({
    super.key,
    this.status = HeroColor.danger,
    this.child,
  });

  /// The status that picks the colors and the default glyph.
  final HeroColor status;

  /// A custom glyph, usually a [HeroIcon].
  final Widget? child;

  /// The default glyph of [status].
  static HeroIconData iconFor(HeroColor status) => switch (status) {
    HeroColor.standard || HeroColor.accent => HeroIcons.info,
    HeroColor.success => HeroIcons.success,
    HeroColor.warning => HeroIcons.warning,
    HeroColor.danger => HeroIcons.danger,
  };

  @override
  Widget build(BuildContext context) {
    final HeroColors colors = HeroTheme.of(context).colors;
    final (Color background, Color foreground) = switch (status) {
      HeroColor.standard => (colors.defaultColor, colors.foreground),
      HeroColor.accent => (colors.accentSoft, colors.accentSoftForeground),
      HeroColor.success => (colors.successSoft, colors.successSoftForeground),
      HeroColor.warning => (colors.warningSoft, colors.warningSoftForeground),
      HeroColor.danger => (colors.dangerSoft, colors.dangerSoftForeground),
    };
    return HeroModalIcon(
      backgroundColor: background,
      foregroundColor: foreground,
      child: child ?? HeroIcon(iconFor(status)),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<HeroColor>('status', status, defaultValue: HeroColor.danger),
    );
  }
}
