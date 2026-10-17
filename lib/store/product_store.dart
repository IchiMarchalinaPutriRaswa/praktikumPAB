import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ProductItem {
  final String name, price, condition, imageUrl;
  final List<Uint8List> images;

  const ProductItem({
    required this.name,
    required this.price,
    required this.condition,
    this.imageUrl = '',
    this.images = const [],
  });

  Uint8List? get imageBytes => images.isEmpty ? null : images.first;
}

class ProductStore {
  static final ValueNotifier<List<ProductItem>> items = ValueNotifier([
    const ProductItem(
      name: 'Basic Cotton T-Shirt',
      price: 'Rp45.000',
      condition: 'Kondisi sangat baik',
      imageUrl: 'https://tse1.mm.bing.net/th/id/OIP.wM-BnE6VHnhH_tv90bWBwAHaKs?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    const ProductItem(
      name: 'Denim Jacket',
      price: 'Rp85.000',
      condition: 'Kondisi baik',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.KdNTIT0xX_DHUVo3pWkOLgHaHa?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    const ProductItem(
      name: 'Casual Jeans',
      price: 'Rp65.000',
      condition: 'Kondisi sangat baik',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.j49LEoht8TGdGZLL1EPmUwHaJ1?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    const ProductItem(
      name: 'Knit Sweater',
      price: 'Rp55.000',
      condition: 'Kondisi baik',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.yKH82MY-_8jGnK6B_Fv2rAHaLW?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
  ]);

  static void add(ProductItem product) {
    items.value = [...items.value, product];
  }
}