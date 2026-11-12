import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime sentAt;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.sentAt,
  });
}

class ChatConversation {
  final String id, productName, productPrice, sellerName;
  final String productImageUrl;
  final String? productImageAsset;
  final Uint8List? productImageBytes;
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id, required this.productName,
    required this.productPrice, required this.sellerName,
    required this.productImageUrl, this.productImageAsset,
    this.productImageBytes, this.messages = const [],
    required this.updatedAt,
  });

  String get lastMessage =>
      messages.isEmpty ? 'Mulai percakapan' : messages.last.text;

  ChatConversation copyWith({
    List<ChatMessage>? messages, DateTime? updatedAt,
  }) => ChatConversation(
    id: id, productName: productName, productPrice: productPrice,
    sellerName: sellerName, productImageUrl: productImageUrl,
    productImageAsset: productImageAsset,
    productImageBytes: productImageBytes,
    messages: messages ?? this.messages,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

class ChatStore {
  static final ValueNotifier<List<ChatConversation>> conversations =
      ValueNotifier([]);

  static ChatConversation openOrCreate({
    required String productName,
    required String productPrice,
    required String sellerName,
    required String productImageUrl,
    String? productImageAsset,
    Uint8List? productImageBytes,
  }) {
    for (final chat in conversations.value) {
      if (chat.productName == productName &&
          chat.productPrice == productPrice) return chat;
    }

    final now = DateTime.now();
    final chat = ChatConversation(
      id: now.microsecondsSinceEpoch.toString(),
      productName: productName,
      productPrice: productPrice,
      sellerName: sellerName,
      productImageUrl: productImageUrl,
      productImageAsset: productImageAsset,
      productImageBytes: productImageBytes,
      messages: [
        ChatMessage(
          text: 'Halo! Terima kasih sudah tertarik dengan produk $productName. Ada yang ingin ditanyakan mengenai produk ini?',
          isMe: false,
          sentAt: now,
        ),
      ],
      updatedAt: now,
    );

    conversations.value = [chat, ...conversations.value];
    return chat;
  }

  static ChatConversation? findById(String id) {
    for (final chat in conversations.value) {
      if (chat.id == id) return chat;
    }
    return null;
  }

  static void sendMessage(String id, String text) {
    final message = text.trim();
    if (message.isEmpty) return;

    final index = conversations.value.indexWhere((c) => c.id == id);
    if (index < 0) return;

    final updated = [...conversations.value];
    final chat = updated[index];
    final now = DateTime.now();

    updated[index] = chat.copyWith(
      messages: [...chat.messages, ChatMessage(
        text: message, isMe: true, sentAt: now,
      )],
      updatedAt: now,
    );

    updated.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    conversations.value = updated;
  }
}
