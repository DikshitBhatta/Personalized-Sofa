import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/controllers/card_details_controller.dart';
import 'package:timberr/models/card_detail.dart';

class AddPaymentController extends GetxController {
  int cardNumber = 0, cvv = 0, month = 0, year = 0;
  var name = "".obs;
  var dateString = "".obs;
  var lastFourDigits = "".obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CardDetailsController _cardDetailsController = Get.find();

  Future<void> addCardDetail() async {
    final docRef = _firestore.collection("card_details").doc();
    await docRef.set({
      "id": docRef.id,
      "cardholder_name": name.value,
      "card_number": cardNumber,
      "month": month,
      "year": year,
      "user_id": _auth.currentUser!.uid
    });

    if (_cardDetailsController.cardDetailList.isEmpty) {
      _cardDetailsController.selectedIndex.value = 0;
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        'default_card_detail_id': docRef.id
      });
    }

    _cardDetailsController.cardDetailList.add(
      CardDetail(
        id: docRef.id,
        cardHolderName: name.value,
        cardNumber: cardNumber.toString(),
        expiryDate: '$month/$year',
        cvvCode: cvv.toString(),
      ),
    );
    Get.back();
  }
}
