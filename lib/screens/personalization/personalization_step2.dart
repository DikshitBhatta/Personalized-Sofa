import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/widgets/input/personalization_controls.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/screens/personalization/personalization_step3.dart';

class PersonalizationStep2Screen extends StatefulWidget {
  const PersonalizationStep2Screen({super.key});

  @override
  State<PersonalizationStep2Screen> createState() => _PersonalizationStep2ScreenState();
}

class _PersonalizationStep2ScreenState extends State<PersonalizationStep2Screen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();
  
  // Adult usage style variables
  int _usagePatternIndex = 0; // Lounging by default
  int _firmnessPreferenceIndex = 1; // Balanced by default
  int _sofaCapacityIndex = 1; // Three by default
  int _seatSupportIndex = 2; // Standard by default
  
  // Child usage style variables
  int _childUsageTypeIndex = 0; // Reading & Quiet Time by default
  int _familyPriorityIndex = 2; // Standard Comfort by default
  int _numberOfChildren = 1;
  bool _growthAdaptable = true;
  
  // Pet usage style variables
  int _petRelaxLocationIndex = 1; // On the sofa cushions by default
  int _wearLevelIndex = 1; // Moderate by default
  int _allergySensitivityIndex = 1; // Medium by default
  int _petFriendlyFeatureIndex = 2; // Standard durability by default

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final usageData = _controller.personalizationData.usageStyle;
    if (usageData != null) {
      // Adult data
      _usagePatternIndex = usageData.usagePattern?.index ?? 0;
      _firmnessPreferenceIndex = usageData.firmnessPreference?.index ?? 1;
      _sofaCapacityIndex = usageData.sofaCapacity?.index ?? 1;
      _seatSupportIndex = usageData.seatSupport?.index ?? 2;
      
      // Child data
      _childUsageTypeIndex = usageData.childUsageType?.index ?? 0;
      _familyPriorityIndex = usageData.familyPriority?.index ?? 2;
      _numberOfChildren = usageData.numberOfChildren ?? 1;
      _growthAdaptable = usageData.growthAdaptable ?? true;
      
      // Pet data
      _petRelaxLocationIndex = usageData.petRelaxLocation?.index ?? 1;
      _wearLevelIndex = usageData.wearLevel?.index ?? 1;
      _allergySensitivityIndex = usageData.allergySensitivity?.index ?? 1;
      _petFriendlyFeatureIndex = usageData.petFriendlyFeature?.index ?? 2;
    }
  }

  void _saveUsageStyleData() {
    final audienceType = _controller.personalizationData.audienceType;
    
    UsageStyleData usageData;
    
    switch (audienceType) {
      case AudienceType.adult:
        usageData = UsageStyleData(
          usagePattern: UsagePattern.values[_usagePatternIndex],
          firmnessPreference: FirmnessPreference.values[_firmnessPreferenceIndex],
          sofaCapacity: SofaCapacity.values[_sofaCapacityIndex],
          seatSupport: SeatSupport.values[_seatSupportIndex],
        );
        break;
      case AudienceType.child:
        usageData = UsageStyleData(
          childUsageType: ChildUsageType.values[_childUsageTypeIndex],
          familyPriority: FamilyPriority.values[_familyPriorityIndex],
          numberOfChildren: _numberOfChildren,
          growthAdaptable: _growthAdaptable,
        );
        break;
      case AudienceType.pet:
        usageData = UsageStyleData(
          petRelaxLocation: PetRelaxLocation.values[_petRelaxLocationIndex],
          wearLevel: WearLevel.values[_wearLevelIndex],
          allergySensitivity: AllergySensitivity.values[_allergySensitivityIndex],
          petFriendlyFeature: PetFriendlyFeature.values[_petFriendlyFeatureIndex],
        );
        break;
      default:
        return;
    }
    
    _controller.setUsageStyle(usageData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLynxWhite,
      appBar: AppBar(
        backgroundColor: kLynxWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            _controller.previousStep();
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: kOffBlack, size: 20),
        ),
        centerTitle: true,
        title: Text(
          "PERSONALIZATION",
          style: kMerriweatherBold16.copyWith(color: kOffBlack),
        ),
      ),
      body: GetBuilder<PersonalizationController>(
        builder: (controller) {
          final audienceType = controller.personalizationData.audienceType;
          
          return Column(
            children: [
              // Progress bar
              PersonalizationProgressBar(
                currentStep: controller.currentStep,
                totalSteps: 4,
                stepCompletionStatus: [
                  controller.isStepComplete(0),
                  controller.isStepComplete(1),
                  controller.isStepComplete(2),
                  controller.isStepComplete(3),
                ],
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        controller.getStepTitle(1),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(1),
                        style: kNunitoSans18.copyWith(color: kTinGrey),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Form based on audience type
                      if (audienceType == AudienceType.adult) ..._buildAdultForm(),
                      if (audienceType == AudienceType.child) ..._buildChildForm(),
                      if (audienceType == AudienceType.pet) ..._buildPetForm(),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
              // Bottom navigation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x10000000),
                      offset: Offset(0, -2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: kChristmasSilver),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            controller.previousStep();
                            Get.back();
                          },
                          child: Text(
                            "Back",
                            style: kNunitoSansSemiBold16.copyWith(color: kTinGrey),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: kChristmasSilver),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            _saveUsageStyleData();
                            if (controller.canProceedToNext()) {
                              controller.nextStep();
                              Get.to(() => PersonalizationStep3Screen());
                            } else {
                              Get.snackbar(
                                "Complete Required Fields",
                                "Please fill in all required information before continuing",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          child: Text(
                            "Continue",
                            style: kNunitoSansSemiBold16.copyWith(color: kTinGrey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildAdultForm() {
    return [
      PersonalizationCardSelector(
        label: "How will you enjoy your sofa most of the time?",
        helperText: "This helps us tailor the perfect proportions for you",
        options: const [
          PersonalizationOption(
            title: "Lounging",
            icon: Icons.weekend,
          ),
          PersonalizationOption(
            title: "Formal Hosting",
            icon: Icons.groups,
          ),
          PersonalizationOption(
            title: "Family Living",
            icon: Icons.family_restroom,
          ),
        ],
        selectedIndex: _usagePatternIndex,
        onChanged: (index) => setState(() => _usagePatternIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "Do you prefer firmer or softer seating?",
        options: const [
          PersonalizationOption(
            title: "Firm",
            iconPath: 'assets/icons/firm_seating.png',
          ),
          PersonalizationOption(
            title: "Balanced",
            icon: Icons.balance,
          ),
          PersonalizationOption(
            title: "Soft",
            icon: Icons.cloud,
          ),
        ],
        selectedIndex: _firmnessPreferenceIndex,
        onChanged: (index) => setState(() => _firmnessPreferenceIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "How many people should it comfortably fit?",
        options: const [
          PersonalizationOption(
            title: "2",
            icon: Icons.people,
          ),
          PersonalizationOption(
            title: "3",
            icon: Icons.group,
          ),
          PersonalizationOption(
            title: "4",
            icon: Icons.groups,
          ),
        ],
        selectedIndex: _sofaCapacityIndex,
        onChanged: (index) => setState(() => _sofaCapacityIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "Would you like extra lumbar support or deeper lounging seats?",
        options: const [
          PersonalizationOption(
            title: "Lumbar Support",
            iconPath: 'assets/icons/Lumbar_support.png',
          ),
          PersonalizationOption(
            title: "Extra Deep Seat",
            icon: Icons.event_seat,
          ),
          PersonalizationOption(
            title: "Standard",
            icon: Icons.chair,
          ),
        ],
        selectedIndex: _seatSupportIndex,
        onChanged: (index) => setState(() => _seatSupportIndex = index),
        crossAxisCount: 3,
      ),
    ];
  }

  List<Widget> _buildChildForm() {
    return [
      PersonalizationCardSelector(
        label: "How will your child mostly use the sofa?",
        helperText: "This helps us create the perfect child-friendly design",
        options: const [
          PersonalizationOption(
            title: "Reading & Quiet Time",
            icon: Icons.menu_book,
          ),
          PersonalizationOption(
            title: "Playtime & TV",
            iconPath: 'assets/icons/Playtime.png',
          ),
          PersonalizationOption(
            title: "Nap & Rest",
            iconPath: 'assets/icons/nap_rest.png',
          ),
        ],
        selectedIndex: _childUsageTypeIndex,
        onChanged: (index) => setState(() => _childUsageTypeIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "What's most important for your family?",
        options: const [
          PersonalizationOption(
            title: "Easy to Clean",
            icon: Icons.cleaning_services,
          ),
          PersonalizationOption(
            title: "Extra Edge Softness",
            icon: Icons.child_care,
          ),
          PersonalizationOption(
            title: "Standard Comfort",
            icon: Icons.home,
          ),
        ],
        selectedIndex: _familyPriorityIndex,
        onChanged: (index) => setState(() => _familyPriorityIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "How many little ones will share it?",
        options: const [
          PersonalizationOption(
            title: "1",
            icon: Icons.person,
          ),
          PersonalizationOption(
            title: "2",
            icon: Icons.people,
          ),
          PersonalizationOption(
            title: "3+",
            icon: Icons.group,
          ),
        ],
        selectedIndex: _numberOfChildren - 1,
        onChanged: (index) => setState(() => _numberOfChildren = index + 1),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "Would you like it designed to grow with your child?",
        options: const [
          PersonalizationOption(
            title: "Yes, adaptable",
            icon: Icons.trending_up,
          ),
          PersonalizationOption(
            title: "No, keep as is",
            icon: Icons.lock,
          ),
        ],
        selectedIndex: _growthAdaptable ? 0 : 1,
        onChanged: (index) => setState(() => _growthAdaptable = index == 0),
        crossAxisCount: 2,
      ),
    ];
  }

  List<Widget> _buildPetForm() {
    return [
      PersonalizationCardSelector(
        label: "Where does your pet like to relax?",
        helperText: "This helps us design the perfect pet-friendly sofa",
        options: const [
          PersonalizationOption(
            title: "Beside me on floor",
            icon: Icons.pets,
          ),
          PersonalizationOption(
            title: "On sofa cushions",
            icon: Icons.weekend,
          ),
          PersonalizationOption(
            title: "On armrests/backrest",
            icon: Icons.chair,
          ),
        ],
        selectedIndex: _petRelaxLocationIndex,
        onChanged: (index) => setState(() => _petRelaxLocationIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "How much scratching or playful wear do you expect?",
        options: const [
          PersonalizationOption(
            title: "Low",
            icon: Icons.sentiment_satisfied,
          ),
          PersonalizationOption(
            title: "Moderate",
            icon: Icons.sentiment_neutral,
          ),
          PersonalizationOption(
            title: "High",
            icon: Icons.sports,
          ),
        ],
        selectedIndex: _wearLevelIndex,
        onChanged: (index) => setState(() => _wearLevelIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "How much shedding or allergy sensitivity should we plan for?",
        options: const [
          PersonalizationOption(
            title: "Low",
            icon: Icons.check_circle,
          ),
          PersonalizationOption(
            title: "Medium",
            icon: Icons.warning,
          ),
          PersonalizationOption(
            title: "High",
            icon: Icons.error,
          ),
        ],
        selectedIndex: _allergySensitivityIndex,
        onChanged: (index) => setState(() => _allergySensitivityIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "Would you like the sofa to be extra pet-friendly?",
        options: const [
          PersonalizationOption(
            title: "Scratch-resistant",
            icon: Icons.shield,
          ),
          PersonalizationOption(
            title: "Easy-clean fabric",
            icon: Icons.cleaning_services,
          ),
          PersonalizationOption(
            title: "Standard durability",
            icon: Icons.home,
          ),
        ],
        selectedIndex: _petFriendlyFeatureIndex,
        onChanged: (index) => setState(() => _petFriendlyFeatureIndex = index),
        crossAxisCount: 3,
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
