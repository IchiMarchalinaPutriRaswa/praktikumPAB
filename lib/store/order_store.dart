import 'package:flutter/foundation.dart';

class OrderStore {
  static final orders =
      ValueNotifier<List<Map<String, dynamic>>>([]);
  static final ratings =
      ValueNotifier<Map<String, List<int>>>({});
  static final reviews =
      ValueNotifier<Map<String, List<String>>>({});

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
    final isCod = payment == 'COD';

    final saved = items.map((item) => {
      ...item,
      'rated': false,
      'reviewed': false,
    }).toList();

    orders.value = [
      {
        'id': id,
        'date': now,
        'items': saved,
        'buyerName': buyerName,
        'address': address,
        'payment': payment,
        'totalPrice': totalPrice,
        'paymentStatus': isCod
            ? 'Menunggu konfirmasi COD'
            : 'Menunggu pembayaran',
        'orderStatus': isCod
            ? 'Menunggu konfirmasi COD'
            : 'Menunggu pembayaran',
        'status': isCod
            ? 'Menunggu konfirmasi COD'
            : 'Menunggu pembayaran',
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

  static Map<String, dynamic>? findById(String id) {
    for (final order in orders.value) {
      if (order['id'].toString() == id) return order;
    }
    return null;
  }

  static void updatePaymentStatus(
    String id, String paymentStatus, {
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

  static void updateOrderStatus(String id, String status) {
    _updateOrder(id, {
      'orderStatus': status,
      'status': status,
    });
  }

  static void updateTracking(
    String id, {
    required String courier,
    required String trackingNumber,
    required List<Map<String, dynamic>> history,
  }) {
    _updateOrder(id, {
      'courier': courier,
      'trackingNumber': trackingNumber,
      'trackingHistory': history,
    });
  }

  static void updateReturn(
    String id, {
    required String status,
    String reason = '',
  }) {
    _updateOrder(id, {
      'returnStatus': status,
      'returnReason': reason,
      'returnDate': DateTime.now(),
    });
  }

  static void addRating(String name, int rating) {
    if (rating < 1 || rating > 5) return;

    final updated = Map<String, List<int>>.from(ratings.value);
    updated[name] = [...(updated[name] ?? []), rating];
    ratings.value = updated;
  }

  static void addReview(String name, String review) {
    if (review.trim().isEmpty) return;

    final updated = Map<String, List<String>>.from(reviews.value);
    updated[name] = [...(updated[name] ?? []), review.trim()];
    reviews.value = updated;
  }

  static void markRated(String id, int index) =>
      _updateItem(id, index, {'rated': true});

  static void markReviewed(String id, int index) =>
      _updateItem(id, index, {
        'rated': true,
        'reviewed': true,
      });

  static void _updateItem(
    String id, int index, Map<String, dynamic> changes,
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

  static void _updateOrder(
    String id, Map<String, dynamic> changes,
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
