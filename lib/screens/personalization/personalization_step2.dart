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
  
  // Form state variables
  double _heightCm = 170.0;
  double _weightKg = 70.0;
  int _sittingHabitIndex = 1; // Balanced by default
  bool _hasBackPain = false;
  
  // Child specific
  int _ageYears = 8;
  bool _growthConsideration = true;
  
  // Pet specific
  String _species = "";
  bool _clawingBehavior = false;
  bool _allergySensitive = false;
  
  final TextEditingController _speciesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final healthData = _controller.personalizationData.healthErgonomics;
    if (healthData != null) {
      _heightCm = healthData.heightCm ?? 170.0;
      _weightKg = healthData.weightKg ?? 70.0;
      _sittingHabitIndex = healthData.sittingHabit?.index ?? 1;
      _hasBackPain = healthData.hasBackPain ?? false;
      _ageYears = healthData.ageYears ?? 8;
      _growthConsideration = healthData.growthConsideration ?? true;
      _species = healthData.species ?? "";
      _speciesController.text = _species;
      _clawingBehavior = healthData.clawingBehavior ?? false;
      _allergySensitive = healthData.allergySensitive ?? false;
    }
  }

  void _saveHealthData() {
    final audienceType = _controller.personalizationData.audienceType;
    
    HealthErgonomicsData healthData;
    
    switch (audienceType) {
      case AudienceType.adult:
        healthData = HealthErgonomicsData(
          heightCm: _heightCm,
          weightKg: _weightKg,
          sittingHabit: SittingHabit.values[_sittingHabitIndex],
          hasBackPain: _hasBackPain,
        );
        break;
      case AudienceType.child:
        healthData = HealthErgonomicsData(
          ageYears: _ageYears,
          heightCm: _heightCm,
          weightKg: _weightKg,
          growthConsideration: _growthConsideration,
        );
        break;
      case AudienceType.pet:
        healthData = HealthErgonomicsData(
          species: _species,
          weightKg: _weightKg,
          clawingBehavior: _clawingBehavior,
          allergySensitive: _allergySensitive,
        );
        break;
      default:
        return;
    }
    
    _controller.setHealthErgonomics(healthData);
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
                            _saveHealthData();
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
      PersonalizationSlider(
        label: "Height",
        value: _heightCm,
        min: 140.0,
        max: 200.0,
        divisions: 60,
        formatter: (value) => "${value.round()} cm",
        onChanged: (value) => setState(() => _heightCm = value),
      ),
      
      const SizedBox(height: 24),
      
      PersonalizationSlider(
        label: "Weight",
        value: _weightKg,
        min: 40.0,
        max: 140.0,
        divisions: 100,
        formatter: (value) => "${value.round()} kg",
        onChanged: (value) => setState(() => _weightKg = value),
      ),
      
      const SizedBox(height: 24),
      
      DiscreteSlider(
        label: "Sitting Habit",
        options: const ["Lounge", "Balanced", "Upright"],
        selectedIndex: _sittingHabitIndex,
        onChanged: (index) => setState(() => _sittingHabitIndex = index),
      ),
      
      const SizedBox(height: 24),
      
      CustomToggle(
        label: "Do you experience back pain?",
        value: _hasBackPain,
        onChanged: (value) => setState(() => _hasBackPain = value),
      ),
    ];
  }

  List<Widget> _buildChildForm() {
    return [
      PersonalizationSlider(
        label: "Age",
        value: _ageYears.toDouble(),
        min: 1.0,
        max: 15.0,
        divisions: 14,
        formatter: (value) => "${value.round()} years",
        onChanged: (value) => setState(() => _ageYears = value.round()),
      ),
      
      const SizedBox(height: 24),
      
      PersonalizationSlider(
        label: "Height",
        value: _heightCm,
        min: 80.0,
        max: 180.0,
        divisions: 100,
        formatter: (value) => "${value.round()} cm",
        onChanged: (value) => setState(() => _heightCm = value),
      ),
      
      const SizedBox(height: 24),
      
      PersonalizationSlider(
        label: "Weight",
        value: _weightKg,
        min: 10.0,
        max: 80.0,
        divisions: 70,
        formatter: (value) => "${value.round()} kg",
        onChanged: (value) => setState(() => _weightKg = value),
      ),
      
      const SizedBox(height: 24),
      
      CustomToggle(
        label: "Consider growth in design?",
        value: _growthConsideration,
        onChanged: (value) => setState(() => _growthConsideration = value),
      ),
    ];
  }

  List<Widget> _buildPetForm() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pet Species",
            style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _speciesController,
            decoration: InputDecoration(
              hintText: "e.g., Dog, Cat, Rabbit",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kChristmasSilver),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kOffBlack, width: 2),
              ),
            ),
            onChanged: (value) => setState(() => _species = value),
          ),
        ],
      ),
      
      const SizedBox(height: 24),
      
      PersonalizationSlider(
        label: "Pet Weight",
        value: _weightKg,
        min: 1.0,
        max: 100.0,
        divisions: 99,
        formatter: (value) => "${value.round()} kg",
        onChanged: (value) => setState(() => _weightKg = value),
      ),
      
      const SizedBox(height: 24),
      
      CustomToggle(
        label: "Does your pet have clawing behavior?",
        value: _clawingBehavior,
        onChanged: (value) => setState(() => _clawingBehavior = value),
      ),
      
      const SizedBox(height: 16),
      
      CustomToggle(
        label: "Is your pet allergy sensitive?",
        value: _allergySensitive,
        onChanged: (value) => setState(() => _allergySensitive = value),
      ),
    ];
  }

  @override
  void dispose() {
    _speciesController.dispose();
    super.dispose();
  }
}
