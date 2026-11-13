import 'package:flutter/material.dart';
import '../store/fit_match_store.dart';

class FitMatchPage extends StatefulWidget {
  final String productName, sizeLabel;
  final double? chestCm, lengthCm, shoulderCm, sleeveCm;

  const FitMatchPage({
    super.key, required this.productName, required this.sizeLabel,
    this.chestCm, this.lengthCm, this.shoulderCm, this.sleeveCm,
  });

  @override
  State<FitMatchPage> createState() => _FitMatchPageState();
}

class _FitMatchPageState extends State<FitMatchPage> {
  late Map<String, TextEditingController> fields;
  String? result;
  List<Map<String, dynamic>> comparisons = [];

  static const labels = {
    'chest': 'Lingkar Dada',
    'length': 'Panjang Pakaian',
    'shoulder': 'Lebar Bahu',
    'sleeve': 'Panjang Lengan',
  };

  @override
  void initState() {
    super.initState();
    FitMatchStore.measurements.clear();
    fields = {
      for (final key in labels.keys)
        key: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void calculate() {
    final input = <String, double>{};
    for (final e in fields.entries) {
      if (e.value.text.trim().isEmpty) continue;
      final v = double.tryParse(e.value.text.trim().replaceAll(',', '.'));
      if (v == null || v <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Periksa ukuran yang dimasukkan.')));
        return;
      }
      input[e.key] = v;
    }

    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi minimal satu ukuran.')));
      return;
    }

    FitMatchStore.save(input);
    final product = {
      'chest': widget.chestCm, 'length': widget.lengthCm,
      'shoulder': widget.shoulderCm, 'sleeve': widget.sleeveCm,
    };
    const limits = {
      'chest': 4.0, 'length': 3.0,
      'shoulder': 2.0, 'sleeve': 3.0,
    };

    final rows = <Map<String, dynamic>>[];
    input.forEach((key, user) {
      final p = product[key];
      if (p == null) return;
      final diff = (user - p).abs();
      final limit = limits[key]!;
      rows.add({
        'label': labels[key], 'user': user, 'product': p,
        'diff': diff,
        'status': diff <= limit ? 'Sesuai' :
            diff <= limit * 2 ? 'Mendekati' : 'Berbeda',
      });
    });

    setState(() {
      comparisons = rows;
      result = rows.isEmpty ? 'Data ukuran produk belum tersedia' :
          rows.every((e) => e['status'] == 'Sesuai')
              ? 'Ukuran sangat mendekati!'
              : rows.any((e) => e['status'] == 'Berbeda')
                  ? 'Ada perbedaan ukuran'
                  : 'Ukuran cukup mendekati';
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('FitMatch')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Cocokkan Ukuran Pakaian',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Masukkan ukuran pakaian yang paling nyaman kamu gunakan.'),
      const SizedBox(height: 16),
      Card(child: ListTile(
        title: Text(widget.productName),
        subtitle: Text('Ukuran produk: ${widget.sizeLabel}'),
      )),
      const SizedBox(height: 16),
      ...fields.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: e.value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: labels[e.key], suffixText: 'cm',
            border: const OutlineInputBorder(),
          ),
        ),
      )),
      ElevatedButton.icon(
        onPressed: calculate,
        icon: const Icon(Icons.compare_arrows),
        label: const Text('Cocokkan Ukuran'),
      ),
      if (result != null) ...[
        const SizedBox(height: 20),
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result!, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              if (comparisons.isEmpty)
                const Text('Belum ada ukuran yang dapat dibandingkan.')
              else
                ...comparisons.map((r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(r['label']),
                  subtitle: Text(
                    'Kamu: ${r['user']} cm | Produk: ${r['product']} cm'),
                  trailing: Text('${r['status']}\n${r['diff']} cm',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 11,
                      color: r['status'] == 'Sesuai'
                          ? Colors.green : Colors.orange),
                  ),
                )),
            ],
          ),
        )),
      ],
      const SizedBox(height: 16),
      const Text(
        'Hasil merupakan estimasi berdasarkan perbandingan ukuran, bukan jaminan kecocokan.',
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
    ]),
  );
}
