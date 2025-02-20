part of 'product_bloc.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<LocationProduct> products;
  final Map<String, LoadingState> loadingStates;
  final Map<String, LivitException>? errors;
  final Map<LocationProduct, List<LivitProductSale>>? productSales;

  ProductsLoaded({required this.products, required this.loadingStates, this.errors, this.productSales});
}

