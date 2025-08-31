import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/address.dart';

class AddressController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Address> addressList = [];
  int selectedIndex = 0;

  String name = "", address = "", country = "", city = "", district = "";
  int pincode = 0;

  Future<void> fetchAddresses() async {
    final snapshot = await _firestore.collection("Addresses").where('user_id', isEqualTo: _auth.currentUser!.uid).get();
    addressList = snapshot.docs.map((doc) => Address.fromJson(doc.data())).toList();
    update();
  }

  Future<void> getDefaultShippingAddress() async {
    final doc = await _firestore.collection("Users").doc(_auth.currentUser!.uid).get();
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
    await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
      'default_shipping_id': addressList.elementAt(index).id
    });
  }

  Future<void> uploadAddress() async {
    final docRef = _firestore.collection("Addresses").doc();
    await docRef.set({
      'id': docRef.id,
      'full_name': name,
      'address': address,
      'pincode': pincode,
      'country': country,
      'city': city,
      'district': district,
      'user_id': _auth.currentUser!.uid,
    });

    if (addressList.isEmpty) {
      selectedIndex = 0;
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).update({
        'default_shipping_id': docRef.id
      });
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
    update();
    Get.back();
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

    await _firestore.collection("Addresses").doc(addressId).update(newAddress.toJson());
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

    await _firestore.collection("Addresses").doc(addressList.elementAt(index).id).delete();
    addressList.removeAt(index);
    update();
  }
}
