import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../concierge_chat/models/concierge_message.dart';
import '../../concierge_chat/models/concierge_chat.dart';
import '../../concierge_chat/services/concierge_chat_service.dart';

class AdminConciergeSupportController extends GetxController {
  final ConciergeChatService _chatService = Get.find<ConciergeChatService>();
  
  final RxList<ConciergeChat> allChats = <ConciergeChat>[].obs;
  final RxList<ConciergeMessage> messages = <ConciergeMessage>[].obs;
  final Rx<ConciergeChat?> selectedChat = Rx<ConciergeChat?>(null);
  final RxString selectedChatId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTyping = false.obs;
  final RxBool isUserTyping = false.obs;
  final RxMap<String, Map<String, dynamic>> userInfoCache = <String, Map<String, dynamic>>{}.obs;
  
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _loadAllChats();
  }

  Future<void> _loadAllChats() async {
    try {
      isLoading.value = true;
      
      // Listen to all concierge chats
      _chatService.streamAllConciergeChats().listen((chatList) {
        allChats.value = chatList;
        
        // Load user info for each chat
        for (final chat in chatList) {
          _loadUserInfoForChat(chat);
        }
      });
      
      isLoading.value = false;
    } catch (e) {
      print('Error loading chats: $e');
      isLoading.value = false;
    }
  }

  Future<void> _loadUserInfoForChat(ConciergeChat chat) async {
    // Get the user ID (not admin)
    final userId = chat.participants.firstWhere(
      (id) => id != _chatService.currentUserId,
      orElse: () => '',
    );
    
    if (userId.isNotEmpty && !userInfoCache.containsKey(userId)) {
      final userInfo = await _chatService.getUserInfo(userId);
      if (userInfo != null) {
        userInfoCache[userId] = userInfo;
      }
    }
  }

  void selectChat(ConciergeChat chat) {
    selectedChat.value = chat;
    selectedChatId.value = chat.chatId;
    
    // Listen to messages
    _chatService.streamMessages(chat.chatId).listen((messageList) {
      messages.value = messageList;
      _scrollToBottom();
    });
    
    // Listen to chat updates
    _chatService.streamChat(chat.chatId).listen((chatData) {
      if (chatData != null) {
        selectedChat.value = chatData;
      }
    });
    
    // Listen to user typing status
    _chatService.streamOtherParticipantTyping(chat.chatId).listen((typing) {
      isUserTyping.value = typing;
    });
    
    // Mark messages as read
    _chatService.markMessagesAsRead(chat.chatId);
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || selectedChatId.value.isEmpty) return;

    try {
      messageController.clear();
      
      await _chatService.sendMessage(
        chatId: selectedChatId.value,
        text: text,
        sender: MessageSender.admin,
      );
      
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void onTypingChanged(String text) {
    final shouldShowTyping = text.trim().isNotEmpty;
    if (shouldShowTyping != isTyping.value) {
      isTyping.value = shouldShowTyping;
      if (selectedChatId.value.isNotEmpty) {
        _chatService.updateTypingStatus(selectedChatId.value, shouldShowTyping);
      }
    }
  }

  String getUserName(ConciergeChat chat) {
    final userId = chat.participants.firstWhere(
      (id) => id != _chatService.currentUserId,
      orElse: () => '',
    );
    
    if (userId.isEmpty) return 'Unknown User';
    
    final userInfo = userInfoCache[userId];
    return userInfo?['name'] ?? userInfo?['email'] ?? 'User';
  }

  String getUserEmail(ConciergeChat chat) {
    final userId = chat.participants.firstWhere(
      (id) => id != _chatService.currentUserId,
      orElse: () => '',
    );
    
    if (userId.isEmpty) return '';
    
    final userInfo = userInfoCache[userId];
    return userInfo?['email'] ?? '';
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    if (selectedChatId.value.isNotEmpty) {
      _chatService.updateTypingStatus(selectedChatId.value, false);
    }
    super.onClose();
  }
}
