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
      imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600',
    ),
    const ProductItem(
      name: 'Denim Jacket',
      price: 'Rp85.000',
      condition: 'Kondisi baik',
      imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600',
    ),
    const ProductItem(
      name: 'Casual Jeans',
      price: 'Rp65.000',
      condition: 'Kondisi sangat baik',
      imageUrl: 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600',
    ),
    const ProductItem(
      name: 'Knit Sweater',
      price: 'Rp55.000',
      condition: 'Kondisi baik',
      imageUrl: 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600',
    ),
  ]);

  static void add(ProductItem product) {
    items.value = [...items.value, product];
  }
}