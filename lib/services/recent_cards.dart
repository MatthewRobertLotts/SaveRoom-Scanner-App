import 'package:flutter/foundation.dart';
import 'saveroom_api_client.dart';

/// In-memory session storage for recently viewed cards.
/// Max 5 items, most recent at the front, notifies listeners on change.
class RecentlyViewed extends ValueNotifier<List<SearchResult>> {
  RecentlyViewed._() : super(const []);

  static final RecentlyViewed _instance = RecentlyViewed._();

  static RecentlyViewed get instance => _instance;

  static List<SearchResult> get recent => instance.value;

  static const _maxItems = 5;

  static void add(SearchResult item) {
    final current = List<SearchResult>.from(instance.value);
    current.removeWhere((i) => i.cardKey == item.cardKey);
    current.insert(0, item);
    if (current.length > _maxItems) {
      current.removeLast();
    }
    instance.value = current;
  }

  static void clear() => instance.value = const [];
}