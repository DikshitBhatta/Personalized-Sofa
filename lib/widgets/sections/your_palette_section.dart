import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/widgets/input/color_pattern_selector.dart';

class YourPaletteSection extends StatefulWidget {
  const YourPaletteSection({super.key});

  @override
  State<YourPaletteSection> createState() => _YourPaletteSectionState();
}

class _YourPaletteSectionState extends State<YourPaletteSection> {
  List<Color> _paletteColors = [
    const Color(0xFFD7B49E),
    const Color(0xFFC19A7D),
    const Color(0xFF8B6F47),
    const Color(0xFF6B5437),
    const Color(0xFF5D4E37),
  ];

  @override
  void initState() {
    super.initState();
    _loadPaletteColors();
  }
  
  @override
  void didUpdateWidget(YourPaletteSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload colors when widget rebuilds (e.g., when coming back to home screen)
    _loadPaletteColors();
  }

  void _loadPaletteColors() {
    try {
      if (Get.isRegistered<PersonalizationController>()) {
        final controller = Get.find<PersonalizationController>();
        
        if (controller.recommendedColorHex.isNotEmpty) {
          // Parse the hex color
          final hexColor = controller.recommendedColorHex.replaceAll('#', '');
          final color = Color(int.parse('FF$hexColor', radix: 16));
          
          // Create palette colors (5 variations from lighter to darker)
          final hslColor = HSLColor.fromColor(color);
          
          if (mounted) {
            setState(() {
              _paletteColors = [
                hslColor.withLightness(0.75).withSaturation((hslColor.saturation * 0.8).clamp(0.0, 1.0)).toColor(),
                hslColor.withLightness(0.65).withSaturation((hslColor.saturation * 0.9).clamp(0.0, 1.0)).toColor(),
                color, // Base color
                hslColor.withLightness(0.40).withSaturation((hslColor.saturation * 1.1).clamp(0.0, 1.0)).toColor(),
                hslColor.withLightness(0.30).withSaturation((hslColor.saturation * 1.2).clamp(0.0, 1.0)).toColor(),
              ];
            });
          }
          
          print('🎨 Loaded palette colors from: ${controller.recommendedColorHex}');
        }
      }
    } catch (e) {
      print('⚠️ Error loading palette colors: $e');
    }
  }

  void _showColorPickerDialog() {
    try {
      final controller = Get.find<PersonalizationController>();
      String? selectedColorHex = controller.recommendedColorHex;
      
      showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: kLynxWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Your Color',
                      style: kNunitoSansSemiBold18.copyWith(
                        color: kOffBlack,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Color Picker
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ColorPicker(
                    selectedColorHex: selectedColorHex,
                    selectedPantoneCode: null,
                    recommendedColorHex: controller.recommendedColorHex,
                    onColorSelected: (colorHex) {
                      setModalState(() {
                        selectedColorHex = colorHex;
                      });
                    },
                    onPantoneCodeChanged: (pantoneCode) {
                      // Not needed for this use case
                    },
                  ),
                ),
              ),
              
              // Save Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedColorHex != null && selectedColorHex!.isNotEmpty) {
                        try {
                          // Get controller
                          final controller = Get.find<PersonalizationController>();
                          
                          // Get current user
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            // Update the recommended color AND manual edit flag in Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                                  'recommended_color_hex': selectedColorHex,
                                  'is_color_manually_edited': true, // Mark as manually edited
                                }, SetOptions(merge: true));
                            
                            // Update the controller's reactive value directly
                            // This will trigger all widgets observing this value to rebuild
                            controller.updateRecommendedColorHex(selectedColorHex!);
                            
                            // Close dialog first
                            Navigator.pop(context);
                            
                            // Reload palette colors after a short delay to ensure controller is updated
                            await Future.delayed(const Duration(milliseconds: 100));
                            setState(() {
                              _loadPaletteColors();
                            });
                            
                            // Show success message
                            Get.snackbar(
                              'Color Updated',
                              'Your palette has been updated successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withOpacity(0.8),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(20),
                              borderRadius: 10,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        } catch (e) {
                          print('Error updating color: $e');
                          Get.snackbar(
                            'Error',
                            'Failed to update color. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(20),
                            borderRadius: 10,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kOffBlack,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: kNunitoSansSemiBold16.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
          },
        );
      },
    );
    } catch (e) {
      print('Error opening color picker: $e');
      Get.snackbar(
        'Error',
        'Unable to open color picker. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(20),
        borderRadius: 10,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalizationController>(
      builder: (controller) {
        // Recalculate palette colors whenever controller updates
        if (controller.recommendedColorHex.isNotEmpty) {
          final hexColor = controller.recommendedColorHex.replaceAll('#', '');
          final color = Color(int.parse('FF$hexColor', radix: 16));
          final hslColor = HSLColor.fromColor(color);
          
          _paletteColors = [
            hslColor.withLightness(0.75).withSaturation((hslColor.saturation * 0.8).clamp(0.0, 1.0)).toColor(),
            hslColor.withLightness(0.65).withSaturation((hslColor.saturation * 0.9).clamp(0.0, 1.0)).toColor(),
            color, // Base color
            hslColor.withLightness(0.40).withSaturation((hslColor.saturation * 1.1).clamp(0.0, 1.0)).toColor(),
            hslColor.withLightness(0.30).withSaturation((hslColor.saturation * 1.2).clamp(0.0, 1.0)).toColor(),
          ];
        }
        
        return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kLynxWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Edit button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your palette today',
                    style: kNunitoSansSemiBold18.copyWith(
                      color: kOffBlack,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalized for you',
                    style: kNunitoSans14.copyWith(
                      color: kGraniteGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showColorPickerDialog,
                child: Text(
                  'Edit',
                  style: kNunitoSansSemiBold16.copyWith(
                    color: kOffBlack,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Color swatches
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _paletteColors.map((color) {
              return Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
      },
    );
  }
}
