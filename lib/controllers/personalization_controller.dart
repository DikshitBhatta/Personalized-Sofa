import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timberr/models/personalization_data.dart';

class PersonalizationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final Rx<PersonalizationData> _personalizationData = PersonalizationData().obs;
  PersonalizationData get personalizationData => _personalizationData.value;
  
  final RxInt _currentStep = 0.obs;
  int get currentStep => _currentStep.value;
  
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSession();
  }
  
  void _initializeSession() {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _personalizationData.value = PersonalizationData(
      sessionId: sessionId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  // Step 1: Audience Selection
  void setAudienceType(AudienceType audienceType) {
    _personalizationData.value.audienceType = audienceType;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    update();
  }
  
  // Step 2: Usage Style
  void setUsageStyle(UsageStyleData usageStyle) {
    _personalizationData.value.usageStyle = usageStyle;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    update();
  }
  
  // Step 3: Style & Material
  void setStyleMaterial(StyleMaterialData styleMaterial) {
    _personalizationData.value.styleMaterial = styleMaterial;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    update();
  }
  
  // Step 4: Personalization Details
  void setPersonalizationDetails(PersonalizationDetails personalizationDetails) {
    _personalizationData.value.personalizationDetails = personalizationDetails;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    update();
  }
  
  // Navigation
  void nextStep() {
    if (_currentStep.value < 3) {
      _currentStep.value++;
    }
  }
  
  void previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
    }
  }
  
  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      _currentStep.value = step;
    }
  }
  
  // Validation
  bool isStepComplete(int step) {
    switch (step) {
      case 0:
        return _personalizationData.value.audienceType != null;
      case 1:
        return _personalizationData.value.usageStyle != null && _validateUsageStyle();
      case 2:
        return _personalizationData.value.styleMaterial?.materialType != null;
      case 3:
        return _validatePersonalizationDetails();
      default:
        return false;
    }
  }
  
  bool _validateUsageStyle() {
    final usageData = _personalizationData.value.usageStyle;
    if (usageData == null) return false;
    
    switch (_personalizationData.value.audienceType) {
      case AudienceType.adult:
        return usageData.usagePattern != null && 
               usageData.firmnessPreference != null && 
               usageData.sofaCapacity != null && 
               usageData.seatSupport != null;
      case AudienceType.child:
        return usageData.childUsageType != null && 
               usageData.familyPriority != null && 
               usageData.numberOfChildren != null && 
               usageData.growthAdaptable != null;
      case AudienceType.pet:
        return usageData.petRelaxLocation != null && 
               usageData.wearLevel != null && 
               usageData.allergySensitivity != null && 
               usageData.petFriendlyFeature != null;
      default:
        return false;
    }
  }
  
  bool _validatePersonalizationDetails() {
    final details = _personalizationData.value.personalizationDetails;
    return details != null && 
           (details.colorHex?.isNotEmpty == true || details.pantoneCode?.isNotEmpty == true) &&
           details.stitchingType != null && 
           details.legType != null && 
           details.finishType != null;
  }
  
  bool canProceedToNext() {
    return isStepComplete(_currentStep.value);
  }
  
  // Firestore operations
  Future<void> _saveToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _isLoading.value = true;
        
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('personalization_sessions')
            .doc(_personalizationData.value.sessionId)
            .set(_personalizationData.value.toJson(), SetOptions(merge: true));
      }
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Failed to save personalization data: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> completePersonalization() async {
    try {
      _isLoading.value = true;
      _personalizationData.value.isCompleted = true;
      _personalizationData.value.updatedAt = DateTime.now();
      
      await _saveToFirestore();
      
      // Try to save analytics event, but don't fail if it doesn't work
      try {
        await _firestore.collection('analytics').add({
          'event': 'personalization_completed',
          'user_id': _auth.currentUser?.uid,
          'session_id': _personalizationData.value.sessionId,
          'data': {
            'material': _personalizationData.value.styleMaterial?.materialType?.toString().split('.').last,
            'color': _personalizationData.value.personalizationDetails?.colorHex,
            'pattern': _personalizationData.value.personalizationDetails?.patternType?.toString().split('.').last,
            'stitching': _personalizationData.value.personalizationDetails?.stitchingType?.toString().split('.').last,
            'legs': _personalizationData.value.personalizationDetails?.legType?.toString().split('.').last,
            'finish': _personalizationData.value.personalizationDetails?.finishType?.toString().split('.').last,
            'protective_features': _personalizationData.value.styleMaterial?.functionalityTypes?.map((e) => e.toString().split('.').last).toList(),
          },
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (analyticsError) {
        print('Analytics tracking failed (this is okay): $analyticsError');
      }
      
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Failed to complete personalization: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow; // Re-throw so the UI can handle it
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Helper methods for UI
  String getStepTitle(int step) {
    switch (step) {
      case 0:
        return "Who is this sofa for?";
      case 1:
        return "Usage Style";
      case 2:
        return "Style & Material";
      case 3:
        return "Color & Details";
      default:
        return "";
    }
  }
  
  String getStepDescription(int step) {
    switch (step) {
      case 0:
        return "Tell us who will be using this sofa most often";
      case 1:
        return "Tell us how you'll use your sofa";
      case 2:
        return "Choose your preferred style and materials";
      case 3:
        return "Personalize the colors and finishing touches";
      default:
        return "";
    }
  }
  
  double getProgress() {
    int completedSteps = 0;
    for (int i = 0; i <= 3; i++) {
      if (isStepComplete(i)) completedSteps++;
    }
    return completedSteps / 4;
  }
}
