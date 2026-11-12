import 'package:flutter/material.dart';
import '../store/order_store.dart';
import 'payment_page.dart';
import 'tracking_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

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
      builder: (d) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Beri Rating & Ulasan'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                onPressed: () => setState(() => selected = i + 1),
                icon: Icon(selected > i ? Icons.star : Icons.star_border, color: Colors.amber),
              ))),
            TextField(maxLines: 3, onChanged: (v) => review = v,
              decoration: const InputDecoration(hintText: 'Tuliskan ulasan produk...', border: OutlineInputBorder())),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
            TextButton(
              onPressed: selected == 0 || review.trim().isEmpty ? null : () => Navigator.pop(d, {'rating': selected, 'review': review}),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;
    OrderStore.addRating(name, result['rating'] as int);
    OrderStore.addReview(name, result['review'] as String);
    OrderStore.markReviewed(id, index);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating dan ulasan berhasil dikirim!')));
  }

  void openPayment(BuildContext context, String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentPage(orderId: id)));
  }

  void openTracking(BuildContext context, String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TrackingPage(orderId: id)));
  }

  Widget info(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Expanded(child: Text(title, style: const TextStyle(color: Colors.black54))),
      Expanded(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );

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
            final order = orders[i];
            final id = order['id'].toString();
            final items = order['items'] as List? ?? [];
            final paymentStatus = order['paymentStatus']?.toString() ?? '-';
            final orderStatus = order['orderStatus']?.toString() ?? order['status']?.toString() ?? '-';
            final payment = order['payment']?.toString() ?? '-';
            final total = order['totalPrice']?.toString() ?? '-';
            final pendingPayment = paymentStatus == 'Menunggu pembayaran';
            final pendingCod = paymentStatus == 'Menunggu konfirmasi COD';
            final courier = order['courier']?.toString() ?? '';
            final trackingNumber = order['trackingNumber']?.toString() ?? '';
            final returnStatus = order['returnStatus']?.toString() ?? 'Belum diajukan';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: Color(0xFFE8EEDE),
                      child: Icon(Icons.receipt_long, color: Color(0xFF89AC46))),
                    title: const Text('Pesanan PreloWear', style: TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${dateLabel(order['date'])}\nID: $id'),
                  ),
                  const Divider(),
                  const Text('Daftar Produk', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),

                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = Map<String, dynamic>.from(entry.value as Map);
                    final name = item['name']?.toString() ?? 'Produk';
                    final done = item['reviewed'] == true;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(name),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item['price']?.toString() ?? ''),
                        Text(done ? 'Sudah diulas' : 'Belum diulas',
                          style: TextStyle(color: done ? Colors.green : Colors.deepOrange)),
                      ]),
                      trailing: done ? const Icon(Icons.check_circle, color: Colors.green)
                        : TextButton(onPressed: () => giveReview(context, id, index, name),
                            child: const Text('Beri Ulasan')),
                    );
                  }),

                  const Divider(height: 24),
                  const Text('Informasi Pembayaran', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  info('Metode pembayaran', payment),
                  info('Total pembayaran', total),
                  info('Status pembayaran', paymentStatus),

                  const Divider(height: 24),
                  const Text('Informasi Pengiriman', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  info('Status pesanan', orderStatus),
                  info('Nama kurir', courier.isEmpty ? 'Belum ditentukan' : courier),
                  info('Nomor resi', trackingNumber.isEmpty ? 'Belum tersedia' : trackingNumber),

                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => openTracking(context, id),
                      icon: const Icon(Icons.local_shipping_outlined),
                      label: const Text('Lacak Pengiriman'),
                    ),
                  ),

                  const Divider(height: 24),
                  const Text('Pengelolaan Retur', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  info('Status retur', returnStatus),

                  if (pendingPayment || pendingCod) ...[
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => openPayment(context, id),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: Text(pendingCod ? 'Konfirmasi Pesanan COD' : 'Bayar Sekarang'),
                      ),
                    ),
                  ],
                ]),
              ),
            );
          },
        );
      },
    ),
  );
}
