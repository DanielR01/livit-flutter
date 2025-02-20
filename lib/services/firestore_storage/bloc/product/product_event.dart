part of 'product_bloc.dart';

abstract class ProductEvent {}

class LoadLocationProducts extends ProductEvent {
  final String locationId;
  final bool loadProductSales;
  LoadLocationProducts({required this.locationId, this.loadProductSales = false});
}

class AddProduct extends ProductEvent {
  final LocationProduct product;
  AddProduct({required this.product});
}

class UpdateProduct extends ProductEvent {
  final LocationProduct product;
  UpdateProduct({required this.product});
}

class DeleteProduct extends ProductEvent {
  final String productId;
  DeleteProduct({required this.productId});
}
