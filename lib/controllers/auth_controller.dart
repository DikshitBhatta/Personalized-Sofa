import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/wrapper.dart';
import 'package:timberr/models/user_data.dart';
import 'package:timberr/role/role_access.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/role/admin_wrapper.dart';
import 'package:timberr/controllers/home_controller.dart';
import 'package:timberr/controllers/favorites_controller.dart';
import 'package:timberr/controllers/cart_controller.dart';
import 'package:timberr/controllers/user_controller.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/controllers/card_details_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get user => _auth.currentUser;

  Future signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Sign in with success - redirect based on role
      await _redirectBasedOnRole();
    } on FirebaseAuthException catch (error) {
      kDefaultDialog("Error", error.message ?? 'Authentication failed');
    } catch (error) {
      kDefaultDialog("Error", 'Some Unknown Error occurred');
    }
  }

  /// Redirect user based on their role after successful authentication
  Future<void> _redirectBasedOnRole() async {
    try {
      if (_auth.currentUser == null) {
        Get.offAll(() => const Wrapper());
        return;
      }

      // Check user role
      final userRole = await RoleBasedAccessControl.getCurrentUserRole();
      final isAdmin = userRole == 'admin';

      if (isAdmin) {
        // Redirect admin to admin wrapper
        _initializeAdminControllers();
        Get.offAll(() => const AdminWrapper());
      } else {
        // Redirect regular user to normal app flow
        Get.offAll(() => const Wrapper());
      }
    } catch (e) {
      print('Error checking user role: $e');
      // Fallback to normal wrapper if role check fails
      Get.offAll(() => const Wrapper());
    }
  }

  /// Initialize controllers needed for admin interface
  void _initializeAdminControllers() {
    // Initialize role controller first
    if (!Get.isRegistered<RoleController>()) {
      Get.put(RoleController(), permanent: true);
    }
    
    // Initialize all necessary controllers for admin interface
    // Admin users need all controllers as they might access user components
    _initializeAllControllers();
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

  Future signUp(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        // Create user data in Firestore
        final userData = UserData(
          name: name,
          email: email,
          newArrivalsNotification: false,
          deliveryStatusNotification: true,
          salesNotification: true,
        );
        
        final userDataMap = userData.toJson();
        userDataMap['created_at'] = DateTime.now().toIso8601String();
        userDataMap['role'] = 'user'; // Default role
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userDataMap);
        
        // Assign default user role
        await RoleBasedAccessControl.assignDefaultUserRole(
          userCredential.user!.uid,
          email,
        );
            
        Get.offAll(() => const Wrapper());
      }
    } on FirebaseAuthException catch (error) {
      kDefaultDialog("Error", error.message ?? 'Registration failed');
    } catch (error) {
      kDefaultDialog("Error", 'Some Unknown Error occurred');
    }
  }

  Future forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Password reset",
          "Password reset request has been sent to your email successfully.");
    } catch (error) {
      kDefaultDialog("Error", 'Failed to send password reset email');
    }
  }
}
