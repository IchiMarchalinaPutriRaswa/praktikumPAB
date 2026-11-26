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

  static const green = Color(0xFF89AC46);
  static const paleGreen = Color(0xFFE5EEE9);

  String paymentMethod = 'Virtual Account';
  String selectedBank = 'BCA';
  String selectedWallet = 'DANA';

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Widget optionChip(String label, bool selected,
      VoidCallback onTap) => ChoiceChip(
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    onSelected: (_) => setState(onTap),
    selectedColor: paleGreen,
    backgroundColor: Colors.white,
    side: BorderSide(
      color: selected ? green : const Color(0xFFD8E3DD),
      width: selected ? 2 : 1,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14)),
    labelStyle: TextStyle(
      fontWeight: FontWeight.w700,
      color: selected ? green : Colors.black87,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 12, vertical: 10),
  );

  Widget sectionLabel(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: const TextStyle(
      fontSize: 17, fontWeight: FontWeight.w800)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Checkout',
      style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.all(16),
      children: [
        sectionLabel('Informasi Pengiriman'),
        TextField(controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama penerima')),
        const SizedBox(height: 12),
        TextField(controller: addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Alamat lengkap')),
        const SizedBox(height: 24),

        sectionLabel('Metode Pembayaran'),
        Wrap(spacing: 8, runSpacing: 8, children: [
          optionChip('Virtual Account',
            paymentMethod == 'Virtual Account',
            () => paymentMethod = 'Virtual Account'),
          optionChip('QRIS', paymentMethod == 'QRIS',
            () => paymentMethod = 'QRIS'),
          optionChip('E-Wallet', paymentMethod == 'E-Wallet',
            () => paymentMethod = 'E-Wallet'),
          optionChip('COD', paymentMethod == 'COD',
            () => paymentMethod = 'COD'),
        ]),

        if (paymentMethod == 'Virtual Account') ...[
          const SizedBox(height: 20),
          sectionLabel('Pilih Bank'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final bank in [
              'BCA', 'BRI', 'BNI', 'Mandiri', 'BSI'
            ])
              optionChip(bank, selectedBank == bank,
                () => selectedBank = bank),
          ]),
        ],

        if (paymentMethod == 'E-Wallet') ...[
          const SizedBox(height: 20),
          sectionLabel('Pilih E-Wallet'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final wallet in ['DANA', 'OVO', 'GoPay'])
              optionChip(wallet, selectedWallet == wallet,
                () => selectedWallet = wallet),
          ]),
        ],

        if (paymentMethod == 'QRIS') ...[
          const SizedBox(height: 14),
          const Text('Pembayaran menggunakan pemindaian QRIS.',
            style: TextStyle(color: Colors.black54)),
        ],

        const SizedBox(height: 24),
        sectionLabel('Ringkasan Pesanan'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(widget.productName)),
                const SizedBox(width: 8),
                Text(widget.productPrice),
              ]),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.w800)),
                Text(widget.productPrice,
                  style: const TextStyle(fontSize: 18,
                    color: green, fontWeight: FontWeight.w800)),
              ]),
          ]),
        ),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _submit,
            child: const Text('Lanjut Pembayaran'),
          ),
        ),
      ]),
  );

  void _submit() {
    if (nameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          'Lengkapi nama dan alamat terlebih dahulu.')));
      return;
    }

    final cartItems = CartStore.items.value
      .where((item) => item['selected'] == true)
      .map((item) => Map<String, dynamic>.from(item)).toList();

    if (widget.fromCart && cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          'Pilih produk yang ingin dibeli terlebih dahulu.')));
      return;
    }

    final items = widget.fromCart ? cartItems : [
      {'name': widget.productName,
       'price': widget.productPrice, 'quantity': 1}
    ];

    String payment = paymentMethod;
    if (paymentMethod == 'Virtual Account') {
      payment = 'Virtual Account - $selectedBank';
    } else if (paymentMethod == 'E-Wallet') {
      payment = 'E-Wallet - $selectedWallet';
    }

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
