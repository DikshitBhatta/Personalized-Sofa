import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/user_data.dart';
import 'package:timberr/role/role_access.dart';
import 'package:timberr/role/role_controller.dart';
import 'package:timberr/role/admin_wrapper.dart';
import 'package:timberr/routes/app_routes.dart';
import 'package:timberr/screens/authentication/user_onboarding_screen.dart';

/// Controller for authentication operations
/// Handles sign in, sign up, and post-auth routing
class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get user => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    print('🔐 AuthController: Initialized');
  }

  /// Sign in with email and password
  Future signIn(String email, String password) async {
    try {
      print('🔑 AuthController: Attempting sign in...');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('✅ AuthController: Sign in successful');
      
      // Sign in successful - redirect based on role
      await _redirectBasedOnRole();
    } on FirebaseAuthException catch (error) {
      print('❌ AuthController: Sign in failed - ${error.message}');
      kDefaultDialog("Error", error.message ?? 'Authentication failed');
    } catch (error) {
      print('❌ AuthController: Unknown error - $error');
      kDefaultDialog("Error", 'Some Unknown Error occurred');
    }
  }

  /// Redirect user based on their role after successful authentication
  Future<void> _redirectBasedOnRole() async {
    try {
      if (_auth.currentUser == null) {
        print('⚠️ AuthController: No user found, redirecting to wrapper');
        Get.offAllNamed(AppRoutes.wrapper);
        return;
      }

      print('🎭 AuthController: Checking user role...');
      // Ensure RoleController exists (it should from InitialBinding, but just in case)
      final roleController = Get.isRegistered<RoleController>() 
          ? Get.find<RoleController>() 
          : Get.put(RoleController(), permanent: true);
      await roleController.refreshUserRole();
      
      final isAdmin = roleController.isAdmin;
      print('👤 AuthController: User is ${isAdmin ? "admin" : "regular user"}');

      if (isAdmin) {
        // Admin user - redirect to admin wrapper
        print('🔧 AuthController: Redirecting to admin interface');
        Get.offAll(() => const AdminWrapper());
      } else {
        // Regular user - use named route to splash screen
        // SplashBinding will handle controller initialization
        print('🏠 AuthController: Redirecting to splash screen');
        Get.offAllNamed(AppRoutes.splash);
      }
    } catch (e) {
      print('❌ AuthController: Error checking user role - $e');
      // Fallback to wrapper if role check fails
      Get.offAllNamed(AppRoutes.wrapper);
    }
  }

  /// Sign up with email and password
  Future signUp(String name, String email, String password) async {
    try {
      print('📝 AuthController: Attempting sign up...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        print('✅ AuthController: User created, saving data...');
        
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
        
        print('✅ AuthController: User data saved, navigating to onboarding');
        // Navigate to onboarding screen for new users
        Get.offAll(() => const UserOnboardingScreen());
      }
    } on FirebaseAuthException catch (error) {
      print('❌ AuthController: Sign up failed - ${error.message}');
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
