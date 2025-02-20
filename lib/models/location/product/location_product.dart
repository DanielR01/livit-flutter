import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:livit/models/location/product/product_media.dart';
import 'package:livit/models/price/price.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/locations_exceptions.dart';

class LocationProduct {
  final String id;
  final String locationId;
  final String name;
  final String description;
  final ProductMedia media;
  final LivitPrice price;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final int stock;

  LocationProduct({
    required this.id,
    required this.locationId,
    required this.name,
    required this.description,
    required this.media,
    required this.price,
    required this.createdAt,
    this.updatedAt,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'name': name,
      'description': description,
      'media': media.toMap(),
      'price': price.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? createdAt,
      'stock': stock,
    };
  }

  factory LocationProduct.fromDocument(DocumentSnapshot doc) {
    try {
      debugPrint('📦 [LocationProduct] Creating location product from document: ${doc.id}');
      final data = doc.data() as Map<String, dynamic>;
      final locationProduct = LocationProduct(
        id: doc.id,
        locationId: data['locationId'] as String,
        name: data['name'] as String,
        description: data['description'] as String,
        media: ProductMedia.fromList(data['media'] as List<dynamic>),
        price: LivitPrice.fromMap(data['price'] as Map<String, dynamic>),
        createdAt: data['createdAt'] as Timestamp,
        updatedAt: data['updatedAt'] as Timestamp?,
        stock: data['stock'] as int,
      );
      debugPrint('📥 [LocationProduct] Location product created from document: ${locationProduct.name}');
      return locationProduct;
    } catch (e) {
      debugPrint('❌ [LocationProduct] Failed to create location product from document: $e');
      throw CouldNotCreateLocationProductFromDocumentException(details: e.toString());
    }
  }

  static DocumentReference getReference(String locationId, String productId) {
    return FirebaseFirestore.instance.collection('locations').doc(locationId).collection('products').doc(productId);
  }

  static CollectionReference getCollectionReference(String locationId) {
    return FirebaseFirestore.instance.collection('locations').doc(locationId).collection('products').withConverter<LocationProduct>(
          fromFirestore: (snapshot, options) => LocationProduct.fromDocument(snapshot),
          toFirestore: (locationProduct, options) => locationProduct.toMap(),
        );
  }

  LocationProduct copyWith({
    String? id,
    String? locationId,
    String? name,
    String? description,
    ProductMedia? media,
    LivitPrice? price,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    int? stock,
  }) {
    return LocationProduct(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      description: description ?? this.description,
      media: media ?? this.media,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stock: stock ?? this.stock,
    );
  }

  @override
  String toString() {
    return 'LocationProduct(id: $id, locationId: $locationId, name: $name, description: $description, price: $price, createdAt: $createdAt, updatedAt: $updatedAt, stock: $stock)';
  }
}
