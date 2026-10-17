import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../store/product_store.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final picker = ImagePicker();
  String condition = 'Sangat baik';
  Uint8List? photo;

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    if (photo != null) return;
    try {
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() => photo = bytes);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih foto. Coba lagi.')),
      );
    }
  }

  String formatPrice(int value) =>
      'Rp${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

  void submitProduct() {
    final name = nameController.text.trim();
    final price = int.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));

    if (name.isEmpty || price == null || price <= 0 || photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama, harga, dan pilih foto produk.')),
      );
      return;
    }

    ProductStore.add(ProductItem(
      name: name, price: formatPrice(price),
      condition: 'Kondisi $condition', images: [photo!],
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dipasang!')),
    );
    nameController.clear();
    priceController.clear();
    setState(() { photo = null; condition = 'Sangat baik'; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jual Barang', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      const Text('Pasang produk preloved kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Isi informasi produk dengan jelas agar lebih menarik.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      GestureDetector(
        onTap: photo == null ? pickPhoto : null,
        child: Container(
          height: 150,
          decoration: BoxDecoration(color: const Color(0xFFE5EEE9), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD5E2DC))),
          child: photo == null
              ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_a_photo_outlined, size: 34, color: Color(0xFF245C4A)),
                  SizedBox(height: 8),
                  Text('Tambah foto produk', style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 3),
                  Text('Pilih 1 foto saja', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ])
              : Stack(children: [
                  Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(19), child: Image.memory(photo!, fit: BoxFit.contain))),
                  Positioned(top: 6, right: 6, child: IconButton(
                    onPressed: () => setState(() => photo = null),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  )),
                ]),
        ),
      ),
      const SizedBox(height: 16),
      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama produk')),
      const SizedBox(height: 12),
      TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga (Rp)')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: condition,
        decoration: const InputDecoration(labelText: 'Kondisi barang'),
        items: const [
          DropdownMenuItem(value: 'Seperti baru', child: Text('Seperti baru')),
          DropdownMenuItem(value: 'Sangat baik', child: Text('Sangat baik')),
          DropdownMenuItem(value: 'Cukup baik', child: Text('Cukup baik')),
        ],
        onChanged: (v) => setState(() => condition = v ?? condition),
      ),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: submitProduct, child: const Text('Pasang Produk')),
    ]),
  );
}
