import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:timberr/chatbot/models/chat_message.dart';
import 'package:timberr/chatbot/services/chatbot_service.dart';

class ChatbotController extends GetxController {
  final ChatbotService _chatbotService = ChatbotService();
  
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFirstTimeUser = true.obs;
  
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }
  
  Future<void> _initialize() async {
    await checkFirstTimeUser();
    await loadUnreadCount();
    _listenToMessages();
  }
  
  Future<void> checkFirstTimeUser() async {
    isFirstTimeUser.value = await _chatbotService.isFirstTimeUser();
  }
  
  Future<void> initializeChatbotForUser() async {
    await _chatbotService.initializeChatbot();
    isFirstTimeUser.value = false;
    await loadUnreadCount();
  }
  
  Future<void> loadUnreadCount() async {
    unreadCount.value = await _chatbotService.getUnreadMessageCount();
  }
  
  void _listenToMessages() {
    _chatbotService.streamMessages().listen((messageList) {
      messages.value = messageList;
      // Scroll to bottom when new message arrives
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }
  
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    
    messageController.clear();
    isLoading.value = true;
    
    try {
      await _chatbotService.sendUserMessage(text);
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Send quick reply (pre-defined questions)
  Future<void> sendQuickReply(String message) async {
    isLoading.value = true;
    
    try {
      await _chatbotService.sendUserMessage(message);
    } catch (e) {
      print('Error sending quick reply: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> markMessagesAsRead() async {
    await _chatbotService.markAllMessagesAsRead();
    unreadCount.value = 0;
  }
  
  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
