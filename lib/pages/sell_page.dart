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
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final nameController = TextEditingController(), priceController = TextEditingController();
  final chestController = TextEditingController(), lengthController = TextEditingController();
  final shoulderController = TextEditingController(), sleeveController = TextEditingController();
  final waistController = TextEditingController();
  final descriptionController = TextEditingController(), defectsController = TextEditingController();
  final List<Uint8List> photos = [];
  String? condition, sizeLabel, clothingType;
  bool conditionError = false, sizeError = false, categoryError = false;
  bool hasStain = false, hasHole = false, hasDamagedSeam = false, hasFadedColor = false;
  static const green = Color(0xFF89AC46);
  static const categories = ['Atasan', 'Outerwear', 'Celana', 'Rok', 'Dress'];
  List<TextEditingController> get controllers => [nameController, priceController, chestController, lengthController, shoulderController, sleeveController, waistController, descriptionController, defectsController];
  bool get isBottom => clothingType == 'Celana' || clothingType == 'Rok';

  @override
  void dispose() { for (final c in controllers) { c.dispose(); } super.dispose(); }

  void selectCategory(String value) {
    if (isBottom != (value == 'Celana' || value == 'Rok')) {
      for (final c in [chestController, lengthController, shoulderController, sleeveController, waistController]) { c.clear(); }
    }
    setState(() { clothingType = value; categoryError = false; });
  }

  Future<void> pickPhoto() async {
    try {
      final remaining = 5 - photos.length;
      if (remaining <= 0) return;
      final files = await picker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty || !mounted) return;
      final bytes = await Future.wait(files.take(remaining).map((f) => f.readAsBytes()));
      if (!mounted) return;
      setState(() => photos.addAll(bytes));
      if (files.length > remaining) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Maksimal 5 foto. Hanya $remaining foto ditambahkan.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memilih foto.')));
    }
  }

  String formatPrice(int value) => 'Rp${value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
  double? measure(TextEditingController c) => c.text.trim().isEmpty ? null : double.tryParse(c.text.trim().replaceAll(',', '.'));

  Widget field(String label, TextEditingController c, {bool required = false, bool numeric = false, bool price = false, int maxLines = 1, String? helper}) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: TextFormField(controller: c, maxLines: maxLines,
      keyboardType: price ? TextInputType.number : numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, helperText: helper),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) return '$label wajib diisi.';
        if (price && text.isNotEmpty) {
          final n = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
          if (n == null || n <= 0) return 'Masukkan harga yang valid.';
        } else if (numeric && text.isNotEmpty) {
          final n = double.tryParse(text.replaceAll(',', '.'));
          if (n == null || n <= 0) return 'Masukkan ukuran lebih dari 0 cm.';
        }
        return null;
      }),
  );

  Widget photoItem(MapEntry<int, Uint8List> item) => SizedBox(width: 125, height: 168, child: Stack(children: [
    Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.memory(item.value, fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFE5EEE9), child: Icon(Icons.broken_image_outlined))))),
    Positioned(top: 5, right: 5, child: IconButton(onPressed: () => setState(() => photos.removeAt(item.key)), icon: const Icon(Icons.close, size: 19), style: IconButton.styleFrom(backgroundColor: Colors.white))),
    Positioned(bottom: 6, left: 6, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
      child: Text(item.key == 0 ? 'Utama' : '${item.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 11)))),
  ]));

  Widget addPhotoTile({bool expanded = false}) => GestureDetector(onTap: pickPhoto, child: Container(
    width: expanded ? double.infinity : 125, height: expanded ? 190 : 168,
    decoration: BoxDecoration(color: const Color(0xFFE5EEE9), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD5E2DC))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_a_photo_outlined, size: expanded ? 42 : 32, color: green), const SizedBox(height: 8),
      Text(expanded ? 'Tambah foto produk' : 'Tambah foto', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 4), const Text('Maksimal 5 foto', style: TextStyle(fontSize: 11, color: Colors.black54)),
      if (expanded) ...[const SizedBox(height: 25), Text('${photos.length}/5 foto dipilih', style: const TextStyle(fontSize: 12, color: Colors.black54))],
    ]),
  ));

  Widget photoPicker() => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: photos.isEmpty
    ? addPhotoTile(expanded: true) : SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
      ...photos.asMap().entries.map((item) => Padding(padding: const EdgeInsets.only(right: 10), child: photoItem(item))),
      if (photos.length < 5) addPhotoTile(),
    ])));

  String buildDefects() {
    final values = <String>[
      if (hasStain) 'Terdapat noda', if (hasHole) 'Terdapat lubang',
      if (hasDamagedSeam) 'Jahitan rusak', if (hasFadedColor) 'Warna memudar',
      if (defectsController.text.trim().isNotEmpty) defectsController.text.trim(),
    ];
    return values.isEmpty ? 'Tidak ada kekurangan yang diketahui penjual.' : values.join('. ');
  }

  Widget check(String title, bool value, ValueChanged<bool?> onChanged) => CheckboxListTile(contentPadding: EdgeInsets.zero, title: Text(title), value: value, activeColor: green, onChanged: onChanged);
  Widget sectionTitle(String title) => Padding(padding: const EdgeInsets.only(top: 8, bottom: 10), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)));

  Widget categoryPicker() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Jenis pakaian', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 10),
    Wrap(spacing: 8, runSpacing: 10, children: categories.map((value) {
      final selected = clothingType == value;
      return ChoiceChip(label: Text(value), selected: selected, onSelected: (_) => selectCategory(value),
        selectedColor: green, backgroundColor: const Color(0xFFE5EEE9),
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
        side: BorderSide(color: selected ? green : const Color(0xFFD5E2DC)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
    }).toList()),
    if (categoryError) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Pilih jenis pakaian terlebih dahulu.', style: TextStyle(color: Colors.red, fontSize: 12))),
  ]);

  Widget measurementFields() {
    if (clothingType == null) return const Padding(padding: EdgeInsets.only(top: 12), child: Text('Pilih jenis pakaian untuk menampilkan kolom ukuran.', style: TextStyle(color: Colors.black54, fontSize: 12)));
    if (isBottom) return Column(children: [
      field('Lingkar pinggang (cm)', waistController, numeric: true),
      field(clothingType == 'Rok' ? 'Panjang rok (cm)' : 'Panjang celana (cm)', lengthController, numeric: true, helper: 'Ukur dari bagian pinggang hingga ujung bawah pakaian.'),
    ]);
    return Column(children: [
      field('Lingkar dada (cm)', chestController, numeric: true),
      field(clothingType == 'Dress' ? 'Panjang dress (cm)' : 'Panjang pakaian (cm)', lengthController, numeric: true),
      field('Lebar bahu (cm)', shoulderController, numeric: true),
      field('Panjang lengan (cm)', sleeveController, numeric: true, helper: 'Isi ukuran sesuai jenis pakaian.'),
    ]);
  }

  Widget sizeFields() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    field('Nama produk', nameController, required: true), field('Harga (Rp)', priceController, required: true, numeric: true, price: true),
    sectionTitle('Ukuran Aktual'), categoryPicker(), const SizedBox(height: 12),
    const Text('Label ukuran', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 10),
    Wrap(spacing: 8, runSpacing: 10, children: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'All Size', 'Free Size'].map((value) {
      final selected = sizeLabel == value;
      return ChoiceChip(label: Text(value), selected: selected, onSelected: (_) => setState(() { sizeLabel = value; sizeError = false; }),
        selectedColor: green, backgroundColor: const Color(0xFFE5EEE9),
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
        side: BorderSide(color: selected ? green : const Color(0xFFD5E2DC)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
    }).toList()),
    if (sizeError) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Pilih label ukuran terlebih dahulu.', style: TextStyle(color: Colors.red, fontSize: 12))),
    const SizedBox(height: 11), measurementFields(),
  ]);

  Widget infoFields() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [sectionTitle('Informasi Produk'), field('Deskripsi produk', descriptionController, maxLines: 3)]);

  Widget preloCheck() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    sectionTitle('PreloCheck'), const Text('Periksa kondisi pakaian dan tandai kekurangan yang diketahui sebelum memasang produk.', style: TextStyle(color: Colors.black54)),
    const SizedBox(height: 16), const Text('Kondisi Barang', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10),
    Wrap(spacing: 10, runSpacing: 10, children: ['Seperti baru', 'Sangat baik', 'Cukup baik'].map((value) {
      final selected = condition == value;
      return ChoiceChip(label: Text(value), selected: selected, onSelected: (_) => setState(() { condition = value; conditionError = false; }),
        selectedColor: green, backgroundColor: const Color(0xFFE5EEE9),
        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
        side: BorderSide(color: selected ? green : const Color(0xFFD5E2DC)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9));
    }).toList()),
    if (conditionError) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Pilih kondisi barang terlebih dahulu.', style: TextStyle(color: Colors.red, fontSize: 12))),
    const SizedBox(height: 16), check('Terdapat noda', hasStain, (v) => setState(() => hasStain = v ?? false)),
    check('Terdapat lubang', hasHole, (v) => setState(() => hasHole = v ?? false)),
    check('Jahitan rusak', hasDamagedSeam, (v) => setState(() => hasDamagedSeam = v ?? false)),
    check('Warna memudar', hasFadedColor, (v) => setState(() => hasFadedColor = v ?? false)),
    field('Keterangan kekurangan lainnya', defectsController, maxLines: 3),
  ]);

  void submitProduct() {
    if (!formKey.currentState!.validate()) return;
    if (clothingType == null) { setState(() => categoryError = true); return; }
    if (sizeLabel == null) { setState(() => sizeError = true); return; }
    if (condition == null) { setState(() => conditionError = true); return; }
    if (photos.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih minimal satu foto produk terlebih dahulu.'))); return; }
    final price = int.parse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    ProductStore.add(ProductItem(
      name: nameController.text.trim(), price: formatPrice(price), condition: 'Kondisi ${condition!}',
      images: List<Uint8List>.from(photos), sizeLabel: sizeLabel!,
      category: clothingType!,
      chestCm: isBottom ? null : measure(chestController), waistCm: isBottom ? measure(waistController) : null,
      lengthCm: measure(lengthController), shoulderCm: isBottom ? null : measure(shoulderController),
      sleeveCm: isBottom ? null : measure(sleeveController),
      description: descriptionController.text.trim().isEmpty ? 'Deskripsi produk belum ditambahkan oleh penjual.' : descriptionController.text.trim(),
      defects: buildDefects(),
    ));
    for (final c in controllers) { c.clear(); }
    setState(() {
      photos.clear(); condition = null; conditionError = false; sizeLabel = null; sizeError = false;
      clothingType = null; categoryError = false; hasStain = false; hasHole = false; hasDamagedSeam = false; hasFadedColor = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil dipasang!')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jual Barang', style: TextStyle(fontWeight: FontWeight.w800))),
    body: Form(key: formKey, child: ListView(padding: EdgeInsets.zero, children: [
      const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pasang produk preloved kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 6),
        Text('Lengkapi informasi produk agar pembeli dapat menilainya dengan jelas.', style: TextStyle(color: Colors.black54)),
      ])),
      photoPicker(),
      Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        sizeFields(), infoFields(), preloCheck(), const SizedBox(height: 20),
        ElevatedButton(onPressed: submitProduct, child: const Text('Pasang Produk')),
      ])),
    ])),
  );
}
