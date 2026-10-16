import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.products, required this.onFavorite, required this.onAddToCart,
    required this.onOpenCatalog, required this.onOpenSell, required this.onOpenCart, required this.onOpenProfile, required this.onOpenProduct, required this.cartCount});

  final List<PreloProduct> products;
  final ValueChanged<PreloProduct> onFavorite;
  final ValueChanged<PreloProduct> onAddToCart;
  final VoidCallback onOpenCatalog;
  final VoidCallback onOpenSell;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenProfile;
  final ValueChanged<PreloProduct> onOpenProduct;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PreloWear', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [
          IconButton(tooltip: 'Cari produk', onPressed: onOpenCatalog, icon: const Icon(Icons.search_rounded)),
          IconButton(tooltip: 'Profil akun', onPressed: onOpenProfile, icon: const Icon(Icons.account_circle_outlined)),
          Padding(padding: const EdgeInsets.only(right: 12), child: Stack(children: [
            IconButton(tooltip: 'Keranjang', onPressed: onOpenCart, icon: const Icon(Icons.shopping_bag_outlined)),
            if (cartCount > 0) Positioned(right: 4, top: 4, child: Container(width: 18, height: 18, alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFD65D73), shape: BoxShape.circle),
              child: Text('$cartCount', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)))),
          ])),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final sidePadding = constraints.maxWidth >= 1000 ? 34.0 : constraints.maxWidth >= 650 ? 24.0 : 16.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(sidePadding, 8, sidePadding, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Pakaian lama, cerita baru.', style: TextStyle(fontSize: 25, height: 1.15, fontWeight: FontWeight.w900, color: kText)),
                const SizedBox(height: 7),
                const Text('Temukan gaya favorit dengan harga yang lebih ramah.', style: TextStyle(color: kMuted, fontSize: 13)),
                const SizedBox(height: 20),
                _PromoBanner(onBrowse: onOpenCatalog),
                const SizedBox(height: 25),
                Row(children: [const Expanded(child: Text('Jelajahi kategori', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: kText))),
                  TextButton(onPressed: onOpenCatalog, child: const Text('Lihat semua'))]),
                const SizedBox(height: 8),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _CategoryPill(icon: Icons.checkroom_rounded, label: 'Atasan', onTap: onOpenCatalog),
                  _CategoryPill(icon: Icons.dry_cleaning_rounded, label: 'Celana', onTap: onOpenCatalog),
                  _CategoryPill(icon: Icons.ac_unit_rounded, label: 'Outer', onTap: onOpenCatalog),
                  _CategoryPill(icon: Icons.shopping_bag_outlined, label: 'Aksesori', onTap: onOpenCatalog),
                ]),
                const SizedBox(height: 25),
                Row(children: [const Expanded(child: Text('Pilihan untuk kamu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: kText))),
                  TextButton.icon(onPressed: onOpenCatalog, icon: const Icon(Icons.arrow_forward_rounded, size: 16), label: const Text('Katalog'))]),
                const SizedBox(height: 12),
                _ProductGrid(products: products.take(4).toList(), onFavorite: onFavorite, onAddToCart: onAddToCart, onOpenProduct: onOpenProduct),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFFE8F1E9), borderRadius: BorderRadius.circular(18)),
                  child: LayoutBuilder(builder: (context, c) {
                    const description = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Punya pakaian yang masih layak?', style: TextStyle(fontWeight: FontWeight.w800, color: kText, fontSize: 15)),
                      SizedBox(height: 4), Text('Jual lagi dan beri kesempatan kedua untuk barang favoritmu.', style: TextStyle(color: kMuted, fontSize: 12, height: 1.4)),
                    ]);
                    if (c.maxWidth < 510) {
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.eco_rounded, color: kBrand, size: 32),
                        const SizedBox(height: 9),
                        description,
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: onOpenSell, child: const Text('Jual pakaian')),
                      ]);
                    }
                    return Row(children: [
                      const Icon(Icons.eco_rounded, color: kBrand, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(child: description),
                      const SizedBox(width: 12),
                      OutlinedButton(onPressed: onOpenSell, child: const Text('Jual pakaian')),
                    ]);
                  }),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(23),
      child: Container(
        height: 206,
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF235D50)),
        child: Stack(fit: StackFit.expand, children: [
          Image.network('https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1400&q=85', fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/preloved_shirt.png', fit: BoxFit.cover)),
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
            colors: [Color(0xE8174F43), Color(0x9A174F43), Color(0x00174F43)]))),
          Padding(padding: const EdgeInsets.all(22), child: Align(alignment: Alignment.centerLeft, child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(50)),
                child: const Text('SECONDHAND, FIRST CHOICE', style: TextStyle(color: kBrandDark, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w900))),
              const SizedBox(height: 12),
              const Text('Gaya keren,\nharga tetap nyaman.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 25, height: 1.08)),
              const SizedBox(height: 14),
              ElevatedButton(onPressed: onBrowse, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: kBrandDark),
                child: const Text('Belanja sekarang')),
            ])))),
        ]),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 18, color: kBrand), label: Text(label), onPressed: onTap,
    backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFECE6DD)),
    labelStyle: const TextStyle(color: kText, fontWeight: FontWeight.w700, fontSize: 12), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
  );
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.onFavorite, required this.onAddToCart, required this.onOpenProduct});
  final List<PreloProduct> products;
  final ValueChanged<PreloProduct> onFavorite;
  final ValueChanged<PreloProduct> onAddToCart;
  final ValueChanged<PreloProduct> onOpenProduct;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final width = constraints.maxWidth;
    final columns = width >= 1050 ? 4 : width >= 720 ? 3 : width >= 355 ? 2 : 1;
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns, crossAxisSpacing: 14, mainAxisSpacing: 14,
        childAspectRatio: columns == 1 ? 0.64 : columns == 2 ? 0.52 : columns == 3 ? 0.58 : 0.62,
      ),
      itemBuilder: (context, index) => ProductCard(product: products[index], onFavorite: () => onFavorite(products[index]), onAddToCart: () => onAddToCart(products[index]), onOpen: () => onOpenProduct(products[index])),
    );
  });
}

