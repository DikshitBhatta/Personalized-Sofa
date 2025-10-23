import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/models/user_onboarding_data.dart';

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

      print('✅ Order status updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
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
