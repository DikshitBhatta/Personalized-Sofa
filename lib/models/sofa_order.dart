import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/models/user_onboarding_data.dart';

enum OrderStatus { pending, processing, delivered, cancelled }

class SofaOrder {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  
  // Sofa details
  final String sofaName;
  final String? glbUrl;
  final String? thumbnailUrl;
  final PersonalizationData personalizationData;
  final UserOnboardingData? onboardingData;
  
  // Pricing
  final double totalPrice;
  final double basePrice;
  
  // Order details
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? deliveryAddress;
  final String? notes;
  
  // Admin notes
  final String? adminNotes;
  final String? rejectionReason;
  
  SofaOrder({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.sofaName,
    this.glbUrl,
    this.thumbnailUrl,
    required this.personalizationData,
    this.onboardingData,
    required this.totalPrice,
    required this.basePrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.deliveryAddress,
    this.notes,
    this.adminNotes,
    this.rejectionReason,
  });

  factory SofaOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SofaOrder(
      id: doc.id,
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      userEmail: data['user_email'] ?? '',
      sofaName: data['sofa_name'] ?? 'Custom Sofa',
      glbUrl: data['glb_url'],
      thumbnailUrl: data['thumbnail_url'],
      personalizationData: PersonalizationData.fromJson(
        data['personalization_data'] ?? {},
      ),
      onboardingData: data['onboarding_data'] != null
          ? UserOnboardingData.fromJson(data['onboarding_data'])
          : null,
      totalPrice: (data['total_price'] ?? 0).toDouble(),
      basePrice: (data['base_price'] ?? 0).toDouble(),
      status: _statusFromString(data['status'] ?? 'pending'),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
      deliveryAddress: data['delivery_address'],
      notes: data['notes'],
      adminNotes: data['admin_notes'],
      rejectionReason: data['rejection_reason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'sofa_name': sofaName,
      'glb_url': glbUrl,
      'thumbnail_url': thumbnailUrl,
      'personalization_data': personalizationData.toJson(),
      'onboarding_data': onboardingData?.toJson(),
      'total_price': totalPrice,
      'base_price': basePrice,
      'status': _statusToString(status),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'admin_notes': adminNotes,
      'rejection_reason': rejectionReason,
    };
  }

  static OrderStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'processing':
        return OrderStatus.processing;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  SofaOrder copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? sofaName,
    String? glbUrl,
    String? thumbnailUrl,
    PersonalizationData? personalizationData,
    UserOnboardingData? onboardingData,
    double? totalPrice,
    double? basePrice,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deliveryAddress,
    String? notes,
    String? adminNotes,
    String? rejectionReason,
  }) {
    return SofaOrder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      sofaName: sofaName ?? this.sofaName,
      glbUrl: glbUrl ?? this.glbUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      personalizationData: personalizationData ?? this.personalizationData,
      onboardingData: onboardingData ?? this.onboardingData,
      totalPrice: totalPrice ?? this.totalPrice,
      basePrice: basePrice ?? this.basePrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      adminNotes: adminNotes ?? this.adminNotes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
