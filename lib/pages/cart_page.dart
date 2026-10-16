import 'package:flutter/material.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool adaProduk = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w800))),
      body: !adaProduk
          ? const Center(child: Text('Keranjang Kosong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300',
                          width: 82, height: 82, fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Basic Cotton T-Shirt', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text('Ukuran M', style: TextStyle(color: Colors.black54)),
                            SizedBox(height: 8),
                            Text('Rp45.000', style: TextStyle(color: Color(0xFF245C4A), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => adaProduk = false),
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Subtotal'), Text('Rp45.000')]),
                const SizedBox(height: 8),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Biaya pengiriman'), Text('Rp0')]),
                const Divider(height: 24),
                const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Rp45.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage())),
                  child: const Text('Lanjut Checkout'),
                ),
              ],
            ),
    );
  }
}
