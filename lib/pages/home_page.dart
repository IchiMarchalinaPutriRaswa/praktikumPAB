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
    {
      'name': 'Basic Cotton T-Shirt',
      'price': 'Rp45.000',
      'condition': 'Kondisi sangat baik',
      'image':
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500',
    },
    {
      'name': 'Denim Jacket',
      'price': 'Rp85.000',
      'condition': 'Kondisi baik',
      'image':
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500',
    },
    {
      'name': 'Casual Jeans',
      'price': 'Rp65.000',
      'condition': 'Kondisi sangat baik',
      'image':
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=500',
    },
    {
      'name': 'Knit Sweater',
      'price': 'Rp55.000',
      'condition': 'Kondisi baik',
      'image':
          'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=500',
    },
  ];

  void openPage(BuildContext context, int index) {
    final pages = [
      const HomePage(),
      const CatalogPage(),
      const SellPage(),
      const CartPage(),
      const ProfilePage(),
    ];

    if (index != 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => pages[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PreloWear',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temukan Gaya Favoritmu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text('Preloved berkualitas untuk semua kalangan.'),
            const SizedBox(height: 16),
            const SearchField(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Produk Pilihan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => openPage(context, 1),
                  child: const Text('Lihat semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.57,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return ProductCard(
                  name: product['name']!,
                  price: product['price']!,
                  condition: product['condition']!,
                  imageUrl: product['image']!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductDetailPage(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavbar(
        onTap: (index) => openPage(context, index),
      ),
    );
  }
}