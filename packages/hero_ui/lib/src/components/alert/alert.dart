/// HeroUI's Alert: an important message with a status indicator.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/foundation.dart';
import '../meter/range_layout.dart';
import '../surface/surface.dart';

/// Overrides for the container of a [HeroAlert], the counterpart of the
/// Tailwind classes HeroUI's customization example puts on `Alert`.
///
/// Every field is optional; `null` keeps HeroUI's value.
@immutable
class HeroAlertStyle with Diagnosticable {
  /// Creates alert style overrides.
  const HeroAlertStyle({
    this.color,
    this.gradient,
    this.border,
    this.borderRadius,
    this.shadows,
    this.padding,
  });

  /// Background color (`bg-*`); defaults to `--surface`.
  final Color? color;

  /// Background gradient painted over [color] (`bg-linear-*`).
  final Gradient? gradient;

  /// Border drawn inside the alert (`border-*`).
  final BorderSide? border;

  /// Corner radii (`rounded-*`); defaults to `min(32px, --radius-3xl)`.
  final BorderRadiusGeometry? borderRadius;

  /// Drop shadows (`shadow-*`); defaults to `--surface-shadow`.
  final List<BoxShadow>? shadows;

  /// Inner padding; defaults to `px-4 py-3`.
  final EdgeInsetsGeometry? padding;

  @override
  bool operator ==(Object other) =>
      other is HeroAlertStyle &&
      other.color == color &&
      other.gradient == gradient &&
      other.border == border &&
      other.borderRadius == borderRadius &&
      listEquals(other.shadows, shadows) &&
      other.padding == padding;

  @override
  int get hashCode => Object.hash(
    color,
    gradient,
    border,
    borderRadius,
    shadows == null ? null : Object.hashAll(shadows!),
    padding,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('color', color, defaultValue: null))
      ..add(
        DiagnosticsProperty<BorderSide>('border', border, defaultValue: null),
      )
      ..add(
        DiagnosticsProperty<BorderRadiusGeometry>(
          'borderRadius',
          borderRadius,
          defaultValue: null,
        ),
      );
  }
}

/// Displays an important message with a status indicator (HeroUI
/// `Alert`).
///
/// ```dart
/// const HeroAlert(
///   status: HeroColor.success,
///   title: Text('Profile updated successfully'),
///   endContent: HeroCloseButton(),
/// )
/// ```
///
/// The alert is a full-width `--surface` row (radius 24, `px-4 py-3`,
/// the surface shadow in light mode) with a 16 px gap between an
/// indicator, the content and any trailing actions, aligned at the top.
///
/// * [status]: `standard` (HeroUI's `default`), `accent`, `success`,
///   `warning` or `danger`. It colors the indicator and the title with the
///   status' soft foreground (`--foreground` for standard) and picks the
///   default icon: info for standard and accent, a check for success, a
///   triangle for warning and an exclamation mark for danger.
/// * [title], [description], [indicator] and [endContent] build HeroUI's
///   usual layout; pass [children] instead to compose the parts yourself:
///
/// ```dart
/// HeroAlert(
///   status: HeroColor.accent,
///   children: <Widget>[
///     const HeroAlertIndicator(),
///     const HeroAlertContent(
///       children: <Widget>[
///         HeroAlertTitle.text('Update available'),
///         HeroAlertDescription.text('Please refresh to get the latest.'),
///       ],
///     ),
///     HeroButton(size: HeroSize.sm, onPressed: refresh, child: const Text('Refresh')),
///   ],
/// )
/// ```
///
/// A [HeroAlertContent] among the [children] takes the remaining width.
/// Descendants see a standard [HeroSurfaceScope], like HeroUI's
/// `SurfaceContext`. The alert fills the available width (576 when it is
/// unbounded, the `max-w-xl` of HeroUI's examples).
class HeroAlert extends StatelessWidget {
  /// Creates an alert.
  const HeroAlert({
    super.key,
    this.status = HeroColor.standard,
    this.children,
    this.title,
    this.description,
    this.indicator,
    this.showIndicator = true,
    this.endContent,
    this.background,
    this.style,
    this.isLive = false,
    this.semanticLabel,
  });

