import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../widgets/product_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final searchController = TextEditingController();

  static const products = [
    ('Basic Cotton T-Shirt', 'Rp45.000', 'Kondisi sangat baik', 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600'),
    ('Denim Jacket', 'Rp85.000', 'Kondisi baik', 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600'),
    ('Casual Jeans', 'Rp65.000', 'Kondisi sangat baik', 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600'),
    ('Knit Sweater', 'Rp55.000', 'Kondisi baik', 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600'),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.toLowerCase();
    final filtered = products.where((p) => p.$1.toLowerCase().contains(query)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchController.text.isEmpty ? null : IconButton(
                  onPressed: () { searchController.clear(); setState(() {}); },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Produk tidak ditemukan'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final columns = w >= 1100 ? 5 : w >= 800 ? 4 : w >= 520 ? 3 : 2;

                        return GridView.builder(
                          itemCount: filtered.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns, crossAxisSpacing: 12,
                            mainAxisSpacing: 14, childAspectRatio: 0.65,
                          ),
                          itemBuilder: (context, index) {
                            final p = filtered[index];
                            return ProductCard(
                              name: p.$1, price: p.$2, condition: p.$3, imageUrl: p.$4,
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => ProductDetailPage(
                                  name: p.$1, price: p.$2, condition: p.$3, imageUrl: p.$4,
                                ),
                              )),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}