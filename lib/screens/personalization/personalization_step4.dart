import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart' as personalization;
import 'package:timberr/widgets/input/color_pattern_selector.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/screens/personalization/personalization_results_screen.dart';

class PersonalizationStep4Screen extends StatefulWidget {
  const PersonalizationStep4Screen({super.key});

  @override
  State<PersonalizationStep4Screen> createState() => _PersonalizationStep4ScreenState();
}

class _PersonalizationStep4ScreenState extends State<PersonalizationStep4Screen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();
  
  String? _selectedColorHex;
  String? _selectedPantoneCode;
  personalization.PatternType? _selectedPattern;
  personalization.StitchingType? _selectedStitching;
  personalization.LegType? _selectedLeg;
  personalization.FinishType? _selectedFinish;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final details = _controller.personalizationData.personalizationDetails;
    if (details != null) {
      _selectedColorHex = details.colorHex;
      _selectedPantoneCode = details.pantoneCode;
      _selectedPattern = details.patternType;
      _selectedStitching = details.stitchingType;
      _selectedLeg = details.legType;
      _selectedFinish = details.finishType;
    }
  }

  void _savePersonalizationDetails() {
    final personalizationDetails = personalization.PersonalizationDetails(
      colorHex: _selectedColorHex,
      pantoneCode: _selectedPantoneCode,
      patternType: _selectedPattern,
      stitchingType: _selectedStitching,
      legType: _selectedLeg,
      finishType: _selectedFinish,
    );
    
    _controller.setPersonalizationDetails(personalizationDetails);
  }

  bool _isFormValid() {
    return (_selectedColorHex?.isNotEmpty == true || _selectedPantoneCode?.isNotEmpty == true) &&
           _selectedStitching != null &&
           _selectedLeg != null &&
           _selectedFinish != null;
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
                        controller.getStepTitle(3),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(3),
                        style: kNunitoSans18.copyWith(color: kTinGrey),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Color selection
                      ColorPicker(
                        selectedColorHex: _selectedColorHex,
                        selectedPantoneCode: _selectedPantoneCode,
                        onColorSelected: (colorHex) {
                          setState(() {
                            _selectedColorHex = colorHex;
                          });
                        },
                        onPantoneCodeChanged: (pantoneCode) {
                          setState(() {
                            _selectedPantoneCode = pantoneCode;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Pattern selection
                      PatternSelector(
                        selectedPattern: _selectedPattern,
                        onPatternSelected: (pattern) {
                          setState(() {
                            _selectedPattern = pattern;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Details selection
                      Text(
                        "Finishing Details",
                        style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            "Choose your preferred finishing options",
                            style: kNunitoSans14.copyWith(color: kGrey),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            "*",
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      DetailsSelector(
                        selectedStitching: _selectedStitching,
                        selectedLeg: _selectedLeg,
                        selectedFinish: _selectedFinish,
                        onStitchingSelected: (stitching) {
                          setState(() {
                            _selectedStitching = stitching;
                          });
                        },
                        onLegSelected: (leg) {
                          setState(() {
                            _selectedLeg = leg;
                          });
                        },
                        onFinishSelected: (finish) {
                          setState(() {
                            _selectedFinish = finish;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Preview card
                      if (_isFormValid()) _buildPreviewCard(),
                      
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
                          onPressed: () async {
                            _savePersonalizationDetails();
                            if (_isFormValid()) {
                              await controller.completePersonalization();
                              _showCompletionDialog();
                            } else {
                              Get.snackbar(
                                "Complete Required Fields",
                                "Please select a color and all finishing details before completing",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          child: Text(
                            "Complete Design",
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

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kSeaGreen.withOpacity(0.1),
            kSeaGreen.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSeaGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kSeaGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.preview, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                "Your Design Preview",
                style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Color preview
          Row(
            children: [
              Text(
                "Color: ",
                style: kNunitoSans14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: kTinGrey,
                ),
              ),
              if (_selectedColorHex != null) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(int.parse(_selectedColorHex!.substring(1), radix: 16) + 0xFF000000),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kChristmasSilver),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedColorHex!.toUpperCase(),
                  style: kNunitoSans14.copyWith(color: kOffBlack),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (_selectedPattern != null)
            _buildPreviewRow("Pattern", _getPatternName(_selectedPattern!)),
          
          if (_selectedStitching != null)
            _buildPreviewRow("Stitching", _getStitchingName(_selectedStitching!)),
          
          if (_selectedLeg != null)
            _buildPreviewRow("Legs", _getLegName(_selectedLeg!)),
          
          if (_selectedFinish != null)
            _buildPreviewRow("Finish", _getFinishName(_selectedFinish!)),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: kNunitoSans14.copyWith(
              fontWeight: FontWeight.w600,
              color: kTinGrey,
            ),
          ),
          Text(
            value,
            style: kNunitoSans14.copyWith(color: kOffBlack),
          ),
        ],
      ),
    );
  }

  String _getPatternName(personalization.PatternType pattern) {
    switch (pattern) {
      case personalization.PatternType.check:
        return "Check";
      case personalization.PatternType.herringbone:
        return "Herringbone";
      case personalization.PatternType.jacquard:
        return "Jacquard";
      case personalization.PatternType.stripe:
        return "Stripe";
    }
  }

  String _getStitchingName(personalization.StitchingType stitching) {
    switch (stitching) {
      case personalization.StitchingType.double:
        return "Double Stitching";
      case personalization.StitchingType.contrast:
        return "Contrast Stitching";
      case personalization.StitchingType.hand:
        return "Hand Stitching";
    }
  }

  String _getLegName(personalization.LegType leg) {
    switch (leg) {
      case personalization.LegType.walnut:
        return "Walnut Wood";
      case personalization.LegType.oak:
        return "Oak Wood";
      case personalization.LegType.ash:
        return "Ash Wood";
      case personalization.LegType.steel:
        return "Steel";
      case personalization.LegType.bronze:
        return "Bronze";
    }
  }

  String _getFinishName(personalization.FinishType finish) {
    switch (finish) {
      case personalization.FinishType.matte:
        return "Matte Finish";
      case personalization.FinishType.gloss:
        return "Gloss Finish";
      case personalization.FinishType.oil:
        return "Oil Finish";
    }
  }

  void _showCompletionDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kSeaGreen,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                "Design Complete!",
                style: kNunitoSansBold20.copyWith(color: kOffBlack),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                "Your personalized sofa design has been saved. Our team will review it and get back to you with a quote.",
                textAlign: TextAlign.center,
                style: kNunitoSans14.copyWith(color: kGrey),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        // Navigate to personalized recommendations screen after a brief delay
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Get.to(
                            () => const PersonalizationResultsScreen(),
                            transition: Transition.rightToLeft,
                          );
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kOffBlack),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "View More",
                        style: kNunitoSans14.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kOffBlack,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Close dialog and pop back to Home screen
                        Get.back(); // Close dialog
                        Future.delayed(const Duration(milliseconds: 300), () {
                          // Pop until we find a route that is NOT a personalization screen
                          // This will get us back to the Home screen
                          Get.until((route) {
                            // Check if the route contains personalization-related content
                            final routeStr = route.toString().toLowerCase();
                            final routeName = route.settings.name?.toLowerCase() ?? '';
                            
                            // If this route is NOT a personalization screen, stop here
                            final isPersonalizationRoute = 
                                routeStr.contains('personalization') ||
                                routeName.contains('personalization');
                            
                            // Also stop if we've reached the first route as a fallback
                            return !isPersonalizationRoute || route.isFirst;
                          });
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOffBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Done",
                        style: kNunitoSans14.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
