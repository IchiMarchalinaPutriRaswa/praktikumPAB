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

    final fitCategories = <String>{
      if (FitMatchStore.getMeasurements('atasan').isNotEmpty ||
          FitMatchStore.getBodyMeasurements('atasan').isNotEmpty)
        'atasan',
      if (FitMatchStore.getMeasurements('bawahan').isNotEmpty ||
          FitMatchStore.getBodyMeasurements('bawahan').isNotEmpty)
        'bawahan',
    };

    if (favorites.isEmpty && purchased.isEmpty &&
        rated.isEmpty && fitCategories.isEmpty) return [];

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

    for (final name in favorites) {
      addScore(name, 30);
    }
    for (final name in purchased) {
      addScore(name, 25);
    }
    for (final entry in ratings.entries) {
      if (entry.value.isEmpty) continue;
      final avg = entry.value.reduce((a, b) => a + b) /
          entry.value.length;
      addScore(entry.key, avg >= 4 ? 20 : avg >= 3 ? 8 : -15);
    }

    final interactionCategories = categoryScores.entries
        .where((e) => e.value > 0)
        .map((e) => e.key).toSet();

    final preferredCategories = {
      ...interactionCategories,
      ...fitCategories,
    };

    if (preferredCategories.isEmpty) return [];

    var candidates = products.where((p) {
      if (favorites.contains(p.name) ||
          purchased.contains(p.name) ||
          rated.contains(p.name)) return false;

      final category = _category(p);
      if (!preferredCategories.contains(category)) return false;

      if (fitCategories.contains(category) &&
          !interactionCategories.contains(category) &&
          !_hasFitData(p)) return false;

      return true;
    }).toList();

    candidates = candidates.where((p) =>
        _score(p, categoryScores) > 0).toList();

    candidates.sort((a, b) =>
        _score(b, categoryScores).compareTo(
          _score(a, categoryScores),
        ));

    return candidates.take(limit).toList();
  }

  static String _category(ProductItem p) {
    final category = p.category.trim().toLowerCase();

    if (['celana', 'rok', 'bawahan'].contains(category)) {
      return 'bawahan';
    }

    if (['atasan', 'outerwear', 'dress'].contains(category)) {
      return 'atasan';
    }

    final text = '${p.name} ${p.description}'.toLowerCase();

    if (_has(text, [
      'jeans', 'celana', 'rok', 'skirt',
      'pants', 'trouser', 'shorts',
    ])) {
      return 'bawahan';
    }

    if (_has(text, [
      'jacket', 'hoodie', 'cardigan', 'outer',
      'jaket', 'blazer', 'vest', 'sweater',
      'blouse', 'shirt', 'kemeja', 'kaos',
      'knit', 'dress', 'gaun',
    ])) {
      return 'atasan';
    }

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
    final category = _category(p);
    final values = {
      ...FitMatchStore.getMeasurements(category),
      ...FitMatchStore.getBodyMeasurements(category),
    };
    final sizes = _productSizes(p);
    return values.keys.any((key) => sizes[key] != null);
  }

  static int _score(ProductItem p, Map<String, int> categories) =>
      (categories[_category(p)] ?? 0) + _fitScore(p);

  static int _fitScore(ProductItem p) {
    final category = _category(p);
    final scores = <double>[];
    final measurements = FitMatchStore.getMeasurements(category);
    final body = FitMatchStore.getBodyMeasurements(category);

    if (measurements.isNotEmpty) {
      scores.add(_compare(p, measurements, false));
    }
    if (body.isNotEmpty) {
      scores.add(_compare(p, body, true));
    }

    return scores.isEmpty
        ? 0
        : (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  static double _compare(
    ProductItem p, Map<String, double> values, bool bodyMode,
  ) {
    final bottom = _category(p) == 'bawahan';
    final sizes = _productSizes(p);
    final limits = bottom
        ? {'waist': 3.0, 'length': 3.0}
        : {
            'chest': 4.0, 'length': 3.0,
            'shoulder': 2.0, 'sleeve': 3.0,
          };

    double matched = 0;
    int count = 0;

    values.forEach((key, user) {
      final product = sizes[key];
      if (product == null || limits[key] == null) return;

      count++;
      final diff = product - user;
      final limit = limits[key]!;

      if (!bodyMode) {
        if (diff.abs() <= limit) matched++;
        else if (diff.abs() <= limit * 2) matched += 0.5;
      } else if (key == 'chest') {
        if (diff >= 4 && diff <= 12) matched++;
        else if (diff >= 0 && diff <= 16) matched += 0.5;
      } else if (key == 'waist') {
        if (diff >= 2 && diff <= 8) matched++;
        else if (diff >= 0 && diff <= 12) matched += 0.5;
      } else {
        if (diff >= -2 && diff <= 4) matched++;
        else if (diff >= -4 && diff <= 6) matched += 0.5;
      }
    });

    return count == 0 ? 0 : matched / count * 25;
  }
}
