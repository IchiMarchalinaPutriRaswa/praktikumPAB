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
    {'name':'Basic Cotton T-Shirt','price':'Rp45.000','condition':'Kondisi sangat baik','image':'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600'},
    {'name':'Denim Jacket','price':'Rp85.000','condition':'Kondisi baik','image':'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600'},
    {'name':'Casual Jeans','price':'Rp65.000','condition':'Kondisi sangat baik','image':'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600'},
    {'name':'Knit Sweater','price':'Rp55.000','condition':'Kondisi baik','image':'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600'},
  ];

  void openPage(BuildContext context, int index) {
    final pages = [const HomePage(), const CatalogPage(), const SellPage(), const CartPage(), const ProfilePage()];
    if (index == 0) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => pages[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PreloWear', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          Text('Gaya baru, harga bersahabat', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.normal)),
        ]),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF245C4A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Temukan barang favoritmu.', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.1)),
              SizedBox(height: 8),
              Text('Preloved berkualitas yang masih layak untuk menemani aktivitasmu.', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 16),
          const SearchField(),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Produk pilihan', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            TextButton(onPressed: () => openPage(context, 1), child: const Text('Lihat semua')),
          ]),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .67,
            ),
            itemBuilder: (_, index) {
              final p = products[index];
              return ProductCard(
                name: p['name']!, price: p['price']!, condition: p['condition']!, imageUrl: p['image']!,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailPage())),
              );
            },
          ),
        ]),
      ),
      bottomNavigationBar: HomeBottomNavbar(onTap: (i) => openPage(context, i)),
    );
  }
}
