import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ProductItem {
  final String name, price, condition, imageUrl;
  final String? imageAsset;
  final List<Uint8List> images;

  const ProductItem({
    required this.name, required this.price, required this.condition,
    this.imageUrl = '', this.imageAsset, this.images = const [],
  });

  Uint8List? get imageBytes => images.isEmpty ? null : images.first;
}

class ProductStore {
  static final ValueNotifier<List<ProductItem>> items = ValueNotifier([
    const ProductItem(
      name: 'Denim Jacket', price: 'Rp85.000',
      condition: 'Kondisi cukup baik',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.KdNTIT0xX_DHUVo3pWkOLgHaHa?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    const ProductItem(
      name: 'Casual Jeans', price: 'Rp65.000',
      condition: 'Kondisi cukup baik',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.j49LEoht8TGdGZLL1EPmUwHaJ1?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    const ProductItem(
      name: 'Knit Sweater', price: 'Rp55.000',
      condition: 'Kondisi seperti baru',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.yKH82MY-_8jGnK6B_Fv2rAHaLW?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
    ),
    const ProductItem(
      name: 'Hoodie', price: 'Rp50.000',
      condition: 'Kondisi cukup baik',
      imageAsset: 'assets/images/hoodie.jpg',
    ),
    const ProductItem(
      name: 'Rok Floral', price: 'Rp35.000',
      condition: 'Kondisi seperti baru',
      imageAsset: 'assets/images/rok.jpg',
    ),
    const ProductItem(
      name: 'Outer', price: 'Rp38.000',
      condition: 'Kondisi sangat baik',
      imageAsset: 'assets/images/outer.jpg',
    ),
  ]);

  static void add(ProductItem product) {
    items.value = [...items.value, product];
  }
}
