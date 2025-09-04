import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/controllers/card_details_controller.dart';
import 'package:timberr/controllers/cart_controller.dart';
import 'package:timberr/controllers/favorites_controller.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/controllers/user_controller.dart';
import 'package:timberr/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final HomeController _homeController = Get.find();
  final FavoritesController _favoritesController = Get.find();
  final CartController _cartController = Get.find();
  final UserController _userController = Get.find();
  final CardDetailsController _cardDetailsController = Get.find();
  final AddressController _addressController = Get.find();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Add a small delay to ensure the widget tree is built
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Load critical data first (user data)
      await _userController.fetchUserData();
      
      // Load other data in parallel to improve performance
      await Future.wait([
        _homeController.getProducts(0).catchError((e) {
          print('Error loading products: $e');
          return; // Continue even if products fail to load
        }),
        _favoritesController.fetchFavorites().catchError((e) {
          print('Error loading favorites: $e');
          return;
        }),
        _cartController.fetchCartItems().catchError((e) {
          print('Error loading cart: $e');
          return;
        }),
        _cardDetailsController.getDefaultCardDetail().catchError((e) {
          print('Error loading card details: $e');
          return;
        }),
        _addressController.getDefaultShippingAddress().catchError((e) {
          print('Error loading address: $e');
          return;
        }),
      ]);
      
      // Ensure we're still mounted before navigating
      if (mounted) {
        Get.off(() => Home());
      }
    } catch (e) {
      print('Critical error during initialization: $e');
      // Still navigate to home even if some operations fail
      if (mounted) {
        Get.off(() => Home());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            LottieBuilder.asset("assets/lottie/splash_loading_animation.json"),
      ),
    );
  }
}
