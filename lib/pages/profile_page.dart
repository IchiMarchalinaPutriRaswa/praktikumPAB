import 'package:flutter/material.dart';
import 'order_history_page.dart';
import 'favorite_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Profil Saya',
        style: TextStyle(fontWeight: FontWeight.w800)),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE5EEE9),
            borderRadius: BorderRadius.circular(22)),
          child: const Column(children: [
            CircleAvatar(radius: 38, backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 42,
                color: Color(0xFF89AC46))),
            SizedBox(height: 12),
            Text('Pengguna PreloWear',
              style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Biodata Pengguna',
              style: TextStyle(color: Colors.black54)),
          ]),
        ),
        const SizedBox(height: 20),

        // Menu Favorit
        _MenuTile(
          icon: Icons.favorite,
          title: 'Favorit Saya',
          subtitle: 'Lihat produk yang disimpan',
          onTap: () => Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => const FavoritePage())),
        ),

        // Menu Riwayat Pesanan
        _MenuTile(
          icon: Icons.receipt_long,
          title: 'Riwayat Pesanan',
          subtitle: 'Lihat pesanan dan berikan rating',
          onTap: () => Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => const OrderHistoryPage())),
        ),

        const SizedBox(height: 20),
        const Text('Informasi Pribadi',
          style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const _BiodataTile(
          icon: Icons.person_outline,
          title: 'Nama Lengkap',
          value: 'Pengguna PreloWear'),
        const _BiodataTile(
          icon: Icons.phone_outlined,
          title: 'Nomor Telepon',
          value: '085372829198'),
        const _BiodataTile(
          icon: Icons.location_on_outlined,
          title: 'Alamat',
          value: 'Purworejo'),
      ],
    ),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon, required this.title,
    required this.subtitle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE5EEE9),
        child: Icon(icon, color: const Color(0xFF89AC46))),
      title: Text(title,
        style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}

class _BiodataTile extends StatelessWidget {
  final IconData icon;
  final String title, value;

  const _BiodataTile({
    required this.icon, required this.title, required this.value,
  });

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 10),
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14)),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE5EEE9),
        child: Icon(icon, color: const Color(0xFF89AC46))),
      title: Text(title,
        style: const TextStyle(fontSize: 13,
          color: Colors.black54)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(value,
          style: const TextStyle(fontSize: 15,
            fontWeight: FontWeight.w600)),
      ),
    ),
  );
}