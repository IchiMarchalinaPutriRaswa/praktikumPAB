import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../product_store.dart';

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
  List<Uint8List> photos = [];

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> pickPhotos() async {
    try {
      final files = await picker.pickMultiImage();
      if (files.isEmpty || !mounted) return;

      final bytes = await Future.wait(files.take(5).map((f) => f.readAsBytes()));
      if (!mounted) return;
      setState(() => photos = bytes);

      if (files.length > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maksimal 5 foto yang digunakan.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih foto. Coba lagi.')),
        );
      }
    }
  }

  String formatPrice(int value) => 'Rp${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

  void submitProduct() {
    final name = nameController.text.trim();
    final price = int.tryParse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));

    if (name.isEmpty || price == null || price <= 0 || photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama, harga, dan pilih foto produk.')),
      );
      return;
    }

    ProductStore.add(ProductItem(
      name: name, price: formatPrice(price),
      condition: 'Kondisi $condition', images: List<Uint8List>.from(photos),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dipasang!')),
    );

    nameController.clear();
    priceController.clear();
    setState(() {
      photos = [];
      condition = 'Sangat baik';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jual Barang', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        const Text('Pasang produk preloved kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Isi informasi produk dengan jelas agar lebih menarik.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: pickPhotos,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EEE9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD5E2DC)),
            ),
            child: photos.isEmpty
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 34, color: Color(0xFF245C4A)),
                      SizedBox(height: 8),
                      Text('Tambah foto produk', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 3),
                      Text('Pilih hingga 5 foto', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    children: [
                      ...photos.map((photo) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(photo, width: 125, height: 130, fit: BoxFit.cover),
                        ),
                      )),
                      const Center(child: Icon(Icons.add_a_photo, size: 28)),
                    ],
                  ),
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
      ],
    ),
  );
}