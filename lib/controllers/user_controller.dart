import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/user_data.dart';
import 'package:timberr/screens/authentication/onboarding_welcome.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  UserData userData = UserData();

  Future<void> fetchUserData() async {
    final doc = await _firestore.collection("Users").doc(_auth.currentUser!.uid).get();
    if (doc.exists) {
      userData = UserData.fromJson(doc.data()!);
      update();
    }
  }

  void signOut() {
    kDefaultDialog(
      "Sign out",
      "Are you sure you want to sign out?",
      onYesPressed: () async {
        await _auth.signOut();
        await Get.deleteAll(force: true);
        Get.offAll(() => const OnBoardingWelcomeScreen());
      },
    );
  }

  Future<void> uploadProfilePicture() async {
    // TODO: Implement Firebase Storage upload
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   final fileExt = image.path.split('.').last;
    //   final filePath = '${_auth.currentUser!.uid}.$fileExt';
    //   final ref = _storage.ref().child('profile-pics/$filePath');
    //   await ref.putFile(File(image.path));
    //   final downloadUrl = await ref.getDownloadURL();
    //   await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
    //     'profile_picture_url': downloadUrl,
    //   });
    //   userData.profilePictureUrl = downloadUrl;
    //   update();
    // }
  }

  Future<void> setSalesNotification(bool val) async {
    userData.salesNotification = val;
    update();
    await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
      'sales_notification': val,
    });
  }

  Future<void> setDeliveryStatusNotification(bool val) async {
    userData.deliveryStatusNotification = val;
    update();
    await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
      'delivery_status_notification': val,
    });
  }

  Future<void> setNewArrivalsNotification(bool val) async {
    userData.newArrivalsNotification = val;
    update();
    await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
      'new_arrivals_notification': val,
    });
  }

  Future<void> setName(String name) async {
    userData.name = name;
    update();
    await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
      'Name': name,
    });
    Get.back();
  }

  void resetPassword() {
    kDefaultDialog(
      "Change Password",
      "Are you sure do you want to change your password?",
      onYesPressed: () async {
        Get.back();
        await _auth.sendPasswordResetEmail(email: userData.email);
        Get.snackbar("Reset Password",
            "Your Password reset request has been sent to your email successfully");
      },
    );
  }
}
