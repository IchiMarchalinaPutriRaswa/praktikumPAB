import '../store/product_store.dart';
import '../store/favorite_store.dart';
import '../store/order_store.dart';
import '../store/fit_match_store.dart';

class RecommendationStore {
  static List<ProductItem> getRecommendations({int limit = 4}) {
    if (limit <= 0) return [];

    final products = ProductStore.items.value;
    final favorites = FavoriteStore.favorites.value;
    final ratings = OrderStore.userRatings.value;
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

    final topFit = FitMatchStore.getMeasurements('atasan');
    final bottomFit = FitMatchStore.getMeasurements('bawahan');

    final fitCategories = <String>{
      if (topFit.isNotEmpty) 'atasan',
      if (bottomFit.isNotEmpty) 'bawahan',
    };

    final categoryScores = <String, int>{};

    void addScore(String name, int points) {
      for (final p in products) {
        if (p.name != name) continue;
        final category = _category(p);
        if (category == 'lainnya') return;
        categoryScores[category] =
            (categoryScores[category] ?? 0) + points;
        return;
      }
    }

    // Preferensi dari produk favorit.
    for (final name in favorites) {
      addScore(name, 30);
    }

    // Preferensi dari riwayat pembelian.
    for (final name in purchased) {
      addScore(name, 25);
    }

    // Preferensi dari rating yang diberikan pengguna.
    for (final entry in ratings.entries) {
      if (entry.value.isEmpty) continue;
      final avg = entry.value.reduce((a, b) => a + b) /
          entry.value.length;
      addScore(entry.key, avg >= 4 ? 20 : avg >= 3 ? 8 : -15);
    }

    final preferredCategories = <String>{
      ...categoryScores.entries
          .where((e) => e.value > 0)
          .map((e) => e.key),
      ...fitCategories,
    };

    if (preferredCategories.isEmpty) return [];

    final candidates = products.where((p) {
      if (favorites.contains(p.name) ||
          purchased.contains(p.name) ||
          rated.contains(p.name)) return false;

      final category = _category(p);
      if (!preferredCategories.contains(category)) return false;

      final hasPreference = (categoryScores[category] ?? 0) > 0;
      final hasFit = fitCategories.contains(category) &&
          _hasFitData(p);

      return hasPreference || hasFit;
    }).where((p) => _score(p, categoryScores) > 0).toList();

    candidates.sort((a, b) {
      final result = _score(b, categoryScores).compareTo(
        _score(a, categoryScores),
      );
      return result != 0 ? result : a.name.compareTo(b.name);
    });

    return candidates.take(limit).toList();
  }

  static String _category(ProductItem p) {
    final text = '${p.name} ${p.description}'.toLowerCase();

    if (_has(text, ['jeans', 'celana', 'rok', 'skirt', 'pants'])) {
      return 'bawahan';
    }

    if (_has(text, [
      'jacket', 'hoodie', 'cardigan', 'outer', 'jaket',
      'blazer', 'vest', 'sweater', 'blouse', 'shirt',
      'kemeja', 'kaos', 'knit', 'dress', 'gaun',
    ])) return 'atasan';

    return 'lainnya';
  }

  static bool _has(String text, List<String> words) =>
      words.any((word) => text.contains(word));

  static Map<String, double?> _productSizes(ProductItem p) =>
      _category(p) == 'bawahan'
          ? {'waist': p.waistCm, 'length': p.lengthCm}
          : {
              'chest': p.chestCm,
              'length': p.lengthCm,
              'shoulder': p.shoulderCm,
              'sleeve': p.sleeveCm,
            };

  static bool _hasFitData(ProductItem p) {
    final values = FitMatchStore.getMeasurements(_category(p));
    final sizes = _productSizes(p);
    return values.keys.any((key) => sizes[key] != null);
  }

  static int _score(ProductItem p, Map<String, int> categories) =>
      (categories[_category(p)] ?? 0) + _fitScore(p);

  static int _fitScore(ProductItem p) {
    final values = FitMatchStore.getMeasurements(_category(p));
    if (values.isEmpty) return 0;

    final sizes = _productSizes(p);
    final limits = _category(p) == 'bawahan'
        ? {'waist': 3.0, 'length': 3.0}
        : {
            'chest': 4.0, 'length': 3.0,
            'shoulder': 2.0, 'sleeve': 3.0,
          };

    double matched = 0;
    int count = 0;

    values.forEach((key, user) {
      final product = sizes[key];
      if (product == null) return;

      count++;
      final diff = (product - user).abs();
      final limit = limits[key]!;

      if (diff <= limit) {
        matched++;
      } else if (diff <= limit * 2) {
        matched += 0.5;
      }
    });

    return count == 0 ? 0 : (matched / count * 25).round();
  }
}
