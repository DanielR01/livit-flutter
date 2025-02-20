import 'package:flutter/foundation.dart';
import 'package:livit/models/product_sale/product_sale.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';

class ProductSaleService {
  final Collections collections = Collections();

  // Future<List<LivitProductSale>> getProductsSalesByLocationId(String locationId) async {
  //   try {
  //     debugPrint('🛠️ [ProductSaleService] Getting products sales by location id: $locationId');
  //     final products = await LivitProductSale.getCollectionReference().where('locationId', isEqualTo: locationId).get();
  //     debugPrint('✅ [ProductSaleService] Products sales loaded: ${products.docs.length}');
  //     return products.docs.map((doc) => doc.data()).toList();
  //   } catch (e) {
  //     debugPrint('❌ [ProductService] Error getting products by location id: $e');
  //     rethrow;
  //   }
  // }
  Future<List<LivitProductSale>> getProductsSalesByLocationIdAndProductId(String locationId, String productId) async {
    try {
      debugPrint('🛠️ [ProductSaleService] Getting products sales by location id: $locationId and product id: $productId');
      final products = await collections.productSalesCollection(locationId).where('productId', isEqualTo: productId).get();
      debugPrint('✅ [ProductSaleService] Products sales loaded: ${products.docs.length}');
      return products.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('❌ [ProductService] Error getting products by location id: $e');
      rethrow;
    }
  }
}
