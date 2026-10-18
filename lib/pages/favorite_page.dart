import 'package:flutter/material.dart';
import '../store/favorite_store.dart';
import '../store/product_store.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Favorit Saya', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ValueListenableBuilder<Set<String>>(
      valueListenable: FavoriteStore.favorites,
      builder: (context, favorites, _) => ValueListenableBuilder<List<ProductItem>>(
        valueListenable: ProductStore.items,
        builder: (context, products, _) {
          final items = products.where((p) => favorites.contains(p.name)).toList();

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.favorite_border_rounded, size: 64, color: Color(0xFF245C4A)),
                  SizedBox(height: 12),
                  Text('Belum ada favorit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Tekan ikon hati pada produk yang kamu sukai.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                ]),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.58,
            ),
            itemBuilder: (context, index) {
              final p = items[index];
              return ProductCard(
                name: p.name, price: p.price, condition: p.condition,
                imageUrl: p.imageUrl, imageBytes: p.imageBytes,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ProductDetailPage(
                    name: p.name, price: p.price, condition: p.condition,
                    imageUrl: p.imageUrl, imageBytes: p.imageBytes,
                  ),
                )),
              );
            },
          );
        },
      ),
    ),
  );
}