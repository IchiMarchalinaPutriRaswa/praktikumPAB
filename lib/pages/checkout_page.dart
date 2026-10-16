import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/formatters.dart';
import '../models/product.dart';

/// Halaman checkout dengan tombol aksi utama (ElevatedButton).
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key, required this.products, required this.quantities, required this.onConfirm});
  final List<PreloProduct> products;
  final Map<String, int> quantities;
  final VoidCallback onConfirm;

  int get _itemCount => products.fold(0, (sum, product) => sum + (quantities[product.id] ?? 0));
  int get _subtotal => products.fold(0, (sum, product) => sum + parseRupiah(product.price) * (quantities[product.id] ?? 0));
  static const int _shipping = 10000;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Checkout pesanan', style: TextStyle(fontWeight: FontWeight.w900))),
    body: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(constraints.maxWidth > 900 ? 32 : 16, 16, constraints.maxWidth > 900 ? 32 : 16, 32),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 860), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Periksa pesananmu', style: TextStyle(fontSize: 24, color: kText, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Pastikan daftar barang dan ringkasan biaya sudah sesuai.', style: TextStyle(color: kMuted, fontSize: 13)),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFECE6DD))),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.location_on_outlined, color: kBrand, size: 25), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Alamat pengiriman', style: TextStyle(color: kText, fontWeight: FontWeight.w900)), SizedBox(height: 5),
                Text('Alamat contoh untuk pratinjau. Aplikasi ini belum terhubung ke layanan pengiriman.', style: TextStyle(color: kMuted, fontSize: 12, height: 1.45)),
              ])),
            ])),
          const SizedBox(height: 16),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFECE6DD))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ringkasan barang', style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 14),
              for (final product in products) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
                Expanded(child: Text('${product.name} × ${quantities[product.id] ?? 0}', style: const TextStyle(color: kText, fontSize: 12))),
                const SizedBox(width: 10), Text(formatRupiah(parseRupiah(product.price) * (quantities[product.id] ?? 0)), style: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 12)),
              ])),
              const Divider(color: Color(0xFFECE6DD)),
              const SizedBox(height: 8),
              _PriceRow(label: 'Jumlah barang', value: '$_itemCount item'),
              const SizedBox(height: 10),
              _PriceRow(label: 'Subtotal', value: formatRupiah(_subtotal)),
              const SizedBox(height: 10),
              _PriceRow(label: 'Estimasi ongkir', value: formatRupiah(_shipping)),
              const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(color: Color(0xFFECE6DD))),
              _PriceRow(label: 'Total simulasi', value: formatRupiah(_subtotal + _shipping), isTotal: true),
            ])),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: products.isEmpty ? null : () { onConfirm(); Navigator.of(context).pop(); },
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Konfirmasi pesanan (simulasi)'),
          )),
          const SizedBox(height: 10),
          const Center(child: Text('Belum ada pembayaran asli. Tombol ini menyelesaikan simulasi tugas.', textAlign: TextAlign.center, style: TextStyle(color: kMuted, fontSize: 11))),
        ],
      ))),
    )),
  );
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.isTotal = false});
  final String label;
  final String value;
  final bool isTotal;
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: TextStyle(color: isTotal ? kText : kMuted, fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500))),
    Text(value, style: TextStyle(color: isTotal ? kBrand : kText, fontWeight: FontWeight.w900, fontSize: isTotal ? 18 : 13)),
  ]);
}
