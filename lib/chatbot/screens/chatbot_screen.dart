import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/chatbot/controllers/chatbot_controller.dart';
import 'package:timberr/chatbot/models/chat_message.dart';
import 'package:timberr/concierge_chat/screens/user_concierge_chat_screen.dart';
import 'package:timberr/concierge_chat/services/concierge_chat_service.dart';
import 'package:timberr/concierge_chat/services/unread_message_service.dart';
import 'package:intl/intl.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatbotController controller = Get.find<ChatbotController>();
    
    // Safely get UnreadMessageService - initialize if not found
    late final UnreadMessageService unreadService;
    try {
      unreadService = Get.find<UnreadMessageService>();
    } catch (e) {
      print('⚠️ UnreadMessageService not found in ChatbotScreen, initializing now...');
      unreadService = Get.put(UnreadMessageService(), permanent: true);
    }
    
    // Mark messages as read when screen opens
    controller.markMessagesAsRead();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1ED),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6B4226),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sofa Expert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6B4226),
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return ChatMessageBubble(message: message);
                },
              );
            }),
          ),

          // Quick reply buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Obx(() => QuickReplyButton(
                    label: '👤 Contact Concierge',
                    badgeCount: unreadService.unreadCount.value,
                    onTap: () {
                      // Ensure service is initialized
                      if (!Get.isRegistered<ConciergeChatService>()) {
                        Get.put(ConciergeChatService(), permanent: true);
                      }
                      Get.to(() => const UserConciergeChatScreen());
                    },
                    isPrimary: true,
                  )),
                  const SizedBox(width: 8),
                  QuickReplyButton(
                    label: '🎨 Sofa color?',
                    onTap: () => controller.sendQuickReply('What sofa color do you recommend for me?'),
                  ),
                  const SizedBox(width: 8),
                  QuickReplyButton(
                    label: '✨ Material?',
                    onTap: () => controller.sendQuickReply('What material should I choose?'),
                  ),
                  const SizedBox(width: 8),
                  QuickReplyButton(
                    label: '📏 Size?',
                    onTap: () => controller.sendQuickReply('What size sofa is best for me?'),
                  ),
                  const SizedBox(width: 8),
                  QuickReplyButton(
                    label: '� Comfort?',
                    onTap: () => controller.sendQuickReply('Tell me about comfort options'),
                  ),
                  const SizedBox(width: 8),
                  QuickReplyButton(
                    label: '🎯 Recommendation?',
                    onTap: () => controller.sendQuickReply('What sofa do you recommend for me?'),
                  ),
                ],
              ),
            ),
          ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F1ED),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: controller.messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask about your sofa...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => controller.sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => GestureDetector(
                    onTap: controller.isLoading.value
                        ? null
                        : controller.sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: controller.isLoading.value
                              ? [Colors.grey, Colors.grey]
                              : [const Color(0xFF6B4226), const Color(0xFF8B6239)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: controller.isLoading.value
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final timeFormat = DateFormat('h:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF6B4226),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF6B4226)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF333333),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    timeFormat.format(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Quick Reply Button Widget
class QuickReplyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final int? badgeCount;

  const QuickReplyButton({
    Key? key,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.badgeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFF6B4226) : const Color(0xFFF5F1ED),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6B4226).withOpacity(isPrimary ? 1.0 : 0.3),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : const Color(0xFF6B4226),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Badge for unread count
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  badgeCount! > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
