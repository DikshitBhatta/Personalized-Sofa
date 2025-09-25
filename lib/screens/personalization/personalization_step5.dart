import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/widgets/input/personalization_controls.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/screens/personalization/personalization_step6.dart';

class PersonalizationStep5Screen extends StatefulWidget {
  const PersonalizationStep5Screen({super.key});

  @override
  State<PersonalizationStep5Screen> createState() => _PersonalizationStep5ScreenState();
}

class _PersonalizationStep5ScreenState extends State<PersonalizationStep5Screen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();

  // Basic comfort fields
  String? _cushionFirmness;
  String? _seatDepth;
  bool _backSupport = false;
  bool _armrests = true;
  bool _headrest = false;
  bool _tallUsers = false;
  bool _elderlyFriendly = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final existing = _controller.personalizationData.comfortPreferences;
    if (existing != null) {
      _cushionFirmness = existing.cushionFirmness;
      _seatDepth = existing.seatDepth;
      _backSupport = existing.backSupport ?? false;
      _armrests = existing.armrests ?? true;
      _headrest = existing.headrest ?? false;
      _tallUsers = existing.tallUsers ?? false;
      _elderlyFriendly = existing.elderlyFriendly ?? false;
    }
  }

  void _saveComfortData() {
    final comfortPrefs = ComfortPreferences(
      cushionFirmness: _cushionFirmness,
      seatDepth: _seatDepth,
      backSupport: _backSupport,
      armrests: _armrests,
      headrest: _headrest,
      tallUsers: _tallUsers,
      elderlyFriendly: _elderlyFriendly,
    );
    
    _controller.setComfortPreferences(comfortPrefs);
  }

  bool _isFormValid() {
    final audienceType = _controller.personalizationData.audienceType;
    
    // Basic validation - cushion firmness is required for all
    if (_cushionFirmness == null) return false;
    
    // Per-audience specific validation
    switch (audienceType) {
      case AudienceType.adult:
        return _seatDepth != null; // Adults need seat depth preference
      case AudienceType.child:
        return true; // Children don't have strict requirements
      case AudienceType.pet:
        return true; // Pets don't have strict requirements
      default:
        return false;
    }
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
                        controller.getStepTitle(4),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(4),
                        style: kNunitoSans18.copyWith(color: kTinGrey),
                      ),

                      const SizedBox(height: 32),

                      // Cushion Firmness (Required for all)
                      PersonalizationCardSelector(
                        label: "Cushion Firmness",
                        helperText: "How firm would you like the seat cushions?",
                        options: const [
                          PersonalizationOption(title: "Soft", icon: Icons.cloud),
                          PersonalizationOption(title: "Medium", icon: Icons.balance),
                          PersonalizationOption(title: "Firm", icon: Icons.square),
                        ],
                        selectedIndex: _cushionFirmness == null ? -1 : 
                            _cushionFirmness == 'soft' ? 0 : 
                            _cushionFirmness == 'medium' ? 1 : 2,
                        onChanged: (index) {
                          setState(() {
                            _cushionFirmness = ['soft', 'medium', 'firm'][index];
                          });
                        },
                        crossAxisCount: 3,
                      ),

                      const SizedBox(height: 24),

                      // Seat Depth (Required for adults, optional for others)
                      if (audienceType == AudienceType.adult) ...[
                        PersonalizationCardSelector(
                          label: "Seat Depth",
                          helperText: "How deep should the seat be for your comfort?",
                          options: const [
                            PersonalizationOption(title: "Shallow", icon: Icons.chair),
                            PersonalizationOption(title: "Medium", icon: Icons.event_seat),
                            PersonalizationOption(title: "Deep", icon: Icons.weekend),
                          ],
                          selectedIndex: _seatDepth == null ? -1 : 
                              _seatDepth == 'shallow' ? 0 : 
                              _seatDepth == 'medium' ? 1 : 2,
                          onChanged: (index) {
                            setState(() {
                              _seatDepth = ['shallow', 'medium', 'deep'][index];
                            });
                          },
                          crossAxisCount: 3,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Comfort features
                      Text(
                        "Comfort Features",
                        style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        audienceType == AudienceType.child 
                            ? "Safety and comfort features for children"
                            : audienceType == AudienceType.pet 
                                ? "Pet-friendly comfort considerations"
                                : "Additional comfort preferences",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: const Text("Extra back support"),
                        subtitle: Text(audienceType == AudienceType.child 
                            ? "Helps maintain good posture during activities"
                            : "Lumbar support for better spine alignment"),
                        value: _backSupport,
                        onChanged: (value) => setState(() => _backSupport = value ?? false),
                      ),

                      CheckboxListTile(
                        title: const Text("Armrests"),
                        subtitle: Text(audienceType == AudienceType.child 
                            ? "Provides stability and safety"
                            : "For comfortable arm positioning"),
                        value: _armrests,
                        onChanged: (value) => setState(() => _armrests = value ?? true),
                      ),

                      if (audienceType == AudienceType.adult) ...[
                        CheckboxListTile(
                          title: const Text("Adjustable headrest"),
                          subtitle: const Text("For neck and head support"),
                          value: _headrest,
                          onChanged: (value) => setState(() => _headrest = value ?? false),
                        ),

                        CheckboxListTile(
                          title: const Text("Tall user friendly"),
                          subtitle: const Text("Extended seat and back height"),
                          value: _tallUsers,
                          onChanged: (value) => setState(() => _tallUsers = value ?? false),
                        ),

                        CheckboxListTile(
                          title: const Text("Elderly friendly features"),
                          subtitle: const Text("Easier entry/exit and firm support"),
                          value: _elderlyFriendly,
                          onChanged: (value) => setState(() => _elderlyFriendly = value ?? false),
                        ),
                      ],

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
                            _saveComfortData();
                            if (_isFormValid()) {
                              _controller.nextStep(); // This sets currentStep to 5
                              Get.to(() => const PersonalizationStep6Screen());
                            } else {
                              Get.snackbar(
                                "Complete Required Fields",
                                "Please select cushion firmness${_controller.personalizationData.audienceType == AudienceType.adult ? ' and seat depth' : ''} before continuing",
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
}