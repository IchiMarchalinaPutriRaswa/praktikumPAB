import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, required this.products, required this.onFavorite, required this.onAddToCart, required this.onOpenProduct});
  final List<PreloProduct> products;
  final ValueChanged<PreloProduct> onFavorite;
  final ValueChanged<PreloProduct> onAddToCart;
  final ValueChanged<PreloProduct> onOpenProduct;

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String _category = 'Semua';
  final List<String> _categories = const ['Semua', 'Atasan', 'Celana', 'Outer', 'Aksesori'];

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final products = widget.products.where((p) =>
      (_category == 'Semua' || p.category == _category) &&
      ('${p.name} ${p.category} ${p.condition}'.toLowerCase().contains(query))
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog produk', style: TextStyle(fontWeight: FontWeight.w900))),
      body: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(constraints.maxWidth >= 900 ? 32 : 16, 10, constraints.maxWidth >= 900 ? 32 : 16, 28),
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'Cari nama pakaian atau kategori...',
              suffixIcon: _searchController.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: () { _searchController.clear(); setState(() {}); })),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.only(left: 2, bottom: 8),
            child: Text('Pilih kategori', style: TextStyle(fontWeight: FontWeight.w800, color: kText, fontSize: 13)),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: _categories.map((category) => ChoiceChip(
            label: Text(category), selected: _category == category, onSelected: (_) => setState(() => _category = category),
            selectedColor: const Color(0xFFDDEDE4), backgroundColor: Colors.white,
            labelStyle: TextStyle(color: _category == category ? kBrandDark : kText, fontWeight: FontWeight.w700, fontSize: 12),
          )).toList()),
          const SizedBox(height: 20),
          Row(children: [const Expanded(child: Text('Hasil pencarian', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: kText))), Text('${products.length} produk', style: const TextStyle(color: kMuted, fontSize: 12))]),
          const SizedBox(height: 12),
          if (products.isEmpty) const _EmptySearch() else LayoutBuilder(builder: (context, gridConstraints) {
            final width = gridConstraints.maxWidth;
            final columns = width >= 1050 ? 4 : width >= 720 ? 3 : width >= 360 ? 2 : 1;
            return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14,
                childAspectRatio: columns == 1 ? 0.64 : columns == 2 ? 0.52 : columns == 3 ? 0.58 : 0.62),
              itemBuilder: (context, index) => ProductCard(product: products[index], onFavorite: () => widget.onFavorite(products[index]), onAddToCart: () => widget.onAddToCart(products[index]), onOpen: () => widget.onOpenProduct(products[index])));
          }),
        ]))),
      )),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: const Column(children: [Icon(Icons.search_off_rounded, size: 42, color: kMuted), SizedBox(height: 10),
      Text('Produk tidak ditemukan', style: TextStyle(fontWeight: FontWeight.w800, color: kText)),
      SizedBox(height: 4), Text('Coba kata kunci atau kategori lain.', style: TextStyle(color: kMuted, fontSize: 12))]));
}
