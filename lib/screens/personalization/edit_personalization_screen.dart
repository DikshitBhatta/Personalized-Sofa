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
  
  // Current data variables
  AudienceType? _selectedAudienceType;
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
    
    _selectedAudienceType = data.audienceType;
    
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
      backgroundColor: kSeaGreen,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        title: Text('Edit Personalization', style: kNunitoSans16.copyWith(fontWeight: FontWeight.w600)),
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
                      Icon(Icons.person_outline, color: kSeaGreen, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Your Complete Personalization',
                        style: kNunitoSans18.copyWith(
                          fontWeight: FontWeight.w700,
                          color: kSeaGreen,
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
            
            // Audience Type Section
            _buildSectionTitle('Who is this sofa for?'),
            _buildAudienceTypeChoice(),
            const SizedBox(height: 24),
            
            // Final Preferences Section
            _buildSectionTitle('What matters most to you?'),
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
                  borderSide: BorderSide(color: kSeaGreen),
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
                border: Border.all(color: kSeaGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.note, color: kSeaGreen, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Special Notes',
                        style: kNunitoSans12Grey.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kSeaGreen,
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
          Icon(icon, color: kSeaGreen, size: 18),
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
                color: kSeaGreen,
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
          Icon(Icons.palette, color: kSeaGreen, size: 18),
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
                    color: kSeaGreen,
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



  @override
  void dispose() {
    _changeNoteController.dispose();
    super.dispose();
  }
}