import 'package:get/get.dart';
import 'package:timberr/controllers/order_controller.dart';
import 'package:timberr/controllers/payment_controller.dart';
import 'package:timberr/controllers/add_payment_controller.dart';

/// Binding for order and payment screens
class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<PaymentController>(() => PaymentController());
    Get.lazyPut<AddPaymentController>(() => AddPaymentController());
  }
}
