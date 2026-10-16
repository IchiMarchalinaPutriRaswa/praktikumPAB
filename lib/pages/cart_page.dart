import 'package:flutter/material.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Image.network(
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=200',
                width: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(width: 56, child: Icon(Icons.checkroom)),
              ),
              title: const Text('Basic Cotton T-Shirt'),
              subtitle: const Text('Ukuran M'),
              trailing: const Text('Rp45.000', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Subtotal'),
            trailing: Text('Rp45.000'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Total'),
            trailing: Text('Rp45.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage())),
              child: const Text('Lanjut Checkout'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keranjang ini masih berisi contoh produk untuk tampilan awal.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
