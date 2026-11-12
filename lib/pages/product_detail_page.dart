import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../store/cart_store.dart';
import '../store/order_store.dart';
import '../store/chat_store.dart';
import 'cart_page.dart';
import 'checkout_page.dart';
import 'chat_detail_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String name, price, condition, imageUrl;
  final String? imageAsset;
  final Uint8List? imageBytes, evidenceImageBytes;
  final String sizeLabel, defects, description;
  final double? chestCm, lengthCm, shoulderCm, sleeveCm;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.condition,
    required this.imageUrl,
    this.imageAsset,
    this.imageBytes,
    this.evidenceImageBytes,
    this.sizeLabel = '-',
    this.chestCm,
    this.lengthCm,
    this.shoulderCm,
    this.sleeveCm,
    this.defects = 'Informasi kekurangan belum dicantumkan.',
    this.description =
        'Produk preloved yang nyaman digunakan dan masih terawat.',
  });

  // Gambar Produk
  Widget productImage() {
    const fallback = SizedBox(
      height: 330,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
        ),
      ),
    );

    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        height: 330,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    if (imageAsset != null && imageAsset!.isNotEmpty) {
      return Image.asset(
        imageAsset!,
        height: 330,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        height: 330,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return fallback;
  }

  // Format Ukuran
  String formatCm(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);

  Widget measurement(String title, double? value) =>
      value == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title),
                  Text(
                    '${formatCm(value)} cm',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );

  // Tambah Keranjang
  void addCart(BuildContext context) {
    CartStore.add(
      name,
      price,
      imageUrl,
      imageBytes: imageBytes,
      imageAsset: imageAsset,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Produk berhasil ditambahkan ke keranjang',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Membuka Chat Penjual
  void openChat(BuildContext context) {
    final chat = ChatStore.openOrCreate(
      productName: name,
      productPrice: price,
      sellerName: 'Penjual PreloWear',
      productImageUrl: imageUrl,
      productImageAsset: imageAsset,
      productImageBytes: imageBytes,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          conversationId: chat.id,
        ),
      ),
    );
  }

  // Menampilkan Rating Produk
  Widget ratingSection() =>
      ValueListenableBuilder<Map<String, List<int>>>(
        valueListenable: OrderStore.ratings,
        builder: (context, ratings, _) {
          final data = ratings[name] ?? [];
          final count = data.length;

          final average = count == 0
              ? 0.0
              : data.fold<int>(0, (a, b) => a + b) / count;

          return Row(
            children: [
              const Text(
                'Rating Produk',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                count == 0
                    ? 'Belum ada rating'
                    : '${average.toStringAsFixed(1)} ($count penilaian)',
              ),
            ],
          );
        },
      );

  // Menampilkan Ulasan Pembeli
  Widget reviewSection() =>
      ValueListenableBuilder<Map<String, List<String>>>(
        valueListenable: OrderStore.reviews,
        builder: (context, reviews, _) {
          final data = reviews[name] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ulasan Pembeli',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),

              if (data.isEmpty)
                const Text(
                  'Belum diulas',
                  style: TextStyle(color: Colors.black54),
                )
              else
                ...data.reversed.map(
                  (review) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5EEE9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.account_circle,
                          color: Color(0xFF89AC46),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(review)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final hasMeasurement =
        chestCm != null ||
        lengthCm != null ||
        shoulderCm != null ||
        sleeveCm != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          // Indikator Keranjang
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: CartStore.items,
            builder: (context, items, _) {
              final count = items.fold<int>(
                0,
                (sum, p) =>
                    sum + (p['quantity'] as int? ?? 1),
              );

              return IconButton(
                tooltip: 'Keranjang ($count)',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CartPage(),
                  ),
                ),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    if (count > 0)
                      Positioned(
                        top: -7,
                        right: -9,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 18,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Foto Produk
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: productImage(),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            price,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF89AC46),
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Chip(
            label: Text(condition),
            backgroundColor: const Color(0xFFE8EEDE),
          ),

          const Divider(height: 28),

          // Deskripsi Produk
          const Text(
            'Deskripsi Produk',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description.trim().isEmpty
                ? 'Deskripsi belum dicantumkan.'
                : description,
          ),

          const SizedBox(height: 20),

          // Informasi Ukuran
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Ukuran Aktual',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Label ukuran: ${sizeLabel.trim().isEmpty || sizeLabel == '-' ? 'Belum dicantumkan' : sizeLabel}',
                ),

                const Divider(),

                if (!hasMeasurement)
                  const Text(
                    'Ukuran aktual belum dicantumkan oleh penjual.',
                  )
                else ...[
                  measurement('Lingkar dada', chestCm),
                  measurement('Panjang pakaian', lengthCm),
                  measurement('Lebar bahu', shoulderCm),
                  measurement('Panjang lengan', sleeveCm),
                ],

                const SizedBox(height: 5),

                const Text(
                  'Ukuran menggunakan satuan sentimeter (cm).',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // PreloCheck
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PreloCheck - Informasi Kondisi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Kondisi Produk',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 4),

                Text(condition),

                const Divider(height: 24),

                const Text(
                  'Kekurangan Produk',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 4),

                Text(
                  defects.trim().isEmpty
                      ? 'Tidak ada kekurangan yang diketahui.'
                      : defects,
                ),

                if (evidenceImageBytes != null) ...[
                  const SizedBox(height: 14),

                  const Text(
                    'Foto Pendukung Kondisi',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      evidenceImageBytes!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(
                            Icons.broken_image_outlined,
                            size: 50,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Rating Produk
          ratingSection(),

          const SizedBox(height: 20),

          // Ulasan Pembeli
          reviewSection(),

          const SizedBox(height: 24),

          // Chat Penjual
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => openChat(context),
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
              ),
              label: const Text('Chat Penjual'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF89AC46),
                side: const BorderSide(
                  color: Color(0xFF89AC46),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Tombol Keranjang dan Beli
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => addCart(context),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Keranjang'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(
                        productName: name,
                        productPrice: price,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Beli Sekarang'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
