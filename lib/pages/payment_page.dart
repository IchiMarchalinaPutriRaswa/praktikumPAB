import 'package:flutter/material.dart';
import '../store/order_store.dart';
import '../store/cart_store.dart';

class PaymentPage extends StatelessWidget {
  final String orderId;
  const PaymentPage({super.key, required this.orderId});

  void processPayment(BuildContext context, Map<String, dynamic> order) {
    final isCod = order['payment'] == 'COD';

    OrderStore.updatePaymentStatus(
      orderId,
      isCod ? 'Pesanan dikonfirmasi (COD)' : 'Berhasil',
      orderStatus: 'Menunggu diproses',
    );

    if (order['fromCart'] == true) CartStore.clear();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(isCod
          ? 'Pesanan berhasil dikonfirmasi.'
          : 'Pembayaran berhasil.'),
    ));
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<Map<String, dynamic>>>(
    valueListenable: OrderStore.orders,
    builder: (context, orders, _) {
      final order = OrderStore.findById(orderId);

      if (order == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pembayaran')),
          body: const Center(child: Text('Pesanan tidak ditemukan.')),
        );
      }

      final payment = order['payment']?.toString() ?? '';
      final status = order['paymentStatus']?.toString() ?? '';
      final isCod = payment == 'COD';
      final isComplete = status == 'Berhasil' ||
          status == 'Pesanan dikonfirmasi (COD)';

      final items = (order['items'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map)).toList();
      final productName = items.map((e) =>
          e['name']?.toString() ?? 'Produk').join(', ');
      final total = order['totalPrice']?.toString() ??
          (items.length == 1 ? items.first['price']?.toString() : null) ?? '-';

      final description = switch (payment) {
        'Transfer bank' => 'Pembayaran melalui transfer bank. ',
        'E-Wallet' => 'Pembayaran melalui dompet digital. ',
        'Virtual Account' => 'Pembayaran menggunakan Virtual Account. ',
        _ => 'Pembayaran dilakukan secara tunai kepada kurir '
            'ketika pesanan diterima.',
      };

      return Scaffold(
        appBar: AppBar(title: const Text('Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w800))),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEDE),
              borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 45, color: Color(0xFF89AC46)),
              const SizedBox(height: 10),
              const Text('Total Pembayaran',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 5),
              Text(total, style: const TextStyle(fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Color(0xFF89AC46))),
            ]),
          ),
          const SizedBox(height: 22),
          const Text('Detail Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _info('Produk', productName),
          _info('Nama penerima', order['buyerName']?.toString() ?? '-'),
          _info('Metode pembayaran', payment),
          _info('Alamat', order['address']?.toString() ?? '-'),
          const Divider(height: 28),
          const Text('Instruksi Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(16)),
            child: Text(description),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEDE),
              borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              const Text('Status Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(status, style: const TextStyle(
                color: Color(0xFF89AC46),
                fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 22),
          if (!isComplete) ...[
            ElevatedButton(
              onPressed: () => processPayment(context, order),
              child: Text(isCod
                  ? 'Konfirmasi Pesanan' : 'Bayar Sekarang')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bayar Nanti')),
          ] else
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Selesai')),
        ]),
      );
    },
  );

  Widget _info(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title)),
        const SizedBox(width: 12),
        Expanded(child: Text(value, textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
  );
}
