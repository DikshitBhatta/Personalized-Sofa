import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// Service to track unread concierge messages for the current user
class UnreadMessageService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable unread count
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToUnreadMessages();
  }

  /// Listen to unread messages in real-time
  void _listenToUnreadMessages() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      unreadCount.value = 0;
      return;
    }

    // Listen to all chats where user is a participant
    _firestore
        .collection('concierge_chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      int totalUnread = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final lastSenderId = data['lastSenderId'] as String?;
        final unread = data['unreadCount'] as int? ?? 0;

        // Count unread messages only if the last sender was NOT this user
        if (lastSenderId != null && lastSenderId != userId && unread > 0) {
          totalUnread += unread;
        }
      }

      unreadCount.value = totalUnread;
      print('📬 Unread concierge messages: $totalUnread');
    }, onError: (error) {
      print('❌ Error listening to unread messages: $error');
      unreadCount.value = 0;
    });
  }

  /// Reset unread count when user opens the chat
  Future<void> markChatAsRead(String chatId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final chatRef = _firestore.collection('concierge_chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) return;

      final data = chatDoc.data()!;
      final lastSenderId = data['lastSenderId'] as String?;

      // Only reset if the last sender was NOT this user
      if (lastSenderId != null && lastSenderId != userId) {
        await chatRef.update({'unreadCount': 0});
      }
    } catch (e) {
      print('❌ Error marking chat as read: $e');
    }
  }

  /// Get unread count synchronously
  int get count => unreadCount.value;

  /// Check if there are unread messages
  bool get hasUnread => unreadCount.value > 0;
}
