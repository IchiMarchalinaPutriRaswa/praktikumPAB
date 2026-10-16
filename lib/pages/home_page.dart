import 'package:flutter/material.dart';
import 'catalog_page.dart';
import 'product_detail_page.dart';
import 'sell_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import '../widgets/product_card.dart';
import '../widgets/search_field.dart';
import '../widgets/home_bottom_navbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const products = [
    {'name': 'Basic Cotton T-Shirt', 'price': 'Rp45.000', 'condition': 'Kondisi sangat baik', 'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600'},
    {'name': 'Denim Jacket', 'price': 'Rp85.000', 'condition': 'Kondisi baik', 'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600'},
    {'name': 'Casual Jeans', 'price': 'Rp65.000', 'condition': 'Kondisi sangat baik', 'image': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600'},
    {'name': 'Knit Sweater', 'price': 'Rp55.000', 'condition': 'Kondisi baik', 'image': 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600'},
  ];

  void openPage(BuildContext context, int index) {
    final pages = [const HomePage(), const CatalogPage(), const SellPage(), const CartPage(), const ProfilePage()];
    if (index == 0) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => pages[index]));
  }

  void openProduct(BuildContext context, Map<String, String> product) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ProductDetailPage(
        name: product['name']!, price: product['price']!,
        condition: product['condition']!, imageUrl: product['image']!,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PreloWear', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: const Color(0xFF245C4A), borderRadius: BorderRadius.circular(22)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Temukan barang favoritmu.', style: TextStyle(color: Colors.white, fontSize: 26, height: 1.25, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Gaya tetap menarik, belanja lebih hemat.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SearchField(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Produk pilihan', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                TextButton(onPressed: () => openPage(context, 1), child: const Text('Lihat semua')),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1250 ? 5 : width >= 850 ? 4 : width >= 550 ? 3 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ProductCard(
                      name: p['name']!, price: p['price']!,
                      condition: p['condition']!, imageUrl: p['image']!,
                      onTap: () => openProduct(context, p),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavbar(onTap: (index) => openPage(context, index)),
    );
  }
}