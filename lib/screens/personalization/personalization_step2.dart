import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/widgets/input/personalization_controls.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/widgets/buttons/custom_elevated_button.dart';
import 'package:timberr/screens/personalization/personalization_step2b.dart';
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
  
  // Pet health variables
  int _petTypeIndex = 0; // Dog by default
  String _customPetName = '';
  int _petSizeIndex = 1; // Medium by default
  int _temperatureSensitivityIndex = 2; // Normal by default
  int _heightPreferenceIndex = 0; // Low-rise by default

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
      
      // Pet health data
      _petTypeIndex = usageData.petType?.index ?? 0;
      _customPetName = usageData.customPetName ?? '';
      _petSizeIndex = usageData.petSize?.index ?? 1;
      _temperatureSensitivityIndex = usageData.temperatureSensitivity?.index ?? 2;
      _heightPreferenceIndex = usageData.heightPreference?.index ?? 0;
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
        _controller.setPetHealthData(
          petType: PetType.values[_petTypeIndex],
          customPetName: _customPetName.isNotEmpty ? _customPetName : null,
          petSize: PetSize.values[_petSizeIndex],
          temperatureSensitivity: TemperatureSensitivity.values[_temperatureSensitivityIndex],
          heightPreference: HeightPreference.values[_heightPreferenceIndex],
        );
        return;
      default:
        return;
    }
    
    _controller.setUsageStyle(usageData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
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
                totalSteps: 8,
                stepCompletionStatus: List.generate(8, (i) => controller.isStepComplete(i)),
                stepLabels: const [
                  'Audience',
                  'Health',
                  'Style',
                  'Details',
                  'Comfort',
                  'Room',
                  'Final',
                  'Extras',
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
                          color: kOffBlack,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            _saveUsageStyleData();
                            if (controller.canProceedToNext()) {
                              controller.nextStep();
                              // Navigate to Step2B for pets, otherwise Step3
                              if (controller.shouldShowPetUsageStep()) {
                                Get.to(() => const PersonalizationStep2BScreen());
                              } else {
                                Get.to(() => PersonalizationStep3Screen());
                              }
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
                            style: kNunitoSansSemiBold16.copyWith(color: kLynxWhite),
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
            iconPath: 'assets/icons/playtime.png',
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
        label: "What type of pet do you have?",
        helperText: "This helps us design the perfect pet-friendly sofa",
        options: const [
          PersonalizationOption(
            title: "Dog",
            icon: Icons.pets,
          ),
          PersonalizationOption(
            title: "Cat",
            icon: Icons.pets,
          ),
          PersonalizationOption(
            title: "Other",
            icon: Icons.pets_outlined,
          ),
        ],
        selectedIndex: _petTypeIndex,
        onChanged: (index) => setState(() => _petTypeIndex = index),
        crossAxisCount: 3,
      ),
      
      // Show custom pet name input if "Other" is selected
      if (_petTypeIndex == 2) ...[
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _customPetName,
          onChanged: (value) => setState(() => _customPetName = value),
          decoration: InputDecoration(
            labelText: "What type of pet is it?",
            hintText: "e.g., Rabbit, Bird, etc.",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "What size is your pet?",
        options: const [
          PersonalizationOption(
            title: "Small",
            icon: Icons.pets,
          ),
          PersonalizationOption(
            title: "Medium",
            icon: Icons.pets,
          ),
          PersonalizationOption(
            title: "Large",
            icon: Icons.pets,
          ),
        ],
        selectedIndex: _petSizeIndex,
        onChanged: (index) => setState(() => _petSizeIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "Does your pet get cold easily, or overheat easily?",
        options: const [
          PersonalizationOption(
            title: "Gets cold",
            icon: Icons.ac_unit,
          ),
          PersonalizationOption(
            title: "Overheats",
            icon: Icons.whatshot,
          ),
          PersonalizationOption(
            title: "Normal",
            icon: Icons.device_thermostat,
          ),
        ],
        selectedIndex: _temperatureSensitivityIndex,
        onChanged: (index) => setState(() => _temperatureSensitivityIndex = index),
        crossAxisCount: 3,
      ),
      
      const SizedBox(height: 32),
      
      PersonalizationCardSelector(
        label: "Height preference for your pet?",
        helperText: "For small pets, low-rise is often better for easy access",
        options: const [
          PersonalizationOption(
            title: "Low-rise",
            icon: Icons.height,
          ),
          PersonalizationOption(
            title: "Plush premium",
            icon: Icons.weekend,
          ),
        ],
        selectedIndex: _heightPreferenceIndex,
        onChanged: (index) => setState(() => _heightPreferenceIndex = index),
        crossAxisCount: 2,
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }
}
