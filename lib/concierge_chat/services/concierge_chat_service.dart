import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/concierge_chat.dart';
import '../models/concierge_message.dart';
import '../models/chat_member.dart';
import '../../Notification/services/notification_service.dart';
import '../../Notification/models/notification_model.dart';

class ConciergeChatService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get or create chat ID for user-admin communication
  String getChatId(String userId, String adminId) {
    final List<String> ids = [userId, adminId]..sort();
    return ids.join('_');
  }

  // Initialize or get existing concierge chat
  Future<String> initializeConciergeChat() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Get first available admin (you can implement admin selection logic)
    final adminId = await _getAvailableAdminId();
    final chatId = getChatId(userId, adminId);

    final chatRef = _firestore.collection('concierge_chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      // Create new chat
      final chat = ConciergeChat(
        chatId: chatId,
        participants: [userId, adminId],
        lastMessage: 'User initiated concierge support',
        updatedAt: DateTime.now(),
        lastSenderId: userId,
        unreadCount: 1,
      );

      await chatRef.set(chat.toJson());

      // Initialize members
      await _initializeChatMembers(chatId, userId, adminId);

      // Send initial message
      await sendMessage(
        chatId: chatId,
        text: 'Hello! I need help with my sofa selection.',
        sender: MessageSender.user,
      );

      // Send notification to admin
      await _notifyAdmin(adminId, userId, 'New concierge support request');
    }

    return chatId;
  }

  // Initialize chat members for tracking read status
  Future<void> _initializeChatMembers(String chatId, String userId, String adminId) async {
    final batch = _firestore.batch();

    final userMemberRef = _firestore
        .collection('concierge_chats')
        .doc(chatId)
        .collection('members')
        .doc(userId);

    final adminMemberRef = _firestore
        .collection('concierge_chats')
        .doc(chatId)
        .collection('members')
        .doc(adminId);

    batch.set(userMemberRef, ChatMember(
      userId: userId,
      chatId: chatId,
      lastReadAt: DateTime.now(),
    ).toJson());

    batch.set(adminMemberRef, ChatMember(
      userId: adminId,
      chatId: chatId,
      lastReadAt: null,
    ).toJson());

    await batch.commit();
  }

  // Get first available admin ID
  Future<String> _getAvailableAdminId() async {
    try {
      // Find admin in user_roles collection
      final adminSnapshot = await _firestore
          .collection('user_roles')
          .where('role_name', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        print('✅ Found admin: ${adminSnapshot.docs.first.id}');
        return adminSnapshot.docs.first.id;
      }

      // No admin found
      print('⚠️ No admin found in user_roles collection');
      throw Exception('No concierge available at the moment. Please contact support.');
    } catch (e) {
      print('❌ Error finding admin: $e');
      if (e.toString().contains('No concierge available')) {
        rethrow;
      }
      throw Exception('Unable to connect to concierge service. Please try again later.');
    }
  }

  // Send message with batched write
  Future<void> sendMessage({
    required String chatId,
    required String text,
    required MessageSender sender,
    String? imageUrl,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final messageRef = _firestore
        .collection('concierge_chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = ConciergeMessage(
      id: messageRef.id,
      chatId: chatId,
      senderId: userId,
      sender: sender,
      text: text,
      createdAt: DateTime.now(),
      readBy: [userId], // Sender has read it
      imageUrl: imageUrl,
    );

    // Write message
    batch.set(messageRef, message.toJson());

    // Update chat metadata
    final chatRef = _firestore.collection('concierge_chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': text.length > 50 ? '${text.substring(0, 50)}...' : text,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'lastSenderId': userId,
      'unreadCount': FieldValue.increment(1),
    });

    await batch.commit();

    // Send FCM notification to other participant
    await _sendMessageNotification(chatId, userId, sender, text);
  }

  // Stream messages for a chat
  Stream<List<ConciergeMessage>> streamMessages(String chatId) {
    return _firestore
        .collection('concierge_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConciergeMessage.fromJson(doc.data()))
            .toList());
  }

  // Stream chat metadata
  Stream<ConciergeChat?> streamChat(String chatId) {
    return _firestore
        .collection('concierge_chats')
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.exists ? ConciergeChat.fromJson(doc.data()!) : null);
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();

    // Update member's lastReadAt
    final memberRef = _firestore
        .collection('concierge_chats')
        .doc(chatId)
        .collection('members')
        .doc(userId);

    batch.update(memberRef, {
      'lastReadAt': Timestamp.fromDate(DateTime.now()),
    });

    // Reset unread count in chat
    final chatRef = _firestore.collection('concierge_chats').doc(chatId);
    batch.update(chatRef, {'unreadCount': 0});

    await batch.commit();
  }

  // Update typing status
  Future<void> updateTypingStatus(String chatId, bool isTyping) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('concierge_chats')
        .doc(chatId)
        .collection('members')
        .doc(userId)
        .update({'isTyping': isTyping});
  }

  // Stream typing status of other participant
  Stream<bool> streamOtherParticipantTyping(String chatId) async* {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final chatDoc = await _firestore.collection('concierge_chats').doc(chatId).get();
    if (!chatDoc.exists) return;

    final participants = List<String>.from(chatDoc.data()!['participants']);
    final otherUserId = participants.firstWhere((id) => id != userId, orElse: () => '');

    if (otherUserId.isEmpty) return;

    yield* _firestore
        .collection('concierge_chats')
        .doc(chatId)
        .collection('members')
        .doc(otherUserId)
        .snapshots()
        .map((doc) => doc.exists ? (doc.data()?['isTyping'] ?? false) : false);
  }

  // Check if admin replied within 1 minute
  Future<bool> checkAdminReplyWithinTimeout(String chatId, {Duration timeout = const Duration(minutes: 1)}) async {
    final startTime = DateTime.now();
    
    await for (final messages in streamMessages(chatId)) {
      final adminMessages = messages.where((msg) => msg.sender == MessageSender.admin);
      
      if (adminMessages.isNotEmpty) {
        // Admin replied
        return true;
      }

      if (DateTime.now().difference(startTime) > timeout) {
        // Timeout reached
        return false;
      }
    }

    return false;
  }

  // Send notification to admin
  Future<void> _notifyAdmin(String adminId, String userId, String message) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.data()?['name'] ?? 'User';

      await _firestore.collection('notifications').add({
        'recipient_id': adminId,
        'type': 'concierge_request',
        'title': 'New Concierge Support Request',
        'message': '$userName needs help',
        'data': {
          'chatId': getChatId(userId, adminId),
          'userId': userId,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Send FCM notification
      try {
        if (Get.isRegistered<NotificationService>()) {
          final notificationService = Get.find<NotificationService>();
          await notificationService.sendNotification(
            targetUserId: adminId,
            title: 'New Support Request',
            body: '$userName needs concierge assistance',
            type: NotificationType.general,
            data: {'type': 'concierge_request', 'chatId': getChatId(userId, adminId)},
          );
        } else {
          print('⚠️ NotificationService not available - skipping FCM notification');
        }
      } catch (notifError) {
        print('Error sending FCM notification: $notifError');
      }
    } catch (e) {
      print('Error notifying admin: $e');
    }
  }

  // Send message notification to other participant
  Future<void> _sendMessageNotification(String chatId, String senderId, MessageSender sender, String text) async {
    try {
      final chatDoc = await _firestore.collection('concierge_chats').doc(chatId).get();
      if (!chatDoc.exists) return;

      final participants = List<String>.from(chatDoc.data()!['participants']);
      final recipientId = participants.firstWhere((id) => id != senderId, orElse: () => '');

      if (recipientId.isEmpty) return;

      final senderDoc = await _firestore.collection('users').doc(senderId).get();
      final senderName = senderDoc.data()?['name'] ?? (sender == MessageSender.admin ? 'Concierge' : 'User');

      await _firestore.collection('notifications').add({
        'recipient_id': recipientId,
        'type': 'concierge_message',
        'title': sender == MessageSender.admin ? 'Concierge Reply' : 'New Message',
        'message': '$senderName: ${text.length > 50 ? '${text.substring(0, 50)}...' : text}',
        'data': {
          'chatId': chatId,
          'senderId': senderId,
        },
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Send FCM
      try {
        if (Get.isRegistered<NotificationService>()) {
          final notificationService = Get.find<NotificationService>();
          await notificationService.sendNotification(
            targetUserId: recipientId,
            title: sender == MessageSender.admin ? 'Concierge Reply' : 'New Message',
            body: text.length > 100 ? '${text.substring(0, 100)}...' : text,
            type: NotificationType.general,
            data: {'type': 'concierge_message', 'chatId': chatId},
          );
        } else {
          print('⚠️ NotificationService not available - skipping FCM notification');
        }
      } catch (notifError) {
        print('Error sending FCM notification: $notifError');
      }
    } catch (e) {
      print('Error sending message notification: $e');
    }
  }

  // Get all concierge chats for admin
  Stream<List<ConciergeChat>> streamAllConciergeChats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('concierge_chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConciergeChat.fromJson(doc.data()))
            .toList());
  }

  // Get user info for chat
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }
}
