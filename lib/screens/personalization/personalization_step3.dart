import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart' as personalization;
import 'package:timberr/widgets/cards/material_grid.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
// removed unused import
import 'package:timberr/screens/personalization/personalization_step4.dart';

class PersonalizationStep3Screen extends StatefulWidget {
  const PersonalizationStep3Screen({super.key});

  @override
  State<PersonalizationStep3Screen> createState() => _PersonalizationStep3ScreenState();
}

class _PersonalizationStep3ScreenState extends State<PersonalizationStep3Screen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();
  
  personalization.MaterialType? _selectedMaterial;
  List<personalization.FunctionalityType> _selectedFunctionalities = [];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final styleMaterial = _controller.personalizationData.styleMaterial;
    if (styleMaterial != null) {
      _selectedMaterial = styleMaterial.materialType;
      _selectedFunctionalities = styleMaterial.functionalityTypes ?? [];
    }
  }

  void _saveStyleMaterialData() {
    final styleMaterialData = personalization.StyleMaterialData(
      materialType: _selectedMaterial,
      functionalityTypes: _selectedFunctionalities.isNotEmpty ? _selectedFunctionalities : null,
    );
    
    _controller.setStyleMaterial(styleMaterialData);
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
                        controller.getStepTitle(2),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(2),
                        style: kNunitoSans18.copyWith(color: kGraniteGrey),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Material selection
                      Row(
                        children: [
                          Text(
                            "Select Material",
                            style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "*",
                            style: TextStyle(color: Colors.red, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Choose the material that best fits your needs and lifestyle",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      MaterialGrid(
                        selectedMaterial: _selectedMaterial,
                        onMaterialSelected: (material) {
                          setState(() {
                            _selectedMaterial = material;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Functionality selection
                      Text(
                        "Additional Features",
                        style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Select any special features you'd like (optional)",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      FunctionalityChips(
                        selectedFunctionalities: _selectedFunctionalities,
                        onSelectionChanged: (functionalities) {
                          setState(() {
                            _selectedFunctionalities = functionalities;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Material info card
                      if (_selectedMaterial != null) _buildMaterialInfoCard(),
                      
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
                            _saveStyleMaterialData();
                            if (controller.canProceedToNext()) {
                              controller.nextStep();
                              Get.to(() => const PersonalizationStep4Screen());
                            } else {
                              Get.snackbar(
                                "Material Selection Required",
                                "Please select a material before continuing",
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

  Widget _buildMaterialInfoCard() {
    final materialInfo = _getMaterialInfo(_selectedMaterial!);
    
    return Container(
      padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kIvoryGradientDark.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kIvoryGradientDark.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
                  color: kOffBlack.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.info_outline, color: kOffBlack),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  materialInfo['name']!,
                  style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow("Care", materialInfo['care']!),
          const SizedBox(height: 8),
          _buildInfoRow("Durability", materialInfo['durability']!),
          const SizedBox(height: 8),
          _buildInfoRow("Pet Friendly", materialInfo['petFriendly']!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            "$label:",
            style: kNunitoSans14.copyWith(
              fontWeight: FontWeight.w600,
              color: kGraniteGrey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: kNunitoSans14.copyWith(color: kOffBlack),
          ),
        ),
      ],
    );
  }

  Map<String, String> _getMaterialInfo(personalization.MaterialType material) {
    switch (material) {
      case personalization.MaterialType.fullGrain:
        return {
          'name': 'Full-grain Leather',
          'care': 'Regular conditioning required',
          'durability': 'Excellent - ages beautifully',
          'petFriendly': 'Good with proper care'
        };
      case personalization.MaterialType.semiAniline:
        return {
          'name': 'Semi-aniline Leather',
          'care': 'Moderate maintenance',
          'durability': 'Very good',
          'petFriendly': 'Good'
        };
      case personalization.MaterialType.nubuck:
        return {
          'name': 'Nubuck Leather',
          'care': 'Special cleaning required',
          'durability': 'Good',
          'petFriendly': 'Moderate'
        };
      case personalization.MaterialType.pu:
        return {
          'name': 'PU Leather',
          'care': 'Easy to clean',
          'durability': 'Good',
          'petFriendly': 'Excellent'
        };
      case personalization.MaterialType.cotton:
        return {
          'name': 'Cotton Fabric',
          'care': 'Machine washable covers',
          'durability': 'Good with care',
          'petFriendly': 'Very good'
        };
      case personalization.MaterialType.linen:
        return {
          'name': 'Linen Fabric',
          'care': 'Professional cleaning recommended',
          'durability': 'Good',
          'petFriendly': 'Good'
        };
      case personalization.MaterialType.velvet:
        return {
          'name': 'Velvet Fabric',
          'care': 'Professional cleaning required',
          'durability': 'Moderate',
          'petFriendly': 'Low - attracts pet hair'
        };
      case personalization.MaterialType.alcantara:
        return {
          'name': 'Alcantara',
          'care': 'Special cleaning required',
          'durability': 'Excellent',
          'petFriendly': 'Good'
        };
      case personalization.MaterialType.ecoFabric:
        return {
          'name': 'Eco-friendly Fabric',
          'care': 'Easy maintenance',
          'durability': 'Very good',
          'petFriendly': 'Excellent'
        };
    }
  }
}
