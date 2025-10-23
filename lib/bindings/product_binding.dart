import 'package:get/get.dart';
import 'package:timberr/controllers/product_page_controller.dart';
import 'package:timberr/controllers/personalization_controller.dart';

/// Binding for product-related screens
class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductPageController>(() => ProductPageController());
    Get.lazyPut<PersonalizationController>(() => PersonalizationController());
  }
}
