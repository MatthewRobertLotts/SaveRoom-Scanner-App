import '../services/saveroom_api_client.dart';

/// In-memory session storage for recently viewed cards.
/// Max 5 items, most recent at the front.
class RecentlyViewed {
  static const _maxItems = 5;

  static final List<SearchResult> _recent = [];

  static List<SearchResult> get recent => List.unmodifiable(_recent);

  static void add(SearchResult item) {
    _recent.removeWhere((i) => i.cardKey == item.cardKey);
    _recent.insert(0, item);
    if (_recent.length > _maxItems) {
      _recent.removeLast();
    }
  }

  static void clear() => _recent.clear();
}
