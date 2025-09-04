import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/wrapper.dart';
import 'package:timberr/models/user_data.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get user => _auth.currentUser;

  Future signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Sign in with success
      Get.offAll(() => const Wrapper());
    } on FirebaseAuthException catch (error) {
      kDefaultDialog("Error", error.message ?? 'Authentication failed');
    } catch (error) {
      kDefaultDialog("Error", 'Some Unknown Error occurred');
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
        
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData.toJson());
            
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
