import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/product.dart';
import '../data/formatters.dart';

class CartPage extends StatelessWidget {
  const CartPage({
    super.key,
    required this.products,
    required this.quantities,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onContinueShopping,
    required this.onCheckout,
  });

  final List<PreloProduct> products;
  final Map<String, int> quantities;
  final void Function(String productId, int quantity) onQuantityChanged;
  final ValueChanged<String> onRemove;
  final VoidCallback onContinueShopping;
  final ValueChanged<int> onCheckout;

  int get _totalItems => products.fold(0, (sum, product) => sum + (quantities[product.id] ?? 0));
  int get _subtotal => products.fold(0, (sum, product) => sum + parseRupiah(product.price) * (quantities[product.id] ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang belanja', style: TextStyle(fontWeight: FontWeight.w900))),
      body: LayoutBuilder(builder: (context, constraints) {
        final side = constraints.maxWidth >= 900 ? 32.0 : 16.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(side, 12, side, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: products.isEmpty ? _emptyState() : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_totalItems item di keranjang', style: const TextStyle(color: kMuted, fontSize: 13)),
                  const SizedBox(height: 14),
                  LayoutBuilder(builder: (context, layout) {
                    if (layout.maxWidth < 760) {
                      return Column(children: [
                        _cartItems(),
                        const SizedBox(height: 16),
                        _summary(),
                      ]);
                    }
                    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(flex: 7, child: _cartItems()),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: _summary()),
                    ]);
                  }),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _emptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          Container(width: 76, height: 76, decoration: const BoxDecoration(color: Color(0xFFE7F2EC), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_bag_outlined, size: 36, color: kBrand)),
          const SizedBox(height: 18),
          const Text('Keranjangmu masih kosong', style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 19)),
          const SizedBox(height: 7),
          const Text('Temukan pakaian preloved favoritmu dengan harga yang lebih ramah.', textAlign: TextAlign.center,
              style: TextStyle(color: kMuted, height: 1.5, fontSize: 13)),
          const SizedBox(height: 18),
          ElevatedButton.icon(onPressed: onContinueShopping, icon: const Icon(Icons.search_rounded), label: const Text('Jelajahi produk')),
        ]),
      );

  Widget _cartItems() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE6DD))),
        child: Column(children: [
          for (var i = 0; i < products.length; i++) ...[
            _CartItemRow(
              product: products[i],
              quantity: quantities[products[i].id] ?? 1,
              onDecrease: () => onQuantityChanged(products[i].id, (quantities[products[i].id] ?? 1) - 1),
              onIncrease: () => onQuantityChanged(products[i].id, (quantities[products[i].id] ?? 1) + 1),
              onRemove: () => onRemove(products[i].id),
            ),
            if (i < products.length - 1) const Divider(height: 24, color: Color(0xFFEFEAE2)),
          ],
        ]),
      );

  Widget _summary() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE6DD))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Ringkasan belanja', style: TextStyle(color: kText, fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          Row(children: [const Expanded(child: Text('Total item', style: TextStyle(color: kMuted, fontSize: 13))), Text('$_totalItems', style: const TextStyle(color: kText, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 12),
          Row(children: [const Expanded(child: Text('Subtotal', style: TextStyle(color: kMuted, fontSize: 13))), Text(formatRupiah(_subtotal), style: const TextStyle(color: kText, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 12),
          const Row(children: [Expanded(child: Text('Pengiriman', style: TextStyle(color: kMuted, fontSize: 13))), Text('Dihitung nanti', style: TextStyle(color: kMuted, fontSize: 12))]),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFEFEAE2))),
          Row(children: [const Expanded(child: Text('Total sementara', style: TextStyle(color: kText, fontWeight: FontWeight.w800))), Flexible(child: Text(formatRupiah(_subtotal), textAlign: TextAlign.end, style: const TextStyle(color: kBrand, fontWeight: FontWeight.w900, fontSize: 18)))]),
          const SizedBox(height: 17),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => onCheckout(_subtotal), icon: const Icon(Icons.lock_outline_rounded), label: const Text('Lanjut checkout'))),
          const SizedBox(height: 10),
          const Text('Checkout ini simulasi untuk tugas. Belum terhubung ke pembayaran atau pengiriman sungguhan.', style: TextStyle(color: kMuted, fontSize: 11, height: 1.4)),
        ]),
      );
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.product, required this.quantity, required this.onDecrease, required this.onIncrease, required this.onRemove});
  final PreloProduct product;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 88, height: 96, child: product.imageAsset != null
              ? Image.asset(product.imageAsset!, fit: BoxFit.cover)
              : Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/preloved_shirt_product.png', fit: BoxFit.cover))),
        ),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.category.toUpperCase(), style: const TextStyle(color: kMuted, fontWeight: FontWeight.w800, fontSize: 9, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: kText, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 5),
          Text(product.price, style: const TextStyle(color: kBrand, fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(height: 9),
          Row(children: [
            _QuantityButton(icon: Icons.remove_rounded, onPressed: onDecrease),
            SizedBox(width: 34, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800))),
            _QuantityButton(icon: Icons.add_rounded, onPressed: onIncrease),
            const SizedBox(width: 8),
            IconButton(tooltip: 'Hapus item', visualDensity: VisualDensity.compact, onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB84F61), size: 19)),
          ]),
        ])),
      ]);
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 29,
        height: 29,
        child: IconButton.filledTonal(
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
        ),
      );
}
