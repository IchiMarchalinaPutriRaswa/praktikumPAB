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
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final descriptionC = TextEditingController();
  final sizeC = TextEditingController();
  final chestC = TextEditingController();
  final lengthC = TextEditingController();
  final shoulderC = TextEditingController();
  final sleeveC = TextEditingController();
  final defectsC = TextEditingController();
  final picker = ImagePicker();
  final List<Uint8List> photos = [];
  Uint8List? evidence;
  String condition = 'Kondisi sangat baik';

  @override
  void dispose() {
    nameC.dispose(); priceC.dispose(); descriptionC.dispose();
    sizeC.dispose(); chestC.dispose(); lengthC.dispose();
    shoulderC.dispose(); sleeveC.dispose(); defectsC.dispose();
    super.dispose();
  }

  void message(String value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));

  Future<void> pickPhotos() async {
    final remaining = 5 - photos.length;
    if (remaining <= 0) { message('Maksimal 5 foto produk.'); return; }
    final files = await picker.pickMultiImage(imageQuality: 80); if (files.isEmpty) return;
    final bytes = <Uint8List>[];
    for (final file in files.take(remaining)) {
      bytes.add(await file.readAsBytes());
    }
    if (mounted) setState(() => photos.addAll(bytes));
  }

  Future<void> pickEvidence() async {
    final file = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => evidence = bytes);
  }

  double? measure(TextEditingController c) {
    final value = double.tryParse(c.text.trim().replaceAll(',', '.')); return value != null && value > 0 ? value : null;
  }

  void submit() {
    final name = nameC.text.trim();
    final raw = priceC.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (name.isEmpty || raw.isEmpty || photos.isEmpty) { message('Isi nama, harga, dan minimal satu foto produk.'); return; }
    final number = int.tryParse(raw);
    if (number == null || number <= 0) { message('Masukkan harga yang valid.'); return; }
    final price = 'Rp${number.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
    ProductStore.add(ProductItem(
      name: name, price: price, condition: condition,
      images: List<Uint8List>.from(photos),
      sizeLabel: sizeC.text.trim().isEmpty ? '-' : sizeC.text.trim(),
      chestCm: measure(chestC), lengthCm: measure(lengthC),
      shoulderCm: measure(shoulderC), sleeveCm: measure(sleeveC),
      description: descriptionC.text.trim().isEmpty
          ? 'Deskripsi belum dicantumkan.' : descriptionC.text.trim(),
      defects: defectsC.text.trim().isEmpty
          ? 'Tidak ada kekurangan yang diketahui.' : defectsC.text.trim(),
      evidenceImage: evidence,
    ));
    for (final c in [nameC, priceC, descriptionC, sizeC, chestC, lengthC, shoulderC, sleeveC, defectsC]) { c.clear(); }
    setState(() {
      photos.clear(); evidence = null;
      condition = 'Kondisi sangat baik';
    });
    message('Produk berhasil ditambahkan ke katalog.');
  }

  Widget field(String hint, TextEditingController c, {int lines = 1, TextInputType? type}) => Padding(padding: const EdgeInsets.only(bottom: 11), child: TextField(controller: c, maxLines: lines, keyboardType: type, decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))));

  Widget heading(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)));

  Widget photoBox() => Container(width: double.infinity, padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFFE8EEDE), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD5E2C8))),
    child: Column(children: [
      if (photos.isEmpty)
        InkWell(onTap: pickPhotos, child: const SizedBox(
          width: double.infinity, height: 130,
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 38,
                color: Color(0xFF89AC46)),
              SizedBox(height: 8),
              Text('Tambah foto produk',
                style: TextStyle(fontWeight: FontWeight.w700)),
              Text('Maksimal 5 foto',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            ])))
      else
        Wrap(spacing: 10, runSpacing: 10, children: [
          ...photos.asMap().entries.map((e) => Stack(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.memory(e.value, width: 88, height: 88,
                fit: BoxFit.cover)),
            Positioned(right: 2, top: 2, child: InkWell(
              onTap: () => setState(() => photos.removeAt(e.key)),
              child: const CircleAvatar(radius: 11,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 14, color: Colors.white)))),
          ])),
          if (photos.length < 5)
            InkWell(onTap: pickPhotos, child: Container(
              width: 88, height: 88,
              decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add_a_photo_outlined,
                color: Color(0xFF89AC46)))),
        ]),
      const SizedBox(height: 8),
      Text('${photos.length}/5 foto dipilih',
        style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ]),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jual Barang', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 28), children: [
        const Text('Pasang produk preloved kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Lengkapi informasi produk agar pembeli dapat menilainya dengan jelas.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 20), photoBox(),
        const SizedBox(height: 20),
        field('Nama produk', nameC),
        field('Harga (Rp)', priceC, type: TextInputType.number),
        heading('Ukuran Aktual'),
        field('Label ukuran', sizeC),
        field('Lingkar dada (cm)', chestC, type: const TextInputType.numberWithOptions(decimal: true)),
        field('Panjang pakaian (cm)', lengthC, type: const TextInputType.numberWithOptions(decimal: true)),
        field('Lebar bahu (cm)', shoulderC, type: const TextInputType.numberWithOptions(decimal: true)),
        field('Panjang lengan (cm)', sleeveC, type: const TextInputType.numberWithOptions(decimal: true)),
        heading('Deskripsi Produk'),
        field('Ceritakan detail produk...', descriptionC, lines: 4),
        heading('PreloCheck - Informasi Kondisi'),
        DropdownButtonFormField<String>(value: condition,
          decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
          items: const ['Kondisi seperti baru', 'Kondisi sangat baik',
            'Kondisi cukup baik', 'Kondisi perlu perhatian']
            .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) { if (v != null) setState(() => condition = v); },
        ),
        const SizedBox(height: 12),
        field('Jelaskan kekurangan produk (jika ada)', defectsC, lines: 3),
        OutlinedButton.icon(onPressed: pickEvidence, icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(evidence == null ? 'Tambah foto pendukung kondisi'
            : 'Ganti foto pendukung kondisi')),
        if (evidence != null) ...[
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(12),
            child: Image.memory(evidence!, height: 150, fit: BoxFit.contain)),
        ],
        const SizedBox(height: 22),
        SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF89AC46),
              foregroundColor: Colors.white),
            child: const Text('Pasang Produk',
              style: TextStyle(fontWeight: FontWeight.w800)))),
      ]),
  );
}
