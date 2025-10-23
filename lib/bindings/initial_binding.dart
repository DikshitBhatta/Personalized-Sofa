import 'package:get/get.dart';
import 'package:timberr/controllers/auth_controller.dart';
import 'package:timberr/role/role_controller.dart';

/// Initial binding for global controllers that need to persist throughout app lifecycle
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize global controllers that should exist for the entire app lifetime
    Get.put(AuthController(), permanent: true);
    Get.put(RoleController(), permanent: true);
  }
}
