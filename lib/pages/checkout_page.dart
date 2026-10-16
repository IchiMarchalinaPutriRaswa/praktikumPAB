import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Informasi Pengiriman', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama penerima', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Alamat lengkap', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          const Text('Metode Pembayaran', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          RadioListTile<String>(
            value: 'Transfer bank',
            groupValue: payment,
            title: const Text('Transfer bank'),
            onChanged: (value) => setState(() => payment = value!),
          ),
          RadioListTile<String>(
            value: 'COD',
            groupValue: payment,
            title: const Text('Bayar di tempat (COD)'),
            onChanged: (value) => setState(() => payment = value!),
          ),
          const Divider(height: 28),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Basic Cotton T-Shirt'),
            subtitle: Text('1 barang'),
            trailing: Text('Rp45.000', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Total'),
            trailing: Text('Rp45.000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty || addressController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lengkapi nama dan alamat terlebih dahulu.')),
                );
                return;
              }
              showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Pesanan dicatat'),
                  content: Text('Metode pembayaran: $payment\\nIni masih simulasi, belum ada pembayaran sungguhan.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      child: const Text('Selesai'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Buat Pesanan'),
          ),
        ],
      ),
    );
  }
}
