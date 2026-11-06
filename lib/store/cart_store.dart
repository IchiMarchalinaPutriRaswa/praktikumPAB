import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class CartStore {
  static final ValueNotifier<List<Map<String, dynamic>>> items = ValueNotifier([]);

  static void add(String name, String price, String image, {
    Uint8List? imageBytes, String? imageAsset,
  }) {
    final updated = [...items.value];
    final index = updated.indexWhere((p) => p['name'] == name);
    if (index >= 0) {
      updated[index] = {...updated[index], 'quantity': (updated[index]['quantity'] as int? ?? 1) + 1};
    } else {
      updated.add({
        'name': name, 'price': price, 'image': image,
        'imageBytes': imageBytes, 'imageAsset': imageAsset, 'quantity': 1,
      });
    }
    items.value = updated;
  }

  static void increase(int index) {
    if (index < 0 || index >= items.value.length) return;
    final updated = [...items.value];
    updated[index] = {...updated[index], 'quantity': (updated[index]['quantity'] as int? ?? 1) + 1};
    items.value = updated;
  }

  static void decrease(int index) {
    if (index < 0 || index >= items.value.length) return;
    final updated = [...items.value];
    final qty = (updated[index]['quantity'] as int? ?? 1) - 1;
    if (qty <= 0) {
      updated.removeAt(index);
    } else {
      updated[index] = {...updated[index], 'quantity': qty};
    }
    items.value = updated;
  }

  static void remove(int index) {
    if (index < 0 || index >= items.value.length) return;
    items.value = [...items.value]..removeAt(index);
  }
}
