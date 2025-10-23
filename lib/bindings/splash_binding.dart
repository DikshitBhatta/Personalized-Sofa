import 'package:get/get.dart';
import 'package:timberr/controllers/splash_controller.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/controllers/user_controller.dart';
import 'package:timberr/controllers/favorites_controller.dart';
import 'package:timberr/controllers/cart_controller.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/controllers/card_details_controller.dart';

/// Binding for Splash screen
/// Preloads essential controllers needed for initial data fetch
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Create splash controller
    Get.lazyPut<SplashController>(() => SplashController());
    
    // Preload all essential controllers for splash screen data loading
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<FavoritesController>(() => FavoritesController(), fenix: true);
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
    Get.lazyPut<CardDetailsController>(() => CardDetailsController(), fenix: true);
  }
}
