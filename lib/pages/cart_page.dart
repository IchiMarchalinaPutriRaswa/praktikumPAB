import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../cart_store.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Widget noImage() => const SizedBox(
    width: 76, height: 76,
    child: ColoredBox(
      color: Color(0xFFE8EEEB),
      child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF245C4A)),
    ),
  );

  Widget productImage(Map<String, dynamic> p) {
    final bytes = p['imageBytes'] as Uint8List?;
    final url = p['image'] as String? ?? '';

    if (bytes != null) return Image.memory(bytes, width: 76, height: 76, fit: BoxFit.cover);
    if (url.isEmpty) return noImage();

    return Image.network(url, width: 76, height: 76, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => noImage());
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: CartStore.items,
      builder: (_, items, __) {
        if (items.isEmpty) return const Center(child: Text('Keranjang Kosong'));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...items.asMap().entries.map((e) {
              final p = e.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: productImage(p)),
                  title: Text(p['name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p['price'] as String? ?? ''),
                  trailing: IconButton(
                    onPressed: () => CartStore.remove(e.key),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Hapus produk',
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            const Text('Ringkasan Pesanan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Total item: ${items.length}'),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const CheckoutPage())),
              child: const Text('Lanjut Checkout'),
            ),
          ],
        );
      },
    ),
  );
}