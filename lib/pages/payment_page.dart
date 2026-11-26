import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../store/order_store.dart';
import '../store/cart_store.dart';

class PaymentPage extends StatelessWidget {
  final String orderId;
  const PaymentPage({super.key, required this.orderId});

  static const green = Color(0xFF89AC46);

  String getBank(String payment) =>
      payment.contains(' - ') ? payment.split(' - ').last : 'BCA';

  String virtualAccount(String bank, String id) {
    const codes = {
      'BCA': '0140',
      'BRI': '0020',
      'BNI': '0090',
      'Mandiri': '0080',
      'BSI': '4510',
    };

    final digits = id.replaceAll(RegExp(r'[^0-9]'), '');
    final suffix = digits.length > 12
        ? digits.substring(digits.length - 12)
        : digits.padLeft(12, '0');

    return '${codes[bank] ?? '0140'}$suffix';
  }

  void confirmPayment(
    BuildContext context,
    Map<String, dynamic> order,
    bool isCod,
  ) {
    OrderStore.updatePaymentStatus(
      orderId,
      isCod ? 'Pesanan dikonfirmasi (COD)' : 'Berhasil',
      orderStatus: 'Menunggu diproses',
    );

    if (order['fromCart'] == true) {
      CartStore.removeSelected();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCod
              ? 'Pesanan COD berhasil dikonfirmasi.'
              : 'Pembayaran berhasil.',
        ),
      ),
    );
  }

  Widget info(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget paymentDetail(String payment) {
    if (payment.startsWith('Virtual Account')) {
      final bank = getBank(payment);
      final va = virtualAccount(bank, orderId);

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer melalui $bank',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const Text('Nomor Virtual Account'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      va,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: green,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: green),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: va),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              const Text('Instruksi pembayaran:'),
              const Text(
                '1. Buka aplikasi mobile banking.\n'
                '2. Pilih menu Virtual Account.\n'
                '3. Masukkan nomor VA di atas.\n'
                '4. Periksa nominal pembayaran.\n'
                '5. Lanjutkan pembayaran.',
              ),
            ],
          ),
        ),
      );
    }

    if (payment == 'QRIS') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Text(
                'Pembayaran QRIS',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Icon(
                Icons.qr_code_2,
                size: 150,
                color: green,
              ),
              const Text(
                'QRIS',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pindai kode QR menggunakan aplikasi '
                'pembayaran yang mendukung QRIS.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }

    if (payment.startsWith('E-Wallet')) {
      final wallet = getBank(payment);

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pembayaran $wallet',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Icon(
                Icons.account_balance_wallet,
                size: 45,
                color: green,
              ),
              const SizedBox(height: 10),
              Text(
                'Silakan lakukan pembayaran melalui aplikasi $wallet.',
              ),
              const SizedBox(height: 8),
              const Text(
                'Konfirmasi berikutnya merupakan pembayaran pesanan.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Pembayaran dilakukan secara tunai kepada kurir '
          'ketika pesanan diterima.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<Map<String, dynamic>>>(
    valueListenable: OrderStore.orders,
    builder: (context, orders, _) {
      final order = OrderStore.findById(orderId);

      if (order == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Pembayaran'),
          ),
          body: const Center(
            child: Text('Pesanan tidak ditemukan.'),
          ),
        );
      }

      final payment = order['payment']?.toString() ?? '';
      final status = order['paymentStatus']?.toString() ?? '';
      final isCod = payment == 'COD';

      final complete = status == 'Berhasil' ||
          status == 'Pesanan dikonfirmasi (COD)';

      final items = (order['items'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final names = items
          .map((e) => e['name'] ?? 'Produk')
          .join(', ');

      final total = order['totalPrice']?.toString() ?? '-';

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEDE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 45,
                    color: green,
                  ),
                  const SizedBox(height: 10),
                  const Text('Total Pembayaran'),
                  const SizedBox(height: 5),
                  Text(
                    total,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Detail Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            info('ID Pesanan', orderId),
            info('Produk', names),
            info('Penerima', order['buyerName'] ?? '-'),
            info('Alamat', order['address'] ?? '-'),
            info('Metode pembayaran', payment),

            const Divider(height: 28),

            // Instruksi pembayaran hanya tampil
            // jika pembayaran belum selesai.
            if (!complete) ...[
              const Text(
                'Instruksi Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              paymentDetail(payment),

              const SizedBox(height: 18),
            ],

            Card(
              color: const Color(0xFFE8EEDE),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Status Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (!complete) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      confirmPayment(context, order, isCod),
                  child: Text(
                    isCod
                        ? 'Konfirmasi Pesanan COD'
                        : 'Bayar Sekarang',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Bayar Nanti'),
                ),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Selesai'),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
