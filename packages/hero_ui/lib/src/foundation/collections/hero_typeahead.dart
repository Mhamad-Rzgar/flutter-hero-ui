import 'dart:async';

/// One searchable entry of a collection for [HeroTypeahead]: an item key and
/// its text value.
typedef HeroTypeaheadEntry = ({Object key, String text, bool isDisabled});

/// Type-to-select for collections, React Aria's `useTypeSelect`.
///
/// Every typed character is appended to a search string that resets after
/// [timeout] without typing. [search] returns the first enabled entry whose
/// text starts with the search string (ignoring case), looking from the
/// focused entry onwards and then from the start.
///
/// ```dart
/// final HeroTypeahead typeahead = HeroTypeahead();
/// final Object? key = typeahead.search('b', entries, from: focusedKey);
/// ```
///
/// Call [dispose] when done to cancel the reset timer.
class HeroTypeahead {
  /// Creates a typeahead with the given reset [timeout].
  HeroTypeahead({this.timeout = const Duration(milliseconds: 1000)});

  /// Time without typing after which the search string starts over.
  final Duration timeout;

  String _buffer = '';
  Timer? _timer;

  /// The current search string.
  String get buffer => _buffer;

  /// Whether a search is in progress, in which case Space is part of the
  /// search rather than a selection key.
  bool get isActive => _buffer.isNotEmpty;

  /// Appends [character] to the search string and returns the key of the
  /// matching entry of [entries], or null when nothing matches.
  Object? search(
    String character,
    List<HeroTypeaheadEntry> entries, {
    Object? from,
  }) {
    _buffer += character;
    _timer?.cancel();
    _timer = Timer(timeout, reset);
    final String query = _buffer.toLowerCase();
    int start = 0;
    if (from != null) {
      final int index = entries.indexWhere(
        (HeroTypeaheadEntry e) => e.key == from,
      );
      if (index >= 0) start = index;
    }
    for (int i = 0; i < entries.length; i++) {
      final HeroTypeaheadEntry entry = entries[(start + i) % entries.length];
      if (!entry.isDisabled && entry.text.toLowerCase().startsWith(query)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Clears the search string.
  void reset() {
    _timer?.cancel();
    _timer = null;
    _buffer = '';
  }

  /// Cancels the reset timer.
  void dispose() => reset();
}
