import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../controllers/personalization_controller.dart';
import '../../models/personalization_data.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Personalization', style: kNunitoSans16.copyWith(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
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
            // Current Personalization Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSeaGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kSeaGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Personalization', style: kNunitoSans16.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (_selectedAudienceType != null)
                    Text('Audience: ${_selectedAudienceType.toString().split('.').last}', style: kNunitoSans14),
                  if (_selectedWhatMattersMost != null)
                    Text('Priority: $_selectedWhatMattersMost', style: kNunitoSans14),
                  Text('Washable Covers: ${_washableReplaceableCovers ? "Important" : "Not important"}', style: kNunitoSans14),
                  Text('Eco-friendly: $_ecoFriendly', style: kNunitoSans14),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAndGenerateNewSofa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSeaGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Generate New Sofa',
                  style: kNunitoSans16.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  color: isSelected ? kSeaGreen : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? kSeaGreen.withOpacity(0.1) : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? kSeaGreen : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: kNunitoSans14.copyWith(
                        color: isSelected ? kSeaGreen : kOffBlack,
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
                  color: selectedValue == option ? kSeaGreen : Colors.grey.shade300,
                  width: selectedValue == option ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: selectedValue == option ? kSeaGreen.withOpacity(0.1) : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    selectedValue == option ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: selectedValue == option ? kSeaGreen : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: kNunitoSans14.copyWith(
                        color: selectedValue == option ? kSeaGreen : kOffBlack,
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