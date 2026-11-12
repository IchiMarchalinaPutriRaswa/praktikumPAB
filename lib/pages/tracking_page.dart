import 'package:flutter/material.dart';
import '../store/order_store.dart';

class TrackingPage extends StatefulWidget {
  final String orderId;
  const TrackingPage({super.key, required this.orderId});
  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final courierController = TextEditingController();
  final resiController = TextEditingController();
  static const green = Color(0xFF89AC46);
  static const statuses = [
    'Menunggu diproses', 'Pesanan dikemas', 'Diserahkan ke kurir',
    'Dalam perjalanan', 'Tiba di kota tujuan', 'Sedang diantar', 'Pesanan diterima',
  ];

  @override
  void initState() {
    super.initState();
    final order = OrderStore.orders.value.firstWhere(
      (o) => o['id']?.toString() == widget.orderId, orElse: () => {});
    courierController.text = order['courier']?.toString() ?? '';
    resiController.text = order['trackingNumber']?.toString() ?? '';
  }
  @override
  void dispose() {
    courierController.dispose();
    resiController.dispose();
    super.dispose();
  }
  List<Map<String, dynamic>> getHistory(Map<String, dynamic> order) =>
      (order['trackingHistory'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map)).toList();
  void updateOrder(Map<String, dynamic> changes) {
    OrderStore.orders.value = OrderStore.orders.value.map((order) =>
      order['id']?.toString() == widget.orderId ? {...order, ...changes} : order
    ).toList();
  }
  String dateLabel(dynamic value) {
    if (value is! DateTime) return '-';
    return '${value.day}/${value.month}/${value.year} '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
  void saveShipping(Map<String, dynamic> order) {
    final courier = courierController.text.trim();
    final resi = resiController.text.trim();
    if (courier.isEmpty || resi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Isi nama kurir dan nomor resi terlebih dahulu.')));
      return;
    }
    final history = getHistory(order);
    final status = order['orderStatus']?.toString() ?? 'Menunggu diproses';
    if (history.isEmpty) {
      history.add({
        'status': status,
        'description': 'Informasi pengiriman telah disimpan.',
        'date': DateTime.now(),
      });
    }
    updateOrder({
      'courier': courier, 'trackingNumber': resi,
      'orderStatus': status, 'trackingHistory': history,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Informasi pengiriman berhasil disimpan.')));
  }
  void advanceStatus(Map<String, dynamic> order) {
    final courier = courierController.text.trim();
    final resi = resiController.text.trim();
    if (courier.isEmpty || resi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lengkapi informasi kurir dan resi terlebih dahulu.')));
      return;
    }
    final current = order['orderStatus']?.toString() ?? '';
    final index = statuses.indexOf(current);
    final next = index < 0 ? 0 : index + 1;
    if (next >= statuses.length) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pesanan sudah sampai tujuan.')));
      return;
    }
    final status = statuses[next];
    final history = getHistory(order);
    history.add({
      'status': status,
      'description': 'Status pengiriman diperbarui menjadi $status.',
      'date': DateTime.now(),
    });
    updateOrder({
      'courier': courier, 'trackingNumber': resi,
      'orderStatus': status, 'trackingHistory': history,
    });
  }

  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
  );

  Widget trackingHistory(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return const Text('Belum ada riwayat perjalanan paket.',
      style: TextStyle(color: Colors.black54));
    return Column(children: history.map((item) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(backgroundColor: Color(0xFFE8EEDE),
        child: Icon(Icons.check_circle, color: green)),
      title: Text(item['status']?.toString() ?? '-',
        style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${item['description'] ?? ''}\n${dateLabel(item['date'])}'),
    )).toList());
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<Map<String, dynamic>>>(
    valueListenable: OrderStore.orders,
    builder: (context, orders, _) {
      final matches = orders.where(
        (order) => order['id']?.toString() == widget.orderId).toList();
      if (matches.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pelacakan Pengiriman')),
          body: const Center(child: Text('Pesanan tidak ditemukan.')));
      }
      final order = matches.first;
      final history = getHistory(order);
      final status = order['orderStatus']?.toString() ?? 'Menunggu diproses';
      return Scaffold(
        appBar: AppBar(title: const Text('Pelacakan Pengiriman',
          style: TextStyle(fontWeight: FontWeight.w800))),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: const Color(0xFFE8EEDE),
              borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              const Icon(Icons.local_shipping_outlined, size: 48, color: green),
              const SizedBox(height: 10),
              const Text('Status Pengiriman', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 6),
              Text(status, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: green)),
            ]),
          ),
          const SizedBox(height: 20),
          sectionTitle('Informasi Kurir'),
          TextField(controller: courierController,
            decoration: const InputDecoration(labelText: 'Nama kurir',
              prefixIcon: Icon(Icons.delivery_dining))),
          const SizedBox(height: 12),
          TextField(controller: resiController,
            decoration: const InputDecoration(labelText: 'Nomor resi',
              prefixIcon: Icon(Icons.receipt_long))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () => saveShipping(order),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Simpan Informasi Pengiriman'))),
          const Divider(height: 32),
          sectionTitle('Riwayat Perjalanan Paket'),
          trackingHistory(history),
          const Divider(height: 32),
          sectionTitle('Simulasi Perubahan Status'),
          const Text('Gunakan tombol berikut untuk mencoba perubahan status perjalanan pesanan.',
            style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => advanceStatus(order),
            icon: const Icon(Icons.local_shipping),
            label: const Text('Perbarui Status Pengiriman')),
        ]),
      );
    },
  );
}
