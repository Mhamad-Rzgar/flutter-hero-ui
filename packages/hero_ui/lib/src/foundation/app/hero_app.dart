import 'package:flutter/cupertino.dart'
    show CupertinoPageRoute, DefaultCupertinoLocalizations;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter/widgets.dart';

import '../theme/hero_theme.dart';
import '../theme/hero_theme_data.dart';
import '../theme/hero_theme_presets.dart';

/// Which brightness a [HeroApp] uses.
enum HeroThemeMode {
  /// Follow the platform setting.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// A page route with iOS push/pop transitions and back-swipe, whose page is
/// painted with the theme's `background` token so the transition's dimming
/// barrier never shows through.
class HeroPageRoute<T> extends CupertinoPageRoute<T> {
  /// Creates a page route.
  HeroPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.barrierDismissible,
  });

  @override
  Widget buildContent(BuildContext context) => ColoredBox(
    color: HeroTheme.of(context).colors.background,
    child: super.buildContent(context),
  );
}

/// The iOS-style scroll behaviour used across hero_ui: bouncing physics on
/// every platform, no Material overscroll glow, and a thin themed scrollbar
/// on desktop platforms.
class HeroScrollBehavior extends ScrollBehavior {
  /// Creates the scroll behaviour.
  const HeroScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return RawScrollbar(
          controller: details.controller,
          thumbColor: HeroTheme.of(context).colors.scrollbar,
          thickness: 6,
          radius: const Radius.circular(3),
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
  };
}

/// An application shell for hero_ui apps, the counterpart of HeroUI's
/// provider.
///
/// [HeroApp] builds on [WidgetsApp] so that no Material or Cupertino
/// styling leaks into the UI. It provides the [HeroTheme] (animating between
/// [theme] and [darkTheme] according to [themeMode]), a default text style
/// and icon theme from the theme tokens, iOS page transitions and
/// [HeroScrollBehavior].
///
/// Apps that already use `MaterialApp` can instead add a [HeroThemeData] to
/// `ThemeData.extensions` or wrap their tree in a [HeroTheme].
class HeroApp extends StatelessWidget {
  /// Creates an app that uses a [Navigator].
  const HeroApp({
    super.key,
    this.navigatorKey,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.title = '',
    this.theme,
    this.darkTheme,
    this.themeMode = HeroThemeMode.system,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
  }) : routerConfig = null;

  /// Creates an app that uses a [Router].
  const HeroApp.router({
    super.key,
    required RouterConfig<Object> this.routerConfig,
    this.builder,
    this.title = '',
    this.theme,
    this.darkTheme,
    this.themeMode = HeroThemeMode.system,
    this.locale,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
  }) : navigatorKey = null,
       home = null,
       routes = const <String, WidgetBuilder>{},
       initialRoute = null,
       onGenerateRoute = null,
       onUnknownRoute = null,
       navigatorObservers = const <NavigatorObserver>[];

  /// Key of the root navigator.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The home route.
  final Widget? home;

  /// Named routes.
  final Map<String, WidgetBuilder> routes;

  /// Initial route name.
  final String? initialRoute;

  /// Route factory.
  final RouteFactory? onGenerateRoute;

  /// Unknown route factory.
  final RouteFactory? onUnknownRoute;

  /// Navigator observers.
  final List<NavigatorObserver> navigatorObservers;

  /// Router configuration for [HeroApp.router].
  final RouterConfig<Object>? routerConfig;

  /// Wraps the navigator, e.g. to add global overlays.
  final TransitionBuilder? builder;

  /// App title.
  final String title;

  /// Light theme; defaults to [HeroThemeData.light].
  final HeroThemeData? theme;

  /// Dark theme; defaults to [HeroThemeData.dark].
  final HeroThemeData? darkTheme;

  /// Which theme to use.
  final HeroThemeMode themeMode;

  /// App locale.
  final Locale? locale;

  /// Extra localization delegates.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Supported locales.
  final Iterable<Locale> supportedLocales;

  /// Whether to show the debug banner.
  final bool debugShowCheckedModeBanner;

  /// App-wide shortcuts.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// App-wide actions.
  final Map<Type, Action<Intent>>? actions;

  HeroThemeData _resolveTheme(BuildContext context) {
    final Brightness platform =
        MediaQuery.maybePlatformBrightnessOf(context) ?? Brightness.light;
    final bool dark = switch (themeMode) {
      HeroThemeMode.system => platform == Brightness.dark,
      HeroThemeMode.light => false,
      HeroThemeMode.dark => true,
    };
    if (dark) {
      return darkTheme ??
          HeroThemeData.dark(preset: theme?.preset ?? HeroThemePreset.standard);
    }
    return theme ?? HeroThemeData.light();
  }

  Widget _wrap(BuildContext context, Widget? child) {
    final HeroThemeData data = _resolveTheme(context);
    return AnimatedHeroTheme(
      data: data,
      child: Builder(
        builder: (BuildContext context) {
          final HeroThemeData theme = HeroTheme.of(context);
          Widget result = child ?? const SizedBox.shrink();
          if (builder != null) result = builder!(context, result);
          return ScrollConfiguration(
            behavior: const HeroScrollBehavior(),
            child: DefaultTextStyle(
              style: theme.typography.base.copyWith(
                color: theme.colors.foreground,
              ),
              child: IconTheme(
                data: IconThemeData(color: theme.colors.foreground, size: 16),
                child: ColoredBox(
                  color: theme.colors.background,
                  child: result,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static PageRoute<T> _pageRoute<T>(
    RouteSettings settings,
    WidgetBuilder builder,
  ) => HeroPageRoute<T>(settings: settings, builder: builder);

  Iterable<LocalizationsDelegate<dynamic>> get _delegates =>
      <LocalizationsDelegate<dynamic>>[
        ...?localizationsDelegates,
        DefaultWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ];

  @override
  Widget build(BuildContext context) {
    final Color color = (theme ?? HeroThemeData.light()).colors.accent;
    if (routerConfig != null) {
      return WidgetsApp.router(
        routerConfig: routerConfig,
        builder: _wrap,
        title: title,
        color: color,
        locale: locale,
        localizationsDelegates: _delegates,
        supportedLocales: supportedLocales,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        shortcuts: shortcuts,
        actions: actions,
      );
    }
    return WidgetsApp(
      navigatorKey: navigatorKey,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      navigatorObservers: navigatorObservers,
      pageRouteBuilder: _pageRoute,
      builder: _wrap,
      title: title,
      color: color,
      locale: locale,
      localizationsDelegates: _delegates,
      supportedLocales: supportedLocales,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      shortcuts: shortcuts,
      actions: actions,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HeroThemeMode>('themeMode', themeMode));
  }
}
