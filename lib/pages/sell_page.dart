import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/formatters.dart';
import '../models/product.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key, required this.onPublish});
  final ValueChanged<PreloProduct> onPublish;
  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Atasan';
  String _condition = 'Sangat baik';

  @override
  void dispose() { _nameController.dispose(); _priceController.dispose(); _descriptionController.dispose(); super.dispose(); }

  void _previewListing() {
    final name = _nameController.text.trim();
    final rawPrice = _priceController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    final price = int.tryParse(rawPrice);
    if (name.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi nama produk dan harga yang valid terlebih dahulu.')));
      return;
    }

    final product = PreloProduct(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: _category,
      price: formatRupiah(price),
      condition: _condition,
      imageUrl: '',
      imageAsset: 'assets/images/preloved_shirt_product.png',
      description: _descriptionController.text.trim(),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terbitkan produk?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/images/preloved_shirt_product.png', height: 125, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 12),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(product.price, style: const TextStyle(fontWeight: FontWeight.w800, color: kBrand)),
            const SizedBox(height: 4),
            Text('${product.category} • ${product.condition}'),
            if (product.description.isNotEmpty) ...[const SizedBox(height: 8), Text(product.description)],
            const SizedBox(height: 10),
            const Text('Produk akan ditambahkan ke katalog lokal aplikasi. Belum diunggah ke server.', style: TextStyle(fontSize: 11, color: kMuted, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Periksa lagi')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onPublish(product);
              _nameController.clear();
              _priceController.clear();
              _descriptionController.clear();
              setState(() {
                _category = 'Atasan';
                _condition = 'Sangat baik';
              });
            },
            child: const Text('Terbitkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Jual pakaian', style: TextStyle(fontWeight: FontWeight.w900))),
    body: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(constraints.maxWidth >= 900 ? 32 : 16, 12, constraints.maxWidth >= 900 ? 32 : 16, 28),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(19), decoration: BoxDecoration(color: const Color(0xFFE7F1E9), borderRadius: BorderRadius.circular(18)),
          child: const Row(children: [Icon(Icons.recycling_rounded, size: 34, color: kBrand), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Beri barangmu cerita baru', style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 17)),
            SizedBox(height: 4), Text('Lengkapi informasi produk dengan jujur agar pembeli lebih percaya.', style: TextStyle(color: kMuted, fontSize: 12, height: 1.4)),
          ]))])),
        const SizedBox(height: 24),
        const Text('Informasi produk', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kText)),
        const SizedBox(height: 14),
        const Text('Nama produk', style: TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 12)), const SizedBox(height: 7),
        TextField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Contoh: Kemeja linen warna krem')),
        const SizedBox(height: 15),
        const Text('Harga jual (Rp)', style: TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 12)), const SizedBox(height: 7),
        TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Contoh: 75000', prefixIcon: Icon(Icons.payments_outlined))),
        const SizedBox(height: 15),
        const Text('Kategori', style: TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 12)), const SizedBox(height: 7),
        DropdownButtonFormField<String>(value: _category, decoration: const InputDecoration(), items: const [
          DropdownMenuItem(value: 'Atasan', child: Text('Atasan')), DropdownMenuItem(value: 'Celana', child: Text('Celana')),
          DropdownMenuItem(value: 'Outer', child: Text('Outer')), DropdownMenuItem(value: 'Aksesori', child: Text('Aksesori')),
        ], onChanged: (value) => setState(() => _category = value ?? 'Atasan')),
        const SizedBox(height: 15),
        const Text('Kondisi barang', style: TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 12)), const SizedBox(height: 7),
        Wrap(spacing: 8, children: ['Seperti baru', 'Sangat baik', 'Baik', 'Layak pakai'].map((condition) => ChoiceChip(
          label: Text(condition), selected: _condition == condition, onSelected: (_) => setState(() => _condition = condition), selectedColor: const Color(0xFFDDEDE4),
        )).toList()),
        const SizedBox(height: 15),
        const Text('Deskripsi produk', style: TextStyle(fontWeight: FontWeight.w700, color: kText, fontSize: 12)), const SizedBox(height: 7),
        TextField(controller: _descriptionController, minLines: 3, maxLines: 5, decoration: const InputDecoration(hintText: 'Jelaskan ukuran, bahan, dan kekurangan barang jika ada.')),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _previewListing, icon: const Icon(Icons.visibility_outlined), label: const Text('Tinjau dan terbitkan produk'))),
      ]))),
    )),
  );
}
