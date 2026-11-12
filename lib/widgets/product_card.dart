import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../store/favorite_store.dart';
import '../store/order_store.dart';

class ProductCard extends StatefulWidget {
  final String name, price, condition, imageUrl;
  final String? imageAsset;
  final List<String> imageAssets;
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  const ProductCard({
    super.key, required this.name, required this.price,
    required this.condition, required this.imageUrl,
    this.imageAsset, this.imageAssets = const [],
    this.imageBytes, required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  static const green = Color(0xFF89AC46);
  static const paleGreen = Color(0xFFE8EEEB);

  Widget noImage() => const ColoredBox(
    color: paleGreen,
    child: Center(child: Icon(
      Icons.image_not_supported_outlined, size: 40)),
  );

  Widget productImage() {
    // Prioritaskan foto yang diunggah langsung oleh penjual.
    if (widget.imageBytes != null) {
      return Image.memory(widget.imageBytes!, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => noImage());
    }
    // Gunakan foto pertama dari daftar galeri produk.
    if (widget.imageAssets.isNotEmpty) {
      return Image.asset(widget.imageAssets.first, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => noImage());
    }
    // Dukung juga produk yang hanya memiliki satu aset gambar.
    if (widget.imageAsset?.isNotEmpty == true) {
      return Image.asset(widget.imageAsset!, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => noImage());
    }
    // Produk bawaan dapat menggunakan gambar dari internet.
    if (widget.imageUrl.isNotEmpty) {
      return Image.network(widget.imageUrl, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => noImage());
    }
    // Tampilkan ikon pengganti jika gambar tidak tersedia.
    return noImage();
  }

  // Perbarui daftar favorit dan tampilkan konfirmasi.
  void toggleFavorite(bool favorite) {
    FavoriteStore.toggle(widget.name);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 900),
      content: Text(favorite
        ? '${widget.name} dihapus dari favorit'
        : '${widget.name} ditambahkan ke favorit'),
    ));
  }

  Widget favoriteButton(bool favorite) => Material(
    color: Colors.white.withOpacity(.92),
    shape: const CircleBorder(),
    child: IconButton(
      tooltip: favorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
      onPressed: () => toggleFavorite(favorite),
      icon: Icon(
        favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: 19, color: favorite ? Colors.red : Colors.black87,
      ),
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
    ),
  );

  Widget productBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: green,
      borderRadius: BorderRadius.circular(20)),
    child: const Text('PRELOVED', style: TextStyle(
      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
  );

  // Nilai rata-rata dihitung dari rating yang tersimpan.
  Widget ratingLabel(Map<String, List<int>> ratings) {
    final data = ratings[widget.name] ?? [];
    final count = data.length;
    final average = count == 0 ? 0.0 :
        data.fold<int>(0, (a, b) => a + b) / count;
    return Row(children: [
      Icon(count == 0 ? Icons.star_border : Icons.star,
        size: 14, color: count == 0 ? Colors.black38 : Colors.amber),
      const SizedBox(width: 4),
      Text(count == 0 ? 'Belum di-rating' :
        '${average.toStringAsFixed(1)} ($count)',
        style: const TextStyle(fontSize: 10, color: Colors.black54,
          fontWeight: FontWeight.w600)),
    ]);
  }

  Widget conditionLabel() => Row(children: [
    const Icon(Icons.verified_outlined, size: 13, color: green),
    const SizedBox(width: 4),
    Expanded(child: Text(widget.condition, maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 10, color: Colors.black54))),
  ]);

  // Informasi ditampilkan di bawah area gambar produk.
  Widget productInformation(Map<String, List<int>> ratings) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.name, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700, height: 1.15)),
        const SizedBox(height: 5),
        conditionLabel(),
        const SizedBox(height: 5),
        ratingLabel(ratings),
        const SizedBox(height: 5),
        Text(widget.price, style: const TextStyle(fontSize: 15,
          color: green, fontWeight: FontWeight.w800)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<Set<String>>(
    valueListenable: FavoriteStore.favorites,
    builder: (context, favorites, _) {
      final favorite = favorites.contains(widget.name);
      return ValueListenableBuilder<Map<String, List<int>>>(
        valueListenable: OrderStore.ratings,
        builder: (context, ratings, _) => InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(
                color: Color(0x0A000000), blurRadius: 12,
                offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Stack(
                  fit: StackFit.expand,
                  children: [
                    productImage(),
                    Positioned(top: 8, left: 8,
                      child: productBadge()),
                    Positioned(top: 6, right: 6,
                      child: favoriteButton(favorite)),
                  ],
                )),
                productInformation(ratings),
              ],
            ),
          ),
        ),
      );
    },
  );
}
