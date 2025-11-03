import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMember {
  final String userId;
  final String chatId;
  final DateTime? lastReadAt;
  final bool isTyping;
  final DateTime? lastSeenAt;

  ChatMember({
    required this.userId,
    required this.chatId,
    this.lastReadAt,
    this.isTyping = false,
    this.lastSeenAt,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userId: json['userId'] ?? '',
      chatId: json['chatId'] ?? '',
      lastReadAt: json['lastReadAt'] != null 
          ? (json['lastReadAt'] as Timestamp).toDate() 
          : null,
      isTyping: json['isTyping'] ?? false,
      lastSeenAt: json['lastSeenAt'] != null 
          ? (json['lastSeenAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'chatId': chatId,
      if (lastReadAt != null) 'lastReadAt': Timestamp.fromDate(lastReadAt!),
      'isTyping': isTyping,
      if (lastSeenAt != null) 'lastSeenAt': Timestamp.fromDate(lastSeenAt!),
    };
  }

  ChatMember copyWith({
    String? userId,
    String? chatId,
    DateTime? lastReadAt,
    bool? isTyping,
    DateTime? lastSeenAt,
  }) {
    return ChatMember(
      userId: userId ?? this.userId,
      chatId: chatId ?? this.chatId,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      isTyping: isTyping ?? this.isTyping,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}
