import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/models/card_detail.dart';

class CardDetailsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var cardDetailList = <CardDetail>[].obs;
  var selectedIndex = 0.obs;

  String getLastFourDigits() {
    if (cardDetailList.isNotEmpty) {
      return cardDetailList
          .elementAt(selectedIndex.value)
          .cardNumber
          .toString()
          .substring(12);
    }
    return "XXXX";
  }

  Future<void> fetchCardDetails() async {
    final snapshot = await _firestore.collection("card_details").where('user_id', isEqualTo: _auth.currentUser!.uid).get();
    cardDetailList.value = snapshot.docs.map((doc) => CardDetail.fromJson(doc.data())).toList();
  }

  Future<void> getDefaultCardDetail() async {
    final doc = await _firestore.collection("users").doc(_auth.currentUser!.uid).get();
    if (doc.exists) {
      String? defaultCardId = doc.data()!['default_card_detail_id'];
      await fetchCardDetails();
      if (defaultCardId != null) {
        for (int i = 0; i < cardDetailList.length; i++) {
          if (cardDetailList.elementAt(i).id == defaultCardId) {
            selectedIndex.value = i;
            break;
          }
        }
      }
    }
  }

  Future<void> setDefaultCardDetail(int index) async {
    if (selectedIndex.value == index) {
      return;
    }
    selectedIndex.value = index;
    await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
      'default_card_detail_id': cardDetailList.elementAt(index).id
    });
  }
}
