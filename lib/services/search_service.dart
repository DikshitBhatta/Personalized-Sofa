import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<List<Map<String, dynamic>>> searchProduct(String query) async {
    final snapshot = await _firestore
        .collection('Products')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
