import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductFirestore {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('products');

  // Lấy danh sách sản phẩm (Realtime Stream)
  Stream<List<Product>> getProducts() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Thêm sản phẩm mới
  Future<void> addProduct(Product product) {
    return _collection.doc(product.id).set(product.toMap());
  }

  // Cập nhật sản phẩm
  Future<void> updateProduct(Product product) {
    return _collection.doc(product.id).update(product.toMap());
  }

  // Xóa sản phẩm
  Future<void> deleteProduct(String id) {
    return _collection.doc(id).delete();
  }
}