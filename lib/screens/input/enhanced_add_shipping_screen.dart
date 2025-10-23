import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/controllers/address_controller.dart';
import 'package:timberr/controllers/user_controller.dart';
import 'package:timberr/screens/input/map_picker_screen.dart';
import 'package:timberr/widgets/buttons/custom_elevated_button.dart';
import 'package:timberr/widgets/input/custom_input_box.dart';

class EnhancedAddShippingScreen extends StatefulWidget {
  const EnhancedAddShippingScreen({super.key});

  @override
  State<EnhancedAddShippingScreen> createState() => _EnhancedAddShippingScreenState();
}

class _EnhancedAddShippingScreenState extends State<EnhancedAddShippingScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddressController _addressController = Get.find();
  final UserController _userController = Get.find();
  bool _isSaving = false; // Flag to prevent rebuilds during save
  
  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _requestLocationAndAutoFill();
  }

  void _initializeUserData() {
    // Initialize name from user data
    if (_userController.userData.name.isNotEmpty) {
      _addressController.name = _userController.userData.name;
    } else {
      // Try to initialize from Firebase if UserController doesn't have name
      _addressController.initializeUserName();
    }
    // Use addPostFrameCallback to avoid calling update during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addressController.update();
    });
  }

  void _requestLocationAndAutoFill() async {
    // Use addPostFrameCallback to avoid calling async operations during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Show a dialog asking for location permission
        bool shouldRequestLocation = await _showLocationPermissionDialog();
        
        if (shouldRequestLocation) {
          // Get current location and auto-fill address fields
          await _addressController.getCurrentLocation();
        }
      } catch (e) {
        print('Error in auto location request: $e');
        // Don't show error to user, just silently continue without location
      }
    });
  }

  Future<bool> _showLocationPermissionDialog() async {
    return await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: kBackgroundBeige,
        title: Row(
          children: [
            const Icon(Icons.location_on, color: kOffBlack, size: 24),
            const SizedBox(width: 8),
            const Text(
              "Use Current Location?",
              style: kMerriweatherBold16,
            ),
          ],
        ),
        content: const Text(
          "We can automatically fill your address details using your current location. This will make it faster to add your shipping address.",
          style: kNunitoSans14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              "Skip",
              style: kNunitoSans14.copyWith(color: kGrey),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              "Use Location",
              style: kNunitoSans14.copyWith(
                color: kOffBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _nameOnChanged(String val) {
    _addressController.name = val;
  }

  String? _nameValidator(String? val) {
    if (val?.isEmpty ?? true) {
      return "Please enter your name";
    }
    return null;
  }

  void _addressOnChanged(String val) {
    _addressController.address = val;
  }

  String? _addressValidator(String? val) {
    if (val?.isEmpty ?? true) {
      return "Please enter the address";
    }
    return null;
  }

  void _pincodeOnChanged(String val) {
    if (val.isNotEmpty) {
      try {
        _addressController.pincode = int.parse(val);
      } catch (e) {
        _addressController.pincode = 0;
      }
    }
  }

  String? _pincodeValidator(String? val) {
    if (val?.isEmpty ?? true) {
      return "Please enter your pincode";
    } else if (!val!.isNum) {
      return "Please enter a valid pincode";
    } else if (val.length < 4 || val.length > 6) {
      return "Pincode must be 4-6 digits long";
    }
    return null;
  }

  void _countryOnChanged(String val) {
    _addressController.country = val;
  }

  String? _countryValidator(String? val) {
    if (val?.isEmpty ?? true) {
      return "Please enter the country";
    }
    return null;
  }

  void _cityOnChanged(String val) {
    _addressController.city = val;
  }

  String? _cityValidator(String? val) {
    if (val?.isEmpty ?? true) {
      return "Please enter the city";
    }
    return null;
  }

  void _districtOnChanged(String val) {
    _addressController.district = val;
  }

  String? _districtValidator(String? val) {
    if (val?.isEmpty ?? true) {
      return "Please enter the district";
    }
    return null;
  }

  Future<void> _uploadAddress() async {
    print('🔵 _uploadAddress called');
    
    if (_formKey.currentState!.validate()) {
      print('🔵 Form is valid, calling controller.uploadAddress()');
      
      // Set flag to prevent rebuilds
      setState(() {
        _isSaving = true;
      });
      
      // Call the controller method and await the result
      bool success = await _addressController.uploadAddress();
      
      print('🔵 uploadAddress returned: $success');
      
      if (success && mounted) {
        print('🔵 Success! Navigating back...');
        
        // Navigate back immediately - this pops current screen from stack
        Navigator.of(context).pop();
        print('🔵 Navigator.pop() called - should return to shipping address screen');
        
        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 200), () {
          if (Get.isSnackbarOpen != true) {
            Get.snackbar(
              "Success",
              "Address saved successfully!",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: kSeaGreen.withOpacity(0.8),
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        });
        
      } else {
        print('❌ Upload failed or widget unmounted, staying on current screen');
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } else {
      print('❌ Form validation failed');
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Get.to<Map<String, dynamic>>(
      () => const MapPickerScreen(),
      transition: Transition.cupertino,
    );
    
    if (result != null) {
      final lat = result['latitude'] as double;
      final lng = result['longitude'] as double;
      
      _addressController.setLoading(true);
      await _addressController.getAddressFromCoordinates(lat, lng);
      _addressController.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBeige,
      appBar: AppBar(
        backgroundColor: kBackgroundBeige,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kOffBlack,
            size: 20,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "ADD SHIPPING ADDRESS",
          style: kMerriweatherBold16,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: _isSaving 
              ? const Center(child: CircularProgressIndicator()) 
              : GetBuilder<AddressController>(
              builder: (controller) => Column(
                children: [
                  // Location status and map picker
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kIvoryGradientLight,
                          kIvoryGradientMid,
                          kIvoryGradientDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: kIvoryGradientDark.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kIvoryGradientDark.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Status message when location is detected
                        // if (controller.currentLatitude != null && controller.currentLongitude != null)
                        //   Container(
                        //     width: double.infinity,
                        //     padding: const EdgeInsets.all(12),
                        //     margin: const EdgeInsets.only(bottom: 12),
                        //     decoration: BoxDecoration(
                        //       color: kSeaGreen.withOpacity(0.1),
                        //       borderRadius: BorderRadius.circular(8),
                        //       border: Border.all(color: kSeaGreen.withOpacity(0.3)),
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Icon(Icons.check_circle, color: kSeaGreen, size: 16),
                        //         const SizedBox(width: 8),
                        //         Expanded(
                        //           child: Text(
                        //             "Location detected! Address fields auto-filled.",
                        //             style: kNunitoSansSemiBold12.copyWith(color: kSeaGreen),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        
                        // Map picker button
                        OutlinedButton.icon(
                          onPressed: controller.isLoadingLocation ? null : _openMapPicker,
                          icon: controller.isLoadingLocation
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(kOffBlack),
                                  ),
                                )
                              : const Icon(Icons.map, color: kOffBlack),
                          label: Text(
                            controller.isLoadingLocation 
                              ? "Getting your location..." 
                              : controller.currentLatitude != null 
                                ? "Change Location on Map"
                                : "Pick Location on Map",
                            style: kNunitoSansSemiBold16.copyWith(color: kOffBlack),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            foregroundColor: kOffBlack,
                            side: BorderSide(color: kOffBlack),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Form fields - Using unique keys to force rebuild when GPS data changes
                  CustomInputBox(
                    key: Key('name_${controller.name}_${controller.currentLatitude ?? 0}'),
                    headerText: "Full name",
                    hintText: "Ex: John Doe",
                    initialValue: controller.name,
                    textInputType: TextInputType.name,
                    onChanged: _nameOnChanged,
                    validator: _nameValidator,
                  ),
                  
                  CustomInputBox(
                    key: Key('address_${controller.address}_${controller.currentLatitude ?? 0}'),
                    headerText: "Address",
                    hintText: "Ex: 87 Church Street",
                    initialValue: controller.address,
                    textInputType: TextInputType.streetAddress,
                    onChanged: _addressOnChanged,
                    validator: _addressValidator,
                  ),
                  
                  CustomInputBox(
                    key: Key('zipcode_${controller.pincode}_${controller.currentLatitude ?? 0}'),
                    headerText: "Zipcode (Postal Code)",
                    hintText: "Ex: 600014",
                    initialValue: controller.pincode > 0 ? controller.pincode.toString() : "",
                    maxLength: 6,
                    textInputType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: _pincodeOnChanged,
                    validator: _pincodeValidator,
                  ),
                  
                  CustomInputBox(
                    key: Key('country_${controller.country}_${controller.currentLatitude ?? 0}'),
                    headerText: "Country",
                    hintText: "Ex: India",
                    initialValue: controller.country,
                    textInputType: TextInputType.text,
                    onChanged: _countryOnChanged,
                    validator: _countryValidator,
                  ),
                  
                  CustomInputBox(
                    key: Key('city_${controller.city}_${controller.currentLatitude ?? 0}'),
                    headerText: "City",
                    hintText: "Ex: Chennai",
                    initialValue: controller.city,
                    textInputType: TextInputType.text,
                    onChanged: _cityOnChanged,
                    validator: _cityValidator,
                  ),
                  
                  CustomInputBox(
                    key: Key('district_${controller.district}_${controller.currentLatitude ?? 0}'),
                    headerText: "District",
                    hintText: "Ex: Mylapore",
                    initialValue: controller.district,
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: _districtOnChanged,
                    validator: _districtValidator,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  CustomElevatedButton(
                    onTap: _uploadAddress,
                    text: "SAVE ADDRESS",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}