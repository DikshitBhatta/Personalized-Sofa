import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/widgets/input/personalization_controls.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/screens/personalization/personalization_step3.dart';

class PersonalizationStep2BScreen extends StatefulWidget {
  const PersonalizationStep2BScreen({super.key});

  @override
  State<PersonalizationStep2BScreen> createState() => _PersonalizationStep2BScreenState();
}

class _PersonalizationStep2BScreenState extends State<PersonalizationStep2BScreen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();
  
  // Pet usage variables
  int _numberOfPets = 1;
  int _petSeatingStyleIndex = 0; // Laying down by default
  int _petRelaxLocationIndex = 1; // On sofa cushions by default
  int _wearLevelIndex = 1; // Moderate by default
  bool _extraPetFriendly = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final usageData = _controller.personalizationData.usageStyle;
    if (usageData != null) {
      _numberOfPets = usageData.numberOfPets ?? 1;
      _petSeatingStyleIndex = usageData.petSeatingStyle?.index ?? 0;
      _petRelaxLocationIndex = usageData.petRelaxLocation?.index ?? 1;
      _wearLevelIndex = usageData.wearLevel?.index ?? 1;
      _extraPetFriendly = usageData.extraPetFriendly ?? true;
    }
  }

  void _savePetUsageData() {
    _controller.setPetUsageData(
      numberOfPets: _numberOfPets,
      petSeatingStyle: PetSeatingStyle.values[_petSeatingStyleIndex],
      petRelaxLocation: PetRelaxLocation.values[_petRelaxLocationIndex],
      wearLevel: WearLevel.values[_wearLevelIndex],
      extraPetFriendly: _extraPetFriendly,
    );
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
                  'Usage',
                  'Style',
                  'Details',
                  'Comfort',
                  'Room',
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
                        controller.getStepTitle(2),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(2),
                        style: kNunitoSans18.copyWith(color: kGraniteGrey),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Number of pets selector
                      PersonalizationCardSelector(
                        label: "How many pets do you have?",
                        options: const [
                          PersonalizationOption(
                            title: "1",
                            icon: Icons.pets,
                          ),
                          PersonalizationOption(
                            title: "2",
                            icon: Icons.pets,
                          ),
                          PersonalizationOption(
                            title: "3",
                            icon: Icons.pets,
                          ),
                        ],
                        selectedIndex: _numberOfPets - 1,
                        onChanged: (index) => setState(() => _numberOfPets = index + 1),
                        crossAxisCount: 3,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Pet seating style
                      PersonalizationCardSelector(
                        label: "Preferred style of seating for your pet?",
                        options: const [
                          PersonalizationOption(
                            title: "Laying down",
                            icon: Icons.bed,
                          ),
                          PersonalizationOption(
                            title: "Sitting",
                            icon: Icons.chair,
                          ),
                          PersonalizationOption(
                            title: "Standing",
                            icon: Icons.pets,
                          ),
                        ],
                        selectedIndex: _petSeatingStyleIndex,
                        onChanged: (index) => setState(() => _petSeatingStyleIndex = index),
                        crossAxisCount: 3,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Where does pet like to relax
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
                      
                      // Scratching/wear level
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
                      
                      // Extra pet-friendly toggle
                      PersonalizationCardSelector(
                        label: "Would you like the sofa to be extra pet-friendly?",
                        helperText: "This includes scratch-resistant materials and easy-clean fabrics",
                        options: const [
                          PersonalizationOption(
                            title: "Yes",
                            icon: Icons.shield,
                          ),
                          PersonalizationOption(
                            title: "No",
                            icon: Icons.home,
                          ),
                        ],
                        selectedIndex: _extraPetFriendly ? 0 : 1,
                        onChanged: (index) => setState(() => _extraPetFriendly = index == 0),
                        crossAxisCount: 2,
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              
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
                            _controller.previousStep();
                            Get.back();
                          },
                          child: Text(
                            "Back",
                            style: kNunitoSansSemiBold16.copyWith(color: kGraniteGrey),
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
                            _savePetUsageData();
                            _controller.nextStep();
                            Get.to(() => PersonalizationStep3Screen());
                          },
                          child: Text(
                            "Continue",
                            style: kNunitoSansSemiBold16.copyWith(color: kGraniteGrey),
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

  @override
  void dispose() {
    super.dispose();
  }
}