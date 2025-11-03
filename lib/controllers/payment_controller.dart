import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/cart_controller.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/screens/cart/order_success_screen.dart';
import 'package:timberr/services/order_service.dart';
import 'package:timberr/models/generated_sofa_model.dart';
import 'package:timberr/services/sofa_price_calculator.dart';
import 'package:timberr/models/user_onboarding_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentController extends GetxController {
  final CartController _cartController = Get.find();
  final RxBool isProcessingPayment = false.obs;
  
  // Store sofa data for order creation
  GeneratedSofaModel? _currentSofa;
  double? _sofaPrice;

  void openCheckout(int orderAmount, {GeneratedSofaModel? sofaModel, double? sofaPrice}) {
    _currentSofa = sofaModel;
    _sofaPrice = sofaPrice;
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
    isProcessingPayment.value = true;
    
    try {
      // Create order if we have sofa data
      if (_currentSofa != null && _sofaPrice != null) {
        await _createSofaOrder();
      }
      
      // Clear cart
      await _cartController.removeAllFromCart();
      
      // Navigate to success screen
      Get.off(
        () => const OrderSuccessScreen(),
        transition: Transition.cupertino,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
      
      Get.snackbar(
        "Payment Success",
        "Your order has been placed successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Error in payment success: $e');
      Get.snackbar(
        "Warning",
        "Payment successful but order creation failed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> _createSofaOrder() async {
    try {
      // Get address
      final addressController = Get.find<AddressController>();
      String? deliveryAddress;
      if (addressController.addressList.isNotEmpty) {
        final address = addressController.addressList[addressController.selectedIndex];
        deliveryAddress = '${address.address}, ${address.district}, ${address.city}, ${address.pincode}, ${address.country}';
      }
      
      // Get onboarding data from Firestore
      UserOnboardingData? onboardingData;
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
          
          if (userDoc.exists && userDoc.data()?['onboarding_data'] != null) {
            onboardingData = UserOnboardingData.fromJson(userDoc.data()!['onboarding_data']);
          }
        }
      } catch (e) {
        print('⚠️ Could not load onboarding data: $e');
      }
      
      // Calculate pricing
      final pricing = SofaPriceCalculator.calculatePrice(_currentSofa!.personalizationData);
      
      // Get user's change preferences note from personalization data
      final userNote = _currentSofa!.personalizationData.finalPreferences?.changePreferencesNote;
      final orderNote = userNote != null && userNote.isNotEmpty 
          ? 'User note: $userNote'
          : 'Order placed via app';
      
      // Create the order
      final orderId = await OrderService.createOrder(
        sofaName: _currentSofa!.name,
        glbUrl: _currentSofa!.glbUrl,
        thumbnailUrl: _currentSofa!.thumbnailUrl,
        personalizationData: _currentSofa!.personalizationData,
        onboardingData: onboardingData,
        totalPrice: pricing.totalPrice,
        basePrice: pricing.basePrice,
        deliveryAddress: deliveryAddress,
        notes: orderNote,
      );
      
      if (orderId != null) {
        print('✅ Order created successfully: $orderId');
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }

  void _handlePaymentError() {
    kDefaultDialog("Payment Failed", "Payment was cancelled or failed. Please try again.");
  }
}
