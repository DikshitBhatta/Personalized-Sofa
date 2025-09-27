import 'package:flutter/material.dart' hide MaterialType;
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/personalization_controller.dart';
import '../../models/personalization_data.dart';
import '../../widgets/buttons/custom_elevated_button.dart';
import 'personalization_results_screen.dart';

class EditPersonalizationScreen extends StatefulWidget {
  const EditPersonalizationScreen({super.key});

  @override
  State<EditPersonalizationScreen> createState() => _EditPersonalizationScreenState();
}

class _EditPersonalizationScreenState extends State<EditPersonalizationScreen> {
  final PersonalizationController _personalizationController = Get.find<PersonalizationController>();
  
  // Text controllers for all editable fields
  final TextEditingController _changeNoteController = TextEditingController();
  final TextEditingController _customPetNameController = TextEditingController();
  final TextEditingController _additionalRequestsController = TextEditingController();
  
  // Step 1: Audience Type
  AudienceType? _selectedAudienceType;
  
  // Step 2: Usage Style (Adult)
  UsagePattern? _selectedUsagePattern;
  FirmnessPreference? _selectedFirmnessPreference;
  SofaCapacity? _selectedSofaCapacity;
  SeatSupport? _selectedSeatSupport;
  
  // Step 2: Usage Style (Child)
  ChildUsageType? _selectedChildUsageType;
  FamilyPriority? _selectedFamilyPriority;
  int? _numberOfChildren;
  bool _growthAdaptable = false;
  
  // Step 2: Usage Style (Pet Health)
  PetType? _selectedPetType;
  String _customPetName = '';
  PetSize? _selectedPetSize;
  TemperatureSensitivity? _selectedTemperatureSensitivity;
  HeightPreference? _selectedHeightPreference;
  
  // Step 2B: Pet Usage
  int? _numberOfPets;
  PetSeatingStyle? _selectedPetSeatingStyle;
  PetRelaxLocation? _selectedPetRelaxLocation;
  WearLevel? _selectedWearLevel;
  bool _extraPetFriendly = false;
  
  // Step 3: Style & Material
  MaterialType? _selectedMaterialType;
  List<FunctionalityType> _selectedFunctionalities = [];
  
  // Step 4: Color, Pattern & Details
  String? _selectedColorHex;
  String? _selectedPantoneCode;
  PatternType? _selectedPatternType;
  StitchingType? _selectedStitchingType;
  LegType? _selectedLegType;
  FinishType? _selectedFinishType;
  
  // Step 5: Room Photo (just display path, not editable here)
  String? _roomPhotoPath;
  
  // Step 6: Comfort Preferences
  String? _selectedCushionFirmness;
  String? _selectedSeatDepth;
  bool _backSupport = false;
  bool _armrests = false;
  bool _headrest = false;
  bool _tallUsers = false;
  bool _elderlyFriendly = false;
  
  // Step 7: Nice to Haves
  List<String> _selectedExtras = [];
  bool _modularExpandable = false;
  List<String> _selectedFeatures = [];
  String _additionalRequests = '';
  
  // Step 8: Final Preferences
  String? _selectedWhatMattersMost;
  bool _washableReplaceableCovers = false;
  String _ecoFriendly = '';
  
  @override
  void initState() {
    super.initState();
    _loadCurrentPersonalizationData();
  }

  void _loadCurrentPersonalizationData() {
    final data = _personalizationController.personalizationData;
    
    // Step 1: Audience Type
    _selectedAudienceType = data.audienceType;
    
    // Step 2: Usage Style
    if (data.usageStyle != null) {
      final usage = data.usageStyle!;
      
      // Adult fields
      _selectedUsagePattern = usage.usagePattern;
      _selectedFirmnessPreference = usage.firmnessPreference;
      _selectedSofaCapacity = usage.sofaCapacity;
      _selectedSeatSupport = usage.seatSupport;
      
      // Child fields
      _selectedChildUsageType = usage.childUsageType;
      _selectedFamilyPriority = usage.familyPriority;
      _numberOfChildren = usage.numberOfChildren;
      _growthAdaptable = usage.growthAdaptable ?? false;
      
      // Pet health fields
      _selectedPetType = usage.petType;
      _customPetName = usage.customPetName ?? '';
      _customPetNameController.text = _customPetName;
      _selectedPetSize = usage.petSize;
      _selectedTemperatureSensitivity = usage.temperatureSensitivity;
      _selectedHeightPreference = usage.heightPreference;
      
      // Pet usage fields
      _numberOfPets = usage.numberOfPets;
      _selectedPetSeatingStyle = usage.petSeatingStyle;
      _selectedPetRelaxLocation = usage.petRelaxLocation;
      _selectedWearLevel = usage.wearLevel;
      _extraPetFriendly = usage.extraPetFriendly ?? false;
    }
    
    // Step 3: Style & Material
    if (data.styleMaterial != null) {
      _selectedMaterialType = data.styleMaterial!.materialType;
      _selectedFunctionalities = data.styleMaterial!.functionalityTypes ?? [];
    }
    
    // Step 4: Color, Pattern & Details
    if (data.personalizationDetails != null) {
      final details = data.personalizationDetails!;
      _selectedColorHex = details.colorHex;
      _selectedPantoneCode = details.pantoneCode;
      _selectedPatternType = details.patternType;
      _selectedStitchingType = details.stitchingType;
      _selectedLegType = details.legType;
      _selectedFinishType = details.finishType;
    }
    
    // Step 5: Room Photo
    _roomPhotoPath = data.roomPhotoPath;
    
    // Step 6: Comfort Preferences
    if (data.comfortPreferences != null) {
      final comfort = data.comfortPreferences!;
      _selectedCushionFirmness = comfort.cushionFirmness;
      _selectedSeatDepth = comfort.seatDepth;
      _backSupport = comfort.backSupport ?? false;
      _armrests = comfort.armrests ?? false;
      _headrest = comfort.headrest ?? false;
      _tallUsers = comfort.tallUsers ?? false;
      _elderlyFriendly = comfort.elderlyFriendly ?? false;
    }
    
    // Step 7: Nice to Haves
    if (data.niceToHaves != null) {
      final nice = data.niceToHaves!;
      _selectedExtras = nice.extras ?? [];
      _modularExpandable = nice.modularExpandable ?? false;
      _selectedFeatures = nice.features ?? [];
      _additionalRequests = nice.additionalRequests ?? '';
      _additionalRequestsController.text = _additionalRequests;
    }
    
    // Step 8: Final Preferences
    if (data.finalPreferences != null) {
      _selectedWhatMattersMost = data.finalPreferences!.whatMattersMost;
      _washableReplaceableCovers = data.finalPreferences!.washableReplaceableCovers ?? false;
      _ecoFriendly = data.finalPreferences!.ecoFriendly ?? '';
      _changeNoteController.text = data.finalPreferences!.changePreferencesNote ?? '';
    }
  }

