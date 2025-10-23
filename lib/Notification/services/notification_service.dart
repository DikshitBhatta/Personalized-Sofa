import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timberr/Notification/services/fcm_v1_service.dart';
import 'package:timberr/Notification/models/notification_model.dart';
import 'package:timberr/role/role_service.dart';

/// Notification Service - Backward compatibility wrapper
/// Delegates all calls to FCMv1Service for actual implementation
class NotificationService {
  final FCMv1Service _fcmService = FCMv1Service();
  
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize notification system
  Future<void> initialize() async {
    await _fcmService.initialize();
  }

  /// Check notification permission status (fast, non-blocking)
  /// Returns true if permission is granted, false otherwise
  /// This is a lightweight check suitable for Phase 0 initialization
  Future<bool> checkPermissionStatus() async {
    try {
      final settings = await _fcmService.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      print('⚠️ Failed to check notification permission: $e');
      return false;
    }
  }

  /// Send notification to specific user
  Future<bool> sendNotification({
    required String targetUserId,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    return await _fcmService.sendNotification(
      targetUserId: targetUserId,
      title: title,
      body: body,
      type: type,
      data: data,
    );
  }

  /// Send notification to all admin users
  Future<void> sendToAdmins({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('🔔 ========== STARTING ADMIN NOTIFICATION PROCESS ==========');
      print('📋 Notification Details:');
      print('   Title: $title');
      print('   Body: $body');
      print('   Type: ${type.name}');
      print('   Data: $data');
      
      // Get all admin user IDs
      print('🔍 Step 1: Fetching admin users from RoleService...');
      final adminUsers = await RoleService.getAllAdminUsers();
      
      print('📊 Step 2: Admin users found: ${adminUsers.length}');
      if (adminUsers.isEmpty) {
        print('⚠️ WARNING: No admin users found in the system!');
        print('💡 Please check:');
        print('   1. user_roles collection has documents with role_name="admin"');
        print('   2. users collection has documents with role="admin"');
        return;
      }
      
      print('👥 Admin user IDs: $adminUsers');
      
      // Send notification to each admin
      int successCount = 0;
      int failureCount = 0;
      
      for (int i = 0; i < adminUsers.length; i++) {
        final adminId = adminUsers[i];
        print('📤 Step 3.${i + 1}: Sending notification to admin: $adminId');
        
        final success = await sendNotification(
          targetUserId: adminId,
          title: title,
          body: body,
          type: type,
          data: data,
        );
        
        if (success) {
          successCount++;
          print('   ✅ Successfully sent to admin $adminId');
        } else {
          failureCount++;
          print('   ❌ Failed to send to admin $adminId');
        }
      }
      
      print('📊 Step 4: Notification Summary:');
      print('   Total admins: ${adminUsers.length}');
      print('   Successful: $successCount');
      print('   Failed: $failureCount');
      print('✅ ========== ADMIN NOTIFICATION PROCESS COMPLETE ==========');
      
    } catch (e, stackTrace) {
      print('❌ ========== ERROR SENDING ADMIN NOTIFICATIONS ==========');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('============================================================');
    }
  }

  /// Send notification to multiple users
  Future<void> sendToMultipleUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    for (final userId in userIds) {
      await sendNotification(
        targetUserId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
      );
    }
  }

  /// Send concierge booking notification to admins
  Future<void> sendConciergeBookingNotification({
    required String clientName,
    required String conciergeName,
    required String visitDate,
    required String visitTime,
    required double amount,
    required String clientId,
  }) async {
    print('🏠 ========== CONCIERGE BOOKING NOTIFICATION ==========');
    print('📋 Booking Details:');
    print('   Client: $clientName (ID: $clientId)');
    print('   Concierge: $conciergeName');
    print('   Visit: $visitDate at $visitTime');
    print('   Amount: \$$amount');
    
    await sendToAdmins(
      title: 'New Concierge Booking Request',
      body: '$clientName has booked $conciergeName for $visitDate at $visitTime',
      type: NotificationType.conciergeBooking,
      data: {
        'client_id': clientId,
        'client_name': clientName,
        'concierge_name': conciergeName,
        'visit_date': visitDate,
        'visit_time': visitTime,
        'amount': amount.toString(),
      },
    );
    
    print('✅ Concierge booking notification process completed');
    print('=====================================================');
  }

  /// Send concierge confirmation notification to user
  Future<void> sendConciergeConfirmationNotification({
    required String userId,
    required String conciergeName,
    required String visitDate,
    required String visitTime,
  }) async {
    await sendNotification(
      targetUserId: userId,
      title: 'Concierge Visit Confirmed! 🎉',
      body: 'Your visit with $conciergeName on $visitDate at $visitTime has been confirmed',
      type: NotificationType.conciergeConfirmation,
      data: {
        'concierge_name': conciergeName,
        'visit_date': visitDate,
        'visit_time': visitTime,
      },
    );
  }

  /// Send concierge rejection notification to user
  Future<void> sendConciergeRejectionNotification({
    required String userId,
    required String conciergeName,
    required String visitDate,
    required String visitTime,
    required String reason,
  }) async {
    await sendNotification(
      targetUserId: userId,
      title: 'Concierge Visit Update Required',
      body: 'Your visit with $conciergeName on $visitDate needs to be rescheduled. Please contact support.',
      type: NotificationType.conciergeRejection,
      data: {
        'concierge_name': conciergeName,
        'visit_date': visitDate,
        'visit_time': visitTime,
        'reason': reason,
      },
    );
  }

  /// Send order update notification
  Future<void> sendOrderUpdateNotification({
    required String userId,
    required String orderId,
    required String status,
    required String message,
  }) async {
    await sendNotification(
      targetUserId: userId,
      title: 'Order Update',
      body: message,
      type: NotificationType.orderUpdate,
      data: {
        'order_id': orderId,
        'status': status,
      },
    );
  }
}