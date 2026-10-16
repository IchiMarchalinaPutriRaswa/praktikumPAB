import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
    required this.products,
    required this.onFavorite,
    required this.onAddToCart,
    required this.onOpenProduct,
  });

  final List<PreloProduct> products;
  final ValueChanged<PreloProduct> onFavorite;
  final ValueChanged<PreloProduct> onAddToCart;
  final ValueChanged<PreloProduct> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk favorit', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pad = constraints.maxWidth >= 900 ? 32.0 : 16.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 14, pad, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: products.isEmpty ? _buildEmptyState() : _buildProductGrid(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 44),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: const Column(
        children: [
          Icon(Icons.favorite_border_rounded, size: 48, color: kBrand),
          SizedBox(height: 12),
          Text('Belum ada produk favorit', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kText)),
          SizedBox(height: 6),
          Text('Tekan ikon hati pada produk untuk menyimpannya di sini.', textAlign: TextAlign.center,
            style: TextStyle(color: kMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1050 ? 4 : width >= 720 ? 3 : width >= 360 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: columns == 1 ? 0.64 : columns == 2 ? 0.52 : columns == 3 ? 0.58 : 0.62,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onFavorite: () => onFavorite(product),
              onAddToCart: () => onAddToCart(product),
              onOpen: () => onOpenProduct(product),
            );
          },
        );
      },
    );
  }
}
