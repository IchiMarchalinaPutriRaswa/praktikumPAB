import 'package:flutter/material.dart';
import '../favorite_store.dart';
import 'sell_page.dart';
import 'cart_page.dart';
import 'home_page.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EEE9),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 34, color: Color(0xFF245C4A)),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pengguna PreloWear',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Belum masuk akun',
                        style: TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Menu(
            icon: Icons.sell_outlined,
            title: 'Jual Barang',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellPage()),
            ),
          ),
          _Menu(
            icon: Icons.shopping_bag_outlined,
            title: 'Keranjang Saya',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartPage()),
            ),
          ),
          ValueListenableBuilder<Set<String>>(
            valueListenable: FavoriteStore.favorites,
            builder: (context, favorites, _) => _Menu(
              icon: Icons.favorite_border_rounded,
              title: 'Favorit Saya',
              trailing: favorites.isEmpty ? null : '${favorites.length}',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritePage()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline),
            title: Text('Tentang PreloWear',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Marketplace pakaian preloved untuk semua kalangan.'),
          ),
        ],
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  static const products = [
    {
      'name': 'Basic Cotton T-Shirt',
      'price': 'Rp45.000',
      'condition': 'Kondisi sangat baik',
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=600',
    },
    {
      'name': 'Denim Jacket',
      'price': 'Rp85.000',
      'condition': 'Kondisi baik',
      'image': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600',
    },
    {
      'name': 'Casual Jeans',
      'price': 'Rp65.000',
      'condition': 'Kondisi sangat baik',
      'image': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600',
    },
    {
      'name': 'Knit Sweater',
      'price': 'Rp55.000',
      'condition': 'Kondisi baik',
      'image': 'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=600',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: FavoriteStore.favorites,
        builder: (context, favorites, _) {
          final items = products
              .where((p) => favorites.contains(p['name']))
              .toList();

          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 64, color: Color(0xFF245C4A)),
                    SizedBox(height: 12),
                    Text('Belum ada favorit',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 6),
                    Text(
                      'Tekan ikon hati pada produk yang kamu sukai.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .72,
            ),
            itemBuilder: (_, index) {
              final p = items[index];
              return ProductCard(
                name: p['name']!,
                price: p['price']!,
                condition: p['condition']!,
                imageUrl: p['image']!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailPage(
                    name: p['name']!, price: p['price']!,
                    condition: p['condition']!, imageUrl: p['image']!)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _Menu({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE5EEE9),
            child: Icon(icon, color: const Color(0xFF245C4A)),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: trailing == null
              ? const Icon(Icons.chevron_right_rounded)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFFE5EEE9),
                      child: Text(
                        trailing!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF245C4A),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
          onTap: onTap,
        ),
      );
}
