import 'package:flutter/material.dart';
import 'catalog_page.dart';
import 'product_detail_page.dart';
import 'sell_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'favorite_page.dart';
import 'chat_list_page.dart';
import '../store/product_store.dart';
import '../widgets/product_card.dart';
import '../widgets/home_bottom_navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  void changePage(int index) => setState(() => selectedIndex = index);

  void openFavorites() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const FavoritePage()));

  void openChats() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const ChatListPage()));

  void openProduct(ProductItem p) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => ProductDetailPage(
        name: p.name, price: p.price, condition: p.condition,
        imageUrl: p.imageUrl, imageAsset: p.imageAsset,
        imageBytes: p.imageBytes, images: p.images,
        imageAssets: p.imageAssets,
        description: p.description, sizeLabel: p.sizeLabel,
        chestCm: p.chestCm, lengthCm: p.lengthCm,
        shoulderCm: p.shoulderCm, sleeveCm: p.sleeveCm,
        defects: p.defects,
      )));

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(
        onCatalog: () => changePage(1),
        onFavorites: openFavorites,
        onChats: openChats,
        onProduct: openProduct,
      ),
      const CatalogPage(),
      const SellPage(),
      const CartPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: HomeBottomNavbar(
        selectedIndex: selectedIndex, onTap: changePage,
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final VoidCallback onCatalog, onFavorites, onChats;
  final ValueChanged<ProductItem> onProduct;

  const _HomeContent({
    required this.onCatalog,
    required this.onFavorites,
    required this.onChats,
    required this.onProduct,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('PreloWear',
        style: TextStyle(fontWeight: FontWeight.w800)),
      actions: [
        IconButton(
          tooltip: 'Riwayat Chat',
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          onPressed: onChats,
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: ValueListenableBuilder<List<ProductItem>>(
      valueListenable: ProductStore.items,
      builder: (context, products, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF89AC46),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Temukan barang favoritmu.',
                    style: TextStyle(color: Colors.white,
                      fontSize: 26, height: 1.25,
                      fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Gaya tetap menarik, belanja lebih hemat.',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Produk pilihan',
                  style: TextStyle(fontSize: 19,
                    fontWeight: FontWeight.w800)),
                TextButton(onPressed: onCatalog,
                  child: const Text('Lihat semua')),
              ],
            ),
            const SizedBox(height: 8),
            if (products.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Belum ada produk.'),
              ))
            else
              LayoutBuilder(builder: (context, constraints) {
                final w = constraints.maxWidth;
                final columns = w >= 1250 ? 5 :
                    w >= 850 ? 4 : w >= 550 ? 3 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.58,
                  ),
                  itemBuilder: (context, i) {
                    final p = products[i];
                    return ProductCard(
                      name: p.name, price: p.price,
                      condition: p.condition, imageUrl: p.imageUrl,
                      imageAsset: p.imageAsset, imageAssets: p.imageAssets,
                      imageBytes: p.imageBytes,
                      onTap: () => onProduct(p),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    ),
  );
}