  void _saveAndGenerateNewSofa() {
    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    
    // Update audience type if changed
    if (_selectedAudienceType != null) {
      _personalizationController.setAudienceType(_selectedAudienceType!);
    }
    
    // Update usage style data
    final updatedUsageStyle = UsageStyleData(
      // Adult fields
      usagePattern: _selectedUsagePattern,
      firmnessPreference: _selectedFirmnessPreference,
      sofaCapacity: _selectedSofaCapacity,
      seatSupport: _selectedSeatSupport,
      
      // Child fields
      childUsageType: _selectedChildUsageType,
      familyPriority: _selectedFamilyPriority,
      numberOfChildren: _numberOfChildren,
      growthAdaptable: _growthAdaptable,
      
      // Pet health fields
      petType: _selectedPetType,
      customPetName: _customPetNameController.text.isNotEmpty ? _customPetNameController.text : null,
      petSize: _selectedPetSize,
      temperatureSensitivity: _selectedTemperatureSensitivity,
      heightPreference: _selectedHeightPreference,
      
      // Pet usage fields
      numberOfPets: _numberOfPets,
      petSeatingStyle: _selectedPetSeatingStyle,
      petRelaxLocation: _selectedPetRelaxLocation,
      wearLevel: _selectedWearLevel,
      extraPetFriendly: _extraPetFriendly,
    );
    _personalizationController.setUsageStyle(updatedUsageStyle);
    
    // Update style & material data
    final updatedStyleMaterial = StyleMaterialData(
      materialType: _selectedMaterialType,
      functionalityTypes: _selectedFunctionalities.isNotEmpty ? _selectedFunctionalities : null,
    );
    _personalizationController.setStyleMaterial(updatedStyleMaterial);
    
    // Update personalization details
    final updatedDetails = PersonalizationDetails(
      colorHex: _selectedColorHex,
      pantoneCode: _selectedPantoneCode,
      patternType: _selectedPatternType,
      stitchingType: _selectedStitchingType,
      legType: _selectedLegType,
      finishType: _selectedFinishType,
    );
    _personalizationController.setPersonalizationDetails(updatedDetails);
    
    // Update comfort preferences
    final updatedComfort = ComfortPreferences(
      cushionFirmness: _selectedCushionFirmness,
      seatDepth: _selectedSeatDepth,
      backSupport: _backSupport,
      armrests: _armrests,
      headrest: _headrest,
      tallUsers: _tallUsers,
      elderlyFriendly: _elderlyFriendly,
    );
    _personalizationController.setComfortPreferences(updatedComfort);
    
    // Update nice to haves
    final updatedNiceToHaves = NiceToHaves(
      extras: _selectedExtras.isNotEmpty ? _selectedExtras : null,
      modularExpandable: _modularExpandable,
      features: _selectedFeatures.isNotEmpty ? _selectedFeatures : null,
      additionalRequests: _additionalRequestsController.text.isNotEmpty ? _additionalRequestsController.text : null,
    );
    _personalizationController.setNiceToHaves(updatedNiceToHaves);
    
    // Update final preferences
    final updatedPreferences = FinalPreferences(
      whatMattersMost: _selectedWhatMattersMost,
      washableReplaceableCovers: _washableReplaceableCovers,
      ecoFriendly: _ecoFriendly,
      changePreferencesNote: _changeNoteController.text,
    );
    _personalizationController.setFinalPreferences(updatedPreferences);
    
    // Close loading dialog
    Get.back();
    
    // Navigate to results screen
    Get.off(() => const PersonalizationResultsScreen());
    
    // Show success message
    Get.snackbar(
      'Preferences Updated', 
      'Your personalization preferences have been updated successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: kOffBlack,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        title: Text('Edit Personalization', style: kNunitoSans16.copyWith(fontWeight: FontWeight.w600,color: kOffBlack)),
        backgroundColor: kBackgroundBeige,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kOffBlack),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comprehensive Current Personalization Summary
            Container(
              width: double.infinity,
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
                      Icon(Icons.person_outline, color: kOffBlack, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Complete Personalization',
                        style: kNunitoSans18.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kOffBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildPersonalizationSection(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Step 1: Audience Type Section
            _buildSectionTitle('Step 1: Who is this sofa for?'),
            _buildAudienceTypeChoice(),
            const SizedBox(height: 24),
            
            // Step 2: Usage Style Sections (Conditional based on audience)
            if (_selectedAudienceType == AudienceType.adult) ...[
              _buildSectionTitle('Step 2: Adult Usage Style'),
              _buildUsagePatternSection(),
              const SizedBox(height: 16),
              _buildFirmnessSection(),
              const SizedBox(height: 16),
              _buildCapacitySection(),
              const SizedBox(height: 16),
              _buildSeatSupportSection(),
              const SizedBox(height: 24),
            ],
            
            if (_selectedAudienceType == AudienceType.child) ...[
              _buildSectionTitle('Step 2: Child Usage Style'),
              _buildChildUsageSection(),
              const SizedBox(height: 16),
              _buildFamilyPrioritySection(),
              const SizedBox(height: 16),
              _buildNumberOfChildrenSection(),
              const SizedBox(height: 16),
              _buildGrowthAdaptableSection(),
              const SizedBox(height: 24),
            ],
            
            if (_selectedAudienceType == AudienceType.pet) ...[
              _buildSectionTitle('Step 2A: Pet Health Information'),
              _buildPetTypeSection(),
              const SizedBox(height: 16),
              _buildPetSizeSection(),
              const SizedBox(height: 16),
              _buildTemperatureSection(),
              const SizedBox(height: 16),
              _buildHeightPreferenceSection(),
              const SizedBox(height: 16),
              
              _buildSectionTitle('Step 2B: Pet Usage Style'),
              _buildNumberOfPetsSection(),
              const SizedBox(height: 16),
              _buildPetSeatingStyleSection(),
              const SizedBox(height: 16),
              _buildPetRelaxLocationSection(),
              const SizedBox(height: 16),
              _buildWearLevelSection(),
              const SizedBox(height: 16),
              _buildExtraPetFriendlySection(),
              const SizedBox(height: 24),
            ],
            
            // Step 3: Style & Material Section
            _buildSectionTitle('Step 3: Style & Material Preferences'),
            _buildMaterialTypeSection(),
            const SizedBox(height: 16),
            _buildFunctionalitiesSection(),
            const SizedBox(height: 24),
            
            // Step 4: Color, Pattern & Details Section
            _buildSectionTitle('Step 4: Color, Pattern & Details'),
            _buildColorSection(),
            const SizedBox(height: 16),
            _buildPatternSection(),
            const SizedBox(height: 16),
            _buildStitchingSection(),
            const SizedBox(height: 16),
            _buildLegTypeSection(),
            const SizedBox(height: 16),
            _buildFinishSection(),
            const SizedBox(height: 24),
            
            // Step 5: Room Photo (Display only)
            if (_roomPhotoPath != null) ...[
              _buildSectionTitle('Step 5: Room Photo'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.photo, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Room photo uploaded',
                        style: kNunitoSans14.copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Step 6: Comfort Preferences Section
            _buildSectionTitle('Step 6: Comfort Preferences'),
            _buildCushionFirmnessSection(),
            const SizedBox(height: 16),
            _buildSeatDepthSection(),
            const SizedBox(height: 16),
            _buildComfortFeaturesSection(),
            const SizedBox(height: 24),
            
            // Step 7: Nice to Haves Section
            _buildSectionTitle('Step 7: Nice to Haves'),
            _buildExtrasSection(),
            const SizedBox(height: 16),
            _buildModularSection(),
            const SizedBox(height: 16),
            _buildFeaturesSection(),
            const SizedBox(height: 16),
            _buildAdditionalRequestsSection(),
            const SizedBox(height: 24),
            
            // Step 8: Final Preferences Section
            _buildSectionTitle('Step 8: Final Preferences'),
            Text('What matters most to you?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildSingleChoice(
              selectedValue: _selectedWhatMattersMost,
              options: ['Comfort', 'Style', 'Durability', 'Price', 'Sustainability'],
              onChanged: (value) => setState(() => _selectedWhatMattersMost = value),
            ),
            const SizedBox(height: 16),
            
            // Washable/Replaceable covers
            CheckboxListTile(
              title: Text('Washable/Replaceable covers important?', style: kNunitoSans14),
              value: _washableReplaceableCovers,
              onChanged: (value) => setState(() => _washableReplaceableCovers = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            
            // Eco-friendly dropdown
            Text('Eco-friendly materials importance:', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildSingleChoice(
              selectedValue: _ecoFriendly,
              options: ['Important', 'Neutral', 'Not important'],
              onChanged: (value) => setState(() => _ecoFriendly = value ?? ''),
            ),
            const SizedBox(height: 16),
            
            // Change preferences note
            Text('Any specific changes you\'d like?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _changeNoteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us what you\'d like to change about your current preferences...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: kOffBlack),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Generate Sofa Button
            CustomElevatedButton(
              onTap: _saveAndGenerateNewSofa,
              text: 'Generate New Sofa',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizationSection() {
    final data = _personalizationController.personalizationData;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Audience Type
        if (data.audienceType != null) 
          _buildInfoRow(
            'Audience',
            _getAudienceTypeName(data.audienceType!),
            Icons.people,
          ),
        
        // Usage Style Information
        if (data.usageStyle != null) ...[
          _buildInfoRow(
            'Usage Style',
            _getUsageStyleName(data.usageStyle!),
            Icons.weekend,
          ),
          
          if (data.usageStyle!.firmnessPreference != null)
            _buildInfoRow(
              'Firmness',
              _getFirmnessName(data.usageStyle!.firmnessPreference!),
              Icons.airline_seat_recline_normal,
            ),
          
          if (data.usageStyle!.sofaCapacity != null)
            _buildInfoRow(
              'Capacity',
              _getCapacityName(data.usageStyle!.sofaCapacity!),
              Icons.group,
            ),
        ],
        
        // Style & Material Information
        if (data.styleMaterial != null) ...[
          if (data.styleMaterial!.materialType != null)
            _buildInfoRow(
              'Material',
              _getMaterialTypeName(data.styleMaterial!.materialType!),
              Icons.texture,
            ),
          
          if (data.styleMaterial!.functionalityTypes != null && 
              data.styleMaterial!.functionalityTypes!.isNotEmpty)
            _buildInfoRow(
              'Features',
              data.styleMaterial!.functionalityTypes!
                .map((f) => _getFunctionalityName(f))
                .join(', '),
              Icons.settings,
            ),
        ],
        
        // Personalization Details
        if (data.personalizationDetails != null) ...[
          if (data.personalizationDetails!.colorHex != null)
            _buildColorRow(
              'Selected Color',
              data.personalizationDetails!.colorHex!,
            ),
          
          if (data.personalizationDetails!.patternType != null)
            _buildInfoRow(
              'Pattern',
              _getPatternName(data.personalizationDetails!.patternType!),
              Icons.pattern,
            ),
          
          if (data.personalizationDetails!.stitchingType != null)
            _buildInfoRow(
              'Stitching',
              _getStitchingName(data.personalizationDetails!.stitchingType!),
              Icons.content_cut,
            ),
          
          if (data.personalizationDetails!.legType != null)
            _buildInfoRow(
              'Leg Style',
              _getLegTypeName(data.personalizationDetails!.legType!),
              Icons.table_restaurant,
            ),
        ],
        
        // Comfort Preferences
        if (data.comfortPreferences != null) ...[
          if (data.comfortPreferences!.backSupport != null)
            _buildInfoRow(
              'Back Support',
              data.comfortPreferences!.backSupport! ? 'Yes' : 'No',
              Icons.event_seat,
            ),
          
          if (data.comfortPreferences!.cushionFirmness != null)
            _buildInfoRow(
              'Cushion Firmness',
              data.comfortPreferences!.cushionFirmness!,
              Icons.texture,
            ),
          
          if (data.comfortPreferences!.seatDepth != null)
            _buildInfoRow(
              'Seat Depth',
              data.comfortPreferences!.seatDepth!,
              Icons.straighten,
            ),
        ],
        
        // Pet Information (if pet audience)
        if (data.audienceType == AudienceType.pet && data.usageStyle != null) ...[
          if (data.usageStyle!.petType != null)
            _buildInfoRow(
              'Pet Type',
              _getPetTypeName(data.usageStyle!.petType!),
              Icons.pets,
            ),
          
          if (data.usageStyle!.petSize != null)
            _buildInfoRow(
              'Pet Size',
              _getPetSizeName(data.usageStyle!.petSize!),
              Icons.straighten,
            ),
          
          if (data.usageStyle!.temperatureSensitivity != null)
            _buildInfoRow(
              'Temperature',
              _getTemperatureName(data.usageStyle!.temperatureSensitivity!),
              Icons.thermostat,
            ),
        ],
        
        // Final Preferences
        if (data.finalPreferences != null) ...[
          if (data.finalPreferences!.whatMattersMost != null)
            _buildInfoRow(
              'Priority',
              data.finalPreferences!.whatMattersMost!,
              Icons.star,
            ),
          
          _buildInfoRow(
            'Washable Covers',
            data.finalPreferences!.washableReplaceableCovers == true ? 'Important' : 'Not Important',
            Icons.local_laundry_service,
          ),
          
          if (data.finalPreferences!.ecoFriendly != null && data.finalPreferences!.ecoFriendly!.isNotEmpty)
            _buildInfoRow(
              'Eco-Friendly',
              data.finalPreferences!.ecoFriendly!,
              Icons.eco,
            ),
          
          if (data.finalPreferences!.changePreferencesNote != null && 
              data.finalPreferences!.changePreferencesNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kOffBlack.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note, color: kOffBlack, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Special Notes',
                        style: kNunitoSans12Grey.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kOffBlack,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.finalPreferences!.changePreferencesNote!,
                    style: kNunitoSans12Grey.copyWith(
                      color: kOffBlack,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: kOffBlack, size: 18),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: kNunitoSans12Grey.copyWith(
                fontWeight: FontWeight.w500,
                color: kOffBlack,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: kNunitoSans12Grey.copyWith(
                color: kOffBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(String label, String colorHex) {
    Color color;
    try {
      color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      color = Colors.grey;
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.palette, color: kOffBlack, size: 18),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: kNunitoSans12Grey.copyWith(
                fontWeight: FontWeight.w500,
                color: kOffBlack,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  colorHex,
                  style: kNunitoSans12Grey.copyWith(
                    color: kOffBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods to get display names
  String _getAudienceTypeName(AudienceType type) {
    switch (type) {
      case AudienceType.adult:
        return 'Adult';
      case AudienceType.child:
        return 'Child';
      case AudienceType.pet:
        return 'Pet';
    }
  }

  String _getUsageStyleName(UsageStyleData usage) {
    if (usage.usagePattern != null) {
      switch (usage.usagePattern!) {
        case UsagePattern.lounging:
          return 'Lounging & Relaxation';
        case UsagePattern.formalHosting:
          return 'Formal Hosting';
        case UsagePattern.familyLiving:
          return 'Family Living';
      }
    }
    if (usage.childUsageType != null) {
      switch (usage.childUsageType!) {
        case ChildUsageType.readingQuiet:
          return 'Reading & Quiet Time';
        case ChildUsageType.playtimeTV:
          return 'Playtime & TV';
        case ChildUsageType.napRest:
          return 'Nap & Rest';
      }
    }
    if (usage.petSeatingStyle != null) {
      switch (usage.petSeatingStyle!) {
        case PetSeatingStyle.layingDown:
          return 'Laying Down';
        case PetSeatingStyle.sitting:
          return 'Sitting';
        case PetSeatingStyle.standing:
          return 'Standing';
      }
    }
    return 'Custom Style';
  }

  String _getFirmnessName(FirmnessPreference firmness) {
    switch (firmness) {
      case FirmnessPreference.soft:
        return 'Soft';
      case FirmnessPreference.balanced:
        return 'Balanced';
      case FirmnessPreference.firm:
        return 'Firm';
    }
  }

  String _getCapacityName(SofaCapacity capacity) {
    switch (capacity) {
      case SofaCapacity.two:
        return '2 Seater';
      case SofaCapacity.three:
        return '3 Seater';
      case SofaCapacity.fourPlus:
        return '4+ People';
      case SofaCapacity.sectional:
        return 'Sectional';
    }
  }

  String _getMaterialTypeName(MaterialType material) {
    switch (material) {
      case MaterialType.fullGrain:
        return 'Full Grain Leather';
      case MaterialType.semiAniline:
        return 'Semi-Aniline Leather';
      case MaterialType.nubuck:
        return 'Nubuck Leather';
      case MaterialType.pu:
        return 'PU Leather';
      case MaterialType.cotton:
        return 'Cotton Fabric';
      case MaterialType.linen:
        return 'Linen Fabric';
      case MaterialType.velvet:
        return 'Luxury Velvet';
      case MaterialType.alcantara:
        return 'Alcantara';
      case MaterialType.ecoFabric:
        return 'Eco-Friendly Fabric';
    }
  }

  String _getFunctionalityName(FunctionalityType functionality) {
    switch (functionality) {
      case FunctionalityType.waterproof:
        return 'Waterproof';
      case FunctionalityType.flameRetardant:
        return 'Flame Retardant';
      case FunctionalityType.antibacterial:
        return 'Antibacterial';
      case FunctionalityType.petResistant:
        return 'Pet Resistant';
    }
  }

  String _getPatternName(PatternType pattern) {
    switch (pattern) {
      case PatternType.check:
        return 'Check';
      case PatternType.herringbone:
        return 'Herringbone';
      case PatternType.jacquard:
        return 'Jacquard';
      case PatternType.stripe:
        return 'Stripe';
    }
  }

  String _getStitchingName(StitchingType stitching) {
    switch (stitching) {
      case StitchingType.double:
        return 'Double Stitch';
      case StitchingType.contrast:
        return 'Contrast Stitch';
      case StitchingType.hand:
        return 'Hand Stitch';
    }
  }

  String _getLegTypeName(LegType leg) {
    switch (leg) {
      case LegType.walnut:
        return 'Walnut Wood';
      case LegType.oak:
        return 'Oak Wood';
      case LegType.ash:
        return 'Ash Wood';
      case LegType.steel:
        return 'Steel';
      case LegType.bronze:
        return 'Bronze';
    }
  }

  // BackSupport and SeatHeight are String fields, not enums

  String _getTemperatureName(TemperatureSensitivity temperature) {
    switch (temperature) {
      case TemperatureSensitivity.getscold:
        return 'Gets Cold';
      case TemperatureSensitivity.overheats:
        return 'Overheats';
      case TemperatureSensitivity.normal:
        return 'Normal';
    }
  }

  String _getPetTypeName(PetType pet) {
    switch (pet) {
      case PetType.dog:
        return 'Dog';
      case PetType.cat:
        return 'Cat';
      case PetType.other:
        return 'Other Pet';
    }
  }

  String _getPetSizeName(PetSize size) {
    switch (size) {
      case PetSize.small:
        return 'Small';
      case PetSize.medium:
        return 'Medium';
      case PetSize.large:
        return 'Large';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: kNunitoSans16.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAudienceTypeChoice() {
    final audienceOptions = {
      AudienceType.adult: 'Adult',
      AudienceType.child: 'Child',
      AudienceType.pet: 'Pet',
    };
    
    return Column(
      children: audienceOptions.entries.map((entry) {
        final isSelected = _selectedAudienceType == entry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedAudienceType = entry.key),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? kOffBlack : kChristmasSilver,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? kOffBlack : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: kNunitoSans14.copyWith(
                        color: isSelected ? Colors.white : kOffBlack,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleChoice({
    required String? selectedValue,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedValue == option ? kOffBlack : kChristmasSilver,
                  width: selectedValue == option ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: selectedValue == option ? kOffBlack : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    selectedValue == option ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: selectedValue == option ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: kNunitoSans14.copyWith(
                        color: selectedValue == option ? Colors.white : kOffBlack,
                        fontWeight: selectedValue == option ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }



  // Step 2 Adult Usage Style Sections
  Widget _buildUsagePatternSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How do you plan to use your sofa?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<UsagePattern>(
          selectedValue: _selectedUsagePattern,
          options: UsagePattern.values,
          getDisplayName: (pattern) {
            switch (pattern) {
              case UsagePattern.lounging: return 'Lounging & Relaxation';
              case UsagePattern.formalHosting: return 'Formal Hosting';
              case UsagePattern.familyLiving: return 'Family Living';
            }
          },
          onChanged: (value) => setState(() => _selectedUsagePattern = value),
        ),
      ],
    );
  }

  Widget _buildFirmnessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Firmness preference?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<FirmnessPreference>(
          selectedValue: _selectedFirmnessPreference,
          options: FirmnessPreference.values,
          getDisplayName: (firmness) {
            switch (firmness) {
              case FirmnessPreference.soft: return 'Soft';
              case FirmnessPreference.balanced: return 'Balanced';
              case FirmnessPreference.firm: return 'Firm';
            }
          },
          onChanged: (value) => setState(() => _selectedFirmnessPreference = value),
        ),
      ],
    );
  }

  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sofa capacity?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<SofaCapacity>(
          selectedValue: _selectedSofaCapacity,
          options: SofaCapacity.values,
          getDisplayName: (capacity) {
            switch (capacity) {
              case SofaCapacity.two: return '2 Seater';
              case SofaCapacity.three: return '3 Seater';
              case SofaCapacity.fourPlus: return '4+ People';
              case SofaCapacity.sectional: return 'Sectional';
            }
          },
          onChanged: (value) => setState(() => _selectedSofaCapacity = value),
        ),
      ],
    );
  }

  Widget _buildSeatSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seat support preference?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<SeatSupport>(
          selectedValue: _selectedSeatSupport,
          options: SeatSupport.values,
          getDisplayName: (support) {
            switch (support) {
              case SeatSupport.lumbarSupport: return 'Lumbar Support';
              case SeatSupport.extraDeep: return 'Extra Deep';
              case SeatSupport.standard: return 'Standard';
            }
          },
          onChanged: (value) => setState(() => _selectedSeatSupport = value),
        ),
      ],
    );
  }

  // Step 2 Child Usage Style Sections
  Widget _buildChildUsageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How will the child use the sofa?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<ChildUsageType>(
          selectedValue: _selectedChildUsageType,
          options: ChildUsageType.values,
          getDisplayName: (usage) {
            switch (usage) {
              case ChildUsageType.readingQuiet: return 'Reading & Quiet Time';
              case ChildUsageType.playtimeTV: return 'Playtime & TV';
              case ChildUsageType.napRest: return 'Nap & Rest';
            }
          },
          onChanged: (value) => setState(() => _selectedChildUsageType = value),
        ),
      ],
    );
  }

  Widget _buildFamilyPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Family priority?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<FamilyPriority>(
          selectedValue: _selectedFamilyPriority,
          options: FamilyPriority.values,
          getDisplayName: (priority) {
            switch (priority) {
              case FamilyPriority.easyClean: return 'Easy to Clean';
              case FamilyPriority.edgeSoftness: return 'Edge Softness';
              case FamilyPriority.standardComfort: return 'Standard Comfort';
            }
          },
          onChanged: (value) => setState(() => _selectedFamilyPriority = value),
        ),
      ],
    );
  }

  Widget _buildNumberOfChildrenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of children?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildSingleChoice(
          selectedValue: _numberOfChildren?.toString(),
          options: ['1', '2', '3', '4+'],
          onChanged: (value) => setState(() => _numberOfChildren = value != null ? 
            (value == '4+' ? 4 : int.tryParse(value)) : null),
        ),
      ],
    );
  }

  Widget _buildGrowthAdaptableSection() {
    return CheckboxListTile(
      title: Text('Growth adaptable features?', style: kNunitoSans14),
      value: _growthAdaptable,
      onChanged: (value) => setState(() => _growthAdaptable = value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Step 2 Pet Health Sections
  Widget _buildPetTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pet type?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<PetType>(
          selectedValue: _selectedPetType,
          options: PetType.values,
          getDisplayName: (type) {
            switch (type) {
              case PetType.dog: return 'Dog';
              case PetType.cat: return 'Cat';
              case PetType.other: return 'Other Pet';
            }
          },
          onChanged: (value) => setState(() => _selectedPetType = value),
        ),
        if (_selectedPetType == PetType.other) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _customPetNameController,
            decoration: InputDecoration(
              hintText: 'Please specify pet type...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPetSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pet size?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<PetSize>(
          selectedValue: _selectedPetSize,
          options: PetSize.values,
          getDisplayName: (size) {
            switch (size) {
              case PetSize.small: return 'Small';
              case PetSize.medium: return 'Medium';
              case PetSize.large: return 'Large';
            }
          },
          onChanged: (value) => setState(() => _selectedPetSize = value),
        ),
      ],
    );
  }

  Widget _buildTemperatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temperature sensitivity?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<TemperatureSensitivity>(
          selectedValue: _selectedTemperatureSensitivity,
          options: TemperatureSensitivity.values,
          getDisplayName: (temp) {
            switch (temp) {
              case TemperatureSensitivity.getscold: return 'Gets Cold';
              case TemperatureSensitivity.overheats: return 'Overheats';
              case TemperatureSensitivity.normal: return 'Normal';
            }
          },
          onChanged: (value) => setState(() => _selectedTemperatureSensitivity = value),
        ),
      ],
    );
  }

  Widget _buildHeightPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Height preference?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<HeightPreference>(
          selectedValue: _selectedHeightPreference,
          options: HeightPreference.values,
          getDisplayName: (height) {
            switch (height) {
              case HeightPreference.lowRise: return 'Low Rise';
              case HeightPreference.plushPremium: return 'Plush Premium';
            }
          },
          onChanged: (value) => setState(() => _selectedHeightPreference = value),
        ),
      ],
    );
  }

