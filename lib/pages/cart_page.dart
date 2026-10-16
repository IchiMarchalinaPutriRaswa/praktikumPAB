import 'package:flutter/material.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network('https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=300', width: 82, height: 82, fit: BoxFit.cover)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Basic Cotton T-Shirt', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 5), Text('Ukuran M', style: TextStyle(color: Colors.black54, fontSize: 12)),
              SizedBox(height: 8), Text('Rp45.000', style: TextStyle(color: Color(0xFF245C4A), fontWeight: FontWeight.w800)),
            ])),
            IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline_rounded)),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const _Row(label: 'Subtotal', value: 'Rp45.000'),
        const _Row(label: 'Biaya pengiriman', value: 'Rp0'),
        const Divider(height: 20),
        const _Row(label: 'Total', value: 'Rp45.000', bold: true),
        const SizedBox(height: 18),
        ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage())), child: const Text('Lanjut Checkout')),
      ]),
    );
  }
}
class _Row extends StatelessWidget {
  final String label, value; final bool bold;
  const _Row({required this.label, required this.value, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.normal)),
      Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.normal, fontSize: bold ? 18 : 14)),
    ]),
  );
}
