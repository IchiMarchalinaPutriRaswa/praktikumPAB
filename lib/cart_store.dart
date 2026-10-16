import 'package:flutter/foundation.dart';

class CartStore {
  static final ValueNotifier<List<Map<String, String>>> items =
      ValueNotifier([]);

  static void add(String name, String price, String image) {
    items.value = [...items.value, {'name': name, 'price': price, 'image': image}];
  }

  static void remove(int index) {
    final list = [...items.value]..removeAt(index);
    items.value = list;
  }
}
