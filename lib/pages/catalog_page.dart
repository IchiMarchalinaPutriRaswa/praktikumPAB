import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../product_store.dart';
import '../widgets/product_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openProduct(BuildContext c, ProductItem p) {
    Navigator.push(c, MaterialPageRoute(builder: (_) => ProductDetailPage(
      name: p.name, price: p.price, condition: p.condition,
      imageUrl: p.imageUrl, imageBytes: p.imageBytes,
    )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Katalog', style: TextStyle(fontWeight: FontWeight.w800))),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Cari produk...', prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: searchController.text.isEmpty ? null : IconButton(
              onPressed: () { searchController.clear(); setState(() {}); },
              icon: const Icon(Icons.close),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ValueListenableBuilder<List<ProductItem>>(
            valueListenable: ProductStore.items,
            builder: (context, products, _) {
              final query = searchController.text.toLowerCase();
              final filtered = products.where((p) => p.name.toLowerCase().contains(query)).toList();

              if (filtered.isEmpty) {
                return Center(child: Text(products.isEmpty ? 'Belum ada produk.' : 'Produk tidak ditemukan.'));
              }

              return LayoutBuilder(builder: (context, constraints) {
                final w = constraints.maxWidth;
                final columns = w >= 1100 ? 5 : w >= 800 ? 4 : w >= 520 ? 3 : 2;

                return GridView.builder(
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns, crossAxisSpacing: 12,
                    mainAxisSpacing: 14, childAspectRatio: 0.58,
                  ),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return ProductCard(
                      name: p.name, price: p.price, condition: p.condition,
                      imageUrl: p.imageUrl, imageBytes: p.imageBytes,
                      onTap: () => openProduct(context, p),
                    );
                  },
                );
              });
            },
          ),
        ),
      ]),
    ),
  );
}