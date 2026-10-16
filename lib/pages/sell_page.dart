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
  void dispose() { nameController.dispose(); priceController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jual Barang', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      const Text('Pasang produk preloved kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6), const Text('Isi informasi produk dengan jelas agar lebih menarik.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18),
      GestureDetector(
        onTap: () {},
        child: Container(height: 150, decoration: BoxDecoration(color: const Color(0xFFE5EEE9), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD5E2DC))),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 34, color: Color(0xFF245C4A)), SizedBox(height: 8), Text('Tambah foto produk', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 3), Text('Maks. 5 foto', style: TextStyle(fontSize: 11, color: Colors.black54))])),
      ),
      const SizedBox(height: 16),
      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nama produk')),
      const SizedBox(height: 12),
      TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga (Rp)')),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: condition, decoration: const InputDecoration(labelText: 'Kondisi barang'), items: const [
        DropdownMenuItem(value:'Seperti baru', child: Text('Seperti baru')), DropdownMenuItem(value:'Sangat baik', child: Text('Sangat baik')), DropdownMenuItem(value:'Cukup baik', child: Text('Cukup baik')),
      ], onChanged: (v) => setState(() => condition = v ?? condition)),
      const SizedBox(height: 20),
      ElevatedButton(onPressed: () {
        if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi nama produk dan harga terlebih dahulu.'))); return;
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk siap dipasang.')));
      }, child: const Text('Pasang Produk')),
    ]),
  );
}
