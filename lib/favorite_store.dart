import 'package:flutter/foundation.dart';

class FavoriteStore {
  static final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

  static bool isFavorite(String id) => favorites.value.contains(id);

  static void toggle(String id) {
    final updated = Set<String>.from(favorites.value);
    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    favorites.value = updated;
  }
}
