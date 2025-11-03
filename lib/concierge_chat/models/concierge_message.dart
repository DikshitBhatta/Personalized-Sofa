import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageSender { user, admin }

class ConciergeMessage {
  final String id;
  final String chatId;
  final String senderId;
  final MessageSender sender;
  final String text;
  final DateTime createdAt;
  final List<String> readBy;
  final String? imageUrl;

  ConciergeMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.readBy = const [],
    this.imageUrl,
  });

  factory ConciergeMessage.fromJson(Map<String, dynamic> json) {
    return ConciergeMessage(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      sender: json['sender'] == 'admin' ? MessageSender.admin : MessageSender.user,
      text: json['text'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      readBy: List<String>.from(json['readBy'] ?? []),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'sender': sender == MessageSender.admin ? 'admin' : 'user',
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'readBy': readBy,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  ConciergeMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    MessageSender? sender,
    String? text,
    DateTime? createdAt,
    List<String>? readBy,
    String? imageUrl,
  }) {
    return ConciergeMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      readBy: readBy ?? this.readBy,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
