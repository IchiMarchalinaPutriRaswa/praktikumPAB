import 'package:flutter/material.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  String condition = 'Sangat baik';

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jual Barang')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pasang produk preloved kamu', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nama produk', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Harga (Rp)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: condition,
            decoration: const InputDecoration(labelText: 'Kondisi barang', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'Seperti baru', child: Text('Seperti baru')),
              DropdownMenuItem(value: 'Sangat baik', child: Text('Sangat baik')),
              DropdownMenuItem(value: 'Cukup baik', child: Text('Cukup baik')),
            ],
            onChanged: (value) => setState(() => condition = value ?? condition),
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EEE9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, size: 32),
                SizedBox(height: 6),
                Text('Foto produk (fitur belum diaktifkan)'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Isi nama produk dan harga terlebih dahulu.')),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Form valid. Penyimpanan produk belum terhubung ke database.')),
              );
            },
            child: const Text('Pasang Produk'),
          ),
        ],
      ),
    );
  }
}
