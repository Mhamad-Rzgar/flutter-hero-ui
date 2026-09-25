import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/theme/hero_theme.dart';
import '../../foundation/theme/hero_theme_data.dart';
import '../../foundation/tokens/hero_motion.dart';
import '../../foundation/tokens/hero_typography.dart';
import '../../foundation/variants/hero_variants.dart';

/// The visual variants of a [HeroAvatar].
enum HeroAvatarVariant {
  /// `--default` fill behind the fallback (HeroUI's `default`).
  standard,

  /// Transparent root; the fallback uses the role's soft fill.
  soft,
}

/// The loading state of a [HeroAvatarImage].
enum HeroAvatarLoadingStatus {
  /// No image has been requested.
  idle,

  /// The image is loading.
  loading,

  /// The image is ready and shown.
  loaded,

  /// The image failed to load; the fallback stays visible.
  error,
}

/// Default size, color and variant for the [HeroAvatar]s below it, plus the
/// optical padding of their fallback. A `HeroAvatarGroup` provides it to
/// its children.
class HeroAvatarScope extends InheritedWidget {
  /// Provides avatar defaults to [child].
  const HeroAvatarScope({
    super.key,
    this.size,
    this.color,
    this.variant,
    this.fallbackPadding,
    required super.child,
  });

  /// Size of avatars that do not set one.
  final HeroSize? size;

  /// Color of avatars that do not set one.
  final HeroColor? color;

  /// Variant of avatars that do not set one.
  final HeroAvatarVariant? variant;

  /// Extra padding around fallback content (the group's clip nudge).
  final EdgeInsetsGeometry? fallbackPadding;

  /// Returns the nearest scope, or null.
  static HeroAvatarScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<HeroAvatarScope>();

  @override
  bool updateShouldNotify(HeroAvatarScope oldWidget) =>
      size != oldWidget.size ||
      color != oldWidget.color ||
      variant != oldWidget.variant ||
      fallbackPadding != oldWidget.fallbackPadding;
}

/// Displays a user profile image with fallback content (HeroUI `Avatar`).
///
/// Use the shorthand parameters for the common case:
///
/// ```dart
/// HeroAvatar(src: 'https://example.com/jane.jpg', name: 'Jane Doe')
/// HeroAvatar(fallback: HeroIcon(HeroIcons.person), color: HeroColor.accent)
/// ```
///
/// or compose the parts like HeroUI:
///
/// ```dart
/// HeroAvatar(
///   children: <Widget>[
///     HeroAvatarImage(image: NetworkImage(url), semanticLabel: 'Jane Doe'),
///     const HeroAvatarFallback(child: Text('JD')),
///   ],
/// )
/// ```
///
/// The fallback shows until the image has loaded, and stays when it fails;
/// the image then fades in. [size], [color] and [variant] fall back to the
/// enclosing [HeroAvatarScope] (set by an avatar group), then to `md`,
/// `standard` and `standard`.
class HeroAvatar extends StatefulWidget {
  /// Creates an avatar.
  const HeroAvatar({
    super.key,
    this.image,
    this.src,
    this.name,
    this.fallback,
    this.fallbackDelay,
    this.semanticLabel,
    this.children = const <Widget>[],
    this.size,
    this.color,
    this.variant,
    this.radius,
  });

  /// The image to show; see also [src].
  final ImageProvider? image;

  /// URL of a network image, used when [image] is null.
  final String? src;

  /// The person's name: its initials are the default fallback and it is
  /// the default accessibility label.
  final String? name;

  /// Fallback content, usually initials or an icon; defaults to the
  /// initials of [name].
  final Widget? fallback;

  /// Delay before the fallback appears (`delayMs`), to avoid a flash for
  /// images that load quickly.
  final Duration? fallbackDelay;

  /// Accessibility label of the image (`alt`); defaults to [name].
  final String? semanticLabel;

  /// Parts ([HeroAvatarImage], [HeroAvatarFallback]); when not empty they
  /// replace the shorthand parameters.
  final List<Widget> children;

  /// Size; see the class documentation for the default.
  final HeroSize? size;

