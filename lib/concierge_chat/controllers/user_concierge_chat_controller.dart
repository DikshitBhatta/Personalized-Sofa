import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/concierge_message.dart';
import '../models/concierge_chat.dart';
import '../services/concierge_chat_service.dart';
import '../services/unread_message_service.dart';

class UserConciergeChatController extends GetxController {
  final ConciergeChatService _chatService = Get.find<ConciergeChatService>();
  late final UnreadMessageService _unreadService;
  
  UserConciergeChatController() {
    // Safely get or initialize UnreadMessageService
    try {
      _unreadService = Get.find<UnreadMessageService>();
    } catch (e) {
      print('⚠️ UnreadMessageService not found in UserConciergeChatController, initializing...');
      _unreadService = Get.put(UnreadMessageService(), permanent: true);
    }
  }
  
  final RxList<ConciergeMessage> messages = <ConciergeMessage>[].obs;
  final Rx<ConciergeChat?> chat = Rx<ConciergeChat?>(null);
  final RxString chatId = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTyping = false.obs;
  final RxBool isAdminTyping = false.obs;
  final RxBool isWaitingForAdmin = false.obs;
  final RxBool adminReplied = false.obs;
  
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      isLoading.value = true;
      isWaitingForAdmin.value = true;
      
      // Initialize or get existing chat
      chatId.value = await _chatService.initializeConciergeChat();
      
      // Mark chat as read when user opens it
      await _unreadService.markChatAsRead(chatId.value);
      
      // Start timeout check for admin reply
      _checkAdminReplyTimeout();
      
      // Listen to messages
      _chatService.streamMessages(chatId.value).listen((messageList) {
        messages.value = messageList;
        
        // Check if admin has replied
        final hasAdminMessage = messageList.any((msg) => msg.sender == MessageSender.admin);
        if (hasAdminMessage && !adminReplied.value) {
          adminReplied.value = true;
          isWaitingForAdmin.value = false;
          // Mark as read again when new admin message arrives
          _unreadService.markChatAsRead(chatId.value);
        }
        
        _scrollToBottom();
      });
      
      // Listen to chat metadata
      _chatService.streamChat(chatId.value).listen((chatData) {
        chat.value = chatData;
      });
      
      // Listen to admin typing status
      _chatService.streamOtherParticipantTyping(chatId.value).listen((typing) {
        isAdminTyping.value = typing;
      });
      
      isLoading.value = false;
    } catch (e) {
      print('Error initializing chat: $e');
      isLoading.value = false;
      
      // Show more specific error message
      String errorMessage = 'Failed to connect to concierge support';
      if (e.toString().contains('No admin available')) {
        errorMessage = 'No concierge available at the moment. Please try again later.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission error. Please check your account status.';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 4),
      );
      
      // Navigate back to previous screen
      Get.back();
    }
  }

  Future<void> _checkAdminReplyTimeout() async {
    // Wait for 1 minute
    await Future.delayed(const Duration(minutes: 1));
    
    if (!adminReplied.value && isWaitingForAdmin.value) {
      // Admin didn't reply in time, send automated message
      isWaitingForAdmin.value = false;
      
      // Add automated fallback message (simulate bot message)
      await _chatService.sendMessage(
        chatId: chatId.value,
        text: 'The concierge is currently busy. How can I help you? They will respond as soon as they are available.',
        sender: MessageSender.user, // Will be shown as system message
      );
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || chatId.value.isEmpty) return;

    try {
      messageController.clear();
      
      await _chatService.sendMessage(
        chatId: chatId.value,
        text: text,
        sender: MessageSender.user,
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
      // Only update typing status if chat is initialized
      if (chatId.value.isNotEmpty) {
        _chatService.updateTypingStatus(chatId.value, shouldShowTyping);
      }
    }
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
    _chatService.updateTypingStatus(chatId.value, false);
    super.onClose();
  }
}
