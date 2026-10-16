import 'package:flutter/material.dart';
import 'checkout_page.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  static const green = Color(0xFF245C4A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=900',
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 280, color: Colors.black12,
                child: const Icon(Icons.image_not_supported_outlined, size: 60),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Basic Cotton T-Shirt', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Rp45.000', style: TextStyle(fontSize: 21, color: green, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Kondisi sangat baik • Ukuran M'),
          const Divider(height: 28),
          const Text('Deskripsi Produk', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Kaos preloved yang nyaman digunakan untuk aktivitas sehari-hari. Kondisi terawat dan siap digunakan kembali.'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage())),
            icon: const Icon(Icons.flash_on),
            label: const Text('Beli Sekarang'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Lihat Keranjang'),
          ),
        ],
      ),
    );
  }
}
