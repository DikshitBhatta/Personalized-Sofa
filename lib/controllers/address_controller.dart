import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/address.dart';
import 'package:timberr/controllers/user_controller.dart';

class AddressController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Address> addressList = [];
  int selectedIndex = 0;

  String name = "", address = "", country = "", city = "", district = "";
  int pincode = 0;
  
  // Location-related properties
  bool isLoadingLocation = false;
  double? currentLatitude;
  double? currentLongitude;
  RxString currentAddress = ''.obs;

  Future<void> fetchAddresses() async {
    final snapshot = await _firestore.collection("addresses").where('user_id', isEqualTo: _auth.currentUser!.uid).get();
    addressList = snapshot.docs.map((doc) => Address.fromJson(doc.data())).toList();
    update();
  }

  Future<void> getDefaultShippingAddress() async {
    final doc = await _firestore.collection("users").doc(_auth.currentUser!.uid).get();
    if (doc.exists) {
      String? defaultShippingId = doc.data()!['default_shipping_id'];
      await fetchAddresses();
      if (defaultShippingId != null) {
        for (int i = 0; i < addressList.length; i++) {
          if (addressList.elementAt(i).id == defaultShippingId) {
            selectedIndex = i;
            update();
            break;
          }
        }
      }
    }
  }

  Future<void> setDefaultShippingAddress(int index) async {
    if (selectedIndex == index) {
      return;
    }
    selectedIndex = index;
    update();
    await _firestore.collection("users").doc(_auth.currentUser!.uid).set({
      'default_shipping_id': addressList.elementAt(index).id
    }, SetOptions(merge: true));
  }

  Future<bool> uploadAddress() async {
    try {
      // Check if user is authenticated
      if (_auth.currentUser == null) {
        print('❌ ERROR: User not authenticated');
        Get.snackbar(
          "Authentication Error",
          "Please log in to save your address.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
        );
        return false;
      }

      print('📍 Starting address upload...');
      print('📍 Address: $address, City: $city, Pincode: $pincode');

      // Note: Loading indicator is shown by the screen, not here
      
      final docRef = _firestore.collection("addresses").doc();
      await docRef.set({
        'id': docRef.id,
        'full_name': name,
        'address': address,
        'pincode': pincode,
        'country': country,
        'city': city,
        'district': district,
        'user_id': _auth.currentUser!.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      print('✅ Address saved to Firestore with ID: ${docRef.id}');

      if (addressList.isEmpty) {
        selectedIndex = 0;
        await _firestore.collection("users").doc(_auth.currentUser!.uid).set({
          'default_shipping_id': docRef.id
        }, SetOptions(merge: true));
        print('✅ Set as default address');
      }

      addressList.add(Address(
        id: docRef.id,
        name: name,
        address: address,
        pincode: pincode,
        country: country,
        city: city,
        district: district,
      ));
      
      print('✅ Address added to local list. Total addresses: ${addressList.length}');
      
      // No need to close dialog - screen handles loading indicator
      
      // Clear the form fields for next use
      _clearFormFields();
      print('✅ Form fields cleared');
      
      print('✅ Address upload completed successfully - ready to return true');
      return true;
      
    } catch (e, stackTrace) {
      // No dialog to close - screen handles loading indicator
      
      print('❌ ERROR uploading address: $e');
      print('❌ Stack trace: $stackTrace');
      
      String errorMessage;
      if (e.toString().contains('permission-denied')) {
        errorMessage = "Permission denied. Please check your account permissions or contact support.";
      } else if (e.toString().contains('network')) {
        errorMessage = "Network error. Please check your internet connection and try again.";
      } else {
        errorMessage = "Failed to save address. Please try again.";
      }
      
      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 5),
      );
      
      return false;
    }
  }

  Future<void> editAddress(int index, String addressId) async {
    Address newAddress = Address(
      id: addressId,
      name: name,
      address: address,
      pincode: pincode,
      country: country,
      city: city,
      district: district,
    );

    await _firestore.collection("addresses").doc(addressId).update(newAddress.toJson());
    addressList[index] = newAddress;
    update();
    Get.back();
  }

  Future<void> deleteAddress(int index) async {
    if (index == selectedIndex) {
      if (addressList.length == 1) {
        await kDefaultDialog("Error", "Add a different address before removing this one");
        return;
      } else {
        selectedIndex = 0;
        await setDefaultShippingAddress((index == 0) ? 1 : 0);
      }
    }

    await _firestore.collection("addresses").doc(addressList.elementAt(index).id).delete();
    addressList.removeAt(index);
    update();
  }

  // Location-related methods
  Future<bool> _checkLocationPermission() async {
    // First check system permission
    PermissionStatus systemPermission = await Permission.location.status;
    
    if (systemPermission.isDenied) {
      systemPermission = await Permission.location.request();
      if (systemPermission.isDenied) {
        return false;
      }
    }
    
    if (systemPermission.isPermanentlyDenied) {
      // Show dialog to go to app settings
      kDefaultDialog(
        "Location Permission Required",
        "Please enable location permission in app settings to use this feature.",
        onYesPressed: () {
          Get.back();
          openAppSettings();
        },
      );
      return false;
    }
    
    // Also check Geolocator permission
    LocationPermission geoPermission = await Geolocator.checkPermission();
    
    if (geoPermission == LocationPermission.denied) {
      geoPermission = await Geolocator.requestPermission();
      if (geoPermission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (geoPermission == LocationPermission.deniedForever) {
      // Show dialog to go to app settings
      kDefaultDialog(
        "Location Permission Required",
        "Please enable location permission in app settings to use this feature.",
        onYesPressed: () {
          Get.back();
          openAppSettings();
        },
      );
      return false;
    }
    
    return true;
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation = true;
      update();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          "Location Service Disabled",
          "Please enable location services to use this feature.",
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoadingLocation = false;
        update();
        return;
      }

      // Check permissions
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        isLoadingLocation = false;
        update();
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      currentLatitude = position.latitude;
      currentLongitude = position.longitude;

      // Reverse geocoding
      await _reverseGeocode(position.latitude, position.longitude);
      
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to get current location: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingLocation = false;
      update();
    }
  }

  Future<void> _reverseGeocode(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Debug logging to understand address components
        print('=== Address Components Debug ===');
        print('Name: ${place.name}');
        print('Street (subThoroughfare + thoroughfare): ${place.subThoroughfare} ${place.thoroughfare}');
        print('Locality (city): ${place.locality}');
        print('SubLocality (area): ${place.subLocality}');
        print('AdministrativeArea (state): ${place.administrativeArea}');
        print('SubAdministrativeArea (district): ${place.subAdministrativeArea}');
        print('PostalCode: ${place.postalCode}');
        print('Country: ${place.country}');
        print('Thoroughfare (street name): ${place.thoroughfare}');
        print('SubThoroughfare (street number): ${place.subThoroughfare}');
        print('================================');
        
        // Build detailed street address using suggested approach
        address = _buildDetailedAddressString(place);
        
        // Set city - prefer locality, fall back to subAdministrativeArea
        city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? "";
        
        // Set district - use subAdministrativeArea as suggested
        district = place.subAdministrativeArea ?? place.subLocality ?? place.thoroughfare ?? "";
        
        // Set country
        country = place.country ?? "";
        
        // Build full address string as suggested
        String fullAddress = '';
        List<String> addressParts = [];
        
        if (address.isNotEmpty) addressParts.add(address);
        if (district.isNotEmpty) addressParts.add(district);
        if (city.isNotEmpty) addressParts.add(city);
        if (country.isNotEmpty) addressParts.add(country);
        
        fullAddress = addressParts.join(', ');
        currentAddress.value = fullAddress;
        
        print('Final parsed address:');
        print('Street Address: $address');
        print('District: $district');
        print('City: $city');
        print('Country: $country');
        print('Full Address: $fullAddress');
        
        // Try to extract postal code
        String? postalCode = place.postalCode;
        if (postalCode != null && postalCode.isNotEmpty) {
          try {
            pincode = int.parse(postalCode.replaceAll(RegExp(r'[^0-9]'), ''));
          } catch (e) {
            pincode = 0;
          }
        }
        
        // Initialize user name if empty
        if (name.isEmpty) {
          _initializeUserName();
        }
        
        Get.snackbar(
          "Location Found",
          "Address details populated automatically!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSeaGreen.withOpacity(0.8),
          colorText: Colors.white,
        );
        
        update(); // Notify UI to refresh
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
      Get.snackbar(
        "Error",
        "Failed to get address details: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }



  String _buildDetailedAddressString(Placemark place) {
    List<String> addressParts = [];
    
    // Build street address similar to suggested approach
    String street = '';
    if (place.subThoroughfare?.isNotEmpty ?? false) {
      street = place.subThoroughfare!;
    }
    if (place.thoroughfare?.isNotEmpty ?? false) {
      if (street.isNotEmpty) {
        street += ' ${place.thoroughfare}';
      } else {
        street = place.thoroughfare!;
      }
    }
    
    if (street.isNotEmpty) {
      addressParts.add(street);
    }
    
    // Add premise or name if available and different
    if (place.name?.isNotEmpty ?? false) {
      // Only add if it's not the same as thoroughfare or already included
      if (place.name != place.thoroughfare && 
          place.name != place.subThoroughfare &&
          !street.contains(place.name!)) {
        addressParts.add(place.name!);
      }
    }
    
    return addressParts.join(", ");
  }





  Future<void> getLocationFromCoordinates(double latitude, double longitude) async {
    try {
      isLoadingLocation = true;
      update();
      
      currentLatitude = latitude;
      currentLongitude = longitude;
      
      await _reverseGeocode(latitude, longitude);
      
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to get location details: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingLocation = false;
      update();
    }
  }

  // Initialize name from user data
  void initializeUserName() {
    _initializeUserName();
  }

  void _initializeUserName() async {
    if (name.isNotEmpty) return; // Already has a name
    
    try {
      // First try to get from UserController
      final userController = Get.find<UserController>();
      if (userController.userData.name.isNotEmpty) {
        name = userController.userData.name;
        update();
        return;
      }
    } catch (e) {
      // UserController not available, try Firebase directly
      print('UserController not available: $e');
    }
    
    // Fallback to Firebase user data
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      try {
        // First try Firebase Auth display name (quickest)
        if (auth.currentUser!.displayName != null && auth.currentUser!.displayName!.isNotEmpty) {
          name = auth.currentUser!.displayName!;
          update();
          return;
        }
        
        // Then try Firestore user document
        final userDoc = await _firestore.collection('users').doc(auth.currentUser!.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            // Try different possible field names for user name
            String? userName;
            if (userData['name'] != null) {
              userName = userData['name'] as String;
            } else if (userData['fullName'] != null) {
              userName = userData['fullName'] as String;
            } else if (userData['full_name'] != null) {
              userName = userData['full_name'] as String;
            } else if (userData['displayName'] != null) {
              userName = userData['displayName'] as String;
            }
            
            if (userName != null && userName.isNotEmpty) {
              name = userName;
              update();
              return;
            }
          }
        }
        
        // Last resort: use email prefix if no display name
        if (auth.currentUser!.email != null) {
          final emailParts = auth.currentUser!.email!.split('@');
          if (emailParts.isNotEmpty && emailParts[0].isNotEmpty) {
            // Capitalize first letter and replace dots/underscores with spaces
            name = emailParts[0]
                .replaceAll(RegExp(r'[._]'), ' ')
                .split(' ')
                .map((word) => word.isNotEmpty 
                    ? word[0].toUpperCase() + word.substring(1).toLowerCase() 
                    : '')
                .join(' ');
            update();
          }
        }
      } catch (e) {
        print('Error fetching user name from Firebase: $e');
      }
    }
  }

  void clearLocationData() {
    currentLatitude = null;
    currentLongitude = null;
    update();
  }

  // Debug method to check authentication and permissions
  void debugAuthStatus() {
    print('=== Auth Debug Info ===');
    print('Current user: ${_auth.currentUser?.uid}');
    print('Email: ${_auth.currentUser?.email}');
    print('Display name: ${_auth.currentUser?.displayName}');
    print('Email verified: ${_auth.currentUser?.emailVerified}');
    print('========================');
  }

  void setLoading(bool loading) {
    isLoadingLocation = loading;
    update();
  }

  Future<void> getAddressFromCoordinates(double latitude, double longitude) async {
    await getLocationFromCoordinates(latitude, longitude);
  }

  // Clear form fields after successful save
  void _clearFormFields() {
    name = "";
    address = "";
    country = "";
    city = "";
    district = "";
    pincode = 0;
    currentLatitude = null;
    currentLongitude = null;
    currentAddress.value = '';
  }
}