  // Step 2B Pet Usage Sections
  Widget _buildNumberOfPetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of pets?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildSingleChoice(
          selectedValue: _numberOfPets?.toString(),
          options: ['1', '2', '3', '4+'],
          onChanged: (value) => setState(() => _numberOfPets = value != null ? 
            (value == '4+' ? 4 : int.tryParse(value)) : null),
        ),
      ],
    );
  }

  Widget _buildPetSeatingStyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pet seating style?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<PetSeatingStyle>(
          selectedValue: _selectedPetSeatingStyle,
          options: PetSeatingStyle.values,
          getDisplayName: (style) {
            switch (style) {
              case PetSeatingStyle.layingDown: return 'Laying Down';
              case PetSeatingStyle.sitting: return 'Sitting';
              case PetSeatingStyle.standing: return 'Standing';
            }
          },
          onChanged: (value) => setState(() => _selectedPetSeatingStyle = value),
        ),
      ],
    );
  }

  Widget _buildPetRelaxLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Where does your pet prefer to relax?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<PetRelaxLocation>(
          selectedValue: _selectedPetRelaxLocation,
          options: PetRelaxLocation.values,
          getDisplayName: (location) {
            switch (location) {
              case PetRelaxLocation.besideFloor: return 'Beside/Floor';
              case PetRelaxLocation.sofaCushions: return 'Sofa Cushions';
              case PetRelaxLocation.armrestsBackrest: return 'Armrests/Backrest';
              case PetRelaxLocation.bed: return 'Bed';
              case PetRelaxLocation.hiddenSpace: return 'Hidden Space';
            }
          },
          onChanged: (value) => setState(() => _selectedPetRelaxLocation = value),
        ),
      ],
    );
  }

  Widget _buildWearLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expected wear level?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<WearLevel>(
          selectedValue: _selectedWearLevel,
          options: WearLevel.values,
          getDisplayName: (wear) {
            switch (wear) {
              case WearLevel.low: return 'Low';
              case WearLevel.moderate: return 'Moderate';
              case WearLevel.high: return 'High';
            }
          },
          onChanged: (value) => setState(() => _selectedWearLevel = value),
        ),
      ],
    );
  }

  Widget _buildExtraPetFriendlySection() {
    return CheckboxListTile(
      title: Text('Extra pet-friendly features?', style: kNunitoSans14),
      value: _extraPetFriendly,
      onChanged: (value) => setState(() => _extraPetFriendly = value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Step 3 Style & Material Sections
  Widget _buildMaterialTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Material preference?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<MaterialType>(
          selectedValue: _selectedMaterialType,
          options: MaterialType.values,
          getDisplayName: (material) {
            switch (material) {
              case MaterialType.fullGrain: return 'Full Grain Leather';
              case MaterialType.semiAniline: return 'Semi-Aniline Leather';
              case MaterialType.nubuck: return 'Nubuck Leather';
              case MaterialType.pu: return 'PU Leather';
              case MaterialType.cotton: return 'Cotton Fabric';
              case MaterialType.linen: return 'Linen Fabric';
              case MaterialType.velvet: return 'Luxury Velvet';
              case MaterialType.alcantara: return 'Alcantara';
              case MaterialType.ecoFabric: return 'Eco-Friendly Fabric';
            }
          },
          onChanged: (value) => setState(() => _selectedMaterialType = value),
        ),
      ],
    );
  }

  Widget _buildFunctionalitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional functionalities?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ...FunctionalityType.values.map((functionality) {
          final isSelected = _selectedFunctionalities.contains(functionality);
          return CheckboxListTile(
            title: Text(_getFunctionalityName(functionality), style: kNunitoSans14),
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedFunctionalities.add(functionality);
                } else {
                  _selectedFunctionalities.remove(functionality);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  // Step 4 Color, Pattern & Details Sections
  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color (Hex Code)?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _selectedColorHex,
          onChanged: (value) => setState(() => _selectedColorHex = value.isNotEmpty ? value : null),
          decoration: InputDecoration(
            hintText: '#FFFFFF',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pattern preference?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<PatternType>(
          selectedValue: _selectedPatternType,
          options: PatternType.values,
          getDisplayName: (pattern) {
            switch (pattern) {
              case PatternType.check: return 'Check';
              case PatternType.herringbone: return 'Herringbone';
              case PatternType.jacquard: return 'Jacquard';
              case PatternType.stripe: return 'Stripe';
            }
          },
          onChanged: (value) => setState(() => _selectedPatternType = value),
        ),
      ],
    );
  }

  Widget _buildStitchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stitching type?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<StitchingType>(
          selectedValue: _selectedStitchingType,
          options: StitchingType.values,
          getDisplayName: (stitching) {
            switch (stitching) {
              case StitchingType.double: return 'Double Stitch';
              case StitchingType.contrast: return 'Contrast Stitch';
              case StitchingType.hand: return 'Hand Stitch';
            }
          },
          onChanged: (value) => setState(() => _selectedStitchingType = value),
        ),
      ],
    );
  }

  Widget _buildLegTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leg style?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<LegType>(
          selectedValue: _selectedLegType,
          options: LegType.values,
          getDisplayName: (leg) {
            switch (leg) {
              case LegType.walnut: return 'Walnut Wood';
              case LegType.oak: return 'Oak Wood';
              case LegType.ash: return 'Ash Wood';
              case LegType.steel: return 'Steel';
              case LegType.bronze: return 'Bronze';
            }
          },
          onChanged: (value) => setState(() => _selectedLegType = value),
        ),
      ],
    );
  }

  Widget _buildFinishSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Finish type?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildEnumChoice<FinishType>(
          selectedValue: _selectedFinishType,
          options: FinishType.values,
          getDisplayName: (finish) {
            switch (finish) {
              case FinishType.matte: return 'Matte';
              case FinishType.gloss: return 'Gloss';
              case FinishType.oil: return 'Oil';
            }
          },
          onChanged: (value) => setState(() => _selectedFinishType = value),
        ),
      ],
    );
  }

  // Step 6 Comfort Preference Sections
  Widget _buildCushionFirmnessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cushion firmness?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildSingleChoice(
          selectedValue: _selectedCushionFirmness,
          options: ['Soft', 'Medium', 'Firm'],
          onChanged: (value) => setState(() => _selectedCushionFirmness = value),
        ),
      ],
    );
  }

  Widget _buildSeatDepthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seat depth preference?', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildSingleChoice(
          selectedValue: _selectedSeatDepth,
          options: ['Shallow', 'Standard', 'Deep'],
          onChanged: (value) => setState(() => _selectedSeatDepth = value),
        ),
      ],
    );
  }

  Widget _buildComfortFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comfort features:', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: Text('Back support', style: kNunitoSans14),
          value: _backSupport,
          onChanged: (value) => setState(() => _backSupport = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Armrests', style: kNunitoSans14),
          value: _armrests,
          onChanged: (value) => setState(() => _armrests = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Headrest', style: kNunitoSans14),
          value: _headrest,
          onChanged: (value) => setState(() => _headrest = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Tall user friendly', style: kNunitoSans14),
          value: _tallUsers,
          onChanged: (value) => setState(() => _tallUsers = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Elderly friendly', style: kNunitoSans14),
          value: _elderlyFriendly,
          onChanged: (value) => setState(() => _elderlyFriendly = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  // Step 7 Nice to Haves Sections
  Widget _buildExtrasSection() {
    final availableExtras = [
      'Built-in USB ports',
      'Cup holders',
      'Storage compartments',
      'Reclining mechanism',
      'Massage function',
      'Heating elements',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Extra features:', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ...availableExtras.map((extra) {
          final isSelected = _selectedExtras.contains(extra);
          return CheckboxListTile(
            title: Text(extra, style: kNunitoSans14),
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedExtras.add(extra);
                } else {
                  _selectedExtras.remove(extra);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildModularSection() {
    return CheckboxListTile(
      title: Text('Modular/Expandable design?', style: kNunitoSans14),
      value: _modularExpandable,
      onChanged: (value) => setState(() => _modularExpandable = value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFeaturesSection() {
    final availableFeatures = [
      'Removable covers',
      'Stain resistant',
      'Anti-microbial',
      'Fire retardant',
      'Hypoallergenic',
      'Scratch resistant',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional features:', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ...availableFeatures.map((feature) {
          final isSelected = _selectedFeatures.contains(feature);
          return CheckboxListTile(
            title: Text(feature, style: kNunitoSans14),
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedFeatures.add(feature);
                } else {
                  _selectedFeatures.remove(feature);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAdditionalRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional requests:', style: kNunitoSans14.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _additionalRequestsController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any additional requests or specifications...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  // Generic enum choice builder
  Widget _buildEnumChoice<T>({
    required T? selectedValue,
    required List<T> options,
    required String Function(T) getDisplayName,
    required Function(T?) onChanged,
  }) {
    return Column(
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedValue == option ? kOffBlack : kChristmasSilver,
                  width: selectedValue == option ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: selectedValue == option ? kOffBlack : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    selectedValue == option ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: selectedValue == option ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      getDisplayName(option),
                      style: kNunitoSans14.copyWith(
                        color: selectedValue == option ? Colors.white : kOffBlack,
                        fontWeight: selectedValue == option ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _changeNoteController.dispose();
    _customPetNameController.dispose();
    _additionalRequestsController.dispose();
    super.dispose();
  }
}