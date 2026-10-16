import 'package:flutter/material.dart';
import 'sell_page.dart';
import 'cart_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          const CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFE5EEE9),
            child: Icon(Icons.person, size: 46, color: Color(0xFF245C4A)),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Pengguna PreloWear', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const Center(child: Text('Belum masuk akun', style: TextStyle(color: Colors.black54))),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.sell_outlined),
            title: const Text('Jual Barang'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellPage())),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Keranjang Saya'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Tentang PreloWear'),
            subtitle: Text('Marketplace pakaian preloved untuk semua kalangan.'),
          ),
        ],
      ),
    );
  }
}
