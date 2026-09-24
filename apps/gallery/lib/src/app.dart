import 'package:flutter/widgets.dart';
import 'package:hero_ui/hero_ui.dart';

import 'gallery_state.dart';
import 'pages/home_page.dart';

/// The hero_ui gallery application.
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key, this.state});

  /// Optional externally owned state (used by tests).
  final GalleryState? state;

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late final GalleryState _state = widget.state ?? GalleryState();

  @override
  void dispose() {
    if (widget.state == null) _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GalleryScope(
      state: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (BuildContext context, _) {
          return HeroApp(
            title: 'HeroUI for Flutter',
            debugShowCheckedModeBanner: false,
            theme: _state.theme.light(),
            darkTheme: _state.theme.dark(),
            themeMode: _state.mode,
            builder: (BuildContext context, Widget? child) =>
                Directionality(textDirection: _state.direction, child: child!),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
