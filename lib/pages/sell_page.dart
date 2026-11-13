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

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final chestController = TextEditingController();
  final lengthController = TextEditingController();
  final shoulderController = TextEditingController();
  final sleeveController = TextEditingController();
  final descriptionController = TextEditingController();
  final defectsController = TextEditingController();

  final picker = ImagePicker();

  static const int maxPhotos = 5;

  String condition = 'Sangat baik';
  String? sizeLabel;

  final List<Uint8List> photos = [];

  bool hasStain = false;
  bool hasHole = false;
  bool hasDamagedSeam = false;
  bool hasFadedColor = false;

  @override
  void dispose() {
    for (final c in [nameController, priceController, chestController, lengthController, shoulderController, sleeveController, descriptionController, defectsController]) {
      c.dispose();
    }
    super.dispose();
  }

  // Memilih beberapa foto produk.
  Future<void> pickPhoto() async {
    try {
      final remaining = maxPhotos - photos.length;

      if (remaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maksimal 5 foto produk.')),
        );
        return;
      }

      final files = await picker.pickMultiImage(imageQuality: 85);

      if (files.isEmpty || !mounted) return;

      final currentRemaining = maxPhotos - photos.length;
      final selectedFiles = files.take(currentRemaining).toList();

      final selectedBytes = await Future.wait<Uint8List>(
        selectedFiles.map((file) => file.readAsBytes()),
      );

      if (!mounted) return;

      setState(() => photos.addAll(selectedBytes));

      if (files.length > currentRemaining) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hanya $currentRemaining foto yang ditambahkan karena batas maksimal 5 foto.')),
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

  String formatPrice(int v) => 'Rp${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

  double? measure(TextEditingController c) => c.text.trim().isEmpty ? null : double.tryParse(c.text.trim().replaceAll(',', '.'));

  // Widget input formulir.
  Widget field(String label, TextEditingController c, {bool required = false, bool numeric = false, bool price = false, int maxLines = 1, String? helper}) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: price ? TextInputType.number : numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, helperText: helper),
      validator: (v) {
        final text = v?.trim() ?? '';

        if (required && text.isEmpty) return '$label wajib diisi.';

        if (price && text.isNotEmpty) {
          final n = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
          if (n == null || n <= 0) return 'Masukkan harga yang valid.';
        } else if (numeric && text.isNotEmpty) {
          final n = double.tryParse(text.replaceAll(',', '.'));
          if (n == null || n <= 0) return 'Masukkan ukuran lebih dari 0 cm.';
        }

        return null;
      },
    ),
  );

  // Widget unggah dan pratinjau foto.
  Widget photoPicker() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (photos.isEmpty && photos.length < maxPhotos)
        GestureDetector(
          onTap: pickPhoto,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFE5EEE9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD5E2DC)),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, size: 34, color: Color(0xFF89AC46)),
                SizedBox(height: 7),
                Text('Tambah foto produk', style: TextStyle(fontWeight: FontWeight.w700)),
                Text('Maksimal 5 foto', style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        )
      else
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...photos.asMap().entries.map((entry) => Container(
                width: 110,
                height: 150,
                margin: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.memory(entry.value, fit: BoxFit.cover),
                      ),
                    ),
                    if (entry.key == 0)
                      const Positioned(
                        left: 4,
                        bottom: 4,
                        child: Chip(
                          label: Text('Utama', style: TextStyle(fontSize: 10)),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        onPressed: () => setState(() => photos.removeAt(entry.key)),
                        icon: const Icon(Icons.close, size: 18),
                        style: IconButton.styleFrom(backgroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              )),
              if (photos.length < maxPhotos)
                GestureDetector(
                  onTap: pickPhoto,
                  child: Container(
                    width: 140,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EEE9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD5E2DC)),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 30, color: Color(0xFF89AC46)),
                        SizedBox(height: 7),
                        Text('Tambah foto', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Maksimal 5 foto', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
    ],
  );

  // Membuat keterangan kekurangan produk.
  String buildDefects() {
    final values = <String>[
      if (hasStain) 'Terdapat noda',
      if (hasHole) 'Terdapat lubang',
      if (hasDamagedSeam) 'Jahitan rusak',
      if (hasFadedColor) 'Warna memudar',
      if (defectsController.text.trim().isNotEmpty) defectsController.text.trim(),
    ];

    return values.isEmpty ? 'Tidak ada kekurangan yang diketahui penjual.' : values.join('. ');
  }

  // Memasang produk ke ProductStore.
  void submitProduct() {
    if (!formKey.currentState!.validate()) return;

    if (photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu foto produk terlebih dahulu.')),
      );
      return;
    }

    final price = int.parse(priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));

    ProductStore.add(
      ProductItem(
        name: nameController.text.trim(),
        price: formatPrice(price),
        condition: 'Kondisi $condition',
        images: List<Uint8List>.from(photos),
        sizeLabel: sizeLabel!,
        chestCm: measure(chestController),
        lengthCm: measure(lengthController),
        shoulderCm: measure(shoulderController),
        sleeveCm: measure(sleeveController),
        description: descriptionController.text.trim().isEmpty
            ? 'Deskripsi produk belum ditambahkan oleh penjual.'
            : descriptionController.text.trim(),
        defects: buildDefects(),
      ),
    );

    // Mengosongkan formulir setelah produk dipasang.
    for (final c in [nameController, priceController, chestController, lengthController, shoulderController, sleeveController, descriptionController, defectsController]) {
      c.clear();
    }

    setState(() {
      photos.clear();
      condition = 'Sangat baik';
      sizeLabel = null;
      hasStain = false;
      hasHole = false;
      hasDamagedSeam = false;
      hasFadedColor = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil dipasang!')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Jual Barang', style: TextStyle(fontWeight: FontWeight.w800)),
    ),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const Text('Pasang produk preloved kamu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Lengkapi informasi produk agar pembeli dapat menilainya dengan jelas. Sertakan foto yang memperjelas kondisi barang.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 18),

          photoPicker(),

          const SizedBox(height: 16),

          field('Nama produk', nameController, required: true),
          field('Harga (Rp)', priceController, required: true, numeric: true, price: true),

          const SizedBox(height: 8),

          const Text('Ukuran Aktual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: sizeLabel,
            decoration: const InputDecoration(labelText: 'Label ukuran'),
            items: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'All Size', 'Free Size'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => sizeLabel = v),
            validator: (v) => v == null ? 'Pilih label ukuran.' : null,
          ),

          const SizedBox(height: 11),

          field('Lingkar dada (cm)', chestController, numeric: true),
          field('Panjang pakaian (cm)', lengthController, numeric: true),
          field('Lebar bahu (cm)', shoulderController, numeric: true),
          field('Panjang lengan (cm)', sleeveController, numeric: true, helper: 'Isi ukuran yang sesuai dengan jenis pakaian.'),

          const SizedBox(height: 8),

          const Text('Informasi Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          field('Deskripsi produk', descriptionController, maxLines: 3),

          const SizedBox(height: 8),

          const Text('PreloCheck', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('Periksa kondisi pakaian dan tandai kekurangan yang diketahui sebelum memasang produk.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 10),

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

          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Terdapat noda'),
            value: hasStain,
            onChanged: (v) => setState(() => hasStain = v ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Terdapat lubang'),
            value: hasHole,
            onChanged: (v) => setState(() => hasHole = v ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Jahitan rusak'),
            value: hasDamagedSeam,
            onChanged: (v) => setState(() => hasDamagedSeam = v ?? false),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Warna memudar'),
            value: hasFadedColor,
            onChanged: (v) => setState(() => hasFadedColor = v ?? false),
          ),

          field('Keterangan kekurangan lainnya', defectsController, maxLines: 3),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: submitProduct,
            child: const Text('Pasang Produk'),
          ),
        ],
      ),
    ),
  );
}
