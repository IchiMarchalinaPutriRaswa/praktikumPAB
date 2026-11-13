import 'package:flutter/foundation.dart';

class ProductReview {
  final String buyerName;
  final int rating;
  final String comment;
  final DateTime date;

  const ProductReview({
    required this.buyerName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class OrderStore {
  static final orders = ValueNotifier<List<Map<String, dynamic>>>([]);

  static ProductReview _sample(
    String buyer,
    int rating,
    String comment,
    int days,
  ) =>
      ProductReview(
        buyerName: buyer,
        rating: rating,
        comment: comment,
        date: DateTime.now().subtract(Duration(days: days)),
      );

  // Data Sampel Rating dan Ulasan Sesuai ProductStore
  static final Map<String, List<ProductReview>> _sampleReviewData = {
    'Adidas Denim Jacket': [
      _sample('Andini', 5, 'Jaket masih bagus dan sesuai deskripsi.', 15),
      _sample('Rizky', 5, 'Bahan nyaman dan kualitasnya memuaskan.', 8),
      _sample('Nadia', 4, 'Produk bagus dan pengiriman cepat.', 2),
    ],

    'JHL Wide Leg Jeans': [
      _sample('Dinda', 5, 'Model wide leg bagus dan nyaman dipakai.', 15),
      _sample('Fajar', 4, 'Celana sesuai foto dan ukurannya pas.', 8),
      _sample('Putri', 3, 'Kondisi sesuai deskripsi dan tetap nyaman.', 2),
    ],

    'Knit Sweater': [
      _sample('Salsa', 5, 'Sweater lembut dan masih terawat.', 15),
      _sample('Aulia', 5, 'Warna sesuai foto dan nyaman dipakai.', 8),
      _sample('Rani', 4, 'Kualitas bagus dan jahitan rapi.', 2),
    ],

    'Adidas Pink Jacket': [
      _sample('Bima', 5, 'Warna pink cantik dan desainnya menarik.', 15),
      _sample('Nisa', 4, 'Jaket nyaman dan sesuai foto.', 8),
      _sample('Dewi', 4, 'Kondisi produk masih sangat baik.', 2),
    ],

    'Blue Pattern Baggy Jeans': [
      _sample('Maya', 5, 'Motif jeans unik dan modelnya keren.', 15),
      _sample('Intan', 4, 'Celana sesuai foto dan ukurannya pas.', 8),
      _sample('Citra', 5, 'Model baggy nyaman digunakan.', 2),
    ],

    'Houndstooth Vest': [
      _sample('Ayu', 5, 'Motif vest cantik dan masih seperti baru.', 15),
      _sample('Rika', 4, 'Modelnya bagus dan mudah dipadukan.', 8),
      _sample('Lina', 3, 'Kondisi produk sangat memuaskan.', 2),
    ],

    'Floral Embroidery Knit Cardigan': [
      _sample('Nadia', 2, 'Detail bordir cantik dan masih rapi.', 15),
      _sample('Anisa', 5, 'Cardigan nyaman dan sesuai foto.', 8),
      _sample('Vina', 4, 'Bagus, hanya sedikit berbeda warna.', 2),
    ],

    'Amora Button Blouse': [
      _sample('Sinta', 5, 'Blouse cantik dan bahannya nyaman.', 15),
      _sample('Nabila', 4, 'Kondisi masih bagus dan sesuai harga.', 8),
      _sample('Della', 5, 'Sangat suka dengan produknya.', 2),
    ],

    'Stussy x Dickies Jacket': [
      _sample('Rafi', 5, 'Desain jaket keren dan bahannya nyaman.', 15),
      _sample('Ardi', 4, 'Jaket sesuai deskripsi dan foto.', 8),
      _sample('Dimas', 5, 'Model workwear bagus dan terlihat keren.', 2),
    ],
  };

  // Mengambil Sampel Ulasan Produk
  static List<ProductReview> sampleReviewsFor(String name) =>
      _sampleReviewData[name] ?? [
        _sample('Nadia', 5, 'Produk sesuai deskripsi dan masih bagus.', 15),
        _sample('Rizky', 4, 'Kualitas produk memuaskan.', 8),
        _sample('Aulia', 5, 'Produk nyaman dan sesuai foto.', 2),
      ];

  // Riwayat Ulasan Awal
  static final reviewHistory =
      ValueNotifier<Map<String, List<ProductReview>>>({
    for (final e in _sampleReviewData.entries)
      e.key: List<ProductReview>.from(e.value),
  });

  // Rating Awal
  static final ratings = ValueNotifier<Map<String, List<int>>>({
    for (final e in _sampleReviewData.entries)
      e.key: e.value.map((r) => r.rating).toList(),
  });

  // Komentar Awal
  static final reviews = ValueNotifier<Map<String, List<String>>>({
    for (final e in _sampleReviewData.entries)
      e.key: e.value.map((r) => r.comment).toList(),
  });

  // Menambahkan Pesanan
  static String addOrder({
    required List<Map<String, dynamic>> items,
    required String buyerName,
    required String address,
    required String payment,
    String? totalPrice,
    bool fromCart = false,
  }) {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final status = payment == 'COD'
        ? 'Menunggu konfirmasi COD'
        : 'Menunggu pembayaran';

    orders.value = [
      {
        'id': id,
        'date': now,
        'items': items.map((item) => {
          ...item,
          'rated': false,
          'reviewed': false,
        }).toList(),
        'buyerName': buyerName,
        'address': address,
        'payment': payment,
        'totalPrice': totalPrice,
        'paymentStatus': status,
        'orderStatus': status,
        'status': status,
        'fromCart': fromCart,
        'courier': '',
        'trackingNumber': '',
        'trackingHistory': <Map<String, dynamic>>[],
        'returnStatus': 'Belum diajukan',
        'returnReason': '',
        'returnDate': null,
      },
      ...orders.value,
    ];

    return id;
  }

  // Mencari Pesanan
  static Map<String, dynamic>? findById(String id) {
    for (final order in orders.value) {
      if (order['id'].toString() == id) return order;
    }
    return null;
  }

  // Memperbarui Status Pembayaran
  static void updatePaymentStatus(
    String id,
    String paymentStatus, {
    String? orderStatus,
  }) {
    final changes = <String, dynamic>{
      'paymentStatus': paymentStatus,
    };

    if (orderStatus != null) {
      changes['orderStatus'] = orderStatus;
      changes['status'] = orderStatus;
    }

    _updateOrder(id, changes);
  }

  // Memperbarui Status Pesanan
  static void updateOrderStatus(String id, String status) =>
      _updateOrder(id, {
        'orderStatus': status,
        'status': status,
      });

  // Memperbarui Informasi Pengiriman
  static void updateTracking(
    String id, {
    required String courier,
    required String trackingNumber,
    required List<Map<String, dynamic>> history,
  }) =>
      _updateOrder(id, {
        'courier': courier,
        'trackingNumber': trackingNumber,
        'trackingHistory': history,
      });

  // Memperbarui Status Pengembalian
  static void updateReturn(
    String id, {
    required String status,
    String reason = '',
  }) =>
      _updateOrder(id, {
        'returnStatus': status,
        'returnReason': reason,
        'returnDate': DateTime.now(),
      });

  // Menambahkan Rating
  static void addRating(String name, int rating) {
    if (rating < 1 || rating > 5) return;

    final updated = Map<String, List<int>>.from(ratings.value);
    final current = updated[name] ??
        sampleReviewsFor(name).map((r) => r.rating).toList();

    updated[name] = [...current, rating];
    ratings.value = updated;
  }

  // Menambahkan Ulasan
  static void addReview(
    String name,
    String review, {
    String buyerName = 'Pembeli',
  }) {
    if (review.trim().isEmpty) return;

    final comment = review.trim();

    final updatedReviews = Map<String, List<String>>.from(reviews.value);
    final current = updatedReviews[name] ??
        sampleReviewsFor(name).map((r) => r.comment).toList();

    updatedReviews[name] = [...current, comment];
    reviews.value = updatedReviews;

    final updated = Map<String, List<ProductReview>>.from(
      reviewHistory.value,
    );

    final history = updated[name] ?? sampleReviewsFor(name);
    final ratingList = ratings.value[name] ??
        history.map((r) => r.rating).toList();

    final index = updatedReviews[name]!.length - 1;

    updated[name] = [
      ...history,
      ProductReview(
        buyerName: buyerName,
        rating: index < ratingList.length ? ratingList[index] : 5,
        comment: comment,
        date: DateTime.now(),
      ),
    ];

    reviewHistory.value = updated;
  }

  // Menandai Pesanan Sudah Dinilai
  static void markRated(String id, int index) =>
      _updateItem(id, index, {'rated': true});

  // Menandai Pesanan Sudah Diulas
  static void markReviewed(String id, int index) =>
      _updateItem(id, index, {
        'rated': true,
        'reviewed': true,
      });

  // Memperbarui Item Pesanan
  static void _updateItem(
    String id,
    int index,
    Map<String, dynamic> changes,
  ) {
    orders.value = orders.value.map((order) {
      if (order['id'] != id) return order;

      final items = (order['items'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      if (index < 0 || index >= items.length) return order;

      items[index] = {...items[index], ...changes};
      return {...order, 'items': items};
    }).toList();
  }

  // Memperbarui Data Pesanan
  static void _updateOrder(
    String id,
    Map<String, dynamic> changes,
  ) {
    final index = orders.value.indexWhere(
      (order) => order['id'].toString() == id,
    );

    if (index < 0) return;

    final updated = [...orders.value];
    updated[index] = {...updated[index], ...changes};
    orders.value = updated;
  }
}
