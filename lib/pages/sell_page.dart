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
  final formKey = GlobalKey<FormState>(), pickerKey = GlobalKey();
  final nameController = TextEditingController(), priceController = TextEditingController();
  final chestController = TextEditingController(), lengthController = TextEditingController();
  final shoulderController = TextEditingController(), sleeveController = TextEditingController();
  final descriptionController = TextEditingController(), defectsController = TextEditingController();
  final picker = ImagePicker();
  String condition = 'Sangat baik';
  String? sizeLabel;
  Uint8List? photo, evidencePhoto;
  bool hasStain = false, hasHole = false, hasDamagedSeam = false, hasFadedColor = false;

  @override
  void dispose() {
    for (final c in [nameController, priceController, chestController, lengthController, shoulderController, sleeveController, descriptionController, defectsController]) { c.dispose(); }
    super.dispose();
  }

  Future<void> pickPhoto({required bool evidence}) async {
    try {
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null || !mounted) return;
      final bytes = await file.readAsBytes();
      if (mounted) setState(() { if (evidence) { evidencePhoto = bytes; } else { photo = bytes; } });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memilih foto. Coba lagi.')));
    }
  }

  String formatPrice(int v) => 'Rp${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
  double? measure(TextEditingController c) => c.text.trim().isEmpty ? null : double.tryParse(c.text.trim().replaceAll(',', '.'));

  Widget field(String label, TextEditingController c, {bool required = false, bool numeric = false, bool price = false, int maxLines = 1, String? helper}) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: TextFormField(controller: c, maxLines: maxLines,
      keyboardType: price ? TextInputType.number : numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, helperText: helper),
      validator: (v) {
        final text = v?.trim() ?? '';
        if (required && text.isEmpty) return '$label wajib diisi.';
        if (price && text.isNotEmpty) { final n = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')); if (n == null || n <= 0) return 'Masukkan harga yang valid.'; }
        else if (numeric && text.isNotEmpty) { final n = double.tryParse(text.replaceAll(',', '.')); if (n == null || n <= 0) return 'Masukkan ukuran lebih dari 0 cm.'; }
        return null;
      },
    ),
  );

  Widget photoPicker({required bool evidence}) {
    final bytes = evidence ? evidencePhoto : photo;
    return GestureDetector(onTap: () => pickPhoto(evidence: evidence), child: Container(
      height: evidence ? 118 : 150,
      decoration: BoxDecoration(color: const Color(0xFFE5EEE9), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD5E2DC))),
      child: bytes == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.add_a_photo_outlined, size: evidence ? 28 : 34, color: const Color(0xFF89AC46)),
        const SizedBox(height: 7), Text(evidence ? 'Tambah foto kondisi' : 'Tambah foto produk', style: const TextStyle(fontWeight: FontWeight.w700)),
        if (!evidence) const Text('Pilih 1 foto utama', style: TextStyle(fontSize: 11, color: Colors.black54)),
      ]) : Stack(children: [
        Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(19), child: Image.memory(bytes, fit: BoxFit.contain))),
        Positioned(top: 5, right: 5, child: IconButton(onPressed: () => setState(() { if (evidence) { evidencePhoto = null; } else { photo = null; } }), icon: const Icon(Icons.close), style: IconButton.styleFrom(backgroundColor: Colors.white))),
      ]),
    ));
  }

  String buildDefects() {
    final values = <String>[
      if (hasStain) 'Terdapat noda', if (hasHole) 'Terdapat lubang',
      if (hasDamagedSeam) 'Jahitan rusak', if (hasFadedColor) 'Warna memudar',
      if (defectsController.text.trim().isNotEmpty) defectsController.text.trim(),
    ];
    return values.isEmpty ? 'Tidak ada kekurangan yang diketahui penjual.' : values.join('. ');
  }

  void submitProduct() {
    if (!formKey.currentState!.validate()) return;
    if (photo == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih foto utama produk terlebih dahulu.'))); return; }
    final price = int.parse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    ProductStore.add(ProductItem(
      name: nameController.text.trim(), price: formatPrice(price), condition: 'Kondisi $condition', images: [photo!],
      sizeLabel: sizeLabel!, chestCm: measure(chestController), lengthCm: measure(lengthController),
      shoulderCm: measure(shoulderController), sleeveCm: measure(sleeveController),
      description: descriptionController.text.trim().isEmpty ? 'Deskripsi produk belum ditambahkan oleh penjual.' : descriptionController.text.trim(),
      defects: buildDefects(), evidenceImage: evidencePhoto,
    ));
    for (final c in [nameController, priceController, chestController, lengthController, shoulderController, sleeveController, descriptionController, defectsController]) { c.clear(); }
    setState(() { photo = null; evidencePhoto = null; condition = 'Sangat baik'; sizeLabel = null; hasStain = false; hasHole = false; hasDamagedSeam = false; hasFadedColor = false; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil dipasang!')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jual Barang', style: TextStyle(fontWeight: FontWeight.w800))),
    body: Form(key: formKey, child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
      const Text('Pasang produk preloved kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6), const Text('Lengkapi informasi produk agar pembeli dapat menilainya dengan jelas.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 18), photoPicker(evidence: false), const SizedBox(height: 16),
      field('Nama produk', nameController, required: true), field('Harga (Rp)', priceController, required: true, numeric: true, price: true),
      const SizedBox(height: 8), const Text('Ukuran Aktual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 10),
      DropdownButtonFormField<String>(value: sizeLabel, decoration: const InputDecoration(labelText: 'Label ukuran'),
        items: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'All Size', 'Free Size'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() => sizeLabel = v), validator: (v) => v == null ? 'Pilih label ukuran.' : null),
      const SizedBox(height: 11), field('Lingkar dada (cm)', chestController, numeric: true),
      field('Panjang pakaian (cm)', lengthController, numeric: true), field('Lebar bahu (cm)', shoulderController, numeric: true),
      field('Panjang lengan (cm)', sleeveController, numeric: true, helper: 'Isi ukuran yang sesuai dengan jenis pakaian.'),
      const SizedBox(height: 8), const Text('Informasi Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10), field('Deskripsi produk', descriptionController, maxLines: 3),
      const SizedBox(height: 8), const Text('PreloCheck', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5), const Text('Periksa kondisi pakaian dan tandai kekurangan yang diketahui sebelum memasang produk.', style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 10), DropdownButtonFormField<String>(value: condition, decoration: const InputDecoration(labelText: 'Kondisi barang'),
        items: const [DropdownMenuItem(value: 'Seperti baru', child: Text('Seperti baru')), DropdownMenuItem(value: 'Sangat baik', child: Text('Sangat baik')), DropdownMenuItem(value: 'Cukup baik', child: Text('Cukup baik'))],
        onChanged: (v) => setState(() => condition = v ?? condition)),
      CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Terdapat noda'), value: hasStain, onChanged: (v) => setState(() => hasStain = v ?? false)),
      CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Terdapat lubang'), value: hasHole, onChanged: (v) => setState(() => hasHole = v ?? false)),
      CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Jahitan rusak'), value: hasDamagedSeam, onChanged: (v) => setState(() => hasDamagedSeam = v ?? false)),
      CheckboxListTile(contentPadding: EdgeInsets.zero, title: const Text('Warna memudar'), value: hasFadedColor, onChanged: (v) => setState(() => hasFadedColor = v ?? false)),
      field('Keterangan kekurangan lainnya', defectsController, maxLines: 3),
      const SizedBox(height: 20), ElevatedButton(onPressed: submitProduct, child: const Text('Pasang Produk')),
    ])),
  );
}
