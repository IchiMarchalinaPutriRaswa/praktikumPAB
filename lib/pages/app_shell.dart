import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/sample_products.dart';
import '../data/formatters.dart';
import '../models/product.dart';
import 'cart_page.dart';
import 'catalog_page.dart';
import 'checkout_page.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'product_detail_page.dart';
import 'product_gallery_page.dart';
import 'profile_page.dart';
import 'sell_page.dart';

/// Shell navigasi marketplace. Halaman detail, galeri, checkout, dan akun dibuka
/// melalui alur pengguna biasa; tidak ada menu praktikum widget.
class PreloWearShell extends StatefulWidget {
  const PreloWearShell({super.key});
  @override
  State<PreloWearShell> createState() => _PreloWearShellState();
}

class _PreloWearShellState extends State<PreloWearShell> {
  int _selectedIndex = 0;
  final Map<String, int> _cartQuantities = {};
  late final List<PreloProduct> _products = sampleProducts();

  int get _cartItemCount => _cartQuantities.values.fold(0, (sum, quantity) => sum + quantity);

  void _toggleFavorite(PreloProduct product) {
    setState(() => product.isFavorite = !product.isFavorite);
    _showMessage(product.isFavorite ? 'Produk ditambahkan ke favorit.' : 'Produk dihapus dari favorit.');
  }

  void _addToCart(PreloProduct product) {
    setState(() => _cartQuantities.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1));
    _showMessage('${product.name} ditambahkan ke keranjang.');
  }

  void _changeCartQuantity(String productId, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cartQuantities.remove(productId);
      } else {
        _cartQuantities[productId] = quantity;
      }
    });
  }

  void _removeCartItem(String productId) {
    setState(() => _cartQuantities.remove(productId));
    _showMessage('Produk dihapus dari keranjang.');
  }

  void _publishListing(PreloProduct product) {
    setState(() {
      _products.insert(0, product);
      _selectedIndex = 1;
    });
    _showMessage('Produk berhasil ditambahkan ke katalog lokal.');
  }

  void _openProduct(PreloProduct product) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProductDetailPage(
      product: product,
      onFavorite: () => _toggleFavorite(product),
      onAddToCart: () => _addToCart(product),
      onOpenGallery: () => _openGallery(product),
    )));
  }

  void _openGallery(PreloProduct product) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProductGalleryPage(product: product)));
  }

  void _openProfile() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage()));
  }

  void _checkout(int _) {
    final cartProducts = _products.where((product) => _cartQuantities.containsKey(product.id)).toList();
    if (cartProducts.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CheckoutPage(
      products: List<PreloProduct>.of(cartProducts),
      quantities: Map<String, int>.of(_cartQuantities),
      onConfirm: () {
        setState(() => _cartQuantities.clear());
        _showMessage('Simulasi pesanan selesai. Keranjang telah dikosongkan.');
      },
    )));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }

  void _goTo(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final cartProducts = _products.where((product) => _cartQuantities.containsKey(product.id)).toList();
    final pages = <Widget>[
      HomePage(
        products: _products,
        onFavorite: _toggleFavorite,
        onAddToCart: _addToCart,
        onOpenCatalog: () => _goTo(1),
        onOpenSell: () => _goTo(2),
        onOpenCart: () => _goTo(4),
        onOpenProfile: _openProfile,
        onOpenProduct: _openProduct,
        cartCount: _cartItemCount,
      ),
      CatalogPage(products: _products, onFavorite: _toggleFavorite, onAddToCart: _addToCart, onOpenProduct: _openProduct),
      SellPage(onPublish: _publishListing),
      FavoritesPage(
        products: _products.where((product) => product.isFavorite).toList(),
        onFavorite: _toggleFavorite,
        onAddToCart: _addToCart,
        onOpenProduct: _openProduct,
      ),
      CartPage(
        products: cartProducts,
        quantities: _cartQuantities,
        onQuantityChanged: _changeCartQuantity,
        onRemove: _removeCartItem,
        onContinueShopping: () => _goTo(1),
        onCheckout: _checkout,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 1000;
      return Scaffold(
        body: SafeArea(child: Row(children: [
          if (isDesktop) _DesktopSideNav(selectedIndex: _selectedIndex, onSelect: _goTo, cartCount: _cartItemCount),
          Expanded(child: IndexedStack(index: _selectedIndex, children: pages)),
        ])),
        bottomNavigationBar: isDesktop ? null : NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _goTo,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Beranda'),
            const NavigationDestination(icon: Icon(Icons.search_rounded), selectedIcon: Icon(Icons.manage_search_rounded), label: 'Katalog'),
            const NavigationDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box_rounded), label: 'Jual'),
            const NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'Favorit'),
            NavigationDestination(icon: _NavCartIcon(count: _cartItemCount), selectedIcon: _NavCartIcon(count: _cartItemCount, selected: true), label: 'Keranjang'),
          ],
        ),
      );
    });
  }
}

class _NavCartIcon extends StatelessWidget {
  const _NavCartIcon({required this.count, this.selected = false});
  final int count;
  final bool selected;
  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: count > 0, label: Text('$count'),
    child: Icon(selected ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined),
  );
}

class _DesktopSideNav extends StatelessWidget {
  const _DesktopSideNav({required this.selectedIndex, required this.onSelect, required this.cartCount});
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    const labels = ['Beranda', 'Katalog', 'Jual pakaian', 'Favorit', 'Keranjang'];
    const icons = [Icons.home_rounded, Icons.search_rounded, Icons.add_box_rounded, Icons.favorite_rounded, Icons.shopping_bag_rounded];
    return Container(
      width: 238,
      decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Color(0xFFECE7DE)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(22, 28, 16, 28), child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: kBrand, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.checkroom_rounded, color: Colors.white, size: 25)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PreloWear', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: kText)),
            Text('Wear it again', style: TextStyle(color: kMuted, fontSize: 11)),
          ])),
        ])),
        const Padding(padding: EdgeInsets.fromLTRB(22, 0, 12, 12), child: Text('MENU UTAMA', style: TextStyle(color: kMuted, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.4))),
        for (var i = 0; i < labels.length; i++) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: ListTile(
            dense: true, selected: selectedIndex == i, selectedTileColor: const Color(0xFFE7F2EC),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            leading: Icon(icons[i], color: selectedIndex == i ? kBrand : kMuted, size: 21),
            title: Row(children: [
              Expanded(child: Text(labels[i], style: TextStyle(fontWeight: selectedIndex == i ? FontWeight.w800 : FontWeight.w500, color: selectedIndex == i ? kBrandDark : kText, fontSize: 13))),
              if (i == 4 && cartCount > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: kBrand, borderRadius: BorderRadius.circular(20)),
                child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
            ]),
            onTap: () => onSelect(i),
          ),
        ),
        const Spacer(),
        Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color(0xFFF8E8D8), borderRadius: BorderRadius.circular(16)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.eco_rounded, color: kBrand, size: 26), SizedBox(height: 9),
            Text('Gaya baru, lebih berkelanjutan.', style: TextStyle(color: kText, fontWeight: FontWeight.w800, height: 1.3)),
            SizedBox(height: 5), Text('Temukan barang preloved yang masih punya cerita.', style: TextStyle(color: kMuted, fontSize: 11, height: 1.4)),
          ]),
        ),
      ]),
    );
  }
}
