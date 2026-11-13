
import 'package:flutter/material.dart';
import '../store/cart_store.dart';
import '../store/order_store.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  final String productName, productPrice;
  final bool fromCart;

  const CheckoutPage({
    super.key,
    required this.productName,
    required this.productPrice,
    this.fromCart = false,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  String payment = 'Transfer bank';

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Checkout',
      style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const Text('Informasi Pengiriman',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        TextField(controller: nameController,
          decoration: const InputDecoration(labelText: 'Nama penerima')),
        const SizedBox(height: 12),
        TextField(controller: addressController, maxLines: 3,
          decoration: const InputDecoration(labelText: 'Alamat lengkap')),
        const SizedBox(height: 22),
        const Text('Metode Pembayaran',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        _PaymentTile(title: 'Transfer bank',
          icon: Icons.account_balance_outlined, value: 'Transfer bank',
          groupValue: payment,
          onChanged: (v) => setState(() => payment = v!)),
        _PaymentTile(title: 'E-Wallet',
          icon: Icons.account_balance_wallet_outlined, value: 'E-Wallet',
          groupValue: payment,
          onChanged: (v) => setState(() => payment = v!)),
        _PaymentTile(title: 'Virtual Account',
          icon: Icons.receipt_long_outlined, value: 'Virtual Account',
          groupValue: payment,
          onChanged: (v) => setState(() => payment = v!)),
        _PaymentTile(title: 'Bayar di tempat (COD)',
          icon: Icons.local_shipping_outlined, value: 'COD',
          groupValue: payment,
          onChanged: (v) => setState(() => payment = v!)),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(widget.productName)),
                const SizedBox(width: 8),
                Text(widget.productPrice,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            const SizedBox(height: 12),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.w800)),
                Text(widget.productPrice,
                  style: const TextStyle(fontSize: 18,
                    color: Color(0xFF89AC46),
                    fontWeight: FontWeight.w800)),
              ]),
          ]),
        ),
        const SizedBox(height: 18),
        ElevatedButton(onPressed: _submit,
          child: const Text('Lanjut Pembayaran')),
      ]),
  );

  void _submit() {
    if (nameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lengkapi nama dan alamat terlebih dahulu.')));
      return;
    }

    final cartItems = CartStore.items.value
        .where((item) => item['selected'] == true)
        .map((item) => Map<String, dynamic>.from(item)).toList();

    if (widget.fromCart && cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pilih produk yang ingin dibeli terlebih dahulu.')));
      return;
    }

    final items = widget.fromCart
        ? cartItems
        : [
            {
              'name': widget.productName,
              'price': widget.productPrice,
              'quantity': 1,
            }
          ];

    final orderId = OrderStore.addOrder(
      items: items,
      buyerName: nameController.text.trim(),
      address: addressController.text.trim(),
      payment: payment,
      totalPrice: widget.productPrice,
      fromCart: widget.fromCart,
    );

    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) =>
        PaymentPage(orderId: orderId)));
  }
}

class _PaymentTile extends StatelessWidget {
  final String title, value, groupValue;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _PaymentTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(16)),
    child: RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title),
      secondary: Icon(icon, color: const Color(0xFF89AC46)),
    ),
  );
}
