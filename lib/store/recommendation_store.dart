import '../store/product_store.dart';
import '../store/favorite_store.dart';
import '../store/order_store.dart';
import '../store/fit_match_store.dart';

class RecommendationStore {
  static List<ProductItem> getRecommendations({int limit = 4}) {
    if (limit <= 0) return [];

    final products = ProductStore.items.value;
    final favorites = FavoriteStore.favorites.value;
    final ratings = OrderStore.ratings.value;
    final purchased = <String>{};

    for (final order in OrderStore.orders.value) {
      final items = order['items'];
      if (items is List) {
        for (final item in items) {
          if (item is Map && item['name'] != null) {
            purchased.add(item['name'].toString());
          }
        }
      }
    }

    final rated = ratings.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => e.key).toSet();

    final hasFit = FitMatchStore.measurements.isNotEmpty ||
        FitMatchStore.bodyMeasurements.isNotEmpty;

    if (favorites.isEmpty && purchased.isEmpty &&
        rated.isEmpty && !hasFit) return [];

    final categoryScores = <String, int>{};

    ProductItem? findProduct(String name) {
      for (final p in products) {
        if (p.name == name) return p;
      }
      return null;
    }

    void addScore(String name, int points) {
      final p = findProduct(name);
      if (p == null) return;
      final category = _category(p);
      if (category == 'lainnya') return;
      categoryScores[category] =
          (categoryScores[category] ?? 0) + points;
    }

    // 1. Preferensi dari favorit
    for (final name in favorites) {
      addScore(name, 30);
    }

    // 2. Preferensi dari riwayat pembelian
    for (final name in purchased) {
      addScore(name, 25);
    }

    // 3. Preferensi dari rating
    for (final entry in ratings.entries) {
      if (entry.value.isEmpty) continue;
      final avg = entry.value.reduce((a, b) => a + b) /
          entry.value.length;
      addScore(entry.key, avg >= 4 ? 20 : avg >= 3 ? 8 : -15);
    }

    // Menghindari produk yang sudah pernah dipilih pengguna
    var candidates = products.where((p) =>
        !favorites.contains(p.name) &&
        !purchased.contains(p.name) &&
        !rated.contains(p.name)).toList();

    // 4. Menentukan kategori yang disukai
    final preferredCategories = categoryScores.entries
        .where((e) => e.value > 0)
        .map((e) => e.key).toSet();

    if (preferredCategories.isNotEmpty) {
      candidates = candidates.where((p) =>
          preferredCategories.contains(_category(p))).toList();
    } else if (hasFit) {
      candidates = candidates.where(_hasFitData).toList();
    } else {
      return [];
    }

    // Hanya menampilkan produk dengan skor positif
    candidates = candidates.where((p) =>
        _score(p, categoryScores) > 0).toList();

    if (candidates.isEmpty) return [];

    // Mengurutkan berdasarkan skor tertinggi
    candidates.sort((a, b) =>
        _score(b, categoryScores).compareTo(
            _score(a, categoryScores)));

    return candidates.take(limit).toList();
  }

  static String _category(ProductItem p) {
    final text = '${p.name} ${p.description}'.toLowerCase();

    if (_has(text, ['jeans', 'celana', 'rok', 'skirt', 'pants'])) {
      return 'bawahan';
    }
    if (_has(text, ['jacket', 'hoodie', 'cardigan',
        'outer', 'jaket', 'blazer'])) {
      return 'outerwear';
    }
    if (_has(text, ['sweater', 'blouse', 'shirt',
        'kemeja', 'kaos', 'knit'])) {
      return 'atasan';
    }
    if (_has(text, ['dress', 'gaun'])) return 'dress';
    return 'lainnya';
  }

  static bool _has(String text, List<String> words) =>
      words.any((word) => text.contains(word));

  static bool _hasFitData(ProductItem p) {
    final sizes = {
      'chest': p.chestCm, 'length': p.lengthCm,
      'shoulder': p.shoulderCm, 'sleeve': p.sleeveCm,
    };
    final keys = {
      ...FitMatchStore.measurements.keys,
      ...FitMatchStore.bodyMeasurements.keys,
    };
    return keys.any((key) => sizes[key] != null);
  }

  static int _score(ProductItem p, Map<String, int> categories) {
    return (categories[_category(p)] ?? 0) + _fitScore(p);
  }

  static int _fitScore(ProductItem p) {
    final scores = <double>[];

    if (FitMatchStore.measurements.isNotEmpty) {
      scores.add(_compare(p, FitMatchStore.measurements, false));
    }
    if (FitMatchStore.bodyMeasurements.isNotEmpty) {
      scores.add(_compare(p, FitMatchStore.bodyMeasurements, true));
    }

    if (scores.isEmpty) return 0;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  static double _compare(ProductItem p, Map<String, double> values,
      bool bodyMode) {
    final sizes = {
      'chest': p.chestCm, 'length': p.lengthCm,
      'shoulder': p.shoulderCm, 'sleeve': p.sleeveCm,
    };
    const limits = {
      'chest': 4.0, 'length': 3.0,
      'shoulder': 2.0, 'sleeve': 3.0,
    };

    double matched = 0;
    int count = 0;

    values.forEach((key, user) {
      final size = sizes[key];
      if (size == null) return;
      count++;
      final diff = size - user;

      if (!bodyMode) {
        if (diff.abs() <= limits[key]!) matched++;
        else if (diff.abs() <= limits[key]! * 2) matched += 0.5;
      } else if (key == 'chest') {
        if (diff >= 4 && diff <= 12) matched++;
        else if (diff >= 0 && diff <= 16) matched += 0.5;
      } else {
        if (diff >= -2 && diff <= 4) matched++;
        else if (diff >= -4 && diff <= 6) matched += 0.5;
      }
    });

    return count == 0 ? 0 : matched / count * 25;
  }
}
