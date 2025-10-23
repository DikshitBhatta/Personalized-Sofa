import 'package:get/get.dart';
import 'package:timberr/models/sofa_order.dart';
import 'package:timberr/services/order_service.dart';

class OrderController extends GetxController {
  final Rx<List<SofaOrder>> allOrders = Rx<List<SofaOrder>>([]);
  final Rx<List<SofaOrder>> pendingOrders = Rx<List<SofaOrder>>([]);
  final Rx<List<SofaOrder>> processingOrders = Rx<List<SofaOrder>>([]);
  final Rx<List<SofaOrder>> deliveredOrders = Rx<List<SofaOrder>>([]);
  final Rx<List<SofaOrder>> cancelledOrders = Rx<List<SofaOrder>>([]);
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserOrders();
  }

  /// Load user's orders
  void loadUserOrders() {
    isLoading.value = true;

    // Listen to pending orders
    OrderService.getUserOrders(status: OrderStatus.pending).listen((orders) {
      pendingOrders.value = orders;
    });

    // Listen to processing orders
    OrderService.getUserOrders(status: OrderStatus.processing).listen((orders) {
      processingOrders.value = orders;
    });

    // Listen to delivered orders
    OrderService.getUserOrders(status: OrderStatus.delivered).listen((orders) {
      deliveredOrders.value = orders;
    });

    // Listen to cancelled orders
    OrderService.getUserOrders(status: OrderStatus.cancelled).listen((orders) {
      cancelledOrders.value = orders;
    });

    // Listen to all orders
    OrderService.getUserOrders().listen((orders) {
      allOrders.value = orders;
      isLoading.value = false;
    });
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    isLoading.value = true;
    final success = await OrderService.cancelOrder(orderId);
    isLoading.value = false;
    
    if (success) {
      Get.snackbar(
        'Success',
        'Order cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to cancel order',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    
    return success;
  }

  /// Get order count by status
  int getOrderCount(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return pendingOrders.value.length;
      case OrderStatus.processing:
        return processingOrders.value.length;
      case OrderStatus.delivered:
        return deliveredOrders.value.length;
      case OrderStatus.cancelled:
        return cancelledOrders.value.length;
    }
  }
}
