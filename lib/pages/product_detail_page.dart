import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../store/cart_store.dart';
import '../store/order_store.dart';
import '../store/chat_store.dart';
import 'cart_page.dart';
import 'checkout_page.dart';
import 'chat_detail_page.dart';
import 'fit_match_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String name, price, condition, imageUrl;
  final String? imageAsset;
  final Uint8List? imageBytes;
  final List<Uint8List> images;
  final List<String> imageAssets;
  final String sizeLabel, defects, description;
  final double? chestCm, lengthCm, shoulderCm, sleeveCm;
  final double? waistCm, hipCm, thighCm;

  const ProductDetailPage({
    super.key, required this.name, required this.price,
    required this.condition, required this.imageUrl,
    this.imageAsset, this.imageBytes,
    this.images = const [], this.imageAssets = const [],
    this.sizeLabel = '-', this.chestCm, this.lengthCm,
    this.shoulderCm, this.sleeveCm,
    this.waistCm, this.hipCm, this.thighCm,
    this.defects = 'Informasi kekurangan belum dicantumkan.',
    this.description = 'Produk preloved yang nyaman digunakan dan masih terawat.',
  });

  // Mendeteksi kategori produk
  bool get isBottom {
    final text = '$name $description'.toLowerCase();
    return ['bawahan', 'celana', 'jeans', 'pants',
      'trouser', 'rok', 'skirt'].any(text.contains);
  }

  // Mengambil lingkar pinggang dari deskripsi jika data belum tersedia
  double? get actualWaistCm {
    if (waistCm != null) return waistCm;

    final match = RegExp(
      r'lingkar\s+pinggang\s*[:=]?\s*(\d+(?:[.,]\d+)?)\s*cm',
      caseSensitive: false,
    ).firstMatch(description);

    return match == null ? null :
        double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  // Memeriksa ketersediaan ukuran
  bool get hasMeasurement => isBottom
      ? actualWaistCm != null || lengthCm != null
      : chestCm != null || lengthCm != null ||
          shoulderCm != null || sleeveCm != null;

  // Gambar Produk
  Widget productImage() {
    const fallback = SizedBox(
      height: 330,
      child: Center(child: Icon(
        Icons.image_not_supported_outlined, size: 48)),
    );

    if (imageBytes != null) {
      return Image.memory(imageBytes!, height: 330,
        width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback);
    }
    if (imageAsset?.isNotEmpty == true) {
      return Image.asset(imageAsset!, height: 330,
        width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback);
    }
    if (imageUrl.isNotEmpty) {
      return Image.network(imageUrl, height: 330,
        width: double.infinity, fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback);
    }
    return fallback;
  }

  String formatCm(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);

  String reviewDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Widget measurement(String title, double? value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text('${formatCm(value)} cm',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // Tambah Keranjang
  void addCart(BuildContext context) {
    CartStore.add(name, price, imageUrl,
      imageBytes: imageBytes, imageAsset: imageAsset,
      imageAssets: imageAssets);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produk berhasil ditambahkan ke keranjang'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Membuka FitMatch sesuai kategori
  void openFitMatch(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => FitMatchPage(
        productName: name,
        sizeLabel: sizeLabel,
        category: isBottom ? 'bawahan' : 'atasan',
        chestCm: chestCm,
        lengthCm: lengthCm,
        shoulderCm: shoulderCm,
        sleeveCm: sleeveCm,
        waistCm: actualWaistCm,
        hipCm: hipCm,
        thighCm: thighCm,
      ),
    ));
  }

  // Membuka Chat Penjual
  void openChat(BuildContext context) {
    final chat = ChatStore.openOrCreate(
      productName: name, productPrice: price,
      sellerName: 'Penjual PreloWear',
      productImageUrl: imageUrl,
      productImageAsset: imageAsset,
      productImageBytes: imageBytes,
    );
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChatDetailPage(conversationId: chat.id)));
  }

  // Rating Produk
  Widget ratingSection() {
    return ValueListenableBuilder<Map<String, List<int>>>(
      valueListenable: OrderStore.ratings,
      builder: (context, ratings, _) {
        final saved = ratings[name];
        final data = saved == null || saved.isEmpty
            ? OrderStore.sampleReviewsFor(name)
                .map((r) => r.rating).toList()
            : saved;
        final count = data.length;
        final average = count == 0 ? 0.0 :
            data.fold<int>(0, (a, b) => a + b) / count;

        return Row(children: [
          const Text('Rating Produk',
            style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          const Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 4),
          Text(count == 0 ? 'Belum ada rating' :
            '${average.toStringAsFixed(1)} ($count penilaian)'),
        ]);
      },
    );
  }

  // Ulasan Pembeli
  Widget reviewSection() {
    return ValueListenableBuilder<Map<String, List<ProductReview>>>(
      valueListenable: OrderStore.reviewHistory,
      builder: (context, history, _) {
        final saved = history[name];
        final data = saved == null || saved.isEmpty
            ? OrderStore.sampleReviewsFor(name) : saved;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ulasan Pembeli',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (data.isEmpty)
              const Text('Belum diulas',
                style: TextStyle(color: Colors.black54))
            else
              ...data.reversed.map((review) {
                final buyer = review.buyerName.trim().isEmpty
                    ? 'Pembeli' : review.buyerName.trim();
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEE9),
                    borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 19,
                        backgroundColor: const Color(0xFF89AC46),
                        child: Text(buyer[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold))),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(child: Text(buyer,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700))),
                            Text(reviewDate(review.date),
                              style: const TextStyle(fontSize: 11,
                                color: Colors.black54)),
                          ]),
                          const SizedBox(height: 5),
                          Row(children: List.generate(5, (i) => Icon(
                            i < review.rating ? Icons.star_rounded :
                                Icons.star_border_rounded,
                            color: Colors.amber, size: 17))),
                          const SizedBox(height: 7),
                          Text(review.comment),
                        ],
                      )),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detail Produk'),
      actions: [
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: CartStore.items,
          builder: (context, items, _) {
            final count = items.fold<int>(0,
              (sum, p) => sum + (p['quantity'] as int? ?? 1));
            return IconButton(
              tooltip: 'Keranjang ($count)',
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CartPage())),
              icon: Stack(clipBehavior: Clip.none, children: [
                const Icon(Icons.shopping_bag_outlined),
                if (count > 0)
                  Positioned(top: -7, right: -9,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12)),
                      child: Text(count > 99 ? '99+' : '$count',
                        style: const TextStyle(color: Colors.white,
                          fontSize: 10, fontWeight: FontWeight.bold)),
                    )),
              ]),
            );
          },
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Foto Produk
        Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: ProductImageCarousel(
            images: images, imageAssets: imageAssets,
            fallback: productImage()),
        )),
        const SizedBox(height: 18),
        Text(name, style: const TextStyle(
          fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(price, style: const TextStyle(fontSize: 22,
          color: Color(0xFF89AC46), fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Chip(label: Text(condition),
          backgroundColor: const Color(0xFFE8EEDE)),
        const Divider(height: 28),

        // Deskripsi Produk
        const Text('Deskripsi Produk',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(description.trim().isEmpty
            ? 'Deskripsi belum dicantumkan.' : description),
        const SizedBox(height: 20),

        // Informasi Ukuran
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informasi Ukuran Aktual',
                style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text('Label ukuran: ${sizeLabel.trim().isEmpty ||
                  sizeLabel == '-' ? 'Belum dicantumkan' : sizeLabel}'),
              const Divider(),
              if (!hasMeasurement)
                const Text('Ukuran aktual belum dicantumkan oleh penjual.')
              else if (isBottom) ...[
                measurement('Lingkar pinggang', actualWaistCm),
                measurement('Panjang celana', lengthCm),
              ] else ...[
                measurement('Lingkar dada', chestCm),
                measurement('Panjang pakaian', lengthCm),
                measurement('Lebar bahu', shoulderCm),
                measurement('Panjang lengan', sleeveCm),
              ],
              const SizedBox(height: 5),
              const Text('Ukuran menggunakan satuan sentimeter (cm).',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // FitMatch
        SizedBox(width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => openFitMatch(context),
            icon: const Icon(Icons.straighten_rounded),
            label: const Text('Cek Kecocokan Ukuran (FitMatch)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF89AC46),
              side: const BorderSide(color: Color(0xFF89AC46)),
              padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
        if (!hasMeasurement)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Ukuran aktual produk belum dicantumkan. '
              'Hasil perbandingan mungkin terbatas.',
              style: TextStyle(fontSize: 12, color: Colors.black54))),
        const SizedBox(height: 20),

        // PreloCheck
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PreloCheck - Informasi Kondisi',
                style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text('Kondisi Produk',
                style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(condition),
              const Divider(height: 24),
              const Text('Kekurangan Produk',
                style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(defects.trim().isEmpty
                  ? 'Tidak ada kekurangan yang diketahui.' : defects),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Rating dan Ulasan
        ratingSection(),
        const SizedBox(height: 20),
        reviewSection(),
        const SizedBox(height: 24),

        // Chat Penjual
        SizedBox(width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => openChat(context),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Chat Penjual'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF89AC46),
              side: const BorderSide(color: Color(0xFF89AC46)),
              padding: const EdgeInsets.symmetric(vertical: 13)),
          )),
        const SizedBox(height: 10),

        // Keranjang dan Beli Sekarang
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => addCart(context),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Keranjang'))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => CheckoutPage(
                productName: name, productPrice: price))),
            icon: const Icon(Icons.flash_on),
            label: const Text('Beli Sekarang'))),
        ]),
      ],
    ),
  );
}

