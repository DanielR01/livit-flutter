import 'package:flutter/foundation.dart';
import 'package:livit/models/location/product/location_product.dart';

class ProductService {
  Future<List<LocationProduct>> getProductsByLocationId(String locationId) async {
    try {
      debugPrint('🛠️ [ProductService] Getting products by location id: $locationId');
      final products = await LocationProduct.getCollectionReference(locationId).get();
      debugPrint('✅ [ProductService] Products loaded: ${products.docs.length}');
      return products.docs.map((doc) => doc.data() as LocationProduct).toList();
    } catch (e) {
      debugPrint('❌ [ProductService] Error getting products by location id: $e');
      rethrow;
    }
  }

  Future<void> addProduct(LocationProduct product) async {
    try {
      debugPrint('📥 [ProductService] Adding product: $product');
      final productCollection = LocationProduct.getCollectionReference(product.locationId);
      await productCollection.add(product);
    } catch (e) {
      debugPrint('❌ [ProductService] Error adding product: $e');
      rethrow;
    }
  }
}
