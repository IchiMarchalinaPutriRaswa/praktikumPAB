import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ProductItem {
  final String name, price, condition, imageUrl;
  final String? imageAsset;
  final List<Uint8List> images;
  final String sizeLabel, defects, description;
  final double? chestCm, lengthCm, shoulderCm, sleeveCm;
  final Uint8List? evidenceImage;

  const ProductItem({
    required this.name, required this.price, required this.condition,
    this.imageUrl = '', this.imageAsset, this.images = const [],
    this.sizeLabel = '-', this.chestCm, this.lengthCm,
    this.shoulderCm, this.sleeveCm,
    this.defects = 'Tidak ada kekurangan yang diketahui.',
    this.description = 'Produk preloved yang nyaman digunakan dan masih terawat.',
    this.evidenceImage,
  });

  Uint8List? get imageBytes => images.isEmpty ? null : images.first;
}

class ProductStore {
  static final ValueNotifier<List<ProductItem>> items = ValueNotifier([
    const ProductItem(
      name: 'Denim Jacket',
      price: 'Rp85.000',
      condition: 'Kondisi cukup baik',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.KdNTIT0xX_DHUVo3pWkOLgHaHa?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
      description: 'Jaket denim kasual dengan desain klasik yang cocok digunakan untuk berbagai aktivitas. Bahan masih nyaman dan memiliki warna yang menarik.',
      sizeLabel: 'L',
      chestCm: 102,
      lengthCm: 62,
      shoulderCm: 43,
      sleeveCm: 59,
      defects: 'Terdapat sedikit perubahan warna pada bagian lipatan lengan akibat pemakaian. Tidak ditemukan lubang atau jahitan rusak.',
    ),
    const ProductItem(
      name: 'Casual Jeans',
      price: 'Rp65.000',
      condition: 'Kondisi cukup baik',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.j49LEoht8TGdGZLL1EPmUwHaJ1?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
      description: 'Celana jeans kasual dengan model sederhana yang mudah dipadukan dengan berbagai atasan. Ukuran label 30, lingkar pinggang sekitar 78 cm dan lingkar pinggul 98 cm.',
      sizeLabel: '30',
      lengthCm: 98,
      defects: 'Warna sedikit memudar pada bagian lutut akibat pemakaian. Tidak ditemukan lubang atau jahitan yang terlepas.',
    ),
    const ProductItem(
      name: 'Knit Sweater',
      price: 'Rp55.000',
      condition: 'Kondisi seperti baru',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.yKH82MY-_8jGnK6B_Fv2rAHaLW?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
      description: 'Sweater rajut dengan tekstur lembut dan desain minimalis. Cocok digunakan untuk aktivitas santai maupun kegiatan sehari-hari.',
      sizeLabel: 'M',
      chestCm: 100,
      lengthCm: 61,
      shoulderCm: 41,
      sleeveCm: 58,
      defects: 'Tidak ditemukan noda, lubang, jahitan rusak, maupun perubahan warna. Kondisi pakaian masih sangat terawat.',
    ),
    const ProductItem(
      name: 'Hoodie',
      price: 'Rp50.000',
      condition: 'Kondisi cukup baik',
      imageAsset: 'assets/images/hoodie.jpg',
      description: 'Hoodie kasual dengan bahan yang nyaman digunakan. Memiliki desain simpel dan cocok untuk kegiatan sehari-hari.',
      sizeLabel: 'L',
      chestCm: 110,
      lengthCm: 68,
      shoulderCm: 47,
      sleeveCm: 62,
      defects: 'Terdapat sedikit bulu halus pada permukaan bahan akibat pemakaian. Tidak ditemukan lubang atau kerusakan jahitan.',
    ),
    const ProductItem(
      name: 'Rok Floral',
      price: 'Rp35.000',
      condition: 'Kondisi seperti baru',
      imageAsset: 'assets/images/rok.jpg',
      description: 'Rok floral dengan motif bunga yang memberikan tampilan feminin. Ukuran label M, lingkar pinggang sekitar 72 cm dan lingkar pinggul 98 cm.',
      sizeLabel: 'M',
      lengthCm: 76,
      defects: 'Tidak ditemukan noda, lubang, jahitan rusak, maupun warna memudar. Produk masih dalam kondisi terawat.',
    ),
    const ProductItem(
      name: 'Outer',
      price: 'Rp38.000',
      condition: 'Kondisi sangat baik',
      imageAsset: 'assets/images/outer.jpg',
      description: 'Outer wanita bermotif polkadot dengan detail kancing depan dan saku. Memiliki desain menarik serta nyaman digunakan untuk aktivitas sehari-hari.',
      sizeLabel: 'M',
      chestCm: 96,
      lengthCm: 62,
      shoulderCm: 39,
      sleeveCm: 56,
      defects: 'Tidak ditemukan noda, lubang, jahitan rusak, maupun warna memudar. Pakaian masih terawat dengan baik.',
    ),
  ]);

  static void add(ProductItem product) {
    items.value = [...items.value, product];
  }
}
