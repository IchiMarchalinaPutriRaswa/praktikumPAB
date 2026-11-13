import 'package:flutter/material.dart';
import '../store/order_store.dart';
import 'payment_page.dart';
import 'tracking_page.dart';
class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});
  static const reasons = [
    'Barang tidak sesuai deskripsi', 'Barang rusak atau cacat',
    'Barang berbeda dari foto', 'Ukuran tidak sesuai informasi',
    'Produk tidak lengkap', 'Lainnya',
  ];
  String dateLabel(dynamic value) {
    if (value is! DateTime) return '-';
    final d = value;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
  Future<void> giveReview(BuildContext context, String id, int index, String name) async {
    int selected = 0;
    String review = '';
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (d) => StatefulBuilder(builder: (context, setState) => AlertDialog(
        title: const Text('Beri Rating & Ulasan'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
            IconButton(onPressed: () => setState(() => selected = i + 1),
              icon: Icon(selected > i ? Icons.star : Icons.star_border, color: Colors.amber)))),
          TextField(maxLines: 3, onChanged: (v) => setState(() => review = v),
            decoration: const InputDecoration(hintText: 'Tuliskan ulasan produk...', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
          TextButton(onPressed: selected == 0 || review.trim().isEmpty ? null :
            () => Navigator.pop(d, {'rating': selected, 'review': review.trim()}),
            child: const Text('Kirim')),
        ],
      )),
    );
    if (result == null) return;
    OrderStore.addRating(name, result['rating'] as int);
    OrderStore.addReview(name, result['review'] as String);
    OrderStore.markReviewed(id, index);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating dan ulasan berhasil dikirim!')));
  }
  Future<void> requestReturn(BuildContext context, String id) async {
    String? reason;
    String detail = '';
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (d) => StatefulBuilder(builder: (context, setDialogState) {
        final valid = reason != null && (reason != 'Lainnya' || detail.trim().isNotEmpty);
        return AlertDialog(
          title: const Text('Pengajuan Retur', style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pilih alasan pengembalian barang:'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: reason, isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pilih alasan retur'),
                items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setDialogState(() => reason = v),
              ),
              const SizedBox(height: 16),
              const Text('Keterangan tambahan'),
              const SizedBox(height: 8),
              TextField(maxLines: 3, maxLength: 300, onChanged: (v) => setDialogState(() => detail = v),
                decoration: const InputDecoration(hintText: 'Jelaskan kondisi atau masalah barang...', border: OutlineInputBorder())),
            ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF89AC46), foregroundColor: Colors.white),
              onPressed: valid ? () => Navigator.pop(d, {'reason': reason!, 'detail': detail.trim()}) : null,
              child: const Text('Ajukan Pengembalian')),
          ],
        );
      }),
    );
    if (result == null) return;
    final detailText = result['detail'] ?? '';
    OrderStore.updateReturn(id, status: 'Menunggu persetujuan',
      reason: detailText.isEmpty ? result['reason']! : '${result['reason']} - $detailText');
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Pengajuan retur berhasil dikirim!'), backgroundColor: Color(0xFF89AC46)));
  }

  void openPayment(BuildContext c, String id) =>
      Navigator.push(c, MaterialPageRoute(builder: (_) => PaymentPage(orderId: id)));
  void openTracking(BuildContext c, String id) =>
      Navigator.push(c, MaterialPageRoute(builder: (_) => TrackingPage(orderId: id)));

  Widget info(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Expanded(child: Text(title, style: const TextStyle(color: Colors.black54))),
      Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );

  Widget productTile(BuildContext context, String id, int index, Map item) {
    final name = item['name']?.toString() ?? 'Produk';
    final done = item['reviewed'] == true;
    return ListTile(
      contentPadding: EdgeInsets.zero, title: Text(name),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item['price']?.toString() ?? ''),
        Text(done ? 'Sudah diulas' : 'Belum diulas',
          style: TextStyle(color: done ? Colors.green : Colors.deepOrange)),
      ]),
      trailing: done ? const Icon(Icons.check_circle, color: Colors.green) :
        TextButton(onPressed: () => giveReview(context, id, index, name), child: const Text('Beri Ulasan')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Riwayat Pesanan', style: TextStyle(fontWeight: FontWeight.w800))),
    body: ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: OrderStore.orders,
      builder: (context, orders, _) {
        if (orders.isEmpty) return const Center(child: Text('Belum ada pesanan'));
        return ListView.builder(
          padding: const EdgeInsets.all(16), itemCount: orders.length,
          itemBuilder: (context, i) {
            final o = orders[i];
            final id = o['id'].toString();
            final items = o['items'] as List? ?? [];
            final payStatus = o['paymentStatus']?.toString() ?? '-';
            final status = o['orderStatus']?.toString() ?? o['status']?.toString() ?? '-';
            final returnStatus = o['returnStatus']?.toString() ?? 'Belum diajukan';
            final returnReason = o['returnReason']?.toString() ?? '';
            final returnDate = o['returnDate'];
            final pending = payStatus == 'Menunggu pembayaran' || payStatus == 'Menunggu konfirmasi COD';
            final canReturn = status == 'Pesanan diterima' && returnStatus == 'Belum diajukan';
            final courier = o['courier']?.toString() ?? '';
            final tracking = o['trackingNumber']?.toString() ?? '';

            return Card(margin: const EdgeInsets.only(bottom: 16), child: Padding(
              padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ListTile(contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: Color(0xFFE8EEDE),
                    child: Icon(Icons.receipt_long, color: Color(0xFF89AC46))),
                  title: const Text('Pesanan PreloWear', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${dateLabel(o['date'])}\nID: $id')),
                const Divider(),
                const Text('Daftar Produk', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...items.asMap().entries.map((e) => productTile(context, id, e.key, Map<String, dynamic>.from(e.value as Map))),
                const Divider(height: 24),
                const Text('Informasi Pembayaran', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                info('Metode pembayaran', o['payment']?.toString() ?? '-'),
                info('Total pembayaran', o['totalPrice']?.toString() ?? '-'),
                info('Status pembayaran', payStatus),
                const Divider(height: 24),
                const Text('Informasi Pengiriman', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                info('Status pesanan', status),
                info('Nama kurir', courier.isEmpty ? 'Belum ditentukan' : courier),
                info('Nomor resi', tracking.isEmpty ? 'Belum tersedia' : tracking),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: OutlinedButton.icon(
                  onPressed: () => openTracking(context, id),
                  icon: const Icon(Icons.local_shipping_outlined), label: const Text('Lacak Pengiriman'))),
                const Divider(height: 24),
                const Text('Pengelolaan Retur', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                info('Status retur', returnStatus),
                if (returnReason.isNotEmpty) info('Alasan retur', returnReason),
                if (returnDate != null) info('Tanggal pengajuan', dateLabel(returnDate)),
                if (canReturn) ...[
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF89AC46), foregroundColor: Colors.white),
                    onPressed: () => requestReturn(context, id),
                    icon: const Icon(Icons.assignment_return_outlined), label: const Text('Ajukan Retur'))),
                ] else if (returnStatus == 'Belum diajukan')
                  const Padding(padding: EdgeInsets.only(top: 8), child: Text(
                    'Pengajuan retur tersedia setelah pesanan diterima.',
                    style: TextStyle(color: Colors.black54, fontSize: 12))),
                if (pending) ...[
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: () => openPayment(context, id),
                    icon: const Icon(Icons.account_balance_wallet_outlined),
                    label: Text(payStatus == 'Menunggu konfirmasi COD' ? 'Konfirmasi Pesanan COD' : 'Bayar Sekarang'))),
                ],
              ]),
            ));
          },
        );
      },
    ),
  );
}
