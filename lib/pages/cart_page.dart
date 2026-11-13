import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../store/cart_store.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Widget noImage() => const SizedBox(
    width: 76, height: 76,
    child: ColoredBox(color: Color(0xFFE8EEEB),
      child: Icon(Icons.image_not_supported_outlined,
          color: Color(0xFF89AC46))),
  );

  Widget productImage(Map<String, dynamic> p) {
    final bytes = p['imageBytes'] as Uint8List?;
    final assets = p['imageAssets'] as List<String>? ?? [];
    final asset = p['imageAsset'] as String?;
    final url = p['image'] as String? ?? '';

    if (bytes != null) {
      return Image.memory(bytes, width: 76, height: 76,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => noImage());
    }
    if (assets.isNotEmpty) {
      return Image.asset(assets.first, width: 76, height: 76,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => noImage());
    }
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(asset, width: 76, height: 76,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => noImage());
    }
    if (url.isNotEmpty) {
      return Image.network(url, width: 76, height: 76,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => noImage());
    }
    return noImage();
  }

  int priceNumber(String? price) =>
      int.tryParse((price ?? '').replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  String formatPrice(int value) =>
      'Rp${value.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text('Keranjang',
        style: TextStyle(fontWeight: FontWeight.w800))),
    body: ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: CartStore.items,
      builder: (_, items, __) {
        if (items.isEmpty) {
          return const Center(child: Text('Keranjang Kosong'));
        }

        final selectedItems = items.where(
            (p) => p['selected'] as bool? ?? true).toList();

        final allSelected = selectedItems.length == items.length;

        final totalItems = selectedItems.fold<int>(0,
            (sum, p) => sum + (p['quantity'] as int? ?? 1));

        final total = selectedItems.fold<int>(0, (sum, p) =>
            sum + priceNumber(p['price'] as String?) *
                (p['quantity'] as int? ?? 1));

        final names = selectedItems.map(
            (p) => p['name'] as String? ?? '').join(', ');

        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Checkbox(
              value: allSelected,
              activeColor: const Color(0xFF89AC46),
              onChanged: (value) =>
                  CartStore.setAllSelected(value ?? false),
            ),
            const Text('Pilih semua',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),

          ...items.asMap().entries.map((e) {
            final p = e.value;
            final qty = p['quantity'] as int? ?? 1;
            final selected = p['selected'] as bool? ?? true;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Checkbox(
                    value: selected,
                    activeColor: const Color(0xFF89AC46),
                    onChanged: (value) =>
                        CartStore.setSelected(e.key, value ?? false),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: productImage(p)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] as String? ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(p['price'] as String? ?? '',
                          style: const TextStyle(color: Color(0xFF89AC46))),
                      Row(children: [
                        IconButton(
                          onPressed: () => CartStore.decrease(e.key),
                          icon: const Icon(Icons.remove_circle_outline),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                              width: 32, height: 32)),
                        Text('$qty', style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => CartStore.increase(e.key),
                          icon: const Icon(Icons.add_circle_outline),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                              width: 32, height: 32)),
                      ]),
                    ],
                  )),
                  IconButton(
                    onPressed: () => CartStore.remove(e.key),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent)),
                ]),
              ),
            );
          }),

          const SizedBox(height: 16),
          const Text('Ringkasan Pesanan', style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Total item dipilih: $totalItems'),
          const SizedBox(height: 4),
          Row(children: [
            const Text('Total harga',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(formatPrice(total), style: const TextStyle(
                color: Color(0xFF89AC46), fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: selectedItems.isEmpty ? null : () =>
                Navigator.push(c, MaterialPageRoute(
                  builder: (_) => CheckoutPage(
                    productName: names,
                    productPrice: formatPrice(total),
                    fromCart: true,
                  ),
                )),
            child: const Text('Lanjut Checkout')),
        ]);
      },
    ),
  );
}
