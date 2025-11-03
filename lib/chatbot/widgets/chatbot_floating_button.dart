import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/chatbot/controllers/chatbot_controller.dart';
import 'package:timberr/chatbot/screens/chatbot_screen.dart';
import 'package:timberr/concierge_chat/services/unread_message_service.dart';

class ChatbotFloatingButton extends StatelessWidget {
  const ChatbotFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatbotController controller = Get.put(ChatbotController());
    
    // Safely get UnreadMessageService - initialize if not found
    late final UnreadMessageService unreadService;
    try {
      unreadService = Get.find<UnreadMessageService>();
    } catch (e) {
      // Service not initialized yet, initialize it now
      print('⚠️ UnreadMessageService not found, initializing now...');
      unreadService = Get.put(UnreadMessageService(), permanent: true);
    }

    return Obx(() {
      // Calculate total unread: chatbot + concierge
      final totalUnread = controller.unreadCount.value + unreadService.unreadCount.value;
      
      // Show "Need expert help?" popup for first-time users
      if (controller.isFirstTimeUser.value) {
        return Positioned(
          right: 16,
          bottom: 20,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            child: InkWell(
              onTap: () async {
                await controller.initializeChatbotForUser();
                Get.to(() => const ChatbotScreen());
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4226), Color(0xFF8B6239)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Need expert help?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Show chat icon for returning users
      return Positioned(
        right: 16,
        bottom: 20,
        child: GestureDetector(
          onTap: () {
            Get.to(() => const ChatbotScreen());
            controller.markMessagesAsRead();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B4226), Color(0xFF8B6239)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              // Unread count badge (chatbot + concierge messages)
              if (totalUnread > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      child: Text(
                        totalUnread > 9
                            ? '9+'
                            : totalUnread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
