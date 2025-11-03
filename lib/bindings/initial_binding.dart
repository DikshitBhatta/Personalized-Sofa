import 'package:get/get.dart';
import 'package:timberr/controllers/auth_controller.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/concierge_chat/services/concierge_chat_service.dart';
import 'package:timberr/concierge_chat/services/unread_message_service.dart';
import 'package:timberr/Notification/services/notification_service.dart';

/// Initial binding for global controllers that need to persist throughout app lifecycle
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize global controllers that should exist for the entire app lifetime
    Get.put(AuthController(), permanent: true);
    Get.put(RoleController(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    Get.put(ConciergeChatService(), permanent: true);
    Get.put(UnreadMessageService(), permanent: true);
  }
}
