import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';

import 'package:timberr/screens/personalization/personalization_step7.dart';

class PersonalizationStep6Screen extends StatefulWidget {
  const PersonalizationStep6Screen({super.key});

  @override
  State<PersonalizationStep6Screen> createState() => _PersonalizationStep6ScreenState();
}

class _PersonalizationStep6ScreenState extends State<PersonalizationStep6Screen> {
  final PersonalizationController _controller = Get.find<PersonalizationController>();
  final ImagePicker _picker = ImagePicker();

  String? _base64Image;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPhoto();
  }

  void _loadExistingPhoto() {
    final existingPhoto = _controller.personalizationData.roomPhotoPath;
    if (existingPhoto != null && existingPhoto.isNotEmpty) {
      setState(() {
        _base64Image = existingPhoto;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() => _isProcessing = true);
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      _showErrorSnackbar("Failed to take photo: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() => _isProcessing = true);
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      _showErrorSnackbar("Failed to select photo: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      
      setState(() {
        _base64Image = base64String;
      });
      
      _controller.setRoomPhoto(base64String);
      
      Get.snackbar(
        "Photo Added",
        "Room photo has been added successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kSeaGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar("Failed to process image: $e");
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _removePhoto() {
    setState(() {
      _base64Image = null;
    });
    _controller.setRoomPhoto(null);
    
    Get.snackbar(
      "Photo Removed",
      "Room photo has been removed",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildPhotoDisplay() {
    if (_base64Image == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kSnowFlakeWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kChristmasSilver, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 48,
              color: kOffBlack,
            ),
            const SizedBox(height: 12),
            Text(
              "No photo added yet",
              style: kNunitoSans16.copyWith(color: kGraniteGrey),
            ),
            const SizedBox(height: 4),
            Text(
              "Add a photo of your room to get better recommendations",
              style: kNunitoSans12Grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    try {
      final bytes = base64Decode(_base64Image!);
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kChristmasSilver, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.memory(
                bytes,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _removePhoto,
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kSnowFlakeWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            Text(
              "Failed to load photo",
              style: kNunitoSans16.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _removePhoto,
              child: Text(
                "Remove photo",
                style: kNunitoSans14.copyWith(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Add Photo"),
        content: const Text("Choose how you want to add a photo of your room:"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _pickImageFromCamera();
            },
            child: const Text("Take Photo"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _pickImageFromGallery();
            },
            child: const Text("Choose from Gallery"),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
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
                        controller.getStepTitle(5),
                        style: kNunitoSansBold24.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.getStepDescription(5),
                        style: kNunitoSans18.copyWith(color: kGraniteGrey),
                      ),

                      const SizedBox(height: 32),

                      // Photo display
                      _buildPhotoDisplay(),

                      const SizedBox(height: 24),

                      // Add photo button
                      if (_base64Image == null) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _showImageSourceDialog,
                            icon: Icon(
                              _isProcessing ? Icons.hourglass_empty : Icons.add_a_photo,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isProcessing ? "Processing..." : "Add Room Photo",
                              style: kNunitoSansSemiBold16.copyWith(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kOffBlack,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Change photo button
                      if (_base64Image != null) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _showImageSourceDialog,
                            icon: Icon(
                              _isProcessing ? Icons.hourglass_empty : Icons.change_circle,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isProcessing ? "Processing..." : "Change Photo",
                              style: kNunitoSansSemiBold16.copyWith(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kSeaGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Info text
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
                              Icons.info_outline,
                              color: kOffBlack,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Why add a room photo?",
                                    style: kNunitoSansSemiBold16.copyWith(color: kOffBlack,),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "A photo of your room helps us suggest furniture that matches your space, lighting, and existing decor. This step is optional but highly recommended for better personalization.",
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
                            // Mark this optional step as completed only when the user explicitly continues
                            _controller.markStepComplete(5);
                            _controller.nextStep();
                            Get.to(() => const PersonalizationStep7Screen());
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