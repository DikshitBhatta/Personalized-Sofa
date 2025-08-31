import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/models/product.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var selectedCategory = 0.obs;
  var productsList = <Product>[].obs;

  Future<void> changeCategory(int categoryId) async {
    if (selectedCategory.value == categoryId) return;
    selectedCategory.value = categoryId;
    await getProducts(categoryId);
  }

  Future<void> getProducts(int categoryId) async {
    Query query = _firestore.collection('Products');
    if (categoryId != 0) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    final snapshot = await query.get();
    productsList.value = snapshot.docs
        .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
