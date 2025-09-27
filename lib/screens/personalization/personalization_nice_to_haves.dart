import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/models/personalization_data.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/screens/personalization/personalization_results_screen.dart';

class PersonalizationNiceToHavesScreen extends StatefulWidget {
  const PersonalizationNiceToHavesScreen({super.key});

  @override
  State<PersonalizationNiceToHavesScreen> createState() => _PersonalizationNiceToHavesScreenState();
}

class _PersonalizationNiceToHavesScreenState extends State<PersonalizationNiceToHavesScreen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();

  // Available extras
  final List<String> _availableExtras = [
    'USB charging ports',
    'Cup holders',
    'Hidden storage',
    'Wireless charging pad',
    'LED accent lighting',
    'Built-in side tables',
  ];

  List<String> _selectedExtras = [];
  bool _modularExpandable = false;

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
      extras: _selectedExtras.isNotEmpty ? _selectedExtras : null,
      modularExpandable: _modularExpandable,
    );
    
    _controller.setNiceToHaves(niceToHaves);
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
                        style: kNunitoSans18.copyWith(color: kTinGrey),
                      ),

                      const SizedBox(height: 32),

                      // Extra features section
                      Text(
                        "Extra Features",
                        style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Select any additional features you'd like to consider (all optional)",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      const SizedBox(height: 16),

                      // Extra features list
                      ..._availableExtras.map((extra) => CheckboxListTile(
                        title: Text(extra),
                        value: _selectedExtras.contains(extra),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedExtras.add(extra);
                            } else {
                              _selectedExtras.remove(extra);
                            }
                          });
                        },
                      )).toList(),

                      const SizedBox(height: 24),

                      // Modular design section
                      Text(
                        "Design Flexibility",
                        style: kNunitoSansSemiBold18.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Future expansion and customization options",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile(
                        title: const Text("Modular/Expandable Design"),
                        subtitle: const Text("Ability to add or reconfigure sections later"),
                        value: _modularExpandable,
                        onChanged: (value) => setState(() => _modularExpandable = value ?? false),
                      ),

                      const SizedBox(height: 32),

                      // Summary section
                      if (_selectedExtras.isNotEmpty || _modularExpandable) ...[
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
                            borderRadius: BorderRadius.circular(12),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star, color: kSeaGreen, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Your Selected Extras",
                                    style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_selectedExtras.isNotEmpty) ...[
                                Text(
                                  "Features: ${_selectedExtras.join(', ')}",
                                  style: kNunitoSans14.copyWith(color: kOffBlack),
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (_modularExpandable) ...[
                                Text(
                                  "• Modular/Expandable design for future customization",
                                  style: kNunitoSans14.copyWith(color: kOffBlack),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Optional note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "All extras are optional and can be discussed during your consultation. Ready to complete your personalization!",
                                style: kNunitoSans14.copyWith(color: kOffBlack),
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
                          color: kSeaGreen,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              offset: Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () async {
                            _saveNiceToHaves();
                            try {
                              await _controller.completePersonalization();
                              // Navigate to results screen
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
                            "Complete Personalization",
                            style: kNunitoSansSemiBold16.copyWith(color: Colors.white),
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
