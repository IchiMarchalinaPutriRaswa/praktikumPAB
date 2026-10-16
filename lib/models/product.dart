class PreloProduct {
  PreloProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.condition,
    required this.imageUrl,
    this.imageAsset,
    this.description = '',
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String category;
  /// Harga yang sudah diformat, misalnya "Rp 45.000".
  final String price;
  final String condition;
  /// URL foto produk dari internet. Kosong jika produk memakai asset lokal.
  final String imageUrl;
  /// Path gambar lokal, terutama untuk listing yang dibuat lewat formulir jual.
  final String? imageAsset;
  final String description;
  bool isFavorite;
}
