import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/cart_controller.dart';
import 'package:timberr/screens/cart/order_success_screen.dart';

class PaymentController extends GetxController {
  final CartController _cartController = Get.find();

  void openCheckout(int orderAmount) {
    // Simulate payment process
    _showPaymentDialog(orderAmount);
  }

  void _showPaymentDialog(int orderAmount) {
    Get.dialog(
      AlertDialog(
        title: const Text('Payment Simulation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order Amount: \$${orderAmount + 5}'),
            const SizedBox(height: 16),
            const Text('This is a demo payment gateway.'),
            const Text('Click "Pay Now" to simulate successful payment.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _handlePaymentError();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _handlePaymentSuccess();
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePaymentSuccess() async {
    await _cartController.removeAllFromCart();
    Get.off(
      () => const OrderSuccessScreen(),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
    Get.snackbar(
      "Payment Success",
      "Your payment was successful!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _handlePaymentError() {
    kDefaultDialog("Payment Failed", "Payment was cancelled or failed. Please try again.");
  }
}