  /// The status: the indicator and title color and the default icon.
  final HeroColor status;

  /// The parts: usually a [HeroAlertIndicator], a [HeroAlertContent] and
  /// actions. Replaces [title], [description], [indicator] and
  /// [endContent].
  final List<Widget>? children;

  /// The title of the default layout (a [HeroAlertTitle]'s content).
  final Widget? title;

  /// The description of the default layout.
  final Widget? description;

  /// Replaces the status icon of the default layout (for example a small
  /// `HeroSpinner`).
  final Widget? indicator;

  /// Whether the default layout shows the indicator.
  final bool showIndicator;

  /// Trailing content of the default layout: actions or a close button.
  final Widget? endContent;

  /// A decorative layer painted behind the content and clipped to the
  /// alert (an absolutely positioned element in HeroUI).
  final Widget? background;

  /// Container overrides.
  final HeroAlertStyle? style;

  /// Whether assistive technologies announce changes of the alert (a live
  /// region, `role="alert"`). HeroUI's alert sets no role.
  final bool isLive;

  /// Accessibility label of the alert.
  final String? semanticLabel;

  /// Returns the indicator and title color of [status].
  static Color statusColorOf(HeroColors colors, HeroColor status) =>
      switch (status) {
        HeroColor.standard => colors.foreground,
        _ => colors.role(status).softForeground,
      };

  /// Returns the default icon of [status].
  static HeroIconData iconOf(HeroColor status) => switch (status) {
    HeroColor.standard || HeroColor.accent => HeroIcons.info,
    HeroColor.success => HeroIcons.success,
    HeroColor.warning => HeroIcons.warning,
    HeroColor.danger => HeroIcons.danger,
  };

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroAlertStyle? style = this.style;
    final List<Widget> parts =
        children ??
        <Widget>[
          if (showIndicator) HeroAlertIndicator(child: indicator),
          HeroAlertContent(
            children: <Widget>[
              if (title case final Widget title) HeroAlertTitle(child: title),
              if (description case final Widget description)
                HeroAlertDescription(child: description),
            ],
          ),
          ?endContent,
        ];

    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: theme.spacing(4),
      children: <Widget>[
        for (final Widget part in parts)
          if (part is HeroAlertContent) Expanded(child: part) else part,
      ],
    );
    content = Padding(
      padding:
          style?.padding ??
          EdgeInsetsDirectional.symmetric(
            horizontal: theme.spacing(4),
            vertical: theme.spacing(3),
          ),
      child: content,
    );
    final Widget? background = this.background;
    if (background != null) {
      content = Stack(
        children: <Widget>[
          Positioned.fill(child: background),
          content,
        ],
      );
    }

    final List<BoxShadow>? shadows = style?.shadows;
    content = HeroSurface(
      borderRadius:
          style?.borderRadius ??
          BorderRadius.all(
            Radius.circular(math.min(theme.spacing(8), theme.radii.xl3)),
          ),
      border: style?.border,
      color: style?.color,
      gradient: style?.gradient,
      shadow: shadows == null
          ? theme.shadows.surface
          : HeroShadow(boxShadows: shadows),
      clipBehavior: background == null ? Clip.none : Clip.antiAlias,
      child: _HeroAlertScope(status: status, child: content),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      liveRegion: isLive,
      label: semanticLabel,
      child: HeroFillExtent(fallback: theme.spacing(144), child: content),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<HeroColor>(
          'status',
          status,
          defaultValue: HeroColor.standard,
        ),
      )
      ..add(FlagProperty('isLive', value: isLive, ifTrue: 'live'))
      ..add(
        FlagProperty(
          'showIndicator',
          value: showIndicator,
          ifFalse: 'no indicator',
          defaultValue: true,
        ),
      );
  }
}

