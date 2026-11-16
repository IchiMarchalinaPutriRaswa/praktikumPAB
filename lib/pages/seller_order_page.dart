import 'package:flutter/material.dart';
import '../store/order_store.dart';

class SellerOrderPage extends StatelessWidget {
  const SellerOrderPage({super.key});
  static const green = Color(0xFF89AC46);
  static const statuses = [
    'Menunggu diproses', 'Pesanan dikemas',
    'Diserahkan ke kurir', 'Dalam perjalanan',
    'Tiba di kota tujuan', 'Sedang diantar',
    'Pesanan diterima',
  ];

  String dateLabel(dynamic d) => d is! DateTime ? '-' :
      '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';

  Widget info(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Expanded(child: Text(title,
        style: const TextStyle(color: Colors.black54))),
      Expanded(child: Text(value, textAlign: TextAlign.end,
        style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );

  void message(BuildContext c, String text) =>
      ScaffoldMessenger.of(c).showSnackBar(
        SnackBar(content: Text(text)));

  Future<void> confirmCod(BuildContext c, String id) async {
    final ok = await showDialog<bool>(context: c, builder: (d) =>
      AlertDialog(
        title: const Text('Konfirmasi Pesanan COD'),
        content: const Text('Terima pesanan COD ini dan lanjutkan ke proses pengemasan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false),
            child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(d, true),
            child: const Text('Konfirmasi')),
        ],
      ));
    if (ok != true) return;
    OrderStore.updateOrderStatus(id, 'Menunggu diproses');
    OrderStore.updatePaymentStatus(
      id, 'COD - dibayar saat barang diterima');
    if (c.mounted) message(c, 'Pesanan COD berhasil dikonfirmasi.');
  }

  Future<void> decideReturn(BuildContext c, String id, bool approve) async {
    final ok = await showDialog<bool>(context: c, builder: (d) =>
      AlertDialog(
        title: Text(approve ? 'Setujui Retur?' : 'Tolak Retur?'),
        content: Text(approve
          ? 'Yakin ingin menyetujui pengembalian barang?'
          : 'Yakin ingin menolak pengembalian barang?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false),
            child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? green : Colors.red,
              foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(d, true),
            child: Text(approve ? 'Setujui' : 'Tolak')),
        ],
      ));
    if (ok != true) return;
    OrderStore.updateReturnDecision(id,
      status: approve ? 'Retur disetujui' : 'Retur ditolak');
    if (c.mounted) message(c,
      approve ? 'Retur berhasil disetujui.' : 'Retur ditolak.');
  }