  /// Color role of the fallback.
  final HeroColor? color;

  /// Visual variant.
  final HeroAvatarVariant? variant;

  /// Overrides the corner radius (`rounded-2xl` for `sm`, `rounded-3xl`
  /// otherwise, which makes circles with the default `--radius`).
  final double? radius;

  /// Returns the initials of [name]: the first letters of its first and
  /// last words, uppercased.
  static String initialsOf(String name) {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    final String first = String.fromCharCode(words.first.runes.first);
    if (words.length == 1) return first.toUpperCase();
    final String last = String.fromCharCode(words.last.runes.first);
    return '$first$last'.toUpperCase();
  }

  /// The side length of an avatar of [size] in [theme] (`--avatar-size`).
  static double dimensionOf(HeroThemeData theme, HeroSize size) =>
      switch (size) {
        HeroSize.sm => theme.spacing(8),
        HeroSize.md => theme.spacing(10),
        HeroSize.lg => theme.spacing(12),
      };

  @override
  State<HeroAvatar> createState() => _HeroAvatarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('name', name, defaultValue: null))
      ..add(EnumProperty<HeroSize>('size', size, defaultValue: null))
      ..add(EnumProperty<HeroColor>('color', color, defaultValue: null))
      ..add(
        EnumProperty<HeroAvatarVariant>('variant', variant, defaultValue: null),
      );
  }
}

class _HeroAvatarState extends State<HeroAvatar> {
  final ValueNotifier<HeroAvatarLoadingStatus> _status =
      ValueNotifier<HeroAvatarLoadingStatus>(HeroAvatarLoadingStatus.idle);

