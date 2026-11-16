import 'package:flutter/material.dart';
import '../store/order_store.dart';

class TrackingPage extends StatelessWidget {
  final String orderId;
  const TrackingPage({super.key, required this.orderId});

  static const green = Color(0xFF89AC46);

  String dateLabel(dynamic value) {
    if (value is! DateTime) return '-';
    final d = value;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} ${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: const TextStyle(
      fontSize: 17, fontWeight: FontWeight.w800)),
  );

  Widget infoTile(IconData icon, String title, String value) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8EEDE),
          child: Icon(icon, color: green)),
        title: Text(title, style: const TextStyle(
          fontSize: 12, color: Colors.black54)),
        subtitle: Text(value, style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700)),
      );

  Widget trackingHistory(List<Map<String, dynamic>> history) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Column(children: [
          Icon(Icons.local_shipping_outlined,
            size: 42, color: Colors.black26),
          SizedBox(height: 8),
          Text('Belum ada riwayat perjalanan paket.',
            style: TextStyle(color: Colors.black54)),
          SizedBox(height: 4),
          Text('Silakan tunggu pembaruan dari penjual.',
            style: TextStyle(fontSize: 12, color: Colors.black45)),
        ])),
      );
    }

    return Column(children: history.reversed.map((item) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8EEDE),
          child: Icon(Icons.check_circle, color: green)),
        title: Text(item['status']?.toString() ?? '-',
          style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${item['description'] ?? ''}\n${dateLabel(item['date'])}'),
      ),
    ).toList());
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<Map<String, dynamic>>>(
    valueListenable: OrderStore.orders,
    builder: (context, orders, _) {
      final matches = orders.where(
        (o) => o['id']?.toString() == orderId).toList();

      if (matches.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pelacakan Pengiriman')),
          body: const Center(child: Text('Pesanan tidak ditemukan.')),
        );
      }

      final order = matches.first;
      final status = order['orderStatus']?.toString()
          ?? order['status']?.toString() ?? '-';
      final courier = order['courier']?.toString() ?? '';
      final tracking = order['trackingNumber']?.toString() ?? '';
      final history = (order['trackingHistory'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e)).toList();

      final items = order['items'] as List? ?? [];

      return Scaffold(
        appBar: AppBar(title: const Text(
          'Pelacakan Pengiriman',
          style: TextStyle(fontWeight: FontWeight.w800))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEDE),
                borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                const Icon(Icons.local_shipping_outlined,
                  size: 48, color: green),
                const SizedBox(height: 10),
                const Text('Status Pengiriman',
                  style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Text(status, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 19,
                    fontWeight: FontWeight.w800, color: green)),
              ]),
            ),
            const SizedBox(height: 22),
            sectionTitle('Informasi Pesanan'),
            infoTile(Icons.receipt_long, 'ID Pesanan', orderId),
            if (items.isNotEmpty)
              infoTile(Icons.shopping_bag_outlined, 'Produk',
                items.map((e) => e['name'] ?? 'Produk').join(', ')),
            const Divider(height: 24),
            sectionTitle('Informasi Kurir'),
            infoTile(Icons.delivery_dining, 'Nama Kurir',
              courier.isEmpty ? 'Belum ditentukan' : courier),
            infoTile(Icons.confirmation_number_outlined, 'Nomor Resi',
              tracking.isEmpty ? 'Belum tersedia' : tracking),
            const Divider(height: 24),
            sectionTitle('Riwayat Perjalanan Paket'),
            trackingHistory(history),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F3),
                borderRadius: BorderRadius.circular(14)),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: green),
                  SizedBox(width: 10),
                  Expanded(child: Text(
                    'Informasi pengiriman diperbarui oleh penjual. '
                    'Periksa halaman ini untuk melihat perkembangan '
                    'status perjalanan pesanan.',
                    style: TextStyle(fontSize: 12,
                      color: Colors.black54))),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
