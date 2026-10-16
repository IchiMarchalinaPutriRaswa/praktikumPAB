import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../widgets/product_card.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  static const products = [
    ('Basic Cotton T-Shirt','Rp45.000','Kondisi sangat baik','https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600'),
    ('Denim Jacket','Rp85.000','Kondisi baik','https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600'),
    ('Casual Jeans','Rp65.000','Kondisi sangat baik','https://images.unsplash.com/photo-1542272604-787c3835535d?w=600'),
    ('Knit Sweater','Rp55.000','Kondisi baik','https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Column(children: [
          const TextField(decoration: InputDecoration(hintText: 'Cari produk...', prefixIcon: Icon(Icons.search_rounded))),
          const SizedBox(height: 14),
          SizedBox(height: 38, child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['Semua','Atasan','Outerwear','Celana','Aksesori'].map((e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(e), selected: e == 'Semua', onSelected: (_) {}),
            )).toList(),
          )),
          const SizedBox(height: 12),
          Expanded(child: GridView.builder(
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .67),
            itemBuilder: (_, i) => ProductCard(
              name: products[i].$1, price: products[i].$2, condition: products[i].$3, imageUrl: products[i].$4,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailPage())),
            ),
          )),
        ]),
      ),
    );
  }
}
