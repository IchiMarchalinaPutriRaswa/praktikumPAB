import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/product.dart';

/// Galeri foto produk. Image.network menampilkan foto online; Image.asset menjadi fallback lokal.
class ProductGalleryPage extends StatelessWidget {
  const ProductGalleryPage({super.key, required this.product});
  final PreloProduct product;

  Widget _image() {
    if (product.imageAsset != null) {
      return Image.asset(product.imageAsset!, fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Image.asset('assets/images/preloved_shirt.png', fit: BoxFit.contain));
    }
    return Image.network(product.imageUrl, fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/preloved_shirt_product.png', fit: BoxFit.contain));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Foto produk', style: TextStyle(fontWeight: FontWeight.w900))),
    body: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.all(constraints.maxWidth > 800 ? 32 : 16),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 920), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.name, style: const TextStyle(fontSize: 22, color: kText, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text('${product.category} • ${product.condition}', style: const TextStyle(color: kMuted, fontSize: 13)),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 300, maxHeight: 580),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFECE6DD))),
            padding: const EdgeInsets.all(12),
            child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _image()),
          ),
          const SizedBox(height: 14),
          Row(children: [const Icon(Icons.image_search_rounded, color: kBrand), const SizedBox(width: 8), Expanded(child: Text(
            'Foto produk ditampilkan dari sumber gambar. Jika gambar internet tidak tersedia, aplikasi menampilkan gambar lokal sebagai cadangan.',
            style: const TextStyle(color: kMuted, fontSize: 12, height: 1.45))) ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFE7F2EC), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, color: kBrand), const SizedBox(width: 10),
              Expanded(child: Text('Harga ${product.price}. Pastikan kondisi dan ukuran barang sesuai sebelum membeli.',
                style: const TextStyle(color: kBrandDark, fontSize: 12, height: 1.45))),
            ]),
          ),
        ],
      ))),
    )),
  );
}
