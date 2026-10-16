import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onFavorite,
    required this.onAddToCart,
    required this.onOpen,
  });

  final PreloProduct product;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;
  final VoidCallback onOpen;

  Widget _productImage() {
    if (product.imageAsset != null) {
      return Image.asset(product.imageAsset!, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback());
    }
    if (product.imageUrl.isEmpty) return _imageFallback();
    return Image.network(product.imageUrl, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/preloved_shirt_product.png', fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      ));
  }

  Widget _imageFallback() => Container(
    color: const Color(0xFFE8F0E8), alignment: Alignment.center,
    child: const Icon(Icons.checkroom_rounded, size: 54, color: kBrand),
  );

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEFE9E0)),
      boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 6))],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        onTap: onOpen,
        child: AspectRatio(aspectRatio: 0.98, child: Stack(fit: StackFit.expand, children: [
          _productImage(),
          Positioned(left: 9, top: 9, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFF8E6D7), borderRadius: BorderRadius.circular(50)),
            child: Text(product.condition, style: const TextStyle(fontSize: 10, color: kBrandDark, fontWeight: FontWeight.w700)),
          )),
          Positioned(right: 8, top: 8, child: Material(
            color: Colors.white.withOpacity(0.94), shape: const CircleBorder(),
            child: IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: product.isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
              onPressed: onFavorite,
              icon: Icon(product.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: product.isFavorite ? const Color(0xFFD65D73) : kText, size: 19),
            ),
          )),
        ])),
      ),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: InkWell(
          onTap: onOpen,
          child: Padding(padding: const EdgeInsets.fromLTRB(12, 11, 12, 6), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.category.toUpperCase(), style: const TextStyle(color: kMuted, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: kText, height: 1.25)),
              const SizedBox(height: 7),
              Text(product.price, style: const TextStyle(color: kBrand, fontWeight: FontWeight.w800, fontSize: 14)),
            ],
          )),
        )),
        Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onAddToCart,
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
            label: const Text('Tambah', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), minimumSize: const Size(0, 38)),
          ),
        )),
      ])),
    ]),
  );
}