  @override
  void dispose() {
    _status.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroAvatarScope? scope = HeroAvatarScope.maybeOf(context);
    final HeroSize size = widget.size ?? scope?.size ?? HeroSize.md;
    final HeroColor color = widget.color ?? scope?.color ?? HeroColor.standard;
    final HeroAvatarVariant variant =
        widget.variant ?? scope?.variant ?? HeroAvatarVariant.standard;
    final double dimension = HeroAvatar.dimensionOf(theme, size);
    final double radius =
        widget.radius ??
        (size == HeroSize.sm ? theme.radii.xl2 : theme.radii.xl3);
    final OutlinedBorder shape = theme.shapeAll(radius);

    final ImageProvider? image =
        widget.image ?? (widget.src != null ? NetworkImage(widget.src!) : null);
    final List<Widget> parts = widget.children.isNotEmpty
        ? widget.children
        : <Widget>[
            if (image != null)
              HeroAvatarImage(
                image: image,
                semanticLabel: widget.semanticLabel ?? widget.name,
              ),
            HeroAvatarFallback(
              delay: widget.fallbackDelay,
              semanticsLabel: widget.name,
              child:
                  widget.fallback ??
                  (widget.name != null
                      ? Text(HeroAvatar.initialsOf(widget.name!))
                      : null),
            ),
          ];

    return _HeroAvatarData(
      size: size,
      color: color,
      variant: variant,
      dimension: dimension,
      fallbackPadding: scope?.fallbackPadding,
      status: _status,
      child: Semantics(
        container: true,
        child: SizedBox.square(
          dimension: dimension,
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: shape,
              textDirection: Directionality.maybeOf(context),
            ),
            child: ColoredBox(
              color: variant == HeroAvatarVariant.soft
                  ? const Color(0x00000000)
                  : theme.colors.defaultColor,
              child: Stack(fit: StackFit.expand, children: parts),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroAvatarData extends InheritedWidget {
  const _HeroAvatarData({
    required this.size,
    required this.color,
    required this.variant,
    required this.dimension,
    required this.fallbackPadding,
    required this.status,
    required super.child,
  });

  final HeroSize size;
  final HeroColor color;
  final HeroAvatarVariant variant;
  final double dimension;
  final EdgeInsetsGeometry? fallbackPadding;
  final ValueNotifier<HeroAvatarLoadingStatus> status;

  static _HeroAvatarData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HeroAvatarData>();

  @override
  bool updateShouldNotify(_HeroAvatarData oldWidget) =>
      size != oldWidget.size ||
      color != oldWidget.color ||
      variant != oldWidget.variant ||
      dimension != oldWidget.dimension ||
      fallbackPadding != oldWidget.fallbackPadding ||
      status != oldWidget.status;
}

/// Signature of [HeroAvatarImage.builder].
typedef HeroAvatarImageBuilder =
    Widget Function(BuildContext context, ImageProvider image);

/// The image of a [HeroAvatar] (HeroUI `Avatar.Image`).
///
/// It loads [image], reports the loading status to the avatar so the
/// [HeroAvatarFallback] can hide, and only paints once the image is ready,
/// fading in over 250 ms. The image covers the avatar ([BoxFit.cover]).
class HeroAvatarImage extends StatefulWidget {
  /// Creates an avatar image.
  const HeroAvatarImage({
    super.key,
    required this.image,
    this.semanticLabel,
    this.builder,
    this.onLoad,
    this.onError,
  });

  /// Creates an avatar image from a network URL.
  HeroAvatarImage.network(
    String src, {
    super.key,
    this.semanticLabel,
    this.builder,
    this.onLoad,
    this.onError,
  }) : image = NetworkImage(src);

  /// The image to load.
  final ImageProvider image;

  /// Accessibility label (`alt`).
  final String? semanticLabel;

  /// Renders the loaded image with a custom widget (`asChild`), for example
  /// a cached network image. The avatar still tracks [image] to know when
  /// it is ready.
  final HeroAvatarImageBuilder? builder;

  /// Called when the image has loaded.
  final VoidCallback? onLoad;

  /// Called when the image fails to load.
  final ImageErrorListener? onError;

  @override
  State<HeroAvatarImage> createState() => _HeroAvatarImageState();
}

class _HeroAvatarImageState extends State<HeroAvatarImage> {
  ImageStream? _stream;
  ImageInfo? _info;
  bool _resolving = false;
  bool _fadeIn = false;
  bool _failed = false;
  _HeroAvatarData? _data;
  late final ImageStreamListener _listener = ImageStreamListener(
    _handleImage,
    onError: _handleError,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _data = _HeroAvatarData.maybeOf(context);
    _resolve();
  }

  @override
  void didUpdateWidget(HeroAvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) _resolve();
  }

  void _setStatus(HeroAvatarLoadingStatus status) {
    _data?.status.value = status;
  }

  void _resolve() {
    final double dimension =
        _data?.dimension ??
        HeroAvatar.dimensionOf(HeroTheme.of(context), HeroSize.md);
    final ImageStream stream = widget.image.resolve(
      createLocalImageConfiguration(context, size: Size.square(dimension)),
    );
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _replaceInfo(null);
    _failed = false;
    _stream = stream;
    _setStatus(HeroAvatarLoadingStatus.loading);
    _resolving = true;
    stream.addListener(_listener);
    _resolving = false;
  }

  void _replaceInfo(ImageInfo? info) {
    final ImageInfo? old = _info;
    _info = info;
    old?.dispose();
  }

  void _handleImage(ImageInfo info, bool synchronousCall) {
    final bool first = _info == null;
    void update() {
      _replaceInfo(info);
      _failed = false;
      // Images that are already cached appear immediately, like an image
      // the browser has in memory; others fade in.
      if (first) _fadeIn = !(synchronousCall || _resolving);
    }

    if (_resolving || !mounted) {
      update();
    } else {
      setState(update);
    }
    _setStatus(HeroAvatarLoadingStatus.loaded);
    if (first) widget.onLoad?.call();
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    if (_resolving || !mounted) {
      _failed = true;
    } else {
      setState(() => _failed = true);
    }
    _setStatus(HeroAvatarLoadingStatus.error);
    widget.onError?.call(error, stackTrace);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _replaceInfo(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ImageInfo? info = _info;
    if (info == null || _failed) return const SizedBox.shrink();
    final HeroThemeData theme = HeroTheme.of(context);
    Widget result =
        widget.builder?.call(context, widget.image) ??
        RawImage(
          image: info.image,
          scale: info.scale,
          fit: BoxFit.cover,
          debugImageLabel: info.debugLabel,
        );
    result = Semantics(
      image: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: result,
    );
    if (!_fadeIn) return result;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: theme.motion.resolve(context, HeroMotion.slow),
      curve: HeroMotion.easeInOut,
      builder: (BuildContext context, double opacity, Widget? child) =>
          Opacity(opacity: opacity, child: child),
      child: result,
    );
  }
}

/// The fallback of a [HeroAvatar] (HeroUI `Avatar.Fallback`): initials,
/// an icon or any widget, shown while the image is missing, loading or
/// failed.
///
/// Text is 14 px medium (12 px for `sm`, 16 px for `lg`) in the role's soft
/// foreground; icons take the same color.
class HeroAvatarFallback extends StatefulWidget {
  /// Creates a fallback.
  const HeroAvatarFallback({
    super.key,
    this.child,
    this.delay,
    this.color,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.semanticsLabel,
  });

  /// The fallback content, usually a [Text] or a [HeroIcon].
  final Widget? child;

  /// Delay before the fallback appears (`delayMs`).
  final Duration? delay;

  /// Overrides the avatar's color role.
  final HeroColor? color;

  /// Overrides the fill.
  final Color? backgroundColor;

  /// Overrides the text and icon color.
  final Color? foregroundColor;

  /// Paints a gradient instead of the fill.
  final Gradient? gradient;

  /// Accessibility label replacing the fallback's own text (for example the
  /// full name behind initials).
  final String? semanticsLabel;

  @override
  State<HeroAvatarFallback> createState() => _HeroAvatarFallbackState();
}

class _HeroAvatarFallbackState extends State<HeroAvatarFallback> {
  Timer? _timer;
  bool _ready = true;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(HeroAvatarFallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delay != widget.delay) _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    final Duration? delay = widget.delay;
    if (delay == null || delay <= Duration.zero) {
      _ready = true;
      return;
    }
    _ready = false;
    _timer = Timer(delay, () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _HeroAvatarData? data = _HeroAvatarData.maybeOf(context);
    if (data == null) return _buildContent(context, null);
    return ValueListenableBuilder<HeroAvatarLoadingStatus>(
      valueListenable: data.status,
      builder: (BuildContext context, HeroAvatarLoadingStatus status, _) {
        if (status == HeroAvatarLoadingStatus.loaded || !_ready) {
          return const SizedBox.shrink();
        }
        return _buildContent(context, data);
      },
    );
  }

  Widget _buildContent(BuildContext context, _HeroAvatarData? data) {
    final HeroThemeData theme = HeroTheme.of(context);
    final HeroSize size = data?.size ?? HeroSize.md;
    final HeroColor color = widget.color ?? data?.color ?? HeroColor.standard;
    final HeroAvatarVariant variant =
        data?.variant ?? HeroAvatarVariant.standard;
    final HeroColorRole role = theme.colors.role(color);
    final Color background =
        widget.backgroundColor ??
        (variant == HeroAvatarVariant.soft
            ? role.soft
            : theme.colors.defaultColor);
    final Color foreground = widget.foregroundColor ?? role.softForeground;
    final HeroFontSize font = switch (size) {
      HeroSize.sm => HeroFontSize.xs,
      HeroSize.md => HeroFontSize.sm,
      HeroSize.lg => HeroFontSize.base,
    };
    Widget content = DefaultTextStyle(
      style: theme.typography
          .style(font, weight: HeroTypography.medium)
          .copyWith(color: foreground),
      textAlign: TextAlign.center,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
      child: IconTheme.merge(
        data: IconThemeData(color: foreground, size: theme.spacing(4)),
        child: widget.child ?? const SizedBox.shrink(),
      ),
    );
    if (widget.semanticsLabel != null) {
      content = Semantics(
        label: widget.semanticsLabel,
        excludeSemantics: true,
        child: content,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.gradient == null ? background : null,
        gradient: widget.gradient,
      ),
      child: Padding(
        padding: data?.fallbackPadding ?? EdgeInsets.zero,
        child: Center(child: content),
      ),
    );
  }
}
