import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  conciergeBooking,
  conciergeConfirmation,
  conciergeRejection,
  orderUpdate,
  general,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data = const {},
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String id) {
    return NotificationModel(
      id: id,
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _typeFromString(json['type'] ?? 'general'),
      isRead: json['is_read'] ?? false,
      createdAt: (json['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'is_read': isRead,
      'created_at': Timestamp.fromDate(createdAt),
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  static NotificationType _typeFromString(String type) {
    switch (type) {
      case 'conciergeBooking':
        return NotificationType.conciergeBooking;
      case 'conciergeConfirmation':
        return NotificationType.conciergeConfirmation;
      case 'conciergeRejection':
        return NotificationType.conciergeRejection;
      case 'orderUpdate':
        return NotificationType.orderUpdate;
      default:
        return NotificationType.general;
    }
  }
}

class FCMTokenModel {
  final String userId;
  final String token;
  final DateTime updatedAt;
  final String platform;

  FCMTokenModel({
    required this.userId,
    required this.token,
    required this.updatedAt,
    required this.platform,
  });

  factory FCMTokenModel.fromJson(Map<String, dynamic> json) {
    return FCMTokenModel(
      userId: json['user_id'] ?? '',
      token: json['token'] ?? '',
      updatedAt: (json['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      platform: json['platform'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'token': token,
      'updated_at': Timestamp.fromDate(updatedAt),
      'platform': platform,
    };
  }
}