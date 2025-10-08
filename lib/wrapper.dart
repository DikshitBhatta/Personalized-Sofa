import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/controllers/card_details_controller.dart';
import 'package:timberr/controllers/cart_controller.dart';
import 'package:timberr/controllers/favorites_controller.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/controllers/user_controller.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/role/admin_wrapper.dart';
import 'package:timberr/screens/authentication/onboarding_welcome.dart';
import 'package:timberr/screens/authentication/splash_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    // Initialize role controller first
    Get.lazyPut(() => RoleController(), fenix: true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check user role and redirect accordingly
      await _redirectBasedOnRole();
    } else {
      Get.off(() => const OnBoardingWelcomeScreen());
    }
  }

  /// Redirect user based on their role
  Future<void> _redirectBasedOnRole() async {
    try {
      // Initialize role controller and wait for role to be loaded
      final roleController = Get.find<RoleController>();
      await roleController.refreshUserRole();
      
      if (roleController.isAdmin) {
        // Admin user - redirect to admin dashboard
        _initializeAdminInterface();
      } else {
        // Regular user - redirect to normal app interface
        _initializeUserInterface();
      }
    } catch (e) {
      print('Error checking user role in wrapper: $e');
      // Fallback to user interface if role check fails
      _initializeUserInterface();
    }
  }

  /// Initialize admin interface
  void _initializeAdminInterface() {
    // Initialize all controllers for admin interface
    // Admin might need access to user features through the interface switcher
    _initializeAllControllers();
    
    // Ensure HomeController is always available (needed for bottom nav)
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    
    Get.offAll(() => const AdminWrapper());
  }

  /// Initialize user interface
  void _initializeUserInterface() {
    // Initialize all controllers for user interface
    _initializeAllControllers();
    Get.to(() => SplashScreen(), transition: Transition.fadeIn);
  }

  /// Initialize all necessary controllers
  void _initializeAllControllers() {
    // Check if controllers are already initialized to avoid duplicates
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put(FavoritesController());
    }
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController());
    }
    if (!Get.isRegistered<UserController>()) {
      Get.put(UserController());
    }
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController());
    }
    if (!Get.isRegistered<CardDetailsController>()) {
      Get.put(CardDetailsController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: kOffBlack)),
    );
  }
}
