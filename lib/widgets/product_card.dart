import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../favorite_store.dart';

class ProductCard extends StatefulWidget {
  final String name, price, condition, imageUrl;
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  const ProductCard({
    super.key, required this.name, required this.price,
    required this.condition, required this.imageUrl,
    this.imageBytes, required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  static const green = Color(0xFF245C4A);

  Widget noImage() => const ColoredBox(
    color: Color(0xFFE8EEEB),
    child: Center(child: Icon(Icons.image_not_supported_outlined, size: 40)),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoriteStore.favorites,
      builder: (context, favorites, _) {
        final favorite = favorites.contains(widget.name);

        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(18),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.imageBytes != null
                          ? Image.memory(widget.imageBytes!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => noImage())
                          : Image.network(widget.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => noImage()),
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(20)),
                          child: const Text('PRELOVED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      Positioned(
                        top: 6, right: 6,
                        child: Material(
                          color: Colors.white.withOpacity(.92),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: favorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
                            onPressed: () {
                              FavoriteStore.toggle(widget.name);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: const Duration(milliseconds: 900),
                                content: Text(favorite
                                    ? '${widget.name} dihapus dari favorit'
                                    : '${widget.name} ditambahkan ke favorit'),
                              ));
                            },
                            icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 19, color: favorite ? Colors.red : Colors.black87),
                            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.15)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.verified_outlined, size: 13, color: green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(widget.condition, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.black54)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(widget.price, style: const TextStyle(fontSize: 15, color: green, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}