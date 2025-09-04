import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timberr/models/product.dart';

class HomeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var selectedCategory = 0.obs;
  var productsList = <Product>[].obs;
  var isLoading = false.obs;

  Future<void> changeCategory(int categoryId) async {
    if (selectedCategory.value == categoryId) return;
    selectedCategory.value = categoryId;
    await getProducts(categoryId);
  }

  Future<void> getProducts(int categoryId) async {
    try {
      isLoading.value = true;
      Query query = _firestore.collection('Products');
      if (categoryId != 0) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      final snapshot = await query.get();
      productsList.value = snapshot.docs
          .map((doc) => Product.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      // Keep existing products if fetch fails
      if (productsList.isEmpty) {
        productsList.value = [];
      }
      rethrow; // Re-throw to let caller handle if needed
    } finally {
      isLoading.value = false;
    }
  }
}
