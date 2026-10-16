import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../cart_store.dart';
import 'cart_page.dart';
import 'checkout_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String name, price, condition, imageUrl;
  final Uint8List? imageBytes;

  const ProductDetailPage({
    super.key, required this.name, required this.price,
    required this.condition, required this.imageUrl, this.imageBytes,
  });

  void addCart(BuildContext c) {
    CartStore.add(name, price, imageUrl, imageBytes: imageBytes);
    ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
      content: Text('Produk berhasil ditambahkan ke keranjang'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(
      title: const Text('Detail Produk'),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const CartPage())),
          icon: const Icon(Icons.shopping_bag_outlined),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: imageBytes != null
                  ? Image.memory(imageBytes!, height: 330, fit: BoxFit.cover)
                  : Image.network(
                      imageUrl, height: 330, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 330,
                        child: Center(child: Icon(Icons.image_not_supported_outlined, size: 48)),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(price, style: const TextStyle(fontSize: 22, color: Color(0xFF245C4A), fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Chip(label: Text(condition)),
        const Divider(height: 28),
        const Text('Deskripsi Produk', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Produk preloved yang nyaman digunakan dan masih terawat.'),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => addCart(c),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Keranjang'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const CheckoutPage())),
              icon: const Icon(Icons.flash_on),
              label: const Text('Beli Sekarang'),
            ),
          ),
        ]),
      ],
    ),
  );
}