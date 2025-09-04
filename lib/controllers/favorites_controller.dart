import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/models/product.dart';

class FavoritesController extends GetxController {
  var favoritesList = <Product>[].obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchFavorites() async {
    final doc = await _firestore.collection("users").doc(_auth.currentUser!.uid).get();
    if (doc.exists) {
      List favoritesIds = doc.data()!['favoritesList'] ?? [];
      for (String productId in favoritesIds) {
        final productDoc = await _firestore.collection('Products').doc(productId).get();
        if (productDoc.exists) {
          favoritesList.add(Product.fromJson(productDoc.data()!));
        }
      }
    }
  }

  Future<void> updateDatabase() async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'favoritesList': favoritesList.map((favoriteItem) => favoriteItem.productId).toList()
    });
  }

  Future<void> addProduct(Product product) async {
    favoritesList.add(product);
    await updateDatabase();
  }

  Future<void> removeProduct(Product product) async {
    favoritesList.remove(product);
    await updateDatabase();
  }

  Future<void> removeProductAt(int index) async {
    favoritesList.removeAt(index);
    await updateDatabase();
  }
}
