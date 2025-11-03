import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_concierge_support_controller.dart';
import '../../concierge_chat/models/concierge_message.dart';
import '../../concierge_chat/models/concierge_chat.dart';

class AdminConciergeSupportScreen extends StatelessWidget {
  const AdminConciergeSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminConciergeSupportController());

    return Scaffold(
      backgroundColor: const Color(0xff2A2438),
      appBar: AppBar(
        backgroundColor: const Color(0xff352F44),
        elevation: 0,
        title: const Text(
          'Concierge Support',
          style: TextStyle(
            color: Color(0xffFFFFFF),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show chat list or selected chat (full screen)
        if (controller.selectedChat.value == null) {
          // Chat list view (full screen)
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xff352F44),
                  border: Border(
                    bottom: BorderSide(color: Color(0xff4A4458), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat, color: Color(0xffB0A0D6)),
                    const SizedBox(width: 12),
                    Text(
                      'Active Chats (${controller.allChats.length})',
                      style: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.allChats.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Color(0xff8476AA),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No active chats',
                              style: TextStyle(
                                color: Color(0xffB0A0D6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.allChats.length,
                        itemBuilder: (context, index) {
                          final chat = controller.allChats[index];
                          return _buildChatListItem(chat, controller);
                        },
                      ),
              ),
            ],
          );
        } else {
          // Chat messages view (full screen)
          return _buildChatPanel(controller);
        }
      }),
    );
  }

  Widget _buildChatListItem(ConciergeChat chat, AdminConciergeSupportController controller) {
    final isSelected = controller.selectedChatId.value == chat.chatId;
    final userName = controller.getUserName(chat);
    final userEmail = controller.getUserEmail(chat);
    final time = DateFormat('HH:mm').format(chat.updatedAt);

    return Material(
      color: isSelected ? const Color(0xff4A4458) : Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectChat(chat),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xff4A4458), width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xff8476AA),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (chat.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage,
                      style: TextStyle(
                        color: const Color(0xffB0A0D6).withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userEmail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: const Color(0xffB0A0D6).withOpacity(0.5),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: const Color(0xffB0A0D6).withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatPanel(AdminConciergeSupportController controller) {
    final chat = controller.selectedChat.value!;
    final userName = controller.getUserName(chat);

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xff352F44),
            border: Border(
              bottom: BorderSide(color: Color(0xff4A4458), width: 1),
            ),
          ),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xffFFFFFF)),
                onPressed: () {
                  controller.selectedChat.value = null;
                  controller.selectedChatId.value = '';
                },
                tooltip: 'Back to chat list',
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xff8476AA),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Obx(() => controller.isUserTyping.value
                        ? const Text(
                            'typing...',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : Text(
                            controller.getUserEmail(chat),
                            style: const TextStyle(
                              color: Color(0xffB0A0D6),
                              fontSize: 12,
                            ),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: Obx(() {
            if (controller.messages.isEmpty) {
              return const Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(color: Color(0xffB0A0D6)),
                ),
              );
            }

            return ListView.builder(
              controller: controller.scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return _buildMessageBubble(message);
              },
            );
          }),
        ),

        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xff352F44),
            border: Border(
              top: BorderSide(color: Color(0xff4A4458), width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff2A2438),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    onChanged: controller.onTypingChanged,
                    style: const TextStyle(color: Color(0xffFFFFFF)),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Color(0xffB0A0D6)),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: controller.sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xff8476AA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ConciergeMessage message) {
    final isAdmin = message.sender == MessageSender.admin;
    final time = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isAdmin)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xff8476AA),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAdmin ? const Color(0xff8476AA) : const Color(0xff352F44),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isAdmin ? 16 : 4),
                      bottomRight: Radius.circular(isAdmin ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Color(0xffFFFFFF),
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xffB0A0D6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isAdmin)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xff8476AA),
              child: Icon(Icons.support_agent, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
