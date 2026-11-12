import 'package:flutter/material.dart';
import '../store/chat_store.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  const ChatDetailPage({super.key, required this.conversationId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    ChatStore.sendMessage(widget.conversationId, text);
    messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String timeLabel(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Widget productImage(ChatConversation chat) {
    const fallback = Icon(Icons.shopping_bag_outlined,
        color: Color(0xFF89AC46));

    if (chat.productImageBytes != null) {
      return Image.memory(chat.productImageBytes!,
        width: 48, height: 48, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback);
    }
    if (chat.productImageAsset != null &&
        chat.productImageAsset!.isNotEmpty) {
      return Image.asset(chat.productImageAsset!,
        width: 48, height: 48, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback);
    }
    if (chat.productImageUrl.isNotEmpty) {
      return Image.network(chat.productImageUrl,
        width: 48, height: 48, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback);
    }
    return fallback;
  }

  Widget messageBubble(ChatMessage message) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF89AC46) :
              const Color(0xFFE8EEDE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(timeLabel(message.sentAt),
              style: TextStyle(fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black45)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<ChatConversation>>(
    valueListenable: ChatStore.conversations,
    builder: (context, chats, _) {
      final chat = ChatStore.findById(widget.conversationId);

      if (chat == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pesan')),
          body: const Center(
            child: Text('Percakapan tidak ditemukan.')),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chat.sellerName,
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
              Text(chat.productName,
                style: const TextStyle(
                  fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
        body: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFFE8EEDE),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: productImage(chat)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chat.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800)),
                  Text(chat.productPrice,
                    style: const TextStyle(
                      color: Color(0xFF89AC46),
                      fontWeight: FontWeight.w700)),
                ],
              )),
            ]),
          ),
          Expanded(
            child: chat.messages.isEmpty
                ? const Center(
                    child: Text('Mulai percakapan dengan penjual.'))
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.messages.length,
                    itemBuilder: (_, i) =>
                        messageBubble(chat.messages[i]),
                  ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(
                color: Color(0xFFE5E5E5))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      filled: true,
                      fillColor: const Color(0xFFF3F5F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    ),
                  )),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send_rounded,
                      color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF89AC46)),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    },
  );
}
