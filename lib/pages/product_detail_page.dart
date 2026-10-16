import 'package:flutter/material.dart';
import 'checkout_page.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});
  static const green = Color(0xFF245C4A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk', style: TextStyle(fontWeight: FontWeight.w800)), actions: [
        IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())), icon: const Icon(Icons.shopping_bag_outlined)),
      ]),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.network(
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=1000', height: 330, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox(height: 330, child: Icon(Icons.image_not_supported_outlined, size: 60)),
        )),
        const SizedBox(height: 18),
        const Text('Basic Cotton T-Shirt', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Rp45.000', style: TextStyle(fontSize: 22, color: green, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          Chip(avatar: const Icon(Icons.check_circle_outline, size: 16), label: const Text('Kondisi sangat baik')),
          const Chip(label: Text('Ukuran M')),
        ]),
        const Divider(height: 28),
        const Text('Deskripsi Produk', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Kaos preloved yang nyaman digunakan untuk aktivitas sehari-hari. Kondisi terawat dan siap digunakan kembali.'),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())), icon: const Icon(Icons.add_shopping_cart), label: const Text('Keranjang'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage())), icon: const Icon(Icons.flash_on), label: const Text('Beli Sekarang'))),
        ]),
      ]),
    );
  }
}
