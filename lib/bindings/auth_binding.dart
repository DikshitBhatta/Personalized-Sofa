import 'package:get/get.dart';
import 'package:timberr/controllers/onboarding_controller.dart';

/// Binding for authentication screens
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
