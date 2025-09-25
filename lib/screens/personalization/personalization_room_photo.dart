import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/personalization_controller.dart';
import 'package:timberr/widgets/progress/personalization_progress_bar.dart';
import 'package:timberr/screens/personalization/personalization_final_preferences.dart';

class PersonalizationRoomPhotoScreen extends StatefulWidget {
  const PersonalizationRoomPhotoScreen({super.key});

  @override
  State<PersonalizationRoomPhotoScreen> createState() => _PersonalizationRoomPhotoScreenState();
}

class _PersonalizationRoomPhotoScreenState extends State<PersonalizationRoomPhotoScreen> {
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
      Get.snackbar(
        "Camera Error",
        "Failed to take photo: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
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
      Get.snackbar(
        "Gallery Error",
        "Failed to select photo: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processImage(XFile image) async {
    try {
      final File imageFile = File(image.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final String base64String = base64Encode(imageBytes);
      
      setState(() {
        _base64Image = base64String;
      });
      
      // Save immediately to controller
      _controller.setRoomPhoto(base64String);
      
      Get.snackbar(
        "Photo Added",
        "Room photo has been saved successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kSeaGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Processing Error",
        "Failed to process image: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _base64Image = null;
    });
    _controller.setRoomPhoto(null);
  }

  Widget _buildPhotoPreview() {
    if (_base64Image != null) {
      try {
        final Uint8List imageBytes = base64Decode(_base64Image!);
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kSeaGreen, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Image.memory(
                  imageBytes,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _removePhoto,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } catch (e) {
        return Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red),
          ),
          child: const Center(
            child: Text("Invalid image data"),
          ),
        );
      }
    }
    
    return const SizedBox.shrink();
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
                        style: kNunitoSans18.copyWith(color: kTinGrey),
                      ),

                      const SizedBox(height: 32),

                      // Photo preview if exists
                      if (_base64Image != null) ...[
                        Text(
                          "Current Room Photo",
                          style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                        ),
                        const SizedBox(height: 12),
                        _buildPhotoPreview(),
                        const SizedBox(height: 24),
                      ],

                      // Photo capture options
                      Text(
                        _base64Image == null ? "Add Room Photo" : "Update Room Photo",
                        style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Upload a photo of your room to help us recommend the perfect sofa size and style. This helps with color coordination and space planning.",
                        style: kNunitoSans14.copyWith(color: kGrey),
                      ),
                      const SizedBox(height: 20),

                      // Camera and gallery buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: kSeaGreen),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _isProcessing ? null : _pickImageFromCamera,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: _isProcessing ? kGrey : kSeaGreen,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Camera",
                                        style: kNunitoSans14.copyWith(
                                          color: _isProcessing ? kGrey : kSeaGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                border: Border.all(color: kSeaGreen),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _isProcessing ? null : _pickImageFromGallery,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_library,
                                        color: _isProcessing ? kGrey : kSeaGreen,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Gallery",
                                        style: kNunitoSans14.copyWith(
                                          color: _isProcessing ? kGrey : kSeaGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_isProcessing) ...[
                        const SizedBox(height: 20),
                        const Center(
                          child: CircularProgressIndicator(color: kSeaGreen),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Processing image...",
                            style: kNunitoSans14.copyWith(color: kGrey),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Optional note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kSeaGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kSeaGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: kSeaGreen, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "This step is optional. You can skip it and continue with your personalization.",
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
                          border: Border.all(color: kChristmasSilver),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton(
                          onPressed: _isProcessing ? null : () {
                            _controller.nextStep();
                            Get.to(() => const PersonalizationFinalPreferencesScreen());
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
