import 'package:flutter/material.dart';
import '../store/cart_store.dart';

class HomeBottomNavbar extends StatelessWidget {
  final ValueChanged<int> onTap;

  const HomeBottomNavbar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: CartStore.items,
      builder: (context, items, _) => NavigationBar(
        selectedIndex: 0,
        height: 76,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDDEFE7),
        onDestinationSelected: onTap,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Katalog'),
          const NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Jual'),
          NavigationDestination(icon: _CartIcon(count: items.length), selectedIcon: _CartIcon(count: items.length), label: 'Keranjang'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  final int count;

  const _CartIcon({required this.count});

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      const Icon(Icons.shopping_bag_outlined),
      if (count > 0)
        Positioned(
          top: -7, right: -11,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
            child: Text(count > 99 ? '99+' : '$count', textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
    ],
  );
}