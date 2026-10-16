import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Halaman akun; Icon digunakan pada identitas, pengaturan, pesanan, dan bantuan.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Akun saya', style: TextStyle(fontWeight: FontWeight.w900))),
    body: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.all(constraints.maxWidth > 900 ? 32 : 16),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Column(
        children: [
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFECE6DD))),
            child: const Column(children: [
              CircleAvatar(radius: 42, backgroundColor: Color(0xFFE7F2EC), child: Icon(Icons.person_rounded, size: 46, color: kBrand)),
              SizedBox(height: 14), Text('Pengguna PreloWear', style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 20)),
              SizedBox(height: 5), Text('Belanja lebih bijak, gunakan kembali.', style: TextStyle(color: kMuted, fontSize: 12)),
            ])),
          const SizedBox(height: 18),
          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE6DD))),
            child: Column(children: [
              _ProfileAction(icon: Icons.receipt_long_outlined, title: 'Pesanan saya', subtitle: 'Lihat ringkasan pesanan simulasi', onTap: () => _showInfo(context, 'Riwayat pesanan akan tersedia jika aplikasi dihubungkan ke database.')),
              const Divider(height: 1, indent: 60, color: Color(0xFFECE6DD)),
              _ProfileAction(icon: Icons.favorite_border_rounded, title: 'Produk favorit', subtitle: 'Simpan barang yang kamu sukai', onTap: () => _showInfo(context, 'Buka menu Favorit pada navigasi utama untuk melihat barang tersimpan.')),
              const Divider(height: 1, indent: 60, color: Color(0xFFECE6DD)),
              _ProfileAction(icon: Icons.settings_outlined, title: 'Pengaturan', subtitle: 'Preferensi aplikasi', onTap: () => _showInfo(context, 'Pengaturan akun belum terhubung ke server.')),
              const Divider(height: 1, indent: 60, color: Color(0xFFECE6DD)),
              _ProfileAction(icon: Icons.help_outline_rounded, title: 'Bantuan', subtitle: 'Informasi penggunaan aplikasi', onTap: () => _showInfo(context, 'Periksa deskripsi produk dan kondisi barang sebelum membeli.')),
              const Divider(height: 1, indent: 60, color: Color(0xFFECE6DD)),
              _ProfileAction(icon: Icons.info_outline_rounded, title: 'Tentang PreloWear', subtitle: 'Marketplace pakaian preloved', onTap: () => _showInfo(context, 'PreloWear adalah proyek tugas Flutter dengan delapan kelompok widget dari modul.')),
            ])),
          const SizedBox(height: 18),
          const Text('Versi tugas 1.0 • Data disimpan lokal selama aplikasi berjalan', textAlign: TextAlign.center, style: TextStyle(color: kMuted, fontSize: 11)),
        ],
      ))),
    )),
  );

  static void _showInfo(BuildContext context, String text) {
    showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Mengerti'))],
    ));
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
    leading: Icon(icon, color: kBrand, size: 23),
    title: Text(title, style: const TextStyle(color: kText, fontWeight: FontWeight.w800, fontSize: 13)),
    subtitle: Text(subtitle, style: const TextStyle(color: kMuted, fontSize: 11)),
    trailing: const Icon(Icons.chevron_right_rounded, color: kMuted),
    onTap: onTap,
  );
}
