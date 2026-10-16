import 'package:flutter/material.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      ('Basic Cotton T-Shirt', 'Rp45.000', Icons.checkroom),
      ('Casual Outerwear', 'Rp65.000', Icons.dry_cleaning),
      ('Everyday Shirt', 'Rp35.000', Icons.shopping_bag_outlined),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Produk')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE5EEE9),
                child: Icon(product.$3, color: const Color(0xFF245C4A)),
              ),
              title: Text(product.$1),
              subtitle: Text(product.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailPage())),
            ),
          );
        },
      ),
    );
  }
}
