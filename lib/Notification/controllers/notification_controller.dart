import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/Notification/models/notification_model.dart';
import 'package:timberr/Notification/services/notification_service.dart';
import 'package:timberr/role/role_service.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    _setupNotificationListener();
  }

  /// Load notifications from Firestore
  Future<void> loadNotifications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      _isLoading = true;
      update();
      
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();
      
      _notifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
          .toList();
      
      _isLoading = false;
      update();
      
    } catch (e) {
      print('❌ Error loading notifications: $e');
      _isLoading = false;
      update();
    }
  }

  /// Set up real-time notification listener
  void _setupNotificationListener() {
    final user = _auth.currentUser;
    if (user == null) return;
    
    _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
          .toList();
      update();
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});
      
      // Update local list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        update();
      }
      
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final batch = _firestore.batch();
      final unreadNotifications = _notifications.where((n) => !n.isRead);
      
      for (final notification in unreadNotifications) {
        final docRef = _firestore.collection('notifications').doc(notification.id);
        batch.update(docRef, {'is_read': true});
      }
      
      await batch.commit();
      
      // Update local list
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      update();
      
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      // Remove from local list
      _notifications.removeWhere((n) => n.id == notificationId);
      update();
      
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  /// Send concierge booking notification to admin
  Future<void> sendConciergeBookingNotification({
    required String clientName,
    required String conciergeName,
    required String visitDate,
    required String visitTime,
    required double amount,
    required String clientId,
  }) async {
    await _notificationService.sendConciergeBookingNotification(
      clientName: clientName,
      conciergeName: conciergeName,
      visitDate: visitDate,
      visitTime: visitTime,
      amount: amount,
      clientId: clientId,
    );
  }

  /// Send concierge confirmation notification to user
  Future<void> sendConciergeConfirmationNotification({
    required String userId,
    required String conciergeName,
    required String visitDate,
    required String visitTime,
  }) async {
    await _notificationService.sendConciergeConfirmationNotification(
      userId: userId,
      conciergeName: conciergeName,
      visitDate: visitDate,
      visitTime: visitTime,
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
    await _notificationService.sendConciergeRejectionNotification(
      userId: userId,
      conciergeName: conciergeName,
      visitDate: visitDate,
      visitTime: visitTime,
      reason: reason,
    );
  }

  /// Send order update notification
  Future<void> sendOrderUpdateNotification({
    required String userId,
    required String orderId,
    required String status,
    required String message,
  }) async {
    await _notificationService.sendOrderUpdateNotification(
      userId: userId,
      orderId: orderId,
      status: status,
      message: message,
    );
  }
  
  /// Debug method to test admin user fetching
  Future<void> debugAdminUsers() async {
    try {
      final adminUsers = await RoleService.getAllAdminUsers();
      print('🔍 Debug - Found admin users: $adminUsers');
      
      if (adminUsers.isEmpty) {
        print('⚠️ No admin users found! Make sure you have admin users in your database.');
        print('💡 Tip: Check user_roles collection or users collection for role=admin');
      }
      
    } catch (e) {
      print('❌ Debug admin users error: $e');
    }
  }
}