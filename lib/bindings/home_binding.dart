import 'package:get/get.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/controllers/favorites_controller.dart';
import 'package:timberr/controllers/cart_controller.dart';
import 'package:timberr/controllers/user_controller.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/controllers/card_details_controller.dart';
import 'package:timberr/Notification/controllers/notification_controller.dart';

/// Binding for Home screen and its dependencies
/// Uses lazyPut to instantiate controllers only when needed
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load controllers - they'll be created when first accessed
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<FavoritesController>(() => FavoritesController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
    Get.lazyPut<CardDetailsController>(() => CardDetailsController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
  }
}
