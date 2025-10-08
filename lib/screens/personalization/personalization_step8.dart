import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/screens/personalization/personalization_results_screen.dart';
import 'package:timberr/widgets/pricing/sofa_price_display.dart';
// removed unused import

class PersonalizationStep8Screen extends StatefulWidget {
  const PersonalizationStep8Screen({super.key});

  @override
  State<PersonalizationStep8Screen> createState() => _PersonalizationStep8ScreenState();
}

class _PersonalizationStep8ScreenState extends State<PersonalizationStep8Screen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();

  // Nice to haves fields
  List<String> _selectedExtras = [];
  bool _modularExpandable = false;

  // Available extras
  final List<Map<String, dynamic>> _availableExtras = [
    {'title': 'USB charging ports', 'icon': Icons.usb, 'value': 'usb_charging'},
    {'title': 'Cup holders', 'icon': Icons.local_drink, 'value': 'cup_holders'},
    {'title': 'Hidden storage', 'icon': Icons.inventory_2, 'value': 'hidden_storage'},
    {'title': 'Wireless charging pad', 'icon': Icons.power, 'value': 'wireless_charging'},
    {'title': 'Built-in speakers', 'icon': Icons.speaker, 'value': 'built_in_speakers'},
    {'title': 'LED lighting', 'icon': Icons.lightbulb, 'value': 'led_lighting'},
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final existing = _controller.personalizationData.niceToHaves;
    if (existing != null) {
      _selectedExtras = existing.extras ?? [];
      _modularExpandable = existing.modularExpandable ?? false;
    }
  }

  void _saveNiceToHaves() {
    final niceToHaves = NiceToHaves(
      extras: _selectedExtras,
      modularExpandable: _modularExpandable,
    );
    
    _controller.setNiceToHaves(niceToHaves);
  }

  void _toggleExtra(String extraValue) {
    setState(() {
      if (_selectedExtras.contains(extraValue)) {
        _selectedExtras.remove(extraValue);
      } else {
        _selectedExtras.add(extraValue);
      }
    });
    // Save immediately to update pricing
    _saveNiceToHaves();
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
                        controller.getStepTitle(7),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(7),
                        style: kNunitoSans18.copyWith(color: kGraniteGrey),
                      ),

                      const SizedBox(height: 32),

                      // Extra features
                      Text(
                        "Extra Features",
                        style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Select any additional features you'd like (optional)",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      const SizedBox(height: 16),

                      // Feature grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5, // Reduced from 3 to give more height for 2-line text
                        ),
                        itemCount: _availableExtras.length,
                        itemBuilder: (context, index) {
                          final extra = _availableExtras[index];
                          final isSelected = _selectedExtras.contains(extra['value']);
                          
                          return InkWell(
                            onTap: () => _toggleExtra(extra['value']),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? kOffBlack : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? kOffBlack : kChristmasSilver,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    extra['icon'],
                                    color: isSelected ? Colors.white : kGraniteGrey,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      extra['title'],
                                      style: kNunitoSans14.copyWith(
                                        color: isSelected ? Colors.white : kOffBlack,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12, // Smaller font to fit better
                                      ),
                                      maxLines: 2, // Allow 2 lines
                                      overflow: TextOverflow.ellipsis, // Handle any remaining overflow
                                    ),
                                  ),
                                  if (isSelected)
                                    const SizedBox(width: 8),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Modular/Expandable option
                      Text(
                        "Future Flexibility",
                        style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Consider future needs and expandability",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: const Text("Modular/Expandable design"),
                        subtitle: const Text("Ability to add or rearrange sections later"),
                        value: _modularExpandable,
                        activeColor: kOffBlack,
                        checkColor: Colors.white,
                        onChanged: (value) {
                          setState(() => _modularExpandable = value ?? false);
                          // Save immediately to update pricing
                          _saveNiceToHaves();
                        },
                      ),

                      const SizedBox(height: 32),

                      // Completion message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kOffBlack.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kOffBlack.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.celebration,
                              color: kOffBlack,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "You're all set!",
                                    style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "We'll use all your preferences to find the perfect sofa recommendations just for you.",
                                    style: kNunitoSans14.copyWith(color: kGraniteGrey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                      // Compact pricing display
                      // Compact pricing display
                      const CompactPriceTag(
                        showBreakdown: false,
                      ),                      const SizedBox(height: 24),
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
                          onPressed: () async {
                            _saveNiceToHaves();
                            // Mark extras step complete before finalizing
                            _controller.markStepComplete(7);
                            
                            try {
                              await _controller.completePersonalization();
                              
                              Get.snackbar(
                                "Personalization Complete!",
                                "Your preferences have been saved successfully",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: kOffBlack,
                                colorText: Colors.white,
                              );
                              
                              // Navigate to personalization results screen
                              Get.to(() => const PersonalizationResultsScreen());
                            } catch (e) {
                              Get.snackbar(
                                "Error",
                                "Failed to complete personalization: $e",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          child: Text(
                            "Complete",
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