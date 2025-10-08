import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/widgets/input/personalization_controls.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
// removed unused import
import 'package:timberr/screens/personalization/personalization_step8.dart';

class PersonalizationStep7Screen extends StatefulWidget {
  const PersonalizationStep7Screen({super.key});

  @override
  State<PersonalizationStep7Screen> createState() => _PersonalizationStep7ScreenState();
}

class _PersonalizationStep7ScreenState extends State<PersonalizationStep7Screen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();

  // Final preferences fields
  String? _whatMattersMost;
  bool _washableReplaceableCovers = false;
  String? _ecoFriendly;
  String? _changePreferencesNote;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final existing = _controller.personalizationData.finalPreferences;
    if (existing != null) {
      _whatMattersMost = existing.whatMattersMost;
      _washableReplaceableCovers = existing.washableReplaceableCovers ?? false;
      _ecoFriendly = existing.ecoFriendly;
      _changePreferencesNote = existing.changePreferencesNote;
    }
  }

  void _saveFinalPreferences() {
    final finalPrefs = FinalPreferences(
      whatMattersMost: _whatMattersMost,
      washableReplaceableCovers: _washableReplaceableCovers,
      ecoFriendly: _ecoFriendly,
      changePreferencesNote: _changePreferencesNote,
    );
    
    _controller.setFinalPreferences(finalPrefs);
  }

  bool _isFormValid() {
    return _whatMattersMost != null && _ecoFriendly != null;
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
                        controller.getStepTitle(6),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(6),
                        style: kNunitoSans18.copyWith(color: kGraniteGrey),
                      ),

                      const SizedBox(height: 32),

                      // What matters most
                      PersonalizationCardSelector(
                        label: "What matters most to you?",
                        helperText: "Help us prioritize the most important aspects for your sofa",
                        options: const [
                          PersonalizationOption(
                            title: "Easy Cleaning",
                            icon: Icons.cleaning_services,
                          ),
                          PersonalizationOption(
                            title: "Durability",
                            icon: Icons.shield,
                          ),
                          PersonalizationOption(
                            title: "Low Maintenance",
                            icon: Icons.schedule,
                          ),
                        ],
                        selectedIndex: _whatMattersMost == null ? -1 : 
                            _whatMattersMost == 'Easy Cleaning' ? 0 : 
                            _whatMattersMost == 'Durability' ? 1 : 2,
                        onChanged: (index) {
                          setState(() {
                            _whatMattersMost = ['Easy Cleaning', 'Durability', 'Low Maintenance'][index];
                          });
                        },
                        crossAxisCount: 3,
                      ),

                      const SizedBox(height: 32),

                      // Eco-friendly preference
                      PersonalizationCardSelector(
                        label: "How important is eco-friendliness?",
                        helperText: "Sustainable materials and production methods",
                        options: const [
                          PersonalizationOption(
                            title: "Important",
                            icon: Icons.eco,
                          ),
                          PersonalizationOption(
                            title: "Neutral",
                            icon: Icons.balance,
                          ),
                          PersonalizationOption(
                            title: "Not Important",
                            icon: Icons.remove_circle_outline,
                          ),
                        ],
                        selectedIndex: _ecoFriendly == null ? -1 : 
                            _ecoFriendly == 'Important' ? 0 : 
                            _ecoFriendly == 'Neutral' ? 1 : 2,
                        onChanged: (index) {
                          setState(() {
                            _ecoFriendly = ['Important', 'Neutral', 'Not Important'][index];
                          });
                        },
                        crossAxisCount: 3,
                      ),

                      const SizedBox(height: 32),

                      // Additional preferences
                      Text(
                        "Additional Preferences",
                        style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Optional features and considerations",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: const Text("Washable/Replaceable covers"),
                        subtitle: const Text("Easy to maintain and update"),
                        value: _washableReplaceableCovers,
                        onChanged: (value) => setState(() => _washableReplaceableCovers = value ?? false),
                      ),

                      const SizedBox(height: 32),

                      // Info container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              kIvoryGradientLight,
                              kIvoryGradientMid,
                              kIvoryGradientDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: kIvoryGradientDark.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kIvoryGradientDark.withOpacity(0.2),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: kOffBlack,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Almost there!",
                                    style: kNunitoSansSemiBold16.copyWith(color: kOffBlack,),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "These preferences help us fine-tune our recommendations to match exactly what you're looking for in your perfect sofa.",
                                    style: kNunitoSans14.copyWith(color: kGraniteGrey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          color: kOffBlack,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: () {
                            _saveFinalPreferences();
                            if (_isFormValid()) {
                              _controller.nextStep();
                              Get.to(() => const PersonalizationStep8Screen());
                            } else {
                              Get.snackbar(
                                "Complete Required Fields",
                                "Please select what matters most and eco-friendliness preference",
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
}