// Carousel Foto Produk
class ProductImageCarousel extends StatefulWidget {
  final List<Uint8List> images;
  final List<String> imageAssets;
  final Widget fallback;

  const ProductImageCarousel({
    super.key, required this.images,
    required this.imageAssets, required this.fallback,
  });

  @override
  State<ProductImageCarousel> createState() =>
      _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int currentImage = 0;

  int get totalImages =>
      widget.images.length + widget.imageAssets.length;

  @override
  Widget build(BuildContext context) {
    if (totalImages == 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: widget.fallback);
    }

    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 330,
          child: PageView.builder(
            itemCount: totalImages,
            onPageChanged: (index) =>
                setState(() => currentImage = index),
            itemBuilder: (context, index) {
              if (index < widget.images.length) {
                return Image.memory(widget.images[index],
                  width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(Icons.broken_image_outlined, size: 48)));
              }

              final assetIndex = index - widget.images.length;
              return Image.asset(widget.imageAssets[assetIndex],
                width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.broken_image_outlined, size: 48)));
            },
          ),
        ),
      ),
      if (totalImages > 1) ...[
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalImages, (index) =>
            Container(
              width: currentImage == index ? 20 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: currentImage == index
                    ? const Color(0xFF89AC46)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10)),
            )),
        ),
        const SizedBox(height: 5),
        Text('${currentImage + 1}/$totalImages',
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ]);
  }
}
