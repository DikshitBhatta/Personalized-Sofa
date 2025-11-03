import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/models/user_onboarding_data.dart';
import 'package:timberr/utils/emotion_color_picker.dart';


class PersonalizationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Debug flag - set to false to disable verbose logging
  static const bool _debugMode = false;
  
  // Cache keys for SharedPreferences
  static const String _cacheKeyColorHex = 'cached_recommended_color_hex';
  static const String _cacheKeyIsManualEdit = 'cached_is_color_manually_edited';
  static const String _cacheKeyStyleTag1 = 'cached_style_tag_1';
  static const String _cacheKeyStyleTag2 = 'cached_style_tag_2';
  
  final Rx<PersonalizationData> _personalizationData = PersonalizationData().obs;
  PersonalizationData get personalizationData => _personalizationData.value;
  
  final RxString _recommendedColorHex = ''.obs;
  String get recommendedColorHex => _recommendedColorHex.value;
  
  // Track if user manually edited the color (to prevent auto-recalculation)
  final RxBool _isColorManuallyEdited = false.obs;
  bool get isColorManuallyEdited => _isColorManuallyEdited.value;
  
  // Cached style tags from onboarding
  final RxString _styleTag1 = 'Modern'.obs;
  String get styleTag1 => _styleTag1.value;
  
  final RxString _styleTag2 = 'Comfortable'.obs;
  String get styleTag2 => _styleTag2.value;
  
  final RxInt _currentStep = 0.obs;
  // Allow marking certain steps as manually completed (useful for optional steps)
  final Set<int> _manualCompletedSteps = {};
  int get currentStep => _currentStep.value;
  
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSession();
    _loadCachedData(); // Load from cache first for instant UI
    _loadRecommendedColor(); // Then fetch from Firestore in background
    _loadOnboardingStyleTags(); // Load style tags
  }
  
  void _initializeSession() {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _personalizationData.value = PersonalizationData(
      sessionId: sessionId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  // Load cached data from SharedPreferences for instant display
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cached color
      final cachedColor = prefs.getString(_cacheKeyColorHex);
      if (cachedColor != null && cachedColor.isNotEmpty) {
        _recommendedColorHex.value = cachedColor;
        print('✅ Loaded cached color: $cachedColor');
      }
      
      // Load cached manual edit flag
      final cachedManualEdit = prefs.getBool(_cacheKeyIsManualEdit) ?? false;
      _isColorManuallyEdited.value = cachedManualEdit;
      
      // Load cached style tags
      final cachedTag1 = prefs.getString(_cacheKeyStyleTag1);
      if (cachedTag1 != null) {
        _styleTag1.value = cachedTag1;
      }
      
      final cachedTag2 = prefs.getString(_cacheKeyStyleTag2);
      if (cachedTag2 != null) {
        _styleTag2.value = cachedTag2;
      }
      
      // Trigger UI update with cached data
      update();
    } catch (e) {
      print('⚠️ Error loading cached data: $e');
    }
  }
  
  // Load recommended color from Firestore or calculate it
  Future<void> _loadRecommendedColor() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          
          // Check if color was manually edited by user
          if (data?['is_color_manually_edited'] == true) {
            _isColorManuallyEdited.value = true;
            await prefs.setBool(_cacheKeyIsManualEdit, true);
          }
          
          // Check if recommended color is already saved
          if (data?['recommended_color_hex'] != null) {
            final firestoreColor = data!['recommended_color_hex'];
            _recommendedColorHex.value = firestoreColor;
            
            // Cache it for next time
            await prefs.setString(_cacheKeyColorHex, firestoreColor);
            
            print('✅ Loaded recommended color from Firestore: $firestoreColor (manually edited: $_isColorManuallyEdited)');
            update(); // Notify UI
          } else {
            // Calculate it if not present
            await _recalculateRecommendedColor();
          }
        }
      }
    } catch (e) {
      print('⚠️ Error loading recommended color: $e');
    }
  }
  
  // Load onboarding style tags from Firestore
  Future<void> _loadOnboardingStyleTags() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['onboarding_data'] != null) {
          final onboardingData = UserOnboardingData.fromJson(
            userDoc.data()!['onboarding_data'],
          );

          // Update style tags
          if (onboardingData.livingRoomPersonality != null) {
            _styleTag1.value = onboardingData.livingRoomPersonality!;
            await prefs.setString(_cacheKeyStyleTag1, _styleTag1.value);
          }
          
          if (onboardingData.livingRoomFeeling != null) {
            _styleTag2.value = onboardingData.livingRoomFeeling!;
            await prefs.setString(_cacheKeyStyleTag2, _styleTag2.value);
          }

          print('✅ Loaded style tags from Firestore: ${_styleTag1.value} · ${_styleTag2.value}');
          update(); // Notify UI
        }
      }
    } catch (e) {
      print('⚠️ Error loading onboarding style tags: $e');
    }
  }
  
  // Recalculate recommended color based on onboarding data and current personalization
  // ONLY if user hasn't manually edited the color
  Future<void> _recalculateRecommendedColor() async {
    // Don't recalculate if user has manually edited the color
    if (_isColorManuallyEdited.value) {
      print('⏭️ Skipping color recalculation - user has manually edited the color');
      return;
    }
    
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['onboarding_data'] != null) {
          final onboardingData = UserOnboardingData.fromJson(
            userDoc.data()!['onboarding_data'],
          );

          // Calculate recommended color
          final emotionColor = EmotionColorPicker.calculateColor(
            onboardingData: onboardingData,
            personalizationData: _personalizationData.value,
          );

          // Convert to hex
          final recommendedColor = EmotionColorPicker.getFlutterColor(emotionColor);
          final hexColor = '#${recommendedColor.value.toRadixString(16).substring(2).toUpperCase()}';

          _recommendedColorHex.value = hexColor;
          
          // Save to Firestore for future quick access
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set({'recommended_color_hex': hexColor}, SetOptions(merge: true));

          // Cache it locally
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKeyColorHex, hexColor);

          print('🎨 Calculated and saved recommended color: $hexColor (${emotionColor.toString()})');
          update();
        }
      }
    } catch (e) {
      print('⚠️ Error recalculating recommended color: $e');
    }
  }
  
  // Method to manually update recommended color (e.g., when user selects a different color)
  void updateRecommendedColorHex(String hexColor) async {
    _recommendedColorHex.value = hexColor;
    _isColorManuallyEdited.value = true; // Mark as manually edited
    
    // Cache the updated color and manual edit flag
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyColorHex, hexColor);
      await prefs.setBool(_cacheKeyIsManualEdit, true);
    } catch (e) {
      print('⚠️ Error caching updated color: $e');
    }
    
    update(); // Notify all listeners
    print('🎨 Manually updated recommended color to: $hexColor (manual edit flag set)');
  }
  
  // Public method to reload color from Firestore (called when returning to home screen)
  Future<void> reloadColorFromFirestore() async {
    await _loadRecommendedColor();
    update(); // Notify all listeners to rebuild
  }
  
  // Method to reset manual edit flag and recalculate emotion color
  Future<void> resetToEmotionColor() async {
    _isColorManuallyEdited.value = false;
    
    // Update Firestore to remove manual edit flag
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'is_color_manually_edited': false}, SetOptions(merge: true));
    }
    
    // Clear cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cacheKeyIsManualEdit, false);
    } catch (e) {
      print('⚠️ Error clearing manual edit cache: $e');
    }
    
    // Recalculate emotion color
    await _recalculateRecommendedColor();
    print('🔄 Reset to emotion-based color');
  }
  
  // Step 1: Audience Selection
  void setAudienceType(AudienceType audienceType) {
    _personalizationData.value.audienceType = audienceType;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    _recalculateRecommendedColor(); // Update recommendation
    update();
  }
  
  // Step 2: Usage Style / Pet Health
  void setUsageStyle(UsageStyleData usageStyle) {
    _personalizationData.value.usageStyle = usageStyle;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    _recalculateRecommendedColor(); // Update recommendation
    update();
  }
  
  // Pet Health Data Setters (Step 2 for pets)
  void setPetHealthData({
    required PetType petType,
    String? customPetName,
    required PetSize petSize,
    required TemperatureSensitivity temperatureSensitivity,
    required HeightPreference heightPreference,
  }) {
    final currentUsageStyle = _personalizationData.value.usageStyle ?? UsageStyleData();
    currentUsageStyle.petType = petType;
    currentUsageStyle.customPetName = customPetName;
    currentUsageStyle.petSize = petSize;
    currentUsageStyle.temperatureSensitivity = temperatureSensitivity;
    currentUsageStyle.heightPreference = heightPreference;
    
    _personalizationData.value.usageStyle = currentUsageStyle;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    _recalculateRecommendedColor(); // Update recommendation
    update();
  }
  
  // Pet Usage Data Setters (Step 2B for pets)
  void setPetUsageData({
    required int numberOfPets,
    required PetSeatingStyle petSeatingStyle,
    required PetRelaxLocation petRelaxLocation,
    required WearLevel wearLevel,
    required bool extraPetFriendly,
  }) {
    final currentUsageStyle = _personalizationData.value.usageStyle ?? UsageStyleData();
    currentUsageStyle.numberOfPets = numberOfPets;
    currentUsageStyle.petSeatingStyle = petSeatingStyle;
    currentUsageStyle.petRelaxLocation = petRelaxLocation;
    currentUsageStyle.wearLevel = wearLevel;
    currentUsageStyle.extraPetFriendly = extraPetFriendly;
    
    _personalizationData.value.usageStyle = currentUsageStyle;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    _recalculateRecommendedColor(); // Update recommendation
    update();
  }
  
  // Room Photo
  void setRoomPhoto(String? photoPath) {
    _personalizationData.value.roomPhotoPath = photoPath;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    update();
  }
  
  // Comfort Preferences
  void setComfortPreferences(ComfortPreferences comfortPreferences) {
    _personalizationData.value.comfortPreferences = comfortPreferences;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    update();
  }
  
  // Nice to Haves
  void setNiceToHaves(NiceToHaves niceToHaves) {
    _personalizationData.value.niceToHaves = niceToHaves;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    update();
  }
  
  // Final Preferences
  void setFinalPreferences(FinalPreferences finalPreferences) {
    _personalizationData.value.finalPreferences = finalPreferences;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    update();
  }
  
  // Step 3: Style & Material
  void setStyleMaterial(StyleMaterialData styleMaterial) {
    _personalizationData.value.styleMaterial = styleMaterial;
    _personalizationData.value.updatedAt = DateTime.now();
    _saveToFirestore();
    _recalculateRecommendedColor(); // Update recommendation
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
    final isPet = _personalizationData.value.audienceType == AudienceType.pet;
    final maxStep = isPet ? 8 : 7;
    if (_currentStep.value < maxStep) {
      _currentStep.value++;
      if (_debugMode) print('PersonalizationController: nextStep called, currentStep now: ${_currentStep.value}');
      update();
    }
  }
  
  void previousStep() {
    if (_currentStep.value > 0) {
      _currentStep.value--;
      if (_debugMode) print('PersonalizationController: previousStep called, currentStep now: ${_currentStep.value}');
      update();
    }
  }
  
  void goToStep(int step) {
    final isPet = _personalizationData.value.audienceType == AudienceType.pet;
    final maxStep = isPet ? 8 : 7;
    if (step >= 0 && step <= maxStep) {
      _currentStep.value = step;
      update();
    }
  }
  
  // Manually mark a step complete (useful for optional steps where completion is on Continue)
  void markStepComplete(int step) {
    _manualCompletedSteps.add(step);
    if (_debugMode) print('PersonalizationController: markStepComplete called for step $step');
    update();
  }
  
  // Check if current audience is pet to determine if step 2B (pet usage) should be shown
  bool shouldShowPetUsageStep() {
    return _personalizationData.value.audienceType == AudienceType.pet;
  }
  
  // Validation
  bool isStepComplete(int step) {
    final isPet = _personalizationData.value.audienceType == AudienceType.pet;
    
    switch (step) {
      case 0:
        return _personalizationData.value.audienceType != null;
      case 1:
        if (isPet) {
          // For pets: Step 1 is Health questions (first part of usage style)
          return _personalizationData.value.usageStyle != null && _validatePetHealthData();
        } else {
          // For others: Step 1 is Usage Style  
          return _personalizationData.value.usageStyle != null && _validateUsageStyle();
        }
      case 2:
        if (isPet) {
          // For pets: Step 2 is Usage questions (second part of usage style)
          return _personalizationData.value.usageStyle != null && _validatePetUsageData();
        } else {
          // For others: Step 2 is Style & Material
          return _personalizationData.value.styleMaterial?.materialType != null;
        }
      case 3:
        if (isPet) {
          // For pets: Step 3 is Style & Material
          return _personalizationData.value.styleMaterial?.materialType != null;
        } else {
          // For others: Step 3 is Details
          return _validatePersonalizationDetails();
        }
      case 4:
        if (isPet) {
          // For pets: Step 4 is Details
          return _validatePersonalizationDetails();
        } else {
          // For others: Step 4 is Comfort
          return _personalizationData.value.comfortPreferences?.cushionFirmness != null;
        }
      case 5:
        if (isPet) {
          // For pets: Step 5 is Comfort
          return _personalizationData.value.comfortPreferences?.cushionFirmness != null;
        } else {
          // For others: Step 5 is Room photo
          final photo = _personalizationData.value.roomPhotoPath;
          final manual = _manualCompletedSteps.contains(5);
          final result5 = manual || (photo != null && photo.isNotEmpty);
          print('PersonalizationController: isStepComplete(5) called -> manual:$manual photoPresent:${photo != null && photo.isNotEmpty} result:$result5');
          return result5;
        }
      case 6:
        if (isPet) {
          // For pets: Step 6 is Room photo
          final photo = _personalizationData.value.roomPhotoPath;
          final manual = _manualCompletedSteps.contains(6);
          final result6 = manual || (photo != null && photo.isNotEmpty);
          print('PersonalizationController: isStepComplete(6) called -> manual:$manual photoPresent:${photo != null && photo.isNotEmpty} result:$result6');
          return result6;
        } else {
          // For others: Step 6 is Final preferences
          return _personalizationData.value.finalPreferences?.whatMattersMost != null &&
                 _personalizationData.value.finalPreferences?.ecoFriendly != null;
        }
      case 7:
        if (isPet) {
          // For pets: Step 7 is Final preferences
          return _personalizationData.value.finalPreferences?.whatMattersMost != null &&
                 _personalizationData.value.finalPreferences?.ecoFriendly != null;
        } else {
          // For others: Step 7 is Extras
          final extras = _personalizationData.value.niceToHaves;
          final hasData = extras != null && ((extras.extras?.isNotEmpty ?? false) || (extras.modularExpandable == true));
          final manual7 = _manualCompletedSteps.contains(7);
          final result7 = manual7 || hasData;
          print('PersonalizationController: isStepComplete(7) called -> manual:$manual7 hasData:$hasData result:$result7');
          return result7;
        }
      case 8:
        if (isPet) {
          // For pets: Step 8 is Extras
          final extras = _personalizationData.value.niceToHaves;
          final hasData = extras != null && ((extras.extras?.isNotEmpty ?? false) || (extras.modularExpandable == true));
          final manual8 = _manualCompletedSteps.contains(8);
          final result8 = manual8 || hasData;
          print('PersonalizationController: isStepComplete(8) called -> manual:$manual8 hasData:$hasData result:$result8');
          return result8;
        } else {
          return false;
        }
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
        return usageData.petType != null && 
               usageData.petSize != null && 
               usageData.temperatureSensitivity != null && 
               usageData.heightPreference != null;
      default:
        return false;
    }
  }
  
  bool _validatePetHealthData() {
    final usageData = _personalizationData.value.usageStyle;
    if (usageData == null) return false;
    
    return usageData.petType != null && 
           usageData.petSize != null && 
           usageData.temperatureSensitivity != null && 
           usageData.heightPreference != null;
  }
  
  bool _validatePetUsageData() {
    final usageData = _personalizationData.value.usageStyle;
    if (usageData == null) return false;
    
    return usageData.numberOfPets != null && 
           usageData.petSeatingStyle != null && 
           usageData.petRelaxLocation != null && 
           usageData.wearLevel != null && 
           usageData.extraPetFriendly != null;
  }
  
  bool _validatePersonalizationDetails() {
    final details = _personalizationData.value.personalizationDetails;
    return details != null && 
           (details.colorHex?.isNotEmpty == true || details.pantoneCode?.isNotEmpty == true) &&
           details.stitchingType != null && 
           details.legType != null;
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
    final isPet = _personalizationData.value.audienceType == AudienceType.pet;
    
    switch (step) {
      case 0:
        return "Who is this sofa for?";
      case 1:
        return isPet ? "Health" : "Usage Style";
      case 2:
        return isPet ? "Usage" : "Style & Material";
      case 3:
        return isPet ? "Style & Material" : "Color & Details";
      case 4:
        return isPet ? "Color & Details" : "Comfort Preferences";
      case 5:
        return isPet ? "Comfort Preferences" : "Room Photo";
      case 6:
        return isPet ? "Room Photo" : "Final Preferences";
      case 7:
        return isPet ? "Final Preferences" : "Nice to Haves";
      case 8:
        return isPet ? "Nice to Haves" : "";
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
      case 4:
        return "Set your comfort preferences and features";
      case 5:
        return "Add a photo of your room for better recommendations";
      case 6:
        return "Tell us what matters most to you";
      case 7:
        return "Any extra features you'd like?";
      default:
        return "";
    }
  }
  
  double getProgress() {
    final isPet = _personalizationData.value.audienceType == AudienceType.pet;
    final totalSteps = isPet ? 9 : 8;
    final maxStep = isPet ? 8 : 7;
    
    int completedSteps = 0;
    for (int i = 0; i <= maxStep; i++) {
      if (isStepComplete(i)) completedSteps++;
    }
    return completedSteps / totalSteps;
  }


}