  Future<void> manageShipment(
      BuildContext c, Map<String, dynamic> o) async {
    final id = o['id'].toString();
    final courier = TextEditingController(text: o['courier'] ?? '');
    final resi = TextEditingController(text: o['trackingNumber'] ?? '');
    final old = o['orderStatus']?.toString() ?? '';
    var selected = statuses.contains(old) ? old : statuses.first;

    final result = await showDialog<bool>(context: c, builder: (d) =>
      StatefulBuilder(builder: (context, setState) => AlertDialog(
        title: const Text('Kelola Pengiriman'),
        content: SingleChildScrollView(child: Column(
          mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: courier,
              decoration: const InputDecoration(labelText: 'Nama Kurir',
                border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: resi,
              decoration: const InputDecoration(labelText: 'Nomor Resi',
                border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selected, isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Status Pengiriman',
                border: OutlineInputBorder()),
              items: statuses.map((s) =>
                DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => selected = v);
              },
            ),
          ],
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false),
            child: const Text('Batal')),
          ElevatedButton(onPressed: () {
            if (selected != statuses.first &&
                (courier.text.trim().isEmpty ||
                 resi.text.trim().isEmpty)) {
              message(c, 'Lengkapi nama kurir dan nomor resi.');
              return;
            }
            Navigator.pop(d, true);
          }, child: const Text('Simpan')),
        ],
      )));

    if (result != true) {
      courier.dispose();
      resi.dispose();
      return;
    }

    final cName = courier.text.trim();
    final number = resi.text.trim();
    courier.dispose();
    resi.dispose();

    final history = (o['trackingHistory'] as List? ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e)).toList();

    if (selected != old || history.isEmpty) {
      history.add({
        'status': selected,
        'description': 'Status pengiriman diperbarui menjadi $selected.',
        'date': DateTime.now(),
      });
    }

    OrderStore.updateTracking(id, courier: cName,
      trackingNumber: number, history: history);
    OrderStore.updateOrderStatus(id, selected);

    if (selected == 'Pesanan diterima' &&
        o['payment']?.toString().toUpperCase() == 'COD') {
      OrderStore.updatePaymentStatus(id, 'Pembayaran COD diterima');
    }
    if (c.mounted) message(c, 'Informasi pengiriman berhasil disimpan.');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pesanan Masuk',
      style: TextStyle(fontWeight: FontWeight.w800))),
    body: ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: OrderStore.orders,
      builder: (context, orders, _) {
        if (orders.isEmpty) {
          return const Center(child: Text('Belum ada pesanan masuk'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final o = orders[i], id = o['id'].toString();
            final items = o['items'] as List? ?? [];
            final payment = o['paymentStatus']?.toString() ?? '-';
            final method = o['payment']?.toString() ?? '-';
            final status = o['orderStatus']?.toString() ?? '-';
            final cod = method.toUpperCase() == 'COD';
            final paid = payment.toLowerCase().contains('berhasil');
            final codPending = cod && status == 'Menunggu konfirmasi COD';
            final completed = status == 'Pesanan diterima';
            final canManage = !completed &&
                (cod ? !codPending : paid);
            final returnStatus = o['returnStatus']?.toString() ?? 'Belum diajukan';
            final reason = o['returnReason']?.toString() ?? '';
            final pending = returnStatus == 'Menunggu persetujuan';

            return Card(margin: const EdgeInsets.only(bottom: 16),
              child: Padding(padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE5EEE9),
                        child: Icon(Icons.receipt_long, color: green)),
                      title: const Text('Pesanan PreloWear',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text('${dateLabel(o['date'])}\nID: $id')),
                    const Divider(),
                    const Text('Informasi Pembeli',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                    info('Nama', o['buyerName']?.toString() ?? '-'),
                    info('Alamat', o['address']?.toString() ?? '-'),
                    const Divider(),
                    const Text('Produk Dipesan',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                    ...items.map((e) {
                      final p = Map<String, dynamic>.from(e as Map);
                      return ListTile(contentPadding: EdgeInsets.zero,
                        title: Text(p['name']?.toString() ?? 'Produk'),
                        subtitle: Text(p['price']?.toString() ?? ''));
                    }),
                    const Divider(),
                    const Text('Informasi Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                    info('Metode', method),
                    info('Total', o['totalPrice']?.toString() ?? '-'),
                    info('Status', payment),
                    const Divider(),
                    const Text('Informasi Pengiriman',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                    info('Status pesanan', status),
                    info('Kurir', o['courier']?.toString().isNotEmpty == true
                      ? o['courier'].toString() : 'Belum ditentukan'),
                    info('Nomor resi', o['trackingNumber']?.toString().isNotEmpty == true
                      ? o['trackingNumber'].toString() : 'Belum tersedia'),
                    SizedBox(width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green, foregroundColor: Colors.white),
                        onPressed: completed ? null : codPending
                          ? () => confirmCod(context, id)
                          : canManage ? () => manageShipment(context, o) : null,
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: Text(completed ? 'Pesanan Selesai'
                          : codPending ? 'Konfirmasi Pesanan COD'
                          : canManage ? 'Kelola Pengiriman'
                          : 'Menunggu Pembayaran'))),
                    const Divider(height: 28),
                    const Text('Pengajuan Retur',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                    info('Status retur', returnStatus),
                    if (reason.isNotEmpty) info('Alasan retur', reason),
                    if (o['returnDate'] != null)
                      info('Tanggal pengajuan', dateLabel(o['returnDate'])),
                    if (pending) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red),
                          onPressed: () => decideReturn(context, id, false),
                          child: const Text('Tolak'))),
                        const SizedBox(width: 10),
                        Expanded(child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white),
                          onPressed: () => decideReturn(context, id, true),
                          child: const Text('Setujui'))),
                      ]),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
