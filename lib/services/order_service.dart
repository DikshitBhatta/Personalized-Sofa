import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/models/user_onboarding_data.dart';
import 'package:timberr/Notification/services/notification_service.dart';
import 'package:timberr/Notification/models/notification_model.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new order
  static Future<String?> createOrder({
    required String sofaName,
    String? glbUrl,
    String? thumbnailUrl,
    required PersonalizationData personalizationData,
    UserOnboardingData? onboardingData,
    required double totalPrice,
    required double basePrice,
    String? deliveryAddress,
    String? notes,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data();
      final userName = userData?['name'] ?? currentUser.displayName ?? 'Unknown User';

      final order = SofaOrder(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        userName: userName,
        userEmail: currentUser.email ?? '',
        sofaName: sofaName,
        glbUrl: glbUrl,
        thumbnailUrl: thumbnailUrl,
        personalizationData: personalizationData,
        onboardingData: onboardingData,
        totalPrice: totalPrice,
        basePrice: basePrice,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: deliveryAddress,
        notes: notes,
      );

      final docRef = await _firestore
          .collection('sofa_orders')
          .add(order.toFirestore());

      print('✅ Order created successfully with ID: ${docRef.id}');
      
      // Send notification to admins about new order
      print('🔔 Sending new order notification to admins...');
      try {
        final notificationService = NotificationService();
        await notificationService.sendToAdmins(
          title: 'New Sofa Order Received! 🛋️',
          body: '$userName ordered a $sofaName for \$${totalPrice.toStringAsFixed(2)}',
          type: NotificationType.orderUpdate,
          data: {
            'order_id': docRef.id,
            'customer_name': userName,
            'customer_email': currentUser.email ?? '',
            'sofa_name': sofaName,
            'total_price': totalPrice.toString(),
            'status': 'pending',
          },
        );
        print('✅ Admin notification sent for new order');
      } catch (notifError) {
        print('⚠️ Admin notification failed (order created anyway): $notifError');
        // Don't fail order creation if notification fails
      }
      
      return docRef.id;
    } catch (e) {
      print('❌ Error creating order: $e');
      return null;
    }
  }

  /// Get user's orders
  static Stream<List<SofaOrder>> getUserOrders({OrderStatus? status}) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    Query query = _firestore
        .collection('sofa_orders')
        .where('user_id', isEqualTo: currentUser.uid);

    if (status != null) {
      query = query.where('status', isEqualTo: _statusToString(status));
    }

    return query
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SofaOrder.fromFirestore(doc))
            .toList());
  }

  /// Get all orders (Admin)
  static Stream<List<SofaOrder>> getAllOrders({OrderStatus? status}) {
    Query query = _firestore.collection('sofa_orders');

    if (status != null) {
      query = query.where('status', isEqualTo: _statusToString(status));
    }

    return query
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SofaOrder.fromFirestore(doc))
            .toList());
  }

  /// Update order status
  static Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
    String? adminNotes,
    String? rejectionReason,
  }) async {
    try {
      print('📦 ========== UPDATING ORDER STATUS ==========');
      print('   Order ID: $orderId');
      print('   New Status: ${_statusToString(status)}');
      
      // Get order details first to send notification
      print('🔍 Step 1: Fetching order details...');
      final orderDoc = await _firestore
          .collection('sofa_orders')
          .doc(orderId)
          .get();
      
      if (!orderDoc.exists) {
        print('❌ Order not found: $orderId');
        return false;
      }
      
      final order = SofaOrder.fromFirestore(orderDoc);
      print('✅ Order found for user: ${order.userId}');
      print('   User Email: ${order.userEmail}');
      print('   Sofa: ${order.sofaName}');
      
      // Update order status in Firestore
      print('💾 Step 2: Updating order in Firestore...');
      final updateData = <String, dynamic>{
        'status': _statusToString(status),
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (adminNotes != null) {
        updateData['admin_notes'] = adminNotes;
      }

      if (rejectionReason != null) {
        updateData['rejection_reason'] = rejectionReason;
      }

      await _firestore
          .collection('sofa_orders')
          .doc(orderId)
          .update(updateData);

      print('✅ Order status updated in Firestore');
      
      // Send notification to user about order status change
      print('🔔 Step 3: Sending notification to user...');
      try {
        final notificationService = NotificationService();
        final statusMessage = _getStatusMessage(status, order.sofaName, rejectionReason);
        
        print('   📧 Sending to user: ${order.userId}');
        print('   📝 Message: $statusMessage');
        
        await notificationService.sendOrderUpdateNotification(
          userId: order.userId,
          orderId: orderId,
          status: _statusToString(status),
          message: statusMessage,
        );
        
        print('✅ Notification sent successfully');
      } catch (notifError) {
        print('⚠️  Notification sending failed (order updated anyway): $notifError');
        // Don't fail the entire operation if notification fails
      }
      
      print('✅ ========== ORDER STATUS UPDATE COMPLETE ==========');
      return true;
    } catch (e, stackTrace) {
      print('❌ ========== ERROR UPDATING ORDER STATUS ==========');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('====================================================');
      return false;
    }
  }
  
  /// Get user-friendly status message
  static String _getStatusMessage(OrderStatus status, String sofaName, String? rejectionReason) {
    switch (status) {
      case OrderStatus.pending:
        return 'Your order for $sofaName is now pending review.';
      case OrderStatus.processing:
        return 'Great news! Your order for $sofaName is now being processed. 🎉';
      case OrderStatus.delivered:
        return 'Your $sofaName has been delivered! We hope you love it. ❤️';
      case OrderStatus.cancelled:
        if (rejectionReason != null && rejectionReason.isNotEmpty) {
          return 'Your order for $sofaName has been cancelled. Reason: $rejectionReason';
        }
        return 'Your order for $sofaName has been cancelled.';
    }
  }

  /// Cancel order (User)
  static Future<bool> cancelOrder(String orderId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the order to verify ownership
      final orderDoc = await _firestore
          .collection('sofa_orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final order = SofaOrder.fromFirestore(orderDoc);

      // Only allow cancellation if it's the user's order and status is pending
      if (order.userId != currentUser.uid) {
        throw Exception('Unauthorized');
      }

      if (order.status != OrderStatus.pending) {
        throw Exception('Cannot cancel order that is already ${_statusToString(order.status)}');
      }

      await _firestore.collection('sofa_orders').doc(orderId).update({
        'status': 'cancelled',
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('✅ Order cancelled successfully');
      return true;
    } catch (e) {
      print('❌ Error cancelling order: $e');
      return false;
    }
  }

  /// Get single order by ID
  static Future<SofaOrder?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore
          .collection('sofa_orders')
          .doc(orderId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return SofaOrder.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting order: $e');
      return null;
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
}
