import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class CartStore {
  static final ValueNotifier<List<Map<String, dynamic>>> items = ValueNotifier([]);

  static void add(String name, String price, String image, {Uint8List? imageBytes}) {
    items.value = [
      ...items.value,
      {'name': name, 'price': price, 'image': image, 'imageBytes': imageBytes},
    ];
  }

  static void remove(int index) {
    items.value = [...items.value]..removeAt(index);
  }
}