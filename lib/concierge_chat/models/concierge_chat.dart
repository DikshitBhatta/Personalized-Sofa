import 'package:cloud_firestore/cloud_firestore.dart';

class ConciergeChat {
  final String chatId;
  final List<String> participants; // [userId, adminId]
  final String lastMessage;
  final DateTime updatedAt;
  final String lastSenderId;
  final int unreadCount; // For admin to see unread user messages

  ConciergeChat({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.updatedAt,
    required this.lastSenderId,
    this.unreadCount = 0,
  });

  factory ConciergeChat.fromJson(Map<String, dynamic> json) {
    return ConciergeChat(
      chatId: json['chatId'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      lastSenderId: json['lastSenderId'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
    };
  }

  ConciergeChat copyWith({
    String? chatId,
    List<String>? participants,
    String? lastMessage,
    DateTime? updatedAt,
    String? lastSenderId,
    int? unreadCount,
  }) {
    return ConciergeChat(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
