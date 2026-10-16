import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/product.dart';

/// Halaman detail produk; Align dipakai untuk memosisikan label, harga, dan aksi.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.onFavorite,
    required this.onAddToCart,
    required this.onOpenGallery,
  });

  final PreloProduct product;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onOpenGallery;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  PreloProduct get product => widget.product;
  VoidCallback get onFavorite => widget.onFavorite;
  VoidCallback get onAddToCart => widget.onAddToCart;
  VoidCallback get onOpenGallery => widget.onOpenGallery;

  Widget _productImage() {
    if (product.imageAsset != null) {
      return Image.asset(product.imageAsset!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset('assets/images/preloved_shirt_product.png', fit: BoxFit.cover));
    }
    return Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/preloved_shirt_product.png', fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail produk', style: TextStyle(fontWeight: FontWeight.w900)), actions: [
        IconButton(tooltip: product.isFavorite ? 'Hapus favorit' : 'Simpan favorit', onPressed: () { onFavorite(); setState(() {}); },
          icon: Icon(product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: product.isFavorite ? const Color(0xFFD65D73) : kText)),
      ]),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final image = ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: AspectRatio(aspectRatio: wide ? 0.9 : 1.12, child: _productImage()),
        );
        final details = _details(context);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(constraints.maxWidth >= 1000 ? 32 : 16, 12, constraints.maxWidth >= 1000 ? 32 : 16, 28),
          child: Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 5, child: image), const SizedBox(width: 28), Expanded(flex: 4, child: details)])
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [image, const SizedBox(height: 22), details]),
          )),
        );
      }),
    );
  }

  Widget _details(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Align(alignment: Alignment.centerLeft, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFE7F2EC), borderRadius: BorderRadius.circular(40)),
      child: Text(product.condition, style: const TextStyle(color: kBrandDark, fontWeight: FontWeight.w800, fontSize: 12)),
    )),
    const SizedBox(height: 14),
    Text(product.name, style: const TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 26, height: 1.15)),
    const SizedBox(height: 8),
    Text(product.category, style: const TextStyle(color: kMuted, fontSize: 13)),
    const SizedBox(height: 14),
    Align(alignment: Alignment.centerLeft, child: Text(product.price,
      style: const TextStyle(color: kBrand, fontSize: 24, fontWeight: FontWeight.w900))),
    const SizedBox(height: 20),
    const Text('Deskripsi produk', style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 16)),
    const SizedBox(height: 8),
    Text(product.description.isEmpty
      ? 'Pakaian preloved pilihan yang masih layak pakai. Periksa foto dan informasi kondisi sebelum membeli. Tanyakan detail ukuran kepada penjual jika diperlukan.'
      : product.description,
      style: const TextStyle(color: kMuted, height: 1.6, fontSize: 13)),
    const SizedBox(height: 20),
    const Divider(color: Color(0xFFECE6DD)),
    const SizedBox(height: 12),
    const _InfoRow(icon: Icons.verified_outlined, title: 'Informasi kondisi', detail: 'Kondisi barang dicantumkan oleh penjual'),
    const SizedBox(height: 12),
    const _InfoRow(icon: Icons.recycling_outlined, title: 'Belanja berkelanjutan', detail: 'Beri pakaian kesempatan untuk dipakai kembali'),
    const SizedBox(height: 24),
    SizedBox(width: double.infinity, child: ElevatedButton.icon(
      onPressed: onAddToCart, icon: const Icon(Icons.add_shopping_cart_rounded), label: const Text('Tambah ke keranjang'))),
    const SizedBox(height: 10),
    SizedBox(width: double.infinity, child: OutlinedButton.icon(
      onPressed: onOpenGallery, icon: const Icon(Icons.photo_library_outlined), label: const Text('Lihat foto produk'))),
  ]);
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: kBrand, size: 22),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: kText, fontWeight: FontWeight.w800, fontSize: 12)),
      const SizedBox(height: 3),
      Text(detail, style: const TextStyle(color: kMuted, fontSize: 11, height: 1.4)),
    ])),
  ]);
}
