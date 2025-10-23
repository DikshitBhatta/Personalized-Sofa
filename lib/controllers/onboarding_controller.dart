import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/user_onboarding_data.dart';
import 'package:timberr/wrapper.dart';

class OnboardingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final UserOnboardingData _onboardingData = UserOnboardingData();
  
  UserOnboardingData get onboardingData => _onboardingData;
  
  // Current page index
  final RxInt currentPageIndex = 0.obs;
  
  // Total pages in onboarding
  static const int totalPages = 4;
  
  void setPersonalityType(String type) {
    _onboardingData.personalityType = type;
  }
  
  void setHomeType(String type) {
    _onboardingData.homeType = type;
  }
  
  void setLivingStyle(String style) {
    _onboardingData.livingStyle = style;
  }
  
  void setLocation(String location) {
    _onboardingData.location = location;
  }
  
  void setLivingRoomFeeling(String feeling) {
    _onboardingData.livingRoomFeeling = feeling;
  }
  
  void setRelaxationActivity(String activity) {
    _onboardingData.relaxationActivity = activity;
  }
  
  void setComfortWords(List<String> words) {
    _onboardingData.comfortWords = words;
  }
  
  void setLivingRoomPersonality(String personality) {
    _onboardingData.livingRoomPersonality = personality;
  }
  
  void setGuestFeeling(String feeling) {
    _onboardingData.guestFeeling = feeling;
  }
  
  void setSocialEnergyPreference(String preference) {
    _onboardingData.socialEnergyPreference = preference;
  }
  
  void setGuestImpression(String impression) {
    _onboardingData.guestImpression = impression;
  }
  
  void setPersonalTasteWord(String word) {
    _onboardingData.personalTasteWord = word;
  }
  
  void setLivingArrangement(String arrangement) {
    _onboardingData.livingArrangement = arrangement;
  }
  
  void setHasPets(bool hasPets) {
    _onboardingData.hasPets = hasPets;
  }
  
  void setHostingFrequency(String frequency) {
    _onboardingData.hostingFrequency = frequency;
  }
  
  void setSofaUsageTime(String time) {
    _onboardingData.sofaUsageTime = time;
  }
  
  void nextPage() {
    if (currentPageIndex.value < totalPages - 1) {
      currentPageIndex.value++;
    }
  }
  
  void previousPage() {
    if (currentPageIndex.value > 0) {
      currentPageIndex.value--;
    }
  }
  
  void goToPage(int index) {
    if (index >= 0 && index < totalPages) {
      currentPageIndex.value = index;
    }
  }
  
  Future<void> completeOnboarding() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Save onboarding data to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'onboarding_data': _onboardingData.toJson(),
          'onboarding_completed': true,
          'onboarding_completed_at': DateTime.now().toIso8601String(),
        });
        
        // Navigate to main app
        Get.offAll(() => const Wrapper());
      }
    } catch (error) {
      kDefaultDialog("Error", 'Failed to save your preferences. Please try again.');
    }
  }
}