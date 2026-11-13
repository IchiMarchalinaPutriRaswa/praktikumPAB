import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ProductItem {
  final String name, price, condition, imageUrl;
  final String? imageAsset;
  final List<String> imageAssets;
  final List<Uint8List> images;
  final String sizeLabel, defects, description;
  final double? chestCm, lengthCm, shoulderCm, sleeveCm;
  final double? waistCm; // TAMBAHAN FITMATCH
  final Uint8List? evidenceImage;

  const ProductItem({
    required this.name, required this.price, required this.condition,
    this.imageUrl = '', this.imageAsset, this.imageAssets = const [],
    this.images = const [],
    this.sizeLabel = '-', this.chestCm, this.lengthCm,
    this.shoulderCm, this.sleeveCm, this.waistCm,
    this.defects = 'Tidak ada kekurangan yang diketahui.',
    this.description = 'Produk preloved yang nyaman digunakan dan masih terawat.',
    this.evidenceImage,
  });

  Uint8List? get imageBytes => images.isEmpty ? null : images.first;
}

class ProductStore {
  static final ValueNotifier<List<ProductItem>> items = ValueNotifier([
    const ProductItem(
      name: 'Adidas Denim Jacket',
      price: 'Rp150.000',
      condition: 'Kondisi sangat baik',
      imageAssets: [
        'assets/images/Denim1.jpg',
        'assets/images/Denim2.jpg',
        'assets/images/Denim3.jpg',
        'assets/images/Denim4.jpg',
        'assets/images/Denim5.jpg',
      ],
      description: 'Jaket denim kasual dengan desain klasik yang cocok digunakan untuk berbagai aktivitas. Bahan masih nyaman dan memiliki warna yang menarik.',
      sizeLabel: 'L', chestCm: 102, lengthCm: 62,
      shoulderCm: 43, sleeveCm: 59,
      defects: 'Terdapat sedikit perubahan warna pada bagian lipatan lengan akibat pemakaian.',
    ),
    const ProductItem(
      name: 'JHL Wide Leg Jeans',
      price: 'Rp110.000',
      condition: 'Kondisi cukup baik',
      imageAssets: [
        'assets/images/JHL1.jpg',
        'assets/images/JHL2.jpg',
        'assets/images/JHL3.jpg',
        'assets/images/JHL4.jpg',
      ],
      description: 'Celana jeans JHL berwarna biru muda dengan model wide leg dan detail saku tempel pada bagian depan. Ukuran XL dengan lingkar pinggang 84 cm.',
      sizeLabel: 'XL', waistCm: 84, lengthCm: 100,
      defects: 'Terdapat benang yang terlepas dan sedikit kerusakan jahitan pada bagian ujung celana.',
    ),
    const ProductItem(
      name: 'Knit Sweater',
      price: 'Rp55.000',
      condition: 'Kondisi seperti baru',
      imageUrl: 'https://tse3.mm.bing.net/th/id/OIP.yKH82MY-_8jGnK6B_Fv2rAHaLW?r=0&rs=1&pid=ImgDetMain&o=7&rm=3',
      description: 'Sweater rajut dengan tekstur lembut dan desain minimalis. Cocok digunakan untuk aktivitas santai maupun kegiatan sehari-hari.',
      sizeLabel: 'M', chestCm: 100, lengthCm: 61,
      shoulderCm: 41, sleeveCm: 58,
      defects: 'Tidak ditemukan noda, lubang, jahitan rusak, maupun warna memudar.',
    ),
    const ProductItem(
      name: 'Adidas Pink Jacket',
      price: 'Rp125.000',
      condition: 'Kondisi sangat baik',
      imageAssets: [
        'assets/images/jacket_adidas1.jpg',
        'assets/images/jacket_adidas2.jpg',
        'assets/images/jacket_adidas3.jpg',
        'assets/images/jacket_adidas4.jpg',
      ],
      description: 'Jaket Adidas berwarna pink dengan desain sporty, motif grafis pada bagian depan, dan detail tiga garis putih pada lengan.',
      sizeLabel: 'All Size', chestCm: 104, lengthCm: 62,
      shoulderCm: 44, sleeveCm: 58,
      defects: 'Tidak ditemukan noda, lubang, jahitan rusak, maupun warna memudar.',
    ),
    const ProductItem(
      name: 'Blue Pattern Baggy Jeans',
      price: 'Rp95.000',
      condition: 'Kondisi cukup baik',
      imageAssets: [
        'assets/images/baggy_jeans1.jpg',
        'assets/images/baggy_jeans2.jpg',
        'assets/images/baggy_jeans3.jpg',
      ],
      description: 'Celana jeans biru dengan motif abstrak dan model baggy yang memberikan tampilan kasual. Ukuran XL dengan lingkar pinggang 84 cm.',
      sizeLabel: 'XL', waistCm: 84, lengthCm: 100,
      defects: 'Terdapat sedikit kerusakan pada bagian jahitan ujung celana.',
    ),
    const ProductItem(
      name: 'Houndstooth Vest',
      price: 'Rp75.000',
      condition: 'Kondisi seperti baru',
      imageAssets: [
        'assets/images/vest1.jpg',
        'assets/images/vest2.jpg',
        'assets/images/vest3.jpg',
      ],
      description: 'Rompi wanita bermotif houndstooth hitam putih dengan kerah V, kancing depan, dan detail saku pada bagian depan.',
      sizeLabel: 'M', chestCm: 92, lengthCm: 48,
      defects: 'Tidak ditemukan noda, lubang, jahitan rusak, maupun warna memudar.',
    ),
    const ProductItem(
      name: 'Floral Embroidery Knit Cardigan',
      price: 'Rp85.000',
      condition: 'Kondisi cukup baik',
      imageAssets: [
        'assets/images/cardigan1.jpg',
        'assets/images/cardigan2.jpg',
        'assets/images/cardigan3.jpg',
      ],
      description: 'Cardigan rajut wanita berwarna cream dengan detail bordir bunga berwarna pink dan kuning yang memberikan kesan manis dan feminin. Memiliki model kancing depan, lengan panjang, serta bahan rajut yang nyaman digunakan.',
      sizeLabel: 'M', chestCm: 100, lengthCm: 55,
      shoulderCm: 40, sleeveCm: 55,
      defects: 'Terdapat sedikit tanda pemakaian pada bagian rajutan.',
    ),
    const ProductItem(
      name: 'Amora Button Blouse',
      price: 'Rp65.000',
      condition: 'Kondisi cukup baik',
      imageAssets: [
        'assets/images/amora_blouse1.jpg',
        'assets/images/amora_blouse2.jpg',
        'assets/images/amora_blouse3.jpg',
        'assets/images/amora_blouse4.jpg',
        'assets/images/amora_blouse5.jpg',
      ],
      description: 'Kemeja wanita lengan panjang dengan motif bunga bernuansa pastel pink dan cream yang memberikan kesan vintage dan feminin. Memiliki detail kancing depan, kerah sederhana, serta potongan yang nyaman digunakan.',
      sizeLabel: 'M', chestCm: 96, lengthCm: 65,
      shoulderCm: 38, sleeveCm: 56,
      defects: 'Terdapat sedikit kerutan pada kain akibat penyimpanan dan pemakaian.',
    ),
    const ProductItem(
      name: 'Stussy x Dickies Jacket',
      price: 'Rp250.000',
      condition: 'Kondisi cukup baik',
      imageAssets: [
        'assets/images/stussy_dickies1.jpg',
        'assets/images/stussy_dickies2.jpg',
        'assets/images/stussy_dickies3.jpg',
        'assets/images/stussy_dickies4.jpg',
      ],
      description: 'Jaket Stussy x Dickies berwarna hitam dengan desain workwear, resleting depan, dua saku samping, dan detail jahitan putih.',
      sizeLabel: 'L', chestCm: 108, lengthCm: 66,
      shoulderCm: 46, sleeveCm: 61,
      defects: 'Terdapat noda tinta pada bagian merk.',
    ),
  ]);

  static void add(ProductItem product) {
    items.value = [...items.value, product];
  }
}
