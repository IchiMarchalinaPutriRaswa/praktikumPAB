import 'package:flutter/material.dart';
import '../store/chat_store.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  String timeLabel(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year && time.month == now.month &&
        time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
  }

  Widget productAvatar(ChatConversation chat) {
    Widget image = const Icon(Icons.shopping_bag_outlined,
        color: Color(0xFF89AC46));

    if (chat.productImageBytes != null) {
      image = Image.memory(chat.productImageBytes!,
          width: 52, height: 52, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else if (chat.productImageAsset != null &&
        chat.productImageAsset!.isNotEmpty) {
      image = Image.asset(chat.productImageAsset!,
          width: 52, height: 52, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    } else if (chat.productImageUrl.isNotEmpty) {
      image = Image.network(chat.productImageUrl,
          width: 52, height: 52, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image));
    }

    return CircleAvatar(
      radius: 26,
      backgroundColor: const Color(0xFFE8EEDE),
      child: ClipOval(child: SizedBox(
        width: 52, height: 52, child: image)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pesan',
        style: TextStyle(fontWeight: FontWeight.w800))),
    body: ValueListenableBuilder<List<ChatConversation>>(
      valueListenable: ChatStore.conversations,
      builder: (context, chats, _) {
        final sortedChats = [...chats]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        if (sortedChats.isEmpty) {
          return const Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64,
                  color: Color(0xFF89AC46)),
              SizedBox(height: 12),
              Text('Belum ada percakapan',
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 6),
              Text('Mulai chat melalui halaman Detail Produk.',
                  style: TextStyle(color: Colors.black54)),
            ],
          ));
        }

        return ListView.separated(
          itemCount: sortedChats.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 76),
          itemBuilder: (context, index) {
            final chat = sortedChats[index];
            final lastMessage = chat.messages.isEmpty
                ? 'Mulai percakapan'
                : '${chat.messages.last.isMe ? 'Anda: ' : ''}${chat.lastMessage}';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              leading: productAvatar(chat),
              title: Text(chat.sellerName,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chat.productName,
                      style: const TextStyle(
                          color: Color(0xFF89AC46),
                          fontWeight: FontWeight.w600)),
                  Text(lastMessage, maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
              trailing: Text(timeLabel(chat.updatedAt),
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  ChatDetailPage(conversationId: chat.id))),
            );
          },
        );
      },
    ),
  );
}
