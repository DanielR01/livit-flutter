import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:livit/models/location/product/product_media.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';

class LocationProduct {
  final String id;
  final String name;
  final String description;
  final ProductMedia media;
  final double price;

  LocationProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.media,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'media': media.toMap(),
      'price': price,
    };
  }

  factory LocationProduct.fromDocument(DocumentSnapshot doc) {
    try {
      debugPrint('📦 [LocationProduct] Creating location product from document');
      final data = doc.data() as Map<String, dynamic>;
      final locationProduct = LocationProduct(
        id: doc.id,
        name: data['name'] as String,
        description: data['description'] as String,
        media: ProductMedia.fromList(data['media'] as List<dynamic>),
        price: data['price'] as double,
      );
      debugPrint('📥 [LocationProduct] Location product created from document: ${locationProduct.name}');
      return locationProduct;
    } catch (e) {
      debugPrint('❌ [LocationProduct] Failed to create location product from document: $e');
      throw CouldNotCreateLocationProductFromDocumentException(details: e.toString());
    }
  }
}