/// Shares the status of a [HeroAlert] with its parts.
class _HeroAlertScope extends InheritedWidget {
  const _HeroAlertScope({required this.status, required super.child});

  final HeroColor status;

  static HeroColor statusOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroAlertScope>()?.status ??
      HeroColor.standard;

  @override
  bool updateShouldNotify(_HeroAlertScope oldWidget) =>
      status != oldWidget.status;
}

/// The status indicator of a [HeroAlert] (HeroUI `Alert.Indicator`).
///
/// A 4 px padded box whose icons take the status color and a 16 px size;
/// without a [child] it shows the status icon.
class HeroAlertIndicator extends StatelessWidget {
  /// Creates the indicator.
  const HeroAlertIndicator({super.key, this.child, this.color});

  /// Replaces the status icon.
  final Widget? child;

  /// Icon color (`text-*`); defaults to the status color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroColor status = _HeroAlertScope.statusOf(context);
    final Color foreground =
        color ?? HeroAlert.statusColorOf(theme.colors, status);
    return ExcludeSemantics(
      excluding: child == null,
      child: Padding(
        padding: EdgeInsets.all(theme.spacing(1)),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: theme.spacing(4)),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: foreground),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: child ?? HeroIcon(HeroAlert.iconOf(status)),
            ),
          ),
        ),
      ),
    );
  }
}

/// The text column of a [HeroAlert] (HeroUI `Alert.Content`), usually a
/// [HeroAlertTitle] and a [HeroAlertDescription]; it takes the width the
/// indicator and actions leave.
class HeroAlertContent extends StatelessWidget {
  /// Creates the content column.
  const HeroAlertContent({super.key, required this.children});

  /// The title, description and any extra content, top to bottom.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

/// The title of a [HeroAlert] (HeroUI `Alert.Title`): `text-sm leading-6
/// font-medium` in the status color.
class HeroAlertTitle extends StatelessWidget {
  /// Creates a title for [child].
  const HeroAlertTitle({super.key, required Widget this.child, this.style})
    : data = null;

  /// Creates a title showing [data].
  const HeroAlertTitle.text(String this.data, {super.key, this.style})
    : child = null;

  /// The title content (text widgets inherit the title style).
  final Widget? child;

  /// The title text, for [HeroAlertTitle.text].
  final String? data;

  /// Style merged over the title style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography
        .style(
          HeroFontSize.sm,
          weight: HeroTypography.medium,
          lineHeight: theme.spacing(6),
        )
        .copyWith(
          color: HeroAlert.statusColorOf(
            theme.colors,
            _HeroAlertScope.statusOf(context),
          ),
        )
        .merge(style?.copyWith(inherit: true));
    final String? data = this.data;
    return data != null
        ? Text(data, style: textStyle)
        : DefaultTextStyle.merge(style: textStyle, child: child!);
  }
}

/// The description of a [HeroAlert] (HeroUI `Alert.Description`):
/// `text-sm` in `--muted`.
class HeroAlertDescription extends StatelessWidget {
  /// Creates a description for [child].
  const HeroAlertDescription({
    super.key,
    required Widget this.child,
    this.style,
  }) : data = null;

  /// Creates a description showing [data].
  const HeroAlertDescription.text(String this.data, {super.key, this.style})
    : child = null;

  /// The description content (text widgets inherit the style).
  final Widget? child;

  /// The description text, for [HeroAlertDescription.text].
  final String? data;

  /// Style merged over the description style.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final TextStyle textStyle = theme.typography.sm
        .copyWith(color: theme.colors.muted)
        .merge(style?.copyWith(inherit: true));
    final String? data = this.data;
    return data != null
        ? Text(data, style: textStyle)
        : DefaultTextStyle.merge(style: textStyle, child: child!);
  }
}
